// Repository Interface for Auth Feature
// Domain Layer - Clean Architecture
//
// This interface defines the contract for auth operations.
// It will be implemented in the data layer and mocked in tests.

import '../data-model.dart'; // Domain models

/// Auth Repository Interface - Domain Layer
///
/// All methods return Result<T> for testable error handling.
/// Stream for reactive auth state changes.
abstract class IAuthRepository {
  // Reactive Auth State
  /// Stream of authentication state changes
  /// Emits new state when user logs in/out or token refreshes
  Stream<AuthState> get authStateChanges;

  // Current User
  /// Get current authenticated user
  /// Returns null if not authenticated
  Future<Result<AuthUser?>> getCurrentUser();

  // Email Authentication
  /// Sign in with email and password
  Future<Result<AuthUser>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create new account with email and password
  Future<Result<AuthUser>> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  /// Send password reset email
  Future<Result<void>> sendPasswordResetEmail({
    required String email,
  });

  /// Verify email with action code
  Future<Result<void>> verifyEmail({
    required String actionCode,
  });

  // Social Authentication
  /// Sign in with Google
  Future<Result<AuthUser>> signInWithGoogle();

  /// Sign in with Apple
  Future<Result<AuthUser>> signInWithApple();

  /// Sign in with GitHub
  Future<Result<AuthUser>> signInWithGithub();

  // Phone Authentication
  /// Send SMS verification code
  Future<Result<String>> sendSmsCode({
    required String phoneNumber,
  });

  /// Verify SMS code and sign in
  Future<Result<AuthUser>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  });

  // Anonymous Authentication
  /// Sign in anonymously
  Future<Result<AuthUser>> signInAnonymously();

  /// Link anonymous account to permanent account
  Future<Result<AuthUser>> linkAnonymousAccount({
    required AuthCredentials credentials,
  });

  // Token Management
  /// Get current access token
  Future<Result<AuthToken?>> getAccessToken();

  /// Refresh access token
  Future<Result<AuthToken>> refreshToken();

  /// Validate token is not expired
  Future<Result<bool>> isTokenValid();

  // User Profile
  /// Update user display name
  Future<Result<void>> updateDisplayName({
    required String displayName,
  });

  /// Update user photo URL
  Future<Result<void>> updatePhotoUrl({
    required String photoUrl,
  });

  /// Update user email
  Future<Result<void>> updateEmail({
    required String newEmail,
    required String password,
  });

  /// Update user password
  Future<Result<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  // Account Management
  /// Delete user account
  Future<Result<void>> deleteAccount({
    required String password,
  });

  /// Re-authenticate user for sensitive operations
  Future<Result<void>> reauthenticate({
    required AuthCredentials credentials,
  });

  // Session Management
  /// Sign out current user
  Future<Result<void>> signOut();

  /// Sign out from all devices
  Future<Result<void>> signOutFromAllDevices();

  /// Get active sessions
  Future<Result<List<UserSession>>> getActiveSessions();

  /// Revoke specific session
  Future<Result<void>> revokeSession({
    required String sessionId,
  });

  // User Metadata
  /// Save user metadata (role, preferences, etc)
  Future<Result<void>> saveUserMetadata({
    required Map<String, dynamic> metadata,
  });

  /// Get user metadata
  Future<Result<Map<String, dynamic>>> getUserMetadata();

  // Error Recovery
  /// Check if error is recoverable
  bool isRecoverableError(String errorCode);

  /// Get user-friendly error message
  String getErrorMessage(String errorCode);
}

/// Result type for handling success and failure cases
/// Used for all repository methods to enable testing
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get data => isSuccess ? (this as Success<T>).value : null;
  String? get error => isFailure ? (this as Failure<T>).message : null;

  // Factory constructors
  static Result<T> success<T>(T value) => Success<T>(value);
  static Result<T> failure<T>(String message, [int? code]) =>
    Failure<T>(message, code);

  // Functional transformations
  Result<U> map<U>(U Function(T) transform) {
    if (isSuccess) {
      return Success<U>(transform((this as Success<T>).value));
    }
    return Failure<U>((this as Failure<T>).message, (this as Failure<T>).code);
  }

  Result<T> mapError(String Function(String) transform) {
    if (isFailure) {
      return Failure<T>(
        transform((this as Failure<T>).message),
        (this as Failure<T>).code,
      );
    }
    return this;
  }

  Future<Result<U>> flatMap<U>(
    Future<Result<U>> Function(T) transform,
  ) async {
    if (isSuccess) {
      return transform((this as Success<T>).value);
    }
    return Failure<U>((this as Failure<T>).message, (this as Failure<T>).code);
  }
}

/// Success case of Result
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

/// Failure case of Result
class Failure<T> extends Result<T> {
  final String message;
  final int? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() => 'Failure($message${code != null ? ', code: $code' : ''})';
}

/// Common Auth Error Codes
class AuthErrorCodes {
  // Firebase Auth Error Codes
  static const invalidEmail = 'auth/invalid-email';
  static const userDisabled = 'auth/user-disabled';
  static const userNotFound = 'auth/user-not-found';
  static const wrongPassword = 'auth/wrong-password';
  static const emailAlreadyInUse = 'auth/email-already-in-use';
  static const weakPassword = 'auth/weak-password';
  static const operationNotAllowed = 'auth/operation-not-allowed';
  static const requiresRecentLogin = 'auth/requires-recent-login';
  static const tooManyRequests = 'auth/too-many-requests';
  static const networkRequestFailed = 'auth/network-request-failed';

  // Custom Error Codes
  static const tokenExpired = 'custom/token-expired';
  static const sessionRevoked = 'custom/session-revoked';
  static const invalidCredentials = 'custom/invalid-credentials';
  static const accountLocked = 'custom/account-locked';
  static const emailNotVerified = 'custom/email-not-verified';
}