import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/voting_notification_constraints.dart';

/// 투표 알림에서 박스 크기에 따른 적응형 텍스트 크기 계산 유틸리티
/// 
/// 다양한 화면 크기와 박스 크기에서 최적의 가독성을 제공하는
/// 텍스트 크기를 자동으로 계산합니다.
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
    double padding = 16.0,
  }) {
    // 사용 가능한 공간 계산
    final availableWidth = containerSize.width - (padding * 2);
    final availableHeight = containerSize.height - (padding * 2);
    
    // 텍스트 유형별 기준 크기
    final baseSize = _getBaseSizeForType(textType);
    
    // 컨테이너 크기에 따른 스케일링 팩터 계산
    final scaleFactor = _calculateScaleFactor(
      availableWidth: availableWidth,
      availableHeight: availableHeight,
      maxLines: maxLines,
    );
    
    // 최종 크기 계산
    final calculatedSize = baseSize * scaleFactor;
    
    // 제약 조건 적용
    return _applyConstraints(calculatedSize, textType);
  }
  
  /// 컨테이너 높이 기반 간단한 텍스트 크기 계산
  /// 
  /// [containerHeight] 컨테이너 높이
  /// [heightRatio] 높이 대비 텍스트 크기 비율 (기본값: 0.12 = 12%)
  /// [textType] 텍스트 유형
  static double fromHeight({
    required double containerHeight,
    double heightRatio = 0.12,
    TextType textType = TextType.title,
  }) {
    final calculatedSize = containerHeight * heightRatio;
    return _applyConstraints(calculatedSize, textType);
  }
  
  /// 컨테이너 너비 기반 텍스트 크기 계산
  /// 
  /// [containerWidth] 컨테이너 너비
  /// [widthRatio] 너비 대비 텍스트 크기 비율 (기본값: 0.08 = 8%)
  /// [textType] 텍스트 유형
  static double fromWidth({
    required double containerWidth,
    double widthRatio = 0.08,
    TextType textType = TextType.title,
  }) {
    final calculatedSize = containerWidth * widthRatio;
    return _applyConstraints(calculatedSize, textType);
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
    // 기본 계산
    double baseSize = calculate(
      containerSize: containerSize,
      textType: textType,
      maxLines: maxLines,
    );
    
    // 텍스트 길이에 따른 조정
    final textLength = text.length;
    double lengthFactor = 1.0;
    
    if (textLength > 30) {
      lengthFactor = 0.85; // 긴 텍스트는 크기 축소
    } else if (textLength > 50) {
      lengthFactor = 0.75; // 매우 긴 텍스트는 더 축소
    } else if (textLength < 10) {
      lengthFactor = 1.15; // 짧은 텍스트는 크기 증가
    }
    
    // 폰트 두께에 따른 조정
    double weightFactor = 1.0;
    if (fontWeight == FontWeight.bold || 
        fontWeight == FontWeight.w700 || 
        fontWeight == FontWeight.w800 || 
        fontWeight == FontWeight.w900) {
      weightFactor = 0.95; // 볼드 폰트는 약간 축소
    } else if (fontWeight == FontWeight.w300 || 
               fontWeight == FontWeight.w200 || 
               fontWeight == FontWeight.w100) {
      weightFactor = 1.05; // 얇은 폰트는 약간 확대
    }
    
    final adjustedSize = baseSize * lengthFactor * weightFactor;
    return _applyConstraints(adjustedSize, textType);
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // 화면 크기에 따른 기본 크기 계산
    double baseSize = calculate(
      containerSize: containerSize,
      textType: textType,
    );
    
    // 화면 크기별 조정 팩터
    double screenFactor = 1.0;
    
    if (screenWidth < 350) {
      // 작은 화면: 텍스트 크기 축소
      screenFactor = 0.9;
    } else if (screenWidth > 500) {
      // 큰 화면: 텍스트 크기 확대
      screenFactor = 1.1;
    }
    
    // 화면 비율 고려 (매우 좁거나 넓은 화면)
    final aspectRatio = screenWidth / screenHeight;
    if (aspectRatio < 0.5) {
      // 매우 세로로 긴 화면
      screenFactor *= 0.95;
    } else if (aspectRatio > 2.0) {
      // 매우 가로로 긴 화면
      screenFactor *= 1.05;
    }
    
    final adjustedSize = baseSize * screenFactor;
    return _applyConstraints(adjustedSize, textType);
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
    double lineSpacing = 1.2,
  }) {
    if (lines.isEmpty) return _getBaseSizeForType(textType);
    
    final lineCount = lines.length;
    
    // 라인 수에 따른 크기 조정
    double lineFactor = 1.0;
    if (lineCount > 3) {
      lineFactor = 0.8; // 많은 라인은 크기 축소
    } else if (lineCount == 1) {
      lineFactor = 1.2; // 단일 라인은 크기 확대
    }
    
    // 사용 가능한 높이 계산 (라인 간격 고려)
    final totalLineHeight = containerSize.height / (lineCount + (lineCount - 1) * (lineSpacing - 1));
    
    // 높이 기반 크기와 길이 기반 크기 중 작은 값 선택
    final heightBasedSize = fromHeight(
      containerHeight: totalLineHeight,
      textType: textType,
    );
    
    final lengthBasedSize = forText(
      text: lines.reduce((a, b) => a.length > b.length ? a : b), // 가장 긴 라인
      containerSize: containerSize,
      textType: textType,
      maxLines: lineCount,
    );
    
    final finalSize = math.min(heightBasedSize, lengthBasedSize) * lineFactor;
    return _applyConstraints(finalSize, textType);
  }
  
  // 내부 헬퍼 메서드들
  
  /// 텍스트 유형별 기준 크기 반환
  static double _getBaseSizeForType(TextType textType) {
    switch (textType) {
      case TextType.title:
        return 16.0;
      case TextType.subtitle:
        return 14.0;
      case TextType.body:
        return 12.0;
      case TextType.caption:
        return 10.0;
      case TextType.label:
        return 11.0;
      case TextType.button:
        return 13.0;
    }
  }
  
  /// 스케일링 팩터 계산
  static double _calculateScaleFactor({
    required double availableWidth,
    required double availableHeight,
    required int maxLines,
  }) {
    // 기준 크기 (300x150 컨테이너를 기준으로 함)
    const referenceWidth = 300.0;
    const referenceHeight = 150.0;
    
    // 너비와 높이 기반 스케일링 팩터
    final widthFactor = availableWidth / referenceWidth;
    final heightFactor = availableHeight / (referenceHeight / maxLines);
    
    // 더 제한적인 요소를 기준으로 스케일링
    final scaleFactor = math.min(widthFactor, heightFactor);
    
    // 과도한 스케일링 방지
    return scaleFactor.clamp(0.5, 2.0);
  }
  
  /// 제약 조건 적용
  static double _applyConstraints(double size, TextType textType) {
    // 텍스트 유형별 최소/최대 크기
    double minSize, maxSize;
    
    switch (textType) {
      case TextType.title:
        minSize = VotingNotificationConstraints.minTextSize + 2;
        maxSize = VotingNotificationConstraints.maxTextSize + 4;
        break;
      case TextType.subtitle:
        minSize = VotingNotificationConstraints.minTextSize + 1;
        maxSize = VotingNotificationConstraints.maxTextSize + 2;
        break;
      case TextType.body:
        minSize = VotingNotificationConstraints.minTextSize;
        maxSize = VotingNotificationConstraints.maxTextSize;
        break;
      case TextType.caption:
        minSize = VotingNotificationConstraints.minTextSize - 1;
        maxSize = VotingNotificationConstraints.maxTextSize - 2;
        break;
      case TextType.label:
        minSize = VotingNotificationConstraints.minTextSize;
        maxSize = VotingNotificationConstraints.maxTextSize - 1;
        break;
      case TextType.button:
        minSize = VotingNotificationConstraints.minTextSize + 1;
        maxSize = VotingNotificationConstraints.maxTextSize + 1;
        break;
    }
    
    return size.clamp(minSize, maxSize);
  }
}

/// 텍스트 유형 열거형
enum TextType {
  title,    // 제목 (가장 큰 텍스트)
  subtitle, // 부제목
  body,     // 본문
  caption,  // 캡션 (가장 작은 텍스트)
  label,    // 라벨
  button,   // 버튼 텍스트
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
    double fontSize;
    
    if (responsive && context != null) {
      fontSize = AdaptiveTextSize.responsive(
        context: context,
        containerSize: containerSize,
        textType: textType,
      );
    } else {
      fontSize = AdaptiveTextSize.calculate(
        containerSize: containerSize,
        textType: textType,
        maxLines: maxLines,
      );
    }
    
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: fontFamily,
    );
  }
}