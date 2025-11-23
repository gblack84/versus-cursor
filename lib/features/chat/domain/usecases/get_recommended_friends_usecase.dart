import 'package:fpdart/fpdart.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '../repositories/i_chat_repository.dart';
import '../failures/chat_failure.dart';
import '/services/logging/dev_logger.dart';

/// UseCase: 친구 추천 목록 조회 (Clean Architecture v4.0 + Phase 1: Either Pattern)
///
/// **비즈니스 규칙**:
/// - totalAPoints 기준 상위 랭킹 사용자 추천
/// - 현재 사용자는 결과에서 제외
/// - 기본 20명 제한
///
/// **Dependencies**:
/// - [IChatRepository]: 데이터 접근 추상화
///
/// **Returns**:
/// - Stream<Either<ChatFailure, List<UserProfile>>>: 추천 친구 목록 또는 실패
class GetRecommendedFriendsUseCase {
  final IChatRepository _chatRepository;

  GetRecommendedFriendsUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 추천 목록 조회 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID (필수)
  /// - [limit]: 조회할 최대 개수 (기본: 20)
  ///
  /// **Returns**:
  /// - Stream<Either<ChatFailure, List<UserProfile>>>
  ///   - Left: FriendLoadFailed (유효성 검사 실패 또는 로드 실패)
  ///   - Right: List<UserProfile> (추천 친구 목록)
  ///
  /// **Implementation**:
  /// 1. Validation: currentUserId 확인
  /// 2. Repository 호출 (이미 Either 반환)
  /// 3. totalAPoints 기준 정렬 (내림차순)
  Stream<Either<ChatFailure, List<UserProfile>>> execute({
    required String currentUserId,
    int limit = 20,
  }) async* {
    DevLogger.params({
      'currentUserId': currentUserId,
      'limit': limit,
    }, tag: 'GetRecommendedFriends');

    // Validation: 현재 사용자 ID 확인
    if (currentUserId.isEmpty) {
      DevLogger.result(
        isSuccess: false,
        data: 'Empty currentUserId',
        tag: 'GetRecommendedFriends',
      );
      yield left(const FriendLoadFailed());
      return;
    }

    DevLogger.checkpoint('Starting recommended friends stream', tag: 'GetRecommendedFriends');

    // Repository 호출 - Either 반환, dynamic → UserProfile 변환
    await for (final either in _chatRepository.getRecommendedFriends(
      currentUserId: currentUserId,
      sortBy: 'totalAPoints',
      limit: limit,
    )) {
      either.fold(
        (failure) {
          DevLogger.result(
            isSuccess: false,
            data: failure.toString(),
            tag: 'GetRecommendedFriends',
          );
        },
        (users) {
          DevLogger.result(
            isSuccess: true,
            data: {'count': users.length},
            tag: 'GetRecommendedFriends',
          );
        },
      );

      yield either.map((users) => users.cast<UserProfile>());
    }
  }
}
