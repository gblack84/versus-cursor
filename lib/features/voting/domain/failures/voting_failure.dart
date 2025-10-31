import 'package:freezed_annotation/freezed_annotation.dart';

part 'voting_failure.freezed.dart';

/// Sealed failure class for Voting Feature
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed sealed class for type exhaustiveness
/// - Automatic `.when()`, `.maybeWhen()`, `.map()` generation
/// - Immutable value objects with pattern matching
///
/// **Error Categories**:
/// - **Network**: Connection/timeout errors
/// - **Server**: Firebase/backend errors
/// - **Validation**: Input validation errors
/// - **Business Logic**: Vote-specific errors (already voted, voting closed)
/// - **Unknown**: Unexpected errors
@freezed
sealed class VotingFailure with _$VotingFailure {
  const VotingFailure._();

  // === Network Errors ===

  /// Network connection failed
  const factory VotingFailure.networkError([String? message]) = _NetworkError;

  /// Request timeout (Firebase deadline-exceeded)
  const factory VotingFailure.timeout([String? message]) = _Timeout;

  // === Server Errors ===

  /// Server error occurred (Firebase internal error)
  const factory VotingFailure.serverError([String? message]) = _ServerError;

  /// Data not found (Firebase not-found)
  const factory VotingFailure.notFound([String? message]) = _NotFound;

  /// Permission denied (Firebase permission-denied)
  const factory VotingFailure.permissionDenied([String? message]) = _PermissionDenied;

  /// User not authenticated (Firebase unauthenticated)
  const factory VotingFailure.unauthenticated([String? message]) = _Unauthenticated;

  /// Unauthorized access (duplicate of unauthenticated for backward compatibility)
  const factory VotingFailure.unauthorized([String? message]) = _Unauthorized;

  /// Data already exists (Firebase already-exists)
  const factory VotingFailure.alreadyExists([String? message]) = _AlreadyExists;

  /// Firestore quota exceeded (Firebase resource-exhausted)
  const factory VotingFailure.quotaExceeded([String? message]) = _QuotaExceeded;

  /// Operation cancelled (Firebase cancelled)
  const factory VotingFailure.cancelled([String? message]) = _Cancelled;

  /// Operation aborted (Firebase aborted)
  const factory VotingFailure.aborted([String? message]) = _Aborted;

  // === Validation Errors ===

  /// Invalid argument (Firebase invalid-argument)
  const factory VotingFailure.invalidArgument([String? message]) = _InvalidArgument;

  /// Invalid voting data
  const factory VotingFailure.invalidData([String? message]) = _InvalidData;

  /// Precondition failed (Firebase failed-precondition)
  const factory VotingFailure.failedPrecondition([String? message]) = _FailedPrecondition;

  // === Business Logic Errors ===

  /// User has already voted (duplicate of alreadyExists for vote-specific context)
  const factory VotingFailure.alreadyVoted([String? message]) = _AlreadyVoted;

  /// Voting session has ended
  const factory VotingFailure.votingClosed([String? message]) = _VotingClosed;

  // === Cache Errors ===

  /// Cache operation failed
  const factory VotingFailure.cacheError([String? message]) = _CacheError;

  // === Unknown Errors ===

  /// Unexpected voting error
  const factory VotingFailure.unexpected(String message) = _Unexpected;

  // === User-friendly message getter ===

  /// Get user-friendly error message
  ///
  /// **Returns**: Human-readable error message for display
  String get errorMessage => when(
    networkError: (msg) => msg ?? 'Network connection failed',
    timeout: (msg) => msg ?? 'Request timeout',
    serverError: (msg) => msg ?? 'Server error occurred',
    notFound: (msg) => msg ?? 'Voting data not found',
    permissionDenied: (msg) => msg ?? 'Permission denied',
    unauthenticated: (msg) => msg ?? 'User not authenticated',
    unauthorized: (msg) => msg ?? 'Unauthorized voting access',
    alreadyExists: (msg) => msg ?? 'Data already exists',
    quotaExceeded: (msg) => msg ?? 'Firestore quota exceeded',
    cancelled: (msg) => msg ?? 'Operation cancelled',
    aborted: (msg) => msg ?? 'Operation aborted',
    invalidArgument: (msg) => msg ?? 'Invalid argument',
    invalidData: (msg) => msg ?? 'Invalid voting data',
    failedPrecondition: (msg) => msg ?? 'Precondition failed',
    alreadyVoted: (msg) => msg ?? 'User has already voted',
    votingClosed: (msg) => msg ?? 'Voting session has ended',
    cacheError: (msg) => msg ?? 'Cache operation failed',
    unexpected: (msg) => msg,
  );

  /// Get error code for logging/debugging
  ///
  /// **Returns**: Firebase error code or generic code
  String get code => when(
    networkError: (_) => 'network-error',
    timeout: (_) => 'deadline-exceeded',
    serverError: (_) => 'server-error',
    notFound: (_) => 'not-found',
    permissionDenied: (_) => 'permission-denied',
    unauthenticated: (_) => 'unauthenticated',
    unauthorized: (_) => 'unauthorized',
    alreadyExists: (_) => 'already-exists',
    quotaExceeded: (_) => 'resource-exhausted',
    cancelled: (_) => 'cancelled',
    aborted: (_) => 'aborted',
    invalidArgument: (_) => 'invalid-argument',
    invalidData: (_) => 'invalid-data',
    failedPrecondition: (_) => 'failed-precondition',
    alreadyVoted: (_) => 'already-voted',
    votingClosed: (_) => 'voting-closed',
    cacheError: (_) => 'cache-error',
    unexpected: (_) => 'unexpected',
  );
}
