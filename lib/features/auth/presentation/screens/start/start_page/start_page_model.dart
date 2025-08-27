import '/features/common/presentation/widgets/pickle_mark/pickle_mark_widget.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'start_page_widget.dart' show StartPageWidget;
import 'package:flutter/material.dart';

class StartPageModel extends AppModel<StartPageWidget> {
  ///  State fields for stateful widgets in this page.

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
