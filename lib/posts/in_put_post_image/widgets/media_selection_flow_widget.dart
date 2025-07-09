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
    this.replaceIndex,
  });

  final String box; // 'A' or 'B'
  final Function(String imageUrl) onComplete; // 단일 이미지 완료 콜백
  final Function(List<String> imageUrls)? onMultiComplete; // 멀티 이미지 완료 콜백
  final String? initialImageUrl; // 편집할 기존 이미지 URL
  final bool startWithEditor; // 에디터로 바로 시작할지 여부
  final List<String>? existingImageUrls; // 기존 이미지 URL들 (재사용용)
  final List<double>? existingAspectRatios; // 기존 이미지 비율들
  final List<String>? existingAssetIds; // 기존 AssetEntity ID들
  final int? replaceIndex; // 교체할 이미지 인덱스 (2,3,4번 이미지용)

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
        print('복원된 AssetEntity 개수: ${selectedAssets.length}');
      }
      
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          selectedAssets: selectedAssets, // 이전 선택 표시
          maxAssets: widget.replaceIndex != null ? 1 : 4,  // 교체 모드에서는 1장만
          requestType: RequestType.image,
          textDelegate: const CustomKoreanAssetPickerTextDelegate(),
          gridCount: 4,
          specialItemPosition: SpecialItemPosition.prepend,
          specialItemBuilder: (BuildContext context, AssetPathEntity? path, int length) {
            return _buildCameraButton(context);
          },
          pickerTheme: ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            colorScheme: ColorScheme.dark(
              primary: AppTheme.of(context).primary,
              secondary: AppTheme.of(context).primary, // 확인 버튼 색상
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
        ),
      );

      if (result != null && result.isNotEmpty) {
        // replaceIndex가 있으면 바로 업로드 (편집 단계 없음)
        if (widget.replaceIndex != null) {
          final file = await result.first.file;
          if (file != null) {
            // 바로 업로드 시작
            await _uploadImageDirectly(file, result.first);
          }
          return;
        }
        
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
        });
      }
    } else {
      // 취소한 경우 모달 닫기
      if (mounted) {
        Navigator.pop(context);
      }
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

  /// 카메라 버튼 빌드
  Widget _buildCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final AssetEntity? entity = await CameraPicker.pickFromCamera(
          context,
          pickerConfig: CameraPickerConfig(
            enableRecording: false, // 사진만
            textDelegate: const CustomKoreanCameraPickerTextDelegate(),
          ),
        );
        
        if (entity != null) {
          final file = await entity.file;
          if (file != null && mounted) {
            setState(() {
              _selectedFile = file;
            });
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 35,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '카메라',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
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
        child: CircularProgressIndicator(
          color: Colors.white,
        ),
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
                    
                    final editedResult = await MediaUploadService.uploadImageWithVariants(
                      imageBytes: bytes,
                      box: widget.box,
                    );
                    final editedDisplayUrl = editedResult['urls']['display'];
                    final editedAspectRatio = editedResult['aspectRatio'];
                    
                    // 편집된 이미지를 맨 앞에 배치 (썸네일로 선택되었으므로)
                    reorderedUrls.add(editedDisplayUrl);
                    reorderedRatios.add(editedAspectRatio);
                    print('편집된 이미지 업로드 완료 (썸네일)');
                    
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
                    // 기존 URL이 있으면 재사용, 없으면 새로 업로드
                    if (widget.existingImageUrls != null && widget.existingAspectRatios != null) {
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
                            )
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
                    if (_selectedAssets.isNotEmpty) {
                      // 편집된 이미지의 AssetEntity ID를 맨 앞에
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
                    
                    final result = await MediaUploadService.uploadImageWithVariants(
                      imageBytes: bytes,
                      box: widget.box,
                    );
                    
                    setState(() {
                      _uploadProgress = 0.9;
                    });
                    
                    final displayUrl = result['urls']['display'];
                    
                    // AppState에 저장
                    appState.update(() {
                      if (widget.box == 'A') {
                        appState.addToUploadImageA(displayUrl);
                        appState.addToUploadImageAspectRatioA(result['aspectRatio']);
                        // 단일 이미지 선택 시 AssetEntity ID 저장
                        if (_selectedAssets.isNotEmpty) {
                          appState.addToAssetEntityIdsA(_selectedAssets.first.id);
                        }
                      } else {
                        appState.addToUploadImageB(displayUrl);
                        appState.addToUploadImageAspectRatioB(result['aspectRatio']);
                        if (_selectedAssets.isNotEmpty) {
                          appState.addToAssetEntityIdsB(_selectedAssets.first.id);
                        }
                      }
                    });
                    
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
  
  /// 직접 업로드 (교체 모드용)
  Future<void> _uploadImageDirectly(File file, AssetEntity asset) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.2;
      });
      
      // 파일 읽기
      final bytes = await file.readAsBytes();
      
      setState(() {
        _uploadProgress = 0.5;
      });
      
      // 업로드
      final result = await MediaUploadService.uploadImageWithVariants(
        imageBytes: bytes,
        box: widget.box,
      );
      
      setState(() {
        _uploadProgress = 0.8;
      });
      
      final displayUrl = result['urls']['display'];
      final aspectRatio = result['aspectRatio'];
      
      // AppState 업데이트
      final appState = Provider.of<AppState>(context, listen: false);
      appState.update(() {
        if (widget.box == 'A') {
          // 특정 인덱스 교체
          if (widget.replaceIndex! < appState.uploadImageA.length) {
            appState.uploadImageA[widget.replaceIndex!] = displayUrl;
            appState.uploadImageAspectRatioA[widget.replaceIndex!] = aspectRatio;
            appState.assetEntityIdsA[widget.replaceIndex!] = asset.id;
          } else {
            // 새로 추가
            appState.addToUploadImageA(displayUrl);
            appState.addToUploadImageAspectRatioA(aspectRatio);
            appState.addToAssetEntityIdsA(asset.id);
          }
        } else {
          // B 박스
          if (widget.replaceIndex! < appState.uploadImageB.length) {
            appState.uploadImageB[widget.replaceIndex!] = displayUrl;
            appState.uploadImageAspectRatioB[widget.replaceIndex!] = aspectRatio;
            appState.assetEntityIdsB[widget.replaceIndex!] = asset.id;
          } else {
            // 새로 추가
            appState.addToUploadImageB(displayUrl);
            appState.addToUploadImageAspectRatioB(aspectRatio);
            appState.addToAssetEntityIdsB(asset.id);
          }
        }
      });
      
      // 프리캐싱 시작
      precacheImage(CachedNetworkImageProvider(displayUrl), context).catchError((e) {
        print('프리캐싱 실패 (무시됨): $e');
      });
      
      setState(() {
        _uploadProgress = 1.0;
      });
      
      // 콜백 호출
      widget.onComplete(displayUrl);
      
      // 모달 닫기
      if (mounted) {
        Navigator.pop(context);
        print('교체 모드 업로드 완료 및 모달 닫기');
      }
    } catch (e) {
      print('직접 업로드 에러: $e');
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
        Navigator.pop(context);
      }
    }
  }
}

/// 커스텀 피커 델리게이트 - 확인 버튼 동작 커스터마이징
class CustomAssetPickerBuilderDelegate extends DefaultAssetPickerBuilderDelegate {
  CustomAssetPickerBuilderDelegate({
    required super.provider,
    required super.initialPermission,
    super.gridCount,
    super.pickerTheme,
    super.specialItemPosition,
    super.specialItemBuilder,
    super.loadingIndicatorBuilder,
    super.shouldRevertGrid,
    super.limitedPermissionOverlayPredicate,
    super.pathNameBuilder,
    super.textDelegate,
    super.themeColor,
    super.locale,
    super.keepScrollOffset,
    required this.onCompleted,
  });
  
  final Function(List<AssetEntity>) onCompleted;
  
  @override
  Widget confirmButton(BuildContext context) {
    return Consumer<DefaultAssetPickerProvider>(
      builder: (BuildContext context, DefaultAssetPickerProvider p, Widget? child) {
        final shouldAllowConfirm = p.selectedAssets.isNotEmpty;
        
        return MaterialButton(
          onPressed: shouldAllowConfirm
              ? () {
                  // 선택 완료 콜백 호출
                  onCompleted(p.selectedAssets);
                }
              : null,
          minWidth: 0,
          height: 40,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: shouldAllowConfirm ? themeColor : Colors.grey,
          disabledColor: Colors.grey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '${textDelegate.confirm} ${p.selectedAssets.isNotEmpty ? '(${p.selectedAssets.length})' : ''}',
              style: TextStyle(
                color: shouldAllowConfirm ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        );
      },
    );
  }
}