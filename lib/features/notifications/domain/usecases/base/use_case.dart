/// Base UseCase abstraction for all use cases
/// Clean Architecture - Domain UseCase Pattern
abstract class UseCase<Input, Output> {
  /// Execute the use case with given input
  Future<Result<Output>> call(Input input);
}

/// Result wrapper for UseCase responses
class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  const Result.success(this.data)
      : isSuccess = true,
        error = null;

  const Result.failure(this.error)
      : isSuccess = false,
        data = null;

  /// Check if result is successful
  bool get isFailure => !isSuccess;

  /// Map result to another type
  Result<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return Result.success(mapper(data!));
    }
    return Result.failure(error);
  }

  /// Get data or throw exception
  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? 'Unknown error');
  }

  /// Get data or return default value
  T getOrElse(T defaultValue) {
    return data ?? defaultValue;
  }

  /// Execute function if success
  void ifSuccess(void Function(T data) action) {
    if (isSuccess && data != null) {
      action(data!);
    }
  }

  /// Execute function if failure
  void ifFailure(void Function(String error) action) {
    if (isFailure && error != null) {
      action(error!);
    }
  }

  /// Fold result into single value
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(String error) onFailure,
  }) {
    if (isSuccess && data != null) {
      return onSuccess(data!);
    }
    return onFailure(error ?? 'Unknown error');
  }
}