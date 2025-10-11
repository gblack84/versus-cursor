import 'package:flutter/material.dart';
import '/core_exports.dart';
import '/features/profile/domain/models/interest.dart';
import 'interest_category_grid.dart';

/// 관심사 선택 바텀시트 위젯
///
/// **Clean Architecture v4.0 준수**:
/// - 재사용 가능한 UI 컴포넌트
/// - Interest 도메인 모델 사용
/// - 카테고리별 관심사 선택 지원
class InterestSelectionBottomSheet extends StatefulWidget {
  const InterestSelectionBottomSheet({
    super.key,
    required this.category,
    required this.availableInterests,
    required this.selectedInterests,
    this.maxSelection,
    this.onConfirm,
  });

  final String category;
  final List<Interest> availableInterests;
  final List<String> selectedInterests;
  final int? maxSelection;
  final ValueChanged<List<Interest>>? onConfirm;

  @override
  State<InterestSelectionBottomSheet> createState() =>
      _InterestSelectionBottomSheetState();

  /// 바텀시트 표시 헬퍼 메서드
  static Future<List<Interest>?> show({
    required BuildContext context,
    required String category,
    required List<Interest> availableInterests,
    required List<String> selectedInterests,
    int? maxSelection,
  }) {
    return showModalBottomSheet<List<Interest>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.of(context).primaryBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => InterestSelectionBottomSheet(
        category: category,
        availableInterests: availableInterests,
        selectedInterests: selectedInterests,
        maxSelection: maxSelection,
      ),
    );
  }
}

class _InterestSelectionBottomSheetState
    extends State<InterestSelectionBottomSheet> {
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedInterests);
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.of(context).secondaryText,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 컨텐츠
            Expanded(
              child: ListView(
                controller: scrollController,
                children: [
                  InterestCategoryGrid(
                    category: widget.category,
                    interests: widget.availableInterests,
                    selectedInterests: _selectedIds,
                    maxSelection: widget.maxSelection,
                    onInterestSelected: _toggleInterest,
                  ),
                ],
              ),
            ),

            // 확인 버튼
            Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.of(context).primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).getText('confirm' /* 확인 */),
                    style: AppTheme.of(context).bodyLarge.override(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _toggleInterest(Interest interest) {
    setState(() {
      if (_selectedIds.contains(interest.id)) {
        _selectedIds.remove(interest.id);
      } else {
        if (widget.maxSelection == null ||
            _selectedIds.length < widget.maxSelection!) {
          _selectedIds.add(interest.id);
        }
      }
    });
  }

  void _confirm() {
    final selectedInterests = widget.availableInterests
        .where((interest) => _selectedIds.contains(interest.id))
        .toList();

    if (widget.onConfirm != null) {
      widget.onConfirm!(selectedInterests);
    }

    Navigator.of(context).pop(selectedInterests);
  }
}
