import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 채팅 이미지 캐싱 서비스
/// 
/// 채팅에서 사용되는 이미지들을 효율적으로 관리하고
/// 프리로딩하여 성능을 최적화합니다.
class ChatImageCacheService {
  static final ChatImageCacheService _instance = ChatImageCacheService._internal();
  static ChatImageCacheService get instance => _instance;
  
  ChatImageCacheService._internal();
  
  // 캐시된 이미지 URL 추적
  final Set<String> _cachedUrls = {};
  
  // 프리로딩 중인 이미지 추적
  final Set<String> _preloadingUrls = {};
  
  /// 이미지 프리로딩
  /// 
  /// 채팅 메시지가 화면에 나타나기 전에 미리 이미지를 로드하여
  /// 사용자 경험을 향상시킵니다.
  Future<void> preloadImage(BuildContext context, String? imageUrl) async {
    if (imageUrl == null || imageUrl.isEmpty) return;
    
    // 이미 캐시되었거나 프리로딩 중이면 스킵
    if (_cachedUrls.contains(imageUrl) || _preloadingUrls.contains(imageUrl)) {
      return;
    }
    
    _preloadingUrls.add(imageUrl);
    
    try {
      await precacheImage(
        CachedNetworkImageProvider(imageUrl),
        context,
      );
      _cachedUrls.add(imageUrl);
    } catch (e) {
      debugPrint('[ChatImageCacheService] 이미지 프리로딩 실패: $e');
    } finally {
      _preloadingUrls.remove(imageUrl);
    }
  }
  
  /// 여러 이미지 동시 프리로딩
  Future<void> preloadImages(BuildContext context, List<String?> imageUrls) async {
    final futures = <Future>[];
    
    for (final url in imageUrls) {
      if (url != null && url.isNotEmpty) {
        futures.add(preloadImage(context, url));
      }
    }
    
    await Future.wait(futures);
  }
  
  /// 투표 메시지의 이미지 프리로딩
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
  
  /// 캐시 정리 (메모리 관리)
  void clearOldCache({int keepRecentCount = 100}) {
    if (_cachedUrls.length <= keepRecentCount) return;
    
    // 가장 오래된 URL들 제거
    final urlsToRemove = _cachedUrls.length - keepRecentCount;
    final iterator = _cachedUrls.iterator;
    var removed = 0;
    
    while (iterator.moveNext() && removed < urlsToRemove) {
      _cachedUrls.remove(iterator.current);
      removed++;
    }
    
    debugPrint('[ChatImageCacheService] $removed개의 오래된 캐시 제거');
  }
  
  /// 전체 캐시 클리어
  void clearAllCache() {
    _cachedUrls.clear();
    _preloadingUrls.clear();
    PaintingBinding.instance.imageCache.clear();
    debugPrint('[ChatImageCacheService] 전체 캐시 클리어');
  }
}