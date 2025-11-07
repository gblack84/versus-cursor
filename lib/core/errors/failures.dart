// Core Failure Classes
// Clean Architecture - Core Layer Error Handling

/// Base interface for all failures in the application
///
/// All failures should implement this abstract interface
/// to provide consistent error handling across layers.
///
/// **Clean Architecture v4.0 - Failure Interface Pattern**:
/// - Pure Dart interface (no external dependencies)
/// - Removed Equatable dependency (use Freezed in implementations)
/// - Each Feature implements this with Freezed sealed classes
/// - Compatible with Either<Failure, T> pattern (fpdart)
///
/// **Implementation Example**:
/// ```dart
/// @freezed
/// sealed class AuthFailure with _$AuthFailure implements Failure {
///   const factory AuthFailure.invalidEmail() = InvalidEmail;
///
///   @override
///   String get message => when(
///     invalidEmail: () => '이메일 형식이 올바르지 않습니다',
///   );
/// }
/// ```
abstract interface class Failure {
  /// Human-readable error message for UI display
  String get message;

  /// Optional error code for programmatic handling
  String? get code;

  /// Equatable-compatible props for equality comparison
  /// (Required for Features still using Equatable compatibility)
  List<Object?> get props;

  /// String representation for debugging
  bool? get stringify;
}

// ============================================================
// Legacy Failure Classes Removed
// ============================================================
//
// The following classes have been removed in Clean Architecture v4.0:
// - NetworkFailure
// - AuthFailure
// - ValidationFailure
// - CacheFailure
// - ServerFailure
// - PermissionFailure
// - NotFoundFailure
// - AppFailure
//
// **Migration Path**:
// Each Feature now defines its own Freezed-based Failure sealed class:
//
// - lib/features/auth/domain/failures/auth_failure.dart
// - lib/features/chat/domain/failures/chat_failure.dart
// - lib/features/profile/domain/failures/profile_failure.dart
// - lib/features/notifications/domain/failures/notification_failure.dart
// - lib/features/post/domain/failures/post_failure.dart
// - lib/features/creation/domain/failures/creation_failure.dart
//
// **Benefits**:
// ✅ Type-safe pattern matching with Freezed when/map
// ✅ Feature-specific error cases
// ✅ No Equatable dependency
// ✅ Automatic equality, hashCode, copyWith generation
// ============================================================
