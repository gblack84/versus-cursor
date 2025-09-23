// Authentication Repository Implementation
// Clean Architecture - Data Layer

import 'package:flutter/foundation.dart';

import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_remote_datasource.dart';
import '../datasources/i_auth_local_datasource.dart';
import '/app/contracts/auth_contract.dart';
import '../dto/auth_user_dto.dart';
import '../dto/user_profile_dto.dart';
import '../mappers/auth_user_mapper.dart';

/// AuthRepositoryImpl
///
/// Concrete implementation of IAuthRepository.
/// Coordinates between remote and local data sources,
/// handles caching, and maps DTOs to domain models.
class AuthRepositoryImpl implements IAuthRepository, AuthContract {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // 1. Check Firebase Auth for current user
      final firebaseUser = _remoteDataSource.getCurrentFirebaseUser();
      if (firebaseUser == null) return null;

      // 2. Try to get cached profile first
      final cachedProfile = await _localDataSource.getCachedUserProfile(firebaseUser.uid);
      if (cachedProfile != null) {
        return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: cachedProfile);
      }

      // 3. If no cache, fetch from Firestore
      final profile = await _remoteDataSource.getUserProfile(firebaseUser.uid);

      // 4. Cache the profile for future use
      if (profile != null) {
        await _localDataSource.cacheUserProfile(profile);
      }

      // 5. Convert to domain model
      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Sign in with Firebase
      final firebaseUser = await _remoteDataSource.signInWithEmailAndPassword(email, password);

      // 2. Get user profile from Firestore
      final profile = await _remoteDataSource.getUserProfile(firebaseUser.uid);

      // 3. Cache user data
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);
      if (profile != null) {
        await _localDataSource.cacheUserProfile(profile);
      }

      // 4. Convert to domain model
      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error signing in with email/password: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Create user with Firebase Auth
      final firebaseUser = await _remoteDataSource.createUserWithEmailAndPassword(email, password);

      // 2. Create initial user profile in Firestore
      final profile = UserProfileDto(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
        createdTime: DateTime.now(),
        lastActive: DateTime.now(),
        role: 'user',
        isPremium: false,
        pointsA: 0,
        pointsQ: 0,
        interests: [],
        expertise: [],
        hobbies: [],
      );

      await _remoteDataSource.createUserProfile(firebaseUser.uid, profile);

      // 3. Cache user data
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);
      await _localDataSource.cacheUserProfile(profile);

      // 4. Convert to domain model
      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error creating user with email/password: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // 1. Sign in with Google
      final firebaseUser = await _remoteDataSource.signInWithGoogle();

      // 2. Check if user profile exists
      var profile = await _remoteDataSource.getUserProfile(firebaseUser.uid);

      // 3. Create profile if new user
      if (profile == null) {
        profile = UserProfileDto(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          profilePic: firebaseUser.photoURL,
          createdTime: DateTime.now(),
          lastActive: DateTime.now(),
          role: 'user',
          isPremium: false,
          pointsA: 0,
          pointsQ: 0,
          interests: [],
          expertise: [],
          hobbies: [],
        );
        await _remoteDataSource.createUserProfile(firebaseUser.uid, profile);
      }

      // 4. Cache user data
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);
      await _localDataSource.cacheUserProfile(profile);

      // 5. Convert to domain model
      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    try {
      // Similar to Google sign in
      final firebaseUser = await _remoteDataSource.signInWithApple();

      var profile = await _remoteDataSource.getUserProfile(firebaseUser.uid);

      if (profile == null) {
        profile = UserProfileDto(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          createdTime: DateTime.now(),
          lastActive: DateTime.now(),
          role: 'user',
          isPremium: false,
          pointsA: 0,
          pointsQ: 0,
          interests: [],
          expertise: [],
          hobbies: [],
        );
        await _remoteDataSource.createUserProfile(firebaseUser.uid, profile);
      }

      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);
      await _localDataSource.cacheUserProfile(profile);

      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendSmsOtp(String phoneNumber) async {
    try {
      // Firebase Auth handles SMS OTP sending internally through verifyPhoneNumber
      // This is typically called before signInWithPhoneNumber
      await _remoteDataSource.sendSmsOtp(phoneNumber);
      debugPrint('SMS OTP sent successfully to: $phoneNumber');
      return true;
    } catch (e) {
      debugPrint('Error sending SMS OTP: $e');
      return false;
    }
  }

  @override
  Future<AuthUser?> signInWithPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      final firebaseUser = await _remoteDataSource.signInWithPhoneNumber(phoneNumber, verificationCode);

      var profile = await _remoteDataSource.getUserProfile(firebaseUser.uid);

      if (profile == null) {
        profile = UserProfileDto(
          uid: firebaseUser.uid,
          phoneNumber: phoneNumber,
          createdTime: DateTime.now(),
          lastActive: DateTime.now(),
          role: 'user',
          isPremium: false,
          pointsA: 0,
          pointsQ: 0,
          interests: [],
          expertise: [],
          hobbies: [],
        );
        await _remoteDataSource.createUserProfile(firebaseUser.uid, profile);
      }

      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);
      await _localDataSource.cacheUserProfile(profile);

      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    } catch (e) {
      debugPrint('Error signing in with phone number: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      // Clear local cache first
      await _localDataSource.clearAllCache();

      // Then sign out from Firebase
      await _remoteDataSource.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _remoteDataSource.sendPasswordResetEmail(email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendEmailVerification() async {
    try {
      await _remoteDataSource.sendEmailVerification();
      return true;
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      return false;
    }
  }

  @override
  Future<bool> deleteUser() async {
    try {
      // Clear local cache
      await _localDataSource.clearAllCache();

      // Delete from Firebase
      await _remoteDataSource.deleteUser();
      return true;
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return false;
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      // Update Firebase Auth profile
      await _remoteDataSource.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Update Firestore profile
      final currentUser = _remoteDataSource.getCurrentFirebaseUser();
      if (currentUser != null) {
        final updateData = <String, dynamic>{};
        if (displayName != null) updateData['displayName'] = displayName;
        if (photoURL != null) updateData['profilePic'] = photoURL;
        updateData['lastActive'] = DateTime.now();

        await _remoteDataSource.updateUserProfileData(currentUser.uid, updateData);

        // Clear cache to force reload with new data
        await _localDataSource.clearCachedUserProfile(currentUser.uid);
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  @override
  bool get isSignedIn {
    return _remoteDataSource.getCurrentFirebaseUser() != null;
  }

  // AuthContract 구현
  @override
  String? getCurrentUserId() {
    return _remoteDataSource.getCurrentFirebaseUser()?.uid;
  }

  @override
  String? getCurrentUserEmail() {
    return _remoteDataSource.getCurrentFirebaseUser()?.email;
  }

  @override
  Future<String?> getIdToken() async {
    try {
      final user = _remoteDataSource.getCurrentFirebaseUser();
      if (user == null) return null;
      // Firebase User의 getIdToken 메서드 호출이 필요함
      // 현재 datasource에 이 메서드가 없으므로 추가 필요
      return null; // TODO: Implement in datasource
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    // getIdToken(true)는 토큰을 강제로 갱신함
    return getIdToken();
  }

  @override
  bool get isEmailVerified {
    return _remoteDataSource.getCurrentFirebaseUser()?.emailVerified ?? false;
  }

  @override
  bool get isAnonymous {
    return _remoteDataSource.getCurrentFirebaseUser()?.isAnonymous ?? false;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      // Try to get profile from cache or Firestore
      var profile = await _localDataSource.getCachedUserProfile(firebaseUser.uid);
      profile ??= await _remoteDataSource.getUserProfile(firebaseUser.uid);

      return AuthUserMapper.fromFirebaseUser(firebaseUser, profile: profile);
    });
  }
}