import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import '/services/logging/debug_service.dart';

/// 에러 타입 정의
enum ErrorType {
  network,
  storage,
  validation,
  permission,
  imageProcessing,
  moderation,
  unknown,
}

/// 에러 처리 결과
class ErrorHandlingResult {
  final bool handled;
  final String? userMessage;
  final dynamic originalError;

  ErrorHandlingResult({
    required this.handled,
    this.userMessage,
    this.originalError,
  });
}

/// 중앙 집중식 에러 처리 클래스
class ErrorHandler {
  /// 에러 메시지 매핑
  static const Map<ErrorType, String> _errorMessages = {
    ErrorType.network: '네트워크 연결을 확인해주세요.',
    ErrorType.storage: '저장 공간이 부족합니다.',
    ErrorType.validation: '입력 내용을 확인해주세요.',
    ErrorType.permission: '필요한 권한이 없습니다.',
    ErrorType.imageProcessing: '이미지 처리 중 오류가 발생했습니다.',
    ErrorType.moderation: '콘텐츠 검열 중 오류가 발생했습니다.',
    ErrorType.unknown: '알 수 없는 오류가 발생했습니다.',
  };

  /// 에러 처리 및 로깅
  static ErrorHandlingResult handle(
    dynamic error, {
    ErrorType? type,
    String? customMessage,
    bool showToast = true,
    BuildContext? context,
    StackTrace? stackTrace,
  }) {
    // 에러 타입 자동 감지
    final errorType = type ?? _detectErrorType(error);

    // 사용자 메시지 결정
    final userMessage = customMessage ??
        _getUserMessage(error, errorType) ??
        _errorMessages[errorType] ??
        _errorMessages[ErrorType.unknown]!;

    // 디버그 로깅
    DebugHelper.logError('[$errorType] $userMessage', error);
    if (stackTrace != null && DebugHelper.isDebugMode) {
      print('StackTrace: $stackTrace');
    }

    // Toast 표시
    if (showToast && context != null && context.mounted) {
      _showErrorToast(userMessage);
    }

    return ErrorHandlingResult(
      handled: true,
      userMessage: userMessage,
      originalError: error,
    );
  }

  /// 비동기 작업 래퍼
  static Future<T?> tryAsync<T>(
    Future<T> Function() operation, {
    ErrorType? type,
    String? customMessage,
    bool showToast = true,
    BuildContext? context,
    T? defaultValue,
    void Function(ErrorHandlingResult)? onError,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      final result = handle(
        error,
        type: type,
        customMessage: customMessage,
        showToast: showToast,
        context: context,
        stackTrace: stackTrace,
      );

      onError?.call(result);
      return defaultValue;
    }
  }

  /// 동기 작업 래퍼
  static T? trySync<T>(
    T Function() operation, {
    ErrorType? type,
    String? customMessage,
    bool showToast = true,
    BuildContext? context,
    T? defaultValue,
    void Function(ErrorHandlingResult)? onError,
  }) {
    try {
      return operation();
    } catch (error, stackTrace) {
      final result = handle(
        error,
        type: type,
        customMessage: customMessage,
        showToast: showToast,
        context: context,
        stackTrace: stackTrace,
      );

      onError?.call(result);
      return defaultValue;
    }
  }

  /// 에러 타입 자동 감지
  static ErrorType _detectErrorType(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return ErrorType.network;
    }

    if (errorString.contains('permission') ||
        errorString.contains('denied') ||
        errorString.contains('unauthorized')) {
      return ErrorType.permission;
    }

    if (errorString.contains('storage') ||
        errorString.contains('disk') ||
        errorString.contains('space')) {
      return ErrorType.storage;
    }

    if (errorString.contains('validation') ||
        errorString.contains('invalid') ||
        errorString.contains('format')) {
      return ErrorType.validation;
    }

    if (errorString.contains('image') ||
        errorString.contains('photo') ||
        errorString.contains('picture')) {
      return ErrorType.imageProcessing;
    }

    if (errorString.contains('moderation') ||
        errorString.contains('content') ||
        errorString.contains('inappropriate')) {
      return ErrorType.moderation;
    }

    return ErrorType.unknown;
  }

  /// 에러 객체에서 사용자 메시지 추출
  static String? _getUserMessage(dynamic error, ErrorType type) {
    if (error is Exception) {
      final message = error.toString();
      // "Exception: " 접두사 제거
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
    }

    // Firebase 에러 처리
    if (error.toString().contains('firebase')) {
      return _handleFirebaseError(error);
    }

    return null;
  }

  /// Firebase 에러 메시지 처리
  static String _handleFirebaseError(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('permission-denied')) {
      return '권한이 없습니다.';
    }
    if (errorString.contains('not-found')) {
      return '요청한 데이터를 찾을 수 없습니다.';
    }
    if (errorString.contains('already-exists')) {
      return '이미 존재하는 데이터입니다.';
    }
    if (errorString.contains('quota-exceeded')) {
      return '할당량을 초과했습니다.';
    }

    return '서버 오류가 발생했습니다.';
  }

  /// 에러 토스트 표시
  static void _showErrorToast(String message) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.red.shade700.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }

  /// 성공 토스트 표시 (에러 처리와 일관성을 위해)
  static void showSuccessToast(String message) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.green.shade700.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 3),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }
}
