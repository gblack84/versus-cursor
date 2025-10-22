import '/core/types/result.dart';
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
/// stream.listen((result) {
///   result.when(
///     success: (messages) => print('받은 메시지: ${messages.length}개'),
///     failure: (error) => print('에러: $error'),
///   );
/// });
/// ```
class GetChatMessagesUseCase {
  final IChatRepository _chatRepository;

  GetChatMessagesUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 실시간 메시지 스트림 반환 (Clean Architecture v4.0)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [limit]: 한 번에 로드할 메시지 개수 (기본값: 30)
  ///
  /// **Returns**:
  /// - `Stream<Result<List<Message>>>`: 메시지 목록의 실시간 스트림
  ///
  /// **Architecture Flow**:
  /// ```
  /// UseCase → Repository.queryMessagesByChatId() → Firestore
  /// ```
  /// - UseCase는 Firestore를 모름 (chatId만 전달)
  /// - Repository에서만 Firestore DocumentReference 생성
  /// - Pure Domain Entity (Message) 반환
  Stream<Result<List<Message>>> execute({
    required String chatId,
    int limit = 30,
  }) {
    try {
      // 입력 검증
      if (chatId.isEmpty) {
        return Stream.value(
          const ResultFailure(
            InvalidMessageContent(),
          ),
        );
      }

      // Clean Architecture v4.0: chatId만 전달, Repository에서 Firestore 처리
      final messagesStream = _chatRepository.queryMessagesByChatId(
        chatId: chatId,
        limit: limit,
        orderBy: 'timeStamp',
        descending: false,
      );

      // Stream<List<Message>>을 Result로 감싸서 반환
      return messagesStream.map((messages) => Success(messages));
    } catch (e) {
      return Stream.value(
        const ResultFailure(
          MessageLoadFailed(),
        ),
      );
    }
  }
}
