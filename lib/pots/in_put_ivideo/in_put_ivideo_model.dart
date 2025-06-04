import '/flutter_flow/flutter_flow_util.dart';
import 'in_put_ivideo_widget.dart' show InPutIvideoWidget;
import 'package:flutter/material.dart';

class InPutIvideoModel extends FlutterFlowModel<InPutIvideoWidget> {
  ///  Local state fields for this component.

  String mediamode = '\" \"';

  String youtubeurl = '\" \"';

  String embedurl = '\" \"';

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadVideoG = false;
  FFUploadedFile uploadedLocalFile_uploadVideoG =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadVideoG = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
