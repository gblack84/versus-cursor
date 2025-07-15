import 'package:flutter/material.dart';
import '/services/perspective_api_service.dart';
import '../constants/field_styles.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/core/app_state.dart';
import 'package:provider/provider.dart';

class ValidationService {
  /// 필수 필드가 비어있는지 확인
  static ValidationEmptyResult checkEmptyFields({
    required String? questionTitle,
    required String? aTitle,
    required String? bTitle,
  }) {
    return ValidationEmptyResult(
      isQuestionTitleEmpty: questionTitle?.trim().isEmpty ?? true,
      isATitleEmpty: aTitle?.trim().isEmpty ?? true,
      isBTitleEmpty: bTitle?.trim().isEmpty ?? true,
    );
  }

  /// 모든 텍스트 필드 검증
  static Future<ValidationResult> validateAllTexts({
    required String? questionTitle,
    required String? description,
    required String? aTitle,
    required String? bTitle,
    BuildContext? context,
    Function(String)? onProgressUpdate,
  }) async {
    // 빈 필드 체크
    final emptyResult = checkEmptyFields(
      questionTitle: questionTitle,
      aTitle: aTitle,
      bTitle: bTitle,
    );

    if (emptyResult.hasEmptyField) {
      return ValidationResult(
        isValid: false,
        emptyResult: emptyResult,
        validationResults: {},
        violations: [],
      );
    }

    // 텍스트 수집
    final textsToValidate = <String, String>{};
    
    if (questionTitle?.isNotEmpty == true) {
      textsToValidate[FieldStyles.questionTitle] = questionTitle!;
    }
    if (description?.isNotEmpty == true) {
      textsToValidate[FieldStyles.description] = description!;
    }
    if (aTitle?.isNotEmpty == true) {
      textsToValidate[FieldStyles.textA] = aTitle!;
    }
    if (bTitle?.isNotEmpty == true) {
      textsToValidate[FieldStyles.textB] = bTitle!;
    }

    if (textsToValidate.isEmpty) {
      return ValidationResult(
        isValid: false,
        emptyResult: emptyResult,
        validationResults: {},
        violations: [],
        errorMessage: '입력된 텍스트가 없습니다.',
      );
    }

    try {
      // Perspective API로 검증
      final results = await PerspectiveApiService.analyzeMultipleTexts(textsToValidate);
      
      // 검증 결과 처리
      bool hasViolations = false;
      List<String> violations = [];

      results.forEach((fieldName, result) {
        if (result.isToxic) {
          hasViolations = true;
          String fieldDisplayName = getFieldDisplayName(fieldName);
          String categoryName = getTopCategoryName(result);
          violations.add('$fieldDisplayName: $categoryName');
        }
      });

      // Perspective API 검증 통과 시 Gemini AI 검증 수행
      if (!hasViolations && context != null) {
        // 진행 상태 업데이트
        onProgressUpdate?.call("AI가 내용을 분석하고 있습니다...");
        
        final geminiResult = await validateWithGemini(
          context: context,
          questionTitle: questionTitle,
          description: description,
          aTitle: aTitle,
          bTitle: bTitle,
          perspectiveResults: results,
        );
        
        if (geminiResult != null) {
          // Gemini 검증 결과 처리
          if (!geminiResult.isValid) {
            hasViolations = true;
            violations.add(geminiResult.reason);
          } else if (geminiResult.severity == 'warning') {
            // 경고의 경우 별도 처리를 위해 결과에 포함만 시킴
            // hasViolations를 true로 설정하지 않음
          }
          
          return ValidationResult(
            isValid: !hasViolations,
            emptyResult: emptyResult,
            validationResults: results,
            violations: violations,
            geminiResult: geminiResult,
          );
        }
      }

      return ValidationResult(
        isValid: !hasViolations,
        emptyResult: emptyResult,
        validationResults: results,
        violations: violations,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        emptyResult: emptyResult,
        validationResults: {},
        violations: [],
        errorMessage: '텍스트 검증 중 오류가 발생했습니다.',
      );
    }
  }

  /// 필드명을 사용자 친화적 이름으로 변환
  static String getFieldDisplayName(String fieldName) {
    switch (fieldName) {
      case FieldStyles.questionTitle:
        return 'Question Title';
      case FieldStyles.description:
        return 'Description';
      case FieldStyles.textA:
        return 'A title';
      case FieldStyles.textB:
        return 'B title';
      default:
        return fieldName;
    }
  }

  /// 가장 높은 점수의 카테고리명 반환
  static String getTopCategoryName(PerspectiveResult result) {
    String topCategory = '';
    double maxScore = 0.0;
    
    result.allScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });
    
    switch (topCategory) {
      case 'PROFANITY':
        return '욕설 감지';
      case 'THREAT':
        return '위협적 표현';
      case 'INSULT':
        return '모욕적 표현';
      case 'TOXICITY':
        return '독성 콘텐츠';
      default:
        return '부적절한 내용';
    }
  }

  /// Gemini AI로 통합 검증
  static Future<GeminiValidationResult?> validateWithGemini({
    required BuildContext context,
    required String? questionTitle,
    required String? description,
    required String? aTitle,
    required String? bTitle,
    required Map<String, PerspectiveResult> perspectiveResults,
  }) async {
    try {
      final appState = context.read<AppState>();
      final currentUser = currentUserReference;
      
      if (currentUser == null) return null;
      
      // Perspective 점수 변환
      Map<String, double> perspectiveScores = {};
      perspectiveResults.forEach((key, result) {
        if (result.allScores.isNotEmpty) {
          perspectiveScores = result.allScores;
        }
      });
      
      // Cloud Function 호출
      final functions = FirebaseFunctions.instanceFor(region: 'asia-northeast3');
      final callable = functions.httpsCallable('validatePostContentWithGemini');
      
      final response = await callable.call({
        'question': questionTitle ?? '',
        'titleA': aTitle ?? '',
        'titleB': bTitle ?? '',
        'descriptionText': description ?? '',
        'imageUrlA': appState.uploadImageUrlsA.isNotEmpty ? appState.uploadImageUrlsA.first : null,
        'imageUrlB': appState.uploadImageUrlsB.isNotEmpty ? appState.uploadImageUrlsB.first : null,
        'perspectiveData': perspectiveScores,
        'userId': currentUser.id,
      });
      
      final data = response.data as Map<String, dynamic>;
      
      return GeminiValidationResult(
        isValid: data['isValid'] ?? true,
        reason: data['reason'] ?? '',
        severity: data['severity'] ?? 'pass',
        suggestions: data['suggestions'] ?? '',
        confidence: (data['confidence'] ?? 0.5).toDouble(),
      );
      
    } catch (e) {
      print('Gemini validation error: $e');
      // Gemini 검증 실패시 null 반환 (Perspective API 결과만 사용)
      return null;
    }
  }

  /// 위반 사항 다이얼로그 표시
  static void showViolationDialog(BuildContext context, List<String> violations, {GeminiValidationResult? geminiResult}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
              if (geminiResult?.suggestions != null && geminiResult!.suggestions.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 제안:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(geminiResult.suggestions),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),
              const Text('내용을 수정한 후 다시 시도해주세요.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
  
  /// Gemini 경고 다이얼로그 표시
  static Future<bool> showWarningDialog(
    BuildContext context, 
    String reason, 
    String? suggestions,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡 제안:', style: TextStyle(fontWeight: FontWeight.bold)),
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
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('수정하기'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('계속하기'),
            ),
          ],
        );
      },
    );
    
    return result ?? false;
  }
}

/// 빈 필드 검증 결과
class ValidationEmptyResult {
  final bool isQuestionTitleEmpty;
  final bool isATitleEmpty;
  final bool isBTitleEmpty;

  ValidationEmptyResult({
    required this.isQuestionTitleEmpty,
    required this.isATitleEmpty,
    required this.isBTitleEmpty,
  });

  bool get hasEmptyField => isQuestionTitleEmpty || isATitleEmpty || isBTitleEmpty;
}

/// 전체 검증 결과
class ValidationResult {
  final bool isValid;
  final ValidationEmptyResult emptyResult;
  final Map<String, PerspectiveResult> validationResults;
  final List<String> violations;
  final String? errorMessage;
  final GeminiValidationResult? geminiResult;

  ValidationResult({
    required this.isValid,
    required this.emptyResult,
    required this.validationResults,
    required this.violations,
    this.errorMessage,
    this.geminiResult,
  });
}

/// Gemini AI 검증 결과
class GeminiValidationResult {
  final bool isValid;
  final String reason;
  final String severity;
  final String suggestions;
  final double confidence;

  GeminiValidationResult({
    required this.isValid,
    required this.reason,
    required this.severity,
    required this.suggestions,
    required this.confidence,
  });
}