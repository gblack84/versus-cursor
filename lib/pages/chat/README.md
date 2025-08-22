# Versus Space 채팅 시스템 아키텍처

## 📋 목차
- [개요](#개요)
- [시스템 구조](#시스템-구조)
- [핵심 컴포넌트](#핵심-컴포넌트)
- [채팅방 생성 플로우](#채팅방-생성-플로우)
- [검색 기능](#검색-기능)
- [미래 계획](#미래-계획)

## 개요

## 🎯 네이밍 컨벤션
- **파일명**: snake_case (Dart 표준)
- **필드명**: camelCase
- 참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

Versus Space의 채팅 시스템은 **투표 중심의 소셜 커뮤니케이션**을 위해 설계되었습니다.
현재는 투표 요청을 통해 채팅이 시작되며, 향후 일반 메시징과 AI 어시스턴트 기능이 추가될 예정입니다.

## 시스템 구조

```
┌─────────────────────────────────────────────────────────┐
│                    채팅 시스템 아키텍처                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────────┐         ┌──────────────────────┐  │
│  │  ChatListWidget │ ────────▶│ ChatDetailWidgetV2   │  │
│  │  (채팅 목록)     │         │  (현재 사용 중)        │  │
│  └─────────────────┘         │                      │  │
│                              │  - 일반 채팅 처리        │  │
│                              │  - AI 투표 카드 표시    │  │
│                              │  - 검색 (AI만)         │  │
│                              └──────────────────────┘  │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │              AIChatPageV2 (미래 기능)              │   │
│  │                                                 │   │
│  │  ⚠️ 현재 미사용 - 향후 AI 어시스턴트용             │   │
│  │  - 앱 사용법 안내                                │   │
│  │  - 실시간 AI 대화                               │   │
│  │  - Gemini AI 통합                              │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Directory Structure

```
lib/pages/chat/
├── ai_chat_v2/           # AI 어시스턴트 (미래 기능)
├── chat_detail_v2/       # 모든 채팅 처리 (현재 사용)
├── chat_list/            # 채팅 목록 화면
├── chat_search/          # 친구 검색 (채팅 시작 미구현)
├── friends_list/         # 친구 목록
├── services/             # 채팅 관련 서비스 레이어
├── MIGRATION_STATUS.md   # 마이그레이션 진행 상태
└── MIGRATION_COMPLETE.md # 마이그레이션 완료 체크리스트
```

## 핵심 컴포넌트

### 1. ChatDetailWidgetV2 ✅ (현재 활성)
**위치**: `chat_detail_v2/chat_detail_widget_v2.dart`

**용도**: 
- ✅ 모든 채팅방 처리 (일반 + AI 투표)
- ✅ 투표 카드 메시지 표시 및 상호작용
- ✅ AI 채팅 감지 및 검색 기능 활성화

**AI 채팅 감지 로직**:
```dart
bool get isAiChat => 
  widget.chatDocument?.chatName == 'AI 피클' ||
  (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);
```

**주요 기능**:
- flutter_chat_ui v2.9.0 Chat 위젯 통합
- 실시간 메시지 동기화 (Firestore)
- 메시지 상태 관리 (sent, delivered, seen)
- 커스텀 메시지 타입 지원 (VoteCardMessage)
- 검색 기능 (AI 채팅에서만)
- 날짜별 구분선 표시

### 2. AIChatPageV2 ⏳ (미래 기능)
**위치**: `ai_chat_v2/ai_chat_page_v2.dart`

**상태**: 
- ⚠️ **현재 미사용** - 라우팅에 등록되지 않음
- 📅 **향후 활성화 예정** - AI 어시스턴트 기능용

**계획된 기능**:
- AI 어시스턴트와 실시간 대화
- 앱 사용법 및 기능 안내
- 설정 도움말
- ChatGPT 스타일 스트리밍 응답

**준비 상태**:
```dart
// Gemini AI 통합 코드 준비 완료
// API 키만 설정하면 사용 가능
_chatController.initializeAI('YOUR_GEMINI_API_KEY');
```

### 3. ChatListWidget
**위치**: `chat_list/chat_list_widget.dart`

**기능**:
- 사용자의 채팅방 목록 표시
- AI 채팅방 구분 표시 (보라색 아이콘)
- 새 채팅 시작 버튼 (⚠️ 미구현 - "준비 중입니다")

### 4. NotificationService
**위치**: `/lib/services/notification_service.dart`

**역할**: 
- **채팅방 자동 생성 담당**
- 투표 요청 시 채팅방 생성
- 투표 카드 메시지 생성

## 채팅방 생성 플로우

### 현재 구현된 방식 (투표 중심)
```
1. 사용자가 투표 생성
    ↓
2. 타겟 사용자 선택
    ↓
3. NotificationService.createVoteRequestChatMessage() 호출
    ↓
4. 채팅방 자동 생성 (ID: participantIds.sort().join('_'))
    ↓
5. 투표 카드 메시지 추가
    ↓
6. 채팅 시작
```

### 채팅방 ID 생성 규칙
```dart
// 일반 채팅방
final participantIds = [senderId, recipientId]..sort();
final chatId = participantIds.join('_');
// 예: "user1_user2"

// AI 채팅방
final aiChatId = 'ai_assistant_${userId}';
// 예: "ai_assistant_abc123"
```

## 검색 기능

### 현재 상태
- ✅ **AI 채팅에서만 활성화**
- ❌ 일반 채팅에서는 비활성화

### 검색 UI 위치
```
ChatDetailAppBar (AppBar의 검색 아이콘)
    ↓ (AI 채팅인 경우만)
_buildAISearchInput() (검색 입력창)
    ↓
검색 결과 네비게이션 (1/3 형태)
```

### 검색 가능 내용
- 텍스트 메시지
- 투표 카드 제목
- 투표 카드 설명
- 투표 옵션 텍스트

## 서비스 레이어

### ChatMessageLifecycleService
**위치**: `services/chat_message_lifecycle_service.dart`

주요 기능:
- 메시지 읽음 상태 관리
- 실시간 상태 스트림
- Firebase Functions 연동
- 배치 업데이트 최적화

## Migration from v1 to v2

### Breaking Changes

1. **ChatDetailWidget → ChatDetailWidgetV2**
```dart
// Before (v1)
import '/pages/chat/chat_detail/chat_detail_widget.dart';
ChatDetailWidget(chatDocument: chat)

// After (v2)
import '/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart';
ChatDetailWidgetV2(chatDocument: chat)
```

2. **User Model Changes**
```dart
// v1 (flutter_chat_types)
types.User(
  id: 'user1',
  firstName: 'John',
  lastName: 'Doe',
  imageUrl: 'url',
)

// v2 (flutter_chat_core)
core.User(
  id: 'user1',
  name: 'John Doe',
  imageSource: 'url',
)
```

3. **Message Model Changes**
```dart
// v1
types.Message.text(
  author: user,
  createdAt: DateTime.now().millisecondsSinceEpoch,
  id: messageId,
  text: 'Hello',
)

// v2
core.Message.text(
  authorId: user.id,
  createdAt: DateTime.now(),
  id: messageId,
  text: 'Hello',
)
```

## Firebase Firestore Structure

### Collections

#### `chats`
```json
{
  "participantIds": ["user1", "user2"],
  "lastMessage": "Hello",
  "lastMessageAt": "Timestamp",
  "lastMessageSender": "user1"
}
```

#### `chats/{chatId}/messages`
```json
{
  "id": "messageId",
  "senderId": "userId",
  "text": "Message content",
  "type": "text|image|video|custom",
  "createdAt": "Timestamp",
  "deliveredAt": "Timestamp",
  "seenAt": "Timestamp",
  "metadata": {}
}
```

### Required Indexes

```json
{
  "collectionGroup": "messages",
  "fields": [
    { "fieldPath": "senderId", "order": "ASCENDING" },
    { "fieldPath": "seenAt", "order": "ASCENDING" }
  ]
}
```

## Message Status Flow

```
Created → Sent → Delivered → Seen
```

1. **Created**: 메시지 생성 (클라이언트)
2. **Sent**: Firestore에 저장됨
3. **Delivered**: 상대방 디바이스에 도달
4. **Seen**: 상대방이 읽음

## Custom Message Types

### VoteCardMessage
투표 카드를 채팅으로 공유하는 커스텀 메시지 타입

```dart
{
  "type": "custom",
  "metadata": {
    "customType": "vote_card",
    "votePostId": "post_id",
    "optionAText": "Option A",
    "optionBText": "Option B",
    "optionAImages": ["url1", "url2"],
    "optionBImages": ["url3", "url4"]
  }
}
```

## Performance Optimizations

### 초기 로드 최적화
1. **Message Pagination**: 초기 30개 메시지 로드, 스크롤 시 20개씩 추가 로드
2. **Parallel Processing**: 
   - 사용자 정보 병렬 로드 (Future.wait)
   - 메시지 변환 병렬 처리
   - 3-5배 빠른 초기 로드
3. **Image Caching**: UnifiedImageCacheService 통합
4. **State Management**: 
   - setState 호출 최소화
   - 불필요한 리렌더링 방지
5. **Batch Updates**: 읽음 상태 배치 업데이트
6. **Stream Subscriptions**: 효율적인 실시간 업데이트
7. **Debug Optimization**: kDebugMode 조건부 로깅

### 성능 메트릭
| 작업 | 이전 | 이후 | 개선율 |
|------|------|------|--------|
| 사용자 정보 로드 (3명) | ~300ms | ~100ms | 67% ↓ |
| 메시지 변환 (30개) | ~150ms | ~50ms | 67% ↓ |
| 채팅방 진입 | ~500ms | ~200ms | 60% ↓ |

## Testing

```bash
# Unit tests
flutter test test/chat/

# Integration tests
flutter test integration_test/chat/
```

## Known Issues & Solutions

### 스크롤 점프 문제 (flutter_chat_ui v2.9.0)
flutter_chat_ui v2는 기본적으로 **Regular List** 모드를 사용하여 채팅방 진입 시 오래된 메시지가 먼저 표시되는 문제가 있습니다.

**문제 증상**:
- 채팅방 진입 시 오래된 메시지가 먼저 보임
- 이후 최신 메시지로 자동 스크롤 (점프 현상)
- 사용자 경험 저하

**해결 방법**: `ChatAnimatedListReversed` 사용
```dart
Chat(
  builders: Builders(
    chatAnimatedListBuilder: (context, itemBuilder) {
      return ChatAnimatedListReversed(
        itemBuilder: itemBuilder,
      );
    },
    // ... other builders
  ),
)
```

**적용 파일**:
- `chat_detail_v2/chat_detail_widget_v2.dart`
- `ai_chat_v2/ai_chat_page_v2.dart`

## 미래 계획

### Phase 1: 일반 메시징 (계획)
- [ ] 친구에게 직접 메시지 시작
- [ ] 채팅방 생성 UI
- [ ] 그룹 채팅

### Phase 2: AI 어시스턴트 (준비됨)
- [ ] AIChatPageV2 활성화
- [ ] Gemini AI API 키 설정
- [ ] 앱 내 도움말 시스템

### Phase 3: 고급 기능
- [ ] 메시지 암호화 (E2E)
- [ ] 오프라인 메시지 큐
- [ ] 음성 메시지 지원
- [ ] 메시지 반응 (이모지)
- [ ] 답장 기능
- [ ] 메시지 편집/삭제

## 주의사항

⚠️ **ChatDetailWidgetV2**와 **AIChatPageV2**는 서로 다른 용도입니다:
- ChatDetailWidgetV2: 현재 모든 채팅 처리 (일반 + 투표)
- AIChatPageV2: 미래 AI 어시스턴트 전용

⚠️ 현재 채팅방은 **투표 요청을 통해서만** 생성됩니다.

⚠️ 검색 기능은 **AI 채팅방에서만** 사용 가능합니다.

## Related Documentation

- [System Architecture](../../../ARCHITECTURE.md) - 전체 시스템 아키텍처
- [ChatDetailWidgetV2 Guide](chat_detail_v2/README.md)
- [AIChatPageV2 Guide](ai_chat_v2/README.md)
- [Services Layer](services/README.md)
- [Migration Guide](MIGRATION_STATUS.md)
- [Firebase Functions](../../../firebase/functions/README.md)

---

최종 업데이트: 2025-08-13