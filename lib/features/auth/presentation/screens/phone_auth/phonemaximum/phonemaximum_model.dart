import '/core/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import 'phonemaximum_widget.dart' show PhonemaximumWidget;
import 'package:flutter/material.dart';

class PhonemaximumModel extends AppModel<PhonemaximumWidget> {
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
