# Creation Feature - Presentation Layer

> 최종 업데이트: 2025-08-24 | 버전: 5.0.0 | Phase 5 MediaStateCoordinator 완성

## 🎨 개요

Presentation Layer는 Clean Architecture의 최외곽 계층으로, **사용자 인터페이스(UI)와 상태 관리**를 담당합니다. Flutter 위젯, 상태 관리 Provider, UI 모델을 포함하며, Domain Layer의 UseCase를 통해 비즈니스 로직을 실행합니다.

### 📌 현재 구현 상태
- ✅ **화면(Screens)**: 4개 주요 화면 (CreatePost, Editor, Thumbnail, Viewer)
- ✅ **위젯(Widgets)**: 3개 카테고리 (create_post, components, dialogs, media)
- ✅ **Provider**: Phase 5 - MediaStateCoordinator 통합 (4개 Provider)
  - CreatePostProviderV2 (중앙 상태 관리)
  - MediaStateCoordinator (3개 Provider 조정)
  - MediaSelectionProvider, MediaUploadProvider, MediaValidationProvider
  - TargetAudienceProvider
- ✅ **Constants**: 7개 UI 상수 파일 (중앙 집중식 스타일 관리)
- ✅ **Delegates**: 3개 커스텀 델리게이트 (한국어 지원, 카메라 버튼)

### 핵심 특징
- 🎯 **Phase 5 MediaStateCoordinator**: 3개 Provider 통합 및 복잡한 워크플로우 관리
- 🔄 **Clean Architecture 준수**: AppState 제거, UseCase 기반 순수 상태 관리
- 🎨 **컴포넌트 재사용성**: base_media_selection_box mixin으로 코드 중복 제거
- 🌐 **다국어 지원**: Korean 커스텀 델리게이트 (wechat_assets_picker)
- 📊 **중앙 집중식 스타일**: 7개 constants 파일로 UI 일관성 보장

---

## 🏗️ 전체 구조도

```
lib/features/creation/presentation/
│
├── 📁 providers/                    # 🔄 상태 관리 [총 6개 Provider]
│   ├── 📄 create_post_provider_v2.dart       # ⭐ 중앙 상태 관리
│   │                                         # - 4개 UseCase 통합
│   │                                         # - PostFormData 모델
│   │                                         # - MediaStateCoordinator 주입
│   │
│   ├── 📁 media/                    # Phase 5: MediaStateCoordinator
│   │   ├── 📄 media_state_coordinator.dart   # 🎯 3 Provider 조정자
│   │   │                                     # - Selection ↔ Upload ↔ Validation
│   │   │                                     # - 복잡한 워크플로우 관리
│   │   │                                     # - 통합 에러 처리
│   │   ├── 📄 media_selection_provider.dart  # 이미지/비디오 선택
│   │   │                                     # - wechat_assets_picker 통합
│   │   │                                     # - AssetEntity 관리
│   │   │                                     # - aspect ratio 계산
│   │   ├── 📄 media_upload_provider.dart     # 멀티미디어 업로드
│   │   │                                     # - 병렬 업로드 (Future.wait)
│   │   │                                     # - 진행률 추적
│   │   │                                     # - 캔슬 지원
│   │   └── 📄 media_validation_provider.dart # AI 검열 통합
│   │                                         # - 3-tier 검증 (Perspective, Vision, Gemini)
│   │                                         # - 실시간 검증 상태
│   │
│   ├── 📄 target_audience_provider.dart      # 타겟 오디언스 관리
│   │                                         # - 4가지 모드 (quick, public, custom, test)
│   │                                         # - AI 추천 사용자
│   │
│   └── 📄 README.md                 # Provider 상세 문서
│       └── 📄 PROVIDER_USAGE.md     # 사용 가이드
│
├── 📁 screens/                      # 🖼️ UI 화면들 [4개]
│   ├── 📁 create_post/              # ⭐ 메인 질문 작성 화면
│   │   ├── 📄 create_post_screen.dart        # 전체 화면 orchestration
│   │   │                                     # - 3개 Provider 통합
│   │   │                                     # - 스크롤 리스너
│   │   │                                     # - 흔들림 애니메이션
│   │   │                                     # - B박스 토글
│   │   └── 📄 README.md             # 상세 문서
│   │
│   ├── 📁 editor/                   # 🎨 이미지 에디터
│   │   ├── 📄 pro_image_editor_page.dart     # ProImageEditor 통합
│   │   │                                     # - 필터, 자르기, 그리기, 텍스트
│   │   │                                     # - Firebase URL 다운로드/업로드
│   │   │                                     # - 한국어 i18n
│   │   └── 📄 README.md             # 에디터 가이드
│   │
│   ├── 📁 thumbnail/                # 🖼️ 썸네일 선택 화면
│   │   ├── 📄 thumbnail_selection_page.dart  # PageView 기반 썸네일
│   │   │                                     # - 이미지 재배치 (드래그)
│   │   │                                     # - 대표 이미지 선택
│   │   │                                     # - 프리로딩 최적화
│   │   └── 📄 README.md             # 썸네일 가이드
│   │
│   ├── 📁 viewer/                   # 🔍 전체화면 이미지 뷰어
│   │   └── 📄 image_viewer_page.dart         # 줌/스와이프 지원
│   │                                         # - PhotoView 통합
│   │
│   └── 📄 README.md                 # Screens 전체 가이드
│
├── 📁 widgets/                      # 🧩 재사용 가능 위젯들
│   ├── 📁 create_post/              # 질문 작성 전용 위젯
│   │   ├── 📄 text_input_widget.dart         # 텍스트 입력 섹션
│   │   │                                     # - 제목, 설명, A/B 옵션
│   │   │                                     # - 실시간 유효성 검증
│   │   │                                     # - 문자 수 카운터
│   │   └── 📄 image_selection_widget.dart    # 이미지 선택 섹션
│   │                                         # - Smart Layout 시스템
│   │                                         # - 동적 박스 크기 계산
│   │                                         # - A/B 박스 표시
│   │
│   ├── 📁 components/               # 공통 컴포넌트 [9개]
│   │   ├── 📄 base_media_selection_box.dart  # 🎯 Mixin 패턴
│   │   │                                     # - 공통 로직 추출
│   │   │                                     # - 코드 재사용성
│   │   ├── 📄 media_selection_box_single.dart # 단일 이미지 박스
│   │   ├── 📄 media_selection_box_multi.dart  # 멀티 이미지 박스
│   │   │                                     # - PageView 기반
│   │   │                                     # - 페이지 인디케이터
│   │   ├── 📄 next_button.dart               # 다음 버튼
│   │   │                                     # - canSubmit 상태 기반
│   │   │                                     # - 로딩 인디케이터
│   │   ├── 📄 warning_message.dart           # 경고 메시지
│   │   ├── 📄 simple_validated_field.dart    # 유효성 검증 입력 필드
│   │   ├── 📄 input_field_builder.dart       # 입력 필드 빌더
│   │   ├── 📄 character_count_display.dart   # 문자 수 표시
│   │   └── 📄 simple_character_count.dart    # 간단한 카운터
│   │
│   ├── 📁 dialogs/                  # 모달 다이얼로그
│   │   ├── 📄 target_audience_dialog.dart    # ⭐ 타겟 오디언스 선택
│   │   │                                     # - 4가지 모드 지원
│   │   │                                     # - 단계별 선택 UI
│   │   ├── 📄 moderation_dialog.dart         # AI 검열 다이얼로그
│   │   ├── 📄 moderation_error_dialog.dart   # 검열 실패 안내
│   │   │
│   │   └── 📁 target_audience_steps/# 타겟 오디언스 단계
│   │       ├── 📄 collection_type_selector.dart # 모드 선택
│   │       ├── 📄 target_count_selector.dart    # 목표 인원 선택
│   │       ├── 📄 detailed_target_selector.dart # Custom 필터
│   │       └── 📄 README.md         # Steps 가이드
│   │
│   ├── 📁 media/                    # 미디어 관련 위젯
│   │   ├── 📄 media_selection_flow_widget.dart # 미디어 선택 플로우
│   │   │                                       # - wechat_assets_picker 통합
│   │   │                                       # - 썸네일 선택 후 에디터
│   │   ├── 📄 media_editor_widget.dart         # 에디터 래퍼
│   │   └── 📄 thumbnail_navigation_helper.dart # 썸네일 네비게이션
│   │
│   └── 📄 README.md                 # Widgets 전체 가이드
│
├── 📁 delegates/                    # 🌐 커스텀 델리게이트 [3개]
│   ├── 📄 korean_asset_picker_delegate.dart  # 한국어 wechat_assets_picker
│   │                                         # - 완전 한국어 번역
│   │                                         # - gridCount: 4
│   ├── 📄 korean_camera_picker_delegate.dart # 한국어 카메라 피커
│   └── 📄 camera_floating_button_delegate.dart # 카메라 플로팅 버튼
│                                             # - 커스텀 카메라 버튼 위치
│
└── 📁 constants/                    # 🎨 UI 상수 [7개 파일]
    ├── 📄 field_styles.dart         # ⭐ 중앙 집중식 필드 스타일
    │                                # - FieldStyles 클래스
    │                                # - FieldConfig 모델
    │                                # - 모든 입력 필드 설정 통합
    ├── 📄 dimensions.dart           # UI 치수 (패딩, 마진, 크기)
    ├── 📄 colors.dart               # 색상 팔레트
    ├── 📄 image_constants.dart      # 이미지 처리 상수
    ├── 📄 animation_constants.dart  # 애니메이션 설정
    ├── 📄 strings.dart              # UI 문자열
    ├── 📄 text_limits.dart          # 텍스트 제한 (최대 길이)
    ├── 📄 config.dart               # 일반 설정
    └── 📄 constants.dart            # 통합 export
```

---

## 📂 디렉토리별 상세 설명

### 1. providers/ - 상태 관리

Creation Feature는 **Phase 5 MediaStateCoordinator 아키텍처**를 적용하여 복잡한 미디어 상태를 체계적으로 관리합니다.

#### 1.1 Phase 5 아키텍처 개요

```
CreatePostProviderV2 (중앙 상태 관리)
    ↓ 주입
MediaStateCoordinator (조정자)
    ├─ MediaSelectionProvider (선택)
    ├─ MediaUploadProvider (업로드)
    └─ MediaValidationProvider (검증)
```

**핵심 원칙**:
- ✅ **단일 책임 원칙**: 각 Provider는 하나의 역할만 담당
- ✅ **조정 패턴**: MediaStateCoordinator가 복잡한 워크플로우 관리
- ✅ **Clean Architecture**: AppState 의존성 제거, UseCase 기반

#### 1.2 create_post_provider_v2.dart (중앙 상태 관리)

**책임**: 전체 Post 생성 플로우의 중앙 상태 관리

```dart
class CreatePostProviderV2 extends ChangeNotifier {
  // UseCase 의존성 (Clean Architecture)
  final CreatePostUseCase _createPostUseCase;
  final ModerateContentUseCase _moderateContentUseCase;
  final ValidatePostUseCase _validatePostUseCase;
  final MediaStateCoordinator _mediaCoordinator; // Phase 5 주입

  // 상태 필드
  PostFormData _formData = PostFormData();
  LoadingState _loadingState = LoadingState.idle;
  ModerationStatus _moderationStatus = ModerationStatus.pending;
  String? _errorMessage;

  // Phase 5: MediaStateCoordinator 접근자
  MediaStateCoordinator get mediaCoordinator => _mediaCoordinator;

  // 비즈니스 메서드
  bool get canSubmit {
    return _formData.isValid &&
        _loadingState == LoadingState.idle &&
        _moderationStatus != ModerationStatus.checking;
  }

  /// Post 생성 (전체 플로우)
  Future<void> createPost(
    String userId, {
    TargetAudience? targetAudience,
    Function(double)? onProgress,
  }) async {
    _loadingState = LoadingState.loading;
    notifyListeners();

    try {
      // 1. DTO 생성
      final dto = PostCreationDto.fromFormData(
        userId: userId,
        title: _formData.title,
        description: _formData.description,
        imagesA: _formData.imagesA,
        imagesB: _formData.imagesB,
        targetAudience: targetAudience,
        isAnonymous: _formData.isAnonymous,
      );

      // 2. UseCase 실행
      final result = await _createPostUseCase.execute(
        dto: dto,
        onProgress: onProgress,
      );

      if (result.isSuccess) {
        _loadingState = LoadingState.success;
        resetForm();
      } else {
        _errorMessage = result.failureOrNull?.getUserMessage();
        _loadingState = LoadingState.error;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _loadingState = LoadingState.error;
    }

    notifyListeners();
  }

  /// 폼 유효성 검증
  Future<bool> validateFormFields() async {
    final result = await _validatePostUseCase.execute(
      title: _formData.title,
      description: _formData.description,
      imagesA: _formData.imagesA,
      imagesB: _formData.imagesB,
      targetAudience: _formData.targetAudience,
    );

    if (result.isFailure) {
      _errorMessage = result.failureOrNull?.getUserMessage();
      notifyListeners();
      return false;
    }

    return true;
  }

  /// 폼 초기화
  void resetForm() {
    _formData = PostFormData();
    _loadingState = LoadingState.idle;
    _moderationStatus = ModerationStatus.pending;
    _errorMessage = null;
    notifyListeners();
  }
}
```

**PostFormData 모델**:
```dart
class PostFormData {
  String title;
  String description;
  String textA;
  String textB;
  List<File> imagesA;
  List<File> imagesB;
  TargetAudience? targetAudience;
  bool isAnonymous;
  bool isSingleMode; // B박스 숨기기

  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        (textA.isNotEmpty || imagesA.isNotEmpty) &&
        (isSingleMode || textB.isNotEmpty || imagesB.isNotEmpty);
  }
}
```

**LoadingState & ModerationStatus**:
```dart
enum LoadingState {
  idle,      // 대기 중
  loading,   // 로딩 중
  success,   // 성공
  error,     // 에러
}

enum ModerationStatus {
  pending,   // 대기
  checking,  // 검증 중
  approved,  // 승인
  rejected,  // 거부
}
```

#### 1.3 media_state_coordinator.dart (Phase 5 조정자)

**책임**: 3개 Media Provider 간 조정 및 복잡한 워크플로우 관리

```dart
class MediaStateCoordinator {
  final MediaSelectionProvider _selectionProvider;
  final MediaUploadProvider _uploadProvider;
  final MediaValidationProvider _validationProvider;

  MediaStateCoordinator({
    required MediaSelectionProvider selectionProvider,
    required MediaUploadProvider uploadProvider,
    required MediaValidationProvider validationProvider,
  })  : _selectionProvider = selectionProvider,
        _uploadProvider = uploadProvider,
        _validationProvider = validationProvider;

  // Getters for Provider Access
  MediaSelectionProvider get selection => _selectionProvider;
  MediaUploadProvider get upload => _uploadProvider;
  MediaValidationProvider get validation => _validationProvider;

  /// 통합 미디어 처리 워크플로우
  Future<MediaProcessingResult> processMediaSelection({
    required String box,
    required List<AssetEntity> assets,
    bool validateContent = true,
    bool autoUpload = false,
    Function(String status)? onStatusUpdate,
  }) async {
    try {
      // Step 1: Selection (선택)
      onStatusUpdate?.call('이미지 선택 중...');
      await _selectionProvider.selectImages(box: box, assets: assets);

      final selectedFiles = box == 'A'
          ? _selectionProvider.selectedFilesA
          : _selectionProvider.selectedFilesB;

      if (selectedFiles.isEmpty) {
        return MediaProcessingResult(
          success: false,
          errorMessage: '선택된 이미지가 없습니다.',
        );
      }

      // Step 2: Validation (검증)
      if (validateContent) {
        onStatusUpdate?.call('이미지 검증 중...');

        final isValid = await _validationProvider.validateImages(
          images: selectedFiles,
          box: box,
        );

        if (!isValid) {
          final rejectionReasons = _validationProvider.parseRejectionReasons();
          return MediaProcessingResult(
            success: false,
            errorMessage: rejectionReasons.isNotEmpty
                ? rejectionReasons
                : '이미지 검증에 실패했습니다.',
          );
        }
      }

      // Step 3: Upload (업로드)
      if (autoUpload) {
        onStatusUpdate?.call('이미지 업로드 중...');

        final uploadResult = await _uploadProvider.uploadImages(
          box: box,
          files: selectedFiles,
          onProgress: (progress) {
            onStatusUpdate?.call('업로드 중... ${(progress * 100).toInt()}%');
          },
        );

        if (!uploadResult.success) {
          return MediaProcessingResult(
            success: false,
            errorMessage: uploadResult.errorMessage ?? '업로드에 실패했습니다.',
          );
        }

        return MediaProcessingResult(
          success: true,
          uploadedUrls: uploadResult.urls,
        );
      }

      return MediaProcessingResult(success: true);
    } catch (e) {
      return MediaProcessingResult(
        success: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// 에러 복구 (모든 Provider 상태 초기화)
  Future<void> resetAllStates() async {
    await _selectionProvider.reset();
    await _uploadProvider.reset();
    await _validationProvider.reset();
  }

  /// 상태 동기화 (Provider 간 일관성 보장)
  Future<void> syncStates() async {
    // Selection → Upload 동기화
    _uploadProvider.syncWithSelection(
      filesA: _selectionProvider.selectedFilesA,
      filesB: _selectionProvider.selectedFilesB,
    );

    // Upload → Validation 동기화
    _validationProvider.syncWithUpload(
      urlsA: _uploadProvider.uploadedUrlsA,
      urlsB: _uploadProvider.uploadedUrlsB,
    );
  }
}
```

**MediaProcessingResult**:
```dart
class MediaProcessingResult {
  final bool success;
  final String? errorMessage;
  final List<String>? uploadedUrls;

  MediaProcessingResult({
    required this.success,
    this.errorMessage,
    this.uploadedUrls,
  });
}
```

#### 1.4 media_selection_provider.dart (이미지 선택)

**책임**: wechat_assets_picker 통합 및 이미지 선택 상태 관리

```dart
class MediaSelectionProvider extends ChangeNotifier {
  // 선택된 파일
  List<File> _selectedFilesA = [];
  List<File> _selectedFilesB = [];

  // 로컬 경로
  List<String> _localPathsA = [];
  List<String> _localPathsB = [];

  // aspect ratio
  List<double> _aspectRatiosA = [];
  List<double> _aspectRatiosB = [];

  // AssetEntity ID (피커 선택 상태 유지)
  List<String> _assetEntityIdsA = [];
  List<String> _assetEntityIdsB = [];

  // 업로드된 URL
  List<String> _uploadedUrlsA = [];
  List<String> _uploadedUrlsB = [];

  // Getters
  List<File> get selectedFilesA => _selectedFilesA;
  List<File> get selectedFilesB => _selectedFilesB;
  List<double> get aspectRatiosA => _aspectRatiosA;
  List<double> get aspectRatiosB => _aspectRatiosB;

  /// 이미지 선택
  Future<void> selectImages({
    required String box,
    required List<AssetEntity> assets,
  }) async {
    final files = <File>[];
    final ratios = <double>[];
    final assetIds = <String>[];

    for (final asset in assets) {
      final file = await asset.file;
      if (file != null) {
        files.add(file);
        ratios.add(asset.width / asset.height);
        assetIds.add(asset.id);
      }
    }

    if (box == 'A') {
      _selectedFilesA = files;
      _aspectRatiosA = ratios;
      _assetEntityIdsA = assetIds;
    } else {
      _selectedFilesB = files;
      _aspectRatiosB = ratios;
      _assetEntityIdsB = assetIds;
    }

    notifyListeners();
  }

  /// 이미지 삭제
  void removeImage(String box, int index) {
    if (box == 'A') {
      _selectedFilesA.removeAt(index);
      _aspectRatiosA.removeAt(index);
      _assetEntityIdsA.removeAt(index);
      _uploadedUrlsA.removeAt(index);
    } else {
      _selectedFilesB.removeAt(index);
      _aspectRatiosB.removeAt(index);
      _assetEntityIdsB.removeAt(index);
      _uploadedUrlsB.removeAt(index);
    }

    notifyListeners();
  }

  /// 초기화
  Future<void> reset() async {
    _selectedFilesA = [];
    _selectedFilesB = [];
    _localPathsA = [];
    _localPathsB = [];
    _aspectRatiosA = [];
    _aspectRatiosB = [];
    _assetEntityIdsA = [];
    _assetEntityIdsB = [];
    _uploadedUrlsA = [];
    _uploadedUrlsB = [];
    notifyListeners();
  }
}
```

#### 1.5 media_upload_provider.dart (멀티미디어 업로드)

**책임**: 병렬 업로드 및 진행률 추적

```dart
class MediaUploadProvider extends ChangeNotifier {
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;

  /// 이미지 배치 업로드 (병렬 처리)
  Future<UploadResult> uploadImages({
    required String box,
    required List<File> files,
    Function(double)? onProgress,
  }) async {
    _isUploading = true;
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final urls = <String>[];
      final totalFiles = files.length;

      // 병렬 업로드 (Future.wait)
      final uploadTasks = files.asMap().entries.map((entry) async {
        final index = entry.key;
        final file = entry.value;

        final url = await _uploadSingleImage(file);

        // 진행률 업데이트
        _uploadProgress = (index + 1) / totalFiles;
        onProgress?.call(_uploadProgress);
        notifyListeners();

        return url;
      });

      final uploadedUrls = await Future.wait(uploadTasks);
      urls.addAll(uploadedUrls);

      _isUploading = false;
      notifyListeners();

      return UploadResult(success: true, urls: urls);
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      notifyListeners();

      return UploadResult(success: false, errorMessage: _errorMessage);
    }
  }

  Future<String> _uploadSingleImage(File file) async {
    // Firebase Storage 업로드 로직
    // ...
    return 'https://firebase.storage/...';
  }
}
```

#### 1.6 media_validation_provider.dart (AI 검열)

**책임**: 3-tier AI 검열 시스템 통합

```dart
class MediaValidationProvider extends ChangeNotifier {
  bool _isValidating = false;
  Map<String, dynamic> _validationResults = {};
  Map<String, String> _validationErrors = {};

  bool get isValidating => _isValidating;

  /// 이미지 검증 (3-tier)
  Future<bool> validateImages({
    required List<File> images,
    required String box,
  }) async {
    _isValidating = true;
    notifyListeners();

    try {
      // 1단계: Perspective API (텍스트 유해성)
      // 2단계: Cloud Vision API (이미지 안전성)
      // 3단계: Gemini AI (로직 검증)

      final allPassed = true; // 검증 로직 결과

      _validationResults[box] = {
        'passed': allPassed,
        'timestamp': DateTime.now(),
      };

      _isValidating = false;
      notifyListeners();

      return allPassed;
    } catch (e) {
      _validationErrors[box] = e.toString();
      _isValidating = false;
      notifyListeners();

      return false;
    }
  }

  /// 거부 이유 파싱
  String parseRejectionReasons() {
    // validationResults에서 거부 이유 추출
    return '선정적 콘텐츠, 폭력적 내용';
  }
}
```

#### 1.7 target_audience_provider.dart (타겟 오디언스)

**책임**: 4가지 모드 타겟 오디언스 관리

```dart
class TargetAudienceProvider extends ChangeNotifier {
  String _mode = 'quick'; // quick, public, custom, test
  int _targetCount = 10;
  List<String> _selectedUserIds = [];
  Map<String, dynamic> _filters = {};

  String get mode => _mode;
  int get targetCount => _targetCount;

  /// 모드 변경
  void setMode(String mode) {
    _mode = mode;
    notifyListeners();
  }

  /// 목표 인원 설정
  void setTargetCount(int count) {
    _targetCount = count;
    notifyListeners();
  }

  /// Custom 필터 설정
  void setFilters(Map<String, dynamic> filters) {
    _filters = filters;
    notifyListeners();
  }

  /// TargetAudience 객체 생성
  TargetAudience buildTargetAudience() {
    return TargetAudience(
      mode: _mode,
      targetCount: _targetCount,
      selectedUserIds: _mode == 'custom' ? _selectedUserIds : null,
      filters: _mode == 'custom' ? _filters : null,
    );
  }
}
```

---

### 2. screens/ - UI 화면

Creation Feature는 **4개 주요 화면**으로 구성됩니다:

#### 2.1 create_post/ - 메인 질문 작성 화면

**파일**: `create_post_screen.dart`

**책임**: 전체 Post 생성 플로우의 orchestration

**주요 구성**:
```dart
class CreatePostScreen extends StatefulWidget {
  static String routeName = 'CreatePostScreen';
  static String routePath = '/createPost';

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _validationSessionId = '';
  bool _showNextButton = false;
  bool _isValidating = false;
  bool _absellected = false; // B박스 숨기기

  // Animation
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Phase 5: MediaStateCoordinator 통합
        ChangeNotifierProvider(
          create: (_) => CreationModule.getCreatePostProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreationModule.getMediaSelectionProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => CreationModule.getMediaValidationProvider(),
        ),
      ],
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // 텍스트 입력 섹션
                    TextInputWidget(
                      showOptionB: !_absellected,
                      validationSessionId: _validationSessionId,
                    ),

                    // 이미지 선택 섹션
                    ImageSelectionWidget(
                      absellected: _absellected,
                      isDynamic: true, // Smart Layout 활성화
                      validationSessionId: _validationSessionId,
                    ),

                    // A/B 모드 토글
                    Switch(
                      value: _absellected,
                      onChanged: (value) {
                        setState(() {
                          _absellected = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              // 하단 Next 버튼
              if (_showNextButton)
                Positioned(
                  bottom: 0,
                  child: Consumer<CreatePostProviderV2>(
                    builder: (context, provider, child) {
                      return NextButton(
                        showButton: provider.canSubmit,
                        onPressed: provider.canSubmit && !_isValidating
                            ? _handleSubmit
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    final provider = context.read<CreatePostProviderV2>();

    // 1. 유효성 검증
    final isValid = await provider.validateFormFields();
    if (!isValid) {
      _triggerShakeAnimation();
      BotToast.showText(text: provider.errorMessage ?? '필수 항목을 입력해주세요');
      return;
    }

    // 2. 타겟 오디언스 선택
    final targetAudience = await TargetAudienceDialog.show(context);
    if (targetAudience == null) return;

    // 3. Post 생성
    await provider.createPost(currentUserUid, targetAudience: targetAudience);

    // 4. 화면 닫기
    if (mounted) Navigator.of(context).pop(true);
  }

  void _triggerShakeAnimation() {
    _shakeController.forward().then((_) {
      _shakeController.reverse();
    });
  }
}
```

**특징**:
- 🎯 MultiProvider로 3개 Provider 통합
- 📊 스크롤 리스너로 Next 버튼 표시/숨김
- 🎨 흔들림 애니메이션으로 유효성 검증 실패 피드백
- 🔄 B박스 토글 기능 (Single 모드)

#### 2.2 editor/ - 이미지 에디터

**파일**: `pro_image_editor_page.dart`

**책임**: ProImageEditor 통합 및 Firebase 연동

**주요 기능**:
```dart
class ProImageEditorPage extends StatefulWidget {
  final String imageUrl;           // Firebase Storage URL
  final String box;                 // 'A' or 'B'
  final String? assetId;            // AssetEntity ID
  final bool isEditMode;            // 편집 모드 (vs 신규)

  @override
  State<ProImageEditorPage> createState() => _ProImageEditorPageState();
}

class _ProImageEditorPageState extends State<ProImageEditorPage> {
  Future<void> _saveEditedImage() async {
    // 1. Firebase URL → 다운로드
    final imageData = await _downloadImage(widget.imageUrl);

    // 2. ProImageEditor로 편집
    final editedBytes = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditor.memory(
          imageData,
          configs: ProImageEditorConfigs(
            i18n: const I18n(
              loading: '이미지 불러오는 중...',
              // ... 한국어 번역
            ),
            // Blur 메뉴 비활성화
            blurEditor: BlurEditorConfigs(enabled: false),
            // Paint 메뉴 정리
            paintEditor: PaintEditorConfigs(
              enabled: true,
              enabledTools: [
                PaintTool.pen,
                PaintTool.arrow,
                PaintTool.dashLine,
                PaintTool.circle,
                PaintTool.emoji,
              ],
            ),
          ),
        ),
      ),
    );

    // 3. 편집된 이미지 → Firebase 업로드
    final newUrl = await _uploadImage(editedBytes, widget.box);

    // 4. MediaSelectionProvider 업데이트
    final provider = context.read<MediaSelectionProvider>();
    provider.updateImageUrl(widget.box, widget.assetId, newUrl);

    // 5. 원본 페이지로 복귀
    Navigator.pop(context, newUrl);
  }
}
```

**ProImageEditor 커스터마이징**:
- ❌ Blur 메뉴 완전 비활성화
- ✅ Paint 메뉴 도구 정리 (Pen, Arrow, DashLine, Circle, Emoji만)
- 🌐 한국어 i18n 완전 지원

#### 2.3 thumbnail/ - 썸네일 선택 화면

**파일**: `thumbnail_selection_page.dart`

**책임**: 대표 이미지 선택 및 순서 변경

**주요 기능**:
```dart
class ThumbnailSelectionPage extends StatelessWidget {
  final List<String> imageUrls;    // Firebase Storage URLs
  final String box;                 // 'A' or 'B'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: TextButton(
          child: Row(
            children: [
              Icon(Icons.arrow_back),
              Text('< 썸네일'),
            ],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              // 선택된 이미지를 맨 앞으로 이동
              final provider = context.read<MediaSelectionProvider>();
              provider.moveToFront(box, index);

              Navigator.pop(context);
            },
            child: CachedNetworkImage(
              imageUrl: imageUrls[index],
              fit: BoxFit.cover,
            ),
          );
        },
      ),
    );
  }
}
```

**특징**:
- 🖼️ GridView 3열 썸네일
- 🎯 탭으로 대표 이미지 선택
- 🔄 선택 시 맨 앞으로 자동 이동

#### 2.4 viewer/ - 전체화면 이미지 뷰어

**파일**: `image_viewer_page.dart`

**책임**: PhotoView 기반 전체화면 보기

**주요 기능**:
```dart
class ImageViewerPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return PhotoView(
            imageProvider: CachedNetworkImageProvider(imageUrls[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2.0,
            enableRotation: false,
            backgroundDecoration: BoxDecoration(color: Colors.black),
          );
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
```

**특징**:
- 🔍 줌 인/아웃 지원 (min: contained, max: 2x)
- 📱 스와이프로 이미지 전환
- 🎨 검은색 배경

---

### 3. widgets/ - 재사용 가능 위젯

Creation Feature는 **4개 카테고리**로 위젯을 체계화했습니다:

#### 3.1 create_post/ - 질문 작성 전용

##### text_input_widget.dart
**책임**: 텍스트 입력 섹션 (제목, 설명, A/B 옵션)

**구성**:
```dart
class TextInputWidget extends StatelessWidget {
  final bool showOptionB;           // B 옵션 표시 여부
  final String validationSessionId; // 검증 세션 ID
  final Function(String)? onTitleChanged;
  final Function(String)? onDescriptionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 제목 입력
        SimpleValidatedField(
          config: FieldStyles.titleConfig,
          sessionId: validationSessionId,
          onChanged: onTitleChanged,
        ),

        // 설명 입력
        SimpleValidatedField(
          config: FieldStyles.descriptionConfig,
          sessionId: validationSessionId,
          onChanged: onDescriptionChanged,
        ),

        // A 옵션 입력
        SimpleValidatedField(
          config: FieldStyles.optionAConfig,
          sessionId: validationSessionId,
        ),

        // B 옵션 입력 (조건부)
        if (showOptionB)
          SimpleValidatedField(
            config: FieldStyles.optionBConfig,
            sessionId: validationSessionId,
          ),
      ],
    );
  }
}
```

**특징**:
- 📊 중앙 집중식 스타일 (FieldStyles)
- ✅ 실시간 유효성 검증
- 🔢 문자 수 카운터
- 🎨 에러 메시지 인라인 표시

##### image_selection_widget.dart
**책임**: 이미지 선택 섹션 (Smart Layout 시스템)

**구성**:
```dart
class ImageSelectionWidget extends StatelessWidget {
  final bool absellected;           // B박스 숨기기
  final bool isDynamic;             // Smart Layout 활성화
  final String validationSessionId;
  final Function(List<File>, String)? onImagesSelected;

  @override
  Widget build(BuildContext context) {
    return Consumer2<MediaSelectionProvider, MediaStateCoordinator>(
      builder: (context, selectionProvider, coordinator, child) {
        // Smart Layout 계산
        final layoutType = _determineLayoutType(
          selectionProvider.aspectRatiosA,
          selectionProvider.aspectRatiosB,
        );

        final boxSizes = _calculateBoxSizes(
          layoutType,
          selectionProvider.aspectRatiosA,
          selectionProvider.aspectRatiosB,
        );

        return Column(
          children: [
            // 레이아웃 디버그 정보 (개발 모드)
            if (kDebugMode)
              LayoutDebugInfo(
                layoutType: layoutType,
                boxSizes: boxSizes,
              ),

            // A/B 박스 배치
            if (layoutType == 'horizontal')
              Row(
                children: [
                  MediaSelectionBoxMulti(
                    box: 'A',
                    dynamicWidth: boxSizes.widthA,
                    dynamicHeight: boxSizes.heightA,
                  ),
                  if (!absellected)
                    MediaSelectionBoxMulti(
                      box: 'B',
                      dynamicWidth: boxSizes.widthB,
                      dynamicHeight: boxSizes.heightB,
                    ),
                ],
              )
            else
              Column(
                children: [
                  MediaSelectionBoxMulti(box: 'A', ...),
                  if (!absellected)
                    MediaSelectionBoxMulti(box: 'B', ...),
                ],
              ),

            // 경고 메시지 (A박스 비어있고 B박스 이미지 있을 때)
            if (_shouldShowWarning())
              WarningMessage(
                message: 'A 박스에 먼저 이미지를 추가해주세요',
              ),
          ],
        );
      },
    );
  }

  String _determineLayoutType(List<double> ratiosA, List<double> ratiosB) {
    if (ratiosA.isEmpty || ratiosB.isEmpty) return 'vertical';

    final avgA = ratiosA.reduce((a, b) => a + b) / ratiosA.length;
    final avgB = ratiosB.reduce((a, b) => a + b) / ratiosB.length;

    // 가로형 이미지들 → 세로 배치
    if (avgA > 1.2 && avgB > 1.2) return 'vertical';

    // 세로형 이미지들 → 가로 배치
    if (avgA < 0.8 && avgB < 0.8) return 'horizontal';

    // 혼합형 → 더 극단적인 쪽 우선
    return avgA < avgB ? 'horizontal' : 'vertical';
  }
}
```

**Smart Layout 시스템**:
1. aspect ratio 분석 → 레이아웃 타입 결정
2. DynamicBoxCalculator로 박스 크기 계산
3. 실시간 업데이트 (Consumer 패턴)

#### 3.2 components/ - 공통 컴포넌트

##### base_media_selection_box.dart (Mixin 패턴)
**책임**: MediaSelectionBox 공통 로직 추출

```dart
mixin BaseMediaSelectionBoxMixin on State {
  String get box; // 'A' or 'B'

  /// 미디어 선택 플로우 시작
  Future<void> handleMediaSelection() async {
    final mediaType = await _showMediaTypeSelection();

    if (mediaType == null) return;

    if (mediaType == 'image') {
      await _openImagePicker();
    } else if (mediaType == 'video') {
      await _openVideoPicker();
    }
  }

  Future<String?> _showMediaTypeSelection() async {
    return showModalBottomSheet<String>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.photo),
            title: Text('이미지'),
            onTap: () => Navigator.pop(context, 'image'),
          ),
          ListTile(
            leading: Icon(Icons.videocam),
            title: Text('비디오'),
            onTap: () => Navigator.pop(context, 'video'),
          ),
        ],
      ),
    );
  }

  Future<void> _openImagePicker() async {
    final assets = await AssetPicker.pickAssets(
      context,
      pickerConfig: AssetPickerConfig(
        maxAssets: 4,
        requestType: RequestType.image,
        textDelegate: KoreanAssetPickerTextDelegate(),
      ),
    );

    if (assets != null && assets.isNotEmpty) {
      final coordinator = context.read<MediaStateCoordinator>();
      await coordinator.processMediaSelection(
        box: box,
        assets: assets,
        validateContent: true,
        autoUpload: true,
      );
    }
  }

  /// 이미지 삭제
  void handleImageDelete(int index) {
    final provider = context.read<MediaSelectionProvider>();
    provider.removeImage(box, index);
  }

  /// 이미지 편집
  Future<void> handleImageEdit(int index) async {
    final provider = context.read<MediaSelectionProvider>();
    final imageUrl = box == 'A'
        ? provider.uploadedUrlsA[index]
        : provider.uploadedUrlsB[index];

    final editedUrl = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProImageEditorPage(
          imageUrl: imageUrl,
          box: box,
          assetId: provider.assetEntityIdsA[index],
          isEditMode: true,
        ),
      ),
    );

    if (editedUrl != null) {
      provider.updateImageUrl(box, index, editedUrl);
    }
  }
}
```

**재사용**:
```dart
class MediaSelectionBoxSingle extends StatefulWidget {
  final String box;
  final double? dynamicWidth;
  final double? dynamicHeight;

  @override
  State<MediaSelectionBoxSingle> createState() => _MediaSelectionBoxSingleState();
}

class _MediaSelectionBoxSingleState extends State<MediaSelectionBoxSingle>
    with BaseMediaSelectionBoxMixin {
  @override
  String get box => widget.box;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: handleMediaSelection,
      child: Container(
        width: widget.dynamicWidth ?? 300,
        height: widget.dynamicHeight ?? 300,
        // ...
      ),
    );
  }
}
```

##### media_selection_box_multi.dart
**책임**: 멀티 이미지 박스 (PageView 기반)

**구성**:
```dart
class MediaSelectionBoxMulti extends StatefulWidget {
  final String box;
  final double? dynamicWidth;
  final double? dynamicHeight;

  @override
  State<MediaSelectionBoxMulti> createState() => _MediaSelectionBoxMultiState();
}

class _MediaSelectionBoxMultiState extends State<MediaSelectionBoxMulti>
    with BaseMediaSelectionBoxMixin {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<MediaSelectionProvider>(
      builder: (context, provider, child) {
        final imageUrls = widget.box == 'A'
            ? provider.uploadedUrlsA
            : provider.uploadedUrlsB;

        if (imageUrls.isEmpty) {
          // 플러스 아이콘 표시
          return GestureDetector(
            onTap: handleMediaSelection,
            child: Container(
              child: Icon(Icons.add, size: 64),
            ),
          );
        }

        return Stack(
          children: [
            // PageView (이미지 스와이프)
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    // 전체화면 뷰어
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageViewerPage(
                          imageUrls: imageUrls,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.cover,
                    memCacheWidth: _calculateMemCacheWidth(),
                    placeholder: (context, url) => Container(
                      color: Colors.grey[300],
                    ),
                    fadeInDuration: Duration(milliseconds: 150),
                  ),
                );
              },
            ),

            // 페이지 인디케이터
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(imageUrls.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == index
                          ? Colors.white
                          : Colors.white.withOpacity(0.5),
                    ),
                  );
                }),
              ),
            ),

            // 우측 상단 X 아이콘 (삭제)
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => handleImageDelete(_currentIndex),
                child: Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),

            // 우측 하단 액션 아이콘들
            if (imageUrls.isNotEmpty)
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  children: [
                    // B박스 표시/숨기기
                    if (widget.box == 'A')
                      _ActionIcon(
                        icon: Icons.add,
                        onTap: () => _toggleBoxVisibility(),
                      ),

                    SizedBox(width: 8),

                    // 이미지 추가
                    _ActionIcon(
                      icon: Icons.add_photo_alternate,
                      onTap: handleMediaSelection,
                    ),

                    SizedBox(width: 8),

                    // 이미지 편집
                    _ActionIcon(
                      icon: Icons.edit,
                      onTap: () => handleImageEdit(_currentIndex),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
```

**특징**:
- 📱 PageView로 멀티 이미지 스와이프
- 🎯 페이지 인디케이터 (현재 이미지 표시)
- ✏️ 우측 하단 액션 아이콘 (B박스 표시, 이미지 추가, 편집)
- 🗑️ 우측 상단 X 아이콘 (삭제)

##### next_button.dart
**책임**: 다음 버튼 (제출 버튼)

```dart
class NextButton extends StatelessWidget {
  final bool showButton;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!showButton) {
      return SizedBox.shrink();
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).primaryColor,
        minimumSize: Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: onPressed == null
          ? CircularProgressIndicator(color: Colors.white)
          : Text(
              '다음',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
    );
  }
}
```

**특징**:
- 🎯 canSubmit 상태 기반 활성화/비활성화
- 🔄 로딩 중 CircularProgressIndicator 표시
- 📏 전체 너비 버튼

##### simple_validated_field.dart
**책임**: 유효성 검증 입력 필드

```dart
class SimpleValidatedField extends StatefulWidget {
  final FieldConfig config;
  final String sessionId;
  final Function(String)? onChanged;

  @override
  State<SimpleValidatedField> createState() => _SimpleValidatedFieldState();
}

class _SimpleValidatedFieldState extends State<SimpleValidatedField> {
  final TextEditingController _controller = TextEditingController();
  String? _errorMessage;
  bool _hasValidated = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.config.hintText,
            errorText: _hasValidated ? _errorMessage : null,
            suffixIcon: CharacterCountDisplay(
              currentLength: _controller.text.length,
              maxLength: widget.config.maxLength,
            ),
          ),
          maxLength: widget.config.maxLength,
          maxLines: widget.config.maxLines,
          onChanged: (text) {
            setState(() {
              _errorMessage = _validate(text);
            });
            widget.onChanged?.call(text);
          },
        ),

        // 에러 메시지 (필드 아래 인라인 표시)
        if (_hasValidated && _errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  String? _validate(String text) {
    if (widget.config.isRequired && text.isEmpty) {
      return '${widget.config.label}은(는) 필수 항목입니다';
    }

    if (text.length > widget.config.maxLength) {
      return '최대 ${widget.config.maxLength}자까지 입력 가능합니다';
    }

    return null;
  }

  void triggerValidation() {
    setState(() {
      _hasValidated = true;
      _errorMessage = _validate(_controller.text);
    });
  }
}
```

**특징**:
- ✅ 실시간 유효성 검증
- 🔢 문자 수 카운터 (suffixIcon)
- 📝 에러 메시지 인라인 표시
- 🎯 다음 버튼 클릭 시 `triggerValidation()` 호출

#### 3.3 dialogs/ - 모달 다이얼로그

##### target_audience_dialog.dart
**책임**: 타겟 오디언스 선택 다이얼로그

**구성**:
```dart
class TargetAudienceDialog {
  static Future<TargetAudience?> show(BuildContext context) async {
    return showDialog<TargetAudience>(
      context: context,
      builder: (context) => _TargetAudienceDialogContent(),
    );
  }
}

class _TargetAudienceDialogContent extends StatefulWidget {
  @override
  State<_TargetAudienceDialogContent> createState() =>
      _TargetAudienceDialogContentState();
}

class _TargetAudienceDialogContentState
    extends State<_TargetAudienceDialogContent> {
  int _currentStep = 0;
  String _selectedMode = 'quick';
  int _targetCount = 10;
  Map<String, dynamic> _filters = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('타겟 오디언스 선택'),
      content: SizedBox(
        width: double.maxFinite,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _nextStep,
          onStepCancel: _previousStep,
          steps: [
            // Step 1: Collection Type 선택
            Step(
              title: Text('모드 선택'),
              content: CollectionTypeSelector(
                selectedMode: _selectedMode,
                onModeChanged: (mode) {
                  setState(() {
                    _selectedMode = mode;
                  });
                },
              ),
            ),

            // Step 2: Target Count 선택
            Step(
              title: Text('목표 인원'),
              content: TargetCountSelector(
                targetCount: _targetCount,
                onCountChanged: (count) {
                  setState(() {
                    _targetCount = count;
                  });
                },
              ),
            ),

            // Step 3: Detailed Target (Custom 모드만)
            if (_selectedMode == 'custom')
              Step(
                title: Text('상세 조건'),
                content: DetailedTargetSelector(
                  filters: _filters,
                  onFiltersChanged: (filters) {
                    setState(() {
                      _filters = filters;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: _currentStep == _maxStep ? _confirm : _nextStep,
          child: Text(_currentStep == _maxStep ? '확인' : '다음'),
        ),
      ],
    );
  }

  int get _maxStep {
    return _selectedMode == 'custom' ? 2 : 1;
  }

  void _nextStep() {
    if (_currentStep < _maxStep) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _confirm() {
    final targetAudience = TargetAudience(
      mode: _selectedMode,
      targetCount: _targetCount,
      filters: _selectedMode == 'custom' ? _filters : null,
    );

    Navigator.pop(context, targetAudience);
  }
}
```

**특징**:
- 🎯 Stepper 기반 단계별 선택
- 🔄 모드에 따라 동적 단계 조정 (custom은 3단계, 나머지는 2단계)
- 📊 4가지 모드 지원 (quick, public, custom, test)

---

### 4. delegates/ - 커스텀 델리게이트

#### 4.1 korean_asset_picker_delegate.dart

**책임**: wechat_assets_picker 한국어 번역

```dart
class KoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get edit => '편집';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => '불러오기 실패';

  @override
  String get original => '원본';

  @override
  String get preview => '미리보기';

  @override
  String get select => '선택';

  @override
  String get emptyList => '목록이 비어있습니다';

  @override
  String get unSupportedAssetType => '지원하지 않는 형식입니다';

  @override
  String get unableToAccessAll => '모든 파일에 접근할 수 없습니다';

  @override
  String get viewingLimitedAssetsTip => '일부 파일만 볼 수 있습니다';

  @override
  String get changeAccessibleLimitedAssets => '접근 가능한 파일 변경';

  @override
  String get accessAllTip => '앱이 기기의 일부 파일에만 접근할 수 있습니다. '
      '시스템 설정으로 이동하여 모든 미디어에 접근할 수 있도록 허용해주세요.';

  @override
  String get goToSystemSettings => '시스템 설정으로 이동';

  @override
  String get accessLimitedAssets => '제한된 접근으로 계속';

  @override
  String get accessiblePathName => '접근 가능한 파일';

  @override
  String get sTypeAudioLabel => '오디오';

  @override
  String get sTypeImageLabel => '이미지';

  @override
  String get sTypeVideoLabel => '비디오';

  @override
  String get sTypeOtherLabel => '기타';

  @override
  String get sActionPlayHint => '재생';

  @override
  String get sActionPreviewHint => '미리보기';

  @override
  String get sActionSelectHint => '선택';

  @override
  String get sActionSwitchPathLabel => '경로 변경';

  @override
  String get sActionUseCameraHint => '카메라 사용';

  @override
  String get sNameDurationLabel => '재생 시간';

  @override
  String get sUnitAssetCountLabel => '개';
}
```

#### 4.2 camera_floating_button_delegate.dart

**책임**: 카메라 버튼 위치 커스터마이징

```dart
class CameraFloatingButtonDelegate extends AssetPickerBuilderDelegate {
  @override
  Widget bottomActionBar(BuildContext context) {
    return Container(
      height: 90,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 카메라 버튼 (좌측)
          _buildCameraButton(context),

          // 확인 버튼 (우측)
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            textDelegate: KoreanCameraPickerTextDelegate(),
          ),
        );

        if (result != null) {
          // 촬영한 이미지 추가
          provider.selectedAssets = [...provider.selectedAssets, result];
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.grey[800],
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(provider.selectedAssets);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '확인 (${provider.selectedAssets.length})',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
```

---

### 5. constants/ - UI 상수

Creation Feature는 **7개 constants 파일**로 UI 스타일을 중앙 집중 관리합니다:

#### 5.1 field_styles.dart (핵심)

**책임**: 모든 입력 필드의 스타일 중앙 집중 관리

```dart
/// Field configuration model
/// 필드 설정 모델
class FieldConfig {
  final String label;
  final String hintText;
  final int maxLength;
  final int maxLines;
  final int minLines;
  final bool isRequired;
  final TextStyle? textStyle;
  final InputDecoration? decoration;

  const FieldConfig({
    required this.label,
    required this.hintText,
    required this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.isRequired = true,
    this.textStyle,
    this.decoration,
  });
}

/// Centralized field styles
/// 중앙 집중식 필드 스타일
class FieldStyles {
  // Base text style
  static const TextStyle baseTextStyle = TextStyle(
    fontSize: 16,
    height: 1.5,
  );

  // Field configurations
  static const FieldConfig titleConfig = FieldConfig(
    label: '제목',
    hintText: '질문 제목을 입력하세요',
    maxLength: 100,
    maxLines: 1,
    isRequired: true,
  );

  static const FieldConfig descriptionConfig = FieldConfig(
    label: '설명',
    hintText: '질문에 대한 설명을 입력하세요',
    maxLength: 500,
    maxLines: 4,
    minLines: 1,
    isRequired: false,
  );

  static const FieldConfig optionAConfig = FieldConfig(
    label: 'A 옵션',
    hintText: 'A 옵션 텍스트',
    maxLength: 200,
    maxLines: 2,
    isRequired: false,
  );

  static const FieldConfig optionBConfig = FieldConfig(
    label: 'B 옵션',
    hintText: 'B 옵션 텍스트',
    maxLength: 200,
    maxLines: 2,
    isRequired: false,
  );

  // Input decoration factory
  static InputDecoration buildDecoration(FieldConfig config) {
    return InputDecoration(
      hintText: config.hintText,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
      ),
    );
  }
}
```

**특징**:
- 🎯 단일 진실 공급원 (Single Source of Truth)
- 📏 모든 필드 설정 한 곳에서 관리
- 🔧 쉬운 유지보수 (스타일 변경 시 한 곳만 수정)

#### 5.2 dimensions.dart

```dart
class Dimensions {
  // Padding
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;

  // Margin
  static const double marginSmall = 8.0;
  static const double marginMedium = 16.0;
  static const double marginLarge = 24.0;

  // Box sizes
  static const double defaultBoxSize = 300.0;
  static const double minBoxSize = 200.0;
  static const double maxBoxSize = 600.0;

  // Icon sizes
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 32.0;

  // Border radius
  static const double borderRadiusSmall = 4.0;
  static const double borderRadiusMedium = 8.0;
  static const double borderRadiusLarge = 16.0;
}
```

#### 5.3 colors.dart

```dart
class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryDark = Color(0xFF1976D2);
  static const Color primaryLight = Color(0xFFBBDEFB);

  // Accent colors
  static const Color accent = Color(0xFFFF5722);

  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);

  // Background colors
  static const Color backgroundLight = Color(0xFFFAFAFA);
  static const Color backgroundDark = Color(0xFF303030);

  // Error colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorLight = Color(0xFFEF5350);

  // Success colors
  static const Color success = Color(0xFF388E3C);
  static const Color successLight = Color(0xFF66BB6A);
}
```

#### 5.4 image_constants.dart

```dart
class ImageConstants {
  // Max images per option
  static const int maxImagesPerOption = 4;

  // Image sizes (for caching)
  static const int thumbnailSize = 150;
  static const int displaySize = 800;

  // Cache widths
  static const int memCacheWidthSmall = 400;
  static const int memCacheWidthMedium = 800;
  static const int memCacheWidthLarge = 1600;
}
```

#### 5.5 animation_constants.dart

```dart
class AnimationConstants {
  // Durations
  static const Duration shortDuration = Duration(milliseconds: 150);
  static const Duration mediumDuration = Duration(milliseconds: 300);
  static const Duration longDuration = Duration(milliseconds: 500);

  // Shake animation
  static const Duration shakeDuration = Duration(milliseconds: 200);
  static const double shakeOffset = 8.0;

  // Fade animation
  static const Duration fadeInDuration = Duration(milliseconds: 150);
}
```

#### 5.6 strings.dart

```dart
class Strings {
  // Common
  static const String confirm = '확인';
  static const String cancel = '취소';
  static const String next = '다음';
  static const String previous = '이전';

  // Validation
  static const String requiredField = '필수 항목입니다';
  static const String maxLengthExceeded = '최대 길이를 초과했습니다';

  // Error messages
  static const String uploadFailed = '업로드에 실패했습니다';
  static const String moderationFailed = 'AI 검열에 실패했습니다';
  static const String networkError = '네트워크 오류가 발생했습니다';
}
```

#### 5.7 text_limits.dart

```dart
class TextLimits {
  static const int titleMaxLength = 100;
  static const int descriptionMaxLength = 500;
  static const int optionMaxLength = 200;
}
```

---

## 🔗 관련 문서

### Creation Feature 문서
- [📱 FEATURE_OVERVIEW.md](../docs/FEATURE_OVERVIEW.md) - 기능 개요 및 사용자 플로우
- [📖 API_REFERENCE.md](../docs/API_REFERENCE.md) - API 인터페이스 상세
- [🚀 USAGE_GUIDE.md](../docs/USAGE_GUIDE.md) - 실제 사용 예제 및 가이드
- [🗄️ Data Layer README](../data/README.md) - Data Layer 아키텍처
- [🎯 Domain Layer README](../domain/README.md) - Domain Layer 아키텍처

### Presentation 서브디렉토리 문서
- [Providers README](./providers/README.md) - Provider 상세
- [Screens README](./screens/README.md) - 화면 상세
- [Widgets README](./widgets/README.md) - 위젯 상세

### Phase 문서
- [Phase 5 MediaStateCoordinator](../../../docs/phases/phase5_media_state.md) - 미디어 상태 관리

### 참고 문서
- [Auth Feature Presentation Layer](../../auth/presentation/README.md) - Auth 참고 구조
- [Clean Architecture v4.0](../../../docs/architecture/clean_architecture_v4.md)
- [Provider Pattern Guide](../../../docs/patterns/provider_pattern.md)
