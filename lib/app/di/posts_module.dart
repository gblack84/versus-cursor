import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
// DataSources
import '../../features/creation/data/datasources/firebase_post_creation_datasource.dart';
import '../../features/creation/data/datasources/firebase_storage_datasource.dart';
// Services (Phase 4 완료)
import '../../features/creation/data/services/image_upload_service.dart';
// Repositories - Phase 4 완료
import '../../features/creation/domain/repositories/i_creation_command_repository.dart';
import '../../features/creation/data/repositories/creation_command_repository_impl.dart';
import '../../features/creation/domain/repositories/i_content_metrics_repository.dart';
import '../../features/creation/data/repositories/content_metrics_repository_impl.dart';
import '../../features/creation/domain/repositories/i_content_moderation_repository.dart';
import '../../features/creation/data/repositories/content_moderation_repository_impl.dart';
import '../../features/creation/domain/repositories/i_content_visibility_repository.dart';
import '../../features/creation/data/repositories/content_visibility_repository_impl.dart';
import '../../features/post/domain/repositories/i_post_query_service.dart';
import '../../features/post/data/repositories/post_query_service_impl.dart';
import '../../features/creation/domain/repositories/i_media_repository.dart';
import '../../features/creation/data/repositories/media_repository_impl.dart';
import '../../features/creation/domain/repositories/i_post_creation_repository_v2.dart';
import '../../features/creation/data/repositories/post_creation_repository_v2_impl.dart';
// Post Display Repository
import '../../features/post/domain/repositories/i_post_display_repository_v2.dart';
import '../../features/post/data/repositories/post_display_repository_v2_impl.dart';
import '../../features/post/data/datasources/interfaces/i_post_display_datasource.dart';
import '../../features/post/data/datasources/firebase_post_display_datasource.dart';
import '../../features/voting/domain/services/vote_timer_service.dart';
import '../../features/voting/domain/ports/i_vote_timer_port.dart';
import '../../features/voting/data/adapters/vote_timer_adapter.dart';

/// Posts Feature DI Module
///
/// Manages dependency injection for posts-related services
/// following Clean Architecture principles
class PostsModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Posts';

  @override
  void register(GetIt sl) {
    // ====== DataSources 등록 (Phase 4) ======
    if (!sl.isRegistered<FirebasePostCreationDataSource>()) {
      sl.registerLazySingleton<FirebasePostCreationDataSource>(
        () => FirebasePostCreationDataSource(),
      );
    }

    if (!sl.isRegistered<FirebaseStorageDataSource>()) {
      sl.registerLazySingleton<FirebaseStorageDataSource>(
        () => FirebaseStorageDataSource(),
      );
    }

    // ====== Services 등록 (Phase 4) ======
    // TODO: TargetAudienceService는 IPostDatasource 의존성 문제로 임시 비활성화
    // Phase 5에서 완전히 해결 예정

    if (!sl.isRegistered<ImageUploadService>()) {
      sl.registerLazySingleton<ImageUploadService>(
        () => ImageUploadService(),
      );
    }

    // ====== Phase 4 Repositories (6개) ======

    // 1. CreationCommandRepository
    if (!sl.isRegistered<ICreationCommandRepository>()) {
      sl.registerLazySingleton<ICreationCommandRepository>(
        () => CreationCommandRepositoryImpl(
          storageDataSource: sl<FirebaseStorageDataSource>(),
        ),
      );
    }

    // 2. VoteRepository - moved to VotingModule

    // 3. ContentMetricsRepository
    if (!sl.isRegistered<IContentMetricsRepository>()) {
      sl.registerLazySingleton<IContentMetricsRepository>(
        () => ContentMetricsRepositoryImpl(),
      );
    }

    // 4. ContentModerationRepository
    if (!sl.isRegistered<IContentModerationRepository>()) {
      sl.registerLazySingleton<IContentModerationRepository>(
        () => ContentModerationRepositoryImpl(),
      );
    }

    // 5. ContentVisibilityRepository
    if (!sl.isRegistered<IContentVisibilityRepository>()) {
      sl.registerLazySingleton<IContentVisibilityRepository>(
        () => ContentVisibilityRepositoryImpl(),
      );
    }

    // 6. PostQueryService (moved from Creation to Post Feature)
    if (!sl.isRegistered<IPostQueryService>()) {
      sl.registerLazySingleton<IPostQueryService>(
        () => PostQueryServiceImpl(),
      );
    }

    // 7. MediaRepository (Phase 5에서 추가)
    if (!sl.isRegistered<IMediaRepository>()) {
      sl.registerLazySingleton<IMediaRepository>(
        () => MediaRepositoryImpl(
          storageDataSource: sl<FirebaseStorageDataSource>(),
        ),
      );
    }

    // 8. PostCreationRepositoryV2 (기존 유지)
    // TODO: targetAudienceService 의존성 제거 필요
    if (!sl.isRegistered<IPostCreationRepositoryV2>()) {
      sl.registerLazySingleton<IPostCreationRepositoryV2>(
        () => PostCreationRepositoryV2Impl(
          dataSource: sl<FirebasePostCreationDataSource>(),
          imageUploadService: sl<ImageUploadService>(),
        ),
      );
    }

    // Post Display Feature DataSource
    if (!sl.isRegistered<IPostDisplayDataSource>()) {
      sl.registerLazySingleton<IPostDisplayDataSource>(
        () => FirebasePostDisplayDataSource(),
      );
    }

    // Post Display Feature V2 Repository
    if (!sl.isRegistered<IPostDisplayRepositoryV2>()) {
      sl.registerLazySingleton<IPostDisplayRepositoryV2>(
        () => PostDisplayRepositoryV2Impl(
          dataSource: sl<IPostDisplayDataSource>(),
        ),
      );
    }

    // Register VoteTimerService (owned by posts feature)
    if (!sl.isRegistered<VoteTimerService>()) {
      sl.registerLazySingleton<VoteTimerService>(
        () => VoteTimerService(),
      );
    }

    // Register VoteTimerPort adapter for voting feature
    // This bridges posts and voting features without direct dependency
    if (!sl.isRegistered<IVoteTimerPort>()) {
      sl.registerLazySingleton<IVoteTimerPort>(
        () => VoteTimerAdapter(sl<VoteTimerService>()),
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    // Unregister Phase 4 repositories
    if (sl.isRegistered<IMediaRepository>()) {
      sl.unregister<IMediaRepository>();
    }
    if (sl.isRegistered<IPostQueryService>()) {
      sl.unregister<IPostQueryService>();
    }
    if (sl.isRegistered<IContentVisibilityRepository>()) {
      sl.unregister<IContentVisibilityRepository>();
    }
    if (sl.isRegistered<IContentModerationRepository>()) {
      sl.unregister<IContentModerationRepository>();
    }
    if (sl.isRegistered<IContentMetricsRepository>()) {
      sl.unregister<IContentMetricsRepository>();
    }
    // VoteRepository - moved to VotingModule
    if (sl.isRegistered<ICreationCommandRepository>()) {
      sl.unregister<ICreationCommandRepository>();
    }

    // Unregister DataSources
    if (sl.isRegistered<FirebaseStorageDataSource>()) {
      sl.unregister<FirebaseStorageDataSource>();
    }
    if (sl.isRegistered<FirebasePostCreationDataSource>()) {
      sl.unregister<FirebasePostCreationDataSource>();
    }

    // Unregister V2 repositories
    if (sl.isRegistered<IPostDisplayRepositoryV2>()) {
      sl.unregister<IPostDisplayRepositoryV2>();
    }
    if (sl.isRegistered<IPostCreationRepositoryV2>()) {
      sl.unregister<IPostCreationRepositoryV2>();
    }

    // Unregister voting adapters
    if (sl.isRegistered<IVoteTimerPort>()) {
      sl.unregister<IVoteTimerPort>();
    }
    if (sl.isRegistered<VoteTimerService>()) {
      sl.unregister<VoteTimerService>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
