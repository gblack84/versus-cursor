import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import '/core_exports.dart';
import '/services/perspective_api_service.dart';
import '/features/common/presentation/widgets/highlighted_text_field.dart';
import '/features/common/data/services/content_filter.dart';
import '../constants/field_styles.dart';

/// 통합된 입력 필드 위젯
/// ValidatedInputField와 SimpleValidatedField를 하나로 통합
class SimpleValidatedField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String labelKey;
  final String hintKey;
  final String? fieldName; // optional for backward compatibility
  final int? maxLength; // 오버라이드용
  final int? maxLines; // 오버라이드용
  final int? minLines; // 오버라이드용
  final double? fontSize; // 오버라이드용
  final TextInputAction? textInputAction; // 오버라이드용
  final Function(String, String, bool)? onFieldChanged; // value, fieldName, isBlocked
  final Function()? onFieldCleared;
  final Function()? onRequiredFieldsCheck;
  final PerspectiveResult? validationResult;
  final bool showClearButton;
  final bool showValidationResults;
  final String? debounceKey;
  final Duration debounceDuration;
  final Function(String)? onChanged; // simple onChanged callback
  final VoidCallback? onClear; // simple clear callback

  const SimpleValidatedField({
    Key? key,
    this.controller,
    this.focusNode,
    required this.labelKey,
    required this.hintKey,
    this.fieldName,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.fontSize,
    this.textInputAction,
    this.onFieldChanged,
    this.onFieldCleared,
    this.onRequiredFieldsCheck,
    this.validationResult,
    this.showClearButton = true,
    this.showValidationResults = false,
    this.debounceKey,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.onChanged,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // fieldName 기반으로 설정 가져오기
    final config = FieldStyles.getConfig(fieldName ?? '');
    
    // 오버라이드 값이 있으면 사용, 없으면 config 값 사용
    final effectiveMaxLength = maxLength ?? config.maxLength;
    final effectiveMaxLines = maxLines ?? config.maxLines;
    final effectiveMinLines = minLines ?? config.minLines;
    final effectiveFontSize = fontSize ?? config.textSize;
    final effectiveTextInputAction = textInputAction ?? config.textInputAction;
    
    return Padding(
      padding: config.fieldPadding,
      child: ValidatedTextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (value) {
        // Simple onChanged callback
        if (onChanged != null) {
          onChanged!(value);
        }
        
        // 필수 필드 체크
        if (onRequiredFieldsCheck != null) {
          onRequiredFieldsCheck!();
        }
        
        // 디바운스된 필터링 (fieldName이 있는 경우에만)
        if (fieldName != null && onFieldChanged != null) {
          EasyDebounce.debounce(
            debounceKey ?? 'simple_validated_field_$fieldName',
            debounceDuration,
            () {
              final result = ContentFilter.filterText(value);
              onFieldChanged!(value, fieldName!, result.isBlocked);
            },
          );
        } else if (debounceKey != null && onFieldChanged != null) {
          // debounceKey만 있는 경우 (ValidatedInputField 호환)
          EasyDebounce.debounce(
            debounceKey!,
            debounceDuration,
            () {
              final result = ContentFilter.filterText(value);
              onFieldChanged!(value, '', result.isBlocked);
            },
          );
        }
      },
      validationResult: validationResult,
      showValidationResults: showValidationResults,
      minLines: effectiveMinLines,
      maxLines: effectiveMaxLines,
      textInputAction: effectiveTextInputAction,
      maxLength: effectiveMaxLength,
      decoration: _buildDecoration(context, config),
      style: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            fontSize: effectiveFontSize,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
      ),
    );
  }
  
  /// InputDecoration 빌드
  InputDecoration _buildDecoration(BuildContext context, FieldConfig config) {
    return InputDecoration(
      isDense: config.isDense,
      contentPadding: config.contentPadding,
      labelText: AppLocalizations.of(context).getText(labelKey),
      labelStyle: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            fontSize: config.labelSize,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
      alignLabelWithHint: false,
      hintText: AppLocalizations.of(context).getText(hintKey),
      hintStyle: AppTheme.of(context).labelMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).labelMedium.fontWeight,
              fontStyle: AppTheme.of(context).labelMedium.fontStyle,
            ),
            fontSize: config.textSize * 0.9,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).labelMedium.fontWeight,
            fontStyle: AppTheme.of(context).labelMedium.fontStyle,
          ),
      enabledBorder: _getBorder(config, FieldStyles.borderColor),
      focusedBorder: _getBorder(config, FieldStyles.focusedBorderColor),
      errorBorder: _getBorder(config, FieldStyles.errorBorderColor),
      focusedErrorBorder: _getBorder(config, FieldStyles.errorBorderColor),
      filled: true,
      fillColor: AppTheme.of(context).secondaryBackground,
      suffixIcon: config.showClearButton && showClearButton && (controller?.text.isNotEmpty ?? false)
          ? InkWell(
              onTap: () {
                controller?.clear();
                // 두 가지 clear 콜백 모두 지원
                if (onFieldCleared != null) {
                  onFieldCleared!();
                }
                if (onClear != null) {
                  onClear!();
                }
              },
              child: Icon(
                Icons.clear,
                color: AppTheme.of(context).primaryText,
                size: 22,
              ),
            )
          : null,
    );
  }
  
  /// 보더 스타일 생성
  InputBorder _getBorder(FieldConfig config, Color color) {
    switch (config.borderType) {
      case FieldBorderType.underline:
        return UnderlineInputBorder(
          borderSide: BorderSide(
            color: color,
            width: config.borderWidth,
          ),
          borderRadius: BorderRadius.circular(
            config.isDense ? FieldStyles.borderRadiusDense : FieldStyles.borderRadius
          ),
        );
      case FieldBorderType.outline:
        return OutlineInputBorder(
          borderSide: BorderSide(
            color: color,
            width: config.borderWidth,
          ),
          borderRadius: BorderRadius.circular(FieldStyles.borderRadius),
        );
      case FieldBorderType.none:
        return InputBorder.none;
    }
  }
}