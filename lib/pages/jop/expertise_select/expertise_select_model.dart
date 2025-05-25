import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'expertise_select_widget.dart' show ExpertiseSelectWidget;
import 'package:flutter/material.dart';

class ExpertiseSelectModel extends FlutterFlowModel<ExpertiseSelectWidget> {
  ///  Local state fields for this page.

  String expertiseTag = '';

  ///  State fields for stateful widgets in this page.

  // State field(s) for expertise widget.
  FocusNode? expertiseFocusNode;
  TextEditingController? expertiseTextController;
  String? Function(BuildContext, String?)? expertiseTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    expertiseFocusNode?.dispose();
    expertiseTextController?.dispose();
  }
}
