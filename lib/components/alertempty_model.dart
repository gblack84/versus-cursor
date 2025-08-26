import '/etc/vsmark/vsmark_widget.dart';
import '/core_exports.dart';
// Previous: /core/app_utils.dart';
import 'alertempty_widget.dart' show AlertemptyWidget;
import 'package:flutter/material.dart';

class AlertemptyModel extends AppModel<AlertemptyWidget> {
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
