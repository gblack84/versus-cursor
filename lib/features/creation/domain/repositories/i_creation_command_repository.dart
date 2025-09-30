import '../../domain/entities/post_creation.dart';
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';

/// Repository interface for post creation/update/delete commands
/// Creation feature의 핵심 Command Repository
abstract class ICreationCommandRepository {
  /// Create new content post
  Future<String> createContent(PostCreation post);

  /// Update existing content
  Future<void> updateContent(String contentId, PostCreation post);

  /// Delete content
  Future<void> deleteContent(String contentId);

  /// Publish content (change visibility)
  Future<void> publishContent(String contentId);

  /// Save draft content
  Future<void> saveDraft(String contentId, PostCreation post);

  /// Update post core information only
  Future<void> updateContentCore(String contentId, PostCore core);

  /// Update post content only
  Future<void> updateContentBody(String contentId, PostContent content);
}