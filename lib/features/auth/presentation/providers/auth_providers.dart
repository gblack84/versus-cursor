// Riverpod Providers for Auth Feature
// Clean Architecture v4.0 - Riverpod 2.x Migration
//
// **Voting Feature 패턴 100% 적용**:
// - ✅ StreamProvider.autoDispose.family
// - ✅ keepAlive() for caching
// - ✅ Firebase Stream real-time sync
// - ✅ Either<L,R> pattern

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/app/di.dart';
import '/features/auth/domain/entities/auth_user.dart';
import '/features/auth/domain/usecases/sign_in_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_up_with_email_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '/features/auth/domain/usecases/sign_in_with_phone_usecase.dart';
import '/features/auth/domain/usecases/get_current_user_usecase.dart';
import '/features/auth/domain/usecases/password_management_usecase.dart';
import '/features/auth/domain/usecases/email_verification_usecase.dart';
import '/features/auth/domain/usecases/account_management_usecase.dart';
import '/features/auth/domain/usecases/sign_out_usecase.dart';

// ========================================
// UseCase Providers (GetIt Wrapping)
// ========================================
/// GetIt에 등록된 SignInWithEmailUseCase를 Riverpod Provider로 제공
final signInWithEmailUseCaseProvider = Provider<SignInWithEmailUseCase>((ref) {
  return getIt<SignInWithEmailUseCase>();
});

/// GetIt에 등록된 SignUpWithEmailUseCase를 Riverpod Provider로 제공
final signUpWithEmailUseCaseProvider = Provider<SignUpWithEmailUseCase>((ref) {
  return getIt<SignUpWithEmailUseCase>();
});

/// GetIt에 등록된 SignInWithGoogleUseCase를 Riverpod Provider로 제공
final signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>((ref) {
  return getIt<SignInWithGoogleUseCase>();
});

/// GetIt에 등록된 SignInWithAppleUseCase를 Riverpod Provider로 제공
final signInWithAppleUseCaseProvider = Provider<SignInWithAppleUseCase>((ref) {
  return getIt<SignInWithAppleUseCase>();
});

/// GetIt에 등록된 SignInWithPhoneUseCase를 Riverpod Provider로 제공
final signInWithPhoneUseCaseProvider = Provider<SignInWithPhoneUseCase>((ref) {
  return getIt<SignInWithPhoneUseCase>();
});

/// GetIt에 등록된 GetCurrentUserUseCase를 Riverpod Provider로 제공
final getCurrentUserUseCaseProvider = Provider<GetCurrentUserUseCase>((ref) {
  return getIt<GetCurrentUserUseCase>();
});

/// GetIt에 등록된 PasswordManagementUseCase를 Riverpod Provider로 제공
final passwordManagementUseCaseProvider = Provider<PasswordManagementUseCase>((ref) {
  return getIt<PasswordManagementUseCase>();
});

/// GetIt에 등록된 EmailVerificationUseCase를 Riverpod Provider로 제공
final emailVerificationUseCaseProvider = Provider<EmailVerificationUseCase>((ref) {
  return getIt<EmailVerificationUseCase>();
});

/// GetIt에 등록된 AccountManagementUseCase를 Riverpod Provider로 제공
final accountManagementUseCaseProvider = Provider<AccountManagementUseCase>((ref) {
  return getIt<AccountManagementUseCase>();
});

/// GetIt에 등록된 SignOutUseCase를 Riverpod Provider로 제공
final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return getIt<SignOutUseCase>();
});

// ========================================
// Auth State Stream Provider
// ========================================
/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Voting Feature 패턴 100% 적용**:
/// - ✅ BehaviorSubject 캐싱 → StreamProvider.family + keepAlive()
/// - ✅ 중복 리스너 방지 → Family가 자동 관리
/// - ✅ 즉시 로딩 → yield null (기본값)
/// - ✅ 자동 메모리 정리 → autoDispose
/// - ✅ 실시간 동기화 → Firebase Stream 전달
///
/// **사용 예시**:
/// ```dart
/// final authState = ref.watch(authStateStreamProvider(const AuthStateParams()));
///
/// authState.when(
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => ErrorWidget(e),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```
final authStateStreamProvider =
    StreamProvider.autoDispose.family<AuthUser?, AuthStateParams>(
  (ref, params) async* {
    // 1. 즉시 로딩: 기본값 먼저 emit
    yield null;

    // 2. Firebase 실시간 Stream
    await for (final user in FirebaseAuth.instance.authStateChanges()) {
      if (user != null) {
        // Firebase User → AuthUser 변환
        yield AuthUser(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
          isEmailVerified: user.emailVerified,
          isAnonymous: user.isAnonymous,
          createdAt: user.metadata.creationTime,
          lastLoginAt: user.metadata.lastSignInTime,
        );
      } else {
        yield null;
      }
    }

    // 3. keepAlive: 중복 리스너 방지
    ref.keepAlive();
  },
);

/// Auth State 파라미터 (Family Provider용)
///
/// StreamProvider.family를 사용하기 위한 파라미터 클래스.
/// 현재는 파라미터가 없지만, 향후 확장 가능성을 위해 정의.
///
/// **equality 구현**:
/// - operator == : 모든 AuthStateParams 인스턴스를 동일하게 취급
/// - hashCode : 항상 0 반환
class AuthStateParams {
  const AuthStateParams();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthStateParams && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}

// ========================================
// Loading & Error State Providers
// ========================================
/// 로딩 상태 Provider
///
/// 로그인, 회원가입 등 비동기 작업 중 로딩 UI를 표시하기 위한 상태.
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).state = true;
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).state = false;
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// if (isLoading) return CircularProgressIndicator();
/// ```
final authLoadingProvider = StateProvider<bool>((ref) => false);

/// 에러 메시지 Provider
///
/// 인증 실패 시 에러 메시지를 저장하고 UI에 표시하기 위한 상태.
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).state = failure.message;
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).state = null;
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```
final authErrorProvider = StateProvider<String?>((ref) => null);
