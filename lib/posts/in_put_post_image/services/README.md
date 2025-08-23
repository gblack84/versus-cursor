# 🚀 In Put Post Image Services 디렉토리

> 질문 작성 모듈의 핵심 비즈니스 로직 및 서비스 레이어

## 📑 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [주요 구성요소](#주요-구성요소)
- [서비스 상세](#서비스-상세)
- [사용 예시](#사용-예시)
- [서비스 아키텍처](#서비스-아키텍처)
- [의존성](#의존성)
- [변경 이력](#변경-이력)

## 🎯 개요

이 디렉토리는 In Put Post Image 모듈의 핵심 비즈니스 로직을 담당하는 서비스 클래스들을 관리합니다. 이미지 업로드, 검증, 편집, AI 모더레이션 등 복잡한 프로세스를 캡슐화하여 재사용성과 유지보수성을 높입니다.

### 주요 목적
- **이미지 처리**: 업로드, 리사이징, 썸네일 생성
- **콘텐츠 검증**: AI 기반 텍스트/이미지 모더레이션
- **선택 관리**: WeChat 피커 통합 및 결과 처리
- **오케스트레이션**: 복잡한 멀티스텝 프로세스 조율

## 📐 네이밍 컨벤션

프로젝트 전체 네이밍 규칙을 따릅니다:

- **파일명**: snake_case (Dart 표준)
  - ✅ `media_upload_service.dart`
  - ✅ `validation_service.dart`
  - ❌ `MediaUploadService.dart`

- **클래스명**: PascalCase
  - ✅ `MediaUploadService`
  - ✅ `ValidationService`
  - ❌ `media_upload_service`

- **메서드/변수명**: camelCase
  - ✅ `uploadImageWithVariants`
  - ✅ `validateAllTexts`
  - ❌ `upload_image_with_variants`

상세 내용: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 서비스 구조
```
services/
├── asset_picker_service.dart        # WeChat 피커 통합
├── image_download_service.dart      # 이미지 다운로드
├── image_editor_callback_handler.dart # 편집 콜백 처리
├── image_reorder_service.dart       # 이미지 순서 변경
├── image_upload_orchestrator.dart   # 업로드 오케스트레이션 v1
├── image_upload_orchestrator_v2.dart # 업로드 오케스트레이션 v2
├── media_selection_service.dart     # 미디어 선택 처리
├── media_upload_service.dart        # 미디어 업로드 핵심
├── selection_result_processor.dart  # 선택 결과 처리
├── validation_service.dart          # 콘텐츠 검증
└── README.md
```

### 서비스 분류

| 카테고리 | 서비스 | 주요 기능 | 중요도 |
|---------|--------|----------|--------|
| **업로드** | MediaUploadService | 이미지 업로드 및 변형 생성 | 핵심 |
| **검증** | ValidationService | AI 모더레이션 통합 | 핵심 |
| **오케스트레이션** | ImageUploadOrchestratorV2 | 전체 프로세스 조율 | 핵심 |
| **선택** | AssetPickerService | WeChat 피커 관리 | 중요 |
| **처리** | SelectionResultProcessor | 선택 결과 처리 | 중요 |

## 📋 서비스 상세

### MediaUploadService

이미지 업로드 및 변형 생성을 담당하는 핵심 서비스입니다.

#### 주요 기능
```dart
class MediaUploadService {
  // 3가지 크기로 이미지 업로드
  static Future<Map<String, dynamic>> uploadImageWithVariants({
    required Uint8List imageBytes,
    required String box,
    String? customPath,
    String? sessionId,
  })
  
  // 정사각형 썸네일 생성
  static img.Image _createSquareThumbnail(
    img.Image source, 
    int size
  )
  
  // Firebase Storage 업로드
  static Future<String> _uploadToFirebase(
    Uint8List bytes,
    String path,
    Map<String, String>? metadata,
  )
}
```

#### 이미지 변형 생성
- **Original**: 원본 이미지 그대로
- **Display**: 최대 800px 너비 (원본이 작으면 스킵)
- **Thumbnail**: 150x150 정사각형 (중앙 크롭)

#### 반환 데이터 구조
```dart
{
  'urls': {
    'original': 'https://...',
    'display': 'https://...',
    'thumbnail': 'https://...',
  },
  'aspectRatio': 1.5,
  'width': 1920,
  'height': 1280,
  'filePath': 'users/uid/posts/images/...',
}
```

### ValidationService

콘텐츠 검증 및 AI 모더레이션을 담당합니다.

#### 주요 기능
```dart
class ValidationService {
  // 빈 필드 검사
  static ValidationEmptyResult checkEmptyFields({
    required String? questionTitle,
    required String? aTitle,
    required String? bTitle,
  })
  
  // 전체 텍스트 검증 (AI 포함)
  static Future<ValidationResult> validateAllTexts({
    required String? questionTitle,
    String? description,
    required String? aTitle,
    required String? bTitle,
    BuildContext? context,
    Map<String, dynamic>? visionDataA,
    Map<String, dynamic>? visionDataB,
  })
  
  // 개선 제안 다이얼로그
  static Future<bool> showImprovementDialog(
    BuildContext context,
    String title,
    String? description,
  )
}
```

#### 검증 프로세스
1. **빈 필드 체크**: 필수 필드 확인
2. **사용자 인증**: Firebase Auth 확인
3. **AI 모더레이션**: Gemini + Perspective API
4. **결과 처리**: 승인/경고/거부

### ImageUploadOrchestratorV2

복잡한 이미지 업로드 프로세스를 조율하는 오케스트레이터입니다.

#### 주요 기능
```dart
class ImageUploadOrchestratorV2 {
  // 멀티 이미지 처리
  Future<ImageProcessResult> handleMultiImageProcess({
    required File editedImageFile,
    required List<File> allFiles,
    required int currentEditIndex,
    bool isAddMode = false,
    bool isEditMode = false,
    Function(double)? onProgress,
  })
  
  // 단일 이미지 처리
  Future<ImageProcessResult> handleSingleImageProcess({
    required File imageFile,
    required AssetEntity asset,
  })
}
```

#### 처리 플로우
1. **선택 모드 판단**: 처음/추가/편집
2. **이미지 검열**: Cloud Vision API
3. **승인/거부 처리**: 선택적 업로드
4. **상태 업데이트**: AppState 동기화
5. **UI 피드백**: 진행률 및 결과 표시

### AssetPickerService

WeChat Assets Picker 통합 및 관리를 담당합니다.

#### 주요 기능
```dart
class AssetPickerService {
  // AssetEntity ID로부터 복원
  static Future<List<AssetEntity>> restoreAssetsFromIds(
    List<String>? assetIds
  )
  
  // 피커 테마 생성
  static ThemeData createPickerTheme(BuildContext context)
  
  // 피커 Provider 생성
  static DefaultAssetPickerProvider createProvider({
    required List<AssetEntity> selectedAssets,
  })
}
```

#### 피커 설정
- **최대 선택**: 4개
- **그리드**: 4열
- **정렬**: 최신순 (수정 날짜 기준)
- **테마**: 다크 모드 커스터마이징

### SelectionResultProcessor

이미지 선택 결과를 처리하고 상태를 업데이트합니다.

#### 주요 기능
```dart
class SelectionResultProcessor {
  // 선택 결과 처리
  Future<void> processSelectionResult(
    List<AssetEntity> selectedAssets
  )
  
  // 삭제 처리
  void _handleRemovals(List<String> removedIds)
  
  // 새 이미지 처리
  Future<void> _handleNewAssets(List<AssetEntity> newAssets)
}
```

#### 처리 로직
1. **변경 감지**: 추가/삭제 항목 파악
2. **삭제 처리**: AppState에서 제거
3. **추가 처리**: 업로드 및 검열
4. **순서 재정렬**: 선택 순서 적용
5. **콜백 호출**: 완료 알림

### ImageReorderService

이미지 순서 재정렬을 담당합니다.

#### 주요 기능
```dart
class ImageReorderService {
  // 이미지 순서 재정렬
  static void reorderImages({
    required AppState appState,
    required String box,
    required List<String> newOrder,
  })
  
  // 선택된 이미지를 맨 앞으로
  static void moveSelectedToFront({
    required AppState appState,
    required String box,
    required int selectedIndex,
  })
}
```

### ImageEditorCallbackHandler

ProImageEditor 편집 결과 처리를 담당합니다.

#### 주요 기능
```dart
class ImageEditorCallbackHandler {
  // 편집 완료 콜백
  static Future<void> handleEditComplete({
    required Uint8List editedBytes,
    required String box,
    required int index,
  })
  
  // 편집 취소 콜백
  static void handleEditCancel()
}
```

## 💻 사용 예시

### 이미지 업로드 플로우

```dart
// 1. 이미지 선택
final assets = await AssetPicker.pickAssets(
  context,
  pickerConfig: AssetPickerConfig(
    maxAssets: 4,
    requestType: RequestType.image,
  ),
);

// 2. 선택 결과 처리
final processor = SelectionResultProcessor(
  context: context,
  appState: appState,
  box: 'A',
  onProgressUpdate: (progress) {
    print('진행률: ${progress * 100}%');
  },
);

await processor.processSelectionResult(assets);

// 3. 이미지 업로드 (오케스트레이터 사용)
final orchestrator = ImageUploadOrchestratorV2(
  context: context,
  appState: appState,
  box: 'A',
);

final result = await orchestrator.handleMultiImageProcess(
  editedImageFile: editedFile,
  allFiles: selectedFiles,
  currentEditIndex: 0,
);

// 4. 검증
final validationResult = await ValidationService.validateAllTexts(
  questionTitle: titleController.text,
  aTitle: aTitleController.text,
  bTitle: bTitleController.text,
  context: context,
);

if (!validationResult.isValid) {
  // 에러 처리
  await ValidationService.showViolationDialog(
    context,
    validationResult.violations,
  );
}
```

### AI 모더레이션 통합

```dart
// 텍스트 + 이미지 통합 검증
final result = await ValidationService.validateAllTexts(
  questionTitle: '질문 제목',
  description: '설명',
  aTitle: 'A 옵션',
  bTitle: 'B 옵션',
  visionDataA: imageAnalysisA,  // Cloud Vision 결과
  visionDataB: imageAnalysisB,
  context: context,
);

// 개선 제안 처리
if (result.geminiResult?.severity == 'warning') {
  final proceed = await ValidationService.showImprovementDialog(
    context,
    result.geminiResult!.reason,
    result.geminiResult!.suggestions,
  );
  
  if (!proceed) {
    // 사용자가 수정 선택
    return;
  }
}
```

### 이미지 순서 변경

```dart
// 썸네일 선택 시 해당 이미지를 맨 앞으로
ImageReorderService.moveSelectedToFront(
  appState: appState,
  box: 'A',
  selectedIndex: 2,
);

// 커스텀 순서 지정
ImageReorderService.reorderImages(
  appState: appState,
  box: 'B',
  newOrder: ['id3', 'id1', 'id2'],
);
```

## 🏗️ 서비스 아키텍처

### 데이터 플로우
```
사용자 이미지 선택
      ↓
AssetPickerService
      ↓
SelectionResultProcessor
      ↓
ImageUploadOrchestratorV2
      ↓
MediaUploadService → Firebase Storage
      ↓
ValidationService → AI Moderation
      ↓
AppState 업데이트
```

### 계층 구조
```
UI Layer (Widgets)
      ↓
Service Layer (이 디렉토리)
      ↓
External Services (Firebase, AI)
      ↓
Data Layer (AppState, Models)
```

### 에러 처리 전략
1. **검증 실패**: 사용자 피드백 + 수정 기회
2. **업로드 실패**: 재시도 메커니즘
3. **AI 타임아웃**: Fallback 로직
4. **네트워크 에러**: 오프라인 큐잉

### 검열 프로세스

#### 이미지 검열 플로우
```
이미지 선택
    ↓
리사이징 (3단계)
    ↓
Firebase 업로드
    ↓
Cloud Vision API
    ↓
결과 파싱
    ↓
승인/거부 결정
```

#### 텍스트 검열 플로우
```
텍스트 입력
    ↓
Perspective API 호출
    ↓
점수 분석 (70% 임계값)
    ↓
Gemini AI 추가 검증
    ↓
승인/경고/거부 결정
```

## 📦 의존성

### 외부 패키지
```yaml
dependencies:
  firebase_storage: ^12.3.2
  firebase_auth: ^5.3.3
  wechat_assets_picker: ^9.5.1
  image: ^4.0.17
  bot_toast: ^4.1.3
```

### 내부 의존성
- `/app_state.dart` - 전역 상태 관리
- `/services/ai_moderation/` - AI 모더레이션
- `/services/cloud_image_moderation_service.dart` - Cloud Vision
- `/services/image_moderation_service.dart` - 이미지 검열
- `../models/` - 데이터 모델
- `../constants/` - 상수 정의
- `../utils/` - 유틸리티 함수

## 🔄 변경 이력

### 2025-08-23
- 문서 전체 재작성
- 10개 서비스 클래스 상세 문서화
- 서비스 아키텍처 다이어그램 추가

### 주요 개발 이력
- **ImageUploadOrchestratorV2 구현** (2025-07-13)
  - File 기반 처리로 전환
  - 멀티 이미지 검열 개선
  - 진행률 피드백 추가

- **ValidationService 통합** (2025-07-16)
  - AI 모더레이션 통합
  - 개선 제안 다이얼로그
  - 사용자 수정 옵션

- **MediaUploadService 최적화** (2025-07-08)
  - 3단계 이미지 생성
  - 병렬 업로드 처리
  - 썸네일 중앙 크롭

## 📝 주요 규칙 및 가이드라인

### 서비스 설계 원칙
1. **단일 책임**: 하나의 서비스는 하나의 도메인 담당
2. **정적 메서드**: 상태 없는 유틸리티 함수
3. **에러 처리**: 명시적 에러 전파 및 처리
4. **비동기 처리**: Future 기반 비동기 패턴

### 성능 가이드라인
- **병렬 처리**: Future.wait 활용
- **프로그레스 피드백**: 실시간 진행률 표시
- **캐싱**: 반복 작업 결과 재사용
- **배치 처리**: 여러 작업 묶어서 처리

### 검열 정책
- **이미지**: Cloud Vision LIKELY 이상 거부
- **텍스트**: Perspective API 70% 이상 거부
- **통합**: 이미지와 텍스트 모두 통과 필요
- **재검열**: 편집 후 재검열 필수

### Firebase Storage 구조
```
users/
└── {userId}/
    └── posts/
        └── images/
            └── {timestamp}_{box}_{type}.jpg
                - original.jpg
                - display.jpg
                - thumb.jpg
```

### 테스트 체크리스트
- [ ] 이미지 업로드 성공/실패
- [ ] AI 모더레이션 통과/거부
- [ ] 멀티 이미지 선택/삭제
- [ ] 네트워크 에러 처리
- [ ] 진행률 콜백 정확성

## 🚀 향후 개선 사항

### 계획된 개선
- [ ] 비디오 업로드 지원
- [ ] 오프라인 큐잉 시스템
- [ ] 업로드 재시도 메커니즘
- [ ] 압축 알고리즘 개선

### 성능 최적화
- [ ] WebP 형식 지원
- [ ] 적응형 압축률
- [ ] CDN 통합
- [ ] 병렬 업로드 개선

### 기능 확장
- [ ] 일괄 편집 기능
- [ ] 클라우드 백업
- [ ] 실시간 협업 편집
- [ ] 오프라인 모드 지원