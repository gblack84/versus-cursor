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

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/widgets/processing_wait_view.dart';

// UI에서 생성된 파라미터 시그니처와 정확히 일치합니다.
Future finalizeAndUpload(
  BuildContext context,
  FFUploadedFile? editedCoverFile,
  String? originalVideoPath,
  int? startMs,
  int? endMs,
  String? postId,
  Future Function(String fileName) getUploadUrlAction,
  Future Function(String gcsPath, String thumbUrl, String postId, String docId,
          String ownerUid, int startMs, int endMs)
      requestEncodingAction,
) async {
  // 사용자가 Nullable로 설정했으므로, null 체크 로직을 다시 추가합니다.
  if (editedCoverFile == null ||
      editedCoverFile.bytes == null ||
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

    // [최종 수정] getUploadUrlAction 호출 시, 정의된 파라미터인 fileName만 전달합니다.
    final getUrlResult = await getUploadUrlAction(
      videoFileName,
    );

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

    final coverUploadPath = 'posts/$postId/cover.jpg';
    final ref = FirebaseStorage.instance.ref().child(coverUploadPath);
    final metadata = SettableMetadata(contentType: 'image/jpeg');

    await ref.putData(editedCoverFile.bytes!);
    final String coverUrl = await ref.getDownloadURL();

    print('✅ Cover image uploaded: $coverUrl');

    final docId = const Uuid().v4();
    final ownerUid = currentUserUid;

    // requestEncodingAction 호출 시, 정의된 모든 파라미터를 순서대로 전달합니다.
    final encodeApiResult = await requestEncodingAction(
      videoGcsPath,
      coverUrl,
      postId,
      docId,
      ownerUid,
      startMs,
      endMs,
    );

    if (!encodeApiResult.succeeded) {
      throw Exception('Server job request failed: ${encodeApiResult.jsonBody}');
    }

    print('✅ Server job requested successfully!');

    final videoDocRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('video')
        .doc(docId);

    Navigator.of(context, rootNavigator: true).pop(); // 로딩 인디케이터 숨기기

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
