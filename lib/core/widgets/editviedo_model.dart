import '/core_exports.dart';
// Previous: /core/app_utils.dart';
import '/core/widgets/editviedo_widget.dart' show EditviedoWidget;
import 'package:flutter/material.dart';

class EditviedoModel extends AppModel<EditviedoWidget> {
  ///  Local state fields for this component.

  AppUploadedFile? uploadedVideo;

  double startSec = 0.0;

  double endSec = 60.0;

  ///  State fields for stateful widgets in this component.

  // State field(s) for Slider widget.
  double? sliderValue1;
  // State field(s) for Slider widget.
  double? sliderValue2;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
