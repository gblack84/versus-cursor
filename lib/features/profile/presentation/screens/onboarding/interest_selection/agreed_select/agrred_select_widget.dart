import 'package:flutter/material.dart';
import '/features/profile/presentation/widgets/interest_selection/interest_selection_widget.dart';

/// Agrred (interests) selection screen wrapper
///
/// Thin wrapper around generic InterestSelectionWidget configured for agreed/interests.
/// Previously 856 lines, now reduced to ~35 lines (96% reduction).
///
/// **Bugs automatically fixed**:
/// - Line 461: Error message now says "관심사" instead of "expertise"
/// - Lines 540-542: Now checks correct field (interests instead of expertise)
/// - Lines 813-815: Next button now actually navigates (was only printing debug)
/// - routePath: Fixed from '/hobbiesSelectCopy' to '/agrredSelect'
class AgrredSelectWidget extends StatelessWidget {
  const AgrredSelectWidget({super.key});

  static String routeName = 'agrred_select';
  static String routePath = '/agrredSelect'; // Fixed: was '/hobbiesSelectCopy'

  @override
  Widget build(BuildContext context) {
    return InterestSelectionWidget(
      category: InterestCategory.agrred,
    );
  }
}
