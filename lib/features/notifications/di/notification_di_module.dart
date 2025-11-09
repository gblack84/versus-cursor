/// Notifications Feature Dependency Injection Module
///
/// **Phase 5 Complete**: Firebase-Centric v2.0
/// - Direct Firestore access (DataSource/DTO/Mapper 제거)
/// - Extension Pattern으로 변환
/// - 817줄 코드 감소 달성
///
/// This module configures dependency injection for the Notifications feature
/// following Clean Architecture principles with proper layering:
/// - Services (Queue, Notification, FCM)
/// - Repositories (Direct Firestore + Extension Pattern)
/// - Contracts
/// - UseCases
/// - Providers
///
/// Firebase-Centric Architecture v2.0:
/// - Direct Firebase SDK access (no DataSource layer)
/// - Extension Pattern for Entity ↔ Firestore conversion
/// - Communication through Firebase Firestore only
/// - Feature independence with routing-based navigation

import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ===== App Layer - Contracts =====
// Contract 패턴 완전 폐기 (2025-11-09)
// Firebase-Centric v2.0: Firestore 직접 접근

// ===== Domain Layer - Repository Interfaces =====
import '../domain/repositories/i_notification_repository.dart';

// ===== Domain Layer - Service Interfaces =====
import '../domain/services/i_notification_service.dart';

// ===== Data Layer - Repository Implementation =====
import '../data/repositories/notification_repository_impl.dart';

// ===== Data Layer - Services/Adapters =====
import '../data/services/notification_service.dart';

// ===== Services Layer (App-wide) =====
import '/services/notification/notification_queue_service.dart';
import '/services/notification/fcm_service.dart';
import '/core/utils/idempotency_service.dart';

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
///
/// **Phase 5 Changes**:
/// - Removed DataSource registration (direct Firestore access)
/// - Removed Mapper registration (Extension Pattern)
/// - Removed NotificationService registration (pending Repository migration)
void registerNotificationModule(GetIt getIt) {
  // ===== Services Registration =====
  _registerServices(getIt);

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

// ===== Phase 5: DataSource and Mapper registration removed =====
// Replaced by Extension Pattern (direct Firestore + Extension methods)

/// Register Services
/// **Phase 5 Complete**: Firebase-Centric v2.0 Architecture
void _registerServices(GetIt getIt) {
  // FCM Service (Singleton instance)
  // Note: FCMService uses singleton pattern internally
  getIt.registerLazySingleton<FCMService>(
    () => FCMService(),
  );

  // ✅ Notification Service (Domain Service)
  // Wraps INotificationRepository for real-time notification streaming
  // Implements all INotificationService methods
  getIt.registerLazySingleton<INotificationService>(
    () => NotificationService(
      repository: getIt<INotificationRepository>(),
    ),
  );

  // ✅ Notification Queue Service
  // Phase 5 Complete: UnifiedCacheService integrated
  // - ILocalNotificationDatasource removed
  // - UnifiedCacheService for processed notification IDs
  // - FCM message conversion implemented (Social, System)
  getIt.registerLazySingleton<NotificationQueueService>(
    () => NotificationQueueService(
      notificationService: getIt<INotificationService>(),
      fcmService: getIt<FCMService>(),
    ),
  );
}

/// Register Repository implementation
///
/// **Phase 5 Complete**: Firebase-Centric v2.0
/// - Direct FirebaseFirestore injection (no DataSource layer)
/// - Extension Pattern for Entity ↔ Firestore conversion
/// - Phase 4 IdempotencyService preserved for duplicate prevention
void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<INotificationRepository>(
    () => NotificationRepositoryImpl(
      firestore: FirebaseFirestore.instance,
      idempotencyService: getIt<IdempotencyService>(),
    ),
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
/// **Phase 5 Complete**: All providers registered
void _registerProviders(GetIt getIt) {
  // ✅ Notification Overlay Provider
  // Manages notification UI overlay display
  // Depends on: QueueService, MarkAsReadUseCase
  getIt.registerLazySingleton<NotificationOverlayProvider>(
    () => NotificationOverlayProvider(
      queueService: getIt<NotificationQueueService>(),
      markAsRead: getIt<MarkAsReadUseCase>(),
    ),
  );
}
