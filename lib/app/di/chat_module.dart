import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../core/repositories/chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';

/// Chat Feature DI Module
/// 
/// Manages dependency injection for chat-related services
/// following Clean Architecture principles
class ChatModule implements FeatureModule {
  static bool _isInitialized = false;
  
  @override
  String get name => 'Chat';
  
  @override
  void register(GetIt sl) {
    // Register ChatRepository as lazy singleton
    if (!sl.isRegistered<ChatRepository>()) {
      sl.registerLazySingleton<ChatRepository>(
        () => ChatRepositoryImpl.instance,
      );
    }
    
    _isInitialized = true;
  }
  
  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<ChatRepository>()) {
      sl.unregister<ChatRepository>();
    }
    _isInitialized = false;
  }
  
  @override
  bool get isInitialized => _isInitialized;
}