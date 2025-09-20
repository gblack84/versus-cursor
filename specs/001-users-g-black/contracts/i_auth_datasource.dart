// DataSource Interface for Auth Feature
// Data Layer - Clean Architecture
//
// This interface defines the contract for external auth services.
// It will be implemented with Firebase and mocked in tests.

import '../data-model.dart'; // Domain models

/// Auth DataSource Interface - Data Layer
///
/// Low-level interface for auth operations.
/// Separates Firebase implementation from business logic.
abstract class IAuthDataSource {
  // Firebase Auth Operations
  /// Get Firebase Auth current user
  Future<Map<String, dynamic>?> getCurrentFirebaseUser();

  /// Listen to Firebase auth state changes
  Stream<Map<String, dynamic>?> authStateChanges();

  /// Sign in with email/password via Firebase
  Future<Map<String, dynamic>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Create user with email/password via Firebase
  Future<Map<String, dynamic>> createUserWithEmailPassword({
    required String email,
    required String password,
  });

  /// Sign in with Google credential
  Future<Map<String, dynamic>> signInWithGoogleCredential({
    required String accessToken,
    required String? idToken,
  });

  /// Sign in with Apple credential
  Future<Map<String, dynamic>> signInWithAppleCredential({
    required String identityToken,
    required String? authorizationCode,
  });

  /// Send SMS verification code
  Future<String> sendSmsVerification({
    required String phoneNumber,
    required Duration timeout,
  });

  /// Verify SMS code
  Future<Map<String, dynamic>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  /// Sign in anonymously
  Future<Map<String, dynamic>> signInAnonymously();

  /// Get ID token for current user
  Future<String?> getIdToken({bool forceRefresh = false});

  /// Sign out
  Future<void> signOut();

  /// Update user profile
  Future<void> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  });

  /// Delete current user
  Future<void> deleteUser();

  /// Reauthenticate with credential
  Future<void> reauthenticateWithCredential({
    required Map<String, dynamic> credential,
  });
}

/// Local DataSource for caching auth data
abstract class IAuthLocalDataSource {
  /// Cache auth token
  Future<void> cacheAuthToken(AuthToken token);

  /// Get cached auth token
  Future<AuthToken?> getCachedAuthToken();

  /// Clear cached auth data
  Future<void> clearCache();

  /// Cache user data
  Future<void> cacheUserData(Map<String, dynamic> userData);

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData();

  /// Check if user is logged in locally
  Future<bool> isLoggedIn();

  /// Save refresh token
  Future<void> saveRefreshToken(String token);

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Cache user preferences
  Future<void> cacheUserPreferences(Map<String, dynamic> preferences);

  /// Get user preferences
  Future<Map<String, dynamic>?> getUserPreferences();
}

/// User DataSource for Firestore operations
abstract class IUserDataSource {
  /// Create user document in Firestore
  Future<void> createUserDocument({
    required String uid,
    required Map<String, dynamic> userData,
  });

  /// Get user document from Firestore
  Future<Map<String, dynamic>?> getUserDocument({
    required String uid,
  });

  /// Update user document in Firestore
  Future<void> updateUserDocument({
    required String uid,
    required Map<String, dynamic> updates,
  });

  /// Delete user document from Firestore
  Future<void> deleteUserDocument({
    required String uid,
  });

  /// Stream user document changes
  Stream<Map<String, dynamic>?> streamUserDocument({
    required String uid,
  });

  /// Check if user exists
  Future<bool> userExists({
    required String uid,
  });

  /// Get user by email
  Future<Map<String, dynamic>?> getUserByEmail({
    required String email,
  });

  /// Save user session
  Future<void> saveUserSession({
    required String uid,
    required Map<String, dynamic> sessionData,
  });

  /// Get user sessions
  Future<List<Map<String, dynamic>>> getUserSessions({
    required String uid,
  });

  /// Delete user session
  Future<void> deleteUserSession({
    required String uid,
    required String sessionId,
  });
}