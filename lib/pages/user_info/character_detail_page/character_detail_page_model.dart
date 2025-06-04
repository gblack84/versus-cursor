import '/flutter_flow/flutter_flow_util.dart';
import 'character_detail_page_widget.dart' show CharacterDetailPageWidget;
import 'package:flutter/material.dart';

class CharacterDetailPageModel
    extends FlutterFlowModel<CharacterDetailPageWidget> {
  ///  Local state fields for this component.

  String selectedCharacterUrl = '\" \"';

  ///  State fields for stateful widgets in this component.

  bool isDataUploading_userUploadProfileImage = false;
  FFUploadedFile uploadedLocalFile_userUploadProfileImage =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_userUploadProfileImage = '';

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
