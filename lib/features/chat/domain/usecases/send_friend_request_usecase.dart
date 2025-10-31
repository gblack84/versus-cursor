import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../repositories/i_chat_repository.dart';
import '../failures/chat_failure.dart';

/// UseCase: 친구 요청 보내기 (Clean Architecture v4.0 + Phase 1: Either Pattern)
///
/// **비즈니스 규칙**:
/// - 본인에게는 친구 요청 불가
/// - 이미 친구인 경우는 Data Layer에서 처리
/// - 중복 요청은 IdempotencyService로 처리
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
  /// 3. eventId 생성 (UUID v4, 중복 방지용)
  /// 4. Repository의 sendFriendRequest() 호출 (이미 Either 반환)
  Future<Either<ChatFailure, Unit>> execute({
    required String fromUserId,
    required String toUserId,
  }) async {
    // Validation: 필수 파라미터
    if (fromUserId.isEmpty || toUserId.isEmpty) {
      return left(const FriendRequestFailed());
    }

    // Validation: 본인에게 친구 요청 불가
    if (fromUserId == toUserId) {
      return left(const FriendRequestFailed());
    }

    // eventId 생성 (중복 방지용)
    final eventId = const Uuid().v4();

    // Repository 호출 - Either 반환
    return await _chatRepository.sendFriendRequest(
      fromUserId: fromUserId,
      toUserId: toUserId,
      eventId: eventId,
    );
  }
}
