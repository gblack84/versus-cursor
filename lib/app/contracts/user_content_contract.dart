/// User Content tracking contract between Creation and Profile Features
///
/// Profile Feature가 Creation Feature에게 제공하는 사용자 콘텐츠 추적 기능
abstract class UserContentContract {
  /// 사용자 콘텐츠 생성 기록
  Future<void> createUserContent({
    required String userId,
    required String postId,
    required String contentType,
    String? visibility,
    List<String>? tags,
    bool isPremium = false,
  });

  /// 사용자 콘텐츠 목록 조회
  Future<List<Map<String, dynamic>>> getUserContents(String userId);

  /// 특정 타입의 사용자 콘텐츠 조회
  Future<List<Map<String, dynamic>>> getUserContentsByType(
    String userId,
    String contentType,
  );

  /// 참여자 수 업데이트
  Future<void> updateParticipantCount({
    required String userId,
    required String postId,
    required int participantCount,
  });

  /// 사용자 콘텐츠 통계 조회
  Future<Map<String, dynamic>> getUserContentStats(String userId);

  /// 프리미엄 콘텐츠만 조회
  Future<List<Map<String, dynamic>>> getUserPremiumContents(String userId);
}