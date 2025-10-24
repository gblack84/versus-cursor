/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 일부입니다.
/// 신규 시스템은 /features/notifications/di/notification_di_module.dart를 사용합니다.
///
/// 삭제 조건:
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import 'factories/notification_factory.dart';

/// Notification Feature Module
///
/// Handles all notification-related dependency injection using Factory pattern
/// This module delegates all creation logic to NotificationFactory to maintain
/// Clean Architecture and reduce coupling
class NotificationModule implements FeatureModule {
  bool _initialized = false;
  final NotificationFactory _factory = NotificationFactory();

  @override
  String get name => 'Notification';

  @override
  bool get isInitialized => _initialized;

  @override
  void register(GetIt sl) {
    if (_initialized) return;

    // Delegate all registration to factory
    // Factory handles proper registration order and dependency resolution
    _factory.registerAll(sl);

    // NOTE: INotificationHandler is registered in di.dart using NotificationDisplayAdapter
    // to avoid cross-feature circular dependency with voting feature

    _initialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (!_initialized) return;

    // Delegate unregistration to factory
    // Factory handles proper unregistration order (reverse of registration)
    _factory.unregisterAll(sl);

    _initialized = false;
  }
}
