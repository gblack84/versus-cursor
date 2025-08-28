# 📦 /lib/features/posts 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Posts Feature 완전 통합

## 🎯 목적

게시물(Versus Posts) 관련 모든 기능을 `/lib/features/posts` 폴더로 통합하여 독립적이고 재사용 가능한 게시물 모듈을 구성합니다.

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 게시물 생성 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 유틸리티 함수들 | Import 경로 변경 |
| **FF 접두사 제거** | 모든 위젯 | `FFButtonWidget` → `AppButton` |
| **AppTheme 통합** | 테마 설정 | `AppTheme.of(context)` 사용 |

### Import 변경 예시
```dart
// Before (FlutterFlow)
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';

// After (Native Flutter)
import '/core/app_theme.dart';
import '/core/widgets/app_button.dart';
import '/core/utils/app_utils.dart';
```

## 📋 현재 상태 분석 (전체 하위 디렉토리 포함)

### 게시물 관련 전체 파일 목록
| 디렉토리 | 파일명 | 설명 | 대상 위치 |
|----------|--------|------|----------|
| **`/lib/posts/in_put_post_image/`** (52개) | | | |
| └─ | in_put_post_image_widget.dart | 게시물 작성 메인 위젯 | presentation/screens/create_post/ |
| └─ | in_put_post_image_model.dart | 게시물 작성 모델 | presentation/screens/create_post/ |
| └─ components/ | base_media_selection_box.dart | 미디어 선택 박스 베이스 | presentation/widgets/media/ |
| └─ | character_count_display.dart | 글자 수 표시 | presentation/widgets/input/ |
| └─ | layout_debug_info.dart | 레이아웃 디버그 정보 | presentation/widgets/debug/ |
| └─ | media_selection_box_multi.dart | 멀티 미디어 선택 박스 | presentation/widgets/media/ |
| └─ | media_selection_box_single.dart | 싱글 미디어 선택 박스 | presentation/widgets/media/ |
| └─ | next_button.dart | 다음 버튼 컴포넌트 | presentation/widgets/buttons/ |
| └─ | simple_character_count.dart | 심플 글자 수 카운터 | presentation/widgets/input/ |
| └─ | simple_validated_field.dart | 유효성 검사 필드 | presentation/widgets/input/ |
| └─ | warning_message.dart | 경고 메시지 | presentation/widgets/feedback/ |
| └─ constants/ | animation_constants.dart | 애니메이션 상수 | domain/constants/ |
| └─ | colors.dart | 색상 상수 | domain/constants/ |
| └─ | config.dart | 설정 상수 | domain/constants/ |
| └─ | dimensions.dart | 크기 상수 | domain/constants/ |
| └─ | field_styles.dart | 필드 스타일 | domain/constants/ |
| └─ | image_constants.dart | 이미지 상수 | domain/constants/ |
| └─ | strings.dart | 문자열 상수 | domain/constants/ |
| └─ | target_audience_constants.dart | 타겟 오디언스 상수 | domain/constants/ |
| └─ | text_limits.dart | 텍스트 제한 상수 | domain/constants/ |
| └─ delegates/ | camera_floating_button_delegate.dart | 카메라 버튼 델리게이트 | presentation/delegates/ |
| └─ | korean_asset_picker_delegate.dart | 한국어 에셋 피커 | presentation/delegates/ |
| └─ | korean_camera_picker_delegate.dart | 한국어 카메라 피커 | presentation/delegates/ |
| └─ helpers/ | aspect_ratio_analyzer.dart | 비율 분석기 | domain/usecases/media/ |
| └─ | image_cache_helper.dart | 이미지 캐시 헬퍼 | data/services/cache/ |
| └─ | input_field_builder.dart | 입력 필드 빌더 | presentation/helpers/ |
| └─ | media_box_callbacks.dart | 미디어 박스 콜백 | presentation/helpers/ |
| └─ | ratio_calculator.dart | 비율 계산기 | domain/usecases/media/ |
| └─ models/ | target_audience_model.dart | 타겟 오디언스 모델 | domain/models/ |
| └─ services/ | asset_picker_service.dart | 에셋 피커 서비스 | data/services/media/ |
| └─ | image_download_service.dart | 이미지 다운로드 | data/services/media/ |
| └─ | image_editor_callback_handler.dart | 이미지 에디터 콜백 | data/services/media/ |
| └─ | image_reorder_service.dart | 이미지 재정렬 | data/services/media/ |
| └─ | image_upload_orchestrator.dart | 이미지 업로드 조정 | data/services/media/ |
| └─ | image_upload_orchestrator_v2.dart | 이미지 업로드 v2 | data/services/media/ |
| └─ | media_selection_service.dart | 미디어 선택 서비스 | data/services/media/ |
| └─ | media_upload_service.dart | 미디어 업로드 서비스 | data/services/media/ |
| └─ | selection_result_processor.dart | 선택 결과 처리기 | data/services/media/ |
| └─ | validation_service.dart | 유효성 검사 서비스 | domain/usecases/validation/ |
| └─ utils/ | debug_helper.dart | 디버그 헬퍼 | presentation/utils/ |
| └─ | error_handler.dart | 에러 핸들러 | data/services/error/ |
| └─ | no_animation_page_route.dart | 애니메이션 없는 라우트 | presentation/utils/ |
| └─ widgets/dialogs/ | moderation_dialog.dart | 검열 다이얼로그 | presentation/widgets/dialogs/ |
| └─ | moderation_error_dialog.dart | 검열 에러 다이얼로그 | presentation/widgets/dialogs/ |
| └─ | target_audience_dialog.dart | 타겟 오디언스 다이얼로그 | presentation/widgets/dialogs/ |
| └─ widgets/dialogs/target_audience_steps/ | collection_type_selector.dart | 수집 타입 선택기 | presentation/widgets/dialogs/ |
| └─ | detailed_target_selector.dart | 상세 타겟 선택기 | presentation/widgets/dialogs/ |
| └─ | target_count_selector.dart | 타겟 수 선택기 | presentation/widgets/dialogs/ |
| └─ widgets/ | media_editor_widget.dart | 미디어 에디터 위젯 | presentation/widgets/editors/ |
| └─ | media_selection_flow_widget.dart | 미디어 선택 플로우 | presentation/widgets/media/ |
| └─ | thumbnail_navigation_helper.dart | 썸네일 네비게이션 헬퍼 | presentation/widgets/navigation/ |
| **`/lib/pages/`** (게시물 관련 7개) | | | |
| └─ home/ | home_page_widget.dart | 홈 피드 화면 | presentation/screens/feed/ |
| └─ | home_page_widget_model.dart | 홈 피드 모델 | presentation/screens/feed/ |
| └─ pro_image_editor/ | pro_image_editor_page.dart | 이미지 에디터 페이지 | presentation/screens/editor/ |
| └─ | pro_image_editor_model.dart | 이미지 에디터 모델 | presentation/screens/editor/ |
| └─ thumbnail_selection/ | thumbnail_selection_page.dart | 썸네일 선택 페이지 | presentation/screens/thumbnail/ |
| └─ | thumbnail_selection_model.dart | 썸네일 선택 모델 | presentation/screens/thumbnail/ |
| └─ image_viewer/ | image_viewer_page.dart | 이미지 뷰어 페이지 | presentation/screens/viewer/ |
| **`/lib/backend/schema/`** (게시물 관련 6개) | | | |
| └─ | posts_model.dart | 게시물 모델 | domain/models/ |
| └─ | ranked_posts_model.dart | 랭킹 게시물 모델 | domain/models/ |
| └─ | comments_model.dart | 댓글 모델 | domain/models/ |
| └─ | likes_model.dart | 좋아요 모델 | domain/models/ |
| └─ | dislikes_model.dart | 싫어요 모델 | domain/models/ |
| └─ | encodings_model.dart | 인코딩 모델 | domain/models/ |
| **`/lib/components/`** (게시물 관련 5개) | | | |
| └─ | videoplay_widget.dart | 비디오 재생 위젯 | presentation/widgets/media/ |
| └─ | editviedo_widget.dart | 비디오 편집 위젯 | presentation/widgets/editors/ |
| └─ | alertempty_widget.dart | 빈 알림 위젯 | presentation/widgets/feedback/ |
| └─ notifications/ | versus_notification_box.dart | Versus 알림 박스 | presentation/widgets/notification/ |
| └─ notifications/models/ | versus_box_size_data.dart | Versus 박스 크기 데이터 | domain/models/ |
| **`/lib/services/`** (게시물 관련 7개) | | | |
| └─ | vote_timer_service.dart | 투표 타이머 서비스 | data/services/vote/ |
| └─ | vote_status_service.dart | 투표 상태 서비스 | data/services/vote/ |
| └─ | vote_state_coordinator.dart | 투표 상태 조정자 | data/services/vote/ |
| └─ | target_audience_service.dart | 타겟 오디언스 서비스 | data/services/audience/ |
| └─ | storage_service.dart | 스토리지 서비스 | data/services/storage/ |
| └─ ai_moderation/ | ai_moderation_service.dart | AI 검열 서비스 | data/services/moderation/ |
| └─ | perspective_api_service.dart | Perspective API 서비스 | data/services/moderation/ |
| **총합** | **77개 파일** | **전체 게시물 관련 파일** | **Feature-First 구조로 재배치** |

## 🏗️ Feature-First 구조 매핑

```
/lib/features/posts/
├── data/
│   ├── repositories/
│   │   ├── post_repository.dart           # 게시물 데이터 접근 추상화
│   │   └── media_repository.dart          # 미디어 데이터 관리
│   │
│   └── services/
│       ├── post_service.dart              # 게시물 CRUD 서비스
│       ├── media_upload_service.dart      # 미디어 업로드
│       ├── image_processing_service.dart  # 이미지 처리
│       ├── video_processing_service.dart  # 비디오 처리
│       ├── youtube_service.dart           # YouTube 통합
│       ├── ai_moderation_service.dart     # AI 콘텐츠 검열
│       ├── perspective_api_service.dart   # Perspective API
│       ├── gemini_service.dart            # Gemini AI
│       └── storage_service.dart           # Firebase Storage
│
├── domain/
│   ├── models/
│   │   ├── post_model.dart               # 게시물 데이터 모델
│   │   ├── comment_model.dart            # 댓글 모델
│   │   ├── media_model.dart              # 미디어 모델
│   │   ├── target_audience_model.dart    # 타겟 오디언스
│   │   ├── moderation_result_model.dart  # 검열 결과
│   │   └── ranked_post_model.dart        # 랭킹 게시물
│   │
│   └── usecases/
│       ├── create_post_usecase.dart      # 게시물 생성
│       ├── edit_post_usecase.dart        # 게시물 수정
│       ├── delete_post_usecase.dart      # 게시물 삭제
│       ├── like_post_usecase.dart        # 좋아요
│       ├── comment_post_usecase.dart     # 댓글 작성
│       └── share_post_usecase.dart       # 공유하기
│
└── presentation/
    ├── screens/
    │   ├── create_post/                  # 게시물 생성 화면
    │   │   ├── in_put_post_image_widget.dart
    │   │   ├── in_put_post_image_model.dart
    │   │   └── steps/                    # 생성 단계별 화면
    │   │       ├── media_selection/      # 미디어 선택
    │   │       ├── content_input/        # 내용 입력
    │   │       └── target_audience/      # 타겟 설정
    │   │
    │   ├── post_detail/                  # 게시물 상세
    │   │   ├── post_detail_widget.dart
    │   │   └── post_detail_model.dart
    │   │
    │   ├── edit_post/                    # 게시물 수정
    │   │   ├── edit_post_widget.dart
    │   │   └── edit_post_model.dart
    │   │
    │   └── feed/                         # 피드 화면
    │       ├── home_feed_widget.dart
    │       └── home_feed_model.dart
    │
    ├── widgets/
    │   ├── post_card.dart                # 게시물 카드
    │   ├── versus_box.dart               # A vs B 박스
    │   ├── media_selector.dart           # 미디어 선택기
    │   ├── image_editor.dart             # 이미지 편집기
    │   ├── video_trimmer.dart            # 비디오 트리머
    │   ├── comment_section.dart          # 댓글 섹션
    │   ├── like_button.dart              # 좋아요 버튼
    │   ├── share_button.dart             # 공유 버튼
    │   └── target_audience_dialog.dart   # 타겟 설정 다이얼로그
    │
    └── providers/
        ├── post_provider.dart             # 게시물 상태 관리
        ├── feed_provider.dart             # 피드 상태 관리
        └── media_provider.dart            # 미디어 상태 관리
```

## 📁 상세 파일 이동 계획

### Phase 1: Services 이동 (data/services/)

```bash
# 미디어 업로드 서비스
git mv lib/posts/in_put_post_image/services/media_upload_service.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/image_upload_orchestrator.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/image_upload_orchestrator_v2.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/asset_picker_service.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/media_selection_service.dart lib/features/posts/data/services/

# 이미지 처리 서비스
git mv lib/posts/in_put_post_image/services/image_editor_callback_handler.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/image_reorder_service.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/image_download_service.dart lib/features/posts/data/services/

# 유효성 검사 서비스
git mv lib/posts/in_put_post_image/services/validation_service.dart lib/features/posts/data/services/
git mv lib/posts/in_put_post_image/services/selection_result_processor.dart lib/features/posts/data/services/

# AI 검열 서비스
git mv lib/services/ai_moderation/ai_moderation_service.dart lib/features/posts/data/services/
git mv lib/services/ai_moderation/text_moderation/gemini_service.dart lib/features/posts/data/services/
git mv lib/services/perspective_api_service.dart lib/features/posts/data/services/
git mv lib/services/image_moderation_service.dart lib/features/posts/data/services/
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 게시물 모델
git mv lib/backend/schema/posts_model.dart lib/features/posts/domain/models/post_model.dart
git mv lib/backend/schema/ranked_posts_model.dart lib/features/posts/domain/models/ranked_post_model.dart
git mv lib/backend/schema/comments_model.dart lib/features/posts/domain/models/comment_model.dart
git mv lib/backend/schema/likes_model.dart lib/features/posts/domain/models/like_model.dart
git mv lib/backend/schema/dislikes_model.dart lib/features/posts/domain/models/dislike_model.dart

# 타겟 오디언스 모델
git mv lib/posts/in_put_post_image/models/target_audience_model.dart lib/features/posts/domain/models/

# AI 검열 모델
git mv lib/services/ai_moderation/models/moderation_result.dart lib/features/posts/domain/models/
git mv lib/services/ai_moderation/models/image_moderation_result.dart lib/features/posts/domain/models/
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 게시물 생성 화면
mkdir -p lib/features/posts/presentation/screens/create_post
git mv lib/posts/in_put_post_image/in_put_post_image_widget.dart lib/features/posts/presentation/screens/create_post/
git mv lib/posts/in_put_post_image/in_put_post_image_model.dart lib/features/posts/presentation/screens/create_post/

# 미디어 선택 단계
mkdir -p lib/features/posts/presentation/screens/create_post/steps/media_selection
git mv lib/posts/in_put_post_image/widgets/media_selection_flow_widget.dart lib/features/posts/presentation/screens/create_post/steps/media_selection/

# 타겟 오디언스 단계
mkdir -p lib/features/posts/presentation/screens/create_post/steps/target_audience
git mv lib/posts/in_put_post_image/widgets/dialogs/target_audience_steps/* lib/features/posts/presentation/screens/create_post/steps/target_audience/

# 홈 피드 화면
mkdir -p lib/features/posts/presentation/screens/feed
git mv lib/pages/home/home_page_widget.dart lib/features/posts/presentation/screens/feed/home_feed_widget.dart
git mv lib/pages/home/home_page_model.dart lib/features/posts/presentation/screens/feed/home_feed_model.dart
```

### Phase 4: Widgets 이동 (presentation/widgets/)

```bash
# UI 컴포넌트
git mv lib/posts/in_put_post_image/components/media_selection_box_single.dart lib/features/posts/presentation/widgets/media_selector.dart
git mv lib/posts/in_put_post_image/components/layout_debug_info.dart lib/features/posts/presentation/widgets/
git mv lib/posts/in_put_post_image/components/warning_message.dart lib/features/posts/presentation/widgets/

# 다이얼로그
git mv lib/posts/in_put_post_image/widgets/dialogs/target_audience_dialog.dart lib/features/posts/presentation/widgets/
git mv lib/posts/in_put_post_image/widgets/dialogs/media_type_selection_dialog.dart lib/features/posts/presentation/widgets/

# 이미지 편집
git mv lib/pages/pro_image_editor lib/features/posts/presentation/widgets/image_editor
git mv lib/pages/thumbnail_selection lib/features/posts/presentation/widgets/thumbnail_selector
```

### Phase 5: Helpers & Utils 이동

```bash
# 헬퍼 클래스
git mv lib/posts/in_put_post_image/helpers/* lib/features/posts/data/services/helpers/

# 유틸리티
git mv lib/posts/in_put_post_image/utils/* lib/features/posts/domain/utils/

# 상수
git mv lib/posts/in_put_post_image/constants/* lib/features/posts/domain/constants/

# 델리게이트
git mv lib/posts/in_put_post_image/delegates/* lib/features/posts/presentation/delegates/
```

### Phase 6: Repository 생성 (data/repositories/)

새로 생성해야 할 Repository 클래스들:
- `PostRepository`: 게시물 CRUD 작업 통합
- `MediaRepository`: 미디어 업로드 및 처리
- `ModerationRepository`: 콘텐츠 검열 시스템
- `VoteRepository`: 투표 시스템 관리

각 Repository는 관련 Service들을 주입받아 통합 로직을 제공합니다.

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 게시물 생성 관련 | 50개+ | 미디어 업로드, 편집 |
| 피드 관련 | 20개+ | 홈 화면, 카드 표시 |
| AI 검열 관련 | 15개+ | 콘텐츠 검증 |
| 스토리지 관련 | 10개+ | Firebase Storage |

### Import 변경 예시

```dart
// Before
import '/posts/in_put_post_image/services/media_upload_service.dart';
import '/services/ai_moderation/ai_moderation_service.dart';
import '/backend/schema/posts_model.dart';

// After
import '/features/posts/data/services/media_upload_service.dart';
import '/features/posts/data/services/ai_moderation_service.dart';
import '/features/posts/domain/models/post_model.dart';
```

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 게시물 생성
- [ ] 텍스트 입력
- [ ] 이미지 업로드 (최대 4개)
- [ ] 비디오 업로드
- [ ] YouTube 링크
- [ ] 이미지 편집
- [ ] 비디오 트리밍
- [ ] AI 콘텐츠 검열
- [ ] 타겟 오디언스 설정

#### 2. 게시물 표시
- [ ] 피드 로딩
- [ ] 카드 레이아웃
- [ ] A vs B 박스 표시
- [ ] 미디어 재생
- [ ] 스마트 레이아웃

#### 3. 상호작용
- [ ] 좋아요/싫어요
- [ ] 댓글 작성
- [ ] 공유하기
- [ ] 신고하기

#### 4. 성능
- [ ] 이미지 캐싱
- [ ] 무한 스크롤
- [ ] 업로드 진행률
- [ ] 오프라인 지원

## ⚠️ 주의사항

### 1. 미디어 처리
- 이미지 리사이징 로직 유지
- 비디오 인코딩 설정 보존
- 썸네일 생성 프로세스

### 2. AI 검열 시스템
- API 키 관리
- 검열 임계값 설정
- 다단계 검증 프로세스

### 3. Firebase Storage
- 업로드 경로 구조 유지
- 보안 규칙 호환성
- 다운로드 URL 관리

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 매우 높음 | 20개+ | 핵심 비즈니스 로직 |
| **Models** | 높음 | 10개+ | 데이터 구조 |
| **Screens** | 매우 높음 | 15개+ | 주요 화면 |
| **Widgets** | 높음 | 30개+ | UI 컴포넌트 |
| **총 영향** | **매우 높음** | **100개+** | 앱 핵심 기능 |

## 🔄 롤백 계획

```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout main

# 또는 백업 브랜치로 복귀
git checkout backup/before-posts-migration
```

## 📅 예상 소요 시간

| Phase | 소요 시간 | 난이도 |
|-------|----------|--------|
| Phase 1: Services | 2시간 | ⭐⭐⭐⭐ |
| Phase 2: Models | 1시간 | ⭐⭐⭐ |
| Phase 3: Screens | 3시간 | ⭐⭐⭐⭐⭐ |
| Phase 4: Widgets | 2시간 | ⭐⭐⭐⭐ |
| Phase 5: Helpers | 1시간 | ⭐⭐ |
| Phase 6: Repository | 2시간 | ⭐⭐⭐⭐ |
| **총 소요 시간** | **11시간** | ⭐⭐⭐⭐⭐ |

## 🚀 다음 단계

1. **의존성 분석**
   - Import 관계 매핑
   - 순환 참조 확인

2. **단계별 마이그레이션**
   - Services 먼저 이동
   - Models 통합
   - UI 컴포넌트 재구성

3. **통합 테스트**
   - 전체 게시물 생성 플로우
   - AI 검열 시스템
   - 미디어 업로드

---

*이 문서는 Feature-First Architecture 마이그레이션의 Posts Feature 통합 가이드입니다.*
*작성일: 2025-08-24*