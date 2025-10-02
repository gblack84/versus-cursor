// Removed Firebase dependency - Clean Architecture
import '/features/creation/domain/entities/post_creation.dart';
import '../models/comments_model.dart';
import '../models/likes_model.dart';
import '../models/dislikes_model.dart';
import '../models/ranked_posts_model.dart';

/// Repository interface for Post display/reading operations
/// This interface is focused on fetching and displaying posts
abstract class IPostDisplayRepository {
  // Post queries for display - Clean Architecture compliant
  Stream<List<PostCreation>> queryPosts({
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryPostsCount({
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  Future<PostCreation?> queryPostsSingleRecord({
    Map<String, dynamic>? filters,
    bool singleRecord = true,
  });

  // Comment operations - Clean Architecture compliant
  Stream<List<CommentsModel>> queryComments({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryCommentsCount({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Like operations - Clean Architecture compliant
  Stream<List<LikesModel>> queryLikes({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryLikesCount({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Dislike operations - Clean Architecture compliant
  Stream<List<DislikesModel>> queryDislikes({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryDislikesCount({
    required String parentId,
    Map<String, dynamic>? filters,
    int limit = -1,
  });

  // Ranked posts operations - Clean Architecture compliant
  Stream<List<RankedPostsModel>> queryRankedPosts({
    Map<String, dynamic>? filters,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryRankedPostsCount({
    Map<String, dynamic>? filters,
    int limit = -1,
  });
}