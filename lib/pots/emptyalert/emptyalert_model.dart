import '/etc/vsmark/vsmark_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'emptyalert_widget.dart' show EmptyalertWidget;
import 'package:flutter/material.dart';

class EmptyalertModel extends FlutterFlowModel<EmptyalertWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for vsmark component.
  late VsmarkModel vsmarkModel;

  @override
  void initState(BuildContext context) {
    vsmarkModel = createModel(context, () => VsmarkModel());
  }

  @override
  void dispose() {
    vsmarkModel.dispose();
  }
}
