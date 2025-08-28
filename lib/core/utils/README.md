# 📦 Core Utils 레이어

> 최종 업데이트: 2025-08-28 | 버전: 1.0.0

## 📋 개요

Core Utils는 Versus Space 애플리케이션 전체에서 사용되는 유틸리티 함수와 헬퍼 클래스를 제공하는 레이어입니다.
플랫폼 검증, 날짜/시간 처리, 숫자 포맷팅, 타이머 관리 등 범용적인 기능을 제공합니다.

## 🏗️ 현재 디렉토리 구조

```
lib/core/utils/
├── app_timer.dart        # 129줄 - 타이머 컨트롤러 및 위젯
├── app_utils.dart        # 497줄 - 범용 유틸리티 함수들
└── custom_functions.dart # 7줄 - 커스텀 함수 (13세 날짜 계산)

총 3개 파일, 633줄
```

## 🔍 현재 코드 분석

### 1. app_timer.dart (129줄)

**핵심 구성요소**:
- `AppTimerController`: StopWatchTimer 래퍼 클래스 (ChangeNotifier 패턴)
- `AppTimer`: 타이머 표시 위젯 (StatefulWidget)
- stop_watch_timer 패키지 활용
- Count Up/Down 모드 지원
- 상태 변경 시 리스너 알림

**주요 메서드**:
```dart
- onStartTimer() - 타이머 시작
- onStopTimer() - 타이머 정지  
- onResetTimer() - 타이머 리셋
- getDisplayTime() - 표시 시간 포맷팅
- onChanged() - 값 변경 콜백
- onEnded() - 타이머 종료 콜백
```

**문제점**:
- StopWatchTimer 패키지 직접 의존
- ChangeNotifier 패턴 사용 (Provider 의존)
- 단일 책임 원칙 위반 (컨트롤러와 위젯이 혼재)

### 2. app_utils.dart (497줄)

**핵심 구성요소**:
- **날짜/시간 유틸리티**:
  - `dateTimeFormat()` - 다양한 형식의 날짜 포맷팅
  - `dateCopy()` - DateTime 객체 복사
  - `getCurrentTimestamp()` - 현재 시간 반환
  - DateTime Extensions (비교 연산자, startOfDay, endOfDay)

- **플랫폼 검증**:
  - `isAndroid`, `isiOS`, `isWeb`, `isMacOS`, `isWindows`, `isLinux`
  - `getPlatformSuffix()` - 플랫폼 식별자 반환
  - `getPlatformDisplayName()` - 플랫폼 표시명 반환

- **숫자 포맷팅**:
  - `formatNumber()` - 다양한 숫자 포맷 지원
  - FormatType enum (decimal, percent, scientific, compact, custom)
  - DecimalType enum (automatic, periodDecimal, commaDecimal)

- **UI 유틸리티**:
  - `showSnackbar()` - SnackBar 표시
  - `launchURL()` - URL 열기
  - `getWidgetBoundingBox()` - 위젯 경계 박스 계산
  - `responsiveVisibility()` - 반응형 가시성 제어

- **텍스트 유효성 검증**:
  - `kTextValidatorUsernameRegex` - 사용자명 정규식
  - `kTextValidatorEmailRegex` - 이메일 정규식
  - `kTextValidatorWebsiteRegex` - 웹사이트 정규식

- **Extensions**:
  - List: `filterList()`, `chunk()`, `divide()`, `withoutNulls`
  - String: `toCapitalization()`, `ref` (DocumentReference)
  - Double: `toStringAsFixedNoZero()`, `divide()`
  - Map: `withoutNulls`
  - Color: `applyAlpha()`
  - TextEditingController: 안전한 text getter/setter

**export 목록**:
```dart
export '/app/models/lat_lng.dart';
export '/app/models/place.dart';
export '/core/models/uploaded_file.dart';
export '/app/state/app_state.dart';
export '/core/models/app_model.dart';
export 'dart:math' show min, max;
export 'package:intl/intl.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
```

**문제점**:
- 단일 파일에 너무 많은 기능 집중 (497줄)
- 다양한 관심사가 혼재 (날짜, 플랫폼, UI, 포맷팅 등)
- export 문이 유틸리티 파일에 포함
- 직접적인 Firebase 의존성

### 3. custom_functions.dart (7줄)

**핵심 구성요소**:
- `datetime13day()` - 13년 전 날짜 계산 (13세 연령 검증용)

**문제점**:
- 단일 함수로 별도 파일 생성은 비효율적
- 함수명이 명확하지 않음
- 비즈니스 로직이 utils에 포함

## ⚠️ 현재 문제점 종합

### 1. 구조적 문제
- **코드 집중**: app_utils.dart에 너무 많은 기능 집중
- **관심사 혼재**: 다양한 도메인 로직이 하나의 파일에 존재
- **계층 위반**: 유틸리티가 app, models 등을 export

### 2. 유지보수 문제
- **파일 크기**: 497줄의 거대한 단일 파일
- **테스트 어려움**: 유틸리티 함수들의 테스트 부재
- **문서화 부족**: 함수별 용도와 사용법 불명확

### 3. 의존성 문제
- **직접 의존**: Firebase, url_launcher 등 외부 패키지 직접 사용
- **순환 의존**: app 레이어와 core 레이어 간 순환 참조
- **불필요한 export**: 유틸리티 파일에서 모델 export

## 🎯 Feature-First Architecture 적용 방안

### 1. 도메인별 분리 전략

```
lib/core/utils/
├── datetime/           # 날짜/시간 관련
│   ├── date_formatter.dart
│   ├── date_extensions.dart
│   └── timeago_helper.dart
├── platform/           # 플랫폼 관련
│   ├── platform_detector.dart
│   └── platform_extensions.dart
├── formatting/         # 포맷팅 관련
│   ├── number_formatter.dart
│   ├── text_formatter.dart
│   └── currency_formatter.dart
├── ui/                # UI 유틸리티
│   ├── responsive_helper.dart
│   ├── widget_helper.dart
│   └── snackbar_helper.dart
├── validators/         # 유효성 검증
│   ├── text_validators.dart
│   └── form_validators.dart
├── extensions/         # 다양한 Extensions
│   ├── list_extensions.dart
│   ├── string_extensions.dart
│   ├── map_extensions.dart
│   └── color_extensions.dart
└── timer/             # 타이머 관련
    ├── timer_controller.dart
    └── timer_widget.dart
```

### 2. 리팩토링 우선순위

| 작업 | 우선순위 | 예상 시간 | 난이도 | 영향도 |
|------|----------|----------|--------|--------|
| app_utils.dart 분리 | 🔴 매우 높음 | 3일 | 높음 | 매우 높음 |
| export 문 제거 | 🔴 매우 높음 | 1일 | 낮음 | 높음 |
| 도메인별 디렉토리 생성 | 🟡 중간 | 2일 | 중간 | 높음 |
| 타이머 리팩토링 | 🟡 중간 | 1일 | 중간 | 중간 |
| 테스트 코드 작성 | 🟢 낮음 | 2일 | 중간 | 높음 |

## 📊 사용 현황 분석

### 직접 사용 파일
- **app_utils.dart**: 100+ 파일에서 사용 (거의 모든 Feature)
- **app_timer.dart**: 투표 타이머, 게임 타이머 등에서 사용
- **custom_functions.dart**: 연령 검증 로직에서만 사용

### 주요 사용 패턴
```dart
// 날짜 포맷팅
dateTimeFormat('relative', timestamp)
dateTimeFormat('MMM d, y', date)

// 플랫폼 검증
if (isAndroid) { ... }
if (isWeb) { ... }

// 숫자 포맷팅
formatNumber(value, formatType: FormatType.compact)

// Extension 사용
list.filterList((item) => item.isActive)
text.toCapitalization(TextCapitalization.words)
```

## 🚀 구현 로드맵

### Phase 1: 긴급 분리 (즉시)
- app_utils.dart를 도메인별로 분리
- export 문 제거 및 import 정리
- 순환 의존성 해결

### Phase 2: 구조 개선 (1주일)
- 도메인별 디렉토리 구조 생성
- 각 도메인별 헬퍼 클래스 구현
- 타이머 시스템 리팩토링

### Phase 3: 품질 향상 (2주일)
- 유틸리티 함수 테스트 작성
- 문서화 및 사용 가이드 작성
- 성능 최적화

## 💡 주요 개선 제안

### 1. 의존성 주입 패턴
```dart
// 현재 (직접 의존)
void launchURL(String url) async {
  await launchUrl(Uri.parse(url));
}

// 개선 (DI 패턴)
class UrlLauncher {
  final LaunchService _launchService;
  
  UrlLauncher(this._launchService);
  
  Future<void> launch(String url) async {
    await _launchService.launch(Uri.parse(url));
  }
}
```

### 2. 타이머 시스템 개선
```dart
// 현재 (Provider 의존)
class AppTimerController with ChangeNotifier {...}

// 개선 (Stream 기반)
class TimerService {
  final _timerStream = StreamController<TimerState>.broadcast();
  Stream<TimerState> get stream => _timerStream.stream;
}
```

### 3. 플랫폼 검증 싱글톤
```dart
class PlatformService {
  static final PlatformService _instance = PlatformService._internal();
  factory PlatformService() => _instance;
  PlatformService._internal();
  
  final bool isAndroid = !kIsWeb && Platform.isAndroid;
  final bool isiOS = !kIsWeb && Platform.isIOS;
  // ...
}
```

## 🔗 연관 파일 및 의존성

### 현재 의존 관계
- `/app/` → `/core/utils/` (app_state, models)
- `/features/*` → `/core/utils/` (모든 Feature에서 사용)
- `/backend/` → `/core/utils/` (Firebase 관련)

### 이동 필요 파일
- `custom_functions.dart` → `/features/auth/utils/age_validator.dart`
- Timer 관련 → `/features/voting/utils/` 또는 `/shared/widgets/timer/`

## ⚡ 성능 고려사항

1. **Tree Shaking**: 불필요한 유틸리티 제거
2. **Lazy Loading**: 필요 시점에 유틸리티 로드
3. **Memoization**: 계산 비용이 높은 함수 결과 캐싱

## 🚨 주의사항

1. **Breaking Changes**: app_utils 분리 시 전체 앱 영향
2. **Import 경로**: 모든 파일의 import 경로 수정 필요
3. **테스트 영향**: 유틸리티 변경 시 광범위한 테스트 필요

## 📋 체크리스트

### 즉시 수정 필요
- [ ] app_utils.dart 도메인별 분리
- [ ] export 문 제거
- [ ] 순환 의존성 해결

### 단기 목표 (1주일)
- [ ] 도메인별 디렉토리 구조 생성
- [ ] 타이머 시스템 개선
- [ ] custom_functions 이동

### 장기 목표 (1개월)
- [ ] 100% 테스트 커버리지
- [ ] 완전한 문서화
- [ ] 성능 최적화

---

*이 문서는 Core Utils 레이어의 현재 상태와 개선 방안을 담고 있습니다.*
*애플리케이션 전체에서 사용되는 핵심 유틸리티 기능을 제공합니다.*