import 'package:flutter/material.dart';
import '/services/perspective_api_service.dart';
import '../constants/field_styles.dart';

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

  /// 위반 사항 다이얼로그 표시
  static void showViolationDialog(BuildContext context, List<String> violations) {
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

  ValidationResult({
    required this.isValid,
    required this.emptyResult,
    required this.validationResults,
    required this.violations,
    this.errorMessage,
  });
}