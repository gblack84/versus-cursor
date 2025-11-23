import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/repositories/i_voting_dialog_repository.dart';
import '../../domain/failures/voting_failure.dart';
import '../../domain/entities/dialog/vote_expansion_request.dart';
import '../../domain/entities/dialog/weight.dart';
import '../extensions/firestore_error_extensions.dart';
import '../../domain/entities/vote_expansion_request_extensions.dart';
import '../../domain/entities/weight_extensions.dart';
import '../../domain/entities/vote_extensions.dart';
import '/services/sharding/shard_utils.dart';
import '/services/cache/unified_cache_service.dart';
import '/services/logging/logger_service.dart';

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
  final ShardUtils _shardUtils;

  VotingDialogRepositoryImpl({
    required FirebaseFirestore firestore,
    ShardUtils? shardUtils,
  })  : _firestore = firestore,
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
  }) async {
    try {
      VotingLogger.voteCasting(
        postId: postId,
        userId: userId,
        voteOption: voteOption,
      );

      // ✅ Direct Firestore transaction (no IdempotencyService wrapper)
      // Deterministic vote ID (userId) provides natural idempotency via set()
      await _firestore.runTransaction((transaction) async {
        // 1. Posts 업데이트
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }

        // 중복 투표 확인 (Transaction 내부에서 안전)
        // Backward compatibility: votedUserIDs arrays provide duplicate check
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

        // ✅ Deterministic vote document (userId as doc ID)
        // Firestore set() is idempotent: retry overwrites, no duplicates
        final voteRef = postRef.collection('votes').doc(userId);
        transaction.set(voteRef, {
          'user': _firestore.doc('users/$userId'),
          'option': voteOption,
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
      });

      VotingLogger.voteCasted(postId: postId, voteOption: voteOption);
      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.voteError(errorType: e.code, error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.voteError(errorType: 'unexpected', error: e, postId: postId);
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

      VotingLogger.voteRemoved(postId: postId, userId: userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.voteError(errorType: e.code, error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.voteError(errorType: 'unexpected', error: e, postId: postId);
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, Map<String, dynamic>?>> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    try {
      VotingLogger.voteLoading(postId: postId, userId: userId);

      // Try 3-Layer cache first
      final cachedHistoryResult = await _cacheService.getVoteHistory(userId);
      final cachedHistory = cachedHistoryResult.fold(
        (failure) => null,  // Cache miss or error - continue to Firestore
        (history) => history,
      );

      if (cachedHistory != null) {
        final userVote = cachedHistory.firstWhere(
          (vote) => vote['postId'] == postId,
          orElse: () => <String, dynamic>{},
        );

        if (userVote.isNotEmpty) {
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

      VotingLogger.voteLoaded(postId: postId, hasVoted: userVote.isNotEmpty);
      return Right(userVote);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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
      VotingLogger.voteLoading(postId: postId);

      final doc = await _firestore.collection('posts').doc(postId).get();

      if (doc.exists) {
        final data = doc.data();
        final counts = {
          'option1': data?['votesA'] ?? 0,
          'option2': data?['votesB'] ?? 0,
        };

        VotingLogger.voteCountsLoaded(
          postId: postId,
          countA: counts['option1'] as int?,
          countB: counts['option2'] as int?,
        );
        return Right(counts);
      }

      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

        return Right(result) as Either<VotingFailure, List<Map<String, dynamic>>>;
      }).handleError((e) {
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
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

      return Right(result);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

      return Right(count);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

      return Right(history);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e);
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
      VotingLogger.expansionRequesting(
        postId: postId,
        userId: userId,
        requestedDuration: additionalTime,
      );

      final requestRef = _firestore.collection('voteExpansionRequests').doc();

      await requestRef.set({
        'requestId': requestRef.id,
        'postId': postId,
        'userId': userId,
        'additionalTime': additionalTime,
        'status': 'pending',
        'requestedAt': FieldValue.serverTimestamp(),
      });

      VotingLogger.expansionRequested(
        postId: postId,
        requestedDuration: additionalTime,
      );
      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.expansionError(
        errorType: e.code,
        error: e,
        postId: postId,
      );
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.expansionError(
        errorType: 'unexpected',
        error: e,
        postId: postId,
      );
      return Left(e.toString().toVotingFailure());
    }
  }

  @override
  Future<Either<VotingFailure, void>> approveVoteExpansion(
    String requestId,
  ) async {
    try {
      // Note: postId not available in this method signature, would need to fetch first
      await _firestore
          .collection('voteExpansionRequests')
          .doc(requestId)
          .update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });

      VotingLogger.expansionApproved(postId: 'unknown', requestId: requestId);
      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.expansionError(errorType: e.code, error: e);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.expansionError(errorType: 'unexpected', error: e);
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

      VotingLogger.expansionRejected(postId: 'unknown', requestId: requestId);
      return const Right(null);
    } on FirebaseException catch (e) {
      VotingLogger.expansionError(errorType: e.code, error: e);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.expansionError(errorType: 'unexpected', error: e);
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

        return Right(requests) as Either<VotingFailure, List<VoteExpansionRequest>>;
      }).handleError((e) {
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
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

      return Right(requests);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

      return Right(count);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

        return Right(weights) as Either<VotingFailure, List<Weight>>;
      }).handleError((e) {
        if (e is FirebaseException) {
          return Left(e.toVotingFailure());
        }
        return Left(e.toString().toVotingFailure());
      });
    } catch (e) {
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

      return Right(weights);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
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

      return Right(count);
    } on FirebaseException catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toVotingFailure());
    } catch (e) {
      VotingLogger.loadError(error: e, postId: postId);
      return Left(e.toString().toVotingFailure());
    }
  }
}
