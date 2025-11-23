import 'package:fpdart/fpdart.dart';
import '../repositories/i_chat_repository.dart';
import '../failures/chat_failure.dart';
import '/services/logging/dev_logger.dart';

/// UseCase: 팔로우/언팔로우 토글 (Clean Architecture v4.0 + Phase 1: Either Pattern)
///
/// **비즈니스 규칙**:
/// - 현재 팔로우 상태를 확인 후 반대 동작 수행
/// - 본인을 팔로우 불가
/// - 팔로우 중이면 → 언팔로우
/// - 팔로우 안 하고 있으면 → 팔로우
///
/// **Dependencies**:
/// - [IChatRepository]: 데이터 접근 추상화
///
/// **Returns**:
/// - Either<ChatFailure, bool>: 변경 후 팔로우 상태 또는 실패
class ToggleFollowUseCase {
  final IChatRepository _chatRepository;

  ToggleFollowUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 팔로우/언팔로우 토글 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [userId]: 팔로우하는 사용자 ID (필수)
  /// - [targetUserId]: 팔로우 대상 사용자 ID (필수)
  ///
  /// **Returns**:
  /// - Either<ChatFailure, bool>
  ///   - Left: FollowToggleFailed (유효성 검사 실패 또는 토글 실패)
  ///   - Right: bool (변경 후 팔로우 상태 - true: 팔로우, false: 언팔로우)
  ///
  /// **Implementation**:
  /// 1. Validation: 본인 팔로우 불가
  /// 2. Validation: 필수 파라미터 확인
  /// 3. Repository의 isFollowing() 호출하여 현재 상태 확인 (Either 반환)
  /// 4. 상태에 따라 followUser() 또는 unfollowUser() 호출
  /// 5. 변경 후 상태 반환
  Future<Either<ChatFailure, bool>> execute({
    required String userId,
    required String targetUserId,
  }) async {
    DevLogger.params({
      'userId': userId,
      'targetUserId': targetUserId,
    }, tag: 'ToggleFollow');

    // Validation: 필수 파라미터
    if (userId.isEmpty || targetUserId.isEmpty) {
      DevLogger.result(
        isSuccess: false,
        data: 'Empty userId or targetUserId',
        tag: 'ToggleFollow',
      );
      return left(const FollowToggleFailed());
    }

    // Validation: 본인 팔로우 불가
    if (userId == targetUserId) {
      DevLogger.result(
        isSuccess: false,
        data: 'Cannot follow self',
        tag: 'ToggleFollow',
      );
      return left(const FollowToggleFailed());
    }

    DevLogger.checkpoint('Calling repository.isFollowing', tag: 'ToggleFollow');

    // 1. 현재 팔로우 상태 확인 (Either 반환)
    final isFollowingEither = await _chatRepository.isFollowing(
      userId: userId,
      targetUserId: targetUserId,
    );

    // 2. isFollowing 결과 처리
    return await isFollowingEither.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: failure.toString(),
          tag: 'ToggleFollow',
        );
        return left(failure); // 조회 실패 시 바로 반환
      },
      (isFollowing) async {
        // 3. 팔로우 상태에 따라 토글
        if (isFollowing) {
          // 이미 팔로우 중 → 언팔로우
          DevLogger.checkpoint('Calling repository.unfollowUser', tag: 'ToggleFollow');

          final result = await _chatRepository.unfollowUser(
            userId: userId,
            targetUserId: targetUserId,
          );
          return result.fold(
            (failure) {
              DevLogger.result(
                isSuccess: false,
                data: failure.toString(),
                tag: 'ToggleFollow',
              );
              return left(failure);
            },
            (_) {
              DevLogger.result(
                isSuccess: true,
                data: {'action': 'unfollowed', 'newState': false},
                tag: 'ToggleFollow',
              );
              return right(false); // 언팔로우 완료
            },
          );
        } else {
          // 팔로우 안 함 → 팔로우
          DevLogger.checkpoint('Calling repository.followUser', tag: 'ToggleFollow');

          final result = await _chatRepository.followUser(
            userId: userId,
            targetUserId: targetUserId,
          );
          return result.fold(
            (failure) {
              DevLogger.result(
                isSuccess: false,
                data: failure.toString(),
                tag: 'ToggleFollow',
              );
              return left(failure);
            },
            (_) {
              DevLogger.result(
                isSuccess: true,
                data: {'action': 'followed', 'newState': true},
                tag: 'ToggleFollow',
              );
              return right(true); // 팔로우 완료
            },
          );
        }
      },
    );
  }
}
