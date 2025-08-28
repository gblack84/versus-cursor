# 🧪 Core 레이어 통합 테스트 가이드

> 전체 Core 레이어 통합 테스트 전략 및 실행 계획  
> 작성일: 2025-08-28 | 목표 커버리지: 85%+

## 📋 전체 테스트 범위

### 테스트 대상 디렉토리
| 디렉토리 | 파일 수 | 목표 커버리지 | 현재 | 우선순위 |
|----------|---------|--------------|------|---------|
| **actions** | 9 | 95% | 0% | Critical |
| **animations** | 11 | 80% | 0% | Medium |
| **constants** | 1 | 100% | 0% | Low |
| **design_system** | 15 | 90% | 0% | High |
| **localization** | 1 | 85% | 0% | Medium |
| **models** | 3 | 90% | 0% | High |
| **theme** | 6 | 85% | 0% | Medium |
| **utils** | 26 | 85% | 0% | High |
| **widgets** | 18 | 90% | 0% | Critical |

### 테스트 타입
- **단위 테스트**: 개별 클래스/함수 (60%)
- **위젯 테스트**: UI 컴포넌트 (20%)
- **통합 테스트**: 모듈 간 상호작용 (15%)
- **골든 테스트**: UI 스냅샷 (5%)

## 🎯 마이그레이션과 동기화된 테스트 전략

### Week 1: Actions & Widgets 초기 테스트 (30% 커버리지)
- **Day 2**: Actions 인터페이스 테스트 (10개 파일)
- **Day 3**: Actions 서비스 테스트 (9개 파일)
- **Day 4-5**: Widgets 카테고리별 테스트 시작

### Week 2: Design System & Widgets 완성 (60% 커버리지)
- **Day 1**: Widgets 테스트 완성 (18개 파일)
- **Day 2-4**: Design System 컴포넌트 테스트 (20개 파일)
- **Day 5**: Utils 테스트 추가 (26개 파일)

### Week 3: 전체 완성 및 통합 (85% 커버리지)
- **Day 1**: Models 테스트 (3개 파일)
- **Day 2**: Animations, Theme 테스트
- **Day 3-4**: 통합 테스트 작성
- **Day 5**: 커버리지 분석 및 보완

## 📝 테스트 디렉토리 구조

```
test/core/
├── actions/                    # Actions 시스템 테스트
│   ├── interfaces/
│   │   ├── i_action_test.dart
│   │   ├── i_app_action_test.dart
│   │   └── i_url_action_test.dart
│   ├── models/
│   │   ├── action_result_test.dart
│   │   └── action_context_test.dart
│   └── services/
│       ├── app_actions_service_test.dart
│       └── url_actions_service_test.dart
│
├── animations/                 # 애니메이션 테스트
│   ├── effects/
│   │   ├── fade_effect_test.dart
│   │   ├── scale_effect_test.dart
│   │   └── slide_effect_test.dart
│   └── animations_test.dart
│
├── design_system/              # 디자인 시스템 테스트
│   ├── components/
│   │   ├── buttons/
│   │   │   ├── primary_button_test.dart
│   │   │   └── secondary_button_test.dart
│   │   └── cards/
│   │       └── versus_card_test.dart
│   └── tokens/
│       ├── colors_test.dart
│       └── spacing_test.dart
│
├── widgets/                    # 위젯 테스트
│   ├── buttons/
│   │   ├── versus_button_test.dart
│   │   └── versus_icon_button_test.dart
│   ├── inputs/
│   │   ├── versus_text_field_test.dart
│   │   └── highlighted_text_field_test.dart
│   ├── media/
│   │   ├── versus_video_player_test.dart
│   │   └── youtube_player_test.dart
│   └── feedback/
│       ├── versus_loading_test.dart
│       └── versus_empty_state_test.dart
│
├── models/                     # 모델 테스트
│   ├── action_test.dart
│   ├── data_map_model_test.dart
│   └── uploaded_file_test.dart
│
├── utils/                      # 유틸리티 테스트
│   ├── format_test.dart
│   ├── validation_test.dart
│   ├── date_time_test.dart
│   └── string_utils_test.dart
│
├── integration/                # 통합 테스트
│   ├── actions_integration_test.dart
│   ├── widgets_integration_test.dart
│   └── design_system_integration_test.dart
│
├── golden/                     # 골든 테스트
│   └── widgets/
│       ├── buttons/
│       │   └── goldens/
│       └── cards/
│           └── goldens/
│
└── helpers/                    # 테스트 헬퍼
    ├── test_app.dart
    ├── mock_data.dart
    ├── test_utils.dart
    └── golden_test_utils.dart
```

## 🧪 디렉토리별 테스트 시나리오

### 1. Actions 테스트 (목표: 95%)
```dart
// test/core/actions/interfaces/i_action_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/core/actions/interfaces/i_action.dart';

void main() {
  group('IAction 인터페이스 테스트', () {
    late MockAction mockAction;
    late ActionContext context;
    
    setUp(() {
      mockAction = MockAction();
      context = ActionContext(
        params: {'key': 'value'},
        user: testUser,
      );
    });
    
    test('execute가 ActionResult를 반환해야 함', () async {
      // Given
      when(mockAction.execute(any)).thenAnswer(
        (_) async => ActionResult(success: true),
      );
      
      // When
      final result = await mockAction.execute(context);
      
      // Then
      expect(result.success, isTrue);
      expect(result.error, isNull);
    });
    
    test('canExecute가 권한을 체크해야 함', () {
      // Given
      when(mockAction.canExecute(any)).thenReturn(true);
      
      // When
      final canExecute = mockAction.canExecute(context);
      
      // Then
      expect(canExecute, isTrue);
    });
    
    test('에러 발생 시 ActionException을 throw해야 함', () async {
      // Given
      when(mockAction.execute(any)).thenThrow(
        ActionException('Test error'),
      );
      
      // When & Then
      expect(
        () async => await mockAction.execute(context),
        throwsA(isA<ActionException>()),
      );
    });
  });
}
```

### 2. Widgets 테스트 (목표: 90%)
```dart
// test/core/widgets/buttons/versus_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/widgets/buttons/versus_button.dart';
import '../../helpers/test_app.dart';

void main() {
  group('VersusButton 위젯 테스트', () {
    testWidgets('텍스트가 올바르게 표시되어야 함', (tester) async {
      // Given
      const buttonText = 'Click Me';
      
      // When
      await tester.pumpWidget(
        TestApp(
          child: VersusButton(
            text: buttonText,
            onPressed: () {},
          ),
        ),
      );
      
      // Then
      expect(find.text(buttonText), findsOneWidget);
    });
    
    testWidgets('로딩 상태가 표시되어야 함', (tester) async {
      // Given
      await tester.pumpWidget(
        TestApp(
          child: VersusButton(
            text: 'Submit',
            onPressed: () {},
            isLoading: true,
          ),
        ),
      );
      
      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Submit'), findsNothing);
    });
    
    testWidgets('비활성화 상태에서 클릭되지 않아야 함', (tester) async {
      // Given
      bool clicked = false;
      
      await tester.pumpWidget(
        TestApp(
          child: VersusButton(
            text: 'Disabled',
            onPressed: null,
          ),
        ),
      );
      
      // When
      await tester.tap(find.byType(VersusButton));
      await tester.pump();
      
      // Then
      expect(clicked, isFalse);
    });
  });
}
```

### 3. Design System 테스트 (목표: 90%)
```dart
// test/core/design_system/components/buttons/primary_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

void main() {
  group('PrimaryButton 컴포넌트 테스트', () {
    testGoldens('다양한 상태의 골든 테스트', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1,
      )
        ..addScenario(
          'Default',
          PrimaryButton(text: 'Default'),
        )
        ..addScenario(
          'Hover',
          PrimaryButton(text: 'Hover', isHovered: true),
        )
        ..addScenario(
          'Pressed',
          PrimaryButton(text: 'Pressed', isPressed: true),
        )
        ..addScenario(
          'Disabled',
          PrimaryButton(text: 'Disabled', onPressed: null),
        )
        ..addScenario(
          'Loading',
          PrimaryButton(text: 'Loading', isLoading: true),
        )
        ..addScenario(
          'With Icon',
          PrimaryButton(
            text: 'With Icon',
            icon: Icons.add,
          ),
        );
      
      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(800, 600),
      );
      
      await screenMatchesGolden(tester, 'primary_button_states');
    });
  });
}
```

### 4. Utils 테스트 (목표: 85%)
```dart
// test/core/utils/format_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/utils/format.dart';

void main() {
  group('Format 유틸리티 테스트', () {
    group('formatNumber', () {
      test('천 단위 쉼표가 추가되어야 함', () {
        expect(formatNumber(1000), equals('1,000'));
        expect(formatNumber(1000000), equals('1,000,000'));
        expect(formatNumber(123456789), equals('123,456,789'));
      });
      
      test('소수점이 유지되어야 함', () {
        expect(formatNumber(1234.56), equals('1,234.56'));
        expect(formatNumber(0.123), equals('0.123'));
      });
      
      test('음수가 올바르게 처리되어야 함', () {
        expect(formatNumber(-1000), equals('-1,000'));
        expect(formatNumber(-1234.56), equals('-1,234.56'));
      });
    });
    
    group('formatDate', () {
      test('날짜가 올바른 형식으로 표시되어야 함', () {
        final date = DateTime(2025, 8, 28, 14, 30);
        
        expect(formatDate(date), equals('2025-08-28'));
        expect(formatDate(date, format: 'MM/dd/yyyy'), equals('08/28/2025'));
        expect(formatDate(date, includeTime: true), equals('2025-08-28 14:30'));
      });
      
      test('null 날짜가 처리되어야 함', () {
        expect(formatDate(null), equals(''));
        expect(formatDate(null, defaultValue: 'N/A'), equals('N/A'));
      });
    });
  });
}
```

### 5. 통합 테스트
```dart
// test/core/integration/actions_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:get_it/get_it.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Actions 시스템 통합 테스트', () {
    setUp(() async {
      // DI 초기화
      await setupTestDI();
    });
    
    tearDown(() {
      GetIt.instance.reset();
    });
    
    testWidgets('언어 변경 액션이 전체 시스템에 반영되어야 함', (tester) async {
      // Given
      final actionService = GetIt.instance<AppActionsService>();
      final localizationService = GetIt.instance<LocalizationService>();
      
      // When
      final result = await actionService.setLanguage('ko');
      await tester.pumpAndSettle();
      
      // Then
      expect(result.success, isTrue);
      expect(localizationService.currentLanguage, equals('ko'));
      expect(find.text('설정'), findsOneWidget); // 한국어 텍스트 확인
    });
    
    testWidgets('테마 변경이 모든 위젯에 적용되어야 함', (tester) async {
      // Given
      final actionService = GetIt.instance<AppActionsService>();
      
      // When
      await actionService.setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();
      
      // Then
      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, equals(ThemeMode.dark));
      
      // 다크 테마 색상 확인
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.color, equals(VersusColors.darkBackground));
    });
  });
}
```

## 🔧 테스트 인프라 설정

### 1. 테스트 헬퍼
```dart
// test/core/helpers/test_app.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TestApp extends StatelessWidget {
  final Widget child;
  final ThemeData? theme;
  final List<SingleChildWidget>? providers;
  
  const TestApp({
    Key? key,
    required this.child,
    this.theme,
    this.providers,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    Widget app = MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: Scaffold(body: child),
    );
    
    if (providers != null && providers!.isNotEmpty) {
      return MultiProvider(
        providers: providers!,
        child: app,
      );
    }
    
    return app;
  }
}

// 공통 테스트 설정
void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // SharedPreferences Mock
  SharedPreferences.setMockInitialValues({});
  
  // Platform 채널 Mock
  const MethodChannel channel = MethodChannel('plugins.flutter.io/path_provider');
  channel.setMockMethodCallHandler((MethodCall methodCall) async {
    return '.';
  });
}
```

### 2. Mock 데이터
```dart
// test/core/helpers/mock_data.dart
import 'package:versus_space/core/models/uploaded_file.dart';
import 'package:faker/faker.dart';

class MockData {
  static final faker = Faker();
  
  static UploadedFile createMockFile({
    String? name,
    String? path,
    int? size,
  }) {
    return UploadedFile(
      name: name ?? faker.lorem.word(),
      path: path ?? '/uploads/${faker.guid.guid()}',
      size: size ?? faker.randomGenerator.integer(1000000),
    );
  }
  
  static ActionContext createMockContext({
    Map<String, dynamic>? params,
    User? user,
  }) {
    return ActionContext(
      params: params ?? {},
      user: user ?? createMockUser(),
      timestamp: DateTime.now(),
    );
  }
  
  static User createMockUser() {
    return User(
      id: faker.guid.guid(),
      email: faker.internet.email(),
      displayName: faker.person.name(),
    );
  }
}
```

### 3. 골든 테스트 유틸
```dart
// test/core/helpers/golden_test_utils.dart
import 'package:golden_toolkit/golden_toolkit.dart';

void configureGoldenTests() {
  return GoldenToolkit.runWithConfiguration(
    () async {
      await loadAppFonts();
    },
    config: GoldenToolkitConfiguration(
      defaultDevices: const [
        Device.phone,
        Device.tabletPortrait,
      ],
      enableRealShadows: true,
      skipGoldenAssertion: () => !Platform.isMacOS,
    ),
  );
}

// 다양한 테마에서 테스트
Future<void> testWithThemes(
  WidgetTester tester,
  Widget widget,
  String goldenName,
) async {
  // Light 테마
  await tester.pumpWidget(
    TestApp(
      theme: VersusTheme.light,
      child: widget,
    ),
  );
  await screenMatchesGolden(tester, '${goldenName}_light');
  
  // Dark 테마
  await tester.pumpWidget(
    TestApp(
      theme: VersusTheme.dark,
      child: widget,
    ),
  );
  await screenMatchesGolden(tester, '${goldenName}_dark');
}
```

## 📊 커버리지 목표 및 측정

### 전체 목표
| 메트릭 | 목표 | 현재 | 차이 |
|-------|------|------|-----|
| **전체 커버리지** | 85% | 0% | -85% |
| **단위 테스트** | 90% | 0% | -90% |
| **위젯 테스트** | 85% | 0% | -85% |
| **통합 테스트** | 70% | 0% | -70% |

### 커버리지 측정 명령어
```bash
# 전체 테스트 실행 및 커버리지
flutter test --coverage

# 특정 디렉토리만 테스트
flutter test --coverage test/core/actions/
flutter test --coverage test/core/widgets/
flutter test --coverage test/core/utils/

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html

# 커버리지 임계값 체크
lcov --summary coverage/lcov.info
```

## ✅ 테스트 체크리스트

### Week 1
- [ ] Actions 인터페이스 테스트 (10개)
- [ ] Actions 서비스 테스트 (9개)
- [ ] Actions 모델 테스트 (3개)
- [ ] Widgets 버튼 테스트 (3개)
- [ ] Widgets 입력 테스트 (3개)

### Week 2
- [ ] Widgets 미디어 테스트 (4개)
- [ ] Widgets 피드백 테스트 (3개)
- [ ] Design System 버튼 테스트 (3개)
- [ ] Design System 카드 테스트 (2개)
- [ ] Design System 폼 테스트 (3개)
- [ ] Utils 주요 함수 테스트 (10개)

### Week 3
- [ ] Models 테스트 (3개)
- [ ] Animations 테스트 (11개)
- [ ] Theme 테스트 (6개)
- [ ] Constants 테스트 (1개)
- [ ] Localization 테스트 (1개)
- [ ] 통합 테스트 (5개)
- [ ] 골든 테스트 (10개)

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/core-test.yml
name: Core Layer Tests

on:
  pull_request:
    paths:
      - 'lib/core/**'
      - 'test/core/**'

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
      
      - name: Run Core tests
        run: flutter test --coverage test/core/
      
      - name: Check coverage threshold
        run: |
          COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | grep -oP '\d+\.\d+')
          echo "Core Layer Coverage: $COVERAGE%"
          if (( $(echo "$COVERAGE < 85" | bc -l) )); then
            echo "Coverage is below 85%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
          flags: core
```

## 📚 테스트 원칙

### 1. 테스트 우선 원칙
- **TDD**: 코드 작성 전 테스트 작성
- **BDD**: 행동 중심 테스트 시나리오
- **테스트 없는 코드는 머지 불가**

### 2. 테스트 품질 원칙
- **AAA 패턴**: Arrange-Act-Assert
- **DRY**: 테스트 코드도 중복 제거
- **가독성**: 테스트명에서 의도 명확히
- **독립성**: 각 테스트는 독립 실행 가능

### 3. 커버리지 원칙
- **핵심 로직 100%**: 비즈니스 로직
- **UI 컴포넌트 85%**: 위젯 테스트
- **유틸리티 90%**: 순수 함수
- **새 코드 95%**: 신규 작성 코드

## 🔍 문제 해결 가이드

### 자주 발생하는 문제

#### 1. 비동기 테스트 타임아웃
```dart
// 문제: Test timed out
// 해결:
test('비동기 작업 테스트', () async {
  // timeout 연장
  await tester.runAsync(() async {
    await Future.delayed(Duration(seconds: 2));
  });
}, timeout: Timeout(Duration(seconds: 10)));
```

#### 2. Mock 데이터 타입 불일치
```dart
// 문제: type 'Null' is not a subtype of type 'String'
// 해결:
when(mockService.getValue()).thenReturn('default');
// 또는
when(mockService.getValue()).thenReturn(null);
```

#### 3. 골든 테스트 실패
```dart
// 문제: Golden does not match
// 해결:
// 1. 골든 파일 업데이트
flutter test --update-goldens

// 2. 폰트 로드 확인
await loadAppFonts();
```

---

*이 문서는 Core 레이어 전체의 통합 테스트 전략과 실행 계획을 담고 있습니다.*  
*마이그레이션과 동시에 점진적으로 테스트를 구축하여 85% 이상의 커버리지를 달성합니다.*