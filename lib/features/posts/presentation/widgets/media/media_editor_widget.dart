import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:path_provider/path_provider.dart';
import '/app/state/app_state.dart';
import '/features/posts/data/adapters/media/image_upload_orchestrator_v2.dart';
import '/features/posts/presentation/screens/create_post/in_put_post_image_model.dart';
import '/services/moderation/image_moderation_service.dart';

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
  final InPutPostImageModel? model;

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
    this.model,
  });

  @override
  State<MediaEditorWidget> createState() => _MediaEditorWidgetState();
}

class _MediaEditorWidgetState extends State<MediaEditorWidget> {
  // 검열 거부로 인한 재시도 모드인지 추적
  bool _isInRejectionRetryMode = false;

  /// Bot Toast 메시지 표시 헬퍼
  void _showToast(String message, {bool isError = false, IconData? icon}) {
    print('[DEBUG] _showToast 호출됨: $message (isError: $isError)');

    // 메시지 내용에 따라 아이콘 자동 결정
    if (icon == null && isError) {
      if (message.contains('편집된 텍스트가 부적절합니다')) {
        icon = Icons.text_fields;
      } else if (message.contains('이미지가 부적절합니다')) {
        icon = Icons.image_not_supported;
      } else {
        icon = Icons.error_outline;
      }
    }

    BotToast.showCustomText(
      toastBuilder: (_) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isError
              ? Colors.red.shade700.withValues(alpha: 0.9)
              : Colors.black.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
      duration: const Duration(seconds: 4),
      align: const Alignment(0, 0.8),
      onlyOne: true,
    );
  }

  /// 편집된 이미지를 File로 저장
  Future<File> _saveEditedImageAsFile(Uint8List bytes) async {
    // 임시 디렉토리에 파일 저장
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final tempPath =
        '${tempDir.path}/edited_image_${widget.box}_$timestamp.jpg';

    final file = File(tempPath);
    await file.writeAsBytes(bytes);

    return file;
  }

  /// 이미지의 비율 계산
  Future<double?> _calculateImageAspectRatio(Uint8List bytes) async {
    try {
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final image = frame.image;

      final width = image.width.toDouble();
      final height = image.height.toDouble();
      final ratio = width / height;

      print('[MediaEditor] 편집된 이미지 비율 계산:');
      print('  - 이미지 크기: ${width.toInt()}x${height.toInt()}');
      print('  - 계산된 비율: $ratio');

      return ratio;
    } catch (e) {
      print('[MediaEditor] 이미지 비율 계산 실패: $e');
      return null;
    }
  }

  /// 거부 메시지 생성
  String _buildRejectionMessage(ImageProcessResult result,
      {ModerationResult? moderationResult}) {
    print('[DEBUG] _buildRejectionMessage 호출됨');
    print('[DEBUG] rejectedCount: ${result.rejectedCount}');
    print(
        '[DEBUG] moderationResult: ${moderationResult != null ? "있음" : "없음"}');

    // 단일 이미지 거부 시 더 구체적인 메시지 제공
    if (result.rejectedCount == 1 && moderationResult != null) {
      // 텍스트 문제인지 이미지 문제인지 구분
      if (moderationResult.hasText && moderationResult.reason.isNotEmpty) {
        // 텍스트 관련 거부 이유들
        final textReasons = [
          '욕설',
          '유해한 콘텐츠',
          '심각한 유해 콘텐츠',
          '혐오 표현',
          '모욕적 표현',
          '위협적 표현'
        ];
        if (textReasons.contains(moderationResult.reason)) {
          return '편집된 텍스트가 부적절합니다: ${moderationResult.reason}';
        }
      }

      // 이미지 관련 거부 이유들
      final imageReasons = ['성인 콘텐츠', '폭력적 콘텐츠', '선정적 콘텐츠'];
      if (imageReasons.contains(moderationResult.reason)) {
        return '이미지가 부적절합니다: ${moderationResult.reason}';
      }

      // 기타 경우
      return '콘텐츠가 부적절합니다: ${moderationResult.reason}';
    }

    // 멀티 이미지 거부 시 기존 방식 유지
    if (result.rejectedCount == 1) {
      return '커뮤니티 가이드라인 위반';
    } else {
      return '커뮤니티 가이드라인 위반: ${result.rejectedIndices.join(", ")}';
    }
  }

  /// 이미지 편집 완료 처리
  Future<void> _handleImageEditingComplete(Uint8List bytes) async {
    print('[MediaEditor] onImageEditingComplete 호출됨');
    print(
        '[MediaEditor] allSelectedFiles 수: ${widget.allSelectedFiles.length}');
    print('[MediaEditor] startWithEditor: ${widget.startWithEditor}');
    print('[MediaEditor] mounted 상태: $mounted');

    // ProImageEditor의 i18n loadingDialogMsg가 표시됨

    // ProImageEditor가 자동으로 닫히는 것을 기다림
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      // AppState 접근
      final appState = Provider.of<AppState>(context, listen: false);

      // ImageUploadOrchestratorV2 생성
      final orchestrator = ImageUploadOrchestratorV2(
        context: context,
        appState: appState,
        box: widget.box,
        model: widget.model,
      );

      // 편집된 이미지를 File로 저장
      final editedFile = await _saveEditedImageAsFile(bytes);

      // 편집된 이미지의 비율 계산
      final aspectRatio = await _calculateImageAspectRatio(bytes);

      // 멀티 이미지 처리
      if (widget.allSelectedFiles.isNotEmpty) {
        // 멀티 이미지 처리 (검열만 수행, 업로드 X)
        final result = await orchestrator.handleMultiImageProcess(
          editedImageFile: editedFile,
          allFiles: widget.allSelectedFiles,
          currentEditIndex: widget.currentEditIndex,
          selectedAssets: widget.selectedAssets,
          isAddMode: widget.isAddMode,
          isEditMode: widget.startWithEditor, // 편집 모드 플래그 추가
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
          showToast: false, // 토스트는 여기서 통합 관리
        );

        if (!result.success || result.allRejected) {
          // 검열 실패
          if (mounted) {
            if (result.allRejected) {
              // 시나리오 2: 모든 이미지가 거부된 경우
              setState(() {
                _isInRejectionRetryMode = true;
              });

              // 거부 메시지 생성 (멀티 이미지의 경우 기존 방식 유지)
              final rejectionMessage = _buildRejectionMessage(result);
              _showToast(rejectionMessage, isError: true);

              // 피커 열기 (모달은 닫지 않음)
              widget.onBackToPicker?.call();
            } else {
              // 편집 모드에서 이미지가 거부된 경우
              if (result.moderationResult != null &&
                  !result.moderationResult!.isAppropriate) {
                final detailedMessage = _buildRejectionMessage(result,
                    moderationResult: result.moderationResult);
                _showToast(detailedMessage, isError: true);
              } else {
                _showToast('이미지 처리 실패', isError: true);
              }
              Navigator.pop(context); // 에디터 닫기
            }
          }
          return;
        }

        // 성공: 일부 이미지가 거부되었을 수도 있음
        if (mounted) {
          print('[MediaEditor] 멀티 이미지 처리 완료');

          // 비율 업데이트 (편집된 이미지의 인덱스에 해당하는 비율 업데이트)
          if (aspectRatio != null &&
              widget.currentEditIndex <
                  (widget.box == 'A'
                      ? appState.uploadImageAspectRatioA.length
                      : appState.uploadImageAspectRatioB.length)) {
            appState.update(() {
              if (widget.box == 'A') {
                appState.uploadImageAspectRatioA[widget.currentEditIndex] =
                    aspectRatio;
              } else {
                appState.uploadImageAspectRatioB[widget.currentEditIndex] =
                    aspectRatio;
              }
            });
          }

          print('[MediaEditor] Navigator.pop 호출 전');
          Navigator.pop(context); // 에디터 닫기
          print('[MediaEditor] Navigator.pop 호출 완료');

          // 콜백 호출 (File이 AppState에 저장됨)
          if (widget.onMultiComplete != null) {
            widget.onMultiComplete!([]); // URL 대신 빈 배열 전달
          }

          // 일부 이미지가 거부된 경우 Toast 표시
          if (result.rejectedCount > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final rejectionMessage = _buildRejectionMessage(result,
                  moderationResult: result.moderationResult);
              _showToast(rejectionMessage, isError: true);
            });
          }
        }
      } else {
        // 단일 이미지 처리
        final result = await orchestrator.handleSingleImageProcess(
          imageFile: editedFile,
          assetId: widget.selectedAssets.isNotEmpty
              ? widget.selectedAssets.first.id
              : null,
          onProgress: (progress) {
            widget.onProgressUpdate?.call(progress);
          },
        );

        if (!result.success || result.allRejected) {
          // 검열 실패
          if (mounted) {
            setState(() {
              _isInRejectionRetryMode = true;
            });

            // 거부 메시지 표시 (단일 이미지이므로 구체적인 이유 표시)
            final rejectionMessage = _buildRejectionMessage(result,
                moderationResult: result.moderationResult);
            _showToast(rejectionMessage, isError: true);

            // 피커 열기 (모달은 닫지 않음)
            widget.onBackToPicker?.call();
          }
          return;
        }

        // 성공: 모달 닫기
        if (mounted) {
          // 비율 업데이트 (startWithEditor인 경우)
          if (aspectRatio != null && widget.startWithEditor) {
            appState.update(() {
              if (widget.box == 'A') {
                // 현재 인덱스의 비율 업데이트
                final currentIndex = widget.currentIndex ?? 0;
                if (currentIndex < appState.uploadImageAspectRatioA.length) {
                  appState.uploadImageAspectRatioA[currentIndex] = aspectRatio;
                }
              } else {
                // 현재 인덱스의 비율 업데이트
                final currentIndex = widget.currentIndex ?? 0;
                if (currentIndex < appState.uploadImageAspectRatioB.length) {
                  appState.uploadImageAspectRatioB[currentIndex] = aspectRatio;
                }
              }
            });
          } else if (aspectRatio != null) {
            // 새 이미지인 경우 비율 추가
            appState.update(() {
              if (widget.box == 'A') {
                appState.addToUploadImageAspectRatioA(aspectRatio);
              } else {
                appState.addToUploadImageAspectRatioB(aspectRatio);
              }
            });
          }

          Navigator.pop(context);
          print('단일 이미지 처리 완료 및 모달 닫기');

          // 콜백 호출 (File이 AppState에 저장됨)
          if (widget.onSingleComplete != null) {
            Future.microtask(() {
              widget.onSingleComplete!(''); // URL 대신 빈 문자열 전달
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
                  primary: Colors.white, // 로딩 인디케이터 색상
                  secondary: Colors.white,
                ),
                textTheme: const TextTheme(
                  bodyMedium: TextStyle(color: Colors.white),
                ),
              ),
              blurEditor: const BlurEditorConfigs(
                enabled: false, // Blur 메뉴 비활성화
              ),
              paintEditor: const PaintEditorConfigs(
                enableModeRect: false, // Rectangle 비활성화
                enableModePolygon: false, // Polygon 비활성화
                enableModePixelate: false, // Pixelate 비활성화
                enableModeLine: false, // Line 비활성화
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                          : (widget.allSelectedFiles.isNotEmpty
                              ? '썸네일'
                              : '갤러리'),
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
