import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 로그를 파일로 저장하는 유틸리티
class FileLogger {
  static File? _logFile;
  static const String _logFileName = 'app_debug.log';

  /// 로그 파일 초기화
  static Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _logFile = File('${directory.path}/$_logFileName');
      
      // 파일이 너무 크면 초기화
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 1024 * 1024) { // 1MB 이상이면
          await _logFile!.writeAsString(''); // 초기화
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('FileLogger 초기화 실패: $e');
      }
    }
  }

  /// 로그 추가
  static Future<void> log(String message) async {
    if (_logFile == null) await initialize();
    
    try {
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] $message\n';
      
      // 파일에 추가
      await _logFile!.writeAsString(
        logEntry,
        mode: FileMode.append,
      );
      
      // 콘솔에도 출력
      if (kDebugMode) {
        print(logEntry.trim());
      }
    } catch (e) {
      if (kDebugMode) {
        print('로그 작성 실패: $e');
      }
    }
  }

  /// 로그 파일 경로 가져오기
  static String? getLogFilePath() {
    return _logFile?.path;
  }

  /// 모든 로그 읽기
  static Future<String> readAllLogs() async {
    if (_logFile == null) await initialize();
    
    try {
      if (await _logFile!.exists()) {
        return await _logFile!.readAsString();
      }
    } catch (e) {
      return 'Error reading logs: $e';
    }
    
    return 'No logs found';
  }

  /// 로그 파일 삭제
  static Future<void> clearLogs() async {
    if (_logFile == null) await initialize();
    
    try {
      if (await _logFile!.exists()) {
        await _logFile!.delete();
        await initialize(); // 새 파일 생성
      }
    } catch (e) {
      if (kDebugMode) {
        print('로그 삭제 실패: $e');
      }
    }
  }
}