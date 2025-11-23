import 'package:fpdart/fpdart.dart';
import '../repositories/i_chat_repository.dart';
import '../failures/chat_failure.dart';
import '/services/logging/dev_logger.dart';

/// UseCase: 친구 요청 보내기 (Clean Architecture v4.0 + Phase 1: Either Pattern)
///
/// **비즈니스 규칙**:
/// - 본인에게는 친구 요청 불가
/// - 이미 친구인 경우는 Data Layer에서 처리
/// - 중복 요청은 Firestore의 자연스러운 멱등성으로 처리
///
/// **Dependencies**:
/// - [IChatRepository]: 데이터 접근 추상화
///
/// **Returns**:
/// - Either<ChatFailure, Unit>: 성공 또는 실패
class SendFriendRequestUseCase {
  final IChatRepository _chatRepository;

  SendFriendRequestUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 요청 보내기 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [fromUserId]: 요청 보내는 사용자 ID (필수)
  /// - [toUserId]: 요청 받는 사용자 ID (필수)
  ///
  /// **Returns**:
  /// - Either<ChatFailure, Unit>
  ///   - Left: FriendRequestFailed (유효성 검사 실패 또는 요청 실패)
  ///   - Right: Unit (성공)
  ///
  /// **Implementation**:
  /// 1. Validation: 본인에게 요청 불가
  /// 2. Validation: 필수 파라미터 확인
  /// 3. Repository의 sendFriendRequest() 호출 (이미 Either 반환)
  Future<Either<ChatFailure, Unit>> execute({
    required String fromUserId,
    required String toUserId,
  }) async {
    DevLogger.params({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
    }, tag: 'SendFriendRequest');

    // Validation: 필수 파라미터
    if (fromUserId.isEmpty || toUserId.isEmpty) {
      DevLogger.result(
        isSuccess: false,
        data: 'Empty fromUserId or toUserId',
        tag: 'SendFriendRequest',
      );
      return left(const FriendRequestFailed());
    }

    // Validation: 본인에게 친구 요청 불가
    if (fromUserId == toUserId) {
      DevLogger.result(
        isSuccess: false,
        data: 'Cannot send friend request to self',
        tag: 'SendFriendRequest',
      );
      return left(const FriendRequestFailed());
    }

    DevLogger.checkpoint('Calling repository.sendFriendRequest', tag: 'SendFriendRequest');

    // Repository 호출 - Either 반환
    final result = await _chatRepository.sendFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
    );

    result.fold(
      (failure) => DevLogger.result(
        isSuccess: false,
        data: failure.toString(),
        tag: 'SendFriendRequest',
      ),
      (_) => DevLogger.result(
        isSuccess: true,
        tag: 'SendFriendRequest',
      ),
    );

    return result;
  }
}
