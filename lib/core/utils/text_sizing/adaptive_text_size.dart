import 'package:flutter/material.dart';

// Re-export all modules for backward compatibility
export 'constants/text_size_constants.dart';
export 'constants/breakpoint_constants.dart';
export 'calculators/text_size_calculator.dart';
export 'calculators/responsive_calculator.dart';
export 'calculators/scale_factor_calculator.dart';
export 'helpers/text_style_helpers.dart';
export 'helpers/device_helpers.dart';

// Import necessary modules
import 'constants/text_size_constants.dart';
import 'calculators/text_size_calculator.dart';
import 'calculators/responsive_calculator.dart';
import 'helpers/text_style_helpers.dart';

/// 투표 알림에서 박스 크기에 따른 적응형 텍스트 크기 계산 유틸리티
///
/// 다양한 화면 크기와 박스 크기에서 최적의 가독성을 제공하는
/// 텍스트 크기를 자동으로 계산합니다.
/// 
/// This is now a facade that delegates to the modular text sizing system.
/// For direct access to specific functionality, use the individual modules.
class AdaptiveTextSize {
  /// 박스 크기에 기반한 적응형 텍스트 크기 계산
  ///
  /// [containerSize] 컨테이너 크기
  /// [textType] 텍스트 유형 (제목, 부제목, 본문 등)
  /// [maxLines] 최대 라인 수 (기본값: 2)
  /// [padding] 컨테이너 내부 패딩 (기본값: 16.0)
  static double calculate({
    required Size containerSize,
    TextType textType = TextType.title,
    int maxLines = 2,
    double padding = TextSizeConstants.defaultPadding,
  }) {
    return TextSizeCalculator.calculate(
      containerSize: containerSize,
      textType: textType,
      maxLines: maxLines,
      padding: padding,
    );
  }

  /// 컨테이너 높이 기반 간단한 텍스트 크기 계산
  ///
  /// [containerHeight] 컨테이너 높이
  /// [heightRatio] 높이 대비 텍스트 크기 비율 (기본값: 0.12 = 12%)
  /// [textType] 텍스트 유형
  static double fromHeight({
    required double containerHeight,
    double heightRatio = TextSizeConstants.defaultHeightRatio,
    TextType textType = TextType.title,
  }) {
    return TextSizeCalculator.fromHeight(
      containerHeight: containerHeight,
      heightRatio: heightRatio,
      textType: textType,
    );
  }

  /// 컨테이너 너비 기반 텍스트 크기 계산
  ///
  /// [containerWidth] 컨테이너 너비
  /// [widthRatio] 너비 대비 텍스트 크기 비율 (기본값: 0.08 = 8%)
  /// [textType] 텍스트 유형
  static double fromWidth({
    required double containerWidth,
    double widthRatio = TextSizeConstants.defaultWidthRatio,
    TextType textType = TextType.title,
  }) {
    return TextSizeCalculator.fromWidth(
      containerWidth: containerWidth,
      widthRatio: widthRatio,
      textType: textType,
    );
  }

  /// 텍스트 길이를 고려한 적응형 크기 계산
  ///
  /// [text] 실제 텍스트 내용
  /// [containerSize] 컨테이너 크기
  /// [textType] 텍스트 유형
  /// [maxLines] 최대 라인 수
  /// [fontWeight] 폰트 두께
  static double forText({
    required String text,
    required Size containerSize,
    TextType textType = TextType.title,
    int maxLines = 2,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextSizeCalculator.forText(
      text: text,
      containerSize: containerSize,
      textType: textType,
      maxLines: maxLines,
      fontWeight: fontWeight,
    );
  }

  /// 반응형 텍스트 크기 계산 (화면 크기 고려)
  ///
  /// [context] BuildContext
  /// [containerSize] 컨테이너 크기
  /// [textType] 텍스트 유형
  static double responsive({
    required BuildContext context,
    required Size containerSize,
    TextType textType = TextType.title,
  }) {
    return ResponsiveCalculator.calculate(
      context: context,
      containerSize: containerSize,
      textType: textType,
    );
  }

  /// 다중 라인 텍스트를 위한 최적 크기 계산
  ///
  /// [lines] 텍스트 라인들
  /// [containerSize] 컨테이너 크기
  /// [textType] 텍스트 유형
  /// [lineSpacing] 라인 간격 (기본값: 1.2)
  static double forMultilineText({
    required List<String> lines,
    required Size containerSize,
    TextType textType = TextType.body,
    double lineSpacing = TextSizeConstants.defaultLineSpacing,
  }) {
    return TextSizeCalculator.forMultilineText(
      lines: lines,
      containerSize: containerSize,
      textType: textType,
      lineSpacing: lineSpacing,
    );
  }
}

/// 적응형 텍스트 위젯
///
/// AdaptiveTextSize를 사용하여 자동으로 크기가 조정되는 텍스트 위젯
class AdaptiveText extends StatelessWidget {
  final String text;
  final Size containerSize;
  final TextType textType;
  final int maxLines;
  final FontWeight fontWeight;
  final Color? color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final bool responsive;

  const AdaptiveText(
    this.text, {
    Key? key,
    required this.containerSize,
    this.textType = TextType.body,
    this.maxLines = 2,
    this.fontWeight = FontWeight.normal,
    this.color,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.ellipsis,
    this.responsive = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fontSize = responsive
        ? AdaptiveTextSize.responsive(
            context: context,
            containerSize: containerSize,
            textType: textType,
          )
        : AdaptiveTextSize.forText(
            text: text,
            containerSize: containerSize,
            textType: textType,
            maxLines: maxLines,
            fontWeight: fontWeight,
          );

    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// 적응형 텍스트 스타일 헬퍼
class AdaptiveTextStyle {
  /// 컨테이너 크기에 맞는 TextStyle 생성
  static TextStyle create({
    required Size containerSize,
    TextType textType = TextType.body,
    int maxLines = 2,
    FontWeight fontWeight = FontWeight.normal,
    Color color = Colors.black,
    String? fontFamily,
    bool responsive = false,
    BuildContext? context,
  }) {
    if (responsive && context != null) {
      return TextStyleHelpers.createResponsiveStyle(
        context: context,
        containerSize: containerSize,
        textType: textType,
        fontWeight: fontWeight,
        color: color,
        fontFamily: fontFamily,
      );
    } else {
      return TextStyleHelpers.createAdaptiveStyle(
        containerSize: containerSize,
        textType: textType,
        maxLines: maxLines,
        fontWeight: fontWeight,
        color: color,
        fontFamily: fontFamily,
      );
    }
  }
}