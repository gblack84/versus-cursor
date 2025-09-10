import '../repositories/i_notification_repository.dart';

/// Cross-feature Post 데이터 조회 UseCase
/// 
/// Clean Architecture 원칙에 따라 IPostDatasource 접근을 추상화하여
/// Presentation 레이어가 Data 레이어를 직접 참조하지 않도록 함
class GetPostDataUseCase {
  final INotificationRepository _repository;
  
  // 캐시를 위한 메모리 스토어
  final Map<String, Map<String, dynamic>> _cachedPosts = {};
  final Duration _cacheExpiry = const Duration(minutes: 5);
  final Map<String, DateTime> _cacheTimestamps = {};
  
  GetPostDataUseCase(this._repository);
  
  /// Post 데이터 조회
  /// 
  /// [postId] - 조회할 게시물 ID
  /// [useCache] - 캐시 사용 여부
  /// Returns: Post 데이터 Map 또는 null
  Future<Map<String, dynamic>?> execute({
    required String postId,
    bool useCache = true,
  }) async {
    try {
      // 입력 검증
      if (postId.isEmpty) {
        throw ArgumentError('Post ID cannot be empty');
      }
      
      // 캐시 확인
      if (useCache && _isCacheValid(postId)) {
        return _cachedPosts[postId];
      }
      
      // Repository를 통한 데이터 조회
      final postData = await _repository.getPostData(
        postId: postId,
      );
      
      if (postData != null) {
        // 캐시 업데이트
        _updateCache(postId, postData);
      }
      
      return postData;
    } catch (e) {
      throw Exception('Failed to get post data: ${e.toString()}');
    }
  }
  
  /// 캐시 유효성 확인
  bool _isCacheValid(String postId) {
    if (!_cachedPosts.containsKey(postId)) return false;
    
    final timestamp = _cacheTimestamps[postId];
    if (timestamp == null) return false;
    
    return DateTime.now().difference(timestamp) < _cacheExpiry;
  }
  
  /// 캐시 업데이트
  void _updateCache(String postId, Map<String, dynamic> postData) {
    _cachedPosts[postId] = postData;
    _cacheTimestamps[postId] = DateTime.now();
    
    // 캐시 크기 제한 (100개)
    if (_cachedPosts.length > 100) {
      _cleanupCache();
    }
  }
  
  /// 오래된 캐시 정리
  void _cleanupCache() {
    final now = DateTime.now();
    final keysToRemove = <String>[];
    
    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp) >= _cacheExpiry) {
        keysToRemove.add(key);
      }
    });
    
    for (final key in keysToRemove) {
      _cachedPosts.remove(key);
      _cacheTimestamps.remove(key);
    }
  }
  
  /// 캐시 완전 삭제
  void clearCache() {
    _cachedPosts.clear();
    _cacheTimestamps.clear();
  }
}