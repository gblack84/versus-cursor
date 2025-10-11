import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/interest.dart';

/// 관심사 칩 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - Interest 도메인 모델 사용
/// - 선택 및 삭제 모드 지원
class InterestChip extends StatelessWidget {
  const InterestChip({
    super.key,
    required this.interest,
    this.selected = false,
    this.onSelected,
    this.onDeleted,
    this.showDeleteIcon = false,
  });

  final Interest interest;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onDeleted;
  final bool showDeleteIcon;

  @override
  Widget build(BuildContext context) {
    final chipColor = _getChipColor(context);

    if (showDeleteIcon && onDeleted != null) {
      return Chip(
        label: Text(interest.name),
        backgroundColor: chipColor,
        deleteIcon: Icon(
          Icons.close,
          size: 18,
          color: AppTheme.of(context).primaryText,
        ),
        onDeleted: onDeleted,
      );
    }

    if (onSelected != null) {
      return FilterChip(
        label: Text(interest.name),
        selected: selected,
        onSelected: onSelected,
        backgroundColor: AppTheme.of(context).secondaryBackground,
        selectedColor: chipColor,
        checkmarkColor: AppTheme.of(context).primaryText,
      );
    }

    return Chip(
      label: Text(interest.name),
      backgroundColor: chipColor,
    );
  }

  Color _getChipColor(BuildContext context) {
    switch (interest.category) {
      case 'expertise':
        return AppTheme.of(context).primary.withValues(alpha: 0.2);
      case 'hobby':
        return AppTheme.of(context).secondary.withValues(alpha: 0.2);
      default:
        return AppTheme.of(context).secondaryBackground;
    }
  }
}
