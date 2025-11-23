import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/creation_providers.dart';
import '/features/creation/presentation/providers/target_audience_notifier.dart'
    show TargetAudience;
import '/features/creation/domain/constants/target_audience_constants.dart';
import '/features/creation/presentation/constants/target_audience_ui_constants.dart';

/// Step 2: 목표 응답 수 설정
class TargetCountSelector extends ConsumerWidget {
  const TargetCountSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(targetAudienceProvider);
    final notifier = ref.read(targetAudienceProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TargetAudienceUIConstants.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '목표 응답 수를 설정하세요',
            style: AppTheme.of(
              context,
            ).headlineSmall.override(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 목표 응답 수 섹션
          _buildTargetCountSection(context, state, notifier),

          const SizedBox(height: 24),

          // 예상 소요 시간 섹션
          _buildEstimatedTimeSection(context, state),

          const SizedBox(height: 24),

          // 프리미엄 옵션
          _buildPremiumOption(context, state, notifier),

          const SizedBox(height: 24),

          // 안내 메시지
          _buildInfoMessage(context),
        ],
      ),
    );
  }

  Widget _buildTargetCountSection(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.of(context).alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '목표 응답 수',
            style: AppTheme.of(
              context,
            ).bodyLarge.override(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),

          // 드롭다운
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.of(context).alternate),
            ),
            child: DropdownButton<int>(
              value: state.targetCount,
              isExpanded: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: AppTheme.of(context).primaryText,
              ),
              items: TargetAudienceConstants.targetCountOptions.map((count) {
                return DropdownMenuItem<int>(
                  value: count,
                  child: Text(
                    '$count명',
                    style: AppTheme.of(context).bodyMedium,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.setTargetCount(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // 빠른 선택 버튼들
          Row(
            children: TargetAudienceConstants.targetCountOptions.map((count) {
              final isSelected = state.targetCount == count;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () {
                      debugPrint('[TargetCountSelector] 목표 응답 수 선택: $count');
                      notifier.setTargetCount(count);
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected
                          ? AppTheme.of(context).primary
                          : Colors.transparent,
                      side: BorderSide(
                        color: isSelected
                            ? AppTheme.of(context).primary
                            : AppTheme.of(context).alternate,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      '$count',
                      style: AppTheme.of(context).bodySmall.override(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.of(context).primaryText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimatedTimeSection(
    BuildContext context,
    TargetAudienceState state,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).accent1.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time,
                size: 20,
                color: AppTheme.of(context).primary,
              ),
              const SizedBox(width: 8),
              Text(
                '예상 소요 시간',
                style: AppTheme.of(
                  context,
                ).bodyMedium.override(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            state.estimatedTime,
            style: AppTheme.of(context).headlineMedium.override(
              color: AppTheme.of(context).primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumOption(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return InkWell(
      onTap: () {
        debugPrint('[TargetCountSelector] 프리미엄 옵션 토글: ${!state.isPremium}');
        notifier.setIsPremium(!state.isPremium);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: state.isPremium
              ? AppTheme.of(context).tertiary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.isPremium
                ? AppTheme.of(context).tertiary
                : AppTheme.of(context).alternate,
            width: state.isPremium ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: state.isPremium
                    ? AppTheme.of(context).tertiary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: state.isPremium
                      ? AppTheme.of(context).tertiary
                      : AppTheme.of(context).secondaryText,
                  width: 2,
                ),
              ),
              child: state.isPremium
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.of(context).primaryBackground,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '빠른 수집 모드',
                        style: AppTheme.of(
                          context,
                        ).bodyLarge.override(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 8),
                      Text('💎', style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '5분 내 완료 보장',
                    style: AppTheme.of(context).bodySmall.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '(프리미엄 기능)',
                    style: AppTheme.of(context).labelSmall.override(
                      color: AppTheme.of(context).tertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoMessage(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: AppTheme.of(context).info,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '활성 사용자가 많은 시간대에는 더 빠르게 수집됩니다',
              style: AppTheme.of(
                context,
              ).bodySmall.override(color: AppTheme.of(context).primaryText),
            ),
          ),
        ],
      ),
    );
  }
}
