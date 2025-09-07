import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/post.dart';
import '../../domain/models/vote_data.dart';
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';
import '../../domain/models/post_voting.dart';
import '../../domain/models/post_metrics.dart';
import '../../domain/repositories/i_post_repository.dart';
import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/backend.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/backend/models/post/posts_model.dart';
import '/backend/models/post/backend_post_models.dart';
import '../adapters/posts_model_adapter.dart';
import '../models/posts_model.dart' as feature_posts;

/// Implementation of post repository using Firestore
class PostRepositoryImpl implements IPostRepository {
  static const String _collection = 'posts';
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  CollectionReference get _postsCollection => _firestore.collection(_collection);

  @override
  Stream<List<Post>> getAllPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getPostsByUserId(String userId) {
    return _postsCollection
        .where('creatorInfo.userid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Future<Post?> getPostById(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        return Post.fromJson(
          mapFromFirestore(doc.data() as Map<String, dynamic>),
          doc.id,
        );
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get post: $e');
    }
  }

  @override
  Stream<Post?> getPostStream(String postId) {
    return _postsCollection
        .doc(postId)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return Post.fromJson(
              mapFromFirestore(doc.data() as Map<String, dynamic>),
              doc.id,
            );
          }
          return null;
        });
  }

  @override
  Future<String> createPost(Post post) async {
    try {
      final docRef = await _postsCollection.add(mapToFirestore(post.toJson()));
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post: $e');
    }
  }

  @override
  Future<void> updatePost(String postId, Post post) async {
    try {
      await _postsCollection.doc(postId).update(mapToFirestore(post.toJson()));
    } catch (e) {
      throw Exception('Failed to update post: $e');
    }
  }

  @override
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();
    } catch (e) {
      throw Exception('Failed to delete post: $e');
    }
  }

  @override
  Future<void> updateVoteData(String postId, VoteData voteData) async {
    try {
      await _postsCollection.doc(postId).update(mapToFirestore(voteData.toJson()));
    } catch (e) {
      throw Exception('Failed to update vote data: $e');
    }
  }

  @override
  Future<void> castVote(String postId, String userId, String option) async {
    try {
      final batch = _firestore.batch();
      final postRef = _postsCollection.doc(postId);
      
      if (option == 'A') {
        batch.update(postRef, {
          'votedUserIdsA': FieldValue.arrayUnion([userId]),
          'votesA': FieldValue.increment(1),
          'totalVotes': FieldValue.increment(1),
          'actualVotesA': FieldValue.increment(1),
          'actualTotalVotes': FieldValue.increment(1),
        });
      } else if (option == 'B') {
        batch.update(postRef, {
          'votedUserIdsB': FieldValue.arrayUnion([userId]),
          'votesB': FieldValue.increment(1),
          'totalVotes': FieldValue.increment(1),
          'actualVotesB': FieldValue.increment(1),
          'actualTotalVotes': FieldValue.increment(1),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to cast vote: $e');
    }
  }

  @override
  Future<void> removeVote(String postId, String userId, String option) async {
    try {
      final batch = _firestore.batch();
      final postRef = _postsCollection.doc(postId);
      
      if (option == 'A') {
        batch.update(postRef, {
          'votedUserIdsA': FieldValue.arrayRemove([userId]),
          'votesA': FieldValue.increment(-1),
          'totalVotes': FieldValue.increment(-1),
          'actualVotesA': FieldValue.increment(-1),
          'actualTotalVotes': FieldValue.increment(-1),
        });
      } else if (option == 'B') {
        batch.update(postRef, {
          'votedUserIdsB': FieldValue.arrayRemove([userId]),
          'votesB': FieldValue.increment(-1),
          'totalVotes': FieldValue.increment(-1),
          'actualVotesB': FieldValue.increment(-1),
          'actualTotalVotes': FieldValue.increment(-1),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to remove vote: $e');
    }
  }

  @override
  Stream<List<Post>> getPostsByCategory(String category) {
    return _postsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getPostsByTags(List<String> tags) {
    return _postsCollection
        .where('tags', arrayContainsAny: tags)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getTrendingPosts({int limit = 20}) {
    return _postsCollection
        .orderBy('stats.participantcount', descending: true)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getRecentPosts({int limit = 20}) {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> searchPosts(String query) {
    return _postsCollection
        .where('questionTitle', isGreaterThanOrEqualTo: query)
        .where('questionTitle', isLessThanOrEqualTo: query + '\uf8ff')
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Future<List<Post>> getPostsPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
      Query query = _postsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final snapshot = await query.get();
      return _convertToPostList(snapshot);
    } catch (e) {
      throw Exception('Failed to get paginated posts: $e');
    }
  }

  @override
  Future<void> reportPost(String postId, String userId, String reason) async {
    try {
      await _postsCollection.doc(postId).update({
        'reportedBy': FieldValue.arrayUnion([userId]),
        'reportCount': FieldValue.increment(1),
        'isReported': true,
      });
    } catch (e) {
      throw Exception('Failed to report post: $e');
    }
  }

  @override
  Future<void> updatePostStats(String postId, Map<String, dynamic> stats) async {
    try {
      await _postsCollection.doc(postId).update(mapToFirestore(stats));
    } catch (e) {
      throw Exception('Failed to update post stats: $e');
    }
  }

  @override
  Stream<List<Post>> getPostsByVisibility(int visibility) {
    return _postsCollection
        .where('visibility', isEqualTo: visibility)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getAnonymousPosts() {
    return _postsCollection
        .where('isAnonymous', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Stream<List<Post>> getPremiumPosts() {
    return _postsCollection
        .where('premiumRequired', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(_convertToPostList);
  }

  @override
  Future<void> completeVote(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'voteCompleted': true,
        'isVotingComplete': true,
        'voteStatus': 'completed',
        'voteCompletedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to complete vote: $e');
    }
  }

  @override
  Future<void> cancelVote(String postId, String reason) async {
    try {
      await _postsCollection.doc(postId).update({
        'voteCompleted': false,
        'isVotingComplete': false,
        'voteStatus': 'cancelled',
        'voteCancelledAt': FieldValue.serverTimestamp(),
        'voteCancelledReason': reason,
      });
    } catch (e) {
      throw Exception('Failed to cancel vote: $e');
    }
  }

  @override
  Future<void> sendNotifications(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'notificationsSent': true,
        'notificationsSentAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to send notifications: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getVoteResults(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'votesA': data['votesA'] ?? 0,
          'votesB': data['votesB'] ?? 0,
          'totalVotes': data['totalVotes'] ?? 0,
          'displayVotesA': data['displayVotesA'] ?? 0,
          'displayVotesB': data['displayVotesB'] ?? 0,
          'displayPercentA': data['displayPercentA'] ?? 0,
          'displayPercentB': data['displayPercentB'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      throw Exception('Failed to get vote results: $e');
    }
  }

  @override
  Future<bool> hasUserVoted(String postId, String userId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final votedUserIdsA = List<String>.from(data['votedUserIdsA'] ?? []);
        final votedUserIdsB = List<String>.from(data['votedUserIdsB'] ?? []);
        return votedUserIdsA.contains(userId) || votedUserIdsB.contains(userId);
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check user vote: $e');
    }
  }

  @override
  Future<String?> getUserVoteOption(String postId, String userId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final votedUserIdsA = List<String>.from(data['votedUserIdsA'] ?? []);
        final votedUserIdsB = List<String>.from(data['votedUserIdsB'] ?? []);
        
        if (votedUserIdsA.contains(userId)) return 'A';
        if (votedUserIdsB.contains(userId)) return 'B';
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user vote option: $e');
    }
  }

  /// Helper method to convert QuerySnapshot to List<Post>
  List<Post> _convertToPostList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return Post.fromJson(
        mapFromFirestore(doc.data() as Map<String, dynamic>),
        doc.id,
      );
    }).toList();
  }

  // MIGRATED: Posts queries (lines 179-214 from backend.dart)
  Future<int> queryPostsModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        PostsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<PostsModel>> queryPostsModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        PostsModel.collection,
        PostsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<PostsModel>> queryPostsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        PostsModel.collection,
        PostsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Comments queries (lines 376-411 from backend.dart)
  Future<int> queryCommentsModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        CommentsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<CommentsModel>> queryCommentsModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        CommentsModel.collection,
        CommentsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<CommentsModel>> queryCommentsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        CommentsModel.collection,
        CommentsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Likes queries (lines 413-451 from backend.dart)
  Future<int> queryLikesModelCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        LikesModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<LikesModel>> queryLikesModel({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        LikesModel.collection(parent),
        LikesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<LikesModel>> queryLikesModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        LikesModel.collection(parent),
        LikesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );
  
  // ============= ADAPTER METHODS (NEW) =============
  // These methods provide access to the new domain models
  // while maintaining backward compatibility with legacy code
  
  /// Get post as separate domain models using Adapter
  Future<PostBundle?> getPostBundleById(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;
      
      final postsModel = feature_posts.PostsModel.fromSnapshot(doc);
      return PostsModelAdapter.toDomainModels(postsModel);
    } catch (e) {
      throw Exception('Failed to get post bundle: $e');
    }
  }
  
  /// Get post core data only
  Future<PostCore?> getPostCore(String postId) async {
    final bundle = await getPostBundleById(postId);
    return bundle?.core;
  }
  
  /// Get post content only
  Future<PostContent?> getPostContent(String postId) async {
    final bundle = await getPostBundleById(postId);
    return bundle?.content;
  }
  
  /// Get post voting data only
  Future<PostVoting?> getPostVoting(String postId) async {
    final bundle = await getPostBundleById(postId);
    return bundle?.voting;
  }
  
  /// Get post metrics only
  Future<PostMetrics?> getPostMetrics(String postId) async {
    final bundle = await getPostBundleById(postId);
    return bundle?.metrics;
  }
  
  /// Create post from domain models
  Future<String> createPostFromBundle(PostBundle bundle) async {
    try {
      final postsModel = PostsModelAdapter.fromDomainModels(bundle);
      final data = postsModel.toFirestore();
      final docRef = await _postsCollection.add(data);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create post from bundle: $e');
    }
  }
  
  /// Update post using domain models
  Future<void> updatePostFromBundle(String postId, PostBundle bundle) async {
    try {
      final postsModel = PostsModelAdapter.fromDomainModels(bundle);
      final data = postsModel.toFirestore();
      await _postsCollection.doc(postId).update(data);
    } catch (e) {
      throw Exception('Failed to update post from bundle: $e');
    }
  }
  
  /// Stream of post bundles
  Stream<List<PostBundle>> getPostBundlesStream() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final postsModel = feature_posts.PostsModel.fromSnapshot(doc);
            return PostsModelAdapter.toDomainModels(postsModel);
          }).toList();
        });
  }
  
  /// Get posts by user as bundles
  Stream<List<PostBundle>> getPostBundlesByUserId(String userId) {
    return _postsCollection
        .where('userid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final postsModel = feature_posts.PostsModel.fromSnapshot(doc);
            return PostsModelAdapter.toDomainModels(postsModel);
          }).toList();
        });
  }
}
