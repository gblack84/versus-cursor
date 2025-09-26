import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/posts_model.dart';

/// Repository interface for Post creation operations
/// This interface is focused on creating and modifying posts
abstract class IPostCreationRepository {
  // Post creation operations
  Future<DocumentReference> createPost(PostsModel post);

  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  });

  Future<void> deletePost(String postId);

  // Post media operations
  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
  });

  // Post statistics updates (for creation context)
  Future<void> incrementViewCount(String postId);

  Future<void> updatePostStatus({
    required String postId,
    required String status,
  });

  // Creation-specific queries
  Future<PostsModel?> getPostById(String postId);

  Stream<PostsModel> watchPost(String postId);

  // User's created posts
  Stream<List<PostsModel>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  Future<int> getUserCreatedPostsCount(String userId);
}