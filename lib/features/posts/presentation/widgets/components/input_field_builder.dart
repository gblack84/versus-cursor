import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';
import '/services/perspective_api_service.dart';
import '../components/simple_validated_field.dart';
import '/features/posts/presentation/screens/create_post/in_put_post_image_model.dart';
import '../constants/field_styles.dart';

/// 입력 필드 빌더 헬퍼
class InputFieldBuilder {
  /// 제목 입력 필드 생성
  static Widget buildTitleField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required InPutPostImageModel model,
    required Function() onRequiredFieldsCheck,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: 'bjdyxvvl',
      hintKey: 'a8xnk2go',
      fieldName: FieldStyles.questionTitle,
      maxLength: 100, // 오버라이드 (60→100)
      validationResult: model.validationResults[FieldStyles.questionTitle],
      onFieldChanged: (value, fieldName, isBlocked) {
        // ContentFilter is handled in SimpleValidatedField
      },
      onFieldCleared: () {
        model.validationResults.remove(FieldStyles.questionTitle);
        onRequiredFieldsCheck();
      },
      onRequiredFieldsCheck: onRequiredFieldsCheck,
    );
  }

  /// 설명 입력 필드 생성
  static Widget buildDescriptionField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required InPutPostImageModel model,
    required Function() onRequiredFieldsCheck,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: '6knmjp9w',
      hintKey: 'pxj6gckn',
      fieldName: FieldStyles.description,
      maxLength: 2000, // 오버라이드 (200→2000)
      validationResult: model.validationResults[FieldStyles.description],
      onFieldChanged: (value, fieldName, isBlocked) {
        // ContentFilter is handled in SimpleValidatedField
      },
      onFieldCleared: () {
        model.validationResults.remove(FieldStyles.description);
        onRequiredFieldsCheck();
      },
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
  static Widget? buildErrorMessage({
    required BuildContext context,
    required PerspectiveResult? validationResult,
  }) {
    if (validationResult == null || !validationResult.isToxic) {
      return null;
    }

    // 에러 메시지 생성
    List<String> issues = [];
    if (validationResult.toxicityScore > 0.8) issues.add('독성 콘텐츠');
    if (validationResult.profanityScore > 0.8) issues.add('욕설');
    if (validationResult.threatScore > 0.8) issues.add('위협적 표현');
    if (validationResult.insultScore > 0.8) issues.add('모욕적 표현');
    
    final errorMessage = issues.isEmpty ? '부적절한 콘텐츠' : issues.join(', ');

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
  
  /// 질문 제목 필드 생성 (SimpleValidatedField 사용)
  static Widget buildQuestionTitleField({
    required BuildContext context,
    required TextEditingController controller,
    required FocusNode focusNode,
    required InPutPostImageModel model,
    required Function() onRequiredFieldsCheck,
    required Function(bool) onBlockedWordChanged,
  }) {
    return SimpleValidatedField(
      controller: controller,
      focusNode: focusNode,
      labelKey: '5kzcbgop',
      hintKey: 'jr6l0zdb',
      fieldName: FieldStyles.questionTitle,
      validationResult: model.validationResults[FieldStyles.questionTitle],
      onFieldChanged: (value, fieldName, isBlocked) {
        model.hasBlockedWordInTitle = isBlocked;
        model.isQuestionTitleEmpty = value.trim().isEmpty;
        onBlockedWordChanged(isBlocked);
      },
      onFieldCleared: () {
        model.validationResults.remove(FieldStyles.questionTitle);
        model.hasValidationViolations = false;
        model.hasBlockedWordInTitle = false;
        model.isQuestionTitleEmpty = true;
        onBlockedWordChanged(false);
        onRequiredFieldsCheck();
      },
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