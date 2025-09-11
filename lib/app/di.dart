/// Dependency Injection Configuration
///
/// This file configures dependency injection for the application
/// following Clean Architecture principles

import 'package:get_it/get_it.dart';
import '/features/voting/domain/repositories/i_voting_repository.dart';
import '/features/posts/data/adapters/posts_data_source_impl.dart';

// Auth Feature DI
import '/features/auth/domain/services/i_auth_service.dart';
import '/features/auth/data/adapters/auth_service_impl.dart';

// Notifications Feature DI
import '/features/notifications/domain/repositories/i_notification_repository.dart';
import '/features/notifications/data/repositories/notification_repository_impl.dart';
import '/features/notifications/domain/usecases/get_user_notifications_use_case.dart';
import '/features/notifications/domain/usecases/mark_as_read_use_case.dart';
import '/features/notifications/domain/usecases/process_vote_notification_use_case.dart';
import '/features/notifications/domain/usecases/send_notification_use_case.dart';
import '/features/notifications/domain/usecases/watch_unread_count_use_case.dart';
import '/features/notifications/domain/usecases/initialize_notifications_use_case.dart';
import '/features/notifications/domain/usecases/start_notification_listening_use_case.dart';
import '/features/notifications/domain/usecases/stop_notification_listening_use_case.dart';
import '/features/notifications/domain/usecases/get_post_data_use_case.dart';

// Voting UI & Adapters
import '/features/voting/domain/ports/i_vote_ui_delegate.dart';
import '/features/voting/presentation/managers/vote_ui_manager.dart';
import '/features/notifications/data/adapters/notification_service.dart';
import '/features/posts/data/services/target_audience_service.dart';
import '/features/notifications/data/datasources/i_remote_notification_datasource.dart';
import '/features/notifications/data/datasources/remote/firebase_notification_datasource.dart';
import '/features/notifications/data/datasources/i_local_notification_datasource.dart';
import '/features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart';
import '/features/notifications/data/datasources/i_post_datasource.dart';
import '/features/notifications/data/datasources/cross/mock_post_datasource.dart';
import '/features/notifications/data/datasources/i_chat_datasource.dart';
import '/features/notifications/data/datasources/cross/mock_chat_datasource.dart';
import '/features/notifications/data/mappers/notification_mapper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
Future<void> setupDependencyInjection() async {
  // ===== Core Dependencies =====

  // SharedPreferences 인스턴스 초기화
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);
  // Register Posts data source for Voting feature
  getIt.registerLazySingleton<PostsDataSource>(
    () => PostsDataSourceImpl.instance,
  );

  // Register Auth service
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(),
  );

  // ===== Notifications Feature DI =====

  // DataSource 등록
  getIt.registerLazySingleton<IRemoteNotificationDatasource>(
    () => FirebaseNotificationDatasource(
      firestore: FirebaseFirestore.instance,
    ),
  );

  getIt.registerLazySingleton<ILocalNotificationDatasource>(
    () => SharedPrefsNotificationDatasource(
      prefs: getIt<SharedPreferences>(),
    ),
  );

  // Cross-feature DataSource (임시 Mock 구현)
  getIt.registerLazySingleton<IPostDatasource>(
    () => MockPostDatasource(),
  );

  getIt.registerLazySingleton<IChatDatasource>(
    () => MockChatDatasource(),
  );

  // Mapper 등록
  getIt.registerLazySingleton<NotificationMapper>(
    () => NotificationMapper(),
  );

  // Register Repository implementation
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
      localDatasource: getIt<ILocalNotificationDatasource>(),
    ),
  );

  // Register UseCases
  getIt.registerFactory<GetUserNotificationsUseCase>(
    () => GetUserNotificationsUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<MarkAsReadUseCase>(
    () => MarkAsReadUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<ProcessVoteNotificationUseCase>(
    () => ProcessVoteNotificationUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<SendNotificationUseCase>(
    () => SendNotificationUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<WatchUnreadCountUseCase>(
    () => WatchUnreadCountUseCase(getIt<INotificationRepository>()),
  );

  // Register new Clean Architecture UseCases
  getIt.registerFactory<InitializeNotificationsUseCase>(
    () => InitializeNotificationsUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<StartNotificationListeningUseCase>(
    () => StartNotificationListeningUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<StopNotificationListeningUseCase>(
    () => StopNotificationListeningUseCase(getIt<INotificationRepository>()),
  );

  getIt.registerFactory<GetPostDataUseCase>(
    () => GetPostDataUseCase(getIt<INotificationRepository>()),
  );

  // Register UI Delegate for Voting Feature
  getIt.registerLazySingleton<IVoteUIDelegate>(
    () => VoteUIManager.instance,
  );

  // GlobalNotificationManager is now registered in NotificationModule

  // Register Services
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(
      repository: getIt<INotificationRepository>(),
      chatDatasource: getIt<IChatDatasource>(),
    ),
  );

  getIt.registerLazySingleton<TargetAudienceService>(
    () => TargetAudienceService(
      postDatasource: getIt<IPostDatasource>(),
    ),
  );

  // Add more dependency registrations here as needed
}
