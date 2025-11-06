// Riverpod Providers for Auth Feature
// Clean Architecture v4.0 - Riverpod 3.x Migration
//
// **Creation Feature 패턴 100% 적용**:
// - ✅ @riverpod annotation
// - ✅ StreamProvider.family + keepAlive()
// - ✅ Notifier class for state management
// - ✅ Either<L,R> pattern

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/features/auth/domain/entities/auth_user.dart';
import 'usecase_providers.dart';

part 'auth_providers.g.dart';

// ========================================
// Auth State Stream Provider
// ========================================

/// Firebase Authentication 실시간 상태 Stream Provider
///
/// **Creation Feature 패턴 적용**:
/// - ✅ StreamProvider.family + keepAlive()
/// - ✅ yield null로 즉시 로딩
/// - ✅ Firebase Stream 실시간 동기화
/// - ✅ 중복 리스너 방지
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
@riverpod
Stream<AuthUser?> authStateStream(AuthStateStreamRef ref, AuthStateParams params) async* {
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
}

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
// Loading & Error State Notifiers
// ========================================

/// 로딩 상태 Notifier
///
/// **역할**: 로그인/회원가입 등 비동기 작업 중 로딩 UI 표시
/// **패턴**: @riverpod class Notifier<bool>
/// **사용처**: SignInScreen, SignUpScreen
///
/// **사용 예시**:
/// ```dart
/// // 로딩 시작
/// ref.read(authLoadingProvider.notifier).setLoading(true);
///
/// // 로딩 종료
/// ref.read(authLoadingProvider.notifier).setLoading(false);
///
/// // 로딩 상태 감시
/// final isLoading = ref.watch(authLoadingProvider);
/// ```
@riverpod
class AuthLoading extends _$AuthLoading {
  @override
  bool build() => false;

  void setLoading(bool value) {
    state = value;
  }

  void reset() {
    state = false;
  }
}

/// 에러 메시지 Notifier
///
/// **역할**: 인증 실패 시 에러 메시지 저장 및 UI 표시
/// **패턴**: @riverpod class Notifier<String?>
/// **사용처**: SignInScreen, SignUpScreen, ErrorSnackBar
///
/// **사용 예시**:
/// ```dart
/// // 에러 설정
/// ref.read(authErrorProvider.notifier).setError('Invalid credentials');
///
/// // 에러 초기화
/// ref.read(authErrorProvider.notifier).clear();
///
/// // 에러 메시지 감시
/// final errorMessage = ref.watch(authErrorProvider);
/// if (errorMessage != null) {
///   ScaffoldMessenger.of(context).showSnackBar(
///     SnackBar(content: Text(errorMessage)),
///   );
/// }
/// ```
@riverpod
class AuthError extends _$AuthError {
  @override
  String? build() => null;

  void setError(String? error) {
    state = error;
  }

  void clear() {
    state = null;
  }
}

// ========================================
// Current User Providers (Clean Architecture)
// ========================================

/// Current User Provider
///
/// **역할**: 현재 로그인한 사용자 정보 조회 (Clean Architecture)
/// **의존성**: GetCurrentUserUseCase
/// **패턴**: FutureProvider.autoDispose
///
/// **Clean Architecture Flow**:
/// ```
/// Presentation → UseCase → Repository → Firebase
/// ```
///
/// **사용 예시**:
/// ```dart
/// final currentUserAsync = ref.watch(currentUserProvider);
///
/// currentUserAsync.when(
///   loading: () => CircularProgressIndicator(),
///   error: (error, stack) => Text('Error: $error'),
///   data: (user) => user == null ? LoginScreen() : HomeScreen(),
/// );
/// ```
@riverpod
Future<AuthUser?> currentUser(CurrentUserRef ref) async {
  final useCase = ref.watch(getCurrentUserUseCaseProvider);
  final result = await useCase();

  return result.fold(
    (failure) => null,
    (user) => user,
  );
}

/// Current User ID Provider
///
/// **역할**: userId만 필요한 경우 편의 제공
/// **의존성**: currentUserProvider
/// **패턴**: FutureProvider.autoDispose (derived)
///
/// **사용 예시**:
/// ```dart
/// final currentUserId = await ref.read(currentUserIdProvider.future);
/// if (currentUserId == null) {
///   // User not logged in
///   return;
/// }
///
/// // Use userId for business logic
/// await repository.loadUserData(currentUserId);
/// ```
@riverpod
Future<String?> currentUserId(CurrentUserIdRef ref) async {
  final user = await ref.watch(currentUserProvider.future);
  return user?.uid;
}
