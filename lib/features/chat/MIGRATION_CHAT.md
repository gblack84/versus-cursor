# 📦 /lib/features/chat 디렉토리 마이그레이션 가이드

> Feature-First Architecture - Chat Feature 완전 통합
> 최종 업데이트: 2025-08-25

## 🎯 목적

채팅 관련 모든 기능을 `/lib/features/chat` 폴더로 통합하여 독립적이고 재사용 가능한 채팅 모듈을 구성합니다.

## ⚠️ 전제조건

Chat 마이그레이션은 다음 Feature들이 완료된 후 진행되어야 합니다:

1. **Core 마이그레이션** (Phase 0) - FlutterFlow 레거시 정리
2. **Common Feature** - 공통 위젯 및 유틸리티
3. **App Feature** - 라우팅 및 상태 관리
4. **Auth Feature** - 인증 시스템 (사용자 정보 필요)
5. **Profile Feature** - 프로필 관리 (채팅 참여자 정보)

의존성: `Core → Common/App → Auth → Profile → Chat`

## 🔄 Core/App 마이그레이션 의존성

### FlutterFlow → Native Flutter 변환
이 기능은 다음 Core/App 마이그레이션 항목들과 의존성이 있습니다:

| 변경 사항 | 영향받는 컴포넌트 | 필요 작업 |
|----------|----------------|----------|
| **FFAppState → AppState** | 채팅 상태 관리 | `Provider<AppState>` 사용 |
| **flutter_flow/ → core/** | 채팅 유틸리티 | Import 경로 변경 |
| **FF 접두사 제거** | 채팅 위젯들 | `FFChatPreview` → `AppChatPreview` |
| **AppTheme 통합** | 채팅 UI 테마 | `AppTheme.of(context)` 사용 |

### Import 변경 예시

**FlutterFlow → Native Flutter 변환**:

**변경 전**:
- `/flutter_flow/flutter_flow_theme.dart`
- `/flutter_flow/flutter_flow_widgets.dart`
- `/flutter_flow/flutter_flow_chat_preview.dart`

**변경 후**:
- `/core/app_theme.dart`
- `/core/widgets/app_button.dart`
- `/core/widgets/app_chat_preview.dart`

## 📋 현재 상태 분석 (전체 하위 디렉토리 포함)

### 채팅 관련 전체 파일 목록
| 디렉토리 | 파일명 | 설명 | 대상 위치 |
|----------|--------|------|----------|
| **`/lib/pages/chat/`** (28개) | | | |
| └─ chat_list/ | chat_list_widget.dart | 채팅 목록 화면 | presentation/screens/chat_list/ |
| └─ | chat_list_model.dart | 채팅 목록 모델 | presentation/screens/chat_list/ |
| └─ chat_detail_v2/ | chat_detail_widget_v2.dart | 채팅 상세 화면 v2 | presentation/screens/chat_detail/ |
| └─ | chat_detail_controller_v2.dart | 채팅 컨트롤러 | presentation/screens/chat_detail/ |
| └─ | chat_detail_migration_service.dart | 마이그레이션 서비스 | data/services/ |
| └─ chat_detail_v2/components/ | chat_detail_app_bar.dart | 채팅 앱바 | presentation/widgets/ |
| └─ | chat_detail_fab.dart | 플로팅 액션 버튼 | presentation/widgets/ |
| └─ | chat_detail_loading_widgets.dart | 로딩 위젯 | presentation/widgets/ |
| └─ | chat_media_picker.dart | 미디어 피커 | presentation/widgets/ |
| └─ | chat_search_bar.dart | 검색바 | presentation/widgets/ |
| └─ | chat_message_builder.dart | 메시지 빌더 | presentation/widgets/ |
| └─ ai_chat_v2/ | ai_chat_page_v2.dart | AI 채팅 페이지 | presentation/screens/ai_chat/ |
| └─ | ai_chat_controller.dart | AI 채팅 컨트롤러 | presentation/screens/ai_chat/ |
| └─ friends_list/ | friends_list_widget.dart | 친구 목록 | presentation/screens/friends/ |
| └─ chat_search/ | chat_search_widget.dart | 채팅 검색 | presentation/screens/search/ |
| └─ services/ | chat_initialization_service.dart | 초기화 서비스 | data/services/ |
| └─ | chat_message_service.dart | 메시지 서비스 | data/services/ |
| └─ | chat_message_lifecycle_service.dart | 메시지 생명주기 | data/services/ |
| └─ | chat_scroll_service.dart | 스크롤 서비스 | data/services/ |
| └─ | chat_animation_service.dart | 애니메이션 서비스 | data/services/ |
| └─ | chat_media_upload_service.dart | 미디어 업로드 | data/services/ |
| └─ | chat_file_size_service.dart | 파일 크기 관리 | data/services/ |
| └─ constants/ | chat_constants.dart | 상수 정의 | domain/constants/ |
| **`/lib/components/chat/`** (11개) | | | |
| └─ | vote_card_message.dart | 투표 카드 메시지 | presentation/widgets/ |
| └─ | base_vote_message.dart | 투표 메시지 베이스 | presentation/widgets/ |
| └─ vote_card/ | vote_card_header.dart | 투표 카드 헤더 | presentation/widgets/ |
| └─ | vote_result_display.dart | 투표 결과 표시 | presentation/widgets/ |
| └─ | vote_option_box.dart | 투표 옵션 박스 | presentation/widgets/ |
| └─ | vote_action_button.dart | 투표 액션 버튼 | presentation/widgets/ |
| **`/lib/backend/schema/`** (메시징 관련 6개) | | | |
| └─ | chats_model.dart | 채팅 모델 | domain/models/ |
| └─ | messages_model.dart | 메시지 모델 | domain/models/ |
| └─ | group_chats_model.dart | 그룹 채팅 모델 | domain/models/ |
| └─ | group_messages_model.dart | 그룹 메시지 모델 | domain/models/ |
| └─ | chat_history_model.dart | 채팅 히스토리 | domain/models/ |
| └─ | chat_interest_jops_model.dart | 관심사 기반 채팅 | domain/models/ |
| **`/lib/services/`** (캐싱 관련 3개) | | | |
| └─ cache/ | unified_cache_service.dart | 통합 캐시 서비스 | data/services/cache/ |
| └─ | simple_memory_cache.dart | 메모리 캐시 | data/services/cache/ |
| └─ | preload_strategy.dart | 프리로드 전략 | data/services/cache/ |
| **`/lib/utils/`** (헬퍼 1개) | | | |
| └─ | vote_message_helper.dart | 투표 메시지 헬퍼 | domain/helpers/ |
| **`/lib/services/`** (투표 관련 2개) | | | |
| └─ | vote_timer_service.dart | 투표 타이머 서비스 | data/services/ |
| └─ | vote_state_coordinator.dart | 투표 상태 조정 | data/services/ |
| **총합** | **56개 파일** | **전체 채팅 관련 파일** | **Feature-First 구조로 재배치** |

## 🏗️ Feature-First 구조 매핑

```
/lib/features/chat/
├── data/
│   ├── repositories/
│   │   ├── chat_repository.dart          # 채팅 데이터 접근 추상화
│   │   ├── message_repository.dart       # 메시지 데이터 관리
│   │   └── ai_chat_repository.dart       # AI 채팅 데이터 관리
│   │
│   └── services/
│       ├── chat_service.dart             # 채팅 CRUD 서비스
│       ├── message_service.dart          # 메시지 관리
│       ├── chat_initialization_service.dart # 채팅 초기화
│       ├── chat_lifecycle_service.dart   # 생명주기 관리
│       ├── chat_media_upload_service.dart # 미디어 업로드
│       ├── chat_file_size_service.dart   # 파일 크기 관리
│       ├── chat_animation_service.dart   # 애니메이션
│       ├── chat_scroll_service.dart      # 스크롤 관리
│       ├── chat_cache_service.dart       # 캐싱 관리
│       └── ai_chat_service.dart          # AI 채팅 서비스
│
├── domain/
│   ├── models/
│   │   ├── chat_model.dart              # 채팅방 모델
│   │   ├── message_model.dart           # 메시지 모델
│   │   ├── group_chat_model.dart        # 그룹 채팅 모델
│   │   ├── vote_message_model.dart      # 투표 메시지 모델
│   │   ├── media_message_model.dart     # 미디어 메시지
│   │   └── ai_assistant_model.dart      # AI 어시스턴트
│   │
│   └── usecases/
│       ├── send_message_usecase.dart    # 메시지 전송
│       ├── load_messages_usecase.dart   # 메시지 로드
│       ├── create_chat_usecase.dart     # 채팅방 생성
│       ├── delete_message_usecase.dart  # 메시지 삭제
│       ├── upload_media_usecase.dart    # 미디어 업로드
│       └── search_messages_usecase.dart # 메시지 검색
│
└── presentation/
    ├── screens/
    │   ├── chat_list/                   # 채팅 목록 화면
    │   │   ├── chat_list_widget.dart
    │   │   └── chat_list_model.dart
    │   │
    │   ├── chat_detail/                 # 채팅 상세 화면
    │   │   ├── chat_detail_widget_v2.dart
    │   │   ├── chat_detail_model.dart
    │   │   └── components/              # 채팅 화면 컴포넌트
    │   │       ├── chat_detail_app_bar.dart
    │   │       ├── message_bubble.dart
    │   │       └── input_toolbar.dart
    │   │
    │   ├── ai_chat/                     # AI 채팅 화면
    │   │   ├── ai_chat_page_v2.dart
    │   │   ├── ai_chat_model.dart
    │   │   └── ai_search_bar.dart
    │   │
    │   ├── chat_search/                 # 채팅 검색 화면
    │   │   ├── chat_search_widget.dart
    │   │   └── chat_search_model.dart
    │   │
    │   ├── friends_list/                # 친구 목록 화면
    │   │   ├── friends_list_widget.dart
    │   │   └── friends_list_model.dart
    │   │
    │   └── group_chat/                  # 그룹 채팅 화면
    │       ├── group_chat_widget.dart
    │       └── group_chat_model.dart
    │
    ├── widgets/
    │   ├── vote_card_message.dart       # 투표 카드 메시지
    │   ├── base_vote_message.dart       # 베이스 투표 메시지
    │   ├── message_list.dart            # 메시지 리스트
    │   ├── typing_indicator.dart        # 타이핑 표시
    │   ├── message_status.dart          # 메시지 상태
    │   ├── chat_avatar.dart             # 채팅 아바타
    │   ├── unread_badge.dart            # 읽지 않은 뱃지
    │   └── chat_date_divider.dart       # 날짜 구분선
    │
    ├── providers/
    │   ├── chat_provider.dart           # 채팅 상태 관리
    │   ├── message_provider.dart        # 메시지 상태 관리
    │   └── typing_provider.dart         # 타이핑 상태 관리
    │
    └── constants/
        ├── chat_colors.dart              # 채팅 색상 상수
        ├── chat_dimensions.dart          # 채팅 크기 상수
        └── chat_strings.dart             # 채팅 문자열 상수
```

## 📁 상세 파일 이동 계획

### Phase 1: Services 이동 (data/services/)

```bash
# 채팅 서비스
git mv lib/pages/chat/services/chat_initialization_service.dart lib/features/chat/data/services/
git mv lib/pages/chat/services/chat_message_service.dart lib/features/chat/data/services/
git mv lib/pages/chat/services/chat_message_lifecycle_service.dart lib/features/chat/data/services/chat_lifecycle_service.dart
git mv lib/pages/chat/services/chat_media_upload_service.dart lib/features/chat/data/services/
git mv lib/pages/chat/services/chat_file_size_service.dart lib/features/chat/data/services/
git mv lib/pages/chat/services/chat_animation_service.dart lib/features/chat/data/services/
git mv lib/pages/chat/services/chat_scroll_service.dart lib/features/chat/data/services/

# 캐싱 서비스
git mv lib/services/cache/unified_cache_service.dart lib/features/chat/data/services/chat_cache_service.dart
git mv lib/services/cache/simple_memory_cache.dart lib/features/chat/data/services/memory_cache_service.dart
git mv lib/services/cache/cache_statistics.dart lib/features/chat/data/services/cache_statistics_service.dart
git mv lib/services/cache/preload_strategy.dart lib/features/chat/data/services/preload_service.dart

# 채팅 관련 서비스
git mv lib/services/chat_image_cache_service.dart lib/features/chat/data/services/
```

### Phase 2: Models 이동 (domain/models/)

```bash
# 채팅 모델
git mv lib/backend/schema/chats_model.dart lib/features/chat/domain/models/chat_model.dart
git mv lib/backend/schema/messages_model.dart lib/features/chat/domain/models/message_model.dart
git mv lib/backend/schema/group_chats_model.dart lib/features/chat/domain/models/group_chat_model.dart

# 컴포넌트 모델
git mv lib/components/chat/vote_card/vote_card_message_model.dart lib/features/chat/domain/models/vote_message_model.dart
```

### Phase 3: Screens 이동 (presentation/screens/)

```bash
# 채팅 목록
mkdir -p lib/features/chat/presentation/screens/chat_list
git mv lib/pages/chat/chat_list/chat_list_widget.dart lib/features/chat/presentation/screens/chat_list/
git mv lib/pages/chat/chat_list/chat_list_model.dart lib/features/chat/presentation/screens/chat_list/

# 채팅 상세
mkdir -p lib/features/chat/presentation/screens/chat_detail
git mv lib/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart lib/features/chat/presentation/screens/chat_detail/
git mv lib/pages/chat/chat_detail_v2/chat_detail_model.dart lib/features/chat/presentation/screens/chat_detail/

# 채팅 상세 컴포넌트
mkdir -p lib/features/chat/presentation/screens/chat_detail/components
git mv lib/pages/chat/chat_detail_v2/components/* lib/features/chat/presentation/screens/chat_detail/components/

# AI 채팅
mkdir -p lib/features/chat/presentation/screens/ai_chat
git mv lib/pages/chat/ai_chat_v2/ai_chat_page_v2.dart lib/features/chat/presentation/screens/ai_chat/
git mv lib/pages/chat/ai_chat_v2/ai_chat_model.dart lib/features/chat/presentation/screens/ai_chat/

# 채팅 검색
mkdir -p lib/features/chat/presentation/screens/chat_search
git mv lib/pages/chat/chat_search/chat_search_widget.dart lib/features/chat/presentation/screens/chat_search/
git mv lib/pages/chat/chat_search/chat_search_model.dart lib/features/chat/presentation/screens/chat_search/

# 친구 목록
mkdir -p lib/features/chat/presentation/screens/friends_list
git mv lib/pages/chat/friends_list/friends_list_widget.dart lib/features/chat/presentation/screens/friends_list/
git mv lib/pages/chat/friends_list/friends_list_model.dart lib/features/chat/presentation/screens/friends_list/
```

### Phase 4: Widgets 이동 (presentation/widgets/)

```bash
# 채팅 컴포넌트
git mv lib/components/chat/vote_card_message.dart lib/features/chat/presentation/widgets/
git mv lib/components/chat/base_vote_message.dart lib/features/chat/presentation/widgets/
git mv lib/components/chat/vote_card/* lib/features/chat/presentation/widgets/vote_card/

# 기타 위젯
git mv lib/pages/chat/widgets/* lib/features/chat/presentation/widgets/
```

### Phase 5: Constants 이동 (presentation/constants/)

```bash
# 상수 파일
git mv lib/pages/chat/constants/* lib/features/chat/presentation/constants/
```

### Phase 6: Repository 생성 (data/repositories/)

**목적**: 데이터 접근 계층 추상화 및 캐싱 통합

**생성할 파일**: `chat_repository.dart`

**주요 책임**:
- ChatService와 MessageService 통합
- UnifiedCacheService를 통한 캐싱 로직
- Stream 기반 실시간 데이터 제공
- 메시지 전송 및 미디어 처리

## 📝 Import 경로 업데이트

### 영향받는 주요 파일들

| 파일 그룹 | 예상 영향 파일 수 | 설명 |
|----------|-----------------|------|
| 채팅 화면 관련 | 30개+ | 채팅 목록, 상세 |
| 메시지 관련 | 20개+ | 메시지 표시, 전송 |
| 캐싱 관련 | 15개+ | 3-Layer 캐싱 |
| AI 채팅 관련 | 10개+ | AI 어시스턴트 |

### Import 변경 예시

**변경 전 (Before)**:
- `/pages/chat/services/chat_initialization_service.dart`
- `/components/chat/vote_card_message.dart`
- `/backend/schema/messages_model.dart`

**변경 후 (After)**:
- `/features/chat/data/services/chat_initialization_service.dart`
- `/features/chat/presentation/widgets/vote_card_message.dart`
- `/features/chat/domain/models/message_model.dart`

## ✅ 검증 체크리스트

### 기능별 테스트

#### 1. 채팅방 관리
- [ ] 채팅방 생성
- [ ] 채팅방 목록 표시
- [ ] 채팅방 삭제
- [ ] 그룹 채팅 생성
- [ ] 참여자 관리

#### 2. 메시지 기능
- [ ] 텍스트 메시지 전송
- [ ] 이미지 전송
- [ ] 비디오 전송
- [ ] 파일 전송
- [ ] 투표 카드 전송
- [ ] 메시지 삭제
- [ ] 메시지 검색

#### 3. 실시간 기능
- [ ] 실시간 메시지 수신
- [ ] 타이핑 인디케이터
- [ ] 읽음 표시
- [ ] 온라인 상태
- [ ] 푸시 알림

#### 4. AI 채팅
- [ ] AI 어시스턴트 대화
- [ ] 투표 카드 생성
- [ ] 검색 기능

#### 5. 성능 & 캐싱
- [ ] 3-Layer 캐싱 동작
- [ ] 메시지 프리로드
- [ ] 이미지 캐싱
- [ ] 오프라인 지원
- [ ] 무한 스크롤

## ⚠️ 주의사항

### 1. 캐싱 시스템
- 3-Layer 구조 유지 (Memory → Hive → Firestore)
- 캐시 키 구조 보존
- TTL 설정 유지

### 2. 실시간 통신
- Firebase Realtime 리스너 관리
- WebSocket 연결 상태
- 재연결 로직

### 3. 미디어 처리
- 이미지 압축 설정
- 비디오 스트리밍
- 파일 크기 제한

### 4. flutter_chat_ui 통합
- 라이브러리 커스터마이징 유지
- 테마 설정 보존
- 메시지 타입 확장

## 📊 예상 영향도

| 구분 | 영향도 | 파일 수 | 설명 |
|------|--------|---------|------|
| **Services** | 매우 높음 | 15개+ | 핵심 채팅 로직 |
| **Models** | 높음 | 5개+ | 데이터 구조 |
| **Screens** | 매우 높음 | 10개+ | 주요 화면 |
| **Widgets** | 높음 | 20개+ | UI 컴포넌트 |
| **Cache** | 매우 높음 | 5개+ | 성능 핵심 |
| **총 영향** | **매우 높음** | **60개+** | 앱 핵심 기능 |

## 🔄 마이그레이션 준비

### 브랜치 전략
```bash
# 0. 의존성 확인
# Core, Common, App, Auth, Profile 마이그레이션이 완료되었는지 확인

# 1. 현재 상태 백업
git add .
git commit -m "chore: backup before chat migration"
git push origin flutterflow

# 2. 마이그레이션 브랜치 생성
git checkout -b feature/chat-migration

# 3. 각 Phase별 커밋
# Phase 완료 시마다 커밋하여 롤백 포인트 생성
```

### 롤백 계획
```bash
# 문제 발생 시 롤백
git reset --hard HEAD~1
git checkout flutterflow

# 또는 백업 브랜치로 복귀
git checkout backup/before-chat-migration
```

## 📅 예상 소요 시간

| Phase | 소요 시간 | 난이도 |
|-------|----------|--------|
| Phase 1: Services | 2시간 | ⭐⭐⭐⭐ |
| Phase 2: Models | 30분 | ⭐⭐ |
| Phase 3: Screens | 2시간 | ⭐⭐⭐⭐ |
| Phase 4: Widgets | 1시간 | ⭐⭐⭐ |
| Phase 5: Constants | 30분 | ⭐ |
| Phase 6: Repository | 2시간 | ⭐⭐⭐⭐ |
| **총 소요 시간** | **8시간** | ⭐⭐⭐⭐ |

## 🚀 다음 단계

1. **캐싱 시스템 보존**
   - 3-Layer 구조 유지
   - 성능 메트릭 확인

2. **실시간 기능 테스트**
   - Firebase 리스너
   - 메시지 동기화

3. **AI 채팅 통합**
   - AI 서비스 연결
   - 투표 카드 시스템

---

*이 문서는 Feature-First Architecture 마이그레이션의 Chat Feature 통합 가이드입니다.*
*최종 업데이트: 2025-08-25*
*예상 작업 시간: 8시간*
*의존성: Core, Common, App, Auth, Profile 완료 필요*