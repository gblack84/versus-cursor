import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/creation_providers.dart';
import '/features/creation/presentation/providers/target_audience_notifier.dart'
    show TargetAudience;
import '/features/creation/domain/constants/target_audience_constants.dart';
import '/features/creation/presentation/constants/target_audience_ui_constants.dart';

/// Step 3: 세부 타겟 설정 (맞춤 설정 선택 시) - Riverpod 3.x (Phase 2-7)
class DetailedTargetSelector extends ConsumerWidget {
  const DetailedTargetSelector({super.key});

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
            '타겟 조건을 설정하세요',
            style: AppTheme.of(
              context,
            ).headlineSmall.override(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 관심사 선택
          _buildInterestsSection(context, state, notifier),

          const SizedBox(height: 24),

          // 연령대 선택
          _buildAgeGroupSection(context, state, notifier),

          const SizedBox(height: 24),

          // 성별 선택
          _buildGenderSection(context, state, notifier),

          const SizedBox(height: 24),

          // 고급 옵션
          _buildAdvancedOptions(context, state, notifier),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '관심사 (복수 선택 가능)',
          style: AppTheme.of(
            context,
          ).bodyLarge.override(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.of(context).alternate),
          ),
          child: Wrap(
            spacing: TargetAudienceUIConstants.chipSpacing,
            runSpacing: TargetAudienceUIConstants.chipRunSpacing,
            children: TargetAudienceConstants.interests.map((interest) {
              final isSelected = state.selectedInterests.contains(interest);

              return FilterChip(
                label: Text(interest),
                selected: isSelected,
                onSelected: (_) {
                  debugPrint(
                    '[DetailedTargetSelector] 관심사 토글: $interest (현재: $isSelected)',
                  );
                  notifier.toggleInterest(interest);
                },
                selectedColor: AppTheme.of(context).primary,
                checkmarkColor: Colors.white,
                backgroundColor: AppTheme.of(context).secondaryBackground,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppTheme.of(context).primaryText,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppTheme.of(context).primary
                      : AppTheme.of(context).alternate,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildAgeGroupSection(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '연령대',
          style: AppTheme.of(
            context,
          ).bodyLarge.override(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: TargetAudienceConstants.ageGroups.entries.map((entry) {
            final isSelected = state.selectedAgeGroup == entry.key;

            return InkWell(
              onTap: () {
                debugPrint(
                  '[DetailedTargetSelector] 연령대 선택: ${entry.value} (${entry.key})',
                );
                notifier.setAgeGroup(entry.key);
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.of(context).primary
                      : AppTheme.of(context).secondaryBackground,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.of(context).primary
                        : AppTheme.of(context).alternate,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? Colors.white : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? Colors.white
                              : AppTheme.of(context).secondaryText,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.of(context).primary,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.of(context).primaryText,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenderSection(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '성별',
          style: AppTheme.of(
            context,
          ).bodyLarge.override(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: TargetAudienceConstants.genderOptions.entries.map((entry) {
            final isSelected = state.selectedGender == entry.key;
            final genderInfo = entry.value;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right:
                      entry.key !=
                          TargetAudienceConstants.genderOptions.keys.last
                      ? 8
                      : 0,
                ),
                child: InkWell(
                  onTap: () {
                    debugPrint(
                      '[DetailedTargetSelector] 성별 선택: ${entry.value} (${entry.key})',
                    );
                    notifier.setGender(entry.key);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.of(context).primary
                          : AppTheme.of(context).secondaryBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.of(context).primary
                            : AppTheme.of(context).alternate,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? Colors.white
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.white
                                  : AppTheme.of(context).secondaryText,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Container(
                                  margin: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.of(context).primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          genderInfo.label,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : AppTheme.of(context).primaryText,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdvancedOptions(
    BuildContext context,
    TargetAudienceState state,
    TargetAudience notifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.of(context).alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '고급 옵션',
            style: AppTheme.of(
              context,
            ).bodyLarge.override(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => notifier.setActiveUserOnly(!state.activeUserOnly),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: state.activeUserOnly
                          ? AppTheme.of(context).primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: state.activeUserOnly
                            ? AppTheme.of(context).primary
                            : AppTheme.of(context).secondaryText,
                        width: 2,
                      ),
                    ),
                    child: state.activeUserOnly
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: AppTheme.of(context).primaryBackground,
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '활성 사용자 우선',
                          style: AppTheme.of(
                            context,
                          ).bodyMedium.override(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '최근 1시간 이내 활동',
                          style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
