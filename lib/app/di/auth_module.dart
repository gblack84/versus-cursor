/// ⚠️ DEPRECATED - Firebase 최적화 후 삭제 예정
///
/// 이 파일은 레거시 DI 시스템의 일부입니다.
/// 신규 시스템은 /features/auth/di/auth_di_module.dart를 사용합니다.
///
/// 삭제 조건:
/// - main.dart에서 DIContainer.initialize() 제거 완료 시
///
/// 관련 이슈: Firebase 최적화 마이그레이션

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'feature_modules.dart';
import '../../features/auth/domain/repositories/i_auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/i_auth_local_datasource.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/presentation/providers/auth_provider.dart' as auth_feature;
import '../contracts/auth_contract.dart';
import '../contracts/user_contract.dart';

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
    // Register Local DataSource
    // Note: Remote DataSource removed - Repository uses FirebaseAuth directly
    if (!sl.isRegistered<IAuthLocalDataSource>()) {
      sl.registerLazySingleton<IAuthLocalDataSource>(
        () => AuthLocalDataSource(
          prefs: sl<SharedPreferences>(),
        ),
      );
    }

    // Register IAuthRepository with direct Firebase dependency
    // Phase 5: UserContract 주입 (Profile Feature와 통신)
    if (!sl.isRegistered<IAuthRepository>()) {
      sl.registerLazySingleton<IAuthRepository>(
        () => AuthRepositoryImpl(
          firebaseAuth: FirebaseAuth.instance,
          localDataSource: sl<IAuthLocalDataSource>(),
          userContract: sl<UserContract>(),
        ),
      );
    }

    // Register AuthContract (Phase 2: Clean Architecture)
    // AuthProvider is already registered in app/di/di.dart
    // We just need to expose it as AuthContract for other Features
    if (!sl.isRegistered<AuthContract>()) {
      sl.registerFactory<AuthContract>(
        () => sl<auth_feature.AuthProvider>(),  // Reuse existing AuthProvider instance
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
