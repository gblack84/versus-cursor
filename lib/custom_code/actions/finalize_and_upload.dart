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

import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import 'package.flutter/material.dart';
// Begin custom widget code

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/backend/firebase_storage/storage.dart';
import '/backend/api_requests/api_calls.dart'; // FlutterFlow가 생성한 API 호출 함수 임포트
import 'package:uuid/uuid.dart';

Future finalizeAndUpload(
  BuildContext context,
  FFUploadedFile? editedCoverFile,
  String? originalVideoPath,
  int? startMs,
  int? endMs,
  String? postId, // 글쓰기 페이지에서 생성되어 전달된 Post ID
) async {
  // 1. 필수 값들이 모두 있는지 확인합니다.
  if (editedCoverFile?.bytes == null ||
      originalVideoPath == null ||
      startMs == null ||
      endMs == null ||
      postId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload failed: Missing required info.')),
    );
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // 2. 서버에 Signed URL을 요청합니다. (우리가 설정한 첫 번째 API Call)
    final getUrlResult = await GetUploadUrlCall.call(
      fileName: 'original_${Uuid().v4()}.mp4',
      contentType: 'video/mp4',
    );

    if (!getUrlResult.succeeded ||
        (getUrlResult.jsonBody as Map<String, dynamic>)['signedUrl'] == null) {
      throw Exception('Failed to get video upload URL from server.');
    }

    final videoSignedUrl =
        getJsonField(getUrlResult.jsonBody, r'''$.signedUrl''').toString();
    final videoGcsPath =
        getJsonField(getUrlResult.jsonBody, r'''$.gcsPath''').toString();

    // 3. 발급받은 URL을 이용해, 원본 비디오를 GCS에 직접 업로드합니다.
    final videoBytes = await File(originalVideoPath).readAsBytes();
    final videoUploadResponse = await http.put(
      Uri.parse(videoSignedUrl),
      headers: {'Content-Type': 'video/mp4'},
      body: videoBytes,
    );

    if (videoUploadResponse.statusCode != 200) {
      throw Exception(
          'Failed to upload original video to GCS. Status: ${videoUploadResponse.statusCode}');
    }
    print('✅ Original video uploaded to GCS: $videoGcsPath');

    // 4. 편집된 커버 이미지를 Firebase Storage에 업로드합니다.
    final coverUploadPath = 'posts/$postId/cover.jpg';
    final String? coverUrl = await uploadData(coverUploadPath, editedCoverFile);
    if (coverUrl == null) {
      throw Exception('Failed to upload cover image.');
    }
    print('✅ Cover image uploaded: $coverUrl');

    // 5. 서버에 최종 인코딩 작업을 요청합니다. (우리가 설정한 두 번째 API Call)
    final docId = const Uuid().v4();
    final ownerUid = currentUserUid ?? '';

    final encodeApiResult = await RequestEncodingCall.call(
      gcsPath: videoGcsPath,
      thumbUrl: coverUrl,
      postId: postId,
      docId: docId,
      ownerUid: ownerUid,
      startMs: startMs,
      endMs: endMs,
    );

    if (!encodeApiResult.succeeded) {
      throw Exception('Server job request failed: ${encodeApiResult.jsonBody}');
    }

    print('✅ Server job requested successfully!');

    // 6. 모든 작업 완료 후 처리
    Navigator.of(context, rootNavigator: true).pop(); // 로딩 인디케이터 숨기기
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload request completed!')),
    );
    Navigator.of(context)
        .popUntil((route) => route.isFirst); // 모든 편집기 페이지 닫고 홈으로 이동
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop(); // 오류 발생 시 로딩 인디케이터 숨기기
    print('❌ An error occurred during upload: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}
