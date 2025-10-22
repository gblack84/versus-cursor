import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_user_dto.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/enums/user_role.dart';

/// Mapper for converting between Auth DTOs and Domain Models
///
/// Clean Architecture: Data Layer → Domain Layer 변환
/// DTO(외부 데이터) → Domain Model(비즈니스 로직)
///
/// Phase 4: 프로필 관련 메서드 제거 완료
/// Auth Feature는 Firebase Authentication 데이터만 처리
class AuthUserMapper {
  /// Firebase User를 Domain Model로 변환 (Auth 데이터만)
  static AuthUser fromFirebaseUser(User firebaseUser) {
    // Firebase User를 DTO로 변환 후 Domain Model로 매핑
    final dto = AuthUserDto.fromFirebaseUser(firebaseUser);
    return _fromDto(dto);
  }

  /// AuthUserDto를 Domain Model로 변환 (Auth 데이터만)
  static AuthUser fromDto(AuthUserDto dto) {
    return _fromDto(dto);
  }

  /// Domain Model을 AuthUserDto로 변환
  static AuthUserDto toAuthDto(AuthUser user) {
    return AuthUserDto(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      emailVerified: user.isEmailVerified,
      phoneNumber: user.phoneNumber,
      providerId: user.providerId,
      createdAt: user.createdAt,
      lastLoginAt: user.lastLoginAt,
      metadata: {
        'role': user.role,
        'isPremium': user.isPremium,
      },
    );
  }

  /// Private helper method for DTO to Domain conversion (Auth data only)
  static AuthUser _fromDto(AuthUserDto dto) {
    return AuthUser(
      uid: dto.uid,
      email: dto.email,
      displayName: dto.displayName,
      userName: null,  // Profile Feature에서 관리
      photoUrl: dto.photoUrl,
      isEmailVerified: dto.emailVerified ?? false,
      phoneNumber: dto.phoneNumber,
      providerId: dto.providerId,
      // Profile specific fields - 기본값만 제공
      bio: null,
      age: null,
      gender: null,
      interests: [],
      expertise: [],
      hobbies: [],
      pointsA: 0,
      pointsQ: 0,
      role: UserRole.user,
      isPremium: false,
      // Timestamps
      createdAt: dto.createdAt,
      lastLoginAt: dto.lastLoginAt,
      // Additional data
      settings: {},
    );
  }

  /// Provider 정보로부터 로그인 타입 판별
  static String detectAuthProvider(User firebaseUser) {
    if (firebaseUser.providerData.isEmpty) {
      return 'email';
    }

    final providerId = firebaseUser.providerData[0].providerId;
    switch (providerId) {
      case 'google.com':
        return 'google';
      case 'apple.com':
        return 'apple';
      case 'phone':
        return 'phone';
      case 'github.com':
        return 'github';
      case 'password':
        return 'email';
      default:
        return providerId;
    }
  }

  /// 익명 사용자 체크
  static bool isAnonymous(User firebaseUser) {
    return firebaseUser.isAnonymous;
  }
}