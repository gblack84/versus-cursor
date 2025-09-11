import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';

/// Auth Feature DI Module
///
/// Manages dependency injection for authentication-related services
/// following Clean Architecture principles
class AuthModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Auth';

  @override
  void register(GetIt sl) {
    // Register IAuthRepository as lazy singleton
    if (!sl.isRegistered<IAuthRepository>()) {
      sl.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl.instance,
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IAuthRepository>()) {
      sl.unregister<IAuthRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
