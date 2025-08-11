# Breaking Changes - Chat System v2 Migration

## Version: 2.0.0 (2025-08-10)

이 문서는 flutter_chat_ui v1에서 v2로 마이그레이션하면서 발생한 주요 변경사항을 설명합니다.

## 🚨 Critical Breaking Changes

### 1. Widget Removal

#### ❌ REMOVED: ChatDetailWidget
- **Location**: `lib/pages/chat/chat_detail/`
- **Replacement**: `ChatDetailWidgetV2`
- **Import Change**:
  ```dart
  // ❌ OLD
  import '/pages/chat/chat_detail/chat_detail_widget.dart';
  
  // ✅ NEW
  import '/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart';
  ```

#### ❌ REMOVED: Original AIChatPage
- **Replacement**: `AIChatPageV2`
- **Location**: `lib/pages/chat/ai_chat_v2/`

### 2. Package Dependencies

#### ❌ REMOVED: flutter_chat_types
```yaml
# pubspec.yaml
# ❌ REMOVED
flutter_chat_types: ^3.6.2
```

#### ✅ ADDED: New Packages
```yaml
# pubspec.yaml
# ✅ ADDED
flutter_chat_ui: ^2.9.0
flutter_chat_core: ^2.8.0
```

### 3. Model Changes

#### User Model
| Field | v1 (flutter_chat_types) | v2 (flutter_chat_core) | 
|-------|-------------------------|------------------------|
| Name | `firstName`, `lastName` | `name` (combined) |
| Avatar | `imageUrl` | `imageSource` |
| Required | Full object in messages | Only `id` in messages |

#### Message Model
| Aspect | v1 | v2 |
|--------|----|----|
| Author | Full `User` object | Only `authorId` string |
| Timestamp | Milliseconds (int) | `DateTime` object |
| Factory | Constructor | Static factory methods |
| System Message | Not supported | Supported with `authorId` |

### 4. API Changes

#### Chat Widget Props
```dart
// ❌ OLD
Chat(
  messages: messages,
  onSendPressed: callback,
  user: currentUser,
  customMessageBuilder: (message, {messageWidth}) => widget,
)

// ✅ NEW
Chat(
  currentUserId: currentUser.id,
  resolveUser: _resolveUser,
  chatController: _chatController,
  theme: _buildChatTheme(),
  timeFormat: DateFormat('HH:mm'),
  onMessageSend: callback,  // Renamed
  builders: core.Builders(  // Wrapped in Builders
    customMessageBuilder: (context, message, index, {isSentByMe, groupStatus}) => widget,
    systemMessageBuilder: (context, message, index, {groupStatus, isSentByMe}) => widget,
  ),
)
```

#### Builder Signatures
```dart
// ❌ OLD - customMessageBuilder
Widget Function(CustomMessage, {int? messageWidth})

// ✅ NEW - customMessageBuilder
Widget Function(
  BuildContext context,
  core.CustomMessage message,
  int index,
  {bool isSentByMe, MessageGroupStatus? groupStatus}
)
```

### 5. Firestore Schema Changes

#### Messages Collection
**New Required Fields**:
```json
{
  "sender_id": "string",     // NEW - Required for queries
  "delivered_at": "Timestamp", // NEW - Optional
  "seen_at": "Timestamp"      // NEW - Optional
}
```

#### New Indexes Required
```json
// firestore.indexes.json
{
  "collectionGroup": "messages",
  "fields": [
    { "fieldPath": "sender_id", "order": "ASCENDING" },
    { "fieldPath": "seen_at", "order": "ASCENDING" }
  ]
}
```

### 6. Service Layer Changes

#### ❌ REMOVED: MessageAdapter
- **File**: `lib/utils/chat_message_converter.dart`
- **Replacement**: `ChatDetailMigrationService`

#### ✅ ADDED: ChatMessageLifecycleService
- **Location**: `lib/pages/chat/services/`
- **Purpose**: Message status management
- **New Features**:
  - Real-time read receipts
  - Message delivery status
  - Batch updates

### 7. Firebase Functions

#### ✅ NEW Functions
1. **markMessagesAsSeen** (HTTP)
   - Endpoint: `/markMessagesAsSeen`
   - Purpose: Batch mark messages as read

2. **onMessageCreated** (Firestore Trigger)
   - Path: `chats/{chatId}/messages/{messageId}`
   - Purpose: Process new messages

## 🔄 Migration Required

### Navigation Updates
```dart
// ❌ OLD
context.push('/chat-detail', extra: chatModel);

// ✅ NEW
context.push('/chat-detail-v2', extra: chatModel);
```

### Route Registration
```dart
// routes.dart or nav.dart
// ❌ OLD
GoRoute(
  name: 'chat-detail',
  path: '/chat-detail',
  builder: (context, state) => ChatDetailWidget(
    chatDocument: state.extra as ChatsModel,
  ),
),

// ✅ NEW
GoRoute(
  name: 'chat-detail-v2',
  path: '/chat-detail-v2',
  builder: (context, state) => ChatDetailWidgetV2(
    chatDocument: state.extra as ChatsModel,
  ),
),
```

### Import Updates
Search and replace all imports:
```dart
// Find all occurrences of:
import '/pages/chat/chat_detail/chat_detail_widget.dart';

// Replace with:
import '/pages/chat/chat_detail_v2/chat_detail_widget_v2.dart';
```

## ⚠️ Deprecated (Will be removed)

### Compatibility Layer (Removed)
- **Previous Location**: `lib/compat/v1/`
- **Status**: ✅ Removed (2025-08-11)
- **Reason**: Migration 100% complete, no longer needed

### Legacy Patterns
1. Using `types.User` in new code
2. Millisecond timestamps for messages
3. Full user objects in messages
4. Manual message status tracking

## 🔧 Action Required

### Immediate Actions
1. ✅ Update all ChatDetailWidget references to ChatDetailWidgetV2
2. ✅ Update navigation routes
3. ✅ Deploy new Firebase Functions
4. ✅ Update Firestore indexes

### Before Next Release
1. Test all chat functionality thoroughly
2. Monitor for any performance issues
3. Update user documentation
4. Train support team on changes

### Future Cleanup (2025-11)
1. ~~Remove compatibility layer~~ ✅ Removed (2025-08-11)
2. Remove flutter_chat_types from pubspec.yaml
3. Clean up any remaining v1 references
4. Archive migration documentation

## 📊 Impact Assessment

### High Impact Areas
- **Chat Detail Pages**: Complete rewrite required
- **Message Models**: All message creation code needs update
- **Navigation**: All chat navigation needs update

### Medium Impact Areas
- **Chat List**: Minor updates for navigation
- **Firebase Functions**: New functions to deploy
- **Firestore Indexes**: New indexes to create

### Low Impact Areas
- **Other Features**: No direct impact
- **UI Components**: Minimal changes needed
- **Business Logic**: Mostly unchanged

## 🆘 Troubleshooting

### Common Issues

#### Issue: Messages not displaying
**Cause**: User model mismatch
**Solution**: Ensure `resolveUser` function is implemented

#### Issue: Read status not working
**Cause**: Missing Firestore indexes
**Solution**: Deploy new indexes from firestore.indexes.json

#### Issue: Custom messages broken
**Cause**: Builder signature changed
**Solution**: Update builder parameters

#### Issue: Time showing date
**Cause**: Default timeFormat includes date
**Solution**: Set `timeFormat: DateFormat('HH:mm')`

## 📚 Resources

- [Migration Guide](MIGRATION_GUIDE.md)
- [Chat Architecture](lib/pages/chat/README.md)
- ~~Compatibility Layer~~ (Removed - migration complete)
- [Firebase Functions](firebase/functions/README.md)

## 📞 Support

For urgent issues related to these breaking changes:
1. Check this document first
2. Review the Migration Guide
3. Test in development environment
4. Contact team lead if blocked

---

**Last Updated**: 2025-08-10
**Version**: 2.0.0
**Status**: Active Migration