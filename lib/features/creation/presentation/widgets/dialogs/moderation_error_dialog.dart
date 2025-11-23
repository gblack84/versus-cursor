import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 이미지 검열 실패 시 표시되는 경고 다이얼로그
class ModerationErrorDialog extends StatelessWidget {
  final String reason;
  final String box;
  final VoidCallback? onRetry;

  const ModerationErrorDialog({
    super.key,
    required this.reason,
    required this.box,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.of(context).secondaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.of(context).error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text('부적절한 콘텐츠', style: AppTheme.of(context).headlineSmall),
        ],
      ),
      content: Text(
        '$reason\n다른 이미지를 선택해주세요.',
        style: AppTheme.of(context).bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 경고 다이얼로그 닫기
            // onRetry 콜백 호출 (Navigator.pop들은 콜백 내부에서 처리)
            onRetry?.call();
          },
          child: Text(
            '다시 선택',
            style: AppTheme.of(context).bodyMedium.override(
              color: AppTheme.of(context).primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// 다이얼로그 표시 헬퍼 메서드
  static void show({
    required BuildContext context,
    required String reason,
    required String box,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          ModerationErrorDialog(reason: reason, box: box, onRetry: onRetry),
    );
  }
}
