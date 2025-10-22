import 'package:flutter/material.dart';
import '/features/profile/presentation/widgets/interest_selection/interest_selection_widget.dart';

/// Hobbies selection screen wrapper
///
/// Thin wrapper around generic InterestSelectionWidget configured for hobbies.
/// Previously 856 lines, now reduced to ~35 lines (96% reduction).
///
/// **Bugs automatically fixed**:
/// - Line 461: Error message now says "hobbies" instead of "expertise"
/// - Lines 540-542: Now checks correct field (interests instead of expertise)
class HobbiesSelectWidget extends StatelessWidget {
  const HobbiesSelectWidget({super.key});

  static String routeName = 'hobbies_select';
  static String routePath = '/hobbiesSelect';

  @override
  Widget build(BuildContext context) {
    return InterestSelectionWidget(
      category: InterestCategory.hobbies,
    );
  }
}
