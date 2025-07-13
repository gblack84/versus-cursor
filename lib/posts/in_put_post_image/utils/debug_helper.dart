import 'package:flutter/foundation.dart';

/// 디버그 헬퍼 클래스
/// 모든 디버그 출력을 중앙에서 관리
class DebugHelper {
  /// 디버그 모드인지 확인
  static bool get isDebugMode => !kReleaseMode;
  
  /// 조건부 디버그 출력
  static void log(String message, {String? tag}) {
    if (!kReleaseMode) {
      final prefix = tag != null ? '[$tag] ' : '';
      print('$prefix$message');
    }
  }
  
  /// 스마트 레이아웃 디버그 로그
  static void logLayout(String message) {
    log(message, tag: 'Layout');
  }
  
  /// 이미지 업로드 디버그 로그
  static void logUpload(String message) {
    log(message, tag: 'Upload');
  }
  
  /// 에러 디버그 로그
  static void logError(String message, [dynamic error]) {
    if (!kReleaseMode) {
      if (error != null) {
        print('[Error] $message: $error');
      } else {
        print('[Error] $message');
      }
    }
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
}