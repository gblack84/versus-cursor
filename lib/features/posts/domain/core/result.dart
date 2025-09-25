import '../failures/post_failures.dart' as failures;

/// Result type for handling success and failure cases
/// 성공과 실패 케이스를 처리하기 위한 Result 타입
///
/// Similar to Either<Failure, T> from dartz/fpdart
/// dartz/fpdart의 Either<Failure, T>와 유사
sealed class Result<T> {
  const Result();

  /// Check if the result is a success
  bool get isSuccess => this is Success<T>;

  /// Check if the result is a failure
  bool get isFailure => this is ResultFailure;

  /// Get the value if success, otherwise null
  T? get valueOrNull => switch (this) {
    Success<T> success => success.value,
    ResultFailure<T> _ => null,
  };

  /// Get the failure if failed, otherwise null
  failures.Failure? get failureOrNull => switch (this) {
    Success<T> _ => null,
    ResultFailure<T> failure => failure.failure,
  };

  /// Fold the result - apply one of the two functions based on the result
  R fold<R>(
    R Function(failures.Failure failure) onFailure,
    R Function(T value) onSuccess,
  ) {
    return switch (this) {
      Success<T> success => onSuccess(success.value),
      ResultFailure<T> failure => onFailure(failure.failure),
    };
  }

  /// Map the success value
  Result<R> map<R>(R Function(T value) mapper) {
    return switch (this) {
      Success<T> success => Success(mapper(success.value)),
      ResultFailure<T> failure => ResultFailure(failure.failure),
    };
  }

  /// FlatMap (bind) - chain operations that return Result
  Result<R> flatMap<R>(Result<R> Function(T value) mapper) {
    return switch (this) {
      Success<T> success => mapper(success.value),
      ResultFailure<T> failure => ResultFailure(failure.failure),
    };
  }

  /// Get value or throw exception
  T getOrThrow() {
    return switch (this) {
      Success<T> success => success.value,
      ResultFailure<T> failure => throw Exception(failure.failure.message),
    };
  }

  /// Get value or default
  T getOrElse(T defaultValue) {
    return switch (this) {
      Success<T> success => success.value,
      ResultFailure<T> _ => defaultValue,
    };
  }
}

/// Success case of Result
/// Result의 성공 케이스
class Success<T> extends Result<T> {
  final T value;

  const Success(this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
      runtimeType == other.runtimeType &&
      value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Success($value)';
}

/// Failure case of Result
/// Result의 실패 케이스
class ResultFailure<T> extends Result<T> {
  final failures.Failure failure;

  const ResultFailure(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResultFailure<T> &&
      runtimeType == other.runtimeType &&
      failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'ResultFailure($failure)';
}

/// Extension methods for easier Result creation
/// Result 생성을 쉽게 하기 위한 확장 메서드
extension ResultExtensions<T> on T {
  /// Convert a value to Success Result
  Result<T> toSuccess() => Success(this);
}

extension FailureExtensions on failures.Failure {
  /// Convert a Failure to Failure Result
  Result<T> toFailure<T>() => ResultFailure<T>(this);
}