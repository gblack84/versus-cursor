import 'package:fpdart/fpdart.dart';

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
///     (failure) => print('에러: $failure'),
///     (messages) => print('받은 메시지: ${messages.length}개'),
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
    // ✅ 입력 검증
    if (chatId.isEmpty) {
      yield left(const InvalidMessageContent());
      return;
    }

    // ✅ Repository에서 이미 Either 반환하므로 그대로 전달 (패스스루)
    await for (final either in _chatRepository.queryMessagesByChatId(
      chatId: chatId,
      limit: limit,
      orderBy: 'timeStamp',
      descending: false,
    )) {
      yield either; // 패스스루: Repository → UseCase → Provider
    }
  }
}
