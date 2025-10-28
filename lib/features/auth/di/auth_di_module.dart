/// Auth Feature Dependency Injection Module
///
/// This module configures dependency injection for the Auth feature
/// following Clean Architecture principles with proper layering:
/// - DataSources (Remote/Local)
/// - Repositories
/// - UseCases
/// - Providers
/// - Contracts

import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ===== Core Services =====
import '/core/utils/idempotency_service.dart';

// ===== App Layer - Contracts =====
import '/app/contracts/auth_contract.dart';
import '/app/contracts/user_contract.dart';

// ===== Domain Layer - Repositories =====
import '../domain/repositories/i_auth_repository.dart';

// ===== Data Layer - DataSources =====
import '../data/datasources/i_auth_local_datasource.dart';
import '../data/datasources/auth_local_datasource.dart';

// ===== Data Layer - Repository Implementation =====
import '../data/repositories/auth_repository_impl.dart';

// ===== Domain Layer - UseCases (10 total) =====
import '../domain/usecases/sign_in_with_email_usecase.dart';
import '../domain/usecases/sign_up_with_email_usecase.dart';
import '../domain/usecases/sign_in_with_google_usecase.dart';
import '../domain/usecases/sign_in_with_apple_usecase.dart';
import '../domain/usecases/sign_in_with_phone_usecase.dart';
import '../domain/usecases/sign_out_usecase.dart';
import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/password_management_usecase.dart';
import '../domain/usecases/email_verification_usecase.dart';
import '../domain/usecases/account_management_usecase.dart';

// ===== Presentation Layer - Providers =====
import '../presentation/providers/auth_provider.dart' as auth_feature;

/// Register all Auth feature dependencies
/// Call this function from main setupDependencyInjection()
void registerAuthModule(GetIt getIt) {
  // ===== DataSources Registration =====
  _registerDataSources(getIt);

  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== AuthContract Registration =====
  _registerContract(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);

  // ===== Providers Registration =====
  _registerProviders(getIt);
}

/// Register Local DataSource
/// Note: Remote DataSource removed - Repository uses FirebaseAuth directly
void _registerDataSources(GetIt getIt) {
  // Local DataSource (Cache/SharedPreferences)
  getIt.registerLazySingleton<IAuthLocalDataSource>(
    () => AuthLocalDataSource(
      prefs: getIt<SharedPreferences>(),
    ),
  );
}

/// Register Repository implementation
/// Note: Repository uses FirebaseAuth directly instead of Remote DataSource
void _registerRepository(GetIt getIt) {
  // Note: UserContract must be registered before this module
  // UserContract is registered in Profile Feature DI module
  if (!getIt.isRegistered<UserContract>()) {
    throw StateError(
      'UserContract must be registered before AuthModule.init()\n'
      'Ensure Profile Feature DI module is initialized first.'
    );
  }

  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: FirebaseAuth.instance,
      localDataSource: getIt<IAuthLocalDataSource>(),
      userContract: getIt<UserContract>(),
    ),
  );
}

/// Register AuthContract
/// AuthRepositoryImpl implements both IAuthRepository and AuthContract (Dual Interface)
void _registerContract(GetIt getIt) {
  getIt.registerLazySingleton<AuthContract>(
    () => getIt<IAuthRepository>() as AuthRepositoryImpl,
  );
}

/// Register all UseCases (10 total)
void _registerUseCases(GetIt getIt) {
  // Sign In UseCases
  getIt.registerFactory<SignInWithEmailUseCase>(
    () => SignInWithEmailUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  getIt.registerFactory<SignInWithGoogleUseCase>(
    () => SignInWithGoogleUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  getIt.registerFactory<SignInWithAppleUseCase>(
    () => SignInWithAppleUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  getIt.registerFactory<SignInWithPhoneUseCase>(
    () => SignInWithPhoneUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  // Sign Up UseCases
  getIt.registerFactory<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(
      repository: getIt<IAuthRepository>(),
      idempotencyService: getIt<IdempotencyService>(),
    ),
  );

  // Sign Out UseCase
  getIt.registerFactory<SignOutUseCase>(
    () => SignOutUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  // User Management UseCases
  getIt.registerFactory<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(
      getIt<IAuthRepository>(),  // positional argument
    ),
  );

  getIt.registerFactory<PasswordManagementUseCase>(
    () => PasswordManagementUseCase(
      repository: getIt<IAuthRepository>(),
      idempotencyService: getIt<IdempotencyService>(),
    ),
  );

  getIt.registerFactory<EmailVerificationUseCase>(
    () => EmailVerificationUseCase(
      repository: getIt<IAuthRepository>(),
      idempotencyService: getIt<IdempotencyService>(),
    ),
  );

  getIt.registerFactory<AccountManagementUseCase>(
    () => AccountManagementUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );
}

/// Register Presentation Layer Providers
void _registerProviders(GetIt getIt) {
  // AuthProvider - manages authentication state
  getIt.registerLazySingleton<auth_feature.AuthProvider>(
    () => auth_feature.AuthProvider(),
  );
}
