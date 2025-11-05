import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/creation_providers.dart';
import '/features/creation/domain/constants/target_audience_constants.dart';
import '/features/creation/presentation/constants/target_audience_ui_constants.dart';

/// Step 1: 수집 방식 선택 - Riverpod 3.x (Phase 2-7)
class CollectionTypeSelector extends ConsumerWidget {
  const CollectionTypeSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(targetAudienceProvider);
    final notifier = ref.read(targetAudienceProvider.notifier);

    // 모든 타입 표시
    final availableTypes =
        TargetAudienceConstants.collectionTypes.entries.toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(TargetAudienceUIConstants.contentPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '투표 수집 방식을 선택하세요',
            style: AppTheme.of(context).headlineSmall.override(
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // 수집 방식 옵션들
          ...availableTypes.map((entry) {
            final typeInfo = entry.value;
            final isSelected = state.collectionType == typeInfo.id;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildTypeOption(
                context: context,
                typeInfo: typeInfo,
                isSelected: isSelected,
                onTap: () {
                  debugPrint(
                      '[CollectionTypeSelector] 수집 방식 선택: ${typeInfo.id}');
                  debugPrint(
                      '[CollectionTypeSelector]   - 제목: ${typeInfo.title}');
                  debugPrint(
                      '[CollectionTypeSelector]   - 설명: ${typeInfo.subtitle}');
                  notifier.setCollectionType(typeInfo.id);
                },
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildTypeOption({
    required BuildContext context,
    required CollectionTypeInfo typeInfo,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primary.withValues(alpha: 0.1)
              : AppTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppTheme.of(context).primary
                : AppTheme.of(context).alternate,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.of(context).primary.withValues(alpha: 0.2)
                    : AppTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  typeInfo.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        typeInfo.title,
                        style: AppTheme.of(context).bodyLarge.override(
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? AppTheme.of(context).primary
                                  : AppTheme.of(context).primaryText,
                            ),
                      ),
                      if (typeInfo.description.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.of(context).accent1,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            typeInfo.description,
                            style: AppTheme.of(context).bodySmall.override(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    typeInfo.subtitle,
                    style: AppTheme.of(context).bodySmall.override(
                          color: AppTheme.of(context).secondaryText,
                        ),
                  ),
                ],
              ),
            ),

            // 선택 표시
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.of(context).primary
                      : AppTheme.of(context).secondaryText,
                  width: 2,
                ),
                color: isSelected
                    ? AppTheme.of(context).primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 16,
                      color: AppTheme.of(context).primaryBackground,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
