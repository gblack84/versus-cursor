import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '/core/app_theme.dart';
import '../delegates/korean_asset_picker_delegate.dart';
import '../delegates/korean_camera_picker_delegate.dart';
import '../services/image_download_service.dart';

/// 미디어 선택부터 편집까지 하나의 플로우로 처리하는 위젯
class MediaSelectionFlowWidget extends StatefulWidget {
  const MediaSelectionFlowWidget({
    super.key,
    required this.box,
    required this.onComplete,
    this.initialImageUrl,
    this.startWithEditor = false,
  });

  final String box; // 'A' or 'B'
  final Function(String imageUrl) onComplete; // 완료 콜백
  final String? initialImageUrl; // 편집할 기존 이미지 URL
  final bool startWithEditor; // 에디터로 바로 시작할지 여부

  @override
  State<MediaSelectionFlowWidget> createState() => _MediaSelectionFlowWidgetState();
}

class _MediaSelectionFlowWidgetState extends State<MediaSelectionFlowWidget> {
  // 선택된 파일
  File? _selectedFile;
  
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
          maxAssets: 1,
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
        final file = await result.first.file;
        if (file != null) {
          setState(() {
            _selectedFile = file;
          });
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

  /// Firebase Storage에 이미지 업로드
  Future<String> _uploadToFirebase(Uint8List bytes) async {
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('사용자가 로그인되어 있지 않습니다.');
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${widget.box}.jpg';
      final path = 'users/${user.uid}/posts/images/$fileName';

      final ref = FirebaseStorage.instance.ref(path);
      
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

      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (snapshot.totalBytes > 0) {
          final progress = snapshot.bytesTransferred / snapshot.totalBytes;
          if (progress.isFinite && mounted) {
            setState(() {
              _uploadProgress = progress.clamp(0.0, 1.0);
            });
          }
        }
      });

      await uploadTask;
      final downloadUrl = await ref.getDownloadURL();
      
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }

      return downloadUrl;
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
                  
                  // 성공 콜백 호출
                  print('onComplete 콜백 호출 직전');
                  widget.onComplete(url);
                  print('onComplete 콜백 호출 완료');
                  
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
                // 피커로 돌아가기
                setState(() {
                  _selectedFile = null;
                });
                _openPicker();
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