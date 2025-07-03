import '/etc/vsmark/vsmark_widget.dart';
import '/core/app_utils.dart';
import 'phonemaximum_widget.dart' show PhonemaximumWidget;
import 'package:flutter/material.dart';

class PhonemaximumModel extends AppModel<PhonemaximumWidget> {
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
