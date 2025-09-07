/// UseCase Base Class
/// 
/// Base class for all use cases following Clean Architecture.
/// Provides a consistent interface for business logic execution.
/// 
/// Created: 2025-09-05
/// Author: CodeSurgeon

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../errors/failures.dart';

/// Base class for all use cases
/// 
/// [Type] is the expected return type
/// [Params] is the input parameters type
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use this class when the use case doesn't require parameters
class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}