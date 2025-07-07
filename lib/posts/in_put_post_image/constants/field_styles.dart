import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/app_theme.dart';

class FieldStyles {
  /// 큰 텍스트 필드용 스타일 (Question Title 등)
  static TextStyle getLargeLabelStyle(BuildContext context) {
    return AppTheme.of(context).bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
      ),
      fontSize: 30.0,
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
    );
  }

  /// 큰 힌트 텍스트용 스타일
  static TextStyle getLargeHintStyle(BuildContext context) {
    return AppTheme.of(context).labelMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
      ),
      fontSize: 30.0,
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).labelMedium.fontWeight,
      fontStyle: AppTheme.of(context).labelMedium.fontStyle,
    );
  }

  /// 일반 라벨 스타일
  static TextStyle getNormalLabelStyle(BuildContext context) {
    return AppTheme.of(context).titleSmall.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).titleSmall.fontWeight,
        fontStyle: AppTheme.of(context).titleSmall.fontStyle,
      ),
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).titleSmall.fontWeight,
      fontStyle: AppTheme.of(context).titleSmall.fontStyle,
    );
  }

  /// 일반 힌트 스타일
  static TextStyle getNormalHintStyle(BuildContext context) {
    return AppTheme.of(context).labelMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
      ),
      fontSize: 14.0,
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).labelMedium.fontWeight,
      fontStyle: AppTheme.of(context).labelMedium.fontStyle,
    );
  }

  /// 일반 텍스트 스타일
  static TextStyle getTextStyle(BuildContext context) {
    return AppTheme.of(context).bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
      ),
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
    );
  }

  /// 큰 텍스트 스타일
  static TextStyle getLargeTextStyle(BuildContext context) {
    return AppTheme.of(context).bodyMedium.override(
      font: GoogleFonts.plusJakartaSans(
        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
      ),
      fontSize: 30.0,
      letterSpacing: 0.0,
      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
    );
  }

  /// 공통 border 생성 함수
  static InputBorder getBorder({
    Color color = Colors.black,
    double width = 2.0,
    double radius = 12.0,
  }) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: color,
        width: width,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// 에러 border 생성 함수
  static InputBorder getErrorBorder(BuildContext context, {
    double width = 2.0,
    double radius = 8.0,
  }) {
    return UnderlineInputBorder(
      borderSide: BorderSide(
        color: AppTheme.of(context).error,
        width: width,
      ),
      borderRadius: BorderRadius.circular(radius),
    );
  }
}