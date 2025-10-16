// Authentication Repository Implementation
// Clean Architecture - Data Layer

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_remote_datasource.dart';
import '../datasources/i_auth_local_datasource.dart';
import '/app/contracts/auth_contract.dart';
import '/app/contracts/user_contract.dart';
import '../dto/auth_user_dto.dart';
import '../mappers/auth_user_mapper.dart';

/// AuthRepositoryImpl
///
/// Concrete implementation of IAuthRepository.
/// Coordinates between remote and local data sources,
/// handles caching, and maps DTOs to domain models.
class AuthRepositoryImpl implements IAuthRepository, AuthContract {
  final IAuthRemoteDataSource _remoteDataSource;
  final IAuthLocalDataSource _localDataSource;
  final UserContract _userContract;

  AuthRepositoryImpl({
    required IAuthRemoteDataSource remoteDataSource,
    required IAuthLocalDataSource localDataSource,
    required UserContract userContract,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource,
        _userContract = userContract;

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // Get current Firebase Auth user
      final firebaseUser = _remoteDataSource.getCurrentFirebaseUser();
      if (firebaseUser == null) return null;

      // Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
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

      // 2. Cache auth data only
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);

      // 3. Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
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

      // 2. Create profile via UserContract (Profile Feature)
      await _userContract.createUserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
      );

      // 3. Cache auth data only
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);

      // 4. Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
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

      // 2. Check if user profile exists via UserContract
      // Note: Profile Feature will handle profile existence check
      try {
        await _userContract.createUserProfile(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
        );
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // 3. Cache auth data only
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);

      // 4. Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    try {
      // Sign in with Apple
      final firebaseUser = await _remoteDataSource.signInWithApple();

      // Create profile via UserContract if new user
      try {
        await _userContract.createUserProfile(
          uid: firebaseUser.uid,
          email: firebaseUser.email,
          displayName: firebaseUser.displayName,
        );
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // Cache auth data only
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);

      // Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
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

      // Create profile via UserContract if new user
      try {
        await _userContract.createUserProfile(
          uid: firebaseUser.uid,
          phoneNumber: phoneNumber,
        );
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // Cache auth data only
      final authDto = AuthUserDto.fromFirebaseUser(firebaseUser);
      await _localDataSource.cacheAuthUser(authDto);

      // Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
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
      // 0. Get user ID before deletion (Firebase Auth 삭제 전 필요)
      final userId = getCurrentUserId();
      if (userId == null) {
        debugPrint('Cannot delete user: No user signed in');
        return false;
      }

      // 1. Clear local cache
      await _localDataSource.clearAllCache();

      // 2. Delete Firestore profile document (Profile Feature via UserContract)
      // ⚠️ Firebase Auth 삭제 전에 실행해야 함 (userId 필요)
      await _userContract.deleteUserProfile(userId);
      debugPrint('Firestore profile deleted for user: $userId');

      // 3. Delete Firebase Auth account
      await _remoteDataSource.deleteUser();
      debugPrint('Firebase Auth account deleted');

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

      // Update Firestore profile via UserContract
      final currentUser = _remoteDataSource.getCurrentFirebaseUser();
      if (currentUser != null) {
        final updateData = <String, dynamic>{};
        if (displayName != null) updateData['displayName'] = displayName;
        if (photoURL != null) updateData['photoUrl'] = photoURL;

        await _userContract.updateUserProfileData(currentUser.uid, updateData);
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
      return await _remoteDataSource.getIdToken();
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      return await _remoteDataSource.getIdToken(forceRefresh: true);
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
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
  String? get currentUserDisplayName {
    return _remoteDataSource.getCurrentFirebaseUser()?.displayName;
  }

  @override
  String? get currentUserPhoto {
    return _remoteDataSource.getCurrentFirebaseUser()?.photoURL;
  }

  @override
  String? get currentPhoneNumber {
    return _remoteDataSource.getCurrentFirebaseUser()?.phoneNumber;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _remoteDataSource.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      // Convert to domain model (Auth data only, no profile)
      return AuthUserMapper.fromFirebaseUser(firebaseUser);
    });
  }

  @override
  Future<bool> updatePassword(String newPassword) async {
    try {
      debugPrint('Attempting to update password...');

      // Check if user is signed in
      if (!isSignedIn) {
        debugPrint('No user signed in');
        return false;
      }

      // Call remote data source to update password
      await _remoteDataSource.updatePassword(newPassword);

      debugPrint('Password updated successfully');
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('Password update failed with Firebase error: ${e.code} - ${e.message}');

      // Handle specific errors
      if (e.code == 'requires-recent-login') {
        debugPrint('User needs to re-authenticate before updating password');
      } else if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak');
      }

      return false;
    } catch (e) {
      debugPrint('Password update failed with unexpected error: $e');
      return false;
    }
  }
}