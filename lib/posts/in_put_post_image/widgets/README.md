# 🎨 InPutPostImage Widgets 디렉토리

> 이미지 게시물 작성을 위한 고급 UI 위젯 컴포넌트 모음

## 🎯 개요

이 디렉토리는 이미지 게시물 작성 플로우에서 사용되는 핵심 위젯들을 포함합니다. 미디어 선택, 편집, 업로드부터 다이얼로그까지 전체 사용자 경험을 담당하는 UI 컴포넌트들로 구성되어 있습니다.

### 주요 특징
- 📷 **미디어 선택/편집**: 갤러리 선택부터 고급 이미지 편집까지
- 🎬 **플로우 관리**: 단계별 미디어 처리 워크플로우
- 🎯 **타겟팅 시스템**: AI 기반 투표 타겟 설정
- 🛡️ **콘텐츠 검열**: AI 모더레이션 통합
- 🎨 **일관된 UX**: AppTheme 기반 통일된 디자인

## 📐 네이밍 컨벤션

| 구분 | 규칙 | 예시 |
|------|------|------|
| **파일명** | snake_case | `media_editor_widget.dart` |
| **클래스명** | PascalCase | `MediaEditorWidget` |
| **메서드명** | camelCase | `handleImageEditingComplete()` |
| **변수명** | camelCase | `selectedFile` |
| **상수** | camelCase | `dialogMaxHeight` |
| **Private** | _접두사 | `_buildEditorPage()` |

> 상세 규칙은 [프로젝트 네이밍 컨벤션](../../../../NAMING_CONVENTION.md) 참조

## 📁 디렉토리 구조

```
widgets/
├── media_editor_widget.dart           # ProImageEditor 통합 이미지 편집기
├── media_selection_flow_widget.dart   # 미디어 선택/편집 통합 플로우
├── thumbnail_navigation_helper.dart   # 썸네일 네비게이션 헬퍼
├── dialogs/                           # 다이얼로그 위젯 모음
│   ├── moderation_dialog.dart
│   ├── moderation_error_dialog.dart
│   ├── target_audience_dialog.dart
│   ├── target_audience_steps/        # 타겟 설정 단계별 UI
│   └── README.md
└── README.md                          # 현재 문서
```

## 🔧 주요 구성요소

### 1. MediaEditorWidget (`media_editor_widget.dart`)

#### 개요
ProImageEditor를 통합한 고급 이미지 편집 위젯입니다. 편집 후 AI 검열과 Firebase Storage 업로드를 자동으로 처리합니다.

#### 주요 기능
- **고급 편집 도구**: 페인트, 텍스트, 필터, 자르기, 회전, 이모지
- **AI 검열 통합**: 편집 완료 시 자동 콘텐츠 검증
- **멀티 이미지 지원**: 여러 이미지 동시 편집 및 처리
- **에러 처리**: 검열 실패 시 상세한 피드백 제공
- **비율 계산**: 편집된 이미지의 aspect ratio 자동 계산

#### 핵심 구성

##### 편집 완료 처리
```dart
Future<void> _handleImageEditingComplete(Uint8List bytes) async {
  // 1. 편집된 이미지를 File로 저장
  final editedFile = await _saveEditedImageAsFile(bytes);
  
  // 2. 비율 계산
  final aspectRatio = await _calculateImageAspectRatio(bytes);
  
  // 3. ImageUploadOrchestratorV2로 처리
  final orchestrator = ImageUploadOrchestratorV2(
    context: context,
    appState: appState,
    box: widget.box,
    model: widget.model,
  );
  
  // 4. 검열 및 업로드
  final result = await orchestrator.handleMultiImageProcess(
    editedImageFile: editedFile,
    allFiles: widget.allSelectedFiles,
    currentEditIndex: widget.currentEditIndex,
    // ...
  );
  
  // 5. 결과 처리
  if (!result.success || result.allRejected) {
    _showToast(_buildRejectionMessage(result), isError: true);
  }
}
```

##### 거부 메시지 생성
```dart
String _buildRejectionMessage(
  ImageProcessResult result, 
  {ModerationResult? moderationResult}
) {
  // 텍스트 vs 이미지 문제 구분
  if (moderationResult?.hasText && 
      textReasons.contains(moderationResult.reason)) {
    return '편집된 텍스트가 부적절합니다: ${moderationResult.reason}';
  }
  
  if (imageReasons.contains(moderationResult?.reason)) {
    return '이미지가 부적절합니다: ${moderationResult.reason}';
  }
  
  return '콘텐츠가 부적절합니다: ${moderationResult?.reason}';
}
```

##### ProImageEditor 설정
```dart
ProImageEditor.file(
  widget.selectedFile,
  callbacks: ProImageEditorCallbacks(
    onImageEditingComplete: _handleImageEditingComplete,
  ),
  configs: ProImageEditorConfigs(
    i18n: I18n(
      various: I18nVarious(
        loadingDialogMsg: "안전성 검사중 입니다...",
      ),
    ),
    blurEditor: BlurEditorConfigs(enabled: false),
    paintEditor: PaintEditorConfigs(
      enableModeRect: false,
      enableModePolygon: false,
      enableModePixelate: false,
      enableModeLine: false,
    ),
  ),
)
```

#### 사용 예시
```dart
MediaEditorWidget(
  selectedFile: imageFile,
  allSelectedFiles: allFiles,
  selectedAssets: assets,
  currentEditIndex: 0,
  box: 'A',
  isAddMode: false,
  startWithEditor: true,
  onSingleComplete: (imageUrl) {
    print('편집 완료: $imageUrl');
  },
  onMultiComplete: (imageUrls) {
    print('멀티 편집 완료: ${imageUrls.length}개');
  },
)
```

### 2. MediaSelectionFlowWidget (`media_selection_flow_widget.dart`)

#### 개요
미디어 선택부터 편집까지 전체 플로우를 관리하는 통합 위젯입니다. wechat_assets_picker와 MediaEditorWidget을 연결합니다.

#### 주요 기능
- **갤러리 통합**: wechat_assets_picker로 이미지 선택
- **카메라 지원**: 플로팅 카메라 버튼으로 즉시 촬영
- **멀티 선택**: 최대 4개 이미지 동시 선택
- **썸네일 선택**: 대표 이미지 선택 페이지
- **상태 복원**: AssetEntity ID 기반 선택 상태 유지
- **권한 처리**: 갤러리/카메라 권한 자동 요청

#### 핵심 구성

##### AssetPicker 설정
```dart
Future<void> _openPicker() async {
  // 1. 권한 확인
  final permission = await PhotoManager.requestPermissionExtend();
  
  // 2. 기존 선택 복원
  List<AssetEntity> selectedAssets = [];
  if (widget.existingAssetIds != null) {
    for (String id in widget.existingAssetIds!) {
      final asset = await AssetEntity.fromId(id);
      if (asset != null) selectedAssets.add(asset);
    }
  }
  
  // 3. 피커 열기
  final result = await AssetPicker.pickAssetsWithDelegate(
    context,
    delegate: CameraFloatingButtonDelegate(
      provider: DefaultAssetPickerProvider(
        selectedAssets: selectedAssets,
        maxAssets: 4,
        requestType: RequestType.image,
        sortPathsByModifiedDate: true,
      ),
      gridCount: 4,
      shouldRevertGrid: false,  // 최신 사진 맨 위
      onCameraPressed: () async {
        // 카메라 열기
        final cameraResult = await _openCameraForPicker(context);
        if (cameraResult != null) {
          _selectedAssets.add(cameraResult);
        }
      },
    ),
  );
}
```

##### 선택 결과 처리
```dart
Future<void> _processSelectionResult(
  List<AssetEntity> selectedAssets
) async {
  // 추가 모드 또는 기존 이미지가 있는 경우
  if (widget.isAddMode || widget.existingImageUrls?.isNotEmpty) {
    // diff 처리 후 모달 닫기
    Navigator.pop(context, {
      'action': 'processing',
      'selectedAssets': selectedAssets
    });
    return;
  }
  
  // 단일 선택 → 바로 편집
  if (selectedAssets.length == 1) {
    final file = await selectedAssets.first.file;
    setState(() {
      _selectedFile = file;
      _selectedAssets = selectedAssets;
    });
  } else {
    // 멀티 선택 → 썸네일 선택
    _navigateToThumbnailSelection(files);
  }
}
```

##### 권한 처리
```dart
if (permission.isAuth != true) {
  // 권한 거부 시 설정 이동 다이얼로그
  final openSettings = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('사진 접근 권한'),
      content: Text('갤러리 접근 권한이 필요합니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('설정으로 이동'),
        ),
      ],
    ),
  );
  
  if (openSettings == true) {
    await PhotoManager.openSetting();
  }
}
```

#### 사용 예시
```dart
// 새 이미지 선택
MediaSelectionFlowWidget(
  box: 'A',
  onComplete: (imageUrl) {
    print('이미지 URL: $imageUrl');
  },
  onFileComplete: (imageFile) {
    print('이미지 파일: ${imageFile.path}');
  },
)

// 기존 이미지 편집
MediaSelectionFlowWidget(
  box: 'B',
  initialImageFile: existingFile,
  startWithEditor: true,
  existingAssetIds: ['asset_id_1', 'asset_id_2'],
  onComplete: (imageUrl) {
    print('편집 완료: $imageUrl');
  },
)
```

### 3. ThumbnailNavigationHelper (`thumbnail_navigation_helper.dart`)

#### 개요
썸네일 선택 페이지와의 네비게이션을 관리하는 헬퍼 클래스입니다.

#### 주요 기능
- **결과 처리**: 썸네일 선택 결과 해석
- **액션 분기**: 뒤로가기, 선택, 취소 처리
- **콜백 관리**: 각 액션에 대한 콜백 실행

#### 핵심 메서드
```dart
static void handleThumbnailResult({
  required Map<String, dynamic>? result,
  required bool mounted,
  required List<File> files,
  required Function(String action) onBackToPicker,
  required Function({
    required File selectedFile,
    required int currentEditIndex,
    required List<File> allSelectedFiles,
  }) onImageSelected,
  required VoidCallback onCancel,
}) {
  if (result != null && mounted) {
    if (result['action'] == 'back_to_picker') {
      // 피커로 돌아가기
      onBackToPicker('back_to_picker');
    } else if (result['selectedIndex'] != null) {
      // 이미지 선택됨
      final selectedIndex = result['selectedIndex'] as int;
      onImageSelected(
        selectedFile: files[selectedIndex],
        currentEditIndex: selectedIndex,
        allSelectedFiles: files,
      );
    }
  } else {
    // 취소
    if (mounted) onCancel();
  }
}
```

### 4. Dialogs 하위 디렉토리

다이얼로그 관련 위젯들은 별도 디렉토리로 관리됩니다.

- **구조**: `dialogs/` 디렉토리 하위에 모든 다이얼로그 위젯 배치
- **문서**: 상세 내용은 [dialogs/README.md](./dialogs/README.md) 참조
- **주요 구성**:
  - `moderation_dialog.dart` - AI 검열 진행 표시
  - `moderation_error_dialog.dart` - 검열 실패 경고
  - `target_audience_dialog.dart` - 타겟 설정 메인
  - `target_audience_steps/` - 단계별 설정 UI

## 💡 통합 사용 예시

### 전체 이미지 게시물 작성 플로우
```dart
class ImagePostCreationFlow {
  final AppState appState;
  final BuildContext context;
  
  Future<void> startCreation() async {
    // 1. 미디어 선택 플로우 시작
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MediaSelectionFlowWidget(
        box: 'A',
        onComplete: (imageUrl) {
          // 2. 이미지 업로드 완료
          appState.addToUploadImageA(imageUrl);
        },
        onFileComplete: (imageFile) {
          // File 객체도 저장
          appState.addToUploadImageFileA(imageFile);
        },
      ),
    );
    
    // 3. 타겟 오디언스 설정
    final targetSettings = await TargetAudienceDialog.show(context);
    
    if (targetSettings != null) {
      // 4. 게시물 생성
      await _createPost(targetSettings);
    }
  }
  
  Future<void> _createPost(Map<String, dynamic> settings) async {
    // 게시물 생성 로직
    final post = PostModel(
      imageUrlsA: appState.uploadImageA,
      imageUrlsB: appState.uploadImageB,
      targetAudience: settings,
      // ...
    );
    
    await FirebaseFirestore.instance
        .collection('posts')
        .add(post.toMap());
  }
}
```

### 이미지 편집 전용 사용
```dart
// 기존 이미지 편집
void editExistingImage(File imageFile) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MediaEditorWidget(
        selectedFile: imageFile,
        allSelectedFiles: [],
        selectedAssets: [],
        currentEditIndex: 0,
        box: 'A',
        isAddMode: false,
        startWithEditor: true,
        onSingleComplete: (url) {
          print('편집 완료: $url');
          Navigator.pop(context);
        },
      ),
    ),
  );
}
```

## 🎨 UI/UX 특징

### 시각적 일관성
- **다크 테마**: 검은색 배경의 일관된 다크 UI
- **Primary 색상**: AppTheme의 primary 색상 활용
- **BorderRadius**: 8-20px의 일관된 모서리 반경
- **Toast 메시지**: BotToast로 통일된 피드백

### 애니메이션
- **페이지 전환**: NoAnimationPageRoute로 즉각적 전환
- **ProImageEditor**: 내장 애니메이션 효과
- **다이얼로그**: FadeTransition 효과

### 에러 처리
- **구체적 메시지**: 텍스트/이미지 문제 구분 표시
- **재시도 옵션**: 검열 실패 시 재선택 가능
- **권한 가이드**: 설정 이동 옵션 제공

## 📊 상태 관리

### AppState 통합
```dart
// 이미지 URL 저장
appState.addToUploadImageA(imageUrl);
appState.addToUploadImageB(imageUrl);

// 파일 객체 저장
appState.addToUploadImageFileA(file);
appState.addToUploadImageFileB(file);

// 비율 저장
appState.addToUploadImageAspectRatioA(ratio);
appState.addToUploadImageAspectRatioB(ratio);

// AssetEntity ID 저장
appState.addToAssetEntityIdsA(assetId);
appState.addToAssetEntityIdsB(assetId);
```

### InPutPostImageModel 활용
```dart
// 모델을 통한 상태 전달
MediaEditorWidget(
  model: InPutPostImageModel(),
  // ...
)
```

## 🐛 디버그 로깅

### 로그 패턴
```dart
print('[위젯명] 동작: 상세 정보');
// 예시
print('[MediaEditor] onImageEditingComplete 호출됨');
print('[MediaEditor] allSelectedFiles 수: ${files.length}');
print('[AssetPicker] Permission state: $permission');
```

### 주요 로그 포인트
- 권한 요청 결과
- 이미지 선택/편집 상태
- AI 검열 결과
- 업로드 진행 상황

## 🔄 변경 이력

### v2.0.0 (2025-08-20)
- MediaEditorWidget 구조 개선
- AI 검열 메시지 세분화
- 멀티 이미지 편집 지원 강화

### v1.5.0 (2025-08-15)
- MediaSelectionFlowWidget 통합
- wechat_assets_picker 통합
- 카메라 플로팅 버튼 추가

### v1.0.0 (2025-08-01)
- 초기 버전 릴리즈
- ProImageEditor 통합
- 기본 이미지 편집 기능

## 📊 성능 고려사항

### 메모리 관리
- **이미지 캐싱**: CachedNetworkImage 사용
- **임시 파일 정리**: dispose()에서 임시 파일 삭제
- **Provider 범위**: 필요한 범위만 감싸기

### 비동기 처리
- **병렬 처리**: Future.wait으로 멀티 이미지 동시 처리
- **에러 복구**: try-catch로 안전한 처리
- **상태 확인**: mounted 체크로 메모리 누수 방지

## 🚀 향후 개선 계획

### 계획된 기능
1. **비디오 지원**: 비디오 선택 및 편집 기능
2. **필터 프리셋**: 자주 사용하는 필터 저장
3. **배치 편집**: 여러 이미지 동시 편집
4. **클라우드 백업**: 편집 히스토리 저장

### 기술적 개선
- 위젯 테스트 추가
- 성능 프로파일링
- 접근성 레이블 강화
- 국제화 지원 확대

## 📚 참고 자료

- [ProImageEditor 문서](https://pub.dev/packages/pro_image_editor)
- [WeChat Assets Picker](https://pub.dev/packages/wechat_assets_picker)
- [Flutter 권한 처리](https://flutter.dev/docs/development/packages-and-plugins/using-packages)
- [하위 디렉토리 문서](./dialogs/README.md)

---

*이 문서는 InPutPostImage Widgets 디렉토리의 구조와 사용법을 설명합니다.*
*최종 업데이트: 2025-08-23*