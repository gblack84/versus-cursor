import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Import notification domain interfaces
import '../../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../../features/notifications/domain/handlers/i_notification_handler.dart';

/// Import notification use cases
import '../../../features/notifications/domain/usecases/get_user_notifications_use_case.dart';
import '../../../features/notifications/domain/usecases/mark_as_read_use_case.dart';
import '../../../features/notifications/domain/usecases/process_vote_notification_use_case.dart';
import '../../../features/notifications/domain/usecases/send_notification_use_case.dart';
import '../../../features/notifications/domain/usecases/watch_unread_count_use_case.dart';
import '../../../features/notifications/domain/usecases/initialize_notifications_use_case.dart';
import '../../../features/notifications/domain/usecases/start_notification_listening_use_case.dart';
import '../../../features/notifications/domain/usecases/stop_notification_listening_use_case.dart';
import '../../../features/notifications/domain/usecases/get_post_data_use_case.dart';

/// Import notification data implementations
import '../../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../../features/notifications/data/datasources/i_remote_notification_datasource.dart';
import '../../../features/notifications/data/datasources/remote/firebase_notification_datasource.dart';
import '../../../features/notifications/data/datasources/i_local_notification_datasource.dart';
import '../../../features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart';

/// Import notification services/adapters
import '../../../features/notifications/domain/services/i_notification_service.dart';
import '../../../features/notifications/data/adapters/notification_service.dart';
import '../../../features/notifications/data/adapters/global_notification_manager.dart';

/// Import cross-feature dependencies
import '../../../features/notifications/data/datasources/i_post_datasource.dart';
import '../../../features/notifications/data/datasources/cross/mock_post_datasource.dart';
import '../../../features/notifications/data/datasources/i_chat_datasource.dart';
import '../../../features/notifications/data/datasources/cross/mock_chat_datasource.dart';
import '../../../features/creation/data/services/target_audience_service.dart';
import '../../../core/domain/ports/i_user_service.dart';
import '../../../features/voting/domain/ports/i_vote_service.dart';
// UserServiceImpl removed - Phase 4 Auth service layer removed
import '../../../features/voting/data/adapters/vote_service_impl.dart';
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
      'IVoteService': 'VoteServiceImpl(voteStatusService) - Voting operations',
      
      // Data Source Layer (Clean Architecture: Outer Layer)
      'IRemoteNotificationDatasource': 'FirebaseNotificationDatasource(FirebaseFirestore.instance) - Remote data access',
      'ILocalNotificationDatasource': 'SharedPrefsNotificationDatasource(SharedPreferences) - Local cache access',
      'IPostDatasource': 'MockPostDatasource() - Cross-feature post data access',
      'IChatDatasource': 'MockChatDatasource() - Cross-feature chat data access',
      
      // Repository Layer (Clean Architecture: Data Layer)
      'INotificationRepository': 'NotificationRepositoryImpl(remoteDatasource, localDatasource) - Data aggregation and caching',
      
      // Service/Adapter Layer (Clean Architecture: Application Layer) 
      'NotificationService': 'NotificationService(repository, chatDatasource) - Real-time notification streaming',
      'TargetAudienceService': 'TargetAudienceService(postDatasource) - AI-powered user targeting',
      
      // Global Manager (Clean Architecture: Application Layer)
      'GlobalNotificationManager': 'GlobalNotificationManager(handler, repository, datasources, services) - Notification orchestration',
    };
  }

  /// Create EventBus instance
  EventBus createEventBus() {
    return EventBus();
  }

  /// Create User Service implementation
  /// NOTE: Auth service layer removed in Phase 4 - return null for now
  IUserService? createUserService() {
    // TODO: Replace with proper implementation when User feature is migrated
    return null;
  }

  /// Create Vote Service implementation
  /// Requires: voteStatusService (should be registered elsewhere)
  IVoteService createVoteService(GetIt sl) {
    return VoteServiceImpl(
      voteStatusService: sl.get(), // Assumes VoteStatusService is registered elsewhere
    );
  }

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

  /// Create Post DataSource (Mock for now)
  IPostDatasource createPostDatasource() {
    return MockPostDatasource();
  }

  /// Create Chat DataSource (Mock for now)
  IChatDatasource createChatDatasource() {
    return MockChatDatasource();
  }

  /// Create Notification Repository
  /// Requires: IRemoteNotificationDatasource, ILocalNotificationDatasource
  INotificationRepository createNotificationRepository(GetIt sl) {
    return NotificationRepositoryImpl(
      remoteDatasource: sl<IRemoteNotificationDatasource>(),
      localDatasource: sl<ILocalNotificationDatasource>(),
    );
  }

  /// Create Notification Service
  /// Requires: INotificationRepository, IChatDatasource
  INotificationService createNotificationService(GetIt sl) {
    return NotificationService(
      repository: sl<INotificationRepository>(),
      chatDatasource: sl<IChatDatasource>(),
    );
  }

  /// Create Target Audience Service
  /// Requires: IPostDatasource
  TargetAudienceService createTargetAudienceService(GetIt sl) {
    return TargetAudienceService(
      postDatasource: sl<IPostDatasource>(),
    );
  }

  /// Create Global Notification Manager
  /// Requires: All notification-related dependencies
  /// This should be registered LAST as it depends on all other services
  GlobalNotificationManager createGlobalNotificationManager(GetIt sl) {
    return GlobalNotificationManager(
      notificationHandler: sl<INotificationHandler>(), // Registered elsewhere to avoid circular dependency
      remoteDatasource: sl<IRemoteNotificationDatasource>(),
      localDatasource: sl<ILocalNotificationDatasource>(),
      notificationService: sl<INotificationService>(),
      userService: sl<IUserService>(),
      voteService: sl<IVoteService>(),
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

  /// Create ProcessVoteNotificationUseCase
  ProcessVoteNotificationUseCase createProcessVoteNotificationUseCase(GetIt sl) {
    return ProcessVoteNotificationUseCase(sl<INotificationRepository>());
  }

  /// Create SendNotificationUseCase
  SendNotificationUseCase createSendNotificationUseCase(GetIt sl) {
    return SendNotificationUseCase(sl<INotificationRepository>());
  }

  /// Create WatchUnreadCountUseCase
  WatchUnreadCountUseCase createWatchUnreadCountUseCase(GetIt sl) {
    return WatchUnreadCountUseCase(sl<INotificationRepository>());
  }

  /// Create InitializeNotificationsUseCase
  InitializeNotificationsUseCase createInitializeNotificationsUseCase(GetIt sl) {
    return InitializeNotificationsUseCase(sl<INotificationRepository>());
  }

  /// Create StartNotificationListeningUseCase
  StartNotificationListeningUseCase createStartNotificationListeningUseCase(GetIt sl) {
    return StartNotificationListeningUseCase(sl<INotificationRepository>());
  }

  /// Create StopNotificationListeningUseCase
  StopNotificationListeningUseCase createStopNotificationListeningUseCase(GetIt sl) {
    return StopNotificationListeningUseCase(sl<INotificationRepository>());
  }

  /// Create GetPostDataUseCase
  GetPostDataUseCase createGetPostDataUseCase(GetIt sl) {
    return GetPostDataUseCase(sl<INotificationRepository>());
  }

  /// Register all notification dependencies using GetIt
  /// 
  /// Registration Order (Critical for dependency resolution):
  /// 1. Core Infrastructure (EventBus)
  /// 2. Cross-feature Services (IUserService, IVoteService) 
  /// 3. DataSources (Remote, Local, Cross-feature)
  /// 4. Repository (depends on DataSources)
  /// 5. Services/Adapters (depends on Repository and DataSources)
  /// 6. Global Manager (depends on everything else)
  void registerAll(GetIt sl) {
    // 1. Core Infrastructure
    sl.registerLazySingleton<EventBus>(
      () => createEventBus(),
    );

    // 2. Cross-feature Service Implementations
    sl.registerLazySingleton<IUserService>(
      () => createUserService(),
    );

    sl.registerLazySingleton<IVoteService>(
      () => createVoteService(sl),
    );

    // 3. DataSources (Clean Architecture: Outer Layer)
    sl.registerLazySingleton<IRemoteNotificationDatasource>(
      () => createRemoteNotificationDatasource(),
    );

    sl.registerLazySingleton<ILocalNotificationDatasource>(
      () => createLocalNotificationDatasource(sl),
    );

    // Cross-feature DataSources (Mock implementations)
    sl.registerLazySingleton<IPostDatasource>(
      () => createPostDatasource(),
    );

    sl.registerLazySingleton<IChatDatasource>(
      () => createChatDatasource(),
    );

    // 4. Repository Layer (Clean Architecture: Data Layer)
    sl.registerLazySingleton<INotificationRepository>(
      () => createNotificationRepository(sl),
    );

    // 5. Service/Adapter Layer (Clean Architecture: Application Layer)
    sl.registerLazySingleton<INotificationService>(
      () => createNotificationService(sl),
    );

    sl.registerLazySingleton<TargetAudienceService>(
      () => createTargetAudienceService(sl),
    );

    // 6. Global Manager (Register LAST - depends on all other services)
    // Note: INotificationHandler must be registered elsewhere to avoid circular dependency
    sl.registerLazySingleton<GlobalNotificationManager>(
      () => createGlobalNotificationManager(sl),
    );

    // 7. Use Cases (Clean Architecture: Application Layer)
    // Register as Factory to create new instances for each injection
    sl.registerFactory<GetUserNotificationsUseCase>(
      () => createGetUserNotificationsUseCase(sl),
    );

    sl.registerFactory<MarkAsReadUseCase>(
      () => createMarkAsReadUseCase(sl),
    );

    sl.registerFactory<ProcessVoteNotificationUseCase>(
      () => createProcessVoteNotificationUseCase(sl),
    );

    sl.registerFactory<SendNotificationUseCase>(
      () => createSendNotificationUseCase(sl),
    );

    sl.registerFactory<WatchUnreadCountUseCase>(
      () => createWatchUnreadCountUseCase(sl),
    );

    sl.registerFactory<InitializeNotificationsUseCase>(
      () => createInitializeNotificationsUseCase(sl),
    );

    sl.registerFactory<StartNotificationListeningUseCase>(
      () => createStartNotificationListeningUseCase(sl),
    );

    sl.registerFactory<StopNotificationListeningUseCase>(
      () => createStopNotificationListeningUseCase(sl),
    );

    sl.registerFactory<GetPostDataUseCase>(
      () => createGetPostDataUseCase(sl),
    );
  }

  /// Unregister all notification dependencies
  /// Unregistration happens in REVERSE order to avoid dependency conflicts
  void unregisterAll(GetIt sl) {
    // Unregister in reverse order
    if (sl.isRegistered<GlobalNotificationManager>()) {
      sl.unregister<GlobalNotificationManager>();
    }
    if (sl.isRegistered<TargetAudienceService>()) {
      sl.unregister<TargetAudienceService>();
    }
    if (sl.isRegistered<NotificationService>()) {
      sl.unregister<NotificationService>();
    }
    if (sl.isRegistered<INotificationRepository>()) {
      sl.unregister<INotificationRepository>();
    }
    if (sl.isRegistered<IChatDatasource>()) {
      sl.unregister<IChatDatasource>();
    }
    if (sl.isRegistered<IPostDatasource>()) {
      sl.unregister<IPostDatasource>();
    }
    if (sl.isRegistered<ILocalNotificationDatasource>()) {
      sl.unregister<ILocalNotificationDatasource>();
    }
    if (sl.isRegistered<IRemoteNotificationDatasource>()) {
      sl.unregister<IRemoteNotificationDatasource>();
    }
    if (sl.isRegistered<IVoteService>()) {
      sl.unregister<IVoteService>();
    }
    if (sl.isRegistered<IUserService>()) {
      sl.unregister<IUserService>();
    }
    if (sl.isRegistered<EventBus>()) {
      sl.unregister<EventBus>();
    }
  }
}