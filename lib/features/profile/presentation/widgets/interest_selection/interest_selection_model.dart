import '/core_exports.dart';
import 'interest_selection_widget.dart' show InterestSelectionWidget;
import 'package:flutter/material.dart';

/// Generic model for interest selection screens
///
/// Replaces individual models for expertise, hobbies, and agrred screens
class InterestSelectionModel extends AppModel<InterestSelectionWidget> {
  ///  Local state fields for this page.

  /// Current input value in the text field
  String inputTag = '';

  ///  State fields for stateful widgets in this page.

  // State field(s) for input widget.
  FocusNode? inputFocusNode;
  TextEditingController? inputTextController;
  String? Function(BuildContext, String?)? inputTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    inputFocusNode?.dispose();
    inputTextController?.dispose();
  }
}
