import 'dart:async';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/core_exports.dart';
import '/features/posts/data/services/media/media_upload_service.dart';
import '/features/posts/data/services/media/selection_result_processor.dart';
import '/features/posts/data/services/error/error_handler.dart';
import '/features/posts/presentation/utils/debug_helper.dart';
import '/services/ui/models/enums.dart';
import '/services/ui/injection/ui_service_injection.dart';
import '/features/posts/domain/usecases/media/ratio_calculator.dart';

/// Provider for managing media upload and processing
class MediaUploadProvider extends ChangeNotifier {
  // State
  bool _isProcessing = false;
  String? _processingMessage;
  double _uploadProgress = 0.0;
  Timer? _layoutUpdateTimer;
  bool _isUpdatingLayout = false;
  LayoutType _currentLayout = LayoutType.horizontal;
  bool _isVerticalRatio = false;
  
  // Current image indices for each box
  int _currentImageIndexA = 0;
  int _currentImageIndexB = 0;

  // Getters
  bool get isProcessing => _isProcessing;
  String? get processingMessage => _processingMessage;
  double get uploadProgress => _uploadProgress;
  LayoutType get currentLayout => _currentLayout;
  bool get isVerticalRatio => _isVerticalRatio;
  int get currentImageIndexA => _currentImageIndexA;
  int get currentImageIndexB => _currentImageIndexB;

  /// Process selected assets and upload them
  Future<void> processAssets({
    required BuildContext context,
    required AppState appState,
    required List<AssetEntity> assets,
    required String box,
    bool isAddMode = false,
    Function(List<String>)? onComplete,
  }) async {
    _isProcessing = true;
    _processingMessage = '이미지 처리 중...';
    _uploadProgress = 0.0;
    notifyListeners();

    try {
      final processor = SelectionResultProcessor(
        context: context,
        appState: appState,
        box: box,
        existingAssetIds: box == 'A' 
          ? appState.assetEntityIdsA
          : appState.assetEntityIdsB,
        onProgressUpdate: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
        onMultiComplete: (imageUrls) {
          onComplete?.call(imageUrls);
          _updateLayoutBasedOnImages(appState);
        },
        onProcessingComplete: () {
          _isProcessing = false;
          _processingMessage = null;
          notifyListeners();
        },
      );
      
      await processor.processSelectionResult(assets);
    } catch (e) {
      _isProcessing = false;
      _processingMessage = null;
      notifyListeners();
      
      ErrorHandler.handle(
        e,
        type: ErrorType.media,
        customMessage: '이미지 처리 중 오류가 발생했습니다',
        context: context,
      );
    }
  }

  /// Update layout based on image aspect ratios
  void _updateLayoutBasedOnImages(AppState appState) {
    // Cancel any pending update
    _layoutUpdateTimer?.cancel();
    
    // Debounce layout updates
    _layoutUpdateTimer = Timer(const Duration(milliseconds: 300), () {
      _performLayoutUpdate(appState);
    });
  }

  /// Perform the actual layout update
  void _performLayoutUpdate(AppState appState) {
    if (_isUpdatingLayout) return;
    _isUpdatingLayout = true;

    try {
      // Check for vertical images in B box
      if (appState.tempImageFilesB.isEmpty && 
          appState.uploadImageAspectRatioA.isNotEmpty) {
        final ratioA = RatioCalculator.getRatio(
          appState.uploadImageAspectRatioA, 
          box: 'A'
        );
        
        // If vertical image detected, switch to vertical layout
        if (ratioA < 1.0) {
          _currentLayout = LayoutType.vertical;
          _isVerticalRatio = false; // Vertical placement (top/bottom)
          notifyListeners();
          DebugHelper.logLayout('Vertical image detected, switching to vertical layout');
        }
      }

      // Analyze both boxes if both have images
      if (appState.uploadImageAspectRatioA.isNotEmpty && 
          appState.uploadImageAspectRatioB.isNotEmpty) {
        final ratioA = RatioCalculator.getRatio(
          appState.uploadImageAspectRatioA, 
          box: 'A'
        );
        final ratioB = RatioCalculator.getRatio(
          appState.uploadImageAspectRatioB, 
          box: 'B'
        );
        
        // Use AspectRatioAnalyzer to determine optimal layout
        final optimalLayout = layoutAnalyzer.getOptimalLayout(ratioA, ratioB);
        
        if (_currentLayout != optimalLayout) {
          _currentLayout = optimalLayout;
          _isVerticalRatio = optimalLayout == LayoutType.horizontal;
          notifyListeners();
          DebugHelper.logLayout('Layout updated to: ${optimalLayout.name}');
        }
      }
    } finally {
      _isUpdatingLayout = false;
    }
  }

  /// Delete image from a box
  Future<void> deleteImage({
    required BuildContext context,
    required AppState appState,
    required String box,
    required int index,
  }) async {
    try {
      if (box == 'A') {
        if (index < appState.uploadImageA.length) {
          // Delete from storage
          final urlToDelete = appState.uploadImageA[index];
          await MediaUploadService.deleteFromStorage(urlToDelete);
          
          // Update app state
          appState.update(() {
            appState.uploadImageA.removeAt(index);
            appState.tempImageFilesA.removeAt(index);
            if (index < appState.uploadImageAspectRatioA.length) {
              appState.uploadImageAspectRatioA.removeAt(index);
            }
            if (index < appState.assetEntityIdsA.length) {
              appState.assetEntityIdsA.removeAt(index);
            }
          });
        }
      } else {
        if (index < appState.uploadImageB.length) {
          // Delete from storage
          final urlToDelete = appState.uploadImageB[index];
          await MediaUploadService.deleteFromStorage(urlToDelete);
          
          // Update app state
          appState.update(() {
            appState.uploadImageB.removeAt(index);
            appState.tempImageFilesB.removeAt(index);
            if (index < appState.uploadImageAspectRatioB.length) {
              appState.uploadImageAspectRatioB.removeAt(index);
            }
            if (index < appState.assetEntityIdsB.length) {
              appState.assetEntityIdsB.removeAt(index);
            }
          });
        }
      }
      
      // Update layout after deletion
      _updateLayoutBasedOnImages(appState);
      
    } catch (e) {
      ErrorHandler.handle(
        e,
        type: ErrorType.media,
        customMessage: '이미지 삭제 중 오류가 발생했습니다',
        context: context,
      );
    }
  }

  /// Clean up uploaded images (for cancellation)
  Future<void> cleanupUploadedImages(AppState appState) async {
    try {
      // Delete all uploaded images from storage
      for (String url in appState.uploadImageA) {
        await MediaUploadService.deleteFromStorage(url);
      }
      for (String url in appState.uploadImageB) {
        await MediaUploadService.deleteFromStorage(url);
      }
      
      // Clear app state
      appState.update(() {
        appState.uploadImageA.clear();
        appState.uploadImageB.clear();
        appState.tempImageFilesA.clear();
        appState.tempImageFilesB.clear();
        appState.uploadImageAspectRatioA.clear();
        appState.uploadImageAspectRatioB.clear();
        appState.assetEntityIdsA.clear();
        appState.assetEntityIdsB.clear();
      });
      
    } catch (e) {
      DebugHelper.logError('Error cleaning up uploaded images', e);
    }
  }

  /// Update current image index for a box
  void updateCurrentImageIndex(String box, int index) {
    if (box == 'A') {
      _currentImageIndexA = index;
    } else {
      _currentImageIndexB = index;
    }
    notifyListeners();
  }

  /// Toggle layout between horizontal and vertical
  void toggleLayout() {
    _currentLayout = _currentLayout == LayoutType.horizontal 
      ? LayoutType.vertical 
      : LayoutType.horizontal;
    _isVerticalRatio = !_isVerticalRatio;
    notifyListeners();
  }

  @override
  void dispose() {
    _layoutUpdateTimer?.cancel();
    super.dispose();
  }
}