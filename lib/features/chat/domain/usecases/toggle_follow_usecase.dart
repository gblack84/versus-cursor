import '../repositories/i_chat_repository.dart';

/// UseCase: 팔로우/언팔로우 토글 (Clean Architecture v4.0)
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
/// - Future<bool>: 변경 후 팔로우 상태 (true: 팔로우 중, false: 언팔로우)
class ToggleFollowUseCase {
  final IChatRepository _chatRepository;

  ToggleFollowUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 팔로우/언팔로우 토글
  ///
  /// **Parameters**:
  /// - [userId]: 팔로우하는 사용자 ID (필수)
  /// - [targetUserId]: 팔로우 대상 사용자 ID (필수)
  ///
  /// **Returns**:
  /// - bool: 변경 후 팔로우 상태
  ///   - true: 팔로우 완료
  ///   - false: 언팔로우 완료
  ///
  /// **Throws**:
  /// - [ArgumentError]: 본인을 팔로우 시도 시
  /// - [ArgumentError]: 필수 파라미터 누락 시
  /// - [Exception]: Firestore 에러 (Repository에서 발생)
  ///
  /// **Implementation**:
  /// 1. Validation: 본인 팔로우 불가
  /// 2. Validation: 필수 파라미터 확인
  /// 3. Repository의 isFollowing() 호출하여 현재 상태 확인
  /// 4. 상태에 따라 followUser() 또는 unfollowUser() 호출
  /// 5. 변경 후 상태 반환
  Future<bool> execute({
    required String userId,
    required String targetUserId,
  }) async {
    // Validation: 필수 파라미터
    if (userId.isEmpty || targetUserId.isEmpty) {
      throw ArgumentError('User IDs cannot be empty');
    }

    // Validation: 본인 팔로우 불가
    if (userId == targetUserId) {
      throw ArgumentError('Cannot follow yourself');
    }

    // 1. 현재 팔로우 상태 확인
    final isFollowing = await _chatRepository.isFollowing(
      userId,
      targetUserId,
    );

    // 2. 팔로우 상태에 따라 토글
    if (isFollowing) {
      // 이미 팔로우 중 → 언팔로우
      await _chatRepository.unfollowUser(userId, targetUserId);
      return false; // 언팔로우 완료
    } else {
      // 팔로우 안 함 → 팔로우
      await _chatRepository.followUser(userId, targetUserId);
      return true; // 팔로우 완료
    }
  }
}
