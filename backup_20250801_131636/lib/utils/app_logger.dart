import 'package:flutter/foundation.dart';

/// 앱 전체에서 사용할 수 있는 로거
class AppLogger {
  static final List<String> _logs = [];
  static const int _maxLogs = 1000;

  /// 액션 로그 추가
  static void logAction(String action, {Map<String, dynamic>? data}) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] ACTION: $action${data != null ? ' | DATA: $data' : ''}';
    
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    
    // 디버그 모드에서만 콘솔에 출력
    if (kDebugMode) {
      print(logEntry);
    }
  }

  /// 네비게이션 로그
  static void logNavigation(String from, String to) {
    logAction('NAVIGATION', data: {'from': from, 'to': to});
  }

  /// 버튼 클릭 로그
  static void logButtonClick(String buttonName, {Map<String, dynamic>? extra}) {
    logAction('BUTTON_CLICK', data: {'button': buttonName, ...?extra});
  }

  /// 에러 로그
  static void logError(String error, {StackTrace? stackTrace}) {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] ERROR: $error${stackTrace != null ? '\nSTACK: $stackTrace' : ''}';
    
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }
    
    if (kDebugMode) {
      print(logEntry);
    }
  }

  /// 모든 로그 가져오기
  static String getAllLogs() {
    return _logs.join('\n');
  }

  /// 최근 N개의 로그 가져오기
  static String getRecentLogs(int count) {
    final start = _logs.length > count ? _logs.length - count : 0;
    return _logs.sublist(start).join('\n');
  }

  /// 로그 초기화
  static void clearLogs() {
    _logs.clear();
  }
}