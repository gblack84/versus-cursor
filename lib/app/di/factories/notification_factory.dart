/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정 (마이그레이션 필요)
///
/// 이 파일은 레거시 DI 시스템의 Factory 패턴 구현입니다.
/// 신규 시스템은 /features/notifications/di/notification_di_module.dart를 사용합니다.
///
/// 삭제 전 필요 작업:
/// - notification_module.dart에서 NotificationFactory 사용처 제거
/// - Factory 패턴 대신 직접 DI 등록 방식으로 변경
///
/// 삭제 조건:
/// - notification_module.dart 삭제 완료 시
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Import notification domain interfaces
import '../../../features/notifications/domain/repositories/i_notification_repository.dart';

/// Import notification use cases
import '../../../features/notifications/domain/usecases/get_user_notifications_use_case.dart';
import '../../../features/notifications/domain/usecases/mark_as_read_use_case.dart';
import '../../../features/notifications/domain/usecases/send_notification_use_case.dart';
import '../../../features/notifications/domain/usecases/watch_unread_count_use_case.dart';
import '../../../features/notifications/domain/usecases/watch_user_notifications_use_case.dart';

/// Import core use cases (shared across features)
import '../../../core/domain/usecases/get_current_user_use_case.dart';

/// Import notification data implementations
import '../../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../../features/notifications/data/datasources/i_remote_notification_datasource.dart';
import '../../../features/notifications/data/datasources/remote/firebase_notification_datasource.dart';
import '../../../features/notifications/data/datasources/i_local_notification_datasource.dart';
import '../../../features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart';

/// Import notification services/adapters
import '../../../features/notifications/domain/services/i_notification_service.dart';
import '../../../features/notifications/data/adapters/notification_service.dart';
import '../../../services/notification/notification_queue_service.dart';

/// Import cross-feature dependencies
import '../../../features/creation/domain/services/i_target_audience_service.dart';
import '../../../core/domain/ports/i_user_service.dart';
// UserServiceImpl removed - Phase 4 Auth service layer removed
// IVoteService removed - Now managed by Voting DI Module
import '../../../core/events/event_bus.dart';

/// Factory for creating and configuring notification feature dependencies
/// 
/// This factory implements the Factory Pattern to encapsulate the creation
/// of notification-related dependencies while maintaining Clean Architecture
/// boundaries and reducing coupling between the DI container and feature modules.
/// 
/// Key Benefits:
/// - Separation of Concerns: Factory handles creation logic, container handles registration
/// - Clean Architecture: Maintains proper dependency direction (data -> domain -> presentation)
/// - Testability: Easy to mock factory for unit tests
/// - Maintainability: Centralized creation logic for notification feature
/// 
/// Usage in DRY-RUN mode:
/// ```dart
/// final factory = NotificationFactory();
/// final bindings = factory.previewBindings();
/// print('Would register ${bindings.length} dependencies');
/// ```
/// 
/// Usage in production:
/// ```dart
/// final factory = NotificationFactory();
/// factory.registerAll(GetIt.instance);
/// ```
class NotificationFactory {
  /// Preview all bindings that would be registered without actually registering them
  /// This is useful for DRY-RUN mode to understand what will be registered
  Map<String, String> previewBindings() {
    return {
      // Core Infrastructure
      'EventBus': 'EventBus() - Event coordination system',

      // Cross-feature Service Implementations
      'IUserService': 'UserServiceImpl() - User management operations',
      // IVoteService removed - Now managed by Voting DI Module

      // Data Source Layer (Clean Architecture: Outer Layer)
      'IRemoteNotificationDatasource': 'FirebaseNotificationDatasource(FirebaseFirestore.instance) - Remote data access',
      'ILocalNotificationDatasource': 'SharedPrefsNotificationDatasource(SharedPreferences) - Local cache access',

      // NotificationService (depends on Datasources only - circular dependency resolved)
      'INotificationService': 'NotificationService(remoteDatasource) - Real-time notification streaming with Firestore direct access',

      // Queue Service (depends on NotificationService)
      'NotificationQueueService': 'NotificationQueueService(localDatasource, notificationService) - Notification queue management and sequential display',

      // Repository Layer (depends on DataSources + NotificationQueueService)
      'INotificationRepository': 'NotificationRepositoryImpl(remoteDatasource, localDatasource, queueService) - Data aggregation and Contract implementation',

      // Note: TargetAudienceService is registered in creation_module.dart as ITargetAudienceService
    };
  }

  /// Create EventBus instance
  EventBus createEventBus() {
    return EventBus();
  }

  /// Create User Service implementation
  /// NOTE: Auth service layer removed in Phase 4 - throw until User feature is migrated
  IUserService createUserService() {
    // TODO: Replace with proper implementation when User feature is migrated
    throw UnimplementedError(
        'IUserService not yet implemented. User feature migration pending.');
  }

  // Vote Service removed - Now managed by Voting DI Module

  /// Create Remote Notification DataSource
  IRemoteNotificationDatasource createRemoteNotificationDatasource() {
    return FirebaseNotificationDatasource(
      firestore: FirebaseFirestore.instance,
    );
  }

  /// Create Local Notification DataSource  
  /// Requires: SharedPreferences instance
  ILocalNotificationDatasource createLocalNotificationDatasource(GetIt sl) {
    return SharedPrefsNotificationDatasource(
      prefs: sl<SharedPreferences>(),
    );
  }


  /// Create Notification Repository
  /// Requires: IRemoteNotificationDatasource, ILocalNotificationDatasource, NotificationQueueService
  INotificationRepository createNotificationRepository(GetIt sl) {
    return NotificationRepositoryImpl(
      remoteDatasource: sl<IRemoteNotificationDatasource>(),
      localDatasource: sl<ILocalNotificationDatasource>(),
      queueService: sl<NotificationQueueService>(),
    );
  }

  /// Create Notification Service
  /// Requires: IRemoteNotificationDatasource
  INotificationService createNotificationService(GetIt sl) {
    return NotificationService(
      remoteDatasource: sl<IRemoteNotificationDatasource>(),
    );
  }

  /// Get Target Audience Service
  /// Note: This service is registered in creation_module.dart as ITargetAudienceService
  /// We just retrieve it from GetIt, not create it here
  ITargetAudienceService getTargetAudienceService(GetIt sl) {
    return sl<ITargetAudienceService>();
  }

  /// Create Notification Queue Service
  /// Requires: Local datasource and NotificationService
  /// Manages notification queue, duplicate prevention, and sequential display
  /// Emits notifications via Stream for Presentation layer to display
  NotificationQueueService createNotificationQueueService(GetIt sl) {
    return NotificationQueueService(
      localDatasource: sl<ILocalNotificationDatasource>(),
      notificationService: sl<INotificationService>(),
    );
  }

  // ===== USE CASES =====

  /// Create GetUserNotificationsUseCase
  GetUserNotificationsUseCase createGetUserNotificationsUseCase(GetIt sl) {
    return GetUserNotificationsUseCase(sl<INotificationRepository>());
  }

  /// Create MarkAsReadUseCase
  MarkAsReadUseCase createMarkAsReadUseCase(GetIt sl) {
    return MarkAsReadUseCase(sl<INotificationRepository>());
  }


  /// Create SendNotificationUseCase
  SendNotificationUseCase createSendNotificationUseCase(GetIt sl) {
    return SendNotificationUseCase(sl<INotificationRepository>());
  }

  /// Create WatchUnreadCountUseCase
  WatchUnreadCountUseCase createWatchUnreadCountUseCase(GetIt sl) {
    return WatchUnreadCountUseCase(sl<INotificationRepository>());
  }

  /// Create GetCurrentUserUseCase
  /// Note: Moved to /lib/core/domain/usecases/ as shared across features
  GetCurrentUserUseCase createGetCurrentUserUseCase(GetIt sl) {
    return GetCurrentUserUseCase(sl<IUserService>());
  }

  /// Create WatchUserNotificationsUseCase
  WatchUserNotificationsUseCase createWatchUserNotificationsUseCase(GetIt sl) {
    return WatchUserNotificationsUseCase(sl<INotificationRepository>());
  }

  /// Register all notification dependencies using GetIt
  ///
  /// Registration Order (Critical for dependency resolution - UPDATED to fix circular dependency):
  /// 1. Core Infrastructure (EventBus)
  /// 2. Cross-feature Services (IUserService)
  /// 3. DataSources (Remote, Local)
  /// 4. NotificationService (depends on Datasources only)
  /// 5. NotificationQueueService (depends on NotificationService)
  /// 6. Repository (depends on DataSources + NotificationQueueService)
  ///
  /// Note: Circular dependency resolved by making NotificationService depend on
  ///       Datasource instead of Repository
  void registerAll(GetIt sl) {
    // 1. Core Infrastructure
    sl.registerLazySingleton<EventBus>(
      () => createEventBus(),
    );

    // 2. Cross-feature Service Implementations
    sl.registerLazySingleton<IUserService>(
      () => createUserService(),
    );

    // IVoteService removed - Now managed by Voting DI Module

    // 3. DataSources (Clean Architecture: Outer Layer)
    sl.registerLazySingleton<IRemoteNotificationDatasource>(
      () => createRemoteNotificationDatasource(),
    );

    sl.registerLazySingleton<ILocalNotificationDatasource>(
      () => createLocalNotificationDatasource(sl),
    );

    // 4. NotificationService (depends on Datasources only - no Repository dependency)
    sl.registerLazySingleton<INotificationService>(
      () => createNotificationService(sl),
    );

    // 5. NotificationQueueService (depends on NotificationService)
    // Note: TargetAudienceService is registered in creation_module.dart as ITargetAudienceService
    sl.registerLazySingleton<NotificationQueueService>(
      () => createNotificationQueueService(sl),
    );

    // 6. Repository Layer (depends on DataSources + NotificationQueueService)
    // Repository is registered LAST to avoid circular dependency
    sl.registerLazySingleton<INotificationRepository>(
      () => createNotificationRepository(sl),
    );

    // 7. Use Cases (Clean Architecture: Application Layer)
    // Register as Factory to create new instances for each injection
    sl.registerFactory<GetUserNotificationsUseCase>(
      () => createGetUserNotificationsUseCase(sl),
    );

    sl.registerFactory<MarkAsReadUseCase>(
      () => createMarkAsReadUseCase(sl),
    );

    sl.registerFactory<SendNotificationUseCase>(
      () => createSendNotificationUseCase(sl),
    );

    sl.registerFactory<WatchUnreadCountUseCase>(
      () => createWatchUnreadCountUseCase(sl),
    );

    sl.registerFactory<GetCurrentUserUseCase>(
      () => createGetCurrentUserUseCase(sl),
    );

    sl.registerFactory<WatchUserNotificationsUseCase>(
      () => createWatchUserNotificationsUseCase(sl),
    );
  }

  /// Unregister all notification dependencies
  /// Unregistration happens in REVERSE order to avoid dependency conflicts
  void unregisterAll(GetIt sl) {
    // Unregister in reverse order (opposite of registerAll)
    // 6. Repository Layer
    if (sl.isRegistered<INotificationRepository>()) {
      sl.unregister<INotificationRepository>();
    }
    // 5. NotificationQueueService
    if (sl.isRegistered<NotificationQueueService>()) {
      sl.unregister<NotificationQueueService>();
    }
    // 4. NotificationService
    if (sl.isRegistered<NotificationService>()) {
      sl.unregister<NotificationService>();
    }
    // 3. DataSources
    if (sl.isRegistered<ILocalNotificationDatasource>()) {
      sl.unregister<ILocalNotificationDatasource>();
    }
    if (sl.isRegistered<IRemoteNotificationDatasource>()) {
      sl.unregister<IRemoteNotificationDatasource>();
    }
    // 2. Cross-feature Services
    if (sl.isRegistered<IUserService>()) {
      sl.unregister<IUserService>();
    }
    // 1. Core Infrastructure
    if (sl.isRegistered<EventBus>()) {
      sl.unregister<EventBus>();
    }
  }
}