// Auth Repository Interface
// Clean Architecture - Domain Layer Interface

import '../models/auth_user.dart';

/// IAuthRepository
/// 
/// Domain layer interface that defines authentication operations.
/// Presentation layer should only depend on this interface, not on 
/// data layer implementations.
abstract class IAuthRepository {
  /// Get currently authenticated user
  Future<AuthUser?> getCurrentUser();
  
  /// Sign in with email and password
  Future<AuthUser?> signInWithEmailAndPassword(String email, String password);
  
  /// Create user with email and password  
  Future<AuthUser?> createUserWithEmailAndPassword(String email, String password);
  
  /// Sign in with Google
  Future<AuthUser?> signInWithGoogle();
  
  /// Sign in with Apple
  Future<AuthUser?> signInWithApple();
  
  /// Sign in with phone number
  Future<AuthUser?> signInWithPhoneNumber(String phoneNumber, String verificationCode);
  
  /// Sign out current user
  Future<void> signOut();
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email);
  
  /// Send email verification
  Future<void> sendEmailVerification();
  
  /// Delete current user account
  Future<void> deleteUser();
  
  /// Update user profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  });
  
  /// Check if user is signed in
  bool get isSignedIn;
  
  /// Stream of auth state changes
  Stream<AuthUser?> get authStateChanges;
}