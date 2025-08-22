# Services Directory

## 개요 (Overview)

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)
이 디렉토리는 비즈니스 로직과 외부 서비스 통합을 담당하는 서비스 클래스들을 포함합니다. 주로 이미지 업로드, 콘텐츠 검열, Firebase 통합 등을 처리합니다.

## 파일 설명 (File Descriptions)

### image_upload_orchestrator_v2.dart
- **역할**: 이미지 업로드와 검열을 총괄하는 메인 서비스
- **주요 기능**:
  - 멀티 이미지 병렬 업로드
  - 이미지 검열 결과 처리
  - 텍스트 검열 통합
  - 에러 처리 및 재시도 로직
- **프로세스**:
  1. 이미지 리사이징 (원본, display, thumbnail)
  2. Firebase Storage 업로드
  3. Cloud Vision API 검열
  4. 결과 반환 및 UI 업데이트
- **중요 메서드**:
  - `processAndUploadImages()`: 멀티 이미지 처리
  - `_processWithTextModeration()`: 텍스트 포함 검열

### image_moderation_service.dart
- **역할**: Cloud Functions를 통한 이미지 검열
- **주요 기능**:
  - Cloud Vision API 호출
  - 검열 결과 파싱
  - 거부 이유 분류 (선정성, 폭력성 등)
- **검열 기준**:
  - LIKELY 이상: 거부
  - POSSIBLE 이하: 승인
- **반환 형식**:
  ```dart
  {
    'isAppropriate': bool,
    'reason': String,
    'details': Map<String, dynamic>
  }
  ```

### perspective_api_service.dart
- **역할**: Google Perspective API를 통한 텍스트 검열
- **주요 기능**:
  - 텍스트 유해성 점수 분석
  - 다국어 지원 (한국어, 영어)
  - 임계값 기반 필터링
- **검열 항목**:
  - TOXICITY (유해성)
  - SEVERE_TOXICITY (심각한 유해성)
  - INSULT (모욕)
  - THREAT (위협)
  - PROFANITY (욕설)
- **임계값**: 0.7 (70% 이상 시 거부)

### storage_service.dart
- **역할**: Firebase Storage 관련 유틸리티 (현재 미사용)
- **향후 계획**: 스토리지 관련 공통 기능 통합

### media_upload_service.dart
- **역할**: 이미지 업로드 및 리사이징 처리
- **주요 기능**:
  - 3단계 이미지 생성:
    - Original: 원본 크기
    - Display: 800px (UI 표시용)
    - Thumbnail: 150px (미리보기용)
  - JPEG 품질 85%로 압축
  - Firebase Storage 경로 관리
- **중요 메서드**:
  - `uploadImageWithSizes()`: 단일 이미지 3단계 업로드
  - `uploadMultipleImages()`: 멀티 이미지 병렬 처리

### validation_service.dart
- **역할**: 입력 필드 유효성 검사
- **주요 기능**:
  - 필수 필드 체크
  - 글자수 제한 검사
  - 실시간 유효성 검사
- **검사 항목**:
  - Description: 필수, 최대 200자
  - A/B Title: 필수, 최대 20자

### image_editor_callback_handler.dart
- **역할**: ProImageEditor 콜백 처리
- **주요 기능**:
  - 편집 완료 후 이미지 처리
  - 재업로드 및 재검열
  - 편집 취소 처리

### selection_result_processor.dart
- **역할**: 이미지 선택 결과 처리
- **주요 기능**:
  - AssetEntity를 File로 변환
  - 멀티 이미지 diff 처리
  - 썸네일 선택 모드 지원

### asset_picker_service.dart
- **역할**: wechat_assets_picker 설정 및 관리
- **주요 기능**:
  - 피커 설정 (그리드, 최대 선택 수 등)
  - 한국어 텍스트 델리게이트
  - 선택된 자산 표시

### media_selection_service.dart (미사용)
- **역할**: 이전 버전의 미디어 선택 서비스

### image_reorder_service.dart
- **역할**: 멀티 이미지 순서 변경
- **주요 기능**:
  - 썸네일에서 선택한 이미지를 맨 앞으로
  - AppState 동기화

## 검열 프로세스 상세

### 이미지 검열 플로우
```
이미지 선택 → 리사이징 → Firebase 업로드 → 
Cloud Functions 호출 → Cloud Vision API → 
결과 파싱 → 승인/거부 결정
```

### 텍스트 검열 플로우
```
텍스트 입력 → Perspective API 호출 → 
점수 분석 → 임계값 비교 → 승인/거부 결정
```

### 통합 검열 (이미지 + 텍스트)
```dart
// 이미지와 텍스트 모두 통과해야 승인
final imageResult = await moderateImage(imageUrl);
final textResult = await checkText(description);
final isApproved = imageResult.isAppropriate && textResult.isAppropriate;
```

## 에러 처리

### 네트워크 에러
- 3회 재시도
- 지수 백오프 (1초, 2초, 4초)
- 최종 실패 시 사용자에게 안내

### 검열 실패
- 구체적인 거부 이유 표시
- 재선택/재편집 유도
- 부분 성공 시 승인된 것만 저장

## 성능 최적화

### 병렬 처리
```dart
// 멀티 이미지 동시 업로드
final results = await Future.wait(
  files.map((file) => uploadImageWithSizes(file))
);
```

### 이미지 최적화
- Display 크기: UI 표시에 최적화 (800px)
- Thumbnail: 리스트/그리드용 (150px)
- JPEG 압축으로 용량 절감

## 사용 예시

### 이미지 업로드 및 검열
```dart
final orchestrator = ImageUploadOrchestratorV2();
final result = await orchestrator.processAndUploadImages(
  imageFiles: selectedFiles,
  box: 'A',
  description: descriptionText,
  titleA: titleAText,
  titleB: titleBText,
);

if (result.isSuccess) {
  // 성공 처리
} else {
  // 에러 표시
  showToast(result.errorMessage);
}
```

## 중요 사항

1. **API 키 관리**:
   - Perspective API 키는 환경 변수로 관리
   - Cloud Functions URL은 Firebase 프로젝트에 종속

2. **검열 정책**:
   - 이미지: LIKELY 이상 거부
   - 텍스트: 70% 이상 유해성 점수 거부
   - 편집 후 재검열 필수

3. **Firebase Storage 구조**:
   ```
   images/
   └── users/
       └── {userId}/
           └── {timestamp}/
               ├── original/
               ├── display/
               └── thumbnail/
   ```

4. **에러 메시지 일관성**:
   - 사용자 친화적 메시지
   - 구체적인 거부 이유 제공
   - 다국어 지원 고려