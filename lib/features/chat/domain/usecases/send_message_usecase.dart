import '/core/types/result.dart';
import '/core/errors/failures.dart';
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

  /// 메시지 전송
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [message]: 전송할 메시지 (Domain Entity - Message)
  ///
  /// **Returns**:
  /// - `Result<void>`: 성공 시 Success(void), 실패 시 ResultFailure
  ///
  /// **Clean Architecture v4.0**:
  /// - IChatRepository.sendMessage() 직접 호출
  /// - Pure Domain Entity (Message) 사용
  Future<Result<void>> execute({
    required String chatId,
    required Message message,
  }) async {
    try {
      // 입력 검증
      if (chatId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'Chat ID가 필요합니다.'),
        );
      }

      if (message.content.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: '메시지 내용이 비어있습니다.'),
        );
      }

      // 기존 Repository 메서드 호출
      await _chatRepository.sendMessage(chatId, message);

      return const Success(null);
    } catch (e) {
      return ResultFailure(
        ServerFailure(message: '메시지 전송 실패: ${e.toString()}'),
      );
    }
  }
}
