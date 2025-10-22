/// Auth Feature가 다른 Feature들에게 제공하는 계약
///
/// 다른 Feature들이 인증 정보에 접근할 때 사용
abstract class AuthContract {
  /// 현재 로그인한 사용자 ID 조회
  String? getCurrentUserId();

  /// 현재 로그인한 사용자 이메일 조회
  String? getCurrentUserEmail();

  /// 로그인 여부 확인
  bool get isSignedIn;

  /// 사용자 토큰 조회 (API 호출용)
  Future<String?> getIdToken();

  /// 토큰 갱신
  Future<String?> refreshToken();

  /// 이메일 인증 여부 확인
  bool get isEmailVerified;

  /// 익명 사용자 여부 확인
  bool get isAnonymous;

  // ============= Profile Feature가 필요로 하는 추가 getter =============

  /// 현재 로그인한 사용자 표시 이름 조회
  String? get currentUserDisplayName;

  /// 현재 로그인한 사용자 프로필 사진 URL 조회
  String? get currentUserPhoto;

  /// 현재 로그인한 사용자 전화번호 조회
  String? get currentPhoneNumber;

  // ============= 로그아웃 기능 =============

  /// 로그아웃
  ///
  /// 캐시 정리 및 세션 종료
  Future<void> signOut();
}