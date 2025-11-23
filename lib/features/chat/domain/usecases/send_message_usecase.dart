import 'dart:io';

import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/message.dart';

/// Send message UseCase (Simplified - No IdempotencyService)
///
/// **Clean Architecture v4.0 - Deterministic ID Pattern**:
/// - Idempotency via message.id (client-generated UUID)
/// - UseCase simplified to business logic only
/// - Media upload before message send
/// - Pure Domain Entity (Message) usage
///
/// **Migration from Phase 4**:
/// - Removed: IdempotencyService completely
/// - Removed: eventId parameter (redundant with message.id)
/// - Firestore set() provides natural idempotency
///
/// **Usage**:
/// ```dart
/// final useCase = SendMessageUseCase(chatRepository: repository);
/// final result = await useCase.execute(
///   chatId: 'chat123',
///   message: Message(text: 'Hello', senderId: 'user123', id: 'client-uuid'),
///   mediaFile: File('path/to/image.jpg'), // optional
/// );
///
/// result.fold(
///   (failure) => ChatLogger.messageError(errorType: 'sendFailed', message: failure.message),
///   (_) => ChatLogger.messageSent(messageId: 'message_id'),
/// );
/// ```
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Send message with optional media upload (Simplified - No IdempotencyService)
  ///
  /// **Parameters**:
  /// - [chatId]: Chat room ID
  /// - [message]: Message entity with client-generated UUID (message.id provides idempotency)
  /// - [mediaFile]: Optional media file (image or video)
  ///
  /// **Returns**:
  /// - `Either<ChatFailure, Unit>`: Success or failure
  ///
  /// **Changes**:
  /// - Removed: IdempotencyService completely
  /// - Removed: eventId parameter (message.id is sufficient)
  /// - UseCase handles: validation → media upload → repository call
  /// - Repository handles: Transaction + Cache + Firestore native idempotency
  ///
  /// **Business Logic**:
  /// 1. Validate input (chatId, content/media required)
  /// 2. Upload media if present
  /// 3. Send message via repository
  Future<Either<ChatFailure, Unit>> execute({
    required String chatId,
    required Message message,
    File? mediaFile,
  }) async {
    DevLogger.params({
      'chatId': chatId,
      'messageId': message.id,
      'hasMedia': mediaFile != null,
      'mediaType': message.mediaType,
    }, tag: 'SendMessage');

    try {
      // 1. Input validation
      if (chatId.isEmpty) {
        DevLogger.validation(
          field: 'chatId',
          reason: 'Chat ID cannot be empty',
          tag: 'SendMessage',
        );
        return left(const InvalidMessageContent());
      }

      // Text message requires content, media message requires file
      if (message.content.isEmpty && mediaFile == null) {
        DevLogger.validation(
          field: 'content/media',
          reason: 'Either text or media is required',
          tag: 'SendMessage',
        );
        return left(const InvalidMessageContent());
      }

      Message finalMessage = message;

      // 2. Upload media if present
      if (mediaFile != null) {
        DevLogger.checkpoint('Uploading media file', tag: 'SendMessage');
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

          DevLogger.checkpoint(
            'Media uploaded: $mediaUrl',
            tag: 'SendMessage',
          );
        } catch (e) {
          DevLogger.error(
            'Media upload failed',
            error: e,
            tag: 'SendMessage',
          );
          return left(const MessageSendFailed());
        }
      }

      // 3. Send message (Repository handles idempotency + transaction + cache)
      DevLogger.checkpoint('Sending message to repository', tag: 'SendMessage');
      final result = await _chatRepository.sendMessage(
        chatId: chatId,
        message: finalMessage,
      );

      result.fold(
        (failure) {
          DevLogger.error(
            'Message send failed',
            error: failure,
            tag: 'SendMessage',
          );
        },
        (_) {
          DevLogger.result(
            isSuccess: true,
            data: 'Message sent (messageId: ${message.id})',
            tag: 'SendMessage',
          );
        },
      );

      return result;
    } catch (e, stackTrace) {
      DevLogger.error(
        'Unexpected error in SendMessage',
        error: e,
        stackTrace: stackTrace,
        tag: 'SendMessage',
      );
      return left(const MessageSendFailed());
    }
  }
}
