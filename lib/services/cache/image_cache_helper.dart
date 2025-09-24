import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/utils/debug_helper.dart';

/// 이미지 캐싱 헬퍼 클래스
/// 이미지 캐싱 로직을 중앙에서 관리
class ImageCacheHelper {
  // 캐시 크기 상수
  static const int kMaxMemCacheWidth = 800;
  static const int kMinMemCacheWidth = 200;
  static const int kDefaultMemCacheWidth = 400;

  // 프리로드 설정
  static const int kMaxPreloadCount = 3; // 최대 프리로드 이미지 수

  /// 메모리 캐시 너비 계산
  /// 디바이스 픽셀 비율과 실제 표시 크기를 고려하여 최적의 캐시 크기 계산
  static int calculateMemCacheWidth(BuildContext context, double displayWidth) {
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (displayWidth * pixelRatio).round();

    // 최소/최대값으로 제한하여 메모리 사용량 최적화
    final cacheWidth = targetWidth.clamp(kMinMemCacheWidth, kMaxMemCacheWidth);

    // 캐시 너비 계산은 DEBUG 레벨로
    DebugHelper.debug(
        '캐시 너비 계산: 표시크기=$displayWidth, 픽셀비율=$pixelRatio, 캐시크기=$cacheWidth',
        tag: 'ImageCache');

    return cacheWidth;
  }

  /// 동적 박스 크기에 따른 메모리 캐시 너비 계산
  static int calculateMemCacheWidthForBox(
    BuildContext context, {
    double? dynamicWidth,
    bool isHorizontal = false,
  }) {
    double baseWidth;

    if (dynamicWidth != null && dynamicWidth.isFinite) {
      baseWidth = dynamicWidth;
    } else {
      baseWidth = isHorizontal
          ? MediaQuery.of(context).size.width / 2
          : MediaQuery.of(context).size.width;
    }

    return calculateMemCacheWidth(context, baseWidth);
  }

  /// 이미지 프리로드
  /// 주어진 URL 리스트의 이미지를 미리 캐시에 로드
  static Future<void> preloadImages(
    BuildContext context,
    List<String> imageUrls, {
    int? memCacheWidth,
  }) async {
    if (!context.mounted || imageUrls.isEmpty) return;

    // 최대 프리로드 개수 제한
    final urlsToPreload = imageUrls.take(kMaxPreloadCount).toList();

    // 프리로드 시작은 URL 해시로 한 번만 로깅
    final preloadId = urlsToPreload.map((url) => url.hashCode).join('_');
    DebugHelper.logOnce(
        'preload_batch_$preloadId', '이미지 프리로드 시작: ${urlsToPreload.length}개',
        tag: 'ImageCache', level: LogLevel.DEBUG);

    try {
      await Future.wait(
        urlsToPreload
            .map((url) => _preloadSingleImage(context, url, memCacheWidth)),
        eagerError: false,
      );
    } catch (e) {
      DebugHelper.error('이미지 프리로드 실패', error: e, tag: 'ImageCache');
    }
  }

  /// 단일 이미지 프리로드
  static Future<void> _preloadSingleImage(
    BuildContext context,
    String imageUrl,
    int? memCacheWidth,
  ) async {
    if (!context.mounted) return;

    try {
      final provider = CachedNetworkImageProvider(
        imageUrl,
        cacheKey: imageUrl,
      );

      await precacheImage(provider, context);

      // 각 이미지 URL에 대해 한 번만 로깅
      DebugHelper.logOnce('preload_${imageUrl.hashCode}',
          '이미지 프리캐시: ${DebugHelper.maskSensitive(imageUrl)}',
          tag: 'ImageCache', level: LogLevel.DEBUG);
    } catch (e) {
      DebugHelper.logOnce('preload_error_${imageUrl.hashCode}',
          '이미지 프리로드 실패: ${DebugHelper.maskSensitive(imageUrl)}',
          tag: 'ImageCache', level: LogLevel.WARNING);
    }
  }

  /// 인접 이미지 프리로드 (PageView용)
  /// 현재 인덱스 기준으로 앞뒤 이미지를 프리로드
  static Future<void> preloadAdjacentImages(
    BuildContext context,
    List<String> imageUrls,
    int currentIndex, {
    int? memCacheWidth,
  }) async {
    if (!context.mounted || imageUrls.isEmpty) return;

    final indicesToPreload = <int>[];

    // 다음 이미지
    if (currentIndex < imageUrls.length - 1) {
      indicesToPreload.add(currentIndex + 1);
    }

    // 이전 이미지
    if (currentIndex > 0) {
      indicesToPreload.add(currentIndex - 1);
    }

    // 두 칸 뒤 이미지 (빠른 스와이프 대비)
    if (currentIndex < imageUrls.length - 2) {
      indicesToPreload.add(currentIndex + 2);
    }

    // 인접 이미지 프리로드는 DEBUG 레벨로
    DebugHelper.debug(
        '인접 이미지 프리로드: 현재=$currentIndex, 프리로드=${indicesToPreload.join(",")}',
        tag: 'ImageCache');

    for (final index in indicesToPreload) {
      if (index >= 0 && index < imageUrls.length) {
        await _preloadSingleImage(context, imageUrls[index], memCacheWidth);
      }
    }
  }

  /// 캐시 클리어 (메모리 부족 시)
  static void clearMemoryCache() {
    PaintingBinding.instance.imageCache.clear();
    DebugHelper.info('이미지 메모리 캐시 클리어', tag: 'ImageCache');
  }

  /// 특정 이미지 캐시에서 제거
  static void evictFromCache(String imageUrl) {
    final provider = CachedNetworkImageProvider(imageUrl);
    provider.evict();
    DebugHelper.debug('캐시에서 이미지 제거: ${DebugHelper.maskSensitive(imageUrl)}',
        tag: 'ImageCache');
  }

  /// 캐시 상태 확인 (디버그용)
  static void logCacheStatus() {
    DebugHelper.runInDebug(() {
      final cache = PaintingBinding.instance.imageCache;
      // 캐시 상태는 명시적 호출 시에만 표시
      DebugHelper.info(
          '캐시 상태: 현재크기=${cache.currentSizeBytes}bytes, '
          '최대크기=${cache.maximumSizeBytes}bytes, '
          '이미지수=${cache.currentSize}개',
          tag: 'ImageCache');
    });
  }
}
