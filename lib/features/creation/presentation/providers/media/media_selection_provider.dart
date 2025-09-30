import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Media selection state management provider
/// 미디어 선택 상태 관리 Provider - Clean Architecture Phase 5
///
/// Responsibilities:
/// - Media file selection and management (이미지/비디오 선택 관리)
/// - Aspect ratio tracking (비율 추적)
/// - Current index management (현재 인덱스 관리)
/// - Reordering and deletion (재정렬 및 삭제)
class MediaSelectionProvider extends ChangeNotifier {
  // ============= State from AppState =============
  // 선택된 파일 (로컬)
  List<File> _selectedFilesA = [];
  List<File> _selectedFilesB = [];

  // 업로드된 URL (Firebase Storage)
  List<String> _uploadedUrlsA = [];
  List<String> _uploadedUrlsB = [];

  // 이미지 비율 (스마트 레이아웃용)
  List<double> _aspectRatiosA = [];
  List<double> _aspectRatiosB = [];

  // 로컬 이미지 경로 (빠른 미리보기용)
  List<String> _localPathsA = [];
  List<String> _localPathsB = [];

  // AssetEntity ID (피커 재선택용)
  List<String> _assetEntityIdsA = [];
  List<String> _assetEntityIdsB = [];

  // ============= State from InPutPostImageModel =============
  // 현재 보고 있는 이미지 인덱스
  int _currentIndexA = 0;
  int _currentIndexB = 0;

  // 비디오 선택 여부
  bool _isVideoSelectedA = false;
  bool _isVideoSelectedB = false;

  // B박스 표시 여부
  bool _isBoxBVisible = false;

  // ============= Getters =============
  List<File> get selectedFilesA => List.unmodifiable(_selectedFilesA);
  List<File> get selectedFilesB => List.unmodifiable(_selectedFilesB);

  List<String> get uploadedUrlsA => List.unmodifiable(_uploadedUrlsA);
  List<String> get uploadedUrlsB => List.unmodifiable(_uploadedUrlsB);

  List<double> get aspectRatiosA => List.unmodifiable(_aspectRatiosA);
  List<double> get aspectRatiosB => List.unmodifiable(_aspectRatiosB);

  List<String> get localPathsA => List.unmodifiable(_localPathsA);
  List<String> get localPathsB => List.unmodifiable(_localPathsB);

  List<String> get assetEntityIdsA => List.unmodifiable(_assetEntityIdsA);
  List<String> get assetEntityIdsB => List.unmodifiable(_assetEntityIdsB);

  int get currentIndexA => _currentIndexA;
  int get currentIndexB => _currentIndexB;

  bool get isVideoSelectedA => _isVideoSelectedA;
  bool get isVideoSelectedB => _isVideoSelectedB;

  bool get isBoxBVisible => _isBoxBVisible;

  // 선택된 미디어 개수
  int get countA => _selectedFilesA.length;
  int get countB => _selectedFilesB.length;

  // 최대 선택 가능 개수
  static const int maxImages = 4;
  static const int maxVideos = 1;

  // ============= Methods =============

  /// Select images from asset picker
  /// 이미지 선택 (AssetPicker에서)
  Future<void> selectImages({
    required String box,
    required List<AssetEntity> assets,
  }) async {
    if (box == 'A') {
      _selectedFilesA.clear();
      _localPathsA.clear();
      _assetEntityIdsA.clear();
      _aspectRatiosA.clear();

      for (final asset in assets.take(maxImages)) {
        final file = await asset.file;
        if (file != null) {
          _selectedFilesA.add(file);
          _localPathsA.add(file.path);
          _assetEntityIdsA.add(asset.id);

          // Calculate aspect ratio
          final aspectRatio = asset.width / asset.height.toDouble();
          _aspectRatiosA.add(aspectRatio);
        }
      }

      _currentIndexA = 0;
    } else {
      _selectedFilesB.clear();
      _localPathsB.clear();
      _assetEntityIdsB.clear();
      _aspectRatiosB.clear();

      for (final asset in assets.take(maxImages)) {
        final file = await asset.file;
        if (file != null) {
          _selectedFilesB.add(file);
          _localPathsB.add(file.path);
          _assetEntityIdsB.add(asset.id);

          // Calculate aspect ratio
          final aspectRatio = asset.width / asset.height.toDouble();
          _aspectRatiosB.add(aspectRatio);
        }
      }

      _currentIndexB = 0;
    }

    notifyListeners();
  }

  /// Add a single file (from editing or camera)
  /// 단일 파일 추가 (편집 또는 카메라에서)
  void addFile({
    required String box,
    required File file,
    required double aspectRatio,
    String? assetId,
  }) {
    if (box == 'A' && _selectedFilesA.length < maxImages) {
      _selectedFilesA.add(file);
      _localPathsA.add(file.path);
      _aspectRatiosA.add(aspectRatio);
      if (assetId != null) {
        _assetEntityIdsA.add(assetId);
      }
    } else if (box == 'B' && _selectedFilesB.length < maxImages) {
      _selectedFilesB.add(file);
      _localPathsB.add(file.path);
      _aspectRatiosB.add(aspectRatio);
      if (assetId != null) {
        _assetEntityIdsB.add(assetId);
      }
    }

    notifyListeners();
  }

  /// Replace file at index (for editing)
  /// 인덱스 위치의 파일 교체 (편집용)
  void replaceFileAtIndex({
    required String box,
    required int index,
    required File file,
    required double aspectRatio,
  }) {
    if (box == 'A' && index >= 0 && index < _selectedFilesA.length) {
      _selectedFilesA[index] = file;
      _localPathsA[index] = file.path;
      _aspectRatiosA[index] = aspectRatio;
    } else if (box == 'B' && index >= 0 && index < _selectedFilesB.length) {
      _selectedFilesB[index] = file;
      _localPathsB[index] = file.path;
      _aspectRatiosB[index] = aspectRatio;
    }

    notifyListeners();
  }

  /// Remove image at index
  /// 인덱스 위치의 이미지 제거
  void removeAtIndex({
    required String box,
    required int index,
  }) {
    if (box == 'A' && index >= 0 && index < _selectedFilesA.length) {
      _selectedFilesA.removeAt(index);
      _localPathsA.removeAt(index);
      _aspectRatiosA.removeAt(index);

      if (index < _assetEntityIdsA.length) {
        _assetEntityIdsA.removeAt(index);
      }
      if (index < _uploadedUrlsA.length) {
        _uploadedUrlsA.removeAt(index);
      }

      // Adjust current index if needed
      if (_currentIndexA >= _selectedFilesA.length && _currentIndexA > 0) {
        _currentIndexA = _selectedFilesA.length - 1;
      }
    } else if (box == 'B' && index >= 0 && index < _selectedFilesB.length) {
      _selectedFilesB.removeAt(index);
      _localPathsB.removeAt(index);
      _aspectRatiosB.removeAt(index);

      if (index < _assetEntityIdsB.length) {
        _assetEntityIdsB.removeAt(index);
      }
      if (index < _uploadedUrlsB.length) {
        _uploadedUrlsB.removeAt(index);
      }

      // Adjust current index if needed
      if (_currentIndexB >= _selectedFilesB.length && _currentIndexB > 0) {
        _currentIndexB = _selectedFilesB.length - 1;
      }
    }

    notifyListeners();
  }

  /// Reorder images
  /// 이미지 순서 변경
  void reorderImages({
    required String box,
    required int oldIndex,
    required int newIndex,
  }) {
    if (box == 'A') {
      if (oldIndex >= 0 && oldIndex < _selectedFilesA.length &&
          newIndex >= 0 && newIndex < _selectedFilesA.length) {
        // Reorder all related lists
        final file = _selectedFilesA.removeAt(oldIndex);
        _selectedFilesA.insert(newIndex, file);

        final path = _localPathsA.removeAt(oldIndex);
        _localPathsA.insert(newIndex, path);

        final ratio = _aspectRatiosA.removeAt(oldIndex);
        _aspectRatiosA.insert(newIndex, ratio);

        if (oldIndex < _assetEntityIdsA.length) {
          final assetId = _assetEntityIdsA.removeAt(oldIndex);
          _assetEntityIdsA.insert(newIndex, assetId);
        }

        if (oldIndex < _uploadedUrlsA.length) {
          final url = _uploadedUrlsA.removeAt(oldIndex);
          _uploadedUrlsA.insert(newIndex, url);
        }
      }
    } else {
      if (oldIndex >= 0 && oldIndex < _selectedFilesB.length &&
          newIndex >= 0 && newIndex < _selectedFilesB.length) {
        // Reorder all related lists
        final file = _selectedFilesB.removeAt(oldIndex);
        _selectedFilesB.insert(newIndex, file);

        final path = _localPathsB.removeAt(oldIndex);
        _localPathsB.insert(newIndex, path);

        final ratio = _aspectRatiosB.removeAt(oldIndex);
        _aspectRatiosB.insert(newIndex, ratio);

        if (oldIndex < _assetEntityIdsB.length) {
          final assetId = _assetEntityIdsB.removeAt(oldIndex);
          _assetEntityIdsB.insert(newIndex, assetId);
        }

        if (oldIndex < _uploadedUrlsB.length) {
          final url = _uploadedUrlsB.removeAt(oldIndex);
          _uploadedUrlsB.insert(newIndex, url);
        }
      }
    }

    notifyListeners();
  }

  /// Move image to front (for thumbnail selection)
  /// 이미지를 맨 앞으로 이동 (썸네일 선택)
  void moveToFront({
    required String box,
    required int index,
  }) {
    if (index > 0) {
      reorderImages(box: box, oldIndex: index, newIndex: 0);
    }
  }

  /// Update current viewing index
  /// 현재 보고 있는 인덱스 업데이트
  void updateCurrentIndex({
    required String box,
    required int index,
  }) {
    if (box == 'A' && index >= 0 && index < _selectedFilesA.length) {
      _currentIndexA = index;
    } else if (box == 'B' && index >= 0 && index < _selectedFilesB.length) {
      _currentIndexB = index;
    }
    notifyListeners();
  }

  /// Update uploaded URLs after successful upload
  /// 업로드 성공 후 URL 업데이트
  void updateUploadedUrls({
    required String box,
    required List<String> urls,
  }) {
    if (box == 'A') {
      _uploadedUrlsA = List.from(urls);
    } else {
      _uploadedUrlsB = List.from(urls);
    }
    notifyListeners();
  }

  /// Toggle video selection
  /// 비디오 선택 토글
  void toggleVideoSelection(String box) {
    if (box == 'A') {
      _isVideoSelectedA = !_isVideoSelectedA;
      if (_isVideoSelectedA) {
        // Clear images when switching to video
        clearBox('A');
      }
    } else {
      _isVideoSelectedB = !_isVideoSelectedB;
      if (_isVideoSelectedB) {
        // Clear images when switching to video
        clearBox('B');
      }
    }
    notifyListeners();
  }

  /// Toggle B box visibility
  /// B박스 표시 토글
  void toggleBoxBVisibility() {
    _isBoxBVisible = !_isBoxBVisible;
    notifyListeners();
  }

  /// Clear all media in a box
  /// 박스의 모든 미디어 제거
  void clearBox(String box) {
    if (box == 'A') {
      _selectedFilesA.clear();
      _uploadedUrlsA.clear();
      _aspectRatiosA.clear();
      _localPathsA.clear();
      _assetEntityIdsA.clear();
      _currentIndexA = 0;
      _isVideoSelectedA = false;
    } else {
      _selectedFilesB.clear();
      _uploadedUrlsB.clear();
      _aspectRatiosB.clear();
      _localPathsB.clear();
      _assetEntityIdsB.clear();
      _currentIndexB = 0;
      _isVideoSelectedB = false;
    }
    notifyListeners();
  }

  /// Clear all selections
  /// 모든 선택 초기화
  void clearAll() {
    clearBox('A');
    clearBox('B');
    _isBoxBVisible = false;
    notifyListeners();
  }

  /// Check if can add more images
  /// 더 추가할 수 있는지 확인
  bool canAddMore(String box) {
    if (box == 'A') {
      return _isVideoSelectedA ? _selectedFilesA.isEmpty : _selectedFilesA.length < maxImages;
    } else {
      return _isVideoSelectedB ? _selectedFilesB.isEmpty : _selectedFilesB.length < maxImages;
    }
  }

  /// Get selected AssetEntity IDs for picker
  /// 피커에서 사용할 선택된 AssetEntity ID 가져오기
  List<String> getSelectedAssetIds(String box) {
    return box == 'A' ? List.from(_assetEntityIdsA) : List.from(_assetEntityIdsB);
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}