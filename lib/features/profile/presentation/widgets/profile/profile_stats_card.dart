import 'package:flutter/material.dart';
import '/core_exports.dart';

/// 프로필 통계 카드 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - AppTheme 기반 일관된 디자인
/// - 포인트 및 통계 정보 표시
class ProfileStatsCard extends StatelessWidget {
  const ProfileStatsCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 아이콘
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),

            // 라벨
            Text(
              label,
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            // 값
            Text(
              value,
              style: AppTheme.of(context).headlineMedium.override(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// 프로필 포인트 카드 위젯
///
/// ProfileStatsCard의 특화 버전으로 A/Q 포인트 표시용
class ProfilePointsCard extends StatelessWidget {
  const ProfilePointsCard({
    super.key,
    required this.pointsA,
    required this.pointsQ,
  });

  final int pointsA;
  final int pointsQ;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ProfileStatsCard(
            label: 'A Points',
            value: pointsA.toString(),
            icon: Icons.emoji_events,
            color: AppTheme.of(context).primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ProfileStatsCard(
            label: 'Q Points',
            value: pointsQ.toString(),
            icon: Icons.question_answer,
            color: AppTheme.of(context).secondary,
          ),
        ),
      ],
    );
  }
}
