import '/core/app_utils.dart';
import 'editvideo_p_widget.dart' show EditvideoPWidget;
import 'package:flutter/material.dart';

class EditvideoPModel extends AppModel<EditvideoPWidget> {
  ///  Local state fields for this page.

  AppUploadedFile? rawBytes;

  String? tempPath = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
