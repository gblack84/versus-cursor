import '../repositories/i_chat_repository.dart';

/// UseCase: 친구 추천 목록 조회 (Clean Architecture v4.0)
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
/// - Stream<List<UserProfile>>: 추천 친구 목록 실시간 스트림
class GetRecommendedFriendsUseCase {
  final IChatRepository _chatRepository;

  GetRecommendedFriendsUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 추천 목록 조회
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID (필수)
  /// - [limit]: 조회할 최대 개수 (기본: 20)
  ///
  /// **Returns**:
  /// - Stream<List<dynamic>>: 추천 친구 목록 (UserProfile)
  ///
  /// **Implementation**:
  /// 1. currentUserId가 빈 문자열이면 빈 Stream 반환
  /// 2. Repository의 getRecommendedFriends() 호출
  /// 3. totalAPoints 기준 정렬 (내림차순)
  Stream<List<dynamic>> execute({
    required String currentUserId,
    int limit = 20,
  }) {
    // Validation: 현재 사용자 ID 확인
    if (currentUserId.isEmpty) {
      return Stream.value([]);
    }

    // Repository 호출
    return _chatRepository.getRecommendedFriends(
      currentUserId: currentUserId,
      sortBy: 'totalAPoints',
      limit: limit,
    );
  }
}
