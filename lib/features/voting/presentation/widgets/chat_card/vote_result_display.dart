import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';

/// 투표 카드의 결과 표시 컴포넌트
///
/// 투표가 완료된 후 결과를 보러 오라는 메시지를 표시합니다.
class VoteResultDisplay extends StatelessWidget {
  final String? currentUserName;

  const VoteResultDisplay({
    super.key,
    this.currentUserName,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = currentUserName ?? '나';

    return Container(
      padding: const EdgeInsets.all(VersusSpacing.sm),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '피클! 피클! 피클!',
              style: TextStyle(
                fontSize: 18,
                color: VersusColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$displayName님 결과를 보러오세요!',
              style: TextStyle(
                fontSize: 14,
                color: VersusColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
