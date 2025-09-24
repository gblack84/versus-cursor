import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/services/media/image_download_service.dart';
import 'pro_image_editor_model.dart';
export 'pro_image_editor_model.dart';

class ProImageEditorPage extends StatefulWidget {
  const ProImageEditorPage({
    super.key,
    required this.imagePath,
    required this.box,
  });

  final String imagePath;
  final String box;

  static String routeName = 'ProImageEditor';
  static String routePath = '/proImageEditor/:imagePath/:box';

  @override
  State<ProImageEditorPage> createState() => _ProImageEditorPageState();
}

class _ProImageEditorPageState extends State<ProImageEditorPage> {
  late ProImageEditorModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => ProImageEditorModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  /// Firebase Storage에 이미지 업로드
  Future<String> _uploadToFirebase(Uint8List bytes) async {
    try {
      setState(() {
        _model.isUploading = true;
        _model.uploadProgress = 0.0;
      });

      // 현재 사용자 가져오기
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      // 파일명 생성
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${widget.box}.jpg';
      final path = 'users/${user.uid}/posts/images/$fileName';

      // Firebase Storage 참조 생성
      final ref = FirebaseStorage.instance.ref(path);

      // 업로드 태스크 생성
      final uploadTask = ref.putData(
        bytes,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'box': widget.box,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        ),
      );

      // 업로드 진행률 모니터링
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (progress.isFinite) {
            setState(() {
              _model.uploadProgress = progress.clamp(0.0, 1.0);
            });
          }
        }
      });

      // 업로드 완료 대기
      await uploadTask;

      // 다운로드 URL 가져오기
      final downloadUrl = await ref.getDownloadURL();

      setState(() {
        _model.isUploading = false;
      });

      return downloadUrl;
    } catch (e) {
      setState(() {
        _model.isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 업로드 실패: $e'),
          backgroundColor: AppTheme.of(context).error,
        ),
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Stack(
        children: [
          // ProImageEditor
          ProImageEditor.file(
            File(widget.imagePath),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                try {
                  // Firebase Storage에 업로드
                  final url = await _uploadToFirebase(bytes);

                  // AppState 업데이트
                  final appState =
                      Provider.of<AppState>(context, listen: false);
                  if (widget.box == 'A') {
                    appState.addToUploadImageA(url);
                  } else {
                    appState.addToUploadImageB(url);
                  }

                  // 성공 메시지 표시
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이미지가 성공적으로 저장되었습니다.'),
                        backgroundColor: AppTheme.of(context).success,
                      ),
                    );

                    // 임시 파일 정리
                    ImageDownloadService.cleanupTempFile(widget.imagePath);

                    // 이전 페이지로 돌아가기
                    context.pop();
                  }
                } catch (e) {
                  // 에러는 이미 _uploadToFirebase에서 처리됨
                  debugPrint('이미지 업로드 에러: $e');
                }
              },
            ),
            configs: const ProImageEditorConfigs(
                // 기본 설정 사용 (한국어는 나중에 추가 가능)
                ),
          ),

          // 업로드 진행 표시
          if (_model.isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: _model.uploadProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.of(context).primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '업로드 중... ${(_model.uploadProgress * 100).clamp(0, 100).toInt()}%',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
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
