# 투표 알림 상수 및 제약 조건

투표 알림 시스템의 크기, 스타일, 애니메이션 등의 상수를 정의합니다.

## 📁 파일 구조

```
constants/
└── voting_notification_constraints.dart  # 모든 제약 조건 및 상수 정의
```

## 🎯 주요 기능

### 1. 크기 제약 조건

#### 알림 크기
```dart
static const double maxNotificationWidthLimit = 500.0;  // 절대 최대 너비
static const double minNotificationWidth = 320.0;       // 최소 너비
static const double defaultNotificationPadding = 16.0;  // 기본 패딩
```

#### 박스 크기
```dart
static const double maxBoxHeightRatio = 0.8;   // 화면 높이의 80%까지
static const double minBoxHeight = 150.0;      // 최소 박스 높이
static const double defaultBoxHeight = 350.0;  // 기본 박스 높이
```

### 2. 텍스트 크기 (v1.2.0 조정)

```dart
// 이전 버전 대비 조정된 값
static const double maxTextSize = 20.0;     // 16.0 → 24.0 → 20.0
static const double minTextSize = 10.0;     // 10.0 → 14.0 → 10.0
static const double defaultTextSize = 14.0; // 12.0 → 18.0 → 14.0
```

### 3. 화면 크기별 스케일링

```dart
// 큰 화면 (>400px): 100% 크기
static const double largeScreenScale = 1.0;
static const double largeScreenThreshold = 400.0;

// 중간 화면 (350-400px): 95% 크기
static const double mediumScreenScale = 0.95;
static const double mediumScreenThreshold = 350.0;

// 작은 화면 (<350px): 85% 크기
static const double smallScreenScale = 0.85;
```

### 4. 애니메이션 설정

```dart
static const Duration slideAnimationDuration = Duration(milliseconds: 500);
static const Duration fadeAnimationDuration = Duration(milliseconds: 300);
static const Duration voteCompleteDuration = Duration(seconds: 1);
```

## 🔧 주요 메서드

### getScaleFactor(screenWidth)
화면 크기에 따른 스케일링 팩터를 계산합니다.

```dart
final scale = VotingNotificationConstraints.getScaleFactor(screenWidth);
// 반환값: 0.85 ~ 1.0
```

### getNotificationWidth(screenWidth)
동적 알림 너비를 계산합니다 (화면의 92% 사용).

```dart
final width = VotingNotificationConstraints.getNotificationWidth(screenWidth);
// 반환값: 320.0 ~ 500.0
```

### getAdaptiveTextSize(boxHeight)
박스 높이에 맞춰 텍스트 크기를 자동 조정합니다.

```dart
final textSize = VotingNotificationConstraints.getAdaptiveTextSize(
  boxHeight,
  baseTextSize: 14.0,
);
// 반환값: minTextSize ~ maxTextSize
```

### constrainBoxSize(proposedSize, scaleFactor)
제안된 크기를 제약 조건에 맞춰 조정합니다.

```dart
final constrainedSize = VotingNotificationConstraints.constrainBoxSize(
  Size(200, 400),
  0.9,
  maxWidth: 300,
  screenHeight: 800,
);
```

## 🎨 스타일 설정

### 그림자 효과
```dart
static const double shadowBlurRadius = 15.0;
static const double shadowOpacity = 0.15;
static const Offset shadowOffset = Offset(0, 5);
```

### Border Radius
```dart
static const double cardBorderRadius = 20.0;
static const double boxBorderRadius = 16.0;
static const double buttonBorderRadius = 12.0;
```

### 아이콘 크기
```dart
static const double labelIconSize = 32.0;    // A/B 라벨
static const double actionIconSize = 20.0;   // 액션 버튼
static const double statusIconSize = 20.0;   // 상태 아이콘
```

## 📊 사용 예제

### 기본 사용법
```dart
// 스케일 팩터 가져오기
final scale = VotingNotificationConstraints.getScaleFactor(
  MediaQuery.of(context).size.width
);

// 텍스트 크기 계산
final textSize = VotingNotificationConstraints.getAdaptiveTextSize(
  boxHeight,
  baseTextSize: VotingNotificationConstraints.defaultTextSize,
);
```

### 디버그 정보 출력
```dart
VotingNotificationConstraints.printConstraints(screenWidth);
// 출력:
// Screen Width: 375.0px
// Scale Factor: 95%
// Notification Width: 345.0px
// Dynamic Padding: 16.0px
// Box Spacing: 8.0px
```

## 🔄 버전 히스토리

### v1.2.0 (2025-07-25)
- 텍스트 크기 조정
  - defaultTextSize: 18.0 → 14.0
  - maxTextSize: 24.0 → 20.0
  - minTextSize: 14.0 → 10.0 (원래 값으로 복원)
- 단일 이미지 모드 최적화

### v1.1.0 (2025-07-23)
- 박스 크기 제약 조건 개선
- 동적 크기 계산 메서드 추가
- 화면 크기별 스케일링 도입

### v1.0.0
- 초기 릴리즈
- 기본 제약 조건 정의

## 🐛 트러블슈팅

### 텍스트가 너무 크거나 작을 때
```dart
// 문제: 자동 계산된 텍스트 크기가 부적절
// 해결: 커스텀 텍스트 크기 직접 지정
VersusNotificationBox(
  customTextSize: 16.0, // 고정 크기 사용
  // ...
)
```

### 박스가 화면을 벗어날 때
```dart
// 문제: 박스 크기가 화면보다 큼
// 해결: constrainBoxSize 메서드 사용
final safeSize = VotingNotificationConstraints.constrainBoxSize(
  originalSize,
  scaleFactor,
  screenHeight: MediaQuery.of(context).size.height,
);
```

---

**최종 업데이트**: 2025-07-25  
**작성자**: SuperClaude Framework