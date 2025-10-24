import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_user.dart';
import '../enums/user_role.dart';

/// Firebase 연동을 위한 AuthUser Extensions
///
/// **Firebase 최적화 v1.0 - DTO 제거 전략**:
/// - DTO/Mapper 없이 Domain 모델에서 직접 Firebase 변환
/// - Extension으로 Firebase 의존성 격리
/// - Freezed 모델의 불변성 유지
///
/// **두 가지 변환 지원**:
/// 1. Firebase Authentication User → AuthUser (fromFirebaseUser)
/// 2. Firestore DocumentSnapshot → AuthUser (fromFirestore)
/// 3. AuthUser → Firestore Map (toFirestore)
extension AuthUserFirestore on AuthUser {
  // ============================================================================
  // Firebase Authentication User → AuthUser
  // ============================================================================

  /// Firebase Authentication User 객체로부터 AuthUser 생성
  ///
  /// **사용처**: 로그인/회원가입 직후 Firebase User 객체 변환
  ///
  /// **특징**:
  /// - Firebase Auth는 인증 정보만 제공
  /// - 프로필 정보는 Firestore에서 별도 로드 필요
  static AuthUser fromFirebaseUser(dynamic firebaseUser) {
    return AuthUser(
      uid: firebaseUser.uid as String,
      email: firebaseUser.email as String?,
      displayName: firebaseUser.displayName as String?,
      photoUrl: firebaseUser.photoURL as String?,
      isEmailVerified: firebaseUser.emailVerified as bool? ?? false,
      phoneNumber: firebaseUser.phoneNumber as String?,
      isAnonymous: firebaseUser.isAnonymous as bool? ?? false,
      providerId: firebaseUser.providerData?.isNotEmpty == true
          ? firebaseUser.providerData![0].providerId as String?
          : null,
      createdAt: firebaseUser.metadata?.creationTime,
      lastLoginAt: firebaseUser.metadata?.lastSignInTime,
    );
  }

  // ============================================================================
  // Firestore DocumentSnapshot → AuthUser
  // ============================================================================

  /// Firestore users 컬렉션 문서로부터 AuthUser 생성
  ///
  /// **사용처**: Firestore에서 사용자 프로필 로드
  ///
  /// **특징**:
  /// - 전체 프로필 정보 포함 (bio, interests, points 등)
  /// - Timestamp → DateTime 자동 변환
  /// - Null-safe 기본값 적용
  static AuthUser fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return AuthUser(
      // Authentication fields
      uid: doc.id, // DocumentSnapshot ID를 uid로 사용
      email: data['email'] as String?,
      displayName: data['displayName'] as String?,
      userName: data['userName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      phoneNumber: data['phoneNumber'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool? ?? data['emailVerified'] as bool? ?? false,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      providerId: data['providerId'] as String?,

      // Profile fields
      bio: data['bio'] as String?,
      age: data['age'] as int?,
      gender: data['gender'] as String?,
      interests: _parseStringList(data['interests']),
      expertise: _parseStringList(data['expertise']),
      hobbies: _parseStringList(data['hobbies']),

      // Points & Rewards
      pointsA: data['pointsA'] as int? ?? 0,
      pointsQ: data['pointsQ'] as int? ?? 0,

      // Role & Premium
      role: _parseUserRole(data['role']),
      isPremium: data['isPremium'] as bool? ?? data['isPremiumUser'] as bool? ?? false,

      // Timestamps
      createdAt: _parseDateTime(data['createdAt']),
      lastLoginAt: _parseDateTime(data['lastLoginAt']),

      // Additional
      settings: data['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  // ============================================================================
  // AuthUser → Firestore Map
  // ============================================================================

  /// AuthUser를 Firestore 저장용 Map으로 변환
  ///
  /// **사용처**: Firestore users 컬렉션에 저장
  ///
  /// **특징**:
  /// - DateTime → Timestamp 자동 변환
  /// - null 값은 필드에서 제외
  /// - UserRole → String 변환
  Map<String, dynamic> toFirestore() {
    return {
      // Authentication fields
      'uid': uid,
      if (email != null) 'email': email,
      if (displayName != null) 'displayName': displayName,
      if (userName != null) 'userName': userName,
      if (photoUrl != null) 'photoUrl': photoUrl,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      'isEmailVerified': isEmailVerified,
      'emailVerified': isEmailVerified, // Backward compatibility
      'isAnonymous': isAnonymous,
      if (providerId != null) 'providerId': providerId,

      // Profile fields
      if (bio != null) 'bio': bio,
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      'interests': interests,
      'expertise': expertise,
      'hobbies': hobbies,

      // Points & Rewards
      'pointsA': pointsA,
      'pointsQ': pointsQ,

      // Role & Premium
      'role': role.toValue(),
      'isPremium': isPremium,
      'isPremiumUser': isPremium, // Backward compatibility

      // Timestamps
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      if (lastLoginAt != null) 'lastLoginAt': Timestamp.fromDate(lastLoginAt!),

      // Additional
      if (settings.isNotEmpty) 'settings': settings,
    };
  }

  // ============================================================================
  // Helper Functions
  // ============================================================================

  /// DateTime 타입 안전 파싱
  ///
  /// **지원 타입**:
  /// - Timestamp (Firestore)
  /// - DateTime (Dart)
  /// - String (ISO 8601)
  /// - null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// String 리스트 안전 파싱
  ///
  /// **지원 타입**:
  /// - List<String>
  /// - List<dynamic> (String으로 변환 시도)
  /// - null → 빈 리스트
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List<String>) return value;
    if (value is List) {
      return value
          .where((item) => item is String)
          .map((item) => item as String)
          .toList();
    }
    return [];
  }

  /// UserRole 안전 파싱
  ///
  /// **지원 타입**:
  /// - String → UserRole enum
  /// - null → UserRole.user (기본값)
  static UserRole _parseUserRole(dynamic value) {
    if (value == null) return UserRole.user;
    if (value is String) {
      try {
        return UserRole.fromValue(value);
      } catch (_) {
        return UserRole.user;
      }
    }
    return UserRole.user;
  }
}
