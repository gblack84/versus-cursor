import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 이미지 검열 중 표시되는 다이얼로그
class ModerationDialog extends StatelessWidget {
  final int currentIndex;
  final int totalCount;

  const ModerationDialog({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 뒤로가기 방지
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
              const SizedBox(height: 20),
              Text(
                '안전성 검사 중...',
                style: AppTheme.of(context).bodyLarge.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              if (totalCount > 1) ...[
                const SizedBox(height: 8),
                Text(
                  '$currentIndex/$totalCount 검열 중',
                  style: AppTheme.of(context).bodyMedium.override(
                        color: Colors.white70,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 다이얼로그 표시 헬퍼 메서드
  static void show({
    required BuildContext context,
    required int currentIndex,
    required int totalCount,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ModerationDialog(
        currentIndex: currentIndex,
        totalCount: totalCount,
      ),
    );
  }
}
