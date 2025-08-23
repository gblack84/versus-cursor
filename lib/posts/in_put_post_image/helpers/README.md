# 🛠️ In Put Post Image Helpers 디렉토리

> 이미지 처리, 레이아웃 계산, 입력 필드 관리를 위한 핵심 헬퍼 클래스 모음

## 📑 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [주요 구성요소](#주요-구성요소)
- [헬퍼 클래스 상세](#헬퍼-클래스-상세)
- [사용 예시](#사용-예시)
- [헬퍼 시스템 아키텍처](#헬퍼-시스템-아키텍처)
- [의존성](#의존성)
- [변경 이력](#변경-이력)

## 🎯 개요

이 디렉토리는 In Put Post Image 모듈의 핵심 비즈니스 로직을 담당하는 헬퍼 클래스들을 관리합니다. 이미지 비율 분석, 동적 레이아웃 계산, 캐싱 최적화, 입력 필드 관리 등 복잡한 로직을 캡슐화하여 재사용성과 유지보수성을 높입니다.

### 주요 목적
- **스마트 레이아웃**: 이미지 비율 기반 자동 레이아웃 결정
- **성능 최적화**: 이미지 캐싱 및 프리로딩 전략
- **코드 재사용**: 공통 로직의 중앙 집중식 관리
- **관심사 분리**: UI와 비즈니스 로직 분리

## 📐 네이밍 컨벤션

프로젝트 전체 네이밍 규칙을 따릅니다:

- **파일명**: snake_case (Dart 표준)
  - ✅ `aspect_ratio_analyzer.dart`
  - ✅ `image_cache_helper.dart`
  - ❌ `AspectRatioAnalyzer.dart`

- **클래스명**: PascalCase
  - ✅ `AspectRatioAnalyzer`
  - ✅ `ImageCacheHelper`

- **메서드/변수명**: camelCase
  - ✅ `calculateMemCacheWidth`
  - ✅ `getOptimalLayout`

상세 내용: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. 헬퍼 클래스 구조
```
helpers/
├── aspect_ratio_analyzer.dart    # 이미지 비율 분석 및 레이아웃 결정
├── image_cache_helper.dart       # 캐싱 및 프리로딩 관리
├── input_field_builder.dart      # 입력 필드 생성 및 관리
├── media_box_callbacks.dart      # MediaSelectionBox 콜백 처리
└── ratio_calculator.dart         # 비율 계산 유틸리티
```

### 2. 기능별 분류

| 카테고리 | 클래스 | 주요 기능 | 사용 빈도 |
|---------|--------|---------|----------|
| **레이아웃** | AspectRatioAnalyzer | 최적 레이아웃 결정 | 높음 |
| **레이아웃** | RatioCalculator | 비율 계산 및 캐싱 | 높음 |
| **성능** | ImageCacheHelper | 캐싱 최적화 | 매우 높음 |
| **UI** | InputFieldBuilder | 입력 필드 생성 | 중간 |
| **이벤트** | MediaBoxCallbacks | 콜백 관리 | 높음 |

## 📋 헬퍼 클래스 상세

### AspectRatioAnalyzer
```dart
class AspectRatioAnalyzer {
  static const double landscapeThreshold = 1.2;  // 가로형 기준
  static const double portraitThreshold = 0.8;   // 세로형 기준
  
  static ImageOrientation getOrientation(double aspectRatio) {
    if (aspectRatio >= landscapeThreshold) {
      return ImageOrientation.landscape;
    } else if (aspectRatio <= portraitThreshold) {
      return ImageOrientation.portrait;
    } else {
      return ImageOrientation.square;
    }
  }
  
  static LayoutType getOptimalLayout(double? ratioA, double? ratioB) {
    // 스마트 레이아웃 결정 로직
    // 가로형 + 가로형 → 세로 배치
    // 세로형 + 세로형 → 가로 배치
    // 혼합형 → 극단적 비율 우선
  }
}
```

**레이아웃 결정 매트릭스:**
| A 타입 | B 타입 | 결과 레이아웃 |
|--------|--------|--------------|
| 가로형 | 가로형 | 세로 배치 (상/하) |
| 세로형 | 세로형 | 가로 배치 (좌/우) |
| 가로형 | 세로형 | 비율 극단성 판단 |
| 정사각형 | 모든 타입 | 상대 타입 기준 |

### ImageCacheHelper
```dart
class ImageCacheHelper {
  static const int kMaxMemCacheWidth = 800;
  static const int kMinMemCacheWidth = 200;
  static const int kMaxPreloadCount = 3;
  
  static int calculateMemCacheWidth(BuildContext context, double displayWidth) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (displayWidth * pixelRatio).round();
    return targetWidth.clamp(kMinMemCacheWidth, kMaxMemCacheWidth);
  }
  
  static Future<void> preloadAdjacentImages(
    BuildContext context,
    List<String> imageUrls,
    int currentIndex,
  ) async {
    // 현재 인덱스 ±1, ±2 이미지 프리로드
  }
}
```

**캐싱 전략:**
- **메모리 캐시**: 200-800px 동적 크기
- **프리로드**: 최대 3개 이미지
- **인접 프리로드**: 현재 ±2 범위
- **캐시 정리**: 메모리 부족 시 자동

### InputFieldBuilder
```dart
class InputFieldBuilder {
  static Widget buildTitleField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required InPutPostImageModel model,
    required Function() onRequiredFieldsCheck,
  }) {
    return SimpleValidatedField(
      fieldName: FieldStyles.questionTitle,
      maxLength: 100,
      validationResult: model.validationResults[FieldStyles.questionTitle],
      // ... 기타 설정
    );
  }
  
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required String hintKey,
    required String labelKey,
  }) {
    // 통일된 InputDecoration 생성
  }
}
```

**지원 필드 타입:**
- Title Field (제목, 100자)
- Description Field (설명, 2000자)
- Question Title (질문, 60자)
- Custom Fields (커스터마이징 가능)

### MediaBoxCallbacks
```dart
class MediaBoxCallbacks {
  final BuildContext context;
  final InPutPostImageModel model;
  final VoidCallback showBBoxWarning;
  final Function openAssetsPicker;
  
  void toggleBoxVisibility() {
    model.absellected = false;
    updateLayout();
  }
  
  void deleteImage(String box, int index) {
    if (box == 'A') {
      _deleteFromA(index);
    } else {
      _deleteFromB(index);
    }
    updateLayout();
  }
}
```

**콜백 타입:**
- **토글**: B박스 표시/숨김
- **추가**: 이미지 추가 처리
- **삭제**: 인덱스 기반 삭제
- **업데이트**: 현재 인덱스 변경

### RatioCalculator
```dart
class RatioCalculator {
  // 캐싱 변수
  static List<double>? _lastRatiosA;
  static double? _lastResultA;
  
  static double calculateRepresentativeRatio(List<double> ratios) {
    if (ratios.isEmpty) return 1.0;
    if (ratios.length == 1) return ratios.first;
    
    final minRatio = ratios.reduce(math.min);
    final maxRatio = ratios.reduce(math.max);
    final difference = maxRatio - minRatio;
    
    // 극단적 차이 → 최소 비율 사용
    if (difference > 0.5) return minRatio;
    
    // 비슷한 비율 → 평균 사용
    return ratios.reduce((a, b) => a + b) / ratios.length;
  }
}
```

**계산 방식:**
- **단일 이미지**: 원본 비율 그대로
- **다중 이미지 (차이 > 0.5)**: 가장 세로 이미지 기준
- **다중 이미지 (차이 ≤ 0.5)**: 평균 비율
- **캐싱**: 박스별 마지막 계산값 저장

## 💻 사용 예시

### 스마트 레이아웃 시스템 구현
```dart
// 1. 이미지 비율 계산
final ratiosA = appState.uploadImageAspectRatioA;
final ratiosB = appState.uploadImageAspectRatioB;

// 2. 대표 비율 계산
final representativeRatioA = RatioCalculator.getRatio(ratiosA, box: 'A');
final representativeRatioB = RatioCalculator.getRatio(ratiosB, box: 'B');

// 3. 최적 레이아웃 결정
final layoutType = AspectRatioAnalyzer.getOptimalLayout(
  representativeRatioA,
  representativeRatioB,
);

// 4. UI 업데이트
setState(() {
  model.isHorizontal = layoutType == LayoutType.horizontal;
});
```

### 이미지 캐싱 최적화
```dart
// PageView에서 이미지 표시
CachedNetworkImage(
  imageUrl: imageUrls[index],
  memCacheWidth: ImageCacheHelper.calculateMemCacheWidth(
    context, 
    MediaQuery.of(context).size.width,
  ),
  placeholder: (context, url) => Container(
    color: Colors.grey[200],
  ),
);

// PageView 스와이프 시 프리로드
onPageChanged: (index) {
  ImageCacheHelper.preloadAdjacentImages(
    context,
    imageUrls,
    index,
  );
}
```

### 입력 필드 생성
```dart
// 일관된 스타일의 입력 필드 생성
InputFieldBuilder.buildFieldContainer(
  child: InputFieldBuilder.buildTitleField(
    context: context,
    controller: _titleController,
    focusNode: _titleFocusNode,
    model: model,
    onRequiredFieldsCheck: _checkRequiredFields,
  ),
  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
);
```

### 콜백 관리
```dart
// MediaBoxCallbacks 초기화
final callbacks = MediaBoxCallbacks(
  context: context,
  model: model,
  showBBoxWarning: _showBBoxWarning,
  openAssetsPicker: _openAssetsPicker,
  showSnackBar: _showSnackBar,
  updateLayout: _updateLayout,
  setState: setState,
);

// MediaSelectionBox에서 사용
MediaSelectionBoxSingle(
  onTap: () => callbacks.openAssetsPicker(context, 'A'),
  onDelete: () => callbacks.deleteImage('A', 0),
  onCancel: callbacks.toggleBoxVisibility,
);
```

## 🏗️ 헬퍼 시스템 아키텍처

### 데이터 플로우
```
사용자 입력 (이미지 선택)
        ↓
  RatioCalculator
  (비율 계산 및 캐싱)
        ↓
  AspectRatioAnalyzer
  (레이아웃 결정)
        ↓
  ImageCacheHelper
  (캐싱 최적화)
        ↓
  MediaBoxCallbacks
  (UI 업데이트)
```

### 계층 구조
```
UI Layer (Widgets)
    ↓ 사용
Helper Layer (이 디렉토리)
    ↓ 의존
Service Layer (../services)
    ↓ 의존
Model Layer (../models)
```

### 성능 최적화 전략
1. **캐싱**: 계산 결과 재사용
2. **프리로딩**: 예상 이미지 미리 로드
3. **동적 크기**: 디바이스별 최적화
4. **배치 처리**: 여러 작업 동시 수행

## 📦 의존성

### 외부 패키지
```yaml
dependencies:
  flutter/material.dart
  cached_network_image: ^3.4.1
  provider: ^6.1.2
  google_fonts: ^6.2.1
```

### 내부 의존성
- `/app_state.dart` (전역 상태)
- `/core/app_theme.dart` (테마)
- `/core/app_localizations.dart` (다국어)
- `/services/perspective_api_service.dart` (검증)
- `../in_put_post_image_model.dart` (모델)
- `../constants/field_styles.dart` (스타일)
- `../components/simple_validated_field.dart` (컴포넌트)
- `../utils/debug_helper.dart` (디버깅)

## 🔄 변경 이력

### 2025-08-23
- 문서 전체 재작성
- 5개 헬퍼 클래스 상세 문서화
- 사용 예시 및 아키텍처 추가

### 주요 개발 이력
- **스마트 레이아웃 시스템 구현** (2025-07-07)
  - AspectRatioAnalyzer 클래스 생성
  - 이미지 비율 기반 자동 레이아웃
  
- **캐싱 시스템 최적화** (2025-07-08)
  - ImageCacheHelper 개선
  - 동적 캐시 크기 계산
  - 프리로딩 전략 구현

- **입력 필드 통합** (2025-07-14)
  - InputFieldBuilder 생성
  - 중복 코드 제거
  - 일관된 스타일 적용

## 📝 주요 규칙 및 가이드라인

### 헬퍼 추가 규칙
1. **단일 책임**: 하나의 명확한 목적
2. **정적 메서드**: 상태 없는 유틸리티 함수
3. **에러 처리**: 안전한 기본값 반환
4. **문서화**: 모든 public 메서드 문서화

### 성능 가이드라인
- **캐싱 활용**: 반복 계산 결과 저장
- **지연 로딩**: 필요시에만 계산
- **메모리 관리**: 캐시 크기 제한
- **배치 처리**: Future.wait 활용

### 테스트 체크리스트
- [ ] 비율 계산 정확성
- [ ] 레이아웃 결정 로직
- [ ] 캐시 크기 적절성
- [ ] 프리로드 동작
- [ ] 에러 상황 처리

## 🚀 향후 개선 사항

### 계획된 개선
- [ ] AI 기반 레이아웃 결정
- [ ] 적응형 캐싱 전략
- [ ] 비동기 비율 계산 최적화
- [ ] 입력 필드 애니메이션

### 성능 최적화
- [ ] 이미지 디코딩 병렬 처리
- [ ] 캐시 히트율 모니터링
- [ ] 메모리 사용량 프로파일링

### 기능 확장
- [ ] 비디오 비율 계산 지원
- [ ] 다양한 레이아웃 템플릿
- [ ] 커스텀 입력 필드 타입