import 'package:flutter/material.dart';
import '/features/profile/presentation/widgets/interest_selection/interest_selection_widget.dart';
import '/features/profile/presentation/widgets/interest_selection/interest_category.dart';

/// Expertise selection screen wrapper
///
/// Thin wrapper around generic InterestSelectionWidget configured for expertise.
/// Previously 867 lines, now reduced to ~35 lines (96% reduction).
class ExpertiseSelectWidget extends StatelessWidget {
  const ExpertiseSelectWidget({super.key});

  static String routeName = 'expertise_select';
  static String routePath = '/jopsSelect01';

  @override
  Widget build(BuildContext context) {
    return InterestSelectionWidget(
      category: InterestCategory.expertise,
    );
  }
}
