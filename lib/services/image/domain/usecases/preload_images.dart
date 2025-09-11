/// Preload Images Use Case - 이미지 사전 로드 비즈니스 로직
///
/// 여러 이미지를 미리 로드하여 성능을 개선합니다.
///
/// 작성일: 2025-09-03
/// 작성자: Services Team

import 'package:dartz/dartz.dart';

import '../repositories/i_image_cache_repository.dart';
import '../entities/cache_types.dart';
import '../entities/image_cache_failure.dart';
import '../entities/cache_policy.dart';

/// 이미지 사전 로드 유즈케이스
///
/// 백그라운드에서 이미지를 미리 다운로드하고 캐싱합니다.
class PreloadImagesUseCase {
  PreloadImagesUseCase({required this.repository});
  final IImageCacheRepository repository;

  /// 단일 이미지 사전 로드
  ///
  /// [url] 사전 로드할 이미지 URL
  /// [priority] 캐시 우선순위
  Future<Either<ImageCacheFailure, Unit>> execute({
    required String url,
    CachePriority priority = CachePriority.normal,
  }) async {
    try {
      // 이미 캐시에 있는지 확인
      final cachedResult = await repository.getCachedImage(url: url);

      return cachedResult.fold(
        (failure) => Left(failure),
        (option) => option.fold(
          () async {
            // 캐시에 없으면 프리페치
            return repository.prefetchImage(
              url: url,
              priority: priority,
            );
          },
          (_) => const Right(unit), // 이미 캐시됨
        ),
      );
    } catch (e) {
      return Left(ValidationFailure('Failed to preload image: $e'));
    }
  }

  /// 여러 이미지 일괄 사전 로드
  ///
  /// [urls] 사전 로드할 이미지 URL 목록
  /// [priority] 캐시 우선순위
  /// [parallel] 병렬 로드 여부
  Future<Either<ImageCacheFailure, List<String>>> executeBatch({
    required List<String> urls,
    CachePriority priority = CachePriority.normal,
    bool parallel = true,
  }) async {
    try {
      if (parallel) {
        // 병렬 프리페치
        return repository.prefetchBatch(
          urls: urls,
          priority: priority,
        );
      } else {
        // 순차적 프리페치
        final successUrls = <String>[];

        for (final url in urls) {
          final result = await execute(
            url: url,
            priority: priority,
          );

          result.fold(
            (failure) => null, // 실패 시 스킵
            (_) => successUrls.add(url),
          );
        }

        return Right(successUrls);
      }
    } catch (e) {
      return Left(ValidationFailure('Failed to preload images batch: $e'));
    }
  }

  /// 패턴 기반 이미지 사전 로드
  ///
  /// 특정 패턴과 일치하는 이미지들을 사전 로드
  Future<Either<ImageCacheFailure, int>> executeByPattern({
    required String pattern,
    CachePriority priority = CachePriority.normal,
  }) async {
    try {
      // 패턴으로 캐시 검색
      final searchResult = await repository.searchByPattern(pattern: pattern);

      return searchResult.fold(
        (failure) => Left(failure),
        (entities) async {
          int count = 0;

          for (final entity in entities) {
            final result = await execute(
              url: entity.url,
              priority: priority,
            );

            if (result.isRight()) {
              count++;
            }
          }

          return Right(count);
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Failed to preload by pattern: $e'));
    }
  }

  /// 우선순위 기반 이미지 사전 로드
  ///
  /// 높은 우선순위의 이미지들을 먼저 로드
  Future<Either<ImageCacheFailure, int>> executeByPriority({
    CachePriority minPriority = CachePriority.normal,
    int limit = 10,
  }) async {
    try {
      // 우선순위별 캐시 목록 가져오기
      final priorityResult = await repository.getByPriority(
        priority: minPriority,
      );

      return priorityResult.fold(
        (failure) => Left(failure),
        (entities) async {
          int count = 0;
          final entitiesToLoad = entities.take(limit);

          for (final entity in entitiesToLoad) {
            final result = await execute(
              url: entity.url,
              priority: entity.priority,
            );

            if (result.isRight()) {
              count++;
            }
          }

          return Right(count);
        },
      );
    } catch (e) {
      return Left(ValidationFailure('Failed to preload by priority: $e'));
    }
  }
}
