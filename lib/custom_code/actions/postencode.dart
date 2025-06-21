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

// postencode Custom Action (수정된 최종본)

import 'dart:convert';
import 'package:http/http.dart' as http;

Future<String?> postencode(
  String gcsPath, // 이제 GCS 경로를 받습니다.
  String paramsJsonEncodins,
) async {
  // API 주소는 우리의 Cloud Run 서비스 URL입니다.
  final url = 'https://encoder-636984750551.asia-northeast3.run.app/encode';

  try {
    // 1. 기존 파라미터(자르기, 회전 등)를 Map으로 변환
    final Map<String, dynamic> params = jsonDecode(paramsJsonEncodins);

    // 2. 서버에 보낼 최종 JSON 본문을 만듭니다.
    // 기존 파라미터에 gcsPath를 추가합니다.
    final body = {
      ...params, // 기존 파라미터를 모두 포함
      'gcsPath': gcsPath, // gcsPath 필드 추가
    };

    // 3. 서버에 JSON 형식으로 POST 요청을 보냅니다.
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body), // 완성된 JSON 본문을 전송
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      print(
          'postencode failed with status ${response.statusCode}: ${response.body}');
      return null;
    }
  } catch (e) {
    print('Exception in postencode: $e');
    return null;
  }
}
