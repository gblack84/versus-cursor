import '/backend/backend.dart';
import '/core/app_utils.dart';
import 'testalgoria_widget.dart' show TestalgoriaWidget;
import 'package:flutter/material.dart';

class TestalgoriaModel extends AppModel<TestalgoriaWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  // Algolia Search Results from action on IconButton
  List<JopsCategoryRecord>? algoliaSearchResults = [];

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }
}
