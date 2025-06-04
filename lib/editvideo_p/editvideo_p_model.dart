import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'editvideo_p_widget.dart' show EditvideoPWidget;
import 'package:flutter/material.dart';

class EditvideoPModel extends FlutterFlowModel<EditvideoPWidget> {
  ///  Local state fields for this page.

  FFUploadedFile? rawBytes;

  String? tempPath = '';

  ///  State fields for stateful widgets in this page.

  bool isDataUploading_pickedFile = false;
  FFUploadedFile uploadedLocalFile_pickedFile =
      FFUploadedFile(bytes: Uint8List.fromList([]));

  // Stores action output result for [Custom Action - bytesToTempPath] action in Button widget.
  String? tempPathOutput;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
