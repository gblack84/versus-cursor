# 🧪 Core Constants 테스트 전략

> 작성일: 2025-08-28 | 테스트 커버리지 목표: 90% | TDD 적용

## 🎯 테스트 목표

Core Constants 레이어의 안정성과 신뢰성을 보장하기 위한 포괄적 테스트:
- ✅ 상수값 무결성 검증
- ✅ 타입 안전성 검증  
- ✅ 헬퍼 메서드 정확성
- ✅ Feature 통합 테스트

## 📊 테스트 범위

### 테스트 대상
```
lib/core/constants/
├── layout/
│   ├── layout_constants.dart      [필수] 핵심 레이아웃 상수
│   ├── container_types.dart       [필수] 타입 정의
│   └── breakpoints.dart          [선택] 반응형 중단점
├── app/
│   ├── app_constants.dart        [필수] 앱 설정
│   └── api_constants.dart        [필수] API 엔드포인트
└── validation/
    └── input_limits.dart         [필수] 입력 제한
```

### 커버리지 목표
- **Unit Tests**: 90% 이상
- **Integration Tests**: 80% 이상
- **Widget Tests**: 해당 없음 (상수 레이어)

## 🧪 테스트 전략

### 1. Unit Tests

#### 1.1 LayoutConstants 테스트
```dart
// test/core/constants/layout/layout_constants_test.dart
import 'package:test/test.dart';
import 'package:versus_space/core/constants/layout/layout_constants.dart';

void main() {
  group('LayoutConstants', () {
    group('getMaxHeight', () {
      test('질문 작성 가로 배치 최대 높이 반환', () {
        final height = LayoutConstants.getMaxHeight(
          containerType: LayoutConstants.containerTypeQuestion,
          isHorizontal: true,
        );
        expect(height, equals(500.0));
      });
      
      test('질문 작성 세로 배치 최대 높이 반환', () {
        final height = LayoutConstants.getMaxHeight(
          containerType: LayoutConstants.containerTypeQuestion,
          isHorizontal: false,
        );
        expect(height, equals(400.0));
      });
      
      test('단일 이미지 최대 높이 반환', () {
        final height = LayoutConstants.getMaxHeight(
          containerType: LayoutConstants.containerTypeQuestion,
          isHorizontal: true,
          isSingle: true,
        );
        expect(height, equals(600.0));
      });
      
      test('알림 다이얼로그 screenHeight 없으면 에러', () {
        expect(
          () => LayoutConstants.getMaxHeight(
            containerType: LayoutConstants.containerTypeNotification,
            isHorizontal: true,
          ),
          throwsArgumentError,
        );
      });
    });
    
    group('getMinHeight', () {
      test('각 컨테이너 타입별 최소 높이 검증', () {
        // 질문 작성
        expect(
          LayoutConstants.getMinHeight(
            containerType: LayoutConstants.containerTypeQuestion,
            isHorizontal: true,
          ),
          equals(150.0),
        );
        
        // 알림
        expect(
          LayoutConstants.getMinHeight(
            containerType: LayoutConstants.containerTypeNotification,
            isHorizontal: false,
          ),
          equals(150.0),
        );
        
        // 메시지
        expect(
          LayoutConstants.getMinHeight(
            containerType: LayoutConstants.containerTypeMessage,
            isHorizontal: false,
          ),
          equals(200.0),
        );
      });
    });
    
    group('상수값 불변성', () {
      test('상수값이 예상 범위 내에 있는지 검증', () {
        expect(LayoutConstants.questionHorizontalMaxHeight, 
          inInclusiveRange(300, 600));
        expect(LayoutConstants.messageHorizontalMinHeight,
          inInclusiveRange(100, 300));
      });
      
      test('비율 값이 0과 1 사이인지 검증', () {
        expect(LayoutConstants.horizontalBoxWidthRatio,
          inExclusiveRange(0, 1));
        expect(LayoutConstants.notificationWidthRatio,
          inInclusiveRange(0, 1));
      });
    });
  });
}
```

#### 1.2 ContainerType Enum 테스트
```dart
// test/core/constants/layout/container_types_test.dart
import 'package:test/test.dart';
import 'package:versus_space/core/constants/layout/container_types.dart';

void main() {
  group('ContainerType', () {
    test('enum 값 검증', () {
      expect(ContainerType.values.length, equals(3));
      expect(ContainerType.question.value, equals('question'));
      expect(ContainerType.notification.value, equals('notification'));
      expect(ContainerType.message.value, equals('message'));
    });
    
    test('fromString 변환', () {
      expect(ContainerType.fromString('question'), 
        equals(ContainerType.question));
      expect(ContainerType.fromString('invalid'), isNull);
    });
  });
}
```

#### 1.3 입력 제한 테스트
```dart
// test/core/constants/validation/input_limits_test.dart
void main() {
  group('InputLimits', () {
    test('텍스트 길이 제한', () {
      expect(InputLimits.maxTitleLength, equals(100));
      expect(InputLimits.maxDescriptionLength, equals(500));
    });
    
    test('파일 크기 제한', () {
      expect(InputLimits.maxImageSize, equals(10 * 1024 * 1024));
      expect(InputLimits.maxVideoSize, equals(100 * 1024 * 1024));
    });
    
    test('수량 제한', () {
      expect(InputLimits.maxImageCount, equals(4));
      expect(InputLimits.minImageCount, equals(1));
    });
  });
}
```

### 2. Integration Tests

#### 2.1 UnifiedBoxCalculator 통합 테스트
```dart
// test/integration/unified_box_calculator_test.dart
import 'package:test/test.dart';
import 'package:versus_space/services/ui/unified_box_calculator.dart';
import 'package:versus_space/core/constants/layout/layout_constants.dart';

void main() {
  group('UnifiedBoxCalculator Integration', () {
    late UnifiedBoxCalculator calculator;
    
    setUp(() {
      calculator = UnifiedBoxCalculator();
    });
    
    test('메시지 카드 크기 계산', () {
      final result = calculator.calculateBoxSizes(
        containerWidth: 400,
        aspectRatioA: 1.5,
        aspectRatioB: 0.8,
        isHorizontal: true,
        containerType: LayoutConstants.containerTypeMessage,
      );
      
      expect(result.boxWidth, lessThanOrEqualTo(400));
      expect(result.heightA, inInclusiveRange(
        LayoutConstants.messageHorizontalMinHeight,
        LayoutConstants.messageHorizontalMaxHeight,
      ));
    });
    
    test('알림 다이얼로그 크기 계산', () {
      final result = calculator.calculateBoxSizes(
        containerWidth: 400,
        aspectRatioA: 1.0,
        aspectRatioB: 1.0,
        isHorizontal: false,
        containerType: LayoutConstants.containerTypeNotification,
        screenHeight: 800,
      );
      
      expect(result.boxWidth, lessThanOrEqualTo(
        LayoutConstants.notificationMaxWidth));
      expect(result.heightA, greaterThanOrEqualTo(
        LayoutConstants.notificationMinBoxHeight));
    });
  });
}
```

#### 2.2 Design System 통합 테스트
```dart
// test/integration/design_system_constants_test.dart
void main() {
  group('Design System Constants Integration', () {
    test('spacing 상수와 레이아웃 상수 일관성', () {
      expect(LayoutConstants.horizontalSpacing,
        equals(VersusSpacing.xs));
      expect(LayoutConstants.verticalSpacing,
        equals(VersusSpacing.md));
    });
    
    test('breakpoint와 레이아웃 호환성', () {
      // 모바일 breakpoint에서 레이아웃 검증
      final mobileWidth = Breakpoints.mobile;
      expect(mobileWidth * LayoutConstants.notificationWidthRatio,
        lessThanOrEqualTo(LayoutConstants.notificationMaxWidth));
    });
  });
}
```

### 3. Performance Tests

#### 3.1 상수 접근 성능 테스트
```dart
// test/performance/constants_performance_test.dart
void main() {
  group('Constants Performance', () {
    test('상수 접근 시간 < 1ms', () {
      final stopwatch = Stopwatch()..start();
      
      for (int i = 0; i < 10000; i++) {
        final height = LayoutConstants.getMaxHeight(
          containerType: LayoutConstants.containerTypeQuestion,
          isHorizontal: true,
        );
      }
      
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      print('10,000 accesses: ${stopwatch.elapsedMilliseconds}ms');
    });
    
    test('메모리 사용량 검증', () {
      // const 상수는 메모리 공유
      final ref1 = LayoutConstants.questionHorizontalMaxHeight;
      final ref2 = LayoutConstants.questionHorizontalMaxHeight;
      expect(identical(ref1, ref2), isTrue);
    });
  });
}
```

### 4. Golden Tests

#### 4.1 상수값 스냅샷 테스트
```dart
// test/golden/constants_golden_test.dart
void main() {
  group('Constants Golden Tests', () {
    test('레이아웃 상수 스냅샷', () {
      final snapshot = {
        'questionHorizontalMaxHeight': LayoutConstants.questionHorizontalMaxHeight,
        'questionVerticalMaxHeight': LayoutConstants.questionVerticalMaxHeight,
        'messageHorizontalMaxHeight': LayoutConstants.messageHorizontalMaxHeight,
        // ... 모든 상수
      };
      
      // golden 파일과 비교
      expect(snapshot, matchesGoldenFile('constants.golden.json'));
    });
  });
}
```

## 🔧 테스트 도구

### 필수 Dependencies
```yaml
dev_dependencies:
  test: ^1.24.0
  mockito: ^5.4.0
  golden_toolkit: ^0.15.0
  test_coverage: ^0.5.0
```

### 테스트 실행 스크립트
```bash
# 모든 테스트 실행
flutter test

# 커버리지 포함 실행
flutter test --coverage

# 특정 디렉토리 테스트
flutter test test/core/constants/

# Golden 테스트 업데이트
flutter test --update-goldens

# 성능 테스트만 실행
flutter test test/performance/
```

## 📈 테스트 커버리지 목표

### Phase 1 (즉시)
- [ ] LayoutConstants 핵심 메서드: 100%
- [ ] ContainerType enum: 100%
- [ ] 기본 통합 테스트: 80%

### Phase 2 (1주일)
- [ ] 모든 헬퍼 메서드: 100%
- [ ] Design System 통합: 90%
- [ ] Performance 테스트: 완료

### Phase 3 (2주일)
- [ ] Golden 테스트: 구현
- [ ] Feature 통합 테스트: 90%
- [ ] 전체 커버리지: 90% 이상

## ⚠️ 테스트 시 주의사항

### 1. 상수 변경 영향도
- 상수값 변경 시 Golden 테스트 실패 예상
- Feature 테스트에 영향 가능
- UI 스냅샷 테스트 재생성 필요

### 2. 플랫폼별 차이
- 화면 크기에 따른 레이아웃 차이
- 픽셀 밀도 고려
- 플랫폼별 최소/최대값 검증

### 3. 성능 기준
- 상수 접근: < 0.01ms
- 계산 메서드: < 1ms
- 메모리: const 활용으로 최소화

## 🚀 CI/CD 통합

### GitHub Actions 설정
```yaml
name: Constants Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter test test/core/constants/
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

### Pre-commit Hook
```bash
#!/bin/sh
# .git/hooks/pre-commit
flutter test test/core/constants/ || exit 1
```

## 📝 테스트 문서화

### 테스트 케이스 명명 규칙
```dart
// ✅ Good
test('getMaxHeight returns 500 for horizontal question layout', () {});

// ❌ Bad  
test('test max height', () {});
```

### 테스트 그룹 구조
```dart
group('ComponentName', () {
  group('MethodName', () {
    test('specific scenario description', () {});
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

*이 문서는 Core Constants 레이어의 포괄적 테스트 전략을 담고 있습니다.*
*TDD 원칙에 따라 테스트 우선 개발을 권장합니다.*