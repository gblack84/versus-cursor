# 🧪 UI Service 테스트 가이드

> 반응형 디자인 및 박스 계산 서비스 테스트 전략  
> 작성일: 2025-08-28 | 목표 커버리지: 90%

## 📋 테스트 개요

UI Service는 애플리케이션 전체의 UI 일관성과 반응형 동작을 담당하므로 철저한 테스트가 필요합니다.

### 테스트 범위
- **반응형 브레이크포인트**: 디바이스별 정확한 타입 감지
- **박스 크기 계산**: 다양한 조합의 정확한 크기 산출
- **캐싱 동작**: 성능 최적화 검증
- **엣지 케이스**: 극단적 크기, null 값 처리

## 🎯 테스트 목표

### 정량적 목표
```yaml
coverage:
  line: 90%
  branch: 85%
  function: 95%

performance:
  unit_test_time: < 100ms
  integration_test_time: < 1s
  widget_test_time: < 500ms

reliability:
  flakiness: 0%
  false_positives: 0%
```

## 🏗️ 테스트 구조

### 디렉토리 구조
```
test/services/ui/
├── unit/
│   ├── responsive_breakpoints_test.dart
│   ├── unified_box_calculator_test.dart
│   └── models/
│       ├── box_sizes_test.dart
│       └── device_type_test.dart
├── integration/
│   ├── responsive_flow_test.dart
│   └── box_calculation_flow_test.dart
├── widget/
│   ├── responsive_widget_test.dart
│   └── vs_box_widget_test.dart
├── performance/
│   ├── calculation_benchmark_test.dart
│   └── cache_performance_test.dart
└── fixtures/
    ├── test_data.dart
    └── mock_helpers.dart
```

## 📝 단위 테스트

### 1. ResponsiveBreakpoints 테스트

#### 1.1 디바이스 타입 감지
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:versus_space/services/ui/responsive_breakpoints.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group('ResponsiveBreakpoints', () {
    group('getDeviceType', () {
      test('should return mobileSmall for width < 320', () {
        final context = createMockContext(width: 300);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.mobileSmall);
      });
      
      test('should return mobile for width 375', () {
        final context = createMockContext(width: 375);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.mobile);
      });
      
      test('should return mobileLarge for width 414', () {
        final context = createMockContext(width: 414);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.mobileLarge);
      });
      
      test('should return tablet for width 768', () {
        final context = createMockContext(width: 768);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.tablet);
      });
      
      test('should return desktop for width 1024', () {
        final context = createMockContext(width: 1024);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.desktop);
      });
      
      test('should return desktopLarge for width 1440', () {
        final context = createMockContext(width: 1440);
        final result = ResponsiveBreakpoints.getDeviceType(context);
        expect(result, DeviceType.desktopLarge);
      });
    });
    
    group('isMobile/isTablet/isDesktop', () {
      test('isMobile should return true for mobile devices', () {
        final context = createMockContext(width: 375);
        expect(ResponsiveBreakpoints.isMobile(context), isTrue);
        expect(ResponsiveBreakpoints.isTablet(context), isFalse);
        expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
      });
      
      test('isTablet should return true for tablet devices', () {
        final context = createMockContext(width: 800);
        expect(ResponsiveBreakpoints.isMobile(context), isFalse);
        expect(ResponsiveBreakpoints.isTablet(context), isTrue);
        expect(ResponsiveBreakpoints.isDesktop(context), isFalse);
      });
      
      test('isDesktop should return true for desktop devices', () {
        final context = createMockContext(width: 1200);
        expect(ResponsiveBreakpoints.isMobile(context), isFalse);
        expect(ResponsiveBreakpoints.isTablet(context), isFalse);
        expect(ResponsiveBreakpoints.isDesktop(context), isTrue);
      });
    });
    
    group('getMaxMessageWidth', () {
      test('should return correct width for each device type', () {
        // Mobile Small: 85% of width
        var context = createMockContext(width: 320);
        expect(
          ResponsiveBreakpoints.getMaxMessageWidth(context),
          closeTo(272, 0.1), // 320 * 0.85
        );
        
        // Mobile: 80% of width
        context = createMockContext(width: 375);
        expect(
          ResponsiveBreakpoints.getMaxMessageWidth(context),
          closeTo(300, 0.1), // 375 * 0.80
        );
        
        // Tablet: fixed 500
        context = createMockContext(width: 768);
        expect(
          ResponsiveBreakpoints.getMaxMessageWidth(context),
          500,
        );
        
        // Desktop: fixed 600
        context = createMockContext(width: 1024);
        expect(
          ResponsiveBreakpoints.getMaxMessageWidth(context),
          600,
        );
      });
    });
    
    group('getMessageMargin', () {
      test('should return different margins for sender and receiver', () {
        final context = createMockContext(width: 375);
        
        // Sender (isMe: true)
        final senderMargin = ResponsiveBreakpoints.getMessageMargin(context, true);
        expect(senderMargin.left, greaterThan(senderMargin.right));
        
        // Receiver (isMe: false)
        final receiverMargin = ResponsiveBreakpoints.getMessageMargin(context, false);
        expect(receiverMargin.right, greaterThan(receiverMargin.left));
      });
    });
    
    group('getVsBoxHeight', () {
      test('should return different heights for image vs text', () {
        final context = createMockContext(width: 375);
        
        final imageHeight = ResponsiveBreakpoints.getVsBoxHeight(
          context,
          hasImages: true,
          isExpanded: false,
        );
        
        final textHeight = ResponsiveBreakpoints.getVsBoxHeight(
          context,
          hasImages: false,
          isExpanded: false,
        );
        
        // 텍스트는 이미지의 70%
        expect(textHeight, closeTo(imageHeight * 0.7, 0.1));
      });
      
      test('should return larger height when expanded', () {
        final context = createMockContext(width: 375);
        
        final collapsedHeight = ResponsiveBreakpoints.getVsBoxHeight(
          context,
          hasImages: true,
          isExpanded: false,
        );
        
        final expandedHeight = ResponsiveBreakpoints.getVsBoxHeight(
          context,
          hasImages: true,
          isExpanded: true,
        );
        
        expect(expandedHeight, greaterThan(collapsedHeight));
      });
    });
  });
}

// Helper function
BuildContext createMockContext({required double width, double height = 800}) {
  final context = MockBuildContext();
  final mediaQuery = MediaQueryData(size: Size(width, height));
  
  when(context.dependOnInheritedWidgetOfExactType<MediaQuery>())
      .thenReturn(MediaQuery(data: mediaQuery, child: Container()));
  
  return context;
}
```

### 2. UnifiedBoxCalculator 테스트

#### 2.1 박스 크기 계산
```dart
group('UnifiedBoxCalculator', () {
  group('calculate', () {
    test('should calculate single image box correctly', () {
      final result = UnifiedBoxCalculator.calculate(
        containerWidth: 400,
        containerType: 'message',
        layoutType: LayoutType.single,
        aspectRatioA: 1.5,
        hasImageA: true,
        hasImageB: false,
      );
      
      expect(result.isSingle, isTrue);
      expect(result.sizeA.width, closeTo(320, 0.1)); // 400 * 0.8
      expect(result.sizeA.height, closeTo(213.3, 0.1)); // 320 / 1.5
      expect(result.sizeB, Size.zero);
    });
    
    test('should calculate horizontal layout correctly', () {
      final result = UnifiedBoxCalculator.calculate(
        containerWidth: 400,
        containerType: 'message',
        layoutType: LayoutType.horizontal,
        aspectRatioA: 1.5,
        aspectRatioB: 2.0,
        hasImageA: true,
        hasImageB: true,
      );
      
      expect(result.isHorizontal, isTrue);
      expect(result.sizeA.width, result.sizeB.width);
      expect(result.sizeA.height, result.sizeB.height); // 통일된 높이
      
      // 평균 높이 검증
      final expectedHeightA = result.sizeA.width / 1.5;
      final expectedHeightB = result.sizeB.width / 2.0;
      final averageHeight = (expectedHeightA + expectedHeightB) / 2;
      
      expect(result.unifiedHeight, closeTo(averageHeight, 0.1));
    });
    
    test('should calculate vertical layout correctly', () {
      final result = UnifiedBoxCalculator.calculate(
        containerWidth: 400,
        containerType: 'message',
        layoutType: LayoutType.vertical,
        aspectRatioA: 0.8, // 세로형 이미지
        aspectRatioB: 0.7, // 세로형 이미지
        hasImageA: true,
        hasImageB: true,
      );
      
      expect(result.isVertical, isTrue);
      expect(result.sizeA.width, closeTo(380, 0.1)); // 400 * 0.95
      expect(result.sizeA.height, result.sizeB.height); // 통일된 높이
    });
    
    test('should respect min/max height constraints', () {
      // 극단적으로 큰 aspectRatio
      var result = UnifiedBoxCalculator.calculate(
        containerWidth: 400,
        containerType: 'message',
        layoutType: LayoutType.single,
        aspectRatioA: 10.0, // 매우 넓은 이미지
        hasImageA: true,
        hasImageB: false,
      );
      
      // 최소 높이 이상이어야 함
      expect(result.sizeA.height, greaterThanOrEqualTo(100));
      
      // 극단적으로 작은 aspectRatio
      result = UnifiedBoxCalculator.calculate(
        containerWidth: 400,
        containerType: 'message',
        layoutType: LayoutType.single,
        aspectRatioA: 0.1, // 매우 높은 이미지
        hasImageA: true,
        hasImageB: false,
      );
      
      // 최대 높이 이하여야 함
      expect(result.sizeA.height, lessThanOrEqualTo(400));
    });
  });
  
  group('calculateForMessageCard', () {
    test('should optimize for chat bubble', () {
      final result = UnifiedBoxCalculator.calculateForMessageCard(
        bubbleWidth: 300,
        layoutType: LayoutType.horizontal,
        aspectRatioA: 1.5,
        aspectRatioB: 1.5,
      );
      
      // 버블 내부에 적절한 크기
      expect(result.containerSize.width, lessThanOrEqualTo(300));
      expect(result.sizeA.height, lessThanOrEqualTo(400)); // 최대 높이
    });
    
    test('should handle null aspectRatio gracefully', () {
      final result = UnifiedBoxCalculator.calculateForMessageCard(
        bubbleWidth: 300,
        layoutType: LayoutType.horizontal,
        aspectRatioA: null,
        aspectRatioB: null,
      );
      
      // 기본 비율 1.5 사용
      expect(result.sizeA.height, closeTo(result.sizeA.width / 1.5, 0.1));
      expect(result.sizeB.height, closeTo(result.sizeB.width / 1.5, 0.1));
    });
  });
  
  group('calculateForNotificationDialog', () {
    test('should maximize dialog space usage', () {
      final result = UnifiedBoxCalculator.calculateForNotificationDialog(
        dialogWidth: 350,
        layoutType: LayoutType.single,
        aspectRatioA: 1.5,
      );
      
      // 다이얼로그 너비의 95% 사용
      expect(result.sizeA.width, closeTo(332.5, 0.1)); // 350 * 0.95
      expect(result.sizeA.height, lessThanOrEqualTo(500)); // 최대 높이
    });
  });
});
```

### 3. 모델 테스트

#### 3.1 BoxSizes 모델 테스트
```dart
group('BoxSizes', () {
  test('should calculate container size correctly', () {
    // 가로 배치
    var boxSizes = BoxSizes(
      sizeA: Size(150, 100),
      sizeB: Size(150, 100),
      layoutType: LayoutType.horizontal,
      containerType: 'message',
      spacing: 8,
      unifiedHeight: 100,
      boxWidth: 150,
    );
    
    expect(boxSizes.containerSize.width, 308); // 150 + 150 + 8
    expect(boxSizes.containerSize.height, 100);
    
    // 세로 배치
    boxSizes = BoxSizes(
      sizeA: Size(200, 150),
      sizeB: Size(200, 150),
      layoutType: LayoutType.vertical,
      containerType: 'message',
      spacing: 8,
      unifiedHeight: 150,
      boxWidth: 200,
    );
    
    expect(boxSizes.containerSize.width, 200);
    expect(boxSizes.containerSize.height, 308); // 150 + 150 + 8
  });
  
  test('should detect unified size correctly', () {
    // 동일한 크기
    var boxSizes = BoxSizes(
      sizeA: Size(150, 100),
      sizeB: Size(150, 100),
      layoutType: LayoutType.horizontal,
      containerType: 'message',
      spacing: 8,
      unifiedHeight: 100,
      boxWidth: 150,
    );
    
    expect(boxSizes.hasUnifiedSize, isTrue);
    
    // 다른 크기
    boxSizes = BoxSizes(
      sizeA: Size(150, 100),
      sizeB: Size(150, 120),
      layoutType: LayoutType.horizontal,
      containerType: 'message',
      spacing: 8,
      unifiedHeight: 110,
      boxWidth: 150,
    );
    
    expect(boxSizes.hasUnifiedSize, isFalse);
  });
  
  test('should generate correct description', () {
    final boxSizes = BoxSizes(
      sizeA: Size(150.5, 100.3),
      sizeB: Size(150.5, 100.3),
      layoutType: LayoutType.horizontal,
      containerType: 'message',
      spacing: 8,
      unifiedHeight: 100.3,
      boxWidth: 150.5,
    );
    
    final shortDesc = boxSizes.shortDescription;
    expect(shortDesc, contains('message'));
    expect(shortDesc, contains('horizontal'));
    expect(shortDesc, contains('151x100')); // 반올림
  });
});
```

## 🔗 통합 테스트

### 반응형 플로우 테스트
```dart
testWidgets('responsive flow integration', (tester) async {
  // 다양한 화면 크기 시뮬레이션
  for (final screenSize in [
    Size(320, 568),  // iPhone SE
    Size(375, 667),  // iPhone 8
    Size(414, 896),  // iPhone 11
    Size(768, 1024), // iPad
    Size(1920, 1080), // Desktop
  ]) {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final deviceType = ResponsiveBreakpoints.getDeviceType(context);
            final maxWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
            
            return Container(
              width: maxWidth,
              child: Text('Device: ${deviceType.name}'),
            );
          },
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // 각 디바이스에 맞는 UI가 렌더링되는지 확인
    expect(find.text(contains('Device:')), findsOneWidget);
  }
});
```

## 🎭 위젯 테스트

### VS 박스 위젯 테스트
```dart
testWidgets('VS box widget should render correctly', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VsBoxWidget(
          layoutType: LayoutType.horizontal,
          aspectRatioA: 1.5,
          aspectRatioB: 2.0,
          imageA: 'assets/test/image_a.jpg',
          imageB: 'assets/test/image_b.jpg',
        ),
      ),
    ),
  );
  
  await tester.pumpAndSettle();
  
  // 두 개의 이미지 박스가 렌더링되는지 확인
  expect(find.byType(Image), findsNWidgets(2));
  
  // 박스 크기 확인
  final boxA = tester.getSize(find.byType(Image).first);
  final boxB = tester.getSize(find.byType(Image).last);
  
  // 통일된 높이 확인
  expect(boxA.height, closeTo(boxB.height, 0.1));
});
```

## ⚡ 성능 테스트

### 계산 벤치마크
```dart
void main() {
  group('Performance Benchmarks', () {
    test('box calculation should be fast', () {
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 1000; i++) {
        UnifiedBoxCalculator.calculate(
          containerWidth: 400,
          containerType: 'message',
          layoutType: LayoutType.horizontal,
          aspectRatioA: 1.5,
          aspectRatioB: 2.0,
        );
      }
      
      stopwatch.stop();
      
      // 1000회 계산이 100ms 이내
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      // 평균 계산 시간
      final averageMs = stopwatch.elapsedMicroseconds / 1000 / 1000;
      print('Average calculation time: ${averageMs}ms');
      
      expect(averageMs, lessThan(0.1)); // 0.1ms 이내
    });
    
    test('cache should improve performance', () {
      // 캐시 없이 측정
      final withoutCache = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        ResponsiveBreakpoints.getDeviceType(createMockContext(width: 375));
      }
      withoutCache.stop();
      
      // 캐시 있을 때 측정 (미래 구현)
      // final withCache = Stopwatch()..start();
      // final service = ResponsiveService(cache: true);
      // for (int i = 0; i < 100; i++) {
      //   service.getDeviceType(createMockContext(width: 375));
      // }
      // withCache.stop();
      
      // expect(withCache.elapsedMicroseconds, 
      //        lessThan(withoutCache.elapsedMicroseconds / 2));
    });
  });
}
```

## 🐛 엣지 케이스 테스트

### 극단적 값 처리
```dart
group('Edge Cases', () {
  test('should handle zero width gracefully', () {
    expect(
      () => UnifiedBoxCalculator.calculate(
        containerWidth: 0,
        containerType: 'message',
        layoutType: LayoutType.single,
      ),
      throwsAssertionError,
    );
  });
  
  test('should handle negative aspectRatio', () {
    final result = UnifiedBoxCalculator.calculate(
      containerWidth: 400,
      containerType: 'message',
      layoutType: LayoutType.single,
      aspectRatioA: -1.5, // 음수
    );
    
    // 기본값으로 폴백
    expect(result.sizeA.height, greaterThan(0));
  });
  
  test('should handle very large aspectRatio', () {
    final result = UnifiedBoxCalculator.calculate(
      containerWidth: 400,
      containerType: 'message',
      layoutType: LayoutType.single,
      aspectRatioA: 1000.0, // 극단적으로 큰 값
    );
    
    // 최소 높이로 제한
    expect(result.sizeA.height, greaterThanOrEqualTo(100));
  });
  
  test('should handle null values appropriately', () {
    final result = UnifiedBoxCalculator.calculate(
      containerWidth: 400,
      containerType: 'message',
      layoutType: LayoutType.horizontal,
      aspectRatioA: null,
      aspectRatioB: null,
    );
    
    // null일 때 기본값 사용
    expect(result.sizeA, isNot(Size.zero));
    expect(result.sizeB, isNot(Size.zero));
  });
});
```

## 📊 테스트 커버리지

### 커버리지 실행
```bash
# 커버리지 실행
flutter test --coverage

# HTML 리포트 생성
genhtml coverage/lcov.info -o coverage/html

# 커버리지 확인
lcov --list coverage/lcov.info
```

### 목표 커버리지
```yaml
responsive_breakpoints.dart:
  lines: 95%
  branches: 90%
  functions: 100%

unified_box_calculator.dart:
  lines: 90%
  branches: 85%
  functions: 95%

models/:
  lines: 100%
  branches: 100%
  functions: 100%
```

## 🔄 CI/CD 통합

### GitHub Actions 설정
```yaml
name: UI Service Tests

on:
  push:
    paths:
      - 'lib/services/ui/**'
      - 'test/services/ui/**'
  pull_request:
    paths:
      - 'lib/services/ui/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run tests
        run: flutter test test/services/ui --coverage
      
      - name: Check coverage
        run: |
          coverage=$(lcov --summary coverage/lcov.info | grep lines | awk '{print $2}' | sed 's/%//')
          if (( $(echo "$coverage < 90" | bc -l) )); then
            echo "Coverage is below 90%"
            exit 1
          fi
      
      - name: Upload coverage
        uses: codecov/codecov-action@v2
        with:
          file: coverage/lcov.info
```

## 📝 테스트 작성 가이드

### 명명 규칙
```dart
// ✅ Good
test('should return mobile type for width less than tablet breakpoint', () {});

// ❌ Bad
test('test mobile', () {});
```

### 테스트 구조
```dart
// Arrange - Act - Assert (AAA) 패턴
test('description', () {
  // Arrange: 테스트 데이터 준비
  final input = createTestInput();
  
  // Act: 테스트 대상 실행
  final result = functionUnderTest(input);
  
  // Assert: 결과 검증
  expect(result, expectedValue);
});
```

### Mock 사용
```dart
// Mock 생성
class MockResponsiveService extends Mock implements IResponsiveService {}

// Stub 설정
when(mockService.getDeviceType(any)).thenReturn(DeviceType.mobile);

// 검증
verify(mockService.getDeviceType(any)).called(1);
```

## ⚠️ 주의사항

### 테스트 격리
- 각 테스트는 독립적으로 실행 가능해야 함
- 전역 상태 변경 금지
- setUp/tearDown으로 초기화

### 비동기 테스트
```dart
testWidgets('async test', (tester) async {
  await tester.pumpWidget(widget);
  await tester.pump(); // 한 프레임 대기
  await tester.pumpAndSettle(); // 애니메이션 완료 대기
});
```

### 플랫폼별 테스트
```dart
test('platform specific', () {
  if (Platform.isIOS) {
    // iOS 전용 테스트
  } else if (Platform.isAndroid) {
    // Android 전용 테스트
  }
}, skip: !Platform.isIOS && !Platform.isAndroid);
```

## 📚 참고 자료

### 테스트 도구
- [Flutter Test Documentation](https://docs.flutter.dev/testing)
- [Mockito Package](https://pub.dev/packages/mockito)
- [Coverage Package](https://pub.dev/packages/coverage)

### 베스트 프랙티스
- [Testing Best Practices](https://docs.flutter.dev/testing/best-practices)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

---

*이 문서는 UI Service의 포괄적인 테스트 전략을 담고 있습니다.*  
*90% 이상의 코드 커버리지를 목표로 합니다.*