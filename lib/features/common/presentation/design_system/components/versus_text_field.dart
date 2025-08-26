import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/features/common/presentation/design_system/tokens/versus_tokens.dart';

/// Versus Space 표준 텍스트 필드 컴포넌트
/// 
/// 기존 SimpleValidatedField와 TextField 패턴을 분석하여 표준화했습니다.
/// 일관된 스타일과 동작을 제공합니다.
class VersusTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final VersusTextFieldType type;
  final VersusTextFieldSize size;
  final int? maxLength;
  final int? maxLines;
  final int? minLines;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final bool showClearButton;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onEditingComplete;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? fillColor;
  final Color? borderColor;
  final bool isFullWidth;

  const VersusTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.type = VersusTextFieldType.outline,
    this.size = VersusTextFieldSize.medium,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.showClearButton = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.onChanged,
    this.onTap,
    this.onSubmitted,
    this.onEditingComplete,
    this.prefixIcon,
    this.suffixIcon,
    this.fillColor,
    this.borderColor,
    this.isFullWidth = true,
  });

  /// 제목용 텍스트 필드 (단일 라인, 큰 텍스트)
  factory VersusTextField.title({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? errorText,
    int? maxLength,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool showClearButton = false,
  }) {
    return VersusTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: VersusTextFieldType.outline,
      size: VersusTextFieldSize.large,
      maxLength: maxLength,
      maxLines: 1,
      onChanged: onChanged,
      enabled: enabled,
      showClearButton: showClearButton,
      textInputAction: TextInputAction.next,
    );
  }

  /// 설명용 텍스트 필드 (여러 라인)
  factory VersusTextField.description({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? labelText,
    String? hintText,
    String? errorText,
    int? maxLength,
    int maxLines = 4,
    int? minLines = 1,
    ValueChanged<String>? onChanged,
    bool enabled = true,
    bool showClearButton = false,
  }) {
    return VersusTextField(
      controller: controller,
      focusNode: focusNode,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      type: VersusTextFieldType.outline,
      size: VersusTextFieldSize.medium,
      maxLength: maxLength,
      maxLines: maxLines,
      minLines: minLines,
      onChanged: onChanged,
      enabled: enabled,
      showClearButton: showClearButton,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,
    );
  }

  /// 검색용 텍스트 필드
  factory VersusTextField.search({
    TextEditingController? controller,
    FocusNode? focusNode,
    String? hintText = '검색...',
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    bool autofocus = false,
  }) {
    return VersusTextField(
      controller: controller,
      focusNode: focusNode,
      hintText: hintText,
      type: VersusTextFieldType.filled,
      size: VersusTextFieldSize.medium,
      maxLines: 1,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      autofocus: autofocus,
      showClearButton: true,
      prefixIcon: const Icon(Icons.search),
      textInputAction: TextInputAction.search,
      keyboardType: TextInputType.text,
    );
  }

  /// 비밀번호용 텍스트 필드는 별도 위젯으로 제공됩니다.
  /// VersusPasswordField를 사용하세요.

  @override
  State<VersusTextField> createState() => _VersusTextFieldState();
}

class _VersusTextFieldState extends State<VersusTextField> {
  late TextEditingController _controller;
  bool _isControllerOwned = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _controller = TextEditingController();
      _isControllerOwned = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    if (_isControllerOwned) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = _getTextStyle();
    final inputDecoration = _buildInputDecoration();
    
    Widget textField = TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      style: textStyle,
      decoration: inputDecoration,
      maxLength: widget.maxLength,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onTap: widget.onTap,
      onSubmitted: widget.onSubmitted,
      onEditingComplete: widget.onEditingComplete,
    );

    if (widget.isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: textField,
      );
    }

    return textField;
  }

  TextStyle _getTextStyle() {
    switch (widget.size) {
      case VersusTextFieldSize.small:
        return VersusTextStyles.bodySmall;
      case VersusTextFieldSize.medium:
        return VersusTextStyles.bodyMedium;
      case VersusTextFieldSize.large:
        return VersusTextStyles.bodyLarge;
    }
  }

  InputDecoration _buildInputDecoration() {
    final borderColor = widget.borderColor ?? VersusColors.borderLight;
    final focusedBorderColor = widget.errorText != null 
        ? VersusColors.error 
        : VersusColors.primary;
    
    InputBorder border;
    Color? fillColor;
    
    switch (widget.type) {
      case VersusTextFieldType.outline:
        border = OutlineInputBorder(
          borderRadius: VersusRadius.radiusSmall,
          borderSide: BorderSide(color: borderColor, width: 1),
        );
        break;
        
      case VersusTextFieldType.filled:
        border = OutlineInputBorder(
          borderRadius: VersusRadius.radiusSmall,
          borderSide: BorderSide.none,
        );
        fillColor = widget.fillColor ?? VersusColors.backgroundSecondary;
        break;
        
      case VersusTextFieldType.underline:
        border = UnderlineInputBorder(
          borderSide: BorderSide(color: borderColor, width: 1),
        );
        break;
    }

    return InputDecoration(
      labelText: widget.labelText,
      labelStyle: VersusTextStyles.labelMedium,
      hintText: widget.hintText,
      hintStyle: VersusTextStyles.labelMedium.copyWith(
        color: VersusColors.textSecondary.withValues(alpha: 0.6),
      ),
      helperText: widget.helperText,
      helperStyle: VersusTextStyles.labelSmall,
      errorText: widget.errorText,
      errorStyle: VersusTextStyles.error,
      filled: widget.type == VersusTextFieldType.filled,
      fillColor: fillColor,
      prefixIcon: widget.prefixIcon,
      suffixIcon: _buildSuffixIcon(),
      contentPadding: _getContentPadding(),
      border: border,
      enabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: VersusColors.error, width: 1),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: VersusColors.error, width: 2),
      ),
      counterStyle: VersusTextStyles.labelSmall,
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.showClearButton && _controller.text.isNotEmpty) {
      return IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: () {
          _controller.clear();
          widget.onChanged?.call('');
        },
        splashRadius: 16,
      );
    }
    return widget.suffixIcon;
  }

  EdgeInsets _getContentPadding() {
    switch (widget.size) {
      case VersusTextFieldSize.small:
        return const EdgeInsets.symmetric(
          horizontal: VersusSpacing.sm,
          vertical: VersusSpacing.xs,
        );
      case VersusTextFieldSize.medium:
        return const EdgeInsets.symmetric(
          horizontal: VersusSpacing.md,
          vertical: VersusSpacing.sm,
        );
      case VersusTextFieldSize.large:
        return const EdgeInsets.symmetric(
          horizontal: VersusSpacing.md,
          vertical: VersusSpacing.md,
        );
    }
  }
}

/// 비밀번호 필드 (토글 버튼 포함)
class VersusPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;

  const VersusPasswordField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
  });

  @override
  State<VersusPasswordField> createState() => _VersusPasswordFieldState();
}

class _VersusPasswordFieldState extends State<VersusPasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return VersusTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      labelText: widget.labelText,
      hintText: widget.hintText,
      errorText: widget.errorText,
      obscureText: _obscureText,
      enabled: widget.enabled,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          size: 18,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
        splashRadius: 16,
      ),
    );
  }
}

/// 텍스트 필드 타입 열거형
enum VersusTextFieldType {
  outline,    // 외곽선 (기본)
  filled,     // 배경 채움
  underline,  // 밑줄만
}

/// 텍스트 필드 크기 열거형
enum VersusTextFieldSize {
  small,      // 작은 크기
  medium,     // 중간 크기 (기본)
  large,      // 큰 크기
}