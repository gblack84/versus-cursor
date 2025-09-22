import 'package:firebase_auth/firebase_auth.dart';
import '../dto/auth_user_dto.dart';
import '../dto/user_profile_dto.dart';
import '../../domain/models/auth_user.dart';

/// Mapper for converting between Auth DTOs and Domain Models
///
/// Clean Architecture: Data Layer → Domain Layer 변환
/// DTO(외부 데이터) → Domain Model(비즈니스 로직)
class AuthUserMapper {
  /// Firebase User를 Domain Model로 변환
  static AuthUser fromFirebaseUser(User firebaseUser, {UserProfileDto? profile}) {
    // Firebase User를 DTO로 변환 후 Domain Model로 매핑
    final dto = AuthUserDto.fromFirebaseUser(firebaseUser);
    return _fromDto(dto, profile: profile);
  }

  /// AuthUserDto를 Domain Model로 변환
  static AuthUser fromDto(AuthUserDto dto, {UserProfileDto? profile}) {
    return _fromDto(dto, profile: profile);
  }

  /// UserProfileDto를 포함한 통합 변환
  static AuthUser fromDtoWithProfile(AuthUserDto authDto, UserProfileDto profileDto) {
    return _fromDto(authDto, profile: profileDto);
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

  /// Domain Model을 UserProfileDto로 변환
  static UserProfileDto toProfileDto(AuthUser user) {
    return UserProfileDto(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      userName: user.userName,
      profilePic: user.photoUrl,
      bio: user.bio,
      age: user.age,
      gender: user.gender,
      interests: user.interests,
      expertise: user.expertise,
      hobbies: user.hobbies,
      pointsA: user.pointsA,
      pointsQ: user.pointsQ,
      role: user.role,
      isPremium: user.isPremium,
      createdTime: user.createdAt,
      lastActive: user.lastLoginAt,
      settings: user.settings,
    );
  }

  /// Private helper method for DTO to Domain conversion
  static AuthUser _fromDto(AuthUserDto dto, {UserProfileDto? profile}) {
    return AuthUser(
      uid: dto.uid,
      email: dto.email,
      displayName: dto.displayName ?? profile?.displayName,
      userName: profile?.userName,
      photoUrl: dto.photoUrl ?? profile?.profilePic,
      isEmailVerified: dto.emailVerified ?? false,
      phoneNumber: dto.phoneNumber,
      providerId: dto.providerId,
      // Profile specific fields
      bio: profile?.bio,
      age: profile?.age,
      gender: profile?.gender,
      interests: profile?.interests ?? [],
      expertise: profile?.expertise ?? [],
      hobbies: profile?.hobbies ?? [],
      pointsA: profile?.pointsA ?? 0,
      pointsQ: profile?.pointsQ ?? 0,
      role: profile?.role ?? 'user',
      isPremium: profile?.isPremium ?? false,
      // Timestamps
      createdAt: dto.createdAt ?? profile?.createdTime,
      lastLoginAt: dto.lastLoginAt ?? profile?.lastActive,
      // Additional data
      settings: profile?.settings ?? {},
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