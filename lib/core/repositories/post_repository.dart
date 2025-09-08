import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/posts/domain/models/posts_model.dart';
import '/features/posts/domain/models/comments_model.dart';
import '/features/posts/domain/models/likes_model.dart';
import '/features/posts/domain/models/dislikes_model.dart';
import '/features/posts/domain/models/ranked_posts_model.dart';

/// Repository interface for Post-related operations
/// This interface defines the contract that must be implemented
/// by the data layer to provide post functionality
abstract class PostRepository {
  // Post queries
  Stream<List<PostsModel>> queryPosts({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryPostsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  Future<PostsModel?> queryPostsSingleRecord({
    Query Function(Query)? queryBuilder,
    bool singleRecord = true,
  });

  // Comment queries
  Stream<List<CommentsModel>> queryComments({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryCommentsCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Like queries
  Stream<List<LikesModel>> queryLikes({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryLikesCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Dislike queries  
  Stream<List<DislikesModel>> queryDislikes({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryDislikesCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Ranked posts queries
  Stream<List<RankedPostsModel>> queryRankedPosts({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryRankedPostsCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // CRUD operations
  Future<PostsModel?> getPost(String postId);
  Future<void> createPost(PostsModel post);
  Future<void> updatePost(PostsModel post);
  Future<void> deletePost(String postId);
}