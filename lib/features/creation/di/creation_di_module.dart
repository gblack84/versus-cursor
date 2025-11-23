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

// ===== Services Layer - Global Services =====
import '/services/batch/batch_service.dart';

// ===== Services Layer - Cache Services (Phase 3) =====
import '/services/cache/unified_cache_service.dart';
import '/services/cache/creation_cache_service.dart';

// ===== Moderation Services (Text + Image Moderation) =====
// Moderation service implementations are registered globally in moderation_di_module.dart
// We only import the interfaces which are used for type annotations in getIt<T>()
import '/services/moderation/perspective_api_service.dart'; // For IPerspectiveApiService

// ===== Data Layer - DataSource Implementations =====
// ❌ Phase 5: Removed firebase_post_creation_datasource.dart (Extension Pattern replaces DataSource)
import '../data/datasources/firebase_storage_datasource.dart';

// ===== Data Layer - Adapters (Clean Architecture) =====
import '../data/adapters/box_calculator_adapter.dart';

// ===== Domain Layer - Service Interfaces (Ports) =====
import '../domain/services/i_image_processing_service.dart';
import '../domain/services/i_image_moderation_service.dart'; // ✅ Image Moderation Port
import '../domain/services/i_target_audience_service.dart';
import '../domain/services/i_box_calculator_service.dart';

// ===== Domain Layer - Repository Interfaces (Ports) =====
import '../domain/repositories/specialized/i_moderation_repository.dart';
import '../domain/repositories/specialized/i_visibility_repository.dart';
import '../domain/repositories/i_media_repository.dart';
import '../domain/repositories/i_post_creation_repository_v2.dart';

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/image_processing_repository_impl.dart';
import '../data/repositories/target_audience_repository_impl.dart';
import '../data/repositories/content_moderation_repository_impl.dart';
import '../data/repositories/content_visibility_repository_impl.dart';
import '../data/repositories/media_repository_impl.dart';
import '../data/repositories/post_creation_repository_v2_impl.dart';

// ===== Domain Layer - UseCases =====
import '../domain/usecases/create_post_usecase.dart';
import '../domain/usecases/moderate_content_usecase.dart';
import '../domain/usecases/validation/validate_post_usecase.dart';
import '../domain/usecases/audience/manage_target_audience_usecase.dart';

/// Register all Creation feature dependencies
/// Call this function from main setupDependencyInjection()
///
/// **Phase 3**: UnifiedCacheService Integration
/// - CreationCacheService Singleton 등록
/// - PostCreationRepositoryV2Impl에 캐시 주입
void registerCreationModule(GetIt getIt) {
  // ===== Phase 3: Cache Services Registration =====
  _registerCacheServices(getIt);

  // ===== Moderation Services Registration =====
  // Moderation services are registered globally in registerModerationModule()
  // (called before registerCreationModule in app/di.dart:76)

  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Services/Domain Interfaces Registration =====
  _registerServices(getIt);

  // ===== Repositories Registration =====
  _registerRepositories(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);
}

/// Register Cache Services (Phase 3)
///
/// **Dependencies**:
/// - UnifiedCacheService must be registered in main.dart before calling registerCreationModule()
void _registerCacheServices(GetIt getIt) {
  // CreationCacheService Singleton
  //
  // **Responsibilities**:
  // - Draft Post 캐싱 (작성 중 임시 저장)
  // - TargetAudience Preset 캐싱 (자동 완성)
  // - AI 생성 결과 캐싱 (비용 절감)
  // - Media 메타데이터 캐싱 (중복 업로드 방지)
  //
  // **Lifecycle**: Singleton (앱 전체에서 공유)
  getIt.registerLazySingleton<CreationCacheService>(
    () => CreationCacheService(cacheService: getIt<UnifiedCacheService>()),
  );
}

/// Register Remote and Local DataSources
///
/// **Phase 5 Update**: FirebasePostCreationDataSource removed
/// - PostCreationRepositoryV2Impl now uses direct Firestore via Extension Pattern
/// - Only FirebaseStorageDataSource remains (for media upload operations)
void _registerDataSources(GetIt getIt) {
  // Firebase Storage DataSource (for media upload operations)
  getIt.registerLazySingleton<FirebaseStorageDataSource>(
    () => FirebaseStorageDataSource(),
  );
}

/// Register Services/Domain Interfaces (Port → Adapter pattern)
void _registerServices(GetIt getIt) {
  // Image Processing Service (Port → Adapter)
  // ✅ DI Pattern: IImageModerationService 주입
  getIt.registerLazySingleton<IImageProcessingService>(
    () => ImageProcessingRepositoryImpl(
      moderationService: getIt<IImageModerationService>(), // ✅ DI 주입
    ),
  );

  // Target Audience Service (Port → Adapter)
  getIt.registerLazySingleton<ITargetAudienceService>(
    () => TargetAudienceRepositoryImpl(),
  );

  // BoxCalculatorService: Clean Architecture Adapter for UI Service
  // Domain Interface → Data Adapter → Services (UnifiedBoxCalculator)
  // Phase 1: Clean Architecture 위반 수정 (2025-11-10)
  getIt.registerLazySingleton<IBoxCalculatorService>(
    () => BoxCalculatorAdapter(),
  );
}

/// Register Repository implementations
///
/// **Firebase-Centric v2.0**: Post Feature dependency removed
/// - Removed IPostQueryService (Post Feature import)
/// - Creation Feature now fully independent
///
/// **Phase 6: Metrics Repository Migration** (2025-11-06)
/// - IContentMetricsRepository moved to Post Feature
void _registerRepositories(GetIt getIt) {
  // 1. Content Moderation Repository (Phase 6: BatchService Integration)
  getIt.registerLazySingleton<IContentModerationRepository>(
    () => ContentModerationRepositoryImpl(
      batchService: getIt<BatchService>(),
    ),
  );

  // 2. Content Visibility Repository
  getIt.registerLazySingleton<IContentVisibilityRepository>(
    () => ContentVisibilityRepositoryImpl(),
  );

  // 3. Media Repository
  getIt.registerLazySingleton<IMediaRepository>(
    () => MediaRepositoryImpl(
      storageDataSource: getIt<FirebaseStorageDataSource>(),
    ),
  );

  // 4. Post Creation Repository V2 (Phase 3 & 5: Cache + Extension)
  getIt.registerLazySingleton<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(
      // ❌ Phase 5: dataSource removed - Direct Firestore via Extension Pattern
      imageProcessingService: getIt<IImageProcessingService>(),
      cacheService: getIt<CreationCacheService>(), // ✅ Phase 3: Cache Injection
    ),
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
    ),
  );

  // Moderate Content UseCase (with Text + Image Moderation dependencies)
  // ✅ DI Pattern: Both PerspectiveApiService and ImageModerationService injected
  getIt.registerFactory(
    () => ModerateContentUseCase(
      perspectiveService: getIt<IPerspectiveApiService>(),
      imageModerationService: getIt<IImageModerationService>(), // ✅ 추가
    ),
  );

  // Validate Post UseCase
  getIt.registerFactory(() => ValidatePostUseCase());
}
