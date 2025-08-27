# 🛠️ Utils - 유틸리티 함수 라이브러리

## 📋 개요

Versus Space 앱 전반에서 사용되는 유틸리티 함수 및 헬퍼 클래스들을 모아놓은 라이브러리입니다. 로깅, 콘텐츠 필터링, 반응형 디자인, 투표 메시지 헬퍼 등 핵심 유틸리티 기능을 제공합니다.

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **클래스명**: PascalCase (`AppLogger`, `ContentFilter`, `ResponsiveBreakpoints`)
- **메서드명**: camelCase (`logAction`, `filterText`, `isMobile`)
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 🏗️ 구조

```
utils/
├── app_logger.dart              # 메모리 기반 로깅 시스템 (64줄)
├── file_logger.dart             # 파일 기반 로깅 시스템 (90줄)
├── content_filter.dart          # 콘텐츠 필터링 시스템 (180줄)
├── responsive_breakpoints.dart  # 반응형 디자인 유틸리티 (177줄)
├── vote_message_helper.dart     # 투표 메시지 헬퍼 (23줄)
└── README.md                    # 문서 파일
```

## 🔧 주요 구성요소

### 1. AppLogger (app_logger.dart)
앱 전체 메모리 기반 로깅 시스템입니다.

```dart
// 사용 예제
AppLogger.logAction('BUTTON_CLICK', data: {'button': 'login'});
AppLogger.logNavigation('home', 'profile');
AppLogger.logError('API 호출 실패', stackTrace: st);

// 로그 조회
String recentLogs = AppLogger.getRecentLogs(50);
String allLogs = AppLogger.getAllLogs();
```

**주요 기능:**
- 액션 로깅 (최대 1000개 보관)
- 네비게이션 추적
- 버튼 클릭 추적
- 에러 로깅
- 디버그 모드에서만 콘솔 출력

### 2. FileLogger (file_logger.dart)
파일 기반 영구 로깅 시스템입니다.

```dart
// 초기화
await FileLogger.initialize();

// 로그 작성
await FileLogger.log('사용자 로그인 성공');

// 로그 읽기
String logs = await FileLogger.readAllLogs();

// 로그 삭제
await FileLogger.clearLogs();
```

**특징:**
- `app_debug.log` 파일에 저장
- 1MB 초과 시 자동 초기화
- 비동기 파일 I/O
- 타임스탬프 자동 추가

### 3. ContentFilter (content_filter.dart)
텍스트 콘텐츠 필터링 및 검증 시스템입니다.

```dart
// 초기화
await ContentFilter.initialize();

// 텍스트 필터링
FilterResult result = ContentFilter.filterText(userInput);
if (result.isBlocked) {
  print('금지어 발견: ${result.blockedWord}');
  print('카테고리: ${result.category}');
  print('심각도: ${result.severity}');
}

// TextFormField 검증
validator: ContentFilter.validateText,
```

**주요 기능:**
- JSON 기반 금지어 사전 (`blocked_words.json`)
- 카테고리별 심각도 관리
- 자음/모음 분리 패턴 감지
- 정규화 및 변형 패턴 검사
- 실시간 텍스트 검증

**FilterResult 구조:**
```dart
class FilterResult {
  final bool isBlocked;
  final String filteredText;
  final String? blockedWord;
  final String? category;
  final String severity;
}
```

### 4. ResponsiveBreakpoints (responsive_breakpoints.dart)
반응형 디자인을 위한 브레이크포인트 및 유틸리티입니다.

```dart
// 디바이스 타입 확인
if (ResponsiveBreakpoints.isMobile(context)) {
  return MobileLayout();
} else if (ResponsiveBreakpoints.isTablet(context)) {
  return TabletLayout();
} else {
  return DesktopLayout();
}

// 디바이스 타입 가져오기
DeviceType deviceType = ResponsiveBreakpoints.getDeviceType(context);

// 반응형 메시지 너비
double maxWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);

// 반응형 VS 박스 높이
double height = ResponsiveBreakpoints.getVsBoxHeight(
  context, 
  hasImages: true, 
  isExpanded: false
);
```

**브레이크포인트:**
- `mobileSmall`: 320px
- `mobile`: 375px
- `mobileLarge`: 414px
- `tablet`: 768px
- `desktop`: 1024px
- `desktopLarge`: 1440px

**DeviceType enum:**
```dart
enum DeviceType {
  mobileSmall,
  mobile,
  mobileLarge,
  tablet,
  desktop,
  desktopLarge,
}
```

### 5. VoteMessageHelper (vote_message_helper.dart)
투표 메시지 상태 아이콘을 관리하는 헬퍼 클래스입니다.

```dart
// 투표 상태별 아이콘 가져오기
IconData icon = VoteMessageHelper.getStatusIcon('completed');
// Returns: Icons.check_circle

// 상태별 아이콘 매핑
// 'completed' → Icons.check_circle
// 'votingRequest' → Icons.how_to_vote
// 'expired' → Icons.block
// 'notParticipated' → Icons.block
// 'inProgress' → Icons.timer
```

## 💻 코드 분석

### 로깅 시스템 특징
- **이중 로깅 체계**: 메모리(AppLogger) + 파일(FileLogger)
- **자동 로테이션**: 메모리 1000개, 파일 1MB 제한
- **디버그 모드 감지**: `kDebugMode`로 프로덕션/개발 환경 구분
- **구조화된 로그**: 타임스탬프, 액션 타입, 데이터 포함

### 콘텐츠 필터링 특징  
- **JSON 기반 설정**: `assets/data/blocked_words.json` 사용
- **정규화 처리**: 공백, 특수문자, 숫자 제거
- **변형 패턴 감지**: 자음/모음 분리 패턴 검사
- **카테고리별 관리**: 심각도 레벨 차등 적용

### 반응형 시스템 특징
- **6단계 브레이크포인트**: 세밀한 디바이스 대응
- **컨텍스트 기반**: MediaQuery 활용
- **VS 박스 최적화**: 이미지/텍스트별 높이 차등
- **메시지 너비 제어**: 디바이스별 최적 너비

## 🚫 문제점

### 코드 품질 이슈
1. **하드코딩된 값**:
   - 로그 최대 개수 1000개 고정
   - 파일 크기 1MB 고정
   - 브레이크포인트 픽셀 값 하드코딩

2. **불완전한 구현**:
   - ContentFilter 자음/모음 변환 간단한 구현
   - 에러 처리 미흡 (FileLogger)
   - 동기화 메커니즘 없음

3. **성능 고려사항**:
   - 메모리 로그 무제한 증가 가능
   - 파일 I/O 블로킹 가능성
   - JSON 파싱 매번 수행

## 🔄 대체 구현

### 프로덕션 로깅
```dart
// 권장 로깅 라이브러리
logger: ^2.0.0           # 구조화된 로깅
firebase_crashlytics     # 크래시 리포팅
sentry_flutter          # 에러 트래킹
```

### 콘텐츠 필터링
```dart
// AI 기반 필터링
/lib/services/ai_moderation/  # Perspective API
Google Cloud Vision API       # 이미지 검열
```

### 반응형 디자인
```dart
flutter_screenutil      # 화면 크기 기반 스케일링
responsive_builder      # 반응형 위젯 빌더
```

## 📊 통계

- **총 파일 수**: 5개
- **총 코드 줄**: 534줄
- **평균 파일 크기**: 107줄
- **가장 큰 파일**: `content_filter.dart` (180줄)
- **가장 작은 파일**: `vote_message_helper.dart` (23줄)

## ⚠️ 주의사항

> **경고**: 로깅 시스템은 민감한 정보를 포함할 수 있습니다.
> 프로덕션에서는 반드시 필터링하세요.

### 보안 고려사항
- 비밀번호, 토큰 로깅 금지
- 개인정보 마스킹 필수
- 파일 로그 암호화 권장

### 권장 사항
- ✅ 환경별 로그 레벨 설정
- ✅ 로그 로테이션 구현
- ✅ 비동기 로깅 사용
- ✅ 구조화된 로그 포맷

## 🗑️ 개선 계획

### Phase 1: 로깅 시스템 개선
- Logger 패키지로 마이그레이션
- 로그 레벨 시스템 구현
- 원격 로깅 서버 연동

### Phase 2: 필터링 고도화
- AI 기반 필터링 통합
- 실시간 업데이트 지원
- 다국어 필터링 추가

### Phase 3: 반응형 최적화
- 동적 브레이크포인트
- 방향 전환 대응
- 폴더블 디바이스 지원

## 📝 변경 이력
- 2025-08-24: 문서화 완료 및 분석
- 2025-08-22: 초기 생성

---

*이 유틸리티 라이브러리는 앱 전반에서 사용되는 핵심 기능들을 제공합니다.*