// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'package:ff_theme/flutter_flow/flutter_flow_theme.dart';
import '/custom_code/widgets/index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '/backend/firebase_storage/storage.dart';
import '/backend/api_requests/api_calls.dart';
import 'package:uuid/uuid.dart';
import '/auth/firebase_auth/auth_util.dart'; // currentUserUid를 위해 추가
import 'package:path/path.dart' as path;
import '/custom_code/widgets/processing_wait_view.dart'; // 대기 화면 위젯 임포트

Future finalizeAndUpload(
  BuildContext context,
  FFUploadedFile? editedCoverFile,
  String? originalVideoPath,
  int? startMs,
  int? endMs,
  String? postId,
) async {
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
    final videoFileName = path.basename(originalVideoPath);

    // API Call 그룹의 이름과 파라미터 이름을 FlutterFlow에서 정의한 것과 일치시킵니다.
    final getUrlResult = await GetUploadUrlCall.call();

    if (!getUrlResult.succeeded ||
        getJsonField(getUrlResult.jsonBody, r'''$.signedUrl''') == null) {
      throw Exception('Failed to get video upload URL from server.');
    }

    final videoSignedUrl =
        getJsonField(getUrlResult.jsonBody, r'''$.signedUrl''').toString();
    final videoGcsPath =
        getJsonField(getUrlResult.jsonBody, r'''$.gcsPath''').toString();

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

    // uploadData 헬퍼 함수를 직접 사용하지 않고 Firebase Storage에 직접 업로드합니다.
    final coverUploadPath = 'posts/$postId/cover.jpg';
    final ref = FirebaseStorage.instance.ref().child(coverUploadPath);
    final metadata = SettableMetadata(contentType: 'image/jpeg');
    await ref.putData(editedCoverFile.bytes!, metadata);
    final String coverUrl = await ref.getDownloadURL();

    print('✅ Cover image uploaded: $coverUrl');

    final docId = const Uuid().v4();
    final ownerUid = currentUserUid;

    // API Call 그룹의 이름과 파라미터 이름을 FlutterFlow에서 정의한 것과 일치시킵니다.
    final encodeApiResult = await RequestEncodingCall.call();

    if (!encodeApiResult.succeeded) {
      throw Exception('Server job request failed: ${encodeApiResult.jsonBody}');
    }

    print('✅ Server job requested successfully!');

    // 인코딩 상태를 확인할 문서 참조 생성
    final videoDocRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('video')
        .doc(docId);

    Navigator.of(context, rootNavigator: true).pop(); // 로딩 인디케이터 숨기기

    // 대기 화면으로 이동
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingWaitView(videoDocRef: videoDocRef),
      ),
    );
  } catch (e) {
    Navigator.of(context, rootNavigator: true).pop();
    print('❌ An error occurred during upload: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('An error occurred: $e')),
    );
  }
}
