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

// ===== App Layer - Contracts (Phase 10 대기 중) =====
// import '/app/contracts/creation_contract.dart'; // TODO Phase 10: Adapter 구현 후 활성화

// ===== Services Layer - Cache Services (Phase 3) =====
import '/services/cache/unified_cache_service.dart';
import '/services/cache/creation_cache_service.dart';

// ===== Core Services - Idempotency (Phase 4) =====
import '/core/utils/idempotency_service.dart';

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

// ===== Data Layer - Repository Implementations (Adapters) =====
import '../data/repositories/image_processing_repository_impl.dart';
import '../data/repositories/target_audience_repository_impl.dart';
import '../data/repositories/content_metrics_repository_impl.dart';
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
///
/// **Phase 4**: Idempotency Pattern Integration
/// - IdempotencyService Singleton 등록
/// - PostCreationRepositoryV2Impl에 IdempotencyService 주입
void registerCreationModule(GetIt getIt) {
  // ===== Phase 3: Cache Services Registration =====
  _registerCacheServices(getIt);

  // ===== Phase 4: Idempotency Service Registration =====
  _registerIdempotencyService(getIt);

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
    () => CreationCacheService(
      cacheService: getIt<UnifiedCacheService>(),
    ),
  );
}

/// Register Idempotency Service (Phase 4)
///
/// **Responsibilities**:
/// - Prevent duplicate post creation during network retries
/// - Prevent duplicate media upload
/// - Prevent duplicate draft save operations
///
/// **Lifecycle**: Singleton (앱 전체에서 공유, 재사용 가능)
void _registerIdempotencyService(GetIt getIt) {
  getIt.registerLazySingleton<IdempotencyService>(
    () => IdempotencyService(),
  );
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
///
/// **Firebase-Centric v2.0**: Post Feature dependency removed
/// - Removed IPostQueryService (Post Feature import)
/// - Creation Feature now fully independent
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

  // 4. Media Repository
  getIt.registerLazySingleton<IMediaRepository>(
    () => MediaRepositoryImpl(
      storageDataSource: getIt<FirebaseStorageDataSource>(),
    ),
  );

  // 5. Post Creation Repository V2 (Phase 3 & 4: Cache + Idempotency)
  getIt.registerLazySingleton<IPostCreationRepositoryV2>(
    () => PostCreationRepositoryV2Impl(
      dataSource: getIt<FirebasePostCreationDataSource>(),
      imageProcessingService: getIt<IImageProcessingService>(),
      cacheService: getIt<CreationCacheService>(), // ✅ Phase 3: Cache Injection
      idempotencyService: getIt<IdempotencyService>(), // ✅ Phase 4: Idempotency Injection
    ),
  );
}

/// Register CreationContract (Cross-Feature Communication)
/// **DISABLED**: Dual Interface Pattern blocked by Either<Failure, T> vs Future<T?> mismatch
/// PostCreationRepositoryV2Impl uses Either pattern but CreationContract expects simple Future/Stream
/// TODO Phase 10: Create adapter class to bridge IPostCreationRepositoryV2 ↔ CreationContract
void _registerContract(GetIt getIt) {
  // COMMENTED OUT - Cannot cast directly due to return type mismatch
  // getIt.registerLazySingleton<CreationContract>(
  //   () => getIt<IPostCreationRepositoryV2>() as PostCreationRepositoryV2Impl,
  // );
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

  // Moderate Content UseCase (no dependencies)
  getIt.registerFactory(
    () => ModerateContentUseCase(),
  );

  // Validate Post UseCase
  getIt.registerFactory(
    () => ValidatePostUseCase(),
  );
}

