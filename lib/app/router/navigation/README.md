# 📦 내비게이션 시스템 (Navigation System)

> Versus Space 앱의 라우팅과 내비게이션을 관리하는 핵심 시스템

## 개요

`/lib/app/router/navigation` 디렉토리는 GoRouter 기반의 선언적 내비게이션 시스템을 구현합니다. 인증 상태 관리, 페이지 전환, 딥링크 처리, 파라미터 직렬화 등 앱의 모든 내비게이션 관련 기능을 담당하는 중앙 라우팅 레이어입니다.

### 주요 특징
- 🚀 **GoRouter 기반**: Flutter의 공식 선언적 라우팅 패키지 사용
- 🔐 **AuthGuard 통합**: Firebase Auth와 완벽한 연동 + Phase 5 Guard Analytics
- 📱 **ShellRoute 지원**: 하단 네비게이션 바 유지하며 페이지 전환
- 🔄 **Riverpod 3.x 상태 관리**: NavigationNotifier로 실시간 내비게이션 상태 추적
- 🎯 **Feature Routes**: Feature별 독립 라우트 관리 (모듈화)
- 📦 **파라미터 직렬화**: 복잡한 객체도 URL 파라미터로 전달 가능
- 🎯 **딥링크 지원**: 외부 링크로 직접 페이지 접근
- ⚡ **전환 효과**: 커스터마이징 가능한 페이지 전환 애니메이션

### 현재 아키텍처

```
/lib/app/router/
├── guards/                           # 🛡️ 인증 및 권한 가드
│   ├── auth_guard.dart              # AuthGuard + Phase 5 Analytics
│   └── README.md                     # Guards 시스템 가이드
│
├── navigation/                       # 📦 내비게이션 상태 관리
│   ├── navigation_state.dart        # Freezed NavigationState 정의
│   ├── navigation_notifier.dart     # Riverpod 3.x StateNotifier
│   ├── nav.dart                     # GoRouter 설정 (428줄)
│   ├── serialization_util.dart      # 파라미터 직렬화 (256줄)
│   └── README.md                    # ← 이 문서
│
└── (Feature Routes는 각 Feature 내부에 위치) # ✅ Phase 1-3 완료
    # /features/auth/presentation/routes/auth_routes.dart (5 routes)
    # /features/profile/presentation/routes/profile_routes.dart (3 routes)
    # /features/chat/presentation/routes/chat_routes.dart (4 routes)
    # /features/creation/presentation/routes/creation_routes.dart (2 routes)
    # /features/notifications/presentation/routes/notification_routes.dart (4 routes)
    # /features/post/presentation/routes/post_routes.dart (3 routes)
    # /features/search/presentation/routes/search_routes.dart (0 routes, 준비)
```

**상태 관리 흐름**:
```
Firebase Auth ─→ AuthGuard ─→ NavigationNotifier (Riverpod 3.x)
                     ↓              ↓
              Guard Analytics   NavigationState
                     ↓              ↓
              Firestore Log    UI Update (ref.watch)
```

---

## Feature Routes 모듈화

### 개념

**Feature Routes**는 각 Feature가 자체 라우트를 정의하고 관리하는 패턴입니다. 기존의 단일 `nav.dart` 파일 (428줄)에 모든 라우트를 정의하던 방식에서 벗어나, Feature별로 라우트를 분리하여 유지보수성과 확장성을 높입니다.

### 구조

**Before (Monolithic)**:
```dart
// /lib/app/router/navigation/nav.dart (428줄)
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    // Auth routes
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignupPage()),

    // Profile routes
    GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    GoRoute(path: '/profile/edit', builder: (context, state) => EditProfilePage()),

    // Chat routes
    GoRoute(path: '/chat', builder: (context, state) => ChatListPage()),
    GoRoute(path: '/chat/:chatId', builder: (context, state) => ChatDetailPage()),

    // ... 50+ more routes (모든 Feature가 섞여 있음)
  ],
);
```

**After (Feature-First)**:
```dart
// /lib/features/auth/presentation/routes/auth_routes.dart
class AuthRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => SignupPage()),
    GoRoute(path: '/forgot-password', builder: (context, state) => ForgotPasswordPage()),
  ];
}

// /lib/features/profile/presentation/routes/profile_routes.dart
class ProfileRoutes {
  static List<RouteBase> routes = [
    GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    GoRoute(path: '/profile/edit', builder: (context, state) => EditProfilePage()),
    GoRoute(path: '/profile/settings', builder: (context, state) => SettingsPage()),
  ];
}

// /lib/app/router/navigation/nav.dart (100줄로 축소!)
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  routes: [
    ...AuthRoutes.routes,        // Auth Feature 라우트
    ...ProfileRoutes.routes,     // Profile Feature 라우트
    ...ChatRoutes.routes,        // Chat Feature 라우트
    ...PostRoutes.routes,        // Post Feature 라우트
    // ... (Feature별 라우트 병합)
  ],
);
```

### 장점

1. **Feature 독립성**: 각 Feature가 자체 라우트를 관리 → 결합도 감소
2. **코드 가독성**: 428줄 → 100줄 (주요 설정만 남음)
3. **병렬 개발**: Feature 팀이 독립적으로 라우트 추가 가능
4. **테스트 용이성**: Feature별 라우트만 테스트하면 됨
5. **확장성**: 새 Feature 추가 시 기존 코드 수정 최소화

### 구현 현황 (Phase 1-3 완료)

**완료일**: 2025-11-10
**상태**: 7/8 Features 완료 (87.5%)

| Feature | 파일 위치 | Routes | Pattern | requireAuth | Status |
|---------|----------|--------|---------|-------------|--------|
| **Auth** | `/features/auth/.../auth_routes.dart` | 5 | GoRoute + pageBuilder | Mixed | ✅ Phase 0 |
| **Profile** | `/features/profile/.../profile_routes.dart` | 3 | AppRoute + toRoute(ref) | ✅ Yes | ✅ Phase 0 |
| **Chat** | `/features/chat/.../chat_routes.dart` | 4 | AppRoute + toRoute(ref) | ✅ Yes | ✅ Phase 0 |
| **Creation** | `/features/creation/.../creation_routes.dart` | 2 | AppRoute + toRoute(ref) | ❌ No | ✅ Phase 1.1 |
| **Notifications** | `/features/notifications/.../notification_routes.dart` | 4 | AppRoute + toRoute(ref) | ✅ Yes | ✅ Phase 1.2 |
| **Post** | `/features/post/.../post_routes.dart` | 3 | AppRoute + toRoute(ref) | ❌ No | ✅ Phase 2 |
| **Search** | `/features/search/.../search_routes.dart` | 0 | Empty (준비) | N/A | ✅ Phase 3 |
| **Voting** | N/A (Dialog 패턴) | 0 | showDialog() | N/A | ✅ 예외 |

**총 Routes**: 21개 (ShellRoute 5개 + Feature Routes 16개)

**Phase별 마이그레이션**:
- **Phase 0** (기존): Auth, Profile, Chat routes 모듈화 완료
- **Phase 1.1** (2025-11-10): Creation routes `requireAuth: false` 명시
- **Phase 1.2** (2025-11-10): Notifications → AppRoute 패턴 전환
- **Phase 2** (2025-11-10): Post routes 신규 생성
- **Phase 3** (2025-11-10): Search routes 준비 (빈 리스트)
- **Phase A** (2025-11-11): RootPageContext 삭제 (29줄 제거, 전역 상태 복잡도 감소)

**패턴 설명**:
- **AppRoute + toRoute(ref)**: 표준 패턴 - AuthGuard 자동 통합, requireAuth 지원
- **GoRoute + pageBuilder**: 커스텀 애니메이션 필요 시 사용 (Auth만 해당)
- **Dialog 패턴**: 라우트 불필요, `showDialog()` 사용 (Voting)

**nav.dart 통합 방식**:
```dart
// /lib/app/router/navigation/nav.dart (lines 112-181)
routes: [
  ...AuthRoutes.routes(ref),                  // Phase 0
  ...ProfileRoutes.routes(ref),               // Phase 0
  ...CreationRoutes.routes(ref),              // Phase 1.1
  ...ChatRoutes.routes(ref),                  // Phase 0
  ...NotificationRoutes.routes(ref),          // Phase 1.2
  ...PostRoutes.routes(ref),                  // Phase 2
  ...SearchRoutes.routes(ref),                // Phase 3
],
```

---

## 페이지 전환 애니메이션 제어

### 애니메이션 제어 위치

페이지 전환 애니메이션은 **Feature Routes 파일**에서 제어합니다. 각 Feature가 자체 라우트의 전환 효과를 독립적으로 설정할 수 있습니다.

**제어 레벨** (우선순위 순):
1. **Feature Routes 파일** (최우선) - `*_routes.dart`에서 route별 애니메이션 정의
2. **nav.dart ShellRoute** - 하단 네비게이션 바 페이지의 전환 효과
3. **호출 시점** - `context.goNamed()` 호출 시 `extra: TransitionInfo()` 전달

### 현재 사용 패턴 (7개 Feature)

| Feature | 애니메이션 | 지속 시간 | 패턴 | 위치 |
|---------|----------|---------|------|------|
| **Auth** | ✅ Fade + Slide | 400ms | `pageBuilder` + `CustomTransitionPage` | `auth_routes.dart` lines 30-103 |
| **Profile** | ❌ Instant | 0ms | `AppRoute.toRoute(ref)` | `profile_routes.dart` |
| **Chat** | ❌ Instant | 0ms | `AppRoute.toRoute(ref)` | `chat_routes.dart` |
| **Creation** | ❌ Instant | 0ms | `AppRoute.toRoute(ref)` | `creation_routes.dart` |
| **Notifications** | ❌ Instant | 0ms | `AppRoute.toRoute(ref)` | `notification_routes.dart` |
| **Post** | ❌ Instant | 0ms | `AppRoute.toRoute(ref)` | `post_routes.dart` |
| **Search** | ❌ N/A | N/A | Empty routes | `search_routes.dart` |
| **ShellRoute** | ❌ Instant | 0ms | `NoTransitionPage` | `nav.dart` lines 124-177 |

**현황 요약**:
- **Animated**: 1/7 Features (14%) - Auth만 애니메이션 사용
- **Instant**: 6/7 Features (86%) - 성능 최적화를 위한 즉시 전환

### 애니메이션 구현 방법

#### 방법 1: AppRoute 패턴 (기본, 애니메이션 없음)

**장점**: AuthGuard 자동 통합, 간단한 구현, 빠른 전환 (0ms)
**단점**: 커스텀 애니메이션 불가

```dart
// /lib/features/profile/presentation/routes/profile_routes.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/app/router/navigation/nav.dart';
import '../screens/profile_edit_screen.dart';

class ProfileRoutes {
  static List<GoRoute> routes(WidgetRef ref) => [
    // 즉시 전환 (Duration.zero)
    AppRoute(
      name: ProfileEditScreen.routeName,
      path: ProfileEditScreen.routePath,
      requireAuth: true,
      builder: (context, params) => ProfileEditScreen(),
    ).toRoute(ref),
  ];
}
```

**내부 동작**:
```dart
// AppRoute.toRoute(ref)가 생성하는 GoRoute
GoRoute(
  name: 'profileEdit',
  path: '/profile/edit',
  redirect: (context, state) => AuthGuard.checkAuth(...),
  pageBuilder: (context, state) => NoTransitionPage(
    key: state.pageKey,
    child: ProfileEditScreen(),
  ),
);
```

---

#### 방법 2: GoRoute + pageBuilder (커스텀 애니메이션)

**장점**: 완전한 애니메이션 제어, Curve 커스터마이징
**단점**: 코드 길이 증가, AuthGuard 수동 통합 필요

**예시 1: Fade + Slide (Auth 패턴)**
```dart
// /lib/features/auth/presentation/routes/auth_routes.dart
import 'package:go_router/go_router.dart';
import '../screens/login_page_widget.dart';

class AuthRoutes {
  static List<GoRoute> routes(WidgetRef ref) => [
    GoRoute(
      name: LoginPageWidget.routeName,
      path: LoginPageWidget.routePath,
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        child: LoginPageWidget(),
        transitionDuration: Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Curve 적용
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          // Fade + Slide 결합
          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: Offset(0.0, 0.15),  // 아래에서 15% 위치
                end: Offset.zero,           // 원래 위치
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
      ),
    ),
  ];
}
```

**예시 2: Slide만 (왼쪽에서 오른쪽)**
```dart
GoRoute(
  name: 'chatDetail',
  path: '/chat/:chatId',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: ChatDetailWidget(
      chatId: state.pathParameters['chatId']!,
    ),
    transitionDuration: Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: Offset(1.0, 0.0),  // 오른쪽 밖
          end: Offset.zero,          // 원래 위치
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        )),
        child: child,
      );
    },
  ),
),
```

**예시 3: Scale + Fade (모달 느낌)**
```dart
GoRoute(
  name: 'postDetail',
  path: '/post/:postId',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: PostDetailPage(
      postId: state.pathParameters['postId']!,
    ),
    transitionDuration: Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: Tween<double>(
          begin: 0.8,   // 80% 크기
          end: 1.0,     // 원래 크기
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  ),
),
```

**예시 4: Rotation (특수 효과)**
```dart
GoRoute(
  name: 'settings',
  path: '/settings',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: SettingsPage(),
    transitionDuration: Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RotationTransition(
        turns: Tween<double>(
          begin: 0.0,
          end: 0.5,  // 180도 회전
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        )),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  ),
),
```

---

#### 방법 3: 호출 시점에 애니메이션 전달

**장점**: 같은 라우트를 다른 애니메이션으로 호출 가능
**단점**: 매번 TransitionInfo 생성 필요, 일관성 저하 가능

```dart
// 애니메이션 없이 이동
context.goNamed(
  'profile',
  extra: TransitionInfo(
    hasTransition: false,
    duration: Duration.zero,
  ),
);

// Fade 애니메이션으로 이동
context.goNamed(
  'profile',
  extra: TransitionInfo(
    hasTransition: true,
    duration: Duration(milliseconds: 300),
  ),
);
```

**주의**: 이 방법은 AppRoute 패턴에서만 지원되며, Feature Routes의 GoRoute에서는 작동하지 않습니다. Feature Routes에서는 방법 2 (pageBuilder)를 사용하세요.

---

### AuthGuard 통합 (커스텀 애니메이션 사용 시)

커스텀 애니메이션을 사용할 때는 AuthGuard를 수동으로 통합해야 합니다:

```dart
GoRoute(
  name: 'profileEdit',
  path: '/profile/edit',

  // AuthGuard 수동 통합
  redirect: (context, state) => AuthGuard.checkAuth(
    context: context,
    currentPath: state.uri.path,
  ),

  // 커스텀 애니메이션
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: ProfileEditScreen(),
    transitionDuration: Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(0.0, 0.15),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        ),
      );
    },
  ),
),
```

---

### 권장 사항

#### 언제 애니메이션을 사용할까?

**✅ 애니메이션 사용 권장**:
- **온보딩/인증 플로우**: 사용자 환영, 첫인상 중요 (예: Auth Feature)
- **모달/다이얼로그**: 팝업 느낌의 화면 (Scale + Fade)
- **계층 구조**: 상세 페이지로 이동 (Slide)
- **특별 이벤트**: 성과 달성, 레벨업 등 (특수 효과)

**❌ 애니메이션 생략 권장**:
- **하단 네비게이션 바**: 탭 전환은 즉시 (ShellRoute 패턴)
- **빈번한 이동**: 채팅 목록 ↔ 상세 (성능 우선)
- **데이터 로딩 중**: 이미 로딩 인디케이터가 있으면 불필요
- **성능 민감**: 저사양 기기 대응

#### 애니메이션 지속 시간

| 사용 사례 | 권장 시간 | 이유 |
|----------|---------|------|
| **빠른 전환** | 150-250ms | 사용자가 기다림을 느끼지 않음 |
| **표준 전환** | 300-400ms | 자연스러운 전환 (Auth 패턴) |
| **강조 효과** | 500-700ms | 특별한 순간 강조 |
| **즉시 전환** | 0ms (Duration.zero) | 성능 최우선 (현재 기본값) |

#### Curve 선택 가이드

```dart
// 부드러운 가속/감속
Curves.easeInOut       // 가장 범용적, Auth에서 사용
Curves.easeOut         // 빠른 시작, 느린 끝 (자연스러움)
Curves.easeIn          // 느린 시작, 빠른 끝

// 탄성 효과
Curves.elasticOut      // 살짝 튕기는 효과 (재미있는 느낌)
Curves.bounceOut       // 강하게 튕기는 효과

// 선형
Curves.linear          // 일정한 속도 (기계적 느낌)
```

---

### 성능 최적화

**현재 프로젝트 전략**: 86%의 라우트가 애니메이션 없음 (0ms)
- **목표**: 60fps 유지, 16ms 이내 렌더링
- **Trade-off**: UX vs 성능 → 성능 우선 선택

**최적화 팁**:
1. **불필요한 애니메이션 제거**: 빈번한 이동에는 Duration.zero 사용
2. **GPU 오버헤드 감소**: 복잡한 애니메이션 조합 지양 (Fade + Slide만 사용)
3. **ShellRoute 즉시 전환**: 하단 네비게이션 바는 NoTransitionPage
4. **지속 시간 단축**: 300-400ms 이내로 제한

### 실무 적용 예시

**Profile Feature Routes**:
```dart
// /lib/features/profile/presentation/routes/profile_routes.dart
import 'package:go_router/go_router.dart';
import '../screens/profile_page.dart';
import '../screens/edit_profile_page.dart';
import '../screens/settings_page.dart';

class ProfileRoutes {
  // Route names (타입 안전성)
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String settings = '/profile/settings';

  // Route definitions
  static List<RouteBase> routes = [
    GoRoute(
      path: profile,
      name: 'profile',
      builder: (context, state) {
        final userId = state.pathParameters['userId'];
        return ProfilePage(userId: userId);
      },
      routes: [
        // Nested routes (프로필 하위 경로)
        GoRoute(
          path: 'edit',
          name: 'editProfile',
          builder: (context, state) => EditProfilePage(),
        ),
        GoRoute(
          path: 'settings',
          name: 'settings',
          builder: (context, state) => SettingsPage(),
        ),
      ],
    ),
  ];
}
```

**AuthGuard 통합**:
```dart
// 인증 필요 라우트
GoRoute(
  path: ProfileRoutes.editProfile,
  name: 'editProfile',
  redirect: (context, state) {
    // AuthGuard를 사용한 인증 체크
    return AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );
  },
  builder: (context, state) => EditProfilePage(),
),
```

**Phase 5 Analytics 통합**:
```dart
// 라우트 변경 시 자동으로 Guard Analytics 이벤트 기록
// (AuthGuard.checkAuth 내부에서 자동 처리)
GoRoute(
  path: '/profile',
  redirect: (context, state) {
    final redirectPath = AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );

    // Guard Analytics 이벤트 자동 기록:
    // - attemptedPath: '/profile'
    // - result: 'blocked' or 'allowed'
    // - userId: current user ID or null
    // - reason: 'authenticated' or 'auth_required'

    return redirectPath;
  },
  builder: (context, state) => ProfilePage(),
),
```

**참조**: [guards/README.md](../guards/README.md) - AuthGuard + Phase 5 Guard Analytics 전체 가이드

---

## 네이밍 컨벤션

### 파일명
- ✅ **snake_case 사용**: `nav.dart`, `serialization_util.dart`, `navigation_notifier.dart`
- ✅ **기능별 접미사**: `_util.dart`, `_notifier.dart`, `_state.dart`
- ✅ **Feature Routes**: `{feature}_routes.dart` (예: `auth_routes.dart`)

### 클래스명
- ✅ **PascalCase 사용**: `NavigationNotifier`, `NavigationState`, `TransitionInfo`
- ✅ **명확한 역할 표현**: `NavigationExtensions`, `GoRouterExtensions`
- ✅ **Feature Routes**: `{Feature}Routes` (예: `AuthRoutes`, `ProfileRoutes`)

### 필드 및 메서드
- ✅ **camelCase 사용**: `currentPath`, `showSplashImage`, `redirectLocation`
- ✅ **private 필드**: `_router`, `_redirectLocation`, `_analytics`
- ✅ **boolean 접두사**: `isRootPage`, `hasTransition`, `shouldRedirect`

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

---

## 주요 구성요소

### 1. navigation_state.dart (120줄)

#### NavigationState (Freezed 불변 클래스)

**역할**: 앱 전체의 내비게이션 상태를 불변 데이터 클래스로 정의

```dart
@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    required String currentPath,
    String? redirectLocation,
    required bool showSplashImage,
    @Default(true) bool notifyOnChange,
  }) = _NavigationState;

  factory NavigationState.fromJson(Map<String, dynamic> json) =>
      _$NavigationStateFromJson(json);
}
```

**주요 필드**:
- `currentPath`: 현재 라우트 경로 (예: '/home', '/profile')
- `redirectLocation`: 인증 후 이동할 목표 경로 (Phase 4 Redirect Location Management)
- `showSplashImage`: 스플래시 화면 표시 여부
- `notifyOnChange`: 상태 변경 알림 활성화 여부

**장점**:
- Freezed의 `copyWith` 메서드로 불변 상태 업데이트
- JSON 직렬화 지원으로 상태 저장/복원 가능
- 타입 안전성 보장 (컴파일 타임 에러 검출)

**사용 예시**:
```dart
// 상태 생성
final state = NavigationState(
  currentPath: '/home',
  redirectLocation: null,
  showSplashImage: false,
);

// 불변 업데이트
final updatedState = state.copyWith(
  currentPath: '/profile',
  redirectLocation: '/profile/edit',
);

// JSON 직렬화
final json = state.toJson();
final restored = NavigationState.fromJson(json);
```

---

### 2. navigation_notifier.dart (108줄)

#### NavigationNotifier (Riverpod 3.x StateNotifier)

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

  // 현재 경로 업데이트
  void updateCurrentPath(String path) {
    state = state.copyWith(currentPath: path);
  }

  // 리다이렉션 위치 설정
  void setRedirectLocation(String? location) {
    state = state.copyWith(redirectLocation: location);
  }

  // 스플래시 화면 숨기기
  void hideSplashImage() {
    state = state.copyWith(showSplashImage: false);
  }

  // 알림 토글
  void toggleNotifyOnChange(bool value) {
    state = state.copyWith(notifyOnChange: value);
  }

  // 상태 초기화
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

**주요 메서드**:
- `updateCurrentPath(String)`: 현재 경로 변경 (GoRouter 라우트 전환 시 호출)
- `setRedirectLocation(String?)`: 인증 후 리다이렉션 목표 설정 (Phase 4)
- `hideSplashImage()`: 스플래시 화면 숨기기 (앱 초기화 완료 시)
- `toggleNotifyOnChange(bool)`: 상태 변경 알림 토글
- `reset()`: 로그아웃 시 상태 초기화

**Riverpod 통합**:
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

**장점**:
- Riverpod 3.x의 타입 안전 Provider 시스템
- `select`로 필요한 필드만 감시 → 불필요한 리빌드 방지
- StateNotifier로 상태 변경 로직 캡슐화
- 테스트 용이성 (Mock Provider 주입 가능)

---

### 3. nav.dart (428줄)

#### GoRouter 설정

**역할**: 앱의 모든 라우트 정의 및 관리

```dart
GoRouter createRouter(NavigationNotifier notifier) => GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  refreshListenable: notifier,  // NavigationNotifier 연결
  navigatorKey: appNavigatorKey,
  errorBuilder: (context, state) => StartPageWidget(),
  redirect: (context, state) {
    // Phase 5 Guard Analytics 통합
    final redirectPath = AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );

    // Guard Analytics 이벤트 자동 기록
    // (AuthGuard.checkAuth 내부에서 처리)

    return redirectPath;
  },
  routes: [
    // Feature Routes 병합
    ...AuthRoutes.routes,
    ...ProfileRoutes.routes,
    ...ChatRoutes.routes,
    ...PostRoutes.routes,
    // ... 기타 Feature Routes
  ],
  observers: [
    routeObserver,
    BotToastNavigatorObserver(),
  ],
);
```

**주요 설정**:
- `refreshListenable`: NavigationNotifier 상태 변경 시 GoRouter 자동 리프레시
- `redirect`: AuthGuard를 통한 전역 인증 체크 + Guard Analytics
- `routes`: Feature Routes 병합 (모듈화)
- `observers`: RouteObserver (성능 추적) + BotToast (알림)

**라우트 구조**:
1. **루트 라우트** ('/'): 인증 상태에 따라 자동 리다이렉션
2. **ShellRoute**: 하단 네비게이션 바 유지 페이지들
   - HomePageWidget ('/home')
   - SearchPageWidget ('/search')
   - ProfilePageWidget ('/profile')
   - ChatListWidget ('/chatList')
3. **Feature Routes**: Feature별 독립 라우트 (모듈화)
   - AuthRoutes: '/login', '/signup', '/forgot-password'
   - ProfileRoutes: '/profile', '/profile/edit', '/profile/settings'
   - ChatRoutes: '/chat', '/chat/:chatId'
   - PostRoutes: '/post', '/post/:postId', '/post/create'
   - 기타 20개 이상의 Feature Routes

**AuthGuard 통합 (Phase 4 + Phase 5)**:
```dart
// GoRouter의 redirect 콜백
redirect: (context, state) {
  final currentPath = state.uri.path;

  // AuthGuard.checkAuth 호출
  final redirectPath = AuthGuard.checkAuth(
    context: context,
    currentPath: currentPath,
  );

  // Guard Analytics 이벤트 자동 기록 (Phase 5):
  // - Public route: result='allowed', reason='public_route'
  // - Authenticated: result='allowed', reason='authenticated'
  // - Blocked: result='blocked', reason='auth_required'

  // redirectPath가 null이면 허용, 아니면 리다이렉션
  return redirectPath;
},
```

**참조**:
- [guards/README.md](../guards/README.md) - AuthGuard 전체 API
- [guards/README.md#phase-5-guard-analytics](../guards/README.md#phase-5-guard-analytics) - Guard Analytics 상세

---

#### AppRoute 클래스

**역할**: 라우트 설정을 캡슐화하고 인증 체크 자동화 (Legacy - Feature Routes로 대체 예정)

```dart
class AppRoute {
  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, AppParameters) builder;

  GoRoute toRoute(NavigationNotifier notifier) => GoRoute(
    path: path,
    name: name,
    redirect: requireAuth
        ? (context, state) => AuthGuard.checkAuth(
            context: context,
            currentPath: state.uri.path,
          )
        : null,
    builder: (context, state) {
      // 비동기 파라미터 로딩
      return FutureBuilder(
        future: _loadAsyncParams(state.pathParameters),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          return builder(context, AppParameters(snapshot.data));
        },
      );
    },
  );
}
```

**특징**:
- `requireAuth`: true이면 AuthGuard 자동 적용
- `asyncParams`: 비동기 파라미터 로딩 지원 (Firestore 문서 fetch 등)
- `builder`: 위젯 빌더 함수

**주의**: AppRoute는 Legacy 패턴으로, Feature Routes로 대체 중입니다. 신규 라우트는 Feature Routes 패턴을 사용하세요.

---

#### NavigationExtensions

**역할**: BuildContext에 편리한 내비게이션 메서드 추가

```dart
extension NavigationExtensions on BuildContext {
  void goNamedAuth(String name, bool mounted, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
    bool ignoreRedirect = false,
  }) {
    if (!mounted) return;

    // AuthGuard 체크는 GoRouter의 redirect에서 자동 처리
    goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void pushNamedAuth(String name, bool mounted, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
    bool ignoreRedirect = false,
  }) {
    if (!mounted) return;

    pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  void safePop() {
    if (canPop()) {
      pop();
    } else {
      // 스택이 비면 홈으로 이동
      goNamed('home');
    }
  }
}
```

**제공 메서드**:
- `goNamedAuth`: 인증 체크 후 페이지 이동 (replace)
- `pushNamedAuth`: 인증 체크 후 페이지 푸시 (스택에 추가)
- `safePop`: 안전한 뒤로가기 (스택이 비면 홈으로)

**사용 예시**:
```dart
// 인증 필요 페이지로 이동
context.goNamedAuth(
  'editProfile',
  mounted,
  pathParameters: {'userId': userId},
);

// 안전한 뒤로가기
context.safePop();
```

---

#### TransitionInfo

**역할**: 페이지 전환 애니메이션 설정

```dart
class TransitionInfo {
  final bool hasTransition;
  final Duration duration;

  const TransitionInfo({
    this.hasTransition = false,
    this.duration = Duration.zero,
  });

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}
```

**기본 설정**:
- 전환 효과 비활성화 (즉시 전환) - 성능 최적화
- 활성화 시 300ms 페이드 효과

---

### 4. serialization_util.dart (256줄)

#### 직렬화 헬퍼 함수

**역할**: 복잡한 Dart 객체를 URL 파라미터로 직렬화/역직렬화

**지원 타입**:
- 기본 타입: `int`, `double`, `String`, `bool`
- 날짜/시간: `DateTime`, `DateTimeRange`
- 색상: `Color`
- 파일: `AppUploadedFile`
- Firebase: `DocumentReference`, `Document`
- JSON 객체

**직렬화 함수**:
```dart
String? serializeParam(
  dynamic param,
  ParamType paramType, {
  bool isList = false,
}) {
  if (param == null) return null;

  if (isList) {
    return json.encode(
      (param as Iterable).map((item) => _serializeSingleParam(item, paramType)).toList(),
    );
  }

  return _serializeSingleParam(param, paramType);
}

String _serializeSingleParam(dynamic param, ParamType paramType) {
  switch (paramType) {
    case ParamType.int:
      return param.toString();
    case ParamType.double:
      return param.toString();
    case ParamType.String:
      return param as String;
    case ParamType.bool:
      return param.toString();
    case ParamType.DateTime:
      return (param as DateTime).millisecondsSinceEpoch.toString();
    case ParamType.DateTimeRange:
      return dateTimeRangeToString(param as DateTimeRange);
    case ParamType.DocumentReference:
      return _serializeDocumentReference(param as DocumentReference);
    case ParamType.JSON:
      return json.encode(param);
    default:
      return param.toString();
  }
}
```

**역직렬화 함수**:
```dart
dynamic deserializeParam<T>(
  String? param,
  ParamType paramType,
  bool isList, {
  List<String>? collectionNamePath,
}) {
  if (param == null) return null;

  if (isList) {
    final list = json.decode(param) as List;
    return list.map((item) => _deserializeSingleParam<T>(
      item.toString(),
      paramType,
      collectionNamePath: collectionNamePath,
    )).toList();
  }

  return _deserializeSingleParam<T>(
    param,
    paramType,
    collectionNamePath: collectionNamePath,
  );
}

T? _deserializeSingleParam<T>(
  String param,
  ParamType paramType, {
  List<String>? collectionNamePath,
}) {
  switch (paramType) {
    case ParamType.int:
      return int.tryParse(param) as T?;
    case ParamType.double:
      return double.tryParse(param) as T?;
    case ParamType.String:
      return param as T;
    case ParamType.bool:
      return (param.toLowerCase() == 'true') as T;
    case ParamType.DateTime:
      return DateTime.fromMillisecondsSinceEpoch(int.parse(param)) as T;
    case ParamType.DateTimeRange:
      return dateTimeRangeFromString(param) as T?;
    case ParamType.DocumentReference:
      return _deserializeDocumentReference(param, collectionNamePath) as T?;
    case ParamType.JSON:
      return json.decode(param) as T;
    default:
      return null;
  }
}
```

#### 특수 직렬화 처리

**DocumentReference 직렬화**:
```dart
String _serializeDocumentReference(DocumentReference ref) {
  // 컬렉션 경로를 | 구분자로 연결
  // 예: "users|userId123|posts|postId456"
  return ref.path.replaceAll('/', '|');
}

DocumentReference? _deserializeDocumentReference(
  String param,
  List<String>? collectionNamePath,
) {
  final path = param.replaceAll('|', '/');
  return FirebaseFirestore.instance.doc(path);
}
```

**DateTimeRange 직렬화**:
```dart
String dateTimeRangeToString(DateTimeRange dateTimeRange) {
  // 시작과 끝 타임스탬프를 | 구분자로 연결
  // 예: "1625097600000|1625184000000"
  final start = dateTimeRange.start.millisecondsSinceEpoch;
  final end = dateTimeRange.end.millisecondsSinceEpoch;
  return '$start|$end';
}

DateTimeRange? dateTimeRangeFromString(String param) {
  final parts = param.split('|');
  if (parts.length != 2) return null;

  final start = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[0]));
  final end = DateTime.fromMillisecondsSinceEpoch(int.parse(parts[1]));

  return DateTimeRange(start: start, end: end);
}
```

---

## 사용 예시

### 1. 페이지 이동

```dart
// 일반 페이지 이동 (Feature Routes)
context.goNamed('home');

// 인증 체크 후 이동 (AuthGuard 자동 적용)
context.goNamedAuth(
  'editProfile',
  mounted,
  ignoreRedirect: false,
);

// 파라미터와 함께 이동
context.pushNamed(
  'chatDetail',
  pathParameters: {'chatId': chatId},
  extra: {'chatDocument': chatModel},
);

// Feature Routes 사용
context.goNamed(
  ProfileRoutes.editProfile,  // '/profile/edit'
  pathParameters: {'userId': userId},
);
```

### 2. 안전한 뒤로가기

```dart
// 스택이 비면 홈으로 이동
context.safePop();
```

### 3. 파라미터 직렬화

```dart
// 복잡한 객체 직렬화
final serialized = serializeParam(
  documentRef,
  ParamType.DocumentReference,
);

// URL 파라미터로 전달
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
```

### 4. NavigationNotifier 사용 (Riverpod 3.x)

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
```

### 5. AuthGuard + Guard Analytics 통합

```dart
// GoRouter redirect에서 AuthGuard 사용
GoRoute(
  path: '/profile/edit',
  redirect: (context, state) {
    // AuthGuard.checkAuth 호출
    final redirectPath = AuthGuard.checkAuth(
      context: context,
      currentPath: state.uri.path,
    );

    // Guard Analytics 이벤트 자동 기록:
    // - attemptedPath: '/profile/edit'
    // - redirectPath: '/startPage' (인증 실패 시) or null (성공 시)
    // - result: 'blocked' or 'allowed'
    // - userId: current user ID or null
    // - reason: 'authenticated', 'auth_required', 'public_route'

    return redirectPath;
  },
  builder: (context, state) => EditProfilePage(),
),
```

**참조**: [guards/README.md#phase-5-guard-analytics](../guards/README.md#phase-5-guard-analytics) - Guard Analytics 전체 가이드

---

## 내비게이션 플로우

### 앱 시작 플로우
```
1. 앱 실행
2. 스플래시 화면 표시 (NavigationState.showSplashImage: true)
3. Firebase Auth 초기화
4. NavigationNotifier 초기화
5. GoRouter 생성 (createRouter)
6. AuthGuard.checkAuth 호출 (전역 redirect)
7. 인증 상태에 따라:
   - 로그인됨: /home으로 이동 (Guard Analytics: result='allowed', reason='authenticated')
   - 로그아웃: /startPage 유지 (Guard Analytics: result='allowed', reason='public_route')
8. NavigationNotifier.hideSplashImage() 호출
9. 스플래시 화면 숨기기
```

### 인증 필요 페이지 접근 플로우 (Phase 4 + Phase 5)
```
1. 인증 필요 페이지 접근 시도 (예: /profile/edit)
2. GoRouter의 redirect 콜백 실행
3. AuthGuard.checkAuth(currentPath: '/profile/edit') 호출
4. 로그인 안 됨:
   - NavigationNotifier.setRedirectLocation('/profile/edit') 호출
   - Guard Analytics 이벤트 기록:
     * attemptedPath: '/profile/edit'
     * redirectPath: '/startPage'
     * result: 'blocked'
     * userId: null
     * reason: 'auth_required'
   - /startPage로 리다이렉션
5. 로그인 성공:
   - NavigationState.redirectLocation 확인 ('/profile/edit')
   - Guard Analytics 이벤트 기록:
     * attemptedPath: '/profile/edit'
     * redirectPath: null
     * result: 'allowed'
     * userId: 'user123'
     * reason: 'authenticated'
   - /profile/edit로 자동 이동
   - NavigationNotifier.setRedirectLocation(null) 호출 (초기화)
```

### ShellRoute 내비게이션
```
1. MainNavigationShell 유지 (하단 네비게이션 바)
2. 하단 네비게이션 바로 페이지 선택
3. ShellRoute 내부에서만 페이지 전환
4. NavigationNotifier.updateCurrentPath() 자동 호출
5. 애니메이션 없이 즉시 전환 (TransitionInfo.appDefault)
6. 스택 관리는 GoRouter가 자동 처리
```

### Feature Routes 모듈화 플로우
```
1. Feature 개발 팀이 자체 routes 파일 생성
   예: /lib/features/profile/presentation/routes/profile_routes.dart
2. ProfileRoutes.routes 정의 (List<RouteBase>)
3. /lib/app/router/navigation/nav.dart에 병합
   routes: [...ProfileRoutes.routes, ...]
4. GoRouter 자동 처리 (경로 충돌 검사, 매칭 등)
5. Feature 독립적으로 라우트 추가/수정 가능
```

---

## 성능 최적화

### 1. 전환 애니메이션 최적화
- 기본값: 애니메이션 없음 (즉시 전환) - TransitionInfo.appDefault()
- 필요 시에만 페이드 효과 적용 (300ms)
- Duration.zero로 불필요한 대기 제거
- GPU 오버헤드 최소화

### 2. 비동기 파라미터 로딩
- FutureBuilder로 파라미터 로딩 중 화면 표시
- 병렬 로딩으로 대기 시간 최소화
- 실패 시 null 처리로 앱 크래시 방지
- Firestore 문서 fetch 최적화 (캐시 활용)

### 3. Riverpod 최적화
- `select`로 필요한 필드만 감시 → 불필요한 리빌드 방지
- NavigationState는 Freezed 불변 클래스 → 효율적인 비교 (==)
- StateNotifier로 상태 변경 로직 캡슐화
- Provider Scope 최소화

### 4. Feature Routes 최적화
- 라우트 코드 분리로 초기 로딩 시간 단축
- Tree-shaking으로 미사용 Feature Routes 제거
- Lazy loading으로 필요할 때만 로드

### 5. Guard Analytics 최적화 (Phase 5)
- Fire-and-forget 패턴 → UI 블로킹 없음
- Firestore batch write로 네트워크 요청 최소화
- 로컬 캐시 우선 (Guard Analytics UI는 캐시 사용)

---

## 트러블슈팅

### 자주 발생하는 문제

#### 1. 인증 후 리다이렉션 실패

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

**참조**: [guards/README.md#redirect-location-management](../guards/README.md#redirect-location-management) - Phase 4 상세 가이드

---

#### 2. 파라미터 직렬화 에러

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

#### 3. Feature Routes 경로 충돌

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

#### 4. Guard Analytics 이벤트 누락

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

**참조**: [guards/README.md#troubleshooting](../guards/README.md#troubleshooting) - Guard Analytics 트러블슈팅

---

## 보안 고려사항

### 1. 인증 체크 (Phase 4 + Phase 5)
- AuthGuard.checkAuth로 보호된 페이지 자동 인증 체크
- 미인증 사용자는 로그인 페이지로 강제 리다이렉션
- 인증 토큰 만료 시 자동 로그아웃 처리
- **Phase 5**: 모든 인증 체크를 Firestore에 기록 (감사 로그)

### 2. 파라미터 검증
- deserializeParam에서 타입 안전성 보장
- try-catch로 파싱 에러 처리
- null 체크로 잘못된 파라미터 방어
- DocumentReference는 Firestore 규칙으로 추가 보안

### 3. URL 보안
- DocumentReference는 ID만 직렬화 (민감 정보 제외)
- 파라미터 인코딩으로 injection 공격 방지
- GoRouter의 자동 URL 인코딩 활용

### 4. Guard Analytics 보안 (Phase 5)
- Firestore 규칙으로 guard_analytics 접근 제어
- 인증된 사용자만 이벤트 생성 가능
- 본인 이벤트만 삭제 가능
- 관리자는 모든 이벤트 접근 가능 (role-based)

**참조**: [guards/README.md#firestore-security-rules](../guards/README.md#firestore-security-rules) - Guard Analytics 보안 규칙

---

## 테스팅

### 단위 테스트

```dart
// NavigationNotifier 테스트
void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  test('NavigationNotifier - updateCurrentPath', () {
    final notifier = container.read(navigationNotifierProvider.notifier);
    final state = container.read(navigationNotifierProvider);

    expect(state.currentPath, '/');

    notifier.updateCurrentPath('/profile');

    final updatedState = container.read(navigationNotifierProvider);
    expect(updatedState.currentPath, '/profile');
  });

  test('NavigationNotifier - setRedirectLocation', () {
    final notifier = container.read(navigationNotifierProvider.notifier);

    notifier.setRedirectLocation('/profile/edit');

    final state = container.read(navigationNotifierProvider);
    expect(state.redirectLocation, '/profile/edit');
  });

  test('NavigationNotifier - reset', () {
    final notifier = container.read(navigationNotifierProvider.notifier);

    notifier.updateCurrentPath('/profile');
    notifier.setRedirectLocation('/settings');
    notifier.reset();

    final state = container.read(navigationNotifierProvider);
    expect(state.currentPath, '/');
    expect(state.redirectLocation, null);
    expect(state.showSplashImage, true);
  });
}
```

### 통합 테스트

```dart
testWidgets('인증 필요 페이지 리다이렉션 + Guard Analytics', (tester) async {
  await tester.pumpWidget(
    ProviderScope(child: MyApp()),
  );

  // 로그아웃 상태에서 보호된 페이지 접근
  final context = tester.element(find.byType(MyApp));
  context.goNamed('editProfile');
  await tester.pumpAndSettle();

  // 로그인 페이지로 리다이렉션 확인
  expect(find.byType(StartPageWidget), findsOneWidget);

  // Guard Analytics 이벤트 확인
  final analytics = GuardAnalyticsService();
  final events = await analytics.getEventsByResult(GuardResult.blocked, limit: 1);

  expect(events.length, 1);
  expect(events.first.attemptedPath, '/profile/edit');
  expect(events.first.result, GuardResult.blocked);
  expect(events.first.reason, 'auth_required');
});
```

**참조**: [guards/README.md#testing](../guards/README.md#testing) - AuthGuard 테스팅 가이드

---

## 성능 지표

### 목표 성능
- **페이지 전환**: <16ms (60fps 유지)
- **파라미터 직렬화**: <10ms
- **AuthGuard 체크**: <5ms (Phase 5 Guard Analytics 포함)
- **딥링크 처리**: <100ms
- **NavigationNotifier 업데이트**: <5ms (Riverpod 최적화)

### 모니터링

```dart
// 라우트 성능 측정
final stopwatch = Stopwatch()..start();
context.goNamed('profile');
stopwatch.stop();
print('Navigation time: ${stopwatch.elapsedMilliseconds}ms');

// AuthGuard 성능 측정 (Phase 5)
final guardStopwatch = Stopwatch()..start();
final redirectPath = AuthGuard.checkAuth(
  context: context,
  currentPath: '/profile',
);
guardStopwatch.stop();
print('AuthGuard + Analytics time: ${guardStopwatch.elapsedMilliseconds}ms');
// 목표: <5ms (Guard Analytics는 fire-and-forget으로 UI 블로킹 없음)
```

---

## 변경 이력

### v3.0.0 (2025-11-10)
- ✅ **Feature Routes 모듈화**: Feature별 독립 라우트 관리
- ✅ **Riverpod 3.x 마이그레이션**: NavigationNotifier (StateNotifier) 도입
- ✅ **NavigationState Freezed 전환**: 불변 상태 관리
- ✅ **Phase 5 Guard Analytics 통합**: 모든 라우트 체크 기록
- ✅ **AppStateNotifier 제거**: Riverpod 3.x로 대체 (deprecated)
- ✅ **문서 대폭 개선**: 550줄, Feature Routes + Guard Analytics 반영

### v2.0.0 (2025-08-22)
- GoRouter 기반 내비게이션 시스템 문서화
- 428줄 nav.dart, 256줄 serialization_util.dart 분석
- ShellRoute 구조 및 인증 플로우 상세 설명

### v1.5.0 (2025-07-25)
- ShellRoute 도입으로 하단 네비게이션 바 구현
- MainNavigationShell 통합

### v1.4.0 (2025-07-03)
- FlutterFlow 의존성 제거
- 네이티브 Flutter 코드로 마이그레이션

### v1.3.0 (2025-06-15)
- 전환 애니메이션 최적화
- hasTransition: false 기본값 설정

### v1.2.0 (2025-06-01)
- 비동기 파라미터 로딩 지원 추가
- AppParameters 클래스 구현

### v1.1.0 (2025-05-15)
- 파라미터 직렬화 시스템 구축
- 모든 ParamType 지원

### v1.0.0 (2025-05-01)
- 초기 GoRouter 기반 내비게이션 구현
- AppStateNotifier 인증 상태 관리 (deprecated)

---

## 참조 문서

- **[guards/README.md](../guards/README.md)** - AuthGuard 시스템 + Phase 5 Guard Analytics 완벽 가이드
- **[ISSUES_ANALYSIS.md](../ISSUES_ANALYSIS.md)** - Router 시스템 이슈 분석 (1,805줄)
- **[NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)** - 네이밍 규칙
- **[CLAUDE.md](../../../../CLAUDE.md)** - 프로젝트 전체 가이드

---

**문서 버전**: 3.0.0
**최종 업데이트**: 2025-11-10
**관리**: Versus Space 개발팀
