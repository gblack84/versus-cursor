# 🚀 Migration Part 3: Router System Refactoring

> Feature-First Architecture를 위한 라우터 시스템 대규모 리팩토링  
> 작성일: 2025-08-27 | 대상: /lib/app/router

## 📋 개요

이 문서는 `/lib/app/router`의 현재 모놀리식 라우팅 시스템을 Feature-First Architecture에 맞게 모듈화하고 리팩토링하는 가이드입니다.
현재 542줄의 단일 파일(nav.dart)을 적절히 분리하고, Feature별 라우트 독립성을 확보합니다.

## 🎯 마이그레이션 목표

### 주요 목표
1. **파일 분리**: nav.dart를 기능별로 분리 (542줄 → 5개 파일)
2. **Feature 독립성**: 각 Feature가 자체 라우트 관리
3. **DI 통합**: 라우터를 DI 시스템에 통합
4. **Guard 시스템**: 체계적인 라우트 보호 메커니즘
5. **테스트 가능성**: 라우트 단위 테스트 가능

### 성공 지표
- [ ] 모든 Feature 직접 import 제거
- [ ] 라우트 파일 크기 < 200줄
- [ ] Feature별 라우트 독립 관리
- [ ] 테스트 커버리지 80%+

## 🔍 현재 상태 분석

### 현재 파일 구조
```
lib/app/router/
└── navigation/
    ├── nav.dart (542줄 - 모든 것이 한 파일에)
    ├── serialization_util.dart (270줄)
    └── README.md
```

### 문제점 상세 분석

#### 1. 단일 파일 과부하 (nav.dart)
```dart
// 현재: 모든 것이 한 파일에
class AppStateNotifier { }    // 73줄
GoRouter createRouter() { }    // 210줄
class AppRoute { }            // 50줄
class NavigationExtensions { } // 80줄
class TransitionInfo { }      // 30줄
class AppParameters { }       // 50줄
// 총 542줄
```

#### 2. Feature 직접 의존성
```dart
// 현재: Feature 페이지 직접 import
import '/pages/home/home_page_widget.dart';
import '/pages/profile/profile_page_widget.dart';
import '/pages/chat/chat_list_widget.dart';
// ... 30개 이상의 직접 import
```

#### 3. 라우트 하드코딩
```dart
// 현재: 모든 라우트가 중앙에 하드코딩
GoRoute(
  name: HomePageWidget.routeName,
  path: HomePageWidget.routePath,
  builder: (context, state) => HomePageWidget(),
),
// ... 30개 이상의 라우트
```

#### 4. serialization_util.dart 문제점 (270줄)
```dart
// 현재: 미사용 타입 처리
String placeToString(AppPlace place) { }  // 실제 사용 안 됨
LatLng? latLngFromString(String? str) { } // 실제 사용 안 됨

// 임시 import 사용
import '/core_exports.dart';  // Temporary - all models from bridge

// 13가지 타입을 단일 파일에서 처리
enum ParamType {
  int, double, String, bool, DateTime, DateTimeRange,
  LatLng, Color, AppPlace, AppUploadedFile, JSON,
  Document, DocumentReference,
}
```

## 📝 마이그레이션 계획

## Phase 1: 파일 분리 및 구조 정리 (Day 1-2)

### Step 1: 디렉토리 구조 생성
```bash
# 새로운 구조 생성
mkdir -p lib/app/router/{guards,transitions,config,state,serialization}
```

### Step 2: AppStateNotifier 분리
```dart
// lib/app/router/state/auth_state_notifier.dart
import 'package:flutter/material.dart';
import '/features/auth/domain/models/base_auth_user.dart';

@injectable
class AuthStateNotifier extends ChangeNotifier {
  BaseAuthUser? _user;
  bool _showSplashImage = true;
  String? _redirectLocation;
  
  bool get loggedIn => _user?.loggedIn ?? false;
  bool get loading => _showSplashImage;
  
  void update(BaseAuthUser newUser) {
    _user = newUser;
    notifyListeners();
  }
  
  void stopShowingSplashImage() {
    _showSplashImage = false;
    notifyListeners();
  }
}
```

### Step 3: 라우터 코어 분리
```dart
// lib/app/router/router.dart
import 'package:go_router/go_router.dart';
import 'package:get_it/get_it.dart';

@lazySingleton
class AppRouter {
  final AuthStateNotifier _authState;
  final List<RouteBase> _featureRoutes;
  
  AppRouter(
    this._authState,
    @factoryParam this._featureRoutes,
  );
  
  late final GoRouter router = GoRouter(
    initialLocation: '/',
    refreshListenable: _authState,
    routes: _buildRoutes(),
    redirect: _handleRedirect,
  );
  
  List<RouteBase> _buildRoutes() {
    return [
      _buildRootRoute(),
      _buildShellRoute(),
      ..._featureRoutes,
    ];
  }
  
  String? _handleRedirect(BuildContext context, GoRouterState state) {
    // 인증 및 권한 체크 로직
  }
}
```

### Step 4: 라우트 상수 분리
```dart
// lib/app/router/routes.dart
abstract class AppRoutes {
  // 루트 라우트
  static const String root = '/';
  static const String splash = '/splash';
  
  // Shell 라우트
  static const String home = '/home';
  static const String search = '/search';
  static const String profile = '/profile';
  static const String chat = '/chat';
  
  // 인증 라우트
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
}
```

### Step 5: Serialization 시스템 정리
```dart
// lib/app/router/serialization/base_serializer.dart
class BaseSerializer {
  // 기본 타입만 처리
  static String? serialize(dynamic param, BaseParamType type) {
    switch (type) {
      case BaseParamType.int:
        return param.toString();
      case BaseParamType.double:
        return param.toString();
      case BaseParamType.string:
        return param;
      case BaseParamType.bool:
        return param ? 'true' : 'false';
      case BaseParamType.dateTime:
        return (param as DateTime).millisecondsSinceEpoch.toString();
      case BaseParamType.json:
        return json.encode(param);
      default:
        return null;
    }
  }
}

// lib/app/router/serialization/firebase_serializer.dart
@injectable
class FirebaseSerializer {
  // Firebase 특화 타입만 처리
  static String? serializeDocumentReference(DocumentReference ref) {
    // DocumentReference 직렬화 로직
  }
  
  static DocumentReference? deserializeDocumentReference(
    String refStr,
    List<String> collectionNamePath,
  ) {
    // DocumentReference 역직렬화 로직
  }
}

// lib/app/router/serialization/param_type.dart
enum BaseParamType {
  int,
  double,
  string,
  bool,
  dateTime,
  json,
}

enum FirebaseParamType {
  documentReference,
  document,
}

// 미사용 타입 제거: LatLng, AppPlace, DateTimeRange
```

## Phase 2: Feature 라우트 모듈화 (Day 3-5)

### Step 1: Feature 라우트 인터페이스 정의
```dart
// lib/app/router/interfaces/feature_route.dart
abstract class IFeatureRoute {
  String get path;
  String get name;
  List<GoRoute> get routes;
  bool requireAuth() => false;
}
```

### Step 2: Auth Feature 라우트
```dart
// lib/features/auth/presentation/routes/auth_routes.dart
@injectable
class AuthRoutes implements IFeatureRoute {
  @override
  String get path => '/auth';
  
  @override
  String get name => 'auth';
  
  @override
  List<GoRoute> get routes => [
    GoRoute(
      path: 'login',
      name: '${name}_login',
      pageBuilder: (context, state) => MaterialPage(
        child: getIt<LoginScreen>(),
      ),
    ),
    GoRoute(
      path: 'signup',
      name: '${name}_signup',
      pageBuilder: (context, state) => MaterialPage(
        child: getIt<SignupScreen>(),
      ),
    ),
    GoRoute(
      path: 'forgot-password',
      name: '${name}_forgot_password',
      pageBuilder: (context, state) => MaterialPage(
        child: getIt<ForgotPasswordScreen>(),
      ),
    ),
  ];
}
```

### Step 3: Posts Feature 라우트
```dart
// lib/features/posts/presentation/routes/posts_routes.dart
@injectable
class PostsRoutes implements IFeatureRoute {
  @override
  String get path => '/posts';
  
  @override
  String get name => 'posts';
  
  @override
  bool requireAuth() => true;
  
  @override
  List<GoRoute> get routes => [
    GoRoute(
      path: 'create',
      name: '${name}_create',
      pageBuilder: (context, state) => MaterialPage(
        child: getIt<CreatePostScreen>(),
      ),
    ),
    GoRoute(
      path: ':id',
      name: '${name}_detail',
      pageBuilder: (context, state) => MaterialPage(
        child: PostDetailScreen(
          postId: state.pathParameters['id']!,
        ),
      ),
    ),
  ];
}
```

### Step 4: Feature 라우트 등록
```dart
// lib/app/router/config/feature_route_registry.dart
@module
abstract class FeatureRouteRegistry {
  @lazySingleton
  List<IFeatureRoute> get featureRoutes => [
    getIt<AuthRoutes>(),
    getIt<PostsRoutes>(),
    getIt<ChatRoutes>(),
    getIt<ProfileRoutes>(),
    getIt<VotingRoutes>(),
    getIt<NotificationsRoutes>(),
    getIt<SearchRoutes>(),
  ];
}
```

## Phase 3: Guard 시스템 구축 (Day 6-7)

### Step 1: Guard 인터페이스
```dart
// lib/app/router/guards/route_guard.dart
abstract class RouteGuard {
  FutureOr<String?> canActivate(
    BuildContext context,
    GoRouterState state,
  );
}
```

### Step 2: 인증 Guard
```dart
// lib/app/router/guards/auth_guard.dart
@injectable
class AuthGuard implements RouteGuard {
  final AuthService _authService;
  
  AuthGuard(this._authService);
  
  @override
  FutureOr<String?> canActivate(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isLoggedIn = await _authService.isLoggedIn();
    
    if (!isLoggedIn && _requiresAuth(state.uri.path)) {
      // 현재 경로 저장 후 로그인으로 리다이렉트
      getIt<AuthStateNotifier>().setRedirectLocation(state.uri.toString());
      return '/auth/login';
    }
    
    if (isLoggedIn && _isAuthRoute(state.uri.path)) {
      // 이미 로그인된 상태에서 인증 페이지 접근 시 홈으로
      return '/home';
    }
    
    return null; // 통과
  }
  
  bool _requiresAuth(String path) {
    final protectedPaths = [
      '/profile',
      '/posts/create',
      '/chat',
      '/notifications',
    ];
    return protectedPaths.any((p) => path.startsWith(p));
  }
  
  bool _isAuthRoute(String path) {
    return path.startsWith('/auth/');
  }
}
```

### Step 3: 권한 Guard
```dart
// lib/app/router/guards/permission_guard.dart
@injectable
class PermissionGuard implements RouteGuard {
  final UserService _userService;
  
  PermissionGuard(this._userService);
  
  @override
  FutureOr<String?> canActivate(
    BuildContext context,
    GoRouterState state,
  ) async {
    final user = await _userService.getCurrentUser();
    
    // Admin 권한 체크
    if (state.uri.path.startsWith('/admin') && user?.role != 'admin') {
      return '/unauthorized';
    }
    
    // Premium 권한 체크
    if (state.uri.path.startsWith('/premium') && !user?.isPremium) {
      return '/subscription';
    }
    
    return null;
  }
}
```

## Phase 4: Navigation Shell 개선 (Day 8)

### Step 1: Shell Route 분리
```dart
// lib/app/router/shell/main_shell_route.dart
@injectable
class MainShellRoute {
  static ShellRoute create() {
    return ShellRoute(
      builder: (context, state, child) => MainNavigationShell(
        child: child,
        currentPath: state.uri.path,
      ),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => NoTransitionPage(
            child: getIt<HomeScreen>(),
          ),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => NoTransitionPage(
            child: getIt<SearchScreen>(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: getIt<ProfileScreen>(),
          ),
        ),
        GoRoute(
          path: '/chat',
          pageBuilder: (context, state) => NoTransitionPage(
            child: getIt<ChatListScreen>(),
          ),
        ),
      ],
    );
  }
}
```

## Phase 5: 전환 효과 시스템 (Day 9)

### Step 1: 전환 효과 정의
```dart
// lib/app/router/transitions/app_transitions.dart
enum TransitionType {
  fade,
  slide,
  scale,
  none,
}

class AppTransitions {
  static Page<dynamic> getTransitionPage({
    required Widget child,
    required TransitionType type,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    switch (type) {
      case TransitionType.fade:
        return CustomTransitionPage(
          child: child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        );
      case TransitionType.slide:
        return CustomTransitionPage(
          child: child,
          transitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end);
            final offsetAnimation = animation.drive(tween);
            return SlideTransition(position: offsetAnimation, child: child);
          },
        );
      case TransitionType.none:
      default:
        return NoTransitionPage(child: child);
    }
  }
}
```

## Phase 6: 테스트 구축 (Day 10-11)

### Step 1: 라우터 테스트
```dart
// test/app/router/router_test.dart
void main() {
  late AppRouter appRouter;
  late MockAuthStateNotifier mockAuthState;
  
  setUp(() {
    mockAuthState = MockAuthStateNotifier();
    appRouter = AppRouter(mockAuthState, []);
  });
  
  group('AppRouter', () {
    test('should redirect to login when not authenticated', () {
      when(mockAuthState.loggedIn).thenReturn(false);
      
      final redirect = appRouter.router.configuration.redirect(
        MockBuildContext(),
        GoRouterState(uri: Uri.parse('/profile')),
      );
      
      expect(redirect, '/auth/login');
    });
    
    test('should allow access when authenticated', () {
      when(mockAuthState.loggedIn).thenReturn(true);
      
      final redirect = appRouter.router.configuration.redirect(
        MockBuildContext(),
        GoRouterState(uri: Uri.parse('/profile')),
      );
      
      expect(redirect, isNull);
    });
  });
}
```

### Step 2: Feature 라우트 테스트
```dart
// test/features/auth/routes/auth_routes_test.dart
void main() {
  group('AuthRoutes', () {
    late AuthRoutes authRoutes;
    
    setUp(() {
      authRoutes = AuthRoutes();
    });
    
    test('should have correct path', () {
      expect(authRoutes.path, '/auth');
    });
    
    test('should have login route', () {
      final loginRoute = authRoutes.routes.firstWhere(
        (r) => r.name == 'auth_login',
      );
      expect(loginRoute.path, 'login');
    });
  });
}
```

## 📊 마이그레이션 영향 분석

### 파일 구조 변화
| 항목 | 현재 | 마이그레이션 후 |
|------|------|---------------|
| **파일 수** | 2개 | 25개+ |
| **nav.dart** | 542줄 | 5개 파일로 분리 (각 <150줄) |
| **serialization_util.dart** | 270줄 | 3개 파일로 분리 (각 <100줄) |
| **Feature 의존성** | 30개+ | 0개 |
| **미사용 코드** | AppPlace, LatLng | 제거됨 |
| **테스트 파일** | 0개 | 15개+ |

### 성능 영향
- **초기 로드**: 변화 없음 (Lazy loading 유지)
- **메모리 사용**: 약간 증가 (DI 인스턴스)
- **유지보수성**: 크게 향상
- **테스트 속도**: 개선 (모듈별 테스트)

## 🔄 마이그레이션 체크리스트

### Week 1
- [ ] 디렉토리 구조 생성
- [ ] nav.dart 파일 분리
  - [ ] AuthStateNotifier 분리
  - [ ] Router 코어 분리
  - [ ] 라우트 상수 분리
  - [ ] Navigation 확장 분리
- [ ] serialization_util.dart 정리
  - [ ] 미사용 타입 제거 (AppPlace, LatLng)
  - [ ] 기본 직렬화와 Firebase 직렬화 분리
  - [ ] ParamType enum 정리
  - [ ] core_exports.dart 의존성 제거

### Week 2
- [ ] Feature 라우트 인터페이스 정의
- [ ] 각 Feature별 라우트 생성
  - [ ] Auth 라우트
  - [ ] Posts 라우트
  - [ ] Chat 라우트
  - [ ] Profile 라우트
  - [ ] Voting 라우트
  - [ ] Notifications 라우트
  - [ ] Search 라우트
- [ ] Feature 라우트 등록 시스템

### Week 3
- [ ] Guard 시스템 구축
  - [ ] AuthGuard
  - [ ] PermissionGuard
  - [ ] Guard 체인 구현
- [ ] Shell Route 개선
- [ ] 전환 효과 시스템
- [ ] 테스트 작성

## ⚠️ 위험 요소 및 대응

### 위험 1: 기존 기능 파괴
**문제**: 리팩토링 중 라우팅 오류
**대응**: 
- 점진적 마이그레이션
- Feature별 단계적 적용
- 충분한 테스트 커버리지

### 위험 2: 순환 의존성
**문제**: Feature 간 라우트 참조
**대응**:
- 라우트 경로는 상수로 관리
- Feature는 자체 라우트만 정의
- 중앙 라우터에서만 통합

### 위험 3: 성능 저하
**문제**: DI 오버헤드
**대응**:
- Lazy loading 적극 활용
- 필요한 라우트만 등록
- 프로파일링으로 병목 확인

## 📈 예상 결과

### 개선 사항
- ✅ **모듈성**: Feature별 독립적 라우트 관리
- ✅ **테스트 가능성**: 라우트별 단위 테스트
- ✅ **유지보수성**: 명확한 책임 분리
- ✅ **확장성**: 새 Feature 쉽게 추가
- ✅ **타입 안전성**: 강타입 라우트 정의

### 성공 지표 달성
- 모든 Feature 직접 import 제거 ✅
- 최대 파일 크기 < 200줄 ✅
- Feature별 라우트 독립 관리 ✅
- 테스트 커버리지 80%+ ✅

## 📚 참고 자료

- [GoRouter Migration Guide](https://pub.dev/packages/go_router/versions/12.0.0/changelog)
- [Feature-First Architecture](/FEATURE_ARCHITECTURE.md)
- [DI System Migration](/lib/app/di/MIGRATION_Part3.md)
- [Clean Architecture in Flutter](https://resocoder.com/clean-architecture/)

---

*이 마이그레이션은 Feature-First Architecture의 핵심 개선 사항입니다.*
*단계별 진행으로 리스크를 최소화하며 점진적으로 적용합니다.*