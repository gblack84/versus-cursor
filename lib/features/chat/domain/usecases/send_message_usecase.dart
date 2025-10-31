import 'dart:io';

import 'package:dartz/dartz.dart';

import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/message.dart';

/// Send message UseCase (PHASE 4: Simplified)
///
/// **Clean Architecture v4.0 - Repository-Level Idempotency**:
/// - IdempotencyService moved to Repository layer
/// - UseCase simplified to business logic only
/// - Media upload before message send
/// - Pure Domain Entity (Message) usage
///
/// **Migration from v3.0**:
/// - Removed: IdempotencyService dependency (now in Repository)
/// - Removed: Transaction handling (now in Repository)
/// - Added: Media upload support
///
/// **Usage**:
/// ```dart
/// final useCase = SendMessageUseCase(chatRepository: repository);
/// final result = await useCase.execute(
///   chatId: 'chat123',
///   message: Message(text: 'Hello', senderId: 'user123'),
///   eventId: 'uuid-v4-generated-by-client',
///   mediaFile: File('path/to/image.jpg'), // optional
/// );
///
/// result.fold(
///   (failure) => print('Failed: ${failure.message}'),
///   (_) => print('Success!'),
/// );
/// ```
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Send message with optional media upload (PHASE 4: Simplified)
  ///
  /// **Parameters**:
  /// - [chatId]: Chat room ID
  /// - [message]: Message entity to send
  /// - [eventId]: UUID v4 (client-generated, for idempotency)
  /// - [mediaFile]: Optional media file (image or video)
  ///
  /// **Returns**:
  /// - `Either<ChatFailure, Unit>`: Success or failure
  ///
  /// **PHASE 4 Changes**:
  /// - IdempotencyService now in Repository layer
  /// - UseCase only handles: validation → media upload → repository call
  /// - Repository handles: Transaction + Idempotency + Cache
  ///
  /// **Business Logic**:
  /// 1. Validate input (chatId, content/media required)
  /// 2. Upload media if present
  /// 3. Send message via repository
  Future<Either<ChatFailure, Unit>> execute({
    required String chatId,
    required Message message,
    required String eventId,
    File? mediaFile,
  }) async {
    try {
      // 1. Input validation
      if (chatId.isEmpty) {
        return left(const InvalidMessageContent());
      }

      // Text message requires content, media message requires file
      if (message.content.isEmpty && mediaFile == null) {
        return left(const InvalidMessageContent());
      }

      Message finalMessage = message;

      // 2. Upload media if present
      if (mediaFile != null) {
        try {
          final mediaUrl = await _chatRepository.uploadMedia(
            chatId: chatId,
            messageId: message.id,
            file: mediaFile,
            mediaType: message.mediaType,
          );

          // Add uploaded URL to message
          if (message.mediaType == 'image') {
            finalMessage = message.copyWith(imageUrl: mediaUrl);
          } else if (message.mediaType == 'video') {
            finalMessage = message.copyWith(videoUrl: mediaUrl);
          }
        } catch (e) {
          return left(const MessageSendFailed());
        }
      }

      // 3. Send message (Repository handles idempotency + transaction + cache)
      return await _chatRepository.sendMessage(
        chatId: chatId,
        message: finalMessage,
        eventId: eventId,
      );
    } catch (e) {
      return left(const MessageSendFailed());
    }
  }
}
