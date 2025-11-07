import 'package:fpdart/fpdart.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '../repositories/i_chat_repository.dart';
import '../failures/chat_failure.dart';

/// UseCase: 친구 검색 (Clean Architecture v4.0 + Phase 1: Either Pattern)
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
/// - Stream<Either<ChatFailure, List<UserProfile>>>: 검색된 사용자 목록 또는 실패
class SearchFriendsUseCase {
  final IChatRepository _chatRepository;

  SearchFriendsUseCase({
    required IChatRepository chatRepository,
  }) : _chatRepository = chatRepository;

  /// Execute: 친구 검색 (Phase 1: Either Pattern)
  ///
  /// **Parameters**:
  /// - [currentUserId]: 현재 사용자 ID (필수)
  /// - [query]: 검색어 (필수, displayName 검색)
  ///
  /// **Returns**:
  /// - Stream<Either<ChatFailure, List<UserProfile>>>
  ///   - Left: SearchFailed (유효성 검사 실패 또는 검색 실패)
  ///   - Right: List<UserProfile> (검색된 사용자 목록)
  ///
  /// **Implementation**:
  /// 1. Validation: 검색어 및 currentUserId 확인
  /// 2. Repository 호출 (이미 Either 반환)
  /// 3. displayName에 검색어 포함 여부로 필터링
  Stream<Either<ChatFailure, List<UserProfile>>> execute({
    required String currentUserId,
    required String query,
  }) async* {
    // Validation: 검색어 및 현재 사용자 ID 확인
    if (query.trim().isEmpty || currentUserId.isEmpty) {
      yield left(const SearchFailed());
      return;
    }

    // Repository 호출 - Either 반환, dynamic → UserProfile 변환
    await for (final either in _chatRepository.searchUsers(
      currentUserId: currentUserId,
      query: query.trim(),
    )) {
      yield either.map((users) => users.cast<UserProfile>());
    }
  }
}
