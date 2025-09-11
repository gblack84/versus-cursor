import 'package:flutter/material.dart';
import '/core/design_system/tokens/versus_tokens.dart';

/// Versus Space 표준 버튼 컴포넌트
///
/// 기존 OutlinedButton 패턴을 분석하여 표준화했습니다.
/// 일관된 스타일과 동작을 제공합니다.
class VersusButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final VersusButtonType type;
  final VersusButtonSize size;
  final Color? customColor;
  final Icon? icon;
  final bool isLoading;
  final bool isFullWidth;

  const VersusButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = VersusButtonType.outline,
    this.size = VersusButtonSize.medium,
    this.customColor,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  /// 주요 액션용 버튼 (브랜드 색상)
  factory VersusButton.primary({
    required String text,
    VoidCallback? onPressed,
    VersusButtonSize size = VersusButtonSize.medium,
    Icon? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return VersusButton(
      text: text,
      onPressed: onPressed,
      type: VersusButtonType.filled,
      size: size,
      customColor: VersusColors.primary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// 보조 액션용 버튼 (보조 색상)
  factory VersusButton.secondary({
    required String text,
    VoidCallback? onPressed,
    VersusButtonSize size = VersusButtonSize.medium,
    Icon? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return VersusButton(
      text: text,
      onPressed: onPressed,
      type: VersusButtonType.filled,
      size: size,
      customColor: VersusColors.secondary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// 외곽선 버튼 (기존 OutlinedButton 패턴)
  factory VersusButton.outline({
    required String text,
    VoidCallback? onPressed,
    VersusButtonSize size = VersusButtonSize.medium,
    Color? borderColor,
    Icon? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return VersusButton(
      text: text,
      onPressed: onPressed,
      type: VersusButtonType.outline,
      size: size,
      customColor: borderColor ?? VersusColors.borderColor,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// 텍스트 버튼 (배경 없음)
  factory VersusButton.text({
    required String text,
    VoidCallback? onPressed,
    VersusButtonSize size = VersusButtonSize.medium,
    Color? textColor,
    Icon? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return VersusButton(
      text: text,
      onPressed: onPressed,
      type: VersusButtonType.text,
      size: size,
      customColor: textColor ?? VersusColors.primary,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  /// 에러/위험 액션용 버튼
  factory VersusButton.error({
    required String text,
    VoidCallback? onPressed,
    VersusButtonSize size = VersusButtonSize.medium,
    Icon? icon,
    bool isLoading = false,
    bool isFullWidth = false,
  }) {
    return VersusButton(
      text: text,
      onPressed: onPressed,
      type: VersusButtonType.filled,
      size: size,
      customColor: VersusColors.error,
      icon: icon,
      isLoading: isLoading,
      isFullWidth: isFullWidth,
    );
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();
    final padding = _getPadding();

    Widget button;

    switch (type) {
      case VersusButtonType.filled:
        button = ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: customColor ?? VersusColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: VersusRadius.radiusSmall,
            ),
            padding: padding,
            elevation: 0,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(textStyle.copyWith(color: Colors.white)),
        );
        break;

      case VersusButtonType.outline:
        button = OutlinedButton(
          style: OutlinedButton.styleFrom(
            foregroundColor: customColor ?? VersusColors.borderColor,
            side: BorderSide(
              color: customColor ?? VersusColors.borderColor,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: VersusRadius.radiusSmall,
            ),
            padding: padding,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(textStyle.copyWith(
            color: customColor ?? VersusColors.borderColor,
          )),
        );
        break;

      case VersusButtonType.text:
        button = TextButton(
          style: TextButton.styleFrom(
            foregroundColor: customColor ?? VersusColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: VersusRadius.radiusSmall,
            ),
            padding: padding,
          ),
          onPressed: isLoading ? null : onPressed,
          child: _buildButtonContent(textStyle.copyWith(
            color: customColor ?? VersusColors.primary,
          )),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(TextStyle textStyle) {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            textStyle.color ?? VersusColors.primary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon!.icon,
            size: _getIconSize(),
            color: textStyle.color,
          ),
          VersusSpacing.gapH(VersusSpacing.sm),
          Text(text, style: textStyle),
        ],
      );
    }

    return Text(text, style: textStyle);
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case VersusButtonSize.small:
        return VersusTextStyles.buttonSmall;
      case VersusButtonSize.medium:
        return VersusTextStyles.buttonMedium;
      case VersusButtonSize.large:
        return VersusTextStyles.buttonLarge;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case VersusButtonSize.small:
        return const EdgeInsets.symmetric(
          horizontal: VersusSpacing.sm,
          vertical: VersusSpacing.xs,
        );
      case VersusButtonSize.medium:
        return VersusSpacing.buttonInternal;
      case VersusButtonSize.large:
        return const EdgeInsets.symmetric(
          horizontal: VersusSpacing.lg,
          vertical: VersusSpacing.sm,
        );
    }
  }

  double _getIconSize() {
    switch (size) {
      case VersusButtonSize.small:
        return 14.0;
      case VersusButtonSize.medium:
        return 16.0;
      case VersusButtonSize.large:
        return 18.0;
    }
  }
}

/// 버튼 타입 열거형
enum VersusButtonType {
  filled, // 배경 채워진 버튼
  outline, // 외곽선 버튼
  text, // 텍스트만 있는 버튼
}

/// 버튼 크기 열거형
enum VersusButtonSize {
  small, // 작은 버튼
  medium, // 중간 버튼 (기본)
  large, // 큰 버튼
}
