import '/features/common/presentation/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
// Previous: /core/app_utils.dart';
import '/features/common/presentation/widgets/alertempty_widget.dart' show AlertemptyWidget;
import 'package:flutter/material.dart';

class AlertemptyModel extends AppModel<AlertemptyWidget> {
  ///  State fields for stateful widgets in this component.

  // Model for pickle mark component.
  late PickleMarkModel pickleMarkModel;

  @override
  void initState(BuildContext context) {
    pickleMarkModel = createModel(context, () => PickleMarkModel());
  }

  @override
  void dispose() {
    pickleMarkModel.dispose();
  }
}
