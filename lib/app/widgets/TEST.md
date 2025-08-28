# 🧪 Widgets 레이어 테스트 가이드

> App 레벨 위젯 및 네비게이션 테스트 전략 및 구현 가이드  
> 작성일: 2025-08-28 | 예상 커버리지: 80%

## 📋 테스트 범위

### 1. 테스트 대상
- **MainNavigationShell**: 듀얼 모드 네비게이션 UI
- **DebugLogPage**: 디버그 로그 뷰어 (개발 빌드만)
- **네비게이션 위젯**: 하단 네비게이션 바
- **index.dart 제거 후 영향**: import 경로 변경 검증

### 2. 테스트 제외 대상
- Feature 레이어 위젯 (각 Feature에서 테스트)
- 외부 패키지 UI 컴포넌트

## 🎯 테스트 전략

### Phase 1: MainNavigationShell 테스트 (Week 4, Day 1)

#### 1.1 네비게이션 모드 테스트
```dart
// test/unit/app/widgets/navigation/main_navigation_shell_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/app/widgets/navigation/main_navigation_shell.dart';
import 'package:versus_space/app/state/providers/navigation_provider.dart';

@GenerateMocks([GoRouterState, NavigationShellContext])
void main() {
  group('MainNavigationShell 위젯 테스트', () {
    late NavigationProvider navigationProvider;
    late Widget testWidget;
    
    setUp(() {
      navigationProvider = NavigationProvider();
    });
    
    Widget buildTestWidget({
      required Widget child,
      required int currentIndex,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider.value(
          value: navigationProvider,
          child: MainNavigationShell(
            navigationShell: MockNavigationShellContext(),
            child: child,
            currentIndex: currentIndex,
          ),
        ),
      );
    }
    
    testWidgets('메인 모드에서 5개 탭이 표시되어야 함', (tester) async {
      // Given
      navigationProvider.setMainMode();
      
      // When
      await tester.pumpWidget(
        buildTestWidget(
          child: Container(),
          currentIndex: 0,
        ),
      );
      
      // Then
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.add_box), findsOneWidget);
      expect(find.byIcon(Icons.message), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });
    
    testWidgets('채팅 모드에서 3개 탭이 표시되어야 함', (tester) async {
      // Given
      navigationProvider.setChatMode();
      
      // When
      await tester.pumpWidget(
        buildTestWidget(
          child: Container(),
          currentIndex: 0,
        ),
      );
      
      // Then
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
      expect(find.byIcon(Icons.groups), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      
      // 메인 모드 아이콘들은 없어야 함
      expect(find.byIcon(Icons.home), findsNothing);
      expect(find.byIcon(Icons.search), findsNothing);
    });
    
    testWidgets('탭 선택이 올바르게 작동해야 함', (tester) async {
      // Given
      final mockContext = MockNavigationShellContext();
      int selectedIndex = 0;
      
      when(mockContext.goBranch(any)).thenAnswer((invocation) {
        selectedIndex = invocation.positionalArguments[0] as int;
      });
      
      await tester.pumpWidget(
        buildTestWidget(
          child: Container(),
          currentIndex: 0,
        ),
      );
      
      // When - 검색 탭 클릭
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      
      // Then
      verify(mockContext.goBranch(1)).called(1);
    });
  });
}
```

#### 1.2 NavigationProvider 상태 테스트
```dart
// test/unit/app/state/providers/navigation_provider_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/state/providers/navigation_provider.dart';

void main() {
  group('NavigationProvider 테스트', () {
    late NavigationProvider provider;
    
    setUp(() {
      provider = NavigationProvider();
    });
    
    test('초기 상태는 메인 모드여야 함', () {
      expect(provider.isMainMode, isTrue);
      expect(provider.isChatMode, isFalse);
      expect(provider.currentMode, equals(NavigationMode.main));
    });
    
    test('모드 전환이 올바르게 작동해야 함', () {
      // Given
      var listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });
      
      // When
      provider.setChatMode();
      
      // Then
      expect(provider.isChatMode, isTrue);
      expect(provider.isMainMode, isFalse);
      expect(listenerCalled, isTrue);
    });
    
    test('같은 모드로 전환 시 리스너가 호출되지 않아야 함', () {
      // Given
      provider.setMainMode();
      
      var listenerCalled = false;
      provider.addListener(() {
        listenerCalled = true;
      });
      
      // When
      provider.setMainMode();
      
      // Then
      expect(listenerCalled, isFalse);
    });
    
    test('현재 인덱스가 올바르게 업데이트되어야 함', () {
      // When
      provider.updateCurrentIndex(2);
      
      // Then
      expect(provider.currentIndex, equals(2));
    });
  });
}
```

### Phase 2: DebugLogPage 테스트 (Week 4, Day 1)

#### 2.1 디버그 로그 위젯 테스트
```dart
// test/unit/app/widgets/debug/debug_log_page_test.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/app/widgets/debug/debug_log_page.dart';

void main() {
  group('DebugLogPage 테스트', () {
    testWidgets('디버그 모드에서만 표시되어야 함', (tester) async {
      // Given - 디버그 모드 시뮬레이션
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: kDebugMode ? DebugLogPage() : Container(),
        ),
      );
      
      // Then
      if (kDebugMode) {
        expect(find.byType(DebugLogPage), findsOneWidget);
        expect(find.text('Debug Logs'), findsOneWidget);
      } else {
        expect(find.byType(DebugLogPage), findsNothing);
      }
      
      debugDefaultTargetPlatformOverride = null;
    });
    
    testWidgets('로그 목록이 표시되어야 함', (tester) async {
      // Given
      final logs = [
        'Log entry 1',
        'Log entry 2',
        'Error: Something went wrong',
      ];
      
      // When
      await tester.pumpWidget(
        MaterialApp(
          home: DebugLogPage(initialLogs: logs),
        ),
      );
      
      // Then
      expect(find.text('Log entry 1'), findsOneWidget);
      expect(find.text('Log entry 2'), findsOneWidget);
      expect(find.text('Error: Something went wrong'), findsOneWidget);
    });
    
    testWidgets('로그 필터링이 작동해야 함', (tester) async {
      // Given
      final logs = [
        'Info: Application started',
        'Error: Network failure',
        'Info: User logged in',
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          home: DebugLogPage(initialLogs: logs),
        ),
      );
      
      // When - Error 필터 적용
      await tester.tap(find.text('Error'));
      await tester.pumpAndSettle();
      
      // Then
      expect(find.text('Error: Network failure'), findsOneWidget);
      expect(find.text('Info: Application started'), findsNothing);
      expect(find.text('Info: User logged in'), findsNothing);
    });
    
    testWidgets('로그 클리어가 작동해야 함', (tester) async {
      // Given
      final logs = ['Log 1', 'Log 2'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: DebugLogPage(initialLogs: logs),
        ),
      );
      
      // Initial state
      expect(find.text('Log 1'), findsOneWidget);
      
      // When
      await tester.tap(find.byIcon(Icons.clear_all));
      await tester.pumpAndSettle();
      
      // Then
      expect(find.text('Log 1'), findsNothing);
      expect(find.text('Log 2'), findsNothing);
    });
  });
}
```

### Phase 3: 통합 테스트 (Week 4, Day 2)

#### 3.1 네비게이션 통합 테스트
```dart
// test/integration/app/widgets/navigation_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('네비게이션 통합 테스트', () {
    testWidgets('전체 네비게이션 플로우가 작동해야 함', (tester) async {
      // Given
      final router = GoRouter(
        routes: [
          ShellRoute(
            builder: (context, state, child) => MainNavigationShell(
              navigationShell: state.shellContext,
              child: child,
            ),
            routes: [
              GoRoute(path: '/', builder: (_, __) => HomePage()),
              GoRoute(path: '/search', builder: (_, __) => SearchPage()),
              GoRoute(path: '/create', builder: (_, __) => CreatePage()),
              GoRoute(path: '/chat', builder: (_, __) => ChatPage()),
              GoRoute(path: '/profile', builder: (_, __) => ProfilePage()),
            ],
          ),
        ],
      );
      
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => NavigationProvider()),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // When & Then - 각 탭 순회
      // 홈
      expect(find.byType(HomePage), findsOneWidget);
      
      // 검색
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      expect(find.byType(SearchPage), findsOneWidget);
      
      // 생성
      await tester.tap(find.byIcon(Icons.add_box));
      await tester.pumpAndSettle();
      expect(find.byType(CreatePage), findsOneWidget);
      
      // 채팅
      await tester.tap(find.byIcon(Icons.message));
      await tester.pumpAndSettle();
      expect(find.byType(ChatPage), findsOneWidget);
      
      // 프로필
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
    });
    
    testWidgets('모드 전환이 UI에 반영되어야 함', (tester) async {
      // Given
      final navigationProvider = NavigationProvider();
      
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: navigationProvider,
          child: MaterialApp(
            home: Consumer<NavigationProvider>(
              builder: (context, provider, child) {
                return MainNavigationShell(
                  navigationShell: MockNavigationShellContext(),
                  child: Container(),
                  currentIndex: 0,
                );
              },
            ),
          ),
        ),
      );
      
      // Initial - 메인 모드
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble), findsNothing);
      
      // When - 채팅 모드로 전환
      navigationProvider.setChatMode();
      await tester.pumpAndSettle();
      
      // Then
      expect(find.byIcon(Icons.home), findsNothing);
      expect(find.byIcon(Icons.chat_bubble), findsOneWidget);
    });
  });
}
```

### Phase 4: 골든 테스트 (Week 4, Day 2)

#### 4.1 UI 스냅샷 테스트
```dart
// test/golden/app/widgets/navigation_golden_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('MainNavigationShell 골든 테스트', () {
    testGoldens('메인 모드 네비게이션 바', (tester) async {
      // Given
      final navigationProvider = NavigationProvider()..setMainMode();
      
      final widget = MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider.value(
          value: navigationProvider,
          child: MainNavigationShell(
            navigationShell: MockNavigationShellContext(),
            child: Container(height: 500, color: Colors.white),
            currentIndex: 0,
          ),
        ),
      );
      
      // When
      await tester.pumpWidgetBuilder(widget);
      
      // Then
      await screenMatchesGolden(tester, 'main_navigation_main_mode');
    });
    
    testGoldens('채팅 모드 네비게이션 바', (tester) async {
      // Given
      final navigationProvider = NavigationProvider()..setChatMode();
      
      final widget = MaterialApp(
        theme: AppTheme.light,
        home: ChangeNotifierProvider.value(
          value: navigationProvider,
          child: MainNavigationShell(
            navigationShell: MockNavigationShellContext(),
            child: Container(height: 500, color: Colors.white),
            currentIndex: 0,
          ),
        ),
      );
      
      // When
      await tester.pumpWidgetBuilder(widget);
      
      // Then
      await screenMatchesGolden(tester, 'main_navigation_chat_mode');
    });
    
    testGoldens('선택된 탭 하이라이트', (tester) async {
      // Test each selected index
      for (int i = 0; i < 5; i++) {
        final widget = MaterialApp(
          theme: AppTheme.light,
          home: MainNavigationShell(
            navigationShell: MockNavigationShellContext(),
            child: Container(height: 500, color: Colors.white),
            currentIndex: i,
          ),
        );
        
        await tester.pumpWidgetBuilder(widget);
        await screenMatchesGolden(tester, 'navigation_selected_$i');
      }
    });
  });
}
```

## 📝 테스트 작성 가이드라인

### 1. 위젯 테스트 구조
```dart
testWidgets('테스트 설명', (WidgetTester tester) async {
  // Arrange - 테스트 환경 설정
  final widget = buildTestWidget();
  
  // Act - 상호작용 수행
  await tester.pumpWidget(widget);
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();
  
  // Assert - 결과 검증
  expect(find.byType(SearchPage), findsOneWidget);
});
```

### 2. Provider 테스트 래퍼
```dart
Widget wrapWithProvider({
  required Widget child,
  required ChangeNotifier provider,
}) {
  return MaterialApp(
    home: ChangeNotifierProvider.value(
      value: provider,
      child: child,
    ),
  );
}
```

### 3. Mock 네비게이션 컨텍스트
```dart
class MockNavigationShellContext extends Mock 
    implements NavigationShellContext {
  @override
  void goBranch(int index) {
    // Mock implementation
  }
}
```

## 🔧 테스트 도구 설정

### 필요한 패키지
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  mockito: ^5.4.0
  golden_toolkit: ^0.15.0
  provider: ^6.1.2
  go_router: ^12.1.3
```

### 골든 테스트 설정
```dart
// test/flutter_test_config.dart
import 'dart:async';
import 'package:golden_toolkit/golden_toolkit.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await loadAppFonts();
  return testMain();
}
```

## 📊 커버리지 목표

| 구분 | 목표 커버리지 | 우선순위 |
|-----|------------|---------|
| MainNavigationShell | 95% | Critical |
| NavigationProvider | 90% | High |
| DebugLogPage | 70% | Low |
| 통합 플로우 | 85% | High |
| UI 골든 테스트 | 80% | Medium |

## ✅ 체크리스트

### 작성 전
- [ ] Mock 객체 준비
- [ ] 테스트 래퍼 생성
- [ ] 골든 파일 초기화

### 작성 중
- [ ] 모든 네비게이션 경로 테스트
- [ ] 모드 전환 테스트
- [ ] 엣지 케이스 처리
- [ ] 골든 테스트 생성

### 작성 후
- [ ] 커버리지 80% 이상
- [ ] 골든 파일 검증
- [ ] CI/CD 통합

## 🚀 실행 명령어

```bash
# 위젯 테스트 실행
flutter test test/app/widgets/

# 통합 테스트 실행
flutter test integration_test/

# 골든 테스트 생성
flutter test --update-goldens

# 커버리지 측정
flutter test --coverage test/app/widgets/
genhtml coverage/lcov.info -o coverage/html

# 특정 테스트만 실행
flutter test test/unit/app/widgets/navigation/
```

## 📚 참고 자료

- [Flutter 위젯 테스트](https://flutter.dev/docs/cookbook/testing/widget)
- [Golden Toolkit](https://pub.dev/packages/golden_toolkit)
- [Integration Testing](https://flutter.dev/docs/testing/integration-tests)
- [Provider 테스트](https://pub.dev/packages/provider#testing)

---

*이 문서는 Widgets 레이어의 테스트 전략과 구현 방법을 담고 있습니다.*