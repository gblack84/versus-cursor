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

// uploadToGCS Custom Action

import 'dart:io';
import 'package:http/http.dart' as http;

Future<bool> uploadToGCS(
  String signedUrl,
  String filePath,
  String contentType,
) async {
  try {
    final file = File(filePath);
    // 파일의 바이너리 데이터를 읽어옵니다.
    final fileBytes = await file.readAsBytes();

    // GCS가 발급해준 signedUrl을 목적지로 하여,
    // HTTP PUT 요청으로 파일 바이너리 데이터를 전송합니다.
    final response = await http.put(
      Uri.parse(signedUrl),
      headers: {'Content-Type': contentType},
      body: fileBytes,
    );

    // GCS는 성공 시 200 OK 응답을 보냅니다.
    if (response.statusCode == 200) {
      print('Successfully uploaded to GCS.');
      return true;
    } else {
      print(
          'Failed to upload to GCS [${response.statusCode}]: ${response.body}');
      return false;
    }
  } catch (e) {
    print('Exception in uploadToGCS: $e');
    return false;
  }
}
