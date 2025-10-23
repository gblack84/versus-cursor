import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '/core/firebase/utils/firestore_util.dart';
// Legacy VotecountsModel import removed - using clean architecture models
import '../models/vote_expansion_request_dto.dart';
import '../models/weight_dto.dart';
import '../models/vote_dto.dart';
import '../mappers/vote_mapper.dart';
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

    // Create VoteDto and convert to Firestore format
    final voteDto = VoteDto(
      id: userId,
      postId: postId,
      userId: userId,
      choice: voteOption,
      timestamp: DateTime.now(),
    );

    await voteRef.set(voteDto.toFirestore());

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
      // Convert to VoteDto to access choice
      final voteDto = VoteDto.fromFirestore(voteDoc);

      // Delete the vote document
      await voteDoc.reference.delete();

      // Update vote counts
      final postRef = _firestore.collection('posts').doc(postId);
      final voteField = voteDto.choice == 'A' ? 'votesA' : 'votesB';
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
  Stream<List<VoteExpansionRequestDto>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollection(
      VoteExpansionRequestDto.collection(null),
      VoteExpansionRequestDto.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<List<VoteExpansionRequestDto>> queryVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollectionOnce(
      VoteExpansionRequestDto.collection(null),
      VoteExpansionRequestDto.fromSnapshot,
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
      VoteExpansionRequestDto.collection(null),
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  // ============================================================================
  // Weights Operations
  // ============================================================================

  @override
  Stream<List<WeightDto>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollection(
      WeightDto.collection(null),
      WeightDto.fromSnapshot,
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  @override
  Future<List<WeightDto>> queryWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return queryCollectionOnce(
      WeightDto.collection(null),
      WeightDto.fromSnapshot,
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
      WeightDto.collection(null),
      queryBuilder: queryBuilder,
      limit: limit,
    );
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
        // Convert to VoteDto (Clean Architecture DTO)
        final voteDto = VoteDto.fromFirestore(doc);

        // Convert to domain entity
        final voteEntity = VoteMapper.toEntity(voteDto);

        // Return as Map for interface compatibility
        return {
          'postId': voteEntity.postId,
          'voteOption': voteEntity.choice,
          'votedAt': voteEntity.timestamp?.millisecondsSinceEpoch ??
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