import '/core/types/result.dart';

/// Base UseCase for operations that don't require input parameters
/// Clean Architecture - Domain UseCase Pattern
abstract class NoParamUseCase<Output> {
  /// Execute the use case without parameters
  Future<Result<Output>> call();
}

/// NoParams class for consistent API
class NoParams {
  const NoParams();
}
