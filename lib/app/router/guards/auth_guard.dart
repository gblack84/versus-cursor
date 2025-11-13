import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

// Phase 5: Guard Analytics
import '/services/analytics/guard_analytics_service.dart';
import '/services/analytics/guard_analytics_event.dart';

/// AuthGuard - 인증 상태 기반 Route 보호
///
/// **Phase 3: Auth Logic Separation** ✅ 완료
/// - AppRoute.toRoute()의 중복 redirect 로직 제거
/// - 중앙화된 auth 체크 로직
/// - Firebase Auth 직접 확인 (간단하고 안정적)
///
/// **Phase 4: Guard System Enhancement** ✅ 완료
/// - ✅ Redirect Location 저장/복원 (로그인 후 원래 페이지로)
/// - ✅ Role-based 권한 체크 (admin, tester, user)
/// - ✅ Custom Guard Composition (AND/OR 조합)
/// - ✅ Error Handling 통합
///
/// **주요 기능**:
/// 1. **Basic Auth Guard**:
///    - `checkAuth()` - 기본 인증 체크
///    - `redirectIfAuthenticated()` - Reverse guard (로그인 시 redirect)
///    - `isAuthenticated` - 인증 상태 확인
///    - `currentUserId` - 현재 사용자 ID
///
/// 2. **Redirect Location**:
///    - `_pendingRedirectLocation` - 인증 실패 시 경로 자동 저장
///    - 로그인 성공 후 원래 페이지로 자동 복귀
///    - `getPendingRedirectLocation()` - 저장된 경로 확인
///    - `clearRedirectLocation()` - 수동 클리어
///
/// 3. **Role-based Authorization**:
///    - `getCurrentUserRole()` - Firestore에서 사용자 역할 조회
///    - `hasRole()` - 특정 역할 보유 확인 (admin 자동 모든 권한)
///    - `hasAnyRole()` - 여러 역할 중 하나라도 보유 (OR)
///    - `hasAllRoles()` - 모든 역할 보유 (AND)
///
/// 4. **Guard Composition**:
///    - `checkAuthWithCondition()` - Auth + 커스텀 조건
///    - `composeGuardsAnd()` - 여러 Guard AND 조합
///    - `composeGuardsOr()` - 여러 Guard OR 조합
///
/// **설계 결정**:
/// - 정적 메서드 사용 (Singleton 불필요)
/// - Firebase Auth 직접 확인 (Riverpod 의존성 제거)
/// - 간단한 API (requireAuth 플래그 기반)
/// - Role 체크는 비동기 (Widget level FutureBuilder)
/// - Guard Composition은 동기 (redirect 콜백 호환)
class AuthGuard {
  /// Private constructor (정적 메서드만 사용)
  AuthGuard._();

  /// Phase 5: Guard Analytics Service
  static final GuardAnalyticsService _analytics = GuardAnalyticsService();

  /// 인증 실패 시 접근하려던 경로 저장 (로그인 후 복귀용)
  ///
  /// **Phase 4 기능**:
  /// - 인증 필요 페이지 접근 시도 → 로그인 페이지로 리디렉션 → 원래 경로 저장
  /// - 로그인 성공 → 저장된 경로로 자동 복귀
  /// - 예: /profile 접근 → 로그인 → /profile 복귀
  static String? _pendingRedirectLocation;

  /// 인증 상태 확인 및 redirect 결정
  ///
  /// **동작**:
  /// 1. requireAuth가 false면 → null (redirect 없음)
  /// 2. requireAuth가 true이고 로그인 안 됨 → '/startPage' (원래 경로 저장)
  /// 3. requireAuth가 true이고 로그인 됨 → null (정상 진입)
  ///
  /// **Phase 4: Redirect Location 저장**:
  /// - 인증 실패 시 원래 접근하려던 경로를 _pendingRedirectLocation에 저장
  /// - 로그인 성공 후 저장된 경로로 자동 복귀
  /// - 예: /profile 접근 → 로그인 필요 → /startPage + 경로 저장 → 로그인 → /profile 복귀
  ///
  /// **사용 예시**:
  /// ```dart
  /// GoRoute(
  ///   path: '/profile',
  ///   redirect: (context, state) => AuthGuard.checkAuth(
  ///     requireAuth: true,
  ///     state: state,
  ///   ),
  ///   builder: (context, state) => ProfilePage(),
  /// )
  /// ```
  ///
  /// **파라미터**:
  /// - [requireAuth]: 인증 필요 여부 (true = 로그인 필수)
  /// - [state]: GoRouterState (현재 route 정보)
  ///
  /// **반환값**:
  /// - String: redirect할 경로 (로그인 페이지)
  /// - null: redirect 불필요 (정상 진입)
  static String? checkAuth({
    required bool requireAuth,
    required GoRouterState state,
  }) {
    final currentPath = state.uri.toString();
    final user = FirebaseAuth.instance.currentUser;

    // Public route면 통과
    if (!requireAuth) {
      // Phase 5: Analytics - Public 라우트 허용
      _analytics.logGuardCheck(
        attemptedPath: currentPath,
        redirectPath: null,
        result: GuardResult.allowed,
        userId: user?.uid,
        reason: 'public_route',
      );
      return null;
    }

    // Auth required - Firebase Auth 확인
    if (user == null) {
      // 로그인 안 됨 → startPage로 redirect
      // Phase 4: redirectLocation 저장 (로그인 후 복귀)

      // 로그인 페이지나 시작 페이지는 저장하지 않음 (무한 루프 방지)
      if (!currentPath.contains('/startPage') &&
          !currentPath.contains('/loginPage') &&
          !currentPath.contains('/createAccount')) {
        _pendingRedirectLocation = currentPath;
      }

      // Phase 5: Analytics - 차단됨 (인증 필요)
      _analytics.logGuardCheck(
        attemptedPath: currentPath,
        redirectPath: '/startPage',
        result: GuardResult.blocked,
        userId: null,
        reason: 'auth_required',
      );

      return '/startPage';
    }

    // 로그인 됨 → 정상 진입
    // Phase 5: Analytics - 허용됨 (인증 완료)
    _analytics.logGuardCheck(
      attemptedPath: currentPath,
      redirectPath: null,
      result: GuardResult.allowed,
      userId: user.uid,
      reason: 'authenticated',
    );
    return null;
  }

  /// 현재 사용자 인증 여부 확인
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (AuthGuard.isAuthenticated) {
  ///   // 로그인 됨
  /// } else {
  ///   // 로그인 안 됨
  /// }
  /// ```
  static bool get isAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  /// 현재 사용자 ID 가져오기
  ///
  /// **반환값**:
  /// - String: 사용자 UID
  /// - null: 로그인 안 됨
  static String? get currentUserId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  /// 로그인 되어 있으면 home으로 redirect (Reverse Guard)
  ///
  /// **동작**:
  /// - 로그인 안 됨 → null (현재 페이지 유지)
  /// - 로그인 됨 → 저장된 redirectLocation 또는 '/home' (메인 페이지로 redirect)
  ///
  /// **Phase 4: Redirect Location 복원**:
  /// - checkAuth()에서 저장한 _pendingRedirectLocation이 있으면 그곳으로 복귀
  /// - 없으면 기본값 redirectTo ('/home')로 이동
  /// - 예: /profile 시도 → 로그인 페이지 → 로그인 성공 → /profile 복귀
  ///
  /// **사용 예시**:
  /// ```dart
  /// GoRoute(
  ///   path: '/',
  ///   redirect: (context, state) => AuthGuard.redirectIfAuthenticated(),
  ///   builder: (context, state) => StartPageWidget(),
  /// )
  /// ```
  ///
  /// **사용 케이스**:
  /// - 로그인 페이지 (이미 로그인 되어 있으면 home 또는 저장된 경로로)
  /// - 시작 페이지 (로그인 되어 있으면 home 또는 저장된 경로로)
  static String? redirectIfAuthenticated({String redirectTo = '/home'}) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 로그인 됨 → 저장된 경로 또는 기본 경로로 redirect
      // Phase 4: 저장된 redirectLocation 우선 사용
      final destination = _pendingRedirectLocation ?? redirectTo;

      // redirectLocation 사용 후 클리어 (재사용 방지)
      if (_pendingRedirectLocation != null) {
        clearRedirectLocation();
      }

      return destination;
    }

    // 로그인 안 됨 → 현재 페이지 유지
    return null;
  }

  /// 저장된 redirect location 정보 확인
  ///
  /// **사용 예시**:
  /// ```dart
  /// final pendingRoute = AuthGuard.getPendingRedirectLocation();
  /// if (pendingRoute != null) {
  ///   print('로그인 후 복귀할 경로: $pendingRoute');
  /// }
  /// ```
  static String? getPendingRedirectLocation() {
    return _pendingRedirectLocation;
  }

  /// 저장된 redirect location 클리어
  ///
  /// **사용 예시**:
  /// - 로그인 성공 후 자동 호출됨 (redirectIfAuthenticated 내부)
  /// - 수동으로 클리어 필요 시: `AuthGuard.clearRedirectLocation()`
  static void clearRedirectLocation() {
    _pendingRedirectLocation = null;
  }

  // ============================================================================
  // Phase 4: Role-based Guard 패턴
  // ============================================================================
  // Phase C-3: Deprecated 메서드 제거 완료 (2025-11-11)
  // 역할 기반 인증은 이제 userRoleProvider 사용:
  // - lib/features/profile/presentation/providers/usecase_providers.dart

  // ============================================================================
  // Phase 4: Custom Guard Composition 패턴
  // ============================================================================

  /// Auth 체크 + 커스텀 조건 조합 (동기)
  ///
  /// **Phase 4 기능: Guard Composition**
  ///
  /// **동작**:
  /// 1. 먼저 requireAuth 체크 (로그인 필요 시)
  /// 2. 통과하면 커스텀 조건 체크
  /// 3. 모두 통과하면 null (정상 진입), 실패하면 redirect 경로 반환
  ///
  /// **사용 예시**:
  /// ```dart
  /// GoRoute(
  ///   path: '/settings',
  ///   redirect: (context, state) => AuthGuard.checkAuthWithCondition(
  ///     requireAuth: true,
  ///     state: state,
  ///     customCheck: (context, state) {
  ///       // 예: 프로필이 완성된 사용자만 접근 가능
  ///       final hasProfile = ...;
  ///       return hasProfile ? null : '/complete-profile';
  ///     },
  ///   ),
  /// )
  /// ```
  ///
  /// **파라미터**:
  /// - [requireAuth]: 인증 필요 여부
  /// - [state]: GoRouterState
  /// - [customCheck]: 커스텀 Guard 함수 (통과하면 null, 실패하면 redirect 경로)
  ///
  /// **반환값**:
  /// - String: redirect 경로 (auth 실패 또는 customCheck 실패)
  /// - null: 모든 조건 통과
  static String? checkAuthWithCondition({
    required bool requireAuth,
    required GoRouterState state,
    String? Function(GoRouterState)? customCheck,
  }) {
    // 1단계: Auth 체크
    final authResult = checkAuth(requireAuth: requireAuth, state: state);
    if (authResult != null) {
      // Auth 실패 → auth redirect 반환
      return authResult;
    }

    // 2단계: 커스텀 조건 체크
    if (customCheck != null) {
      final customResult = customCheck(state);
      if (customResult != null) {
        // 커스텀 조건 실패 → custom redirect 반환
        return customResult;
      }
    }

    // 모든 조건 통과
    return null;
  }

  /// 여러 Guard 조건을 AND로 조합 (모두 통과해야 함)
  ///
  /// **Phase 4 기능: Multi-Guard Composition (AND)**
  ///
  /// **동작**:
  /// - 제공된 Guard 함수들을 순차적으로 실행
  /// - 하나라도 실패하면 즉시 그 redirect 반환
  /// - 모두 통과하면 null
  ///
  /// **사용 예시**:
  /// ```dart
  /// GoRoute(
  ///   path: '/admin-settings',
  ///   redirect: (context, state) => AuthGuard.composeGuardsAnd(
  ///     state: state,
  ///     guards: [
  ///       // Guard 1: 로그인 필요
  ///       (state) => AuthGuard.checkAuth(requireAuth: true, state: state),
  ///       // Guard 2: 프로필 완성 필요
  ///       (state) => hasProfile ? null : '/complete-profile',
  ///       // Guard 3: 이메일 인증 필요
  ///       (state) => emailVerified ? null : '/verify-email',
  ///     ],
  ///   ),
  /// )
  /// ```
  ///
  /// **파라미터**:
  /// - [state]: GoRouterState
  /// - [guards]: Guard 함수 리스트 (순차 실행)
  ///
  /// **반환값**:
  /// - String: 첫 번째 실패한 Guard의 redirect
  /// - null: 모든 Guard 통과
  static String? composeGuardsAnd({
    required GoRouterState state,
    required List<String? Function(GoRouterState)> guards,
  }) {
    for (final guard in guards) {
      final result = guard(state);
      if (result != null) {
        // 첫 번째 실패 → 즉시 반환
        return result;
      }
    }

    // 모든 Guard 통과
    return null;
  }

  /// 여러 Guard 조건을 OR로 조합 (하나라도 통과하면 됨)
  ///
  /// **Phase 4 기능: Multi-Guard Composition (OR)**
  ///
  /// **동작**:
  /// - 제공된 Guard 함수들을 순차적으로 실행
  /// - 하나라도 통과하면 즉시 null 반환
  /// - 모두 실패하면 마지막 Guard의 redirect 반환
  ///
  /// **사용 예시**:
  /// ```dart
  /// GoRoute(
  ///   path: '/premium-content',
  ///   redirect: (context, state) => AuthGuard.composeGuardsOr(
  ///     state: state,
  ///     guards: [
  ///       // Guard 1: Admin이면 무조건 통과
  ///       (state) => isAdmin ? null : '/unauthorized',
  ///       // Guard 2: Premium 구독자도 통과
  ///       (state) => isPremium ? null : '/subscribe',
  ///       // Guard 3: Trial 기간이면 통과
  ///       (state) => isTrialActive ? null : '/trial-expired',
  ///     ],
  ///     fallbackRedirect: '/unauthorized',
  ///   ),
  /// )
  /// ```
  ///
  /// **파라미터**:
  /// - [state]: GoRouterState
  /// - [guards]: Guard 함수 리스트 (순차 실행)
  /// - [fallbackRedirect]: 모든 Guard 실패 시 기본 redirect (기본값: '/unauthorized')
  ///
  /// **반환값**:
  /// - null: 하나라도 Guard 통과
  /// - String: 모든 Guard 실패 시 fallbackRedirect
  static String? composeGuardsOr({
    required GoRouterState state,
    required List<String? Function(GoRouterState)> guards,
    String fallbackRedirect = '/unauthorized',
  }) {
    for (final guard in guards) {
      final result = guard(state);
      if (result == null) {
        // 하나라도 통과 → 즉시 null 반환
        return null;
      }
    }

    // 모든 Guard 실패 → fallback redirect
    return fallbackRedirect;
  }
}
