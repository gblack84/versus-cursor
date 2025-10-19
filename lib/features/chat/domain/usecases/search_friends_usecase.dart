import '../repositories/i_chat_repository.dart';

/// UseCase: 친구 검색 (Clean Architecture v4.0)
///
/// **비즈니스 규칙**:
/// - displayName 기준 검색
/// - 현재 사용자는 결과에서 제외
/// - 검색어가 비어있으면 빈 결과 반환
///
/// **Dependencies**:
/// - [IChatRepository]: 데이터 접근 추상화
///
/// **Returns**:
/// - Stream<List<UserProfile>>: 검색된 사용자 목록 실시간 스트림
class SearchFriendsUseCase {
  final IChatRepository _chatRepository;

  SearchFriendsUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 검색
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID (필수)
  /// - [query]: 검색어 (필수, displayName 검색)
  ///
  /// **Returns**:
  /// - Stream<List<dynamic>>: 검색된 사용자 목록 (UserProfile)
  ///
  /// **Implementation**:
  /// 1. 검색어가 비어있으면 빈 Stream 반환
  /// 2. currentUserId가 빈 문자열이면 빈 Stream 반환
  /// 3. Repository의 searchUsers() 호출
  /// 4. displayName에 검색어 포함 여부로 필터링
  Stream<List<dynamic>> execute({
    required String currentUserId,
    required String query,
  }) {
    // Validation: 검색어 및 현재 사용자 ID 확인
    if (query.trim().isEmpty || currentUserId.isEmpty) {
      return Stream.value([]);
    }

    // Repository 호출
    return _chatRepository.searchUsers(
      currentUserId: currentUserId,
      query: query.trim(),
    );
  }
}
