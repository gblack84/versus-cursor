import '/core_exports.dart';
import 'pro_image_editor_page.dart' show ProImageEditorPage;
import 'package:flutter/material.dart';

class ProImageEditorModel extends AppModel<ProImageEditorPage> {
  /// State fields for stateful widgets in this page.

  // 이미지 업로드 중 상태
  bool isUploading = false;

  // 업로드 진행률
  double uploadProgress = 0.0;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
