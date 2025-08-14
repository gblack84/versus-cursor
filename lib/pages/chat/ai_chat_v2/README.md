# AI Chat v2 - 미래 AI 어시스턴트 기능

## ⚠️ 현재 상태: 미사용

**이 컴포넌트는 현재 사용되지 않습니다!**
- 라우팅에 등록되지 않음
- 향후 AI 어시스턴트 기능용으로 준비됨
- ChatDetailWidgetV2와 다른 용도

## 🎯 계획된 용도

**AIChatPageV2**는 미래에 **AI 어시스턴트와의 대화**를 위한 전용 페이지입니다.

### 계획된 기능:
1. 📱 **앱 사용법 안내**: AI가 앱 기능 설명
2. ⚙️ **설정 도움말**: 사용자 설정 가이드
3. 💬 **일반 대화**: ChatGPT 스타일 실시간 대화
4. 🎓 **학습 기능**: 사용자 패턴 학습 및 추천

## Overview

This is the future AI assistant implementation using flutter_chat_ui v2.9.0 with flutter_chat_core. It provides:

- ✅ **AI Streaming Support**: Real-time streaming of AI responses using TextStreamMessage
- ✅ **ScrollToMessage**: Native support for scrolling to specific messages
- ✅ **Message Adapter**: Bridge between flutter_chat_types and flutter_chat_core
- ✅ **VoteCardMessage Compatibility**: Existing custom messages continue to work

## Phase 1 Status (Completed)

### Files Created:
1. `ai_chat_controller.dart` - ChatController with streaming support
2. `message_adapter.dart` - Converts between message types  
3. `ai_chat_page_v2.dart` - New AI chat page implementation

### Key Features Implemented:
- Gemini AI integration with streaming
- Message type conversion (types ↔ core)
- Custom message rendering (VoteCardMessage)
- Search functionality
- User resolution system

## Usage (Future - 현재 미사용)

향후 AI 어시스턴트 기능이 활성화되면:

```dart
// 현재는 사용하지 않음!
// 향후 활성화 시:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => AIChatPageV2(
      aiChatId: 'unique_chat_id',
    ),
  ),
);
```

## Configuration

### API Key Setup
The Gemini API key needs to be configured. Update line 52 in `ai_chat_controller.dart`:

```dart
// TODO: Get API key from environment or Firebase Remote Config
_chatController.initializeAI('YOUR_GEMINI_API_KEY');
```

## Next Steps (Phase 2-3)

### Phase 2: General Chat Migration
- Migrate `ChatDetailWidget` to use v2
- Implement full message loading from Firestore
- Add attachment support

### Phase 3: Complete Integration
- Remove flutter_chat_types dependency
- Clean up legacy code
- Performance optimization

## Architecture

```
flutter_chat_ui v2.9.0
         ↓
flutter_chat_core (Message system)
         ↓
MessageAdapter (Conversion layer)
         ↓
flutter_chat_types (Legacy compatibility)
         ↓
VoteCardMessage (Existing custom messages)
```

## Testing

The current implementation can be tested by:
1. Running `flutter pub get` to install dependencies
2. Adding a navigation route to `AIChatPageV2`
3. Configuring the Gemini API key

## ⚠️ 주의사항

**이 컴포넌트는 ChatDetailWidgetV2와 완전히 다른 용도입니다:**
- **ChatDetailWidgetV2**: 현재 모든 채팅 처리 (투표 카드 포함)
- **AIChatPageV2**: 미래 AI 어시스턴트 전용 (아직 미사용)

## Known Issues

- 현재 라우팅에 등록되지 않음 (의도적)
- API key configuration needs to be moved to environment variables
- Message persistence to Firestore not yet implemented
- Attachment handling not implemented

## Migration Benefits

- **AI Streaming**: Real-time AI responses like ChatGPT
- **Better Performance**: Stream-based updates
- **Native Scroll Control**: ScrollToMessageMixin support
- **Future Proof**: Compatible with latest flutter_chat_ui updates