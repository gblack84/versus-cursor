# 🚀 Versus Space Router 시스템 완벽 가이드

> Flutter GoRouter 기반 라우팅 + AuthGuard 인증 + Phase 5 Guard Analytics 통합 시스템

## 📚 목차

- [개요](#-개요)
- [전체 아키텍처](#-전체-아키텍처)
- [BOUNDARIES - 아키텍처 경계](#-boundaries---router-시스템-아키텍처-경계)
- [디렉토리 구조](#-디렉토리-구조)
- [Guards 시스템](#-guards-시스템)
- [Navigation 시스템](#-navigation-시스템)
- [Feature Routes 패턴](#-feature-routes-패턴)
- [실전 사용 패턴](#-실전-사용-패턴)
- [Phase 5 Guard Analytics](#-phase-5-guard-analytics)
- [아키텍처 결정 (ADR)](#-아키텍처-결정-adr)
- [마이그레이션 가이드](#-마이그레이션-가이드)
- [트러블슈팅](#-트러블슈팅)
- [성능 최적화](#-성능-최적화)
- [참조 문서](#-참조-문서)

---

## 🎯 개요

**Versus Space Router**는 Flutter 앱의 모든 라우팅, 인증, 권한 관리, 내비게이션 상태, 그리고 분석을 통합 관리하는 핵심 시스템입니다.

### 핵심 특징

- 🛡️ **AuthGuard**: Static 메서드 기반 인증 가드 (Phase 1-4 완료)
- 📊 **Guard Analytics**: Firestore 기반 실시간 라우트 체크 로깅 (Phase 5 완료)
- 📦 **NavigationNotifier**: Riverpod 3.x 상태 관리
- 🎯 **Feature Routes**: Feature별 독립 라우트 모듈화
- 🚀 **GoRouter**: Flutter 공식 선언적 라우팅
- 🔄 **실시간 동기화**: Firebase Auth + Firestore
- ⚡ **고성능**: <5ms 인증 체크, <10ms 파라미터 직렬화

### 버전 정보

- **Router 시스템**: v3.0.0 (2025-11-10)
- **AuthGuard**: Phase 5 완료 (Guard Analytics 통합)
- **Navigation**: Riverpod 3.x 마이그레이션 완료
- **Feature Routes**: 모듈화 패턴 확립

---

## 🏗 전체 아키텍처

### 시스템 구조도

```
┌─────────────────────────────────────────────────────────────────────┐
│                         Flutter Application                         │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────────┐
│                          GoRouter (Entry)                           │
│  • initialLocation: '/'                                             │
│  • redirect: AuthGuard.checkAuth (전역 인증 체크)                   │
│  • refreshListenable: NavigationNotifier (Riverpod 3.x)            │
│  • routes: Feature Routes 병합                                      │
└──────────────────┬──────────────────────────────────────────────────┘
                   │
    ┌──────────────┴───────────────┬───────────────────┐
    ▼                              ▼                   ▼
┌─────────────────┐    ┌─────────────────────┐   ┌─────────────────────┐
│  Guards System  │    │ Navigation System   │   │  Feature Routes     │
│                 │    │                     │   │  (7/8 완료)         │
│ • AuthGuard     │    │ • NavigationState   │   │ • AuthRoutes (5)    │
│ • checkAuth     │    │ • NavigationNotifier│   │ • ProfileRoutes (3) │
│ • redirectIf... │    │ • Serialization     │   │ • ChatRoutes (4)    │
│ • checkRole     │    │ • TransitionInfo    │   │ • CreationRoutes (2)│
│ • compose       │    │                     │   │ • NotificationRoutes│
│                 │    │                     │   │   (4)               │
│ Phase 5:        │    │ Riverpod 3.x:       │   │ • PostRoutes (3)    │
│ • GuardAnalytics│    │ • StateNotifier     │   │ • SearchRoutes (0)  │
│   Service       │    │ • Freezed State     │   │                     │
│ • Firestore Log │    │ • ref.watch()       │   │ Feature-First:      │
│                 │    │                     │   │ • Modular           │
│                 │    │                     │   │ • Independent       │
│                 │    │                     │   │ • Testable          │
└────────┬────────┘    └─────────┬───────────┘   └────────┬────────┘
         │                       │                        │
         ▼                       ▼                        ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Firebase Backend                             │
│  • Firestore: guard_analytics 컬렉션 (Phase 5)                      │
│  • Auth: 사용자 인증 상태                                             │
│  • Security Rules: 접근 제어                                         │
└─────────────────────────────────────────────────────────────────────┘
```

### 데이터 흐름

```
[사용자 액션: 페이지 이동 /profile/edit]
         ↓
[GoRouter redirect 콜백 실행]
         ↓
[AuthGuard.checkAuth(currentPath: '/profile/edit') 호출]
         ↓
    ┌────────────────────────────────┐
    │ 1. Firebase Auth 상태 확인     │
    │    - currentUser != null?      │
    └────────────┬───────────────────┘
                 │
    ┌────────────┴─────────────┐
    │                          │
    ▼ (인증됨)                 ▼ (미인증)
┌──────────────────┐     ┌────────────────────────┐
│ 2. Guard         │     │ 2. Redirect Location   │
│    Analytics:    │     │    저장:               │
│    - result:     │     │    - NavigationNotifier│
│      'allowed'   │     │      .setRedirect      │
│    - reason:     │     │      Location(...)     │
│      'auth..'    │     │                        │
│    - userId: uid │     │ 3. Guard Analytics:    │
│                  │     │    - result: 'blocked' │
│ 3. 페이지 렌더링 │     │    - reason: 'auth_req'│
│    (/profile/    │     │    - userId: null      │
│     edit)        │     │                        │
│                  │     │ 4. /startPage로 리다이렉션│
└──────────────────┘     └────────────────────────┘
         │                          │
         │                          │ (로그인 성공 후)
         │                          ▼
         │              ┌────────────────────────┐
         │              │ 5. Redirect Location   │
         │              │    확인 및 자동 이동   │
         │              │    - /profile/edit로   │
         │              │                        │
         │              │ 6. Guard Analytics:    │
         │              │    - result: 'allowed' │
         │              │    - reason: 'auth..'  │
         │              └────────────────────────┘
         │                          │
         └──────────────────────────┘
                   ▼
    [NavigationNotifier 상태 업데이트]
                   ↓
         [UI 자동 리빌드 (ref.watch)]
```

---

## 🏛️ BOUNDARIES - Router 시스템 아키텍처 경계

### Router 시스템의 위치

**Clean Architecture 레이어**: Presentation Layer (App Layer의 일부)
**역할**: 라우팅, 인증 가드, 내비게이션 상태 관리

### 의존성 규칙

#### ✅ 허용되는 의존성

**1. Feature Routes (각 Feature의 Presentation Layer)**
```dart
// Feature Routes import
import '/features/auth/presentation/routes/auth_routes.dart';
import '/features/profile/presentation/routes/profile_routes.dart';
import '/features/chat/presentation/routes/chat_routes.dart';

// Routes 병합
final routes = [
  ...AuthRoutes.routes,
  ...ProfileRoutes.routes,
  ...ChatRoutes.routes,
];
```

**2. AuthGuard (Static 메서드 → Firebase Auth 직접 접근 허용)**
```dart
// GoRouter 기술적 제약으로 Firebase Auth 직접 사용 허용
static bool isAuthenticated() {
  return FirebaseAuth.instance.currentUser != null;
}

static String? getUserId() {
  return FirebaseAuth.instance.currentUser?.uid;
}
```

**허용 근거**:
- GoRouter의 `redirect` 콜백은 **static 메서드** 또는 **top-level 함수**만 허용
- Riverpod Provider를 사용할 수 없는 기술적 제약
- Firebase Auth는 **Infrastructure 관리** 목적 (인증 상태 확인)

**3. NavigationNotifier (Riverpod 상태 관리)**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/navigation_state.dart';

@riverpod
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavigationState build() => const NavigationState();
}
```

**4. Core Layer 공통 요소**
```dart
import '/core/utils/serialization_util.dart';
import '/core/constants/app_constants.dart';
```

#### ❌ 금지되는 의존성

**1. Domain/Data Layer 직접 import**
```dart
// ❌ 금지 - Repository 직접 import
import '/features/profile/data/repositories/profile_repository_impl.dart';

// ❌ 금지 - UseCase 직접 import
import '/features/auth/domain/usecases/sign_in_usecase.dart';
```

**2. 비즈니스 로직을 위한 Firestore 직접 쿼리**
```dart
// ❌ 금지 - AuthGuard에서 Firestore로 역할 체크
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(uid)
    .get();
final role = userDoc.data()?['role'] as String?;

// ✅ 올바른 방법 (Phase C-1으로 해결됨)
// Domain Layer Extension 사용
import '/features/profile/domain/entities/user_profile_business.dart';
final profile = await getUserProfile(uid);
final role = profile.getRole();
```

### Feature Routes 경계

**Feature Routes는 각 Feature 내부에 위치**:

**위치 규칙**:
- 경로: `/features/*/presentation/routes/`
- 명명: `*_routes.dart` (예: auth_routes.dart)
- 패턴: `static List<RouteBase> get routes` 노출

**의존성 규칙**:
- ✅ **허용**: 해당 Feature Presentation Layer만 (Screens, Widgets)
- ❌ **금지**: 다른 Feature Routes 직접 의존
- ❌ **금지**: Domain/Data Layer 직접 import

**예시**:
```dart
// lib/features/auth/presentation/routes/auth_routes.dart

import '/features/auth/presentation/screens/start_page.dart';
import '/features/auth/presentation/screens/sign_in_page.dart';

class AuthRoutes {
  static const String startPage = 'startPage';
  static const String signInPage = 'signInPage';

  static List<RouteBase> get routes => [
    GoRoute(
      name: startPage,
      path: '/start',
      builder: (context, state) => const StartPageWidget(),
    ),
    GoRoute(
      name: signInPage,
      path: '/signIn',
      builder: (context, state) => const SignInPageWidget(),
    ),
  ];
}
```

### Router 시스템 책임 범위

**Router 시스템이 담당하는 것**:
- ✅ 라우팅 (페이지 전환, 파라미터 전달)
- ✅ 인증 체크 (AuthGuard - Firebase Auth 상태 확인)
- ✅ 내비게이션 상태 관리 (NavigationNotifier)
- ✅ Guard Analytics (Phase 5 - Firestore 로깅)

**Router 시스템이 담당하지 않는 것**:
- ❌ 비즈니스 로직 (UseCase 사용)
- ❌ 데이터 조회 (Repository 사용)
- ❌ 상태 관리 (Feature별 Provider 사용)

### 참고 문서

- **전체 아키텍처**: [CLAUDE.md - BOUNDARIES 섹션](../../../CLAUDE.md#boundaries)
- **App Layer 경계**: [lib/app/README.md - BOUNDARIES](../README.md#boundaries)
- **Feature별 경계**: 각 Feature의 README.md 참조

---

## 📁 디렉토리 구조

```
/lib/app/router/
├── guards/                             # 🛡️ 인증 및 권한 가드
│   ├── auth_guard.dart                 # AuthGuard (584줄) - Phase 1-5 완료
│   └── README.md                       # Guards 시스템 완벽 가이드 (800+ 줄)
│
├── navigation/                         # 📦 내비게이션 상태 관리
│   ├── navigation_state.dart          # Freezed NavigationState (120줄)
│   ├── navigation_state.freezed.dart  # Generated (277줄)
│   ├── navigation_notifier.dart       # Riverpod 3.x StateNotifier (108줄)
│   ├── nav.dart                       # GoRouter 설정 (428줄)
│   ├── serialization_util.dart        # 파라미터 직렬화 (256줄)
│   └── README.md                       # Navigation 시스템 가이드 (1,280줄)
│
├── (Feature Routes는 각 Feature 내부에 위치)  # ✅ Phase 1-3 완료
│   # /features/auth/presentation/routes/auth_routes.dart
│   # /features/profile/presentation/routes/profile_routes.dart
│   # /features/chat/presentation/routes/chat_routes.dart
│   # /features/creation/presentation/routes/creation_routes.dart
│   # /features/notifications/presentation/routes/notification_routes.dart
│   # /features/post/presentation/routes/post_routes.dart
│   # /features/search/presentation/routes/search_routes.dart
│
├── ISSUES_ANALYSIS.md                 # Router 시스템 이슈 분석 (1,805줄)
└── README.md                          # ← 이 문서 (통합 가이드)
```

### 파일별 역할

| 파일 | 역할 | 라인 수 | 상태 |
|------|------|---------|------|
| **auth_guard.dart** | 인증/권한 체크, Phase 5 Analytics 통합 | 584 | ✅ 완료 |
| **navigation_state.dart** | Freezed 불변 상태 정의 | 120 | ✅ 완료 |
| **navigation_notifier.dart** | Riverpod 3.x 상태 관리 | 108 | ✅ 완료 |
| **nav.dart** | GoRouter 설정 및 라우트 정의 | 428 | ✅ 완료 |
| **serialization_util.dart** | URL 파라미터 직렬화 | 256 | ✅ 완료 |
| **guards/README.md** | Guards 시스템 완벽 가이드 | 800+ | ✅ 완료 |
| **navigation/README.md** | Navigation 시스템 가이드 | 1,280 | ✅ 완료 |
| **ISSUES_ANALYSIS.md** | Router 이슈 분석 문서 | 1,805 | ✅ 완료 |
| **Feature Routes** | 각 Feature 내부 routes 파일 (7개) | ~700 | ✅ Phase 1-3 완료 |
| - auth_routes.dart | Auth Feature 라우트 (5개) | ~150 | ✅ |
| - profile_routes.dart | Profile Feature 라우트 (3개) | ~100 | ✅ |
| - chat_routes.dart | Chat Feature 라우트 (4개) | ~120 | ✅ |
| - creation_routes.dart | Creation Feature 라우트 (2개) | ~98 | ✅ |
| - notification_routes.dart | Notification Feature 라우트 (4개) | ~98 | ✅ |
| - post_routes.dart | Post Feature 라우트 (3개) | ~89 | ✅ |
| - search_routes.dart | Search Feature 라우트 (0개, 준비) | ~60 | ✅ |

**총 라인 수**: ~5,300줄 (코드 + 문서 + Feature Routes)

---

## 🛡 Guards 시스템

### AuthGuard 개요

**AuthGuard**는 Static 메서드 기반의 인증 가드로, GoRouter의 redirect 콜백에서 호출되어 인증과 권한을 체크합니다.

**Phase 완성도**:
- ✅ **Core**: 기본 인증 체크 (checkAuth, redirectIfAuthenticated)
- ✅ **Phase 4**: Redirect Location 관리 + Role-based Authorization + Guard Composition
- ✅ **Phase 5**: Guard Analytics (Firestore 로깅)

### 주요 API

#### 1. checkAuth - 기본 인증 체크

```dart
/// 인증 상태 확인 및 redirect 결정
///
/// [Parameters]
/// - requireAuth: 인증 필요 여부 (true = 로그인 필수)
/// - state: GoRouterState (현재 route 정보)
///
/// [Returns]
/// - null: redirect 불필요 (정상 진입)
/// - String: redirect할 경로 ('/startPage')
static String? checkAuth({
  required bool requireAuth,
  required GoRouterState state,
}) {
  final currentPath = state.uri.toString();
  final user = FirebaseAuth.instance.currentUser;

  // Public route면 통과
  if (!requireAuth) {
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
    if (!currentPath.contains('/startPage') &&
        !currentPath.contains('/loginPage') &&
        !currentPath.contains('/createAccount')) {
      _pendingRedirectLocation = currentPath;
    }

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
  _analytics.logGuardCheck(
    attemptedPath: currentPath,
    redirectPath: null,
    result: GuardResult.allowed,
    userId: user.uid,
    reason: 'authenticated',
  );
  return null;
}
```

**사용 예시**:
```dart
// Public route (requireAuth: false)
GoRoute(
  path: '/startPage',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: false,
    state: state,
  ),
  builder: (context, state) => StartPageWidget(),
),

// Protected route (requireAuth: true)
GoRoute(
  path: '/profile',
  redirect: (context, state) => AuthGuard.checkAuth(
    requireAuth: true,
    state: state,
  ),
  builder: (context, state) => ProfilePage(),
),
```

---

#### 2. redirectIfAuthenticated - Reverse Guard (로그인 페이지 보호)

```dart
/// 로그인 되어 있으면 home으로 redirect
///
/// [Parameters]
/// - redirectTo: 기본 리다이렉트 경로 (기본값: '/home')
///
/// [Returns]
/// - null: 미로그인 상태 (현재 페이지 유지)
/// - String: 로그인됨 → 저장된 경로 또는 기본 경로로 redirect
static String? redirectIfAuthenticated({String redirectTo = '/home'}) {
  final user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    // 로그인 됨 → 저장된 경로 또는 기본 경로로 redirect
    final destination = _pendingRedirectLocation ?? redirectTo;

    // redirectLocation 사용 후 클리어
    if (_pendingRedirectLocation != null) {
      clearRedirectLocation();
    }

    return destination;
  }

  // 로그인 안 됨 → 현재 페이지 유지
  return null;
}
```

**사용 예시**:
```dart
GoRoute(
  path: '/startPage',
  redirect: (context, state) => AuthGuard.redirectIfAuthenticated(),
  builder: (context, state) => StartPageWidget(),
),
```

**시나리오**:
1. 사용자가 `/profile` 접근 시도 (미로그인)
2. checkAuth가 `/startPage`로 redirect + 경로 저장 (`_pendingRedirectLocation = '/profile'`)
3. 사용자 로그인 성공
4. redirectIfAuthenticated가 저장된 `/profile`로 복귀

---

#### 3. Role-based Authorization (Phase 4) - 비동기 메서드

**주의**: 역할 체크는 비동기 메서드로, redirect 콜백에서 직접 사용 불가능합니다.
**사용처**: Widget-level에서 FutureBuilder로 사용하세요.

```dart
/// 현재 사용자의 역할(role) 가져오기
///
/// [Returns]
/// - UserRole: admin, tester, user
/// - null: 로그인 안 됨 또는 프로필 없음
static Future<UserRole?> getCurrentUserRole() async {
  // Firestore에서 UserProfile 조회하여 role 필드 파싱
}

/// 특정 역할 보유 여부 확인
///
/// [Parameters]
/// - requiredRole: 필요한 역할 (UserRole.admin, UserRole.tester, etc.)
///
/// [Returns]
/// - true: 필요한 역할 보유 (admin은 모든 권한 자동 보유)
/// - false: 권한 없음
static Future<bool> hasRole(UserRole requiredRole) async { ... }

/// 여러 역할 중 하나라도 보유 여부 (OR)
static Future<bool> hasAnyRole(List<UserRole> requiredRoles) async { ... }

/// 모든 역할 보유 여부 (AND)
static Future<bool> hasAllRoles(List<UserRole> requiredRoles) async { ... }
```

**사용 예시** (Widget-level):
```dart
// Admin 페이지 보호
class AdminPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthGuard.hasRole(UserRole.admin),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (!snapshot.data!) {
          return UnauthorizedPage(); // 403 Forbidden
        }

        return AdminDashboard();
      },
    );
  }
}

// Admin 또는 Tester만 접근 가능
future: AuthGuard.hasAnyRole([UserRole.admin, UserRole.tester]),
```

---

#### 4. Guard Composition (Phase 4)

```dart
/// Auth 체크 + 커스텀 조건 조합 (동기)
///
/// [Parameters]
/// - requireAuth: 인증 필요 여부
/// - state: GoRouterState
/// - customCheck: 커스텀 Guard 함수 (통과하면 null, 실패하면 redirect 경로)
///
/// [Returns]
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
    return authResult; // Auth 실패
  }

  // 2단계: 커스텀 조건 체크
  if (customCheck != null) {
    final customResult = customCheck(state);
    if (customResult != null) {
      return customResult; // 커스텀 조건 실패
    }
  }

  // 모든 조건 통과
  return null;
}
```

**사용 예시**:
```dart
GoRoute(
  path: '/settings',
  redirect: (context, state) => AuthGuard.checkAuthWithCondition(
    requireAuth: true,
    state: state,
    customCheck: (state) {
      // 예: 프로필이 완성된 사용자만 접근 가능
      final hasProfile = ...;
      return hasProfile ? null : '/complete-profile';
    },
  ),
)
```

---

#### 5. composeGuardsAnd - 여러 Guard AND 조합

```dart
/// 여러 Guard 조건을 AND로 조합 (모두 통과해야 함)
///
/// [Parameters]
/// - state: GoRouterState
/// - guards: Guard 함수 리스트 (순차 실행)
///
/// [Returns]
/// - String: 첫 번째 실패한 Guard의 redirect
/// - null: 모든 Guard 통과
static String? composeGuardsAnd({
  required GoRouterState state,
  required List<String? Function(GoRouterState)> guards,
}) {
  for (final guard in guards) {
    final result = guard(state);
    if (result != null) {
      return result; // 첫 번째 실패 → 즉시 반환
    }
  }
  return null; // 모든 Guard 통과
}
```

**사용 예시**:
```dart
GoRoute(
  path: '/admin-settings',
  redirect: (context, state) => AuthGuard.composeGuardsAnd(
    state: state,
    guards: [
      // Guard 1: 로그인 필요
      (state) => AuthGuard.checkAuth(requireAuth: true, state: state),
      // Guard 2: 프로필 완성 필요
      (state) => hasProfile ? null : '/complete-profile',
      // Guard 3: 이메일 인증 필요
      (state) => emailVerified ? null : '/verify-email',
    ],
  ),
)
```

---

#### 6. composeGuardsOr - 여러 Guard OR 조합

```dart
/// 여러 Guard 조건을 OR로 조합 (하나라도 통과하면 됨)
///
/// [Parameters]
/// - state: GoRouterState
/// - guards: Guard 함수 리스트 (순차 실행)
/// - fallbackRedirect: 모든 Guard 실패 시 기본 redirect (기본값: '/unauthorized')
///
/// [Returns]
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
      return null; // 하나라도 통과 → 즉시 null 반환
    }
  }
  return fallbackRedirect; // 모든 Guard 실패
}
```

**사용 예시**:
```dart
GoRoute(
  path: '/premium-content',
  redirect: (context, state) => AuthGuard.composeGuardsOr(
    state: state,
    guards: [
      // Guard 1: Admin이면 무조건 통과
      (state) => isAdmin ? null : '/unauthorized',
      // Guard 2: Premium 구독자도 통과
      (state) => isPremium ? null : '/subscribe',
      // Guard 3: Trial 기간이면 통과
      (state) => isTrialActive ? null : '/trial-expired',
    ],
    fallbackRedirect: '/unauthorized',
  ),
)
```

---

### Redirect Location Management (Phase 4)

**문제**: 로그인 후 사용자가 원래 접근하려던 페이지로 자동 이동하지 못함

**해결책**: AuthGuard의 Static 필드 `_pendingRedirectLocation` 사용

```dart
// 1. checkAuth()가 자동으로 경로 저장
static String? checkAuth({
  required bool requireAuth,
  required GoRouterState state,
}) {
  // 로그인 필요한데 미인증이면
  if (requireAuth && user == null) {
    // 원래 접근하려던 경로 저장 (로그인/시작 페이지 제외)
    if (!currentPath.contains('/startPage') &&
        !currentPath.contains('/loginPage') &&
        !currentPath.contains('/createAccount')) {
      _pendingRedirectLocation = currentPath;
    }
    return '/startPage'; // 로그인 페이지로 redirect
  }
  ...
}

// 2. redirectIfAuthenticated()가 자동으로 복귀
static String? redirectIfAuthenticated({String redirectTo = '/home'}) {
  if (user != null) {
    // 저장된 경로 또는 기본 경로로 redirect
    final destination = _pendingRedirectLocation ?? redirectTo;

    // 사용 후 클리어
    if (_pendingRedirectLocation != null) {
      clearRedirectLocation();
    }

    return destination;
  }
  return null;
}

// 3. 수동 접근 메서드
static String? getPendingRedirectLocation() => _pendingRedirectLocation;
static void clearRedirectLocation() => _pendingRedirectLocation = null;
```

**시나리오**:
1. 사용자가 `/profile` 접근 시도 (미로그인)
2. checkAuth가 `/startPage`로 redirect + `_pendingRedirectLocation = '/profile'` 저장
3. 사용자가 로그인 성공
4. redirectIfAuthenticated가 저장된 `/profile`로 자동 복귀
5. `_pendingRedirectLocation` 자동 클리어

---

## 📦 Navigation 시스템

### NavigationState (Freezed)

**역할**: 앱 전체의 내비게이션 상태를 불변 데이터 클래스로 정의

```dart
@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required String currentPath,        // 현재 라우트 경로
    String? redirectLocation,           // 인증 후 이동 목표 경로
    required bool showSplashImage,      // 스플래시 화면 표시 여부
    @Default(true) bool notifyOnChange, // 상태 변경 알림 활성화
  }) = _NavigationState;

  factory NavigationState.fromJson(Map<String, dynamic> json) =>
      _$NavigationStateFromJson(json);
}
```

**특징**:
- Freezed의 `copyWith` 메서드로 불변 상태 업데이트
- JSON 직렬화 지원 (앱 재시작 후 상태 복원 가능)
- 타입 안전성 보장 (컴파일 타임 에러 검출)

---

### NavigationNotifier (Riverpod 3.x)

**역할**: NavigationState의 상태 변화를 관리하고 UI에 알림

```dart
class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(
    const NavigationState(
      currentPath: '/',
      redirectLocation: null,
      showSplashImage: true,
      notifyOnChange: true,
    ),
  );

  void updateCurrentPath(String path) {
    state = state.copyWith(currentPath: path);
  }

  void setRedirectLocation(String? location) {
    state = state.copyWith(redirectLocation: location);
  }

  void hideSplashImage() {
    state = state.copyWith(showSplashImage: false);
  }

  void toggleNotifyOnChange(bool value) {
    state = state.copyWith(notifyOnChange: value);
  }

  void reset() {
    state = const NavigationState(
      currentPath: '/',
      redirectLocation: null,
      showSplashImage: true,
      notifyOnChange: true,
    );
  }
}

// Riverpod Provider 등록
final navigationNotifierProvider = StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);
```

**사용 예시**:
```dart
// 위젯에서 상태 읽기
final navState = ref.watch(navigationNotifierProvider);
print('Current path: ${navState.currentPath}');

// 상태 업데이트
ref.read(navigationNotifierProvider.notifier).updateCurrentPath('/profile');

// 특정 필드만 감시 (최적화)
final currentPath = ref.watch(
  navigationNotifierProvider.select((state) => state.currentPath),
);
```

---

### Serialization (파라미터 직렬화)

**역할**: 복잡한 Dart 객체를 URL 파라미터로 직렬화/역직렬화

**지원 타입**:
- 기본 타입: `int`, `double`, `String`, `bool`
- 날짜/시간: `DateTime`, `DateTimeRange`
- Firebase: `DocumentReference`, `Document`
- JSON 객체

**예시**:
```dart
// DocumentReference 직렬화
final docRef = FirebaseFirestore.instance.doc('users/user123');
final serialized = serializeParam(docRef, ParamType.DocumentReference);
// → "users|user123"

// URL에 전달
context.pushNamed(
  'detailPage',
  queryParameters: {'docRef': serialized},
);

// 역직렬화
final restored = deserializeParam<DocumentReference>(
  state.queryParameters['docRef'],
  ParamType.DocumentReference,
  false,
);
// → FirebaseFirestore.instance.doc('users/user123')
```

---

## 🎯 Feature Routes 패턴

### 개념

**Feature Routes**는 각 Feature가 자체 라우트를 정의하고 관리하는 패턴입니다.

**Before (Monolithic - 428줄 nav.dart)**:
```dart
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
    // Profile routes
    GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    // ... 50+ more routes (모든 Feature가 섞여 있음)
  ],
);
```

**After (Feature-First - 100줄로 축소)**:
```dart
// /lib/features/auth/presentation/routes/auth_routes.dart
class AuthRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
  ];
}

// /lib/app/router/navigation/nav.dart
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    ...AuthRoutes.routes,        // Auth Feature
    ...ProfileRoutes.routes,     // Profile Feature
    ...ChatRoutes.routes,        // Chat Feature
    // ... (Feature별 라우트 병합)
  ],
);
```

### 장점

1. **Feature 독립성**: 각 Feature가 자체 라우트 관리
2. **코드 가독성**: 428줄 → 100줄 (76% 감소)
3. **병렬 개발**: Feature 팀이 독립적으로 작업 가능
4. **테스트 용이성**: Feature별 라우트만 테스트
5. **확장성**: 새 Feature 추가 시 기존 코드 수정 최소화

### 구현 현황 (Phase 1-3 완료)

**완료일**: 2025-11-10
**상태**: 7/8 Features 모듈화 완료

| Feature | Routes 파일 | Route 개수 | requireAuth | 상태 | Phase |
|---------|------------|-----------|-------------|------|-------|
| **Auth** | `/features/auth/presentation/routes/auth_routes.dart` | 5 | Mixed | ✅ 100% | Phase 0 (기존) |
| **Profile** | `/features/profile/presentation/routes/profile_routes.dart` | 3 | ✅ Yes | ✅ 100% | Phase 0 (기존) |
| **Chat** | `/features/chat/presentation/routes/chat_routes.dart` | 4 | ✅ Yes | ✅ 100% | Phase 0 (기존) |
| **Creation** | `/features/creation/presentation/routes/creation_routes.dart` | 2 | ❌ No (Public) | ✅ 100% | Phase 1.1 |
| **Notifications** | `/features/notifications/presentation/routes/notification_routes.dart` | 4 | ✅ Yes | ✅ 100% | Phase 1.2 |
| **Post** | `/features/post/presentation/routes/post_routes.dart` | 3 | ❌ No (Public) | ✅ 100% | Phase 2 |
| **Search** | `/features/search/presentation/routes/search_routes.dart` | 0 | N/A | ✅ 100% | Phase 3 |
| **Voting** | N/A (Dialog 패턴) | 0 | N/A | ✅ 예외 처리 | - |

**총 Routes**: 21개 (ShellRoute 5개 + Feature Routes 16개)

**Phase별 작업 내역**:
- **Phase 1.1** (2025-11-10): Creation routes에 `requireAuth: false` 명시
- **Phase 1.2** (2025-11-10): Notifications routes AppRoute 패턴 전환
- **Phase 2** (2025-11-10): Post routes 모듈화 (`post_routes.dart` 신규 생성)
- **Phase 3** (2025-11-10): Search routes 준비 (`search_routes.dart` 빈 리스트, 향후 확장 대비)

**특이사항**:
- **Voting Feature**: Dialog/Overlay 패턴 사용 (`showDialog()` 기반), 라우트 불필요
- **ShellRoute**: Bottom navigation 5개 탭 (Home, Search, CreatePost, Chat, Profile)은 nav.dart 내부 유지
- **Search Feature**: 현재 routes 비어있음 (SearchResultsWidget 구현 시 추가 예정)

### 구현 예시

**Profile Feature Routes**:
```dart
// /lib/features/profile/presentation/routes/profile_routes.dart
import 'package:go_router/go_router.dart';
import '../screens/profile_page.dart';
import '../screens/edit_profile_page.dart';
import '../screens/settings_page.dart';

class ProfileRoutes {
  // Route constants (타입 안전성)
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';

  // Route definitions
  static List<RouteBase> routes = [
    GoRoute(
      path: profile,
      name: 'profile',
      redirect: (context, state) {
        // AuthGuard 체크 (Phase 5 Guard Analytics 자동 기록)
        return AuthGuard.checkAuth(
          context: context,
          currentPath: state.uri.path,
        );
      },
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        return ProfilePage(userId: userId);
      },
      routes: [
        // Nested routes
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          redirect: (context, state) => AuthGuard.checkAuth(
            context: context,
            currentPath: state.uri.path,
          ),
          builder: (context, state) => EditProfilePage(),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          redirect: (context, state) => AuthGuard.checkAuth(
            context: context,
            currentPath: state.uri.path,
          ),
          builder: (context, state) => SettingsPage(),
        ),
      ],
    ),
  ];
}
```

**사용**:
```dart
// nav.dart에서 병합
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    ...ProfileRoutes.routes,
    // ... 다른 Feature Routes
  ],
);

// 위젯에서 사용
context.goNamed(ProfileRoutes.editProfile);
```

### 페이지 전환 애니메이션 제어

**개요**: 페이지 전환 시 애니메이션은 Feature Routes 파일에서 제어합니다.

**제어 위치**: 각 Feature의 `*_routes.dart` 파일

**현재 사용 패턴**:

| 패턴 | 사용처 | 애니메이션 | 이유 |
|------|--------|-----------|------|
| **즉시 전환** | Profile, Post, Chat, Creation, Notifications | None (Duration.zero) | 실용적 페이지 - 빠른 반응 |
| **Fade+Slide** | Auth (Login, StartPage) | 400ms | 진입 화면 - 세련된 느낌 |
| **Fade+Scale** | Voting Dialog | 250ms | 모달 - 팝업 효과 |
| **즉시 전환** | Bottom Navigation (ShellRoute) | None | Material Design 권장 |

**애니메이션 추가 방법**:

**옵션 1: AppRoute 패턴 (기본, 애니메이션 없음)**
```dart
// lib/features/profile/presentation/routes/profile_routes.dart
AppRoute(
  name: ProfileEditScreen.routeName,
  path: ProfileEditScreen.routePath,
  requireAuth: true,
  builder: (context, params) => ProfileEditScreen(),
).toRoute(ref)  // 즉시 전환 (Duration.zero)
```

**옵션 2: GoRoute + pageBuilder (커스텀 애니메이션)**
```dart
// lib/features/auth/presentation/routes/auth_routes.dart
GoRoute(
  name: LoginPageWidget.routeName,
  path: LoginPageWidget.routePath,
  pageBuilder: (context, state) => CustomTransitionPage(
    child: LoginPageWidget(),
    transitionDuration: Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      );
      return FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 0.15),  // 아래에서 15% 올라오기
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: child,
        ),
      );
    },
  ),
)
```

**애니메이션 타입**:

1. **Fade**: 부드러운 전환 (300ms)
   ```dart
   FadeTransition(opacity: animation, child: child)
   ```

2. **Slide**: 방향성 전환 (300ms)
   ```dart
   SlideTransition(
     position: Tween<Offset>(
       begin: Offset(1.0, 0.0),  // 오른쪽에서
       end: Offset.zero,
     ).animate(animation),
     child: child,
   )
   ```

3. **Fade + Slide**: 세련된 조합 (400ms)
   ```dart
   FadeTransition(
     opacity: animation,
     child: SlideTransition(...),
   )
   ```

4. **Scale + Fade**: Material 스타일 (250ms)
   ```dart
   FadeTransition(
     opacity: animation,
     child: ScaleTransition(
       scale: Tween<double>(begin: 0.9, end: 1.0).animate(animation),
       child: child,
     ),
   )
   ```

**권장사항**:
- **실용적 페이지** (Settings, Forms, List) → 애니메이션 없음
- **진입/종료 페이지** (Auth, Onboarding) → Fade+Slide (400ms)
- **Bottom Navigation** → 애니메이션 없음 (즉시성)
- **Modal/Dialog** → Fade+Scale (250ms)

---

## 💡 실전 사용 패턴

### 1. 기본 페이지 이동

```dart
// 일반 페이지 이동 (replace)
context.goNamed('home');

// 페이지 푸시 (스택에 추가)
context.pushNamed('chatDetail', pathParameters: {'chatId': chatId});

// 안전한 뒤로가기 (스택이 비면 홈으로)
context.safePop();
```

---

### 2. 인증이 필요한 페이지

```dart
// GoRouter 정의 시 redirect 콜백
GoRoute(
  path: '/profile/edit',
  redirect: (context, state) {
    // AuthGuard.checkAuth 호출
    return AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );
    // Phase 5 Guard Analytics 자동 기록:
    // - result: 'allowed' or 'blocked'
    // - reason: 'authenticated', 'auth_required', 'public_route'
  },
  builder: (context, state) => EditProfilePage(),
),
```

---

### 3. 역할 기반 권한이 필요한 페이지

```dart
// 관리자 전용 페이지
GoRoute(
  path: '/admin',
  redirect: (context, state) => AuthGuard.checkRole(
    context: context,
    currentPath: state.uri.path,
    requiredRoles: ['admin'],
  ),
  builder: (context, state) => AdminPage(),
),

// 관리자 또는 테스터 (OR 조합)
GoRoute(
  path: '/debug',
  redirect: (context, state) => AuthGuard.compose(
    guards: [
      () => AuthGuard.checkRole(
        context: context,
        currentPath: state.uri.path,
        requiredRoles: ['admin'],
      ),
      () => AuthGuard.checkRole(
        context: context,
        currentPath: state.uri.path,
        requiredRoles: ['tester'],
      ),
    ],
    logic: GuardLogic.or,
  ),
  builder: (context, state) => DebugPage(),
),
```

---

### 4. 복잡한 가드 조합

```dart
// 인증 + 관리자 역할 (AND 조합)
GoRoute(
  path: '/admin/settings',
  redirect: (context, state) => AuthGuard.compose(
    guards: [
      () => AuthGuard.checkAuth(context: context, currentPath: state.uri.path),
      () => AuthGuard.checkRole(
        context: context,
        currentPath: state.uri.path,
        requiredRoles: ['admin'],
      ),
    ],
    logic: GuardLogic.and,
  ),
  builder: (context, state) => AdminSettingsPage(),
),
```

---

### 5. 복잡한 파라미터 전달

```dart
// DocumentReference 전달
final postRef = FirebaseFirestore.instance.doc('posts/post123');
final serialized = serializeParam(postRef, ParamType.DocumentReference);

context.pushNamed(
  'postDetail',
  queryParameters: {'postRef': serialized},
);

// 역직렬화
final restored = deserializeParam<DocumentReference>(
  state.queryParameters['postRef'],
  ParamType.DocumentReference,
  false,
);

// JSON 객체 전달
final complexData = {'key1': 'value1', 'key2': 123};
final jsonSerialized = serializeParam(
  json.encode(complexData),
  ParamType.JSON,
);

context.pushNamed(
  'complexPage',
  queryParameters: {'data': jsonSerialized},
);
```

---

### 6. NavigationNotifier 사용

```dart
// 위젯에서 상태 읽기
@override
Widget build(BuildContext context, WidgetRef ref) {
  final navState = ref.watch(navigationNotifierProvider);

  return Text('Current path: ${navState.currentPath}');
}

// 상태 업데이트
ref.read(navigationNotifierProvider.notifier).updateCurrentPath('/profile');

// 특정 필드만 감시 (최적화)
final currentPath = ref.watch(
  navigationNotifierProvider.select((state) => state.currentPath),
);

// Redirect location 확인 및 자동 이동
void onLoginSuccess(BuildContext context, WidgetRef ref) {
  final navState = ref.read(navigationNotifierProvider);

  if (navState.redirectLocation != null) {
    // 저장된 경로로 이동
    context.goNamed(navState.redirectLocation!);

    // redirectLocation 초기화
    ref.read(navigationNotifierProvider.notifier).setRedirectLocation(null);
  } else {
    // 기본 홈으로 이동
    context.goNamed('/home');
  }
}
```

---

## 📊 Phase 5 Guard Analytics

### 개요

**Phase 5 Guard Analytics**는 모든 라우트 체크를 Firestore에 기록하고, 실시간으로 분석할 수 있는 시스템입니다.

**주요 특징**:
- 🔥 **Fire-and-forget**: UI 블로킹 없음 (<5ms)
- 📊 **실시간 분석**: DebugLogPage에서 실시간 조회
- 🗄️ **Firestore 저장**: guard_analytics 컬렉션
- 🔐 **보안 규칙**: 인증된 사용자만 접근 가능
- 📈 **통계**: 총 체크 수, 차단/허용 비율

### GuardAnalyticsService

**위치**: `/lib/services/analytics/guard_analytics_service.dart` (279줄)

**주요 메서드**:
```dart
class GuardAnalyticsService {
  // 싱글톤 인스턴스
  static final GuardAnalyticsService _instance = GuardAnalyticsService._();
  factory GuardAnalyticsService() => _instance;

  // 1. Guard 체크 이벤트 기록 (Fire-and-forget)
  Future<void> logGuardCheck({
    required String attemptedPath,
    String? redirectPath,
    required GuardResult result,
    String? userId,
    required String reason,
  }) async {
    final event = GuardAnalyticsEvent(
      eventId: const Uuid().v4(),
      timestamp: DateTime.now(),
      attemptedPath: attemptedPath,
      redirectPath: redirectPath,
      result: result,
      userId: userId,
      reason: reason,
    );

    // Firestore에 저장 (비동기, 에러 무시)
    unawaited(_firestore.collection('guard_analytics').add(event.toFirestore()));
  }

  // 2. 최근 이벤트 실시간 조회 (StreamProvider용)
  Stream<List<GuardAnalyticsEvent>> watchRecentEvents({int limit = 100}) {
    return _firestore
        .collection('guard_analytics')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
            .toList());
  }

  // 3. 통계 조회
  Future<GuardAnalyticsStats> getStats() async {
    final snapshot = await _firestore.collection('guard_analytics').get();
    final events = snapshot.docs
        .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
        .toList();

    final totalChecks = events.length;
    final blockedCount = events.where((e) => e.result == GuardResult.blocked).length;
    final allowedCount = events.where((e) => e.result == GuardResult.allowed).length;

    return GuardAnalyticsStats(
      totalChecks: totalChecks,
      blockedCount: blockedCount,
      allowedCount: allowedCount,
    );
  }

  // 4. 결과별 필터링
  Future<List<GuardAnalyticsEvent>> getEventsByResult(
    GuardResult result, {
    int limit = 100,
  }) async {
    final snapshot = await _firestore
        .collection('guard_analytics')
        .where('result', isEqualTo: result.name)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
        .toList();
  }

  // 5. 사용자별 필터링
  Future<List<GuardAnalyticsEvent>> getEventsByUser(
    String userId, {
    int limit = 100,
  }) async {
    final snapshot = await _firestore
        .collection('guard_analytics')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => GuardAnalyticsEvent.fromFirestore(doc))
        .toList();
  }

  // 6. 전체 이벤트 삭제 (관리자 전용)
  Future<void> clearAllEvents() async {
    final snapshot = await _firestore.collection('guard_analytics').get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
```

---

### GuardAnalyticsEvent (Freezed)

**위치**: `/lib/services/analytics/guard_analytics_event.dart`

```dart
@freezed
class GuardAnalyticsEvent with _$GuardAnalyticsEvent {
  const factory GuardAnalyticsEvent({
    required String eventId,          // UUID
    required DateTime timestamp,      // 체크 시각
    required String attemptedPath,    // 시도한 경로 (예: '/profile/edit')
    String? redirectPath,             // 리다이렉션 경로 (예: '/startPage')
    required GuardResult result,      // 'allowed' or 'blocked'
    String? userId,                   // 사용자 ID (없으면 null)
    required String reason,           // 이유 (예: 'authenticated', 'auth_required')
  }) = _GuardAnalyticsEvent;

  // Firestore Extension Pattern
  factory GuardAnalyticsEvent.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return GuardAnalyticsEvent(
      eventId: doc.id,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      attemptedPath: data['attemptedPath'] as String,
      redirectPath: data['redirectPath'] as String?,
      result: GuardResult.values.byName(data['result'] as String),
      userId: data['userId'] as String?,
      reason: data['reason'] as String,
    );
  }
}

extension GuardAnalyticsEventFirestore on GuardAnalyticsEvent {
  Map<String, dynamic> toFirestore() {
    return {
      'eventId': eventId,
      'timestamp': Timestamp.fromDate(timestamp),
      'attemptedPath': attemptedPath,
      'redirectPath': redirectPath,
      'result': result.name,
      'userId': userId,
      'reason': reason,
    };
  }

  // 터미널 스타일 로그 라인
  String get terminalLogLine {
    final emoji = result == GuardResult.blocked ? '🔴' : '🟢';
    final time = DateFormat('HH:mm:ss').format(timestamp);
    final redirect = redirectPath != null ? ' → $redirectPath' : '';
    return '[$time] $emoji ${result.name.toUpperCase()} $attemptedPath$redirect (uid: ${userId ?? 'none'}, reason: $reason)';
  }
}

enum GuardResult {
  allowed,
  blocked,
}
```

---

### GuardAnalyticsStats

**위치**: `/lib/services/analytics/guard_analytics_event.dart`

```dart
@freezed
class GuardAnalyticsStats with _$GuardAnalyticsStats {
  const factory GuardAnalyticsStats({
    required int totalChecks,      // 총 체크 수
    required int blockedCount,     // 차단 수
    required int allowedCount,     // 허용 수
  }) = _GuardAnalyticsStats;

  const GuardAnalyticsStats._();

  // 차단 비율 (%)
  double get blockPercentage {
    if (totalChecks == 0) return 0.0;
    return (blockedCount / totalChecks) * 100;
  }

  // 허용 비율 (%)
  double get allowPercentage {
    if (totalChecks == 0) return 0.0;
    return (allowedCount / totalChecks) * 100;
  }
}
```

---

### Riverpod Providers

**위치**: `/lib/app/widgets/debug/providers/guard_analytics_providers.dart`

```dart
// 1. 실시간 이벤트 Stream
@riverpod
Stream<List<GuardAnalyticsEvent>> guardEvents(Ref ref) {
  final service = GuardAnalyticsService();
  return service.watchRecentEvents(limit: 100);
}

// 2. 통계 조회
@riverpod
Future<GuardAnalyticsStats> guardStats(Ref ref) async {
  // 이벤트 변경 시 자동 새로고침
  ref.watch(guardEventsProvider);

  final service = GuardAnalyticsService();
  return service.getStats();
}

// 3. 결과별 필터링
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByResult(
  Ref ref,
  GuardResult result,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByResult(result, limit: 100);
}

// 4. 사용자별 필터링
@riverpod
Future<List<GuardAnalyticsEvent>> guardEventsByUser(
  Ref ref,
  String userId,
) async {
  final service = GuardAnalyticsService();
  return service.getEventsByUser(userId, limit: 100);
}

// 5. 전체 이벤트 삭제
@riverpod
Future<void> clearGuardEvents(Ref ref) async {
  final service = GuardAnalyticsService();
  await service.clearAllEvents();

  // Provider 새로고침
  ref.invalidate(guardEventsProvider);
  ref.invalidate(guardStatsProvider);
}
```

---

### UI 통합 (GuardAnalyticsTab)

**위치**: `/lib/app/widgets/debug/guard_analytics_tab.dart`

```dart
class GuardAnalyticsTab extends ConsumerWidget {
  const GuardAnalyticsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 통계 조회
    final statsAsync = ref.watch(guardStatsProvider);

    // 실시간 이벤트 조회
    final eventsAsync = ref.watch(guardEventsProvider);

    return Container(
      color: Colors.black,
      child: Column(
        children: [
          // 통계 섹션
          statsAsync.when(
            data: (stats) => _buildStatsContent(stats),
            loading: () => CircularProgressIndicator(color: Colors.greenAccent),
            error: (error, stack) => Text('Error: $error', style: TextStyle(color: Colors.red)),
          ),

          const Divider(color: Colors.greenAccent, thickness: 2),

          // 이벤트 리스트
          Expanded(
            child: eventsAsync.when(
              data: (events) => ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return SelectableText(
                    event.terminalLogLine,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: event.result == GuardResult.blocked
                          ? Colors.red.shade300
                          : Colors.green.shade300,
                    ),
                  );
                },
              ),
              loading: () => CircularProgressIndicator(color: Colors.greenAccent),
              error: (error, stack) => Text('Error: $error', style: TextStyle(color: Colors.red)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(GuardAnalyticsStats stats) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guard Analytics Statistics',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.greenAccent,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Total Checks: ${stats.totalChecks}',
            style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.greenAccent),
          ),
          Text(
            'Blocked: ${stats.blockedCount} (${stats.blockPercentage.toStringAsFixed(1)}%)',
            style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.red),
          ),
          Text(
            'Allowed: ${stats.allowedCount} (${stats.allowPercentage.toStringAsFixed(1)}%)',
            style: TextStyle(fontFamily: 'monospace', fontSize: 14, color: Colors.green),
          ),
        ],
      ),
    );
  }
}
```

---

### Firestore Security Rules

**위치**: `/firebase/firestore.rules` (lines 304-332)

```javascript
// Guard Analytics 컬렉션 (Server-Only + Debug UI)
match /guard_analytics/{eventId} {
  // 읽기: 인증된 사용자만 (개발 환경에서 Debug Tools 접근)
  allow read: if request.auth != null;

  // 쓰기: 인증된 사용자 (AuthGuard가 이벤트 기록)
  allow create: if request.auth != null
    && request.resource.data.keys().hasAll(['eventId', 'timestamp', 'attemptedPath', 'result', 'reason'])
    && request.resource.data.keys().hasOnly(['eventId', 'timestamp', 'attemptedPath', 'redirectPath', 'result', 'userId', 'reason'])
    && request.resource.data.result in ['blocked', 'allowed'];

  // 업데이트 불가 (Append-Only 로그)
  allow update: if false;

  // 삭제: 본인 이벤트만 또는 관리자
  allow delete: if request.auth != null
    && (request.auth.uid == resource.data.userId
        || request.auth.uid in ['ADMIN_UID_1', 'ADMIN_UID_2']);
}
```

---

## 🏛 아키텍처 결정 (ADR)

### ADR-001: Static 메서드 vs Singleton 클래스

**결정**: AuthGuard를 Static 메서드 패턴으로 구현

**근거**:
1. **GoRouter 통합**: GoRouter의 redirect 콜백은 static 함수와 호환성이 높음
2. **상태 없음**: AuthGuard는 상태를 가지지 않으므로 Singleton 불필요
3. **코드 간결성**: Static 메서드가 더 간결하고 직관적
4. **테스트 용이성**: Mock Firebase Auth로 쉽게 테스트 가능

**대안**:
- Singleton 클래스: 상태 관리가 필요한 경우 고려

---

### ADR-002: Fire-and-forget vs Synchronous 로깅

**결정**: Phase 5 Guard Analytics를 Fire-and-forget 패턴으로 구현

**근거**:
1. **UI 블로킹 없음**: 로깅 실패가 사용자 경험에 영향을 주지 않음
2. **성능**: <5ms 인증 체크 유지 (로깅은 비동기)
3. **신뢰성**: 로깅 실패가 인증 프로세스를 방해하지 않음

**대안**:
- Synchronous 로깅: 감사 로그가 critical한 경우 고려
- 하이브리드: 로그인 성공/실패 등 중요 이벤트만 Synchronous

---

### ADR-003: Firestore vs Local Storage

**결정**: Guard Analytics를 Firestore에 저장

**근거**:
1. **실시간 분석**: 여러 디바이스에서 통합 분석 가능
2. **보안**: Firestore Rules로 접근 제어
3. **확장성**: 서버 측 분석 및 대시보드 구축 용이

**대안**:
- Local Storage (Hive): 네트워크 없이 동작, 비용 절감
- Hybrid: 로컬 캐시 + Firestore 동기화

---

### ADR-004: Extension Pattern vs DTO/Mapper

**결정**: GuardAnalyticsEvent를 Extension Pattern으로 구현

**근거**:
1. **코드 간결성**: DTO/Mapper 제거로 85% 코드 감소
2. **직접성**: Firestore ↔ Entity 직접 변환
3. **타입 안전성**: Extension은 Entity 타입에 결합

**참조**: [CLAUDE.md#왜-extension](../../../../CLAUDE.md#왜-extension)

---

### ADR-005: Riverpod 3.x vs Riverpod 2.x

**결정**: NavigationNotifier를 Riverpod 3.x로 마이그레이션

**근거**:
1. **타입 안전성**: StateNotifier + Freezed State
2. **코드 감소**: @riverpod annotation으로 boilerplate 제거
3. **최적화**: select로 필요한 필드만 감시

**대안**:
- Riverpod 2.x Codegen: Notifications Feature에서 사용 중 (78% 코드 감소)

---

### ADR-006: Feature Routes vs Monolithic Routes

**결정**: Feature별 독립 라우트 관리 (Feature Routes 패턴)

**근거**:
1. **Feature 독립성**: 결합도 감소, 병렬 개발 가능
2. **코드 가독성**: 428줄 → 100줄 (76% 감소)
3. **테스트 용이성**: Feature별 라우트만 테스트
4. **확장성**: 새 Feature 추가 시 최소 수정

**구현 계획**:
- Phase 1: Profile, Chat Feature Routes 분리
- Phase 2: Auth, Post Feature Routes 분리
- Phase 3: 나머지 Feature Routes 분리
- Phase 4: nav.dart 100줄 이하로 축소

---

## 🔄 마이그레이션 가이드

### Phase 1-5 완료 현황

| Phase | 내용 | 상태 |
|-------|------|------|
| **Phase 1** | 기본 인증 체크 (checkAuth) | ✅ 완료 |
| **Phase 2** | 리다이렉트 관리 (redirectIfAuthenticated) | ✅ 완료 |
| **Phase 3** | (Reserved for future use) | - |
| **Phase 4** | 역할 기반 권한 (checkRole, compose) | ✅ 완료 |
| **Phase 5** | Guard Analytics (Firestore 로깅) | ✅ 완료 |
| **Phase B-1** | Interest Selection 라우트 모듈화 (ProfileRoutes에 3개 라우트 추가) | ✅ 완료 (2025-11-11) |

---

### AppStateNotifier → NavigationNotifier 마이그레이션

**Before (AppStateNotifier - Deprecated)**:
```dart
class AppStateNotifier extends ChangeNotifier {
  BaseAuthUser? initialUser;
  BaseAuthUser? user;
  bool showSplashImage = true;
  String? _redirectLocation;

  bool get loggedIn => user?.loggedIn ?? false;
  bool get shouldRedirect => loggedIn && _redirectLocation != null;

  void update(BaseAuthUser? newUser) {
    user = newUser;
    notifyListeners();
  }
}

// Provider 등록
final appStateNotifierProvider = ChangeNotifierProvider<AppStateNotifier>(
  (ref) => AppStateNotifier(),
);
```

**After (NavigationNotifier - Riverpod 3.x)**:
```dart
@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required String currentPath,
    String? redirectLocation,
    required bool showSplashImage,
    @Default(true) bool notifyOnChange,
  }) = _NavigationState;
}

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier() : super(
    const NavigationState(
      currentPath: '/',
      redirectLocation: null,
      showSplashImage: true,
      notifyOnChange: true,
    ),
  );

  void updateCurrentPath(String path) {
    state = state.copyWith(currentPath: path);
  }

  void setRedirectLocation(String? location) {
    state = state.copyWith(redirectLocation: location);
  }

  void hideSplashImage() {
    state = state.copyWith(showSplashImage: false);
  }
}

// Provider 등록
final navigationNotifierProvider = StateNotifierProvider<NavigationNotifier, NavigationState>(
  (ref) => NavigationNotifier(),
);
```

**마이그레이션 체크리스트**:
- [x] NavigationState Freezed 클래스 생성
- [x] NavigationNotifier StateNotifier 구현
- [x] Provider 등록 (navigationNotifierProvider)
- [x] AuthGuard에서 NavigationNotifier 사용
- [x] GoRouter에서 refreshListenable 변경
- [x] AppStateNotifier 제거
- [x] 문서 업데이트 (navigation/README.md)

---

### Feature Routes 마이그레이션

**Step 1: Feature별 Routes 파일 생성**

```bash
# Profile Feature Routes
mkdir -p lib/features/profile/presentation/routes
touch lib/features/profile/presentation/routes/profile_routes.dart

# Chat Feature Routes
mkdir -p lib/features/chat/presentation/routes
touch lib/features/chat/presentation/routes/chat_routes.dart
```

**Step 2: 라우트 이동**

```dart
// lib/features/profile/presentation/routes/profile_routes.dart
import 'package:go_router/go_router.dart';
import '../screens/profile_page.dart';
import '../screens/edit_profile_page.dart';

class ProfileRoutes {
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';

  static List<RouteBase> routes = [
    GoRoute(
      path: profile,
      name: 'profile',
      redirect: (context, state) => AuthGuard.checkAuth(
        context: context,
        currentPath: state.uri.path,
      ),
      builder: (context, state) => ProfilePage(userId: state.pathParameters['userId']),
      routes: [
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          redirect: (context, state) => AuthGuard.checkAuth(
            context: context,
            currentPath: state.uri.path,
          ),
          builder: (context, state) => EditProfilePage(),
        ),
      ],
    ),
  ];
}
```

**Step 3: nav.dart에서 병합**

```dart
// lib/app/router/navigation/nav.dart
import '/features/profile/presentation/routes/profile_routes.dart';
import '/features/chat/presentation/routes/chat_routes.dart';

GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    ...ProfileRoutes.routes,
    ...ChatRoutes.routes,
    // ... 기타 Feature Routes
  ],
);
```

**Step 4: 테스트**

```bash
flutter analyze
flutter test
flutter run
```

---

## 🐛 트러블슈팅

### 1. 인증 후 리다이렉션 실패

**증상**: 로그인 후 원래 페이지로 돌아가지 않음

**원인**: NavigationNotifier의 redirectLocation이 null

**해결**:
```dart
// AuthGuard.checkAuth에서 redirectLocation 자동 설정됨
// 문제 발생 시 NavigationNotifier 상태 확인
final navState = ref.read(navigationNotifierProvider);
print('Redirect location: ${navState.redirectLocation}');

// 수동 설정 (테스트용)
ref.read(navigationNotifierProvider.notifier).setRedirectLocation('/profile/edit');
```

**참조**: [guards/README.md#redirect-location-management](guards/README.md#redirect-location-management)

---

### 2. Guard Analytics 이벤트 누락

**증상**: DebugLogPage에서 Guard Analytics 이벤트가 보이지 않음

**원인**: AuthGuard.checkAuth 호출 누락 또는 Firestore 권한 문제

**해결**:
```dart
// 1. GoRouter redirect에서 AuthGuard.checkAuth 호출 확인
GoRoute(
  path: '/protected',
  redirect: (context, state) {
    return AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );
  },
  builder: ...,
);

// 2. Firestore 규칙 확인
// firebase/firestore.rules에서 guard_analytics 컬렉션 규칙 확인
// allow read: if request.auth != null;
// allow create: if request.auth != null ...

// 3. GuardAnalyticsService 초기화 확인
// AuthGuard.dart line 60에서 GuardAnalyticsService 인스턴스 확인
static final GuardAnalyticsService _analytics = GuardAnalyticsService();
```

**참조**: [guards/README.md#troubleshooting](guards/README.md#troubleshooting)

---

### 3. Feature Routes 경로 충돌

**증상**: 같은 경로를 여러 Feature에서 정의하여 에러 발생

**원인**: Feature Routes 병합 시 경로 중복

**해결**:
```dart
// Feature별로 고유한 경로 사용
// ❌ 잘못된 예 (충돌)
class ProfileRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/settings', ...),  // 충돌!
  ];
}

class ChatRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/settings', ...),  // 충돌!
  ];
}

// ✅ 올바른 예 (고유 경로)
class ProfileRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/profile/settings', ...),  // OK
  ];
}

class ChatRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/chat/settings', ...),  // OK
  ];
}
```

---

### 4. 파라미터 직렬화 에러

**증상**: 복잡한 객체 전달 시 에러 발생

**원인**: 지원하지 않는 타입 사용

**해결**:
```dart
// 지원하는 ParamType만 사용
// int, double, String, bool, DateTime, DateTimeRange,
// Color, DocumentReference, Document, JSON, AppUploadedFile

// 복잡한 객체는 JSON으로 변환
final jsonParam = json.encode(complexObject.toJson());
final serialized = serializeParam(jsonParam, ParamType.JSON);

// 역직렬화
final restored = deserializeParam<Map<String, dynamic>>(
  serialized,
  ParamType.JSON,
  false,
);
final complexObject = ComplexObject.fromJson(restored);
```

---

### 5. NavigationNotifier 상태 동기화 문제

**증상**: 상태 변경이 UI에 반영되지 않음

**원인**: ref.watch 누락 또는 잘못된 Provider 사용

**해결**:
```dart
// ✅ 올바른 사용
@override
Widget build(BuildContext context, WidgetRef ref) {
  final navState = ref.watch(navigationNotifierProvider);
  return Text('Current path: ${navState.currentPath}');
}

// ❌ 잘못된 사용 (ref.read는 한 번만 읽음, 변경 감지 안 됨)
@override
Widget build(BuildContext context, WidgetRef ref) {
  final navState = ref.read(navigationNotifierProvider);  // ❌ 변경 감지 안 됨
  return Text('Current path: ${navState.currentPath}');
}

// ✅ 특정 필드만 감시 (최적화)
final currentPath = ref.watch(
  navigationNotifierProvider.select((state) => state.currentPath),
);
```

---

## ⚡ 성능 최적화

### 1. AuthGuard 성능

**목표**: <5ms 인증 체크 (Phase 5 Guard Analytics 포함)

**최적화 기법**:
- Fire-and-forget 로깅: UI 블로킹 없음
- Static 메서드: 인스턴스 생성 오버헤드 없음
- 캐시: Firebase Auth currentUser는 캐시됨

**벤치마크**:
```dart
final stopwatch = Stopwatch()..start();
final redirectPath = AuthGuard.checkAuth(
  context: context,
  currentPath: '/profile',
);
stopwatch.stop();
print('AuthGuard + Analytics time: ${stopwatch.elapsedMilliseconds}ms');
// 목표: <5ms
```

---

### 2. NavigationNotifier 최적화

**목표**: <5ms 상태 업데이트

**최적화 기법**:
- Freezed 불변 클래스: 효율적인 비교 (==)
- select: 필요한 필드만 감시
- StateNotifier: 상태 변경 로직 캡슐화

**예시**:
```dart
// ❌ 전체 상태 감시 (불필요한 리빌드)
final navState = ref.watch(navigationNotifierProvider);
final currentPath = navState.currentPath;

// ✅ 특정 필드만 감시 (최적화)
final currentPath = ref.watch(
  navigationNotifierProvider.select((state) => state.currentPath),
);
```

---

### 3. Feature Routes 최적화

**목표**: 초기 로딩 시간 <1s

**최적화 기법**:
- 라우트 코드 분리: Tree-shaking으로 미사용 제거
- Lazy loading: 필요할 때만 로드
- 병렬 로딩: 여러 Feature Routes 동시 로드

---

### 4. 파라미터 직렬화 최적화

**목표**: <10ms 직렬화/역직렬화

**최적화 기법**:
- 타입별 최적화: 각 타입에 맞는 최적 직렬화
- 캐싱: 자주 사용하는 DocumentReference 캐시
- 압축: 긴 JSON은 gzip 압축

---

## 📖 참조 문서

### Router 시스템 문서

- **[guards/README.md](guards/README.md)** (800+ 줄) - AuthGuard 시스템 + Phase 5 Guard Analytics 완벽 가이드
- **[navigation/README.md](navigation/README.md)** (1,280줄) - Navigation 시스템 완벽 가이드
- **[ISSUES_ANALYSIS.md](ISSUES_ANALYSIS.md)** (1,805줄) - Router 시스템 이슈 분석
- **[README.md](README.md)** (이 문서) - Router 시스템 통합 가이드

### 프로젝트 문서

- **[CLAUDE.md](../../../CLAUDE.md)** - 프로젝트 전체 가이드 (1,200+ 줄)
- **[NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)** - 네이밍 규칙

### Feature 문서

- **[Auth Feature README](../../../lib/features/auth/README.md)** (982줄)
- **[Profile Feature README](../../../lib/features/profile/README.md)** (1,020줄)
- **[Chat Feature README](../../../lib/features/chat/README.md)** (665줄)
- **[Notifications Feature README](../../../lib/features/notifications/README.md)** (1,272줄)

### Firebase 문서

- **[Firebase Functions README](../../../../firebase/functions/README.md)** (14,899줄)
- **[Firestore Security Rules](../../../../firebase/firestore.rules)** (514줄)

---

## 🎓 학습 로드맵

### Level 1: 기초 (GoRouter + AuthGuard)

**학습 시간**: 4시간

**학습 순서**:
1. [navigation/README.md](navigation/README.md) - GoRouter 기초, NavigationNotifier
2. [guards/README.md](guards/README.md) - AuthGuard.checkAuth 기본 사용
3. 실습: 간단한 인증 페이지 만들기

---

### Level 2: 중급 (Feature Routes + Redirect)

**학습 시간**: 6시간

**학습 순서**:
1. Feature Routes 패턴 이해
2. Redirect Location Management (Phase 4)
3. 실습: Feature별 라우트 분리

---

### Level 3: 고급 (Guard Analytics + 역할 기반 권한)

**학습 시간**: 8시간

**학습 순서**:
1. Phase 5 Guard Analytics 시스템
2. 역할 기반 권한 체크 (checkRole, compose)
3. 실습: 관리자 전용 페이지 + Analytics 대시보드

---

## 🎯 다음 단계

### Feature Routes 마이그레이션 (진행 예정)

**Phase 1**: Profile, Chat Feature Routes 분리 (예상 2주)
**Phase 2**: Auth, Post Feature Routes 분리 (예상 2주)
**Phase 3**: 나머지 Feature Routes 분리 (예상 3주)
**Phase 4**: nav.dart 100줄 이하로 축소 (예상 1주)

**완료 시점**: 2025-12월 예상

---

### Router 시스템 개선 (2026 Q1)

- [ ] Feature Routes 테스트 자동화
- [ ] Guard Analytics 대시보드 (웹)
- [ ] 역할 기반 권한 확장 (팀, 그룹)
- [ ] Deep Link 고급 패턴
- [ ] 성능 벤치마크 자동화

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **아키텍처 질문**: 이 문서의 "참조 문서" 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용

---

**문서 버전**: 1.0.0
**최종 업데이트**: 2025-11-10
**관리**: Versus Space 개발팀
**총 라인 수**: ~1,400줄 (통합 가이드)

---

## ✨ 기여

이 문서에 기여하려면:
1. guards/README.md 또는 navigation/README.md 업데이트
2. 이 통합 가이드 (router/README.md) 업데이트
3. PR 생성 및 리뷰 요청

**감사합니다!** 🙏
