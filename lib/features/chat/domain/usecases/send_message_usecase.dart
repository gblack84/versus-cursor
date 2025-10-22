import 'dart:io';

import '/core/types/result.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/message.dart';

/// 새 메시지를 전송하는 UseCase
///
/// **Clean Architecture v4.0**:
/// - IChatRepository.sendMessage() 직접 호출
/// - 순수 Domain Entity (Message) 사용 (Firestore 의존성 완전 제거)
///
/// **사용 예시**:
/// ```dart
/// final useCase = SendMessageUseCase(chatRepository: repository);
/// final result = await useCase.execute(
///   chatId: 'chat123',
///   message: MessagesModel(text: 'Hello', userId: 'user123'),
/// );
///
/// result.fold(
///   (failure) => print('전송 실패: ${failure.message}'),
///   (success) => print('전송 성공!'),
/// );
/// ```
class SendMessageUseCase {
  final IChatRepository _chatRepository;

  SendMessageUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 메시지 전송 (미디어 업로드 포함)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [message]: 전송할 메시지 (Domain Entity - Message)
  /// - [mediaFile]: 첨부할 미디어 파일 (optional - 이미지 또는 비디오)
  ///
  /// **Returns**:
  /// - `Result<void>`: 성공 시 Success(void), 실패 시 ResultFailure
  ///
  /// **Clean Architecture v4.0**:
  /// - IChatRepository.uploadMedia() + sendMessage() 호출
  /// - Pure Domain Entity (Message) 사용
  /// - 미디어 파일이 있으면 먼저 업로드 후 URL을 Message에 추가
  Future<Result<void>> execute({
    required String chatId,
    required Message message,
    File? mediaFile,
  }) async {
    try {
      // 입력 검증
      if (chatId.isEmpty) {
        return const ResultFailure(
          InvalidMessageContent(),
        );
      }

      // 텍스트 메시지는 content 필수, 미디어 메시지는 mediaFile 필수
      if (message.content.isEmpty && mediaFile == null) {
        return const ResultFailure(
          InvalidMessageContent(),
        );
      }

      Message finalMessage = message;

      // 미디어 파일이 있으면 먼저 업로드
      if (mediaFile != null) {
        try {
          final mediaUrl = await _chatRepository.uploadMedia(
            chatId: chatId,
            messageId: message.id,
            file: mediaFile,
            mediaType: message.mediaType,
          );

          // 업로드된 URL을 Message에 추가
          if (message.mediaType == 'image') {
            finalMessage = message.copyWith(imageUrl: mediaUrl);
          } else if (message.mediaType == 'video') {
            finalMessage = message.copyWith(videoUrl: mediaUrl);
          }
        } catch (e) {
          return const ResultFailure(
            MessageSendFailed(),
          );
        }
      }

      // 메시지 전송
      await _chatRepository.sendMessage(chatId, finalMessage);

      return const Success(null);
    } catch (e) {
      return const ResultFailure(
        MessageSendFailed(),
      );
    }
  }
}
