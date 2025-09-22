// Firebase User Mapper
// Clean Architecture - Data Layer

import 'package:firebase_auth/firebase_auth.dart' as firebase;
import '../../domain/models/auth_user.dart';
import '../dto/auth_user_dto.dart';
import '../dto/user_profile_dto.dart';

/// FirebaseUserMapper
///
/// Maps Firebase Auth User to domain models and DTOs.
/// Handles conversion between Firebase-specific format and our domain.
class FirebaseUserMapper {
  /// Convert Firebase User to Domain Model
  static AuthUser toDomain(firebase.User firebaseUser, {UserProfileDto? profile}) {
    return AuthUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: profile?.displayName ?? firebaseUser.displayName,
      photoUrl: profile?.profilePic ?? firebaseUser.photoURL,
      phoneNumber: profile?.phoneNumber ?? firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified,
      isAnonymous: firebaseUser.isAnonymous,
      providerId: _getProviderId(firebaseUser),
      createdAt: profile?.createdTime ??
        (firebaseUser.metadata.creationTime ?? DateTime.now()),
      lastLoginAt: profile?.lastActive ?? DateTime.now(),
      role: profile?.role ?? 'user',
      isPremium: profile?.isPremium ?? false,
      settings: _buildMetadata(firebaseUser, profile),
    );
  }

  /// Convert Firebase User to DTO
  static AuthUserDto toDto(firebase.User firebaseUser, {UserProfileDto? profile}) {
    return AuthUserDto(
      uid: firebaseUser.uid,
      email: firebaseUser.email,
      displayName: profile?.displayName ?? firebaseUser.displayName,
      photoUrl: profile?.profilePic ?? firebaseUser.photoURL,
      phoneNumber: profile?.phoneNumber ?? firebaseUser.phoneNumber,
      emailVerified: firebaseUser.emailVerified,
      providerId: _getProviderId(firebaseUser),
      createdAt: profile?.createdTime ??
        (firebaseUser.metadata.creationTime ?? DateTime.now()),
      lastLoginAt: profile?.lastActive ?? DateTime.now(),
      metadata: _buildMetadata(firebaseUser, profile),
    );
  }

  /// Get provider ID from Firebase User
  static String _getProviderId(firebase.User user) {
    if (user.providerData.isNotEmpty) {
      // Get the first non-firebase provider
      for (final provider in user.providerData) {
        if (provider.providerId != 'firebase') {
          return provider.providerId;
        }
      }
    }

    // Fallback based on auth method
    if (user.email != null && !user.isAnonymous) {
      return 'password';
    } else if (user.phoneNumber != null) {
      return 'phone';
    } else if (user.isAnonymous) {
      return 'anonymous';
    }

    return 'unknown';
  }

  /// Build metadata from Firebase User and Profile
  static Map<String, dynamic> _buildMetadata(
    firebase.User user,
    UserProfileDto? profile,
  ) {
    final metadata = <String, dynamic>{
      'firebaseUid': user.uid,
      'emailVerified': user.emailVerified,
      'isAnonymous': user.isAnonymous,
      'creationTime': user.metadata.creationTime?.toIso8601String(),
      'lastSignInTime': user.metadata.lastSignInTime?.toIso8601String(),
      'providers': user.providerData.map((p) => p.providerId).toList(),
    };

    // Add profile metadata if available
    if (profile != null) {
      metadata.addAll({
        'interests': profile.interests,
        'expertise': profile.expertise,
        'hobbies': profile.hobbies,
        'pointsA': profile.pointsA,
        'pointsQ': profile.pointsQ,
        'location': profile.location,
        'bio': profile.bio,
      });
    }

    return metadata;
  }

  /// Create minimal AuthUser from Firebase UID
  static AuthUser fromUid(String uid) {
    return AuthUser(
      uid: uid,
      isEmailVerified: false,
      isAnonymous: false,
      providerId: 'unknown',
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
      role: 'user',
      isPremium: false,
    );
  }

  /// Check if Firebase User needs profile update
  static bool needsProfileUpdate(
    firebase.User firebaseUser,
    UserProfileDto? profile,
  ) {
    if (profile == null) return true;

    // Check if basic info has changed
    if (firebaseUser.displayName != null &&
        firebaseUser.displayName != profile.displayName) {
      return true;
    }

    if (firebaseUser.photoURL != null &&
        firebaseUser.photoURL != profile.profilePic) {
      return true;
    }

    if (firebaseUser.email != null &&
        firebaseUser.email != profile.email) {
      return true;
    }

    if (firebaseUser.phoneNumber != null &&
        firebaseUser.phoneNumber != profile.phoneNumber) {
      return true;
    }

    return false;
  }
}