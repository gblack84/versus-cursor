import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';
import '../../domain/models/target_audience.dart';
import '../../domain/services/i_target_audience_service.dart' as service;
import '../../domain/services/i_image_processing_service.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../../domain/datasources/i_post_creation_datasource.dart';
import '../services/target_audience_service.dart';
import '../services/image_upload_service.dart';
import '../mappers/creation_firestore_mapper.dart';

/// Implementation of IPostCreationRepositoryV2
///
/// Uses DataSource to isolate Firebase dependencies and handles
/// post creation with PostCore and PostContent only (Creation Feature responsibility).
///
/// ## Mapper Usage
/// - **CreationFirestoreMapper**: Handles all Creation Feature data (PostCore, PostContent)
///   - ✅ createPost() - Creation part only
///   - ✅ updatePostCore() - Full mapper usage
///   - ✅ updatePostContent() - Full mapper usage
///   - ✅ _extractPostCore() - Full mapper usage
///   - ✅ _extractPostContent() - Full mapper usage
///
/// ## Feature Boundaries
/// - **Creation Feature**: PostCore, PostContent (Using CreationFirestoreMapper)
/// - **Voting Feature**: Will add PostVoting fields via onCreate trigger
/// - **Post Feature**: Will add PostMetrics fields after voting completion
///
/// Phase 1.3: Services are now internal dependencies
/// Phase 2: CreationFirestoreMapper fully integrated
/// Phase 8: PostVoting/PostMetrics removed - Feature isolation complete
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final IPostCreationDataSource _dataSource;
  final TargetAudienceService? _targetAudienceService;
  final ImageUploadService _imageUploadService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationFirestoreMapper _mapper = CreationFirestoreMapper();

  PostCreationRepositoryV2Impl({
    required IPostCreationDataSource dataSource,
    TargetAudienceService? targetAudienceService,
    required ImageUploadService imageUploadService,
    FirebaseFirestore? firestore,
  }) : _dataSource = dataSource,
       _targetAudienceService = targetAudienceService,
       _imageUploadService = imageUploadService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection('posts');

  // ====== Creation Operations ======

  @override
  Future<String> createPost({
    required PostCore core,
    required PostContent content,
  }) async {
    // Use CreationFirestoreMapper for Creation Feature fields only
    final data = _mapper.toCreateDocument(core, content);

    // Additional default fields for backward compatibility
    data['postCreatedDate'] = core.createdAt;

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
    required Map<String, dynamic> data,
  }) async {
    await _dataSource.updatePost(postId, data);
  }

  @override
  Future<void> updatePostCore({
    required String postId,
    required PostCore core,
  }) async {
    final data = _mapper.toUpdateDocument(core: core);
    await updatePost(postId: postId, data: data);
  }

  @override
  Future<void> updatePostContent({
    required String postId,
    required PostContent content,
  }) async {
    final data = _mapper.toUpdateDocument(content: content);
    await updatePost(postId: postId, data: data);
  }

  // Note: updatePostContentOld, updatePostVoting, updatePostMetrics removed
  // - updatePostContentOld: Legacy method no longer needed
  // - updatePostVoting: Handled by Voting Feature
  // - updatePostMetrics: Handled by Post Feature

  // ====== Delete Operations ======

  @override
  Future<void> deletePost(String postId) async {
    // For now, we can delegate to updatePost to mark as deleted
    // or create a deletePost method in DataSource
    await updatePost(postId: postId, data: {'deleted': true, 'deletedAt': DateTime.now()});
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
    await updatePost(postId: postId, data: {
      'status': status,
      'updatedAt': DateTime.now(),
    });
  }

  @override
  Future<void> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
  }) async {
    await updatePost(postId: postId, data: {
      'processingStatus': 'completed',
      'processedAt': processedAt ?? DateTime.now(),
    });
  }

  // ====== Query Operations ======
  // Note: getPostBundle removed - spans multiple features

  @override
  Future<PostCore?> getPostCore(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return _extractPostCore(data, postId);
  }

  @override
  Future<PostContent?> getPostContent(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return _extractPostContent(data, postId);
  }

  // Note: getPostVoting and getPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== Stream Operations ======
  // Note: watchPostBundle removed - spans multiple features

  @override
  Stream<PostCore> watchPostCore(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');
      final data = doc.data() as Map<String, dynamic>;
      return _extractPostCore(data, postId)!;
    });
  }

  @override
  Stream<PostContent> watchPostContent(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');
      final data = doc.data() as Map<String, dynamic>;
      return _extractPostContent(data, postId)!;
    });
  }

  // Note: watchPostVoting and watchPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== User's Posts ======

  @override
  Stream<List<PostCore>> getUserCreatedPosts({
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

        return _extractPostCore(data, postId)!;
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
    required PostCore core,
    required PostContent content,
  }) async {
    // Basic validation
    if (core.questionTitle.isEmpty) return false;
    if (core.userId.isEmpty) return false;

    // Check content
    if (content.optionA.isEmpty && content.optionB.isEmpty) {
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
  service.ValidationResult validateTargetAudience(TargetAudience targetAudience) {
    // Delegate to internal service if available
    final audienceService = _targetAudienceService;
    if (audienceService != null) {
      return audienceService.validateTargetAudience(targetAudience);
    }
    // Return valid if no service available (temporary)
    return service.ValidationResult(isValid: true);
  }

  @override
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  }) async {
    // Delegate to internal service
    final result = await _imageUploadService.processMultipleImages(
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
    final result = await _imageUploadService.processEditedImage(
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

  // ====== Creation Feature Domain (Using CreationFirestoreMapper) ======

  PostCore? _extractPostCore(Map<String, dynamic> data, String postId) {
    // ✅ Creation Feature responsibility - Using CreationFirestoreMapper
    return _mapper.extractPostCore(data, postId);
  }

  PostContent? _extractPostContent(Map<String, dynamic> data, String postId) {
    // ✅ Creation Feature responsibility - Using CreationFirestoreMapper
    return _mapper.extractPostContent(data, postId);
  }

  // ====== Other Features Domain ======
  // Note: _extractPostVoting and _extractPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively
  // Each feature will implement their own mappers to extract their domain models from Firestore

  // Note: _parseDateTime removed - no longer needed
  // CreationFirestoreMapper handles all DateTime conversions for Creation Feature
  // Other features will implement their own mappers with their own DateTime handling
}