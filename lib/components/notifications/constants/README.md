# Notification Constants - 알림 시스템 상수 및 제약 조건

알림 시스템의 반응형 디자인을 위한 상수, 제약 조건, 스케일링 전략을 정의하는 디렉토리입니다.

## 📋 개요

이 디렉토리는 Versus Space 앱의 투표 알림 시스템에서 사용되는 모든 UI 제약 조건과 상수를 중앙 집중식으로 관리합니다. 다양한 화면 크기와 디바이스에서 일관된 사용자 경험을 제공하기 위한 반응형 디자인의 핵심 설정을 포함합니다.

### 주요 특징
- **반응형 디자인**: 3단계 화면 크기별 스케일링 시스템
- **동적 크기 계산**: 화면 크기에 따른 자동 크기 조정
- **제약 조건 관리**: 최대/최소 크기 제한으로 UI 일관성 보장
- **적응형 텍스트**: 박스 크기에 따른 텍스트 크기 자동 조정
- **애니메이션 설정**: 슬라이드, 페이드 효과 시간 정의
- **디자인 토큰**: 그림자, 테두리, 간격 등 스타일 상수

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`voting_notification_constraints.dart`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`VotingNotificationConstraints`)
- **상수**: lowerCamelCase (`maxNotificationWidthLimit`, `defaultBoxHeight`)
- **메서드**: lowerCamelCase (`getScaleFactor`, `constrainBoxSize`)
- **매개변수**: lowerCamelCase (`screenWidth`, `boxHeight`)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### VotingNotificationConstraints 클래스
**파일**: `voting_notification_constraints.dart`  
**용도**: 투표 알림 UI의 모든 크기 제약과 스케일링 로직을 관리하는 정적 클래스

#### 크기 제약 상수

##### 알림 컨테이너
| 상수 | 값 | 설명 |
|------|-----|------|
| `maxNotificationWidthLimit` | 500.0 | 알림의 절대 최대 너비 |
| `minNotificationWidth` | 320.0 | 알림의 최소 너비 (모바일 최소 지원) |
| `defaultNotificationPadding` | 16.0 | 기본 화면 패딩 |
| `largeScreenPadding` | 20.0 | 큰 화면용 패딩 |

##### 투표 박스
| 상수 | 값 | 설명 |
|------|-----|------|
| `maxBoxHeightRatio` | 0.8 | 화면 높이의 최대 80% 사용 |
| `minBoxHeight` | 150.0 | 박스 최소 높이 |
| `defaultBoxHeight` | 350.0 | 박스 기본 높이 |
| `boxSpacing` | 8.0 | A/B 박스 간 간격 |
| `verticalSpacing` | 12.0 | 세로 배치 시 간격 |

#### 반응형 스케일링 시스템

##### 3단계 화면 크기 분류
```dart
// 큰 화면 (>400px)
largeScreenScale = 1.0       // 100% 크기
largeScreenThreshold = 400.0

// 중간 화면 (350-400px)  
mediumScreenScale = 0.95     // 95% 크기
mediumScreenThreshold = 350.0

// 작은 화면 (<350px)
smallScreenScale = 0.85      // 85% 크기
```

#### 텍스트 크기 관리

| 상수 | 값 | 설명 | 변경 이력 |
|------|-----|------|-----------|
| `maxTextSize` | 20.0 | 최대 텍스트 크기 | 16.0→24.0→20.0 |
| `minTextSize` | 16.0 | 최소 텍스트 크기 | 10.0→12.0→16.0 |
| `defaultTextSize` | 14.0 | 기본 텍스트 크기 | 12.0→18.0→14.0 |

#### 애니메이션 타이밍

| 상수 | 값 | 용도 |
|------|-----|------|
| `slideAnimationDuration` | 500ms | 슬라이드 애니메이션 |
| `fadeAnimationDuration` | 300ms | 페이드 애니메이션 |
| `voteCompleteDuration` | 1초 | 투표 완료 전환 |
| `votingTimeLimit` | 10분 | 투표 제한 시간 |

#### 스타일 토큰

##### 그림자 효과
```dart
cardElevation = 12.0
shadowBlurRadius = 15.0
shadowOpacity = 0.15
shadowOffset = Offset(0, 5)
```

##### Border Radius
```dart
cardBorderRadius = 20.0    // 카드 외곽
boxBorderRadius = 16.0     // 투표 박스
buttonBorderRadius = 12.0  // 버튼
labelBorderRadius = 16.0   // A/B 라벨
```

##### 아이콘 크기
```dart
labelIconSize = 32.0    // A/B 라벨 아이콘
actionIconSize = 20.0   // 닫기 등 액션 아이콘
statusIconSize = 20.0   // 상태 표시 아이콘
```

### 핵심 메서드

#### getScaleFactor(screenWidth)
화면 너비에 따른 스케일링 팩터를 계산합니다.

```dart
static double getScaleFactor(double screenWidth) {
  if (screenWidth > 400) return 1.0;      // 큰 화면
  if (screenWidth > 350) return 0.95;     // 중간 화면
  return 0.85;                            // 작은 화면
}
```

#### getNotificationWidth(screenWidth)
동적 알림 너비를 계산합니다 (화면의 92% 사용).

```dart
static double getNotificationWidth(double screenWidth) {
  final dynamicWidth = screenWidth * 0.92;
  final padding = screenWidth > 400 ? 20.0 : 16.0;
  final maxWidth = dynamicWidth - (padding * 2);
  
  return maxWidth.clamp(320.0, 500.0);
}
```

#### constrainBoxSize(proposedSize, scaleFactor, ...)
제안된 크기를 제약 조건에 맞춰 조정합니다.

```dart
static Size constrainBoxSize(
  Size proposedSize, 
  double scaleFactor,
  {double? maxWidth, double? screenHeight}
) {
  // 1. 스케일링 적용
  // 2. 높이 제약 확인
  // 3. 비율 유지하며 조정
  // 4. 최종 크기 반환
}
```

#### getAdaptiveTextSize(boxHeight)
박스 높이에 비례하여 텍스트 크기를 조정합니다.

```dart
static double getAdaptiveTextSize(
  double boxHeight,
  {double baseTextSize = 14.0}
) {
  final heightRatio = boxHeight / 350.0;  // 기본 높이 대비 비율
  final adaptedSize = baseTextSize * heightRatio;
  return adaptedSize.clamp(16.0, 20.0);   // 최소/최대 제한
}
```

## 💡 사용 예시

### 기본 사용법

```dart
import 'package:versus_space/components/notifications/constants/voting_notification_constraints.dart';

class VotingNotificationDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 스케일 팩터 계산
    final scaleFactor = VotingNotificationConstraints.getScaleFactor(screenWidth);
    
    // 알림 너비 계산
    final notificationWidth = VotingNotificationConstraints.getNotificationWidth(screenWidth);
    
    // 박스 크기 제약 적용
    final constrainedSize = VotingNotificationConstraints.constrainBoxSize(
      Size(300, 400),
      scaleFactor,
      screenHeight: screenHeight,
    );
    
    return Container(
      width: notificationWidth,
      padding: EdgeInsets.all(
        VotingNotificationConstraints.getDynamicPadding(screenWidth)
      ),
      // ...
    );
  }
}
```

### 적응형 텍스트 크기

```dart
// 박스 높이에 따른 텍스트 크기 자동 조정
Text(
  optionText,
  style: TextStyle(
    fontSize: VotingNotificationConstraints.getAdaptiveTextSize(
      boxHeight,
      baseTextSize: 14.0,
    ),
  ),
)
```

### 반응형 레이아웃

```dart
// 화면 크기에 따른 레이아웃 결정
Widget _buildLayout(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final spacing = VotingNotificationConstraints.getDynamicBoxSpacing(screenWidth);
  
  if (screenWidth > VotingNotificationConstraints.largeScreenThreshold) {
    // 큰 화면: 가로 배치
    return Row(
      children: [
        Expanded(child: _buildOptionA()),
        SizedBox(width: spacing),
        Expanded(child: _buildOptionB()),
      ],
    );
  } else {
    // 작은 화면: 세로 배치
    return Column(
      children: [
        _buildOptionA(),
        SizedBox(height: spacing),
        _buildOptionB(),
      ],
    );
  }
}
```

### 디버그 정보 출력

```dart
// 개발 중 제약 조건 확인
if (kDebugMode) {
  VotingNotificationConstraints.printConstraints(screenWidth);
}

// 출력 예시:
// [VotingNotificationConstraints] Debug Info:
//   Screen Width: 375.0px
//   Scale Factor: 95%
//   Notification Width: 345.0px
//   Dynamic Padding: 16.0px
//   Box Spacing: 8.0px
//   Max Box Height Ratio: 80%
//   Default Box Height: 350.0px
```

## 🎨 디자인 시스템 통합

### 반응형 디자인 전략

#### 1. 화면 크기 감지
```dart
// 화면 크기 카테고리 결정
String getScreenCategory(double width) {
  if (width > 400) return 'large';
  if (width > 350) return 'medium';
  return 'small';
}
```

#### 2. 동적 크기 조정
- **너비**: 화면의 92% 사용, 최대 500px 제한
- **높이**: 화면의 80% 제한, 최소 150px 보장
- **패딩**: 큰 화면 20px, 작은 화면 16px
- **간격**: 큰 화면 12px, 작은 화면 8px

#### 3. 텍스트 스케일링
- 박스 높이에 비례하여 자동 조정
- 최소/최대 크기로 가독성 보장
- 기준 높이(350px) 대비 비율 계산

### 애니메이션 가이드라인

```dart
// 진입 애니메이션
SlideTransition(
  position: Tween<Offset>(
    begin: Offset(0, -1),  // 위에서 시작
    end: Offset.zero,
  ).animate(CurvedAnimation(
    parent: controller,
    curve: Curves.easeOutCubic,
    duration: VotingNotificationConstraints.slideAnimationDuration,
  )),
)

// 페이드 효과
FadeTransition(
  opacity: animation,
  duration: VotingNotificationConstraints.fadeAnimationDuration,
)
```

## ⚡ 성능 최적화

### 상수 사용의 이점
- **컴파일 타임 최적화**: const 키워드로 컴파일 시점 최적화
- **메모리 효율**: 정적 상수로 인스턴스 생성 없음
- **일관성 보장**: 중앙 집중식 관리로 일관된 UI

### 계산 최적화
```dart
// 자주 사용되는 값 캐싱
class NotificationWidget extends StatefulWidget {
  late final double scaleFactor;
  late final double notificationWidth;
  
  @override
  void initState() {
    super.initState();
    final screenWidth = MediaQuery.of(context).size.width;
    scaleFactor = VotingNotificationConstraints.getScaleFactor(screenWidth);
    notificationWidth = VotingNotificationConstraints.getNotificationWidth(screenWidth);
  }
}
```

## 🔗 관련 파일

### 상위 컴포넌트
- `/lib/components/notifications/` - 알림 시스템 메인 디렉토리
- `/lib/components/notifications/widgets/` - 알림 UI 위젯들
- `/lib/components/notifications/models/` - 알림 데이터 모델

### 사용처
- `voting_notification_dialog.dart` - 투표 알림 다이얼로그
- `versus_notification_box.dart` - A/B 옵션 박스
- `notification_overlay.dart` - 알림 오버레이

### 디자인 시스템
- `/lib/design_system/` - 전역 디자인 토큰

## 📊 아키텍처

```
VotingNotificationConstraints
├── 크기 제약 조건
│   ├── 알림 크기 (너비, 패딩)
│   ├── 박스 크기 (높이, 비율)
│   └── 간격 (박스 간, 세로 간격)
├── 반응형 스케일링
│   ├── 화면 크기 감지
│   ├── 스케일 팩터 계산
│   └── 동적 크기 조정
├── 텍스트 관리
│   ├── 적응형 크기
│   ├── 최소/최대 제한
│   └── 박스 비례 계산
└── 스타일 토큰
    ├── 애니메이션 타이밍
    ├── 그림자 효과
    └── Border Radius
```

## 🐛 문제 해결

### 텍스트가 잘리는 문제
```dart
// 문제: 작은 박스에서 텍스트 오버플로우
// 해결: 적응형 텍스트 크기 사용
final textSize = VotingNotificationConstraints.getAdaptiveTextSize(
  actualBoxHeight,  // 실제 렌더링된 박스 높이 사용
  baseTextSize: 14.0,
);
```

### 화면 회전 시 레이아웃 깨짐
```dart
// 문제: 가로/세로 전환 시 크기 불일치
// 해결: OrientationBuilder 사용
OrientationBuilder(
  builder: (context, orientation) {
    final size = MediaQuery.of(context).size;
    final width = orientation == Orientation.portrait 
      ? size.width 
      : size.height;
    
    return _buildAdaptiveLayout(width);
  },
)
```

### 디바이스별 크기 차이
```dart
// 문제: 태블릿에서 너무 큰 알림
// 해결: 최대 너비 제한 적용
final width = VotingNotificationConstraints.getNotificationWidth(screenWidth);
// 자동으로 500px 제한 적용됨
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 개정 및 상세 설명 추가
- **2025-07-25**: 텍스트 크기 조정 (v1.2.0)
  - defaultTextSize: 18.0 → 14.0
  - 가독성 개선을 위한 최소 크기 상향
- **2025-07-23**: 반응형 디자인 시스템 도입 (v1.1.0)
  - 3단계 스케일링 시스템 추가
  - 동적 크기 계산 메서드 구현
- **2025-07-20**: 초기 구현 (v1.0.0)
  - 기본 제약 조건 정의
  - 정적 크기 설정

---

*이 문서는 `/lib/components/notifications/constants` 디렉토리의 알림 시스템 상수를 설명합니다.*