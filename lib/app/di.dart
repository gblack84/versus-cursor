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

// Notifications UI & Adapters
import '/features/notifications/presentation/managers/i_notification_ui_delegate.dart';
import '/features/notifications/presentation/managers/notification_ui_manager.dart';
import '/features/notifications/data/adapters/global_notification_manager.dart';

final getIt = GetIt.instance;

/// Initialize dependency injection
void setupDependencyInjection() {
  // Register Posts data source for Voting feature
  getIt.registerLazySingleton<PostsDataSource>(
    () => PostsDataSourceImpl.instance,
  );
  
  // Register Auth service
  getIt.registerLazySingleton<IAuthService>(
    () => AuthServiceImpl(),
  );
  
  // ===== Notifications Feature DI =====
  
  // Register Repository implementation
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl.instance,
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
  
  // Register UI Delegate
  getIt.registerLazySingleton<INotificationUIDelegate>(
    () => NotificationUIManager.instance,
  );
  
  // Register Global Notification Manager
  getIt.registerLazySingleton<GlobalNotificationManager>(
    () => GlobalNotificationManager.instance,
  );
  
  // Add more dependency registrations here as needed
}