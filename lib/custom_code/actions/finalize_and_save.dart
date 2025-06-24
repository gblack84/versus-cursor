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
import 'dart:convert';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'package:http/http.dart' as http;
// ProcessingWaitView를 사용하기 위해 임포트
import '/custom_code/widgets/processing_wait_view.dart';

// 커버 이미지 업로드용 헬퍼 함수 (이것은 그대로 사용)
Future<String> uploadData(
    String storagePath, Uint8List data, String contentType) async {
  try {
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    final metadata = SettableMetadata(contentType: contentType);
    await ref.putData(data, metadata);
    return await ref.getDownloadURL();
  } catch (e) {
    print("Firebase Storage Upload failed: $e");
    throw Exception("Firebase Storage 업로드 실패: $e");
  }
}

Future finalizeAndSave(
  BuildContext context,
  String originalVideoPath,
  int trimStart,
  int trimEnd,
  int rotation,
  String cropData,
  int coverTimestamp,
  String finalCoverBytesBase64,
) async {
  // 로딩 인디케이터 표시
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: Colors.white),
          SizedBox(height: 16),
          Text("최종 저장 중...",
              style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ));
    },
  );

  try {
    // 0. 데이터 준비
    final Uint8List finalCoverBytes = base64Decode(finalCoverBytesBase64);
    final File videoFile = File(originalVideoPath);
    final Uint8List videoBytes = await videoFile.readAsBytes();
    final String videoFileName = path.basename(originalVideoPath);
    final ownerUid = currentUserUid;

    if (ownerUid == null || ownerUid.isEmpty) {
      throw Exception('사용자 인증 정보를 찾을 수 없습니다.');
    }

    // 1. [핵심] 백엔드에 비디오 업로드용 Signed URL 요청
    final signedUrlResponse = await http.post(
      Uri.parse(
          'https://encoder-636984750551.asia-northeast3.run.app/generate-upload-url'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'fileName': videoFileName, 'contentType': 'video/mp4'}),
    );

    if (signedUrlResponse.statusCode != 200) {
      throw Exception('Signed URL 요청 실패: ${signedUrlResponse.body}');
    }
    final urlData = jsonDecode(signedUrlResponse.body);
    final String signedUrl = urlData['signedUrl'];
    final String gcsPath = urlData['gcsPath']; // <- 서버 전달용 GCS 경로

    // 2. [핵심] 받은 URL로 대용량 비디오 파일 업로드
    final uploadResponse = await http.put(
      Uri.parse(signedUrl),
      headers: {'Content-Type': 'video/mp4'},
      body: videoBytes,
    );

    if (uploadResponse.statusCode != 200) {
      throw Exception('GCS 비디오 업로드 실패: ${uploadResponse.body}');
    }

    // 3. [핵심] 커버 이미지는 Firebase Storage로 직접 업로드
    final coverUploadPath = 'uploads/covers/$ownerUid/${Uuid().v4()}.jpg';
    final String thumbUrl =
        await uploadData(coverUploadPath, finalCoverBytes, 'image/jpeg');

    // 4. 최종 정보로 서버 /encode 호출
    final postId = Uuid().v4();
    final videoId = Uuid().v4();
    final encodeParams = {
      'gcsPath': gcsPath, // <- 이제 GCS 경로를 전달합니다.
      'thumbUrl': thumbUrl,
      'postId': postId,
      'docId': videoId,
      'ownerUid': ownerUid,
      'start_ms': trimStart,
      'end_ms': trimEnd,
      'rotate': rotation,
      'crop': cropData,
    };

    final encodeResponse = await http.post(
      Uri.parse('https://encoder-636984750551.asia-northeast3.run.app/encode'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(encodeParams),
    );

    if (encodeResponse.statusCode != 200) {
      throw Exception('서버 인코딩 요청 실패: ${encodeResponse.body}');
    }

    // 5. 대기 화면으로 이동
    final finalDocRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('video')
        .doc(videoId);

    Navigator.of(context).pop(); // 로딩 다이얼로그 닫기

    // [수정] 이전 페이지 스택을 유지하며 대기화면으로 이동
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ProcessingWaitView(videoDocRef: finalDocRef),
      ),
    );
  } catch (e) {
    Navigator.of(context).pop(); // 오류 시 로딩 다이얼로그 닫기
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('최종 저장 중 오류가 발생했습니다: $e')),
    );
  }
}
