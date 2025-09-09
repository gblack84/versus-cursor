import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';

/// Notification Feature DI Module
/// 
/// Manages dependency injection for notification-related services
/// following Clean Architecture principles
class NotificationModule implements FeatureModule {
  static bool _isInitialized = false;
  
  @override
  String get name => 'Notification';
  
  @override
  void register(GetIt sl) {
    // Register INotificationRepository as lazy singleton
    if (!sl.isRegistered<INotificationRepository>()) {
      sl.registerLazySingleton<INotificationRepository>(
        () => NotificationRepositoryImpl.instance,
      );
    }
    
    _isInitialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<INotificationRepository>()) {
      sl.unregister<INotificationRepository>();
    }
    _isInitialized = false;
  }
  
  @override
  bool get isInitialized => _isInitialized;
}