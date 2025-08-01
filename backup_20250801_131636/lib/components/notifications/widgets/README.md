# 투표 알림 위젯 컴포넌트

투표 알림 시스템의 UI 컴포넌트들을 제공합니다.

## 📁 파일 구조

```
widgets/
├── versus_notification_box.dart       # A/B 투표 박스 컴포넌트
└── notification_image_viewer.dart     # 전체화면 이미지 뷰어 (v1.1.0 추가)
```

## 🎯 주요 컴포넌트

### 1. VersusNotificationBox

투표 알림의 A/B 박스를 표시하는 핵심 컴포넌트입니다.

#### 주요 기능
- 이미지/그라데이션 배경 지원
- 적응형 텍스트 크기
- 투표 결과 표시
- 애니메이션 효과
- 멀티이미지 지원 (v1.1.0)
- 이미지 탭으로 뷰어 열기 (v1.2.0)

#### 사용법
```dart
VersusNotificationBox(
  boxType: 'A',
  boxSize: Size(150, 200),
  title: '옵션 A',
  imageUrl: 'https://example.com/image.jpg',
  imageUrls: ['url1', 'url2', 'url3'], // 멀티이미지
  onTap: () => vote('A'),
  showResult: false,
  votePercentage: 0.65,
  voteCount: 13,
  enableImageTap: true, // 이미지 탭으로 뷰어 열기
)
```

#### 프로퍼티
| 이름 | 타입 | 설명 | 필수 |
|------|------|------|------|
| boxType | String | 'A' 또는 'B' | ✓ |
| boxSize | Size | 박스 크기 | ✓ |
| title | String | 박스 제목 | ✓ |
| imageUrl | String? | 단일 이미지 URL | |
| imageUrls | List<String>? | 멀티이미지 URL 리스트 | |
| onTap | VoidCallback? | 탭 콜백 | |
| showResult | bool | 투표 결과 표시 여부 | |
| votePercentage | double? | 투표 비율 (0.0~1.0) | |
| voteCount | int? | 투표 수 | |
| enableImageTap | bool | 이미지 탭 활성화 | |

### 2. NotificationImageViewer

투표 알림의 이미지를 전체화면으로 보여주는 뷰어입니다.

#### 주요 기능 (v1.2.0 개선)
- 멀티이미지 지원 (PageView)
- 2D 스와이프 네비게이션
  - 좌우: A/B 박스 전환 (듀얼 모드)
  - 상하: 멀티이미지 탐색
- 단일 이미지 모드 지원
  - B박스가 텍스트만 있을 때 자동 전환
  - 좌우 스와이프 비활성화
  - A/B 타이틀 모두 표시
- 이미지 확대/축소 (InteractiveViewer)
- 텍스트 확장/축소

#### 사용법
```dart
NotificationImageViewer.show(
  context,
  question: '어떤 스타일이 더 좋나요?',
  optionA: '스타일 A',
  optionB: '스타일 B',
  imageUrlsA: ['url1', 'url2', 'url3'],
  imageUrlsB: ['url4', 'url5'],
  descriptionA: 'A 설명',
  descriptionB: 'B 설명',
  initialIndex: 0, // 시작 이미지 인덱스
);
```

#### 네비게이션 동작
- **듀얼 모드** (A, B 모두 이미지 있음)
  - 좌우 스와이프: A ↔ B 전환
  - 상하 스와이프: 멀티이미지 탐색
  - 헤더: "A 2/3", "B 1/2" 형식

- **단일 모드** (A만 이미지, B는 텍스트)
  - 좌우 스와이프: 비활성화
  - 상하 스와이프: A의 멀티이미지 탐색
  - 헤더: "2/3" 형식 (박스 타입 생략)
  - 하단: A/B 타이틀 모두 표시

### 3. VersusNotificationBoxBuilder

사이즈 데이터를 기반으로 박스를 생성하는 헬퍼 클래스입니다.

#### buildFromSizeData
단일 박스를 생성합니다.
```dart
final box = VersusNotificationBoxBuilder.buildFromSizeData(
  context: context,
  sizeData: sizeData,
  boxType: 'A',
  title: '옵션 A',
  imageUrl: imageUrl,
);
```

#### buildBoxPair
A/B 박스 쌍을 자동 배치합니다.
```dart
final boxes = VersusNotificationBoxBuilder.buildBoxPair(
  context: context,
  sizeData: sizeData,
  titleA: '옵션 A',
  titleB: '옵션 B',
  imageUrlA: imageUrlA,
  imageUrlB: imageUrlB,
  imageUrlsA: multiImagesA, // 멀티이미지
  imageUrlsB: multiImagesB,
  onTapA: () => vote('A'),
  onTapB: () => vote('B'),
);
```

## 🎨 커스터마이징

### 커스텀 그라데이션
```dart
VersusNotificationBox(
  // ...
  gradientColors: [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ],
)
```

### 커스텀 텍스트 크기
```dart
VersusNotificationBox(
  // ...
  customTextSize: 16.0, // 자동 계산 대신 고정 크기
)
```

### 라벨 숨기기
```dart
VersusNotificationBox(
  // ...
  showLabel: false, // A/B 라벨 숨기기
)
```

## 🔧 고급 기능

### 멀티이미지 인디케이터
박스에 멀티이미지가 있을 때 자동으로 표시됩니다.
- 위치: 우측 상단
- 형식: 📷 3 (이미지 개수)

### 디버그 모드
```dart
VersusNotificationBox(
  // ...
  showDebugInfo: true, // 박스 크기 표시
)
```

### 단일 이미지 모드에서 듀얼 타이틀
B박스가 텍스트만 있을 때 A박스에 A/B 타이틀을 함께 표시합니다.
```dart
VersusNotificationBox(
  // ...
  isSingleImageMode: true,
  dualModeSecondTitle: '옵션 B',
)
```

## 📊 성능 최적화

### 이미지 캐싱
- CachedNetworkImage 사용
- memCacheWidth로 메모리 최적화
- fadeIn 애니메이션 (200ms)

### 안전한 크기 처리
```dart
// 최대 크기 제한 (1000px)
final safeWidth = boxSize.width.clamp(0.0, 1000.0);
final safeHeight = boxSize.height.clamp(0.0, 1000.0);
```

## 🐛 트러블슈팅

### 이미지가 로드되지 않을 때
- 네트워크 연결 확인
- 이미지 URL 유효성 검증
- 에러 위젯이 표시됨 (broken_image 아이콘)

### 멀티이미지가 표시되지 않을 때
- imageUrls 배열이 비어있지 않은지 확인
- 멀티이미지 인디케이터가 표시되는지 확인
- 디버그 로그 확인

### 단일 모드에서 스와이프가 작동하지 않을 때
- B박스의 이미지 URL이 null인지 확인
- effectiveUrlsB가 비어있는지 확인
- 상하 스와이프만 가능함을 인지

## 🔄 버전 히스토리

### v1.2.0 (2025-07-25)
- NotificationImageViewer 단일 이미지 모드 추가
- 타이틀 전달 로직 개선
- 텍스트 크기 조정
- 디버그 로그 추가

### v1.1.0 (2025-07-23)
- 멀티이미지 지원 추가
- NotificationImageViewer 컴포넌트 추가
- 이미지 탭으로 뷰어 열기 기능

### v1.0.0
- 초기 릴리즈
- VersusNotificationBox 기본 기능

---

**최종 업데이트**: 2025-07-25  
**작성자**: SuperClaude Framework