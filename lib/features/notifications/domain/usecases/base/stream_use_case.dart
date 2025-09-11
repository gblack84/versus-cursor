/// Base UseCase for stream-based operations
/// Clean Architecture - Domain UseCase Pattern for Reactive Programming
abstract class StreamUseCase<Input, Output> {
  /// Execute the use case and return a stream of results
  Stream<Output> call(Input input);
}
