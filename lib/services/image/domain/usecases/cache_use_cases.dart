import 'package:dartz/dartz.dart';
import '/types/cache_types.dart'';
import '../types/cache_types.dart';

abstract class ICacheImageUseCase {
  Future<Either<ImageCacheFailure, void>> call({
    required String url,
    CachePriority priority = CachePriority.normal,
  });
}

abstract class IGetCachedImageUseCase {
  Future<Either<ImageCacheFailure, String>> call({
    required String url,
  });
}

abstract class IOptimizeImageUseCase {
  Future<Either<ImageCacheFailure, String>> call({
    required String imagePath,
  });
}

class CacheImageUseCase implements ICacheImageUseCase {
  @override
  Future<Either<ImageCacheFailure, void>> call({
    required String url,
    CachePriority priority = CachePriority.normal,
  }) async {
    // Basic implementation, replace with actual caching logic
    try {
      // TODO: Implement actual caching
      return const Right(null);
    } catch (e) {
      return Left(ImageCacheFailure.unexpected(e.toString()));
    }
  }
}

class GetCachedImageUseCase implements IGetCachedImageUseCase {
  @override
  Future<Either<ImageCacheFailure, String>> call({
    required String url,
  }) async {
    // Basic implementation, replace with actual cache retrieval
    try {
      // TODO: Implement actual cache retrieval
      return Left(ImageCacheFailure.cacheNotFound());
    } catch (e) {
      return Left(ImageCacheFailure.unexpected(e.toString()));
    }
  }
}

class OptimizeImageUseCase implements IOptimizeImageUseCase {
  @override
  Future<Either<ImageCacheFailure, String>> call({
    required String imagePath,
  }) async {
    // Basic implementation, replace with actual image optimization
    try {
      // TODO: Implement actual image optimization
      return Right(imagePath);
    } catch (e) {
      return Left(ImageCacheFailure.unexpected(e.toString()));
    }
  }
}
