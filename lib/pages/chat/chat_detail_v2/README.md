# Chat Detail v2 - 모든 채팅 처리 컴포넌트

## 🎯 용도

**ChatDetailWidgetV2**는 Versus Space의 **모든 채팅 기능을 처리**하는 핵심 컴포넌트입니다.

### 현재 담당 기능:
1. ✅ **일반 채팅**: 사용자 간 1:1 메시지
2. ✅ **투표 카드**: AI가 생성한 투표 요청 표시 및 상호작용
3. ✅ **검색 기능**: AI 채팅방에서만 활성화

### ⚠️ 주의사항
이 컴포넌트는 **AIChatPageV2와 다른 용도**입니다:
- **ChatDetailWidgetV2**: 현재 사용 중, 모든 채팅 처리
- **AIChatPageV2**: 미래 기능, AI 어시스턴트 전용 (미사용)

## Status: ✅ 현재 활성 사용 중

### Completed Components:
1. **ChatDetailWidgetV2** - Full v2 implementation with proper builders
2. **ChatDetailControllerV2** - Controller with ScrollToMessageMixin support  
3. **ChatDetailMigrationService** - Message conversion service
4. **Firestore Integration** - Real-time message synchronization

## Architecture

```
flutter_chat_ui v2.9.0
         ↓
    Chat Widget
         ↓
ChatDetailControllerV2 (with ScrollToMessageMixin)
         ↓
ChatDetailMigrationService (Conversion layer)
         ↓
    Firestore
         ↓
  VoteCardMessage (Custom messages)
```

## AI 채팅 감지 로직

```dart
bool get isAiChat => 
  widget.chatDocument?.chatName == 'AI 피클' ||
  (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);
```

AI 채팅으로 감지되면:
- AppBar에 검색 아이콘 표시
- 검색 기능 활성화
- AI 관련 UI 표시

## Key Features Implemented

### ✅ Core Chat Functionality
- Message sending and receiving
- Real-time Firestore synchronization
- User resolution system
- Custom message rendering (VoteCardMessage)

### ✅ v2 API Migration
- Proper use of `core.Builders`
- `core.User` with `name` and `imageSource`
- `core.Message` types (text, image, video, custom)
- ScrollToMessageMixin integration

### ✅ Search Support (AI Chat Only)
- **AI 채팅에서만 활성화**
- Search query highlighting in messages
- Search navigation (1/3 형태)
- `_buildAISearchInput()` 메서드로 구현

### ✅ Media Support Structure
- Media selection bottom sheet
- Gallery/camera pickers implemented
- ChatMediaUploadService integration

## Usage

To use the new chat detail page:

```dart
// Navigate to v2 chat detail
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ChatDetailWidgetV2(
      chatDocument: chatModel,
    ),
  ),
);
```

## Migration Guide

### From v1 ChatDetailWidget to v2

1. **Change import**:
```dart
// Old
import '/pages/chat/chat_detail/chat_detail_widget.dart';

// New
import '/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart';
```

2. **Update navigation**:
```dart
// Old
ChatDetailWidget(chatDocument: chat)

// New
ChatDetailWidgetV2(chatDocument: chat)
```

### Key Differences

#### User Model
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

#### Builders
```dart
// v1
Builders(
  customMessageBuilder: (message, {messageWidth}) => widget,
)

// v2
core.Builders(
  customMessageBuilder: (context, message, index, {isSentByMe, groupStatus}) => widget,
)
```

## Remaining TODOs

### Phase 2.4: Attachment Support
- [ ] Implement gallery picker
- [ ] Implement camera picker
- [ ] Add file upload support
- [ ] Update message models for attachments

### Phase 2.5: Testing & Validation
- [ ] Test message sending/receiving
- [ ] Test scroll-to-message functionality
- [ ] Test search in AI chat
- [ ] Test VoteCardMessage rendering
- [ ] Performance testing with large message lists

## Next Steps (Phase 3)

1. **Complete Migration**:
   - Replace all uses of ChatDetailWidget with ChatDetailWidgetV2
   - Remove old ChatDetailWidget
   - Update all navigation references

2. **Remove flutter_chat_types**:
   - Remove dependency from pubspec.yaml
   - Update all remaining references
   - Clean up MessageAdapter

3. **Performance Optimization**:
   - Implement message pagination
   - Add message caching
   - Optimize image loading

## Known Issues

- Gallery/camera pickers not yet implemented (placeholders in place)
- Attachment handling needs implementation
- Message persistence could be optimized with better caching

## Testing

To test the current implementation:

1. Update a chat navigation to use ChatDetailWidgetV2
2. Test sending/receiving messages
3. Test VoteCardMessage rendering
4. Test AI chat search functionality

```dart
// Example test navigation
context.push('/chat-detail-v2', extra: chatDocument);
```

## Migration Progress

- [x] Phase 1: AI Chat v2 (100%)
- [x] Phase 2: General Chat v2 (90% - attachments pending)
- [ ] Phase 3: Complete Integration (0%)

Total Migration Progress: **60%**