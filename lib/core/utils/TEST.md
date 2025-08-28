# 🧪 Core Utils 테스트 가이드

> 작성일: 2025-08-28 | 대상: Core Utils 레이어 | 목표 커버리지: 95%

## 📋 테스트 전략 개요

Core Utils는 애플리케이션 전체에서 사용되는 핵심 유틸리티이므로, 철저한 테스트가 필수적입니다.
모든 유틸리티 함수와 Extension에 대해 단위 테스트를 작성하고, 엣지 케이스를 포함한 완벽한 커버리지를 목표로 합니다.

## 🎯 테스트 목표

- ✅ **코드 커버리지**: 95% 이상
- ✅ **엣지 케이스**: 모든 경계값 테스트
- ✅ **성능 테스트**: 시간 복잡도 검증
- ✅ **플랫폼별 테스트**: 각 플랫폼별 동작 검증
- ✅ **회귀 테스트**: 기존 동작 보장

## 📊 현재 테스트 현황

| 파일 | 현재 커버리지 | 목표 커버리지 | 테스트 파일 |
|------|--------------|--------------|------------|
| app_timer.dart | 0% | 95% | ❌ 없음 |
| app_utils.dart | 0% | 95% | ❌ 없음 |
| custom_functions.dart | 0% | 100% | ❌ 없음 |

## 🧪 테스트 구조

```
test/core/utils/
├── datetime/
│   ├── date_formatter_test.dart
│   ├── date_extensions_test.dart
│   ├── timeago_helper_test.dart
│   └── age_calculator_test.dart
├── platform/
│   ├── platform_detector_test.dart
│   └── platform_extensions_test.dart
├── formatting/
│   ├── number_formatter_test.dart
│   ├── text_formatter_test.dart
│   └── currency_formatter_test.dart
├── validators/
│   ├── text_validators_test.dart
│   ├── email_validator_test.dart
│   └── url_validator_test.dart
├── extensions/
│   ├── list_extensions_test.dart
│   ├── string_extensions_test.dart
│   ├── map_extensions_test.dart
│   └── color_extensions_test.dart
├── ui/
│   ├── responsive_helper_test.dart
│   ├── widget_helper_test.dart
│   └── snackbar_helper_test.dart
├── timer/
│   ├── timer_controller_test.dart
│   └── timer_widget_test.dart
└── integration/
    └── utils_integration_test.dart
```

## 📝 테스트 케이스 상세

### 1. DateTime 유틸리티 테스트

#### 1.1 DateFormatter 테스트
```dart
// test/core/utils/datetime/date_formatter_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/utils/datetime/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    group('format', () {
      test('should format date with standard pattern', () {
        final date = DateTime(2025, 8, 28, 14, 30);
        
        expect(
          DateFormatter.format('yyyy-MM-dd', date),
          '2025-08-28',
        );
        
        expect(
          DateFormatter.format('MMM d, y', date),
          'Aug 28, 2025',
        );
        
        expect(
          DateFormatter.format('HH:mm', date),
          '14:30',
        );
      });
      
      test('should format relative time', () {
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));
        final lastWeek = now.subtract(Duration(days: 7));
        
        expect(
          DateFormatter.format('relative', yesterday),
          contains('day ago'),
        );
        
        expect(
          DateFormatter.format('relative', lastWeek),
          contains('days ago'),
        );
      });
      
      test('should handle null date', () {
        expect(DateFormatter.format('yyyy-MM-dd', null), '');
      });
      
      test('should support localization', () {
        final date = DateTime(2025, 8, 28);
        
        expect(
          DateFormatter.format('MMMM', date, locale: 'de'),
          'August', // German month name
        );
      });
    });
    
    group('copy', () {
      test('should create independent copy', () {
        final original = DateTime(2025, 8, 28);
        final copy = DateFormatter.copy(original);
        
        expect(copy, equals(original));
        expect(identical(copy, original), isFalse);
      });
      
      test('should handle null', () {
        expect(DateFormatter.copy(null), isNull);
      });
    });
  });
}
```

#### 1.2 DateTime Extensions 테스트
```dart
// test/core/utils/datetime/date_extensions_test.dart
void main() {
  group('DateTimeOperators', () {
    final date1 = DateTime(2025, 8, 28, 12, 0);
    final date2 = DateTime(2025, 8, 28, 14, 0);
    final date3 = DateTime(2025, 8, 28, 12, 0);
    
    test('should compare dates correctly', () {
      expect(date1 < date2, isTrue);
      expect(date2 > date1, isTrue);
      expect(date1 <= date3, isTrue);
      expect(date1 >= date3, isTrue);
      expect(date1 <= date2, isTrue);
      expect(date2 >= date1, isTrue);
    });
  });
  
  group('DateTimeHelpers', () {
    test('should get start of day', () {
      final date = DateTime(2025, 8, 28, 14, 30, 45);
      final start = date.startOfDay;
      
      expect(start.year, 2025);
      expect(start.month, 8);
      expect(start.day, 28);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });
    
    test('should get end of day', () {
      final date = DateTime(2025, 8, 28, 14, 30, 45);
      final end = date.endOfDay;
      
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
      expect(end.millisecond, 999);
    });
  });
}
```

#### 1.3 Age Calculator 테스트
```dart
// test/core/utils/datetime/age_calculator_test.dart
void main() {
  group('AgeCalculator', () {
    test('should calculate minimum birth date', () {
      final now = DateTime.now();
      final minBirthDate = AgeCalculator.getMinimumBirthDate();
      
      final expectedYear = now.year - 13;
      expect(minBirthDate.year, expectedYear);
      expect(minBirthDate.month, now.month);
      expect(minBirthDate.day, now.day);
    });
    
    test('should check if old enough', () {
      final now = DateTime.now();
      final oldEnough = DateTime(now.year - 14, now.month, now.day);
      final tooYoung = DateTime(now.year - 12, now.month, now.day);
      final exactly13 = DateTime(now.year - 13, now.month, now.day);
      
      expect(AgeCalculator.isOldEnough(oldEnough), isTrue);
      expect(AgeCalculator.isOldEnough(tooYoung), isFalse);
      expect(AgeCalculator.isOldEnough(exactly13), isTrue);
    });
    
    test('should support custom minimum age', () {
      final now = DateTime.now();
      final birth18 = DateTime(now.year - 18, now.month, now.day);
      
      expect(
        AgeCalculator.isOldEnough(birth18, minimumAge: 18),
        isTrue,
      );
      
      expect(
        AgeCalculator.isOldEnough(birth18, minimumAge: 21),
        isFalse,
      );
    });
  });
}
```

### 2. Platform 테스트

#### 2.1 Platform Detector 테스트
```dart
// test/core/utils/platform/platform_detector_test.dart
@TestOn('vm')
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:versus_space/core/utils/platform/platform_detector.dart';

void main() {
  group('PlatformDetector', () {
    test('should detect current platform', () {
      if (Platform.isAndroid) {
        expect(PlatformDetector.isAndroid, isTrue);
        expect(PlatformDetector.isiOS, isFalse);
      } else if (Platform.isIOS) {
        expect(PlatformDetector.isiOS, isTrue);
        expect(PlatformDetector.isAndroid, isFalse);
      }
    });
    
    test('should detect mobile platforms', () {
      if (Platform.isAndroid || Platform.isIOS) {
        expect(PlatformDetector.isMobile, isTrue);
        expect(PlatformDetector.isDesktop, isFalse);
      }
    });
    
    test('should return correct suffix', () {
      if (Platform.isAndroid) {
        expect(PlatformDetector.suffix, 'android');
      } else if (Platform.isIOS) {
        expect(PlatformDetector.suffix, 'ios');
      }
    });
    
    test('should return correct display name', () {
      if (Platform.isAndroid) {
        expect(PlatformDetector.displayName, 'Android');
      } else if (Platform.isIOS) {
        expect(PlatformDetector.displayName, 'iOS');
      }
    });
  });
}
```

### 3. Number Formatter 테스트

```dart
// test/core/utils/formatting/number_formatter_test.dart
void main() {
  group('NumberFormatter', () {
    group('decimal formatting', () {
      test('should format with automatic decimal', () {
        expect(
          NumberFormatter.format(
            1234.56,
            formatType: FormatType.decimal,
          ),
          '1,234.56',
        );
      });
      
      test('should format with period decimal', () {
        expect(
          NumberFormatter.format(
            1234.56,
            formatType: FormatType.decimal,
            decimalType: DecimalType.periodDecimal,
          ),
          '1,234.56',
        );
      });
      
      test('should format with comma decimal', () {
        expect(
          NumberFormatter.format(
            1234.56,
            formatType: FormatType.decimal,
            decimalType: DecimalType.commaDecimal,
          ),
          '1.234,56',
        );
      });
    });
    
    group('other formats', () {
      test('should format as percent', () {
        expect(
          NumberFormatter.format(0.125, formatType: FormatType.percent),
          '12.5%',
        );
      });
      
      test('should format as scientific', () {
        expect(
          NumberFormatter.format(1234.56, formatType: FormatType.scientific),
          contains('E'),
        );
      });
      
      test('should format as compact', () {
        expect(
          NumberFormatter.format(1234, formatType: FormatType.compact),
          '1.2K',
        );
        
        expect(
          NumberFormatter.format(1234567, formatType: FormatType.compact),
          '1.2M',
        );
      });
      
      test('should format with currency', () {
        expect(
          NumberFormatter.format(
            1234.56,
            formatType: FormatType.decimal,
            currency: '$',
          ),
          r'$1,234.56',
        );
      });
      
      test('should handle null value', () {
        expect(
          NumberFormatter.format(null, formatType: FormatType.decimal),
          '',
        );
      });
    });
    
    group('edge cases', () {
      test('should handle zero', () {
        expect(
          NumberFormatter.format(0, formatType: FormatType.decimal),
          '0',
        );
      });
      
      test('should handle negative numbers', () {
        expect(
          NumberFormatter.format(-1234, formatType: FormatType.decimal),
          '-1,234',
        );
      });
      
      test('should handle very large numbers', () {
        expect(
          NumberFormatter.format(1e15, formatType: FormatType.compact),
          contains('P'), // Peta
        );
      });
      
      test('should handle very small numbers', () {
        expect(
          NumberFormatter.format(0.000001, formatType: FormatType.scientific),
          contains('E-'),
        );
      });
    });
  });
}
```

### 4. List Extensions 테스트

```dart
// test/core/utils/extensions/list_extensions_test.dart
void main() {
  group('ListFilter', () {
    test('should filter list correctly', () {
      final list = [1, 2, 3, 4, 5];
      final filtered = list.filterList((e) => e > 3);
      
      expect(filtered, [4, 5]);
    });
    
    test('should handle empty list', () {
      final list = <int>[];
      final filtered = list.filterList((e) => e > 0);
      
      expect(filtered, isEmpty);
    });
  });
  
  group('ListDivide', () {
    test('should chunk list', () {
      final list = [1, 2, 3, 4, 5, 6, 7];
      final chunks = list.chunk(3);
      
      expect(chunks.length, 3);
      expect(chunks[0], [1, 2, 3]);
      expect(chunks[1], [4, 5, 6]);
      expect(chunks[2], [7]);
    });
    
    test('should divide with separator', () {
      final list = [1, 2, 3];
      final divided = list.divide(0);
      
      expect(divided, [1, 0, 2, 0, 3]);
    });
    
    test('should add to start and end', () {
      final list = [2, 3];
      
      expect(list.addToStart(1), [1, 2, 3]);
      expect(list.addToEnd(4), [2, 3, 4]);
    });
  });
  
  group('IterableHelpers', () {
    test('should sort list with key', () {
      final list = ['abc', 'a', 'ab'];
      final sorted = list.sortedList(keyOf: (s) => s.length);
      
      expect(sorted, ['a', 'ab', 'abc']);
    });
    
    test('should sort descending', () {
      final list = [1, 3, 2];
      final sorted = list.sortedList(desc: true);
      
      expect(sorted, [3, 2, 1]);
    });
    
    test('should map with index', () {
      final list = ['a', 'b', 'c'];
      final mapped = list.mapIndexed((i, e) => '$i:$e');
      
      expect(mapped, ['0:a', '1:b', '2:c']);
    });
  });
  
  group('IterableNullable', () {
    test('should filter nulls', () {
      final list = [1, null, 2, null, 3];
      final filtered = list.withoutNulls;
      
      expect(filtered, [1, 2, 3]);
    });
  });
}
```

### 5. Validators 테스트

```dart
// test/core/utils/validators/text_validators_test.dart
void main() {
  group('TextValidators', () {
    group('Email Validator', () {
      test('should validate correct emails', () {
        final validEmails = [
          'user@example.com',
          'test.user@example.co.uk',
          'user+tag@example.org',
          'user_name@example-domain.com',
        ];
        
        for (final email in validEmails) {
          expect(
            RegExp(kTextValidatorEmailRegex).hasMatch(email),
            isTrue,
            reason: '$email should be valid',
          );
        }
      });
      
      test('should reject invalid emails', () {
        final invalidEmails = [
          'invalid',
          '@example.com',
          'user@',
          'user@.com',
          'user..name@example.com',
        ];
        
        for (final email in invalidEmails) {
          expect(
            RegExp(kTextValidatorEmailRegex).hasMatch(email),
            isFalse,
            reason: '$email should be invalid',
          );
        }
      });
    });
    
    group('Username Validator', () {
      test('should validate correct usernames', () {
        final validUsernames = [
          'user',
          'user123',
          'user_name',
          'user-name',
        ];
        
        for (final username in validUsernames) {
          expect(
            RegExp(kTextValidatorUsernameRegex).hasMatch(username),
            isTrue,
            reason: '$username should be valid',
          );
        }
      });
      
      test('should reject invalid usernames', () {
        final invalidUsernames = [
          '1user', // starts with number
          'u', // too short
          'user name', // contains space
          'user@name', // contains special char
        ];
        
        for (final username in invalidUsernames) {
          expect(
            RegExp(kTextValidatorUsernameRegex).hasMatch(username),
            isFalse,
            reason: '$username should be invalid',
          );
        }
      });
    });
    
    group('URL Validator', () {
      test('should validate correct URLs', () {
        final validUrls = [
          'https://example.com',
          'http://www.example.com',
          'www.example.com',
          'example.com',
          'https://example.com/path?query=value',
        ];
        
        for (final url in validUrls) {
          expect(
            RegExp(kTextValidatorWebsiteRegex).hasMatch(url),
            isTrue,
            reason: '$url should be valid',
          );
        }
      });
      
      test('should reject invalid URLs', () {
        final invalidUrls = [
          'not a url',
          'htp://wrong.com',
          'example',
        ];
        
        for (final url in invalidUrls) {
          expect(
            RegExp(kTextValidatorWebsiteRegex).hasMatch(url),
            isFalse,
            reason: '$url should be invalid',
          );
        }
      });
    });
  });
}
```

### 6. Timer 테스트

```dart
// test/core/utils/timer/timer_controller_test.dart
void main() {
  group('TimerController', () {
    late VotingTimerController controller;
    
    setUp(() {
      controller = VotingTimerController(
        initialTimeMs: 60000, // 1 minute
        mode: StopWatchMode.countDown,
      );
    });
    
    tearDown(() {
      controller.dispose();
    });
    
    test('should initialize with correct value', () {
      expect(controller.currentValue, 60000);
    });
    
    test('should emit state changes', () async {
      final states = <TimerState>[];
      final subscription = controller.stream.listen(states.add);
      
      controller.start();
      await Future.delayed(Duration(milliseconds: 100));
      controller.stop();
      
      await subscription.cancel();
      
      expect(states, isNotEmpty);
      expect(states.any((s) => s.isRunning), isTrue);
    });
    
    test('should reset timer', () async {
      controller.start();
      await Future.delayed(Duration(milliseconds: 100));
      
      final valueBefore = controller.currentValue;
      controller.reset();
      await Future.delayed(Duration(milliseconds: 50));
      
      expect(controller.currentValue, 60000);
      expect(controller.currentValue, isNot(valueBefore));
    });
  });
}
```

### 7. Widget 테스트

```dart
// test/core/utils/ui/responsive_helper_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ResponsiveHelper', () {
    testWidgets('should detect mobile width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(400, 800)),
            child: Builder(
              builder: (context) {
                final isMobile = ResponsiveHelper.isMobileWidth(context);
                return Text(isMobile ? 'Mobile' : 'Not Mobile');
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Mobile'), findsOneWidget);
    });
    
    testWidgets('should detect desktop width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(size: Size(1200, 800)),
            child: Builder(
              builder: (context) {
                final isDesktop = ResponsiveHelper.isDesktopWidth(context);
                return Text(isDesktop ? 'Desktop' : 'Not Desktop');
              },
            ),
          ),
        ),
      );
      
      expect(find.text('Desktop'), findsOneWidget);
    });
  });
}
```

## 🔧 테스트 도구 및 설정

### 테스트 의존성
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  test: ^1.24.0
  mockito: ^5.4.0
  fake_async: ^1.3.1
  clock: ^1.1.1
```

### 테스트 설정
```dart
// test/test_helper.dart
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void setupTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Platform 채널 모킹
  const MethodChannel channel = MethodChannel('plugins.flutter.io/url_launcher');
  channel.setMockMethodCallHandler((MethodCall call) async {
    if (call.method == 'launch') {
      return true;
    }
    return null;
  });
}
```

## 📊 커버리지 목표

### 파일별 목표
| 도메인 | 목표 커버리지 | 중요도 |
|--------|--------------|--------|
| DateTime | 95% | 🔴 매우 높음 |
| Platform | 90% | 🔴 매우 높음 |
| Formatting | 95% | 🔴 매우 높음 |
| Validators | 100% | 🔴 매우 높음 |
| Extensions | 95% | 🟡 중간 |
| UI Helpers | 85% | 🟡 중간 |
| Timer | 90% | 🟡 중간 |

## 🏃 테스트 실행

### 모든 테스트 실행
```bash
flutter test
```

### 특정 디렉토리 테스트
```bash
flutter test test/core/utils/datetime/
```

### 커버리지 리포트 생성
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Watch 모드
```bash
flutter test --watch
```

## 🐛 디버깅 가이드

### 테스트 디버깅
```dart
// 특정 테스트만 실행
test('specific test', () {
  // 테스트 코드
}, solo: true);

// 테스트 건너뛰기
test('skip this', () {
  // 테스트 코드
}, skip: 'Not implemented yet');
```

### 시간 관련 테스트
```dart
import 'package:fake_async/fake_async.dart';

test('time dependent test', () {
  FakeAsync().run((async) {
    final timer = Timer(Duration(seconds: 5), () {});
    
    async.elapse(Duration(seconds: 5));
    
    expect(timer.isActive, isFalse);
  });
});
```

## ⚠️ 주의사항

1. **Platform 테스트**: 각 플랫폼별로 조건부 테스트 필요
2. **시간 테스트**: FakeAsync 사용으로 테스트 속도 향상
3. **Widget 테스트**: MediaQuery 모킹 필요
4. **외부 의존성**: 모든 외부 패키지 모킹 필요

## 📋 체크리스트

### 단위 테스트
- [ ] DateTime 유틸리티 테스트
- [ ] Platform 검증 테스트
- [ ] Number Formatter 테스트
- [ ] Text Validators 테스트
- [ ] List Extensions 테스트
- [ ] String Extensions 테스트
- [ ] Map Extensions 테스트
- [ ] Color Extensions 테스트

### Widget 테스트
- [ ] Timer Widget 테스트
- [ ] Responsive Helper 테스트
- [ ] SnackBar Helper 테스트

### 통합 테스트
- [ ] 유틸리티 조합 테스트
- [ ] 성능 테스트
- [ ] 메모리 누수 테스트

---

*이 문서는 Core Utils의 테스트 가이드입니다.*
*95% 이상의 코드 커버리지를 목표로 안정적인 유틸리티 시스템을 구축합니다.*