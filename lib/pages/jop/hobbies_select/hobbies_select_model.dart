import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'hobbies_select_widget.dart' show HobbiesSelectWidget;
import 'package:flutter/material.dart';

class HobbiesSelectModel extends FlutterFlowModel<HobbiesSelectWidget> {
  ///  Local state fields for this page.

  String hobbiesTag = '';

  ///  State fields for stateful widgets in this page.

  // State field(s) for hobbies widget.
  FocusNode? hobbiesFocusNode;
  TextEditingController? hobbiesTextController;
  String? Function(BuildContext, String?)? hobbiesTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    hobbiesFocusNode?.dispose();
    hobbiesTextController?.dispose();
  }
}
