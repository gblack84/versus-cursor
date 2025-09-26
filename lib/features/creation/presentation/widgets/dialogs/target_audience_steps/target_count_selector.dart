import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/creation/domain/models/target_audience_model.dart';
import '/features/creation/domain/constants/target_audience_constants.dart';

/// Step 2: 목표 응답 수 설정
class TargetCountSelector extends StatelessWidget {
  final Function(int) onCountChanged;
  final Function(bool) onPremiumChanged;

  const TargetCountSelector({
    super.key,
    required this.onCountChanged,
    required this.onPremiumChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<TargetAudienceModel>(
      builder: (context, model, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(TargetAudienceConstants.contentPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '목표 응답 수를 설정하세요',
                style: AppTheme.of(context).headlineSmall.override(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // 목표 응답 수 섹션
              _buildTargetCountSection(context, model),

              const SizedBox(height: 24),

              // 예상 소요 시간 섹션
              _buildEstimatedTimeSection(context, model),

              const SizedBox(height: 24),

              // 프리미엄 옵션
              _buildPremiumOption(context, model),

              const SizedBox(height: 24),

              // 안내 메시지
              _buildInfoMessage(context),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTargetCountSection(
      BuildContext context, TargetAudienceModel model) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.of(context).alternate,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '목표 응답 수',
            style: AppTheme.of(context).bodyLarge.override(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),

          // 드롭다운
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.of(context).alternate,
              ),
            ),
            child: DropdownButton<int>(
              value: model.targetCount,
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
                  onCountChanged(value);
                }
              },
            ),
          ),

          const SizedBox(height: 16),

          // 빠른 선택 버튼들
          Row(
            children: TargetAudienceConstants.targetCountOptions.map((count) {
              final isSelected = model.targetCount == count;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: OutlinedButton(
                    onPressed: () {
                      debugPrint('[TargetCountSelector] 목표 응답 수 선택: $count');
                      onCountChanged(count);
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
      BuildContext context, TargetAudienceModel model) {
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
                style: AppTheme.of(context).bodyMedium.override(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            model.estimatedTime,
            style: AppTheme.of(context).headlineMedium.override(
                  color: AppTheme.of(context).primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumOption(BuildContext context, TargetAudienceModel model) {
    return InkWell(
      onTap: () {
        debugPrint('[TargetCountSelector] 프리미엄 옵션 토글: ${!model.isPremium}');
        onPremiumChanged(!model.isPremium);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: model.isPremium
              ? AppTheme.of(context).tertiary.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: model.isPremium
                ? AppTheme.of(context).tertiary
                : AppTheme.of(context).alternate,
            width: model.isPremium ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 체크박스
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: model.isPremium
                    ? AppTheme.of(context).tertiary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: model.isPremium
                      ? AppTheme.of(context).tertiary
                      : AppTheme.of(context).secondaryText,
                  width: 2,
                ),
              ),
              child: model.isPremium
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
                        style: AppTheme.of(context).bodyLarge.override(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '💎',
                        style: const TextStyle(fontSize: 18),
                      ),
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
              style: AppTheme.of(context).bodySmall.override(
                    color: AppTheme.of(context).primaryText,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
