# Creation Feature - 통합 문서

> **최종 업데이트**: 2025-11-07
> **아키텍처**: Clean Architecture v4.0 + Firebase-Centric v2.0
> **캐싱**: CreationCacheService + UnifiedCacheService 3-Layer (Memory → Hive → Firestore)
> **상태 관리**: Riverpod 3.x ✅ **완료** (2025-11-06)
> **에러 처리**: Freezed Sealed Classes ✅ **완료** (2025-11-07)
> **AI 통합**: Gemini 1.5 Pro + Perspective API + Cloud Vision API

## 🎉 Riverpod 3.x Migration 완료!

**Phase 2 완료 날짜**: 2025-11-06

**마이그레이션 성과**:
- ✅ **5개 Notifiers** 모두 Riverpod 3.x 패턴으로 전환 완료
- ✅ **17개 Widgets** 검토 완료 (7개 ConsumerWidget, 10개 Pure UI)
- ✅ **코드 생성 검증** 완료 (`flutter analyze` 이슈 0개)
- ✅ **통합 테스트 검증** 완료 ([검증 리포트](./INTEGRATION_TEST_VERIFICATION.md) 참조)

**주요 변경사항**:
1. **Notifiers**: `@riverpod` annotation + code generation
2. **States**: Freezed 불변 클래스 (`.freezed.dart`, `.g.dart`)
3. **Widgets**: `ConsumerWidget`/`ConsumerStatefulWidget` 사용
4. **에러 처리**: Either 패턴으로 타입 안전 보장
5. **Draft Auto-Save**: 500ms debounce + 3-Layer 캐싱
6. **Idempotency**: UUID 기반 eventId 생성

**검증 완료 플로우**:
- 🟢 **CreatePost**: Draft 자동 저장/복원, 게시물 생성
- 🟢 **MediaUpload**: 큐 기반 병렬 업로드, 재시도 로직
- 🟢 **TargetAudience**: 3단계 위저드 상태 전이
- 🟢 **MediaValidation**: AI 기반 콘텐츠 검열

**관련 문서**:
- [통합 테스트 검증 리포트](./INTEGRATION_TEST_VERIFICATION.md) - 코드 레벨 정적 분석 결과
- [Phase 문서 목록](#-관련-문서) - 단계별 마이그레이션 가이드

---

## 🎯 Freezed Migration 완료!

**완료 날짜**: 2025-11-07

**마이그레이션 성과**:
- ✅ **CreationFailure Sealed Class** - 16+ failure types with Freezed pattern
- ✅ **Korean Localization** - Extension pattern for user-friendly error messages
- ✅ **Type-Safe Error Handling** - Either<CreationFailure, T> pattern
- ✅ **Zero Warnings** - 29 static warnings fixed (24 catches + 5 casts)
- ✅ **Production Ready** - flutter analyze: No issues found!

**주요 변경사항**:
1. **Failures**: Freezed sealed class with factory constructors
2. **Extensions**: `getUserMessage()` for Korean error messages
3. **Data Layer**: Fixed 24 unused catch clauses, 5 unnecessary casts
4. **Quality**: 69 errors → 0, 29 warnings → 0

**파일 업데이트**:
| File | Changes | Lines |
|------|---------|-------|
| `domain/failures/creation_failure.dart` | Freezed sealed class | 421 |
| `domain/failures/creation_failure_extensions.dart` | Korean messages + permission handling | Added |
| `data/repositories/media_repository_impl.dart` | 18 catch clauses | Fixed |
| `data/repositories/post_creation_repository_v2_impl.dart` | 6 catches + 5 casts | Fixed |

**검증 완료**:
```bash
flutter analyze
# Analyzing versus-cursor...
# No issues found!
```

**관련 문서**:
- [Domain Layer README](./domain/README.md) - Freezed failure hierarchy
- [Data Layer README](./data/README.md) - Error handling with Freezed
- [Presentation Layer README](./presentation/README.md) - Provider error handling

---

## 📋 목차

- [Riverpod 3.x Migration 완료](#-riverpod-3x-migration-완료)
- [Freezed Migration 완료](#-freezed-migration-완료)
- [전체 디렉토리 구조](#-전체-디렉토리-구조)
- [아키텍처 개요](#-아키텍처-개요)
- [핵심 기능](#-핵심-기능)
- [BOUNDARIES - Clean Architecture 3-Layer 경계](#️-boundaries---clean-architecture-3-layer-경계)
- [로깅 전략](#-로깅-전략)
- [빠른 참조 가이드](#-빠른-참조-가이드)
- [레이어별 README 안내](#-레이어별-readme-안내)
- [주요 파일 위치](#-주요-파일-위치)
- [DI (Dependency Injection)](#-di-dependency-injection)
- [통계](#-통계)
- [시작하기](#-시작하기)
- [자주 찾는 질문](#-자주-찾는-질문)
- [기여 가이드](#-기여-가이드)
- [학습 가이드](#-학습-가이드)
- [관련 문서](#-관련-문서)

---

## 🗂 전체 디렉토리 구조

```
lib/features/creation/
├── 📂 data/                              # Data Layer (Firebase-Centric v2.0)
│   ├── 📂 datasources/                   # Port-Adapter 패턴 (2개)
│   │   ├── firebase_storage_datasource.dart   # Firebase Storage 구현체
│   │   └── 📂 interfaces/
│   │       └── i_storage_datasource.dart      # Storage 인터페이스 (Port)
│   ├── 📂 repositories/                  # Repository 구현체 (9개)
│   │   ├── 🎯 Core Repositories (3개)
│   │   │   ├── post_creation_repository_v2_impl.dart   # 메인 CRUD + Cache + Idempotency
│   │   │   ├── target_audience_repository_impl.dart    # Firebase Functions 통합
│   │   │   └── media_repository_impl.dart              # Storage 쿼리/업로드
│   │   ├── 🔧 Upload & Processing (2개)
│   │   │   ├── media_upload_repository_impl.dart       # 멀티 업로드 + Progress
│   │   │   └── image_processing_repository_impl.dart   # AI 검열 + 처리
│   │   └── 🔐 Specialized Repositories (4개)
│   │       ├── content_moderation_repository_impl.dart # AI 필터링
│   │       ├── content_metrics_repository_impl.dart    # CQRS + Sharding
│   │       ├── content_visibility_repository_impl.dart # 접근 제어
│   │       └── (기타 1개)
│   └── 📄 README.md                      # Data Layer 상세 문서 (1,664줄)
│
├── 📂 domain/                             # Domain Layer (Clean Architecture v4.0)
│   ├── 📂 constants/                     # 도메인 상수 (3개)
│   │   ├── creation_constants.dart       # 검증 규칙, 한국어 메시지
│   │   ├── ai_generation_constants.dart  # Gemini AI 설정
│   │   └── target_audience_constants.dart # 타겟 옵션
│   ├── 📂 entities/                      # Freezed 불변 엔티티 (3개 + Extensions)
│   │   ├── post_creation.dart            # Aggregate Root (477줄)
│   │   ├── post_creation.freezed.dart
│   │   ├── post_creation.g.dart
│   │   ├── post_creation_extensions.dart # Firestore Extension (189줄)
│   │   ├── target_audience.dart          # Value Object (370줄)
│   │   ├── target_audience.freezed.dart
│   │   ├── target_audience.g.dart
│   │   ├── target_audience_extensions.dart # Firestore Extension (68줄)
│   │   ├── media_info.dart               # Sealed Union (48줄)
│   │   └── media_info_extensions.dart    # Firestore Extension (152줄)
│   ├── 📂 failures/                      # Failure 정의 (1개)
│   │   ├── creation_failure.dart         # 16+ Failure types (421줄)
│   │   └── creation_failure.freezed.dart
│   ├── 📂 repositories/                  # Repository 인터페이스 (4개)
│   │   ├── i_post_creation_repository.dart      # 게시물 CRUD (152줄)
│   │   ├── i_target_audience_repository.dart    # 타겟 관리 (71줄)
│   │   ├── i_media_repository.dart              # 미디어 업로드 (91줄)
│   │   └── i_content_metrics_repository.dart    # CQRS Query (75줄)
│   ├── 📂 services/                      # Domain Service 인터페이스 (4개)
│   │   ├── i_image_processing_service.dart      # 이미지 처리 (43줄)
│   │   ├── i_image_moderation_service.dart      # 컨텐츠 검열 (51줄)
│   │   ├── i_ai_service.dart                    # AI 생성 (48줄)
│   │   └── i_target_audience_service.dart       # AI 타겟팅 (36줄)
│   ├── 📂 usecases/                      # UseCase 비즈니스 로직 (5+개)
│   │   ├── create_post_usecase.dart
│   │   ├── save_draft_usecase.dart
│   │   ├── upload_media_usecase.dart
│   │   ├── generate_title_usecase.dart
│   │   └── moderate_content_usecase.dart
│   └── 📄 README.md                      # Domain Layer 상세 문서 (2,357줄)
│
├── 📂 presentation/                       # Presentation Layer (Clean Architecture v4.0)
│   ├── 📂 constants/                     # UI 상수 (10개 파일, 495줄)
│   │   ├── dimensions.dart               # Box sizes, padding, margins (75줄)
│   │   ├── colors.dart                   # Brand colors, gradients (48줄)
│   │   ├── strings.dart                  # Korean text constants (58줄)
│   │   ├── field_styles.dart             # InputDecoration presets (178줄)
│   │   └── ... (6개 더)
│   ├── 📂 delegates/                     # 3개 파일 (185줄)
│   │   └── korean_asset_picker_text_delegate.dart # wechat_assets_picker Korean
│   ├── 📂 providers/                     # Riverpod 3.x 상태 관리 (23개 파일, 7,748줄)
│   │   ├── 🎯 Main Notifiers (5개)
│   │   │   ├── create_post_notifier.dart         # 메인 오케스트레이터 (806줄)
│   │   │   ├── target_audience_notifier.dart     # 3-Step Wizard (158줄)
│   │   │   ├── media_selection_notifier.dart     # 갤러리 + Smart Layout (575줄)
│   │   │   ├── media_upload_notifier.dart        # Queue Manager (605줄)
│   │   │   └── media_validation_notifier.dart    # Content Safety (345줄)
│   │   └── 📂 states/                    # Freezed State Models (8개)
│   │       ├── create_post_state.dart
│   │       ├── target_audience_state.dart
│   │       ├── media_selection_state.dart
│   │       └── ... (5개 더)
│   ├── 📂 screens/                       # 화면 위젯 (4개, 1,131줄)
│   │   ├── create_post/
│   │   │   └── create_post_screen.dart           # 메인 화면 (306줄)
│   │   ├── editor/
│   │   │   └── pro_image_editor_page.dart        # 이미지 편집기 (162줄)
│   │   ├── thumbnail/
│   │   │   └── thumbnail_selection_page.dart     # 썸네일 선택 (329줄)
│   │   └── viewer/
│   │       └── image_viewer_page.dart            # 전체화면 뷰어 (334줄)
│   ├── 📂 widgets/                       # 재사용 위젯 (20개, 4,950줄)
│   │   ├── 📂 components/ (9개, 2,618줄)
│   │   │   ├── media_selection_box_single.dart
│   │   │   ├── media_selection_box_multi.dart
│   │   │   └── input_field_builder.dart
│   │   ├── 📂 create_post/ (2개, 644줄)
│   │   │   ├── text_input_widget.dart
│   │   │   └── image_selection_widget.dart
│   │   ├── 📂 dialogs/ (4개, 1,151줄)
│   │   │   ├── target_audience_dialog.dart       # 3-Step Wizard (301줄)
│   │   │   ├── collection_type_selector.dart     # Step 1: 컬렉션 타입
│   │   │   ├── target_count_selector.dart        # Step 2: 타겟 수
│   │   │   └── detailed_target_selector.dart     # Step 3: 상세 설정
│   │   └── 📂 media/ (3개, 1,248줄)
│   │       ├── media_selection_flow_widget.dart
│   │       ├── media_editor_widget.dart
│   │       └── media_preview_widget.dart
│   └── 📄 README.md                      # Presentation Layer 상세 문서 (3,324줄)
│
├── 📂 di/
│   └── creation_di_module.dart           # Dependency Injection 모듈
│
└── 📄 README.md                          # 👈 이 문서 (통합 가이드)
```

**총 파일 수**: 약 120개 (생성된 Freezed/JSON/Riverpod 파일 포함)
- Data Layer: 11개
- Domain Layer: 30개 (주요 15개 + Freezed/JSON 생성 15개)
- Presentation Layer: 61개 (14,509줄)
- DI: 1개
- 문서: 4개

---

## 🏗 아키텍처 개요

### 3-Layer Clean Architecture 구조

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  • Riverpod 3.x 상태 관리 (@riverpod annotation)             │
│  • Freezed 불변 State (8개 State models)                     │
│  • 5개 Main Notifiers (CreatePost, TargetAudience, Media)   │
│  • Korean Localization (wechat_assets_picker delegates)     │
│  • 3-Step Wizard UI (Collection Type → Target Count → Custom)│
│  • Smart Layout Calculation (Aspect ratio-based)            │
│  • 61개 파일 (14,509줄)                                       │
│  • Clean 마이그레이션: Draft auto-save, Queue upload         │
└──────────────────┬──────────────────────────────────────────┘
                   │ Provider 의존성 (ref.watch)
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • Pure Dart (프레임워크 독립)                                 │
│  • Freezed 불변 엔티티 (PostCreation, TargetAudience, MediaInfo) │
│  • Sealed Union Types (타입 안전한 다형성)                     │
│  • Either<Failure, Success> 패턴                             │
│  • Repository 인터페이스 (4개)                                 │
│  • Domain Service 인터페이스 (4개 AI 서비스)                   │
│  • UseCase 패턴 (5+개 - 단일 책임)                             │
│  • CreationFailure (16+ 실패 타입, 한국어 메시지)               │
│  • 30개 파일 (~4,495줄)                                        │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository 인터페이스 의존성
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • Firebase-Centric Architecture v2.0                        │
│  • Direct Firebase SDK 사용 (Firestore, Storage)             │
│  • Extension Pattern (DTO/Mapper 제거, 85% 코드 감소)         │
│  • Port-Adapter Pattern (Storage만 추상화)                   │
│  • CreationCacheService + UnifiedCacheService (3-Layer)     │
│    - L1 Memory: <10ms (SimpleMemoryCache, LRU)              │
│    - L2 Hive: 10-30ms (영구 로컬 저장)                       │
│    - L3 Firestore: 50-500ms (오프라인 지원)                  │
│  • Idempotency Pattern (중복 방지)                           │
│  • 9개 Specialized Repositories (관심사 분리)                │
│  • CQRS Pattern (Metrics는 Query-only)                      │
│  • Sharding Strategy (고성능 Counter)                        │
│  • 11개 파일 (~4,200줄)                                       │
└─────────────────────────────────────────────────────────────┘
                   │
                   ▼
         Firebase + AI Services
   (Firestore, Storage, Gemini AI, Perspective API,
    Cloud Vision, Firebase Functions)
```

### 핵심 디자인 패턴

| 패턴 | 레이어 | 목적 | 예시 파일 |
|------|--------|------|-----------|
| **Extension Pattern** | Data | Firestore 직렬화 (DTO/Mapper 대체, 85% 감소) | `domain/entities/*_extensions.dart` (409줄) |
| **Repository Pattern** | Domain/Data | 데이터 소스 추상화, 9개 특화 Repository | `i_post_creation_repository.dart` → `post_creation_repository_v2_impl.dart` |
| **UseCase Pattern** | Domain | 비즈니스 로직 캡슐화 | `create_post_usecase.dart`, `save_draft_usecase.dart` |
| **Freezed Pattern** | Domain | 불변 엔티티 + 코드 생성 | `post_creation.dart` + `*.freezed.dart` |
| **Sealed Union Types** | Domain | 타입 안전 다형성 | `MediaInfo = ImageInfo \| VideoInfo` |
| **Either Pattern** | Domain | 타입 안전 에러 처리 | `Either<CreationFailure, PostCreation>` |
| **Port-Adapter Pattern** | Domain/Data | 서비스 인터페이스 분리 | `IAIService` (Port) ↔ `GeminiAIService` (Adapter) |
| **Factory Pattern** | Domain | 복잡한 객체 생성 | `TargetAudience.general()`, `.detailed()`, `.custom()` |
| **@riverpod Annotation** | Presentation | Riverpod 3.x 코드 생성 | `@riverpod class CreatePost extends _$CreatePost` |
| **Notifier Pattern** | Presentation | 상태 관리 + 비즈니스 로직 | 5개 Main Notifiers (CreatePost, TargetAudience, Media) |
| **3-Layer Caching** | Data | 성능 최적화 (60%+ 히트율) | `CreationCacheService` + `UnifiedCacheService` |
| **Idempotency Pattern** | Data | 중복 작업 방지 (UUID 기반) | `IdempotencyService` (eventId) |
| **CQRS Pattern** | Data | 읽기/쓰기 분리 | `ContentMetricsRepository` (Query-only) |
| **Sharding Strategy** | Data | 고성능 Counter (10 shards) | `ContentMetricsRepository` |
| **Debouncing** | Presentation | Draft 자동 저장 최적화 (500ms) | `CreatePostNotifier._draftSaveTimer` |
| **Queue-based Upload** | Presentation | 병렬 업로드 (max 3 concurrent) | `MediaUploadNotifier` |

---

## 🎯 핵심 기능

### 1. A vs B 게시물 생성 시스템
- **멀티미디어 지원**: 텍스트, 이미지 (최대 4개), 비디오
- **Draft 자동 저장**: 500ms debounce + Cache-first loading (<10ms)
- **실시간 검증**: Perspective API + Gemini AI + Cloud Vision
- **AI 타이틀 생성**: Gemini 1.5 Pro로 자동 타이틀 생성
- **익명 게시**: 익명 게시 옵션
- **카테고리/태그**: 선택적 카테고리 + 최대 5개 태그

### 2. 3-Step Wizard UI
- **Step 1: Collection Type**: 전체 / 친구 / 팔로워 / 커스텀
- **Step 2: Target Count**: 타겟 오디언스 수 선택 (10~1,000명)
- **Step 3: Custom Settings**: 성별, 연령, 지역, 관심사 상세 설정
- **TargetAudienceNotifier**: 3단계 상태 관리 (Riverpod 3.x)
- **Factory Pattern**: 3가지 TargetAudience 생성 방법

### 3. Smart Media Layout
- **Aspect Ratio 분석**: 자동 가로/세로/그리드 레이아웃 감지
- **3가지 레이아웃**: Horizontal (wide), Vertical (tall), Grid (square-ish)
- **Box Size 계산**: UnifiedBoxCalculator로 최적 크기 계산
- **Dual Media Box**: A vs B 비교 레이아웃
- **MediaSelectionNotifier**: 갤러리 선택 + 레이아웃 계산

### 4. AI-Powered Targeting
- **Gemini AI 통합**: 자연어 → TargetAudience 변환
- **Firebase Functions**: calculateTargetAudience Cloud Function
- **ITargetAudienceService**: Domain Service 인터페이스
- **TargetAudienceRepositoryImpl**: AI 타겟팅 구현체
- **타겟 검증**: AI 기반 타겟 오디언스 최적화

### 5. Content Safety (3-Layer 검열)
- **Perspective API**: 텍스트 유해성 검사 (독성, 폭력, 혐오 등)
- **Gemini AI**: 컨텍스트 기반 검열 (문화적 민감성)
- **Cloud Vision API**: 이미지 안전성 검사 (성인, 폭력, 스푸핑)
- **IImageModerationService**: Domain Service 인터페이스
- **ContentModerationRepository**: 검열 결과 저장

### 6. Queue-based Upload
- **병렬 업로드**: 최대 3개 동시 업로드 (`Future.wait`)
- **진행률 추적**: 실시간 업로드 진행률 표시
- **재시도 로직**: 실패 시 자동 재시도 (최대 3회)
- **Queue Manager**: MediaUploadNotifier (605줄)
- **UploadQueueState**: Freezed State (UploadItem, UploadStatus enum)

### 7. Draft Auto-Save (500ms Debounce)
- **자동 저장**: 텍스트 입력 500ms 후 자동 저장
- **Cache-first Loading**: Draft 복원 <10ms (Memory Hit)
- **CreationCacheService**: Draft 전용 캐시 서비스
- **3-Layer Caching**: Memory → Hive → Firestore
- **Draft 무효화**: 게시 완료 시 자동 삭제

### 8. Korean Localization
- **wechat_assets_picker**: Korean text delegates
- **Korean 에러 메시지**: 16+ Failure types (한국어)
- **Korean UI 상수**: `strings.dart` (58줄)
- **KoreanAssetPickerTextDelegate**: 갤러리 한국어화
- **문화적 적응**: 한국 사용자 UX 최적화

---

## 🏛️ BOUNDARIES - Clean Architecture 3-Layer 경계

Creation Feature는 **Clean Architecture v4.0**의 3-Layer 구조를 따르며, 각 Layer 간 의존성 방향을 엄격히 준수합니다.

### 3-Layer 의존성 규칙

```
┌─────────────────────────────────────────────────────────────┐
│                   Presentation Layer                         │
│  • 의존: Domain Layer (UseCase, Entity, Repository          │
│          Interface)                                          │
│  • 금지: Data Layer, 다른 Feature Presentation               │
│  • 패턴: Riverpod Provider, ConsumerWidget, AsyncValue      │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 의존
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                     Domain Layer                             │
│  • 의존: 없음 (Pure Dart)                                    │
│  • 금지: Presentation, Data, Flutter SDK, Firebase           │
│  • 패턴: UseCase, Entity (Freezed Sealed), Repository       │
│          Interface                                           │
└──────────────────┬──────────────────────────────────────────┘
                   │ Repository Interface 구현
                   ▼
┌─────────────────────────────────────────────────────────────┐
│                      Data Layer                              │
│  • 의존: Domain Layer (Entity, Repository Interface)         │
│  • 금지: Presentation Layer                                   │
│  • 패턴: Repository 구현, Extension (fromFirestore,          │
│          toFirestore), Firebase SDK 직접 사용                │
└─────────────────────────────────────────────────────────────┘
```

### 실전 예시

#### 1. ✅ Presentation → Domain (올바른 사용)

```dart
// presentation/providers/create_post_notifier.dart
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  @override
  PostCreation build() => PostCreation.initial();

  Future<void> createPost() async {
    final useCase = getIt<CreatePostUseCase>();
    final result = await useCase.execute(state);

    result.fold(
      (failure) => throw Exception(failure.getUserMessage()),
      (postId) {
        state = PostCreation.initial();
        // Navigate to post detail
      },
    );
  }

  Future<void> uploadMedia(List<File> files) async {
    final useCase = getIt<UploadMediaUseCase>();

    for (final file in files) {
      final result = await useCase.execute(file);

      result.fold(
        (failure) => throw Exception(failure.getUserMessage()),
        (mediaUrl) {
          state = state.copyWith(
            mediaUrls: [...state.mediaUrls, mediaUrl],
          );
        },
      );
    }
  }
}
```

#### 2. ✅ Domain → 독립성 (올바른 사용)

```dart
// domain/usecases/create_post_usecase.dart
class CreatePostUseCase {
  final IPostRepository _repository;
  final IAIModerationService _aiService;

  CreatePostUseCase(this._repository, this._aiService);

  Future<Either<CreationFailure, String>> execute(
    PostCreation creation,
  ) async {
    // AI 검열
    final moderationResult = await _aiService.moderateContent(
      title: creation.title,
      description: creation.description,
    );

    if (moderationResult.isLeft()) {
      return left(CreationFailure.inappropriateContent());
    }

    // 게시물 생성
    return _repository.createPost(creation);
  }
}

// domain/usecases/upload_media_usecase.dart
class UploadMediaUseCase {
  final IMediaRepository _repository;

  UploadMediaUseCase(this._repository);

  Future<Either<CreationFailure, String>> execute(File file) {
    return _repository.uploadMedia(file);
  }
}

// domain/entities/post_creation.dart (Freezed)
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    required String title,
    required String description,
    required String optionAText,
    required String optionBText,
    required List<String> mediaUrls,
    required TargetAudience targetAudience,
  }) = _PostCreation;

  factory PostCreation.initial() => PostCreation(
    title: '',
    description: '',
    optionAText: '',
    optionBText: '',
    mediaUrls: [],
    targetAudience: TargetAudience.all(),
  );
}
```

#### 3. ✅ Data → Domain (올바른 사용)

```dart
// data/repositories/post_repository_impl.dart
class PostRepositoryImpl implements IPostRepository {
  final FirebaseFirestore _firestore;
  final UnifiedCacheService _cacheService;

  @override
  Future<Either<CreationFailure, String>> createPost(
    PostCreation creation,
  ) async {
    try {
      // ✅ Data Layer는 Firestore 직접 접근 허용
      final docRef = await _firestore.collection('posts').add({
        'title': creation.title,
        'description': creation.description,
        'optionAText': creation.optionAText,
        'optionBText': creation.optionBText,
        'mediaUrls': creation.mediaUrls,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return right(docRef.id);
    } catch (e) {
      return left(CreationFailure.serverError(e.toString()));
    }
  }
}

// data/repositories/media_repository_impl.dart
class MediaRepositoryImpl implements IMediaRepository {
  final FirebaseStorage _storage;

  @override
  Future<Either<CreationFailure, String>> uploadMedia(File file) async {
    try {
      // ✅ Data Layer는 Firebase Storage 직접 접근 허용
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('media/$fileName');

      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return right(downloadUrl);
    } catch (e) {
      return left(CreationFailure.uploadError(e.toString()));
    }
  }
}
```

#### 4. ❌ 잘못된 사용 패턴

```dart
// ❌ Presentation Layer에서 Firestore 직접 접근
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  Future<void> createPost() async {
    final docRef = await FirebaseFirestore.instance
        .collection('posts')
        .add({
      'title': state.title,
      'description': state.description,
    });
  }
}

// ❌ Domain Layer에서 Firebase 의존성
class CreatePostUseCase {
  Future<String> execute(PostCreation creation) async {
    final docRef = await FirebaseFirestore.instance
        .collection('posts')
        .add(creation.toJson());
    return docRef.id;
  }
}
```

### Boundary 검증

#### 자동 검증 (Lint)

```bash
# Presentation → Data 위반 검사
grep -r "import.*creation.*data" lib/features/creation/presentation/

# Domain → Firebase 의존성 검사
grep -r "import.*firebase" lib/features/creation/domain/

# 기대 결과: 발견되지 않아야 함
```

#### 수동 검증 체크리스트

- [ ] Presentation Layer는 UseCase만 호출하는가?
- [ ] Domain Layer는 Pure Dart만 사용하는가? (Firebase/Flutter SDK 없음)
- [ ] Data Layer는 Repository Interface를 구현하는가?
- [ ] GetIt으로 UseCase/Repository를 DI하는가?
- [ ] Either 패턴으로 에러를 반환하는가?
- [ ] Freezed Sealed Class로 Failure 타입을 정의하는가?

### 참고 문서

- **전체 프로젝트 Boundaries**: `/CLAUDE.md` - "## 🏛 BOUNDARIES" 섹션
- **App Layer Boundaries**: `/lib/app/README.md` - "### 🏛️ BOUNDARIES" 섹션
- **Creation Domain Layer**: `domain/README.md` - UseCase, Entity, Failure
- **Creation Data Layer**: `data/README.md` - Repository 구현, Extension
- **Creation Presentation Layer**: `presentation/README.md` - Provider, Widget

---

## 📝 로깅 전략

### 개요

Creation Feature는 **Layer별 로깅 책임 분리** 원칙을 따릅니다.

| Layer | 로깅 여부 | 근거 | 예시 |
|-------|----------|------|------|
| **Domain** | ❌ 불필요 | Pure Dart, 프레임워크 독립 | UseCase는 순수 비즈니스 로직만 |
| **Data** | ✅ 필수 | Firestore 쓰기, 캐시, AI API 호출 | Repository에서 모든 외부 작업 로깅 |
| **Presentation** | ⚠️ 선택적 | UI 상태 관리 중심 | Notifier는 비즈니스 로직만 로깅 |

---

### Layer별 세부 전략

#### Domain Layer: ❌ 로깅 불필요

**원칙**: Pure Dart만 사용하며 프레임워크에 독립적이어야 함

```dart
// ❌ BAD: UseCase에서 로깅
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> execute({
    required String userId,
    required String title,
  }) {
    Logger.debug('Creating post: $title');  // ❌ 불필요
    return _repository.createPost(...);
  }
}

// ✅ GOOD: UseCase는 로깅 없음
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> execute({
    required String userId,
    required String title,
  }) {
    return _repository.createPost(...);  // ✅ 깔끔
  }
}
```

**근거**:
- UseCase는 순수 비즈니스 로직만 담당
- 로깅은 Repository (Data Layer)에서 처리
- Entity, Failure는 데이터 구조만 정의

---

#### Data Layer: ✅ Logger 사용 (필수)

**로깅이 필요한 경우**:
- ✅ Firestore 쓰기 작업 (create, update, delete)
- ✅ 캐시 저장/로딩 실패
- ✅ AI/외부 API 호출
- ✅ Idempotency 위반
- ✅ 네트워크 에러

**Repository 로깅 예시**:
```dart
// PostCreationRepositoryV2Impl.dart
class PostCreationRepositoryV2Impl implements IPostCreationRepository {
  Future<Either<CreationFailure, void>> saveDraftPost(
    String userId,
    PostCreation draft, {
    required String eventId,
  }) async {
    try {
      // 캐시 저장 (L1, L2)
      await _cacheService.setDraftPost(userId, draft);

      // Firestore 저장 (L3)
      await _firestore.collection('drafts').doc(userId).set(
        draft.toFirestore(),
      );

      CreationLogger.draftSaved(userId: userId, eventId: eventId);  // ✅ 로깅
      return right(unit);
    } catch (e) {
      CreationLogger.draftSaveFailed(error: e);  // ✅ 에러 로깅
      return left(CreationFailure.firestoreWriteFailed(e.toString()));
    }
  }
}
```

**도메인 Logger 클래스**: `lib/services/logging/logger_service.dart`
- `CreationLogger`: Draft 저장, 미디어 업로드, AI 검열
- `TargetAudienceLogger`: 타겟 오디언스 선택, AI 추천
- `MediaLogger`: 이미지/비디오 처리, Firebase Storage 업로드

---

#### Presentation Layer: ⚠️ 선택적 로깅

**로깅이 필요한 경우**:
- ✅ Draft 자동 로드/복원 (비즈니스 로직)
- ❌ UI 상태 변경 (updateTitle, form inputs 등)
- ❌ Provider 에러 처리 (Either 패턴으로 자동 처리)

**Notifier 로깅 예시** (create_post_notifier.dart):

```dart
// ✅ GOOD: 비즈니스 로직만 로깅
@riverpod
class CreatePost extends _$CreatePost {
  Future<void> _loadDraftAsync() async {
    try {
      final draft = await repository.getDraftPost(currentUserId);
      if (draft != null) {
        state = CreatePostState(...);
        Logger.debug('Draft restored from cache',
          tag: 'CreatePostNotifier');  // ✅ 비즈니스 로직 로깅
      }
    } catch (e) {
      Logger.warning('Draft load failed',
        tag: 'CreatePostNotifier');  // ✅ 에러 로깅
    }
  }

  // Draft 저장 로직 - Repository로 위임
  Future<void> saveDraft() async {
    try {
      // Repository가 저장 + 로깅 모두 담당
      await repository.saveDraftPost(currentUserId, draft, eventId: eventId);
      // ✅ 로깅 없음 - Repository에서 처리
    } catch (e) {
      // Repository logs save failures automatically
      // ✅ 로깅 없음 - Repository에서 처리
    }
  }

  // ❌ BAD: UI 상태 업데이트는 로깅 불필요
  void updateTitle(String value) {
    state = state.copyWith(
      formData: state.formData.copyWith(title: value),
    );
    // ❌ Logger.debug('Title updated: $value');  // 불필요
    saveDraft();  // ✅ Draft 저장은 Repository로 위임
  }
}
```

**Provider는 로깅 불필요**:
```dart
// ✅ GOOD: Provider는 Either 패턴만 사용
@riverpod
Stream<List<MediaInfo>> mediaUploadQueue(Ref ref) async* {
  final repository = ref.watch(mediaRepositoryProvider);

  await for (final either in repository.watchUploadQueue()) {
    yield* either.fold(
      (failure) => Stream<List<MediaInfo>>.error(failure),  // ✅ Either 패턴
      (queue) async* { yield queue; },
    );
  }
}

// Widget에서 AsyncValue.when()으로 자동 에러 처리
final asyncQueue = ref.watch(mediaUploadQueueProvider);
asyncQueue.when(
  data: (queue) => UploadQueueWidget(queue: queue),
  error: (error, stack) => ErrorWidget(error: error),  // ✅ 자동 에러 UI
  loading: () => CircularProgressIndicator(),
);
```

---

### 설계 철학

**Clean Architecture 원칙**:
1. **Domain Layer**: 로깅 없음 (Pure Dart)
2. **Data Layer**: 모든 외부 작업 로깅 (Firestore, Cache, AI API)
3. **Presentation Layer**:
   - Notifier: 비즈니스 로직만 로깅 (Draft 로드/복원)
   - Provider: Either 패턴으로 에러 전파
   - Widget: AsyncValue.when()으로 UI 렌더링

**Single Responsibility**:
- **Repository**: 데이터 영속성 + 로깅 모두 관리
- **Notifier**: UI 상태 관리 + 최소한의 비즈니스 로직 로깅
- **UseCase**: 순수 비즈니스 로직만 담당

---

### 참고 문서

- **로깅 전략 가이드**: `/lib/services/logging/PRINT_TO_LOGGER_MIGRATION.md`
- **Logger 서비스**: `/lib/services/logging/logger_service.dart`
- **Data Layer 로깅 예시**: `data/repositories/post_creation_repository_v2_impl.dart`
- **Presentation Layer 로깅 예시**: `presentation/providers/create_post_notifier.dart`

---

## 🎯 빠른 참조 가이드

### 찾고자 하는 것 → 참조할 README 섹션

| 무엇을 찾을 때 | 어느 README | 어느 섹션 | 파일 위치 |
|---------------|-------------|-----------|-----------|
| **게시물 생성 로직** | `domain/README.md` | UseCase 섹션 | `domain/usecases/create_post_usecase.dart` |
| **Draft 자동 저장** | `data/README.md` | CreationCacheService 섹션 | `services/cache/creation_cache_service.dart` |
| **Firestore 데이터 변환** | `data/README.md` | Extension Pattern 섹션 | `domain/entities/*_extensions.dart` |
| **Firebase 저장 로직** | `data/README.md` | Repository 구현 섹션 | `data/repositories/post_creation_repository_v2_impl.dart` |
| **3-Layer 캐싱** | `data/README.md` | UnifiedCacheService 섹션 | `/lib/services/cache/unified_cache_service.dart` |
| **AI 서비스 통합** | `data/README.md` | Port-Adapter 섹션 | `data/services/gemini_ai_service.dart` |
| **에러 타입 정의** | `domain/README.md` | Failure 섹션 | `domain/failures/creation_failure.dart` |
| **엔티티 구조** | `domain/README.md` | Entity 섹션 | `domain/entities/post_creation.dart` |
| **Sealed Union Types** | `domain/README.md` | MediaInfo 섹션 | `domain/entities/media_info.dart` |
| **Factory Pattern** | `domain/README.md` | TargetAudience 섹션 | `domain/entities/target_audience.dart` |
| **Riverpod Notifier** | `presentation/README.md` | Providers 섹션 | `presentation/providers/create_post_notifier.dart` |
| **Freezed State Models** | `presentation/README.md` | States 섹션 | `presentation/providers/states/create_post_state.dart` |
| **3-Step Wizard UI** | `presentation/README.md` | Dialogs 섹션 | `presentation/widgets/dialogs/target_audience_dialog.dart` |
| **Smart Media Layout** | `presentation/README.md` | MediaSelection 섹션 | `presentation/providers/media/media_selection_notifier.dart` |
| **Queue Upload** | `presentation/README.md` | MediaUpload 섹션 | `presentation/providers/media/media_upload_notifier.dart` |
| **Korean Localization** | `presentation/README.md` | Delegates 섹션 | `presentation/delegates/korean_asset_picker_text_delegate.dart` |
| **DI 설정** | `di/creation_di_module.dart` | - | `di/creation_di_module.dart` |

---

## 🧭 Navigation Patterns

**파일**: [./presentation/routes/creation_routes.dart](./presentation/routes/creation_routes.dart)

Creation Feature는 **Feature Routes 패턴**을 사용하여 2개의 라우트를 관리합니다.

### 라우트 구성

| Route | Path | requireAuth | 설명 |
|-------|------|-------------|------|
| **createPost** | `/create` | ✅ true | 게시물 생성 페이지 (3-Step Wizard) |
| **targetAudience** | `/create/target` | ✅ true | AI 타겟팅 위자드 (Phase 1.1 완료) |

**모든 라우트는 인증 필수** (`requireAuth: true`):
- 게시물 생성은 로그인 필수 (악의적 사용 방지)
- AuthGuard 자동 적용 (Phase 4 Redirect Location Management)
- Guard Analytics 이벤트 자동 기록 (Phase 5)

### Phase 1.1 마이그레이션 (2025-11-10)

**Before (nav.dart 직접 정의)**:
```dart
GoRoute(
  path: '/create',
  name: 'createPost',
  builder: (context, state) => CreatePostPage(),
)
```

**After (Feature Routes + AppRoute 패턴)**:
```dart
AppRoute(
  name: 'createPost',
  path: '/create',
  requireAuth: true,  // AuthGuard 자동 통합
  builder: (context, params) => CreatePostPage(),
).toRoute(ref)
```

**주요 개선**:
- ✅ `requireAuth: true` → AuthGuard 자동 적용
- ✅ AppRoute 패턴 → 즉시 전환 (0ms, NoTransitionPage)
- ✅ WidgetRef 파라미터 → Riverpod 통합 지원
- ✅ 타입 안전 네비게이션 → `CreationRoutes` 상수

### 사용 예시

#### 1. 기본 네비게이션

```dart
import '/features/creation/presentation/routes/creation_routes.dart';

// 게시물 생성 페이지로 이동
context.goNamed(CreationRoutes.createPost);

// AI 타겟팅 위자드로 이동
context.goNamed(CreationRoutes.targetAudience);
```

#### 2. 인증 체크 + 네비게이션

```dart
// mounted 체크 포함 (위젯이 마운트된 상태에서만 이동)
context.goNamedAuth(
  CreationRoutes.createPost,
  mounted,
);
```

#### 3. FAB (Floating Action Button) → 게시물 생성

```dart
// HomePageWidget의 FAB 클릭 시
FloatingActionButton(
  onPressed: () {
    // 로그인 체크 후 생성 페이지로 이동
    context.goNamedAuth(
      CreationRoutes.createPost,
      mounted,
    );
  },
  child: Icon(Icons.add),
)
```

#### 4. Draft 복구 → 게시물 생성 재개

```dart
// Draft가 있을 때 자동으로 복구
@override
void initState() {
  super.initState();

  // Draft 확인
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final draftExists = await ref.read(
      draftExistsProvider.future,
    );

    if (draftExists) {
      // Draft 복구 다이얼로그 표시
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('작성 중인 게시물이 있습니다'),
          content: Text('이어서 작성하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Draft 삭제
                ref.read(createPostNotifierProvider.notifier).clearDraft();
              },
              child: Text('새로 작성'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // Draft 복구
                ref.read(createPostNotifierProvider.notifier).loadDraft();
                // 생성 페이지로 이동
                context.goNamed(CreationRoutes.createPost);
              },
              child: Text('이어서 작성'),
            ),
          ],
        ),
      );
    }
  });
}
```

### AuthGuard Integration

모든 Creation 라우트는 **AuthGuard**로 보호됩니다:

```dart
// GoRouter의 redirect 콜백에서 자동 체크
redirect: (context, state) {
  final redirectPath = AuthGuard.checkAuth(
    context: context,
    currentPath: state.uri.path,
  );

  // 미인증 사용자:
  // 1. NavigationNotifier.setRedirectLocation('/create') 저장
  // 2. Guard Analytics 이벤트 기록 (result='blocked', reason='auth_required')
  // 3. '/startPage'로 리다이렉션

  // 로그인 성공 후:
  // 1. Guard Analytics 이벤트 기록 (result='allowed', reason='authenticated')
  // 2. '/create'로 자동 이동
  // 3. redirectLocation 초기화

  return redirectPath;
}
```

**참조**:
- [AuthGuard 전체 가이드](/lib/app/router/guards/README.md)
- [Phase 4: Redirect Location Management](/lib/app/router/guards/README.md#redirect-location-management)
- [Phase 5: Guard Analytics](/lib/app/router/guards/README.md#phase-5-guard-analytics)

### 3-Step Wizard Navigation

게시물 생성은 **3단계 위자드**로 구성됩니다:

**Step 1: 연령/성별 선택** (`AgeGenderSelectionDialog`)
```dart
// Step 1 → Step 2 이동
void _onAgeGenderNext() {
  setState(() {
    _currentStep = 2;  // InterestsSelectionDialog
  });
}
```

**Step 2: 관심사 선택** (`InterestsSelectionDialog`)
```dart
// Step 2 → Step 3 이동
void _onInterestsNext() {
  setState(() {
    _currentStep = 3;  // AIRecommendationDialog
  });
}
```

**Step 3: AI 추천** (`AIRecommendationDialog`)
```dart
// AI 타겟팅 완료 → Firebase Functions 호출
Future<void> _onAIRecommendationConfirm() async {
  // 1. Gemini AI로 타겟 유저 선정
  final targetUsers = await ref.read(
    aiTargetingProvider(postContent).future,
  );

  // 2. Firebase Functions 호출 (sendNotificationsByAI)
  await ref.read(createPostNotifierProvider.notifier).sendNotifications(
    targetUsers: targetUsers,
  );

  // 3. 생성 완료 → 홈으로 이동
  if (mounted) {
    context.go('/home');
  }
}
```

### Draft 자동 저장 (500ms Debounce)

게시물 생성 중 **자동으로 Draft 저장**:

```dart
class CreatePostNotifier extends _$CreatePostNotifier {
  Timer? _autoSaveTimer;

  // 제목 변경 시
  void updateTitle(String title) {
    state = state.copyWith(title: title);
    _scheduleDraftSave();
  }

  // 설명 변경 시
  void updateDescription(String description) {
    state = state.copyWith(description: description);
    _scheduleDraftSave();
  }

  // 500ms Debounce
  void _scheduleDraftSave() {
    _autoSaveTimer?.cancel();
    _autoSaveTimer = Timer(Duration(milliseconds: 500), () {
      _saveDraft();
    });
  }

  // Draft 저장 (CreationCacheService)
  Future<void> _saveDraft() async {
    await _cacheService.set(
      CreationCacheKeys.draft(_currentUserId),
      state.toDraft(),
      ttl: Duration(days: 7),  // 7일 보관
    );
  }
}
```

**Draft 복구**:
```dart
// 앱 재실행 시 Draft 확인
@riverpod
Future<bool> draftExists(DraftExistsRef ref) async {
  final cacheService = getIt<CreationCacheService>();
  final userId = ref.watch(currentUserIdProvider);

  final draft = await cacheService.get<DraftModel>(
    CreationCacheKeys.draft(userId),
  );

  return draft != null;
}
```

### Media Upload Integration

미디어 업로드는 **큐 기반 병렬 처리**:

```dart
// MediaUploadNotifier
class MediaUploadNotifier extends _$MediaUploadNotifier {
  // 큐에 미디어 추가
  void addToQueue(List<XFile> files) {
    for (final file in files) {
      _uploadQueue.add(file);
    }
    _processQueue();  // 병렬 업로드 시작
  }

  // 큐 처리 (최대 3개 동시 업로드)
  Future<void> _processQueue() async {
    while (_uploadQueue.isNotEmpty && _activeUploads.length < 3) {
      final file = _uploadQueue.removeFirst();
      _activeUploads.add(file);

      // 병렬 업로드
      unawaited(_uploadFile(file));
    }
  }

  // 파일 업로드 (재시도 로직 포함)
  Future<void> _uploadFile(XFile file) async {
    try {
      final downloadUrl = await _storageRepository.uploadMedia(
        file: file,
        userId: _currentUserId,
      );

      // 업로드 완료 → 상태 업데이트
      state = state.copyWith(
        uploadedUrls: [...state.uploadedUrls, downloadUrl],
      );
    } catch (e) {
      // 재시도 (최대 3회)
      if (_retryCount < 3) {
        _retryCount++;
        await Future.delayed(Duration(seconds: 2));
        await _uploadFile(file);  // 재시도
      } else {
        // 실패 → 에러 상태
        state = state.copyWith(
          error: CreationFailure.uploadError(e.toString()),
        );
      }
    } finally {
      _activeUploads.remove(file);
      _processQueue();  // 다음 파일 처리
    }
  }
}
```

### AI Moderation Flow

게시물 생성 시 **AI 컨텐츠 검열**:

**Step 1: Perspective API (텍스트 욕설 감지)**
```dart
final perspectiveResult = await _perspectiveApi.analyzeComment(title + description);

if (perspectiveResult.toxicity > 0.8) {
  return left(CreationFailure.inappropriateContent(
    'Inappropriate language detected',
  ));
}
```

**Step 2: Gemini AI (컨텍스트 기반 판단)**
```dart
final geminiResult = await _geminiAi.moderateText(title + description);

if (!geminiResult.isAppropriate) {
  return left(CreationFailure.inappropriateContent(
    geminiResult.reason,
  ));
}
```

**Step 3: Cloud Vision API (이미지 안전성 확인)**
```dart
for (final imagePath in imagePaths) {
  final visionResult = await _cloudVision.analyzeSafety(imagePath);

  if (visionResult.hasViolations) {
    return left(CreationFailure.inappropriateContent(
      'Inappropriate image detected',
    ));
  }
}
```

**검열 실패 시 네비게이션**:
```dart
// 검열 실패 → 에러 다이얼로그 → 생성 페이지 유지
if (moderationFailed) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('부적절한 콘텐츠'),
      content: Text('게시물 내용이 커뮤니티 가이드라인을 위반합니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('수정하기'),
        ),
      ],
    ),
  );

  // 생성 페이지에 머무름 (네비게이션 없음)
  return;
}
```

### 애니메이션

모든 Creation 라우트는 **즉시 전환** (Duration.zero):
- 성능 최적화 우선
- AppRoute 패턴 기본 동작: NoTransitionPage
- 애니메이션 없이 즉시 화면 전환

### nav.dart 통합

```dart
// /lib/app/router/navigation/nav.dart (line 128)
GoRouter createRouter(WidgetRef ref) => GoRouter(
  routes: [
    ...CreationRoutes.routes(ref), // 2개 라우트 병합
    // ... 다른 Feature Routes
  ],
);
```

### 참조 문서

- **[creation_routes.dart](./presentation/routes/creation_routes.dart)** - 라우트 정의
- **[Router 시스템 개요](/lib/app/router/README.md)** - 전체 Router 아키텍처
- **[Navigation 상세 가이드](/lib/app/router/navigation/README.md)** - Feature Routes 패턴
- **[AuthGuard 가이드](/lib/app/router/guards/README.md)** - 인증 가드 + Analytics

---

## 📚 레이어별 README 안내

### 1. Data Layer README (`data/README.md` - 1,664줄)

**📌 핵심 내용**:
- Firebase-Centric Architecture v2.0 설명
- Extension Pattern 사용법 (DTO/Mapper 제거, 85% 코드 감소)
- 9개 Specialized Repositories (관심사 분리)
- CreationCacheService + UnifiedCacheService 3-Layer 캐싱 전략
- Idempotency Pattern (중복 작업 방지)
- Port-Adapter Pattern (Storage 추상화)
- CQRS Pattern (Metrics Query-only)
- Sharding Strategy (고성능 Counter, 10 shards)

**📖 주요 섹션**:
1. **아키텍처 개요**: Firebase-Centric v2.0 vs Clean Architecture
2. **Extension Pattern**: PostCreation/TargetAudience/MediaInfo Entity ↔ Firestore 변환
3. **Core Repositories**: PostCreationRepositoryV2Impl, TargetAudienceRepositoryImpl, MediaRepositoryImpl
4. **Upload & Processing**: MediaUploadRepositoryImpl, ImageProcessingRepositoryImpl
5. **Specialized Repositories**: ContentModerationRepository, ContentMetricsRepository, ContentVisibilityRepository
6. **CreationCacheService**: Draft 자동 저장, AI 결과 캐싱, 미디어 메타데이터 캐싱
7. **Idempotency Pattern**: UUID 기반 eventId, 중복 방지 로직
8. **Performance**: 캐시 히트율 60%+, Draft 복원 <10ms, AI 비용 70% 절감

**💡 언제 참조?**
- Firebase Firestore 연동 방법을 알고 싶을 때
- Extension Pattern 사용법을 배우고 싶을 때
- Draft 자동 저장 전략을 이해하고 싶을 때
- AI 서비스 통합 방법을 확인하고 싶을 때
- Firestore 컬렉션 구조를 파악하고 싶을 때
- CQRS 패턴 및 Sharding 전략을 알고 싶을 때

**🔗 바로가기**: [data/README.md](./data/README.md)

---

### 2. Domain Layer README (`domain/README.md` - 2,357줄)

**📌 핵심 내용**:
- Clean Architecture v4.0 원칙
- Freezed 불변 엔티티 패턴 (PostCreation, TargetAudience, MediaInfo)
- Sealed Union Types (타입 안전 다형성)
- Either<Failure, Success> 에러 처리
- Repository 인터페이스 설계 (4개)
- Domain Service 인터페이스 (4개 AI 서비스)
- UseCase 패턴 (5+개 - 단일 책임)
- CreationFailure 타입 정의 (16+ types, 한국어 메시지)
- Factory Pattern (3가지 TargetAudience 생성)

**📖 주요 섹션**:
1. **Entities**: PostCreation (Aggregate Root), TargetAudience (Value Object), MediaInfo (Sealed Union)
2. **Entity Extensions**: 409 lines (Phase 5) - Firestore 변환
3. **Failures**: CreationFailure (16+ types) - 한국어 에러 메시지
4. **Repository Interfaces**: IPostCreationRepository, ITargetAudienceRepository, IMediaRepository, IContentMetricsRepository
5. **Domain Services**: IImageProcessingService, IImageModerationService, IAIService, ITargetAudienceService
6. **UseCases**: CreatePost, SaveDraft, UploadMedia, GenerateTitle, ModerateContent
7. **Constants**: creation_constants.dart (검증 규칙), ai_generation_constants.dart (Gemini 설정)
8. **3가지 독특한 패턴**: Sealed Union Types, Factory Pattern (3 types), AI Integration (4 services)

**💡 언제 참조?**
- 비즈니스 로직을 이해하고 싶을 때
- 엔티티 구조를 확인하고 싶을 때
- Sealed Union Types 사용법을 알고 싶을 때
- Factory Pattern 사용법을 배우고 싶을 때
- 에러 처리 방법을 알고 싶을 때
- Repository/Service 계약을 확인하고 싶을 때
- UseCase 사용법을 배우고 싶을 때
- AI 서비스 인터페이스를 확인하고 싶을 때

**🔗 바로가기**: [domain/README.md](./domain/README.md)

---

### 3. Presentation Layer README (`presentation/README.md` - 3,324줄)

**📌 핵심 내용**:
- Riverpod 3.x 상태 관리 (`@riverpod` annotation)
- Freezed 불변 State (8개 State models)
- 5개 Main Notifiers (CreatePost, TargetAudience, MediaSelection, MediaUpload, MediaValidation)
- ConsumerWidget/ConsumerStatefulWidget
- AsyncValue.when() 자동 상태 처리
- 3-Step Wizard UI (TargetAudienceDialog)
- Smart Media Layout (Aspect ratio-based)
- Queue-based Upload (max 3 concurrent)
- Draft Auto-Save (500ms debounce)
- Korean Localization (wechat_assets_picker delegates)

**📖 주요 섹션**:
1. **Providers**: 5개 Main Notifiers + 23개 Provider 파일 (7,748줄)
2. **Freezed State Models**: 8개 State classes (CreatePostState, TargetAudienceState, MediaSelectionState, etc.)
3. **Screens**: 4개 화면 (CreatePost, ProImageEditor, ThumbnailSelection, ImageViewer)
4. **Widgets**: 20개 위젯 (Components, CreatePost, Dialogs, Media)
5. **Constants**: 10개 파일 (Dimensions, Colors, Strings, FieldStyles, etc.)
6. **Riverpod 3.x Patterns**: ref.watch vs ref.read vs ref.listen
7. **Performance Optimizations**: Draft auto-save, Cache-first, Parallel upload, Lazy loading, Smart layout caching
8. **Integration Guide**: UseCase 호출, Repository 통합, 에러 처리, 캐시 전략
9. **Best Practices**: DO/DON'T 가이드
10. **Troubleshooting**: 5가지 일반적인 이슈

**💡 언제 참조?**
- UI 컴포넌트를 수정하고 싶을 때
- Riverpod 3.x Notifier 사용법을 알고 싶을 때
- Freezed State 관리 방법을 배우고 싶을 때
- 3-Step Wizard UI를 커스터마이징하고 싶을 때
- Smart Media Layout 로직을 이해하고 싶을 때
- Queue-based Upload를 수정하고 싶을 때
- Draft Auto-Save를 커스터마이징하고 싶을 때
- Korean Localization을 추가/수정하고 싶을 때
- Performance Optimization을 적용하고 싶을 때

**🔗 바로가기**: [presentation/README.md](./presentation/README.md)

---

## 📍 주요 파일 위치

### 게시물 생성 플로우 추적

```
사용자 입력 → Presentation → Domain → Data → Firebase
                    ↓           ↓        ↓
           CreatePostNotifier  UseCase  Repository
```

1. **UI 이벤트**: `presentation/screens/create_post/create_post_screen.dart`
2. **Notifier 호출**: `presentation/providers/create_post_notifier.dart` (createPost 메서드)
3. **UseCase 실행**: `domain/usecases/create_post_usecase.dart`
4. **Repository 호출**: `domain/repositories/i_post_creation_repository.dart`
5. **Data 구현**: `data/repositories/post_creation_repository_v2_impl.dart`
6. **Extension 변환**: `domain/entities/post_creation_extensions.dart`
7. **Firebase 저장**: Firestore `posts` 컬렉션
8. **Cache 무효화**: `services/cache/creation_cache_service.dart`

### Draft 자동 저장 플로우

```
텍스트 변경 → Debounce (500ms) → Cache → (선택적) Firestore
                  ↓                  ↓
         CreatePostNotifier  CreationCacheService
```

1. **텍스트 입력**: `presentation/widgets/create_post/text_input_widget.dart`
2. **Notifier 상태 업데이트**: `presentation/providers/create_post_notifier.dart` (formData 변경)
3. **Debounce Timer**: `ref.listenSelf()` → 500ms 후 실행
4. **CreationCacheService 호출**: `services/cache/creation_cache_service.dart`
5. **3-Layer Caching**:
   - L1 Memory: `UnifiedCacheService` → `SimpleMemoryCache` (LRU, <10ms)
   - L2 Hive: `UnifiedCacheService` → Hive Box (10-30ms)
   - L3 Firestore: (선택적) Repository → Firestore (50-500ms)
6. **Draft 복원**: 앱 재시작 시 `CreationCacheService.getDraftPost(userId)`

### AI 타겟팅 플로우

```
자연어 입력 → Gemini AI → TargetAudience Entity → Firebase Functions → 타겟 목록
                  ↓              ↓                    ↓
         IAIService    TargetAudienceNotifier  calculateTargetAudience
```

1. **자연어 입력**: `presentation/widgets/dialogs/target_audience_dialog.dart` (Step 3)
2. **Notifier 호출**: `presentation/providers/target_audience_notifier.dart`
3. **Domain Service**: `domain/services/i_target_audience_service.dart`
4. **Repository 구현**: `data/repositories/target_audience_repository_impl.dart`
5. **Gemini AI 호출**: `data/services/gemini_ai_service.dart`
6. **AI 파싱**: 자연어 → TargetAudience Entity (Factory Pattern)
7. **Firebase Functions**: `calculateTargetAudience` Cloud Function
8. **타겟 목록 반환**: AI 기반 추천 사용자 목록
9. **Cache 저장**: `CreationCacheService.setTargetAudiencePreset(userId, audience)`

---

## 🔧 DI (Dependency Injection)

**파일**: `di/creation_di_module.dart`

**등록되는 의존성**:
- **Repository 구현체** (9개):
  - PostCreationRepositoryV2Impl
  - TargetAudienceRepositoryImpl
  - MediaRepositoryImpl
  - MediaUploadRepositoryImpl
  - ImageProcessingRepositoryImpl
  - ContentModerationRepositoryImpl
  - ContentMetricsRepositoryImpl
  - ContentVisibilityRepositoryImpl
  - (기타 1개)
- **Domain Services** (4개):
  - GeminiAIService (implements IAIService)
  - ImageProcessingService (implements IImageProcessingService)
  - ImageModerationService (implements IImageModerationService)
  - TargetAudienceService (implements ITargetAudienceService)
- **UseCase** (5+개):
  - CreatePostUseCase
  - SaveDraftUseCase
  - UploadMediaUseCase
  - GenerateTitleUseCase
  - ModerateContentUseCase
- **공유 서비스**:
  - CreationCacheService (Feature 전용)
  - UnifiedCacheService (전역 싱글톤, GetIt 등록 불필요)
  - IdempotencyService (전역 싱글톤, GetIt 등록 불필요)

**Provider에서 사용**:
```dart
// presentation/providers/creation_providers.dart
final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  return getIt<CreatePostUseCase>();
});

@riverpod
class CreatePost extends _$CreatePost {
  @override
  CreatePostState build() {
    return const CreatePostState();
  }

  Future<void> createPost() async {
    final useCase = getIt<CreatePostUseCase>();
    final result = await useCase.execute(
      post: state.formData.toPostCreation(),
    );

    result.fold(
      (failure) => state = state.copyWith(errorMessage: failure.message),
      (post) => state = state.copyWith(createdPost: post),
    );
  }
}
```

---

## 📊 통계

| 구분 | 파일 수 | 총 라인 수 | 주요 패턴 |
|------|---------|-----------|-----------|
| **Data** | 11 | ~4,200 | Extension (85% 감소), Port-Adapter, CreationCache, Idempotency, CQRS, Sharding |
| **Domain** | 30 | ~4,495 | Freezed, Sealed Union, Either, Factory, UseCase, Repository Interface, Domain Service |
| **Presentation** | 61 | ~14,509 | Riverpod 3.x, Freezed State, Notifier, 3-Step Wizard, Smart Layout, Queue Upload |
| **DI** | 1 | ~200 | GetIt 등록 |
| **문서** | 4 | ~7,345+ | 통합 가이드 + 레이어별 상세 문서 |
| **총합** | **107** | **~30,749** | Clean Architecture v4.0 + Firebase-Centric v2.0 + AI Integration |

**Creation Feature vs Chat Feature**:
| 항목 | Chat | Creation | 비율 |
|------|------|----------|------|
| **파일 수** | 53 | 107 | 2.0x |
| **코드 라인** | 20,759 | 30,749 | 1.5x |
| **문서 라인** | 12,000+ | 7,345+ | 0.6x |
| **Presentation 파일** | 17 | 61 | 3.6x |
| **Presentation 라인** | 5,162 | 14,509 | 2.8x |
| **Domain Entities** | 5 | 3 | 0.6x |
| **Repositories** | 2 | 9 | 4.5x |
| **Domain Services** | 0 | 4 | ∞ |
| **AI 통합** | 1 (Gemini) | 4 (Gemini, Perspective, Cloud Vision, Functions) | 4.0x |
| **복잡도** | Medium | High | - |

**Phase 5 Extension Pattern Migration 성과**:
- **Before (Phase 4)**: 5,615 lines (DataSource + DTO + Mapper + Repositories)
- **After (Phase 5)**: 4,548 lines (Extension + Repositories)
- **코드 감소**: -1,067 lines (**-19%**)
- **삭제된 요소**: DataSource (450 lines), DTO (600 lines), Mapper (565 lines)
- **추가된 요소**: Extension (409 lines in domain/entities/)
- **효율성**: 85% 코드 감소 (1,615 → 409 lines)

---

## 🚀 시작하기

### 1. 새로운 Creation 기능 추가 시

1. **Domain Entity 정의**: `domain/entities/` (필요시 새 엔티티 추가)
2. **Failure 추가**: `domain/failures/creation_failure.dart` (새 실패 타입)
3. **Repository 인터페이스**: `domain/repositories/i_*_repository.dart`
4. **Domain Service 인터페이스**: `domain/services/i_*_service.dart` (필요시)
5. **UseCase 생성**: `domain/usecases/*_usecase.dart`
6. **Repository 구현**: `data/repositories/*_repository_impl.dart`
7. **Extension 작성**: `domain/entities/*_extensions.dart` (Firestore 변환)
8. **Notifier 생성**: `presentation/providers/*_notifier.dart`
9. **State 정의**: `presentation/providers/states/*_state.dart` (Freezed)
10. **UI 컴포넌트**: `presentation/screens/` 또는 `widgets/`
11. **DI 등록**: `di/creation_di_module.dart`

### 2. 버그 수정 시

1. **증상 파악**: 어느 레이어에서 발생? (UI/비즈니스/데이터)
2. **해당 레이어 README 참조**: 섹션별 상세 설명 확인
3. **파일 위치 찾기**: 위 "주요 파일 위치" 섹션 참조
4. **플로우 추적**: 게시물 생성/Draft 저장/AI 타겟팅 플로우 확인
5. **에러 타입 확인**: `domain/failures/creation_failure.dart`
6. **Notifier 상태 확인**: `presentation/providers/*_notifier.dart`
7. **Extension 로직 검증**: `domain/entities/*_extensions.dart`

### 3. 성능 최적화 시

1. **캐시 전략**: `data/README.md` > CreationCacheService 섹션
2. **Notifier 최적화**: `presentation/README.md` > Performance Optimizations 섹션
3. **Draft Auto-Save**: `presentation/README.md` > CreatePostNotifier 섹션
4. **Queue Upload**: `presentation/README.md` > MediaUploadNotifier 섹션
5. **Smart Layout Caching**: `presentation/README.md` > MediaSelectionNotifier 섹션
6. **Extension 효율성**: `data/README.md` > Extension Pattern 섹션
7. **Image Caching**: `presentation/README.md` > UnifiedImageCacheService 섹션

### 4. UI 커스터마이징 시

1. **3-Step Wizard**: `presentation/README.md` > Dialogs 섹션
2. **Smart Media Layout**: `presentation/README.md` > MediaSelection 섹션
3. **Draft Auto-Save UI**: `presentation/README.md` > CreatePostNotifier 섹션
4. **Korean Localization**: `presentation/README.md` > Delegates 섹션
5. **Constants 수정**: `presentation/constants/` (Dimensions, Colors, Strings, FieldStyles)
6. **Freezed State**: `presentation/providers/states/` (State 모델 확장)

---

## 🔍 자주 찾는 질문

<details>
<summary><strong>Q1. Draft 자동 저장은 어떻게 작동하나요?</strong></summary>

**A**: 3단계로 작동합니다.
1. **Debouncing (500ms)**: `CreatePostNotifier.ref.listenSelf()` → Timer로 500ms 후 실행
2. **CreationCacheService**: `putDraftPost(userId, draft)` → 3-Layer 캐싱
3. **3-Layer Caching**:
   - L1 Memory: <10ms (SimpleMemoryCache, LRU)
   - L2 Hive: 10-30ms (영구 저장)
   - L3 Firestore: (선택적) 50-500ms

**복원**: 앱 재시작 시 `CreationCacheService.getDraftPost(userId)` → L1 → L2 → L3 순서

📖 상세: `data/README.md` > CreationCacheService 섹션, `presentation/README.md` > CreatePostNotifier 섹션
</details>

<details>
<summary><strong>Q2. Extension Pattern은 왜 사용하나요?</strong></summary>

**A**: **85% 코드 감소**를 달성하기 위해 사용합니다.
- **Before**: DataSource (450줄) + DTO (600줄) + Mapper (565줄) = 1,615줄
- **After**: Extension (409줄) = 85% 감소

**장점**:
- Firestore ↔ Entity 직접 변환
- DTO/Mapper 중간 레이어 제거
- 코드 간결성 대폭 향상
- Domain 모델 직접 사용

**사용 예시**:
```dart
// Firestore → Entity
final post = PostCreationFirestore.fromFirestore(doc);

// Entity → Firestore
await firestore.collection('posts').add(post.toFirestore());
```

📖 상세: `data/README.md` > Extension Pattern 섹션
</details>

<details>
<summary><strong>Q3. 3-Step Wizard UI는 어떻게 구현되나요?</strong></summary>

**A**: **TargetAudienceNotifier** + **TargetAudienceDialog**로 구현됩니다.

**3단계 플로우**:
1. **Step 1: Collection Type** → `collection_type_selector.dart`
   - 전체 / 친구 / 팔로워 / 커스텀 선택
2. **Step 2: Target Count** → `target_count_selector.dart`
   - 타겟 오디언스 수 선택 (10~1,000명)
3. **Step 3: Custom Settings** → `detailed_target_selector.dart`
   - 성별, 연령, 지역, 관심사 상세 설정

**상태 관리**:
```dart
@freezed
class TargetAudienceState with _$TargetAudienceState {
  const factory TargetAudienceState({
    @Default(0) int currentStep,
    @Default(TargetAudienceType.general) TargetAudienceType selectedType,
    @Default(100) int targetCount,
    TargetAudience? customAudience,
  }) = _TargetAudienceState;
}
```

📖 상세: `presentation/README.md` > TargetAudienceNotifier 섹션, Dialogs 섹션
</details>

<details>
<summary><strong>Q4. Smart Media Layout은 어떻게 계산되나요?</strong></summary>

**A**: **Aspect Ratio 분석**으로 자동 감지합니다.

**알고리즘**:
```dart
void _updateLayout() {
  // 모든 이미지의 Aspect Ratio 평균 계산
  final avgRatio = allRatios.reduce((a, b) => a + b) / allRatios.length;

  LayoutType layoutType;
  if (avgRatio > 1.3) {
    layoutType = LayoutType.horizontal;  // Wide images
  } else if (avgRatio < 0.7) {
    layoutType = LayoutType.vertical;    // Tall images
  } else {
    layoutType = LayoutType.grid;        // Square-ish
  }

  // UnifiedBoxCalculator로 최적 크기 계산
  final boxSizes = _calculateBoxSizes(layoutType, allRatios);
  state = state.copyWith(layoutType: layoutType, boxSizes: boxSizes);
}
```

**3가지 레이아웃**:
- **Horizontal**: avgRatio > 1.3 (가로 이미지)
- **Vertical**: avgRatio < 0.7 (세로 이미지)
- **Grid**: 0.7 ≤ avgRatio ≤ 1.3 (정사각형)

📖 상세: `presentation/README.md` > MediaSelectionNotifier 섹션
</details>

<details>
<summary><strong>Q5. AI 서비스는 어떻게 통합되나요?</strong></summary>

**A**: **Port-Adapter Pattern** + **Domain Service Interface** 사용.

**4개 AI 서비스**:
1. **Gemini AI** (IAIService):
   - 타이틀 자동 생성
   - 태그 자동 생성
   - 컨텍스트 기반 검열
2. **Perspective API** (IImageModerationService):
   - 텍스트 유해성 검사 (독성, 폭력, 혐오)
3. **Cloud Vision API** (IImageModerationService):
   - 이미지 안전성 검사 (성인, 폭력, 스푸핑)
4. **Firebase Functions** (ITargetAudienceService):
   - AI 기반 타겟팅 (calculateTargetAudience)

**통합 구조**:
```
Domain Layer (Port)          Data Layer (Adapter)
IAIService                ← GeminiAIService
IImageModerationService   ← PerspectiveAPIService
                          ← CloudVisionService
ITargetAudienceService    ← TargetAudienceRepositoryImpl (Functions)
```

📖 상세: `domain/README.md` > Domain Services 섹션, `data/README.md` > Port-Adapter 섹션
</details>

<details>
<summary><strong>Q6. Queue-based Upload는 어떻게 작동하나요?</strong></summary>

**A**: **MediaUploadNotifier** + **Future.wait** 병렬 업로드.

**알고리즘**:
```dart
Future<List<String>> uploadFiles(List<File> files) async {
  // Queue에 추가
  for (final file in files) {
    state = state.copyWith(
      queue: [...state.queue, UploadItem(file: file, status: UploadStatus.pending)],
    );
  }

  // 최대 3개씩 병렬 업로드
  while (state.queue.any((item) => item.status == UploadStatus.pending)) {
    final pending = state.queue
        .where((item) => item.status == UploadStatus.pending)
        .take(3)  // max 3 concurrent
        .toList();

    // Future.wait로 병렬 실행
    final results = await Future.wait(
      pending.map((item) => _uploadSingle(item)),
    );

    uploadedUrls.addAll(results.whereType<String>());
  }

  return uploadedUrls;
}
```

**특징**:
- 최대 3개 동시 업로드
- 진행률 실시간 추적
- 재시도 로직 (최대 3회)
- UploadQueueState (Freezed) 관리

📖 상세: `presentation/README.md` > MediaUploadNotifier 섹션
</details>

<details>
<summary><strong>Q7. Sealed Union Types는 어떻게 사용하나요?</strong></summary>

**A**: **MediaInfo** = **ImageInfo | VideoInfo** 패턴으로 타입 안전한 다형성.

**정의**:
```dart
@freezed
sealed class MediaInfo with _$MediaInfo {
  const factory MediaInfo.image({
    required String url,
    required int width,
    required int height,
    String? thumbnailUrl,
  }) = ImageInfo;

  const factory MediaInfo.video({
    required String url,
    required Duration duration,
    String? thumbnailUrl,
    int? width,
    int? height,
  }) = VideoInfo;

  factory MediaInfo.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoFromJson(json);
}
```

**사용 예시** (Exhaustive Pattern Matching):
```dart
final mediaInfo = MediaInfo.image(...);

mediaInfo.when(
  image: (url, width, height, thumbnailUrl) {
    // 이미지 처리
  },
  video: (url, duration, thumbnailUrl, width, height) {
    // 비디오 처리
  },
);
```

**장점**:
- 타입 안전성 (컴파일 타임 체크)
- Exhaustive Checking (모든 케이스 강제)
- 코드 간결성

📖 상세: `domain/README.md` > MediaInfo 섹션
</details>

<details>
<summary><strong>Q8. Idempotency Pattern은 어떻게 작동하나요?</strong></summary>

**A**: **UUID 기반 eventId**로 중복 작업 방지.

**플로우**:
```dart
// 1. eventId 생성
final eventId = _idempotencyService.generateEventId();

// 2. 중복 체크
if (!await _idempotencyService.markAsProcessing(eventId)) {
  return left(CreationFailure.duplicateOperation());
}

// 3. 작업 실행
try {
  await _firestore.collection('posts').add(data);
  await _idempotencyService.markAsCompleted(eventId);
} catch (e) {
  await _idempotencyService.markAsFailed(eventId);
  rethrow;
}
```

**IdempotencyService 구조**:
- `generateEventId()`: UUID v4 생성
- `markAsProcessing(eventId)`: 처리 중 마킹 (false이면 중복)
- `markAsCompleted(eventId)`: 완료 마킹
- `markAsFailed(eventId)`: 실패 마킹
- TTL: 24시간 (Hive에 저장)

📖 상세: `data/README.md` > Idempotency Pattern 섹션
</details>

<details>
<summary><strong>Q9. Factory Pattern은 왜 3가지가 필요한가요?</strong></summary>

**A**: **TargetAudience** 생성 시나리오가 3가지이기 때문입니다.

**3가지 Factory**:
1. **TargetAudience.general()**: 전체 사용자 대상
   - collectionType: 'all'
   - 필터 없음
2. **TargetAudience.detailed()**: 간단한 필터링
   - collectionType: 'friends' | 'followers'
   - targetCount 설정
3. **TargetAudience.custom()**: 상세 필터링
   - 성별, 연령, 지역, 관심사 모두 설정
   - AI 기반 타겟팅 가능

**사용 예시**:
```dart
// 전체 대상
final allAudience = TargetAudience.general(targetCount: 1000);

// 친구 대상
final friendsAudience = TargetAudience.detailed(
  collectionType: 'friends',
  targetCount: 100,
);

// 커스텀 타겟
final customAudience = TargetAudience.custom(
  gender: 'female',
  ageGroup: '20s',
  region: 'seoul',
  interests: ['fashion', 'beauty'],
  targetCount: 50,
);
```

**장점**:
- 시나리오별 최적화
- 필수 파라미터 강제
- 코드 가독성 향상

📖 상세: `domain/README.md` > TargetAudience 섹션
</details>

<details>
<summary><strong>Q10. Korean Localization은 어떻게 구현되나요?</strong></summary>

**A**: **KoreanAssetPickerTextDelegate** + **Korean 에러 메시지** + **Korean UI 상수**.

**1. wechat_assets_picker 한국어화**:
```dart
// presentation/delegates/korean_asset_picker_text_delegate.dart
class KoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get edit => '편집';

  // ... 50+ 번역
}
```

**2. CreationFailure 한국어 메시지**:
```dart
// domain/failures/creation_failure.dart
@freezed
sealed class CreationFailure with _$CreationFailure {
  const factory CreationFailure.networkError([String? message]) = _NetworkError;
  // message: '네트워크 연결을 확인해주세요.'

  const factory CreationFailure.invalidInput([String? message]) = _InvalidInput;
  // message: '입력 내용이 올바르지 않습니다.'

  // ... 16+ 한국어 메시지
}
```

**3. UI 상수 한국어**:
```dart
// presentation/constants/strings.dart
class CreationStrings {
  static const String createPost = '게시물 작성';
  static const String selectTargetAudience = '타겟 오디언스 선택';
  static const String uploadMedia = '미디어 업로드';
  // ... 50+ 한국어 문자열
}
```

📖 상세: `presentation/README.md` > Delegates 섹션, Korean Localization 섹션
</details>

---

## 📝 기여 가이드

### 코드 수정 시

1. **레이어 규칙 준수**:
   - Presentation → Domain → Data 방향으로만 의존
   - Domain은 프레임워크 독립 (Pure Dart, Flutter/Firebase 의존성 없음)
   - Data는 Firebase SDK 직접 사용 (Firebase-Centric v2.0)

2. **패턴 일관성**:
   - Entity는 Freezed 사용 (`@freezed` annotation)
   - Sealed Union은 sealed class 사용 (MediaInfo)
   - Factory는 명명된 생성자 사용 (TargetAudience)
   - Repository는 Either 패턴 (`Either<Failure, T>`)
   - Extension으로 Firestore 변환 (fromFirestore, toFirestore)
   - Notifier는 Riverpod 3.x (`@riverpod` annotation)

3. **문서 업데이트**:
   - 파일 추가 시: 해당 레이어 README 업데이트
   - 아키텍처 변경 시: 이 통합 README 업데이트
   - 주요 변경사항: CHANGELOG 기록

4. **테스트 작성**:
   - UseCase: 비즈니스 로직 단위 테스트
   - Repository: Mock Firebase 통합 테스트
   - Notifier: Riverpod 상태 관리 테스트
   - Widget: flutter_test 위젯 테스트

5. **코드 생성**:
   - Freezed 추가 시: `dart run build_runner build --delete-conflicting-outputs`
   - Riverpod 추가 시: `dart run build_runner watch`
   - JSON 추가 시: `@JsonSerializable()` annotation

---

## 🎓 학습 가이드

### 초보자를 위한 학습 경로

1. **Clean Architecture 이해**: `domain/README.md` 읽기
   - Entity, Repository Interface, UseCase, Failure 개념
2. **Firebase-Centric v2.0**: `data/README.md` 읽기
   - Extension Pattern, 9 Repositories, 3-Layer Caching
3. **Riverpod 3.x**: `presentation/README.md` 읽기
   - Notifier, Freezed State, @riverpod annotation
4. **실습**: 간단한 Draft 저장 기능 추가
   - CreatePostNotifier → UseCase → Repository → Cache

### 고급 개발자를 위한 참조

1. **Extension Pattern 심화**: `data/README.md` > Extension 섹션
   - 85% 코드 감소 달성 방법
   - PostCreation/TargetAudience/MediaInfo 변환
2. **Sealed Union Types**: `domain/README.md` > MediaInfo 섹션
   - 타입 안전한 다형성
   - Exhaustive Pattern Matching
3. **Factory Pattern 심화**: `domain/README.md` > TargetAudience 섹션
   - 3가지 Factory 사용 시나리오
4. **AI Integration**: `data/README.md` > Port-Adapter 섹션
   - 4개 AI 서비스 통합 (Gemini, Perspective, Cloud Vision, Functions)
5. **3-Step Wizard UI**: `presentation/README.md` > Dialogs 섹션
   - 복잡한 상태 관리
   - TargetAudienceNotifier 구현
6. **Queue-based Upload**: `presentation/README.md` > MediaUploadNotifier 섹션
   - 병렬 업로드 (max 3 concurrent)
   - 진행률 추적 및 재시도 로직
7. **Performance Optimization**: `presentation/README.md` > Performance 섹션
   - Draft auto-save (500ms debounce)
   - Cache-first loading (<10ms)
   - Smart layout caching

---

## 📞 문의 및 지원

- **버그 리포트**: GitHub Issues
- **아키텍처 질문**: 각 레이어 README의 "자주 찾는 질문" 섹션 참조
- **기능 제안**: Feature Request 템플릿 사용
- **기술 문서**: `/docs` 디렉토리의 가이드 참조

---

## 🔗 관련 문서

### 내부 문서
- [Data Layer README](./data/README.md) - Firebase-Centric v2.0 아키텍처, Extension Pattern, 9 Repositories
- [Domain Layer README](./domain/README.md) - Clean Architecture v4.0, Sealed Union, Factory, 4 AI Services
- [Presentation Layer README](./presentation/README.md) - Riverpod 3.x, 5 Notifiers, 8 States, Korean Localization
- [Creation DI Module](./di/creation_di_module.dart) - Dependency Injection 설정

### 공유 서비스
- `/lib/services/cache/unified_cache_service.dart` - 3-Layer 캐싱 시스템
- `/lib/services/cache/creation_cache_service.dart` - Creation 전용 캐시 (Draft, AI, Media)
- `/lib/services/cache/simple_memory_cache.dart` - L1 메모리 캐시 (LRU, 100개 제한)
- `/lib/services/cache/cache_statistics.dart` - 캐시 성능 모니터링
- `/lib/core/utils/idempotency_service.dart` - 중복 방지 서비스 (UUID 기반)
- `/lib/core/utils/shard_utils.dart` - Sharded Counter 유틸리티 (10 shards)

### Feature 비교 문서
- [Chat Feature README](/lib/features/chat/README.md) - 실시간 채팅 시스템 (비교 참조)
- [Profile Feature README](/lib/features/profile/README.md) - 프로필 관리
- [Post Feature README](/lib/features/post/README.md) - 게시물 관리

### 외부 라이브러리
- [Riverpod 3.x](https://riverpod.dev/) - 상태 관리 (@riverpod annotation)
- [fpdart](https://pub.dev/packages/fpdart) - Functional Programming (Either pattern)
- [freezed](https://pub.dev/packages/freezed) - 불변 엔티티 코드 생성
- [Hive](https://pub.dev/packages/hive) - 로컬 DB (L2 캐시)
- [wechat_assets_picker](https://pub.dev/packages/wechat_assets_picker) - 갤러리 선택 (Korean delegates)
- [pro_image_editor](https://pub.dev/packages/pro_image_editor) - 이미지 편집기
- [google_generative_ai](https://pub.dev/packages/google_generative_ai) - Gemini AI

### AI 서비스 문서
- [Gemini AI](https://ai.google.dev/docs) - 타이틀/태그 생성, 컨텍스트 검열
- [Perspective API](https://perspectiveapi.com/) - 텍스트 유해성 검사
- [Cloud Vision API](https://cloud.google.com/vision) - 이미지 안전성 검사
- [Firebase Functions](https://firebase.google.com/docs/functions) - calculateTargetAudience

### 아키텍처 참조
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html) - Robert C. Martin
- [Firebase-Centric Architecture](https://firebase.google.com/docs/firestore/best-practices) - Google Firebase
- [DDD Patterns](https://martinfowler.com/bliki/DomainDrivenDesign.html) - Martin Fowler
- [Port-Adapter Pattern](https://alistair.cockburn.us/hexagonal-architecture/) - Alistair Cockburn (Hexagonal Architecture)

---

**마지막 업데이트**: 2025-11-06
**버전**: v3.0.0 (Clean Architecture v4.0 + Firebase-Centric v2.0 + AI Integration Complete)
**작성자**: Creation Feature Team
