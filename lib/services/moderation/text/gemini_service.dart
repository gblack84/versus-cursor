import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
import '/services/moderation/models/moderation_result.dart';
import '../interfaces/i_gemini_moderation_service.dart';

/// Gemini AI를 활용한 콘텐츠 검증 서비스 (Port-Adapter Pattern Adapter)
///
/// Cloud Functions를 통해 Gemini AI 기반 콘텐츠 검증을 수행합니다.
/// - 콘텐츠 논리성 검증
/// - 컨텍스트 적절성 분석
/// - 예상 투표 비율 예측
///
/// **Port-Adapter Pattern**:
/// - Implements: IGeminiModerationService (Port)
/// - Adapts: FirebaseFunctions (Cloud Functions HTTP callable)
///
/// **Phase 2-Cleanup**: ✅ Static → Instance 변환 완료
/// **DI Pattern**: Constructor injection for FirebaseFunctions
class GeminiModerationService implements IGeminiModerationService {
  final FirebaseFunctions _functions;

  /// Constructor injection for Firebase Functions
  GeminiModerationService({
    required FirebaseFunctions functions,
  }) : _functions = functions;

  /// 초기화 (더 이상 필요 없음 - Cloud Functions 사용)
  @override
  void initialize() {
    print('[GeminiModerationService] Using Cloud Functions for Gemini AI');
  }

  /// Gemini AI로 포스트 콘텐츠 검증 (Cloud Functions 호출)
  @override
  Future<GeminiModerationResult?> validateContent({
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
      print(
          '[GeminiModerationService] Calling Cloud Function validatePostContentWithGemini');

      // Cloud Function 호출
      final callable =
          _functions.httpsCallable('validatePostContentWithGemini');
      final response = await callable.call({
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

      // 타입 안전 변환
      final result = Map<String, dynamic>.from(response.data as Map);
      print('[GeminiModerationService] Response received from Cloud Function');
      print('[GeminiModerationService] Full response data: ${response.data}');
      print(
          '[GeminiModerationService] expectedRatio in response: ${result['expectedRatio']}');

      // 새로운 응답 형식 확인 (action 필드가 있는지)
      if (result['action'] != null) {
        print(
            '[GeminiModerationService] New format detected - action: ${result['action']}');

        // 새 형식을 기존 형식으로 변환
        final isValid = result['action'] != 'BLOCK';
        final severityMap = {
          'PROCEED': 'pass',
          'PROCEED_WITH_SUGGESTION': 'warning',
          'BLOCK': 'error'
        };
        final severity = severityMap[result['action']] ?? 'pass';
        final feedback = result['feedback'] as Map<String, dynamic>?;

        // expectedRatio 처리
        final expectedRatio = result['expectedRatio'] != null
            ? Map<String, dynamic>.from(result['expectedRatio'] as Map)
            : null;

        print(
            '[GeminiModerationService] Creating GeminiModerationResult with:');
        print('  - expectedRatioA: ${expectedRatio?['A']?.toDouble() ?? 0.5}');
        print('  - expectedRatioB: ${expectedRatio?['B']?.toDouble() ?? 0.5}');

        return GeminiModerationResult(
          isValid: isValid,
          reason: feedback?['title'] ?? '',
          severity: severity,
          suggestions: feedback?['description'] ?? '',
          confidence: (result['confidence'] ?? 1.0).toDouble(),
          documentId: result['documentId'] as String?,
          expectedRatioA: expectedRatio?['A']?.toDouble() ?? 0.5,
          expectedRatioB: expectedRatio?['B']?.toDouble() ?? 0.5,
        );
      }

      // 기존 형식 처리 (하위 호환성)
      print(
          '[GeminiModerationService] isValid: ${result['isValid']}, severity: ${result['severity']}');

      // expectedRatio 처리
      final expectedRatio = result['expectedRatio'] != null
          ? Map<String, dynamic>.from(result['expectedRatio'] as Map)
          : null;

      // Cloud Function에서 반환한 결과를 GeminiModerationResult로 변환
      return GeminiModerationResult(
        isValid: result['isValid'] ?? true,
        reason: result['reason'] ?? '',
        severity: result['severity'] ?? 'pass',
        suggestions: result['suggestions'] ?? '',
        confidence: (result['confidence'] ?? 1.0).toDouble(),
        documentId: result['documentId'] as String?,
        expectedRatioA: expectedRatio?['A']?.toDouble() ?? 0.5,
        expectedRatioB: expectedRatio?['B']?.toDouble() ?? 0.5,
      );
    } on FirebaseFunctionsException catch (e) {
      print(
          '[GeminiModerationService] Cloud Function Error: ${e.code} - ${e.message}');
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
