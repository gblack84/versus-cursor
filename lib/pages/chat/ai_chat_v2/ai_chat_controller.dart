import 'dart:async';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

/// AI Chat Controller with Streaming Support
/// 
/// This controller manages the chat state for AI conversations,
/// including support for streaming messages using TextStreamMessage.
class AIChatController extends InMemoryChatController {
  
  // Gemini AI model instance
  GenerativeModel? _model;
  
  // Current streaming subscription
  StreamSubscription? _currentStreamSubscription;
  
  // Current streaming message ID
  String? _currentStreamMessageId;
  
  // User ID constants
  static const String aiUserId = 'ai_assistant';
  static const String aiUserName = 'AI 피클';
  
  /// Initialize the controller with optional initial messages
  AIChatController({List<Message>? messages}) : super(messages: messages);
  
  /// Initialize Gemini AI model
  void initializeAI(String apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        maxOutputTokens: 2048,
      ),
    );
  }
  
  /// Send a query to AI and receive streaming response
  Future<void> sendAIQuery({
    required String query,
    required String currentUserId,
  }) async {
    if (_model == null) {
      throw Exception('AI model not initialized. Call initializeAI first.');
    }
    
    // Cancel any existing stream
    await cancelStream();
    
    // Add user message
    final userMessage = Message.text(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: currentUserId,
      text: query,
      createdAt: DateTime.now(),
    );
    await insertMessage(userMessage);
    
    // Create streaming message placeholder
    _currentStreamMessageId = 'stream_${DateTime.now().millisecondsSinceEpoch}';
    final streamMessage = Message.textStream(
      id: _currentStreamMessageId!,
      authorId: aiUserId,
      streamId: 'stream_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    await insertMessage(streamMessage);
    
    // Start AI streaming
    try {
      final content = [Content.text(query)];
      final response = _model!.generateContentStream(content);
      
      String accumulatedText = '';
      
      _currentStreamSubscription = response.listen(
        (chunk) {
          if (chunk.text != null) {
            accumulatedText += chunk.text!;
            
            // Update the message with accumulated text
            updateMessage(
              streamMessage,
              Message.text(
                id: _currentStreamMessageId!,
                authorId: aiUserId,
                text: accumulatedText,
                createdAt: streamMessage.createdAt,
              ),
            );
          }
        },
        onDone: () {
          // Stream completed
          _currentStreamSubscription = null;
          _currentStreamMessageId = null;
          
          // Finalize the message as a regular text message
          if (accumulatedText.isNotEmpty) {
            updateMessage(
              streamMessage,
              Message.text(
                id: streamMessage.id,
                authorId: aiUserId,
                text: accumulatedText,
                createdAt: streamMessage.createdAt,
                sentAt: DateTime.now(),
              ),
            );
          }
        },
        onError: (error) {
          // Handle streaming error
          _currentStreamSubscription = null;
          _currentStreamMessageId = null;
          
          // Update message with error state
          updateMessage(
            streamMessage,
            Message.text(
              id: streamMessage.id,
              authorId: aiUserId,
              text: '오류가 발생했습니다: ${error.toString()}',
              createdAt: streamMessage.createdAt,
              failedAt: DateTime.now(),
            ),
          );
        },
      );
    } catch (e) {
      // Handle initialization error
      _currentStreamMessageId = null;
      
      // Add error message
      final errorMessage = Message.text(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: aiUserId,
        text: 'AI 응답 생성 중 오류가 발생했습니다: ${e.toString()}',
        createdAt: DateTime.now(),
        failedAt: DateTime.now(),
      );
      await insertMessage(errorMessage);
    }
  }
  
  /// Cancel the current streaming operation
  Future<void> cancelStream() async {
    if (_currentStreamSubscription != null) {
      await _currentStreamSubscription!.cancel();
      _currentStreamSubscription = null;
      
      // Mark the streaming message as cancelled
      if (_currentStreamMessageId != null) {
        final messages = this.messages;
        final streamMessage = messages.firstWhere(
          (msg) => msg.id == _currentStreamMessageId,
          orElse: () => Message.unsupported(
            id: _currentStreamMessageId!,
            authorId: aiUserId,
          ),
        );
        
        if (streamMessage is TextStreamMessage) {
          updateMessage(
            streamMessage,
            Message.text(
              id: streamMessage.id,
              authorId: aiUserId,
              text: '[스트리밍 취소됨]',
              createdAt: streamMessage.createdAt,
              failedAt: DateTime.now(),
            ),
          );
        }
      }
      
      _currentStreamMessageId = null;
    }
  }
  
  /// Check if streaming is currently active
  bool get isStreaming => _currentStreamSubscription != null;
  
  @override
  void dispose() {
    cancelStream();
    super.dispose();
  }
}