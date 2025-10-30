import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/repositories/i_voting_dialog_repository.dart';
import '../../domain/failures/voting_failure.dart';
import '../../domain/entities/dialog/vote_expansion_request.dart';
import '../../domain/entities/dialog/weight.dart';
import '../extensions/firestore_error_extensions.dart';
import '../extensions/vote_expansion_request_extensions.dart';
import '../extensions/weight_extensions.dart';
import '../extensions/vote_extensions.dart';
import '../../../../core/utils/idempotency_service.dart';
import '../../../../core/utils/shard_utils.dart';
import '../../../../services/cache/unified_cache_service.dart';

/// Implementation of Dialog voting repository
///
/// **Firebase-Centric Architecture v1.0**:
/// - Implements IVotingDialogRepository interface
/// - Firebase SDK 직접 사용 (IVotingRemoteDataSource 제거)
/// - Extension을 통한 Firestore ↔ Domain 변환
/// - Either<Failure, T>로 에러 처리 통합
/// - UnifiedCacheService for 3-Layer caching
///
/// **Dependencies**:
/// - FirebaseFirestore: Firebase SDK 직접 주입
/// - UnifiedCacheService: 3-Layer cache (Memory → Hive → Firestore)
///
/// **Removed Dependencies** (from Clean Architecture v4.0):
/// - ❌ IVotingRemoteDataSource: Firebase 직접 사용으로 대체
/// - ❌ IVotingLocalDataSource: UnifiedCacheService로 대체 (Phase 2)
/// - ❌ IVoteStatePort: Moved to Coordinator
/// - ❌ INotificationDataPort: Moved to App layer
/// - ❌ IVoteUIDelegate: Moved to Presentation layer
class VotingDialogRepositoryImpl implements IVotingDialogRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;
  final IdempotencyService _idempotencyService;
  final ShardUtils _shardUtils;

  VotingDialogRepositoryImpl({
    required FirebaseFirestore firestore,
    IdempotencyService? idempotencyService,
    ShardUtils? shardUtils,
  })  : _firestore = firestore,
        _idempotencyService =
            idempotencyService ?? IdempotencyService(firestore: firestore),
        _shardUtils = shardUtils ?? ShardUtils(firestore: firestore);

  // ============================================================================
  // Basic Vote Operations (CRUD)
  // ============================================================================

  @override
  Future<Either<VotingFailure, void>> castVote({
    required String postId,
    required String userId,
    required String voteOption,
    String? messageId,
    String? chatId,
    String? eventId, // 🆕 Idempotency를 위한 eventId
  }) async {
    try {
      // eventId가 없으면 자동 생성
      final actualEventId = eventId ?? const Uuid().v4();

      if (kDebugMode) {
        print(
            '[DialogRepo] castVote started: postId=$postId, choice=$voteOption, eventId=$actualEventId');
      }

      // ✅ Idempotency + Sharded Counter 적용
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'votes',
        entityId: postId,
        userId: userId,
        eventId: actualEventId,
        operation: (transaction) async {
          // 1. Posts 업데이트
          final postRef = _firestore.collection('posts').doc(postId);
          final postDoc = await transaction.get(postRef);

          if (!postDoc.exists) {
            throw Exception('게시물을 찾을 수 없습니다');
          }

          // 중복 투표 확인 (Transaction 내부에서 안전)
          // Note: IdempotencyService가 이미 eventId 기반 체크를 했지만,
          // 배열 중복도 확인 (backward compatibility)
          final postData = postDoc.data() as Map<String, dynamic>;
          final votedUsersA =
              List<String>.from(postData['votedUserIDsA'] ?? []);
          final votedUsersB =
              List<String>.from(postData['votedUserIDsB'] ?? []);

          if (votedUsersA.contains(userId) ||
              votedUsersB.contains(userId)) {
            throw Exception('이미 투표하셨습니다');
          }

          // 투표 필드 업데이트 (Backward Compatibility)
          final updates = <String, dynamic>{
            'votedUserIDs$voteOption': FieldValue.arrayUnion([userId]),
            'lastVoteAt': FieldValue.serverTimestamp(),
          };

          transaction.update(postRef, updates);

          // ✨ Sharded Counter 증가
          final field = 'votes$voteOption';
          _shardUtils.incrementShard(
            transaction,
            counterType: 'vote',
            entityId: postId,
            userId: userId,
            field: field,
          );
          _shardUtils.incrementShard(
            transaction,
            counterType: 'vote',
            entityId: postId,
            userId: userId,
            field: 'totalVotes',
          );

          // 1.5 votes 서브컬렉션에 투표 문서 생성
          final voteRef = postRef.collection('votes').doc(userId);
          transaction.set(voteRef, {
            'user': _firestore.doc('users/$userId'),
            'option': voteOption,
            'eventId': actualEventId,
            'createdAt': FieldValue.serverTimestamp(),
            'fromChat': messageId != null && chatId != null,
          });

          // 2. Messages 업데이트 (있는 경우)
          if (messageId != null && chatId != null) {
            final messageRef = _firestore
                .collection('chats')
                .doc(chatId)
                .collection('messages')
                .doc(messageId);

            final messageDoc = await transaction.get(messageRef);

            if (messageDoc.exists) {
              transaction.update(messageRef, {
                'userVotes.$userId': {
                  'option': voteOption,
                  'votedAt': FieldValue.serverTimestamp(),
                },
                'lastVoteUpdate': FieldValue.serverTimestamp(),
              });
            }
          }
        },
      );

      if (kDebugMode) {
        print(
            '[DialogRepo] castVote success: postId=$postId, choice=$voteOption');
      }

      return const Right(null);
    } on IdempotencyViolation catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] Idempotency violation: $e');
      }
      return const Left(AlreadyVoted());
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] castVote Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] castVote error: $e');
      }
      // Parse error message to determine failure type
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, void>> removeVote({
    required String postId,
    required String userId,
  }) async {
    try {
      // Get the current vote to know which counter to decrement
      final voteDoc = await _firestore
          .collection('posts')
          .doc(postId)
          .collection('votes')
          .doc(userId)
          .get();

      if (voteDoc.exists) {
        // Convert to Vote domain model to access choice
        final vote = VoteFirestoreX.fromFirestore(voteDoc);

        // Delete the vote document
        await voteDoc.reference.delete();

        // Update vote counts
        final postRef = _firestore.collection('posts').doc(postId);
        final voteField = vote.choice == 'A' ? 'votesA' : 'votesB';
        await postRef.update({
          voteField: FieldValue.increment(-1),
        });
      }

      if (kDebugMode) {
        print('[DialogRepo] removeVote success: postId=$postId, userId=$userId');
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] removeVote Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] removeVote error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, Map<String, dynamic>?>> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    try {
      // Try 3-Layer cache first
      final cachedHistory = await _cacheService.getVoteHistory(userId);

      if (cachedHistory != null) {
        final userVote = cachedHistory.firstWhere(
          (vote) => vote['postId'] == postId,
          orElse: () => <String, dynamic>{},
        );

        if (userVote.isNotEmpty) {
          if (kDebugMode) {
            print('[DialogRepo] checkUserVote cache hit: postId=$postId');
          }
          return Right(userVote);
        }
      }

      // Fallback to Firebase
      final votesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('votes')
          .get();

      final voteHistory = votesSnapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      final userVote = voteHistory.firstWhere(
        (vote) => vote['postId'] == postId,
        orElse: () => <String, dynamic>{},
      );

      if (userVote.isEmpty) {
        return const Right(null);
      }

      // Cache the complete history to 3-Layer cache
      await _cacheService.setVoteHistory(userId, voteHistory);

      return Right(userVote);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] checkUserVote Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] checkUserVote error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  @override
  Future<Either<VotingFailure, Map<String, dynamic>?>> getVoteCounts(
    String postId,
  ) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (doc.exists) {
        final data = doc.data();
        final counts = {
          'option1': data?['votesA'] ?? 0,
          'option2': data?['votesB'] ?? 0,
        };

        if (kDebugMode) {
          print('[DialogRepo] getVoteCounts success: postId=$postId, counts=$counts');
        }

        return Right(counts);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCounts Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCounts error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Stream<Either<VotingFailure, List<Map<String, dynamic>>>> streamVoteCounts({
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('posts');

      // ✅ Apply postId filter if provided
      if (postId != null) {
        query = query.where(FieldPath.documentId, isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        final result = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'option1': data['votesA'] ?? 0,
            'option2': data['votesB'] ?? 0,
          };
        }).toList();

        if (kDebugMode) {
          print('[DialogRepo] streamVoteCounts emit: ${result.length} items');
        }

        return Right(result) as Either<VotingFailure, List<Map<String, dynamic>>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamVoteCounts error: $e');
        }
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamVoteCounts error: $e');
      }
      if (e is FirebaseException) {
        return Stream.value(Left(e.toVotingFailure()));
      }
      return Stream.value(Left(e.toString().toVotingFailure()));
    }
  }

  @override
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getVoteCountsOnce({
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('posts');

      // ✅ Apply postId filter if provided
      if (postId != null) {
        query = query.where(FieldPath.documentId, isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final result = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'option1': data['votesA'] ?? 0,
          'option2': data['votesB'] ?? 0,
        };
      }).toList();

      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsOnce success: ${result.length} items');
      }

      return Right(result);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsOnce Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsOnce error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, int>> getVoteCountsCount({
    String? postId,
    int limit = -1,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('posts');

      // ✅ Apply postId filter if provided
      if (postId != null) {
        query = query.where(FieldPath.documentId, isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsCount success: count=$count');
      }

      return Right(count);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsCount Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteCountsCount error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // User Vote History
  // ============================================================================

  @override
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getUserVoteHistory(
    String userId,
  ) async {
    try {
      final votesSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('votes')
          .get();

      final history = votesSnapshot.docs
          .map((doc) => {
                ...doc.data(),
                'id': doc.id,
              })
          .toList();

      if (kDebugMode) {
        print('[DialogRepo] getUserVoteHistory success: ${history.length} votes');
      }

      return Right(history);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getUserVoteHistory Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getUserVoteHistory error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  @override
  Future<Either<VotingFailure, void>> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  }) async {
    try {
      final requestRef = _firestore.collection('voteExpansionRequests').doc();

      await requestRef.set({
        'requestId': requestRef.id,
        'postId': postId,
        'userId': userId,
        'additionalTime': additionalTime,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('[DialogRepo] requestVoteExpansion success: postId=$postId, time=$additionalTime');
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] requestVoteExpansion Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] requestVoteExpansion error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, void>> approveVoteExpansion(
    String requestId,
  ) async {
    try {
      await _firestore
          .collection('voteExpansionRequests')
          .doc(requestId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('[DialogRepo] approveVoteExpansion success: requestId=$requestId');
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] approveVoteExpansion Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] approveVoteExpansion error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, void>> rejectVoteExpansion(
    String requestId,
  ) async {
    try {
      await _firestore
          .collection('voteExpansionRequests')
          .doc(requestId)
          .update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('[DialogRepo] rejectVoteExpansion success: requestId=$requestId');
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] rejectVoteExpansion Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] rejectVoteExpansion error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Stream<Either<VotingFailure, List<VoteExpansionRequest>>>
      streamVoteExpansionRequests({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collectionGroup('voteExpansionRequests');

      // ✅ Apply filters if provided
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        final requests = snapshot.docs
            .map((doc) => VoteExpansionRequestFirestoreX.fromFirestore(doc))
            .toList();

        if (kDebugMode) {
          print('[DialogRepo] streamVoteExpansionRequests emit: ${requests.length} items');
        }

        return Right(requests) as Either<VotingFailure, List<VoteExpansionRequest>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamVoteExpansionRequests error: $e');
        }
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamVoteExpansionRequests error: $e');
      }
      if (e is FirebaseException) {
        return Stream.value(Left(e.toVotingFailure()));
      }
      return Stream.value(Left(e.toString().toVotingFailure()));
    }
  }

  @override
  Future<Either<VotingFailure, List<VoteExpansionRequest>>>
      getVoteExpansionRequestsOnce({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collectionGroup('voteExpansionRequests');

      // ✅ Apply filters if provided
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final requests = snapshot.docs
          .map((doc) => VoteExpansionRequestFirestoreX.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsOnce success: ${requests.length} items');
      }

      return Right(requests);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsOnce Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsOnce error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, int>> getVoteExpansionRequestsCount({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _firestore.collectionGroup('voteExpansionRequests');

      // ✅ Apply filters if provided
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (status != null) {
        query = query.where('status', isEqualTo: status);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsCount success: count=$count');
      }

      return Right(count);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsCount Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getVoteExpansionRequestsCount error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  // ============================================================================
  // Weights Operations
  // ============================================================================

  @override
  Stream<Either<VotingFailure, List<Weight>>> streamWeights({
    String? userId,
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  }) {
    try {
      Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

      // ✅ Apply filters if provided
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        final weights = snapshot.docs
            .map((doc) => WeightFirestoreX.fromFirestore(doc))
            .toList();

        if (kDebugMode) {
          print('[DialogRepo] streamWeights emit: ${weights.length} items');
        }

        return Right(weights) as Either<VotingFailure, List<Weight>>;
      }).handleError((e) {
        if (kDebugMode) {
          print('[DialogRepo] streamWeights error: $e');
        }
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] streamWeights error: $e');
      }
      if (e is FirebaseException) {
        return Stream.value(Left(e.toVotingFailure()));
      }
      return Stream.value(Left(e.toString().toVotingFailure()));
    }
  }

  @override
  Future<Either<VotingFailure, List<Weight>>> getWeightsOnce({
    String? userId,
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

      // ✅ Apply filters if provided
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      final weights = snapshot.docs
          .map((doc) => WeightFirestoreX.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('[DialogRepo] getWeightsOnce success: ${weights.length} items');
      }

      return Right(weights);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsOnce Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsOnce error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, int>> getWeightsCount({
    String? userId,
    String? postId,
    int limit = -1,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

      // ✅ Apply filters if provided
      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }
      if (postId != null) {
        query = query.where('postId', isEqualTo: postId);
      }

      if (limit > 0) {
        query = query.limit(limit);
      }

      final snapshot = await query.count().get();
      final count = snapshot.count ?? 0;

      if (kDebugMode) {
        print('[DialogRepo] getWeightsCount success: count=$count');
      }

      return Right(count);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsCount Firebase error: $e');
      }
      return Left(e.toVotingFailure());
    } catch (e) {
      if (kDebugMode) {
        print('[DialogRepo] getWeightsCount error: $e');
      }
      return Left(e.toString().toVotingFailure());
    }
  }
}
