# 📋 Core Utils 마이그레이션 계획 (Part 3)

> 작성일: 2025-08-28 | 대상: Core Utils 레이어 | 예상 기간: 5일

## 🎯 마이그레이션 목표

Core Utils를 Feature-First Architecture에 맞게 재구조화하여:
- ✅ 도메인별 명확한 분리
- ✅ 의존성 주입 패턴 적용
- ✅ 테스트 가능한 구조
- ✅ 재사용 가능한 유틸리티
- ✅ 성능 최적화

## 📊 현재 상태 분석

### 📁 현재 구조
```
lib/core/utils/
├── app_timer.dart        # 129줄 - 모든 타이머 로직
├── app_utils.dart        # 497줄 - 모든 유틸리티 함수
└── custom_functions.dart # 7줄 - 연령 계산 함수
```

### 🔍 식별된 문제점
1. **과도한 집중** - 497줄의 단일 파일에 모든 유틸리티
2. **관심사 혼재** - 날짜, 플랫폼, UI, 포맷팅이 하나의 파일에
3. **계층 위반** - Core가 App 레이어를 import
4. **테스트 부재** - 유틸리티 함수들의 테스트 없음
5. **문서화 부족** - 사용법과 목적이 불명확

## 📈 마이그레이션 전략

### 🏗️ 목표 구조
```
lib/
├── core/
│   └── utils/                    # 유틸리티 레이어
│       ├── datetime/             # 날짜/시간 유틸리티
│       │   ├── date_formatter.dart
│       │   ├── date_extensions.dart
│       │   ├── timeago_helper.dart
│       │   └── age_calculator.dart
│       ├── platform/             # 플랫폼 검증
│       │   ├── platform_detector.dart
│       │   ├── platform_extensions.dart
│       │   └── platform_constants.dart
│       ├── formatting/           # 포맷팅 유틸리티
│       │   ├── number_formatter.dart
│       │   ├── text_formatter.dart
│       │   ├── currency_formatter.dart
│       │   └── format_types.dart
│       ├── validators/           # 유효성 검증
│       │   ├── text_validators.dart
│       │   ├── email_validator.dart
│       │   └── url_validator.dart
│       ├── extensions/           # Dart Extensions
│       │   ├── list_extensions.dart
│       │   ├── string_extensions.dart
│       │   ├── map_extensions.dart
│       │   ├── color_extensions.dart
│       │   └── datetime_extensions.dart
│       ├── ui/                   # UI 헬퍼
│       │   ├── responsive_helper.dart
│       │   ├── widget_helper.dart
│       │   ├── snackbar_helper.dart
│       │   └── breakpoints.dart
│       ├── network/              # 네트워크 유틸리티
│       │   ├── url_launcher.dart
│       │   └── json_parser.dart
│       └── utils.dart            # 통합 export 파일
│
└── features/
    └── voting/                   # 투표 Feature
        └── utils/
            └── timer/            # 타이머 이동
                ├── timer_controller.dart
                └── timer_widget.dart
```

## 🔄 마이그레이션 단계

### Phase 1: 분석 및 준비 (Day 1 - 오전)

#### 1.1 의존성 분석
```bash
# app_utils.dart 사용처 찾기
grep -r "app_utils" lib/ --include="*.dart" | wc -l
# 예상: 100+ 파일

# 각 유틸리티 함수 사용 빈도 분석
grep -r "dateTimeFormat\|formatNumber\|showSnackbar" lib/
```

#### 1.2 테스트 작성 (현재 동작 보존)
```dart
// test/core/utils/app_utils_test.dart
void main() {
  group('Current Utilities', () {
    test('dateTimeFormat should format correctly', () {
      final date = DateTime(2025, 8, 28);
      expect(dateTimeFormat('MMM d, y', date), 'Aug 28, 2025');
    });
    
    test('formatNumber should handle all types', () {
      expect(formatNumber(1234.56, formatType: FormatType.compact), '1.2K');
    });
  });
}
```

### Phase 2: 도메인별 분리 (Day 1 - 오후 ~ Day 2)

#### 2.1 DateTime 유틸리티 분리
```dart
// lib/core/utils/datetime/date_formatter.dart
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class DateFormatter {
  static void _initTimeagoLocales() {
    timeago.setLocaleMessages('en', timeago.EnMessages());
    timeago.setLocaleMessages('de', timeago.DeMessages());
  }
  
  static String format(String format, DateTime? dateTime, {String? locale}) {
    if (dateTime == null) return '';
    
    if (format == 'relative') {
      _initTimeagoLocales();
      return timeago.format(dateTime, locale: locale, allowFromNow: true);
    }
    
    return DateFormat(format, locale).format(dateTime);
  }
  
  static DateTime? copy(DateTime? dateTime) => dateTime != null
      ? DateTime.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch)
      : null;
}

// lib/core/utils/datetime/date_extensions.dart
extension DateTimeOperators on DateTime {
  bool operator <(DateTime other) => isBefore(other);
  bool operator >(DateTime other) => isAfter(other);
  bool operator <=(DateTime other) => this < other || isAtSameMomentAs(other);
  bool operator >=(DateTime other) => this > other || isAtSameMomentAs(other);
}

extension DateTimeHelpers on DateTime {
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);
}

// lib/core/utils/datetime/age_calculator.dart
class AgeCalculator {
  static DateTime getMinimumBirthDate({int minimumAge = 13}) {
    final now = DateTime.now();
    return DateTime(now.year - minimumAge, now.month, now.day);
  }
  
  static bool isOldEnough(DateTime birthDate, {int minimumAge = 13}) {
    return birthDate.isBefore(getMinimumBirthDate(minimumAge: minimumAge));
  }
}
```

#### 2.2 Platform 유틸리티 분리
```dart
// lib/core/utils/platform/platform_detector.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class PlatformDetector {
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;
  static bool get isiOS => !kIsWeb && Platform.isIOS;
  static bool get isWeb => kIsWeb;
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;
  static bool get isWindows => !kIsWeb && Platform.isWindows;
  static bool get isLinux => !kIsWeb && Platform.isLinux;
  
  static bool get isMobile => isAndroid || isiOS;
  static bool get isDesktop => isMacOS || isWindows || isLinux;
  
  static String get suffix {
    if (kIsWeb) return 'web';
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    if (Platform.isMacOS) return 'macos';
    if (Platform.isWindows) return 'windows';
    if (Platform.isLinux) return 'linux';
    return 'unknown';
  }
  
  static String get displayName {
    if (kIsWeb) return 'Web';
    if (Platform.isIOS) return 'iOS';
    if (Platform.isAndroid) return 'Android';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    if (Platform.isLinux) return 'Linux';
    return 'Unknown';
  }
}
```

#### 2.3 Number Formatter 분리
```dart
// lib/core/utils/formatting/format_types.dart
enum FormatType {
  decimal,
  percent,
  scientific,
  compact,
  compactLong,
  custom,
}

enum DecimalType {
  automatic,
  periodDecimal,
  commaDecimal,
}

// lib/core/utils/formatting/number_formatter.dart
import 'package:intl/intl.dart';
import 'format_types.dart';

class NumberFormatter {
  static String format(
    num? value, {
    required FormatType formatType,
    DecimalType decimalType = DecimalType.automatic,
    String? currency,
    bool toLowerCase = false,
    String? format,
    String? locale,
  }) {
    if (value == null) return '';
    
    var formattedValue = '';
    
    switch (formatType) {
      case FormatType.decimal:
        formattedValue = _formatDecimal(value, decimalType, locale);
        break;
      case FormatType.percent:
        formattedValue = NumberFormat.percentPattern(locale).format(value);
        break;
      case FormatType.scientific:
        formattedValue = NumberFormat.scientificPattern(locale).format(value);
        if (toLowerCase) formattedValue = formattedValue.toLowerCase();
        break;
      case FormatType.compact:
        formattedValue = NumberFormat.compact(locale: locale).format(value);
        break;
      case FormatType.compactLong:
        formattedValue = NumberFormat.compactLong(locale: locale).format(value);
        break;
      case FormatType.custom:
        formattedValue = NumberFormat(format, locale).format(value);
        break;
    }
    
    if (currency != null) {
      final symbol = currency.isNotEmpty
          ? currency
          : NumberFormat.simpleCurrency(locale: locale).currencySymbol;
      formattedValue = '$symbol$formattedValue';
    }
    
    return formattedValue.isNotEmpty ? formattedValue : value.toString();
  }
  
  static String _formatDecimal(num value, DecimalType type, String? locale) {
    switch (type) {
      case DecimalType.automatic:
        return NumberFormat.decimalPattern(locale).format(value);
      case DecimalType.periodDecimal:
        return NumberFormat.decimalPattern('en_US').format(value);
      case DecimalType.commaDecimal:
        return NumberFormat.decimalPattern('es_PA').format(value);
    }
  }
}
```

### Phase 3: Extensions 분리 (Day 3)

#### 3.1 List Extensions
```dart
// lib/core/utils/extensions/list_extensions.dart
extension ListFilter<T> on List<T> {
  List<T> filterList(bool Function(T element) filter) =>
      where((element) => filter(element)).toList();
}

extension ListDivide<T> on List<T> {
  List<List<T>> chunk(int chunkSize) {
    List<List<T>> chunks = [];
    for (int i = 0; i < length; i += chunkSize) {
      int end = (i + chunkSize < length) ? i + chunkSize : length;
      chunks.add(sublist(i, end));
    }
    return chunks;
  }
  
  List<T> divide(T separator) {
    if (isEmpty) return this;
    final List<T> result = [];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }
  
  List<T> addToStart(T item) => [item, ...this];
  List<T> addToEnd(T item) => [...this, item];
}

extension IterableHelpers<T> on Iterable<T> {
  List<T> sortedList<S extends Comparable>({
    S Function(T)? keyOf,
    bool desc = false,
  }) {
    final sorted = toList()
      ..sort(keyOf == null ? null : (a, b) => keyOf(a).compareTo(keyOf(b)));
    return desc ? sorted.reversed.toList() : sorted;
  }
  
  List<S> mapIndexed<S>(S Function(int, T) func) => toList()
      .asMap()
      .map((index, value) => MapEntry(index, func(index, value)))
      .values
      .toList();
}

extension IterableNullable<T> on Iterable<T?> {
  List<T> get withoutNulls => where((e) => e != null).cast<T>().toList();
}
```

### Phase 4: UI Helpers 분리 (Day 4)

#### 4.1 Responsive Helper
```dart
// lib/core/utils/ui/breakpoints.dart
class Breakpoints {
  static const double small = 479.0;
  static const double medium = 767.0;
  static const double large = 991.0;
}

// lib/core/utils/ui/responsive_helper.dart
import 'package:flutter/material.dart';
import 'breakpoints.dart';

class ResponsiveHelper {
  static bool isMobileWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width < Breakpoints.small;
  
  static bool isTabletWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= Breakpoints.small && width < Breakpoints.medium;
  }
  
  static bool isDesktopWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Breakpoints.large;
  
  static bool visibility({
    required BuildContext context,
    bool phone = true,
    bool tablet = true,
    bool tabletLandscape = true,
    bool desktop = true,
  }) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < Breakpoints.small) return phone;
    if (width < Breakpoints.medium) return tablet;
    if (width < Breakpoints.large) return tabletLandscape;
    return desktop;
  }
}
```

#### 4.2 SnackBar Helper
```dart
// lib/core/utils/ui/snackbar_helper.dart
import 'package:flutter/material.dart';

class SnackBarHelper {
  static void show(
    BuildContext context,
    String message, {
    bool loading = false,
    Duration duration = const Duration(seconds: 4),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (loading)
              Padding(
                padding: const EdgeInsetsDirectional.only(end: 10.0),
                child: Container(
                  height: 20,
                  width: 20,
                  child: const CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                ),
              ),
            Text(message),
          ],
        ),
        duration: duration,
      ),
    );
  }
}
```

### Phase 5: Import 경로 업데이트 (Day 5)

#### 5.1 자동 업데이트 스크립트
```bash
#!/bin/bash
# update_utils_imports.sh

# DateTime 관련 import 변경
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/app_utils.dart.*dateTimeFormat|import .*/core/utils/datetime/date_formatter.dart|g' {} \;

# Platform 관련 import 변경
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/app_utils.dart.*isAndroid|import .*/core/utils/platform/platform_detector.dart|g' {} \;

# Number Format 관련 import 변경
find lib -name "*.dart" -exec sed -i '' \
  's|import .*/app_utils.dart.*formatNumber|import .*/core/utils/formatting/number_formatter.dart|g' {} \;
```

#### 5.2 수동 검증
```bash
# 변경 확인
git diff --name-only | xargs grep -l "import"

# 컴파일 확인
flutter analyze

# 테스트 실행
flutter test
```

### Phase 6: Timer 이동 및 리팩토링 (Day 5 - 오후)

#### 6.1 Timer를 Feature로 이동
```dart
// lib/features/voting/utils/timer/timer_controller.dart
import 'dart:async';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class VotingTimerController {
  final StopWatchTimer _timer;
  final _stateController = StreamController<TimerState>.broadcast();
  
  Stream<TimerState> get stream => _stateController.stream;
  int get currentValue => _timer.rawTime.value;
  
  VotingTimerController({
    required int initialTimeMs,
    required StopWatchMode mode,
  }) : _timer = StopWatchTimer(
    mode: mode,
    presetMillisecond: initialTimeMs,
  ) {
    _timer.rawTime.listen((value) {
      _stateController.add(TimerState(value: value, isRunning: _timer.isRunning));
    });
  }
  
  void start() => _timer.onStartTimer();
  void stop() => _timer.onStopTimer();
  void reset() => _timer.onResetTimer();
  
  void dispose() {
    _timer.dispose();
    _stateController.close();
  }
}

class TimerState {
  final int value;
  final bool isRunning;
  
  TimerState({required this.value, required this.isRunning});
}
```

## 📊 위험 요소 및 대응 방안

### 위험 1: 대규모 Breaking Changes
- **위험도**: 매우 높음
- **영향**: 100+ 파일
- **대응**:
  - 단계적 마이그레이션
  - Deprecated 어노테이션 활용
  - 호환성 레이어 제공

### 위험 2: Import 경로 문제
- **위험도**: 높음
- **영향**: 전체 프로젝트
- **대응**:
  - 자동 스크립트 활용
  - 철저한 테스트
  - 점진적 업데이트

### 위험 3: 기능 누락
- **위험도**: 중간
- **영향**: 런타임 에러
- **대응**:
  - 완전한 테스트 커버리지
  - 모든 함수 매핑 문서화
  - 단계별 검증

## 📋 체크리스트

### 🔴 Day 1: 분석 및 DateTime 분리
- [ ] 의존성 분석 완료
- [ ] 현재 동작 테스트 작성
- [ ] DateTime 유틸리티 분리
- [ ] DateFormatter 구현
- [ ] DateExtensions 구현
- [ ] AgeCalculator 구현

### 🟡 Day 2: Platform 및 Formatting 분리
- [ ] PlatformDetector 구현
- [ ] NumberFormatter 구현
- [ ] TextFormatter 구현
- [ ] FormatTypes 정의

### 🟢 Day 3: Extensions 분리
- [ ] ListExtensions 구현
- [ ] StringExtensions 구현
- [ ] MapExtensions 구현
- [ ] ColorExtensions 구현

### 🔵 Day 4: UI Helpers 및 Validators
- [ ] ResponsiveHelper 구현
- [ ] SnackBarHelper 구현
- [ ] TextValidators 구현
- [ ] UrlLauncher 구현

### ⚪ Day 5: 마이그레이션 및 테스트
- [ ] Import 경로 업데이트
- [ ] Timer 이동 및 리팩토링
- [ ] 통합 테스트
- [ ] 문서화

## 🚀 실행 명령

### 빠른 시작
```bash
# 디렉토리 구조 생성
./scripts/create_utils_structure.sh

# Import 업데이트
./scripts/update_utils_imports.sh

# 테스트 실행
flutter test test/core/utils/
```

### 검증
```bash
# 정적 분석
flutter analyze

# 사용처 확인
./scripts/check_utils_usage.sh

# 성능 테스트
flutter test test/core/utils/performance/
```

## ⚠️ 롤백 계획

만약 문제 발생 시:

```bash
# 1. 호환성 레이어 활성화
git checkout feature/utils-compatibility

# 2. 기존 app_utils 복원
git checkout main -- lib/core/utils/app_utils.dart

# 3. Import 경로 복구
./scripts/restore_utils_imports.sh

# 4. 점진적 재시도
```

## 📊 예상 효과

### 정량적 효과
- 파일 크기 80% 감소 (497줄 → 평균 100줄)
- 테스트 커버리지 0% → 95%
- Import 시간 30% 개선

### 정성적 효과
- 명확한 도메인 분리
- 향상된 유지보수성
- 쉬운 테스트 작성
- 더 나은 문서화

## 📝 참고 자료

- [Flutter Best Practices](https://docs.flutter.dev/development/packages-and-plugins/using-packages)
- [Dart Extensions](https://dart.dev/guides/language/extension-methods)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

*이 문서는 Core Utils의 Feature-First Architecture 마이그레이션 계획입니다.*
*도메인별 분리와 점진적 마이그레이션으로 안전한 전환을 보장합니다.*