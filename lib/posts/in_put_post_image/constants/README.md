# Constants Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 In Put Post Image 모듈에서 사용되는 모든 상수들을 중앙 집중식으로 관리합니다. 하드코딩된 값들을 제거하고 유지보수성을 높이기 위해 체계적으로 분리되어 있습니다.

## 파일 설명 (File Descriptions)

### constants.dart
- **역할**: 모든 상수 파일들을 export하는 배럴 파일
- **사용법**: `import 'constants/constants.dart'`로 모든 상수에 접근

### dimensions.dart
- **역할**: UI 치수 관련 상수
- **주요 상수**:
  - `kDefaultBoxHeight`: 기본 박스 높이 (350.0)
  - `kSelectedBoxHeight`: 선택된 박스 높이 (250.0)
  - `kBoxPadding`: 박스 패딩 값
  - `kBoxRadius`: 박스 모서리 반경 (20.0)
  - `kIconSize`: 아이콘 크기들
  - `kActionButtonSize`: 액션 버튼 크기 (45.0)

### image_constants.dart
- **역할**: 이미지 처리 관련 상수
- **주요 상수**:
  - `kMaxImageWidth`: 최대 이미지 너비 (800)
  - `kThumbnailSize`: 썸네일 크기 (150)
  - `kJpegQuality`: JPEG 압축 품질 (85)
  - `kMaxImageCount`: 최대 이미지 수 (4)
  - `kImageAspectRatioThreshold`: 가로/세로 판단 임계값

### animation_constants.dart
- **역할**: 애니메이션 관련 상수
- **주요 상수**:
  - `kShakeAnimationDuration`: 흔들림 시간 (200ms)
  - `kShakeAnimationExtent`: 흔들림 범위 (8.0)
  - `kFadeInDuration`: 페이드인 시간 (150ms)
  - `kPageTransitionDuration`: 페이지 전환 시간

### strings.dart
- **역할**: 문자열 상수 (에러 메시지, 라벨 등)
- **주요 상수**:
  - 에러 메시지
  - 버튼 텍스트
  - 플레이스홀더
  - 토스트 메시지
- **예시**:
  ```dart
  static const kErrorImageUpload = '이미지 업로드 실패';
  static const kErrorNetworkTimeout = '네트워크 연결 시간 초과';
  ```

### text_limits.dart
- **역할**: 텍스트 필드 제한 관련 상수
- **주요 상수**:
  - `kDescriptionMaxLength`: 설명 최대 길이 (200)
  - `kTitleMaxLength`: 제목 최대 길이 (20)
  - `kDescriptionMinLines`: 설명 최소 줄 수 (1)
  - `kDescriptionMaxLines`: 설명 최대 줄 수 (null - 무제한)

### colors.dart
- **역할**: 커스텀 색상 정의
- **주요 상수**:
  - `kErrorColor`: 에러 표시 색상
  - `kWarningBackgroundColor`: 경고 배경색
  - `kOverlayColor`: 오버레이 색상
  - `kActionButtonBackground`: 액션 버튼 배경색

### config.dart
- **역할**: 설정 및 환경 관련 상수
- **주요 상수**:
  - `kEnableDebugMode`: 디버그 모드 활성화
  - `kImageUploadTimeout`: 업로드 타임아웃 (30초)
  - `kModerationThreshold`: 검열 임계값 (0.7)
  - `kRetryAttempts`: 재시도 횟수 (3)

### target_audience_constants.dart
- **역할**: 타겟 오디언스 관련 상수 (현재 미사용)
- **내용**: 타겟 설정 관련 예약 상수

## 사용 예시

### 상수 import
```dart
import 'constants/constants.dart';

// 개별 import도 가능
import 'constants/dimensions.dart';
import 'constants/strings.dart';
```

### 상수 사용
```dart
// 치수 사용
Container(
  height: Dimensions.kDefaultBoxHeight,
  padding: EdgeInsets.all(Dimensions.kBoxPadding),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(Dimensions.kBoxRadius),
  ),
)

// 문자열 사용
showToast(Strings.kErrorImageUpload);

// 설정 사용
if (Config.kEnableDebugMode) {
  print('Debug info...');
}
```

## 명명 규칙

1. **접두사 규칙**:
   - `k`로 시작 (Dart 상수 관례)
   - 카멜케이스 사용
   - 예: `kMaxImageCount`

2. **그룹화**:
   - 관련 상수끼리 클래스로 그룹화
   - static const로 선언

3. **설명적 이름**:
   - 용도가 명확히 드러나는 이름 사용
   - 약어 최소화

## 주의사항

1. **중복 방지**:
   - 새 상수 추가 전 기존 상수 확인
   - 비슷한 값이 있다면 재사용

2. **타입 안전성**:
   - 명확한 타입 지정
   - 필요시 enum 사용 고려

3. **변경 시 영향**:
   - 상수 변경은 전체 모듈에 영향
   - 변경 전 사용처 확인 필수

## 향후 개선사항

1. **환경별 설정**:
   - 개발/운영 환경별 다른 값 지원
   - 빌드 시점 주입

2. **다국어 지원**:
   - strings.dart를 i18n으로 마이그레이션
   - 언어별 상수 분리