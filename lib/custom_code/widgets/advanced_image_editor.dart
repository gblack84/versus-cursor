// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import 'index.dart'; // Imports other custom widgets
import '/custom_code/actions/index.dart'; // Imports custom actions
import '/core/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'index.dart';
import '/core/custom_functions.dart';

import 'dart:async'; // 비동기 스트림을 위해 추가
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;
import 'package:pro_image_editor/pro_image_editor.dart';
import '/app_state.dart';
import '/auth/firebase_auth/auth_util.dart';

class AdvancedImageEditor extends StatefulWidget {
  const AdvancedImageEditor({Key? key, this.width, this.height})
      : super(key: key);
  final double? width;
  final double? height;

  @override
  _AdvancedImageEditorState createState() => _AdvancedImageEditorState();
}

class _AdvancedImageEditorState extends State<AdvancedImageEditor> {
  Uint8List? _imageBytes;
  bool _isLoading = false; // 로딩 오버레이 표시 여부
  String _statusText = ""; // 로딩 시 표시될 텍스트
  StreamSubscription? _firestoreSubscription; // Firestore 리스너

  @override
  void initState() {
    super.initState();
    if (AppState().uploadCoverBytes.isNotEmpty) {
      try {
        _imageBytes = base64Decode(AppState().uploadCoverBytes);
      } catch (e) {
        print('Error decoding base64 image: $e');
      }
    }
  }

  @override
  void dispose() {
    // 위젯이 제거될 때 Firestore 리스너를 반드시 취소하여 메모리 누수를 방지합니다.
    _firestoreSubscription?.cancel();
    super.dispose();
  }

  // [핵심 로직] 모든 업로드 및 인코딩 과정을 처리하는 내부 함수
  Future<void> _processAndUpload(Uint8List editedCoverBytes) async {
    // --- App State에서 모든 필요 데이터 가져오기 ---
    final originalVideoPath = AppState().uploadVideoPath;
    final postId = AppState().uploadPostId;
    final startMs = AppState().uploadStartMs.toInt();
    final endMs = AppState().uploadEndMs.toInt();

    if (originalVideoPath.isEmpty || postId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('필수 정보가 없습니다.')));
      return;
    }

    // --- UI를 로딩 상태로 변경 ---
    setState(() {
      _isLoading = true;
      _statusText = "업로드 준비 중...";
    });

    try {
      // --- 1. Signed URL 요청 ---
      setState(() => _statusText = "보안 업로드 URL 요청 중...");
      final videoFileName = path.basename(originalVideoPath);
      const getUploadUrlEndpoint =
          'https://encoder-636984750551.asia-northeast3.run.app/generate-upload-url';
      final getUploadUrlResponse = await http.post(
          Uri.parse(getUploadUrlEndpoint),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(
              {'fileName': videoFileName, 'contentType': 'video/mp4'}));
      if (getUploadUrlResponse.statusCode != 200)
        throw Exception('업로드 URL 생성 실패');
      final getUrlResultBody = jsonDecode(getUploadUrlResponse.body);
      final videoSignedUrl = getUrlResultBody['signedUrl'] as String;
      final videoGcsPath = getUrlResultBody['gcsPath'] as String;

      // --- 2. GCS에 영상 업로드 ---
      setState(() => _statusText = "영상 업로드 중...");
      final videoBytes = await File(originalVideoPath).readAsBytes();
      final videoUploadResponse = await http.put(Uri.parse(videoSignedUrl),
          headers: {'Content-Type': 'video/mp4'}, body: videoBytes);
      if (videoUploadResponse.statusCode != 200)
        throw Exception('영상 GCS 업로드 실패');

      // --- 3. 커버 이미지 업로드 ---
      setState(() => _statusText = "커버 이미지 업로드 중...");
      final coverUploadPath = 'posts/$postId/cover.jpg';
      final ref = FirebaseStorage.instance.ref().child(coverUploadPath);
      await ref.putData(
          editedCoverBytes, SettableMetadata(contentType: 'image/jpeg'));
      final coverUrl = await ref.getDownloadURL();

      // --- 4. 인코딩 요청 ---
      setState(() => _statusText = "서버에 인코딩 요청 중...");
      final docId = const Uuid().v4();
      final ownerUid = currentUserUid;
      const requestEncodingEndpoint =
          'https://encoder-636984750551.asia-northeast3.run.app/encode';
      final encodeApiResponse = await http.post(
        Uri.parse(requestEncodingEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "gcsPath": videoGcsPath,
          "thumbUrl": coverUrl,
          "postId": postId,
          "docId": docId,
          "ownerUid": ownerUid,
          "start_ms": startMs,
          "end_ms": endMs,
          "rotate": 0,
          "crop": null,
        }),
      );
      if (encodeApiResponse.statusCode != 200)
        throw Exception('서버 인코딩 작업 요청 실패');

      // --- 5. 실시간 상태 감시 시작 ---
      setState(() => _statusText = "서버에서 영상 처리 중...");
      final videoDocRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('video')
          .doc(docId);
      _listenToEncodingStatus(videoDocRef);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusText = "";
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('오류 발생: $e')));
    }
  }

  void _listenToEncodingStatus(DocumentReference videoDocRef) {
    _firestoreSubscription = videoDocRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          final status = data['status'] as String?;
          if (status == 'encoded') {
            setState(() => _statusText = "처리 완료!");
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('✅ 영상이 성공적으로 처리되었습니다!')));
            // 1초 후, 최초 페이지로 돌아갑니다.
            Future.delayed(const Duration(seconds: 1), () {
              if (mounted) {
                Navigator.of(context)
                    .popUntil(ModalRoute.withName('editvideoP'));
              }
            });
            _firestoreSubscription?.cancel();
          } else if (status == 'failed') {
            final errorMessage = data['error'] ?? '알 수 없는 오류';
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('❌ 처리 실패: $errorMessage')));
            setState(() => _isLoading = false); // 로딩 오버레이 닫기
            _firestoreSubscription?.cancel();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_imageBytes == null) {
      return const Scaffold(body: Center(child: Text('이미지를 불러올 수 없습니다.')));
    }

    return Scaffold(
      body: Stack(
        children: [
          // ProImageEditor는 항상 뒤에 존재합니다.
          ProImageEditor.memory(
            _imageBytes!,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                // "완료" 버튼을 누르면, 모든 처리를 시작합니다.
                await _processAndUpload(bytes);
              },
              onCloseEditor: () {
                if (!_isLoading && mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),

          // _isLoading이 true일 때만 로딩 오버레이를 보여줍니다.
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      _statusText,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
