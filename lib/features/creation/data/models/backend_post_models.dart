/// Backend model aliases for Clean Architecture compatibility
///
/// This file provides aliases and adapters between backend models and feature models
/// to maintain backward compatibility while following Clean Architecture principles.

// Import existing backend models
import 'comments_model.dart' as backend_comments;
import 'likes_model.dart' as backend_likes;

// For exports in backend.dart
export 'comments_model.dart' show ContentCommentsModel;
export 'likes_model.dart' show ContentsLikesModel;
export '../../domain/models/dislikes_model.dart';
export 'ranked_posts_model.dart';

// Re-export with expected names for backend compatibility
typedef CommentsModel = backend_comments.ContentCommentsModel;
typedef LikesModel = backend_likes.ContentsLikesModel;

// Helper functions to maintain API compatibility
Map<String, dynamic> createCommentsModelData({
  String? commentId,
  String? userId,
  String? text,
  DateTime? createdAt,
  bool? isPremium,
  int? likesCount,
}) =>
    backend_comments.createContentCommentsModelData(
      commentId: commentId,
      userId: userId,
      text: text,
      createdAt: createdAt,
      isPremium: isPremium,
      likesCount: likesCount,
    );

Map<String, dynamic> createLikesModelData({
  String? userId,
  DateTime? createdAt,
}) =>
    backend_likes.createContentsLikesModelData(
      userId: userId,
      createdAt: createdAt,
    );
