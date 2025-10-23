/// Creation Feature Dependency Injection Module
///
/// This module configures dependency injection for the Creation feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote/Local)
/// - Services/Domain Interfaces
/// - Repositories
/// - UseCases
/// - Media Providers
/// - Coordinator
/// - Main Providers

import 'package:get_it/get_it.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/creation_contract.dart';

// ===== Data Layer - DataSource Implementations =====
import '../data/datasources/firebase_post_creation_datasource.dart';
import '../data/datasources/firebase_storage_datasource.dart';

// ===== Domain Layer - Service Interfaces (Ports) =====
import '../domain/services/i_image_processing_service.dart';
import '../domain/services/i_target_audience_service.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/specialized/i_metrics_repository.dart';
import '../domain/repositories/specialized/i_moderation_repository.dart';
import '../domain/repositories/specialized/i_visibility_repository.dart';
import '../domain/repositories/i_media_repository.dart';
import '../domain/repositories/i_post_creation_repository_v2.dart';
import '/features/post/domain/repositories/i_post_query_service.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/image_processing_repository_impl.dart';
import '../data/repositories/target_audience_repository_impl.dart';
import '../data/repositories/content_metrics_repository_impl.dart';
import '../data/repositories/content_moderation_repository_impl.dart';
import '../data/repositories/content_visibility_repository_impl.dart';
import '../data/repositories/media_repository_impl.dart';
import '../data/repositories/post_creation_repository_v2_impl.dart';
import '/features/post/data/repositories/post_query_service_impl.dart';

// ===== Domain Layer - UseCases =====
import '../domain/usecases/create_post_usecase.dart';
import '../domain/usecases/moderate_content_usecase.dart';
import '../domain/usecases/validation/validate_post_usecase.dart';
import '../domain/usecases/audience/manage_target_audience_usecase.dart';

// ===== Presentation Layer - Media Providers =====
import '../presentation/providers/media/media_selection_provider.dart';
import '../presentation/providers/media/media_upload_provider.dart';
import '../presentation/providers/media/media_validation_provider.dart';
import '../presentation/providers/media/media_state_coordinator.dart';

// ===== Presentation Layer - Main Providers =====
import '../presentation/providers/create_post_provider_v2.dart';
import '../presentation/providers/target_audience_provider.dart';

/// Register all Creation feature dependencies
/// Call this function from main setupDependencyInjection()
void registerCreationModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Services/Domain Interfaces Registration =====
  _registerServices(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== CreationContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Media Providers Registration =====
  _registerMediaProviders(getIt);

  // ===== Coordinator Registration =====
  _registerCoordinator(getIt);

  // ===== Main Providers Registration =====
  _registerProviders(getIt);
}

/// Register Remote and Local DataSources
void _registerDataSources(GetIt getIt) {
  // Firebase Post Creation DataSource
  getIt.registerLazySingleton<FirebasePostCreationDataSource>(
    () => FirebasePostCreationDataSource(),
  );

  // Firebase Storage DataSource
  getIt.registerLazySingleton<FirebaseStorageDataSource>(
    () => FirebaseStorageDataSource(),
  );
}

/// Register Services/Domain Interfaces (Port → Adapter pattern)
void _registerServices(GetIt getIt) {
  // Image Processing Service (Port → Adapter)
  getIt.registerLazySingleton<IImageProcessingService>(
    () => ImageProcessingRepositoryImpl(),
  );

  // Target Audience Service (Port → Adapter)
  getIt.registerLazySingleton<ITargetAudienceService>(
    () => TargetAudienceRepositoryImpl(),
  );
}

/// Register Repository implementations
void _registerRepositories(GetIt getIt) {
  // 1. Content Metrics Repository
  getIt.registerLazySingleton<IContentMetricsRepository>(
    () => ContentMetricsRepositoryImpl(),
  );

  // 2. Content Moderation Repository
  getIt.registerLazySingleton<IContentModerationRepository>(
    () => ContentModerationRepositoryImpl(),
  );

  // 3. Content Visibility Repository
  getIt.registerLazySingleton<IContentVisibilityRepository>(
    () => ContentVisibilityRepositoryImpl(),
  );

  // 4. Post Query Service
  getIt.registerLazySingleton<IPostQueryService>(
    () => PostQueryServiceImpl(),
  );

  // 5. Media Repository
  getIt.registerLazySingleton<IMediaRepository>(
    () => MediaRepositoryImpl(
      storageDataSource: getIt<FirebaseStorageDataSource>(),
    ),
  );

  // 6. Post Creation Repository V2
  getIt.registerLazySingleton<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(
      dataSource: getIt<FirebasePostCreationDataSource>(),
      imageProcessingService: getIt<IImageProcessingService>(),
    ),
  );
}

/// Register CreationContract (Cross-Feature Communication)
/// PostCreationRepositoryV2Impl implements both IPostCreationRepositoryV2 and CreationContract (Dual Interface)
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<CreationContract>(
    () => getIt<IPostCreationRepositoryV2>() as PostCreationRepositoryV2Impl,
  );
}

/// Register all UseCases (4 total)
void _registerUseCases(GetIt getIt) {
  // Manage Target Audience UseCase
  getIt.registerFactory(
    () => ManageTargetAudienceUseCase(
      targetAudienceService: getIt<ITargetAudienceService>(),
    ),
  );

  // Create Post UseCase
  getIt.registerFactory(
    () => CreatePostUseCase(
      postRepository: getIt<IPostCreationRepositoryV2>(),
      mediaRepository: getIt<IMediaRepository>(),
      manageTargetAudienceUseCase: getIt<ManageTargetAudienceUseCase>(),
    ),
  );

  // Moderate Content UseCase (no dependencies)
  getIt.registerFactory(
    () => ModerateContentUseCase(),
  );

  // Validate Post UseCase
  getIt.registerFactory(
    () => ValidatePostUseCase(),
  );
}

/// Register Media Providers (used by Coordinator)
void _registerMediaProviders(GetIt getIt) {
  // Media Selection Provider (no dependencies)
  getIt.registerFactory(
    () => MediaSelectionProvider(),
  );

  // Media Upload Provider
  getIt.registerFactory(
    () => MediaUploadProvider(
      mediaRepository: getIt<IMediaRepository>(),
      imageProcessingService: getIt<IImageProcessingService>(),
    ),
  );

  // Media Validation Provider
  getIt.registerFactory(
    () => MediaValidationProvider(
      moderateContentUseCase: getIt<ModerateContentUseCase>(),
    ),
  );
}

/// Register Coordinator
void _registerCoordinator(GetIt getIt) {
  // Media State Coordinator
  getIt.registerFactory(
    () => MediaStateCoordinator(
      selectionProvider: getIt<MediaSelectionProvider>(),
      uploadProvider: getIt<MediaUploadProvider>(),
      validationProvider: getIt<MediaValidationProvider>(),
    ),
  );
}

/// Register Main Presentation Layer Providers
void _registerProviders(GetIt getIt) {
  // Create Post Provider V2
  getIt.registerFactory(
    () => CreatePostProviderV2(
      createPostUseCase: getIt<CreatePostUseCase>(),
      moderateContentUseCase: getIt<ModerateContentUseCase>(),
      validatePostUseCase: getIt<ValidatePostUseCase>(),
      mediaCoordinator: getIt<MediaStateCoordinator>(),
    ),
  );

  // Target Audience Provider (no dependencies)
  getIt.registerFactory(
    () => TargetAudienceModel(),
  );
}
