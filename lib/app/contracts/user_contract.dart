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

  // ============= 쓰기 메서드 (Auth Feature 전용) =============

  /// 신규 사용자 프로필 생성
  ///
  /// Auth Feature에서 회원가입 시 호출됩니다.
  /// Firebase Auth 사용자 생성 직후 Firestore users 컬렉션에 프로필을 생성합니다.
  Future<void> createUserProfile({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  });

  /// 프로필 데이터 업데이트
  ///
  /// 부분 업데이트를 지원합니다. Map에 포함된 필드만 업데이트됩니다.
  /// IUserRepository.updateUserProfile(UserProfile)과 구분하기 위해 Data suffix 사용
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data);

  /// 프로필 삭제
  ///
  /// 회원 탈퇴 시 호출됩니다. Firebase Auth 삭제와 함께 실행됩니다.
  Future<void> deleteUserProfile(String uid);
}