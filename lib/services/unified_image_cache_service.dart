import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 통합 이미지 캐시 서비스
/// 
/// 앱 전체에서 일관된 이미지 캐싱 전략을 제공합니다.
/// 모든 컴포넌트에서 동일한 품질과 성능을 보장합니다.
class UnifiedImageCacheService {
  // 싱글톤 인스턴스
  static final UnifiedImageCacheService _instance = UnifiedImageCacheService._internal();
  static UnifiedImageCacheService get instance => _instance;
  
  UnifiedImageCacheService._internal();
  
  // 캐시 크기 상수
  static const int MIN_CACHE_WIDTH = 400;   // 최소 캐시 너비
  static const int MAX_CACHE_WIDTH = 1600;  // 최대 캐시 너비  
  static const double SCALE_FACTOR = 2.0;   // 기본 스케일 팩터
  
  // 캐시된 URL 추적 (ChatImageCacheService에서 이동)
  final Set<String> _cachedUrls = {};
  final Set<String> _preloadingUrls = {};
  
  /// 메모리 캐시 너비 계산 (기본)
  /// 
  /// 디스플레이 크기에 기반하여 최적의 캐시 크기를 계산합니다.
  /// Retina 디스플레이를 고려하여 2배 스케일을 적용합니다.
  static int calculateMemCacheWidth(double displaySize) {
    if (!displaySize.isFinite || displaySize <= 0) {
      return MIN_CACHE_WIDTH;
    }
    
    final calculatedWidth = (displaySize * SCALE_FACTOR).round();
    return calculatedWidth.clamp(MIN_CACHE_WIDTH, MAX_CACHE_WIDTH);
  }
  
  /// 디바이스 픽셀 비율을 고려한 캐시 너비 계산
  /// 
  /// 고해상도 디스플레이에서 더 선명한 이미지를 제공합니다.
  static int calculateWithPixelRatio(BuildContext context, double displaySize) {
    if (!displaySize.isFinite || displaySize <= 0) {
      return MIN_CACHE_WIDTH;
    }
    
    final pixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetWidth = (displaySize * pixelRatio).round();
    return targetWidth.clamp(MIN_CACHE_WIDTH, MAX_CACHE_WIDTH);
  }
  
  /// 박스 크기 기반 캐시 너비 계산
  /// 
  /// 레이아웃 타입과 박스 크기를 고려하여 최적화된 캐시 크기를 반환합니다.
  static int calculateForBox(
    BuildContext context, {
    double? boxWidth,
    double? boxHeight,
    bool isHorizontal = false,
  }) {
    double baseSize;
    
    if (boxWidth != null && boxWidth.isFinite && boxWidth > 0) {
      baseSize = boxWidth;
    } else if (boxHeight != null && boxHeight.isFinite && boxHeight > 0) {
      baseSize = boxHeight;
    } else {
      // 폴백: 화면 크기 기반
      final screenWidth = MediaQuery.of(context).size.width;
      baseSize = isHorizontal ? screenWidth / 2 : screenWidth * 0.9;
    }
    
    return calculateMemCacheWidth(baseSize);
  }
  
  /// 이미지 프리로딩 (통합)
  /// 
  /// 여러 이미지를 미리 캐시에 로드하여 성능을 최적화합니다.
  Future<void> preloadImages(
    BuildContext context,
    List<String?> imageUrls, {
    int? overrideMemCacheWidth,
    int maxPreloadCount = 5,
  }) async {
    if (!context.mounted) return;
    
    final validUrls = imageUrls
        .where((url) => url != null && url.isNotEmpty)
        .cast<String>()
        .take(maxPreloadCount)
        .toList();
    
    if (validUrls.isEmpty) return;
    
    final futures = <Future>[];
    for (final url in validUrls) {
      futures.add(_preloadSingleImage(
        context,
        url,
        overrideMemCacheWidth,
      ));
    }
    
    try {
      await Future.wait(futures, eagerError: false);
    } catch (e) {
      debugPrint('[UnifiedImageCache] 프리로딩 실패: $e');
    }
  }
  
  /// 단일 이미지 프리로드
  Future<void> _preloadSingleImage(
    BuildContext context,
    String imageUrl,
    int? overrideMemCacheWidth,
  ) async {
    if (!context.mounted) return;
    
    // 이미 캐시되었거나 프리로딩 중이면 스킵
    if (_cachedUrls.contains(imageUrl) || _preloadingUrls.contains(imageUrl)) {
      return;
    }
    
    _preloadingUrls.add(imageUrl);
    
    try {
      // 캐시 너비 결정
      final cacheWidth = overrideMemCacheWidth ?? 
                        calculateMemCacheWidth(MediaQuery.of(context).size.width);
      
      // CachedNetworkImageProvider로 프리로드
      await precacheImage(
        CachedNetworkImageProvider(
          imageUrl,
          maxWidth: cacheWidth,
        ),
        context,
      );
      
      _cachedUrls.add(imageUrl);
      debugPrint('[UnifiedImageCache] 프리로드 완료: ${imageUrl.hashCode}');
    } catch (e) {
      debugPrint('[UnifiedImageCache] 프리로드 실패: ${imageUrl.hashCode}');
    } finally {
      _preloadingUrls.remove(imageUrl);
    }
  }
  
  /// 투표 메시지 이미지 프리로딩 (ChatImageCacheService에서 이동)
  Future<void> preloadVoteMessageImages(
    BuildContext context, {
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
  }) async {
    final urls = <String?>[];
    
    // 단일 이미지
    urls.add(imageUrlA);
    urls.add(imageUrlB);
    
    // 멀티 이미지
    if (imageUrlsA != null) {
      urls.addAll(imageUrlsA);
    }
    if (imageUrlsB != null) {
      urls.addAll(imageUrlsB);
    }
    
    await preloadImages(context, urls);
  }
  
  /// 인접 이미지 프리로드 (PageView용)
  Future<void> preloadAdjacentImages(
    BuildContext context,
    List<String> imageUrls,
    int currentIndex, {
    int range = 2,
  }) async {
    if (!context.mounted || imageUrls.isEmpty) return;
    
    final indicesToPreload = <int>[];
    
    // 앞뒤 range개씩 프리로드
    for (int i = 1; i <= range; i++) {
      if (currentIndex + i < imageUrls.length) {
        indicesToPreload.add(currentIndex + i);
      }
      if (currentIndex - i >= 0) {
        indicesToPreload.add(currentIndex - i);
      }
    }
    
    final urlsToPreload = indicesToPreload
        .where((index) => index >= 0 && index < imageUrls.length)
        .map((index) => imageUrls[index])
        .toList();
    
    await preloadImages(context, urlsToPreload);
  }
  
  /// 캐시 상태 확인
  bool isCached(String imageUrl) {
    return _cachedUrls.contains(imageUrl);
  }
  
  /// 캐시 통계
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedCount': _cachedUrls.length,
      'preloadingCount': _preloadingUrls.length,
      'totalCount': _cachedUrls.length + _preloadingUrls.length,
    };
  }
  
  /// 오래된 캐시 정리
  void clearOldCache({int keepRecentCount = 100}) {
    if (_cachedUrls.length <= keepRecentCount) return;
    
    final urlsToRemove = _cachedUrls.length - keepRecentCount;
    final urlsList = _cachedUrls.toList();
    
    for (int i = 0; i < urlsToRemove; i++) {
      _cachedUrls.remove(urlsList[i]);
      
      // CachedNetworkImage 캐시에서도 제거
      final provider = CachedNetworkImageProvider(urlsList[i]);
      provider.evict();
    }
    
    debugPrint('[UnifiedImageCache] $urlsToRemove개의 오래된 캐시 제거');
  }
  
  /// 특정 이미지 캐시 제거
  void evictFromCache(String imageUrl) {
    _cachedUrls.remove(imageUrl);
    _preloadingUrls.remove(imageUrl);
    
    final provider = CachedNetworkImageProvider(imageUrl);
    provider.evict();
    
    debugPrint('[UnifiedImageCache] 캐시에서 제거: ${imageUrl.hashCode}');
  }
  
  /// 전체 캐시 클리어
  void clearAllCache() {
    _cachedUrls.clear();
    _preloadingUrls.clear();
    PaintingBinding.instance.imageCache.clear();
    debugPrint('[UnifiedImageCache] 전체 캐시 클리어');
  }
  
  /// 캐시 상태 로깅 (디버그용)
  void logCacheStatus() {
    final imageCache = PaintingBinding.instance.imageCache;
    debugPrint('[UnifiedImageCache] 캐시 상태:');
    debugPrint('  - 캐시된 URL: ${_cachedUrls.length}개');
    debugPrint('  - 프리로딩 중: ${_preloadingUrls.length}개');
    debugPrint('  - 이미지 캐시 크기: ${imageCache.currentSizeBytes} bytes');
    debugPrint('  - 이미지 캐시 개수: ${imageCache.currentSize}개');
  }
}