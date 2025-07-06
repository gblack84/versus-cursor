import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:easy_debounce/easy_debounce.dart';
import '/core/app_theme.dart';
import '/core/app_localizations.dart';
import '/services/perspective_api_service.dart';
import '/widgets/highlighted_text_field.dart';

class ValidatedInputField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String labelKey;
  final String hintKey;
  final int maxLength;
  final int maxLines;
  final int minLines;
  final bool isDense;
  final double fontSize;
  final Function(String)? onChanged;
  final PerspectiveResult? validationResult;
  final bool showValidationResults;
  final String? debounceKey;
  final Function()? onDebounce;
  final bool showClearButton;
  final VoidCallback? onClear;
  final TextInputAction textInputAction;

  const ValidatedInputField({
    Key? key,
    this.controller,
    this.focusNode,
    required this.labelKey,
    required this.hintKey,
    required this.maxLength,
    this.maxLines = 1,
    this.minLines = 1,
    this.isDense = true,
    this.fontSize = 14.0,
    this.onChanged,
    this.validationResult,
    this.showValidationResults = false,
    this.debounceKey,
    this.onDebounce,
    this.showClearButton = true,
    this.onClear,
    this.textInputAction = TextInputAction.done,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValidatedTextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: (value) {
        if (onChanged != null) {
          onChanged!(value);
        }
        
        // Debounce 처리
        if (debounceKey != null && onDebounce != null) {
          EasyDebounce.debounce(
            debounceKey!,
            Duration(milliseconds: 500),
            onDebounce!,
          );
        }
      },
      validationResult: validationResult,
      showValidationResults: showValidationResults,
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
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black,
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(isDense ? 12.0 : 8.0),
        ),
        filled: true,
        fillColor: AppTheme.of(context).secondaryBackground,
        suffixIcon: showClearButton && (controller?.text.isNotEmpty ?? false)
            ? InkWell(
                onTap: () {
                  controller?.clear();
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