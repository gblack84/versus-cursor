# 🧪 Router 레이어 테스트 가이드

> GoRouter 기반 라우팅 시스템 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 예상 커버리지: 90%

## 📋 테스트 범위

### 1. 테스트 대상
- **라우트 정의**: 모든 경로 매핑 및 빌더
- **Guard 시스템**: AuthGuard, PermissionGuard
- **네비게이션 상태**: AuthStateNotifier, NavigationProvider
- **딥링크 처리**: URL 파싱 및 리디렉션
- **전환 애니메이션**: 페이지 트랜지션

### 2. 테스트 제외 대상
- GoRouter 패키지 자체
- Flutter 네비게이션 프레임워크

## 🎯 테스트 전략

### Phase 1: 라우트 정의 테스트 (Week 2, Day 1-2)

#### 1.1 기본 라우트 테스트
```dart
// test/unit/app/router/routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/app/router/routes.dart';

void main() {
  group('라우트 정의 테스트', () {
    late List<GoRoute> routes;
    
    setUp(() {
      routes = AppRoutes.getAllRoutes();
    });
    
    test('모든 필수 라우트가 정의되어야 함', () {
      final routePaths = routes.map((r) => r.path).toSet();
      
      expect(routePaths.contains('/'), isTrue);
      expect(routePaths.contains('/login'), isTrue);
      expect(routePaths.contains('/home'), isTrue);
      expect(routePaths.contains('/profile'), isTrue);
      expect(routePaths.contains('/create-post'), isTrue);
      expect(routePaths.contains('/chat'), isTrue);
    });
    
    test('라우트 이름이 고유해야 함', () {
      final routeNames = routes
          .where((r) => r.name != null)
          .map((r) => r.name)
          .toList();
      
      final uniqueNames = routeNames.toSet();
      expect(routeNames.length, equals(uniqueNames.length));
    });
    
    test('모든 라우트에 빌더가 정의되어야 함', () {
      for (final route in routes) {
        expect(route.builder, isNotNull);
      }
    });
  });
  
  group('중첩 라우트 테스트', () {
    test('ShellRoute가 올바르게 구성되어야 함', () {
      final router = AppRouter.create();
      
      // ShellRoute 찾기
      final shellRoute = router.configuration.routes
          .firstWhere((r) => r is ShellRoute) as ShellRoute;
      
      expect(shellRoute.builder, isNotNull);
      expect(shellRoute.routes.length, greaterThan(0));
    });
    
    test('하위 라우트가 부모 경로를 상속해야 함', () {
      final router = AppRouter.create();
      
      // /profile/:id/edit 같은 중첩 경로 테스트
      final profileRoute = router.configuration.routes
          .firstWhere((r) => r.path == '/profile');
      
      expect(profileRoute.routes, isNotEmpty);
      
      final editRoute = profileRoute.routes
          .firstWhere((r) => r.path == 'edit');
      
      expect(editRoute.path, equals('edit'));
      // 전체 경로는 /profile/:id/edit가 됨
    });
  });
}
```

#### 1.2 Feature 라우트 모듈 테스트
```dart
// test/unit/app/router/feature_routes_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/features/auth/routes.dart';
import 'package:versus_space/features/posts/routes.dart';

void main() {
  group('Feature 라우트 독립성 테스트', () {
    test('Auth Feature 라우트가 독립적이어야 함', () {
      final authRoutes = AuthRoutes.routes;
      
      expect(authRoutes.length, greaterThan(0));
      
      // Auth 관련 경로만 포함
      for (final route in authRoutes) {
        expect(
          route.path.startsWith('/auth') || 
          route.path == '/login' ||
          route.path == '/signup',
          isTrue,
        );
      }
    });
    
    test('Posts Feature 라우트가 독립적이어야 함', () {
      final postsRoutes = PostsRoutes.routes;
      
      expect(postsRoutes.length, greaterThan(0));
      
      // Posts 관련 경로만 포함
      for (final route in postsRoutes) {
        expect(
          route.path.contains('post') ||
          route.path.contains('create'),
          isTrue,
        );
      }
    });
    
    test('Feature 라우트 간 충돌이 없어야 함', () {
      final authPaths = AuthRoutes.routes.map((r) => r.path).toSet();
      final postsPaths = PostsRoutes.routes.map((r) => r.path).toSet();
      
      final intersection = authPaths.intersection(postsPaths);
      expect(intersection.isEmpty, isTrue);
    });
  });
}
```

### Phase 2: Guard 시스템 테스트 (Week 2, Day 2-3)

#### 2.1 AuthGuard 테스트
```dart
// test/unit/app/router/guards/auth_guard_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/app/router/guards/auth_guard.dart';

@GenerateMocks([AuthService, BuildContext])
void main() {
  group('AuthGuard 테스트', () {
    late AuthGuard authGuard;
    late MockAuthService mockAuthService;
    
    setUp(() {
      mockAuthService = MockAuthService();
      authGuard = AuthGuard(mockAuthService);
    });
    
    test('인증되지 않은 사용자는 로그인 페이지로 리디렉션되어야 함', () {
      // Given
      when(mockAuthService.isAuthenticated).thenReturn(false);
      when(mockAuthService.currentUser).thenReturn(null);
      
      final state = GoRouterState(
        location: '/profile',
        matchedLocation: '/profile',
      );
      
      // When
      final result = authGuard.redirect(MockBuildContext(), state);
      
      // Then
      expect(result, equals('/login?redirect=/profile'));
    });
    
    test('인증된 사용자는 요청한 페이지로 이동해야 함', () {
      // Given
      when(mockAuthService.isAuthenticated).thenReturn(true);
      when(mockAuthService.currentUser).thenReturn(
        User(id: '123', email: 'test@example.com'),
      );
      
      final state = GoRouterState(
        location: '/profile',
        matchedLocation: '/profile',
      );
      
      // When
      final result = authGuard.redirect(MockBuildContext(), state);
      
      // Then
      expect(result, isNull); // null은 리디렉션 없음을 의미
    });
    
    test('공개 경로는 인증 없이 접근 가능해야 함', () {
      // Given
      when(mockAuthService.isAuthenticated).thenReturn(false);
      
      final publicPaths = ['/about', '/terms', '/privacy'];
      
      for (final path in publicPaths) {
        final state = GoRouterState(
          location: path,
          matchedLocation: path,
        );
        
        // When
        final result = authGuard.redirect(MockBuildContext(), state);
        
        // Then
        expect(result, isNull);
      }
    });
  });
}
```

#### 2.2 PermissionGuard 테스트
```dart
// test/unit/app/router/guards/permission_guard_test.dart
void main() {
  group('PermissionGuard 테스트', () {
    test('권한이 있는 사용자는 접근 가능해야 함', () {
      // Given
      final user = User(id: '123', role: 'admin');
      final guard = PermissionGuard(requiredRole: 'admin');
      
      when(mockAuthService.currentUser).thenReturn(user);
      
      // When
      final result = guard.canActivate(mockContext, mockState);
      
      // Then
      expect(result, isTrue);
    });
    
    test('권한이 없는 사용자는 403 페이지로 리디렉션되어야 함', () {
      // Given
      final user = User(id: '123', role: 'user');
      final guard = PermissionGuard(requiredRole: 'admin');
      
      when(mockAuthService.currentUser).thenReturn(user);
      
      // When
      final result = guard.redirect(mockContext, mockState);
      
      // Then
      expect(result, equals('/403'));
    });
  });
}
```

### Phase 3: 네비게이션 테스트 (Week 2, Day 3-4)

#### 3.1 네비게이션 통합 테스트
```dart
// test/integration/app/router/navigation_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  group('네비게이션 통합 테스트', () {
    testWidgets('초기 경로가 올바르게 표시되어야 함', (tester) async {
      // Given
      final router = AppRouter.create();
      
      // When
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      await tester.pumpAndSettle();
      
      // Then
      expect(find.byType(HomePage), findsOneWidget);
    });
    
    testWidgets('프로그래매틱 네비게이션이 작동해야 함', (tester) async {
      // Given
      final router = AppRouter.create();
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      
      // When
      router.go('/profile');
      await tester.pumpAndSettle();
      
      // Then
      expect(find.byType(ProfilePage), findsOneWidget);
    });
    
    testWidgets('뒤로가기가 올바르게 작동해야 함', (tester) async {
      // Given
      final router = AppRouter.create();
      
      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
        ),
      );
      
      // When
      router.push('/profile');
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      
      // Then
      expect(find.byType(HomePage), findsOneWidget);
    });
  });
}
```

#### 3.2 딥링크 테스트
```dart
// test/integration/app/router/deeplink_test.dart
void main() {
  group('딥링크 처리 테스트', () {
    test('유효한 딥링크가 올바른 페이지로 이동해야 함', () async {
      // Given
      final router = AppRouter.create();
      final deepLink = 'https://versusspace.com/post/12345';
      
      // When
      router.go('/post/12345');
      
      // Then
      expect(router.location, equals('/post/12345'));
    });
    
    test('잘못된 딥링크는 404 페이지로 이동해야 함', () async {
      // Given
      final router = AppRouter.create();
      
      // When
      router.go('/invalid/path/that/does/not/exist');
      
      // Then
      expect(router.location, equals('/404'));
    });
    
    test('쿼리 파라미터가 올바르게 파싱되어야 함', () async {
      // Given
      final router = AppRouter.create();
      
      // When
      router.go('/search?q=flutter&category=tech');
      
      final state = router.routerDelegate.currentConfiguration;
      
      // Then
      expect(state.queryParameters['q'], equals('flutter'));
      expect(state.queryParameters['category'], equals('tech'));
    });
  });
}
```

### Phase 4: 성능 테스트 (Week 2, Day 5)

```dart
// test/performance/app/router/router_performance_test.dart
void main() {
  test('라우트 매칭이 1ms 이하여야 함', () {
    final router = AppRouter.create();
    
    final stopwatch = Stopwatch()..start();
    router.go('/profile/123/edit');
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(1));
  });
  
  test('Guard 체인 실행이 5ms 이하여야 함', () {
    final router = AppRouter.create();
    
    // Guard가 여러 개 체인된 경로
    final stopwatch = Stopwatch()..start();
    router.go('/admin/dashboard');
    stopwatch.stop();
    
    expect(stopwatch.elapsedMilliseconds, lessThan(5));
  });
}
```

## 📝 테스트 작성 가이드라인

### 1. 위젯 테스트 패턴
```dart
testWidgets('설명', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(
    TestApp(
      router: mockRouter,
      child: TestPage(),
    ),
  );
  
  // Act
  await tester.tap(find.byKey(Key('navigate_button')));
  await tester.pumpAndSettle();
  
  // Assert
  expect(find.byType(TargetPage), findsOneWidget);
});
```

### 2. Mock Router 생성
```dart
class MockRouter extends Mock implements GoRouter {
  @override
  String get location => '/test';
  
  @override
  void go(String location, {Object? extra}) {
    // Mock 구현
  }
}
```

### 3. TestApp 래퍼
```dart
class TestApp extends StatelessWidget {
  final Widget child;
  final GoRouter? router;
  
  const TestApp({
    Key? key,
    required this.child,
    this.router,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (router != null) {
      return MaterialApp.router(
        routerConfig: router!,
      );
    }
    
    return MaterialApp(
      home: child,
    );
  }
}
```

## 🔧 테스트 도구 설정

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  go_router: ^12.1.3
  network_image_mock: ^2.0.1
  golden_toolkit: ^0.15.0
```

### 테스트 환경 설정
```dart
// test/helpers/test_helpers.dart
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // 네트워크 이미지 Mock
  HttpOverrides.global = TestHttpOverrides();
  
  // Platform 채널 Mock
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (MethodCall methodCall) async {
      return '.';
    },
  );
}
```

## 📊 커버리지 목표

| 구분 | 목표 커버리지 | 우선순위 |
|-----|------------|---------|
| 라우트 정의 | 100% | Critical |
| Guard 시스템 | 95% | Critical |
| 네비게이션 상태 | 90% | High |
| 딥링크 처리 | 85% | Medium |
| 트랜지션 | 70% | Low |

## ✅ 체크리스트

### 작성 전
- [ ] GoRouter Mock 준비
- [ ] TestApp 래퍼 생성
- [ ] 테스트 환경 설정

### 작성 중
- [ ] 모든 라우트 커버
- [ ] Guard 로직 검증
- [ ] 엣지 케이스 처리
- [ ] 성능 측정

### 작성 후
- [ ] 커버리지 95% 이상
- [ ] E2E 시나리오 테스트
- [ ] 문서화

## 🚀 실행 명령어

```bash
# Router 테스트만 실행
flutter test test/app/router/

# 통합 테스트 포함
flutter test test/integration/app/router/

# 골든 테스트 업데이트
flutter test --update-goldens

# 커버리지 리포트
flutter test --coverage test/app/router/
lcov --remove coverage/lcov.info '*.g.dart' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
```

## 📚 참고 자료

- [GoRouter 테스팅 가이드](https://pub.dev/packages/go_router#testing)
- [Flutter 네비게이션 테스트](https://flutter.dev/docs/cookbook/testing/navigation)
- [Widget 테스트 베스트 프랙티스](https://flutter.dev/docs/testing#widget-tests)

---

*이 문서는 Router 시스템의 테스트 전략과 구현 방법을 담고 있습니다.*