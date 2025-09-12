import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/core/firebase/utils/firestore_util.dart';
// Legacy VotecountsModel import removed - using clean architecture models
import '../../domain/models/vote_expansion_requests_model.dart';
import '../../domain/models/rankings_model.dart';
import '../../domain/models/weights_model.dart';
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
  }) async {
    final voteRef = _firestore
        .collection('posts')
        .doc(postId)
        .collection('votes')
        .doc(userId);

    await voteRef.set({
      'userId': userId,
      'voteOption': voteOption,
      'votedAt': FieldValue.serverTimestamp(),
    });

    // Update vote counts
    final postRef = _firestore.collection('posts').doc(postId);
    final voteField = voteOption == 'A' ? 'votesA' : 'votesB';
    await postRef.update({
      voteField: FieldValue.increment(1),
    });
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
      final voteOption = voteDoc.data()?['voteOption'] as String?;

      // Delete the vote document
      await voteDoc.reference.delete();

      // Update vote counts
      if (voteOption != null) {
        final postRef = _firestore.collection('posts').doc(postId);
        final voteField = voteOption == 'A' ? 'votesA' : 'votesB';
        await postRef.update({
          voteField: FieldValue.increment(-1),
        });
      }
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
  // Rankings Operations
  // ============================================================================

  @override
  Future<void> updateRankings() async {
    // This would typically be handled by a Cloud Function or backend service
    // For now, we'll implement a basic ranking algorithm

    final postsSnapshot = await _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final batch = _firestore.batch();

    for (int i = 0; i < postsSnapshot.docs.length; i++) {
      final post = postsSnapshot.docs[i];
      final votesA = post.data()['votesA'] ?? 0;
      final votesB = post.data()['votesB'] ?? 0;
      final totalVotes = votesA + votesB;

      // Simple ranking score based on total votes and recency
      final score = totalVotes * 1.0;

      final rankingRef = _firestore.collection('rankings').doc(post.id);

      batch.set(
        rankingRef,
        {
          'postId': post.id,
          'rank': i + 1,
          'score': score,
          'votesA': votesA,
          'votesB': votesB,
          'totalVotes': totalVotes,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  @override
  Future<List<RankingsModel>> queryRankingsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollectionOnce(
      RankingsModel.collection,
      RankingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<List<RankingsModel>> getTopRankings({int limit = 10}) async {
    final snapshot = await _firestore
        .collection('rankings')
        .orderBy('rank')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => RankingsModel.fromSnapshot(doc)).toList();
  }

  @override
  Stream<List<RankingsModel>> queryRankings({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollection(
      RankingsModel.collection,
      RankingsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<int> queryRankingsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    return queryCollectionCount(
      RankingsModel.collection,
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

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
  Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollection(
      VoteExpansionRequestsModel.collection(null),
      VoteExpansionRequestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<List<VoteExpansionRequestsModel>> queryVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollectionOnce(
      VoteExpansionRequestsModel.collection(null),
      VoteExpansionRequestsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<int> queryVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    return queryCollectionCount(
      VoteExpansionRequestsModel.collection(null),
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  // ============================================================================
  // Weights Operations
  // ============================================================================

  @override
  Stream<List<WeightsModel>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollection(
      WeightsModel.collection(null),
      WeightsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<List<WeightsModel>> queryWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollectionOnce(
      WeightsModel.collection(null),
      WeightsModel.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<int> queryWeightsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    return queryCollectionCount(
      WeightsModel.collection(null),
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }
}