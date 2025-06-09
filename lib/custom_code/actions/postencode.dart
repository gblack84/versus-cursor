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

import 'package:http/http.dart' as http;
import 'dart:convert';

/// pathMp4  : 로컬 MP4 파일 경로
/// paramsJsonEncodins : JSON 문자열( {start_ms, end_ms, rotate, crop …} )
///
/// 성공하면 Cloud Run 이 돌려준 결과 JSON 문자열(String)을,
/// 실패(400/500) 또는 예외가 나면 null 을 반환합니다.
Future<String?> postencode(
  String pathMp4,
  String paramsJsonEncodins,
) async {
  try {
    // 1) JSON → Map
    final Map<String, dynamic> params =
        jsonDecode(paramsJsonEncodins) as Map<String, dynamic>;

    // 2) multipart/form-data POST /encode
    final req = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://encoder-636984750551.asia-northeast3.run.app/encode',
      ),
    )
      ..files.add(
        await http.MultipartFile.fromPath('file', pathMp4),
      )
      ..fields.addAll(
        params.map((k, v) => MapEntry(k, v.toString())),
      );

    // 3) 전송 & 결과 해석
    final res = await req.send();
    final bodyString = await res.stream.bytesToString();

    // 4) HTTP 200 → JSON 문자열 반환, 그 외 → null
    if (res.statusCode == 200) {
      // 서버 응답 전체를 JSON 문자열로 반환
      return bodyString;
    } else {
      // 실패 시 null 반환
      print('postencode failed with status ${res.statusCode}: $bodyString');
      return null;
    }
  } catch (e) {
    print('Exception in postencode: $e');
    return null;
  }
}
