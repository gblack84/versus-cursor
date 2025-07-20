import 'package:flutter/material.dart';
import '/services/perspective_api_service.dart';
import 'models/moderation_result.dart';
import 'constants/moderation_config.dart';
import 'text_moderation/gemini_service.dart';
import '/design_system/design_system.dart';

/// 통합 AI 검열 서비스
/// 
/// 모든 AI 기반 콘텐츠 검열을 중앙에서 관리합니다.
/// - Perspective API (텍스트 유해성)
/// - Vision API (이미지 검열)
/// - Gemini AI (콘텐츠 논리성)
class AIModerationService {
  /// 포스트 콘텐츠 전체 검증
  static Future<ModerationResult> moderatePostContent({
    required ModerationRequest request,
    ModerationOptions options = ModerationOptions.defaultOptions,
    Function(String)? onProgressUpdate,
  }) async {
    final violations = <String>[];
    TextModerationResult? textResult;
    GeminiModerationResult? geminiResult;
    
    try {
      // 1단계: 텍스트 유해성 검사 (Perspective API)
      if (options.enablePerspectiveAPI) {
        onProgressUpdate?.call('텍스트를 검토하고 있습니다...');
        textResult = await _moderateText(request);
        
        if (textResult.isToxic) {
          violations.add(_formatTextViolation(textResult));
        }
      }

      // 2단계: 텍스트 검증 통과 시 Gemini AI 검증
      if (options.enableGeminiAI && violations.isEmpty) {
        onProgressUpdate?.call('AI가 내용을 분석하고 있습니다...');
        
        // 클라이언트에서 직접 Gemini 호출
        geminiResult = await GeminiModerationService.validateContent(
          userId: request.userId,
          questionTitle: request.questionTitle,
          description: request.description,
          titleA: request.titleA,
          titleB: request.titleB,
          imageUrlA: request.imageUrlsA?.firstOrNull,
          imageUrlB: request.imageUrlsB?.firstOrNull,
          visionDataA: request.visionDataA,
          visionDataB: request.visionDataB,
          perspectiveScores: textResult?.scores,
          sessionId: request.sessionId,
          documentId: request.documentId,
          revisionCount: request.revisionCount,
        );
        
        if (geminiResult != null) {
          if (!geminiResult.isValid) {
            violations.add(geminiResult.reason);
          } else if (geminiResult.severity == 'warning') {
            // 경고는 violations에 추가하지 않고 결과에만 포함
          }
        } else {
          // Gemini API 실패 시 로그만 남기고 계속 진행
          print('[AIModerationService] Gemini API 응답 없음 - 기본 통과 처리');
        }
      }

      // 3단계: 최종 결과 생성
      final severity = _determineSeverity(textResult, geminiResult, violations);
      
      return ModerationResult(
        isValid: violations.isEmpty || severity == 'warning',
        severity: severity,
        violations: violations,
        textResult: textResult,
        geminiResult: geminiResult,
      );
      
    } catch (e) {
      print('[AIModerationService] Error: $e');
      return ModerationResult(
        isValid: false,
        severity: 'error',
        violations: violations,
        errorMessage: '검증 중 오류가 발생했습니다.',
      );
    }
  }

  /// 텍스트 검열 (Perspective API)
  static Future<TextModerationResult> _moderateText(ModerationRequest request) async {
    final textsToValidate = <String, String>{};
    
    if (request.questionTitle?.isNotEmpty == true) {
      textsToValidate['질문'] = request.questionTitle!;
    }
    if (request.description?.isNotEmpty == true) {
      textsToValidate['설명'] = request.description!;
    }
    if (request.titleA?.isNotEmpty == true) {
      textsToValidate['A 옵션'] = request.titleA!;
    }
    if (request.titleB?.isNotEmpty == true) {
      textsToValidate['B 옵션'] = request.titleB!;
    }

    if (textsToValidate.isEmpty) {
      return TextModerationResult(
        scores: {},
        isToxic: false,
        confidence: 1.0,
      );
    }

    // Perspective API 호출
    final results = await PerspectiveApiService.analyzeMultipleTexts(textsToValidate);
    
    // 가장 높은 점수와 카테고리 찾기
    double maxScore = 0.0;
    String? detectedCategory;
    Map<String, double> allScores = {};
    
    results.forEach((fieldName, result) {
      if (result.isToxic) {
        result.allScores.forEach((category, score) {
          if (score > maxScore) {
            maxScore = score;
            detectedCategory = category;
          }
          allScores[category] = score;
        });
      }
    });
    
    return TextModerationResult(
      scores: allScores,
      isToxic: detectedCategory != null,
      detectedCategory: detectedCategory,
      confidence: maxScore,
    );
  }

  /// 텍스트 위반 사항 포맷팅
  static String _formatTextViolation(TextModerationResult result) {
    if (result.detectedCategory == null) return '부적절한 내용';
    
    final categoryName = ModerationConfig.koreanCategoryNames[result.detectedCategory] ?? 
                        result.detectedCategory!;
    return categoryName;
  }

  /// 심각도 결정
  static String _determineSeverity(
    TextModerationResult? textResult,
    GeminiModerationResult? geminiResult,
    List<String> violations,
  ) {
    // 텍스트 유해성이 감지되면 무조건 error
    if (textResult?.isToxic == true) {
      return 'error';
    }
    
    // Gemini 결과에 따른 처리
    if (geminiResult != null) {
      return geminiResult.severity;
    }
    
    // 위반 사항이 있으면 error, 없으면 pass
    return violations.isNotEmpty ? 'error' : 'pass';
  }

  /// 검증 결과 다이얼로그 표시
  static Future<void> showModerationDialog(
    BuildContext context,
    ModerationResult result,
  ) async {
    if (result.severity == 'warning' && result.geminiResult != null) {
      // 경고 다이얼로그
      final proceed = await _showWarningDialog(
        context,
        result.geminiResult!.reason,
        result.geminiResult!.suggestions,
      );
      
      if (!proceed) {
        // 사용자가 수정을 선택한 경우 - 정상적인 흐름이므로 에러를 던지지 않음
        return;
      }
    } else if (!result.isValid) {
      // 차단 다이얼로그
      await _showBlockDialog(
        context,
        result.violations,
        result.geminiResult?.suggestions,
      );
      throw Exception('콘텐츠가 차단되었습니다');
    }
  }

  /// 경고 다이얼로그
  static Future<bool> _showWarningDialog(
    BuildContext context,
    String reason,
    String? suggestions,
  ) async {
    return _showSuggestionDialog(context, reason, suggestions);
  }

  /// 제안 다이얼로그 (VersusDialog로 마이그레이션됨)
  static Future<bool> _showSuggestionDialog(
    BuildContext context,
    String reason,
    String? suggestions,
  ) async {
    final result = await VersusDialog.warning(
      context: context,
      title: '콘텐츠 개선 제안',
      content: reason,
      suggestions: suggestions,
      confirmText: '계속하기',
      cancelText: '수정하기',
      barrierDismissible: false,
    );
    
    return result ?? false;
  }

  /// 차단 다이얼로그 (VersusDialog로 마이그레이션됨)
  static Future<void> _showBlockDialog(
    BuildContext context,
    List<String> violations,
    String? suggestions,
  ) async {
    await VersusDialog.error(
      context: context,
      title: '부적절한 내용 감지',
      content: '다음 항목에서 부적절한 내용이 감지되었습니다:',
      violations: violations,
      suggestions: suggestions,
      confirmText: '확인',
      barrierDismissible: false,
    );
  }
}