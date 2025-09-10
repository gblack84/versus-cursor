import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../i_local_notification_datasource.dart';

/// SharedPreferences를 사용하는 Local DataSource 구현체
/// 
/// 알림 데이터를 로컬에 캐싱하여 오프라인 지원 및
/// 성능 향상을 제공합니다.
class SharedPrefsNotificationDatasource implements ILocalNotificationDatasource {
  static const String _processedIdsKey = 'processed_notification_ids';
  static const String _cachePrefix = 'cached_notifications_';
  static const String _cacheTimePrefix = 'cache_time_';
  static const String _preferencesPrefix = 'notification_prefs_';
  
  // 캐시 만료 시간 (30분)
  static const Duration _cacheExpiry = Duration(minutes: 30);
  
  // 최대 캐시 크기
  static const int _maxCacheSize = 100;
  
  final SharedPreferences _prefs;
  
  SharedPrefsNotificationDatasource({
    required SharedPreferences prefs,
  }) : _prefs = prefs;
  
  @override
  Future<Set<String>> getProcessedNotificationIds() async {
    final List<String>? ids = _prefs.getStringList(_processedIdsKey);
    return ids?.toSet() ?? {};
  }
  
  @override
  Future<void> saveProcessedNotificationIds(Set<String> ids) async {
    await _prefs.setStringList(_processedIdsKey, ids.toList());
  }
  
  @override
  Future<void> addProcessedNotificationId(String id) async {
    final currentIds = await getProcessedNotificationIds();
    currentIds.add(id);
    await saveProcessedNotificationIds(currentIds);
  }
  
  @override
  Future<void> clearProcessedNotificationIds() async {
    await _prefs.remove(_processedIdsKey);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getCachedNotifications(String userId) async {
    final cacheKey = '$_cachePrefix$userId';
    final timeKey = '$_cacheTimePrefix$userId';
    
    // 캐시 시간 확인
    final lastCacheTime = await getLastCacheTime(userId);
    if (lastCacheTime != null) {
      final difference = DateTime.now().difference(lastCacheTime);
      if (difference > _cacheExpiry) {
        // 캐시 만료
        await clearCache(userId);
        return [];
      }
    }
    
    // 캐시된 데이터 가져오기
    final String? cachedJson = _prefs.getString(cacheKey);
    if (cachedJson == null) return [];
    
    try {
      final List<dynamic> decodedList = json.decode(cachedJson);
      return decodedList.map((item) => item as Map<String, dynamic>).toList();
    } catch (e) {
      // 캐시 데이터 손상 시 삭제
      await clearCache(userId);
      return [];
    }
  }
  
  @override
  Future<void> cacheNotifications(
    String userId,
    List<Map<String, dynamic>> notifications,
  ) async {
    final cacheKey = '$_cachePrefix$userId';
    final timeKey = '$_cacheTimePrefix$userId';
    
    // 최대 크기 제한
    final limitedNotifications = notifications.take(_maxCacheSize).toList();
    
    // JSON으로 직렬화
    final String jsonString = json.encode(limitedNotifications);
    
    // 저장
    await _prefs.setString(cacheKey, jsonString);
    await updateCacheTime(userId, DateTime.now());
  }
  
  @override
  Future<void> clearCache(String userId) async {
    final cacheKey = '$_cachePrefix$userId';
    final timeKey = '$_cacheTimePrefix$userId';
    
    await _prefs.remove(cacheKey);
    await _prefs.remove(timeKey);
  }
  
  @override
  Future<void> clearAllCache() async {
    // 모든 캐시 관련 키 찾기
    final allKeys = _prefs.getKeys();
    final cacheKeys = allKeys.where((key) => 
      key.startsWith(_cachePrefix) || 
      key.startsWith(_cacheTimePrefix) ||
      key.startsWith(_preferencesPrefix)
    );
    
    // 일괄 삭제
    for (final key in cacheKeys) {
      await _prefs.remove(key);
    }
  }
  
  @override
  Future<DateTime?> getLastCacheTime(String userId) async {
    final timeKey = '$_cacheTimePrefix$userId';
    final int? timestamp = _prefs.getInt(timeKey);
    
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }
  
  @override
  Future<void> updateCacheTime(String userId, DateTime time) async {
    final timeKey = '$_cacheTimePrefix$userId';
    await _prefs.setInt(timeKey, time.millisecondsSinceEpoch);
  }
  
  @override
  Future<Map<String, dynamic>> getNotificationPreferences(String userId) async {
    final prefKey = '$_preferencesPrefix$userId';
    final String? prefsJson = _prefs.getString(prefKey);
    
    if (prefsJson == null) {
      // 기본 설정 반환
      return {
        'enablePushNotifications': true,
        'enableInAppNotifications': true,
        'notificationTypes': {
          'votingRequest': true,
          'systemAlert': true,
          'social': true,
        },
        'quietHoursEnabled': false,
        'quietHoursStart': '22:00',
        'quietHoursEnd': '08:00',
      };
    }
    
    try {
      return json.decode(prefsJson) as Map<String, dynamic>;
    } catch (e) {
      // 손상된 데이터 시 기본값 반환
      return {};
    }
  }
  
  @override
  Future<void> saveNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  ) async {
    final prefKey = '$_preferencesPrefix$userId';
    final String jsonString = json.encode(preferences);
    await _prefs.setString(prefKey, jsonString);
  }
  
  @override
  Future<bool> isNotificationCached(String notificationId) async {
    // 모든 사용자의 캐시를 확인
    final allKeys = _prefs.getKeys();
    final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));
    
    for (final key in cacheKeys) {
      final String? cachedJson = _prefs.getString(key);
      if (cachedJson != null) {
        try {
          final List<dynamic> notifications = json.decode(cachedJson);
          final exists = notifications.any((notif) => notif['id'] == notificationId);
          if (exists) return true;
        } catch (e) {
          continue;
        }
      }
    }
    
    return false;
  }
  
  @override
  Future<Map<String, dynamic>?> getCachedNotification(String notificationId) async {
    // 모든 사용자의 캐시를 확인
    final allKeys = _prefs.getKeys();
    final cacheKeys = allKeys.where((key) => key.startsWith(_cachePrefix));
    
    for (final key in cacheKeys) {
      final String? cachedJson = _prefs.getString(key);
      if (cachedJson != null) {
        try {
          final List<dynamic> notifications = json.decode(cachedJson);
          final notification = notifications.firstWhere(
            (notif) => notif['id'] == notificationId,
            orElse: () => null,
          );
          if (notification != null) {
            return notification as Map<String, dynamic>;
          }
        } catch (e) {
          continue;
        }
      }
    }
    
    return null;
  }
  
  @override
  Future<void> cacheNotification(
    String notificationId,
    Map<String, dynamic> notification,
  ) async {
    // notification에서 userId 추출
    final userId = notification['userId'] as String?;
    if (userId == null) return;
    
    // 기존 캐시 가져오기
    final cachedNotifications = await getCachedNotifications(userId);
    
    // 중복 확인 및 추가
    final index = cachedNotifications.indexWhere((n) => n['id'] == notificationId);
    if (index >= 0) {
      // 기존 항목 업데이트
      cachedNotifications[index] = notification;
    } else {
      // 새 항목 추가 (맨 앞에)
      cachedNotifications.insert(0, notification);
    }
    
    // 다시 캐싱
    await cacheNotifications(userId, cachedNotifications);
  }
}