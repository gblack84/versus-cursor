// Auth Repository Interface
// Clean Architecture - Domain Layer Interface

import 'package:fpdart/fpdart.dart';

import '../entities/auth_user.dart';
import '../failures/auth_failure.dart';

/// IAuthRepository
///
/// Domain layer interface that defines authentication operations.
/// Presentation layer should only depend on this interface, not on
/// data layer implementations.
abstract class IAuthRepository {
  /// Get currently authenticated user
  Future<Either<AuthFailure, AuthUser>> getCurrentUser();

  /// Sign in with email and password
  Future<Either<AuthFailure, AuthUser>> signInWithEmailAndPassword(String email, String password);

  /// Create user with email and password
  Future<Either<AuthFailure, AuthUser>> createUserWithEmailAndPassword(
      String email, String password);

  /// Sign in with Google
  Future<Either<AuthFailure, AuthUser>> signInWithGoogle();

  /// Sign in with Apple
  Future<Either<AuthFailure, AuthUser>> signInWithApple();

  /// Sign in with phone number
  Future<Either<AuthFailure, AuthUser>> signInWithPhoneNumber(
      String phoneNumber, String verificationCode);

  /// Send SMS OTP code for phone authentication
  Future<Either<AuthFailure, bool>> sendSmsOtp(String phoneNumber);

  /// Sign out current user
  Future<Either<AuthFailure, void>> signOut();

  /// Send password reset email
  Future<Either<AuthFailure, void>> sendPasswordResetEmail(String email);

  /// Send email verification
  Future<Either<AuthFailure, bool>> sendEmailVerification();

  /// Delete current user account
  Future<Either<AuthFailure, bool>> deleteUser();

  /// Update user profile
  Future<Either<AuthFailure, void>> updateUserProfile({
    String? displayName,
    String? photoURL,
  });

  /// Update user password
  /// Requires user to be recently authenticated
  Future<Either<AuthFailure, bool>> updatePassword(String newPassword);

  /// Check if user is signed in
  bool get isSignedIn;

  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges;
}
