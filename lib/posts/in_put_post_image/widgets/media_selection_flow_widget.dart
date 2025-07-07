import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:provider/provider.dart';
import '/core/app_theme.dart';
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
  });

  final String box; // 'A' or 'B'
  final Function(String imageUrl) onComplete; // 단일 이미지 완료 콜백
  final Function(List<String> imageUrls)? onMultiComplete; // 멀티 이미지 완료 콜백
  final String? initialImageUrl; // 편집할 기존 이미지 URL
  final bool startWithEditor; // 에디터로 바로 시작할지 여부

  @override
  State<MediaSelectionFlowWidget> createState() => _MediaSelectionFlowWidgetState();
}

class _MediaSelectionFlowWidgetState extends State<MediaSelectionFlowWidget> {
  // 선택된 파일
  File? _selectedFile;
  
  // 멀티 이미지 선택 시 사용
  List<File> _allSelectedFiles = [];
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
      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 4,  // 최대 4장으로 변경
          requestType: RequestType.image,
          themeColor: AppTheme.of(context).primary,
          textDelegate: const CustomKoreanAssetPickerTextDelegate(),
          gridCount: 4,
          specialItemPosition: SpecialItemPosition.prepend,
          specialItemBuilder: (BuildContext context, AssetPathEntity? path, int length) {
            return _buildCameraButton(context);
          },
        ),
      );

      if (result != null && result.isNotEmpty) {
        // 1장만 선택한 경우 바로 편집
        if (result.length == 1) {
          final file = await result.first.file;
          if (file != null) {
            setState(() {
              _selectedFile = file;
            });
          }
        } else {
          // 여러 장 선택한 경우 썸네일 선택 페이지로 이동
          final files = await Future.wait(
            result.map((asset) async => await asset.file)
          );
          
          final validFiles = files.whereType<File>().toList();
          if (validFiles.isNotEmpty && mounted) {
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

  /// Firebase Storage에 이미지 업로드 (리사이징 포함)
  Future<String> _uploadToFirebase(Uint8List bytes) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      // MediaUploadService를 사용하여 리사이징 및 업로드
      final urls = await MediaUploadService.uploadImageWithVariants(
        imageBytes: bytes,
        box: widget.box,
      );
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }

      // display URL을 기본으로 반환 (UI 표시용)
      return urls['display']!;
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
      rethrow;
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
                  // Firebase Storage에 업로드
                  final url = await _uploadToFirebase(bytes);
                  print('Firebase 업로드 완료: $url');
                  
                  // 멀티 이미지 처리
                  if (_allSelectedFiles.isNotEmpty) {
                    // 선택된 이미지를 맨 앞으로 재배열하기 위한 리스트
                    final reorderedUrls = <String>[];
                    
                    // 1. 편집된 이미지(대표 이미지)를 맨 앞에 추가
                    reorderedUrls.add(url);
                    print('대표 이미지 추가 (원래 인덱스: $_currentEditIndex)');
                    
                    // 2. 나머지 이미지들을 원래 순서대로 업로드 및 추가
                    for (int i = 0; i < _allSelectedFiles.length; i++) {
                      if (i != _currentEditIndex) {
                        final file = _allSelectedFiles[i];
                        final fileBytes = await file.readAsBytes();
                        final additionalUrl = await _uploadToFirebase(fileBytes);
                        reorderedUrls.add(additionalUrl);
                        print('추가 이미지 업로드 (인덱스: $i)');
                      }
                    }
                    
                    // 모든 URL을 AppState에 추가
                    print('총 ${reorderedUrls.length}개 이미지 업로드 완료');
                    print('순서: 대표 이미지가 맨 앞, 나머지는 원래 순서대로');
                    
                    // 멀티 이미지 콜백이 있으면 사용, 없으면 첫 번째 URL만 전달
                    if (widget.onMultiComplete != null) {
                      widget.onMultiComplete!(reorderedUrls);
                    } else {
                      widget.onComplete(reorderedUrls.first);
                    }
                  } else {
                    // 단일 이미지 처리
                    print('onComplete 콜백 호출 직전');
                    widget.onComplete(url);
                    print('onComplete 콜백 호출 완료');
                  }
                  
                  // 모달 닫기
                  if (mounted) {
                    Navigator.pop(context);
                    print('모달 닫기 완료');
                  }
                } catch (e) {
                  // 에러 처리
                  print('이미지 업로드 에러: $e');
                  if (mounted) {
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
            ),
        ),
        
        // 커스텀 뒤로가기 버튼 (X 버튼 위에 오버레이)
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () {
                // 멀티 이미지가 있으면 썸네일 선택 페이지로, 없으면 피커로
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
              },
            ),
          ),
        ),
      ],
    );
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