import 'package:fpdart/fpdart.dart';

import '/services/logging/dev_logger.dart';
import '../failures/chat_failure.dart';
import '../repositories/i_chat_repository.dart';
import '../entities/chat.dart';

/// 현재 사용자의 채팅 목록을 실시간 스트림으로 가져오는 UseCase
///
/// **Clean Architecture v4.0**:
/// - IChatRepository.queryChats() 메서드 사용
/// - 순수 Domain Entity (Chat) 사용 (Firestore 의존성 완전 제거)
///
/// **사용 예시**:
/// ```dart
/// final useCase = GetChatListUseCase(chatRepository: repository);
/// final stream = useCase.execute(userId: 'user123', limit: 50);
///
/// stream.listen((either) {
///   either.fold(
///     (failure) => ChatLogger.chatListError(error: failure, userId: 'user123'),
///     (chats) => ChatLogger.chatListLoaded(count: chats.length, userId: 'user123'),
///   );
/// });
/// ```
class GetChatListUseCase {
  final IChatRepository _chatRepository;

  GetChatListUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 실시간 채팅 목록 스트림 반환 (PHASE 1: Either Pattern 완료)
  ///
  /// **Parameters**:
  /// - [userId]: 현재 사용자 ID
  /// - [limit]: 한 번에 로드할 채팅 개수 (기본값: 50)
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Chat>>>`: 채팅 목록의 실시간 스트림
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
  Stream<Either<ChatFailure, List<Chat>>> execute({
    required String userId,
    int limit = 50,
  }) async* {
    DevLogger.params({'userId': userId, 'limit': limit}, tag: 'GetChatList');
    DevLogger.checkpoint('Starting chat list stream', tag: 'GetChatList');

    // ✅ 입력 검증
    if (userId.isEmpty) {
      DevLogger.validation(
        field: 'userId',
        reason: 'User ID cannot be empty',
        tag: 'GetChatList',
      );
      yield left(const ChatNotFound());
      return;
    }

    DevLogger.checkpoint('Querying repository for chat list', tag: 'GetChatList');

    // ✅ Repository에서 이미 Either 반환하므로 그대로 전달 (패스스루)
    await for (final either in _chatRepository.queryChats(
      userId: userId,
      limit: limit,
      orderBy: 'lastMessageAt',
      descending: true,
    )) {
      either.fold(
        (failure) {
          DevLogger.error(
            'Chat list stream error',
            error: failure,
            tag: 'GetChatList',
          );
        },
        (chats) {
          DevLogger.result(
            isSuccess: true,
            data: '${chats.length} chats emitted',
            tag: 'GetChatList',
          );
        },
      );
      yield either; // 패스스루: Repository → UseCase → Provider
    }

    DevLogger.checkpoint('Chat list stream ended', tag: 'GetChatList');
  }
}
