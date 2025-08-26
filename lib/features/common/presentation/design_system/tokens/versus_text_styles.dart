import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'versus_colors.dart';

/// Versus Space Typography 시스템
/// 
/// 기존 GoogleFonts.plusJakartaSans 패턴을 표준화했습니다.
/// AppTheme의 Typography 클래스와 호환되면서 더 간단한 사용법을 제공합니다.
class VersusTextStyles {
  // 폰트 패밀리 상수
  static const String fontFamily = 'Plus Jakarta Sans';
  
  // 제목 스타일들 (headings)
  static TextStyle get headingLarge => GoogleFonts.plusJakartaSans(
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get headingMedium => GoogleFonts.plusJakartaSans(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get headingSmall => GoogleFonts.plusJakartaSans(
    fontSize: 20.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  // 본문 스타일들 (body text)
  static TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get bodySmall => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textPrimary,
  );
  
  // 라벨 스타일들 (labels, captions)
  static TextStyle get labelLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textSecondary,
  );
  
  static TextStyle get labelMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textSecondary,
  );
  
  static TextStyle get labelSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textSecondary,
  );
  
  // 버튼 스타일들
  static TextStyle get buttonLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get buttonMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get buttonSmall => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  // 특별한 용도 스타일들
  static TextStyle get dialogTitle => GoogleFonts.plusJakartaSans(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get dialogContent => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get inputField => GoogleFonts.plusJakartaSans(
    fontSize: 14.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textPrimary,
  );
  
  static TextStyle get inputLabel => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.textSecondary,
  );
  
  // 에러/성공 메시지용
  static TextStyle get error => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.error,
  );
  
  static TextStyle get success => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.success,
  );
  
  static TextStyle get warning => GoogleFonts.plusJakartaSans(
    fontSize: 12.0,
    fontWeight: FontWeight.normal,
    color: VersusColors.warning,
  );
  
  // 커스텀 스타일 생성기 (기존 .override() 패턴 대체)
  static TextStyle custom({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
  }) => GoogleFonts.plusJakartaSans(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
  );
  
  // 색상만 변경하는 헬퍼 메서드들
  static TextStyle withColor(TextStyle baseStyle, Color color) => 
    baseStyle.copyWith(color: color);
    
  static TextStyle withPrimaryColor(TextStyle baseStyle) => 
    withColor(baseStyle, VersusColors.primary);
    
  static TextStyle withSecondaryColor(TextStyle baseStyle) => 
    withColor(baseStyle, VersusColors.secondary);
}