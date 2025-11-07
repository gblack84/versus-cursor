import 'package:fpdart/fpdart.dart';
import '/core/errors/failures.dart';

/// Base use case interface for search feature
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// No params use case
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Stream use case
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}

/// No params stream use case
abstract class NoParamsStreamUseCase<Type> {
  Stream<Either<Failure, Type>> call();
}
