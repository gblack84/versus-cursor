import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'upload_choice_bottom_sheet_widget.dart'
    show UploadChoiceBottomSheetWidget;
import 'package:flutter/material.dart';

class UploadChoiceBottomSheetModel
    extends FlutterFlowModel<UploadChoiceBottomSheetWidget> {
  ///  State fields for stateful widgets in this component.

  // Stores action output result for [Custom Action - getVideoPath] action in Button widget.
  String? pickedVideoPath;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  PostsRecord? postDocRef;
  // Stores action output result for [Backend Call - Create Document] action in Button widget.
  VideoRecord? videoDocRef;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
