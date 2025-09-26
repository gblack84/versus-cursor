# Posts Feature 파일 이동 마이그레이션 가이드

> **작성일**: 2025-01-20
> **버전**: 1.0.0
> **목적**: Posts Feature의 Clean Architecture 재구성을 위한 체계적인 파일 이동 계획

## 📋 개요

Posts Feature를 Clean Architecture 원칙에 맞게 재구성하기 위한 파일 이동 마이그레이션 가이드입니다. 비즈니스 로직과 기술적 유틸리티를 명확히 분리하여 더 나은 모듈화와 재사용성을 달성합니다.

### 주요 원칙
- **비즈니스 로직**: Feature 내부에 유지
- **기술적 유틸리티**: Services 레이어로 추출
- **도메인 로직**: 해당 도메인 Feature로 이동

---

## 🚀 Phase 1: 투표(Voting) 관련 파일 이동

### 1.1 VoteTimerService 이동

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/vote/vote_timer_service.dart` |
| **목표 위치** | `/lib/features/voting/domain/services/vote_timer_service.dart` |
| **영향받는 파일 수** | 약 19개 |
| **이유** | 투표 타이머는 Voting 도메인의 핵심 비즈니스 로직 |

**영향받는 Import 경로**:
```dart
// Before
import '/features/posts/data/adapters/vote/vote_timer_service.dart';

// After
import '/features/voting/domain/services/vote_timer_service.dart';
```

**영향받는 파일 목록**:
- `/lib/app/di.dart`
- `/lib/app/di/posts_module.dart`
- `/lib/features/voting/data/adapters/vote_timer_adapter.dart`
- `/lib/features/posts/presentation/widgets/vote/*.dart`

### 1.2 VoteStatusService 이동

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/vote/vote_status_service.dart` |
| **목표 위치** | `/lib/features/voting/domain/services/vote_status_service.dart` |
| **영향받는 파일 수** | 약 8개 |
| **이유** | 투표 상태 관리는 Voting 도메인의 책임 |

### 1.3 VoteStatusServiceAdapter 이동

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/vote/vote_status_service_adapter.dart` |
| **목표 위치** | **삭제** (더 이상 필요 없음) |
| **이유** | Services 이동 후 Adapter 패턴 불필요 |

### 1.4 Vote 관련 위젯 (검토 필요)

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/presentation/widgets/vote/` |
| **검토 사항** | Voting Feature로 이동 vs 현재 위치 유지 |
| **파일 목록** | `vote_card_message.dart`, `base_vote_message.dart`, `vote_card_header.dart` |

---

## 📦 Phase 2: 기술 유틸리티 Services 추출

### 2.1 MediaUploadService 추출

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/media/media_upload_service.dart` |
| **목표 위치** | `/lib/services/media/media_upload_service.dart` |
| **영향받는 파일 수** | 약 15개 |
| **이유** | 파일 업로드는 여러 Feature에서 재사용 가능한 기술적 유틸리티 |

**리팩토링 필요 사항**:
- Posts 특화 로직 분리
- 범용 인터페이스 설계
- Chat, Profile Feature 재사용 가능하도록 개선

### 2.2 StorageService 추출

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/storage/storage_service.dart` |
| **목표 위치** | `/lib/services/storage/firebase_storage_service.dart` |
| **영향받는 파일 수** | 약 10개 |
| **이유** | Firebase Storage 래핑은 공통 기술 인프라 |

### 2.3 ErrorHandler 이동

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/error/error_handler.dart` |
| **목표 위치** | `/lib/core/utils/error_handler.dart` |
| **영향받는 파일 수** | 약 20개 |
| **이유** | 에러 처리는 앱 전체 공통 유틸리티 |

### 2.4 ImageCacheHelper 통합

| 항목 | 내용 |
|------|------|
| **현재 위치** | `/lib/features/posts/data/adapters/cache/image_cache_helper.dart` |
| **목표** | `/lib/services/image/unified_image_cache_service.dart`에 통합 |
| **작업** | 기능 통합 후 삭제 |
| **이유** | 중복 제거 및 단일 이미지 캐싱 서비스 유지 |

### 2.5 미디어 관련 서비스들

#### 이동 대상 (기술적 유틸리티)

| 현재 파일 | 목표 위치 | 이유 |
|----------|----------|------|
| `asset_picker_service.dart` | `/lib/services/media/` | 범용 이미지 선택 서비스 |
| `image_download_service.dart` | `/lib/services/media/` | Firebase Storage 다운로드 유틸리티 |
| `selection_result_processor.dart` | `/lib/services/media/` | AssetEntity 처리 유틸리티 |
| `media_selection_service.dart` | `/lib/services/media/` | 미디어 선택 관리 서비스 |
| `image_editor_callback_handler.dart` | `/lib/services/media/` | ProImageEditor 콜백 처리 |

#### Posts Feature에 유지 (비즈니스 로직)

| 현재 파일 | 유지 이유 | 상태 |
|----------|----------|------|
| `image_upload_orchestrator_v2.dart` | Posts A/B 박스 워크플로우 전용 | 사용 중 (File 기반) |
| `image_upload_orchestrator.dart` | 레거시 참조용 (MediaUploadService 호출) | 미사용 (Uint8List 기반) |
| `image_reorder_service.dart` | Posts 특화 이미지 순서 관리 | 사용 중 |

**Note**: `image_upload_orchestrator_v2.dart`는 Clean Architecture 위반 사항이 있으나 (UI, Domain, Data 혼재) Posts의 핵심 워크플로우이므로 현재 위치 유지. 향후 리팩토링 필요.

#### 추가 이동 대상

| 현재 파일 | 목표 위치 | 이유 |
|----------|----------|------|
| `validation_service.dart` | `/lib/services/validation/` | 범용 입력 검증 서비스 |
| `posts_model_adapter.dart` | `/lib/features/posts/data/mappers/` | 데이터 매핑 로직 |

---

## 🔄 Phase 3: AI Moderation 서비스 통합

### 3.1 Moderation 서비스 통합

| 항목 | 내용 |
|------|------|
| **현재 중복** | Posts와 Services 모두에 moderation 존재 |
| **목표** | `/lib/services/moderation/`으로 통합 |
| **삭제 대상** | `/lib/features/posts/data/adapters/moderation/` |

**통합 대상 파일**:
- `ai_moderation_service.dart` → Services로 이동
- `text_moderation/gemini_service.dart` → Services로 이동
- `models/moderation_result.dart` → Services로 이동
- `constants/moderation_config.dart` → Services로 이동

---

## 🗂️ Phase 4: Posts Feature 내부 구조 정리

### 4.1 목표 디렉토리 구조

```
/lib/features/posts/
├── domain/
│   ├── models/
│   │   ├── post.dart
│   │   ├── post_content.dart
│   │   ├── media_content.dart
│   │   ├── target_audience_model.dart
│   │   └── ...
│   ├── repositories/
│   │   └── i_post_repository.dart
│   └── usecases/
│       ├── create_post_usecase.dart
│       ├── validate_post_usecase.dart
│       └── ...
├── data/
│   ├── repositories/
│   │   └── post_repository_impl.dart
│   ├── datasources/
│   │   ├── post_remote_datasource.dart
│   │   └── post_local_datasource.dart
│   ├── adapters/
│   │   └── media/  # Posts 특화 미디어 워크플로우 유지
│   │       ├── image_upload_orchestrator_v2.dart
│   │       ├── image_upload_orchestrator.dart (레거시)
│   │       └── image_reorder_service.dart
│   └── mappers/
│       ├── post_mapper.dart
│       └── posts_model_adapter.dart (Phase 2.5에서 이동)
└── presentation/
    ├── screens/
    │   ├── create_post/
    │   ├── feed/
    │   └── ...
    ├── widgets/
    │   └── (Posts 전용 위젯)
    └── providers/
        ├── create_post_provider.dart
        └── media_provider.dart
```

### 4.2 삭제 대상 디렉토리

- `/lib/features/posts/data/adapters/vote/` (Phase 1: Voting으로 이동 후)
- `/lib/features/posts/data/adapters/moderation/` (Phase 3: Services로 이동 후)
- `/lib/features/posts/data/adapters/error/` (Phase 2: Core로 이동 후)
- `/lib/features/posts/data/adapters/storage/` (Phase 2: Services로 이동 후)
- `/lib/features/posts/data/adapters/cache/` (Phase 2: 통합 후)
- `/lib/features/posts/data/adapters/validation/` (Phase 2.5: Services로 이동 후)

---

## 📝 Phase 5: Import 경로 수정

### 5.1 일괄 수정이 필요한 Import 패턴

| 변경 전 | 변경 후 |
|---------|---------|
| `/features/posts/data/adapters/vote/vote_timer_service` | `/features/voting/domain/services/vote_timer_service` |
| `/features/posts/data/adapters/vote/vote_status_service` | `/features/voting/domain/services/vote_status_service` |
| `/features/posts/data/adapters/media/media_upload_service` | `/services/media/media_upload_service` |
| `/features/posts/data/adapters/media/asset_picker_service` | `/services/media/asset_picker_service` |
| `/features/posts/data/adapters/media/image_download_service` | `/services/media/image_download_service` |
| `/features/posts/data/adapters/media/selection_result_processor` | `/services/media/selection_result_processor` |
| `/features/posts/data/adapters/media/media_selection_service` | `/services/media/media_selection_service` |
| `/features/posts/data/adapters/media/image_editor_callback_handler` | `/services/media/image_editor_callback_handler` |
| `/features/posts/data/adapters/storage/storage_service` | `/services/storage/firebase_storage_service` |
| `/features/posts/data/adapters/error/error_handler` | `/core/utils/error_handler` |
| `/features/posts/data/adapters/moderation/` | `/services/moderation/` |
| `/features/posts/data/adapters/validation/validation_service` | `/services/validation/validation_service` |

### 5.2 Import 수정 스크립트 예시

```bash
# VoteTimerService import 경로 일괄 수정
find lib -name "*.dart" -type f -exec sed -i '' \
  's|/features/posts/data/adapters/vote/vote_timer_service|/features/voting/domain/services/vote_timer_service|g' {} \;

# MediaUploadService import 경로 일괄 수정
find lib -name "*.dart" -type f -exec sed -i '' \
  's|/features/posts/data/adapters/media/media_upload_service|/services/media/media_upload_service|g' {} \;
```

---

## ⚙️ Phase 6: DI (Dependency Injection) 설정 업데이트

### 6.1 수정이 필요한 DI 파일

- `/lib/app/di.dart`
- `/lib/app/di/posts_module.dart`
- `/lib/app/di/voting_module.dart`
- `/lib/app/di/services_module.dart` (생성 필요)

### 6.2 DI 등록 변경 예시

```dart
// Before (posts_module.dart)
sl.registerLazySingleton<VoteTimerService>(
  () => VoteTimerService(),
);

// After (voting_module.dart)
sl.registerLazySingleton<VoteTimerService>(
  () => VoteTimerService(),
);

// Services module (새로 생성)
sl.registerLazySingleton<MediaUploadService>(
  () => MediaUploadService(),
);
```

---

## ✅ 마이그레이션 체크리스트

### Pre-Migration
- [ ] 현재 코드 백업 (git branch 생성)
- [ ] 모든 테스트 통과 확인
- [ ] 빌드 성공 확인

### Phase 1: Voting 이동
- [ ] VoteTimerService 파일 이동
- [ ] VoteStatusService 파일 이동
- [ ] Import 경로 수정
- [ ] DI 설정 업데이트
- [ ] 컴파일 확인

### Phase 2: Services 추출
- [ ] MediaUploadService 이동
- [ ] StorageService 이동
- [ ] ErrorHandler 이동
- [ ] ImageCacheHelper 통합
- [ ] Import 경로 수정
- [ ] DI 설정 업데이트

### Phase 2.5: 미디어 서비스 정리
- [ ] AssetPickerService → `/lib/services/media/` 이동
- [ ] ImageDownloadService → `/lib/services/media/` 이동
- [ ] SelectionResultProcessor → `/lib/services/media/` 이동
- [ ] MediaSelectionService → `/lib/services/media/` 이동
- [ ] ImageEditorCallbackHandler → `/lib/services/media/` 이동
- [ ] ValidationService → `/lib/services/validation/` 이동
- [ ] PostsModelAdapter → `/lib/features/posts/data/mappers/` 이동
- [ ] ImageUploadOrchestratorV2 유지 확인 (Posts 워크플로우)
- [ ] ImageUploadOrchestrator 유지 확인 (레거시 참조)
- [ ] ImageReorderService 유지 확인 (Posts 특화)
- [ ] Import 경로 수정

### Phase 3: Moderation 통합
- [ ] 중복 파일 확인
- [ ] Services로 통합
- [ ] Posts의 moderation 삭제
- [ ] Import 경로 수정

### Phase 4: 구조 정리
- [ ] 빈 디렉토리 삭제
- [ ] README 업데이트
- [ ] 문서 업데이트

### Post-Migration
- [ ] 전체 빌드 테스트
- [ ] 기능 테스트 (투표, 업로드, 검열)
- [ ] 성능 테스트
- [ ] 최종 문서화

---

## 🚨 주의 사항

### 순환 의존성 방지
- Voting ↔ Posts 간 직접 의존 금지
- 필요시 인터페이스를 통한 의존성 역전 적용

### Breaking Changes
- Chat Feature가 vote 위젯 사용 중
- 점진적 마이그레이션 필요
- 임시로 Adapter 패턴 유지 가능

### 롤백 계획
- 각 Phase별 git commit
- 문제 발생 시 Phase 단위 롤백
- 핫픽스 브랜치 준비

---

## 📊 예상 효과

| 지표 | 현재 | 목표 | 개선율 |
|------|------|------|--------|
| 코드 중복 | 높음 | 낮음 | -60% |
| 모듈 응집도 | 중간 | 높음 | +40% |
| 재사용성 | 낮음 | 높음 | +50% |
| 테스트 용이성 | 중간 | 높음 | +30% |
| 빌드 시간 | 기준 | 개선 | -20% |

---

## 📅 타임라인

| Phase | 예상 시간 | 우선순위 | 위험도 |
|-------|----------|---------|--------|
| Phase 1 (Voting) | 2-3시간 | 높음 | 중간 |
| Phase 2 (Services) | 3-4시간 | 높음 | 낮음 |
| Phase 3 (Moderation) | 2시간 | 중간 | 낮음 |
| Phase 4 (정리) | 2시간 | 낮음 | 낮음 |
| Phase 5 (Import) | 1-2시간 | 필수 | 높음 |
| Phase 6 (DI) | 1시간 | 필수 | 중간 |

**총 예상 시간**: 11-14시간

---

*이 문서는 Posts Feature 리팩토링의 안전한 실행을 위한 가이드입니다. 각 Phase는 독립적으로 실행 가능하며, 문제 발생 시 롤백이 가능합니다.*