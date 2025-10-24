// Authentication Repository Implementation
// Clean Architecture - Data Layer

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/auth_user_extensions.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../datasources/i_auth_local_datasource.dart';
import '/app/contracts/auth_contract.dart';
import '/app/contracts/user_contract.dart';

/// AuthRepositoryImpl
///
/// **Firebase 최적화 v1.0 - Remote DataSource 제거**:
/// - FirebaseAuth 직접 사용
/// - DTO/Mapper 제거
/// - Extension으로 변환 처리
///
/// Concrete implementation of IAuthRepository.
/// Handles Firebase Authentication and local caching.
class AuthRepositoryImpl implements IAuthRepository, AuthContract {
  final FirebaseAuth _firebaseAuth;
  final IAuthLocalDataSource _localDataSource;
  final UserContract _userContract;

  // Google Sign-In 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    required IAuthLocalDataSource localDataSource,
    required UserContract userContract,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _localDataSource = localDataSource,
        _userContract = userContract;

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      // Get current Firebase Auth user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Convert to domain model using Extension
      return AuthUserFirestore.fromFirebaseUser(firebaseUser);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      // 2. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 3. Cache auth data
      await _localDataSource.cacheAuthUser(authUser);

      return authUser;
    } catch (e) {
      debugPrint('Error signing in with email/password: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Create user with Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user!;

      // 2. Create profile via UserContract (Profile Feature)
      await _userContract.createUserProfile(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        displayName: firebaseUser.displayName,
      );

      // 3. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 4. Cache auth data
      await _localDataSource.cacheAuthUser(authUser);

      return authUser;
    } catch (e) {
      debugPrint('Error creating user with email/password: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }

      // 2. Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

      // 5. Create profile via UserContract if new user
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

      // 6. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 7. Cache auth data
      await _localDataSource.cacheAuthUser(authUser);

      return authUser;
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    try {
      // 1. Trigger Apple Sign-In
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // 2. Create Firebase credential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      // 3. Sign in to Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      final firebaseUser = userCredential.user!;

      // 4. Create profile via UserContract if new user
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

      // 5. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 6. Cache auth data
      await _localDataSource.cacheAuthUser(authUser);

      return authUser;
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      rethrow;
    }
  }

  // Phone verification ID storage (in-memory for simplicity)
  String? _verificationId;

  @override
  Future<bool> sendSmsOtp(String phoneNumber) async {
    try {
      // Firebase Auth handles SMS OTP sending through verifyPhoneNumber
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          await _firebaseAuth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Phone verification failed: ${e.message}');
          throw e;
        },
        codeSent: (String verificationId, int? resendToken) {
          // Store verification ID for later use
          _verificationId = verificationId;
          debugPrint('SMS OTP sent successfully to: $phoneNumber');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
      return true;
    } catch (e) {
      debugPrint('Error sending SMS OTP: $e');
      return false;
    }
  }

  @override
  Future<AuthUser?> signInWithPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      if (_verificationId == null) {
        throw Exception('Verification ID is null. Please call sendSmsOtp first.');
      }

      // Create credential with verification code
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: verificationCode,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user!;

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

      // Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // Cache auth data
      await _localDataSource.cacheAuthUser(authUser);

      // Clear verification ID
      _verificationId = null;

      return authUser;
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

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Error signing out: $e');
      rethrow;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      rethrow;
    }
  }

  @override
  Future<bool> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        debugPrint('No user signed in');
        return false;
      }

      await user.sendEmailVerification();
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
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('Firebase Auth account deleted');
      }

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
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw Exception('No user signed in');
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      // Update Firestore profile via UserContract
      final updateData = <String, dynamic>{};
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoUrl'] = photoURL;

      await _userContract.updateUserProfileData(user.uid, updateData);
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      rethrow;
    }
  }

  @override
  bool get isSignedIn {
    return _firebaseAuth.currentUser != null;
  }

  // AuthContract 구현
  @override
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }

  @override
  String? getCurrentUserEmail() {
    return _firebaseAuth.currentUser?.email;
  }

  @override
  Future<String?> getIdToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await user.getIdToken();
    } catch (e) {
      debugPrint('Error getting ID token: $e');
      return null;
    }
  }

  @override
  Future<String?> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await user.getIdToken(true); // forceRefresh = true
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      return null;
    }
  }

  @override
  bool get isEmailVerified {
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  bool get isAnonymous {
    return _firebaseAuth.currentUser?.isAnonymous ?? false;
  }

  @override
  String? get currentUserDisplayName {
    return _firebaseAuth.currentUser?.displayName;
  }

  @override
  String? get currentUserPhoto {
    return _firebaseAuth.currentUser?.photoURL;
  }

  @override
  String? get currentPhoneNumber {
    return _firebaseAuth.currentUser?.phoneNumber;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;

      // Convert to domain model using Extension
      return AuthUserFirestore.fromFirebaseUser(firebaseUser);
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

      final user = _firebaseAuth.currentUser!;

      // Update password
      await user.updatePassword(newPassword);

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