// Authentication Repository Implementation
// Clean Architecture - Data Layer

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/auth_user.dart';
import '../../domain/entities/auth_user_extensions.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../domain/failures/auth_failure.dart';
import '../../../../services/cache/unified_cache_service.dart';

/// AuthRepositoryImpl
///
/// **Firebase-Centric Architecture v2.0 - UnifiedCacheService 통합**:
/// - FirebaseAuth 직접 사용
/// - DTO/Mapper 제거
/// - Extension으로 변환 처리
/// - 3-Layer 캐싱 (Memory → Hive → Firestore)
///
/// Concrete implementation of IAuthRepository.
/// Handles Firebase Authentication and 3-Layer caching.
class AuthRepositoryImpl implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;

  // Google Sign-In 인스턴스
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
    // localDataSource parameter 제거 - UnifiedCacheService는 싱글톤
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<Either<AuthFailure, AuthUser>> getCurrentUser() async {
    try {
      // Get current Firebase Auth user
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // ✅ Cache-first strategy
      final cachedUser = await _cacheService.getAuthUser(firebaseUser.uid);
      if (cachedUser != null) {
        return right(cachedUser);
      }

      // Cache miss: Convert to domain model and cache
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Sign in with Firebase
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 2. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 3. Cache auth data (3-Layer)
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error signing in with email/password: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> createUserWithEmailAndPassword(String email, String password) async {
    try {
      // 1. Create user with Firebase Auth
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 2. Create profile in Firestore users collection
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
        'uid': firebaseUser.uid,
        'email': firebaseUser.email ?? '',
        'displayName': firebaseUser.displayName ?? '',
        'photoUrl': null,
        'phoneNumber': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 3. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 4. Cache auth data (3-Layer)
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error creating user with email/password: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return left(const AuthFailure.cancelledByUser());
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
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 5. Create profile in Firestore users collection if new user
      try {
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'displayName': firebaseUser.displayName ?? '',
          'photoUrl': firebaseUser.photoURL,
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // 6. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 7. Cache auth data (3-Layer)
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error signing in with Google: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithApple() async {
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
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 4. Create profile in Firestore users collection if new user
      try {
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'displayName': firebaseUser.displayName ?? '',
          'photoUrl': firebaseUser.photoURL,
          'phoneNumber': null,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // 5. Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // 6. Cache auth data (3-Layer)
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error signing in with Apple: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  // Phone verification ID storage (in-memory for simplicity)
  String? _verificationId;

  @override
  Future<Either<AuthFailure, bool>> sendSmsOtp(String phoneNumber) async {
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
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error sending SMS OTP: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, AuthUser>> signInWithPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      if (_verificationId == null) {
        return left(const AuthFailure.invalidSmsCode());
      }

      // Create credential with verification code
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: verificationCode,
      );

      // Sign in with credential
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return left(const AuthFailure.userNotFound());
      }

      // Create profile in Firestore users collection if new user
      try {
        await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'displayName': '',
          'photoUrl': null,
          'phoneNumber': phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        // Profile already exists, ignore error
        debugPrint('Profile creation skipped (may already exist): $e');
      }

      // Convert to domain model using Extension
      final authUser = AuthUserFirestore.fromFirebaseUser(firebaseUser);

      // Cache auth data (3-Layer)
      await _cacheService.setAuthUser(
        authUser.uid,
        authUser,
        ttl: const Duration(hours: 24),
      );

      // Clear verification ID
      _verificationId = null;

      return right(authUser);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error signing in with phone number: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      // Clear local cache first (3-Layer)
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId != null) {
        await _cacheService.clearAuthUser(userId);
        await _cacheService.clearAuthToken(userId);
      }

      // Sign out from Google if signed in
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      // Sign out from Firebase
      await _firebaseAuth.signOut();

      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error signing out: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(const AuthFailure.userNotFound());
      }

      await user.sendEmailVerification();
      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error sending email verification: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, bool>> deleteUser() async {
    try {
      // 0. Get user ID before deletion (Firebase Auth 삭제 전 필요)
      final userId = _firebaseAuth.currentUser?.uid;
      if (userId == null) {
        return left(const AuthFailure.userNotFound());
      }

      // 1. Clear local cache (3-Layer)
      await _cacheService.clearAuthUser(userId);
      await _cacheService.clearAuthToken(userId);

      // 2. Delete Firestore profile document
      // ⚠️ Firebase Auth 삭제 전에 실행해야 함 (userId 필요)
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();
      debugPrint('Firestore profile deleted for user: $userId');

      // 3. Delete Firebase Auth account
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
        debugPrint('Firebase Auth account deleted');
      }

      return right(true);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error deleting user: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        return left(const AuthFailure.userNotFound());
      }

      // Update Firebase Auth profile
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);

      // Update Firestore profile
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoURL != null) updateData['photoUrl'] = photoURL;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updateData);

      return right(null);
    } on FirebaseAuthException catch (e) {
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  @override
  bool get isSignedIn {
    return _firebaseAuth.currentUser != null;
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
  Future<Either<AuthFailure, bool>> updatePassword(String newPassword) async {
    try {
      debugPrint('Attempting to update password...');

      // Check if user is signed in
      if (!isSignedIn) {
        return left(const AuthFailure.userNotFound());
      }

      final user = _firebaseAuth.currentUser!;

      // Update password
      await user.updatePassword(newPassword);

      debugPrint('Password updated successfully');
      return right(true);
    } on FirebaseAuthException catch (e) {
      debugPrint('Password update failed with Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseAuthException(e));
    } catch (e) {
      debugPrint('Password update failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Map FirebaseAuthException to AuthFailure
  ///
  /// **Firebase-Centric v2.0 Pattern**: Repository는 Firebase 에러를 Domain Failure로 변환
  AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      // Email & Password errors
      case 'invalid-email':
        return const AuthFailure.invalidEmail();
      case 'weak-password':
        return const AuthFailure.weakPassword();
      case 'email-already-in-use':
        return const AuthFailure.emailAlreadyInUse();
      case 'user-not-found':
        return const AuthFailure.userNotFound();
      case 'wrong-password':
        return const AuthFailure.invalidCredentials();

      // Phone auth errors
      case 'invalid-phone-number':
        return const AuthFailure.invalidPhoneNumber();
      case 'invalid-verification-code':
        return const AuthFailure.invalidSmsCode();
      case 'expired-action-code':
        return const AuthFailure.smsCodeExpired();

      // User state errors
      case 'user-disabled':
        return const AuthFailure.userDisabled();

      // Permission errors
      case 'requires-recent-login':
        return const AuthFailure.requiresRecentLogin();

      // Network errors
      case 'network-request-failed':
        return const AuthFailure.networkError();

      // Default
      default:
        return AuthFailure.unexpected(e.message ?? 'Firebase Auth Error: ${e.code}');
    }
  }
}