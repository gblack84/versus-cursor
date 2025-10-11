import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/interest.dart';
import 'interest_chip.dart';

/// 관심사 카테고리 그리드 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - Interest 도메인 모델 사용
/// - 카테고리별 관심사 그룹화 표시
class InterestCategoryGrid extends StatelessWidget {
  const InterestCategoryGrid({
    super.key,
    required this.category,
    required this.interests,
    this.selectedInterests = const [],
    this.onInterestSelected,
    this.maxSelection,
  });

  final String category;
  final List<Interest> interests;
  final List<String> selectedInterests;
  final ValueChanged<Interest>? onInterestSelected;
  final int? maxSelection;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 카테고리 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Text(
                _getCategoryTitle(context),
                style: AppTheme.of(context).headlineSmall.override(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              if (maxSelection != null) ...[
                const SizedBox(width: 8),
                Text(
                  '(${selectedInterests.length}/$maxSelection)',
                  style: AppTheme.of(context).bodySmall.override(
                        color: AppTheme.of(context).secondaryText,
                      ),
                ),
              ],
            ],
          ),
        ),

        // 관심사 그리드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = selectedInterests.contains(interest.id);
              final canSelect = maxSelection == null ||
                  selectedInterests.length < maxSelection! ||
                  isSelected;

              return InterestChip(
                interest: interest,
                selected: isSelected,
                onSelected: canSelect && onInterestSelected != null
                    ? (selected) {
                        if (selected) {
                          onInterestSelected!(interest);
                        } else {
                          // 선택 해제는 별도 로직 필요
                        }
                      }
                    : null,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _getCategoryTitle(BuildContext context) {
    switch (category) {
      case 'expertise':
        return AppLocalizations.of(context).getText('expertise' /* 전문분야 */);
      case 'hobby':
        return AppLocalizations.of(context).getText('hobbies' /* 취미 */);
      default:
        return category;
    }
  }
}
