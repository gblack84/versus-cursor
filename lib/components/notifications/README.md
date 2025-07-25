# 투표 알림 사이즈 바인딩 시스템

질문 작성 페이지와 투표 알림 간 일관된 크기 바인딩을 제공하는 시스템입니다.

## 🎯 핵심 기능

### 1. 사이즈 데이터 캡처
질문 작성 페이지에서 생성된 A/B 박스의 크기 정보를 캡처하여 저장합니다.

### 2. 스마트 레이아웃 변환
투표 알림에 적합하도록 레이아웃을 자동 변환합니다:
- 세로 배치 → 가로 배치 (공간 절약)
- 단일 이미지 → A + 빈 B박스
- 화면 크기별 최적화
- **박스 크기 통일**: 가로/세로 배치 시 평균 크기 사용으로 일관성 확보

### 3. 적응형 크기 조정
다양한 화면 크기에서 일관된 사용자 경험을 제공합니다:
- 큰 화면 (>400px): 90% 스케일링
- 중간 화면 (350-400px): 80% 스케일링  
- 작은 화면 (<350px): 70% 스케일링

### 4. 멀티이미지 지원 (v1.1.0 추가, v1.2.0 개선)
- 각 박스에 여러 개의 이미지 표시 가능
- PageView를 통한 이미지 탐색 (위아래 스와이프)
- 이미지 뷰어로 전체화면 보기 지원
- **v1.2.0 개선사항**:
  - 단일 이미지 모드 지원 (B박스가 텍스트만 있을 때)
  - 단일 모드에서 A/B 타이틀 모두 표시
  - 좌우 스와이프 자동 비활성화
  - 멀티이미지 카운트 정확도 개선

### 5. 향상된 UX (새로운 기능)
- **모달 다이얼로그 전환**: 검은색 반투명 배경으로 몰입도 향상
- **92% 화면 너비 사용**: 적절한 여백으로 가독성 개선
- **30초 자동 닫기 제거**: 사용자가 직접 선택할 때까지 대기
- **배경 터치 방지**: 실수로 닫히지 않도록 보호

## 📁 파일 구조

```
lib/components/notifications/
├── models/
│   └── versus_box_size_data.dart          # 사이즈 데이터 모델
├── services/
│   ├── versus_box_size_calculator.dart    # 크기 계산 서비스 (박스 크기 평균화 포함)
│   └── layout_synchronizer.dart           # 레이아웃 동기화
├── widgets/
│   ├── versus_notification_box.dart       # 투표 박스 컴포넌트
│   └── notification_image_viewer.dart     # 멀티이미지 뷰어 (새로운 파일)
├── constants/
│   └── voting_notification_constraints.dart # 크기 제약 조건
├── utils/
│   └── adaptive_text_size.dart            # 적응형 텍스트 크기
├── examples/
│   └── voting_system_example.dart         # 사용 예제
├── voting_notification_dialog.dart        # 투표 알림 다이얼로그 (모달 UI 업데이트)
├── notification_overlay.dart              # 알림 오버레이 (showDialog 사용)
└── README.md                              # 이 문서
```

## 🚀 사용법

### 1. 기본 사용법

```dart
// 1. 질문 작성 페이지에서 사이즈 데이터 캡처
final sizeData = VersusBoxSizeCalculator.captureCurrentSizes(
  context,
  appState,
  model,
);

// 2. 투표 알림 표시 (사이즈 데이터 포함)
NotificationOverlay.showVoting(
  context,
  question: '어떤 옵션이 더 좋나요?',
  optionA: '옵션 A',
  optionB: '옵션 B',
  imageUrlA: 'https://example.com/image_a.jpg',
  imageUrlB: 'https://example.com/image_b.jpg',
  sizeData: sizeData, // 👈 캡처된 사이즈 데이터
  onVote: (option) {
    print('투표: $option');
  },
);
```

### 1-1. 멀티이미지 사용법 (새로운 기능)

```dart
// 멀티이미지 투표 알림 표시
NotificationOverlay.showVoting(
  context,
  question: '어떤 스타일이 더 좋나요?',
  optionA: '스타일 A',
  optionB: '스타일 B',
  imageUrlsA: [ // 👈 멀티이미지 A
    'https://example.com/style_a_1.jpg',
    'https://example.com/style_a_2.jpg',
    'https://example.com/style_a_3.jpg',
  ],
  imageUrlsB: [ // 👈 멀티이미지 B
    'https://example.com/style_b_1.jpg',
    'https://example.com/style_b_2.jpg',
  ],
  sizeData: sizeData,
  onVote: (option) {
    print('투표: $option');
  },
);
```

### 2. 투표 결과 표시

```dart
NotificationOverlay.showVoting(
  context,
  question: '투표 결과',
  optionA: '옵션 A',
  optionB: '옵션 B',
  sizeData: sizeData,
  showResults: true,
  votePercentageA: 0.65,
  votePercentageB: 0.35,
  voteCountA: 13,
  voteCountB: 7,
  onVote: (_) {}, // 결과 모드에서는 투표 불가
);
```

### 3. 커스텀 레이아웃

```dart
Widget customVotingLayout = VersusNotificationBoxBuilder.buildBoxPair(
  context: context,
  sizeData: sizeData,
  titleA: '옵션 A',
  titleB: '옵션 B',
  imageUrlA: imageUrlA,
  imageUrlB: imageUrlB,
  onTapA: () => vote('A'),
  onTapB: () => vote('B'),
);
```

## 🔧 고급 설정

### 디버그 모드

```dart
NotificationOverlay.showVoting(
  context,
  // ... 기본 파라미터들
  showDebugInfo: true, // 박스 크기 정보 표시
);
```

### 커스텀 애니메이션

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
  }

  Widget build(BuildContext context) {
    return VersusNotificationBox(
      boxType: 'A',
      boxSize: Size(150, 150),
      title: '옵션 A',
      animationController: _animationController,
    );
  }
}
```

## 📊 성능 최적화

### 1. 이미지 캐싱
- `CachedNetworkImage` 사용
- 동적 메모리 캐시 크기 계산
- Progressive loading 지원

### 2. 크기 계산 최적화
- 한 번 계산된 크기는 재사용
- 화면 회전 시 자동 재계산
- 불필요한 리빌드 방지

### 3. 레이아웃 최적화
- 컨테이너 크기 기반 적응형 텍스트
- 화면 크기별 스케일링
- 메모리 효율적인 위젯 구조

## 🎨 커스터마이징

### 1. 색상 및 스타일

```dart
// voting_notification_constraints.dart에서 수정
static const double cardBorderRadius = 20.0;
static const double boxBorderRadius = 16.0;
static const Color primaryColor = Color(0xFF6366F1);
```

### 2. 애니메이션

```dart
// 슬라이드 애니메이션 지속시간
static const Duration slideAnimationDuration = Duration(milliseconds: 500);

// 자동 사라짐 시간
static const Duration autoHideDuration = Duration(seconds: 30);
```

### 3. 크기 제약 조건

```dart
// 박스 크기 제한
static const double maxBoxHeight = 160.0;
static const double minBoxHeight = 80.0;

// 텍스트 크기 제한 (v1.2.0에서 조정됨)
static const double maxTextSize = 20.0;    // 16.0 → 20.0
static const double minTextSize = 10.0;    // 유지
static const double defaultTextSize = 14.0; // 12.0 → 18.0 → 14.0
```

## 🧪 테스트

### 단위 테스트 예제

```dart
void main() {
  group('VersusBoxSizeCalculator', () {
    testWidgets('사이즈 데이터 캡처 테스트', (WidgetTester tester) async {
      // 테스트 위젯 빌드
      await tester.pumpWidget(MyTestWidget());
      
      // 사이즈 데이터 캡처
      final sizeData = VersusBoxSizeCalculator.captureCurrentSizes(
        tester.element(find.byType(MyTestWidget)),
        mockAppState,
        mockModel,
      );
      
      // 검증
      expect(sizeData, isNotNull);
      expect(sizeData!.layoutType, LayoutType.horizontal);
    });
  });
}
```

### 통합 테스트

```dart
import 'examples/voting_system_example.dart';

void main() {
  testWidgets('전체 투표 플로우 테스트', (WidgetTester tester) async {
    await tester.pumpWidget(CompleteVotingFlowExample());
    
    // 1. 사이즈 데이터 캡처
    await tester.tap(find.text('사이즈 데이터 캡처'));
    await tester.pump();
    
    // 2. 투표 알림 표시
    await tester.tap(find.text('사이즈 바인딩 투표'));
    await tester.pump();
    
    // 3. 투표 실행
    await tester.tap(find.text('A 선택'));
    await tester.pump();
    
    // 검증
    expect(find.text('투표 완료!'), findsOneWidget);
  });
}
```

## 🐛 트러블슈팅

### 자주 발생하는 문제들

#### 1. 사이즈 데이터가 null로 반환됨
```dart
// 원인: 이미지가 업로드되지 않았거나 AppState가 초기화되지 않음
// 해결: 이미지 업로드 상태 확인
if (appState.uploadImageA.isEmpty && appState.uploadImageB.isEmpty) {
  print('이미지가 없습니다');
}
```

#### 2. 투표 박스 크기가 너무 작음
```dart
// 원인: 화면 크기가 매우 작거나 스케일링 팩터 과도
// 해결: 최소 크기 제약 조건 확인
final constrainedSize = VotingNotificationConstraints.constrainBoxSize(size, 1.0);
```

#### 3. 레이아웃이 예상과 다름
```dart
// 원인: 레이아웃 변환 규칙 적용됨 (세로→가로 등)
// 해결: 디버그 모드로 변환 과정 확인
VotingSystemExample.showDebugVoting(context);
```

#### 4. 텍스트가 잘림
```dart
// 원인: 적응형 텍스트 크기가 너무 작게 계산됨
// 해결: 커스텀 텍스트 크기 지정
VersusNotificationBox(
  customTextSize: 14.0, // 고정 크기 사용
  // ...
)
```

#### 5. 단일 이미지 모드에서 멀티이미지가 표시되지 않음 (v1.2.0)
```dart
// 원인: B박스 타이틀이 비어있어 단일 모드로 잘못 인식됨
// 해결: NotificationImageViewer.show 호출 시 올바른 타이틀 전달 확인
optionA: boxType == 'A' ? title : (otherOptionTitle ?? ''),
optionB: boxType == 'A' ? (otherOptionTitle ?? '') : title,
```

### 디버그 도구

#### 1. 사이즈 정보 출력
```dart
print('사이즈 데이터: $sizeData');
print('투표용 크기: ${votingSizes.shortDescription}');
print('성능 정보: ${votingSizes.performanceInfo}');
```

#### 2. 레이아웃 변환 정보
```dart
LayoutSynchronizer.printConversionInfo(
  originalData: sizeData,
  targetConfig: votingLayout,
  containerWidth: containerWidth,
);
```

#### 3. 제약 조건 확인
```dart
VotingNotificationConstraints.printConstraints(screenWidth);
```

#### 4. 멀티이미지 디버그 (v1.2.0 추가)
```dart
// NotificationImageViewer 초기화 시 자동 출력되는 로그
// - 이미지 URL 개수
// - 타이틀 정보
// - 박스별 이미지 개수
// - 초기 인덱스 및 박스 타입
```

## 📈 성능 지표

### 목표 성능
- **응답 시간**: <100ms (크기 계산)
- **메모리 사용량**: <10MB 추가
- **토큰 절약**: 30-50% (압축 모드)
- **정확도**: 95%+ (크기 일관성)

### 모니터링 방법
```dart
// 성능 측정
final stopwatch = Stopwatch()..start();
final sizeData = VersusBoxSizeCalculator.captureCurrentSizes(context, appState, model);
stopwatch.stop();
print('캡처 시간: ${stopwatch.elapsedMilliseconds}ms');

// 메모리 사용량 확인 (개발 모드)
if (kDebugMode) {
  print('메모리 사용량: ${ProcessInfo.currentRss / 1024 / 1024:.1f}MB');
}
```

## 🔄 업그레이드 가이드

### v1.0 → v2.0 (호환성 유지)
기존 코드는 그대로 작동하며, 새로운 기능을 점진적으로 적용할 수 있습니다.

```dart
// 기존 방식 (계속 지원됨)
NotificationOverlay.show(context, title: '알림', message: '메시지', onTap: () {});

// 새로운 방식 (권장)
NotificationOverlay.showVoting(context, question: '질문', optionA: 'A', optionB: 'B', onVote: (option) {});
```

## 🤝 기여하기

### 개발 환경 설정
1. Flutter SDK 3.0.0+ 설치
2. 프로젝트 클론 및 의존성 설치
3. 예제 앱 실행하여 테스트

### 코드 스타일
- Dart 공식 스타일 가이드 준수
- 주석 및 문서화 필수
- 단위 테스트 작성

### 기여 방법
1. 이슈 생성 또는 기존 이슈 확인
2. 피처 브랜치 생성
3. 구현 및 테스트
4. Pull Request 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 🙏 감사의 글

- Flutter 팀의 훌륭한 프레임워크
- 커뮤니티의 피드백과 기여
- 사용자들의 소중한 의견

---

**버전**: 1.2.0  
**최종 업데이트**: 2025-07-25  
**작성자**: SuperClaude Framework
**변경사항**: 
- v1.1.0 (2025-07-23): 멀티이미지 지원, 박스 크기 평균화, 모달 UI 개선
- v1.2.0 (2025-07-25): 단일 이미지 모드 개선, 멀티이미지 뷰어 수정, 텍스트 크기 조정