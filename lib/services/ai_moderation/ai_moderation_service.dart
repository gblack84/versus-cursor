import 'package:flutter/material.dart';
import '/services/perspective_api_service.dart';
import 'models/moderation_result.dart';
import 'constants/moderation_config.dart';
import 'text_moderation/gemini_service.dart';
import '/core/app_theme.dart';

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
        throw Exception('사용자가 수정을 선택했습니다');
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
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('콘텐츠 개선 제안'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(reason),
              if (suggestions != null && suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ 제안:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(suggestions),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('계속 진행하시겠습니까?'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('수정하기'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('계속하기'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }

  /// 차단 다이얼로그
  static Future<void> _showBlockDialog(
    BuildContext context,
    List<String> violations,
    String? suggestions,
  ) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('부적절한 내용 감지'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('다음 항목에서 부적절한 내용이 감지되었습니다:'),
              const SizedBox(height: 10),
              ...violations.map((violation) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text('• $violation', style: const TextStyle(color: Colors.red)),
              )),
              if (suggestions != null && suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('✓ 제안:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(suggestions),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Text('내용을 수정한 후 다시 시도해주세요.'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black, width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('확인'),
              ),
            ),
          ],
        );
      },
    );
  }
}