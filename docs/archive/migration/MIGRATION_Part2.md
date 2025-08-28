# 📋 Feature-First Architecture Migration Part 2: Directory Restructuring
> Phase 2 마이그레이션 - 디렉토리 재구성 (파일 이동)
> 작성일: 2025-08-27
> 참조: MIGRATION_ORDER.md, MIGRATION_SAFETY.md

## 🎯 Migration Overview

### 현재 상태
- ✅ Phase 1 완료: Feature 모듈 마이그레이션 완료
- ✅ 모든 Feature 디렉토리 이동 완료
- ✅ Import 경로 업데이트 완료

### Phase 2 목표
- 🎯 **파일 이동만 수행** (코드 수정 없음)
- 🎯 Core 디렉토리 생성 및 Common 이동
- 🎯 Services 레이어 재구성
- 🎯 Backend 구조 정리
- 🎯 App 디렉토리 구조화

## 🚫 Phase 2 제한사항 (MIGRATION_SAFETY.md 준수)

### 파일 이동만
- ✅ 허용: 파일 위치 변경
- ✅ 허용: 디렉토리 구조 생성
- ✅ 허용: Import 경로 수정
- ❌ 금지: 파일명 변경
- ❌ 금지: 클래스명 변경
- ❌ 금지: 코드 리팩토링
- ❌ 금지: 함수명/변수명 변경

## 📊 Migration Matrix

| Directory | 현재 파일 수 | 이동될 파일 수 | 우선순위 | 예상 시간 |
|-----------|-------------|---------------|----------|-----------|
| `/features/common` → `/core` | 50개 | 42개 | 1 (최고) | 4시간 |
| `/features/common` → `/services` | 50개 | 8개 | 2 | 1시간 |
| `/backend` (재구성) | 22개 | 22개 + 3개 | 3 | 2시간 |
| `/app` (구조화) | 16개 | 16개 | 4 | 1시간 |
| **총계** | **138개** | **91개 이동** | - | **8시간** |

## 🏗️ Target Directory Structure

### 1️⃣ /lib/app (현재 유지 + 구조화)

```
app/
├── MIGRATION_APP.md
├── app.dart
├── di/
│   └── README.md
├── models/ (2 파일) 
│   ├── lat_lng.dart
│   └── place.dart
├── router/ (4 파일)
│   ├── README.md
│   └── navigation/
│       ├── README.md
│       ├── nav.dart
│       └── serialization_util.dart
├── state/ (2 파일)
│   ├── app_state.dart
│   └── providers/
│       └── navigation_provider.dart
└── widgets/ (4 파일)
    ├── index.dart
    ├── debug/
    │   └── debug_log_page.dart
    └── navigation/
        ├── README.md
        └── main_navigation_shell.dart
```

### 2️⃣ /lib/core (새로 생성 - features/common에서 이동)

```
core/
├── constants/ (1 파일) ← features/common/domain/models에서
│   └── layout_constants.dart
├── design_system/ (14 파일) ← features/common/presentation/design_system에서
│   ├── README.md
│   ├── design_system.dart
│   ├── components/
│   │   ├── versus_button.dart
│   │   ├── versus_components.dart
│   │   ├── versus_dialog.dart
│   │   ├── versus_icon.dart
│   │   └── versus_text_field.dart
│   ├── tokens/
│   │   ├── versus_colors.dart
│   │   ├── versus_icon_data.dart
│   │   ├── versus_icons.dart
│   │   ├── versus_radius.dart
│   │   ├── versus_spacing.dart
│   │   ├── versus_text_styles.dart
│   │   └── versus_tokens.dart
│   └── utils/
│       └── icon_style_manager.dart
├── localization/ (2 파일) ← features/common/localization에서
│   ├── app_language_selector.dart
│   └── app_localizations.dart
├── theme/ (1 파일) ← features/common/presentation/theme에서
│   └── app_theme.dart
├── models/ (5 파일) ← features/common/domain/models에서
│   ├── form_field_controller.dart
│   ├── upload_data.dart
│   ├── uploaded_file.dart
│   ├── app_model.dart
│   └── README.md
├── utils/ (3 파일) ← features/common/utils에서
│   ├── app_timer.dart
│   ├── app_utils.dart
│   └── custom_functions.dart
├── widgets/ (16 파일) ← features/common/presentation/widgets에서
│   ├── README.md
│   ├── alertempty_widget.dart
│   ├── alertempty_model.dart ← features/common/domain/models
│   ├── app_choice_chips.dart
│   ├── app_icon_button.dart
│   ├── app_media_display.dart
│   ├── app_toggle_icon.dart
│   ├── app_video_player.dart
│   ├── app_web_view.dart
│   ├── app_widgets.dart
│   ├── editviedo_widget.dart
│   ├── editviedo_model.dart ← features/common/domain/models
│   ├── highlighted_text_field.dart
│   ├── unified_video_player.dart
│   ├── videoplay_widget.dart
│   ├── videoplay_model.dart ← features/common/domain/models
│   ├── youtube_player_widget.dart
│   └── pickle_mark/
│       ├── pickle_mark_model.dart
│       └── pickle_mark_widget.dart
├── animations/ (1 파일) ← features/common/presentation/animations에서
│   └── app_animations.dart
└── actions/ (2 파일) ← features/common/presentation/actions에서
    ├── README.md
    └── global_actions.dart
```

### 3️⃣ /lib/services (현재 + common에서 이동)

```
services/
├── README.md
├── cache/ (5 파일) ← 현재 유지
│   ├── README.md
│   ├── cache_statistics.dart
│   ├── preload_strategy.dart
│   ├── simple_memory_cache.dart
│   └── unified_cache_service.dart
├── moderation/ (3 파일) ← 현재 services에서 그룹화
│   ├── cloud_image_moderation_service.dart
│   ├── image_moderation_service.dart
│   └── perspective_api_service.dart
├── image/ (1 파일)
│   └── unified_image_cache_service.dart
├── logger/ (2 파일) ← features/common/data/services에서
│   ├── app_logger.dart
│   └── file_logger.dart
├── content/ (1 파일) ← features/common/data/services에서
│   └── content_filter.dart
├── ui/ (2 파일) ← features/common/data/services에서
│   ├── responsive_breakpoints.dart
│   └── unified_box_calculator.dart
└── validators/ ← features/common/domain/validators에서
    └── README.md
```

### 4️⃣ /lib/backend (재구성)

```
backend/
├── README.md
├── backend.dart
│
├── firebase/                    # Firebase 전용
│   ├── config/
│   │   └── firebase_config.dart
│   ├── firestore/              # Firestore 관련
│   │   ├── collections/        # 컬렉션별 접근
│   │   │   ├── posts_collection.dart
│   │   │   ├── users_collection.dart
│   │   │   └── chats_collection.dart
│   │   └── utils/
│   │       ├── firestore_util.dart
│   │       └── schema_util.dart
│   └── storage/                # Firebase Storage
│       ├── storage_service.dart (storage.dart에서 이름 변경)
│       └── storage_paths.dart
│
├── models/                      # 데이터 모델 (스키마)
│   ├── chat/
│   │   └── messages_model.dart (features/chat에서 이동)
│   ├── post/
│   │   ├── posts_model.dart (features/posts에서 이동)
│   │   ├── comments_model.dart (content_comments_model.dart)
│   │   ├── likes_model.dart (contents_likes_model.dart)
│   │   └── shares_model.dart (contents_shares_model.dart)
│   ├── user/
│   │   ├── users_model.dart (features/auth에서 이동)
│   │   └── settings_model.dart
│   ├── media/
│   │   ├── images_model.dart
│   │   ├── video_model.dart
│   │   └── image_moderation_model.dart
│   ├── feed/
│   │   ├── feed_details_model.dart
│   │   └── poll_details_model.dart
│   ├── transaction/
│   │   ├── point_model.dart
│   │   └── transactions_model.dart
│   └── shared/
│       ├── client_model.dart
│       └── contents_interests_model.dart
│
├── api/                         # 외부 API
│   ├── algolia/
│   │   ├── algolia_service.dart
│   │   └── algolia_config.dart
│   └── rest/
│       ├── api_manager.dart
│       ├── api_calls.dart
│       └── get_streamed_response.dart
│
└── repositories/               # 새로 추가 - 데이터 접근 추상화
    ├── post_repository.dart
    ├── user_repository.dart
    ├── chat_repository.dart
    └── media_repository.dart
```

## 📋 Detailed Migration Steps

### Step 1: Core 디렉토리 생성 및 Common 이동 (4시간)

#### 1.1 디렉토리 구조 생성 (30분)
```bash
# Core 디렉토리 구조 생성
mkdir -p lib/core/{constants,design_system,localization,theme,models,utils,widgets,animations,actions}
mkdir -p lib/core/design_system/{components,tokens,utils}
mkdir -p lib/core/widgets/pickle_mark
```

#### 1.2 파일 이동 - Design System (1시간)
```
FROM: features/common/presentation/design_system/
TO: core/design_system/

이동할 파일:
- design_system.dart
- components/*.dart (5개)
- tokens/*.dart (7개)
- utils/icon_style_manager.dart
```

#### 1.3 파일 이동 - Widgets & Models (1.5시간)
```
FROM: features/common/presentation/widgets/
TO: core/widgets/

이동할 파일:
- 14개 위젯 파일
- pickle_mark/*.dart (2개)

FROM: features/common/domain/models/
TO: core/widgets/ (모델과 위젯 같은 위치)
- alertempty_model.dart
- editviedo_model.dart
- videoplay_model.dart
```

#### 1.4 파일 이동 - 기타 (1시간)
```
FROM: features/common/
TO: core/

- localization/*.dart → core/localization/
- presentation/theme/app_theme.dart → core/theme/
- domain/models/*.dart → core/models/ (5개)
- utils/*.dart → core/utils/ (3개)
- presentation/animations/*.dart → core/animations/
- presentation/actions/*.dart → core/actions/
- domain/models/layout_constants.dart → core/constants/
```

### Step 2: Services 디렉토리 재구성 (1시간)

#### 2.1 디렉토리 구조 생성 (15분)
```bash
mkdir -p lib/services/{moderation,image,logger,content,ui,validators}
```

#### 2.2 파일 이동 (45분)
```
FROM: features/common/data/services/
TO: services/

- app_logger.dart → services/logger/
- file_logger.dart → services/logger/
- content_filter.dart → services/content/
- responsive_breakpoints.dart → services/ui/
- unified_box_calculator.dart → services/ui/

FROM: services/
TO: services/moderation/
- cloud_image_moderation_service.dart
- image_moderation_service.dart
- perspective_api_service.dart
```

### Step 3: Backend 디렉토리 재구성 (2시간)

#### 3.1 디렉토리 구조 생성 (15분)
```bash
mkdir -p lib/backend/firebase/{config,firestore,storage}
mkdir -p lib/backend/firebase/firestore/{collections,utils}
mkdir -p lib/backend/models/{chat,post,user,media,feed,transaction,shared}
mkdir -p lib/backend/api/{algolia,rest}
mkdir -p lib/backend/repositories
```

#### 3.2 Firebase 파일 재배치 (30분)
```
FROM: backend/firebase/
TO: backend/firebase/config/
- firebase_config.dart

FROM: backend/firebase_storage/
TO: backend/firebase/storage/
- storage.dart → storage_service.dart

FROM: backend/schema/util/
TO: backend/firebase/firestore/utils/
- firestore_util.dart
- schema_util.dart
```

#### 3.3 Models 재구성 (1시간)
```
FROM: backend/schema/
TO: backend/models/

- content_comments_model.dart → post/comments_model.dart
- contents_likes_model.dart → post/likes_model.dart
- contents_shares_model.dart → post/shares_model.dart
- settings_model.dart → user/settings_model.dart
- images_model.dart → media/images_model.dart
- video_model.dart → media/video_model.dart
- image_moderation_model.dart → media/image_moderation_model.dart
- feed_details_model.dart → feed/feed_details_model.dart
- poll_details_model.dart → feed/poll_details_model.dart
- point_model.dart → transaction/point_model.dart
- transactions_model.dart → transaction/transactions_model.dart
- client_model.dart → shared/client_model.dart
- contents_interests_model.dart → shared/contents_interests_model.dart

FROM: features/
TO: backend/models/
- features/chat/data/models/messages_model.dart → chat/messages_model.dart
- features/posts/data/models/posts_model.dart → post/posts_model.dart
- features/auth/data/models/users_model.dart → user/users_model.dart
```

#### 3.4 API 재배치 (15분)
```
FROM: backend/api_requests/
TO: backend/api/rest/
- api_manager.dart
- api_calls.dart
- get_streamed_response.dart
```

#### 3.5 Repositories 생성 (빈 파일) (15분)
```
Create: backend/repositories/
- post_repository.dart (빈 파일)
- user_repository.dart (빈 파일)
- chat_repository.dart (빈 파일)
- media_repository.dart (빈 파일)
```

### Step 4: App 디렉토리 구조화 (1시간)

#### 4.1 디렉토리 생성 (15분)
```bash
mkdir -p lib/app/{di,models,router/navigation,state/providers,widgets/debug,widgets/navigation}
```

#### 4.2 파일 재배치 (45분)
```
현재 파일들을 적절한 위치로 이동:
- app_state.dart → state/app_state.dart
- nav.dart → router/navigation/nav.dart
- serialization_util.dart → router/navigation/serialization_util.dart
- navigation_provider.dart → state/providers/navigation_provider.dart
- lat_lng.dart → models/lat_lng.dart
- place.dart → models/place.dart
- index.dart → widgets/index.dart
- debug_log_page.dart → widgets/debug/debug_log_page.dart
- main_navigation_shell.dart → widgets/navigation/main_navigation_shell.dart
```

## 🔄 Import Path Updates

### Import 경로 변경 예시
```dart
// Before
import 'package:versus_space/features/common/presentation/design_system/tokens/versus_colors.dart';

// After
import 'package:versus_space/core/design_system/tokens/versus_colors.dart';
```

### 주요 Import 변경 패턴
- `features/common/presentation/` → `core/`
- `features/common/domain/models/` → `core/models/`
- `features/common/data/services/` → `services/`
- `backend/schema/` → `backend/models/`
- `backend/api_requests/` → `backend/api/rest/`

## 🛡️ Safety Measures

### 백업 전략
```bash
# 마이그레이션 시작 전 백업
git checkout -b backup/before-phase2
git add .
git commit -m "backup: Before Phase 2 migration"

# Phase별 백업
git checkout -b migration/phase2-core
git checkout -b migration/phase2-services
git checkout -b migration/phase2-backend
git checkout -b migration/phase2-app
```

### 검증 체크리스트
- [ ] 모든 파일 이동 완료
- [ ] Import 경로 업데이트
- [ ] flutter analyze 에러 없음
- [ ] flutter test 통과
- [ ] 앱 정상 실행

## 📊 Success Criteria

### 완료 기준
1. **파일 구조**: 모든 파일이 목표 위치로 이동
2. **Import 경로**: 모든 import 경로 업데이트 완료
3. **빌드 성공**: flutter build 정상 실행
4. **테스트 통과**: 기존 테스트 모두 통과
5. **앱 실행**: 앱이 정상적으로 실행됨

### 검증 명령어
```bash
# Import 경로 검증
grep -r "features/common" lib/ | grep -v "MIGRATION"

# 빌드 검증
flutter clean
flutter pub get
flutter analyze
flutter build apk --debug

# 테스트 검증
flutter test
```

## ⚠️ 주의사항

### 하지 말아야 할 것
- ❌ 파일명 변경
- ❌ 클래스명 변경
- ❌ 함수 리팩토링
- ❌ 코드 구조 변경
- ❌ 기능 수정

### 해야 할 것
- ✅ 파일 이동만
- ✅ Import 경로만 수정
- ✅ 디렉토리 구조 생성
- ✅ 백업 브랜치 생성
- ✅ 단계별 검증

## 🚀 Next Steps

### Phase 2 완료 후
1. **Phase 3**: 코드 리팩토링 (레이어 분리)
2. **Phase 4**: 인터페이스 추출
3. **Phase 5**: DI Container 구축
4. **Phase 6**: 테스트 추가

### 예상 일정
- Phase 2 (파일 이동): 1일
- Import 경로 수정: 1일
- 검증 및 테스트: 0.5일
- **총 예상**: 2.5일

## 🔗 Related Documents
- [MIGRATION_ORDER.md](../features/MIGRATION_ORDER.md) - Phase 1 마이그레이션 순서
- [MIGRATION_SAFETY.md](../features/MIGRATION_SAFETY.md) - 안전 가이드라인
- [MIGRATION_COMMON.md](../features/common/MIGRATION_COMMON.md) - Common 마이그레이션
- [MIGRATION_APP.md](../app/MIGRATION_APP.md) - App 마이그레이션

---
*이 문서는 Phase 2 마이그레이션 진행 상황에 따라 업데이트됩니다.*
*Last Updated: 2025-08-27*