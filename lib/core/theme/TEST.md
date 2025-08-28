# 🧪 Core Theme 테스트 가이드

> 작성일: 2025-08-28 | 대상: Core Theme 레이어 | 커버리지 목표: 95%

## 📊 테스트 전략 개요

Core Theme의 테스트는 디자인 시스템의 일관성, 테마 전환 로직, 상태 관리를 검증합니다.

### 테스트 피라미드
```
         /\
        /  \  E2E Tests (5%)
       /    \  - 테마 전환 시나리오
      /------\
     /        \ Widget Tests (25%)
    /          \ - Theme widgets
   /            \ - UI 일관성
  /--------------\
 /                \ Unit Tests (70%)
/                  \ - Color Tokens
                     - Typography
                     - Theme Provider
```

### 커버리지 목표
- **전체**: 95% 이상
- **Design System**: 100% (Critical)
- **Theme Provider**: 95%
- **UI Components**: 90%

## 🎯 테스트 케이스

### 1. Design System Tests

#### 1.1 Color Tokens 테스트
```dart
// test/core/design_system/tokens/color_tokens_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:versus_space/core/design_system/tokens/color_tokens.dart';

void main() {
  group('ColorTokens', () {
    group('Light Colors', () {
      test('should have correct primary color', () {
        expect(ColorTokens.light.primary, const Color(0xFFD95B5B));
      });
      
      test('should have correct secondary color', () {
        expect(ColorTokens.light.secondary, const Color(0xFF588157));
      });
      
      test('should have sufficient contrast for text', () {
        // WCAG AA 기준 테스트
        final contrast = _calculateContrast(
          ColorTokens.light.text,
          ColorTokens.light.background,
        );
        expect(contrast, greaterThan(4.5)); // AA 기준
      });
      
      test('should have all required colors defined', () {
        expect(ColorTokens.light.primary, isNotNull);
        expect(ColorTokens.light.secondary, isNotNull);
        expect(ColorTokens.light.background, isNotNull);
        expect(ColorTokens.light.surface, isNotNull);
        expect(ColorTokens.light.text, isNotNull);
        expect(ColorTokens.light.textSecondary, isNotNull);
      });
    });
    
    group('Dark Colors', () {
      test('should have correct primary color', () {
        expect(ColorTokens.dark.primary, const Color(0xFF4B39EF));
      });
      
      test('should have sufficient contrast for dark mode', () {
        final contrast = _calculateContrast(
          ColorTokens.dark.text,
          ColorTokens.dark.background,
        );
        expect(contrast, greaterThan(4.5));
      });
    });
    
    group('System Colors', () {
      test('should have semantic colors', () {
        expect(ColorTokens.system.success, const Color(0xFF249689));
        expect(ColorTokens.system.warning, const Color(0xFFF9CF58));
        expect(ColorTokens.system.error, const Color(0xFFFF5963));
        expect(ColorTokens.system.info, const Color(0xFF4B9BFF));
      });
      
      test('semantic colors should be distinguishable', () {
        // 색맹 친화적인지 테스트
        final colors = [
          ColorTokens.system.success,
          ColorTokens.system.warning,
          ColorTokens.system.error,
        ];
        
        for (int i = 0; i < colors.length; i++) {
          for (int j = i + 1; j < colors.length; j++) {
            final distance = _colorDistance(colors[i], colors[j]);
            expect(distance, greaterThan(50)); // 최소 색상 거리
          }
        }
      });
    });
  });
}

double _calculateContrast(Color foreground, Color background) {
  // WCAG 2.1 contrast ratio 계산
  final l1 = foreground.computeLuminance();
  final l2 = background.computeLuminance();
  final lighter = l1 > l2 ? l1 : l2;
  final darker = l1 > l2 ? l2 : l1;
  return (lighter + 0.05) / (darker + 0.05);
}

double _colorDistance(Color c1, Color c2) {
  // Euclidean distance in RGB space
  final dr = c1.red - c2.red;
  final dg = c1.green - c2.green;
  final db = c1.blue - c2.blue;
  return math.sqrt(dr * dr + dg * dg + db * db);
}
```

#### 1.2 Typography Tokens 테스트
```dart
// test/core/design_system/tokens/typography_tokens_test.dart
void main() {
  group('TypographyTokens', () {
    test('should have correct font family', () {
      expect(TypographyTokens.fontFamily, 'Plus Jakarta Sans');
    });
    
    test('should have proper size hierarchy', () {
      final displayLarge = TypographyTokens.displayLarge();
      final displayMedium = TypographyTokens.displayMedium();
      final displaySmall = TypographyTokens.displaySmall();
      
      expect(displayLarge.fontSize, greaterThan(displayMedium.fontSize!));
      expect(displayMedium.fontSize, greaterThan(displaySmall.fontSize!));
    });
    
    test('should maintain consistent font weights', () {
      final display = TypographyTokens.displayLarge();
      final headline = TypographyTokens.headlineLarge();
      
      expect(display.fontWeight, FontWeight.w600);
      expect(headline.fontWeight, FontWeight.w600);
    });
    
    test('should support color overrides', () {
      final style = TypographyTokens.bodyMedium(color: Colors.red);
      expect(style.color, Colors.red);
    });
    
    test('should have appropriate line heights', () {
      final body = TypographyTokens.bodyMedium();
      final display = TypographyTokens.displayLarge();
      
      expect(body.height, greaterThanOrEqualTo(1.4));
      expect(display.height, lessThanOrEqualTo(1.3));
    });
  });
}
```

### 2. Theme Provider Tests

#### 2.1 Theme Provider 단위 테스트
```dart
// test/features/theme/providers/theme_provider_test.dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([ThemeRepository])
void main() {
  late ThemeProvider provider;
  late MockThemeRepository mockRepository;
  
  setUp(() {
    mockRepository = MockThemeRepository();
    provider = ThemeProvider(mockRepository);
  });
  
  group('ThemeProvider', () {
    test('should initialize with system theme by default', () async {
      when(mockRepository.getThemeMode())
          .thenAnswer((_) async => ThemeMode.system);
      
      await provider.initialize();
      
      expect(provider.mode, ThemeMode.system);
      verify(mockRepository.getThemeMode()).called(1);
    });
    
    test('should save theme mode when changed', () async {
      when(mockRepository.saveThemeMode(any))
          .thenAnswer((_) async {});
      
      provider.setThemeMode(ThemeMode.dark);
      
      expect(provider.mode, ThemeMode.dark);
      verify(mockRepository.saveThemeMode(ThemeMode.dark)).called(1);
    });
    
    test('should not save if theme mode unchanged', () {
      provider.setThemeMode(ThemeMode.system);
      provider.setThemeMode(ThemeMode.system);
      
      verifyNever(mockRepository.saveThemeMode(any));
    });
    
    test('should watch theme mode changes', () async {
      final controller = StreamController<ThemeMode>();
      when(mockRepository.watchThemeMode())
          .thenAnswer((_) => controller.stream);
      
      await provider.initialize();
      
      expectLater(
        provider.stream,
        emitsInOrder([ThemeMode.light, ThemeMode.dark]),
      );
      
      controller.add(ThemeMode.light);
      controller.add(ThemeMode.dark);
    });
    
    test('should build light and dark themes', () async {
      await provider.initialize();
      
      expect(provider.lightTheme, isNotNull);
      expect(provider.darkTheme, isNotNull);
      expect(provider.lightTheme!.brightness, Brightness.light);
      expect(provider.darkTheme!.brightness, Brightness.dark);
    });
    
    test('should notify listeners on theme change', () async {
      var notificationCount = 0;
      provider.addListener(() => notificationCount++);
      
      provider.setThemeMode(ThemeMode.dark);
      provider.setThemeMode(ThemeMode.light);
      
      expect(notificationCount, 2);
    });
  });
}
```

#### 2.2 Theme Repository 테스트
```dart
// test/features/theme/data/repositories/theme_repository_impl_test.dart
void main() {
  late ThemeRepositoryImpl repository;
  late SharedPreferences prefs;
  
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    repository = ThemeRepositoryImpl(prefs);
  });
  
  group('ThemeRepositoryImpl', () {
    test('should return system theme when no preference saved', () async {
      final mode = await repository.getThemeMode();
      expect(mode, ThemeMode.system);
    });
    
    test('should save and retrieve theme mode', () async {
      await repository.saveThemeMode(ThemeMode.dark);
      final mode = await repository.getThemeMode();
      
      expect(mode, ThemeMode.dark);
      expect(prefs.getString('theme_mode'), 'dark');
    });
    
    test('should emit theme changes', () async {
      expectLater(
        repository.watchThemeMode(),
        emitsInOrder([ThemeMode.light, ThemeMode.dark]),
      );
      
      await repository.saveThemeMode(ThemeMode.light);
      await repository.saveThemeMode(ThemeMode.dark);
    });
    
    test('should clear theme mode', () async {
      await repository.saveThemeMode(ThemeMode.dark);
      await repository.clearThemeMode();
      
      final mode = await repository.getThemeMode();
      expect(mode, ThemeMode.system);
    });
  });
}
```

### 3. Widget Tests

#### 3.1 Theme Mode Toggle 위젯 테스트
```dart
// test/features/theme/widgets/theme_mode_toggle_test.dart
void main() {
  testWidgets('ThemeModeToggle should display current mode', 
      (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    provider.setThemeMode(ThemeMode.dark);
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: ThemeModeToggle(),
        ),
      ),
    );
    
    expect(find.byIcon(Icons.dark_mode), findsOneWidget);
  });
  
  testWidgets('should cycle through theme modes on tap', 
      (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: ThemeModeToggle(),
        ),
      ),
    );
    
    // System → Light
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(provider.mode, ThemeMode.light);
    
    // Light → Dark
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(provider.mode, ThemeMode.dark);
    
    // Dark → System
    await tester.tap(find.byType(IconButton));
    await tester.pump();
    expect(provider.mode, ThemeMode.system);
  });
}
```

#### 3.2 Adaptive Theme Builder 테스트
```dart
// test/features/theme/widgets/adaptive_theme_builder_test.dart
void main() {
  testWidgets('should apply light theme in light mode', 
      (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    provider.setThemeMode(ThemeMode.light);
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: AdaptiveThemeBuilder(
          builder: (context, theme) {
            return MaterialApp(
              theme: theme.lightTheme,
              darkTheme: theme.darkTheme,
              themeMode: theme.mode,
              home: Container(
                color: Theme.of(context).primaryColor,
              ),
            );
          },
        ),
      ),
    );
    
    final container = tester.widget<Container>(find.byType(Container));
    expect(container.color, ColorTokens.light.primary);
  });
  
  testWidgets('should respond to system brightness changes', 
      (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    provider.setThemeMode(ThemeMode.system);
    
    // 시스템 밝기 변경 시뮬레이션
    tester.platformDispatcher.platformBrightnessTestValue = 
        Brightness.dark;
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: AdaptiveThemeBuilder(
          builder: (context, theme) {
            return MaterialApp(
              theme: theme.lightTheme,
              darkTheme: theme.darkTheme,
              themeMode: theme.mode,
              home: Container(),
            );
          },
        ),
      ),
    );
    
    final materialApp = tester.widget<MaterialApp>(
      find.byType(MaterialApp)
    );
    expect(materialApp.themeMode, ThemeMode.system);
  });
}
```

### 4. Integration Tests

#### 4.1 전체 테마 시스템 통합 테스트
```dart
// test/integration/theme_system_test.dart
void main() {
  testWidgets('Complete theme system integration', 
      (tester) async {
    await tester.pumpWidget(MyApp());
    
    // 초기 테마 확인
    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, 
           Brightness.light);
    
    // 테마 토글 찾기
    final toggle = find.byType(ThemeModeToggle);
    expect(toggle, findsOneWidget);
    
    // Dark 모드로 전환
    await tester.tap(toggle);
    await tester.pumpAndSettle();
    
    expect(Theme.of(tester.element(find.byType(Scaffold))).brightness, 
           Brightness.dark);
    
    // 색상 확인
    final appBar = tester.widget<AppBar>(find.byType(AppBar));
    expect(appBar.backgroundColor, ColorTokens.dark.surface);
  });
}
```

### 5. Golden Tests (시각적 회귀 테스트)

#### 5.1 테마별 스크린샷 테스트
```dart
// test/golden/theme_golden_test.dart
void main() {
  testWidgets('Light theme golden test', (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    provider.setThemeMode(ThemeMode.light);
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: ThemeShowcase(), // 모든 UI 컴포넌트 표시
      ),
    );
    
    await expectLater(
      find.byType(ThemeShowcase),
      matchesGoldenFile('goldens/theme_light.png'),
    );
  });
  
  testWidgets('Dark theme golden test', (tester) async {
    final provider = ThemeProvider(MockThemeRepository());
    provider.setThemeMode(ThemeMode.dark);
    
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: ThemeShowcase(),
      ),
    );
    
    await expectLater(
      find.byType(ThemeShowcase),
      matchesGoldenFile('goldens/theme_dark.png'),
    );
  });
}
```

## 🔄 성능 테스트

### 테마 전환 성능 테스트
```dart
// test/performance/theme_performance_test.dart
void main() {
  test('Theme switching should be fast', () async {
    final provider = ThemeProvider(MockThemeRepository());
    
    final stopwatch = Stopwatch()..start();
    
    for (int i = 0; i < 100; i++) {
      provider.setThemeMode(i.isEven ? ThemeMode.light : ThemeMode.dark);
    }
    
    stopwatch.stop();
    
    // 100번 전환이 1초 이내
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    
    // 평균 10ms 이내
    expect(stopwatch.elapsedMilliseconds / 100, lessThan(10));
  });
  
  test('Theme build should be efficient', () async {
    final stopwatch = Stopwatch()..start();
    
    final lightTheme = buildLightTheme();
    final darkTheme = buildDarkTheme();
    
    stopwatch.stop();
    
    // 테마 생성이 100ms 이내
    expect(stopwatch.elapsedMilliseconds, lessThan(100));
  });
}
```

## 🧩 Mocking Utilities

### Mock 생성기
```dart
// test/mocks/theme_mocks.dart
import 'package:mockito/annotations.dart';

@GenerateMocks([
  ThemeRepository,
  SharedPreferences,
])
void main() {}

// 사용법
class MockThemeProvider extends Mock implements ThemeProvider {
  @override
  ThemeMode get mode => ThemeMode.light;
  
  @override
  ThemeData? get lightTheme => ThemeData.light();
  
  @override
  ThemeData? get darkTheme => ThemeData.dark();
}
```

## 📝 테스트 실행 스크립트

### 전체 테스트 실행
```bash
#!/bin/bash
# run_theme_tests.sh

echo "🧪 Running Theme Tests..."

# Unit Tests
echo "📦 Unit Tests..."
flutter test test/core/design_system/ --coverage
flutter test test/features/theme/domain/ --coverage
flutter test test/features/theme/data/ --coverage

# Widget Tests
echo "🎨 Widget Tests..."
flutter test test/features/theme/widgets/ --coverage

# Integration Tests
echo "🔗 Integration Tests..."
flutter test test/integration/theme_system_test.dart

# Golden Tests
echo "📸 Golden Tests..."
flutter test test/golden/theme_golden_test.dart --update-goldens

# Performance Tests
echo "⚡ Performance Tests..."
flutter test test/performance/theme_performance_test.dart

# Coverage Report
echo "📊 Generating Coverage Report..."
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 특정 테스트 실행
```bash
# Design System만 테스트
flutter test test/core/design_system/

# Theme Provider만 테스트
flutter test test/features/theme/providers/

# Golden 테스트 업데이트
flutter test test/golden/ --update-goldens
```

## ✅ 테스트 체크리스트

### 필수 테스트
- [ ] Color Token 정의 검증
- [ ] Typography 계층 구조
- [ ] Theme Provider 상태 관리
- [ ] Theme Repository 저장/로드
- [ ] 테마 전환 로직
- [ ] WCAG 접근성 기준

### 권장 테스트
- [ ] 시스템 테마 대응
- [ ] 성능 벤치마크
- [ ] 메모리 누수 체크
- [ ] Golden 테스트
- [ ] 다국어 지원

### 선택 테스트
- [ ] 애니메이션 성능
- [ ] 배터리 영향
- [ ] 네트워크 영향

## 📊 커버리지 목표

| 컴포넌트 | 현재 | 목표 | 상태 |
|---------|------|------|------|
| Design System | 0% | 100% | 🔴 |
| Theme Provider | 0% | 95% | 🔴 |
| Theme Repository | 0% | 95% | 🔴 |
| Theme Widgets | 0% | 90% | 🔴 |
| Integration | 0% | 85% | 🔴 |

## 🚨 주의사항

1. **테스트 격리**: 각 테스트는 독립적으로 실행 가능해야 함
2. **Mock 사용**: SharedPreferences는 항상 Mock 사용
3. **Platform 테스트**: iOS/Android 플랫폼별 테스트 필요
4. **Golden 업데이트**: UI 변경 시 Golden 파일 업데이트 필수

---

*이 문서는 Core Theme 레이어의 테스트 가이드입니다.*
*95% 이상의 커버리지로 안정적인 테마 시스템을 보장합니다.*