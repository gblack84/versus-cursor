import 'package:flutter/foundation.dart';

/// 간단한 메모리 캐시 서비스
///
/// LRU(Least Recently Used) 정책을 사용하여 메모리 효율적으로 관리
class SimpleMemoryCache {
  // 싱글톤 인스턴스
  static final SimpleMemoryCache _instance = SimpleMemoryCache._internal();
  static SimpleMemoryCache get instance => _instance;

  SimpleMemoryCache._internal();

  // 캐시 저장소
  final Map<String, CacheEntry> _cache = {};

  // 캐시 설정
  static const int maxCacheSize = 100; // 최대 캐시 항목 수
  static const Duration defaultTTL = Duration(minutes: 5); // 기본 TTL

  // 통계
  int _hits = 0;
  int _misses = 0;

  /// 캐시에서 데이터 가져오기
  T? get<T>(String key) {
    final entry = _cache[key];

    if (entry == null) {
      _misses++;
      _logDebug('Cache MISS: $key');
      return null;
    }

    // TTL 확인
    if (entry.isExpired) {
      _cache.remove(key);
      _misses++;
      _logDebug('Cache EXPIRED: $key');
      return null;
    }

    // LRU 업데이트
    entry.lastAccessed = DateTime.now();
    _hits++;
    _logDebug('Cache HIT: $key');

    return entry.data as T?;
  }

  /// 캐시에 데이터 저장
  void set<T>(String key, T value, {Duration? ttl}) {
    // 캐시 크기 제한 확인
    if (_cache.length >= maxCacheSize && !_cache.containsKey(key)) {
      _evictLRU();
    }

    _cache[key] = CacheEntry(
      data: value,
      ttl: ttl ?? defaultTTL,
    );

    _logDebug('Cache SET: $key');
  }

  /// 특정 키 삭제
  void remove(String key) {
    _cache.remove(key);
    _logDebug('Cache REMOVE: $key');
  }

  /// 패턴에 매칭되는 모든 키 삭제
  void invalidate(String pattern) {
    final keysToRemove =
        _cache.keys.where((key) => key.contains(pattern)).toList();

    for (final key in keysToRemove) {
      _cache.remove(key);
    }

    _logDebug('Cache INVALIDATE: $pattern (${keysToRemove.length} items)');
  }

  /// 전체 캐시 클리어
  void clear() {
    _cache.clear();
    _hits = 0;
    _misses = 0;
    _logDebug('Cache CLEARED');
  }

  /// LRU 정책에 따라 가장 오래된 항목 제거
  void _evictLRU() {
    if (_cache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _cache.entries) {
      if (oldestTime == null || entry.value.lastAccessed.isBefore(oldestTime)) {
        oldestTime = entry.value.lastAccessed;
        oldestKey = entry.key;
      }
    }

    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _logDebug('Cache EVICT: $oldestKey (LRU)');
    }
  }

  /// 캐시 통계
  double get hitRate => _hits + _misses == 0 ? 0 : _hits / (_hits + _misses);
  int get size => _cache.length;

  /// 디버그 로깅
  void _logDebug(String message) {
    if (kDebugMode) {
      final stats =
          'Hit Rate: ${(hitRate * 100).toStringAsFixed(1)}%, Size: $size/$maxCacheSize';
      debugPrint('[MemoryCache] $message | $stats');
    }
  }
}

/// 캐시 엔트리
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration ttl;
  DateTime lastAccessed;

  CacheEntry({
    required this.data,
    required this.ttl,
  })  : createdAt = DateTime.now(),
        lastAccessed = DateTime.now();

  bool get isExpired => DateTime.now().difference(createdAt) > ttl;
}

/// 캐시 키 생성 헬퍼
class CacheKeys {
  // 채팅 관련
  static String chatMessages(String chatId) => 'chat_messages_$chatId';
  static String chatList() => 'chat_list';
  static String chatParticipants(String chatId) => 'chat_participants_$chatId';

  // 피드 관련
  static String feedPosts() => 'feed_posts';
  static String popularPosts() => 'popular_posts';
  static String userPosts(String userId) => 'user_posts_$userId';

  // 사용자 관련
  static String userProfile(String userId) => 'user_profile_$userId';
  static String userAvatar(String userId) => 'user_avatar_$userId';

  // 미디어 관련
  static String mediaThumb(String url) => 'media_thumb_${url.hashCode}';
  static String mediaFull(String url) => 'media_full_${url.hashCode}';
}
