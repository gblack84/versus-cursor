# Chat System v2 Architecture

## Overview

Versus Space 채팅 시스템은 flutter_chat_ui v2.9.0 기반으로 구축되었으며, Firebase Firestore를 백엔드로 사용합니다. v2 마이그레이션을 통해 더 나은 성능, 실시간 상태 관리, 향상된 UX를 제공합니다.

## Directory Structure

```
lib/pages/chat/
├── ai_chat_v2/           # AI 채팅 (피클봇) 구현
├── chat_detail_v2/       # 일반 채팅 상세 화면
├── chat_list/            # 채팅 목록 화면
├── chat_search/          # 채팅 검색 기능
├── friends_list/         # 친구 목록
├── services/             # 채팅 관련 서비스 레이어
├── MIGRATION_STATUS.md   # 마이그레이션 진행 상태
└── MIGRATION_COMPLETE.md # 마이그레이션 완료 체크리스트
```

## Core Components

### 1. ChatDetailWidgetV2
**위치**: `chat_detail_v2/chat_detail_widget_v2.dart`

주요 기능:
- flutter_chat_ui v2.9.0 Chat 위젯 통합
- 실시간 메시지 동기화 (Firestore)
- 메시지 상태 관리 (sent, delivered, seen)
- 커스텀 메시지 타입 지원 (VoteCardMessage)
- 미디어 업로드 (이미지, 비디오)
- 날짜별 구분선 표시

### 2. AIChatPageV2
**위치**: `ai_chat_v2/ai_chat_page_v2.dart`

주요 기능:
- AI 피클봇과의 대화
- 검색 기능 통합
- 투표 카드 생성 및 공유
- 메시지 하이라이팅

### 3. ChatMessageLifecycleService
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
  "last_message": "Hello",
  "last_message_at": "Timestamp",
  "last_message_sender": "user1"
}
```

#### `chats/{chatId}/messages`
```json
{
  "id": "message_id",
  "sender_id": "user_id",
  "text": "Message content",
  "type": "text|image|video|custom",
  "created_at": "Timestamp",
  "delivered_at": "Timestamp",
  "seen_at": "Timestamp",
  "metadata": {}
}
```

### Required Indexes

```json
{
  "collectionGroup": "messages",
  "fields": [
    { "fieldPath": "sender_id", "order": "ASCENDING" },
    { "fieldPath": "seen_at", "order": "ASCENDING" }
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

1. **Message Pagination**: 초기 50개 메시지 로드, 스크롤 시 추가 로드
2. **Image Caching**: UnifiedImageCacheService 통합
3. **Batch Updates**: 읽음 상태 배치 업데이트
4. **Stream Subscriptions**: 효율적인 실시간 업데이트

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

## Future Improvements

- [ ] 메시지 암호화 (E2E)
- [ ] 오프라인 메시지 큐
- [ ] 메시지 검색 기능
- [ ] 음성 메시지 지원
- [ ] 메시지 반응 (이모지)
- [ ] 답장 기능
- [ ] 메시지 편집/삭제

## Related Documentation

- [Services Layer](services/README.md)
- [Migration Guide](MIGRATION_STATUS.md)
- [Firebase Functions](../../../firebase/functions/README.md)
- ~~Compatibility Layer~~ (Removed - migration complete)