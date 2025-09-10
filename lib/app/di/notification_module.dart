import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feature_modules.dart';
import '../../features/notifications/domain/repositories/i_notification_repository.dart';
import '../../features/notifications/domain/handlers/i_notification_handler.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/data/datasources/i_remote_notification_datasource.dart';
import '../../features/notifications/data/datasources/remote/firebase_notification_datasource.dart';
import '../../features/notifications/data/datasources/i_local_notification_datasource.dart';
import '../../features/notifications/data/datasources/local/shared_prefs_notification_datasource.dart';
import '../../features/notifications/data/datasources/i_post_datasource.dart';
import '../../features/notifications/data/datasources/cross/mock_post_datasource.dart';
import '../../features/notifications/data/datasources/i_chat_datasource.dart';
import '../../features/notifications/data/datasources/cross/mock_chat_datasource.dart';
import '../../features/notifications/data/adapters/notification_service.dart';
import '../../features/notifications/data/adapters/target_audience_service.dart';
import '../../features/notifications/data/adapters/global_notification_manager.dart';
import '../../features/notifications/presentation/handlers/notification_handler_impl.dart';
import '../../features/notifications/domain/services/i_user_service.dart';
import '../../features/notifications/domain/services/i_vote_service.dart';
import '../../features/notifications/data/services/cross_feature_service_adapter.dart';

/// Notification Feature Module
/// 
/// Handles all notification-related dependency injection
class NotificationModule implements FeatureModule {
  bool _initialized = false;
  
  @override
  String get name => 'Notification';
  
  @override
  bool get isInitialized => _initialized;
  
  @override
  void register(GetIt sl) {
    if (_initialized) return;
    
    // DataSources
    sl.registerLazySingleton<IRemoteNotificationDatasource>(
      () => FirebaseNotificationDatasource(
        firestore: FirebaseFirestore.instance,
      ),
    );
    
    sl.registerLazySingleton<ILocalNotificationDatasource>(
      () => SharedPrefsNotificationDatasource(
        prefs: sl<SharedPreferences>(),
      ),
    );
    
    // Cross-feature DataSources (Mock implementations for now)
    sl.registerLazySingleton<IPostDatasource>(
      () => MockPostDatasource(),
    );
    
    sl.registerLazySingleton<IChatDatasource>(
      () => MockChatDatasource(),
    );
    
    // Repository
    sl.registerLazySingleton<INotificationRepository>(
      () => NotificationRepositoryImpl(
        remoteDatasource: sl<IRemoteNotificationDatasource>(),
        localDatasource: sl<ILocalNotificationDatasource>(),
      ),
    );
    
    // Presentation layer Handler
    sl.registerLazySingleton<INotificationHandler>(
      () => NotificationHandlerImpl(),
    );
    
    // Cross-feature service adapters
    sl.registerLazySingleton<IUserService>(
      () => UserServiceAdapter(),
    );
    
    sl.registerLazySingleton<IVoteService>(
      () => VoteServiceAdapter(),
    );
    
    // Services/Adapters
    sl.registerLazySingleton<NotificationService>(
      () => NotificationService(
        repository: sl<INotificationRepository>(),
        chatDatasource: sl<IChatDatasource>(),
      ),
    );
    
    sl.registerLazySingleton<TargetAudienceService>(
      () => TargetAudienceService(
        postDatasource: sl<IPostDatasource>(),
      ),
    );
    
    // Global Notification Manager (no longer singleton)
    sl.registerLazySingleton<GlobalNotificationManager>(
      () => GlobalNotificationManager(
        notificationHandler: sl<INotificationHandler>(),
        notificationRepository: sl<INotificationRepository>(),
        remoteDatasource: sl<IRemoteNotificationDatasource>(),
        localDatasource: sl<ILocalNotificationDatasource>(),
        notificationService: sl<NotificationService>(),
        userService: sl<IUserService>(),
        voteService: sl<IVoteService>(),
      ),
    );
    
    _initialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (!_initialized) return;
    
    // Unregister in reverse order
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
    
    _initialized = false;
  }
}