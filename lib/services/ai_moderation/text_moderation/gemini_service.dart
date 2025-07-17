import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/moderation_result.dart';

/// Gemini AI를 활용한 콘텐츠 검증 서비스 (Cloud Functions 버전)
class GeminiModerationService {
  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
  
  /// 초기화 (더 이상 필요 없음 - Cloud Functions 사용)
  static void initialize() {
    print('[GeminiModerationService] Using Cloud Functions for Gemini AI');
  }
  
  /// Gemini AI로 포스트 콘텐츠 검증 (Cloud Functions 호출)
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
    String? sessionId,
    String? documentId,
    int? revisionCount,
  }) async {
    try {
      print('[GeminiModerationService] Calling Cloud Function validatePostContentWithGemini');
      
      // Cloud Function 호출
      final callable = _functions.httpsCallable('validatePostContentWithGemini');
      final response = await callable.call<Map<String, dynamic>>({
        'question': questionTitle,
        'titleA': titleA,
        'titleB': titleB,
        'descriptionText': description,
        'imageUrlA': imageUrlA,
        'imageUrlB': imageUrlB,
        'visionDataA': visionDataA,
        'visionDataB': visionDataB,
        'perspectiveData': perspectiveScores,
        'userId': userId,
        'sessionId': sessionId,
        'documentId': documentId,
        'revisionCount': revisionCount,
      });
      
      final result = response.data;
      print('[GeminiModerationService] Response received from Cloud Function');
      
      // 새로운 응답 형식 확인 (action 필드가 있는지)
      if (result['action'] != null) {
        print('[GeminiModerationService] New format detected - action: ${result['action']}');
        
        // 새 형식을 기존 형식으로 변환
        final isValid = result['action'] != 'BLOCK';
        final severityMap = {
          'PROCEED': 'pass',
          'PROCEED_WITH_SUGGESTION': 'warning',
          'BLOCK': 'error'
        };
        final severity = severityMap[result['action']] ?? 'pass';
        final feedback = result['feedback'] as Map<String, dynamic>?;
        
        return GeminiModerationResult(
          isValid: isValid,
          reason: feedback?['title'] ?? '',
          severity: severity,
          suggestions: feedback?['description'] ?? '',
          confidence: (result['confidence'] ?? 1.0).toDouble(),
          documentId: result['documentId'] as String?,
        );
      }
      
      // 기존 형식 처리 (하위 호환성)
      print('[GeminiModerationService] isValid: ${result['isValid']}, severity: ${result['severity']}');
      
      // Cloud Function에서 반환한 결과를 GeminiModerationResult로 변환
      return GeminiModerationResult(
        isValid: result['isValid'] ?? true,
        reason: result['reason'] ?? '',
        severity: result['severity'] ?? 'pass',
        suggestions: result['suggestions'] ?? '',
        confidence: (result['confidence'] ?? 1.0).toDouble(),
        documentId: result['documentId'] as String?,
      );
    } on FirebaseFunctionsException catch (e) {
      print('[GeminiModerationService] Cloud Function Error: ${e.code} - ${e.message}');
      print('[GeminiModerationService] Details: ${e.details}');
      
      // 인증 오류
      if (e.code == 'unauthenticated') {
        throw Exception('로그인이 필요합니다.');
      }
      
      // 기타 오류는 상위로 전파
      throw Exception('Gemini AI 검증 중 오류가 발생했습니다: ${e.message}');
    } catch (e) {
      print('[GeminiModerationService] Unexpected Error: $e');
      print('[GeminiModerationService] Error type: ${e.runtimeType}');
      
      // 예상치 못한 오류
      throw Exception('콘텐츠 검증 중 오류가 발생했습니다.');
    }
  }
}