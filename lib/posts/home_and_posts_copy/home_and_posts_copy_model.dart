import '/core/app_utils.dart';
import 'home_and_posts_copy_widget.dart' show HomeAndPostsCopyWidget;
import 'package:flutter/material.dart';

class HomeAndPostsCopyModel extends AppModel<HomeAndPostsCopyWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for PageView widget.
  PageController? pageViewController1;

  int get pageViewCurrentIndex1 => pageViewController1 != null &&
          pageViewController1!.hasClients &&
          pageViewController1!.page != null
      ? pageViewController1!.page!.round()
      : 0;
  // State field(s) for PageView widget.
  PageController? pageViewController2;

  int get pageViewCurrentIndex2 => pageViewController2 != null &&
          pageViewController2!.hasClients &&
          pageViewController2!.page != null
      ? pageViewController2!.page!.round()
      : 0;
  bool isDataUploading_uploadDataTix = false;
  AppUploadedFile uploadedLocalFile_uploadDataTix =
      AppUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataTix = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
