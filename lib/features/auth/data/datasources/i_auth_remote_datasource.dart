// Remote DataSource Interface for Authentication
// Clean Architecture - Data Layer

import 'package:firebase_auth/firebase_auth.dart';
import '../dto/user_profile_dto.dart';

/// IAuthRemoteDataSource
///
/// Interface for remote authentication operations using Firebase
abstract class IAuthRemoteDataSource {
  /// Get current Firebase user
  User? getCurrentFirebaseUser();

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Create user with email and password
  Future<User> createUserWithEmailAndPassword(String email, String password);

  /// Sign in with Google
  Future<User> signInWithGoogle();

  /// Sign in with Apple
  Future<User> signInWithApple();

  /// Sign in with phone number
  Future<User> signInWithPhoneNumber(
      String phoneNumber, String verificationCode);

  /// Send SMS OTP for phone authentication
  Future<void> sendSmsOtp(String phoneNumber);

  /// Sign out
  Future<void> signOut();

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Delete user
  Future<void> deleteUser();

  /// Update user display name and photo
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Stream of auth state changes
  Stream<User?> authStateChanges();

  /// Get user profile from Firestore
  Future<UserProfileDto?> getUserProfile(String uid);

  /// Create user profile in Firestore
  Future<void> createUserProfile(String uid, UserProfileDto profile);

  /// Update user profile in Firestore
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data);
}