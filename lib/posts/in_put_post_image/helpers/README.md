# Helpers Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 특정 기능을 수행하는 헬퍼 클래스들을 포함합니다. 주로 계산, 분석, 데이터 변환 등의 유틸리티 기능을 제공합니다.

## 파일 설명 (File Descriptions)

### aspect_ratio_analyzer.dart
- **역할**: 이미지 비율을 분석하고 최적의 레이아웃을 결정
- **주요 기능**:
  - 이미지 비율 계산 (너비/높이)
  - 가로형/세로형 이미지 분류
  - 최적 레이아웃 추천
- **레이아웃 결정 로직**:
  ```dart
  // 가로형 이미지들 → 세로 배치 (위/아래)
  // 세로형 이미지들 → 가로 배치 (좌/우)
  // 혼합형 → 더 극단적인 비율 우선
  ```
- **임계값**:
  - 가로형: 비율 > 1.2
  - 정사각형: 0.8 ≤ 비율 ≤ 1.2
  - 세로형: 비율 < 0.8

### dynamic_box_calculator.dart
- **역할**: 이미지 비율에 따른 동적 박스 크기 계산
- **주요 기능**:
  - 화면 크기 기반 계산
  - 패딩과 간격 고려
  - A/B 박스 크기 최적화
- **계산 로직**:
  - 가로 레이아웃: 균등 분할 (50:50)
  - 세로 레이아웃: 
    - 같은 타입: 균등 분할
    - 다른 타입: 가로형 40%, 세로형 60%
- **제약 조건**:
  - 최소 높이: 150px
  - 최대 높이: 화면의 70%

### image_cache_helper.dart
- **역할**: 이미지 캐싱 최적화 및 프리로딩
- **주요 기능**:
  - 메모리 캐시 크기 계산
  - 이미지 프리로딩
  - 인접 이미지 프리로딩 (PageView용)
- **캐시 전략**:
  ```dart
  // 박스 크기에 따른 캐시 크기
  // 가로형 선택: 380px
  // 가로형 미선택: 190px
  // 세로형 선택: 350px
  // 세로형 미선택: 250px
  ```
- **프리로딩 전략**:
  - 초기: 첫 2개 이미지
  - 스와이프: 현재 ±1 이미지

### input_field_builder.dart
- **역할**: 텍스트 입력 필드 생성 헬퍼
- **주요 기능**:
  - 일관된 스타일 적용
  - 유효성 검사 통합
  - 글자수 카운터 연결
- **지원 필드**:
  - Description (여러 줄)
  - A/B Title (한 줄)
  - 커스텀 필드

### media_box_callbacks.dart
- **역할**: MediaSelectionBox 콜백 관리 헬퍼
- **주요 기능**:
  - 이미지 선택 콜백
  - 편집 콜백
  - 삭제 콜백
  - B박스 토글 콜백
- **사용 목적**:
  - 콜백 로직 중앙화
  - 코드 중복 제거
  - 일관된 동작 보장

### ratio_calculator.dart
- **역할**: 이미지 비율 계산 유틸리티
- **주요 기능**:
  - File 객체에서 이미지 크기 추출
  - 비율 계산 (너비/높이)
  - 비동기 처리
- **에러 처리**:
  - 이미지 디코딩 실패 시 1.0 반환
  - null 안전성 보장

## 헬퍼 간 상호작용

### 스마트 레이아웃 시스템
```
이미지 선택
    ↓
RatioCalculator: 비율 계산
    ↓
AspectRatioAnalyzer: 레이아웃 결정
    ↓
DynamicBoxCalculator: 박스 크기 계산
    ↓
UI 업데이트
```

### 이미지 최적화 플로우
```
ImageCacheHelper: 캐시 크기 결정
    ↓
CachedNetworkImage: memCacheWidth 적용
    ↓
메모리 사용량 최적화
```

## 사용 예시

### 스마트 레이아웃 적용
```dart
// 1. 비율 분석
final analyzer = AspectRatioAnalyzer();
final layoutType = analyzer.determineOptimalLayout(
  aspectRatiosA: [1.5, 1.6],  // 가로형 이미지들
  aspectRatiosB: [0.7, 0.6],  // 세로형 이미지들
);

// 2. 박스 크기 계산
final calculator = DynamicBoxCalculator();
final boxSizes = calculator.calculateBoxSizes(
  screenSize: MediaQuery.of(context).size,
  isVertical: layoutType == LayoutType.vertical,
  aspectRatiosA: aspectRatiosA,
  aspectRatiosB: aspectRatiosB,
);

// 3. UI에 적용
MediaSelectionBox(
  dynamicHeight: boxSizes.boxA.height,
  dynamicWidth: boxSizes.boxA.width,
  // ...
)
```

### 이미지 프리로딩
```dart
// PageView 스와이프 시
ImageCacheHelper.preloadAdjacentImages(
  context,
  imageUrls,
  currentIndex,
  memCacheWidth: 380,
);
```

## 성능 고려사항

### 메모리 최적화
- 동적 캐시 크기로 메모리 사용량 최소화
- 불필요한 고해상도 이미지 로딩 방지
- 프리로딩은 인접 이미지만

### 계산 최적화
- 레이아웃 계산은 이미지 변경 시에만
- 캐시된 비율 값 재사용
- 불필요한 재계산 방지

## 디버깅 팁

### 레이아웃 문제
```dart
// LayoutDebugInfo 컴포넌트 활용
// AspectRatioAnalyzer의 로그 확인
DebugHelper.logLayout('Layout decision: $layoutType');
```

### 캐시 문제
```dart
// ImageCacheHelper의 캐시 크기 로그
print('Cache width for box: $cacheWidth');
```

## 향후 개선 사항

1. **AI 기반 레이아웃**:
   - 이미지 내용 분석
   - 더 스마트한 배치 결정

2. **적응형 캐싱**:
   - 디바이스 성능에 따른 캐시 조정
   - 네트워크 상태 고려

3. **애니메이션 헬퍼**:
   - 레이아웃 전환 애니메이션
   - 부드러운 크기 변경