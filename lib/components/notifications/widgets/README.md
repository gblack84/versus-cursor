# Notification Widgets - 알림 UI 위젯 시스템

투표 알림 시스템의 UI 컴포넌트를 제공하는 위젯 라이브러리입니다.

## 📋 개요

이 디렉토리는 Versus Space 앱의 투표 알림 시스템에서 사용되는 재사용 가능한 UI 위젯들을 포함합니다. 질문 작성 시의 레이아웃과 동일한 비율로 알림을 표시하고, 풍부한 인터랙션을 제공하는 것이 목표입니다.

### 주요 특징
- **반응형 레이아웃**: 다양한 화면 크기에 최적화된 박스 크기 자동 조정
- **멀티이미지 지원**: 하나의 옵션에 여러 이미지 표시 및 탐색
- **2D 네비게이션**: 좌우(A/B 전환) + 상하(이미지 탐색) 스와이프
- **접근성 지원**: Semantics를 통한 스크린 리더 호환
- **성능 최적화**: 이미지 캐싱 및 메모리 관리
- **애니메이션**: 부드러운 전환 효과와 시각적 피드백

## 🎯 네이밍 컨벤션

### 파일명
- **Dart 파일**: snake_case (`notification_image_viewer.dart`)
- **위젯 파일**: 기능을 명확히 나타내는 이름 사용

### 코드 내 명명 규칙
- **클래스명**: PascalCase (`NotificationImageViewer`, `VersusNotificationBox`)
- **프로퍼티**: lowerCamelCase (`boxType`, `imageUrls`, `votePercentage`)
- **메서드**: lowerCamelCase (`buildBox`, `showImageViewer`)
- **상수**: lowerCamelCase 또는 SCREAMING_SNAKE_CASE (앱 전역 상수)
- **private 멤버**: underscore prefix (`_buildContent`, `_currentBoxType`)

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### NotificationImageViewer

**파일**: `notification_image_viewer.dart`  
**용도**: 투표 알림의 이미지를 전체화면으로 표시하는 모달 뷰어

#### 핵심 기능

| 기능 | 설명 | 구현 상태 |
|------|------|----------|
| **멀티이미지 지원** | PageView를 통한 여러 이미지 탐색 | ✅ 완료 |
| **2D 스와이프** | 좌우(A/B 전환) + 상하(이미지 탐색) | ✅ 완료 |
| **단일/듀얼 모드** | B박스 이미지 유무에 따른 자동 전환 | ✅ 완료 |
| **확대/축소** | InteractiveViewer를 통한 줌 기능 | ✅ 완료 |
| **텍스트 확장** | 긴 텍스트의 접기/펼치기 | ✅ 완료 |
| **스와이프 힌트** | 사용법 안내 애니메이션 | ✅ 완료 |

#### 주요 프로퍼티

```dart
class NotificationImageViewer extends StatefulWidget {
  final String question;           // 질문 텍스트
  final String optionA;            // A 옵션 제목
  final String optionB;            // B 옵션 제목
  final String? imageUrlA;         // A 단일 이미지 (레거시)
  final String? imageUrlB;         // B 단일 이미지 (레거시)
  final List<String>? imageUrlsA; // A 멀티이미지
  final List<String>? imageUrlsB; // B 멀티이미지
  final String? description;       // 설명 텍스트
  final int initialIndex;          // 시작 이미지 인덱스
}
```

#### 네비게이션 모드

##### 듀얼 모드 (A, B 모두 이미지 있음)
- **좌우 스와이프**: A ↔ B 박스 전환
- **상하 스와이프**: 각 박스 내 이미지 탐색
- **헤더 표시**: "A 2/3", "B 1/2" 형식
- **스와이프 힌트**: 4방향 아이콘 표시

##### 단일 모드 (A만 이미지, B는 텍스트)
- **좌우 스와이프**: 비활성화
- **상하 스와이프**: A의 이미지만 탐색
- **헤더 표시**: "2/3" (박스 타입 생략)
- **하단 정보**: A/B 타이틀 모두 표시
- **스와이프 힌트**: 상하 아이콘만 표시

#### 내부 구현 상세

```dart
// 박스별 독립적인 PageController
late PageController _pageControllerA;
late PageController _pageControllerB;

// 현재 상태 관리
String _currentBoxType = 'A';      // 현재 보고 있는 박스
int _currentIndexInBoxA = 0;       // A박스 내 현재 이미지
int _currentIndexInBoxB = 0;       // B박스 내 현재 이미지

// 텍스트 확장 상태
bool _isQuestionExpanded = false;
bool _isDescriptionExpanded = false;
```

### VersusNotificationBox

**파일**: `versus_notification_box.dart`  
**용도**: 투표 알림에서 A/B 옵션을 표시하는 박스 컴포넌트

#### 핵심 기능

| 기능 | 설명 | 구현 상태 |
|------|------|----------|
| **이미지 배경** | CachedNetworkImage 사용 | ✅ 완료 |
| **그라데이션 배경** | 이미지 없을 때 대체 | ✅ 완료 |
| **적응형 텍스트** | 박스 크기에 따른 자동 조정 | ✅ 완료 |
| **투표 결과** | 퍼센트 및 투표 수 표시 | ✅ 완료 |
| **선택 상태** | 시각적 피드백 제공 | ✅ 완료 |
| **멀티이미지 표시** | 카운트 인디케이터 | ✅ 완료 |
| **접근성** | Semantics 지원 | ✅ 완료 |

#### 주요 프로퍼티

```dart
class VersusNotificationBox extends StatelessWidget {
  // 필수 프로퍼티
  final String boxType;           // 'A' 또는 'B'
  final Size boxSize;             // 박스 크기
  final String title;              // 옵션 제목
  
  // 이미지 관련
  final String? imageUrl;          // 단일 이미지
  final List<String>? imageUrls;   // 멀티이미지
  final List<String>? otherImageUrls; // 다른 박스 이미지
  
  // 인터랙션
  final VoidCallback? onTap;       // 탭 핸들러
  final bool enableImageTap;       // 이미지 탭으로 뷰어 열기
  
  // 상태 표시
  final bool isSelected;           // 선택 상태
  final bool showResult;           // 결과 표시 여부
  final double? votePercentage;    // 투표 비율 (0.0~1.0)
  final int? voteCount;            // 투표 수
  
  // 커스터마이징
  final AnimationController? animationController;
  final List<Color>? gradientColors;
  final double? customTextSize;
  final bool showLabel;            // A/B 라벨 표시
  final bool showDebugInfo;        // 디버그 정보
  
  // 단일 이미지 모드
  final bool isSingleImageMode;
  final String? dualModeSecondTitle;
  
  // 이미지 뷰어용 데이터
  final String? question;
  final String? otherOptionTitle;
  final String? otherImageUrl;
  final String? description;
}
```

#### 레이아웃 구조

```
Container
├── BoxDecoration (테두리, 그림자)
└── Stack
    ├── Background (이미지 or 그라데이션)
    ├── ResultOverlay (투표 결과)
    ├── SelectionOverlay (선택 상태)
    ├── Content
    │   ├── Label (A/B)
    │   └── Title (하단 그라데이션)
    ├── MultiImageIndicator (📷 3)
    └── DebugInfo (크기 표시)
```

### VersusNotificationBoxBuilder

**용도**: VersusBoxSizeData를 받아 자동으로 박스를 생성하는 헬퍼 클래스

#### buildFromSizeData

단일 박스를 생성합니다.

```dart
static Widget buildFromSizeData({
  required BuildContext context,
  required VersusBoxSizeData sizeData,
  required String boxType,
  required String title,
  String? imageUrl,
  List<String>? imageUrls,
  // ... 기타 파라미터
})
```

#### buildBoxPair

A/B 박스 쌍을 레이아웃에 맞게 자동 배치합니다.

```dart
static Widget buildBoxPair({
  required BuildContext context,
  required VersusBoxSizeData sizeData,
  required String titleA,
  required String titleB,
  // ... 기타 파라미터
})
```

레이아웃 타입에 따른 배치:
- **horizontal**: Row로 좌우 배치 + FittedBox로 크기 조정
- **vertical**: Column으로 상하 배치
- **single**: A박스만 표시 (B 타이틀은 A박스에 포함)

## 💡 사용 예시

### 기본 사용법

```dart
// 단일 박스 생성
final box = VersusNotificationBox(
  boxType: 'A',
  boxSize: Size(150, 200),
  title: '모던한 스타일',
  imageUrl: 'https://example.com/modern.jpg',
  onTap: () => handleVote('A'),
  isSelected: false,
  showResult: false,
);
```

### 멀티이미지 지원

```dart
// 멀티이미지가 있는 박스
final multiImageBox = VersusNotificationBox(
  boxType: 'A',
  boxSize: Size(150, 200),
  title: '다양한 스타일',
  imageUrls: [
    'https://example.com/style1.jpg',
    'https://example.com/style2.jpg',
    'https://example.com/style3.jpg',
  ],
  enableImageTap: true,  // 탭하면 이미지 뷰어 열기
  question: '어떤 스타일이 더 좋나요?',
  otherOptionTitle: '클래식 스타일',
  otherImageUrls: [...],  // B박스 이미지들
);
```

### Builder를 통한 박스 쌍 생성

```dart
// VersusBoxSizeData를 활용한 자동 생성
final boxes = VersusNotificationBoxBuilder.buildBoxPair(
  context: context,
  sizeData: sizeData,  // 질문 작성 시 저장된 크기 데이터
  titleA: '옵션 A',
  titleB: '옵션 B',
  imageUrlsA: ['url1', 'url2'],
  imageUrlsB: ['url3', 'url4'],
  onTapA: () => vote('A'),
  onTapB: () => vote('B'),
  selectedBox: currentSelection,
  showResults: voteCompleted,
  votePercentageA: 0.65,
  votePercentageB: 0.35,
  voteCountA: 130,
  voteCountB: 70,
);
```

### 이미지 뷰어 직접 호출

```dart
// 프로그래매틱하게 이미지 뷰어 열기
NotificationImageViewer.show(
  context,
  question: '어떤 디자인이 더 좋나요?',
  optionA: '미니멀 디자인',
  optionB: '맥시멀 디자인',
  imageUrlsA: ['url1', 'url2', 'url3'],
  imageUrlsB: ['url4', 'url5'],
  description: '2025년 트렌드 디자인 비교',
  initialIndex: 2,  // 3번째 이미지부터 시작
);
```

### 투표 결과 표시

```dart
// 투표 완료 후 결과 표시
VersusNotificationBox(
  boxType: 'A',
  boxSize: Size(150, 200),
  title: '승리한 옵션',
  imageUrl: imageUrl,
  showResult: true,
  votePercentage: 0.72,  // 72%
  voteCount: 1440,        // 1,440표
  isSelected: userVotedForA,
);
```

## 🎨 커스터마이징

### 커스텀 그라데이션

```dart
VersusNotificationBox(
  // ... 기본 프로퍼티
  gradientColors: [
    Color(0xFF6366F1),  // 시작 색상
    Color(0xFF8B5CF6),  // 끝 색상
  ],
)
```

### 텍스트 크기 조정

```dart
VersusNotificationBox(
  // ... 기본 프로퍼티
  customTextSize: 18.0,  // 자동 계산 대신 고정 크기
)
```

### 애니메이션 적용

```dart
// AnimationController 생성
final animationController = AnimationController(
  duration: Duration(milliseconds: 300),
  vsync: this,
);

VersusNotificationBox(
  // ... 기본 프로퍼티
  animationController: animationController,
)

// 애니메이션 실행
animationController.forward();
```

### 단일 이미지 모드 (A만 이미지)

```dart
VersusNotificationBox(
  boxType: 'A',
  // ... 기본 프로퍼티
  isSingleImageMode: true,
  dualModeSecondTitle: '텍스트만 있는 B 옵션',
  // A박스 하단에 A/B 타이틀 모두 표시됨
)
```

## ⚡ 성능 최적화

### 이미지 캐싱 전략

```dart
// CachedNetworkImage 설정
CachedNetworkImage(
  imageUrl: imageUrl,
  width: safeWidth,
  height: safeHeight,
  fit: BoxFit.cover,
  alignment: Alignment.center,
  placeholder: (context, url) => _buildPlaceholder(),
  errorWidget: (context, url, error) => _buildErrorWidget(),
  memCacheWidth: UnifiedImageCacheService.calculateMemCacheWidth(safeWidth),
  fadeInDuration: const Duration(milliseconds: 200),
)
```

### 안전한 크기 처리

```dart
// 비정상적으로 큰 값 방지
const double maxSafeSize = 1000.0;
final safeWidth = boxSize.width.clamp(0.0, maxSafeSize);
final safeHeight = boxSize.height.clamp(0.0, maxSafeSize);
```

### 메모리 관리

```dart
// PageController dispose
@override
void dispose() {
  _pageControllerA.dispose();
  _pageControllerB.dispose();
  super.dispose();
}
```

### 위젯 재사용

```dart
// FittedBox로 자동 크기 조정
FittedBox(
  fit: BoxFit.scaleDown,  // 화면에 맞춰 축소
  child: Row(...)
)
```

## ♿ 접근성

### Semantics 지원

```dart
Semantics(
  button: true,
  label: '옵션 $boxType: $title',
  selected: isSelected,
  hint: showResult && votePercentage != null 
      ? '투표 결과: ${(votePercentage! * 100).toStringAsFixed(0)}%' 
      : '탭하여 선택',
  child: _buildBox(context),
)
```

### 스크린 리더 지원
- 모든 인터랙티브 요소에 label 제공
- 선택 상태와 결과를 음성으로 안내
- 탭 가능한 영역 명확히 표시

## 🧪 테스팅 가이드

### 위젯 테스트

```dart
testWidgets('VersusNotificationBox 렌더링 테스트', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VersusNotificationBox(
          boxType: 'A',
          boxSize: Size(150, 200),
          title: '테스트 옵션',
        ),
      ),
    ),
  );
  
  expect(find.text('테스트 옵션'), findsOneWidget);
  expect(find.text('A'), findsOneWidget);
});
```

### 인터랙션 테스트

```dart
testWidgets('박스 탭 테스트', (tester) async {
  bool tapped = false;
  
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: VersusNotificationBox(
          boxType: 'A',
          boxSize: Size(150, 200),
          title: '옵션',
          onTap: () => tapped = true,
        ),
      ),
    ),
  );
  
  await tester.tap(find.byType(VersusNotificationBox));
  expect(tapped, isTrue);
});
```

## 🐛 트러블슈팅

### 이미지가 로드되지 않을 때

**증상**: 깨진 이미지 아이콘 표시
**원인**: 
- 네트워크 연결 문제
- 잘못된 이미지 URL
- Firebase Storage 권한 문제

**해결**:
```dart
// 에러 위젯 커스터마이징
errorWidget: (context, url, error) {
  print('이미지 로드 실패: $url');
  print('에러: $error');
  return _buildErrorWidget();
}
```

### 멀티이미지가 표시되지 않을 때

**증상**: 멀티이미지 인디케이터가 보이지 않음
**원인**: imageUrls 배열이 비어있거나 null

**해결**:
```dart
// 디버그 로그 추가
print('imageUrls 개수: ${imageUrls?.length ?? 0}');
print('otherImageUrls 개수: ${otherImageUrls?.length ?? 0}');
```

### 스와이프가 작동하지 않을 때

**증상**: 이미지 뷰어에서 스와이프 무반응
**원인**: 
- 단일 모드에서 좌우 스와이프 시도
- GestureDetector 충돌

**해결**:
```dart
// 스와이프 속도 임계값 조정
if (details.primaryVelocity! < -300) {  // 왼쪽 스와이프
  // ... A → B 전환
}
```

### 텍스트가 잘릴 때

**증상**: 긴 제목이 "..."로 표시
**원인**: maxLines 제한

**해결**:
```dart
// maxLines 증가 또는 fontSize 감소
Text(
  title,
  maxLines: 3,  // 2 → 3으로 증가
  style: TextStyle(
    fontSize: _getAdaptiveTextSize() * 0.9,  // 크기 감소
  ),
)
```

## 🔗 관련 파일

### 의존성
- `/lib/design_system/` - 디자인 토큰과 스타일
- `/lib/services/unified_image_cache_service.dart` - 이미지 캐싱
- `/lib/shared/services/unified_box_calculator.dart` - 박스 크기 계산
- `/lib/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart` - 비율 분석
- `../models/versus_box_size_data.dart` - 크기 데이터 모델
- `../constants/voting_notification_constraints.dart` - 제약 조건

### 사용처
- `/lib/components/notifications/voting_notification_dialog.dart` - 알림 다이얼로그
- `/lib/services/notification_service.dart` - 알림 서비스
- `/lib/pages/home/home_page_widget.dart` - 홈 피드

## 📊 아키텍처

### 위젯 계층 구조

```
NotificationService
└── VotingNotificationDialog
    ├── VersusNotificationBoxBuilder
    │   ├── buildFromSizeData() → VersusNotificationBox
    │   └── buildBoxPair() → Row/Column
    │       ├── VersusNotificationBox (A)
    │       └── VersusNotificationBox (B)
    └── VersusNotificationBox.onTap()
        └── NotificationImageViewer.show()
            └── PageRouteBuilder → NotificationImageViewer
```

### 데이터 플로우

```
1. Firestore post 문서
   ↓ (boxSizeData, imageUrls)
2. NotificationService
   ↓ (showDialog)
3. VotingNotificationDialog
   ↓ (VersusBoxSizeData)
4. VersusNotificationBoxBuilder
   ↓ (Size 계산)
5. VersusNotificationBox
   ↓ (onTap)
6. NotificationImageViewer
```

## 📝 변경 이력

- **2025-08-22**: 문서 전체 재작성 및 코드 분석 완료
- **2025-07-25**: NotificationImageViewer 단일 모드 추가, 타이틀 로직 개선
- **2025-07-23**: 멀티이미지 지원 추가, 이미지 뷰어 컴포넌트 구현
- **2025-07-20**: VersusNotificationBox 초기 구현
- **2025-07-15**: 디렉토리 생성 및 기본 구조 설계

---

*이 문서는 `/lib/components/notifications/widgets` 디렉토리의 알림 UI 위젯을 설명합니다.*