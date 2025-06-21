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

// generateCoverImage Custom Action (수정된 최종본)

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> generateCoverImage(
  String gcsPath, // GCS 경로를 받도록 수정
  String docId,
  int coverTimestampMs,
  String? overlayText,
) async {
  final url =
      'https://encoder-636984750551.asia-northeast3.run.app/generate-cover';

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'gcsPath': gcsPath, // gcsPath를 전송
        'docId': docId,
        'cover_timestamp_ms': coverTimestampMs,
        'overlay_text': overlayText ?? '',
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['thumbUrl'];
    }
    print(
        'generateCoverImage failed with status ${response.statusCode}: ${response.body}');
    return null;
  } catch (e) {
    print('Exception in generateCoverImage: $e');
    return null;
  }
}
