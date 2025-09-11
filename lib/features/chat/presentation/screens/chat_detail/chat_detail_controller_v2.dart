import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

/// Chat Detail Controller for v2
///
/// Extends InMemoryChatController which already includes ScrollToMessageMixin
class ChatDetailControllerV2 extends core.InMemoryChatController {
  // Pagination callback
  Function()? onReachTop;

  ChatDetailControllerV2() : super();

  /// Load initial messages
  void loadInitialMessages(List<core.Message> messages) {
    setMessages(messages);
  }

  /// Update a message (override parent method)
  @override
  Future<void> updateMessage(
      core.Message oldMessage, core.Message newMessage) async {
    final currentMessages = messages.toList();
    final index = currentMessages.indexWhere((m) => m.id == oldMessage.id);
    if (index != -1) {
      currentMessages[index] = newMessage;
      setMessages(currentMessages);
    }
  }

  /// Remove a message (override parent method)
  @override
  Future<void> removeMessage(core.Message message,
      {bool animated = true}) async {
    final currentMessages = messages.toList();
    currentMessages.removeWhere((m) => m.id == message.id);
    setMessages(currentMessages);
  }

  /// Search for messages containing query
  List<core.Message> searchMessages(String query) {
    if (query.isEmpty) return [];

    final lowerQuery = query.toLowerCase();
    return messages.where((message) {
      // Search in text messages
      if (message is core.TextMessage) {
        return message.text.toLowerCase().contains(lowerQuery);
      }

      // Search in custom messages metadata
      if (message is core.CustomMessage) {
        final metadata = message.metadata ?? {};
        final title = metadata['title']?.toString().toLowerCase() ?? '';
        final description =
            metadata['description']?.toString().toLowerCase() ?? '';
        final optionA = metadata['optionAText']?.toString().toLowerCase() ?? '';
        final optionB = metadata['optionBText']?.toString().toLowerCase() ?? '';

        return title.contains(lowerQuery) ||
            description.contains(lowerQuery) ||
            optionA.contains(lowerQuery) ||
            optionB.contains(lowerQuery);
      }

      return false;
    }).toList();
  }

  // scrollToMessage is already provided by ScrollToMessageMixin
  // No need to override it
}
