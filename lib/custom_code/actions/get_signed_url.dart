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

// getSignedUrl Custom Action

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<dynamic> getSignedUrl(String fileName, String contentType) async {
  // API 주소는 우리의 Cloud Run 서비스 URL로 설정합니다.
  final url =
      'https://encoder-636984750551.asia-northeast3.run.app/generate-upload-url';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fileName': fileName,
        'contentType': contentType,
      }),
    );

    if (response.statusCode == 200) {
      // 성공 시, {"signedUrl": "...", "gcsPath": "..."} 형태의 JSON 객체를 반환
      return jsonDecode(response.body);
    } else {
      // 실패 시 null 반환
      print(
          'Error getting signed URL [${response.statusCode}]: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception in getSignedUrl: $e');
    return null;
  }
}
