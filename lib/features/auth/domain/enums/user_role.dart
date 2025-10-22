/// User Role Enum
///
/// Domain Layer - 사용자 역할 타입 정의
/// Type-safe role management instead of String values
enum UserRole {
  /// 관리자 - 모든 권한 보유
  admin,

  /// 테스터 - 테스트 기능 접근 가능
  tester,

  /// 일반 사용자 - 기본 권한
  user;

  /// 관리자 여부 확인
  bool get isAdmin => this == UserRole.admin;

  /// 테스터 여부 확인 (관리자도 테스터 권한 보유)
  bool get isTester => this == UserRole.tester || this == UserRole.admin;

  /// String 값으로 변환
  String toValue() {
    return switch (this) {
      UserRole.admin => 'admin',
      UserRole.tester => 'tester',
      UserRole.user => 'user',
    };
  }

  /// String 값에서 UserRole 생성
  static UserRole fromValue(String value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'tester' => UserRole.tester,
      'user' => UserRole.user,
      _ => UserRole.user, // 기본값
    };
  }
}
