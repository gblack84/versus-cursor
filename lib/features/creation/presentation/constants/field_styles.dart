import 'package:flutter/material.dart';

/// 필드 스타일 설정을 중앙 관리하는 클래스
/// 나중에 전역으로 이동 가능한 구조로 설계
class FieldStyles {
  // 필드 타입 상수
  static const String questionTitle = 'questionTitle';
  static const String description = 'description';
  static const String textA = 'textA';
  static const String textB = 'textB';

  // 필드별 설정
  static const Map<String, FieldConfig> fieldConfigs = {
    questionTitle: FieldConfig(
      textSize: 30.0,
      labelSize: 30.0,
      maxLength: 60,
      maxLines: 3,
      minLines: 1,
      isDense: false,
      borderType: FieldBorderType.underline,
      borderWidth: 2.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      fieldPadding: EdgeInsets.zero,
      textInputAction: TextInputAction.done,
      showCharacterCount: true,
      showClearButton: true,
    ),
    description: FieldConfig(
      textSize: 20.0,
      labelSize: 25.0,
      maxLength: 200,
      maxLines: null, // 무제한
      minLines: 1,
      isDense: false,
      borderType: FieldBorderType.underline,
      borderWidth: 2.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      fieldPadding: EdgeInsets.zero,
      textInputAction: TextInputAction.newline,
      showCharacterCount: true,
      showClearButton: true,
    ),
    textA: FieldConfig(
      textSize: 15.0,
      labelSize: 20.0,
      maxLength: 20,
      maxLines: 5,
      minLines: 1,
      isDense: true,
      borderType: FieldBorderType.underline,
      borderWidth: 2.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      fieldPadding: EdgeInsets.zero,
      textInputAction: TextInputAction.done,
      showCharacterCount: true,
      showClearButton: true,
    ),
    textB: FieldConfig(
      textSize: 15.0,
      labelSize: 20.0,
      maxLength: 20,
      maxLines: 5,
      minLines: 1,
      isDense: true,
      borderType: FieldBorderType.underline,
      borderWidth: 2.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
      fieldPadding: EdgeInsets.zero,
      textInputAction: TextInputAction.done,
      showCharacterCount: true,
      showClearButton: true,
    ),
  };

  // 공통 스타일 상수
  static const Color borderColor = Colors.black;
  static const Color focusedBorderColor = Colors.black;
  static const Color errorBorderColor = Colors.black;
  static const double borderRadius = 12.0;
  static const double borderRadiusDense = 12.0;

  // 헬퍼 메서드
  static FieldConfig getConfig(String fieldName) {
    return fieldConfigs[fieldName] ?? _defaultConfig;
  }

  // 기본 설정
  static const FieldConfig _defaultConfig = FieldConfig(
    textSize: 14.0,
    labelSize: 14.0,
    maxLength: null,
    maxLines: 1,
    minLines: 1,
    isDense: true,
    borderType: FieldBorderType.underline,
    borderWidth: 2.0,
    contentPadding: EdgeInsets.symmetric(vertical: 12.0),
    fieldPadding: EdgeInsets.zero,
    textInputAction: TextInputAction.done,
    showCharacterCount: false,
    showClearButton: true,
  );
}

/// 필드 설정 모델
class FieldConfig {
  final double textSize;
  final double labelSize;
  final int? maxLength;
  final int? maxLines;
  final int minLines;
  final bool isDense;
  final FieldBorderType borderType;
  final double borderWidth;
  final EdgeInsets contentPadding;
  final EdgeInsets fieldPadding;
  final TextInputAction textInputAction;
  final bool showCharacterCount;
  final bool showClearButton;

  const FieldConfig({
    required this.textSize,
    required this.labelSize,
    required this.maxLength,
    required this.maxLines,
    required this.minLines,
    required this.isDense,
    required this.borderType,
    required this.borderWidth,
    required this.contentPadding,
    required this.fieldPadding,
    required this.textInputAction,
    required this.showCharacterCount,
    required this.showClearButton,
  });

  /// 기존 설정을 복사하면서 일부 속성만 변경
  /// 나중에 전역 스타일을 상속받을 때 유용
  FieldConfig copyWith({
    double? textSize,
    double? labelSize,
    int? maxLength,
    int? maxLines,
    int? minLines,
    bool? isDense,
    FieldBorderType? borderType,
    double? borderWidth,
    EdgeInsets? contentPadding,
    EdgeInsets? fieldPadding,
    TextInputAction? textInputAction,
    bool? showCharacterCount,
    bool? showClearButton,
  }) {
    return FieldConfig(
      textSize: textSize ?? this.textSize,
      labelSize: labelSize ?? this.labelSize,
      maxLength: maxLength ?? this.maxLength,
      maxLines: maxLines ?? this.maxLines,
      minLines: minLines ?? this.minLines,
      isDense: isDense ?? this.isDense,
      borderType: borderType ?? this.borderType,
      borderWidth: borderWidth ?? this.borderWidth,
      contentPadding: contentPadding ?? this.contentPadding,
      fieldPadding: fieldPadding ?? this.fieldPadding,
      textInputAction: textInputAction ?? this.textInputAction,
      showCharacterCount: showCharacterCount ?? this.showCharacterCount,
      showClearButton: showClearButton ?? this.showClearButton,
    );
  }
}

/// 보더 타입 enum
enum FieldBorderType {
  underline,
  outline,
  none,
}
