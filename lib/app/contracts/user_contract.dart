/// User Feature가 다른 Feature들에게 제공하는 계약
///
/// 사용자 프로필 정보 접근용
abstract class UserContract {
  /// 사용자 프로필 조회
  Future<Map<String, dynamic>?> getUserProfile(String userId);

  /// 사용자 이름 조회
  Future<String?> getUserDisplayName(String userId);

  /// 사용자 프로필 사진 조회
  Future<String?> getUserPhotoUrl(String userId);

  /// 사용자 관심사 조회
  Future<List<String>> getUserInterests(String userId);

  /// 사용자 전문 분야 조회
  Future<List<String>> getUserExpertise(String userId);

  /// 사용자 포인트 조회
  Future<Map<String, int>> getUserPoints(String userId);

  /// 프리미엄 사용자 여부
  Future<bool> isPremiumUser(String userId);

  /// 사용자 역할 조회 (admin, tester, user)
  Future<String?> getUserRole(String userId);
}