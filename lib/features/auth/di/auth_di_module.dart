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

// ===== Infrastructure Services =====
import '/services/rate_limit/rate_limit_service.dart';

// ===== App Layer - Contracts =====
// Contract 패턴 완전 폐기 (2025-11-09) - Firebase-Centric Architecture
// - AuthContract 제거: FirebaseAuth.instance 직접 사용
// - UserContract 제거: IUserRepository 직접 사용

// ===== Domain Layer - Repositories =====
import '../domain/repositories/i_auth_repository.dart';

// ===== Domain Layer - Services =====
// Phase 3 Services removed (Dead Code cleanup 2025-11-20)

// ===== Data Layer - Repository Implementation =====
import '../data/repositories/auth_repository_impl.dart';

// ===== Domain Layer - UseCases (12 total) =====
// Sign In
import '../domain/usecases/sign_in/sign_in_with_email_usecase.dart';
import '../domain/usecases/sign_in/sign_in_with_google_usecase.dart';
import '../domain/usecases/sign_in/sign_in_with_apple_usecase.dart';
// Sign Up
import '../domain/usecases/sign_up/sign_up_with_email_usecase.dart';
// Account Management (Old - Multi-method UseCases)
import '../domain/usecases/account/password_management_usecase.dart';
import '../domain/usecases/account/email_verification_usecase.dart';
import '../domain/usecases/account/account_management_usecase.dart';
// Account Management (New - SRP UseCases)
import '../domain/usecases/account/update_password_usecase.dart';
import '../domain/usecases/account/reset_password_usecase.dart';
// Phone Authentication (New - SRP UseCases)
import '../domain/usecases/phone/send_phone_otp_usecase.dart';
import '../domain/usecases/phone/sign_in_with_phone_usecase.dart';
// Session
import '../domain/usecases/session/sign_out_usecase.dart';
import '../domain/usecases/session/get_current_user_usecase.dart';

/// Register all Auth feature dependencies
/// Call this function from main setupDependencyInjection()
void registerAuthModule(GetIt getIt) {
  // ===== Repository Registration =====
  _registerRepository(getIt);

  // ===== UseCases Registration =====
  _registerUseCases(getIt);
}

/// Register Repository implementation
///
/// **Firebase-Centric Architecture v2.0**:
/// - Direct FirebaseAuth.instance injection
/// - UnifiedCacheService.instance for 3-Layer caching (singleton, no DI needed)
/// - No Local DataSource abstraction layer
void _registerRepository(GetIt getIt) {
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: FirebaseAuth.instance,
      // UnifiedCacheService는 싱글톤으로 Repository 내부에서 직접 접근
    ),
  );
}

/// Register all UseCases (10 total)
void _registerUseCases(GetIt getIt) {
  // Sign In UseCases
  getIt.registerFactory<SignInWithEmailUseCase>(
    () => SignInWithEmailUseCase(
      repository: getIt<IAuthRepository>(),
      rateLimitService: getIt<RateLimitService>(),
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

  // Sign Up UseCases
  getIt.registerFactory<SignUpWithEmailUseCase>(
    () => SignUpWithEmailUseCase(
      repository: getIt<IAuthRepository>(),
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
    ),
  );

  getIt.registerFactory<EmailVerificationUseCase>(
    () => EmailVerificationUseCase(
      repository: getIt<IAuthRepository>(),
      rateLimitService: getIt<RateLimitService>(),
    ),
  );

  getIt.registerFactory<AccountManagementUseCase>(
    () => AccountManagementUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  // New SRP UseCases (Phase 1 - Category A)
  getIt.registerFactory<UpdatePasswordUseCase>(
    () => UpdatePasswordUseCase(
      repository: getIt<IAuthRepository>(),
    ),
  );

  getIt.registerFactory<ResetPasswordUseCase>(
    () => ResetPasswordUseCase(
      repository: getIt<IAuthRepository>(),
      rateLimitService: getIt<RateLimitService>(),
    ),
  );

  getIt.registerFactory<SendPhoneOtpUseCase>(
    () => SendPhoneOtpUseCase(
      repository: getIt<IAuthRepository>(),
      rateLimitService: getIt<RateLimitService>(),
    ),
  );

  // NEW SRP version (with RateLimitService)
  getIt.registerFactory<SignInWithPhoneUseCase>(
    () => SignInWithPhoneUseCase(
      repository: getIt<IAuthRepository>(),
      rateLimitService: getIt<RateLimitService>(),
    ),
  );
}
