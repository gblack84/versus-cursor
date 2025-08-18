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

#### 🆕 AI 채팅방 검색 UI 개선 (2025-08-14)
- **검색창 위치 변경**: 상단 → 하단 (카카오톡 스타일)
  - 채팅 화면 하단에 고정 배치
  - MediaQuery.padding.bottom으로 안전 영역 확보
- **메시지 입력창 숨기기**: 
  - AI 채팅방에서 `composerBuilder: (context) => SizedBox.shrink()` 사용
  - 검색 전용 UI 구현
- **검색창 UI 개선**:
  - `textAlignVertical: TextAlignVertical.center` - 텍스트 수직 중앙 정렬
  - `InputDecoration.collapsed()` - 불필요한 패딩 제거
  - 검색 아이콘과 텍스트 간 8px 패딩
  - 44px 고정 높이의 둥근 검색창
- **입력 제한 설정**:
  - `maxLength: 20` - 최대 20자 제한
  - `autocorrect: false` - 자동수정 비활성화
  - `enableSuggestions: false` - 제안 비활성화
  - `textInputAction: TextInputAction.search` - 키보드에 검색 버튼
  - `trim()` 처리로 앞뒤 공백 자동 제거

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

## Recent Updates

### 2025-08-18: VoteStateCoordinator 통합
- **VoteCardMessage 리팩토링**:
  - BaseVoteMessageStateMixin에서 레거시 타이머 코드 제거 (265줄)
  - VoteStateCoordinator로 투표 상태 관리 일원화
  - StreamBuilder를 통한 실시간 투표 상태 업데이트
  - 메모리 사용량 감소 (타이머 인스턴스 N개 → 1개)

- **성능 개선**:
  - 투표 카드별 독립 타이머 → 중앙 집중식 타이머 관리
  - 중복 상태 관리 코드 제거
  - 실시간 Firestore 리스너 통합

### 2025-08-14: AI 채팅방 검색 UI 개선
- 검색창 위치 변경 (상단 → 하단)
- 메시지 입력창 숨김 처리
- 검색창 디자인 개선
- 입력 제한 설정 (20자 제한, 자동수정 비활성화)

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