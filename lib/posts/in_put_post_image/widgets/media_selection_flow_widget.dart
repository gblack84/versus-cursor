import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '/core/app_theme.dart';
import '/app_state.dart';
import '../delegates/korean_asset_picker_delegate.dart';
import '../delegates/korean_camera_picker_delegate.dart';
import '../services/image_download_service.dart';
import '../services/media_upload_service.dart';
import '/pages/thumbnail_selection/thumbnail_selection_page.dart';
import '../services/selection_result_processor.dart';
import 'custom_asset_picker_delegate.dart';

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
        // 취소한 경우 모달 닫기
        if (mounted) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 선택 중 오류가 발생했습니다: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
        Navigator.pop(context);
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
      MaterialPageRoute(
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지를 불러올 수 없습니다: $e'),
            backgroundColor: AppTheme.of(context).error,
          ),
        );
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
          child: Stack(
            children: [
              // 파일이 선택되면 에디터 표시
              if (_selectedFile != null)
                _buildEditorPage()
              else
                _buildLoadingPage(),
            
              // 업로드 진행 오버레이
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
                        '업로드 중... ${(_uploadProgress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
    return Stack(
      children: [
        // ProImageEditor
        ProImageEditor.file(
          _selectedFile!,
            callbacks: ProImageEditorCallbacks(
              onImageEditingComplete: (Uint8List bytes) async {
                print('onImageEditingComplete 호출됨');
                try {
                  // 업로드 진행 상태 표시
                  setState(() {
                    _isUploading = true;
                    _uploadProgress = 0.2;
                  });
                  
                  // AppState 접근
                  final appState = Provider.of<AppState>(context, listen: false);
                  
                  // 멀티 이미지 처리
                  if (_allSelectedFiles.isNotEmpty) {
                    final reorderedUrls = <String>[];
                    final reorderedRatios = <double>[];
                    
                    // 1. 편집된 이미지 업로드
                    setState(() {
                      _uploadProgress = 0.2;
                    });
                    
                    Map<String, dynamic> editedResult;
                    String? editedImageUrl;
                    try {
                      editedResult = await MediaUploadService.uploadImageWithVariants(
                        imageBytes: bytes,
                        box: widget.box,
                        onModerationStatusUpdate: (status) {
                          print('[MediaSelection] 편집 이미지 검열 상태 업데이트: $status');
                          if (editedImageUrl != null && mounted) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            appState.updateImageModerationStatus(
                              editedImageUrl!,
                              status,
                              isBoxA: widget.box == 'A',
                            );
                          }
                        },
                        onRejected: (reason) {
                          print('[MediaSelection] 편집 이미지 거부됨: $reason');
                          if (editedImageUrl != null && mounted) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            
                            // 거부된 이미지 제거
                            if (widget.box == 'A') {
                              final imageIndex = appState.uploadImageA.indexOf(editedImageUrl!);
                              if (imageIndex >= 0) {
                                appState.removeFromUploadImageA(editedImageUrl!);
                                if (imageIndex < appState.uploadImageAspectRatioA.length) {
                                  appState.removeAtIndexFromUploadImageAspectRatioA(imageIndex);
                                }
                                if (imageIndex < appState.assetEntityIdsA.length) {
                                  appState.removeAtIndexFromAssetEntityIdsA(imageIndex);
                                }
                              }
                            } else {
                              final imageIndex = appState.uploadImageB.indexOf(editedImageUrl!);
                              if (imageIndex >= 0) {
                                appState.removeFromUploadImageB(editedImageUrl!);
                                if (imageIndex < appState.uploadImageAspectRatioB.length) {
                                  appState.removeAtIndexFromUploadImageAspectRatioB(imageIndex);
                                }
                                if (imageIndex < appState.assetEntityIdsB.length) {
                                  appState.removeAtIndexFromAssetEntityIdsB(imageIndex);
                                }
                              }
                            }
                            
                            // 스낵바는 InPutPostImageWidget에서 표시됨
                          }
                        },
                      );
                    } catch (e) {
                      // 검열 실패 또는 업로드 실패
                      if (mounted) {
                        setState(() {
                          _isUploading = false;
                        });
                        
                        String errorMessage = '이미지 업로드 실패';
                        if (e.toString().contains('커뮤니티 가이드라인')) {
                          errorMessage = e.toString();
                        } else if (e.toString().contains('부적절한')) {
                          errorMessage = e.toString();
                        }
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: AppTheme.of(context).error,
                            duration: const Duration(seconds: 5),
                          ),
                        );
                        Navigator.pop(context);
                      }
                      return;
                    }
                    final editedDisplayUrl = editedResult['urls']['display'];
                    final editedAspectRatio = editedResult['aspectRatio'];
                    editedImageUrl = editedDisplayUrl;
                    
                    // 추가 모드인지 확인
                    if (widget.isAddMode && widget.currentIndex != null) {
                      // 추가 모드일 때는 새 이미지를 추가
                      print('추가 모드: 현재 인덱스 ${widget.currentIndex}에서 이미지 추가');
                      
                      // 1. 먼저 기존 이미지들을 그대로 복사
                      if (widget.existingImageUrls != null && widget.existingAspectRatios != null) {
                        reorderedUrls.addAll(widget.existingImageUrls!);
                        reorderedRatios.addAll(widget.existingAspectRatios!);
                      }
                      
                      // 2. 새 이미지를 추가
                      reorderedUrls.add(editedDisplayUrl);
                      reorderedRatios.add(editedAspectRatio);
                      
                      print('새 이미지 추가 완료. 총 ${reorderedUrls.length}개 이미지');
                    } else {
                      // 기존 모드: 편집된 이미지를 맨 앞에 배치 (썸네일로 선택되었으므로)
                      reorderedUrls.add(editedDisplayUrl);
                      reorderedRatios.add(editedAspectRatio);
                      print('편집된 이미지 업로드 완료 (썸네일)');
                    }
                    
                    // 첫 번째 이미지 즉시 프리캐싱
                    final firstImagePrecache = precacheImage(
                      CachedNetworkImageProvider(editedDisplayUrl), 
                      context
                    ).catchError((e) {
                      print('첫 이미지 프리캐싱 실패 (무시됨): $e');
                    });
                    
                    setState(() {
                      _uploadProgress = 0.4;
                    });
                    
                    // 2. 나머지 이미지들 처리 (편집된 이미지 제외)
                    // 추가 모드가 아닐 때만 나머지 이미지 처리
                    if (!widget.isAddMode && widget.existingImageUrls != null && widget.existingAspectRatios != null && widget.existingImageUrls!.isNotEmpty) {
                      // 기존 URL 재사용 모드
                      for (int i = 0; i < widget.existingImageUrls!.length; i++) {
                        if (i != _currentEditIndex) {
                          reorderedUrls.add(widget.existingImageUrls![i]);
                          if (i < widget.existingAspectRatios!.length) {
                            reorderedRatios.add(widget.existingAspectRatios![i]);
                          }
                        }
                      }
                      
                      setState(() {
                        _uploadProgress = 0.8;
                      });
                      
                      print('기존 이미지 URL 재사용 완료');
                    } else {
                      // 새로 업로드 모드 (최초 선택 시)
                      final uploadFutures = <Future<Map<String, dynamic>>>[];
                      final fileBytesFutures = <Future<Uint8List>>[];
                      
                      // 파일 읽기를 먼저 병렬로 처리 (편집된 이미지 제외)
                      for (int i = 0; i < _allSelectedFiles.length; i++) {
                        if (i != _currentEditIndex) {
                          fileBytesFutures.add(_allSelectedFiles[i].readAsBytes());
                        }
                      }
                      
                      if (fileBytesFutures.isNotEmpty) {
                        final allFileBytes = await Future.wait(fileBytesFutures);
                        
                        // 업로드 작업을 병렬로 시작
                        for (final fileBytes in allFileBytes) {
                          uploadFutures.add(
                            MediaUploadService.uploadImageWithVariants(
                              imageBytes: fileBytes,
                              box: widget.box,
                              onModerationStatusUpdate: (status) {
                                // 검열 상태 업데이트는 나중에 URL이 확정된 후 처리
                              },
                              onRejected: (reason) {
                                // 거부 처리도 나중에 URL이 확정된 후 처리
                              },
                            ).catchError((e) {
                              // 개별 이미지 업로드 실패 시 로그만 남기고 계속
                              print('[MediaSelection] 이미지 업로드 실패 (건너뜀): $e');
                              return <String, dynamic>{
                                'urls': {'display': '', 'original': '', 'thumbnail': ''},
                                'aspectRatio': 1.0,
                              };
                            })
                          );
                        }
                        
                        setState(() {
                          _uploadProgress = 0.6;
                        });
                        
                        // 모든 업로드 완료 대기
                        final results = await Future.wait(uploadFutures);
                        
                        // 결과 처리 및 프리캐싱
                        final precacheFutures = <Future<void>>[];
                        for (final result in results) {
                          final displayUrl = result['urls']['display'];
                          // 빈 URL은 건너뜀 (업로드 실패한 경우)
                          if (displayUrl != null && displayUrl.isNotEmpty) {
                            reorderedUrls.add(displayUrl);
                            reorderedRatios.add(result['aspectRatio']);
                            
                            // 백그라운드 프리캐싱
                            precacheFutures.add(
                              precacheImage(
                                CachedNetworkImageProvider(displayUrl), 
                                context
                              ).catchError((e) {
                                print('프리캐싱 실패 (무시됨): $e');
                              })
                            );
                          }
                        }
                        
                        // 나머지 이미지들은 백그라운드에서 계속 프리캐싱
                        Future.wait(precacheFutures).then((_) {
                          print('모든 이미지 프리캐싱 완료');
                        });
                      }
                    }
                    
                    print('전체 이미지 처리 완료: ${reorderedUrls.length}개 (원본 ${_allSelectedFiles.length}개에서)');
                    
                    // 첫 이미지 프리캐싱 완료 대기
                    await firstImagePrecache;
                    
                    setState(() {
                      _uploadProgress = 0.9;
                    });
                    
                    // 3. AssetEntity ID 순서 맞추기
                    final reorderedAssetIds = <String>[];
                    if (widget.isAddMode) {
                      // 추가 모드: 기존 ID들 + 새 ID
                      if (widget.existingAssetIds != null) {
                        reorderedAssetIds.addAll(widget.existingAssetIds!);
                      }
                      // 새로 선택된 AssetEntity의 ID 추가
                      if (_selectedAssets.isNotEmpty && _currentEditIndex < _selectedAssets.length) {
                        reorderedAssetIds.add(_selectedAssets[_currentEditIndex].id);
                      }
                    } else if (_selectedAssets.isNotEmpty) {
                      // 편집 모드: 편집된 이미지의 AssetEntity ID를 맨 앞에
                      if (_currentEditIndex < _selectedAssets.length) {
                        reorderedAssetIds.add(_selectedAssets[_currentEditIndex].id);
                      }
                      // 나머지 AssetEntity ID들
                      for (int i = 0; i < _selectedAssets.length; i++) {
                        if (i != _currentEditIndex) {
                          reorderedAssetIds.add(_selectedAssets[i].id);
                        }
                      }
                    }
                    
                    // 4. AppState에 저장
                    appState.update(() {
                      if (widget.box == 'A') {
                        appState.uploadImageA = reorderedUrls;
                        appState.uploadImageAspectRatioA = reorderedRatios;
                        appState.assetEntityIdsA = reorderedAssetIds;
                      } else {
                        appState.uploadImageB = reorderedUrls;
                        appState.uploadImageAspectRatioB = reorderedRatios;
                        appState.assetEntityIdsB = reorderedAssetIds;
                      }
                    });
                    
                    // 4. 콜백 호출
                    if (widget.onMultiComplete != null) {
                      widget.onMultiComplete!(reorderedUrls);
                    }
                    
                    setState(() {
                      _uploadProgress = 1.0;
                    });
                    
                    // 모달 닫기
                    if (mounted) {
                      Navigator.pop(context);
                      print('멀티 이미지 업로드 완료 및 모달 닫기');
                    }
                    
                  } else {
                    // 단일 이미지 처리
                    setState(() {
                      _uploadProgress = 0.5;
                    });
                    
                    // 나중에 콜백에서 사용할 변수들
                    String? uploadedImageUrl;
                    double? uploadedAspectRatio;
                    
                    try {
                      final appState = Provider.of<AppState>(context, listen: false);
                      
                      print('[MediaSelection] 업로드 시작');
                      
                      final result = await MediaUploadService.uploadImageWithVariants(
                        imageBytes: bytes,
                        box: widget.box,
                        onModerationStatusUpdate: (status) {
                          print('[MediaSelection] 검열 상태 업데이트: $status');
                          if (mounted) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            // 먼저 업로드된 URL을 찾아서 상태 업데이트
                            final currentImages = widget.box == 'A' ? appState.uploadImageA : appState.uploadImageB;
                            if (currentImages.isNotEmpty) {
                              final lastImage = currentImages.last;
                              appState.updateImageModerationStatus(
                                lastImage,
                                status,
                                isBoxA: widget.box == 'A',
                              );
                            }
                          }
                        },
                        onRejected: (reason) {
                          print('[MediaSelection] 이미지 거부됨: $reason');
                          if (mounted) {
                            final appState = Provider.of<AppState>(context, listen: false);
                            
                            // 거부된 이미지 제거
                            if (widget.box == 'A') {
                              if (appState.uploadImageA.isNotEmpty) {
                                final lastImage = appState.uploadImageA.last;
                                final imageIndex = appState.uploadImageA.length - 1;
                                appState.removeFromUploadImageA(lastImage);
                                if (imageIndex < appState.uploadImageAspectRatioA.length) {
                                  appState.removeAtIndexFromUploadImageAspectRatioA(imageIndex);
                                }
                                if (imageIndex < appState.assetEntityIdsA.length) {
                                  appState.removeAtIndexFromAssetEntityIdsA(imageIndex);
                                }
                              }
                            } else {
                              if (appState.uploadImageB.isNotEmpty) {
                                final lastImage = appState.uploadImageB.last;
                                final imageIndex = appState.uploadImageB.length - 1;
                                appState.removeFromUploadImageB(lastImage);
                                if (imageIndex < appState.uploadImageAspectRatioB.length) {
                                  appState.removeAtIndexFromUploadImageAspectRatioB(imageIndex);
                                }
                                if (imageIndex < appState.assetEntityIdsB.length) {
                                  appState.removeAtIndexFromAssetEntityIdsB(imageIndex);
                                }
                              }
                            }
                            
                            // 스낵바는 InPutPostImageWidget에서 표시됨
                          }
                        },
                      );
                      print('[MediaSelection] 업로드 완료');
                      
                      final displayUrl = result['urls']['display'] as String;
                      uploadedImageUrl = displayUrl;
                      uploadedAspectRatio = result['aspectRatio'] as double;
                      
                      // 초기 검열 상태를 pending으로 설정
                      appState.updateImageModerationStatus(
                        uploadedImageUrl,
                        'pending',
                        isBoxA: widget.box == 'A',
                      );
                      
                      // 검열 모니터링은 부모 위젯(InPutPostImageWidget)에서 처리
                    } catch (e) {
                      // 업로드 실패
                      if (mounted) {
                        setState(() {
                          _isUploading = false;
                        });
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('이미지 업로드에 실패했습니다.'),
                            backgroundColor: AppTheme.of(context).error,
                          ),
                        );
                        Navigator.pop(context);
                      }
                      return;
                    }
                    
                    setState(() {
                      _uploadProgress = 0.9;
                    });
                    
                    final displayUrl = uploadedImageUrl;
                    
                    // 편집 모드인지 확인 (startWithEditor가 true이고 initialImageUrl이 있는 경우)
                    final isEditMode = widget.startWithEditor && widget.initialImageUrl != null;
                    
                    if (!isEditMode) {
                      // 편집 모드가 아닐 때만 AppState에 추가
                      appState.update(() {
                        if (widget.box == 'A') {
                          appState.addToUploadImageA(displayUrl);
                          appState.addToUploadImageAspectRatioA(uploadedAspectRatio!);
                          // 단일 이미지 선택 시 AssetEntity ID 저장
                          if (_selectedAssets.isNotEmpty) {
                            appState.addToAssetEntityIdsA(_selectedAssets.first.id);
                          }
                        } else {
                          appState.addToUploadImageB(displayUrl);
                          appState.addToUploadImageAspectRatioB(uploadedAspectRatio!);
                          if (_selectedAssets.isNotEmpty) {
                            appState.addToAssetEntityIdsB(_selectedAssets.first.id);
                          }
                        }
                      });
                    }
                    
                    // 프리캐싱 시작
                    precacheImage(CachedNetworkImageProvider(displayUrl), context).catchError((e) {
                      print('프리캐싱 실패 (무시됨): $e');
                    });
                    
                    // 콜백 호출
                    widget.onComplete(displayUrl);
                    
                    setState(() {
                      _uploadProgress = 1.0;
                    });
                    
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
                      _isUploading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('이미지 업로드 실패: $e'),
                        backgroundColor: AppTheme.of(context).error,
                      ),
                    );
                  }
                }
              },
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
              // TODO: customWidgets 설정 추가 필요
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
                if (_allSelectedFiles.isNotEmpty) {
                  // 썸네일 선택 페이지로 돌아가기
                  setState(() {
                    _selectedFile = null;
                  });
                  _navigateToThumbnailSelection(_allSelectedFiles);
                } else {
                  // 피커로 돌아가기
                  setState(() {
                    _selectedFile = null;
                  });
                  _openPicker();
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
                      : (_allSelectedFiles.isNotEmpty ? '썸네일' : '갤러리'),
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