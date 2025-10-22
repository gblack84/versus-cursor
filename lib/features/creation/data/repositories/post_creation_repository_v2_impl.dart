import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/app/contracts/creation_contract.dart';
import '../../domain/models/aggregates/post_creation.dart';
import '../../domain/models/value_objects/target_audience.dart';
import '../../domain/services/i_target_audience_service.dart';
import '../../domain/services/i_image_processing_service.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../datasources/interfaces/i_post_creation_datasource.dart';
import '../mappers/creation_firestore_mapper.dart';

// Use ValidationResult from ITargetAudienceService
export '../../domain/services/i_target_audience_service.dart' show ValidationResult;

/// Implementation of IPostCreationRepositoryV2
///
/// **Phase 2 Migration**: PostCore/PostContent 제거, PostCreation 직접 사용
/// Uses DataSource to isolate Firebase dependencies and handles
/// post creation with PostCreation aggregate (Creation Feature responsibility).
///
/// ## Mapper Usage
/// - **CreationFirestoreMapper**: Handles all Creation Feature data (PostCreation aggregate)
///   - ✅ createPost() - PostCreation → Firestore document
///   - ✅ updatePost() - PostCreation → Firestore update document
///   - ✅ getPost() - Firestore document → PostCreation
///   - ✅ watchPost() - Firestore stream → PostCreation stream
///
/// ## Feature Boundaries
/// - **Creation Feature**: PostCreation aggregate (Using CreationFirestoreMapper)
/// - **Voting Feature**: Will add PostVoting fields via onCreate trigger
/// - **Post Feature**: Will add PostMetrics fields after voting completion
///
/// Phase 1: MediaContent Freezed conversion complete
/// Phase 2: PostCore/PostContent removed, PostCreation direct usage (447 lines removed)
/// Phase 3: Dual Interface Pattern - implements both IPostCreationRepositoryV2 and CreationContract
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2, CreationContract {
  final IPostCreationDataSource _dataSource;
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // ====== Creation Operations ======

  @override
  Future<String> createPost({
    required PostCreation post,
  }) async {
    // Use CreationFirestoreMapper to convert PostCreation to Firestore document
    final data = _mapper.toCreateDocument(post);

    // Additional default fields for backward compatibility
    data['postCreatedDate'] = post.createdAt;

    // Note: PostVoting and PostMetrics fields will be added by their respective features
    // through onCreate triggers or after post creation

    // Create the post using DataSource
    final result = await _dataSource.createPost(data);

    // Extract the ID from the result
    final postId = result['id'] as String;

    return postId;
  }

  // ====== Update Operations ======

  @override
  Future<void> updatePost({
    required String postId,
    required PostCreation post,
  }) async {
    // Use CreationFirestoreMapper to convert PostCreation to Firestore update document
    final data = _mapper.toUpdateDocument(post);
    await _dataSource.updatePost(postId, data);
  }

  @override
  Future<void> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    await _dataSource.updatePost(postId, data);
  }

  // Note: updatePostContentOld, updatePostVoting, updatePostMetrics removed
  // - updatePostContentOld: Legacy method no longer needed
  // - updatePostVoting: Handled by Voting Feature
  // - updatePostMetrics: Handled by Post Feature

  // ====== Delete Operations ======

  @override
  Future<void> deletePost(String postId) async {
    // For now, we can delegate to updatePostPartial to mark as deleted
    // or create a deletePost method in DataSource
    await updatePostPartial(postId: postId, data: {'deleted': true, 'deletedAt': DateTime.now()});
    // TODO: Add deletePost to DataSource interface and implementation
  }

  // ====== Media Operations ======

  @override
  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  }) async {
    final field = side != null ? 'option$side.images' : 'images';
    await _postsCollection.doc(postId).update({
      field: FieldValue.arrayUnion([
        {
          'url': mediaUrl,
          'type': mediaType,
          'uploadedAt': DateTime.now(),
        }
      ]),
    });
  }

  @override
  Future<void> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side,
  }) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;
    final field = side != null ? 'option$side' : null;

    if (field != null) {
      final option = data[field] as Map<String, dynamic>? ?? {};
      final images = (option['images'] as List<dynamic>? ?? [])
          .where((img) => img['url'] != mediaUrl)
          .toList();

      await _postsCollection.doc(postId).update({
        '$field.images': images,
      });
    }
  }

  // ====== Status Operations ======

  @override
  Future<void> updatePostStatus({
    required String postId,
    required String status,
  }) async {
    await updatePostPartial(postId: postId, data: {
      'status': status,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  }) async {
    await updatePostPartial(postId: postId, data: {
      'processingStatus': 'completed',
      'processedAt': processedAt ?? DateTime.now(),
    });
  }

  // ====== Query Operations ======
  // Note: getPostBundle removed - spans multiple features

  @override
  Future<PostCreation?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return _mapper.extractPostCreation(data, postId);
  }

  // Note: getPostVoting and getPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== Stream Operations ======
  // Note: watchPostBundle removed - spans multiple features

  @override
  Stream<PostCreation> watchPost(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');
      final data = doc.data() as Map<String, dynamic>;
      return _mapper.extractPostCreation(data, postId);
    });
  }

  // Note: watchPostVoting and watchPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== User's Posts ======

  @override
  Stream<List<PostCreation>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  }) {
    Query query = _postsCollection
        .where('userid', isEqualTo: userId)
        .orderBy('createdAt', descending: true);

    if (limit > 0) {
      query = query.limit(limit);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final postId = doc.id;

        return _mapper.extractPostCreation(data, postId);
      }).toList();
    });
  }

  @override
  Future<int> getUserCreatedPostsCount(String userId) async {
    final snapshot = await _postsCollection
        .where('userid', isEqualTo: userId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // ====== Validation ======

  @override
  Future<bool> validatePostData({
    required PostCreation post,
  }) async {
    // Basic validation
    if (post.title.isEmpty) return false;
    if (post.userId.isEmpty) return false;

    // Check content (at least one option must have content)
    final hasOptionA = post.optionA.text?.isNotEmpty == true ||
                       post.optionA.imageUrls.isNotEmpty ||
                       (post.optionA.videoUrls?.isNotEmpty ?? false);
    final hasOptionB = post.optionB.text?.isNotEmpty == true ||
                       post.optionB.imageUrls.isNotEmpty ||
                       (post.optionB.videoUrls?.isNotEmpty ?? false);

    if (!hasOptionA && !hasOptionB) {
      return false;
    }

    return true;
  }

  @override
  Future<bool> canUserCreatePost(String userId) async {
    // Check rate limiting (e.g., max 10 posts per day)
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snapshot = await _postsCollection
        .where('userid', isEqualTo: userId)
        .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
        .count()
        .get();

    return (snapshot.count ?? 0) < 10; // Max 10 posts per day
  }

  // ====== Service Operations (Phase 1.3) ======

  @override
  ValidationResult validateTargetAudience(TargetAudience targetAudience) {
    // Delegate to internal service if available
    final audienceService = _targetAudienceService;
    if (audienceService != null) {
      return audienceService.validateTargetAudience(targetAudience);
    }
    // Return valid if no service available (temporary)
    return ValidationResult(isValid: true);
  }

  @override
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  }) async {
    // Delegate to internal service
    final result = await _imageProcessingService.processMultipleImages(
      files: files,
      box: box,
      onProgress: onProgress,
    );

    // Convert service result to domain result
    return ImageProcessingResult(
      approvedFiles: result.approvedFiles,
      approvedRatios: result.approvedRatios,
      approvedAssetIds: result.approvedAssetIds,
      rejectedReasons: result.rejectedReasons,
      rejectedIndices: result.rejectedIndices,
      rejectedCount: result.rejectedCount,
      allRejected: result.allRejected,
    );
  }

  @override
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    // Delegate to internal service
    final result = await _imageProcessingService.processEditedImage(
      editedFile: editedFile,
      box: box,
      assetId: assetId,
      onProgress: onProgress,
    );

    // Convert service result to domain result
    return SingleImageResult(
      success: result.success,
      file: result.file,
      aspectRatio: result.aspectRatio,
      assetId: result.assetId,
      rejectionReason: result.moderationResult?.reason,
    );
  }

  @override
  Map<String, dynamic> convertTargetAudienceToStorageFormat(TargetAudience targetAudience) {
    // Delegate to internal service if available
    final audienceService = _targetAudienceService;
    if (audienceService != null) {
      return audienceService.convertModelToFirestore(targetAudience);
    }
    // Return basic conversion if no service available
    return targetAudience.toMap();
  }

  // ====== Helper Methods ======
  // Note: All extraction helpers removed - CreationFirestoreMapper handles all conversions
  // - _extractPostCore: Replaced by _mapper.extractPostCreation()
  // - _extractPostContent: Replaced by _mapper.extractPostCreation()
  // - _extractPostVoting: Handled by Voting Feature
  // - _extractPostMetrics: Handled by Post Feature
  // - _parseDateTime: Handled by CreationFirestoreMapper

  // ====== Additional Command Operations (from ICreationCommandRepository) ======

  @override
  Future<String> createContent(PostCreation post) async {
    // Direct delegation to createPost - no conversion needed
    return createPost(post: post);
  }

  @override
  Future<void> updateContent(String contentId, PostCreation post) async {
    // Direct delegation to updatePost - no conversion needed
    await updatePost(postId: contentId, post: post);
  }

  @override
  Future<void> deleteContent(String contentId) async {
    await deletePost(contentId);
  }

  @override
  Future<void> publishContent(String contentId) async {
    await updatePostStatus(postId: contentId, status: 'published');
  }

  @override
  Future<void> saveDraft(String contentId, PostCreation post) async {
    // Update post and set status to draft
    await updatePost(postId: contentId, post: post);
    await updatePostStatus(postId: contentId, status: 'draft');
  }

  // Note: _postOptionToMediaContent helper removed
  // CreationFirestoreMapper now handles PostOption ↔ MediaContent conversion
}