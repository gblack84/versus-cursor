/// Notifications Feature Dependency Injection Module
///
/// This module configures dependency injection for the Notifications feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote/Local)
/// - Services (Queue, Notification, FCM)
/// - Repositories
/// - Contracts
/// - UseCases
/// - Providers
///
/// Firebase-Centric Architecture v1.0:
/// - Direct Firebase SDK access (no cross-feature dependencies)
/// - Communication through Firebase Firestore only
/// - Feature independence with routing-based navigation

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/notification_contract.dart';

// ===== Domain Layer - Repository Interfaces =====
import '../domain/repositories/i_notification_repository.dart';

// ===== Domain Layer - Service Interfaces =====
import '../domain/services/i_notification_service.dart';

// ===== Data Layer - DataSource Interfaces =====
import '../data/datasources/i_remote_notification_datasource.dart';
import '../data/datasources/i_local_notification_datasource.dart';

// ===== Data Layer - DataSource Implementations =====
import '../data/datasources/remote/firebase_notification_datasource.dart';
import '../data/datasources/local/shared_prefs_notification_datasource.dart';

// ===== Data Layer - Repository Implementation =====
import '../data/repositories/notification_repository_impl.dart';

// ===== Data Layer - Mappers =====
import '../data/mappers/notification_mapper.dart';

// ===== Data Layer - Services/Adapters =====
import '../data/adapters/notification_service.dart';

// ===== Services Layer (App-wide) =====
import '/services/notification/notification_queue_service.dart';
import '/services/notification/fcm_service.dart';

// ===== Domain Layer - UseCases (5 total) =====
import '../domain/usecases/get_user_notifications_usecase.dart';
import '../domain/usecases/watch_user_notifications_usecase.dart';
import '../domain/usecases/send_notification_usecase.dart';
import '../domain/usecases/mark_as_read_usecase.dart';
import '../domain/usecases/watch_unread_count_usecase.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/notification_overlay_provider.dart';

/// Register all Notifications feature dependencies
/// Call this function from main setupDependencyInjection()
void registerNotificationModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Mapper Registration =====
  _registerMapper(getIt);

  // ===== Services Registration =====
  _registerServices(getIt);

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== NotificationContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Remote and Local DataSources
void _registerDataSources(GetIt getIt) {
  // Remote DataSource (Firebase Firestore)
  getIt.registerLazySingleton<IRemoteNotificationDatasource>(
    () => FirebaseNotificationDatasource(
      firestore: FirebaseFirestore.instance,
    ),
  );

  // Local DataSource (SharedPreferences)
  getIt.registerLazySingleton<ILocalNotificationDatasource>(
    () => SharedPrefsNotificationDatasource(
      prefs: getIt<SharedPreferences>(),
    ),
  );
}

/// Register Mapper
void _registerMapper(GetIt getIt) {
  getIt.registerLazySingleton<NotificationMapper>(
    () => NotificationMapper(),
  );
}

/// Register Services
/// Order matters: FCM → NotificationService → QueueService
void _registerServices(GetIt getIt) {
  // FCM Service (Singleton instance)
  // Note: FCMService uses singleton pattern internally
  getIt.registerLazySingleton<FCMService>(
    () => FCMService(),
  );

  // Notification Service (Domain Service)
  // Depends on: remoteDatasource
  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
    ),
  );

  // Notification Queue Service
  // Depends on: localDatasource, notificationService, fcmService
  // This must be registered BEFORE Repository
  getIt.registerLazySingleton<NotificationQueueService>(
    () => NotificationQueueService(
      localDatasource: getIt<ILocalNotificationDatasource>(),
      notificationService: getIt<INotificationService>(),
      fcmService: getIt<FCMService>(),
    ),
  );
}

/// Register Repository implementation
void _registerRepository(GetIt getIt) {
  // Note: Repository depends on queueService, which must be registered first
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      remoteDatasource: getIt<IRemoteNotificationDatasource>(),
      localDatasource: getIt<ILocalNotificationDatasource>(),
      queueService: getIt<NotificationQueueService>(),
    ),
  );
}

/// Register NotificationContract
/// NotificationRepositoryImpl implements both INotificationRepository and NotificationContract (Dual Interface)
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<NotificationContract>(
    () => getIt<INotificationRepository>() as NotificationRepositoryImpl,
  );
}

/// Register all UseCases (5 total)
void _registerUseCases(GetIt getIt) {
  getIt.registerFactory(
    () => GetUserNotificationsUseCase(
      getIt<INotificationRepository>(),
    ),
  );

  getIt.registerFactory(
    () => WatchUserNotificationsUseCase(
      getIt<INotificationRepository>(),
    ),
  );

  getIt.registerFactory(
    () => SendNotificationUseCase(
      getIt<INotificationRepository>(),
    ),
  );

  getIt.registerFactory(
    () => MarkAsReadUseCase(
      getIt<INotificationRepository>(),
    ),
  );

  getIt.registerFactory(
    () => WatchUnreadCountUseCase(
      getIt<INotificationRepository>(),
    ),
  );
}

/// Register Presentation Layer Providers
void _registerProviders(GetIt getIt) {
  // Notification Overlay Provider
  // Depends on: queueService, markAsRead
  getIt.registerLazySingleton<NotificationOverlayProvider>(
    () => NotificationOverlayProvider(
      queueService: getIt<NotificationQueueService>(),
      markAsRead: getIt<MarkAsReadUseCase>(),
    ),
  );
}
