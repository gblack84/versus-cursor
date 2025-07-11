import 'package:flutter/material.dart';
import '/core/app_theme.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.of(context).error,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            '부적절한 콘텐츠',
            style: AppTheme.of(context).headlineSmall,
          ),
        ],
      ),
      content: Text(
        '$reason\n다른 이미지를 선택해주세요.',
        style: AppTheme.of(context).bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context); // 경고 다이얼로그 닫기
            Navigator.pop(context); // 에디터 닫기
            Navigator.pop(context); // MediaSelectionFlowWidget 닫기
            
            // 검열 실패 시에만 모달 업 애니메이션으로 피커 열기
            if (onRetry != null) {
              onRetry!();
            } else {
              await _showAssetPickerWithAnimation(context);
            }
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
  
  /// 애니메이션과 함께 피커 다시 열기
  Future<void> _showAssetPickerWithAnimation(BuildContext context) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            '피커를 다시 여는 중...',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
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
      builder: (_) => ModerationErrorDialog(
        reason: reason,
        box: box,
        onRetry: onRetry,
      ),
    );
  }
}