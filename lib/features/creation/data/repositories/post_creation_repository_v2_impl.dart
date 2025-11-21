import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import '../../domain/failures/creation_failure.dart';
import '../../domain/entities/post_creation.dart';
import '../../domain/entities/post_creation_extensions.dart'; // ✅ Phase 5: Extension Pattern
import '../../domain/entities/target_audience.dart';
import '../../domain/services/i_target_audience_service.dart';
import '../../domain/services/i_image_processing_service.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '/services/cache/creation_cache_service.dart';
import '/services/idempotency/idempotency_service.dart'; // ✅ Phase 4: Idempotency
import '/services/logging/logger_service.dart';

// Use ValidationResult from ITargetAudienceService
export '../../domain/services/i_target_audience_service.dart'
    show ValidationResult;

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
/// Phase 2 Migration: Either pattern migration complete
/// Phase 3 Migration: UnifiedCacheService Integration (Draft Auto-Save)
/// Phase 4 Migration: Idempotency Pattern (Duplicate Operation Prevention)
/// Phase 5 Migration: Extension Pattern (DataSource/Mapper → Direct Firestore)
///   - Removed: IPostCreationDataSource, CreationFirestoreMapper
///   - Added: PostCreationFirestore Extension, TargetAudienceFirestore Extension
///   - Direct Firestore transformation via Extension methods
class PostCreationRepositoryV2Impl implements IPostCreationRepositoryV2 {
  final ITargetAudienceService? _targetAudienceService;
  final IImageProcessingService _imageProcessingService;
  final CollectionReference<Map<String, dynamic>> _postsCollection;
  final CreationCacheService _cacheService; // ✅ Phase 3: Cache Integration
  final IdempotencyService _idempotencyService; // ✅ Phase 4: Idempotency

  PostCreationRepositoryV2Impl({
    ITargetAudienceService? targetAudienceService,
    required IImageProcessingService imageProcessingService,
    required CreationCacheService cacheService, // ✅ Phase 3: DI Injection
    required IdempotencyService idempotencyService, // ✅ Phase 4: DI Injection
    FirebaseFirestore? firestore,
  }) : _targetAudienceService = targetAudienceService,
       _imageProcessingService = imageProcessingService,
       _cacheService = cacheService,
       _idempotencyService = idempotencyService,
       _postsCollection = (firestore ?? FirebaseFirestore.instance).collection(
         'posts',
       );

  // ====== Creation Operations ======

  @override
  Future<Either<CreationFailure, String>> createPost({
    required PostCreation post,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      final postId = await _idempotencyService.executeIdempotent<String>(
        entityType: 'post_create',
        entityId: post.id ?? 'draft_${post.userId}',
        userId: post.userId,
        eventId: eventId,
        operation: (transaction) async {
          // ✅ Phase 5: Use Extension to convert PostCreation to Firestore document
          final data = post.toFirestore();

          // Additional default fields for backward compatibility
          data['postCreatedDate'] = Timestamp.fromDate(post.createdAt);

          // Note: PostVoting and PostMetrics fields will be added by their respective features
          // through onCreate triggers or after post creation

          // Create the post using Transaction
          final docRef = _postsCollection.doc();
          transaction.set(docRef, data);

          return docRef.id;
        },
      );

      // ✅ Phase 3: Delete Draft after successful post creation
      await deleteDraftPost(post.userId);

      return right(postId);
    } on IdempotencyViolation catch (_) {
      // User attempted same operation with different eventId (real duplicate)
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'create',
          // message:'Duplicate post creation attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'create',
          // message:'Failed to create post: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'create',
          // message:'Unexpected error during post creation: $e',
        ),
      );
    }
  }

  // ========== Phase 3: Draft Post Operations ==========

  /// Draft Post 조회 (Cache-First Pattern)
  ///
  /// **Flow**:
  /// 1. L1/L2 캐시 시도 (<10ms)
  /// 2. 캐시 미스 → Firestore에서 Draft 조회
  /// 3. 캐시 업데이트 (다음 조회 시 <10ms)
  ///
  /// **사용처**:
  /// - 앱 재시작 시 작성 중이던 Draft 복원
  /// - 백그라운드 전환 후 복귀 시 Draft 복원
  ///
  /// **Example**:
  /// ```dart
  /// final draft = await repository.getDraftPost('user123');
  /// if (draft != null) {
  ///   // Draft 복원 성공 (<10ms)
  /// }
  /// ```
  Future<PostCreation?> getDraftPost(String userId) async {
    // 1. ✅ 캐시 먼저 시도 (L1 → L2)
    final cachedDraft = await _cacheService.getDraftPost(userId);
    if (cachedDraft != null) {
      return cachedDraft; // <10ms 응답
    }

    // 2. ✅ Firestore에서 Draft 조회
    final snapshot = await _postsCollection
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'draft')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // ✅ Phase 5: Use Extension to convert Firestore document to PostCreation
    final draft = PostCreationFirestore.fromFirestore(snapshot.docs.first);

    // 3. ✅ 캐시 업데이트 (다음 조회 시 <10ms)
    await _cacheService.setDraftPost(userId, draft);

    return draft;
  }

  /// Draft Post 저장 (Write-Through Pattern)
  ///
  /// **Flow**:
  /// 1. 캐시에 즉시 저장 (<10ms, UI 반응성 보장)
  /// 2. Firestore에 비동기 저장 (백그라운드, 데이터 안전성)
  ///
  /// **Auto-Save 전략** (Provider에서 구현):
  /// - 500ms Debounce: 연속 입력 시 마지막만 저장
  /// - Write-Through: 캐시와 Firestore 동시 업데이트
  ///
  /// **Example**:
  /// ```dart
  /// final draft = PostCreation(
  ///   userId: 'user123',
  ///   title: '작성 중인 질문',
  ///   status: PostStatus.draft,
  /// );
  /// await repository.saveDraftPost('user123', draft);
  /// // <10ms 응답, UI 블로킹 없음
  /// ```
  Future<void> saveDraftPost(
    String userId,
    PostCreation draft,
  ) async {
    // 1. ✅ 캐시에 즉시 저장 (UI 반응성)
    await _cacheService.setDraftPost(userId, draft);

    // 2. ✅ Firestore에 비동기 저장 (데이터 안전성)
    //    Option 1: 고정 ID로 자연스러운 멱등성 보장 (IdempotencyService 불필요)
    scheduleMicrotask(() async {
      try {
        final draftId = 'draft_$userId';  // ✅ 고정 ID per user
        // ✅ Phase 5: Direct Firestore set() with Extension
        await _postsCollection.doc(draftId).set(draft.toFirestore());

        Logger.info(
          'Draft saved successfully: $draftId',
          tag: 'PostCreationRepository',
        );
      } catch (e) {
        // 실패 시 재시도 로직 (Optional)
        // TODO: Implement retry with exponential backoff
        Logger.warning(
          'Draft save failed: $e',
          tag: 'PostCreationRepository',
        );
      }
    });
  }

  /// Draft Post 삭제 (게시 완료 시)
  ///
  /// **사용처**:
  /// - Post 게시 완료 시 Draft 자동 삭제 (createPost()에서 호출)
  /// - 사용자가 명시적으로 Draft 삭제 시
  ///
  /// **Example**:
  /// ```dart
  /// await repository.deleteDraftPost('user123');
  /// // L1, L2, L3 모두 삭제
  /// ```
  Future<void> deleteDraftPost(String userId) async {
    // 1. 캐시 무효화
    await _cacheService.invalidateDraftPost(userId);

    // 2. Firestore Draft 삭제
    final snapshot = await _postsCollection
        .where('userid', isEqualTo: userId)
        .where('status', isEqualTo: 'draft')
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  /// 타겟 오디언스 프리셋 조회 (최근 사용 설정)
  ///
  /// **사용처**:
  /// - 새 질문 작성 시 최근 사용한 타겟 설정 자동 완성
  /// - 타겟 설정 UI 초기값 제공
  ///
  /// **Example**:
  /// ```dart
  /// final preset = await repository.getTargetAudiencePreset('user123');
  /// if (preset != null) {
  ///   // 자동 완성: 최근 사용한 타겟 설정 적용
  /// }
  /// ```
  Future<TargetAudience?> getTargetAudiencePreset(String userId) async {
    // 1. 캐시에서 프리셋 조회
    final preset = await _cacheService.getTargetAudiencePreset(userId);
    if (preset != null) {
      return preset;
    }

    // 2. 최근 게시물에서 타겟 오디언스 추출
    final snapshot = await _postsCollection
        .where('userid', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // ✅ Phase 5: Use Extension
    final lastPost = PostCreationFirestore.fromFirestore(snapshot.docs.first);

    // 3. 캐시 업데이트
    final audience = lastPost.targetAudience;
    if (audience != null) {
      await _cacheService.setTargetAudiencePreset(userId, audience);
    }

    return audience;
  }

  // ====== Update Operations ======

  @override
  Future<Either<CreationFailure, Unit>> updatePost({
    required String postId,
    required PostCreation post,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'post_update',
        entityId: postId,
        userId: post.userId,
        eventId: eventId,
        operation: (transaction) async {
          // ✅ Phase 5: Use Extension to convert PostCreation to Firestore document
          final data = post.toFirestore();
          final docRef = _postsCollection.doc(postId);
          transaction.update(docRef, data);
        },
      );
      return right(unit);
    } on IdempotencyViolation catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'update',
          postId: postId,
          // message:'Duplicate post update attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'update',
          postId: postId,
          // message:'Failed to update post: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'update',
          postId: postId,
          // message:'Unexpected error during post update: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> updatePostPartial({
    required String postId,
    required Map<String, dynamic> data,
  }) async {
    try {
      // ✅ Phase 5: Direct Firestore update
      await _postsCollection.doc(postId).update(data);
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'update',
          postId: postId,
          // message:'Failed to update post partial: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'update',
          postId: postId,
          // message:'Unexpected error during partial update: $e',
        ),
      );
    }
  }

  // Note: updatePostContentOld, updatePostVoting, updatePostMetrics removed
  // - updatePostContentOld: Legacy method no longer needed
  // - updatePostVoting: Handled by Voting Feature
  // - updatePostMetrics: Handled by Post Feature

  // ====== Delete Operations ======

  @override
  Future<Either<CreationFailure, Unit>> deletePost({
    required String postId,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'post_delete',
        entityId: postId,
        userId:
            '', // deletePost doesn't have userId directly, use postId as identifier
        eventId: eventId,
        operation: (transaction) async {
          final docRef = _postsCollection.doc(postId);
          transaction.update(docRef, {
            'deleted': true,
            'deletedAt': DateTime.now(),
          });
        },
      );
      return right(unit);
    } on IdempotencyViolation catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'delete',
          postId: postId,
          // message:'Duplicate post delete attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'delete',
          postId: postId,
          // message:'Failed to delete post: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'delete',
          postId: postId,
          // message:'Unexpected error during post deletion: $e',
        ),
      );
    }
  }

  // ====== Media Operations ======

  @override
  Future<Either<CreationFailure, Unit>> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'media_upload',
        entityId: postId,
        userId:
            '', // Media upload doesn't have userId, use postId as identifier
        eventId: eventId,
        operation: (transaction) async {
          final field = side != null ? 'option$side.images' : 'images';
          final docRef = _postsCollection.doc(postId);

          transaction.update(docRef, {
            field: FieldValue.arrayUnion([
              {
                'url': mediaUrl,
                'type': mediaType,
                'uploadedAt': DateTime.now(),
              },
            ]),
          });
        },
      );
      return right(unit);
    } on IdempotencyViolation catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'uploadMedia',
          postId: postId,
          // message:'Duplicate media upload attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'uploadMedia',
          postId: postId,
          // message:'Failed to upload media: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'uploadMedia',
          postId: postId,
          // message:'Unexpected error during media upload: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side,
  }) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'deleteMedia',
            postId: postId,
            // message:'Post not found',
          ),
        );
      }

      final data = doc.data() as Map<String, dynamic>;
      final field = side != null ? 'option$side' : null;

      if (field != null) {
        final option = data[field] as Map<String, dynamic>? ?? {};
        final images = (option['images'] as List<dynamic>? ?? [])
            .where((img) => img['url'] != mediaUrl)
            .toList();

        await _postsCollection.doc(postId).update({'$field.images': images});
      }
      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'deleteMedia',
          postId: postId,
          // message:'Failed to delete media: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'deleteMedia',
          postId: postId,
          // message:'Unexpected error during media deletion: $e',
        ),
      );
    }
  }

  // ====== Status Operations ======

  @override
  Future<Either<CreationFailure, Unit>> updatePostStatus({
    required String postId,
    required String status,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'post_status_update',
        entityId: postId,
        userId: '', // updatePostStatus doesn't have userId directly
        eventId: eventId,
        operation: (transaction) async {
          final docRef = _postsCollection.doc(postId);
          transaction.update(docRef, {
            'status': status,
            'updatedAt': DateTime.now(),
          });
        },
      );
      return right(unit);
    } on IdempotencyViolation catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'updateStatus',
          postId: postId,
          // message:'Duplicate status update attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'updateStatus',
          postId: postId,
          // message:'Failed to update status: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'updateStatus',
          postId: postId,
          // message:'Unexpected error during status update: $e',
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> markPostAsProcessed({
    required String postId,
    DateTime? processedAt,
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    try {
      // ✅ Phase 4: Wrap operation in Idempotency Service
      await _idempotencyService.executeIdempotent<void>(
        entityType: 'post_processing_mark',
        entityId: postId,
        userId: '', // markPostAsProcessed doesn't have userId directly
        eventId: eventId,
        operation: (transaction) async {
          final docRef = _postsCollection.doc(postId);
          transaction.update(docRef, {
            'processingStatus': 'completed',
            'processedAt': processedAt ?? DateTime.now(),
          });
        },
      );
      return right(unit);
    } on IdempotencyViolation catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'markProcessed',
          postId: postId,
          // message:'Duplicate mark processed attempt: ${e.message}',
          // code:'idempotency_violation',
        ),
      );
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'markProcessed',
          postId: postId,
          // message:'Failed to mark as processed: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'markProcessed',
          postId: postId,
          // message:'Unexpected error marking as processed: $e',
        ),
      );
    }
  }

  // ====== Query Operations ======
  // Note: getPostBundle removed - spans multiple features

  @override
  Future<Either<CreationFailure, Option<PostCreation>>> getPost(
    String postId,
  ) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) {
        return right(none());
      }

      // ✅ Phase 5: Use Extension
      final post = PostCreationFirestore.fromFirestore(doc);
      return right(some(post));
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'getPost',
          postId: postId,
          // message:'Failed to get post: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'getPost',
          postId: postId,
          // message:'Unexpected error while getting post: $e',
        ),
      );
    }
  }

  // Note: getPostVoting and getPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== Stream Operations ======
  // Note: watchPostBundle removed - spans multiple features

  @override
  Stream<Either<CreationFailure, PostCreation>> watchPost(String postId) {
    return _postsCollection.doc(postId).snapshots().map((doc) {
      try {
        if (!doc.exists) {
          return left(
            CreationFailure.postCreationRepositoryFailed(
              operation: 'watchPost',
              postId: postId,
              // message:'Post not found',
            ),
          );
        }
        // ✅ Phase 5: Use Extension
        final post = PostCreationFirestore.fromFirestore(doc);
        return right(post);
      } on FirebaseException {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'watchPost',
            postId: postId,
            // message:'Failed to watch post: ${e.message}',
            // code:e.code,
          ),
        );
      } catch (_) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'watchPost',
            postId: postId,
            // message:'Unexpected error while watching post: $e',
          ),
        );
      }
    });
  }

  // Note: watchPostVoting and watchPostMetrics removed
  // These are handled by Voting Feature and Post Feature respectively

  // ====== User's Posts ======

  @override
  Stream<Either<CreationFailure, List<PostCreation>>> getUserCreatedPosts({
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
      try {
        // ✅ Phase 5: Use Extension
        final posts = snapshot.docs
            .map((doc) => PostCreationFirestore.fromFirestore(doc))
            .toList();
        return right(posts);
      } on FirebaseException {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'getUserCreatedPosts',
            // message:'Failed to get user posts: ${e.message}',
            // code:e.code,
          ),
        );
      } catch (_) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'getUserCreatedPosts',
            // message:'Unexpected error while getting user posts: $e',
          ),
        );
      }
    });
  }

  @override
  Future<Either<CreationFailure, int>> getUserCreatedPostsCount(
    String userId,
  ) async {
    try {
      final snapshot = await _postsCollection
          .where('userid', isEqualTo: userId)
          .count()
          .get();
      return right(snapshot.count ?? 0);
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'getUserCreatedPostsCount',
          // message:'Failed to get user posts count: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'getUserCreatedPostsCount',
          // message:'Unexpected error while getting user posts count: $e',
        ),
      );
    }
  }

  // ====== Validation ======

  @override
  Future<Either<CreationFailure, Unit>> validatePostData({
    required PostCreation post,
  }) async {
    try {
      // Basic validation
      if (post.title.isEmpty) {
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'title': 'Title is required'},
          ),
        );
      }
      if (post.userId.isEmpty) {
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'userId': 'User ID is required'},
          ),
        );
      }

      // Check content (at least one option must have content)
      final hasOptionA =
          post.optionA.text?.isNotEmpty == true ||
          post.optionA.imageUrls.isNotEmpty ||
          (post.optionA.videoUrls?.isNotEmpty ?? false);
      final hasOptionB =
          post.optionB.text?.isNotEmpty == true ||
          post.optionB.imageUrls.isNotEmpty ||
          (post.optionB.videoUrls?.isNotEmpty ?? false);

      if (!hasOptionA && !hasOptionB) {
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'options': 'Both options are empty'},
          ),
        );
      }

      return right(unit);
    } catch (_) {
      return left(
        CreationFailure.creationValidationFailed(
          fieldErrors: {'unknown': 'Unexpected validation error'},
        ),
      );
    }
  }

  @override
  Future<Either<CreationFailure, Unit>> canUserCreatePost(String userId) async {
    try {
      // Check rate limiting (e.g., max 10 posts per day)
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      final snapshot = await _postsCollection
          .where('userid', isEqualTo: userId)
          .where('createdAt', isGreaterThanOrEqualTo: startOfDay)
          .count()
          .get();

      final count = snapshot.count ?? 0;
      if (count >= 10) {
        return left(
          CreationFailure.postCreationRepositoryFailed(
            operation: 'canUserCreatePost',
            // message:'User has reached daily post limit (10 posts per day)',
          ),
        );
      }

      return right(unit);
    } on FirebaseException {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'canUserCreatePost',
          // message:'Failed to check user post limit: ${e.message}',
          // code:e.code,
        ),
      );
    } catch (_) {
      return left(
        CreationFailure.postCreationRepositoryFailed(
          operation: 'canUserCreatePost',
          // message:'Unexpected error while checking post limit: $e',
        ),
      );
    }
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
    // Delegate to internal service (now returns Either)
    final resultEither = await _imageProcessingService.processMultipleImages(
      files: files,
      box: box,
      onProgress: onProgress,
    );

    // Unwrap Either - throw if failed (service operations should handle errors)
    return resultEither.fold(
      (failure) =>
          throw Exception('Image processing failed: ${failure.message}'),
      (result) => ImageProcessingResult(
        approvedFiles: result.approvedFiles,
        approvedRatios: result.approvedRatios,
        approvedAssetIds: result.approvedAssetIds,
        rejectedReasons: result.rejectedReasons,
        rejectedIndices: result.rejectedIndices,
        rejectedCount: result.rejectedCount,
        allRejected: result.allRejected,
      ),
    );
  }

  @override
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  }) async {
    // Delegate to internal service (now returns Either)
    final resultEither = await _imageProcessingService.processEditedImage(
      editedFile: editedFile,
      box: box,
      assetId: assetId,
      onProgress: onProgress,
    );

    // Unwrap Either - throw if failed (service operations should handle errors)
    return resultEither.fold(
      (failure) =>
          throw Exception('Image processing failed: ${failure.message}'),
      (result) => SingleImageResult(
        success: result.success,
        file: result.file,
        aspectRatio: result.aspectRatio,
        assetId: result.assetId,
        rejectionReason: result.moderationResult?.reason,
      ),
    );
  }

  @override
  Map<String, dynamic> convertTargetAudienceToStorageFormat(
    TargetAudience targetAudience,
  ) {
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
  Future<Either<CreationFailure, String>> createContent(
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    // Direct delegation to createPost with eventId
    return createPost(post: post, eventId: eventId);
  }

  @override
  Future<Either<CreationFailure, Unit>> updateContent(
    String contentId,
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    // Direct delegation to updatePost with eventId
    return updatePost(postId: contentId, post: post, eventId: eventId);
  }

  @override
  Future<Either<CreationFailure, Unit>> deleteContent(
    String contentId, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    return deletePost(postId: contentId, eventId: eventId);
  }

  @override
  Future<Either<CreationFailure, Unit>> publishContent(
    String contentId, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    return updatePostStatus(
      postId: contentId,
      status: 'published',
      eventId: eventId,
    );
  }

  @override
  Future<Either<CreationFailure, Unit>> saveDraft(
    String contentId,
    PostCreation post, {
    required String eventId, // ✅ Phase 4: UUID for idempotency
  }) async {
    // Update post and set status to draft - need to chain Either operations
    final updateResult = await updatePost(
      postId: contentId,
      post: post,
      eventId: eventId,
    );
    if (updateResult.isLeft()) return updateResult;

    return updatePostStatus(
      postId: contentId,
      status: 'draft',
      eventId: eventId,
    );
  }

  // Note: _postOptionToMediaContent helper removed
  // CreationFirestoreMapper now handles PostOption ↔ MediaContent conversion
}
