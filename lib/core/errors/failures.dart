// Core Failure Classes
// Clean Architecture - Core Layer Error Handling

import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
///
/// All failures should extend this abstract class
/// to provide consistent error handling across layers.
abstract class Failure extends Equatable {
  const Failure({
    this.message = 'An unexpected error occurred',
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network connection failed',
    super.code,
  });
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed',
    super.code,
  });
}

/// Validation-related failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed',
    super.code,
  });
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Cache operation failed',
    super.code,
  });
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Server error occurred',
    super.code,
  });
}

/// Permission-related failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied',
    super.code,
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Resource not found',
    super.code,
  });
}

/// General application failures
class AppFailure extends Failure {
  const AppFailure({
    super.message = 'Application error occurred',
    super.code,
  });
}
