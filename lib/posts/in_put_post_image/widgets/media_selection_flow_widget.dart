import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core/app_theme.dart';
import '/app_state.dart';
import '../delegates/korean_asset_picker_delegate.dart';
import '../delegates/korean_camera_picker_delegate.dart';
import '../services/image_download_service.dart';
import '/pages/thumbnail_selection/thumbnail_selection_page.dart';
import '../services/selection_result_processor.dart';
import 'custom_asset_picker_delegate.dart';
import 'media_editor_widget.dart';
import '../utils/no_animation_page_route.dart';

/// 미디어 선택부터 편집까지 하나의 플로우로 처리하는 위젯
class MediaSelectionFlowWidget extends StatefulWidget {
  const MediaSelectionFlowWidget({
    super.key,
    required this.box,
    required this.onComplete,
    this.onMultiComplete,
    this.initialImageUrl,
    this.startWithEditor = false,
    this.existingImageUrls,
    this.existingAspectRatios,
    this.existingAssetIds,
    this.isAddMode = false,
    this.currentIndex,
  });

  final String box; // 'A' or 'B'
  final Function(String imageUrl) onComplete; // 단일 이미지 완료 콜백
  final Function(List<String> imageUrls)? onMultiComplete; // 멀티 이미지 완료 콜백
  final String? initialImageUrl; // 편집할 기존 이미지 URL
  final bool startWithEditor; // 에디터로 바로 시작할지 여부
  final List<String>? existingImageUrls; // 기존 이미지 URL들 (재사용용)
  final List<double>? existingAspectRatios; // 기존 이미지 비율들
  final List<String>? existingAssetIds; // 기존 AssetEntity ID들
  final bool isAddMode; // 추가 모드인지 여부
  final int? currentIndex; // 현재 보고 있는 이미지 인덱스

  @override
  State<MediaSelectionFlowWidget> createState() => _MediaSelectionFlowWidgetState();
}

class _MediaSelectionFlowWidgetState extends State<MediaSelectionFlowWidget> {
  // 선택된 파일
  File? _selectedFile;
  
  // 멀티 이미지 선택 시 사용
  List<File> _allSelectedFiles = [];
  List<AssetEntity> _selectedAssets = []; // AssetEntity 저장
  int _currentEditIndex = 0;
  
  // 업로드 상태
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  
  // 재시도 상태 추적
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    
    // 기존 이미지가 있고 에디터로 바로 시작하는 경우
    if (widget.startWithEditor && widget.initialImageUrl != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _downloadAndEditExistingImage();
      });
    } else {
      // 에디터로 바로 시작하지 않는 경우, 피커 열기
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openPicker();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  /// AssetPicker 열기
  Future<void> _openPicker() async {
    try {
      // 기존에 선택된 AssetEntity 복원
      List<AssetEntity> selectedAssets = [];
      
      print('[AssetPicker] Opening picker...');
      print('[AssetPicker] Box: ${widget.box}');
      print('[AssetPicker] isAddMode: ${widget.isAddMode}');
      print('[AssetPicker] existingAssetIds: ${widget.existingAssetIds?.length ?? 0}');
      
      if (widget.existingAssetIds != null && widget.existingAssetIds!.isNotEmpty) {
        for (String id in widget.existingAssetIds!) {
          try {
            final asset = await AssetEntity.fromId(id);
            if (asset != null) {
              selectedAssets.add(asset);
            }
          } catch (e) {
            print('AssetEntity 복원 실패 (ID: $id): $e');
          }
        }
        print('[AssetPicker] 복원된 AssetEntity 개수: ${selectedAssets.length}');
      }
      
      print('[AssetPicker] Config:');
      print('  - Max assets: 4');
      print('  - Special item position: NONE (using floating camera button)');
      print('  - Selected assets count: ${selectedAssets.length}');
      print('  - Grid count: 4');
      print('  - Sort by modified date: true');
      print('  - Should revert grid: false (최신 사진 맨 위)');
      
      // 커스텀 델리게이트를 사용하여 플로팅 카메라 버튼 추가
      final List<AssetEntity>? result = await AssetPicker.pickAssetsWithDelegate(
        context,
        delegate: CustomAssetPickerBuilderDelegate(
          provider: DefaultAssetPickerProvider(
            selectedAssets: selectedAssets,
            maxAssets: 4,
            requestType: RequestType.image,
            sortPathsByModifiedDate: true, // 최신 사진을 맨 위에 표시
          ),
          initialPermission: PermissionState.authorized,
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
            print('[AssetPicker] Floating camera button pressed');
            
            // 정렬 순서 디버깅
            try {
              final paths = await PhotoManager.getAssetPathList(type: RequestType.image);
              if (paths.isNotEmpty) {
                final firstPath = paths.first;
                final assets = await firstPath.getAssetListPaged(page: 0, size: 5);
                print('[AssetPicker] 첫 5개 사진 생성 날짜:');
                for (int i = 0; i < assets.length; i++) {
                  final asset = assets[i];
                  final createDate = asset.createDateTime;
                  print('  ${i + 1}. ${createDate.toString()} - ${asset.title ?? "No title"}');
                }
              }
            } catch (e) {
              print('[AssetPicker] 정렬 디버깅 실패: $e');
            }
            
            // 카메라 열기
            final AssetEntity? cameraResult = await _openCameraForPicker(context);
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

      print('[AssetPicker] Picker result: ${result?.length ?? 0} items selected');
      
      if (result != null && result.isNotEmpty) {
        // 기존 이미지가 있는 경우 - diff 처리
        if (widget.existingImageUrls != null && 
            widget.existingImageUrls!.isNotEmpty) {
          print('[AssetPicker] Processing with existing images (diff mode)');
          await _processSelectionResult(result);
          return;
        }
        
        // 기존 이미지가 없거나 첫 번째 이미지인 경우 - 기존 플로우 유지
        // 1장만 선택한 경우 바로 편집
        if (result.length == 1) {
          print('[AssetPicker] Single image selected, opening editor');
          final file = await result.first.file;
          if (file != null) {
            setState(() {
              _selectedFile = file;
              // 단일 선택 시에도 AssetEntity 저장
              _selectedAssets = result;
            });
          }
        } else {
          print('[AssetPicker] Multiple images selected (${result.length}), opening thumbnail selection');
          // 여러 장 선택한 경우 썸네일 선택 페이지로 이동
          final files = await Future.wait(
            result.map((asset) async => await asset.file)
          );
          
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
        print('[AssetPicker] Picker cancelled');
        // 피커 취소 시 항상 모달 닫기
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        _showToast('이미지 선택 중 오류가 발생했습니다: $e', isError: true);
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
        builder: (context) => ThumbnailSelectionPage(
          imagePaths: files,
          box: widget.box,
        ),
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
      final AssetEntity? entity = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: CameraPickerConfig(
          enableRecording: false, // 사진만
          textDelegate: const CustomKoreanCameraPickerTextDelegate(),
        ),
      );
      
      if (entity != null) {
        print('[AssetPicker] Photo taken from camera in picker');
        return entity;
      } else {
        print('[AssetPicker] Camera cancelled in picker');
        return null;
      }
    } catch (e) {
      print('[AssetPicker] Camera error: $e');
      return null;
    }
  }

  /// 기존 이미지 다운로드 후 편집
  Future<void> _downloadAndEditExistingImage() async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      
      // Firebase Storage URL에서 이미지 다운로드
      final localPath = await ImageDownloadService.downloadImage(widget.initialImageUrl!);
      final file = File(localPath);
      
      setState(() {
        _isUploading = false;
        _selectedFile = file;
      });
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      
      // 에러 발생 시 모달 닫기
      if (mounted) {
        _showToast('이미지를 불러올 수 없습니다: $e', isError: true);
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
      onSingleComplete: widget.onComplete,
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
    setState(() {
      _isUploading = true;
    });
    
    final appState = Provider.of<AppState>(context, listen: false);
    final processor = SelectionResultProcessor(
      context: context,
      appState: appState,
      box: widget.box,
      existingAssetIds: widget.existingAssetIds,
      onProgressUpdate: (progress) {
        setState(() {
          _uploadProgress = progress;
        });
      },
      onMultiComplete: widget.onMultiComplete,
    );
    
    await processor.processSelectionResult(selectedAssets);
    
    setState(() {
      _isUploading = false;
    });
  }
}