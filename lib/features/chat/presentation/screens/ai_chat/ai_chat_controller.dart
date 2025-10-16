import 'package:flutter_chat_core/flutter_chat_core.dart';

import '/core/constants/app_constants.dart';

/// AI Chat Controller - Clean Architecture v4.0
///
/// **책임**: AI 채팅방의 UI State 관리만 담당
/// **변경사항** (Clean Architecture 준수):
/// - ❌ Gemini API 초기화 로직 제거 → GeminiAIService로 이동
/// - ❌ API 스트리밍 로직 제거 → SendAIQueryUseCase로 이동
/// - ✅ UI State 관리 로직만 유지 (InMemoryChatController)
///
/// **사용 예시**:
/// ```dart
/// final controller = AIChatController();
/// await controller.addUserMessage('Hello AI', currentUserId);
/// await controller.addAIStreamingPlaceholder();
/// controller.updateStreamingMessage('AI response chunk');
/// ```
class AIChatController extends InMemoryChatController {
  // Current streaming message tracking
  String? _currentStreamMessageId;

  /// Initialize the controller with optional initial messages
  AIChatController({List<Message>? messages}) : super(messages: messages);

  /// Add user message to chat
  ///
  /// **Pure UI State Management** - Infrastructure 로직 없음
  Future<void> addUserMessage(String text, String currentUserId) async {
    final userMessage = Message.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: currentUserId,
      text: text,
      createdAt: DateTime.now(),
    );
    await insertMessage(userMessage);
  }

  /// Create AI streaming message placeholder
  ///
  /// **Returns**: Message ID for streaming updates
  Future<String> addAIStreamingPlaceholder() async {
    _currentStreamMessageId = 'stream_${DateTime.now().millisecondsSinceEpoch}';
    final streamMessage = Message.textStream(
      id: _currentStreamMessageId!,
      authorId: AppConstants.aiUserId,
      streamId: 'stream_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    await insertMessage(streamMessage);
    return _currentStreamMessageId!;
  }

  /// Update streaming message with accumulated text
  ///
  /// **Pure UI Update** - 외부 API 호출 없음
  void updateStreamingMessage(String messageId, String accumulatedText) {
    final messages = this.messages;
    final streamMessage = messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => Message.unsupported(id: messageId, authorId: AppConstants.aiUserId),
    );

    updateMessage(
      streamMessage,
      Message.text(
        id: messageId,
        authorId: AppConstants.aiUserId,
        text: accumulatedText,
        createdAt: streamMessage.createdAt,
      ),
    );
  }

  /// Finalize streaming message
  void finalizeStreamingMessage(String messageId, String finalText) {
    final messages = this.messages;
    final streamMessage = messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => Message.unsupported(id: messageId, authorId: AppConstants.aiUserId),
    );

    updateMessage(
      streamMessage,
      Message.text(
        id: messageId,
        authorId: AppConstants.aiUserId,
        text: finalText,
        createdAt: streamMessage.createdAt,
        sentAt: DateTime.now(),
      ),
    );

    _currentStreamMessageId = null;
  }

  /// Mark streaming message as failed
  void markStreamingMessageFailed(String messageId, String errorText) {
    final messages = this.messages;
    final streamMessage = messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => Message.unsupported(id: messageId, authorId: AppConstants.aiUserId),
    );

    updateMessage(
      streamMessage,
      Message.text(
        id: messageId,
        authorId: AppConstants.aiUserId,
        text: errorText,
        createdAt: streamMessage.createdAt,
        failedAt: DateTime.now(),
      ),
    );

    _currentStreamMessageId = null;
  }

  /// Get current streaming message ID
  String? get currentStreamMessageId => _currentStreamMessageId;

  /// Clear streaming message ID
  void clearStreamMessageId() {
    _currentStreamMessageId = null;
  }
}
