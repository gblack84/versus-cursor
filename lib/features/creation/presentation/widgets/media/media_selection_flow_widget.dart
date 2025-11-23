import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:provider/provider.dart'; // For DefaultAssetPickerProvider (3rd party)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core_exports.dart';
import '/features/creation/presentation/delegates/korean_asset_picker_delegate.dart';
import '/features/creation/presentation/delegates/korean_camera_picker_delegate.dart';
import '/services/media/image_download_service.dart';
import '/features/creation/presentation/screens/thumbnail/thumbnail_selection_page.dart';
import '/features/creation/presentation/delegates/camera_floating_button_delegate.dart';
import 'media_editor_widget.dart';
import '/core/utils/navigation/no_animation_page_route.dart';
import '/features/creation/presentation/providers/creation_providers.dart';
import '/features/creation/domain/failures/creation_failure.dart';
import '/features/creation/domain/failures/creation_failure_extensions.dart';

/// 미디어 선택부터 편집까지 하나의 플로우로 처리하는 위젯 - Riverpod 3.x (Phase 2-7)
class MediaSelectionFlowWidget extends ConsumerStatefulWidget {
  const MediaSelectionFlowWidget({
    super.key,
    required this.box,
    required this.onComplete,
    this.onMultiComplete,
    this.onFileComplete,
    this.onMultiFileComplete,
    this.initialImageUrl,
    this.initialImageFile,
    this.startWithEditor = false,
    this.existingImageUrls,
    this.existingImageFiles,
    this.existingAspectRatios,
    this.existingAssetIds,
    this.isAddMode = false,
    this.currentIndex,
    this.onImagesSelected, // Phase 5: MediaSelectionProvider 콜백
  });

  final String box; // 'A' or 'B'
  final Function(String imageUrl) onComplete; // 단일 이미지 완료 콜백
  final Function(List<String> imageUrls)? onMultiComplete; // 멀티 이미지 완료 콜백
  final Function(File imageFile)? onFileComplete; // 단일 파일 완료 콜백
  final Function(List<File> imageFiles)? onMultiFileComplete; // 멀티 파일 완료 콜백
  final String? initialImageUrl; // 편집할 기존 이미지 URL
  final File? initialImageFile; // 편집할 기존 이미지 File
  final bool startWithEditor; // 에디터로 바로 시작할지 여부
  final List<String>? existingImageUrls; // 기존 이미지 URL들 (재사용용)
  final List<File>? existingImageFiles; // 기존 이미지 File들
  final List<double>? existingAspectRatios; // 기존 이미지 비율들
  final List<String>? existingAssetIds; // 기존 AssetEntity ID들
  final bool isAddMode; // 추가 모드인지 여부
  final int? currentIndex; // 현재 보고 있는 이미지 인덱스
  final Function(List<AssetEntity> assets)?
  onImagesSelected; // Phase 5: Provider 연동

  @override
  ConsumerState<MediaSelectionFlowWidget> createState() =>
      _MediaSelectionFlowWidgetState();
}

class _MediaSelectionFlowWidgetState
    extends ConsumerState<MediaSelectionFlowWidget> {
  // 선택된 파일
  File? _selectedFile;

  // 멀티 이미지 선택 시 사용
  List<File> _allSelectedFiles = [];
  List<AssetEntity> _selectedAssets = []; // AssetEntity 저장
  int _currentEditIndex = 0;

  // 재시도 상태 추적
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();

    // Phase 5: MediaSelectionProvider에서 기존 선택 복원
    _initializeFromProvider();

    // 기존 이미지가 있고 에디터로 바로 시작하는 경우
    if (widget.startWithEditor) {
      if (widget.initialImageFile != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _editExistingFile();
        });
      } else if (widget.initialImageUrl != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _downloadAndEditExistingImage();
        });
      }
    } else {
      // 에디터로 바로 시작하지 않는 경우, 피커 열기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPicker();
      });
    }
  }

  /// Phase 5: Provider에서 초기 상태 복원 - Riverpod 3.x
  Future<void> _initializeFromProvider() async {
    final mediaSelectionState = ref.read(mediaSelectionProvider);

    // 기존 AssetEntity ID 복원
    final existingIds = widget.box == 'A'
        ? mediaSelectionState.assetEntityIdsA
        : mediaSelectionState.assetEntityIdsB;

    if (existingIds.isNotEmpty) {
      final restoredAssets = <AssetEntity>[];
      for (String id in existingIds) {
        try {
          final asset = await AssetEntity.fromId(id);
          if (asset != null) {
            restoredAssets.add(asset);
          }
        } catch (e) {
          // AssetEntity 복원 실패 - Flutter DevTools에서 확인 가능
        }
      }

      if (mounted && restoredAssets.isNotEmpty) {
        setState(() {
          _selectedAssets = restoredAssets;
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Bot Toast 메시지 표시 헬퍼 (ErrorHandler 스타일과 통일)
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

  /// AssetPicker 열기
  Future<void> _openPicker() async {
    try {
      // 권한 확인 및 요청
      final PermissionState permission =
          await PhotoManager.requestPermissionExtend();

      if (permission.isAuth != true) {
        // Step 7: 권한이 거부된 경우 - MediaProcessingFailed 사용
        final permissionMessage = permission == PermissionState.denied
            ? '사진 접근 권한이 필요합니다.\n설정에서 권한을 허용해주세요.'
            : '제한된 사진 접근만 허용되었습니다.\n모든 사진에 접근하려면 설정을 변경해주세요.';

        final failure = CreationFailure.mediaProcessingFailed(
          failedStep: MediaProcessingStep.permission,
          affectedFiles: [],
          details: permissionMessage,
        );
        _showToast(failure.getUserMessage(), isError: true);

        // Step 7: 설정으로 이동하는 다이얼로그 표시
        if (mounted) {
          final bool? openSettings = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('사진 접근 권한'),
                content: Text(failure.getUserMessage()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('취소'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('설정으로 이동'),
                  ),
                ],
              );
            },
          );

          if (openSettings == true) {
            await PhotoManager.openSetting();
          }
        }

        // 권한이 없으면 플로우 종료
        if (mounted) {
          Navigator.of(context).pop();
        }
        return;
      }
      // Phase 5: MediaSelectionProvider에서 기존 선택 복원 - Riverpod 3.x
      final mediaSelectionState = ref.read(mediaSelectionProvider);
      List<AssetEntity> selectedAssets = [];

      // Provider에서 AssetEntity ID 가져오기
      final existingIds = widget.box == 'A'
          ? mediaSelectionState.assetEntityIdsA
          : mediaSelectionState.assetEntityIdsB;

      if (existingIds.isNotEmpty) {
        for (String id in existingIds) {
          try {
            final asset = await AssetEntity.fromId(id);
            if (asset != null) {
              selectedAssets.add(asset);
            }
          } catch (e) {
            // AssetEntity 복원 실패 - Flutter DevTools에서 확인 가능
          }
        }
      }

      // 커스텀 델리게이트를 사용하여 플로팅 카메라 버튼 추가
      final List<AssetEntity>? result =
          await AssetPicker.pickAssetsWithDelegate(
            context,
            delegate: CameraFloatingButtonDelegate(
              provider: DefaultAssetPickerProvider(
                selectedAssets: selectedAssets,
                maxAssets: 4,
                requestType: RequestType.image,
                sortPathsByModifiedDate: true, // 최신 사진을 맨 위에 표시
              ),
              initialPermission: permission,
              gridCount: 4,
              shouldRevertGrid: false, // 최신 사진이 맨 위에 오도록 설정
              pickerTheme: ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.black,
                appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
                colorScheme: ColorScheme.dark(
                  primary: AppTheme.of(context).primary,
                  secondary: AppTheme.of(context).primary,
                  surface: Colors.black,
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.of(context).primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.of(context).primary,
                  ),
                ),
              ),
              textDelegate: const CustomKoreanAssetPickerTextDelegate(),
              onCameraPressed: () async {
                // 카메라 열기
                final AssetEntity? cameraResult = await _openCameraForPicker(
                  context,
                );
                if (cameraResult != null) {
                  // 촬영한 사진을 선택 목록에 추가
                  setState(() {
                    _selectedAssets.add(cameraResult);
                  });
                  // 피커의 선택 상태도 업데이트
                  if (context.mounted) {
                    final provider = context.read<DefaultAssetPickerProvider>();
                    provider.selectAsset(cameraResult);
                  }
                }
              },
            ),
            pageRouteBuilder: (Widget picker) {
              return AssetPickerPageRoute<List<AssetEntity>>(
                builder: (_) => picker,
                transitionDuration: Duration.zero,
              );
            },
          );

      if (result != null && result.isNotEmpty) {
        // Phase 5: 선택 결과를 Provider에 저장
        if (widget.onImagesSelected != null) {
          widget.onImagesSelected!(result);
        }

        // 추가 모드이거나 기존 이미지가 있는 경우 - diff 처리
        if (widget.isAddMode ||
            (widget.existingImageUrls != null &&
                widget.existingImageUrls!.isNotEmpty) ||
            (widget.existingImageFiles != null &&
                widget.existingImageFiles!.isNotEmpty)) {
          await _processSelectionResult(result);
          return;
        }

        // 기존 이미지가 없거나 첫 번째 이미지인 경우 - 기존 플로우 유지
        // 1장만 선택한 경우 바로 편집
        if (result.length == 1) {
          final file = await result.first.file;
          if (file != null) {
            setState(() {
              _selectedFile = file;
              // 단일 선택 시에도 AssetEntity 저장
              _selectedAssets = result;
            });
          }
        } else {
          // 여러 장 선택한 경우 썸네일 선택 페이지로 이동
          final files = await Future.wait(result.map((asset) => asset.file));

          final validFiles = files.whereType<File>().toList();
          if (validFiles.isNotEmpty && mounted) {
            // AssetEntity 리스트 저장
            setState(() {
              _selectedAssets = result;
            });
            // 썸네일 선택 페이지로 이동
            _navigateToThumbnailSelection(validFiles);
          }
        }
      } else {
        // 피커 취소 시 항상 모달 닫기
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      // Step 7: 이미지 선택 중 오류 - ImageUploadFailed 사용
      if (mounted) {
        final failure = CreationFailure.imageUploadFailed();
        _showToast('${failure.getUserMessage()}: $e', isError: true);
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    }
  }

  /// 썸네일 선택 페이지로 이동
  Future<void> _navigateToThumbnailSelection(List<File> files) async {
    setState(() {
      _allSelectedFiles = files;
    });

    // ThumbnailSelectionPage로 이동
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      NoAnimationPageRoute(
        builder: (context) =>
            ThumbnailSelectionPage(imagePaths: files, box: widget.box),
      ),
    );

    if (result != null && mounted) {
      // 뒤로가기 액션인 경우 피커로 돌아가기
      if (result['action'] == 'back_to_picker') {
        _openPicker();
      } else if (result['selectedIndex'] != null) {
        // 정상적으로 이미지를 선택한 경우
        final selectedIndex = result['selectedIndex'] as int;
        setState(() {
          _selectedFile = files[selectedIndex];
          _currentEditIndex = selectedIndex;
          // 모든 파일을 저장 (썸네일 선택 시에도 전체 파일 유지)
          _allSelectedFiles = files;
        });
      }
    } else {
      // 취소한 경우 모달 닫기
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  /// 피커 내에서 카메라 열기
  Future<AssetEntity?> _openCameraForPicker(BuildContext context) async {
    try {
      // 카메라 권한 확인
      final PermissionState cameraPermission =
          await PhotoManager.requestPermissionExtend();

      if (cameraPermission.isAuth != true) {
        // Step 7: 카메라 권한 오류 - MediaProcessingFailed 사용
        final failure = CreationFailure.mediaProcessingFailed(
          failedStep: MediaProcessingStep.permission,
          affectedFiles: [],
          details: '카메라 권한이 필요합니다.',
        );
        _showToast(failure.getUserMessage(), isError: true);
        return null;
      }

      final AssetEntity? entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          enableRecording: false, // 사진만
          textDelegate: const CustomKoreanCameraPickerTextDelegate(),
        ),
      );

      return entity;
    } catch (e) {
      // Step 7: 카메라 오류 - ImageUploadFailed 사용
      final failure = CreationFailure.imageUploadFailed();
      _showToast(failure.getUserMessage(), isError: true);
      return null;
    }
  }

  /// 기존 파일 편집
  Future<void> _editExistingFile() async {
    setState(() {
      _selectedFile = widget.initialImageFile;

      // 멀티 이미지 편집 시 전체 파일 목록 설정
      if (widget.existingImageFiles != null &&
          widget.existingImageFiles!.isNotEmpty) {
        _allSelectedFiles = List<File>.from(widget.existingImageFiles!);
        _currentEditIndex = widget.currentIndex ?? 0;
      }

      // AssetEntity ID들도 복원
      if (widget.existingAssetIds != null &&
          widget.existingAssetIds!.isNotEmpty) {
        // AssetEntity 복원은 비동기로 처리
        _restoreAssetEntities();
      }
    });
  }

  /// AssetEntity ID들을 비동기로 복원
  Future<void> _restoreAssetEntities() async {
    if (widget.existingAssetIds == null) return;

    final restoredAssets = <AssetEntity>[];
    for (String id in widget.existingAssetIds!) {
      try {
        final asset = await AssetEntity.fromId(id);
        if (asset != null) {
          restoredAssets.add(asset);
        }
      } catch (e) {
        // AssetEntity 복원 실패 - Flutter DevTools에서 확인 가능
      }
    }

    if (mounted) {
      setState(() {
        _selectedAssets = restoredAssets;
      });
    }
  }

  /// 기존 이미지 다운로드 후 편집
  Future<void> _downloadAndEditExistingImage() async {
    try {
      // Firebase Storage URL에서 이미지 다운로드
      final localPath = await ImageDownloadService.downloadImage(
        widget.initialImageUrl!,
      );
      final file = File(localPath);

      setState(() {
        _selectedFile = file;
      });
    } catch (e) {
      // Step 7: 이미지 로드 실패 - ImageUploadFailed 사용
      if (mounted) {
        final failure = CreationFailure.imageUploadFailed();
        _showToast('${failure.getUserMessage()}: $e', isError: true);
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.black,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height,
        color: Colors.black,
        child: SafeArea(
          child: _selectedFile != null
              ? _buildEditorPage()
              : _buildLoadingPage(),
        ),
      ),
    );
  }

  /// 로딩 페이지 빌드
  Widget _buildLoadingPage() {
    return Container(
      color: Colors.black,
      child: const Center(
        child: SizedBox.shrink(), // 중복 로딩 인디케이터 제거
      ),
    );
  }

  /// 에디터 페이지 빌드
  Widget _buildEditorPage() {
    return MediaEditorWidget(
      selectedFile: _selectedFile!,
      allSelectedFiles: _allSelectedFiles,
      selectedAssets: _selectedAssets,
      currentEditIndex: _currentEditIndex,
      box: widget.box,
      isAddMode: widget.isAddMode,
      currentIndex: widget.currentIndex,
      existingImageUrls: widget.existingImageUrls,
      existingAspectRatios: widget.existingAspectRatios,
      existingAssetIds: widget.existingAssetIds,
      startWithEditor: widget.startWithEditor,
      isRetrying: _isRetrying,
      onSingleComplete: (imageUrl) {
        // URL 기반 완료 처리
        widget.onComplete(imageUrl);

        // File 기반에서 편집 시작한 경우, File 콜백도 호출
        // 단, 멀티 이미지가 아닌 경우에만 (멀티 이미지는 이미 처리됨)
        if (widget.initialImageFile != null &&
            widget.onFileComplete != null &&
            _allSelectedFiles.isEmpty) {
          // 편집된 파일이 _selectedFile에 저장되어 있음
          widget.onFileComplete!(_selectedFile!);
        }
      },
      onMultiComplete: widget.onMultiComplete,
      onBackToThumbnail: () {
        if (_allSelectedFiles.isNotEmpty) {
          setState(() {
            _selectedFile = null;
          });
          _navigateToThumbnailSelection(_allSelectedFiles);
        }
      },
      onBackToPicker: () {
        setState(() {
          _selectedFile = null;
          _allSelectedFiles = [];
          _selectedAssets = [];
          _isRetrying = true; // 재시도 상태 설정
        });
        _openPicker();
        // 피커가 열린 후 재시도 플래그 리셋
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _isRetrying = false;
            });
          }
        });
      },
      onCloseModal: () {
        // 모달을 닫고 질문 작성 페이지로 돌아가기
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }

  /// 선택 결과 처리 (diff 계산)
  Future<void> _processSelectionResult(List<AssetEntity> selectedAssets) async {
    try {
      // Phase 5: Provider에 선택 결과 저장
      if (widget.onImagesSelected != null) {
        widget.onImagesSelected!(selectedAssets);
      }

      // MediaSelectionFlow 모달 닫기 - processing 액션 전달
      if (mounted) {
        Navigator.pop(context, {
          'action': 'processing',
          'selectedAssets': selectedAssets,
        });
      }
    } catch (e) {
      // 에러 발생 시에도 모달 닫기
      if (mounted) {
        Navigator.pop(context);
      }
      rethrow;
    }
  }
}
