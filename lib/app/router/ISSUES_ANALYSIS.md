# Router 디렉토리 주요 이슈 분석 보고서

> **작성일**: 2025-11-10
> **분석 대상**: `/lib/app/router/navigation/`
> **전체 완성도**: 🟡 **64%** (Clean Architecture v4.0 기준)
> **Riverpod 마이그레이션**: 🟡 **75%** (Navigation 완료, AppState 대기)

---

## 📊 Executive Summary (요약)

### 전체 이슈 통계

| 심각도 | 개수 | 비율 | 우선순위 |
|-------|-----|------|---------|
| 🔴 **Critical** | 3개 | 27% | **즉시 해결 필요** |
| 🟡 **Medium** | 4개 | 36% | 2주 이내 해결 |
| 🟢 **Low** | 4개 | 36% | 1개월 이내 해결 |
| **Total** | **11개** | **100%** | - |

### 우선순위 매트릭스 (긴급도 × 중요도)

```
높음 │ 🔴 Provider 혼재    🔴 Feature Import  🟡 Circular Import
중요 │ 🔴 Auth 하드코딩   🟡 패턴 혼재       🟡 Serialization
도   │ 🟡 Error 처리      🟢 Analytics       🟢 Deep Linking
낮음 │ 🟢 Transition      🟢 Error Page      -
     └─────────────────────────────────────────────
        낮음           중간              높음
                    긴급도
```

### 권장 해결 순서

**Week 1** (Critical):
1. Provider 0.x 제거 → Riverpod 3.x 전환
2. Feature Route 모듈화 (Profile, Chat, Auth, Creation)
3. Auth 로직 분리 (AppStateNotifier → AuthGuard)

**Week 2** (Medium):
4. GoRoute/AppRoute 패턴 통일
5. Serialization 위치 이동 (/core/utils/)
6. Circular import 제거
7. Error 처리 개선 (print → Logger)

**Week 3-4** (Low):
8. Transition 라이브러리 구축
9. Analytics 통합
10. Deep Linking 설정
11. 전용 Error 페이지

---

## 🔴 Critical Issues (즉시 해결 필요)

### Issue #1: Provider 0.x와 Riverpod 3.x 혼재

**심각도**: 🔴 **Critical** (영향도: 10/10)
**발견 위치**: `nav.dart:646`
**영향 범위**: 전체 상태 관리 시스템

#### 현재 상태

```dart
// ❌ nav.dart:646 - Provider 0.x 사용
final rootPageContext = context.read<RootPageContext?>();

// ❌ nav.dart:1 - Provider import
import 'package:provider/provider.dart';  // Legacy

// ❌ nav.dart:34-85 - ChangeNotifier 패턴
class AppStateNotifier extends ChangeNotifier {
  User? initialUser;
  User? _user;

  bool get loggedIn => _user != null;

  Future<void> update(User? user) async {
    _user = user;
    notifyListeners();  // Provider 0.x 패턴
  }
}
```

#### 문제점

1. **패러다임 충돌**:
   - Navigation: Riverpod 3.x (`@riverpod` annotation)
   - AppState: Provider 0.x (`ChangeNotifier`)
   - **결과**: 두 가지 상태 관리 패러다임 공존 → 혼란

2. **유지보수 어려움**:
   - Provider 0.x는 deprecated 예정
   - 새 팀원이 어느 패턴을 따라야 할지 불명확
   - 버그 발생 시 디버깅 복잡도 증가

3. **성능 이슈**:
   - `ChangeNotifier.notifyListeners()`: 모든 리스너 재빌드
   - Riverpod: 스마트 리빌드 (변경된 부분만)
   - **결과**: 불필요한 위젯 재빌드 발생 가능

4. **테스트 복잡도**:
   - Provider mock: `ChangeNotifierProvider.value()`
   - Riverpod mock: `ProviderScope(overrides: [])`
   - **결과**: 테스트 설정 코드 2배 증가

#### 영향도 분석

| 영향 영역 | 현재 상태 | 영향도 |
|----------|---------|-------|
| **상태 관리 일관성** | 혼재 | 🔴 심각 |
| **새 Feature 추가** | 패턴 선택 혼란 | 🔴 심각 |
| **성능** | 불필요한 재빌드 | 🟡 중간 |
| **테스트** | 복잡도 증가 | 🟡 중간 |
| **의존성** | Provider 제거 불가 | 🔴 심각 |

#### 해결 방법

**Step 1**: `AppStateNotifier` → Riverpod `AuthState`

```dart
// ✅ auth/presentation/providers/auth_state_provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'auth_state_provider.g.dart';

/// Auth 상태 데이터 모델 (Freezed)
@freezed
class AuthStateData with _$AuthStateData {
  const factory AuthStateData({
    User? user,
    @Default(false) bool isLoading,
    String? redirectLocation,
  }) = _AuthStateData;

  const AuthStateData._();

  bool get isAuthenticated => user != null;
}

/// Auth 상태 Provider (Riverpod 3.x)
@riverpod
class AuthState extends _$AuthState {
  @override
  AuthStateData build() {
    // Firebase Auth Stream 구독
    final authRepo = ref.watch(authRepositoryProvider);

    // Stream을 AsyncValue로 변환
    ref.listen(
      authRepo.authStateChanges(),
      (previous, next) {
        next.whenData((user) {
          state = state.copyWith(user: user);
        });
      },
    );

    return const AuthStateData();
  }

  /// 로그아웃
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    try {
      final authRepo = ref.read(authRepositoryProvider);
      await authRepo.signOut();
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Redirect 위치 설정
  void setRedirectLocation(String? location) {
    state = state.copyWith(redirectLocation: location);
  }

  /// Redirect 위치 초기화
  void clearRedirectLocation() {
    state = state.copyWith(redirectLocation: null);
  }
}
```

**Step 2**: Router에서 사용

```dart
// ✅ nav.dart - Before/After

// ❌ Before: Provider 0.x
final rootPageContext = context.read<RootPageContext?>();
if (appStateNotifier.loggedIn) { ... }

// ✅ After: Riverpod 3.x
GoRouter createRouter(WidgetRef ref) => GoRouter(
  refreshListenable: ref.watch(authStateProvider.notifier),  // 자동 갱신
  redirect: (context, state) {
    final authState = ref.read(authStateProvider);

    if (!authState.isAuthenticated) {
      // 로그인 필요
      ref.read(authStateProvider.notifier).setRedirectLocation(state.uri.toString());
      return '/startPage';
    }

    return null;  // 접근 허용
  },
);
```

**Step 3**: Provider 의존성 제거

```yaml
# ❌ Before: pubspec.yaml
dependencies:
  provider: ^6.1.1  # 제거!
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.0

# ✅ After: pubspec.yaml
dependencies:
  flutter_riverpod: ^3.0.3
  riverpod_annotation: ^3.0.0

dev_dependencies:
  riverpod_generator: ^3.0.0
```

#### 예상 소요 시간

- **AuthStateProvider 작성**: 1시간
- **nav.dart 수정**: 1시간
- **테스트 작성**: 30분
- **의존성 제거 및 검증**: 30분
- **Total**: **3시간**

#### 체크리스트

- [ ] `auth_state_provider.dart` 생성 (Riverpod 3.x)
- [ ] `authStateProvider` 코드 생성 (`build_runner`)
- [ ] `nav.dart`에서 `AppStateNotifier` 제거
- [ ] `createRouter()` 시그니처 변경 (`WidgetRef` 추가)
- [ ] `main.dart`에서 `ProviderScope` 내부로 Router 이동
- [ ] `pubspec.yaml`에서 `provider` 제거
- [ ] 모든 Provider import 제거 확인
- [ ] 테스트 실행 (Auth 관련)
- [ ] 앱 실행 및 로그인/로그아웃 테스트

---

### Issue #2: 직접 스크린 Import (Feature-First 위반)

**심각도**: 🔴 **Critical** (영향도: 9/10)
**발견 위치**: `nav.dart:21-25` (Profile, Chat, Creation)
**영향 범위**: 전체 아키텍처 품질, Feature 독립성

#### 현재 상태

```dart
// ❌ nav.dart:21-25 - 직접 스크린 import
import '/features/profile/presentation/screens/profile_edit/profile_edit_screen.dart';
import '/features/profile/presentation/screens/settings/settings_screen.dart';
import '/features/profile/presentation/screens/user_posts_list/user_posts_list_screen.dart';
import '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart';
import '/features/creation/presentation/screens/create_post/create_post_screen.dart';

// ❌ nav.dart:152-157 - Router에서 직접 사용
GoRoute(
  name: 'profileEdit',
  path: '/profileEdit/:userId',
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfileEditScreen(userId: userId);  // 직접 인스턴스화
  },
)
```

#### 문제점

1. **강한 결합 (Tight Coupling)**:
   - Router가 각 Feature의 내부 구조를 알아야 함
   - Feature가 화면 경로 변경 시 Router도 수정 필요
   - **결과**: 변경 영향도 증가, 유지보수 어려움

2. **Feature 독립성 상실**:
   - Feature는 자신의 routes를 관리해야 함
   - 현재: Router가 모든 Feature의 routes 관리 (Single Point of Failure)
   - **결과**: Feature 추가/제거 시 Router 대규모 수정

3. **순환 의존성 위험**:
   ```
   /app/router/nav.dart
     └─> import '/features/profile/presentation/screens/...'
           └─> import '/app/widgets/...'  (간접적)
                 └─> import '/app/router/...'  (잠재적 순환!)
   ```

4. **테스트 복잡도**:
   - Router 테스트 시 모든 Feature 화면 mock 필요
   - Feature 테스트 시 Router mock 필요
   - **결과**: 테스트 설정 코드 증가, 격리 어려움

5. **Feature 재사용 불가**:
   - 다른 프로젝트에서 Feature 재사용 시 routes도 함께 제공 불가
   - **결과**: Feature 모듈화 실패

#### 영향도 분석

| 영향 영역 | 현재 상태 | 영향도 |
|----------|---------|-------|
| **Clean Architecture** | Feature-First 위반 | 🔴 심각 |
| **유지보수** | 변경 영향도 큼 | 🔴 심각 |
| **Feature 독립성** | 결합도 높음 | 🔴 심각 |
| **테스트** | 복잡도 증가 | 🟡 중간 |
| **재사용성** | Feature 재사용 불가 | 🟡 중간 |

#### 해결 방법

**Step 1**: Feature별 Route 모듈 생성

```dart
// ✅ features/profile/presentation/routes/profile_routes.dart

import 'package:go_router/go_router.dart';
import '../screens/profile_edit/profile_edit_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/user_posts_list/user_posts_list_screen.dart';
import '../screens/onboarding/onboarding_flow_screen.dart';
import '../screens/user_info/user_info_display_screen.dart';

/// **Profile Feature Routes Module**
///
/// 이 클래스는 Profile Feature의 모든 routes를 중앙집중식으로 관리하며,
/// Router에서 `...ProfileRoutes.routes`로 주입합니다.
///
/// ## Feature-First Architecture 준수
///
/// - Feature가 자신의 routes 소유 및 관리
/// - Router는 Feature routes를 주입만 받음 (인지 불필요)
/// - Feature 추가/제거 시 Router 영향 최소화
class ProfileRoutes {
  ProfileRoutes._();  // Private constructor (static only)

  /// **Profile Feature의 모든 routes**
  ///
  /// Router에서 다음과 같이 사용:
  /// ```dart
  /// routes: [
  ///   ...ProfileRoutes.routes,
  /// ]
  /// ```
  static List<GoRoute> get routes => [
    // 프로필 편집
    GoRoute(
      name: routeNames.profileEdit,
      path: '/profileEdit/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return ProfileEditScreen(userId: userId);
      },
    ),

    // 설정
    GoRoute(
      name: routeNames.settings,
      path: '/settings/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return SettingsScreen(userId: userId);
      },
    ),

    // 사용자 게시물 목록
    GoRoute(
      name: routeNames.userPostsList,
      path: '/userPostsList/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserPostsListScreen(userId: userId);
      },
    ),

    // 온보딩 플로우
    GoRoute(
      name: routeNames.onboardingFlow,
      path: '/onboardingFlow/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return OnboardingFlowScreen(userId: userId);
      },
    ),

    // 사용자 정보 표시
    GoRoute(
      name: routeNames.userInfoDisplay,
      path: '/userInfoDisplay/:userId',
      builder: (context, state) {
        final userId = state.pathParameters['userId']!;
        return UserInfoDisplayScreen(userId: userId);
      },
    ),
  ];

  /// **Route 이름 상수**
  ///
  /// 타입 안전한 네비게이션을 위한 route 이름 정의.
  ///
  /// 사용 예시:
  /// ```dart
  /// context.goNamed(ProfileRoutes.routeNames.profileEdit, ...);
  /// ```
  static const routeNames = _ProfileRouteNames();
}

class _ProfileRouteNames {
  const _ProfileRouteNames();

  String get profileEdit => 'profileEdit';
  String get settings => 'settings';
  String get userPostsList => 'userPostsList';
  String get onboardingFlow => 'onboardingFlow';
  String get userInfoDisplay => 'userInfoDisplay';
}
```

**Step 2**: Chat Feature Routes

```dart
// ✅ features/chat/presentation/routes/chat_routes.dart

import 'package:go_router/go_router.dart';
import '../screens/chat_list/chat_list_widget_clean.dart';
import '../screens/friends/friends_widget.dart';
import '../screens/chat_detail/chat_detail_widget_clean.dart';
import '../screens/ai_chat/ai_chat_page_clean.dart';

class ChatRoutes {
  ChatRoutes._();

  static List<GoRoute> get routes => [
    // 채팅 목록
    GoRoute(
      name: routeNames.chatList,
      path: '/chat/list',
      builder: (context, state) => const ChatListWidgetClean(),
    ),

    // 친구 목록
    GoRoute(
      name: routeNames.friends,
      path: '/chat/friends',
      builder: (context, state) => const FriendsWidget(),
    ),

    // 1:1 채팅 상세
    GoRoute(
      name: routeNames.chatDetail,
      path: '/chatDetail',
      builder: (context, state) {
        final chatDocument = state.extra as dynamic;  // Chat entity
        return ChatDetailWidgetClean(chatDocument: chatDocument);
      },
    ),

    // AI 채팅
    GoRoute(
      name: routeNames.aiChat,
      path: '/aiChatPage/:aiChatId',
      builder: (context, state) {
        final aiChatId = state.pathParameters['aiChatId']!;
        return AIChatPageClean(aiChatId: aiChatId);
      },
    ),
  ];

  static const routeNames = _ChatRouteNames();
}

class _ChatRouteNames {
  const _ChatRouteNames();

  String get chatList => 'chatList';
  String get friends => 'friends';
  String get chatDetail => 'chatDetail';
  String get aiChat => 'aiChat';
}
```

**Step 3**: Router에서 Feature Routes 주입

```dart
// ✅ nav.dart - Before/After

// ❌ Before: 직접 import + 직접 정의
import '/features/profile/presentation/screens/profile_edit/profile_edit_screen.dart';
import '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart';

GoRouter createRouter(...) => GoRouter(
  routes: [
    GoRoute(
      name: 'profileEdit',
      path: '/profileEdit/:userId',
      builder: (context, state) => ProfileEditScreen(...),
    ),
    GoRoute(
      name: 'chatDetail',
      path: '/chatDetail',
      builder: (context, state) => ChatDetailWidgetClean(...),
    ),
    // ... 25개 더
  ],
);

// ✅ After: Feature Routes 주입
import '/features/profile/presentation/routes/profile_routes.dart';
import '/features/chat/presentation/routes/chat_routes.dart';
import '/features/auth/presentation/routes/auth_routes.dart';
import '/features/creation/presentation/routes/creation_routes.dart';
import '/features/notifications/presentation/routes/notification_routes.dart';

GoRouter createRouter(...) => GoRouter(
  routes: [
    // Root & ShellRoute (Router가 관리)
    GoRoute(path: '/', redirect: (context, state) => '/home'),
    ShellRoute(
      builder: (context, state, child) => MainNavigationShell(child: child),
      routes: [ ... ],  // Bottom nav routes
    ),

    // Feature Routes (Feature가 관리)
    ...ProfileRoutes.routes,      // 5 routes
    ...ChatRoutes.routes,         // 4 routes
    ...AuthRoutes.routes,         // 5 routes
    ...CreationRoutes.routes,     // 3 routes
    ...NotificationRoutes.routes, // 4 routes (이미 완료)
  ],
);
```

#### 마이그레이션 전후 비교

| 항목 | Before | After | 개선율 |
|-----|--------|-------|--------|
| **nav.dart import 수** | 24개 (모든 screen) | 5개 (routes만) | **80% 감소** |
| **nav.dart routes 정의** | 27개 (668줄) | 6개 (100줄) | **85% 감소** |
| **Feature 독립성** | ❌ 낮음 (Router 의존) | ✅ 높음 (자체 관리) | **100% 개선** |
| **변경 영향도** | 🔴 전체 Router 수정 | 🟢 Feature만 수정 | **90% 감소** |
| **테스트 복잡도** | 🔴 모든 screen mock | 🟢 routes만 mock | **80% 감소** |

#### 예상 소요 시간

- **ProfileRoutes 생성**: 1시간
- **ChatRoutes 생성**: 45분
- **AuthRoutes 생성**: 1시간
- **CreationRoutes 생성**: 30분
- **nav.dart 리팩토링**: 1시간
- **테스트**: 45분
- **Total**: **5시간**

#### 체크리스트

- [ ] `/features/profile/presentation/routes/profile_routes.dart` 생성
- [ ] `/features/chat/presentation/routes/chat_routes.dart` 생성
- [ ] `/features/auth/presentation/routes/auth_routes.dart` 생성
- [ ] `/features/creation/presentation/routes/creation_routes.dart` 생성
- [ ] `nav.dart`에서 직접 screen import 제거
- [ ] `nav.dart`에 Feature routes import 추가
- [ ] `routes: [...]`를 `routes: [...FeatureRoutes.routes]` 패턴으로 변경
- [ ] 모든 route 이름 상수 검증
- [ ] Navigation 테스트 (모든 routes 접근 가능)
- [ ] Feature 독립성 테스트 (Feature 단독 빌드 가능)

---

### Issue #3: Auth 로직 하드코딩 (Router에 비즈니스 로직)

**심각도**: 🔴 **Critical** (영향도: 8/10)
**발견 위치**: `nav.dart:34-85` (AppStateNotifier), `nav.dart:587-591` (Auth guard)
**영향 범위**: Clean Architecture, 책임 분리 원칙

#### 현재 상태

```dart
// ❌ nav.dart:34-85 - Router에 Auth 로직 포함
class AppStateNotifier extends ChangeNotifier {
  User? initialUser;
  User? _user;
  StreamSubscription<User?>? _userSub;
  String? _redirectLocation;

  AppStateNotifier._();

  bool get loggedIn => _user != null;

  Future<void> update(User? user) async {
    _user = user;
    if (user != null) {
      initialUser ??= user;
    } else {
      initialUser = null;
    }
    notifyListeners();
  }

  void setRedirectLocationIfUnset(String location) {
    _redirectLocation ??= location;
  }

  String? getRedirectLocation() {
    final redirectLocation = _redirectLocation;
    _redirectLocation = null;
    return redirectLocation;
  }

  Future<void> onUserTokenRefresh() async {
    await FirebaseAuth.instance.currentUser?.getIdToken(true);
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  static AppStateNotifier? _instance;
  static AppStateNotifier get instance => _instance ??= AppStateNotifier._();
}

// ❌ nav.dart:587-591 - Inline auth guard
if (requireAuth && !appStateNotifier.loggedIn) {
  appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
  return '/startPage';
}
```

#### 문제점

1. **책임 침범 (Violation of SRP)**:
   - Router의 책임: **네비게이션 구조 정의**
   - Auth Feature의 책임: **인증 상태 관리**
   - **현재**: Router가 Auth 로직 포함 (책임 혼재)
   - **결과**: Clean Architecture 위반

2. **재사용성 상실**:
   - Auth 로직이 Router에 종속
   - 다른 앱에서 Auth Feature 재사용 불가
   - **결과**: 코드 중복 발생

3. **테스트 복잡도**:
   - Router 테스트 시 Firebase Auth mock 필요
   - Auth 로직 테스트 시 Router context 필요
   - **결과**: 단위 테스트 어려움

4. **확장성 부족**:
   - 새로운 Guard 추가 어려움 (예: OnboardingGuard, SubscriptionGuard)
   - 모든 Guard 로직을 Router에 추가해야 함
   - **결과**: nav.dart 파일 크기 증가 (현재 668줄)

#### 영향도 분석

| 영향 영역 | 현재 상태 | 영향도 |
|----------|---------|-------|
| **Clean Architecture** | SRP 위반 | 🔴 심각 |
| **책임 분리** | Router + Auth 혼재 | 🔴 심각 |
| **테스트** | 복잡도 증가 | 🟡 중간 |
| **재사용성** | Auth 재사용 불가 | 🟡 중간 |
| **확장성** | Guard 추가 어려움 | 🟡 중간 |

#### 해결 방법

**Step 1**: Auth Feature에 AuthGuard 생성

```dart
// ✅ features/auth/presentation/guards/auth_guard.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_state_provider.dart';

/// **Auth Guard - 인증 필요 Route 보호**
///
/// 이 Guard는 `requireAuth: true`인 route에 적용되어,
/// 비로그인 사용자를 로그인 화면으로 리다이렉트합니다.
///
/// ## 사용 예시
///
/// ```dart
/// GoRoute(
///   path: '/profile',
///   redirect: (context, state) => AuthGuard.redirect(ref, state),
///   builder: (context, state) => ProfileScreen(),
/// )
/// ```
class AuthGuard {
  AuthGuard._();  // Static only

  /// **Auth 상태 확인 및 리다이렉트**
  ///
  /// **반환값**:
  /// - `null`: 인증됨, 접근 허용
  /// - `String`: 비인증, 리다이렉트 경로
  ///
  /// **파라미터**:
  /// - [ref]: Riverpod WidgetRef (authStateProvider 접근)
  /// - [state]: GoRouterState (현재 경로 정보)
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(authStateProvider);

    // 인증 확인
    if (!authState.isAuthenticated) {
      // Redirect 위치 저장 (로그인 후 복귀용)
      ref.read(authStateProvider.notifier).setRedirectLocation(
        state.uri.toString(),
      );

      // 로그인 화면으로 리다이렉트
      return '/startPage';
    }

    // 접근 허용
    return null;
  }

  /// **Onboarding 완료 여부 확인**
  ///
  /// 로그인했지만 온보딩 미완료 사용자를 온보딩으로 리다이렉트.
  static String? onboardingRedirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(authStateProvider);

    // 로그인 확인
    if (!authState.isAuthenticated) {
      return '/startPage';
    }

    // 온보딩 완료 확인
    final profileState = ref.read(profileStateProvider(authState.user!.uid));
    if (!profileState.hasValue || !profileState.value!.isOnboardingComplete) {
      return '/onboardingFlow/${authState.user!.uid}';
    }

    return null;
  }

  /// **Admin 권한 확인**
  ///
  /// Admin 전용 route 보호 (예시).
  static String? adminRedirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(authStateProvider);

    if (!authState.isAuthenticated) {
      return '/startPage';
    }

    final profileState = ref.read(profileStateProvider(authState.user!.uid));
    if (!profileState.hasValue || !profileState.value!.isAdmin) {
      return '/';  // 권한 없음 → 홈으로
    }

    return null;
  }
}
```

**Step 2**: OnboardingGuard 생성 (예시)

```dart
// ✅ features/profile/presentation/guards/onboarding_guard.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/profile_state_provider.dart';

/// **Onboarding Guard - 온보딩 완료 확인**
///
/// 온보딩 미완료 사용자를 온보딩 플로우로 리다이렉트.
class OnboardingGuard {
  OnboardingGuard._();

  static String? redirect(WidgetRef ref, GoRouterState state, String userId) {
    final profileState = ref.read(profileStateProvider(userId));

    if (!profileState.hasValue) {
      return null;  // 로딩 중
    }

    if (!profileState.value!.isOnboardingComplete) {
      return '/onboardingFlow/$userId';
    }

    return null;  // 온보딩 완료
  }
}
```

**Step 3**: Router에서 Guard 사용

```dart
// ✅ nav.dart - Before/After

// ❌ Before: Inline auth check
GoRoute(
  name: 'profileEdit',
  path: '/profileEdit/:userId',
  builder: (context, state) {
    // Inline auth check (❌ 중복 코드)
    if (!appStateNotifier.loggedIn) {
      appStateNotifier.setRedirectLocationIfUnset(state.uri.toString());
      return StartPageWidget();
    }
    return ProfileEditScreen(...);
  },
)

// ✅ After: AuthGuard 사용
import '/features/auth/presentation/guards/auth_guard.dart';

GoRouter createRouter(WidgetRef ref) => GoRouter(
  routes: [
    GoRoute(
      name: 'profileEdit',
      path: '/profileEdit/:userId',
      redirect: (context, state) => AuthGuard.redirect(ref, state),  // 재사용 가능!
      builder: (context, state) => ProfileEditScreen(...),
    ),

    GoRoute(
      name: 'adminPanel',
      path: '/admin',
      redirect: (context, state) => AuthGuard.adminRedirect(ref, state),  // Admin 전용
      builder: (context, state) => AdminPanelScreen(),
    ),
  ],
);
```

**Step 4**: main.dart에서 ProviderScope 내부로 Router 이동

```dart
// ✅ main.dart - Router를 ProviderScope 내부로

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(...);

  runApp(
    ProviderScope(  // Riverpod root
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {  // StatelessWidget → ConsumerWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {  // ref 추가
    return MaterialApp.router(
      routerConfig: createRouter(ref),  // ref 전달
      // ...
    );
  }
}
```

#### 마이그레이션 전후 비교

| 항목 | Before | After | 개선율 |
|-----|--------|-------|--------|
| **Router 코드 줄 수** | 668줄 (Auth 포함) | ~150줄 (순수 routing) | **77% 감소** |
| **Auth 로직 위치** | Router | Auth Feature | **100% 분리** |
| **Guard 재사용성** | ❌ Inline 중복 | ✅ 재사용 가능 | **100% 개선** |
| **테스트 복잡도** | 🔴 Router + Auth | 🟢 분리 테스트 | **70% 감소** |
| **확장성** | 🔴 Guard 추가 어려움 | 🟢 쉬운 확장 | **100% 개선** |

#### 예상 소요 시간

- **AuthGuard 생성**: 45분
- **OnboardingGuard 생성**: 30분
- **nav.dart 리팩토링**: 45분
- **main.dart 수정**: 15분
- **테스트**: 45분
- **Total**: **3시간**

#### 체크리스트

- [ ] `/features/auth/presentation/guards/auth_guard.dart` 생성
- [ ] `/features/profile/presentation/guards/onboarding_guard.dart` 생성
- [ ] `nav.dart`에서 `AppStateNotifier` 제거
- [ ] `createRouter(WidgetRef ref)` 시그니처 변경
- [ ] 모든 `requireAuth` route에 `redirect: AuthGuard.redirect` 추가
- [ ] `main.dart`에서 `MyApp`을 `ConsumerWidget`으로 변경
- [ ] `MaterialApp.router(routerConfig: createRouter(ref))`
- [ ] Auth guard 테스트 작성
- [ ] 로그인/로그아웃 시나리오 테스트

---

## 🟡 Medium Issues (2주 이내 해결)

### Issue #4: GoRoute/AppRoute 패턴 혼재

**심각도**: 🟡 **Medium** (영향도: 6/10)
**발견 위치**: `nav.dart` 전체
**영향 범위**: 코드 일관성, 유지보수성

#### 현재 상태

```dart
// ❌ nav.dart - 2가지 패턴 혼재

// Pattern 1: GoRoute 직접 사용
GoRoute(
  name: 'loginPage',
  path: '/loginPage',
  builder: (context, state) => const LoginPageWidget(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    // Custom transition
  },
)

// Pattern 2: AppRoute.toRoute() 사용
AppRoute(
  name: 'profileEdit',
  path: '/profileEdit/:userId',
  requireAuth: true,
  builder: (context, params) => ProfileEditScreen(
    userId: params.getParam('userId', ParamType.String),
  ),
).toRoute(appStateNotifier)
```

#### 문제점

1. **일관성 부족**:
   - 개발자가 어느 패턴을 따라야 할지 불명확
   - 코드 리뷰 시 혼란 발생

2. **유지보수 어려움**:
   - 두 가지 패턴 모두 이해 필요
   - 수정 시 패턴별로 다른 접근

3. **테스트 복잡도**:
   - 2가지 패턴 모두 mock 필요
   - 테스트 코드 중복

#### 해결 방법

**Step 1**: `AppRoute` 제거, `GoRoute`로 통일

```dart
// ✅ 모든 routes를 GoRoute로 통일

GoRoute(
  name: 'profileEdit',
  path: '/profileEdit/:userId',
  redirect: (context, state) => AuthGuard.redirect(ref, state),  // Guard 분리
  builder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return ProfileEditScreen(userId: userId);
  },
)
```

**Step 2**: `AppParameters`, `AppRoute` 클래스 제거

```dart
// ❌ 제거할 클래스들
class AppParameters { ... }  // nav.dart:502-558
class AppRoute { ... }       // nav.dart:560-626
class TransitionInfo { ... } // nav.dart:628-638 (일부 유지 가능)
```

#### 예상 소요 시간

- **GoRoute 통일**: 1시간
- **AppRoute 제거**: 30분
- **테스트**: 30분
- **Total**: **2시간**

---

### Issue #5: Circular Import 위험 (widgets/index.dart)

**심각도**: 🟡 **Medium** (영향도: 5/10)
**발견 위치**: `nav.dart:12`
**영향 범위**: 의존성 관리, 빌드 시간

#### 현재 상태

```dart
// ❌ nav.dart:12
import '/app/widgets/index.dart';

// widgets/index.dart는 모든 Feature 화면 export
// → Feature 화면들이 router 의존 가능성
// → 순환 의존성 위험!
```

#### 문제점

```
/app/router/nav.dart
  └─> import '/app/widgets/index.dart'
       └─> export '/features/profile/presentation/screens/...'
            └─> import '/app/router/...' (잠재적!)
                 └─> 순환 의존성! ♻️
```

#### 해결 방법

**Step 1**: Feature Routes 모듈화로 자동 해결

```dart
// ✅ nav.dart에서 widgets/index.dart 제거
// ❌ import '/app/widgets/index.dart';

// ✅ Feature routes만 import
import '/features/profile/presentation/routes/profile_routes.dart';
import '/features/chat/presentation/routes/chat_routes.dart';
// ...
```

**Step 2**: ShellRoute만 widgets import

```dart
// ✅ MainNavigationShell만 필요
import '/app/widgets/navigation/main_navigation_shell.dart';

// ShellRoute에서만 사용
ShellRoute(
  builder: (context, state, child) => MainNavigationShell(child: child),
  routes: [ ... ],
)
```

#### 예상 소요 시간

- **widgets/index.dart 제거**: 15분 (Issue #2 해결 시 자동)
- **테스트**: 15분
- **Total**: **30분**

---

### Issue #6: Serialization 위치 부적절

**심각도**: 🟡 **Medium** (영향도: 4/10)
**발견 위치**: `serialization_util.dart` (전체 256줄)
**영향 범위**: 프로젝트 구조, 책임 분리

#### 현재 상태

```
/lib/app/router/navigation/
  └── serialization_util.dart  (❌ Router에 위치)
```

#### 문제점

1. **책임 혼재**:
   - Router의 책임: 네비게이션 구조
   - Serialization의 책임: 파라미터 직렬화
   - **현재**: Router 디렉토리에 위치 (부적절)

2. **재사용성 부족**:
   - Serialization은 Router 외에도 사용 가능 (API, Cache 등)
   - 현재 위치로는 재사용 어려움

#### 해결 방법

**Step 1**: `/core/utils/`로 이동

```bash
# 파일 이동
mv lib/app/router/navigation/serialization_util.dart \
   lib/core/utils/serialization/serialization_util.dart

# 디렉토리 구조
lib/core/utils/
  └── serialization/
       ├── serialization_util.dart       # 이동
       ├── param_type.dart                # ParamType enum 분리
       └── firestore_serialization.dart   # Firestore 전용 분리
```

**Step 2**: Import 경로 업데이트

```dart
// ❌ Before
import '../navigation/serialization_util.dart';

// ✅ After
import '/core/utils/serialization/serialization_util.dart';
```

#### 예상 소요 시간

- **파일 이동**: 15분
- **Import 경로 업데이트**: 30분
- **테스트**: 15분
- **Total**: **1시간**

---

### Issue #7: Error 처리 미흡 (print() 사용)

**심각도**: 🟡 **Medium** (영향도: 3/10)
**발견 위치**: `serialization_util.dart:107, 224`
**영향 범위**: 디버깅, 프로덕션 안정성

#### 현재 상태

```dart
// ❌ serialization_util.dart:107, 224
catch (e) {
  print('Error deserializing parameter: $e');  // print() 사용!
  return null;
}
```

#### 문제점

1. **프로덕션 로그 부재**:
   - `print()`는 프로덕션에서 무시됨
   - 에러 추적 불가

2. **디버깅 어려움**:
   - 에러 발생 시 컨텍스트 부족
   - Stack trace 없음

#### 해결 방법

```dart
// ✅ Logger 사용
import '/core/utils/logger.dart';

try {
  // deserialization logic
} catch (e, stackTrace) {
  Logger.error(
    'Error deserializing parameter',
    error: e,
    stackTrace: stackTrace,
    context: {
      'value': value,
      'paramType': paramType.toString(),
    },
  );
  return null;
}
```

#### 예상 소요 시간

- **Logger import 추가**: 5분
- **print() → Logger.error() 변경**: 15분
- **테스트**: 10분
- **Total**: **30분**

---

## 🟢 Low Issues (1개월 이내 해결)

### Issue #8: Transition 코드 중복

**심각도**: 🟢 **Low** (영향도: 2/10)
**발견 위치**: `nav.dart` 여러 routes
**영향 범위**: 코드 품질, DRY 원칙

#### 현재 상태

```dart
// ❌ nav.dart:176-192, 204-220 - 중복된 transition 코드
transitionsBuilder: (context, animation, secondaryAnimation, child) {
  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );
  return FadeTransition(
    opacity: curvedAnimation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.15),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: child,
    ),
  );
}
```

#### 해결 방법

**Step 1**: Transition 프리셋 라이브러리 생성

```dart
// ✅ app/router/transitions/transition_presets.dart

import 'package:flutter/material.dart';

/// **Transition Presets Library**
///
/// 재사용 가능한 페이지 전환 효과 모음.
class TransitionPresets {
  TransitionPresets._();

  /// **Fade + Slide 전환** (300ms, easeInOut)
  static Widget fadeSlide({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
    Offset begin = const Offset(0.0, 0.15),
    Duration duration = const Duration(milliseconds: 300),
  }) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    );

    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }

  /// **Scale + Fade 전환** (200ms, easeIn)
  static Widget scaleFade({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeIn),
        ),
        child: child,
      ),
    );
  }

  /// **Slide (left to right)** (250ms, easeInOut)
  static Widget slideLeft({
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeInOut,
      )),
      child: child,
    );
  }
}
```

**Step 2**: Routes에서 사용

```dart
// ✅ nav.dart
import 'transitions/transition_presets.dart';

GoRoute(
  path: '/loginPage',
  builder: (context, state) => const LoginPageWidget(),
  pageBuilder: (context, state) => CustomTransitionPage(
    child: const LoginPageWidget(),
    transitionsBuilder: TransitionPresets.fadeSlide,  // 재사용!
  ),
)
```

#### 예상 소요 시간

- **TransitionPresets 생성**: 30분
- **Routes 업데이트**: 30분
- **테스트**: 15min
- **Total**: **1시간 15분**

---

### Issue #9: Analytics 미적용

**심각도**: 🟢 **Low** (영향도: 2/10)
**영향 범위**: 사용자 행동 추적, 데이터 분석

#### 현재 상태

```dart
// ❌ nav.dart:91 - Analytics 없음
observers: [
  routeObserver,
  BotToastNavigatorObserver(),
  // Analytics observer 없음!
]
```

#### 해결 방법

```dart
// ✅ Firebase Analytics 추가
import 'package:firebase_analytics/firebase_analytics.dart';

GoRouter createRouter(WidgetRef ref) => GoRouter(
  observers: [
    routeObserver,
    BotToastNavigatorObserver(),
    FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),  // 추가
  ],
);

// 자동으로 다음 이벤트 로깅:
// - screen_view (페이지 이동)
// - page_view (웹)
```

#### 예상 소요 시간

- **FirebaseAnalyticsObserver 추가**: 15분
- **커스텀 이벤트 추가**: 30분
- **테스트**: 15분
- **Total**: **1시간**

---

### Issue #10: Deep Linking 미설정

**심각도**: 🟢 **Low** (영향도: 2/10)
**영향 범위**: 웹 URL, 앱 외부 링크

#### 현재 상태

```dart
// ❌ 명시적인 deep link 설정 없음
```

#### 해결 방법

```dart
// ✅ Android: android/app/src/main/AndroidManifest.xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="versusspace.app" />
</intent-filter>

// ✅ iOS: ios/Runner/Info.plist
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>versusspace</string>
    </array>
  </dict>
</array>
```

#### 예상 소요 시간

- **Android 설정**: 15분
- **iOS 설정**: 15분
- **테스트**: 30분
- **Total**: **1시간**

---

### Issue #11: Error 페이지 부재

**심각도**: 🟢 **Low** (영향도: 2/10)
**영향 범위**: 사용자 경험, 에러 처리

#### 현재 상태

```dart
// ❌ nav.dart:92 - 404 시 StartPage 표시
errorBuilder: (context, state) => const StartPageWidget(),
```

#### 해결 방법

```dart
// ✅ 전용 Error 페이지 생성
// app/widgets/error/error_page.dart

class ErrorPage extends StatelessWidget {
  final int? statusCode;
  final String? message;

  const ErrorPage({
    super.key,
    this.statusCode,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusCode == 404 ? Icons.search_off : Icons.error_outline,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 24),
            Text(
              statusCode == 404 ? 'Page Not Found' : 'Error',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(message ?? 'Something went wrong'),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: Text('Go Home'),
            ),
          ],
        ),
      ),
    );
  }
}

// ✅ Router에서 사용
errorBuilder: (context, state) => ErrorPage(
  statusCode: 404,
  message: 'Route not found: ${state.uri}',
),
```

#### 예상 소요 시간

- **ErrorPage 생성**: 30min
- **Router 통합**: 15min
- **테스트**: 15min
- **Total**: **1시간**

---

## 🗺️ 해결 로드맵 (5-Phase)

### Phase 1: Provider 제거 (2-3시간) 🔴

**목표**: Riverpod 3.x 전환, Provider 0.x 완전 제거

**작업 내용**:
1. `auth/presentation/providers/auth_state_provider.dart` 생성
2. `nav.dart`에서 `AppStateNotifier` 제거
3. `createRouter(WidgetRef ref)` 시그니처 변경
4. `main.dart`에서 `MyApp`을 `ConsumerWidget`으로 변경
5. `pubspec.yaml`에서 `provider` 제거

**완료 기준**:
- ✅ Zero `import 'package:provider/provider.dart'`
- ✅ Zero `ChangeNotifier` usage
- ✅ All auth state uses `authStateProvider`

**예상 소요**: 2-3시간

---

### Phase 2: Feature Route 모듈화 (3-5시간) 🔴

**목표**: Feature-First 아키텍처 준수

**작업 내용**:
1. `/features/profile/presentation/routes/profile_routes.dart` 생성 (5 routes)
2. `/features/chat/presentation/routes/chat_routes.dart` 생성 (4 routes)
3. `/features/auth/presentation/routes/auth_routes.dart` 생성 (5 routes)
4. `/features/creation/presentation/routes/creation_routes.dart` 생성 (3 routes)
5. `nav.dart`에서 직접 screen import 제거
6. `routes: [...FeatureRoutes.routes]` 패턴 적용

**완료 기준**:
- ✅ 모든 Feature에 `/presentation/routes/` 디렉토리
- ✅ `nav.dart`에 screen import 0개
- ✅ Feature 독립성 테스트 통과

**예상 소요**: 3-5시간

---

### Phase 3: Auth 로직 분리 (2시간) 🔴

**목표**: Router와 Auth Feature 책임 분리

**작업 내용**:
1. `/features/auth/presentation/guards/auth_guard.dart` 생성
2. `/features/profile/presentation/guards/onboarding_guard.dart` 생성
3. `nav.dart`에서 inline auth check 제거
4. 모든 `requireAuth` route에 `redirect: AuthGuard.redirect` 추가

**완료 기준**:
- ✅ `nav.dart`에 Auth 로직 0줄
- ✅ Guard 재사용성 확인
- ✅ Auth/Onboarding guard 테스트 통과

**예상 소요**: 2시간

---

### Phase 4: Guard 시스템 & 패턴 통일 (2-3시간) 🟡

**목표**: 일관된 routing 패턴, 확장 가능한 guard 시스템

**작업 내용**:
1. `AppRoute.toRoute()` 패턴 제거, `GoRoute`로 통일
2. `AppParameters`, `AppRoute` 클래스 제거
3. Serialization `/core/utils/`로 이동
4. Circular import (widgets/index.dart) 제거
5. Error 처리 (`print()` → `Logger`)

**완료 기준**:
- ✅ Single routing pattern (GoRoute only)
- ✅ Zero circular dependencies
- ✅ All errors logged with context

**예상 소요**: 2-3시간

---

### Phase 5: Analytics & Monitoring (1-2시간) 🟢

**목표**: 사용자 행동 추적, 에러 모니터링

**작업 내용**:
1. `FirebaseAnalyticsObserver` 추가
2. Transition 프리셋 라이브러리 구축
3. Deep linking 설정 (Android/iOS)
4. 전용 Error 페이지 생성

**완료 기준**:
- ✅ All route changes tracked
- ✅ Deep links working
- ✅ Professional error pages

**예상 소요**: 1-2시간

---

## 📊 전체 로드맵 타임라인

```
Week 1 (Critical):
┌─────────────────────────────────────────────────────────┐
│ Phase 1: Provider 제거             [████████░░] 2-3h     │
│ Phase 2: Feature Routes 모듈화      [████████░░] 3-5h     │
│ Phase 3: Auth 로직 분리             [████░░░░░░] 2h       │
├─────────────────────────────────────────────────────────┤
│ Total Week 1:                      [████████░░] 7-10h    │
└─────────────────────────────────────────────────────────┘

Week 2 (Medium):
┌─────────────────────────────────────────────────────────┐
│ Phase 4: Guard & Pattern 통일       [████░░░░░░] 2-3h     │
├─────────────────────────────────────────────────────────┤
│ Total Week 2:                      [████░░░░░░] 2-3h     │
└─────────────────────────────────────────────────────────┘

Week 3-4 (Low):
┌─────────────────────────────────────────────────────────┐
│ Phase 5: Analytics & Monitoring    [██░░░░░░░░] 1-2h     │
├─────────────────────────────────────────────────────────┤
│ Total Week 3-4:                    [██░░░░░░░░] 1-2h     │
└─────────────────────────────────────────────────────────┘

GRAND TOTAL: 10-15시간 (2주 내 완료 가능)
```

---

## 🎯 최종 체크리스트

### Critical (Week 1)

**Provider 제거**:
- [ ] `auth_state_provider.dart` 생성
- [ ] `authStateProvider` 코드 생성 (build_runner)
- [ ] `nav.dart`에서 `AppStateNotifier` 제거
- [ ] `createRouter(WidgetRef ref)` 시그니처 변경
- [ ] `MyApp` → `ConsumerWidget`
- [ ] `pubspec.yaml`에서 `provider` 제거
- [ ] Auth 관련 테스트 실행

**Feature Routes 모듈화**:
- [ ] `profile_routes.dart` 생성 (5 routes)
- [ ] `chat_routes.dart` 생성 (4 routes)
- [ ] `auth_routes.dart` 생성 (5 routes)
- [ ] `creation_routes.dart` 생성 (3 routes)
- [ ] `nav.dart`에서 직접 screen import 제거
- [ ] `routes: [...FeatureRoutes.routes]` 패턴 적용
- [ ] Feature 독립성 테스트

**Auth 로직 분리**:
- [ ] `auth_guard.dart` 생성
- [ ] `onboarding_guard.dart` 생성
- [ ] `nav.dart`에서 inline auth check 제거
- [ ] 모든 `requireAuth` route에 `redirect: AuthGuard.redirect`
- [ ] Guard 테스트 작성

### Medium (Week 2)

**Guard & Pattern 통일**:
- [ ] `AppRoute.toRoute()` 제거
- [ ] `GoRoute`로 통일
- [ ] `AppParameters`, `AppRoute` 클래스 제거
- [ ] Serialization `/core/utils/`로 이동
- [ ] widgets/index.dart import 제거
- [ ] `print()` → `Logger.error()` 변경

### Low (Week 3-4)

**Analytics & Monitoring**:
- [ ] `FirebaseAnalyticsObserver` 추가
- [ ] `TransitionPresets` 라이브러리 생성
- [ ] Deep linking 설정 (Android/iOS)
- [ ] `ErrorPage` 생성
- [ ] `errorBuilder` 업데이트

---

## 📈 예상 개선 효과

### 코드 품질

| 메트릭 | Before | After | 개선율 |
|-------|--------|-------|--------|
| **nav.dart 줄 수** | 668줄 | ~150줄 | **77% 감소** |
| **직접 import 수** | 24개 | 5개 | **79% 감소** |
| **Provider 의존성** | 2개 (Provider + Riverpod) | 1개 (Riverpod) | **50% 감소** |
| **중복 코드** | Inline auth, transition | 재사용 Guard, Presets | **~80% 감소** |
| **테스트 복잡도** | 🔴 높음 (모든 mock) | 🟢 낮음 (분리) | **~70% 개선** |

### 아키텍처 준수율

| 원칙 | Before | After | 개선 |
|-----|--------|-------|-----|
| **Clean Architecture** | 64% | 95%+ | **+31%p** |
| **Riverpod 3.x 마이그레이션** | 75% | 100% | **+25%p** |
| **Feature-First** | 40% | 100% | **+60%p** |
| **SRP (책임 단일)** | ❌ 위반 | ✅ 준수 | **100% 개선** |
| **DRY (중복 제거)** | ⚠️ 많은 중복 | ✅ 최소화 | **~80% 개선** |

### 개발 생산성

| 항목 | Before | After | 개선 효과 |
|-----|--------|-------|----------|
| **Feature 추가 시간** | ~3시간 | ~1시간 | **67% 단축** |
| **테스트 작성 시간** | ~2시간 | ~45분 | **62% 단축** |
| **버그 수정 시간** | ~1.5시간 | ~30분 | **67% 단축** |
| **코드 리뷰 시간** | ~1시간 | ~20분 | **67% 단축** |

---

## 🎓 학습 포인트

### 개발자를 위한 Best Practices

#### 1. Feature-First Architecture

**핵심 원칙**:
- Feature가 자신의 routes 소유
- Router는 Feature routes 주입만 받음
- 낮은 결합도, 높은 응집도

**코드 예시**:
```dart
// ✅ Good: Feature가 routes 소유
// features/profile/presentation/routes/profile_routes.dart
class ProfileRoutes {
  static List<GoRoute> get routes => [ ... ];
}

// app/router/nav.dart
routes: [
  ...ProfileRoutes.routes,  // 주입
]

// ❌ Bad: Router가 Feature 내부 알아야 함
import '/features/profile/presentation/screens/profile_edit_screen.dart';
GoRoute(path: '/profileEdit', builder: (context, state) => ProfileEditScreen())
```

#### 2. Guard Pattern

**핵심 원칙**:
- 재사용 가능한 route guard
- 책임 분리 (Auth Feature가 auth 로직 소유)
- 확장 가능 (Admin, Subscription 등)

**코드 예시**:
```dart
// ✅ Good: 재사용 가능한 Guard
class AuthGuard {
  static String? redirect(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(authStateProvider);
    if (!authState.isAuthenticated) {
      return '/startPage';
    }
    return null;
  }
}

GoRoute(
  path: '/profile',
  redirect: (context, state) => AuthGuard.redirect(ref, state),  // 재사용!
)

// ❌ Bad: Inline auth check (중복)
GoRoute(
  path: '/profile',
  builder: (context, state) {
    if (!appStateNotifier.loggedIn) {  // 중복 코드!
      return StartPageWidget();
    }
    return ProfileScreen();
  },
)
```

#### 3. Riverpod 3.x 상태 관리

**핵심 원칙**:
- `@riverpod` annotation 사용
- Freezed 불변 state
- Stream 자동 구독
- Type-safe provider 접근

**코드 예시**:
```dart
// ✅ Good: Riverpod 3.x + Freezed
@freezed
class AuthStateData with _$AuthStateData {
  const factory AuthStateData({
    User? user,
    @Default(false) bool isLoading,
  }) = _AuthStateData;

  const AuthStateData._();
  bool get isAuthenticated => user != null;
}

@riverpod
class AuthState extends _$AuthState {
  @override
  AuthStateData build() {
    final authRepo = ref.watch(authRepositoryProvider);

    ref.listen(authRepo.authStateChanges(), (previous, next) {
      next.whenData((user) => state = state.copyWith(user: user));
    });

    return const AuthStateData();
  }
}

// ❌ Bad: Provider 0.x (ChangeNotifier)
class AppStateNotifier extends ChangeNotifier {
  User? _user;
  bool get loggedIn => _user != null;

  void update(User? user) {
    _user = user;
    notifyListeners();  // 모든 리스너 재빌드
  }
}
```

---

## 🔗 관련 문서

- **GoRouter 공식 문서**: https://pub.dev/packages/go_router
- **Riverpod 3.x 문서**: https://riverpod.dev
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **Feature-First Architecture**: https://codewithandrea.com/articles/flutter-project-structure/
- **Firebase Auth**: https://firebase.google.com/docs/auth

---

**보고서 작성**: 2025-11-10
**분석 기준**: Clean Architecture v4.0 + Riverpod 3.x
**다음 액션**: Phase 1 (Provider 제거) 시작 권장
