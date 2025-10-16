import '/core/types/result.dart';
import '/core/errors/failures.dart';
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
/// stream.listen((result) {
///   result.when(
///     success: (chats) => print('받은 채팅: ${chats.length}개'),
///     failure: (error) => print('에러: $error'),
///   );
/// });
/// ```
class GetChatListUseCase {
  final IChatRepository _chatRepository;

  GetChatListUseCase({required IChatRepository chatRepository})
      : _chatRepository = chatRepository;

  /// 실시간 채팅 목록 스트림 반환 (Clean Architecture v4.0)
  ///
  /// **Parameters**:
  /// - [userId]: 현재 사용자 ID
  /// - [limit]: 한 번에 로드할 채팅 개수 (기본값: 50)
  ///
  /// **Returns**:
  /// - `Stream<Result<List<Chat>>>`: 채팅 목록의 실시간 스트림
  ///
  /// **Clean Architecture v4.0 개선사항**:
  /// 1. Firestore queryBuilder 제거 (Infrastructure 의존성 제거)
  /// 2. Repository에서 participantIds 필터링 처리
  /// 3. 순수 Dart 타입만 사용 (Domain Entity)
  Stream<Result<List<Chat>>> execute({
    required String userId,
    int limit = 50,
  }) {
    try {
      // 입력 검증
      if (userId.isEmpty) {
        return Stream.value(
          ResultFailure(
            ValidationFailure(message: 'User ID는 비어있을 수 없습니다.'),
          ),
        );
      }

      // Clean Architecture v4.0: Repository 호출 (Firestore 타입 제거)
      final chatsStream = _chatRepository.queryChats(
        userId: userId,
        limit: limit,
        orderBy: 'lastMessageAt',
        descending: true,
      );

      // Stream<List<Chat>>을 Result로 감싸서 반환
      return chatsStream.map((chats) => Success(chats));
    } catch (e) {
      return Stream.value(
        ResultFailure(
          ServerFailure(message: '채팅 목록 로드 실패: ${e.toString()}'),
        ),
      );
    }
  }
}
