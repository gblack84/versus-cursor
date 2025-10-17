import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'feature_modules.dart';
import '../../features/chat/data/datasources/i_chat_remote_datasource.dart';
import '../../features/chat/data/datasources/firebase_chat_remote_datasource.dart';
import '../../features/chat/domain/repositories/i_chat_repository.dart';
import '../../features/chat/data/repositories/chat_repository_impl.dart';

/// Chat Feature DI Module (Clean Architecture v4.0)
///
/// Manages dependency injection for chat-related services
/// following Clean Architecture principles with Datasource layer
class ChatModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Chat';

  @override
  void register(GetIt sl) {
    // Register Chat Datasource
    if (!sl.isRegistered<IChatRemoteDatasource>()) {
      sl.registerLazySingleton<IChatRemoteDatasource>(
        () => FirebaseChatRemoteDatasource(
          firestore: FirebaseFirestore.instance,
        ),
      );
    }

    // Register ChatRepository with Datasource injection
    if (!sl.isRegistered<IChatRepository>()) {
      sl.registerLazySingleton<IChatRepository>(
        () => ChatRepositoryImpl(
          remoteDatasource: sl<IChatRemoteDatasource>(),
        ),
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IChatRepository>()) {
      sl.unregister<IChatRepository>();
    }
    if (sl.isRegistered<IChatRemoteDatasource>()) {
      sl.unregister<IChatRemoteDatasource>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
