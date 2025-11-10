import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';
import '/services/moderation/perspective_api_service.dart';
import '/services/moderation/constants/moderation_config.dart'; // ✅ Phase 3: Added
import '../components/simple_validated_field.dart';
import '/features/creation/presentation/constants/field_styles.dart';
import '/features/creation/domain/failures/creation_failure.dart';
import '/features/creation/domain/failures/creation_failure_extensions.dart'; // Extension for getUserMessage()

/// 입력 필드 빌더 헬퍼
///
/// Clean Architecture 준수:
/// - InPutPostImageModel 의존성 제거 (Phase 4에서 삭제됨)
/// - 콜백 패턴으로 Provider와 통합
/// - validationResult를 외부에서 주입받음
class InputFieldBuilder {
  /// 제목 입력 필드 생성
  ///
  /// SimpleValidatedField를 사용하여 고급 기능 제공:
  /// - 다국어 지원 (labelKey, hintKey)
  /// - AI 기반 검열 (Perspective API + Gemini)
  /// - maxLength 100 (vs TextFormField 기본 60)
  static Widget buildTitleField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String value, String fieldName, bool isBlocked) onFieldChanged,
    required Function() onFieldCleared,
    required Function() onRequiredFieldsCheck,
    PerspectiveResult? validationResult,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: 'bjdyxvvl',
      hintKey: 'a8xnk2go',
      fieldName: FieldStyles.questionTitle,
      maxLength: 100, // 오버라이드 (60→100)
      validationResult: validationResult,
      onFieldChanged: onFieldChanged,
      onFieldCleared: onFieldCleared,
      onRequiredFieldsCheck: onRequiredFieldsCheck,
    );
  }

  /// 설명 입력 필드 생성
  ///
  /// SimpleValidatedField를 사용하여 고급 기능 제공:
  /// - 다국어 지원
  /// - AI 기반 검열 (Perspective API + Gemini)
  /// - maxLength 2000 (vs TextFormField 기본 400)
  static Widget buildDescriptionField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String value, String fieldName, bool isBlocked) onFieldChanged,
    required Function() onFieldCleared,
    required Function() onRequiredFieldsCheck,
    PerspectiveResult? validationResult,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: '6knmjp9w',
      hintKey: 'pxj6gckn',
      fieldName: FieldStyles.description,
      maxLength: 2000, // 오버라이드 (200→2000)
      validationResult: validationResult,
      onFieldChanged: onFieldChanged,
      onFieldCleared: onFieldCleared,
      onRequiredFieldsCheck: onRequiredFieldsCheck,
    );
  }

  /// 패딩이 적용된 입력 필드 컨테이너
  static Widget buildFieldContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? width,
  }) {
    return Padding(
      padding: padding ?? EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0),
      child: width != null
          ? Container(
              width: width,
              child: child,
            )
          : child,
    );
  }

  /// 에러 메시지 표시
  /// Step 9: AIModerationFailure로 중앙화된 메시지 사용
  static Widget? buildErrorMessage({
    required BuildContext context,
    required PerspectiveResult? validationResult,
  }) {
    if (validationResult == null || !validationResult.isToxic) {
      return null;
    }

    // Step 9: Perspective API 점수를 AIModerationFailure 카테고리로 매핑
    // ✅ Phase 3: 하드코딩 제거 (0.8 → ModerationConfig.severeThreshold)
    List<String> detectedCategories = [];
    if (validationResult.toxicityScore > ModerationConfig.severeThreshold) detectedCategories.add('toxicity');
    if (validationResult.profanityScore > ModerationConfig.severeThreshold) detectedCategories.add('profanity');
    if (validationResult.threatScore > ModerationConfig.severeThreshold) detectedCategories.add('harassment');
    if (validationResult.insultScore > ModerationConfig.severeThreshold) detectedCategories.add('hate');

    // Step 9: detectedCategories가 비어있으면 generic 카테고리 사용
    if (detectedCategories.isEmpty) {
      detectedCategories.add('toxicity'); // 기본값
    }

    // Step 9: 최대 점수 계산
    final maxScore = [
      validationResult.toxicityScore,
      validationResult.profanityScore,
      validationResult.threatScore,
      validationResult.insultScore,
    ].reduce((a, b) => a > b ? a : b);

    // Step 9: AIModerationFailed 생성 및 getUserMessage() 사용
    final failure = CreationFailure.aiModerationFailed(
      aiProvider: 'perspective',
      detectedCategories: detectedCategories,
      confidenceScore: maxScore,
    );

    final errorMessage = failure.getUserMessage();

    return Padding(
      padding: const EdgeInsets.only(top: 4.0, left: 12.0, right: 12.0),
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Colors.red,
          fontSize: 12.0,
        ),
      ),
    );
  }

  /// 질문 제목 필드 생성 (추가 플래그 관리)
  ///
  /// buildTitleField와 유사하지만 추가 상태 관리:
  /// - hasBlockedWordInTitle 플래그
  /// - isQuestionTitleEmpty 플래그
  /// - hasValidationViolations 플래그
  ///
  /// 사용 시 주의: 이 메서드는 특정 UI 플로우에서만 사용
  /// 일반적인 경우 buildTitleField() 사용 권장
  static Widget buildQuestionTitleField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required Function(String value, String fieldName, bool isBlocked) onFieldChanged,
    required Function() onFieldCleared,
    required Function() onRequiredFieldsCheck,
    PerspectiveResult? validationResult,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: '5kzcbgop',
      hintKey: 'jr6l0zdb',
      fieldName: FieldStyles.questionTitle,
      validationResult: validationResult,
      onFieldChanged: onFieldChanged,
      onFieldCleared: onFieldCleared,
      onRequiredFieldsCheck: onRequiredFieldsCheck,
    );
  }

  /// 공통 InputDecoration 생성
  static InputDecoration getInputDecoration({
    required BuildContext context,
    required String hintKey,
    required String labelKey,
    double fontSize = 14.0,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      contentPadding: const EdgeInsets.only(bottom: 8.0),
      labelText: AppLocalizations.of(context).getText(labelKey),
      labelStyle: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            fontSize: fontSize,
            letterSpacing: 0.0,
          ),
      alignLabelWithHint: false,
      hintText: AppLocalizations.of(context).getText(hintKey),
      hintStyle: AppTheme.of(context).labelMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).labelMedium.fontWeight,
              fontStyle: AppTheme.of(context).labelMedium.fontStyle,
            ),
            fontSize: fontSize * 0.9,
            letterSpacing: 0.0,
          ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: AppTheme.of(context).secondaryBackground,
      suffixIcon: suffixIcon,
    );
  }

  /// 공통 TextStyle 생성
  static TextStyle getTextStyle({
    required BuildContext context,
    double fontSize = 14.0,
  }) {
    return AppTheme.of(context).bodyMedium.override(
          font: GoogleFonts.plusJakartaSans(
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
          fontSize: fontSize,
          letterSpacing: 0.0,
        );
  }
}
