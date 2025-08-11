# Flutter Chat UI v1 to v2 Migration Guide

## Overview

이 가이드는 Versus Space 프로젝트의 채팅 시스템을 flutter_chat_ui v1 (flutter_chat_types)에서 v2 (flutter_chat_core)로 마이그레이션하는 방법을 설명합니다.

## Migration Timeline

- **2025-08-10**: v2 마이그레이션 시작
- **2025-08-10**: ChatDetailWidgetV2, AIChatPageV2 완료
- **2025-08-10**: 메시지 상태 관리 시스템 구현
- **2025-09**: 나머지 컴포넌트 마이그레이션 (예정)
- **2025-11**: v1 완전 제거 (예정)

## Package Changes

### Dependencies Update

**pubspec.yaml**:
```yaml
# Remove (v1)
dependencies:
  flutter_chat_types: ^3.6.2
  
# Add (v2)
dependencies:
  flutter_chat_ui: ^2.9.0
  flutter_chat_core: ^2.8.0
```

### Import Changes

```dart
// Before (v1)
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

// After (v2)
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
```

## Model Changes

### User Model

**v1 (flutter_chat_types)**:
```dart
types.User(
  id: 'user_id',
  firstName: 'John',
  lastName: 'Doe',
  imageUrl: 'https://example.com/avatar.jpg',
  metadata: {'role': 'user'},
)
```

**v2 (flutter_chat_core)**:
```dart
core.User(
  id: 'user_id',
  name: 'John Doe',  // Combined name field
  imageSource: 'https://example.com/avatar.jpg',  // Renamed field
  metadata: {'role': 'user'},
)
```

### Message Model

**v1 Text Message**:
```dart
types.TextMessage(
  author: userObject,  // Full user object
  createdAt: DateTime.now().millisecondsSinceEpoch,  // Milliseconds
  id: const Uuid().v4(),
  text: 'Hello World',
)
```

**v2 Text Message**:
```dart
core.Message.text(
  authorId: 'user_id',  // Only user ID
  createdAt: DateTime.now(),  // DateTime object
  id: const Uuid().v4(),
  text: 'Hello World',
)
```

**v1 Image Message**:
```dart
types.ImageMessage(
  author: userObject,
  createdAt: timestamp,
  id: messageId,
  name: 'image.jpg',
  size: 1024,
  uri: 'https://example.com/image.jpg',
)
```

**v2 Image Message**:
```dart
core.Message.image(
  authorId: 'user_id',
  createdAt: DateTime.now(),
  id: messageId,
  name: 'image.jpg',
  size: 1024,
  uri: 'https://example.com/image.jpg',
)
```

**v1 Custom Message**:
```dart
types.CustomMessage(
  author: userObject,
  createdAt: timestamp,
  id: messageId,
  metadata: {
    'customType': 'vote_card',
    'votePostId': 'post_123',
  },
)
```

**v2 Custom Message**:
```dart
core.Message.custom(
  authorId: 'user_id',
  createdAt: DateTime.now(),
  id: messageId,
  metadata: {
    'customType': 'vote_card',
    'votePostId': 'post_123',
  },
)
```

### System Message (NEW in v2)

```dart
core.Message.system(
  id: 'system_message_id',
  text: '오늘',  // Date separator
  createdAt: DateTime.now(),
  authorId: 'system',  // Required in v2
)
```

## Widget Changes

### Chat Widget

**v1**:
```dart
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

Chat(
  messages: messages,
  onSendPressed: _handleSendPressed,
  user: currentUser,
  customMessageBuilder: (message, {messageWidth}) {
    return CustomMessageWidget(message);
  },
)
```

**v2**:
```dart
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

Chat(
  currentUserId: currentUser.id,  // Only ID needed
  resolveUser: _resolveUser,  // User resolution function
  chatController: _chatController,  // Controller required
  theme: _buildChatTheme(),  // Theme configuration
  timeFormat: DateFormat('HH:mm'),  // Custom time format
  onMessageSend: _handleSendPressed,  // Renamed callback
  builders: core.Builders(  // Builders wrapper
    customMessageBuilder: (context, message, index, {isSentByMe, groupStatus}) {
      return CustomMessageWidget(message);
    },
    systemMessageBuilder: (context, message, index, {groupStatus, isSentByMe}) {
      return SystemMessageWidget(message);
    },
  ),
)
```

### ChatController (NEW in v2)

```dart
class _ChatDetailState extends State<ChatDetailWidget> {
  late ChatController _chatController;
  
  @override
  void initState() {
    super.initState();
    _chatController = ChatController(
      client: StreamChatCore.of(context).client,
      channel: widget.channel,
    );
  }
  
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }
}
```

## Service Layer Changes

### Message Status Management

**New Service**: `ChatMessageLifecycleService`

```dart
// Mark messages as seen
await ChatMessageLifecycleService().markMessagesAsSeen(
  chatId: chatId,
  currentUserId: currentUser.id,
);

// Watch message statuses
final statusStream = ChatMessageLifecycleService().watchMessageStatuses(
  chatId: chatId,
);

// Status enum
enum MessageDeliveryStatus {
  sent,
  delivered,
  seen,
  unknown,
}
```

## Firebase Structure Changes

### Firestore Fields

**New fields in messages collection**:
```json
{
  "delivered_at": "Timestamp",  // NEW
  "seen_at": "Timestamp",       // NEW
  "sender_id": "user_id",        // Required for queries
}
```

### Required Indexes

Add to `firestore.indexes.json`:
```json
{
  "collectionGroup": "messages",
  "fields": [
    { "fieldPath": "sender_id", "order": "ASCENDING" },
    { "fieldPath": "seen_at", "order": "ASCENDING" }
  ]
}
```

## Step-by-Step Migration

### Step 1: Install Dependencies

```bash
flutter pub add flutter_chat_ui flutter_chat_core
flutter pub remove flutter_chat_types
```

### Step 2: Create V2 Widget

Create new file: `chat_detail_v2/chat_detail_widget_v2.dart`

### Step 3: Implement Migration Service

```dart
class ChatDetailMigrationService {
  static core.Message convertToV2Message(dynamic firestoreData) {
    // Convert Firestore data to v2 message
  }
  
  static Map<String, dynamic> convertToFirestore(core.Message message) {
    // Convert v2 message to Firestore format
  }
}
```

### Step 4: Update Navigation

```dart
// Old
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatDetailWidget(chat: chat),
  ),
);

// New
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatDetailWidgetV2(chatDocument: chat),
  ),
);
```

### Step 5: Test Thoroughly

1. Test message sending/receiving
2. Test media uploads
3. Test custom messages (vote cards)
4. Test message status updates
5. Test with different user accounts

### Step 6: Remove Old Code

Once v2 is stable:
1. Delete `chat_detail/` directory
2. Remove v1 imports
3. Remove compatibility layer
4. Update all references

## Common Issues and Solutions

### Issue 1: User Model Fields
**Problem**: `firstName` and `lastName` don't exist in v2
**Solution**: Combine into single `name` field

### Issue 2: Timestamp Format
**Problem**: v1 uses milliseconds, v2 uses DateTime
**Solution**: Use conversion functions
```dart
// v1 to v2
DateTime.fromMillisecondsSinceEpoch(v1Timestamp)

// v2 to v1
v2DateTime.millisecondsSinceEpoch
```

### Issue 3: Message Author
**Problem**: v1 uses full user object, v2 uses only ID
**Solution**: Implement `resolveUser` function
```dart
Future<core.User?> _resolveUser(String userId) async {
  // Fetch user from cache or Firestore
  return _usersCache[userId];
}
```

### Issue 4: Custom Message Builder Signature
**Problem**: Builder parameters changed
**Solution**: Update signature
```dart
// v1
Widget Function(CustomMessage, {int? messageWidth})

// v2
Widget Function(BuildContext, core.CustomMessage, int, {bool isSentByMe, MessageGroupStatus? groupStatus})
```

## Testing Checklist

- [ ] Text messages send and display correctly
- [ ] Image upload and display works
- [ ] Video messages function properly
- [ ] Custom messages (vote cards) render
- [ ] Message status (sent/delivered/seen) updates
- [ ] Date separators appear correctly
- [ ] Time format displays as expected
- [ ] User avatars and names show properly
- [ ] Scroll to message functionality works
- [ ] Search functionality (AI chat) works
- [ ] Message reactions (if implemented)
- [ ] Group chat (if applicable)
- [ ] Offline message queue (if implemented)
- [ ] Push notifications integration
- [ ] Performance with large message lists

## Performance Optimization

1. **Message Pagination**: Load 50 messages initially
2. **Image Caching**: Use `UnifiedImageCacheService`
3. **Stream Management**: Properly dispose subscriptions
4. **Batch Updates**: Use batch operations for Firestore

## Resources

- [Flutter Chat UI v2 Documentation](https://pub.dev/packages/flutter_chat_ui)
- [Flutter Chat Core Documentation](https://pub.dev/packages/flutter_chat_core)
- [Migration Status](lib/pages/chat/MIGRATION_STATUS.md)
- [Chat Architecture](lib/pages/chat/README.md)
- [Breaking Changes](BREAKING_CHANGES.md)

## Support

For migration issues or questions:
1. Check the [Breaking Changes](BREAKING_CHANGES.md) document
2. ~~Review the Compatibility Layer~~ (Removed - migration complete)
3. Consult the example implementations in `chat_detail_v2/`

## Next Steps

After completing the migration:
1. Monitor for any issues in production
2. Collect user feedback
3. Plan removal of compatibility layer
4. Update documentation
5. Train team on v2 API