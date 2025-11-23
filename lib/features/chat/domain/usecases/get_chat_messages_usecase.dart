import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/message.dart';

/// 채팅 메시지를 실시간 스트림으로 가져오는 UseCase
///
/// **Clean Architecture v4.0**:
/// - IChatRepository.queryMessagesByChatId() 메서드 사용
/// - 순수 Domain Entity (Message) 사용 (Firestore 의존성 완전 제거)
///
/// **사용 예시**:
/// ```dart
/// final useCase = GetChatMessagesUseCase(chatRepository: repository);
/// final stream = useCase.execute(chatId: 'chat123', limit: 30);
///
/// stream.listen((either) {
///   either.fold(
///     (failure) => ChatLogger.messageError(errorType: 'receiveFailed', error: failure),
///     (messages) => ChatLogger.messagesReceived(count: messages.length, chatId: 'chat123'),
///   );
/// });
/// ```
class GetChatMessagesUseCase {
  final IChatRepository _chatRepository;

  GetChatMessagesUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 실시간 메시지 스트림 반환 (PHASE 1: Either Pattern 완료)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [limit]: 한 번에 로드할 메시지 개수 (기본값: 30)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Message>>>`: 메시지 목록의 실시간 스트림
  ///
  /// **PHASE 1 Complete - Passthrough Pattern**:
  /// 1. Repository부터 Either 반환 (캐시/네트워크 에러 처리)
  /// 2. UseCase는 입력 검증만 수행 후 패스스루
  /// 3. 불필요한 .map() 변환 제거 (코드 단순화)
  /// 4. Repository 에러가 그대로 전달됨
  ///
  /// **Clean Architecture v4.0**:
  /// - Firestore 의존성 완전 제거
  /// - 순수 Domain Entity 사용
  /// - Either 패턴으로 타입 안전한 에러 처리
  Stream<Either<ChatFailure, List<Message>>> execute({
    required String chatId,
    int limit = 30,
  }) async* {
    DevLogger.params({'chatId': chatId, 'limit': limit}, tag: 'GetChatMessages');
    DevLogger.checkpoint('Starting chat messages stream', tag: 'GetChatMessages');

    // ✅ 입력 검증
    if (chatId.isEmpty) {
      DevLogger.validation(
        field: 'chatId',
        reason: 'Chat ID cannot be empty',
        tag: 'GetChatMessages',
      );
      yield left(const InvalidMessageContent());
      return;
    }

    DevLogger.checkpoint('Querying repository for chat messages', tag: 'GetChatMessages');

    // ✅ Repository에서 이미 Either 반환하므로 그대로 전달 (패스스루)
    await for (final either in _chatRepository.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: 'timeStamp',
      descending: false,
    )) {
      either.fold(
        (failure) {
          DevLogger.error(
            'Chat messages stream error',
            error: failure,
            tag: 'GetChatMessages',
          );
        },
        (messages) {
          DevLogger.result(
            isSuccess: true,
            data: '${messages.length} messages emitted',
            tag: 'GetChatMessages',
          );
        },
      );
      yield either; // 패스스루: Repository → UseCase → Provider
    }

    DevLogger.checkpoint('Chat messages stream ended', tag: 'GetChatMessages');
  }
}
