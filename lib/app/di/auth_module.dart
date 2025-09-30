import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'feature_modules.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/i_auth_remote_datasource.dart';
import '../../features/auth/data/datasources/firebase_auth_remote_datasource.dart';
import '../../features/auth/data/datasources/i_auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

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
    // Register DataSources first
    if (!sl.isRegistered<IAuthRemoteDataSource>()) {
      sl.registerLazySingleton<IAuthRemoteDataSource>(
        () => FirebaseAuthRemoteDataSource(),
      );
    }

    if (!sl.isRegistered<IAuthLocalDataSource>()) {
      sl.registerLazySingleton<IAuthLocalDataSource>(
        () => AuthLocalDataSource(
          prefs: sl<SharedPreferences>(),
        ),
      );
    }

    // Register IAuthRepository with DataSource dependencies
    if (!sl.isRegistered<IAuthRepository>()) {
      sl.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl(
          remoteDataSource: sl<IAuthRemoteDataSource>(),
          localDataSource: sl<IAuthLocalDataSource>(),
        ),
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
