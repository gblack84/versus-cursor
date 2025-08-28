# 🧪 Core Widgets Layer - Test Guide

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Widgets 레이어의 포괄적인 테스트 전략과 구현 가이드입니다. 목표는 95% 이상의 테스트 커버리지와 안정적인 위젯 동작 보장입니다.

## 🎯 테스트 목표

1. **위젯 테스트 커버리지**: 95% 이상
2. **골든 테스트**: 모든 주요 위젯의 시각적 회귀 방지
3. **통합 테스트**: 위젯 간 상호작용 검증
4. **성능 테스트**: 렌더링 성능 16ms 이내
5. **접근성 테스트**: WCAG 2.1 AA 준수

## 📊 테스트 커버리지 현황

| 카테고리 | 파일 수 | 테스트 파일 | 커버리지 | 목표 |
|---------|---------|------------|----------|------|
| Buttons | 3 | 0 | 0% | 95% |
| Inputs | 3 | 0 | 0% | 95% |
| Media | 4 | 0 | 0% | 90% |
| Feedback | 3 | 0 | 0% | 95% |
| Layout | 3 | 0 | 0% | 90% |
| Specialized | 2 | 0 | 0% | 85% |
| **총계** | **18** | **0** | **0%** | **95%** |

## 🏗️ 테스트 구조

```
test/core/widgets/
├── buttons/
│   ├── versus_button_test.dart
│   ├── versus_icon_button_test.dart
│   └── versus_toggle_icon_test.dart
├── inputs/
│   ├── versus_text_field_test.dart
│   ├── highlighted_text_field_test.dart
│   └── versus_choice_chips_test.dart
├── media/
│   ├── versus_media_display_test.dart
│   ├── versus_video_player_test.dart
│   ├── youtube_player_test.dart
│   └── unified_video_player_test.dart
├── feedback/
│   ├── versus_loading_test.dart
│   ├── versus_empty_state_test.dart
│   └── versus_error_state_test.dart
├── layout/
│   ├── versus_container_test.dart
│   ├── versus_card_test.dart
│   └── versus_divider_test.dart
├── specialized/
│   ├── pickle_mark_test.dart
│   └── versus_web_view_test.dart
├── golden/
│   ├── goldens/           # 골든 이미지 파일
│   └── golden_test.dart   # 골든 테스트
└── integration/
    └── widget_integration_test.dart
```

## 🧪 테스트 유형별 구현

### 1. 위젯 유닛 테스트

#### VersusButton 테스트 예시
```dart
// test/core/widgets/buttons/versus_button_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/widgets/buttons/versus_button.dart';

void main() {
  group('VersusButton', () {
    late Widget testWidget;

    Widget buildTestWidget(Widget child) {
      return MaterialApp(
        home: Scaffold(body: child),
      );
    }

    group('Rendering', () {
      testWidgets('displays text correctly', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        );

        expect(find.text('Test Button'), findsOneWidget);
      });

      testWidgets('displays icon when provided', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Icon Button',
              icon: const Icon(Icons.add),
              onPressed: () {},
            ),
          ),
        );

        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.text('Icon Button'), findsOneWidget);
      });

      testWidgets('applies correct size', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Large Button',
              size: ButtonSize.large,
              onPressed: () {},
            ),
          ),
        );

        final buttonFinder = find.byType(VersusButton);
        final buttonSize = tester.getSize(buttonFinder);
        
        expect(buttonSize.height, greaterThan(48));
      });
    });

    group('Interaction', () {
      testWidgets('handles tap correctly', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Tap Me',
              onPressed: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.text('Tap Me'));
        await tester.pump();

        expect(tapped, isTrue);
      });

      testWidgets('disables interaction when disabled', (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Disabled',
              isDisabled: true,
              onPressed: () => tapped = true,
            ),
          ),
        );

        await tester.tap(find.text('Disabled'), warnIfMissed: false);
        await tester.pump();

        expect(tapped, isFalse);
      });

      testWidgets('shows loading state', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            const VersusButton(
              text: 'Loading',
              isLoading: true,
              onPressed: null,
            ),
          ),
        );

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Loading'), findsNothing);
      });
    });

    group('Styling', () {
      testWidgets('applies primary variant style', (tester) async {
        await tester.pumpWidget(
          buildTestWidget(
            VersusButton(
              text: 'Primary',
              variant: ButtonVariant.primary,
              onPressed: () {},
            ),
          ),
        );

        final button = tester.widget<VersusButton>(
          find.byType(VersusButton),
        );
        
        expect(button.variant, equals(ButtonVariant.primary));
      });

      testWidgets('applies custom theme', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(
              primaryColor: Colors.red,
            ),
            home: Scaffold(
              body: VersusButton(
                text: 'Themed',
                onPressed: () {},
              ),
            ),
          ),
        );

        // Verify theme is applied
        final context = tester.element(find.byType(VersusButton));
        final theme = Theme.of(context);
        expect(theme.primaryColor, equals(Colors.red));
      });
    });
  });
}
```

### 2. 골든 테스트

```dart
// test/core/widgets/golden/golden_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:versus_space/core/widgets/widgets.dart';

void main() {
  group('Golden Tests', () {
    testGoldens('VersusButton variants', (tester) async {
      final builder = GoldenBuilder.grid(
        columns: 2,
        widthToHeightRatio: 1,
      )
        ..addScenario(
          'Primary',
          VersusButton(
            text: 'Primary Button',
            variant: ButtonVariant.primary,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Secondary',
          VersusButton(
            text: 'Secondary Button',
            variant: ButtonVariant.secondary,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Outlined',
          VersusButton(
            text: 'Outlined Button',
            variant: ButtonVariant.outlined,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Text',
          VersusButton(
            text: 'Text Button',
            variant: ButtonVariant.text,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Danger',
          VersusButton(
            text: 'Danger Button',
            variant: ButtonVariant.danger,
            onPressed: () {},
          ),
        )
        ..addScenario(
          'Loading',
          const VersusButton(
            text: 'Loading',
            isLoading: true,
            onPressed: null,
          ),
        );

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'versus_button_variants');
    });

    testGoldens('VersusTextField states', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'Default',
          const VersusTextField(
            hintText: 'Enter text...',
          ),
        )
        ..addScenario(
          'With Label',
          const VersusTextField(
            labelText: 'Username',
            hintText: 'Enter username...',
          ),
        )
        ..addScenario(
          'Error State',
          const VersusTextField(
            hintText: 'Enter email...',
            errorText: 'Invalid email address',
          ),
        )
        ..addScenario(
          'Multiline',
          const VersusTextField(
            hintText: 'Enter description...',
            maxLines: 3,
          ),
        );

      await tester.pumpWidgetBuilder(builder.build());
      await screenMatchesGolden(tester, 'versus_textfield_states');
    });
  });
}
```

### 3. 통합 테스트

```dart
// test/core/widgets/integration/widget_integration_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Widget Integration Tests', () {
    testWidgets('Form submission flow', (tester) async {
      await tester.pumpWidget(TestApp());

      // Find widgets
      final emailField = find.byKey(const Key('email_field'));
      final passwordField = find.byKey(const Key('password_field'));
      final submitButton = find.byKey(const Key('submit_button'));

      // Enter email
      await tester.enterText(emailField, 'test@example.com');
      await tester.pump();

      // Enter password
      await tester.enterText(passwordField, 'password123');
      await tester.pump();

      // Submit form
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Verify success
      expect(find.text('Form submitted successfully'), findsOneWidget);
    });

    testWidgets('Media player interaction', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusVideoPlayer(
              url: 'https://example.com/video.mp4',
              showControls: true,
            ),
          ),
        ),
      );

      // Wait for initialization
      await tester.pumpAndSettle();

      // Find play button
      final playButton = find.byIcon(Icons.play_arrow);
      expect(playButton, findsOneWidget);

      // Tap play
      await tester.tap(playButton);
      await tester.pump();

      // Verify playing
      expect(find.byIcon(Icons.pause), findsOneWidget);
    });
  });
}
```

### 4. 성능 테스트

```dart
// test/core/widgets/performance/performance_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/widgets/widgets.dart';

void main() {
  group('Performance Tests', () {
    testWidgets('VersusButton renders under 16ms', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton(
              text: 'Performance Test',
              onPressed: () {},
            ),
          ),
        ),
      );

      stopwatch.stop();
      
      // Verify render time is under 16ms (60fps)
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(16),
        reason: 'Widget should render in under 16ms for 60fps',
      );
    });

    testWidgets('List of 100 buttons performs well', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => VersusButton(
                text: 'Button $index',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      stopwatch.stop();
      
      // Verify initial render is reasonable
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(100),
        reason: 'Large list should render efficiently',
      );
    });
  });
}
```

### 5. 접근성 테스트

```dart
// test/core/widgets/accessibility/accessibility_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/widgets/widgets.dart';

void main() {
  group('Accessibility Tests', () {
    testWidgets('VersusButton has semantic label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton(
              text: 'Submit',
              onPressed: () {},
            ),
          ),
        ),
      );

      // Find by semantic label
      expect(
        find.bySemanticsLabel('Submit'),
        findsOneWidget,
      );
    });

    testWidgets('VersusTextField announces errors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: VersusTextField(
              hintText: 'Email',
              errorText: 'Invalid email format',
            ),
          ),
        ),
      );

      // Verify error is announced
      final semantics = tester.getSemantics(find.byType(VersusTextField));
      expect(
        semantics.label,
        contains('Invalid email format'),
      );
    });

    testWidgets('Focus traversal works correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                VersusTextField(key: Key('field1')),
                VersusTextField(key: Key('field2')),
                VersusButton(
                  key: Key('button'),
                  text: 'Submit',
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      // Tab through elements
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      
      // Verify focus order
      expect(
        tester.widget<VersusTextField>(find.byKey(Key('field1'))).focusNode?.hasFocus,
        isTrue,
      );
    });
  });
}
```

## 📝 테스트 작성 가이드

### 테스트 명명 규칙

```dart
// 패턴: [테스트 대상]_[동작]_[예상 결과]
'button_whenTapped_callsOnPressed'
'textField_withErrorText_displaysErrorMessage'
'loading_whenTrue_showsProgressIndicator'
```

### 테스트 구조 (AAA Pattern)

```dart
testWidgets('description', (tester) async {
  // Arrange - 준비
  final widget = VersusButton(
    text: 'Test',
    onPressed: () {},
  );

  // Act - 실행
  await tester.pumpWidget(buildTestWidget(widget));
  await tester.tap(find.text('Test'));
  await tester.pump();

  // Assert - 검증
  expect(find.text('Test'), findsOneWidget);
});
```

### 테스트 헬퍼 함수

```dart
// test/core/widgets/test_helpers.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 테스트용 MaterialApp 래퍼
Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

/// 테마가 적용된 테스트 위젯
Widget buildThemedTestWidget(Widget child, ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(body: child),
  );
}

/// 비동기 작업 대기
Future<void> pumpUntilFound(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 10),
}) async {
  final end = DateTime.now().add(timeout);
  
  do {
    if (DateTime.now().isAfter(end)) {
      throw TestFailure('Timeout waiting for $finder');
    }
    
    await tester.pump(const Duration(milliseconds: 100));
  } while (finder.evaluate().isEmpty);
}
```

## 🏃 테스트 실행

### 모든 테스트 실행
```bash
# 전체 테스트 실행
flutter test

# 커버리지 포함
flutter test --coverage

# 특정 디렉토리
flutter test test/core/widgets/

# 특정 파일
flutter test test/core/widgets/buttons/versus_button_test.dart
```

### 골든 테스트 실행
```bash
# 골든 테스트 실행
flutter test --update-goldens

# CI/CD에서 골든 테스트 검증
flutter test --tags=golden
```

### 통합 테스트 실행
```bash
# 통합 테스트 실행
flutter test integration_test/

# 특정 디바이스에서 실행
flutter test integration_test/ -d chrome
```

## 📊 커버리지 리포트

### 커버리지 생성 및 확인
```bash
# 커버리지 생성
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 리포트 열기
open coverage/html/index.html
```

### 최소 커버리지 강제
```yaml
# pubspec.yaml
dev_dependencies:
  test_coverage: ^0.5.0

# .github/workflows/test.yml
- name: Check test coverage
  run: |
    flutter test --coverage
    test_coverage --min-coverage=95
```

## 🐛 디버깅 팁

### 위젯 트리 출력
```dart
testWidgets('debug widget tree', (tester) async {
  await tester.pumpWidget(widget);
  
  // 위젯 트리 출력
  debugDumpApp();
  
  // 렌더 트리 출력
  debugDumpRenderTree();
  
  // 레이어 트리 출력
  debugDumpLayerTree();
});
```

### 스크린샷 캡처
```dart
testWidgets('capture screenshot on failure', (tester) async {
  await tester.pumpWidget(widget);
  
  try {
    expect(find.text('NonExistent'), findsOneWidget);
  } catch (e) {
    // 실패 시 스크린샷 저장
    final bytes = await tester.binding.takeScreenshot();
    final file = File('test/failures/screenshot.png');
    await file.writeAsBytes(bytes);
    rethrow;
  }
});
```

### 애니메이션 테스트
```dart
testWidgets('test animation', (tester) async {
  await tester.pumpWidget(AnimatedWidget());
  
  // 애니메이션 시작
  await tester.tap(find.text('Animate'));
  
  // 애니메이션 진행
  await tester.pump(); // 0% 진행
  await tester.pump(Duration(milliseconds: 500)); // 50% 진행
  await tester.pump(Duration(milliseconds: 500)); // 100% 완료
  
  // 또는 애니메이션 완료까지 대기
  await tester.pumpAndSettle();
});
```

## 🚨 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/widget_tests.yml
name: Widget Tests

on:
  push:
    paths:
      - 'lib/core/widgets/**'
      - 'test/core/widgets/**'
  pull_request:
    paths:
      - 'lib/core/widgets/**'
      - 'test/core/widgets/**'

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
      run: flutter test test/core/widgets/ --coverage
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: coverage/lcov.info
    
    - name: Check minimum coverage
      run: |
        COVERAGE=$(lcov --summary coverage/lcov.info | grep lines | sed 's/.*: \([0-9.]*\)%.*/\1/')
        if (( $(echo "$COVERAGE < 95" | bc -l) )); then
          echo "Coverage $COVERAGE% is below 95%"
          exit 1
        fi
```

## ✅ 테스트 체크리스트

### 각 위젯별 필수 테스트

#### 버튼 위젯
- [ ] 텍스트 렌더링
- [ ] 아이콘 렌더링
- [ ] 클릭 이벤트
- [ ] 비활성화 상태
- [ ] 로딩 상태
- [ ] 각 variant 스타일
- [ ] 각 size 적용

#### 입력 위젯
- [ ] 텍스트 입력
- [ ] 포커스 처리
- [ ] 유효성 검사
- [ ] 에러 표시
- [ ] 최대 길이 제한
- [ ] 멀티라인 지원

#### 미디어 위젯
- [ ] 이미지 로딩
- [ ] 비디오 재생
- [ ] 에러 처리
- [ ] 플레이스홀더
- [ ] 컨트롤 표시

#### 피드백 위젯
- [ ] 로딩 표시
- [ ] 빈 상태 표시
- [ ] 에러 상태 표시
- [ ] 액션 버튼 처리

## 📚 참고 자료

### 공식 문서
- [Flutter Testing](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Golden Testing](https://github.com/eBay/flutter_glove_box)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

### 유용한 패키지
- `flutter_test`: 기본 테스트 프레임워크
- `golden_toolkit`: 골든 테스트 도구
- `mocktail`: Mock 객체 생성
- `test_coverage`: 커버리지 검증
- `patrol`: E2E 테스트 프레임워크

---

*이 문서는 Core Widgets 레이어의 테스트 가이드입니다.*
*지속적으로 업데이트되며, 모든 위젯은 이 가이드를 따라 테스트되어야 합니다.*