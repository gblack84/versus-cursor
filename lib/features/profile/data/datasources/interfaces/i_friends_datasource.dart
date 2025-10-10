/// 친구 DataSource 인터페이스
///
/// **책임**: Firestore 'friendsList' 및 'users' 컬렉션의 친구 관련 데이터 통신
abstract class IFriendsDataSource {
  // ============= 기본 친구 관리 =============

  /// 친구 목록 조회 (ID만)
  Future<List<String>> getFriends(String userId);

  /// 친구 목록 실시간 감시 (ID만)
  Stream<List<String>> watchFriends(String userId);

  /// 친구 프로필 조회
  Future<List<Map<String, dynamic>>> getFriendProfiles(String userId);

  /// 친구 프로필 실시간 감시
  Stream<List<Map<String, dynamic>>> watchFriendProfiles(String userId);

  /// 친구 삭제
  Future<void> removeFriend(String userId, String friendId);

  // ============= 친구 요청 관리 =============

  /// 친구 요청 전송
  Future<void> sendFriendRequest(String fromUserId, String toUserId);

  /// 친구 요청 수락
  Future<void> acceptFriendRequest(String userId, String requesterId);

  /// 친구 요청 거절
  Future<void> rejectFriendRequest(String userId, String requesterId);

  /// 친구 요청 취소
  Future<void> cancelFriendRequest(String userId, String targetUserId);

  /// 받은 친구 요청 조회
  Future<List<String>> getPendingFriendRequests(String userId);

  /// 받은 친구 요청 실시간 감시
  Stream<List<String>> watchPendingFriendRequests(String userId);

  /// 보낸 친구 요청 조회
  Future<List<String>> getSentFriendRequests(String userId);

  /// 보낸 친구 요청 실시간 감시
  Stream<List<String>> watchSentFriendRequests(String userId);

  // ============= 친구 상태 확인 =============

  /// 친구 관계 확인
  Future<bool> areFriends(String userId1, String userId2);

  /// 친구 요청 존재 확인
  Future<bool> hasPendingFriendRequest(String fromUserId, String toUserId);

  /// 친구 수 조회
  Future<int> getFriendsCount(String userId);

  // ============= 친구 검색 및 추천 =============

  /// 공통 친구 조회
  Future<List<String>> getMutualFriends(String userId1, String userId2);

  /// 친구 추천 (AI 기반)
  Future<List<Map<String, dynamic>>> getFriendSuggestions(
    String userId, {
    int limit = 10,
  });

  /// 친구 검색
  Future<List<Map<String, dynamic>>> searchFriends(
    String userId,
    String query,
  );

  /// 관심사별 친구 조회
  Future<List<Map<String, dynamic>>> getFriendsByInterest(
    String userId,
    String interest,
  );

  // ============= 온라인 상태 =============

  /// 온라인 친구 조회
  Future<List<String>> getOnlineFriends(String userId);

  /// 온라인 친구 실시간 감시
  Stream<List<String>> watchOnlineFriends(String userId);

  // ============= 친구 활동 =============

  /// 최근 친구 활동 조회
  Future<List<Map<String, dynamic>>> getRecentFriendsActivity(
    String userId, {
    int limit = 20,
  });

  /// 친구 관계 메타데이터 업데이트
  Future<void> updateFriendshipMetadata(
    String userId,
    String friendId,
    Map<String, dynamic> metadata,
  );
}
