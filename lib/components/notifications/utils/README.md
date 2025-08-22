# Notification Utils - 알림 시스템 유틸리티

투표 알림 시스템에서 사용되는 적응형 텍스트 크기 계산 및 UI 헬퍼 유틸리티를 제공하는 디렉토리입니다.

## 📋 개요

이 디렉토리는 Versus Space 앱의 투표 알림 시스템에서 다양한 화면 크기와 박스 크기에 최적화된 텍스트 크기를 자동으로 계산하는 유틸리티 클래스들을 포함합니다. 컨테이너 크기, 텍스트 길이, 화면 크기 등을 종합적으로 고려하여 최적의 가독성을 제공합니다.

### 주요 특징
- **적응형 텍스트 크기**: 컨테이너 크기에 따른 동적 텍스트 크기 계산
- **다양한 계산 방법**: 높이, 너비, 텍스트 길이, 반응형 기반 계산
- **텍스트 유형 관리**: 제목, 부제목, 본문 등 유형별 최적화
- **제약 조건 통합**: VotingNotificationConstraints와 연동
- **위젯 제공**: AdaptiveText 위젯으로 즉시 사용 가능
- **스타일 헬퍼**: AdaptiveTextStyle로 TextStyle 생성 지원

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`adaptive_text_size.dart`)
- **README**: 대문자 확장자 (`README.md`)

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`AdaptiveTextSize`, `AdaptiveText`)
- **메서드**: lowerCamelCase (`calculate`, `fromHeight`, `forText`)
- **매개변수**: lowerCamelCase (`containerSize`, `textType`, `maxLines`)
- **Enum**: PascalCase (`TextType`)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. AdaptiveTextSize 클래스
**파일**: `adaptive_text_size.dart`  
**용도**: 박스 크기에 따른 적응형 텍스트 크기 계산 유틸리티

#### 핵심 메서드

##### calculate() - 종합 계산
```dart
static double calculate({
  required Size containerSize,
  TextType textType = TextType.title,
  int maxLines = 2,
  double padding = 16.0,
})
```
컨테이너 크기를 기반으로 최적의 텍스트 크기를 계산합니다.

| 매개변수 | 설명 |
|---------|------|
| `containerSize` | 텍스트를 담을 컨테이너 크기 |
| `textType` | 텍스트 유형 (제목, 본문 등) |
| `maxLines` | 최대 라인 수 |
| `padding` | 컨테이너 내부 패딩 |

##### fromHeight() - 높이 기반 계산
```dart
static double fromHeight({
  required double containerHeight,
  double heightRatio = 0.12,
  TextType textType = TextType.title,
})
```
컨테이너 높이의 비율로 텍스트 크기를 계산합니다.

##### fromWidth() - 너비 기반 계산
```dart
static double fromWidth({
  required double containerWidth,
  double widthRatio = 0.08,
  TextType textType = TextType.title,
})
```
컨테이너 너비의 비율로 텍스트 크기를 계산합니다.

##### forText() - 텍스트 길이 고려 계산
```dart
static double forText({
  required String text,
  required Size containerSize,
  TextType textType = TextType.title,
  int maxLines = 2,
  FontWeight fontWeight = FontWeight.normal,
})
```
실제 텍스트 내용과 길이를 고려하여 크기를 계산합니다.

**길이별 조정 팩터**:
- 10자 미만: 1.15배 (짧은 텍스트 확대)
- 10-30자: 1.0배 (기본)
- 30-50자: 0.85배 (긴 텍스트 축소)
- 50자 초과: 0.75배 (매우 긴 텍스트 축소)

##### responsive() - 반응형 계산
```dart
static double responsive({
  required BuildContext context,
  required Size containerSize,
  TextType textType = TextType.title,
})
```
화면 크기를 고려한 반응형 텍스트 크기를 계산합니다.

**화면 크기별 조정**:
- 350px 미만: 0.9배
- 350-500px: 1.0배
- 500px 초과: 1.1배

##### forMultilineText() - 멀티라인 텍스트
```dart
static double forMultilineText({
  required List<String> lines,
  required Size containerSize,
  TextType textType = TextType.body,
  double lineSpacing = 1.2,
})
```
여러 줄 텍스트에 최적화된 크기를 계산합니다.

### 2. TextType Enum
**용도**: 텍스트 유형 분류 및 기본 크기 관리

```dart
enum TextType {
  title,    // 제목 (기본 16.0)
  subtitle, // 부제목 (기본 14.0)
  body,     // 본문 (기본 12.0)
  caption,  // 캡션 (기본 10.0)
  label,    // 라벨 (기본 11.0)
  button,   // 버튼 (기본 13.0)
}
```

#### 유형별 제약 조건

| TextType | 기본 크기 | 최소 크기 | 최대 크기 |
|----------|----------|----------|----------|
| title | 16.0 | minTextSize + 2 | maxTextSize + 4 |
| subtitle | 14.0 | minTextSize + 1 | maxTextSize + 2 |
| body | 12.0 | minTextSize | maxTextSize |
| caption | 10.0 | minTextSize - 1 | maxTextSize - 2 |
| label | 11.0 | minTextSize | maxTextSize - 1 |
| button | 13.0 | minTextSize + 1 | maxTextSize + 1 |

### 3. AdaptiveText 위젯
**용도**: 자동으로 크기가 조정되는 텍스트 위젯

```dart
class AdaptiveText extends StatelessWidget {
  final String text;
  final Size containerSize;
  final TextType textType;
  final int maxLines;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final bool responsive;
}
```

#### 주요 속성

| 속성 | 타입 | 설명 |
|------|------|------|
| `text` | String | 표시할 텍스트 |
| `containerSize` | Size | 컨테이너 크기 |
| `textType` | TextType | 텍스트 유형 |
| `maxLines` | int | 최대 라인 수 (기본: 2) |
| `responsive` | bool | 반응형 모드 활성화 |

### 4. AdaptiveTextStyle 헬퍼
**용도**: 적응형 TextStyle 생성 유틸리티

```dart
class AdaptiveTextStyle {
  static TextStyle create({
    required Size containerSize,
    TextType textType = TextType.body,
    int maxLines = 2,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    String? fontFamily,
    bool responsive = false,
    BuildContext? context,
  })
}
```

## 💡 사용 예시

### 기본 사용법

```dart
import 'package:versus_space/components/notifications/utils/adaptive_text_size.dart';

// 1. 직접 크기 계산
final textSize = AdaptiveTextSize.calculate(
  containerSize: Size(300, 150),
  textType: TextType.title,
  maxLines: 2,
);

Text(
  'A vs B 투표',
  style: TextStyle(fontSize: textSize),
);
```

### AdaptiveText 위젯 사용

```dart
// 자동 크기 조정 텍스트
AdaptiveText(
  '커피 vs 차, 당신의 선택은?',
  containerSize: Size(250, 100),
  textType: TextType.title,
  maxLines: 2,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  responsive: true,  // 화면 크기 고려
)
```

### 텍스트 길이 기반 계산

```dart
// 긴 텍스트는 자동으로 작게 조정
final longText = '이것은 매우 긴 텍스트입니다. 자동으로 크기가 조정되어 컨테이너에 맞춰집니다.';

final adjustedSize = AdaptiveTextSize.forText(
  text: longText,
  containerSize: Size(200, 80),
  textType: TextType.body,
  fontWeight: FontWeight.normal,
);

// 짧은 텍스트: 크기 증가
// 긴 텍스트: 크기 감소
```

### 반응형 텍스트

```dart
// 화면 크기에 따라 자동 조정
Widget build(BuildContext context) {
  final textSize = AdaptiveTextSize.responsive(
    context: context,
    containerSize: Size(300, 100),
    textType: TextType.subtitle,
  );
  
  return Container(
    width: 300,
    height: 100,
    child: Center(
      child: Text(
        '반응형 텍스트',
        style: TextStyle(fontSize: textSize),
      ),
    ),
  );
}
```

### 멀티라인 텍스트 처리

```dart
// 여러 줄 텍스트 최적화
final lines = [
  '첫 번째 줄입니다',
  '두 번째 줄은 조금 더 깁니다',
  '세 번째 줄',
];

final multilineSize = AdaptiveTextSize.forMultilineText(
  lines: lines,
  containerSize: Size(250, 120),
  textType: TextType.body,
  lineSpacing: 1.2,
);
```

### AdaptiveTextStyle 사용

```dart
// TextStyle 생성
final adaptiveStyle = AdaptiveTextStyle.create(
  containerSize: Size(200, 100),
  textType: TextType.button,
  fontWeight: FontWeight.w600,
  color: Theme.of(context).primaryColor,
  responsive: true,
  context: context,
);

ElevatedButton(
  child: Text('투표하기', style: adaptiveStyle),
  onPressed: () {},
)
```

### 투표 알림에서의 활용

```dart
// VotingNotificationDialog에서 사용
class VotingNotificationBox extends StatelessWidget {
  final String optionText;
  final Size boxSize;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: boxSize.width,
      height: boxSize.height,
      child: Center(
        child: AdaptiveText(
          optionText,
          containerSize: boxSize,
          textType: TextType.title,
          maxLines: 3,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          textAlign: TextAlign.center,
          responsive: true,
        ),
      ),
    );
  }
}
```

## 🎨 계산 알고리즘

### 스케일링 팩터 계산

```dart
// 기준 크기: 300x150 컨테이너
const referenceWidth = 300.0;
const referenceHeight = 150.0;

// 스케일링 팩터
widthFactor = availableWidth / referenceWidth;
heightFactor = availableHeight / (referenceHeight / maxLines);

// 최종 팩터 (0.5 ~ 2.0 범위)
scaleFactor = min(widthFactor, heightFactor).clamp(0.5, 2.0);
```

### 제약 조건 적용 과정

1. **기본 크기 결정**: TextType별 기준 크기
2. **스케일링 적용**: 컨테이너 크기 비율 계산
3. **조정 팩터 적용**: 텍스트 길이, 폰트 두께 등
4. **제약 조건 확인**: 최소/최대 크기 범위 적용
5. **최종 크기 반환**: 모든 조건을 만족하는 크기

### 반응형 조정 로직

```
화면 너비 < 350px → 0.9배
화면 너비 350-500px → 1.0배
화면 너비 > 500px → 1.1배

화면 비율 < 0.5 (세로로 긴) → 추가 0.95배
화면 비율 > 2.0 (가로로 긴) → 추가 1.05배
```

## ⚡ 성능 최적화

### 계산 캐싱
```dart
// 자주 사용되는 크기는 캐싱
class CachedAdaptiveText extends StatefulWidget {
  @override
  _CachedAdaptiveTextState createState() => _CachedAdaptiveTextState();
}

class _CachedAdaptiveTextState extends State<CachedAdaptiveText> {
  late final double _cachedSize;
  
  @override
  void initState() {
    super.initState();
    // 한 번만 계산
    _cachedSize = AdaptiveTextSize.calculate(
      containerSize: widget.containerSize,
      textType: widget.textType,
    );
  }
}
```

### 조건부 재계산
```dart
// 필요할 때만 재계산
@override
void didUpdateWidget(AdaptiveText oldWidget) {
  super.didUpdateWidget(oldWidget);
  
  if (oldWidget.containerSize != widget.containerSize ||
      oldWidget.textType != widget.textType) {
    // 크기나 타입이 변경된 경우에만 재계산
    setState(() {
      _recalculateSize();
    });
  }
}
```

### 배치 처리
```dart
// 여러 텍스트를 한 번에 계산
final sizes = <String, double>{};

for (final option in voteOptions) {
  sizes[option.id] = AdaptiveTextSize.forText(
    text: option.text,
    containerSize: boxSize,
    textType: TextType.body,
  );
}
```

## 🔗 관련 파일

### 의존성
- `/lib/components/notifications/constants/voting_notification_constraints.dart` - 텍스트 크기 제약
- `flutter/material.dart` - Flutter UI 프레임워크
- `dart:math` - 수학 함수

### 사용처
- `/lib/components/notifications/widgets/voting_notification_dialog.dart` - 투표 알림 다이얼로그
- `/lib/components/notifications/widgets/versus_notification_box.dart` - A/B 옵션 박스
- `/lib/components/chat/vote_card_message.dart` - 채팅 투표 카드

### 연관 모듈
- `/lib/components/notifications/constants/` - 크기 제약 조건
- `/lib/components/notifications/models/` - 데이터 모델
- `/lib/design_system/` - 디자인 시스템

## 📊 아키텍처

```
AdaptiveTextSize
├── 계산 메서드
│   ├── calculate() - 종합 계산
│   ├── fromHeight() - 높이 기반
│   ├── fromWidth() - 너비 기반
│   ├── forText() - 텍스트 길이 고려
│   ├── responsive() - 반응형
│   └── forMultilineText() - 멀티라인
├── 내부 헬퍼
│   ├── _getBaseSizeForType() - 기본 크기
│   ├── _calculateScaleFactor() - 스케일링
│   └── _applyConstraints() - 제약 적용
└── 관련 클래스
    ├── TextType - 텍스트 유형
    ├── AdaptiveText - 위젯
    └── AdaptiveTextStyle - 스타일 헬퍼
```

## 🐛 문제 해결

### 텍스트가 너무 작게 표시될 때
```dart
// 문제: 큰 컨테이너에서도 텍스트가 작음
// 해결: TextType을 title로 변경하거나 최소 크기 조정
AdaptiveText(
  text,
  containerSize: largeSize,
  textType: TextType.title,  // body → title
  maxLines: 1,  // 라인 수 줄이기
)
```

### 긴 텍스트가 잘릴 때
```dart
// 문제: 텍스트가 컨테이너를 벗어남
// 해결: maxLines 증가 또는 overflow 설정
AdaptiveText(
  longText,
  containerSize: boxSize,
  maxLines: 3,  // 2 → 3
  overflow: TextOverflow.ellipsis,  // 말줄임표
)
```

### 반응형이 작동하지 않을 때
```dart
// 문제: 화면 크기 변경 시 텍스트 크기 불변
// 해결: responsive 플래그와 context 전달
AdaptiveText(
  text,
  containerSize: boxSize,
  responsive: true,  // 반응형 활성화
  // BuildContext는 자동으로 사용됨
)
```

### 폰트 두께로 인한 오버플로우
```dart
// 문제: Bold 폰트에서 텍스트 오버플로우
// 해결: forText 메서드 사용 (폰트 두께 고려)
final size = AdaptiveTextSize.forText(
  text: text,
  containerSize: boxSize,
  fontWeight: FontWeight.bold,  // 두께 전달
  textType: TextType.body,
);
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 작성 및 코드 분석 완료
- **2025-08-05**: AdaptiveTextSize 유틸리티 클래스 생성
  - 다양한 계산 메서드 구현
  - TextType enum 추가
  - AdaptiveText 위젯 구현
  - AdaptiveTextStyle 헬퍼 추가
- **2025-08-03**: 초기 디렉토리 생성
  - 알림 시스템 유틸리티 분리

---

*이 문서는 `/lib/components/notifications/utils` 디렉토리의 적응형 텍스트 유틸리티를 설명합니다.*