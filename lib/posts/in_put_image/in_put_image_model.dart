import '/core/app_utils.dart';
import 'in_put_image_widget.dart' show InPutImageWidget;
import 'package:flutter/material.dart';

class InPutImageModel extends AppModel<InPutImageWidget> {
  ///  State fields for stateful widgets in this component.

  bool isDataUploading_uploadImageG = false;
  List<AppUploadedFile> uploadedLocalFiles_uploadImageG = [];
  List<String> uploadedFileUrls_uploadImageG = [];

  bool isDataUploading_uploadImageC = false;
  AppUploadedFile uploadedLocalFile_uploadImageC =
      AppUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadImageC = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
