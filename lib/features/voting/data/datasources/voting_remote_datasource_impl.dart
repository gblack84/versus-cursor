import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/core/firebase/utils/firestore_util.dart';
// Firebase Optimization: Domain models with extensions
import '../../domain/entities/dialog/vote_expansion_request.dart';
import '../../domain/entities/dialog/weight.dart';
import '../extensions/vote_extensions.dart';
import '../extensions/vote_expansion_request_extensions.dart';
import '../extensions/weight_extensions.dart';
import 'i_voting_remote_datasource.dart';

/// Implementation of remote data source for voting feature
class VotingRemoteDataSourceImpl implements IVotingRemoteDataSource {
  final FirebaseFirestore _firestore;
  
  VotingRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================================================
  // Vote Operations
  // ============================================================================

  @override
  Future<dynamic> getVoteCounts(String postId) async {
    try {
      final doc = await _firestore
          .collection('posts')
          .doc(postId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        return {
          'option1': data?['votesA'] ?? 0,
          'option2': data?['votesB'] ?? 0,
        };
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting vote counts: $e');
      }
      return null;
    }
  }

  @override
  Stream<List<dynamic>> queryVotecounts({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('posts');
    
    if (queryBuilder != null && queryBuilder is Function) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }
    
    if (limit > 0) {
      query = query.limit(limit);
    }
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'option1': data['votesA'] ?? 0,
          'option2': data['votesB'] ?? 0,
        };
      }).toList();
    });
  }

  @override
  Future<List<dynamic>> queryVotecountsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('posts');
    
    if (queryBuilder != null && queryBuilder is Function) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }
    
    if (limit > 0) {
      query = query.limit(limit);
    }
    
    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'option1': data['votesA'] ?? 0,
        'option2': data['votesB'] ?? 0,
      };
    }).toList();
  }

  @override
  Future<int> queryVotecountsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collection('posts');
    
    if (queryBuilder != null && queryBuilder is Function) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }
    
    if (limit > 0) {
      query = query.limit(limit);
    }
    
    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption,
    String? messageId,
    String? chatId,
  }) async {
    try {
      if (kDebugMode) {
        print('[VotingRemoteDataSource] submitVote started: postId=$postId, choice=$voteOption');
      }

      // ✅ Firebase Transaction으로 atomic 업데이트 (중복 투표 방지)
      await _firestore.runTransaction((transaction) async {
        // 1. Posts 업데이트
        final postRef = _firestore.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }

        // 중복 투표 확인 (Transaction 내부에서 안전)
        final postData = postDoc.data() as Map<String, dynamic>;
        final votedUsersA = List<String>.from(postData['votedUserIDsA'] ?? []);
        final votedUsersB = List<String>.from(postData['votedUserIDsB'] ?? []);

        if (votedUsersA.contains(userId) || votedUsersB.contains(userId)) {
          throw Exception('이미 투표하셨습니다');
        }

        // 투표 필드 업데이트 (atomic)
        final updates = <String, dynamic>{
          'votedUserIDs$voteOption': FieldValue.arrayUnion([userId]),
          'votes$voteOption': FieldValue.increment(1),
          'totalVotes': FieldValue.increment(1),
          'lastVoteAt': FieldValue.serverTimestamp(),
        };

        transaction.update(postRef, updates);

        // 1.5 votes 서브컬렉션에 투표 문서 생성
        final voteRef = postRef.collection('votes').doc();
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
            if (kDebugMode) {
              print('[VotingRemoteDataSource] Updating message userVotes: messageId=$messageId, choice=$voteOption');
            }

            transaction.update(messageRef, {
              'userVotes.$userId': {
                'option': voteOption,
                'votedAt': FieldValue.serverTimestamp(),
              },
              'lastVoteUpdate': FieldValue.serverTimestamp(),
            });
          } else {
            if (kDebugMode) {
              print('[VotingRemoteDataSource] Message not found: messageId=$messageId');
            }
          }
        } else {
          if (kDebugMode) {
            print('[VotingRemoteDataSource] Skipping message update: messageId=$messageId, chatId=$chatId');
          }
        }
      });

      // 3. AI 채팅 업데이트 (트랜잭션 외부 - 실패해도 메인 플로우 계속)
      await _updateAIChatMessage(postId, userId, voteOption);

      if (kDebugMode) {
        print('[VotingRemoteDataSource] Vote submitted successfully: postId=$postId, choice=$voteOption');
      }
    } catch (e) {
      final errorMessage = e.toString().contains('이미 투표')
          ? '이미 투표하셨습니다'
          : e.toString().contains('찾을 수 없')
              ? '게시물을 찾을 수 없습니다'
              : '투표 처리 중 오류가 발생했습니다';

      if (kDebugMode) {
        print('[VotingRemoteDataSource] Vote submission failed: $e');
      }

      throw Exception(errorMessage);
    }
  }

  /// AI 채팅 메시지 업데이트
  ///
  /// 트랜잭션 외부에서 실행되며, 실패해도 메인 투표 플로우에 영향 없음
  Future<bool> _updateAIChatMessage(
    String postId,
    String userId,
    String choice,
  ) async {
    try {
      // 게시물 작성자 찾기
      final postDoc = await _firestore.collection('posts').doc(postId).get();

      if (!postDoc.exists) {
        if (kDebugMode) {
          print('[VotingRemoteDataSource] AI chat update skipped: post not found');
        }
        return false;
      }

      final postData = postDoc.data() as Map<String, dynamic>;
      final authorId = postData['userId'] ?? postData['authorId'];
      if (authorId == null) {
        if (kDebugMode) {
          print('[VotingRemoteDataSource] AI chat update skipped: author ID not found');
        }
        return false;
      }

      // AI 채팅 메시지 찾기
      final aiChatId = 'ai_assistant_$authorId';
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(aiChatId)
          .collection('messages')
          .where('votePostId', isEqualTo: postId)
          .where('messageType', isEqualTo: 'voteRequest')
          .limit(1)
          .get();

      if (messagesQuery.docs.isEmpty) {
        if (kDebugMode) {
          print('[VotingRemoteDataSource] AI chat update skipped: message not found');
        }
        return false;
      }

      // userVotes 업데이트
      final messageDoc = messagesQuery.docs.first;
      await messageDoc.reference.update({
        'userVotes.$userId': {
          'option': choice,
          'votedAt': FieldValue.serverTimestamp(),
        },
        'lastVoteUpdate': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('[VotingRemoteDataSource] AI chat message updated successfully');
      }
      return true;
    } catch (e) {
      // 실패해도 메인 플로우는 계속
      if (kDebugMode) {
        print('[VotingRemoteDataSource] AI chat update failed (continuing): $e');
      }
      return false;
    }
  }

  @override
  Future<void> removeVote({
    required String postId,
    required String userId,
  }) async {
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
  }

  // Legacy VotecountsModel getVoteCounts method removed
  // Use clean architecture through repository pattern instead

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  // Legacy VotecountsModel queryVotecounts method removed
  // Use clean architecture through repository pattern instead

  // Legacy VotecountsModel queryVotecountsOnce method removed
  // Use clean architecture through repository pattern instead

  // Legacy VotecountsModel queryVotecountsCount method removed
  // Use clean architecture through repository pattern instead

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  @override
  Future<void> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  }) async {
    final requestRef = _firestore
        .collection('voteExpansionRequests')
        .doc();

    await requestRef.set({
      'requestId': requestRef.id,
      'postId': postId,
      'userId': userId,
      'additionalTime': additionalTime,
      'status': 'pending',
      'requestedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> approveVoteExpansion(String requestId) async {
    await _firestore
        .collection('voteExpansionRequests')
        .doc(requestId)
        .update({
      'status': 'approved',
      'approvedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> rejectVoteExpansion(String requestId) async {
    await _firestore
        .collection('voteExpansionRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<List<VoteExpansionRequest>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collectionGroup('voteExpansionRequests');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => VoteExpansionRequestFirestoreX.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<List<VoteExpansionRequest>> queryVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collectionGroup('voteExpansionRequests');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => VoteExpansionRequestFirestoreX.fromFirestore(doc))
        .toList();
  }

  @override
  Future<int> queryVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    Query<Map<String, dynamic>> query =
        _firestore.collectionGroup('voteExpansionRequests');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  // ============================================================================
  // Weights Operations
  // ============================================================================

  @override
  Stream<List<Weight>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => WeightFirestoreX.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<List<Weight>> queryWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => WeightFirestoreX.fromFirestore(doc))
        .toList();
  }

  @override
  Future<int> queryWeightsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) async {
    Query<Map<String, dynamic>> query = _firestore.collectionGroup('weights');

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    if (limit > 0) {
      query = query.limit(limit);
    }

    final snapshot = await query.count().get();
    return snapshot.count ?? 0;
  }

  // ============================================================================
  // User Vote History
  // ============================================================================

  @override
  Future<List<Map<String, dynamic>>> getUserVotes(String userId) async {
    try {
      // Get user's votes from the votes subcollection across all posts
      final votesQuery = await _firestore
          .collectionGroup('votes')
          .where('userId', isEqualTo: userId)
          .orderBy('votedAt', descending: true)
          .limit(100)
          .get();

      return votesQuery.docs.map((doc) {
        // Convert to Vote domain model (direct conversion via extension)
        final vote = VoteFirestoreX.fromFirestore(doc);

        // Return as Map for interface compatibility
        return {
          'postId': vote.postId,
          'voteOption': vote.choice,
          'votedAt': vote.timestamp?.millisecondsSinceEpoch ??
                     DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user votes: $e');
      }
      return [];
    }
  }
}