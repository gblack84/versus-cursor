// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'creation_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Post Creation Repository Provider
///
/// Provides access to the post creation repository for CRUD operations

@ProviderFor(postCreationRepository)
const postCreationRepositoryProvider = PostCreationRepositoryProvider._();

/// Post Creation Repository Provider
///
/// Provides access to the post creation repository for CRUD operations

final class PostCreationRepositoryProvider
    extends
        $FunctionalProvider<
          IPostCreationRepositoryV2,
          IPostCreationRepositoryV2,
          IPostCreationRepositoryV2
        >
    with $Provider<IPostCreationRepositoryV2> {
  /// Post Creation Repository Provider
  ///
  /// Provides access to the post creation repository for CRUD operations
  const PostCreationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'postCreationRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$postCreationRepositoryHash();

  @$internal
  @override
  $ProviderElement<IPostCreationRepositoryV2> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IPostCreationRepositoryV2 create(Ref ref) {
    return postCreationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IPostCreationRepositoryV2 value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IPostCreationRepositoryV2>(value),
    );
  }
}

String _$postCreationRepositoryHash() =>
    r'842680f7f84df93380bdccce1244c7ab7d51675a';

/// Media Repository Provider
///
/// Provides access to media upload and management operations

@ProviderFor(mediaRepository)
const mediaRepositoryProvider = MediaRepositoryProvider._();

/// Media Repository Provider
///
/// Provides access to media upload and management operations

final class MediaRepositoryProvider
    extends
        $FunctionalProvider<
          IMediaRepository,
          IMediaRepository,
          IMediaRepository
        >
    with $Provider<IMediaRepository> {
  /// Media Repository Provider
  ///
  /// Provides access to media upload and management operations
  const MediaRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaRepositoryHash();

  @$internal
  @override
  $ProviderElement<IMediaRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IMediaRepository create(Ref ref) {
    return mediaRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IMediaRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IMediaRepository>(value),
    );
  }
}

String _$mediaRepositoryHash() => r'ceadbbccd05e51a43e94dc87b5d9c22c6f804113';

/// Image Processing Service Provider
///
/// Provides access to image processing and moderation service

@ProviderFor(imageProcessingService)
const imageProcessingServiceProvider = ImageProcessingServiceProvider._();

/// Image Processing Service Provider
///
/// Provides access to image processing and moderation service

final class ImageProcessingServiceProvider
    extends
        $FunctionalProvider<
          IImageProcessingService,
          IImageProcessingService,
          IImageProcessingService
        >
    with $Provider<IImageProcessingService> {
  /// Image Processing Service Provider
  ///
  /// Provides access to image processing and moderation service
  const ImageProcessingServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'imageProcessingServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$imageProcessingServiceHash();

  @$internal
  @override
  $ProviderElement<IImageProcessingService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IImageProcessingService create(Ref ref) {
    return imageProcessingService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IImageProcessingService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IImageProcessingService>(value),
    );
  }
}

String _$imageProcessingServiceHash() =>
    r'b724c3de01104f759c8f83bac20bac2877f6d0e1';

/// Media State Coordinator Provider
///
/// **MOVED to media_coordinator_provider.dart** (Phase 2-7-3)
/// This provider is now defined in media/media_coordinator_provider.dart
/// and exported above. The old GetIt-based version is replaced.
// @riverpod
// MediaStateCoordinator mediaStateCoordinator(Ref ref) {
//   return getIt<MediaStateCoordinator>();
// }
// ============= UseCase Providers =============
/// Create Post UseCase Provider
///
/// Provides access to the post creation business logic

@ProviderFor(createPostUseCase)
const createPostUseCaseProvider = CreatePostUseCaseProvider._();

/// Media State Coordinator Provider
///
/// **MOVED to media_coordinator_provider.dart** (Phase 2-7-3)
/// This provider is now defined in media/media_coordinator_provider.dart
/// and exported above. The old GetIt-based version is replaced.
// @riverpod
// MediaStateCoordinator mediaStateCoordinator(Ref ref) {
//   return getIt<MediaStateCoordinator>();
// }
// ============= UseCase Providers =============
/// Create Post UseCase Provider
///
/// Provides access to the post creation business logic

final class CreatePostUseCaseProvider
    extends
        $FunctionalProvider<
          CreatePostUseCase,
          CreatePostUseCase,
          CreatePostUseCase
        >
    with $Provider<CreatePostUseCase> {
  /// Media State Coordinator Provider
  ///
  /// **MOVED to media_coordinator_provider.dart** (Phase 2-7-3)
  /// This provider is now defined in media/media_coordinator_provider.dart
  /// and exported above. The old GetIt-based version is replaced.
  // @riverpod
  // MediaStateCoordinator mediaStateCoordinator(Ref ref) {
  //   return getIt<MediaStateCoordinator>();
  // }
  // ============= UseCase Providers =============
  /// Create Post UseCase Provider
  ///
  /// Provides access to the post creation business logic
  const CreatePostUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createPostUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createPostUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreatePostUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreatePostUseCase create(Ref ref) {
    return createPostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreatePostUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreatePostUseCase>(value),
    );
  }
}

String _$createPostUseCaseHash() => r'e67a8af4976e6cabf7da0614b74f80ebe27324e5';

/// Moderate Content UseCase Provider
///
/// Provides access to content moderation business logic

@ProviderFor(moderateContentUseCase)
const moderateContentUseCaseProvider = ModerateContentUseCaseProvider._();

/// Moderate Content UseCase Provider
///
/// Provides access to content moderation business logic

final class ModerateContentUseCaseProvider
    extends
        $FunctionalProvider<
          ModerateContentUseCase,
          ModerateContentUseCase,
          ModerateContentUseCase
        >
    with $Provider<ModerateContentUseCase> {
  /// Moderate Content UseCase Provider
  ///
  /// Provides access to content moderation business logic
  const ModerateContentUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'moderateContentUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$moderateContentUseCaseHash();

  @$internal
  @override
  $ProviderElement<ModerateContentUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ModerateContentUseCase create(Ref ref) {
    return moderateContentUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ModerateContentUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ModerateContentUseCase>(value),
    );
  }
}

String _$moderateContentUseCaseHash() =>
    r'8f9a22a9a7c82f56abf4e208f04295ec6b2c441d';

/// Validate Post UseCase Provider
///
/// Provides access to post validation business logic

@ProviderFor(validatePostUseCase)
const validatePostUseCaseProvider = ValidatePostUseCaseProvider._();

/// Validate Post UseCase Provider
///
/// Provides access to post validation business logic

final class ValidatePostUseCaseProvider
    extends
        $FunctionalProvider<
          ValidatePostUseCase,
          ValidatePostUseCase,
          ValidatePostUseCase
        >
    with $Provider<ValidatePostUseCase> {
  /// Validate Post UseCase Provider
  ///
  /// Provides access to post validation business logic
  const ValidatePostUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'validatePostUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$validatePostUseCaseHash();

  @$internal
  @override
  $ProviderElement<ValidatePostUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ValidatePostUseCase create(Ref ref) {
    return validatePostUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ValidatePostUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ValidatePostUseCase>(value),
    );
  }
}

String _$validatePostUseCaseHash() =>
    r'743b7f70ffa7c22a572d246762a2f8c79ff10a8a';
