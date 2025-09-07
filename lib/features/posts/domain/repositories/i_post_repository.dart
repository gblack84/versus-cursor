import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/post.dart';
import '../models/vote_data.dart';

/// Repository interface for post operations
abstract class IPostRepository {
  /// Get a stream of all posts
  Stream<List<Post>> getAllPosts();

  /// Get a stream of posts by user ID
  Stream<List<Post>> getPostsByUserId(String userId);

  /// Get a single post by ID
  Future<Post?> getPostById(String postId);

  /// Get a stream of a single post by ID
  Stream<Post?> getPostStream(String postId);

  /// Create a new post
  Future<String> createPost(Post post);

  /// Update an existing post
  Future<void> updatePost(String postId, Post post);

  /// Delete a post
  Future<void> deletePost(String postId);

  /// Update post vote data
  Future<void> updateVoteData(String postId, VoteData voteData);

  /// Cast a vote on a post
  Future<void> castVote(String postId, String userId, String option);

  /// Remove a vote from a post
  Future<void> removeVote(String postId, String userId, String option);

  /// Get posts by category
  Stream<List<Post>> getPostsByCategory(String category);

  /// Get posts by tags
  Stream<List<Post>> getPostsByTags(List<String> tags);

  /// Get trending posts
  Stream<List<Post>> getTrendingPosts({int limit = 20});

  /// Get recent posts
  Stream<List<Post>> getRecentPosts({int limit = 20});

  /// Search posts by query
  Stream<List<Post>> searchPosts(String query);

  /// Get posts with pagination
  Future<List<Post>> getPostsPaginated({
    DocumentSnapshot? lastDocument,
    int limit = 10,
  });

  /// Report a post
  Future<void> reportPost(String postId, String userId, String reason);

  /// Update post statistics
  Future<void> updatePostStats(String postId, Map<String, dynamic> stats);

  /// Get posts by visibility level
  Stream<List<Post>> getPostsByVisibility(int visibility);

  /// Get anonymous posts
  Stream<List<Post>> getAnonymousPosts();

  /// Get premium posts
  Stream<List<Post>> getPremiumPosts();

  /// Complete a vote
  Future<void> completeVote(String postId);

  /// Cancel a vote
  Future<void> cancelVote(String postId, String reason);

  /// Send notifications for a post
  Future<void> sendNotifications(String postId);

  /// Get vote results for a post
  Future<Map<String, dynamic>> getVoteResults(String postId);

  /// Check if user has voted on a post
  Future<bool> hasUserVoted(String postId, String userId);

  /// Get user's vote option on a post
  Future<String?> getUserVoteOption(String postId, String userId);
}
