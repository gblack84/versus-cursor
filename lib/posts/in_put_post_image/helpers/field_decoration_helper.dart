import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/app_theme.dart';
import '/core/app_localizations.dart';

class FieldDecorationHelper {
  /// 큰 텍스트 필드용 InputDecoration 생성
  static InputDecoration getLargeFieldDecoration(
    BuildContext context, {
    required String labelKey,
    required String hintKey,
    bool isDense = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      isDense: isDense,
      labelText: AppLocalizations.of(context).getText(labelKey),
      labelStyle: AppTheme.of(context).bodyMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
            ),
            fontSize: 30.0,
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
            fontSize: 30.0,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).labelMedium.fontWeight,
            fontStyle: AppTheme.of(context).labelMedium.fontStyle,
          ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: 3.0,
        ),
        borderRadius: BorderRadius.circular(12.0),
      ),
      filled: true,
      fillColor: AppTheme.of(context).secondaryBackground,
      suffixIcon: suffixIcon,
    );
  }

  /// 일반 텍스트 필드용 InputDecoration 생성
  static InputDecoration getNormalFieldDecoration(
    BuildContext context, {
    required String labelKey,
    required String hintKey,
    bool isDense = true,
    Widget? suffixIcon,
    double borderWidth = 2.0,
  }) {
    return InputDecoration(
      isDense: isDense,
      labelText: AppLocalizations.of(context).getText(labelKey),
      labelStyle: AppTheme.of(context).titleSmall.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).titleSmall.fontWeight,
              fontStyle: AppTheme.of(context).titleSmall.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).titleSmall.fontWeight,
            fontStyle: AppTheme.of(context).titleSmall.fontStyle,
          ),
      alignLabelWithHint: false,
      hintText: AppLocalizations.of(context).getText(hintKey),
      hintStyle: AppTheme.of(context).labelMedium.override(
            font: GoogleFonts.plusJakartaSans(
              fontWeight: AppTheme.of(context).labelMedium.fontWeight,
              fontStyle: AppTheme.of(context).labelMedium.fontStyle,
            ),
            fontSize: 14.0,
            letterSpacing: 0.0,
            fontWeight: AppTheme.of(context).labelMedium.fontWeight,
            fontStyle: AppTheme.of(context).labelMedium.fontStyle,
          ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: Colors.black,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).error,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(
          color: AppTheme.of(context).error,
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      filled: true,
      fillColor: AppTheme.of(context).secondaryBackground,
      suffixIcon: suffixIcon,
    );
  }

  /// Clear 버튼 생성
  static Widget buildClearButton(
    BuildContext context, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        Icons.clear,
        color: AppTheme.of(context).primaryText,
        size: 22,
      ),
    );
  }
}