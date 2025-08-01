import '/etc/vsmark/vsmark_widget.dart';
import '/core/app_utils.dart';
import '/index.dart';
import 'start_page_widget.dart' show StartPageWidget;
import 'package:flutter/material.dart';

class StartPageModel extends AppModel<StartPageWidget> {
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
