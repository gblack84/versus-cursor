import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import '/core_exports.dart';
import '/services/media/image_download_service.dart';
import '../../providers/creation_providers.dart';

/// ProImageEditor 통합 페이지
///
/// Migrated to Riverpod 3.x (Phase 2-6)
/// Clean Architecture Phase 8:
/// - Firebase SDK 직접 사용 제거 ✅
/// - MediaUploadNotifier를 통한 간접 업로드 ✅
/// - MediaStateCoordinator를 통한 상태 관리 ✅
/// - AppState 의존성 제거 ✅
/// - Legacy AppModel 패턴 제거 ✅
class ProImageEditorPage extends ConsumerStatefulWidget {
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
  ConsumerState<ProImageEditorPage> createState() => _ProImageEditorPageState();
}

class _ProImageEditorPageState extends ConsumerState<ProImageEditorPage> {
  // 업로드 상태 (AppModel 대신 State에서 직접 관리)
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// 이미지 편집 완료 핸들러
  Future<void> _handleImageEditingComplete(Uint8List bytes) async {
    if (!mounted) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    try {
      // Notifier를 통한 업로드 (Firebase 직접 호출 제거 - Riverpod 3.x)
      final uploadNotifier = ref.read(mediaUploadProvider.notifier);
      final url = await uploadNotifier.uploadEditedImage(
        imageBytes: bytes,
        box: widget.box,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _uploadProgress = progress;
            });
          }
        },
      );

      if (!mounted) return;

      // MediaSelectionProvider 직접 사용 (Phase 2-14: Coordinator 삭제됨)
      final mediaSelectionNotifier = ref.read(mediaSelectionProvider.notifier);
      final currentState = ref.read(mediaSelectionProvider);
      final currentUrls = widget.box == 'A'
          ? currentState.uploadedUrlsA
          : currentState.uploadedUrlsB;

      mediaSelectionNotifier.updateUploadedUrls(
        box: widget.box,
        urls: [...currentUrls, url],
      );

      // 성공 메시지
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('이미지가 성공적으로 저장되었습니다.'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );

        // 임시 파일 정리
        ImageDownloadService.cleanupTempFile(widget.imagePath);

        // 이전 페이지로 돌아가기
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
      debugPrint('이미지 업로드 에러: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: Stack(
        children: [
          // ProImageEditor
          ProImageEditor.file(
            File(widget.imagePath),
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: _handleImageEditingComplete,
            ),
            configs: const ProImageEditorConfigs(
              // 기본 설정 사용 (한국어는 나중에 추가 가능)
            ),
          ),

          // 업로드 진행 표시
          if (_isUploading)
            Container(
              color: Colors.black54,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      value: _uploadProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.of(context).primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '업로드 중... ${(_uploadProgress * 100).clamp(0, 100).toInt()}%',
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
