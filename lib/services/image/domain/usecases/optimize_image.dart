/// Optimize Image Use Case - 이미지 최적화 비즈니스 로직
/// 
/// 이미지 최적화를 위한 도메인 레이어 유즈케이스입니다.
/// 
/// 작성일: 2025-09-03
/// 작성자: Services Team

import 'dart:typed_data';
import 'package:dartz/dartz.dart';

import '../repositories/i_image_cache_repository.dart';
import '../entities/image_metadata.dart';

/// 이미지 최적화 유즈케이스
/// 
/// 이미지 품질과 크기를 최적화하여 성능을 개선합니다.
class OptimizeImageUseCase {
  
  OptimizeImageUseCase({required this.repository});
  final IImageCacheRepository repository;
  
  /// 이미지 최적화 실행
  /// 
  /// [url] 최적화할 이미지 URL
  /// [targetWidth] 목표 너비
  /// [targetHeight] 목표 높이
  /// [quality] 품질 (0-100)
  Future<Either<ImageCacheFailure, Uint8List>> execute({
    required String url,
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    try {
      // 먼저 캐시에서 이미지 가져오기
      final cachedResult = await repository.getCachedImage(
        url: url,
        width: targetWidth,
        height: targetHeight,
      );
      
      return cachedResult.fold(
        (failure) => Left(failure),
        (option) => option.fold(
          () async {
            // 캐시에 없으면 다운로드 후 최적화
            final downloadResult = await repository.downloadImage(url: url);
            
            return downloadResult.fold(
              (failure) => Left(failure),
              (imageData) async {
                // 이미지 최적화 로직 (실제 구현 필요)
                final optimizedData = await _optimizeImage(
                  imageData,
                  targetWidth: targetWidth,
                  targetHeight: targetHeight,
                  quality: quality,
                );
                
                // 최적화된 이미지 캐시에 저장
                final metadata = ImageMetadata(
                  url: url,
                  width: targetWidth ?? 0,
                  height: targetHeight ?? 0,
                  format: ImageFormat.jpeg,
                  fileSize: optimizedData.length,
                  createdAt: DateTime.now(),
                );
                
                await repository.cacheImage(
                  url: url,
                  imageData: optimizedData,
                  metadata: metadata,
                );
                
                return Right(optimizedData);
              },
            );
          },
          (data) => Right(data),
        ),
      );
    } catch (e) {
      return Left(ValidationFailure('Failed to optimize image: $e'));
    }
  }
  
  /// 배치 이미지 최적화
  Future<Either<ImageCacheFailure, List<Uint8List>>> executeBatch({
    required List<String> urls,
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    final results = <Uint8List>[];
    
    for (final url in urls) {
      final result = await execute(
        url: url,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        quality: quality,
      );
      
      result.fold(
        (failure) => null, // 실패 시 스킵
        (data) => results.add(data),
      );
    }
    
    return Right(results);
  }
  
  /// 실제 이미지 최적화 로직
  /// TODO: 실제 이미지 처리 라이브러리 사용 필요
  Future<Uint8List> _optimizeImage(
    Uint8List imageData, {
    int? targetWidth,
    int? targetHeight,
    int quality = 85,
  }) async {
    // 임시 구현 - 실제로는 이미지 처리 라이브러리 사용
    // 예: flutter_image_compress 등
    return imageData;
  }
}