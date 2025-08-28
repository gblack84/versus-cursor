# 🧪 Core Design System 테스트 전략

> 작성일: 2025-08-28 | 테스트 커버리지 목표: 95% | 디자인 시스템 품질 보증

## 🎯 테스트 목표

Core Design System의 안정성과 일관성을 보장하기 위한 포괄적 테스트:
- ✅ 디자인 토큰 무결성 검증
- ✅ 컴포넌트 동작 정확성
- ✅ 테마 시스템 안정성
- ✅ 접근성 표준 준수

## 📊 테스트 범위

### 테스트 대상
```
lib/core/design_system/
├── tokens/                    
│   ├── versus_colors.dart      [필수] 색상 대비, 테마 일관성
│   ├── versus_spacing.dart     [필수] 간격 계산, EdgeInsets
│   ├── versus_text_styles.dart [필수] 타이포그래피 계층
│   └── versus_radius.dart      [필수] BorderRadius 정확성
├── components/
│   ├── versus_button.dart      [필수] 상호작용, 상태 관리
│   ├── versus_dialog.dart      [필수] 생명주기, 애니메이션
│   └── versus_text_field.dart  [필수] 입력 검증, 포커스
└── theme/
    └── app_theme.dart          [필수] 테마 전환, Material 3
```

### 커버리지 목표
- **Unit Tests**: 95% 이상 (토큰, 유틸리티)
- **Widget Tests**: 90% 이상 (컴포넌트)
- **Integration Tests**: 85% 이상 (테마 시스템)
- **Visual Tests**: 100% (Golden 테스트)

## 🧪 테스트 전략

### 1. Design Token Tests

#### 1.1 색상 시스템 테스트
```dart
// test/core/design_system/tokens/versus_colors_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';

void main() {
  group('VersusColors', () {
    group('색상 대비 테스트 (WCAG AA)', () {
      test('primary 색상이 흰색 배경에서 4.5:1 이상 대비', () {
        final contrast = calculateContrast(
          VersusColors.primary,
          Colors.white,
        );
        expect(contrast, greaterThanOrEqualTo(4.5));
      });
      
      test('textPrimary가 backgroundPrimary에서 읽기 가능', () {
        final contrast = calculateContrast(
          VersusColors.textPrimary,
          VersusColors.backgroundPrimary,
        );
        expect(contrast, greaterThanOrEqualTo(7.0)); // AAA 기준
      });
      
      test('error 색상이 충분한 대비 제공', () {
        final contrast = calculateContrast(
          VersusColors.error,
          VersusColors.backgroundPrimary,
        );
        expect(contrast, greaterThanOrEqualTo(3.0)); // AA Large
      });
    });
    
    group('알파값 헬퍼 메서드', () {
      test('primaryWithAlpha가 올바른 투명도 적용', () {
        final color = VersusColors.primaryWithAlpha(0.5);
        expect(color.alpha, equals(128)); // 0.5 * 255
        expect(color.red, equals(VersusColors.primary.red));
      });
      
      test('알파값 범위 검증 (0.0 ~ 1.0)', () {
        expect(
          () => VersusColors.primaryWithAlpha(-0.1),
          throwsAssertionError,
        );
        expect(
          () => VersusColors.primaryWithAlpha(1.1),
          throwsAssertionError,
        );
      });
    });
    
    group('다크모드 색상 준비도', () {
      test('다크모드 색상 정의 확인', () {
        expect(VersusColors.darkPrimary, isNotNull);
        expect(VersusColors.darkBackground, isNotNull);
        expect(VersusColors.darkTextPrimary, isNotNull);
      });
      
      test('다크모드 색상 대비 검증', () {
        final contrast = calculateContrast(
          VersusColors.darkTextPrimary,
          VersusColors.darkBackground,
        );
        expect(contrast, greaterThanOrEqualTo(4.5));
      });
    });
  });
}

// 헬퍼 함수: WCAG 대비 계산
double calculateContrast(Color color1, Color color2) {
  final l1 = color1.computeLuminance();
  final l2 = color2.computeLuminance();
  final lMax = l1 > l2 ? l1 : l2;
  final lMin = l1 < l2 ? l1 : l2;
  return (lMax + 0.05) / (lMin + 0.05);
}
```

#### 1.2 간격 시스템 테스트
```dart
// test/core/design_system/tokens/versus_spacing_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/design_system/tokens/versus_spacing.dart';

void main() {
  group('VersusSpacing', () {
    group('4px 그리드 시스템', () {
      test('모든 간격이 4의 배수 또는 정의된 값', () {
        expect(VersusSpacing.xs, equals(4.0));
        expect(VersusSpacing.sm, equals(8.0));
        expect(VersusSpacing.md, equals(16.0));
        expect(VersusSpacing.lg, equals(20.0)); // 예외: 자주 사용
        expect(VersusSpacing.xl, equals(32.0));
      });
      
      test('간격 값이 점진적으로 증가', () {
        expect(VersusSpacing.xs, lessThan(VersusSpacing.sm));
        expect(VersusSpacing.sm, lessThan(VersusSpacing.md));
        expect(VersusSpacing.md, lessThan(VersusSpacing.lg));
        expect(VersusSpacing.lg, lessThan(VersusSpacing.xl));
      });
    });
    
    group('EdgeInsets 헬퍼', () {
      test('paddingMD가 올바른 EdgeInsets 생성', () {
        final padding = VersusSpacing.paddingMD;
        expect(padding.left, equals(16.0));
        expect(padding.top, equals(16.0));
        expect(padding.right, equals(16.0));
        expect(padding.bottom, equals(16.0));
      });
      
      test('horizontal 헬퍼가 대칭 패딩 생성', () {
        final padding = VersusSpacing.horizontal(20.0);
        expect(padding.left, equals(20.0));
        expect(padding.right, equals(20.0));
        expect(padding.top, equals(0.0));
        expect(padding.bottom, equals(0.0));
      });
      
      test('custom 패딩 생성기 동작', () {
        final padding = VersusSpacing.custom(
          top: 10,
          left: 20,
        );
        expect(padding.top, equals(10.0));
        expect(padding.left, equals(20.0));
        expect(padding.right, equals(0.0));
        expect(padding.bottom, equals(0.0));
      });
    });
    
    group('자주 사용되는 패턴', () {
      test('screenPadding이 20px 적용', () {
        expect(VersusSpacing.screenPadding, equals(20.0));
        
        final padding = VersusSpacing.screenHorizontal;
        expect(padding.left, equals(20.0));
        expect(padding.right, equals(20.0));
      });
      
      test('cardPadding이 md 값과 일치', () {
        expect(VersusSpacing.cardPadding, equals(VersusSpacing.md));
      });
    });
  });
}
```

#### 1.3 타이포그래피 테스트
```dart
// test/core/design_system/tokens/versus_text_styles_test.dart
void main() {
  group('VersusTextStyles', () {
    group('폰트 계층 구조', () {
      test('heading 크기가 계층적', () {
        expect(
          VersusTextStyles.headingLarge.fontSize,
          greaterThan(VersusTextStyles.headingMedium.fontSize),
        );
        expect(
          VersusTextStyles.headingMedium.fontSize,
          greaterThan(VersusTextStyles.headingSmall.fontSize),
        );
      });
      
      test('heading이 body보다 굵음', () {
        expect(
          VersusTextStyles.headingMedium.fontWeight,
          equals(FontWeight.w600),
        );
        expect(
          VersusTextStyles.bodyMedium.fontWeight,
          equals(FontWeight.normal),
        );
      });
    });
    
    group('폰트 패밀리', () {
      test('모든 스타일이 Plus Jakarta Sans 사용', () {
        expect(
          VersusTextStyles.headingLarge.fontFamily,
          contains('Plus Jakarta Sans'),
        );
        expect(
          VersusTextStyles.bodyMedium.fontFamily,
          contains('Plus Jakarta Sans'),
        );
      });
    });
    
    group('색상 일관성', () {
      test('기본 텍스트 색상이 정의된 값 사용', () {
        expect(
          VersusTextStyles.bodyMedium.color,
          equals(VersusColors.textPrimary),
        );
        expect(
          VersusTextStyles.labelMedium.color,
          equals(VersusColors.textSecondary),
        );
      });
    });
  });
}
```

### 2. Component Widget Tests

#### 2.1 버튼 컴포넌트 테스트
```dart
// test/core/design_system/components/versus_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/design_system/components/versus_button.dart';

void main() {
  group('VersusButton', () {
    testWidgets('primary 버튼 렌더링', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.primary(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
    
    testWidgets('비활성화 상태 처리', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.primary(
              text: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );
      
      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });
    
    testWidgets('로딩 상태 표시', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.primary(
              text: 'Loading',
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });
    
    testWidgets('탭 이벤트 처리', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.primary(
              text: 'Tap Me',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Tap Me'));
      expect(tapped, isTrue);
    });
    
    testWidgets('아이콘 버튼 렌더링', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.icon(
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
```

#### 2.2 다이얼로그 테스트
```dart
// test/core/design_system/components/versus_dialog_test.dart
void main() {
  group('VersusDialog', () {
    testWidgets('warning 다이얼로그 표시', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                VersusDialog.warning(
                  context: context,
                  title: '경고',
                  content: '테스트 메시지',
                );
              },
              child: Text('Show Dialog'),
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      expect(find.text('경고'), findsOneWidget);
      expect(find.text('테스트 메시지'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });
    
    testWidgets('다이얼로그 닫기', (tester) async {
      // 다이얼로그 표시
      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();
      
      // 닫기 버튼 탭
      await tester.tap(find.text('닫기'));
      await tester.pumpAndSettle();
      
      expect(find.text('경고'), findsNothing);
    });
  });
}
```

#### 2.3 텍스트 필드 테스트
```dart
// test/core/design_system/components/versus_text_field_test.dart
void main() {
  group('VersusTextField', () {
    testWidgets('텍스트 입력', (tester) async {
      final controller = TextEditingController();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusTextField(
              controller: controller,
              hintText: 'Enter text',
            ),
          ),
        ),
      );
      
      await tester.enterText(find.byType(TextField), 'Hello World');
      expect(controller.text, equals('Hello World'));
    });
    
    testWidgets('이메일 검증', (tester) async {
      String? errorText;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusTextField.email(
              onValidate: (error) => errorText = error,
            ),
          ),
        ),
      );
      
      // 잘못된 이메일
      await tester.enterText(find.byType(TextField), 'invalid');
      await tester.pump();
      expect(errorText, isNotNull);
      
      // 올바른 이메일
      await tester.enterText(find.byType(TextField), 'test@example.com');
      await tester.pump();
      expect(errorText, isNull);
    });
    
    testWidgets('패스워드 토글', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusTextField.password(),
          ),
        ),
      );
      
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, isTrue);
      
      // 토글 버튼 탭
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();
      
      final updatedField = tester.widget<TextField>(find.byType(TextField));
      expect(updatedField.obscureText, isFalse);
    });
  });
}
```

### 3. Theme System Tests

#### 3.1 테마 전환 테스트
```dart
// test/core/design_system/theme/app_theme_test.dart
void main() {
  group('AppTheme', () {
    test('light 테마 생성', () {
      final theme = AppTheme.light();
      
      expect(theme.brightness, equals(Brightness.light));
      expect(theme.useMaterial3, isTrue);
      expect(theme.colorScheme.primary, equals(Color(0xFFD95B5B)));
    });
    
    test('dark 테마 생성', () {
      final theme = AppTheme.dark();
      
      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.useMaterial3, isTrue);
    });
    
    testWidgets('테마 전환 동작', (tester) async {
      var isDark = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () => setState(() => isDark = !isDark),
                child: Text('Toggle'),
              ),
            ),
          ),
        ),
      );
      
      // 초기: light
      var theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, equals(Brightness.light));
      
      // 전환 후: dark
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      
      theme = Theme.of(tester.element(find.byType(Scaffold)));
      expect(theme.brightness, equals(Brightness.dark));
    });
  });
}
```

#### 3.2 Theme Extension 테스트
```dart
// test/core/design_system/theme/theme_extensions_test.dart
void main() {
  group('Theme Extensions', () {
    testWidgets('AppColorScheme 접근', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Builder(
            builder: (context) {
              final colors = Theme.of(context).extension<AppColorScheme>()!;
              expect(colors.primary, isNotNull);
              expect(colors.secondary, isNotNull);
              return Container();
            },
          ),
        ),
      );
    });
    
    test('AppColorScheme lerp 동작', () {
      final colors1 = AppColorScheme.light;
      final colors2 = AppColorScheme.dark;
      
      final lerped = colors1.lerp(colors2, 0.5);
      
      expect(lerped.primary, isNot(equals(colors1.primary)));
      expect(lerped.primary, isNot(equals(colors2.primary)));
    });
  });
}
```

### 4. Visual Regression Tests (Golden Tests)

#### 4.1 컴포넌트 Golden 테스트
```dart
// test/core/design_system/golden/components_golden_test.dart
void main() {
  group('Component Golden Tests', () {
    testWidgets('버튼 변형들', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: Column(
              children: [
                VersusButton.primary(text: 'Primary', onPressed: () {}),
                VersusButton.secondary(text: 'Secondary', onPressed: () {}),
                VersusButton.outline(text: 'Outline', onPressed: () {}),
                VersusButton.text(text: 'Text', onPressed: () {}),
                VersusButton.primary(text: 'Disabled', onPressed: null),
                VersusButton.primary(
                  text: 'Loading',
                  onPressed: () {},
                  isLoading: true,
                ),
              ],
            ),
          ),
        ),
      );
      
      await expectLater(
        find.byType(Scaffold),
        matchesGoldenFile('goldens/buttons.png'),
      );
    });
    
    testWidgets('다이얼로그 스타일', (tester) async {
      // Warning, Error, Success, Info 다이얼로그 스냅샷
    });
    
    testWidgets('텍스트 필드 상태', (tester) async {
      // Normal, Focused, Error, Disabled 상태 스냅샷
    });
  });
}
```

#### 4.2 테마별 Golden 테스트
```dart
// test/core/design_system/golden/theme_golden_test.dart
void main() {
  group('Theme Golden Tests', () {
    testWidgets('Light 테마 컴포넌트', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(),
          home: ComponentShowcase(),
        ),
      );
      
      await expectLater(
        find.byType(ComponentShowcase),
        matchesGoldenFile('goldens/light_theme.png'),
      );
    });
    
    testWidgets('Dark 테마 컴포넌트', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark(),
          home: ComponentShowcase(),
        ),
      );
      
      await expectLater(
        find.byType(ComponentShowcase),
        matchesGoldenFile('goldens/dark_theme.png'),
      );
    });
  });
}
```

### 5. Accessibility Tests

#### 5.1 시맨틱 테스트
```dart
// test/core/design_system/accessibility/semantics_test.dart
void main() {
  group('Accessibility', () {
    testWidgets('버튼 시맨틱 레이블', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusButton.primary(
              text: 'Submit',
              onPressed: () {},
              semanticLabel: 'Submit form',
            ),
          ),
        ),
      );
      
      final semantics = tester.getSemantics(find.text('Submit'));
      expect(semantics.label, contains('Submit form'));
      expect(semantics.hasAction(SemanticsAction.tap), isTrue);
    });
    
    testWidgets('텍스트 필드 힌트 접근성', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersusTextField(
              hintText: 'Enter your name',
              semanticLabel: 'Name input field',
            ),
          ),
        ),
      );
      
      final semantics = tester.getSemantics(find.byType(TextField));
      expect(semantics.label, contains('Name input field'));
      expect(semantics.isTextField, isTrue);
    });
  });
}
```

### 6. Performance Tests

#### 6.1 렌더링 성능 테스트
```dart
// test/core/design_system/performance/rendering_test.dart
void main() {
  group('Performance', () {
    testWidgets('버튼 렌더링 성능', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: 100,
              itemBuilder: (context, index) => VersusButton.primary(
                text: 'Button $index',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );
      
      stopwatch.stop();
      
      // 100개 버튼 렌더링이 100ms 이내
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
    
    testWidgets('테마 전환 성능', (tester) async {
      var isDark = false;
      
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            theme: isDark ? AppTheme.dark() : AppTheme.light(),
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () => setState(() => isDark = !isDark),
                child: Text('Toggle'),
              ),
            ),
          ),
        ),
      );
      
      final stopwatch = Stopwatch()..start();
      await tester.tap(find.text('Toggle'));
      await tester.pump();
      stopwatch.stop();
      
      // 테마 전환이 16ms 이내 (60fps)
      expect(stopwatch.elapsedMilliseconds, lessThan(16));
    });
  });
}
```

## 🔧 테스트 도구

### 필수 Dependencies
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  golden_toolkit: ^0.15.0
  mocktail: ^1.0.0
  test: ^1.24.0
```

### 테스트 실행 스크립트
```bash
# 모든 테스트 실행
flutter test

# 커버리지 포함 실행
flutter test --coverage

# 특정 디렉토리 테스트
flutter test test/core/design_system/

# Golden 테스트 업데이트
flutter test --update-goldens

# 성능 테스트만 실행
flutter test test/core/design_system/performance/
```

## 📈 테스트 커버리지 목표

### Phase 1 (즉시)
- [ ] 색상 대비 테스트: 100%
- [ ] 간격 시스템 테스트: 100%
- [ ] 버튼 기본 동작: 90%

### Phase 2 (1주일)
- [ ] 모든 컴포넌트 위젯 테스트: 90%
- [ ] 테마 시스템 테스트: 85%
- [ ] Golden 테스트 기반 구축

### Phase 3 (2주일)
- [ ] 접근성 테스트: 100%
- [ ] 성능 테스트: 완료
- [ ] 전체 커버리지: 95% 이상

## ⚠️ 테스트 시 주의사항

### 1. 색상 테스트
- WCAG AA/AAA 기준 엄격 적용
- 다크모드 대비도 별도 검증
- 색맹 시뮬레이션 테스트 고려

### 2. 컴포넌트 테스트
- 모든 상태 조합 테스트
- 엣지 케이스 처리
- 비동기 동작 검증

### 3. Golden 테스트
- 플랫폼별 폰트 차이 고려
- 화면 크기 변화 대응
- 정기적인 Golden 파일 업데이트

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
name: Design System Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test test/core/design_system/
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit
flutter test test/core/design_system/ || exit 1
```

## 📝 테스트 문서화

### 테스트 케이스 명명 규칙
```dart
// ✅ Good
test('primary 색상이 흰색 배경에서 4.5:1 이상 대비', () {});

// ❌ Bad
test('test color contrast', () {});
```

### 테스트 그룹 구조
```dart
group('ComponentName', () {
  group('Feature/Behavior', () {
    test('specific scenario in Korean', () {});
    test('edge case description', () {});
  });
});
```

## 📊 테스트 리포트

### 주간 테스트 리포트
- 테스트 실행 횟수
- 실패/성공 비율
- 커버리지 변화
- 성능 메트릭

### 월간 분석
- 자주 실패하는 테스트
- 커버리지 부족 영역
- 성능 추세
- 개선 제안

---

*이 문서는 Core Design System의 포괄적 테스트 전략을 담고 있습니다.*
*95% 이상의 테스트 커버리지로 안정적인 디자인 시스템을 보장합니다.*