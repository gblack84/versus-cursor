import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '../../domain/repositories/i_voting_repository.dart';
import '/features/voting/domain/models/votecounts_model.dart';
import '/features/voting/domain/models/vote_expansion_requests_model.dart';
import '/features/voting/domain/models/rankings_model.dart';
import '/features/voting/domain/models/weights_model.dart';

/// Implementation of voting repository with migrated backend query functions
class VotingRepositoryImpl implements IVotingRepository {
  static VotingRepositoryImpl? _instance;
  static VotingRepositoryImpl get instance => _instance ??= VotingRepositoryImpl._();
  
  final PostsDataSource? _postsDataSource;
  
  VotingRepositoryImpl._() : _postsDataSource = null;
  
  // Constructor for dependency injection
  VotingRepositoryImpl.withDataSource(this._postsDataSource);

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================
  
  @override
  Future<int> queryVotecountsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        VotecountsModel.collection(null),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<VotecountsModel>> queryVotecounts({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        VotecountsModel.collection(null),
        VotecountsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<VotecountsModel>> queryVotecountsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        VotecountsModel.collection(null),
        VotecountsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // ============================================================================
  // Vote Expansion Requests Queries
  // ============================================================================
  
  @override
  Future<int> queryVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        VoteExpansionRequestsModel.collection(null),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        VoteExpansionRequestsModel.collection(null),
        VoteExpansionRequestsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<VoteExpansionRequestsModel>> queryVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        VoteExpansionRequestsModel.collection(null),
        VoteExpansionRequestsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // ============================================================================
  // Rankings Queries
  // ============================================================================
  
  @override
  Future<int> queryRankingsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        RankingsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<RankingsModel>> queryRankings({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        RankingsModel.collection,
        RankingsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<RankingsModel>> queryRankingsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        RankingsModel.collection,
        RankingsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // ============================================================================
  // Weights Queries
  // ============================================================================
  
  @override
  Future<int> queryWeightsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        WeightsModel.collection(null),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<WeightsModel>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        WeightsModel.collection(null),
        WeightsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<WeightsModel>> queryWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        WeightsModel.collection(null),
        WeightsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // ============================================================================
  // Voting Operations
  // ============================================================================
  
  @override
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    final voteRef = FirebaseFirestore.instance
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
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
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
    final voteDoc = await FirebaseFirestore.instance
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
        final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
        final voteField = voteOption == 'A' ? 'votesA' : 'votesB';
        await postRef.update({
          voteField: FieldValue.increment(-1),
        });
      }
    }
  }

  @override
  Future<VotecountsModel?> getVoteCounts(String postId) async {
    final doc = await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('votecounts')
        .doc('summary')
        .get();
    
    return doc.exists ? VotecountsModel.fromSnapshot(doc) : null;
  }

  // ============================================================================
  // Ranking Operations
  // ============================================================================
  
  @override
  Future<void> updateRankings() async {
    // This would typically be handled by a Cloud Function or backend service
    // For now, we'll implement a basic ranking algorithm
    
    final postsSnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();
    
    final batch = FirebaseFirestore.instance.batch();
    
    for (int i = 0; i < postsSnapshot.docs.length; i++) {
      final post = postsSnapshot.docs[i];
      final votesA = post.data()['votesA'] ?? 0;
      final votesB = post.data()['votesB'] ?? 0;
      final totalVotes = votesA + votesB;
      
      // Simple ranking score based on total votes and recency
      final score = totalVotes * 1.0;
      
      final rankingRef = FirebaseFirestore.instance
          .collection('rankings')
          .doc(post.id);
      
      batch.set(rankingRef, {
        'postId': post.id,
        'rank': i + 1,
        'score': score,
        'votesA': votesA,
        'votesB': votesB,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
    
    await batch.commit();
  }

  @override
  Future<List<RankingsModel>> getTopRankings({int limit = 10}) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('rankings')
        .orderBy('score', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs.map((doc) => RankingsModel.fromSnapshot(doc)).toList();
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
    await FirebaseFirestore.instance.collection('voteExpansionRequests').add({
      'postId': postId,
      'userId': userId,
      'additionalTime': additionalTime,
      'requestedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  @override
  Future<void> approveVoteExpansion(String requestId) async {
    final requestDoc = await FirebaseFirestore.instance
        .collection('voteExpansionRequests')
        .doc(requestId)
        .get();
    
    if (requestDoc.exists) {
      final data = requestDoc.data()!;
      final postId = data['postId'] as String;
      final additionalTime = data['additionalTime'] as int;
      
      // Update the request status
      await requestDoc.reference.update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
      });
      
      // Extend the vote end time for the post
      final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
      final postDoc = await postRef.get();
      
      if (postDoc.exists) {
        final currentEndTime = postDoc.data()?['voteEndTime'] as Timestamp?;
        if (currentEndTime != null) {
          final newEndTime = currentEndTime.toDate().add(Duration(minutes: additionalTime));
          await postRef.update({
            'voteEndTime': Timestamp.fromDate(newEndTime),
          });
        }
      }
    }
  }

  @override
  Future<void> rejectVoteExpansion(String requestId) async {
    await FirebaseFirestore.instance
        .collection('voteExpansionRequests')
        .doc(requestId)
        .update({
      'status': 'rejected',
      'rejectedAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================================
  // Delegated Methods for Ranked Posts (using PostsDataSource)
  // ============================================================================
  
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  }) {
    if (_postsDataSource != null) {
      return _postsDataSource!.getRankedPosts(
        category: category,
        limit: limit,
      );
    }
    // Fallback to empty stream if data source not provided
    return Stream.value([]);
  }
  
  Future<RankedPostsData?> getRankedPostById(String postId) async {
    if (_postsDataSource != null) {
      return _postsDataSource!.getRankedPostById(postId);
    }
    return null;
  }
}