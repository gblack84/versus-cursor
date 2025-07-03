// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import 'index.dart'; // Imports other custom actions
import '/core/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:image_picker/image_picker.dart';

Future<String?> getVideoPath(String source) async {
  final picker = ImagePicker();
  ImageSource imageSource;

  // 파라미터로 'camera'가 들어오면 카메라를, 그렇지 않으면 갤러리를 엽니다.
  if (source == 'camera') {
    imageSource = ImageSource.camera;
  } else {
    imageSource = ImageSource.gallery;
  }

  final XFile? video = await picker.pickVideo(source: imageSource);

  if (video != null) {
    // 촬영 또는 선택된 영상의 원본 경로를 반환합니다.
    return video.path;
  }

  return null;
}
