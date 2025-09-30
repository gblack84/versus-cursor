import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/app/contracts/models/post_bundle.dart';
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';
import '../../domain/models/media_content.dart';
import '../../domain/models/target_audience.dart';
import '../../domain/services/i_target_audience_service.dart' as service;
import '../../domain/services/i_image_processing_service.dart';
import '/features/voting/domain/models/chat/post_voting.dart';
import '/features/post/domain/models/post_metrics.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../../domain/datasources/i_post_creation_datasource.dart';
import '../services/target_audience_service.dart';
import '../services/image_upload_service.dart';
import '../mappers/creation_firestore_mapper.dart';

/// Implementation of IPostCreationRepositoryV2
///
/// Uses DataSource to isolate Firebase dependencies and handles
/// post creation with PostBundle and domain models for Clean Architecture.
///
/// ## Mapper Usage
/// - **CreationFirestoreMapper**: Handles all Creation Feature data (PostCore, PostContent)
///   - ✅ createPostFromModels() - Creation part only
///   - ✅ updatePostCore() - Full mapper usage
///   - ✅ updatePostContent() - Full mapper usage
///   - ✅ updatePostContentOld() - Legacy method using mapper
///   - ✅ _extractPostCore() - Full mapper usage
///   - ✅ _extractPostContent() - Full mapper usage
///
/// ## Feature Boundaries
/// - **Creation Feature**: PostCore, PostContent (Using CreationFirestoreMapper)
/// - **Voting Feature**: PostVoting (Manual conversion - temporary)
/// - **Post Feature**: PostMetrics (Manual conversion - temporary)
///
/// Phase 1.3: Services are now internal dependencies
/// Phase 2: CreationFirestoreMapper fully integrated
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
  Future<String> createPost(PostBundle bundle) {
    return createPostFromModels(
      core: bundle.core,
      content: bundle.content,
      voting: bundle.voting,
      metrics: bundle.metrics,
    );
  }

  @override
  Future<String> createPostFromModels({
    required PostCore core,
    required PostContent content,
    required PostVoting voting,
    required PostMetrics metrics,
  }) async {
    // Use CreationFirestoreMapper for Creation Feature fields
    final data = _mapper.toCreateDocument(core, content);

    // Add PostVoting fields (owned by Voting Feature)
    if (voting.voteStartTime != null) data['voteStartTime'] = voting.voteStartTime;
    if (voting.voteEndTime != null) data['voteEndTime'] = voting.voteEndTime;
    data['voteStatus'] = voting.voteStatus;
    data['voteCompleted'] = voting.voteCompleted;
    data['votesA'] = voting.votesA;
    data['votesB'] = voting.votesB;
    data['votedUserIdsA'] = voting.votedUserIdsA;
    data['votedUserIdsB'] = voting.votedUserIdsB;
    data['notificationsSent'] = voting.notificationsSent;

    // Add PostMetrics fields (owned by Post Feature)
    data['commentcount'] = metrics.commentCount;
    data['likecount'] = metrics.likeCount;
    data['sherecount'] = metrics.shareCount; // Preserve original typo
    data['savecount'] = metrics.saveCount;
    data['reportCount'] = metrics.reportCount;
    data['participantcount'] = metrics.participantCount;
    data['interestcount'] = metrics.interestCount;

    // Additional default fields
    data['postCreatedDate'] = core.createdAt; // For backward compatibility

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

  @override
  Future<void> updatePostContentOld({
    required String postId,
    required PostContent content,
  }) async {
    // Legacy method for backward compatibility - now using mapper for consistency
    final data = _mapper.toUpdateDocument(content: content);
    await updatePost(postId: postId, data: data);
  }

  @override
  Future<void> updatePostVoting({
    required String postId,
    required PostVoting voting,
  }) async {
    final data = {
      if (voting.voteStartTime != null) 'voteStartTime': voting.voteStartTime,
      if (voting.voteEndTime != null) 'voteEndTime': voting.voteEndTime,
      'voteStatus': voting.voteStatus,
      'voteCompleted': voting.voteCompleted,
      'votesA': voting.votesA,
      'votesB': voting.votesB,
      'votedUserIdsA': voting.votedUserIdsA,
      'votedUserIdsB': voting.votedUserIdsB,
      'updatedAt': DateTime.now(),
    };
    await updatePost(postId: postId, data: data);
  }

  @override
  Future<void> updatePostMetrics({
    required String postId,
    required PostMetrics metrics,
  }) async {
    final data = {
      'commentcount': metrics.commentCount,
      'likecount': metrics.likeCount,
      'sherecount': metrics.shareCount,
      'savecount': metrics.saveCount,
      'reportCount': metrics.reportCount,
      'participantcount': metrics.participantCount,
      'interestcount': metrics.interestCount,
      'updatedAt': DateTime.now(),
    };
    await updatePost(postId: postId, data: data);
  }

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

  @override
  Future<PostBundle?> getPostBundle(String postId) async {
    final core = await getPostCore(postId);
    if (core == null) return null;

    final content = await getPostContent(postId);
    final voting = await getPostVoting(postId);
    final metrics = await getPostMetrics(postId);

    if (content == null || voting == null || metrics == null) return null;

    return PostBundle(
      core: core,
      content: content,
      voting: voting,
      metrics: metrics,
    );
  }

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

  @override
  Future<PostVoting?> getPostVoting(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return _extractPostVoting(data, postId);
  }

  @override
  Future<PostMetrics?> getPostMetrics(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return _extractPostMetrics(data, postId);
  }

  // ====== Stream Operations ======

  @override
  Stream<PostBundle> watchPostBundle(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');

      final data = doc.data() as Map<String, dynamic>;
      return PostBundle(
        core: _extractPostCore(data, postId)!,
        content: _extractPostContent(data, postId)!,
        voting: _extractPostVoting(data, postId)!,
        metrics: _extractPostMetrics(data, postId)!,
      );
    });
  }

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

  @override
  Stream<PostVoting> watchPostVoting(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');
      final data = doc.data() as Map<String, dynamic>;
      return _extractPostVoting(data, postId)!;
    });
  }

  @override
  Stream<PostMetrics> watchPostMetrics(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      if (!doc.exists) throw Exception('Post not found');
      final data = doc.data() as Map<String, dynamic>;
      return _extractPostMetrics(data, postId)!;
    });
  }

  // ====== User's Posts ======

  @override
  Stream<List<PostBundle>> getUserCreatedPosts({
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

        return PostBundle(
          core: _extractPostCore(data, postId)!,
          content: _extractPostContent(data, postId)!,
          voting: _extractPostVoting(data, postId)!,
          metrics: _extractPostMetrics(data, postId)!,
        );
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
  Future<bool> validatePostData(PostBundle bundle) async {
    // Basic validation
    if (bundle.core.questionTitle.isEmpty) return false;
    if (bundle.core.userId.isEmpty) return false;
    if (!bundle.isConsistent) return false;

    // Check content
    if (bundle.content.optionA.isEmpty && bundle.content.optionB.isEmpty) {
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
    if (_targetAudienceService != null) {
      return _targetAudienceService.validateTargetAudience(targetAudience);
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
    if (_targetAudienceService != null) {
      return _targetAudienceService.convertModelToFirestore(targetAudience);
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

  // ====== Other Features Domain (Manual conversion - will be migrated to their own mappers) ======

  PostVoting? _extractPostVoting(Map<String, dynamic> data, String postId) {
    // ⚠️ Voting Feature responsibility - Manual conversion
    // TODO: Will be moved to VotingFirestoreMapper when Voting Feature is migrated
    return PostVoting(
      postId: postId,
      voteStartTime: _parseDateTime(data['voteStartTime']),
      voteEndTime: _parseDateTime(data['voteEndTime']),
      voteStatus: data['voteStatus'] ?? 'pending',
      voteCompleted: data['voteCompleted'] ?? false,
      voteCompletedAt: _parseDateTime(data['voteCompletedAt']),
      voteCancelledAt: _parseDateTime(data['voteCancelledAt']),
      voteCancelledReason: data['voteCancelledReason'],
      voteTimeout: const Duration(minutes: 10),
      votesA: data['votesA'] ?? 0,
      votesB: data['votesB'] ?? 0,
      votedUserIdsA: List<String>.from(data['votedUserIdsA'] ?? []),
      votedUserIdsB: List<String>.from(data['votedUserIdsB'] ?? []),
      displayVotesA: data['displayVotesA'],
      displayVotesB: data['displayVotesB'],
      notificationsSent: data['notificationsSent'] ?? 0,
      notificationsSentAt: _parseDateTime(data['notificationsSentAt']),
      expansionPointsUsed: data['expansionPointsUsed'] ?? 0,
      expandedUserCount: data['expandedUserCount'] ?? 0,
      expansionStatus: data['expansionStatus'] ?? 'none',
    );
  }

  PostMetrics? _extractPostMetrics(Map<String, dynamic> data, String postId) {
    // ⚠️ Post Feature responsibility - Manual conversion
    // TODO: Will be moved to PostFirestoreMapper when Post Feature is migrated
    return PostMetrics(
      postId: postId,
      commentCount: data['commentcount'] ?? 0,
      likeCount: data['likecount'] ?? 0,
      shareCount: data['sherecount'] ?? 0,
      saveCount: data['savecount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      participantCount: data['participantcount'] ?? 0,
      interestCount: data['interestcount'] ?? 0,
      engagementRate: 0.0, // Will be calculated
      qualityScore: 0.0, // Will be calculated
      firstInteractionAt: _parseDateTime(data['createdAt']),
      lastInteractionAt: data['updatedAt'] != null
          ? _parseDateTime(data['updatedAt'])
          : _parseDateTime(data['createdAt']),
    );
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);

    // Assume Firestore Timestamp
    try {
      return (value as dynamic).toDate();
    } catch (_) {
      return DateTime.now();
    }
  }

  // Visibility conversion methods are no longer needed
  // They are handled by CreationFirestoreMapper
}