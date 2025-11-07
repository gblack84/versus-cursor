import 'package:flutter/material.dart';
import '/services/moderation/ai_moderation_service.dart';
import '/services/moderation/models/moderation_result.dart'
    as ai;
import '/features/creation/presentation/constants/field_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/core_exports.dart';

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
    AppState? appState,  // AppState를 직접 파라미터로 받음
    Function(String)? onProgressUpdate,
    Map<String, dynamic>? visionDataA,
    Map<String, dynamic>? visionDataB,
    String? sessionId,
    String? documentId,
    int? revisionCount,
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
        aiModerationResult: null,
        violations: [],
      );
    }

    // 현재 사용자 확인
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null || userId.isEmpty) {
      return ValidationResult(
        isValid: false,
        emptyResult: emptyResult,
        aiModerationResult: null,
        violations: [],
        errorMessage: '사용자 인증이 필요합니다.',
      );
    }

    // AppState는 파라미터로 받음 (더 이상 context.read 사용 안 함)

    try {
      // AI Moderation Request 생성
      final moderationRequest = ai.ModerationRequest(
        questionTitle: questionTitle,
        description: description,
        titleA: aTitle,
        titleB: bTitle,
        imageUrlsA: appState?.uploadImageA,
        imageUrlsB: appState?.uploadImageB,
        visionDataA: visionDataA,
        visionDataB: visionDataB,
        userId: userId,
        sessionId: sessionId,
        documentId: documentId,
        revisionCount: revisionCount,
      );

      // AI Moderation 실행
      final moderationResult = await AIModerationService.moderatePostContent(
        request: moderationRequest,
        onProgressUpdate: onProgressUpdate,
      );

      // PROCEED_WITH_SUGGESTION 케이스 처리
      if (moderationResult.geminiResult?.severity == 'warning' &&
          context != null) {
        // 개선 제안이 있는 경우
        final proceed = await showImprovementDialog(
          context,
          moderationResult.geminiResult!.reason,
          moderationResult.geminiResult!.suggestions,
        );

        if (!proceed) {
          print('[ValidationService] 사용자가 수정하기를 선택함');
          return ValidationResult(
            isValid: true, // true로 변경하여 InPutPostImageWidget의 432줄 조건을 통과하도록 함
            emptyResult: emptyResult,
            aiModerationResult: moderationResult,
            violations: [],
            errorMessage: null, // 에러 메시지 제거 - 정상적인 사용자 선택
            userRequestedModification: true, // 사용자가 수정하기를 선택함
          );
        }
      }

      return ValidationResult(
        isValid: moderationResult.isValid,
        emptyResult: emptyResult,
        aiModerationResult: moderationResult,
        violations: moderationResult.violations,
        errorMessage: moderationResult.errorMessage,
      );
    } catch (e) {
      return ValidationResult(
        isValid: false,
        emptyResult: emptyResult,
        aiModerationResult: null,
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

  /// 위반 사항 다이얼로그 표시
  static Future<void> showViolationDialog(
    BuildContext context,
    List<String> violations, {
    ai.GeminiModerationResult? geminiResult,
  }) async {
    // AIModerationService의 다이얼로그 사용
    if (geminiResult != null) {
      final moderationResult = ai.ModerationResult(
        isValid: false,
        severity: geminiResult.severity,
        violations: violations,
        geminiResult: geminiResult,
      );

      await AIModerationService.showModerationDialog(context, moderationResult);
    } else {
      // 기본 다이얼로그 표시
      await showDialog(
        context: context,
        barrierDismissible: false,
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
                      child: Text('• $violation',
                          style: const TextStyle(color: Colors.red)),
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

  /// 개선 제안 다이얼로그 표시
  static Future<bool> showImprovementDialog(
    BuildContext context,
    String title,
    String? description,
  ) async {
    print('[ValidationService] showImprovementDialog 호출됨');
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (description != null && description.isNotEmpty) ...[
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
                      const Text('✓ 제안:',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(description),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text('이대로 게시하시겠습니까?'),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      print('[ValidationService] 수정하기 버튼 클릭됨');
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('수정하기'),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      print('[ValidationService] 계속하기 버튼 클릭됨');
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('계속하기'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );

    print('[ValidationService] 다이얼로그 결과: $result');
    return result ?? false;
  }

  /// Gemini 경고 다이얼로그 표시 (기존 호환성 유지)
  static Future<bool> showWarningDialog(
    BuildContext context,
    String reason,
    String? suggestions,
  ) async {
    return showImprovementDialog(context, reason, suggestions);
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

  bool get hasEmptyField =>
      isQuestionTitleEmpty || isATitleEmpty || isBTitleEmpty;
}

/// 전체 검증 결과
class ValidationResult {
  final bool isValid;
  final ValidationEmptyResult emptyResult;
  final ai.ModerationResult? aiModerationResult;
  final List<String> violations;
  final String? errorMessage;
  final bool userRequestedModification; // 사용자가 수정하기를 선택했는지 여부

  ValidationResult({
    required this.isValid,
    required this.emptyResult,
    required this.aiModerationResult,
    required this.violations,
    this.errorMessage,
    this.userRequestedModification = false,
  });

  // 이전 버전 호환성을 위한 getter
  ai.GeminiModerationResult? get geminiResult =>
      aiModerationResult?.geminiResult;

  // 기존 코드 호환성을 위한 getter
  Map<String, dynamic> get validationResults => {};
}
