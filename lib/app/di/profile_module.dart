import 'package:get_it/get_it.dart';
import 'feature_modules.dart';
import '../../features/profile/domain/repositories/i_user_repository.dart';
import '../../features/profile/data/repositories/user_repository_impl.dart';

/// Profile Feature DI Module
///
/// Manages dependency injection for profile-related services
/// following Clean Architecture principles
class ProfileModule implements FeatureModule {
  static bool _isInitialized = false;

  @override
  String get name => 'Profile';

  @override
  void register(GetIt sl) {
    // Register UserRepository as lazy singleton
    if (!sl.isRegistered<IUserRepository>()) {
      sl.registerLazySingleton<IUserRepository>(
        () => UserRepositoryImpl.instance,
      );
    }

    _isInitialized = true;
  }

  @override
  void unregister(GetIt sl) {
    if (sl.isRegistered<IUserRepository>()) {
      sl.unregister<IUserRepository>();
    }
    _isInitialized = false;
  }

  @override
  bool get isInitialized => _isInitialized;
}
