/// DevLogger - Development-only logging utility
///
/// **Purpose**: Structured logging for UseCase execution in development mode
///
/// **Features**:
/// - ✅ Development-only (kDebugMode)
/// - ✅ Production tree-shaking (0 overhead in release)
/// - ✅ Structured output with timestamps and tags
/// - ✅ 5 log types: params, checkpoint, result, validation, error
///
/// **Usage Example**:
/// ```dart
/// Future<Either<AuthFailure, User>> execute(String email, String password) async {
///   DevLogger.params({'email': email}, tag: 'SignIn');
///   DevLogger.checkpoint('Starting authentication', tag: 'SignIn');
///
///   final result = await _repository.signIn(email, password);
///
///   result.fold(
///     (failure) => DevLogger.error('Sign-in failed', error: failure, tag: 'SignIn'),
///     (user) => DevLogger.result(isSuccess: true, data: user.uid, tag: 'SignIn'),
///   );
///
///   return result;
/// }
/// ```
///
/// **Output Format**:
/// ```
/// [DEV][SignIn] 📋 PARAMS: {email: test@example.com, password: ********}
/// [DEV][SignIn] 🔵 CHECKPOINT: Starting authentication
/// [DEV][SignIn] ✅ SUCCESS: user-123
/// [DEV][SignIn] ❌ ERROR: Invalid credentials
/// [DEV][SignIn] ⚠️  VALIDATION: Field 'email' failed: Invalid format
/// ```
///
/// **Performance**:
/// - Development: ~0.1ms per log (debugPrint overhead)
/// - Production: 0ms (tree-shaken by compiler)
///
/// **Guidelines**:
/// - Use `tag` parameter to identify UseCase
/// - Log input parameters with `params()` at start
/// - Log business logic milestones with `checkpoint()`
/// - Log final result with `result()`
/// - Log validation failures with `validation()`
/// - Log exceptions with `error()` including stack trace

import 'package:flutter/foundation.dart';

/// DevLogger provides structured logging for development debugging
class DevLogger {
  // Private constructor to prevent instantiation
  DevLogger._();

  /// Log input parameters at UseCase entry point
  ///
  /// **When to use**: Beginning of UseCase execute() method
  ///
  /// **Example**:
  /// ```dart
  /// DevLogger.params({
  ///   'userId': userId,
  ///   'postId': postId,
  ///   'action': 'like',
  /// }, tag: 'LikePost');
  /// ```
  ///
  /// **Output**: `[DEV][LikePost] 📋 PARAMS: {userId: user-123, postId: post-456}`
  static void params(
    Map<String, dynamic> parameters, {
    String? tag,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag]' : '';
      debugPrint('[$timestamp][DEV]$tagPrefix 📋 PARAMS: $parameters');
    }
  }

  /// Log business logic checkpoint
  ///
  /// **When to use**: Important milestones in UseCase execution flow
  ///
  /// **Example**:
  /// ```dart
  /// DevLogger.checkpoint('Starting authentication', tag: 'SignIn');
  /// DevLogger.checkpoint('Validating email format', tag: 'SignIn');
  /// DevLogger.checkpoint('Checking rate limit', tag: 'SignIn');
  /// DevLogger.checkpoint('Querying Firebase Auth', tag: 'SignIn');
  /// ```
  ///
  /// **Output**: `[DEV][SignIn] 🔵 CHECKPOINT: Starting authentication`
  static void checkpoint(
    String checkpoint, {
    String? tag,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag]' : '';
      debugPrint('[$timestamp][DEV]$tagPrefix 🔵 CHECKPOINT: $checkpoint');
    }
  }

  /// Log UseCase execution result
  ///
  /// **When to use**: After UseCase completes (success or failure)
  ///
  /// **Example**:
  /// ```dart
  /// // Success case
  /// result.fold(
  ///   (failure) => DevLogger.error('Failed', error: failure, tag: 'SignIn'),
  ///   (user) => DevLogger.result(
  ///     isSuccess: true,
  ///     data: user.uid,
  ///     tag: 'SignIn',
  ///   ),
  /// );
  ///
  /// // Failure case (alternative to error())
  /// DevLogger.result(
  ///   isSuccess: false,
  ///   data: failure.getUserMessage(),
  ///   tag: 'SignIn',
  /// );
  /// ```
  ///
  /// **Output**:
  /// - Success: `[DEV][SignIn] ✅ SUCCESS: user-123`
  /// - Failure: `[DEV][SignIn] ❌ FAILURE: Invalid credentials`
  static void result({
    required bool isSuccess,
    dynamic data,
    String? tag,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag]' : '';
      final statusIcon = isSuccess ? '✅' : '❌';
      final statusText = isSuccess ? 'SUCCESS' : 'FAILURE';
      final dataText = data != null ? ': $data' : '';

      debugPrint('[$timestamp][DEV]$tagPrefix $statusIcon $statusText$dataText');
    }
  }

  /// Log validation failure
  ///
  /// **When to use**: Input validation failures in UseCase
  ///
  /// **Example**:
  /// ```dart
  /// if (email.isEmpty) {
  ///   DevLogger.validation(
  ///     field: 'email',
  ///     reason: 'Email is required',
  ///     tag: 'SignIn',
  ///   );
  ///   return left(AuthFailure.invalidEmail());
  /// }
  ///
  /// if (!emailRegex.hasMatch(email)) {
  ///   DevLogger.validation(
  ///     field: 'email',
  ///     reason: 'Invalid email format',
  ///     tag: 'SignIn',
  ///   );
  ///   return left(AuthFailure.invalidEmail());
  /// }
  /// ```
  ///
  /// **Output**: `[DEV][SignIn] ⚠️  VALIDATION: Field 'email' failed: Email is required`
  static void validation({
    required String field,
    required String reason,
    String? tag,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag]' : '';
      debugPrint("[$timestamp][DEV]$tagPrefix ⚠️  VALIDATION: Field '$field' failed: $reason");
    }
  }

  /// Log exception or error
  ///
  /// **When to use**: Exception caught in try-catch, or Failure in fold()
  ///
  /// **Example**:
  /// ```dart
  /// try {
  ///   await _repository.signIn(email, password);
  /// } catch (e, stackTrace) {
  ///   DevLogger.error(
  ///     'Firebase Auth exception',
  ///     error: e,
  ///     stackTrace: stackTrace,
  ///     tag: 'SignIn',
  ///   );
  ///   return left(AuthFailure.serverError(e.toString()));
  /// }
  ///
  /// // Or in fold()
  /// result.fold(
  ///   (failure) {
  ///     DevLogger.error('Sign-in failed', error: failure, tag: 'SignIn');
  ///     return left(failure);
  ///   },
  ///   (user) => right(user),
  /// );
  /// ```
  ///
  /// **Output**:
  /// ```
  /// [DEV][SignIn] 🔴 ERROR: Firebase Auth exception
  ///   Error: FirebaseAuthException: invalid-email
  ///   Stack trace:
  ///     #0      AuthRepositoryImpl.signIn
  ///     #1      SignInWithEmailUseCase.execute
  ///     ...
  /// ```
  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String? tag,
  }) {
    if (kDebugMode) {
      final timestamp = DateTime.now().toIso8601String();
      final tagPrefix = tag != null ? '[$tag]' : '';

      // Primary error message
      debugPrint('[$timestamp][DEV]$tagPrefix 🔴 ERROR: $message');

      // Error object details
      if (error != null) {
        debugPrint('  Error: $error');
      }

      // Stack trace (first 5 lines for readability)
      if (stackTrace != null) {
        final stackLines = stackTrace.toString().split('\n');
        final limitedStack = stackLines.take(5).join('\n    ');
        debugPrint('  Stack trace:\n    $limitedStack');

        if (stackLines.length > 5) {
          debugPrint('    ... (${stackLines.length - 5} more lines)');
        }
      }
    }
  }
}
