import '/backend/backend.dart';
import '/core/app_utils.dart';
import 'upload_choice_bottom_sheet_widget.dart'
    show UploadChoiceBottomSheetWidget;
import 'package:flutter/material.dart';

class UploadChoiceBottomSheetModel
    extends AppModel<UploadChoiceBottomSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PostsRecord? newPost;
  // Stores action output result for [Custom Action - getVideoPath] action in Button widget.
  String? pickedVideoPath;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
