import '/core/types/result.dart';

/// Base UseCase abstraction for all use cases
/// Clean Architecture - Domain UseCase Pattern
///
/// **Clean Architecture v4.0 - UseCase Pattern**:
/// - Uses Core Result<T> type for type-safe error handling
/// - Returns Result<Success<T>, ResultFailure<Failure>>
/// - Compatible with Failure sealed classes
abstract class UseCase<Input, Output> {
  /// Execute the use case with given input
  ///
  /// Returns [Result<Output>] which is either:
  /// - Success<Output> - successful operation with data
  /// - ResultFailure<Failure> - failed operation with typed Failure
  Future<Result<Output>> call(Input input);
}
