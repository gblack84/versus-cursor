import 'dart:async';
import '/features/posts/domain/models/posts_model.dart';

/// Cross-feature datasource interface for post data
/// Abstracts access to posts feature data
/// 
/// GlobalNotificationManager와 Posts feature 간의 의존성을 격리합니다.
abstract class IPostDatasource {
  /// Get post data by ID
  Future<Map<String, dynamic>?> getPost(String postId);
  
  /// Get post model by ID (typed version)
  Future<PostsModel?> getPostModel(String postId);
  
  /// Create post with target audience settings
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> postData,
    required Map<String, dynamic> targetAudience,
  });
  
  /// Update post notification status
  Future<void> updatePostNotificationStatus({
    required String postId,
    required bool notificationsSent,
    DateTime? notificationsSentAt,
  });
  
  /// Get posts for user
  Future<List<Map<String, dynamic>>> getUserPosts(String userId);
  
  /// Check if post exists
  Future<bool> postExists(String postId);
  
  /// Get post creator ID
  Future<String?> getPostCreatorId(String postId);
  
  /// Update post vote counts
  Future<void> updatePostVotes({
    required String postId,
    required int votesA,
    required int votesB,
  });
  
  /// Get user's target audience statistics
  /// Returns a list of posts with target audience data for statistics
  Future<List<Map<String, dynamic>>> getUserPostsWithTargetAudience({
    required String userId,
    int limit = 100,
  });
}