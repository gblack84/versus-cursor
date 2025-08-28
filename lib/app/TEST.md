# 🧪 App 레이어 통합 테스트 가이드

> 전체 App 레이어 통합 테스트 전략 및 실행 계획  
> 작성일: 2025-08-28 | 목표 커버리지: 80%+

## 📋 전체 테스트 범위

### 테스트 대상 레이어
1. **DI (Dependency Injection)**: GetIt 기반 의존성 주입
2. **Router**: GoRouter 네비게이션 시스템
3. **State**: Provider 기반 상태 관리
4. **Widgets**: 앱 레벨 UI 컴포넌트
5. **Models**: 데이터 모델

### 테스트 타입
- **단위 테스트**: 개별 클래스/함수
- **위젯 테스트**: UI 컴포넌트
- **통합 테스트**: 레이어 간 상호작용
- **E2E 테스트**: 전체 사용자 플로우
- **성능 테스트**: 응답 시간 및 메모리

## 🎯 마이그레이션과 동기화된 테스트 전략

### Week 1: DI 시스템 (20% 커버리지)
- **Day 1**: 테스트 인프라 구축
- **Day 2-3**: DI 컨테이너 테스트 (5-8개 파일)
- **Day 4-5**: 모듈별 테스트 추가

### Week 2: Router 시스템 (40% 커버리지)
- **Day 1-2**: 라우트 정의 테스트 (10-15개 파일)
- **Day 2-3**: Guard 시스템 테스트
- **Day 3-4**: 네비게이션 통합 테스트
- **Day 5**: 성능 및 딥링크 테스트

### Week 3: State 관리 (60% 커버리지)
- **Day 1-2**: Provider 단위 테스트 (15-20개 파일)
- **Day 2-3**: 브리지 패턴 테스트
- **Day 3-4**: Multi-Provider 통합 테스트
- **Day 5**: 메모리 누수 및 성능 테스트

### Week 4: Widgets & Models (80% 커버리지)
- **Day 1-2**: 위젯 테스트 (10-15개 파일)
- **Day 3**: 모델 테스트 (5개 파일)
- **Day 4-5**: 전체 통합 테스트 및 문서화

## 📝 테스트 디렉토리 구조

```
test/
├── unit/                        # 단위 테스트
│   └── app/
│       ├── di/
│       │   ├── injection_test.dart
│       │   └── modules/
│       ├── router/
│       │   ├── routes_test.dart
│       │   └── guards/
│       ├── state/
│       │   ├── app_state_test.dart
│       │   └── providers/
│       ├── widgets/
│       │   └── navigation/
│       └── models/
│           ├── lat_lng_test.dart
│           └── place_test.dart
│
├── widget/                      # 위젯 테스트
│   └── app/
│       └── widgets/
│           ├── navigation_shell_test.dart
│           └── debug_log_test.dart
│
├── integration/                 # 통합 테스트
│   └── app/
│       ├── di/
│       │   ├── dependency_graph_test.dart
│       │   └── mock_injection_test.dart
│       ├── router/
│       │   ├── navigation_test.dart
│       │   └── deeplink_test.dart
│       ├── state/
│       │   ├── multi_provider_test.dart
│       │   └── persistence_test.dart
│       └── models/
│           └── model_integration_test.dart
│
├── e2e/                        # End-to-End 테스트
│   ├── app_startup_test.dart
│   ├── navigation_flow_test.dart
│   └── state_management_test.dart
│
├── performance/                # 성능 테스트
│   └── app/
│       ├── di/
│       │   └── injection_performance_test.dart
│       ├── router/
│       │   └── router_performance_test.dart
│       └── state/
│           └── state_performance_test.dart
│
├── golden/                     # 골든 테스트 (UI 스냅샷)
│   └── app/
│       └── widgets/
│           └── navigation_golden_test.dart
│
└── helpers/                    # 테스트 헬퍼
    ├── test_helpers.dart
    ├── mock_data.dart
    └── test_wrappers.dart
```

## 🧪 전체 통합 테스트 시나리오

### E2E 테스트: 앱 시작 및 초기화
```dart
// test/e2e/app_startup_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:versus_space/main.dart' as app;
import 'package:versus_space/app/di/injection.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('앱 시작 E2E 테스트', () {
    testWidgets('앱이 정상적으로 시작되어야 함', (tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();
      
      // Then
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(MainNavigationShell), findsOneWidget);
    });
    
    testWidgets('DI 시스템이 초기화되어야 함', (tester) async {
      // When
      await Injection.init();
      app.main();
      await tester.pumpAndSettle();
      
      // Then
      expect(getIt.isRegistered<AuthService>(), isTrue);
      expect(getIt.isRegistered<NotificationService>(), isTrue);
    });
    
    testWidgets('초기 라우트가 올바르게 설정되어야 함', (tester) async {
      // Given
      app.main();
      await tester.pumpAndSettle();
      
      // Then
      final router = getIt<GoRouter>();
      expect(router.location, equals('/'));
    });
  });
}
```

### 통합 테스트: 레이어 간 상호작용
```dart
// test/integration/app/layer_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('App 레이어 통합 테스트', () {
    test('DI → State → Router 통합이 작동해야 함', () async {
      // Given - DI 초기화
      await Injection.init();
      
      // When - State Provider 획득
      final appState = getIt<AppState>();
      appState.updateLanguage('ko');
      
      // Then - Router가 State 변경을 반영
      final router = getIt<GoRouter>();
      expect(router.locale?.languageCode, equals('ko'));
    });
    
    test('Router Guard가 DI 서비스를 사용해야 함', () async {
      // Given
      await Injection.init();
      final authService = getIt<AuthService>();
      when(authService.isAuthenticated).thenReturn(false);
      
      // When
      final router = AppRouter.create();
      router.go('/profile');
      
      // Then - Guard가 작동하여 로그인 페이지로 리디렉션
      expect(router.location, equals('/login?redirect=/profile'));
    });
    
    test('State 변경이 Widget에 반영되어야 함', () async {
      // Given
      final appState = AppState();
      final navigationProvider = NavigationProvider();
      
      // When
      navigationProvider.setChatMode();
      
      // Then - Widget이 업데이트됨
      expect(navigationProvider.isChatMode, isTrue);
      expect(navigationProvider.currentMode, equals(NavigationMode.chat));
    });
  });
}
```

## 🔧 테스트 인프라 설정

### 1. 테스트 헬퍼 파일
```dart
// test/helpers/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final List<SingleChildWidget>? providers;
  final GoRouter? router;
  
  const TestApp({
    Key? key,
    required this.child,
    this.providers,
    this.router,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(home: child);
    
    if (router != null) {
      app = MaterialApp.router(
        routerConfig: router!,
      );
    }
    
    if (providers != null) {
      return MultiProvider(
        providers: providers!,
        child: app,
      );
    }
    
    return app;
  }
}

// Mock 설정
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences Mock
  SharedPreferences.setMockInitialValues({});
  
  // GetIt 초기화
  getIt.reset();
  
  // Platform 채널 Mock
  const MethodChannel('plugins.flutter.io/path_provider')
      .setMockMethodCallHandler((MethodCall methodCall) async {
    return '.';
  });
}
```

### 2. Mock 데이터 생성
```dart
// test/helpers/mock_data.dart
import 'package:faker/faker.dart';

class MockDataGenerator {
  static final faker = Faker();
  
  static User generateUser() {
    return User(
      id: faker.guid.guid(),
      email: faker.internet.email(),
      displayName: faker.person.name(),
      createdAt: DateTime.now(),
    );
  }
  
  static Post generatePost() {
    return Post(
      id: faker.guid.guid(),
      title: faker.lorem.sentence(),
      contentA: faker.lorem.paragraph(),
      contentB: faker.lorem.paragraph(),
      userId: faker.guid.guid(),
      createdAt: DateTime.now(),
    );
  }
  
  static Place generatePlace() {
    return Place(
      id: faker.guid.guid(),
      name: faker.company.name(),
      location: LatLng(
        latitude: faker.randomGenerator.decimal(min: -90, max: 90),
        longitude: faker.randomGenerator.decimal(min: -180, max: 180),
      ),
      address: faker.address.streetAddress(),
    );
  }
}
```

## 📊 커버리지 목표 및 측정

### 레이어별 목표
| 레이어 | 목표 커버리지 | 현재 | 우선순위 |
|-------|------------|------|---------|
| DI | 95% | 0% | Critical |
| Router | 90% | 0% | Critical |
| State | 85% | 0% | High |
| Widgets | 80% | 0% | Medium |
| Models | 100% | 0% | Medium |

### 커버리지 측정 명령어
```bash
# 전체 테스트 실행 및 커버리지 측정
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 특정 레이어만 측정
flutter test --coverage test/unit/app/di/
flutter test --coverage test/unit/app/router/
flutter test --coverage test/unit/app/state/

# 커버리지 임계값 체크 (CI/CD용)
lcov --list coverage/lcov.info | grep "Total:" | awk '{print $2}' | sed 's/%//'
```

## ✅ 테스트 체크리스트

### 마이그레이션 주차별 체크리스트

#### Week 1: DI 시스템
- [ ] 테스트 디렉토리 구조 생성
- [ ] Mock 클래스 생성
- [ ] DI 컨테이너 초기화 테스트
- [ ] 의존성 등록 테스트
- [ ] 순환 의존성 테스트
- [ ] Mock 교체 테스트
- [ ] 성능 벤치마크

#### Week 2: Router 시스템
- [ ] 라우트 정의 테스트
- [ ] Guard 로직 테스트
- [ ] 네비게이션 플로우 테스트
- [ ] 딥링크 처리 테스트
- [ ] 에러 페이지 테스트
- [ ] 트랜지션 테스트

#### Week 3: State 관리
- [ ] Provider 상태 변경 테스트
- [ ] notifyListeners 검증
- [ ] 브리지 패턴 테스트
- [ ] 상태 지속성 테스트
- [ ] 메모리 누수 테스트
- [ ] 대용량 데이터 처리 테스트

#### Week 4: Widgets & Models
- [ ] NavigationShell 테스트
- [ ] 모드 전환 테스트
- [ ] 모델 직렬화 테스트
- [ ] 유효성 검사 테스트
- [ ] 골든 테스트
- [ ] E2E 시나리오 테스트

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/test.yml
name: Test

on:
  pull_request:
    paths:
      - 'lib/app/**'
      - 'test/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test --coverage
      
      - name: Check coverage
        run: |
          COVERAGE=$(lcov --list coverage/lcov.info | grep "Total:" | awk '{print $2}' | sed 's/%//')
          echo "Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 80" | bc -l) )); then
            echo "Coverage is below 80%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## 📚 테스트 원칙

### 1. 테스트 우선 원칙
- **TDD**: 코드 작성 전 테스트 작성
- **Red-Green-Refactor**: 실패 → 성공 → 리팩토링
- **테스트 없는 코드는 머지 불가**

### 2. 테스트 품질 원칙
- **AAA 패턴**: Arrange-Act-Assert
- **격리**: 각 테스트는 독립적으로 실행
- **명확성**: 테스트명에서 의도가 드러나야 함
- **속도**: 단위 테스트는 100ms 이하

### 3. 커버리지 원칙
- **최소 80%**: 전체 커버리지
- **Critical 경로 100%**: 핵심 비즈니스 로직
- **새 코드 90%**: 신규 작성 코드

## 🔍 문제 해결 가이드

### 자주 발생하는 문제

#### 1. Widget 테스트 실패
```dart
// 문제: RenderBox was not laid out
// 해결: 
await tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: YourWidget(),
    ),
  ),
);
```

#### 2. Provider 테스트 실패
```dart
// 문제: Provider not found
// 해결:
await tester.pumpWidget(
  ChangeNotifierProvider.value(
    value: yourProvider,
    child: MaterialApp(home: YourWidget()),
  ),
);
```

#### 3. 비동기 테스트 실패
```dart
// 문제: Timer still pending
// 해결:
await tester.pumpAndSettle();
// 또는
await tester.pump(Duration(seconds: 1));
```

## 📈 테스트 메트릭 대시보드

### 주요 지표
- **커버리지**: 80% 목표
- **테스트 실행 시간**: < 5분
- **테스트 성공률**: 100%
- **플레이크 테스트**: 0개

### 측정 도구
- **lcov**: 커버리지 측정
- **flutter test --machine**: JSON 출력
- **codecov.io**: 커버리지 추적
- **GitHub Actions**: CI/CD 자동화

---

*이 문서는 App 레이어 전체의 통합 테스트 전략과 실행 계획을 담고 있습니다.*  
*마이그레이션과 동시에 점진적으로 테스트를 구축하여 안정성을 확보합니다.*