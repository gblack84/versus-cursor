import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/usecases/validation/validate_post_usecase.dart';
import '../../domain/repositories/i_post_creation_repository_v2.dart';
import '../../domain/repositories/i_media_repository.dart';
import '../../domain/services/i_image_processing_service.dart';
import 'media/media_state_coordinator.dart';
import '/app/di.dart';

part 'creation_providers.g.dart';

// ============= Repository Providers =============

/// Post Creation Repository Provider
///
/// Provides access to the post creation repository for CRUD operations
@riverpod
IPostCreationRepositoryV2 postCreationRepository(Ref ref) {
  return getIt<IPostCreationRepositoryV2>();
}

/// Media Repository Provider
///
/// Provides access to media upload and management operations
@riverpod
IMediaRepository mediaRepository(Ref ref) {
  return getIt<IMediaRepository>();
}

// ============= Service Providers =============

/// Image Processing Service Provider
///
/// Provides access to image processing and moderation service
@riverpod
IImageProcessingService imageProcessingService(Ref ref) {
  return getIt<IImageProcessingService>();
}

/// Media State Coordinator Provider
///
/// Coordinates media selection and upload state across providers
@riverpod
MediaStateCoordinator mediaStateCoordinator(Ref ref) {
  return getIt<MediaStateCoordinator>();
}

// ============= UseCase Providers =============

/// Create Post UseCase Provider
///
/// Provides access to the post creation business logic
@riverpod
CreatePostUseCase createPostUseCase(Ref ref) {
  return CreatePostUseCase(
    postRepository: ref.watch(postCreationRepositoryProvider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
  );
}

/// Moderate Content UseCase Provider
///
/// Provides access to content moderation business logic
@riverpod
ModerateContentUseCase moderateContentUseCase(Ref ref) {
  // ModerateContentUseCase is injected via GetIt, not created here
  return getIt<ModerateContentUseCase>();
}

/// Validate Post UseCase Provider
///
/// Provides access to post validation business logic
@riverpod
ValidatePostUseCase validatePostUseCase(Ref ref) {
  // ValidatePostUseCase is injected via GetIt, not created here
  return getIt<ValidatePostUseCase>();
}
