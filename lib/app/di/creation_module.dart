import 'package:get_it/get_it.dart';
import 'package:flutter/material.dart';
import 'feature_modules.dart';
import '../../features/creation/domain/usecases/create_post_usecase.dart';
import '../../features/creation/domain/usecases/moderate_content_usecase.dart';
// import '../../features/creation/domain/usecases/get_feed_usecase.dart'; // TODO: Implement in Phase 5
import '../../features/creation/domain/usecases/media/upload_images_usecase.dart';
import '../../features/creation/domain/usecases/audience/manage_target_audience_usecase.dart';
import '../../features/creation/domain/usecases/validation/validate_post_usecase.dart';
// import '../../features/creation/domain/repositories/i_post_repository.dart'; // Legacy - removed
import '../../features/creation/domain/repositories/i_media_repository.dart';
import '../../features/creation/domain/repositories/i_post_creation_repository_v2.dart';
import '../../features/creation/domain/repositories/i_creation_command_repository.dart';
import '../../features/creation/domain/repositories/i_content_metrics_repository.dart';
import '../../features/creation/domain/repositories/i_content_moderation_repository.dart';
import '../../features/creation/domain/repositories/i_content_visibility_repository.dart';
// ICreationQueryService moved to Post Feature as IPostQueryService
import '../../features/creation/domain/datasources/i_post_creation_datasource.dart';
import '../../features/creation/domain/datasources/i_storage_datasource.dart';
import '../../features/creation/domain/services/i_image_processing_service.dart';
import '../../features/creation/domain/services/i_media_upload_service.dart';
import '../../features/creation/data/repositories/media_repository_impl.dart';
import '../../features/creation/data/services/media_upload_service_impl.dart';
import '../../features/creation/data/repositories/post_creation_repository_v2_impl.dart';
import '../../features/creation/data/repositories/creation_command_repository_impl.dart';
import '../../features/creation/data/repositories/content_metrics_repository_impl.dart';
import '../../features/creation/data/repositories/content_moderation_repository_impl.dart';
import '../../features/creation/data/repositories/content_visibility_repository_impl.dart';
// CreationQueryServiceImpl moved to Post Feature as PostQueryServiceImpl
import '../../features/creation/data/datasources/firebase_post_creation_datasource.dart';
import '../../features/creation/data/datasources/firebase_storage_datasource.dart';
import '../../features/creation/data/services/target_audience_service.dart';
import '../../features/creation/data/services/image_upload_service.dart';
import '../../features/notifications/data/datasources/i_post_datasource.dart';
// Firebase implementation is directly in creation module
import '../../services/moderation/image_moderation_service.dart';
import '../../features/creation/presentation/providers/create_post_provider_v2.dart';
// import '../../features/creation/presentation/providers/feed_provider.dart'; // TODO: Implement in Phase 5
import '../../features/creation/presentation/providers/media/media_selection_provider.dart'; // Phase 5: Media state management
import '../../features/creation/presentation/providers/media/media_upload_provider.dart'; // Phase 5: Media upload management
import '../../features/creation/presentation/providers/media/media_validation_provider.dart'; // Phase 5: Media validation
import '../../features/creation/presentation/providers/media/media_state_coordinator.dart'; // Phase 5: State coordination

/// Creation Feature DI Module
///
/// Manages dependency injection for content creation features
/// following Clean Architecture principles.
///
/// This module handles:
/// - Post creation and publishing
/// - Media upload and processing
/// - Content moderation
/// - Target audience management
/// - CQRS pattern implementation for creation operations
class CreationModule implements FeatureModule {
  static bool _isInitialized = false;
  static final GetIt _getIt = GetIt.instance;

  @override
  String get name => 'Creation';

  @override
  bool get isInitialized => _isInitialized;

  @override
  void register(GetIt sl) {
    if (_isInitialized) return;

    // Register in order: DataSources → Services → Repositories → UseCases → Providers
    _registerDataSources(sl);
    _registerServices(sl);
    _registerRepositories(sl);
    _registerUseCases(sl);
    _registerProviders(sl);

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    // Unregister in reverse order
    _unregisterProviders(sl);
    _unregisterUseCases(sl);
    _unregisterRepositories(sl);
    _unregisterServices(sl);
    _unregisterDataSources(sl);

    _isInitialized = false;
  }

  /// Register DataSource implementations
  void _registerDataSources(GetIt sl) {
    // Storage DataSource
    if (!sl.isRegistered<IStorageDataSource>()) {
      sl.registerLazySingleton<IStorageDataSource>(
        () => FirebaseStorageDataSource(),
      );
    }

    // Post DataSource (shared with Notifications feature)
    if (!sl.isRegistered<IPostDatasource>()) {
      // TODO: Implement proper FirebasePostDatasource in notifications feature
      // For now, skip registration to avoid circular dependencies
      // sl.registerLazySingleton<IPostDatasource>(
      //   () => FirebasePostDatasource(),
      // );
    }

    // Post Creation DataSource
    if (!sl.isRegistered<IPostCreationDataSource>()) {
      sl.registerLazySingleton<IPostCreationDataSource>(
        () => FirebasePostCreationDataSource(),
      );
    }
  }

  /// Register Service implementations
  void _registerServices(GetIt sl) {
    // Target Audience Service
    if (!sl.isRegistered<TargetAudienceService>()) {
      sl.registerLazySingleton<TargetAudienceService>(
        // TODO: Fix TargetAudienceService dependencies
        () => TargetAudienceService(
          // postDatasource: sl<IPostDatasource>(),
        ),
      );
    }

    // Image Processing Service (implements IImageProcessingService)
    if (!sl.isRegistered<IImageProcessingService>()) {
      sl.registerLazySingleton<IImageProcessingService>(
        () => ImageUploadService(),
      );
    }

    // Legacy Image Upload Service registration for backward compatibility
    if (!sl.isRegistered<ImageUploadService>()) {
      sl.registerLazySingleton<ImageUploadService>(
        () => ImageUploadService(),
      );
    }

    // Image Moderation Service
    if (!sl.isRegistered<ImageModerationService>()) {
      sl.registerLazySingleton<ImageModerationService>(
        () => ImageModerationService(),
      );
    }

    // Media Upload Service (IMediaUploadService implementation)
    if (!sl.isRegistered<IMediaUploadService>()) {
      sl.registerLazySingleton<IMediaUploadService>(
        () => MediaUploadServiceImpl(
          mediaRepository: sl<IMediaRepository>(),
          imageProcessingService: sl<IImageProcessingService>(),
        ),
      );
    }
  }

  /// Register Repository implementations
  void _registerRepositories(GetIt sl) {
    // Media Repository
    if (!sl.isRegistered<IMediaRepository>()) {
      sl.registerLazySingleton<IMediaRepository>(
        () => MediaRepositoryImpl(
          storageDataSource: sl<IStorageDataSource>(),
        ),
      );
    }

    // Post Creation Repository V2
    if (!sl.isRegistered<IPostCreationRepositoryV2>()) {
      sl.registerLazySingleton<IPostCreationRepositoryV2>(
        () => PostCreationRepositoryV2Impl(
          dataSource: sl<IPostCreationDataSource>(),
          targetAudienceService: sl<TargetAudienceService>(),
          imageUploadService: sl<ImageUploadService>(),
        ),
      );
    }

    // Creation Command Repository (CQRS Command side)
    if (!sl.isRegistered<ICreationCommandRepository>()) {
      sl.registerLazySingleton<ICreationCommandRepository>(
        () => CreationCommandRepositoryImpl(
          storageDataSource: sl<IStorageDataSource>(),
        ),
      );
    }

    // Content Metrics Repository
    if (!sl.isRegistered<IContentMetricsRepository>()) {
      sl.registerLazySingleton<IContentMetricsRepository>(
        () => ContentMetricsRepositoryImpl(),
      );
    }

    // Content Moderation Repository
    if (!sl.isRegistered<IContentModerationRepository>()) {
      sl.registerLazySingleton<IContentModerationRepository>(
        () => ContentModerationRepositoryImpl(
          moderateUseCase: sl<ModerateContentUseCase>(),
        ),
      );
    }

    // Content Visibility Repository
    if (!sl.isRegistered<IContentVisibilityRepository>()) {
      sl.registerLazySingleton<IContentVisibilityRepository>(
        () => ContentVisibilityRepositoryImpl(
          targetAudienceUseCase: sl<ManageTargetAudienceUseCase>(),
        ),
      );
    }

    // Creation Query Service (CQRS Query side) - Moved to Post Feature as IPostQueryService
    // Registration now in PostsModule
  }

  /// Register UseCases
  void _registerUseCases(GetIt sl) {
    // Create Post UseCase
    // Phase 5 Restoration: ManageTargetAudienceUseCase fully integrated
    sl.registerFactory<CreatePostUseCase>(
      () => CreatePostUseCase(
        postRepository: sl<IPostCreationRepositoryV2>(),
        mediaRepository: sl<IMediaRepository>(),
        manageTargetAudienceUseCase: sl<ManageTargetAudienceUseCase>(),
      ),
    );

    // Moderate Content UseCase
    sl.registerFactory<ModerateContentUseCase>(
      () => ModerateContentUseCase(),
    );

    // Upload Images UseCase
    sl.registerFactory<UploadImagesUseCase>(
      () => UploadImagesUseCase(
        mediaRepository: sl<IMediaRepository>(),
        imageProcessingService: sl<IImageProcessingService>(),
      ),
    );

    // Manage Target Audience UseCase
    sl.registerFactory<ManageTargetAudienceUseCase>(
      () => ManageTargetAudienceUseCase(
        targetAudienceService: sl<TargetAudienceService>(),
      ),
    );

    // Validate Post UseCase
    sl.registerFactory<ValidatePostUseCase>(
      () => const ValidatePostUseCase(),
    );

    // TODO: Implement GetFeedUseCase in Phase 5
    // sl.registerFactory<GetFeedUseCase>(
    //   () => GetFeedUseCase(
    //     postRepository: sl<IPostRepository>(),
    //   ),
    // );
  }

  /// Register Providers
  void _registerProviders(GetIt sl) {
    // Media Selection Provider (Singleton for state persistence)
    if (!sl.isRegistered<MediaSelectionProvider>()) {
      sl.registerLazySingleton<MediaSelectionProvider>(
        () => MediaSelectionProvider(),
      );
    }

    // Media Upload Provider (Singleton for global upload state)
    if (!sl.isRegistered<MediaUploadProvider>()) {
      sl.registerLazySingleton<MediaUploadProvider>(
        () => MediaUploadProvider(
          mediaRepository: sl<IMediaRepository>(),
          mediaUploadService: sl<IMediaUploadService>(),
          imageUploadService: sl<ImageUploadService>(),
        ),
      );
    }

    // Media Validation Provider (Singleton for caching validation results)
    if (!sl.isRegistered<MediaValidationProvider>()) {
      sl.registerLazySingleton<MediaValidationProvider>(
        () => MediaValidationProvider(
          moderateContentUseCase: sl<ModerateContentUseCase>(),
        ),
      );
    }

    // Media State Coordinator (Factory for independent instances)
    sl.registerFactory<MediaStateCoordinator>(
      () => MediaStateCoordinator(
        selectionProvider: sl<MediaSelectionProvider>(),
        uploadProvider: sl<MediaUploadProvider>(),
        validationProvider: sl<MediaValidationProvider>(),
      ),
    );

    // Create Post Provider V2
    sl.registerFactory<CreatePostProviderV2>(
      () => CreatePostProviderV2(
        createPostUseCase: sl<CreatePostUseCase>(),
        moderateContentUseCase: sl<ModerateContentUseCase>(),
        validatePostUseCase: sl<ValidatePostUseCase>(),
        mediaCoordinator: sl<MediaStateCoordinator>(),
      ),
    );

    // Note: PostAggregateProvider moved to Post feature
    // The creation feature now focuses solely on post creation

    // TODO: Implement FeedProvider in Phase 5
    // sl.registerFactory<FeedProvider>(
    //   () => FeedProvider(
    //     getFeedUseCase: sl<GetFeedUseCase>(),
    //   ),
    // );
  }

  /// Unregister DataSources
  void _unregisterDataSources(GetIt sl) {
    if (sl.isRegistered<IStorageDataSource>()) {
      sl.unregister<IStorageDataSource>();
    }
    if (sl.isRegistered<IPostDatasource>()) {
      sl.unregister<IPostDatasource>();
    }
    if (sl.isRegistered<IPostCreationDataSource>()) {
      sl.unregister<IPostCreationDataSource>();
    }
  }

  /// Unregister Services
  void _unregisterServices(GetIt sl) {
    if (sl.isRegistered<TargetAudienceService>()) {
      sl.unregister<TargetAudienceService>();
    }
    if (sl.isRegistered<IImageProcessingService>()) {
      sl.unregister<IImageProcessingService>();
    }
    if (sl.isRegistered<ImageUploadService>()) {
      sl.unregister<ImageUploadService>();
    }
    if (sl.isRegistered<ImageModerationService>()) {
      sl.unregister<ImageModerationService>();
    }
  }

  /// Unregister Repositories
  void _unregisterRepositories(GetIt sl) {
    if (sl.isRegistered<IMediaRepository>()) {
      sl.unregister<IMediaRepository>();
    }
    if (sl.isRegistered<IPostCreationRepositoryV2>()) {
      sl.unregister<IPostCreationRepositoryV2>();
    }
    if (sl.isRegistered<ICreationCommandRepository>()) {
      sl.unregister<ICreationCommandRepository>();
    }
    if (sl.isRegistered<IContentMetricsRepository>()) {
      sl.unregister<IContentMetricsRepository>();
    }
    if (sl.isRegistered<IContentModerationRepository>()) {
      sl.unregister<IContentModerationRepository>();
    }
    if (sl.isRegistered<IContentVisibilityRepository>()) {
      sl.unregister<IContentVisibilityRepository>();
    }
    // ICreationQueryService moved to PostsModule as IPostQueryService
  }

  /// Unregister UseCases
  void _unregisterUseCases(GetIt sl) {
    if (sl.isRegistered<CreatePostUseCase>()) {
      sl.unregister<CreatePostUseCase>();
    }
    if (sl.isRegistered<ModerateContentUseCase>()) {
      sl.unregister<ModerateContentUseCase>();
    }
    if (sl.isRegistered<UploadImagesUseCase>()) {
      sl.unregister<UploadImagesUseCase>();
    }
    if (sl.isRegistered<ManageTargetAudienceUseCase>()) {
      sl.unregister<ManageTargetAudienceUseCase>();
    }
  }

  /// Unregister Providers
  void _unregisterProviders(GetIt sl) {
    if (sl.isRegistered<MediaSelectionProvider>()) {
      sl.unregister<MediaSelectionProvider>();
    }
    if (sl.isRegistered<MediaUploadProvider>()) {
      sl.unregister<MediaUploadProvider>();
    }
    if (sl.isRegistered<MediaValidationProvider>()) {
      sl.unregister<MediaValidationProvider>();
    }
    if (sl.isRegistered<MediaStateCoordinator>()) {
      sl.unregister<MediaStateCoordinator>();
    }
    if (sl.isRegistered<CreatePostProviderV2>()) {
      sl.unregister<CreatePostProviderV2>();
    }
  }

  // Static helper methods for backward compatibility during migration

  /// Get CreatePostProviderV2 instance
  static CreatePostProviderV2 getCreatePostProvider() {
    return _getIt<CreatePostProviderV2>();
  }


  /// Get MediaSelectionProvider instance
  static MediaSelectionProvider getMediaSelectionProvider() {
    return _getIt<MediaSelectionProvider>();
  }

  /// Get MediaUploadProvider instance
  static MediaUploadProvider getMediaUploadProvider() {
    return _getIt<MediaUploadProvider>();
  }

  /// Get MediaValidationProvider instance
  static MediaValidationProvider getMediaValidationProvider() {
    return _getIt<MediaValidationProvider>();
  }

  /// Get MediaStateCoordinator instance
  static MediaStateCoordinator getMediaStateCoordinator() {
    return _getIt<MediaStateCoordinator>();
  }

  /// Create provider with dependency injection
  /// @deprecated Use GetIt directly instead
  static T createProvider<T extends ChangeNotifier>() {
    if (T == CreatePostProviderV2) {
      return CreatePostProviderV2(
        createPostUseCase: _getIt<CreatePostUseCase>(),
        moderateContentUseCase: _getIt<ModerateContentUseCase>(),
        validatePostUseCase: _getIt<ValidatePostUseCase>(),
        mediaCoordinator: _getIt<MediaStateCoordinator>(),
      ) as T;
    }
    // TODO: Add FeedProvider in Phase 5
    throw UnimplementedError('Provider $T not configured');
  }

  /// Initialize module (for backward compatibility)
  /// @deprecated Use register() through DI.init() instead
  static Future<void> initialize() async {
    final module = CreationModule();
    module.register(_getIt);
  }

  /// Reset all registrations (useful for testing)
  static Future<void> reset() async {
    final module = CreationModule();
    module.unregister(_getIt);
  }
}