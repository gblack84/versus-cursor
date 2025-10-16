import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/message.dart';

/// 페이지네이션으로 이전 메시지를 추가 로드하는 UseCase
///
/// **Clean Architecture v4.0**:
/// - chat_detail_widget_v2.dart의 _loadMoreMessages() 로직을 UseCase로 이동
/// - IChatRepository.queryMessagesBeforeMessageId() 사용
/// - 순수 Domain Entity (Message) 사용 (Firestore 의존성 완전 제거)
///
/// **사용 예시**:
/// ```dart
/// final useCase = LoadMoreMessagesUseCase(chatRepository: repository);
/// final result = await useCase.execute(
///   chatId: 'chat123',
///   lastDocument: previousMessages.last.reference,
///   limit: 30,
/// );
///
/// result.when(
///   success: (olderMessages) => print('${olderMessages.length}개 추가 로드'),
///   failure: (error) => print('로드 실패: $error'),
/// );
/// ```
class LoadMoreMessagesUseCase {
  final IChatRepository _chatRepository;

  LoadMoreMessagesUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 이전 메시지 추가 로드 (Clean Architecture v4.0)
  ///
  /// **Parameters**:
  /// - [chatId]: 채팅방 ID
  /// - [lastMessageId]: 현재 로드된 가장 오래된 메시지의 ID
  /// - [limit]: 추가로 로드할 메시지 개수 (기본값: 30)
  ///
  /// **Returns**:
  /// - `Result<List<Message>>`: 성공 시 이전 메시지 목록, 실패 시 에러 메시지
  ///
  /// **Architecture Flow**:
  /// ```
  /// UseCase → Repository.queryMessagesBeforeMessageId() → Firestore
  /// ```
  /// - UseCase는 Firestore를 모름 (chatId와 messageId만 전달)
  /// - Repository에서만 DocumentSnapshot 처리
  /// - Pure Domain Entity (Message) 반환
  ///
  /// **주의사항**:
  /// - 더 이상 로드할 메시지가 없으면 빈 리스트 반환
  /// - 빈 리스트를 Provider에서 감지하여 hasMore = false 처리
  Future<Result<List<Message>>> execute({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    try {
      // 입력 검증
      if (chatId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'Chat ID는 비어있을 수 없습니다.'),
        );
      }

      if (lastMessageId.isEmpty) {
        return ResultFailure(
          ValidationFailure(message: 'Message ID는 비어있을 수 없습니다.'),
        );
      }

      // Clean Architecture v4.0: messageId만 전달, Repository에서 Firestore 처리
      final messages = await _chatRepository.queryMessagesBeforeMessageId(
        chatId: chatId,
        lastMessageId: lastMessageId,
        limit: limit,
      );

      return Success(messages);
    } catch (e) {
      return ResultFailure(
        ServerFailure(message: '이전 메시지 로드 실패: ${e.toString()}'),
      );
    }
  }
}
