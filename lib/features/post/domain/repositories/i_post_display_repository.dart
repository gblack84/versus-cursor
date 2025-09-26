import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/creation/domain/models/posts_model.dart';
import '../models/comments_model.dart';
import '../models/likes_model.dart';
import '../models/dislikes_model.dart';
import '../models/ranked_posts_model.dart';

/// Repository interface for Post display/reading operations
/// This interface is focused on fetching and displaying posts
abstract class IPostDisplayRepository {
  // Post queries for display
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

  // Comment operations
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

  // Like operations
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

  // Dislike operations
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

  // Ranked posts operations
  Stream<List<RankedPostsModel>> queryRankedPosts({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryRankedPostsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });
}