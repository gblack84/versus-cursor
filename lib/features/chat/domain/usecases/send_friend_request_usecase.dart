import '../repositories/i_chat_repository.dart';

/// UseCase: 친구 요청 보내기 (Clean Architecture v4.0)
///
/// **비즈니스 규칙**:
/// - 본인에게는 친구 요청 불가
/// - 이미 친구인 경우는 Data Layer에서 처리
/// - 중복 요청은 Data Layer에서 처리
///
/// **Dependencies**:
/// - [IChatRepository]: 데이터 접근 추상화
///
/// **Returns**:
/// - Future<void>: 성공/실패는 Exception으로 처리
class SendFriendRequestUseCase {
  final IChatRepository _chatRepository;

  SendFriendRequestUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 요청 보내기
  ///
  /// **Parameters**:
  /// - [fromUserId]: 요청 보내는 사용자 ID (필수)
  /// - [toUserId]: 요청 받는 사용자 ID (필수)
  ///
  /// **Throws**:
  /// - [ArgumentError]: 본인에게 친구 요청 시
  /// - [ArgumentError]: 필수 파라미터 누락 시
  /// - [Exception]: Firestore 에러 (Repository에서 발생)
  ///
  /// **Implementation**:
  /// 1. Validation: 본인에게 요청 불가
  /// 2. Validation: 필수 파라미터 확인
  /// 3. Repository의 sendFriendRequest() 호출
  Future<void> execute({
    required String fromUserId,
    required String toUserId,
  }) async {
    // Validation: 필수 파라미터
    if (fromUserId.isEmpty || toUserId.isEmpty) {
      throw ArgumentError('User IDs cannot be empty');
    }

    // Validation: 본인에게 친구 요청 불가
    if (fromUserId == toUserId) {
      throw ArgumentError('Cannot send friend request to yourself');
    }

    // Repository 호출
    await _chatRepository.sendFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );
  }
}
