import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/chat/domain/repositories/i_chat_repository.dart';
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
    if (!sl.isRegistered<IChatRepository>()) {
      sl.registerLazySingleton<IChatRepository>(
        () => ChatRepositoryImpl.instance,
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IChatRepository>()) {
      sl.unregister<IChatRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
