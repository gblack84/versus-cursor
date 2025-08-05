import 'package:flutter/foundation.dart';

/// 로그 레벨 열거형
enum LogLevel {
  DEBUG,
  INFO,
  WARNING,
  ERROR,
}

/// 디버그 헬퍼 클래스
/// 모든 디버그 출력을 중앙에서 관리하고 로그 레벨을 지원
class DebugHelper {
  /// 최소 로그 레벨 (릴리즈 모드에서는 WARNING 이상만 출력)
  static LogLevel minimumLevel = kReleaseMode ? LogLevel.WARNING : LogLevel.DEBUG;
  
  /// 로그 레벨별 이모지
  static const Map<LogLevel, String> _levelEmojis = {
    LogLevel.DEBUG: '🔍',
    LogLevel.INFO: 'ℹ️',
    LogLevel.WARNING: '⚠️',
    LogLevel.ERROR: '❌',
  };
  
  /// 디버그 모드인지 확인
  static bool get isDebugMode => !kReleaseMode;
  
  /// 조건부 디버그 출력 (기존 호환성 유지)
  static void log(String message, {String? tag}) {
    debug(message, tag: tag);
  }
  
  /// DEBUG 레벨 로그
  static void debug(String message, {String? tag}) {
    _log(LogLevel.DEBUG, message, tag: tag);
  }
  
  /// INFO 레벨 로그
  static void info(String message, {String? tag}) {
    _log(LogLevel.INFO, message, tag: tag);
  }
  
  /// WARNING 레벨 로그
  static void warning(String message, {String? tag}) {
    _log(LogLevel.WARNING, message, tag: tag);
  }
  
  /// ERROR 레벨 로그
  static void error(String message, {dynamic error, String? tag}) {
    final errorMessage = error != null ? '$message: $error' : message;
    _log(LogLevel.ERROR, errorMessage, tag: tag);
  }
  
  /// 내부 로그 메서드
  static void _log(LogLevel level, String message, {String? tag}) {
    // 로그 레벨 확인
    if (level.index < minimumLevel.index) return;
    
    final emoji = _levelEmojis[level] ?? '';
    final prefix = tag != null ? '[$tag] ' : '';
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    
    print('$timestamp $emoji $prefix$message');
  }
  
  /// 스마트 레이아웃 디버그 로그
  static void logLayout(String message) {
    log(message, tag: 'Layout');
  }
  
  /// 이미지 업로드 디버그 로그
  static void logUpload(String message) {
    log(message, tag: 'Upload');
  }
  
  /// 에러 디버그 로그 (기존 호환성 유지)
  static void logError(String message, [dynamic error]) {
    DebugHelper.error(message, error: error, tag: 'Error');
  }
  
  /// 이미지 선택 디버그 로그
  static void logImageSelection(String message) {
    log(message, tag: 'ImageSelection');
  }
  
  /// 검열 디버그 로그
  static void logModeration(String message) {
    log(message, tag: 'Moderation');
  }
  
  /// API 호출 디버그 로그
  static void logApi(String message) {
    log(message, tag: 'API');
  }
  
  /// 파이어베이스 디버그 로그
  static void logFirebase(String message) {
    log(message, tag: 'Firebase');
  }
  
  /// 조건부 실행 (디버그 모드에서만 실행)
  static void runInDebug(void Function() callback) {
    if (!kReleaseMode) {
      callback();
    }
  }
  
  /// 데이터 마스킹 유틸리티
  static String maskData(dynamic data) {
    if (data == null) return 'null';
    
    if (data is Map) {
      return 'Map(${data.length} items)';
    } else if (data is List) {
      return 'List(${data.length} items)';
    } else if (data is String && data.length > 50) {
      return '${data.substring(0, 20)}...${data.substring(data.length - 10)}';
    }
    
    return data.toString();
  }
  
  /// 민감한 데이터 마스킹
  static String maskSensitive(String value, {int visibleChars = 4}) {
    if (value.length <= visibleChars * 2) return value;
    
    final start = value.substring(0, visibleChars);
    final end = value.substring(value.length - visibleChars);
    return '$start....$end';
  }
}