import 'package:freezed_annotation/freezed_annotation.dart';
import '../enums/user_role.dart';

part 'auth_user.freezed.dart';
part 'auth_user.g.dart';

/// Extended Auth User Domain Entity for Versus Space
///
/// **Clean Architecture v4.0 - Domain Layer**:
/// - Freezed 불변 객체 (자동 생성: copyWith, ==, hashCode, toString)
/// - JSON 직렬화 지원
/// - 타입 안전성 보장
///
/// **Auth Feature의 핵심 Entity**:
/// - 사용자 인증 정보
/// - 프로필 정보
/// - 포인트 시스템
/// - 역할 기반 권한
@freezed
sealed class AuthUser with _$AuthUser {
  const AuthUser._();

  const factory AuthUser({
    // ==================== Authentication fields ====================
    /// 사용자 고유 ID (Firebase UID)
    required String uid,

    /// 이메일 주소
    String? email,

    /// 표시 이름 (Display Name)
    String? displayName,

    /// 사용자 이름 (Unique Username)
    String? userName,

    /// 프로필 사진 URL
    String? photoUrl,

    /// 전화번호
    String? phoneNumber,

    /// 이메일 인증 여부
    @Default(false) bool isEmailVerified,

    /// 익명 사용자 여부
    @Default(false) bool isAnonymous,

    /// 로그인 제공자 ID (google, apple, email, phone 등)
    String? providerId,

    // ==================== Profile fields ====================
    /// 자기소개
    String? bio,

    /// 나이
    int? age,

    /// 성별
    String? gender,

    /// 관심사 목록
    @Default([]) List<String> interests,

    /// 전문 분야 목록 (최대 4개)
    @Default([]) List<String> expertise,

    /// 취미 목록 (최대 8개)
    @Default([]) List<String> hobbies,

    // ==================== Points & Rewards ====================
    /// A 포인트 (답변으로 얻은 포인트)
    @Default(0) int pointsA,

    /// Q 포인트 (질문으로 얻은 포인트)
    @Default(0) int pointsQ,

    // ==================== Role & Premium ====================
    /// 사용자 역할 (admin, tester, user)
    @JsonKey(
      fromJson: _userRoleFromJson,
      toJson: _userRoleToJson,
    )
    @Default(UserRole.user)
    UserRole role,

    /// 프리미엄 사용자 여부
    @Default(false) bool isPremium,

    // ==================== Timestamps ====================
    /// 계정 생성 시간
    DateTime? createdAt,

    /// 마지막 로그인 시간
    DateTime? lastLoginAt,

    // ==================== Additional ====================
    /// 사용자 설정 (Key-Value 형태)
    @Default({}) Map<String, dynamic> settings,
  }) = _AuthUser;

  // ==================== Factory from JSON ====================
  factory AuthUser.fromJson(Map<String, dynamic> json) =>
      _$AuthUserFromJson(json);

  // ==================== Computed Properties ====================

  /// 프로필 완성도 확인
  ///
  /// **완성 조건**:
  /// - userName 존재
  /// - displayName 존재
  /// - age 존재
  /// - interests가 1개 이상
  bool get isProfileComplete {
    return userName != null &&
        displayName != null &&
        age != null &&
        interests.isNotEmpty;
  }

  /// 관리자 여부
  bool get isAdmin => role.isAdmin;

  /// 테스터 여부 (admin도 포함)
  bool get isTester => role.isTester;

  /// 총 포인트 (A 포인트 + Q 포인트)
  int get totalPoints => pointsA + pointsQ;
}

// ==================== JSON Converters ====================

/// UserRole을 JSON에서 파싱
UserRole _userRoleFromJson(dynamic json) {
  if (json is String) {
    return UserRole.fromValue(json);
  }
  return UserRole.user; // 기본값
}

/// UserRole을 JSON으로 변환
String _userRoleToJson(UserRole role) {
  return role.toValue();
}
