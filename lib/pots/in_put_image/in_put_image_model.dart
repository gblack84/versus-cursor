import '/flutter_flow/flutter_flow_util.dart';
import 'in_put_image_widget.dart' show InPutImageWidget;
import 'package:flutter/material.dart';

class InPutImageModel extends FlutterFlowModel<InPutImageWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading1 = false;
  List<FFUploadedFile> uploadedLocalFiles1 = [];
  List<String> uploadedFileUrls1 = [];

  bool isDataUploading2 = false;
  FFUploadedFile uploadedLocalFile2 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl2 = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
