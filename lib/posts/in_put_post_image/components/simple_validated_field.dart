import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import '/core/app_theme.dart';
import '/core/app_localizations.dart';
import '/services/perspective_api_service.dart';
import '/widgets/highlighted_text_field.dart';
import '/utils/content_filter.dart';

class SimpleValidatedField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String labelKey;
  final String hintKey;
  final String fieldName;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool isDense;
  final double fontSize;
  final double borderWidth;
  final TextInputAction textInputAction;
  final Function(String, String, bool)? onFieldChanged; // value, fieldName, isBlocked
  final Function()? onFieldCleared;
  final Function()? onRequiredFieldsCheck;
  final PerspectiveResult? validationResult;
  final bool showClearButton;

  const SimpleValidatedField({
    Key? key,
    this.controller,
    this.focusNode,
    required this.labelKey,
    required this.hintKey,
    required this.fieldName,
    this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.isDense = true,
    this.fontSize = 14.0,
    this.borderWidth = 2.0,
    this.textInputAction = TextInputAction.done,
    this.onFieldChanged,
    this.onFieldCleared,
    this.onRequiredFieldsCheck,
    this.validationResult,
    this.showClearButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (value) {
        // 필수 필드 체크
        if (onRequiredFieldsCheck != null) {
          onRequiredFieldsCheck!();
        }
        
        // 디바운스된 필터링
        EasyDebounce.debounce(
          'simple_validated_field_$fieldName',
          Duration(milliseconds: 500),
          () {
            final result = ContentFilter.filterText(value);
            if (onFieldChanged != null) {
              onFieldChanged!(value, fieldName, result.isBlocked);
            }
          },
        );
      },
      validationResult: validationResult,
      showValidationResults: false,
      minLines: minLines,
      maxLines: maxLines,
      textInputAction: textInputAction,
      maxLength: maxLength,
      decoration: InputDecoration(
        isDense: isDense,
        labelText: AppLocalizations.of(context).getText(labelKey),
        labelStyle: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.plusJakartaSans(
                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
              fontSize: fontSize,
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
              fontSize: fontSize * 0.9,
              letterSpacing: 0.0,
              fontWeight: AppTheme.of(context).labelMedium.fontWeight,
              fontStyle: AppTheme.of(context).labelMedium.fontStyle,
            ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: borderWidth,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        filled: true,
        fillColor: AppTheme.of(context).secondaryBackground,
        suffixIcon: showClearButton && (controller?.text.isNotEmpty ?? false)
            ? InkWell(
                onTap: () {
                  controller?.clear();
                  if (onFieldCleared != null) {
                    onFieldCleared!();
                  }
                },
                child: Icon(
                  Icons.clear,
                  color: AppTheme.of(context).primaryText,
                  size: 22,
                ),
              )
            : null,
      ),
      style: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
          ),
    );
  }
}