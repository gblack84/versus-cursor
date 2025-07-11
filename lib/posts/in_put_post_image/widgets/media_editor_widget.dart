import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/core/app_theme.dart';
import '/app_state.dart';
import '../services/image_upload_orchestrator.dart';
import 'dialogs/moderation_dialog.dart';
import 'dialogs/moderation_error_dialog.dart';

/// 이미지 에디터 페이지 위젯
class MediaEditorWidget extends StatefulWidget {
  final File selectedFile;
  final List<File> allSelectedFiles;
  final List<AssetEntity> selectedAssets;
  final int currentEditIndex;
  final String box;
  final bool isAddMode;
  final int? currentIndex;
  final List<String>? existingImageUrls;
  final List<double>? existingAspectRatios;
  final List<String>? existingAssetIds;
  final bool startWithEditor;
  final Function(String imageUrl)? onSingleComplete;
  final Function(List<String> imageUrls)? onMultiComplete;
  final VoidCallback? onBackToThumbnail;
  final VoidCallback? onBackToPicker;
  final Function(double)? onProgressUpdate;

  const MediaEditorWidget({
    super.key,
    required this.selectedFile,
    required this.allSelectedFiles,
    required this.selectedAssets,
    required this.currentEditIndex,
    required this.box,
    required this.isAddMode,
    this.currentIndex,
    this.existingImageUrls,
    this.existingAspectRatios,
    this.existingAssetIds,
    required this.startWithEditor,
    this.onSingleComplete,
    this.onMultiComplete,
    this.onBackToThumbnail,
    this.onBackToPicker,
    this.onProgressUpdate,
  });

  @override
  State<MediaEditorWidget> createState() => _MediaEditorWidgetState();
}

class _MediaEditorWidgetState extends State<MediaEditorWidget> {
  double _uploadProgress = 0.0;

  /// 이미지 편집 완료 처리
  Future<void> _handleImageEditingComplete(Uint8List bytes) async {
    print('onImageEditingComplete 호출됨');
    try {
      // ProImageEditor의 기본 로딩이 잠시 나타났다가 사라진 후 커스텀 검열 다이얼로그 표시
      await Future.delayed(const Duration(milliseconds: 100));
      
      // AppState 접근
      final appState = Provider.of<AppState>(context, listen: false);
      
      // ImageUploadOrchestrator 생성
      final orchestrator = ImageUploadOrchestrator(
        context: context,
        appState: appState,
        box: widget.box,
      );
      
      // 멀티 이미지 처리
      if (widget.allSelectedFiles.isNotEmpty) {
        // 멀티 이미지 업로드 처리
        final result = await orchestrator.handleMultiImageUpload(
          editedImageBytes: bytes,
          allFiles: widget.allSelectedFiles,
          currentEditIndex: widget.currentEditIndex,
          selectedAssets: widget.selectedAssets,
          isAddMode: widget.isAddMode,
          currentIndex: widget.currentIndex,
          existingImageUrls: widget.existingImageUrls,
          existingAspectRatios: widget.existingAspectRatios,
          existingAssetIds: widget.existingAssetIds,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
            widget.onProgressUpdate?.call(progress);
          },
          onModerationProgress: (current, total) {
            ModerationDialog.show(
              context: context,
              currentIndex: current,
              totalCount: total,
            );
          },
        );
        
        if (!result.success) {
          // 검열 실패 또는 업로드 실패
          if (mounted) {
            Navigator.pop(context); // 검열 다이얼로그 닫기
            
            if (result.rejectionReason != null) {
              ModerationErrorDialog.show(
                context: context,
                reason: result.rejectionReason!,
                box: widget.box,
                onRetry: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(), // MediaSelectionFlowWidget로 교체 필요
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('이미지 업로드 실패: ${result.error ?? "알 수 없는 오류"}'),
                  backgroundColor: AppTheme.of(context).error,
                ),
              );
              Navigator.pop(context); // 에디터 닫기
            }
          }
          return;
        }
        
        // 콜백 호출
        if (widget.onMultiComplete != null && result.imageUrls != null) {
          widget.onMultiComplete!(result.imageUrls!);
        }
        
        // 모달 닫기
        if (mounted) {
          Navigator.pop(context); // 검열 다이얼로그 닫기
          Navigator.pop(context); // 에디터 닫기
          print('멀티 이미지 업로드 완료 및 모달 닫기');
        }
        
      } else {
        // 단일 이미지 처리
        final result = await orchestrator.handleSingleImageUpload(
          imageBytes: bytes,
          selectedAssets: widget.selectedAssets,
          isEditMode: widget.startWithEditor && widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
            widget.onProgressUpdate?.call(progress);
          },
          onModerationStart: () {
            ModerationDialog.show(
              context: context,
              currentIndex: 1,
              totalCount: 1,
            );
          },
        );
        
        if (!result.success) {
          // 검열 실패 또는 업로드 실패
          if (mounted) {
            Navigator.pop(context); // 검열 다이얼로그 닫기
            
            if (result.rejectionReason != null) {
              ModerationErrorDialog.show(
                context: context,
                reason: result.rejectionReason!,
                box: widget.box,
                onRetry: () async {
                  await showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    useSafeArea: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => Container(), // MediaSelectionFlowWidget로 교체 필요
                  );
                },
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('이미지 업로드 실패: ${result.error ?? "알 수 없는 오류"}'),
                  backgroundColor: AppTheme.of(context).error,
                ),
              );
              Navigator.pop(context); // 에디터 닫기
            }
          }
          return;
        }
        
        // 검열 다이얼로그 닫기
        if (mounted) {
          Navigator.pop(context);
        }
        
        // 콜백 호출
        if (result.imageUrls != null && result.imageUrls!.isNotEmpty) {
          widget.onSingleComplete?.call(result.imageUrls!.first);
        }
        
        // 모달 닫기
        if (mounted) {
          Navigator.pop(context);
          print('단일 이미지 업로드 완료 및 모달 닫기');
        }
      }
    } catch (e) {
      // 에러 처리
      print('이미지 업로드 에러: $e');
      if (mounted) {
        setState(() {
          _uploadProgress = 0.0;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 업로드 실패: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ProImageEditor
        ProImageEditor.file(
          widget.selectedFile,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: _handleImageEditingComplete,
          ),
          configs: ProImageEditorConfigs(
            heroTag: 'image-editor-hero',
            theme: Theme.of(context).copyWith(
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              colorScheme: ColorScheme.dark(
                primary: AppTheme.of(context).primary,
                secondary: AppTheme.of(context).primary,
              ),
            ),
            blurEditor: const BlurEditorConfigs(
              enabled: false,  // Blur 메뉴 비활성화
            ),
            paintEditor: const PaintEditorConfigs(
              enableModeRect: false,     // Rectangle 비활성화
              enableModePolygon: false,  // Polygon 비활성화
              enableModePixelate: false, // Pixelate 비활성화
              enableModeLine: false,     // Line 비활성화
            ),
          ),
        ),
        
        // 커스텀 뒤로가기 버튼 (X 버튼 위에 오버레이)
        Positioned(
          top: 12,
          left: 8,
          child: InkWell(
            onTap: () {
              // startWithEditor로 시작한 경우 바로 모달 닫기 (질문 작성 페이지로)
              if (widget.startWithEditor) {
                Navigator.pop(context);
              } else {
                // 갤러리 선택 플로우인 경우 기존 로직
                if (widget.allSelectedFiles.isNotEmpty) {
                  // 썸네일 선택 페이지로 돌아가기
                  widget.onBackToThumbnail?.call();
                } else {
                  // 피커로 돌아가기
                  widget.onBackToPicker?.call();
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.chevron_left,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    widget.startWithEditor 
                      ? '취소' 
                      : (widget.allSelectedFiles.isNotEmpty ? '썸네일' : '갤러리'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}