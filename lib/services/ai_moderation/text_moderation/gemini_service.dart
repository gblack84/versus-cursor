import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/moderation_result.dart';
import '../constants/moderation_config.dart';

/// Gemini AI를 활용한 콘텐츠 검증 서비스
class GeminiModerationService {
  static final FirebaseFunctions _functions = 
      FirebaseFunctions.instanceFor(region: 'asia-northeast3');
  
  /// Gemini AI로 포스트 콘텐츠 검증
  static Future<GeminiModerationResult?> validateContent({
    required String userId,
    required String? questionTitle,
    required String? description,
    required String? titleA,
    required String? titleB,
    String? imageUrlA,
    String? imageUrlB,
    Map<String, dynamic>? visionDataA,
    Map<String, dynamic>? visionDataB,
    Map<String, double>? perspectiveScores,
  }) async {
    try {
      final callable = _functions.httpsCallable('validatePostContentWithGemini');
      
      final response = await callable.call({
        'question': questionTitle ?? '',
        'titleA': titleA ?? '',
        'titleB': titleB ?? '',
        'descriptionText': description ?? '',
        'imageUrlA': imageUrlA,
        'imageUrlB': imageUrlB,
        'visionDataA': visionDataA,
        'visionDataB': visionDataB,
        'perspectiveData': perspectiveScores,
        'userId': userId,
      }).timeout(ModerationConfig.apiTimeout);
      
      final data = response.data as Map<String, dynamic>;
      
      return GeminiModerationResult(
        isValid: data['isValid'] ?? true,
        reason: data['reason'] ?? '',
        severity: data['severity'] ?? 'pass',
        suggestions: data['suggestions'] ?? '',
        confidence: (data['confidence'] ?? 0.5).toDouble(),
      );
      
    } on FirebaseFunctionsException catch (e) {
      print('[GeminiModeration] Firebase Functions error: ${e.code} - ${e.message}');
      return null;
    } on TimeoutException {
      print('[GeminiModeration] Request timeout');
      return null;
    } catch (e) {
      print('[GeminiModeration] Unexpected error: $e');
      return null;
    }
  }

  /// 사용자 포스팅 이력 조회
  static Future<Map<String, dynamic>> getUserHistory(String userId) async {
    try {
      // 이 부분은 필요시 별도 Cloud Function으로 구현
      // 현재는 validatePostContentWithGemini 함수 내부에서 처리
      return {
        'rejectedCount': 0,
        'reportCount': 0,
        'isNewUser': true,
      };
    } catch (e) {
      print('[GeminiModeration] Error fetching user history: $e');
      return {
        'rejectedCount': 0,
        'reportCount': 0,
        'isNewUser': true,
      };
    }
  }

  /// Gemini 결과를 사용자 친화적 메시지로 변환
  static String formatUserMessage(GeminiModerationResult result) {
    if (result.isValid) {
      return '';
    }
    
    switch (result.severity) {
      case 'error':
        return result.reason;
      case 'warning':
        return '개선이 필요합니다: ${result.reason}';
      default:
        return result.reason;
    }
  }

  /// 심각도에 따른 처리 방식 결정
  static bool shouldBlockContent(GeminiModerationResult result) {
    return !result.isValid && result.severity == 'error';
  }

  static bool shouldShowWarning(GeminiModerationResult result) {
    return result.isValid && result.severity == 'warning';
  }
}