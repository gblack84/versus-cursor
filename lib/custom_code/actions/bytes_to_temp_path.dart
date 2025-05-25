// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> bytesToTempPath(FFUploadedFile file) async {
  if (file.bytes == null) {
    throw Exception('Video bytes are null');
  }

  // 임시 디렉터리 결정
  final dir = await getTemporaryDirectory();
  final filename =
      file.name ?? 'video_${DateTime.now().millisecondsSinceEpoch}.mp4';
  final fullPath = '${dir.path}/$filename';

  // Bytes → 파일 저장
  final f = File(fullPath);
  await f.writeAsBytes(file.bytes!);

  // 경로 반환
  return fullPath;
}
