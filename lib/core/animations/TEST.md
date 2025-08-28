# 🧪 Core Animations 테스트 가이드

> Core Animations 레이어의 포괄적 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 85%+

## 📋 테스트 전략 개요

### 테스트 피라미드
```
        E2E Tests (5%)
       /            \
    Integration (25%)
   /                  \
  Unit Tests (70%)
 /                      \
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 커버리지 목표
- **전체 목표**: 85% 이상
- **단위 테스트**: 90% (효과, 프리셋, 모델)
- **통합 테스트**: 75% (서비스, 컨트롤러 풀)
- **E2E 테스트**: 60% (실제 애니메이션 플로우)

## 🎯 테스트 범위

### Core 레이어 테스트
```
core/animations/
├── interfaces/      → 인터페이스 구현 검증
├── models/         → 모델 직렬화, 상태 관리
├── effects/        → 각 효과의 동작 검증
└── presets/        → 프리셋 적용 테스트
```

### Service 레이어 테스트
```
services/animations/
├── animation_service.dart     → 서비스 통합 테스트
├── controller_pool.dart       → 풀 관리 테스트
└── performance_monitor.dart   → 성능 측정 테스트
```

## 📝 단위 테스트

### 1. 효과 테스트
```dart
// test/core/animations/effects/fade_effect_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/animations/effects/basic/fade_effect.dart';

void main() {
  group('FadeEffect', () {
    late FadeEffect fadeEffect;
    late AnimationController controller;
    
    setUp(() {
      fadeEffect = FadeEffect(
        begin: 0.0,
        end: 1.0,
        duration: const Duration(milliseconds: 300),
      );
      
      controller = AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: TestVSync(),
      );
    });
    
    tearDown(() {
      controller.dispose();
    });
    
    test('초기값 확인', () {
      expect(fadeEffect.begin, 0.0);
      expect(fadeEffect.end, 1.0);
      expect(fadeEffect.duration, const Duration(milliseconds: 300));
    });
    
    test('애니메이션 진행 확인', () async {
      final animation = Tween<double>(
        begin: fadeEffect.begin,
        end: fadeEffect.end,
      ).animate(controller);
      
      controller.forward();
      
      // 시작
      expect(animation.value, 0.0);
      
      // 중간
      controller.value = 0.5;
      expect(animation.value, 0.5);
      
      // 완료
      controller.value = 1.0;
      expect(animation.value, 1.0);
    });
    
    test('역방향 애니메이션', () async {
      controller.value = 1.0;
      controller.reverse();
      
      await tester.pumpAndSettle();
      expect(controller.value, 0.0);
    });
  });
}
```

### 2. 프리셋 테스트
```dart
// test/core/animations/presets/page_transitions_test.dart
void main() {
  group('PageTransitions Presets', () {
    testWidgets('FadeIn 프리셋 적용', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Container(
            child: Text('Test').applyPreset(PageTransitions.fadeIn),
          ),
        ),
      );
      
      // 초기 투명도 확인
      final opacity = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(opacity.opacity.value, 0.0);
      
      // 애니메이션 완료
      await tester.pumpAndSettle();
      expect(opacity.opacity.value, 1.0);
    });
    
    testWidgets('SlideUp 프리셋 적용', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Container(
            child: Text('Test').applyPreset(PageTransitions.slideUp),
          ),
        ),
      );
      
      // 초기 위치 확인
      final slideTransition = tester.widget<SlideTransition>(
        find.byType(SlideTransition),
      );
      expect(slideTransition.position.value, const Offset(0, 1));
      
      // 애니메이션 완료
      await tester.pumpAndSettle();
      expect(slideTransition.position.value, Offset.zero);
    });
  });
}
```

### 3. 모델 테스트
```dart
// test/core/animations/models/animation_config_test.dart
void main() {
  group('AnimationConfig', () {
    test('기본값 생성', () {
      final config = AnimationConfig();
      
      expect(config.duration, const Duration(milliseconds: 300));
      expect(config.curve, Curves.easeInOut);
      expect(config.delay, Duration.zero);
      expect(config.loop, false);
      expect(config.reverse, false);
    });
    
    test('커스텀 값 생성', () {
      final config = AnimationConfig(
        duration: const Duration(seconds: 1),
        curve: Curves.elasticOut,
        delay: const Duration(milliseconds: 100),
        loop: true,
        reverse: true,
      );
      
      expect(config.duration, const Duration(seconds: 1));
      expect(config.curve, Curves.elasticOut);
      expect(config.loop, true);
    });
    
    test('copyWith 메서드', () {
      final original = AnimationConfig();
      final modified = original.copyWith(
        duration: const Duration(seconds: 2),
      );
      
      expect(modified.duration, const Duration(seconds: 2));
      expect(modified.curve, original.curve); // 변경되지 않은 값 유지
    });
  });
}
```

## 🔗 통합 테스트

### 1. 애니메이션 서비스 테스트
```dart
// test/services/animations/animation_service_test.dart
@GenerateMocks([ControllerPool, PerformanceMonitor])
void main() {
  group('AnimationService Integration', () {
    late AnimationService service;
    late MockControllerPool mockPool;
    late MockPerformanceMonitor mockMonitor;
    
    setUp(() {
      mockPool = MockControllerPool();
      mockMonitor = MockPerformanceMonitor();
      service = AnimationService(mockPool, mockMonitor);
      
      // 프리셋 등록
      service.registerPreset(PageTransitions.fadeIn);
      service.registerPreset(PageTransitions.slideUp);
    });
    
    testWidgets('프리셋 적용 및 성능 추적', (tester) async {
      final controller = AnimationController(
        vsync: TestVSync(),
        duration: const Duration(milliseconds: 300),
      );
      
      when(mockPool.get()).thenReturn(controller);
      
      final widget = Container(
        child: Text('Test'),
      );
      
      final animated = service.applyPreset(
        widget,
        'fadeIn',
      );
      
      // 컨트롤러 풀 사용 확인
      verify(mockPool.get()).called(1);
      
      // 성능 모니터링 확인
      verify(mockMonitor.track('fadeIn')).called(1);
      
      expect(animated, isA<Widget>());
    });
    
    test('접근성 모드에서 애니메이션 비활성화', () {
      service.setReduceMotion(true);
      
      final widget = Container();
      final result = service.applyPreset(widget, 'fadeIn');
      
      // 애니메이션 없이 원본 반환
      expect(result, same(widget));
      verifyNever(mockPool.get());
    });
  });
}
```

### 2. 컨트롤러 풀 테스트
```dart
// test/services/animations/controller_pool_test.dart
void main() {
  group('ControllerPool', () {
    late ControllerPool pool;
    
    setUp(() {
      pool = ControllerPool();
    });
    
    test('컨트롤러 재사용', () {
      final controller1 = pool.get();
      pool.release(controller1);
      
      final controller2 = pool.get();
      expect(controller2, same(controller1)); // 같은 인스턴스 재사용
    });
    
    test('최대 풀 크기 제한', () {
      final controllers = <AnimationController>[];
      
      // 최대 크기까지 생성
      for (int i = 0; i < 15; i++) {
        controllers.add(pool.get());
      }
      
      // 모두 반환
      for (final controller in controllers) {
        pool.release(controller);
      }
      
      // 풀 크기 확인 (최대 10개)
      expect(pool.availableCount, 10);
    });
    
    test('동시 사용 추적', () {
      final c1 = pool.get();
      final c2 = pool.get();
      
      expect(pool.inUseCount, 2);
      
      pool.release(c1);
      expect(pool.inUseCount, 1);
      
      pool.release(c2);
      expect(pool.inUseCount, 0);
    });
  });
}
```

### 3. 성능 모니터 테스트
```dart
// test/services/animations/performance_monitor_test.dart
void main() {
  group('PerformanceMonitor', () {
    late PerformanceMonitor monitor;
    
    setUp(() {
      monitor = PerformanceMonitor();
    });
    
    test('애니메이션 추적', () {
      monitor.track('fadeIn');
      monitor.track('fadeIn');
      monitor.track('slideUp');
      
      final fadeMetrics = monitor.getMetrics('fadeIn');
      expect(fadeMetrics?.count, 2);
      
      final slideMetrics = monitor.getMetrics('slideUp');
      expect(slideMetrics?.count, 1);
    });
    
    test('프레임 드롭 기록', () {
      monitor.track('complexAnimation');
      monitor.reportFrameDrop('complexAnimation', 10);
      
      final metrics = monitor.getMetrics('complexAnimation');
      expect(metrics?.maxFrameDrop, 10);
      expect(metrics?.hasPerformanceIssue, true);
    });
    
    test('성능 리포트 생성', () {
      monitor.track('animation1');
      monitor.track('animation1');
      monitor.reportFrameDrop('animation1', 3);
      
      final report = monitor.generateReport();
      expect(report, contains('animation1'));
      expect(report, contains('Count: 2'));
      expect(report, contains('Max Frame Drop: 3'));
    });
  });
}
```

## 🎬 E2E 테스트

### 1. 페이지 전환 시나리오
```dart
// test/e2e/page_transition_test.dart
void main() {
  group('Page Transition E2E', () {
    testWidgets('홈에서 프로필로 전환', (tester) async {
      await tester.pumpWidget(MyApp());
      
      // 홈 페이지 확인
      expect(find.text('Home'), findsOneWidget);
      
      // 프로필 버튼 탭
      await tester.tap(find.byIcon(Icons.person));
      
      // 애니메이션 시작
      await tester.pump();
      
      // 애니메이션 중간 상태 확인
      await tester.pump(const Duration(milliseconds: 150));
      final opacity = tester.widget<FadeTransition>(
        find.byType(FadeTransition),
      );
      expect(opacity.opacity.value, greaterThan(0));
      expect(opacity.opacity.value, lessThan(1));
      
      // 애니메이션 완료
      await tester.pumpAndSettle();
      expect(find.text('Profile'), findsOneWidget);
    });
  });
}
```

### 2. 인터랙션 애니메이션
```dart
// test/e2e/interaction_animation_test.dart
void main() {
  testWidgets('버튼 탭 애니메이션', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onTap: () {},
            child: Text('Tap Me'),
          ),
        ),
      ),
    );
    
    // 버튼 찾기
    final button = find.text('Tap Me');
    expect(button, findsOneWidget);
    
    // 탭 전 크기
    final initialSize = tester.getSize(button);
    
    // 버튼 탭
    await tester.tap(button);
    await tester.pump();
    
    // 스케일 다운 확인
    await tester.pump(const Duration(milliseconds: 50));
    final duringSize = tester.getSize(button);
    expect(duringSize.width, lessThan(initialSize.width));
    
    // 바운스 백
    await tester.pumpAndSettle();
    final finalSize = tester.getSize(button);
    expect(finalSize, equals(initialSize));
  });
}
```

## 🧪 테스트 유틸리티

### TestVSync 구현
```dart
// test/utils/test_vsync.dart
class TestVSync extends TickerProvider {
  @override
  Ticker createTicker(TickerCallback onTick) {
    return Ticker(onTick);
  }
}
```

### AnimationTestHelper
```dart
// test/utils/animation_test_helper.dart
class AnimationTestHelper {
  static Future<void> waitForAnimation(
    WidgetTester tester,
    Duration duration,
  ) async {
    await tester.pump();
    await tester.pump(duration * 0.5); // 중간
    await tester.pump(duration * 0.5); // 완료
  }
  
  static double getOpacity(WidgetTester tester, Finder finder) {
    final fadeTransition = tester.widget<FadeTransition>(finder);
    return fadeTransition.opacity.value;
  }
  
  static Offset getPosition(WidgetTester tester, Finder finder) {
    final slideTransition = tester.widget<SlideTransition>(finder);
    return slideTransition.position.value;
  }
}
```

## 📊 테스트 커버리지 보고서

### 현재 커버리지 (Before)
```
lib/core/animations/
├── app_animations.dart    15% (17/113 lines)
```

### 목표 커버리지 (After)
```
lib/core/animations/
├── interfaces/           95% (테스트 가능한 코드)
├── models/              90% (모든 모델 메서드)
├── effects/             85% (각 효과 동작)
├── presets/             80% (프리셋 적용)

services/animations/
├── animation_service    85% (서비스 로직)
├── controller_pool      90% (풀 관리)
├── performance_monitor  75% (모니터링)
```

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
# .github/workflows/animations_test.yml
name: Animations Tests

on:
  push:
    paths:
      - 'lib/core/animations/**'
      - 'lib/services/animations/**'
      - 'test/**/*animations*'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run animation tests
        run: |
          flutter test test/core/animations/ --coverage
          flutter test test/services/animations/ --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: coverage/lcov.info
          flags: animations
```

## 🔍 디버깅 도구

### AnimationInspector
```dart
// lib/debug/animation_inspector.dart
class AnimationInspector extends StatelessWidget {
  final Widget child;
  final bool enabled;
  
  const AnimationInspector({
    required this.child,
    this.enabled = true,
  });
  
  @override
  Widget build(BuildContext context) {
    if (!enabled || !kDebugMode) {
      return child;
    }
    
    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4),
            color: Colors.black54,
            child: StreamBuilder<AnimationStatus>(
              stream: _animationStatusStream,
              builder: (context, snapshot) {
                return Text(
                  'Animation: ${snapshot.data}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
```

## 📋 테스트 체크리스트

### 단위 테스트
- [ ] 모든 효과 클래스 테스트
- [ ] 모든 프리셋 테스트
- [ ] 모델 직렬화 테스트
- [ ] 유틸리티 함수 테스트

### 통합 테스트
- [ ] 서비스 통합 테스트
- [ ] 컨트롤러 풀 테스트
- [ ] 성능 모니터 테스트
- [ ] 접근성 모드 테스트

### E2E 테스트
- [ ] 페이지 전환 테스트
- [ ] 인터랙션 테스트
- [ ] 복잡한 시나리오 테스트
- [ ] 성능 테스트

### 성능 테스트
- [ ] 60fps 유지 확인
- [ ] 메모리 누수 체크
- [ ] 프레임 드롭 모니터링
- [ ] 배터리 소모 측정

## ⚠️ 주의사항

1. **애니메이션 테스트는 시간 의존적**: `pump()` 사용 시 정확한 시간 지정 필요
2. **플랫폼별 차이**: iOS/Android 애니메이션 동작 차이 고려
3. **Golden 테스트**: 애니메이션 중간 상태 캡처 시 타이밍 중요
4. **성능 테스트**: 실제 디바이스에서 테스트 필수

---

*이 문서는 Core Animations 레이어의 포괄적 테스트 전략을 담고 있습니다.*  
*목표 커버리지 85% 달성을 위한 체계적인 테스트 계획입니다.*