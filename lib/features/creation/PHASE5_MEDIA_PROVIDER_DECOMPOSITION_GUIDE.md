# Phase 5: Media Provider 상태 관리 분해 가이드

**버전**: 1.0.0
**작성일**: 2025-01-28
**대상 파일**: 미디어 관련 Provider 통합 및 분해
**전략**: 상태 영역별 책임 분리 및 Clean Architecture 통합

## 🎯 목표

기존 분산된 미디어 관련 상태 관리를 4개의 명확한 영역으로 분해하여:
- **단일 책임 원칙** 준수
- **상태 불변성** 보장
- **Provider 간 느슨한 결합**
- **기존 Creation Feature와 완벽한 통합**

## 📊 현재 상태 분석

### 기존 미디어 관련 Provider 현황
```yaml
현재 분산된 상태:
  CreatePostProviderV2:
    - 367줄 (미디어 + 게시물 상태 혼재)
    - uploadImageA/B 리스트
    - aspectRatioA/B 관리
    - 업로드 진행 상태

  InPutPostImageModel:
    - 이미지 선택 상태
    - 현재 인덱스 관리
    - 레이아웃 타입

  AppState:
    - 전역 미디어 상태
    - 임시 저장 상태

문제점:
  - 상태가 여러 곳에 분산
  - 책임 경계 불명확
  - 동기화 어려움
  - 테스트 복잡도 높음
```

## 🏗️ 분해 전략: 4개 상태 영역

### 1. Media Selection Provider (`media_selection_provider.dart`)
```dart
/// 미디어 선택 상태 전담 관리
/// Creation feature의 이미지/비디오 선택 로직
class MediaSelectionProvider extends ChangeNotifier {
  // 상태
  List<AssetEntity> _selectedMediaA = [];
  List<AssetEntity> _selectedMediaB = [];
  int _currentIndexA = 0;
  int _currentIndexB = 0;
  MediaSelectionMode _mode = MediaSelectionMode.single;

  // 선택 제약
  static const int maxImages = 4;
  static const int maxVideos = 1;

  // 액션 메서드
  Future<void> selectMedia({
    required MediaBox box,
    required List<AssetEntity> assets,
  }) async {
    // 기존 CreatePostProviderV2의 선택 로직 흡수
  }

  void deselectMedia({
    required MediaBox box,
    required int index,
  }) {
    // 선택 해제 및 상태 업데이트
  }

  void reorderMedia({
    required MediaBox box,
    required int oldIndex,
    required int newIndex,
  }) {
    // 미디어 순서 변경
  }

  void clearSelection({MediaBox? box}) {
    // 선택 초기화
  }
}
```

### 2. Media Upload Provider (`media_upload_provider.dart`)
```dart
/// 업로드 진행 상태 및 에러 관리
/// Firebase Storage 업로드 프로세스 추적
class MediaUploadProvider extends ChangeNotifier {
  // 상태
  final Map<String, UploadTask> _activeTasks = {};
  final Map<String, double> _uploadProgress = {};
  final Map<String, UploadError> _uploadErrors = {};
  final List<String> _completedUploads = [];

  // 업로드 설정
  static const int maxConcurrentUploads = 3;
  static const int maxRetries = 3;

  // 액션 메서드
  Future<List<String>> startUpload({
    required List<AssetEntity> assets,
    required String contentId,
  }) async {
    // MediaUploadService와 연동
    // 병렬 업로드 관리
  }

  Future<void> retryUpload(String uploadId) async {
    // 실패한 업로드 재시도
  }

  void cancelUpload(String uploadId) {
    // 진행중인 업로드 취소
  }

  void cancelAllUploads() {
    // 모든 업로드 취소
  }

  // 진행률 스트림
  Stream<double> getProgressStream(String uploadId) {
    // 개별 업로드 진행률 스트림
  }
}
```

### 3. Media Validation Provider (`media_validation_provider.dart`)
```dart
/// AI 검열 및 유효성 검증 상태 관리
/// ModerateContentUseCase와 통합
class MediaValidationProvider extends ChangeNotifier {
  // 상태
  final Map<String, ValidationResult> _validationResults = {};
  final Queue<ValidationRequest> _pendingValidations = Queue();
  final Map<String, RejectionReason> _rejectedReasons = {};
  bool _isValidating = false;

  // 검증 설정
  static const Duration validationTimeout = Duration(seconds: 30);

  // 액션 메서드
  Future<ValidationResult> validateMedia({
    required String mediaUrl,
    required MediaType type,
  }) async {
    // AI 모더레이션 서비스 호출
    // 기존 ModerateContentUseCase 활용
  }

  void clearValidation(String mediaId) {
    // 검증 결과 초기화
  }

  void clearAllValidations() {
    // 모든 검증 결과 초기화
  }

  bool hasValidationErrors() {
    // 검증 에러 존재 여부
  }

  List<String> getRejectedMediaIds() {
    // 거부된 미디어 ID 목록
  }
}
```

### 4. Media State Coordinator (`media_state_coordinator.dart`)
```dart
/// Provider 간 상태 동기화 및 조정
/// 중앙 집중식 상태 관리 조정자
class MediaStateCoordinator extends ChangeNotifier {
  final MediaSelectionProvider _selectionProvider;
  final MediaUploadProvider _uploadProvider;
  final MediaValidationProvider _validationProvider;
  final CreatePostProviderV2 _creationProvider;

  MediaStateCoordinator({
    required MediaSelectionProvider selectionProvider,
    required MediaUploadProvider uploadProvider,
    required MediaValidationProvider validationProvider,
    required CreatePostProviderV2 creationProvider,
  }) : _selectionProvider = selectionProvider,
       _uploadProvider = uploadProvider,
       _validationProvider = validationProvider,
       _creationProvider = creationProvider {
    _initializeListeners();
  }

  void _initializeListeners() {
    // Provider 간 이벤트 리스닝 설정
    _selectionProvider.addListener(_onSelectionChanged);
    _uploadProvider.addListener(_onUploadChanged);
    _validationProvider.addListener(_onValidationChanged);
  }

  // 통합 액션
  Future<void> processMediaSelection({
    required MediaBox box,
    required List<AssetEntity> assets,
  }) async {
    // 1. Selection Provider에 선택 상태 업데이트
    await _selectionProvider.selectMedia(box: box, assets: assets);

    // 2. Upload Provider에 업로드 시작
    final uploadIds = await _uploadProvider.startUpload(
      assets: assets,
      contentId: _creationProvider.draftId,
    );

    // 3. Validation Provider에 검증 요청
    for (final uploadId in uploadIds) {
      await _validationProvider.validateMedia(
        mediaUrl: uploadId,
        type: MediaType.image,
      );
    }

    // 4. Creation Provider에 최종 상태 반영
    _updateCreationProvider();
  }

  void synchronizeStates() {
    // 모든 Provider 상태 동기화
  }

  void handleStateConflicts() {
    // 상태 충돌 해결
  }

  void notifyDependents() {
    // 의존 컴포넌트에 변경 알림
  }
}
```

## 📁 디렉토리 구조

```
lib/features/creation/
├── presentation/
│   ├── providers/
│   │   ├── media/                         # 미디어 상태 관리 전용
│   │   │   ├── media_selection_provider.dart
│   │   │   ├── media_upload_provider.dart
│   │   │   ├── media_validation_provider.dart
│   │   │   ├── media_state_coordinator.dart
│   │   │   └── media_providers.dart      # Export 파일
│   │   │
│   │   ├── create_post_provider_v2.dart  # 기존 (미디어 로직 제거)
│   │   └── provider_config.dart          # DI 설정 업데이트
│   │
│   └── widgets/
│       └── media/                        # 미디어 UI 컴포넌트
│           ├── media_selection_widget.dart
│           ├── media_upload_indicator.dart
│           └── media_validation_overlay.dart
```

## 🔄 마이그레이션 계획

### Phase 5.1: 인터페이스 정의 (4시간)
```yaml
작업 내용:
  1. 4개 Provider 인터페이스 정의
  2. 상태 모델 클래스 생성
  3. 이벤트 및 액션 정의
  4. Provider 간 통신 프로토콜 설계

생성 파일:
  - presentation/providers/media/interfaces/
    • i_media_selection_provider.dart
    • i_media_upload_provider.dart
    • i_media_validation_provider.dart
    • i_media_state_coordinator.dart
```

### Phase 5.2: Provider 구현 (8시간)
```yaml
작업 내용:
  1. MediaSelectionProvider 구현
     - CreatePostProviderV2에서 선택 로직 추출
     - InPutPostImageModel 통합

  2. MediaUploadProvider 구현
     - MediaUploadService와 연동
     - 진행률 추적 시스템

  3. MediaValidationProvider 구현
     - ModerateContentUseCase 통합
     - AI 검증 결과 관리

  4. MediaStateCoordinator 구현
     - Provider 간 이벤트 버스
     - 상태 동기화 로직

영향받는 파일:
  - 수정: CreatePostProviderV2 (미디어 로직 제거)
  - 수정: CreatePostScreen (새 Provider 사용)
  - 생성: 4개 Provider 구현체
```

### Phase 5.3: UI 위젯 마이그레이션 (4시간)
```yaml
작업 내용:
  1. ImageSelectionWidget 수정
     - MediaSelectionProvider 사용
     - 선택 상태 바인딩

  2. 업로드 인디케이터 생성
     - MediaUploadProvider 구독
     - 진행률 표시 UI

  3. 검증 오버레이 생성
     - MediaValidationProvider 구독
     - 에러 메시지 표시

영향받는 파일:
  - 수정: ImageSelectionWidget
  - 수정: CreatePostScreen
  - 생성: 2개 새 UI 컴포넌트
```

### Phase 5.4: DI 설정 및 통합 (2시간)
```yaml
작업 내용:
  1. provider_config.dart 업데이트
     - 4개 Provider GetIt 등록
     - MediaStateCoordinator 설정

  2. CreatePostScreen 통합
     - MultiProvider 설정
     - Provider 의존성 주입

  3. 기존 코드 정리
     - 중복 코드 제거
     - 미사용 import 정리

영향받는 파일:
  - 수정: provider_config.dart
  - 수정: CreatePostScreen
  - 삭제: 레거시 미디어 관련 코드
```

### Phase 5.5: 테스트 및 검증 (4시간)
```yaml
작업 내용:
  1. 단위 테스트 작성
     - 각 Provider별 테스트
     - 상태 동기화 테스트

  2. 통합 테스트
     - 전체 미디어 플로우 테스트
     - Provider 간 통신 테스트

  3. 성능 테스트
     - 메모리 사용량 측정
     - 상태 업데이트 성능

테스트 파일:
  - test/providers/media/
    • media_selection_provider_test.dart
    • media_upload_provider_test.dart
    • media_validation_provider_test.dart
    • media_state_coordinator_test.dart
```

## 🔗 기존 코드와의 통합

### CreatePostProviderV2 통합
```dart
// Before: CreatePostProviderV2에 모든 미디어 로직 포함
class CreatePostProviderV2 extends ChangeNotifier {
  List<String> uploadImageA = [];  // 제거 예정
  List<String> uploadImageB = [];  // 제거 예정
  // ... 367줄의 혼재된 코드
}

// After: 미디어 로직을 MediaStateCoordinator에 위임
class CreatePostProviderV2 extends ChangeNotifier {
  final MediaStateCoordinator _mediaCoordinator;

  // 게시물 생성 로직에만 집중
  Future<void> createPost() async {
    final mediaUrls = await _mediaCoordinator.getFinalMediaUrls();
    // 게시물 생성 로직
  }
}
```

### UseCase 연동
```dart
// MediaValidationProvider가 기존 UseCase 활용
class MediaValidationProvider {
  final ModerateContentUseCase _moderateUseCase;

  Future<ValidationResult> validateMedia(...) async {
    final result = await _moderateUseCase.execute(
      imageUrls: [mediaUrl],
    );

    return result.fold(
      (failure) => ValidationResult.error(failure),
      (success) => ValidationResult.success(),
    );
  }
}
```

## ✅ 검증 체크리스트

### 기능 검증
- [ ] 이미지 선택 정상 작동
- [ ] 업로드 진행률 표시
- [ ] AI 검증 통합
- [ ] 에러 처리 정상 작동

### 상태 관리 검증
- [ ] Provider 간 동기화
- [ ] 상태 불변성 유지
- [ ] 메모리 누수 없음
- [ ] 성능 저하 없음

### Clean Architecture 준수
- [ ] 단일 책임 원칙
- [ ] 의존성 역전
- [ ] 레이어 분리
- [ ] 테스트 가능성

## 📈 예상 효과

### 코드 품질
- **응집도**: 각 Provider가 단일 책임 수행
- **결합도**: Provider 간 느슨한 결합
- **테스트 용이성**: 독립적 테스트 가능

### 유지보수성
- **변경 영향 최소화**: 각 상태 영역 독립적
- **코드 이해도**: 명확한 책임 분리
- **확장성**: 새로운 미디어 타입 추가 용이

### 성능
- **병렬 처리**: 독립적인 상태 업데이트
- **캐싱 최적화**: 각 영역별 최적 캐싱
- **메모리 효율**: 불필요한 상태 중복 제거

## 🚀 실행 계획

### Day 1 (8시간)
- [ ] Phase 5.1: 인터페이스 정의 (4시간)
- [ ] Phase 5.2 시작: MediaSelectionProvider 구현 (4시간)

### Day 2 (8시간)
- [ ] Phase 5.2 계속: 나머지 3개 Provider 구현 (8시간)

### Day 3 (8시간)
- [ ] Phase 5.3: UI 위젯 마이그레이션 (4시간)
- [ ] Phase 5.4: DI 설정 및 통합 (2시간)
- [ ] Phase 5.5: 테스트 및 검증 (2시간)

## 📝 참고 사항

- **네이밍 컨벤션**: 'post' 대신 'media' 또는 'creation' 사용
- **기존 호환성**: CreatePostProviderV2와 점진적 통합
- **트랜잭션 보장**: 각 Provider가 독립적 트랜잭션 유지
- **에러 복구**: 각 영역별 독립적 에러 처리

## 🎯 Success Criteria

1. **코드 라인 감소**: CreatePostProviderV2 367줄 → 200줄 이하
2. **Provider 분리**: 4개 독립 Provider 생성
3. **테스트 커버리지**: 각 Provider 80% 이상
4. **성능 유지**: 기존 대비 성능 저하 없음
5. **Clean Architecture**: 100% 준수

---

**작성자**: Architecture Team
**검토자**: Tech Lead
**승인**: Pending