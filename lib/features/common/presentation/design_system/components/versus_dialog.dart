import 'package:flutter/material.dart';
import '/features/common/presentation/design_system/tokens/versus_tokens.dart';

/// Versus Space 표준 다이얼로그 컴포넌트
/// 
/// AIModerationService의 다이얼로그 패턴을 기반으로 표준화했습니다.
/// 일관된 스타일과 동작을 제공합니다.
class VersusDialog {
  /// 경고 다이얼로그
  /// 
  /// AI Moderation의 warning 다이얼로그 패턴을 표준화한 것입니다.
  /// 사용자가 수정하거나 계속 진행할 수 있는 선택지를 제공합니다.
  static Future<bool?> warning({
    required BuildContext context,
    required String title,
    required String content,
    String? suggestions,
    String confirmText = '계속하기',
    String cancelText = '수정하기',
    bool barrierDismissible = false,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: VersusRadius.radiusMedium,
          ),
          title: Text(
            title,
            style: VersusTextStyles.dialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: VersusTextStyles.dialogContent,
              ),
              if (suggestions != null && suggestions.isNotEmpty) ...[
                VersusSpacing.gapMD,
                _buildSuggestionBox(suggestions),
              ],
              VersusSpacing.gapMD,
              Text(
                '계속 진행하시겠습니까?',
                style: VersusTextStyles.dialogContent,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VersusDialogButton.outlined(
                    text: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  VersusSpacing.gapH(VersusSpacing.sm),
                  _VersusDialogButton.outlined(
                    text: confirmText,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 에러/차단 다이얼로그
  /// 
  /// AI Moderation의 block 다이얼로그 패턴을 표준화한 것입니다.
  /// 사용자에게 문제점을 알려주고 수정을 요구합니다.
  static Future<void> error({
    required BuildContext context,
    required String title,
    required String content,
    List<String>? violations,
    String? suggestions,
    String confirmText = '확인',
    bool barrierDismissible = false,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: VersusRadius.radiusMedium,
          ),
          title: Text(
            title,
            style: VersusTextStyles.dialogTitle,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content,
                style: VersusTextStyles.dialogContent,
              ),
              if (violations != null && violations.isNotEmpty) ...[
                VersusSpacing.gapSM,
                ...violations.map((violation) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '• $violation',
                    style: VersusTextStyles.error,
                  ),
                )),
              ],
              if (suggestions != null && suggestions.isNotEmpty) ...[
                VersusSpacing.gapMD,
                _buildSuggestionBox(suggestions),
              ],
              VersusSpacing.gapSM,
              Text(
                '내용을 수정한 후 다시 시도해주세요.',
                style: VersusTextStyles.dialogContent,
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: _VersusDialogButton.outlined(
                text: confirmText,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 일반 확인 다이얼로그
  /// 
  /// 간단한 확인 메시지용 다이얼로그입니다.
  static Future<bool?> confirm({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    bool barrierDismissible = true,
  }) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: VersusRadius.radiusMedium,
          ),
          title: Text(
            title,
            style: VersusTextStyles.dialogTitle,
          ),
          content: Text(
            content,
            style: VersusTextStyles.dialogContent,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VersusDialogButton.outlined(
                    text: cancelText,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  VersusSpacing.gapH(VersusSpacing.sm),
                  _VersusDialogButton.outlined(
                    text: confirmText,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// 정보 다이얼로그
  /// 
  /// 단순한 정보 표시용 다이얼로그입니다.
  static Future<void> info({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    bool barrierDismissible = true,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: _getBackgroundColor(context),
          shape: RoundedRectangleBorder(
            borderRadius: VersusRadius.radiusMedium,
          ),
          title: Text(
            title,
            style: VersusTextStyles.dialogTitle,
          ),
          content: Text(
            content,
            style: VersusTextStyles.dialogContent,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8, right: 8),
              child: _VersusDialogButton.outlined(
                text: confirmText,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        );
      },
    );
  }

  // 내부 헬퍼 메서드들
  static Color _getBackgroundColor(BuildContext context) {
    // 기존 AppTheme과 호환성 유지
    try {
      final theme = Theme.of(context);
      if (theme.brightness == Brightness.dark) {
        return VersusColors.darkSurface;
      } else {
        return VersusColors.backgroundSecondary;
      }
    } catch (e) {
      return VersusColors.backgroundSecondary;
    }
  }

  static Widget _buildSuggestionBox(String suggestions) {
    return Container(
      padding: VersusSpacing.paddingMD,
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        border: Border.all(
          color: VersusColors.borderColor,
          width: 1,
        ),
        borderRadius: VersusRadius.radiusSmall,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                VersusIcons.check.getIcon(VersusIcons.currentStyle),
                size: 16,
                color: VersusColors.textPrimary,
              ),
              VersusSpacing.gapH(4),
              Text(
                '제안:',
                style: VersusTextStyles.labelMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VersusSpacing.gapXS,
          Text(
            suggestions,
            style: VersusTextStyles.labelMedium,
          ),
        ],
      ),
    );
  }
}

/// 다이얼로그용 버튼 컴포넌트
/// 
/// 기존 OutlinedButton 패턴을 표준화한 내부 컴포넌트입니다.
class _VersusDialogButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? foregroundColor;
  final Color? borderColor;

  const _VersusDialogButton._({
    required this.text,
    this.onPressed,
    this.foregroundColor,
    this.borderColor,
  });

  factory _VersusDialogButton.outlined({
    required String text,
    VoidCallback? onPressed,
  }) {
    return _VersusDialogButton._(
      text: text,
      onPressed: onPressed,
      foregroundColor: VersusColors.borderColor,
      borderColor: VersusColors.borderColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor ?? VersusColors.borderColor,
        side: BorderSide(
          color: borderColor ?? VersusColors.borderColor,
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: VersusRadius.radiusSmall,
        ),
        padding: VersusSpacing.buttonInternal,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: VersusTextStyles.buttonMedium.copyWith(
          color: foregroundColor ?? VersusColors.borderColor,
        ),
      ),
    );
  }
}