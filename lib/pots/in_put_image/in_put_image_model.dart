import '/flutter_flow/flutter_flow_util.dart';
import 'in_put_image_widget.dart' show InPutImageWidget;
import 'package:flutter/material.dart';

class InPutImageModel extends FlutterFlowModel<InPutImageWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadImageG = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadImageG = [];
  List<String> uploadedFileUrls_uploadImageG = [];

  bool isDataUploading_uploadImageC = false;
  FFUploadedFile uploadedLocalFile_uploadImageC =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadImageC = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
