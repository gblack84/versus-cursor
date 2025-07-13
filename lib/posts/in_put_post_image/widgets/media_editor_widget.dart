import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import '/app_state.dart';
import '../services/image_upload_orchestrator.dart';

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
  final bool isRetrying;
  final Function(String imageUrl)? onSingleComplete;
  final Function(List<String> imageUrls)? onMultiComplete;
  final VoidCallback? onBackToThumbnail;
  final VoidCallback? onBackToPicker;
  final VoidCallback? onCloseModal;
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
    this.isRetrying = false,
    this.onSingleComplete,
    this.onMultiComplete,
    this.onBackToThumbnail,
    this.onBackToPicker,
    this.onCloseModal,
    this.onProgressUpdate,
  });

  @override
  State<MediaEditorWidget> createState() => _MediaEditorWidgetState();
}

class _MediaEditorWidgetState extends State<MediaEditorWidget> {
  // 검열 거부로 인한 재시도 모드인지 추적
  bool _isInRejectionRetryMode = false;

  /// Bot Toast 메시지 표시 헬퍼
  void _showToast(String message, {bool isError = false}) {
    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError 
            ? Colors.red.shade700.withValues(alpha: 0.9) 
            : Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
      duration: const Duration(seconds: 3),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }

  /// 이미지 편집 완료 처리
  Future<void> _handleImageEditingComplete(Uint8List bytes) async {
    print('[MediaEditor] onImageEditingComplete 호출됨');
    print('[MediaEditor] allSelectedFiles 수: ${widget.allSelectedFiles.length}');
    print('[MediaEditor] startWithEditor: ${widget.startWithEditor}');
    print('[MediaEditor] mounted 상태: $mounted');
    
    // ProImageEditor의 i18n loadingDialogMsg가 표시됨
    
    // ProImageEditor가 자동으로 닫히는 것을 기다림
    await Future.delayed(const Duration(milliseconds: 100));
    
    try {
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
            widget.onProgressUpdate?.call(progress);
          },
          onModerationProgress: (current, total) {
            // 검열 진행 상황은 ProImageEditor의 loadingDialogMsg로 표시됨
          },
        );
        
        if (!result.success) {
          // 검열 실패 또는 업로드 실패
          if (mounted) {
            
            if (result.rejectionReason != null) {
              // 시나리오 2: 모든 이미지가 거부된 경우
              if (result.scenarioType == 2) {
                setState(() {
                  _isInRejectionRetryMode = true;
                });
                // 토스트 먼저 표시
                _showToast(result.rejectionReason!, isError: true);
                
                // 피커 열기 (모달은 닫지 않음)
                widget.onBackToPicker?.call();
              } else {
                // 시나리오 1: 일부 이미지만 거부된 경우
                _showToast(result.rejectionReason!, isError: true);
                Navigator.pop(context);
              }
            } else {
              _showToast('이미지 업로드 실패: ${result.error ?? "알 수 없는 오류"}', isError: true);
              Navigator.pop(context); // 에디터 닫기
            }
          }
          return;
        }
        
        // 시나리오 1 체크: 일부 이미지가 거부되었지만 성공한 경우
        final rejectionMessage = result.rejectionReason;
        
        // 모달 먼저 닫기 (Toast와 콜백 호출 전에)
        if (mounted) {
          print('[MediaEditor] 멀티 이미지 업로드 완료');
          print('[MediaEditor] Navigator.pop 호출 전');
          Navigator.pop(context); // 에디터 닫기
          print('[MediaEditor] Navigator.pop 호출 완료');
          
          // 콜백 호출
          if (widget.onMultiComplete != null && result.imageUrls != null) {
            widget.onMultiComplete!(result.imageUrls!);
          }
          
          // Toast는 마지막에 (다음 프레임에서 안전하게)
          if (rejectionMessage != null && result.success) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showToast(rejectionMessage, isError: true);
            });
          }
        }
        
      } else {
        // 단일 이미지 처리
        final result = await orchestrator.handleSingleImageUpload(
          imageBytes: bytes,
          selectedAssets: widget.selectedAssets,
          isEditMode: widget.startWithEditor && widget.existingImageUrls != null && widget.existingImageUrls!.isNotEmpty,
          onProgress: (progress) {
            widget.onProgressUpdate?.call(progress);
          },
          onModerationStart: () {
            // 검열은 ProImageEditor의 loadingDialogMsg로 표시됨
          },
        );
        
        if (!result.success) {
          // 검열 실패 또는 업로드 실패
          if (mounted) {
            
            if (result.rejectionReason != null) {
              // 단일 이미지가 거부된 경우
              setState(() {
                _isInRejectionRetryMode = true;
              });
              // 토스트 먼저 표시
              _showToast(result.rejectionReason!, isError: true);
              
              // 피커 열기 (모달은 닫지 않음)
              widget.onBackToPicker?.call();
            } else {
              _showToast('이미지 업로드 실패: ${result.error ?? "알 수 없는 오류"}', isError: true);
              Navigator.pop(context); // 에디터 닫기
            }
          }
          return;
        }
        
        // 모달 먼저 닫기 (콜백 호출 전에)
        if (mounted) {
          Navigator.pop(context);
          print('단일 이미지 업로드 완료 및 모달 닫기');
          
          // Navigator.pop 이후에 콜백 호출 (microtask로 다음 프레임에 실행)
          if (result.imageUrls != null && result.imageUrls!.isNotEmpty) {
            Future.microtask(() {
              widget.onSingleComplete?.call(result.imageUrls!.first);
            });
          }
        }
      }
    } catch (e) {
      // 에러 처리
      print('이미지 업로드 에러: $e');
      if (mounted) {
        _showToast('이미지 업로드 실패: $e', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // ProImageEditor
          ProImageEditor.file(
          widget.selectedFile,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: _handleImageEditingComplete,
          ),
          configs: ProImageEditorConfigs(
            heroTag: 'image-editor-hero',
            i18n: const I18n(
              various: I18nVarious(
                loadingDialogMsg: "안전성 검사중 입니다...",
                closeEditorWarningTitle: "편집 취소",
                closeEditorWarningMessage: "변경사항을 저장하지 않고 나가시겠습니까?",
                closeEditorWarningConfirmBtn: "확인", 
                closeEditorWarningCancelBtn: "취소",
              ),
              paintEditor: I18nPaintEditor(
                bottomNavigationBarText: "페인트",
                freestyle: "자유형",
                arrow: "화살표",
                line: "선",
                rectangle: "사각형",
                circle: "원",
                dashLine: "점선",
                lineWidth: "선 두께",
                toggleFill: "채우기 전환",
                undo: "실행취소",
                redo: "다시실행",
                done: "완료",
                back: "뒤로",
                smallScreenMoreTooltip: "더보기",
              ),
              textEditor: I18nTextEditor(
                inputHintText: "텍스트 입력",
                bottomNavigationBarText: "텍스트",
                back: "뒤로",
                done: "완료",
                textAlign: "텍스트 정렬",
                backgroundMode: "배경 모드",
                smallScreenMoreTooltip: "더보기",
              ),
              cropRotateEditor: I18nCropRotateEditor(
                bottomNavigationBarText: "자르기/회전",
                rotate: "회전",
                ratio: "비율",
                back: "뒤로",
                done: "완료",
                smallScreenMoreTooltip: "더보기",
              ),
              filterEditor: I18nFilterEditor(
                bottomNavigationBarText: "필터",
                back: "뒤로",
                done: "완료",
                filters: I18nFilters(),
              ),
              emojiEditor: I18nEmojiEditor(
                bottomNavigationBarText: "이모지",
              ),
              stickerEditor: I18nStickerEditor(
                bottomNavigationBarText: "스티커",
              ),
              doneLoadingMsg: "안전성 검사중 입니다...",
            ),
            theme: Theme.of(context).copyWith(
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              dialogTheme: DialogThemeData(
                backgroundColor: Colors.black.withValues(alpha: 0.5),
              ),
              colorScheme: const ColorScheme.dark(
                primary: Colors.white,  // 로딩 인디케이터 색상
                secondary: Colors.white,
              ),
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Colors.white),
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
              // 검열 거부로 인한 재시도 모드인 경우 모달 닫기
              if (_isInRejectionRetryMode) {
                if (widget.onCloseModal != null) {
                  widget.onCloseModal!();
                } else {
                  Navigator.pop(context);
                }
                return;
              }
              
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
    ),
    );
  }
}