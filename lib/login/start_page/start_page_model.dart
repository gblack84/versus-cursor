import '/etc/vsmark/vsmark_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'start_page_widget.dart' show StartPageWidget;
import 'package:flutter/material.dart';

class StartPageModel extends FlutterFlowModel<StartPageWidget> {
  ///  State fields for stateful widgets in this page.

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
