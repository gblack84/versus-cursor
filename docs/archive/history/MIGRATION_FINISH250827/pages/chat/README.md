# 💬 채팅 시스템 - Versus Space 소셜 커뮤니케이션 플랫폼

> 투표 중심의 실시간 채팅 시스템으로 flutter_chat_ui v2 기반의 모던 아키텍처

## 📋 목차
- [개요](#개요)
- [네이밍 컨벤션](#네이밍-컨벤션)
- [디렉토리 구조](#디렉토리-구조)
- [시스템 아키텍처](#시스템-아키텍처)
- [주요 구성요소](#주요-구성요소)
- [서비스 레이어](#서비스-레이어)
- [채팅방 생성 플로우](#채팅방-생성-플로우)
- [성능 최적화](#성능-최적화)
- [마이그레이션 가이드](#마이그레이션-가이드)
- [변경 이력](#변경-이력)

## 📋 개요

Versus Space의 채팅 시스템은 **투표 중심의 소셜 커뮤니케이션**을 위해 설계된 혁신적인 메시징 플랫폼입니다. flutter_chat_ui v2.9.0을 기반으로 구축되었으며, 실시간 메시지 동기화, 3-Layer 캐싱, AI 통합을 특징으로 합니다.

### 🎯 핵심 특징
- **투표 카드 메시징**: A vs B 형식의 인터랙티브 투표를 채팅으로 공유
- **3-Layer 캐싱**: Memory → Hive → Firestore로 <10ms 응답 속도 달성
- **AI 채팅 통합**: Gemini AI 기반 어시스턴트 (준비 완료)
- **실시간 동기화**: Firebase Firestore 기반 즉각적인 메시지 전달
- **성능 최적화**: 병렬 처리로 60% 빠른 채팅방 진입

### 📊 코드 통계
| 카테고리 | 수치 |
|---------|------|
| **총 디렉토리** | 8개 (서브 포함) |
| **Dart 파일** | 22개 |
| **총 코드 라인** | ~3,500줄 |
| **서비스 클래스** | 7개 |
| **README 문서** | 8개 |

## 🎯 네이밍 컨벤션

프로젝트 전체 네이밍 표준을 준수합니다:

### 파일명
- **패턴**: snake_case (Dart 표준)
- **예시**: `chat_detail_widget_v2.dart`, `chat_message_service.dart`

### 클래스명
- **패턴**: PascalCase
- **접미사**: Widget, Service, Model, Controller
- **예시**: `ChatDetailWidgetV2`, `ChatMessageService`

### Firestore 필드
- **패턴**: camelCase
- **예시**: `participantIds`, `lastMessageAt`, `senderId`

### 특수 ID
- **AI 채팅방**: `ai_assistant_{userId}` (snake_case 유지)
- **일반 채팅방**: `userId1_userId2` (정렬된 ID 조합)

> 참조: [프로젝트 전체 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 📁 디렉토리 구조

```
/lib/pages/chat/
├── 📱 ai_chat_v2/              # AI 어시스턴트 채팅 (미래 기능)
│   ├── ai_chat_controller.dart  # AI 채팅 컨트롤러
│   ├── ai_chat_page_v2.dart     # AI 채팅 UI
│   └── README.md                # 상세 문서
│
├── 💬 chat_detail_v2/          # 메인 채팅 화면 (현재 활성)
│   ├── chat_detail_widget_v2.dart       # 메인 채팅 위젯
│   ├── chat_detail_controller_v2.dart   # 채팅 컨트롤러
│   ├── chat_detail_migration_service.dart # v1→v2 마이그레이션
│   ├── components/              # UI 컴포넌트
│   │   ├── chat_detail_app_bar.dart    # 앱바
│   │   ├── chat_detail_fab.dart        # FAB 버튼
│   │   ├── chat_detail_loading_widgets.dart # 로딩 UI
│   │   ├── chat_media_picker.dart      # 미디어 선택
│   │   ├── chat_message_builder.dart   # 메시지 빌더
│   │   └── chat_search_bar.dart        # 검색바
│   └── README.md
│
├── 📋 chat_list/               # 채팅 목록
│   ├── chat_list_widget.dart    # 채팅 목록 UI
│   ├── chat_list_model.dart     # 데이터 모델
│   └── README.md
│
├── 🔍 chat_search/             # 친구 검색 (미구현)
│   ├── chat_search_widget.dart  # 검색 UI
│   └── README.md
│
├── 📐 constants/               # 상수 정의
│   ├── chat_constants.dart      # 채팅 관련 상수
│   └── README.md
│
├── 👥 friends_list/            # 친구 목록
│   ├── friends_list_widget.dart # 친구 목록 UI
│   └── README.md
│
├── ⚙️ services/               # 비즈니스 로직 레이어
│   ├── chat_initialization_service.dart  # 초기화 (356줄)
│   ├── chat_message_service.dart         # 메시지 변환 (212줄)
│   ├── chat_message_lifecycle_service.dart # 상태 관리 (246줄)
│   ├── chat_media_upload_service.dart    # 미디어 업로드 (188줄)
│   ├── chat_file_size_service.dart       # 파일 크기 (128줄)
│   ├── chat_animation_service.dart       # 애니메이션 (63줄)
│   ├── chat_scroll_service.dart          # 스크롤 (71줄)
│   └── README.md
│
└── README.md                   # 현재 문서
```

## 🏗️ 시스템 아키텍처

### 전체 구조도
```
┌─────────────────────────────────────────────────────────────┐
│                     채팅 시스템 아키텍처                         │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────┐        ┌──────────────────────────────┐   │
│  │ ChatList    │ ──────▶ │ ChatDetailWidgetV2 (활성)    │   │
│  │ Widget      │        │ ├─ 일반 채팅 처리               │   │
│  │             │        │ ├─ 투표 카드 표시               │   │
│  └─────────────┘        │ ├─ AI 채팅 감지                │   │
│                         │ └─ 검색 기능 (AI만)             │   │
│                         └──────────────────────────────┘   │
│                                    │                        │
│                                    ▼                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              서비스 레이어 (7개 서비스)                   │   │
│  │                                                     │   │
│  │  • ChatInitializationService - 채팅방 초기화          │   │
│  │  • ChatMessageService - 메시지 변환                  │   │
│  │  • ChatMessageLifecycleService - 상태 관리          │   │
│  │  • ChatMediaUploadService - 미디어 업로드            │   │
│  │  • ChatFileSizeService - 파일 크기 계산              │   │
│  │  • ChatAnimationService - 애니메이션                │   │
│  │  • ChatScrollService - 스크롤 관리                  │   │
│  └─────────────────────────────────────────────────────┘   │
│                                    │                        │
│                                    ▼                        │
│  ┌─────────────────────────────────────────────────────┐   │
│  │           3-Layer 캐싱 시스템                         │   │
│  │                                                     │   │
│  │  L1: Memory Cache (LRU, <10ms)                     │   │
│  │       ↓                                            │   │
│  │  L2: Hive Local DB (10-30ms)                       │   │
│  │       ↓                                            │   │
│  │  L3: Firestore Offline (50-100ms)                  │   │
│  │       ↓                                            │   │
│  │  Network: Firebase (300-500ms)                     │   │
│  └─────────────────────────────────────────────────────┘   │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         AIChatPageV2 (미래 기능)                      │   │
│  │  ⚠️ 현재 미사용 - AI 어시스턴트용 준비 완료              │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

### 데이터 플로우
```
사용자 입력
    ↓
ChatDetailWidgetV2 (UI Layer)
    ↓
ChatDetailControllerV2 (Controller)
    ↓
Services Layer (Business Logic)
    ↓
3-Layer Cache System
    ↓
Firebase Firestore (Persistence)
```

## 🔑 주요 구성요소

### 1. ChatDetailWidgetV2 ✅ (현재 메인)
**경로**: `chat_detail_v2/chat_detail_widget_v2.dart`

**핵심 기능**:
```dart
class ChatDetailWidgetV2 extends StatefulWidget {
  final ChatsModel? chatDocument;
  
  // AI 채팅 감지
  bool get isAiChat => 
    widget.chatDocument?.chatName == 'AI 피클' ||
    (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);
  
  // flutter_chat_ui v2 통합
  Chat(
    messages: _messages,
    onSendPressed: _handleSendPressed,
    builders: Builders(
      chatAnimatedListBuilder: (context, itemBuilder) {
        return ChatAnimatedListReversed(
          itemBuilder: itemBuilder,  // 스크롤 점프 해결
        );
      },
      customMessageBuilder: _customMessageBuilder,  // 투표 카드
    ),
  )
}
```

**컴포넌트 구조**:
- `ChatDetailAppBar`: 상단 앱바, 검색 아이콘
- `ChatDetailFAB`: 플로팅 액션 버튼
- `ChatMessageBuilder`: 메시지 타입별 렌더링
- `ChatMediaPicker`: 이미지/비디오 선택
- `ChatSearchBar`: AI 채팅 검색 기능

### 2. AIChatPageV2 ⏳ (미래 기능)
**경로**: `ai_chat_v2/ai_chat_page_v2.dart`

**준비 상태**:
```dart
class AIChatPageV2 extends StatefulWidget {
  // Gemini AI 통합 준비 완료
  void initState() {
    _chatController.initializeAI('YOUR_GEMINI_API_KEY');
    // 스트리밍 응답 지원
    // 앱 사용법 안내 시스템
  }
}
```

### 3. ChatListWidget 📋
**경로**: `chat_list/chat_list_widget.dart`

**주요 기능**:
- 채팅방 목록 표시
- AI 채팅 구분 (보라색 아이콘)
- 마지막 메시지 미리보기
- 읽지 않은 메시지 카운트

## ⚙️ 서비스 레이어

### ChatInitializationService (핵심)
**크기**: 356줄 | **패턴**: 싱글톤

```dart
// 채팅방 초기화 통합 관리
final result = await ChatInitializationService().bootstrap(
  chatDocument: chatDoc,
  initialMessageLimit: 30,
);

// BootstrapResult 구조
class BootstrapResult {
  final List<core.Message> messages;
  final core.User? currentUser;
  final UsersModel? currentUserRecord;
  final DateTime? lastLoadedTimestamp;
}
```

**3-Layer 캐싱 플로우**:
1. Memory Cache 체크 (<10ms)
2. Hive Local DB 체크 (10-30ms)
3. Firestore Offline 체크 (50-100ms)
4. Network 요청 (300-500ms, 캐시 미스 시만)

### ChatMessageService
**크기**: 212줄 | **패턴**: 정적 메서드

```dart
// Firestore → flutter_chat_ui 변환
static Future<core.Message?> convertDocumentToMessage(DocumentSnapshot doc) {
  // 지원 타입: text, image, voteRequest, voteCreated, system
  switch (messageType) {
    case 'voteRequest':
    case 'voteCreated':
      return _createVoteMessage(...);
    case 'image':
      return _createImageMessage(...);
    default:
      return core.TextMessage(...);
  }
}

// 병렬 일괄 변환 (30-50개 동시 처리)
static Future<List<core.Message>> convertDocumentsToMessages(docs);
```

### ChatMessageLifecycleService
**크기**: 246줄 | **패턴**: 싱글톤

```dart
enum MessageDeliveryStatus {
  sent,      // 전송됨
  delivered, // 배달됨
  seen,      // 읽음
  unknown,   // 알 수 없음
}

// 배치 업데이트로 성능 최적화
await lifecycleService.markMessagesAsSeen(
  chatId: chatId,
  currentUserId: userId,
);
```

### 기타 서비스
- **ChatMediaUploadService** (188줄): wechat_assets_picker 통합
- **ChatFileSizeService** (128줄): 파일 크기 계산 및 포맷팅
- **ChatAnimationService** (63줄): FAB 애니메이션 관리
- **ChatScrollService** (71줄): 스크롤 상태 추적

## 🚀 채팅방 생성 플로우

### 현재 구현 (투표 중심)
```
1. 투표 생성
    ↓
2. 타겟 사용자 선택
    ↓
3. NotificationService.createVoteRequestChatMessage()
    ↓
4. 채팅방 자동 생성
    ├─ ID: participantIds.sort().join('_')
    └─ 예: "user1_user2"
    ↓
5. 투표 카드 메시지 추가
    ↓
6. 실시간 동기화 시작
```

### AI 채팅방 생성
```dart
// 사용자별 AI 채팅방 고정 ID
final aiChatId = 'ai_assistant_${userId}';
// 계정 생성 시 자동 생성 (계획)
```

## ⚡ 성능 최적화

### 3-Layer 캐싱 시스템
| 레이어 | 기술 | 응답 시간 | 용량 |
|--------|------|-----------|------|
| **L1 Memory** | LRU Cache | <10ms | 100개 |
| **L2 Local** | Hive DB | 10-30ms | 무제한 |
| **L3 Offline** | Firestore | 50-100ms | 무제한 |
| **Network** | Firebase | 300-500ms | - |

### 병렬 처리 최적화
```dart
// 이전: 순차 처리 (300ms)
for (final userId in userIds) {
  final user = await loadUser(userId);
}

// 현재: 병렬 처리 (100ms)
final users = await Future.wait(
  userIds.map((id) => loadUser(id))
);
```

### 성능 메트릭
| 작업 | 이전 | 현재 | 개선율 |
|------|------|------|--------|
| 사용자 로드 (3명) | 300ms | 100ms | **67% ↓** |
| 메시지 변환 (30개) | 150ms | 50ms | **67% ↓** |
| 채팅방 진입 | 500ms | 200ms | **60% ↓** |
| 캐시 히트 시 | - | <10ms | **95% ↓** |

### 최적화 기법
1. **메시지 페이지네이션**: 초기 30개, 스크롤 시 20개씩
2. **이미지 프리캐싱**: UnifiedImageCacheService
3. **setState 최소화**: 배치 업데이트
4. **스트림 구독 관리**: 메모리 누수 방지
5. **디버그 조건부 처리**: kDebugMode 활용

## 🔄 마이그레이션 가이드

### v1 → v2 주요 변경사항

#### 1. 위젯 변경
```dart
// Before (v1)
import '/pages/chat/chat_detail/chat_detail_widget.dart';
ChatDetailWidget(chatDocument: chat)

// After (v2)
import '/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart';
ChatDetailWidgetV2(chatDocument: chat)
```

#### 2. 모델 변경
```dart
// v1: flutter_chat_types
types.User(
  id: 'user1',
  firstName: 'John',
  lastName: 'Doe',
)

// v2: flutter_chat_core
core.User(
  id: 'user1',
  name: 'John Doe',  // 통합된 이름 필드
)
```

#### 3. 스크롤 점프 해결
```dart
// ChatAnimatedListReversed 필수 적용
builders: Builders(
  chatAnimatedListBuilder: (context, itemBuilder) {
    return ChatAnimatedListReversed(
      itemBuilder: itemBuilder,
    );
  },
)
```

## 🐛 알려진 이슈 및 해결책

### 1. 스크롤 점프 문제 ✅ (해결됨)
- **원인**: flutter_chat_ui v2 기본 Regular List 모드
- **해결**: ChatAnimatedListReversed 적용
- **파일**: chat_detail_widget_v2.dart, ai_chat_page_v2.dart

### 2. 중복 메시지 ID ✅ (해결됨)
- **원인**: InMemoryChatController 중복 체크 누락
- **해결**: uniqueOlderMessages 필터링 추가

### 3. 캐시 직렬화 ✅ (해결됨)
- **원인**: Hive DateTime 타입 처리 오류
- **해결**: parseDateTime 헬퍼 메서드 구현

## 🚧 현재 제한사항

⚠️ **채팅방 생성**: 현재 투표 요청을 통해서만 가능  
⚠️ **검색 기능**: AI 채팅방에서만 활성화  
⚠️ **친구 검색**: 미구현 상태 ("준비 중입니다" 메시지)  
⚠️ **그룹 채팅**: 아직 지원하지 않음  

## 🔮 향후 계획

### Phase 1: 일반 메시징 확장
- [ ] 친구에게 직접 메시지 시작
- [ ] 채팅방 생성 UI
- [ ] 그룹 채팅 지원

### Phase 2: AI 어시스턴트 활성화
- [ ] AIChatPageV2 라우팅 등록
- [ ] Gemini AI API 통합
- [ ] 실시간 스트리밍 응답

### Phase 3: 고급 기능
- [ ] 메시지 암호화 (E2E)
- [ ] 오프라인 메시지 큐
- [ ] 음성/비디오 메시지
- [ ] 메시지 반응 (이모지)
- [ ] 답장/편집/삭제 기능

## 📚 관련 문서

### 하위 디렉토리 문서
- [AI 채팅 가이드](ai_chat_v2/README.md) - AI 어시스턴트 상세
- [채팅 상세 가이드](chat_detail_v2/README.md) - 메인 채팅 구현
- [채팅 목록](chat_list/README.md) - 채팅 목록 UI
- [친구 검색](chat_search/README.md) - 검색 기능
- [상수 정의](constants/README.md) - 채팅 관련 상수
- [친구 목록](friends_list/README.md) - 친구 관리
- [서비스 레이어](services/README.md) - 비즈니스 로직

### 프로젝트 문서
- [시스템 아키텍처](../../../ARCHITECTURE.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)
- [Firebase Functions](../../../firebase/functions/README.md)

## 📝 변경 이력

| 버전 | 날짜 | 변경사항 | 작성자 |
|------|------|----------|--------|
| 2.0.0 | 2025-08-23 | 통합 문서 작성, 하위 디렉토리 반영 | AI Assistant |
| 1.5.0 | 2025-08-17 | 3-Layer 캐싱 시스템 구현 | 개발팀 |
| 1.4.0 | 2025-08-13 | 서비스 레이어 분리 | 개발팀 |
| 1.3.0 | 2025-08-11 | flutter_chat_ui v2 마이그레이션 | 개발팀 |
| 1.2.0 | 2025-08-08 | 투표 카드 메시지 구현 | 개발팀 |
| 1.1.0 | 2025-08-04 | AI 채팅 준비 | 개발팀 |
| 1.0.0 | 2025-07-31 | 초기 채팅 시스템 구축 | 개발팀 |

---

*이 문서는 Versus Space 프로젝트의 채팅 시스템 전체를 설명합니다.*  
*채팅 시스템은 투표 중심의 혁신적인 소셜 커뮤니케이션을 제공합니다.*  
*마지막 업데이트: 2025-08-23*