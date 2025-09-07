// Auth Repository Implementation
// Clean Architecture - Data Layer Implementation

import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/models/auth_user.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../services/auth_util.dart' as auth_util;
import 'dart:async';

/// AuthRepositoryImpl
/// 
/// Data layer implementation of IAuthRepository interface.
/// Handles Firebase Authentication operations and data transformation.
class AuthRepositoryImpl implements IAuthRepository {
  AuthRepositoryImpl({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthUser?> getCurrentUser() async {
    try {
      final firebaseUser = _firebaseAuth.currentUser;
      return firebaseUser != null ? AuthUser.fromFirebaseUser(firebaseUser) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null ? AuthUser.fromFirebaseUser(credential.user!) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user != null ? AuthUser.fromFirebaseUser(credential.user!) : null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // TODO: Implement Google sign in integration
    // For now, delegate to existing auth_util system
    return getCurrentUser();
  }

  @override
  Future<AuthUser?> signInWithApple() async {
    // TODO: Implement Apple sign in integration  
    // For now, delegate to existing auth_util system
    return getCurrentUser();
  }

  @override
  Future<AuthUser?> signInWithPhoneNumber(String phoneNumber, String verificationCode) async {
    try {
      // This would require implementing phone auth flow
      // For now, delegate to auth_util
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await auth_util.authManager.signOut();
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> deleteUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.delete();
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await user.updatePhotoURL(photoURL);
      }
    } catch (e) {
      // Handle error silently for now
    }
  }

  @override
  bool get isSignedIn {
    return _firebaseAuth.currentUser != null;
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      return firebaseUser != null ? AuthUser.fromFirebaseUser(firebaseUser) : null;
    });
  }
}