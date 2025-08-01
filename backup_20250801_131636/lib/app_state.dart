import 'package:flutter/material.dart';
import 'dart:io';

class AppState extends ChangeNotifier {
  static AppState _instance = AppState._internal();

  factory AppState() {
    return _instance;
  }

  AppState._internal();

  static void reset() {
    _instance = AppState._internal();
  }

  Future initializePersistedState() async {}

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  String _selectedLang = '';
  String get selectedLang => _selectedLang;
  set selectedLang(String value) {
    _selectedLang = value;
  }

  String _displayName = '';
  String get displayName => _displayName;
  set displayName(String value) {
    _displayName = value;
  }


  String _uploadTextA = '';
  String get uploadTextA => _uploadTextA;
  set uploadTextA(String value) {
    _uploadTextA = value;
  }


  String _uploadTextB = '';
  String get uploadTextB => _uploadTextB;
  set uploadTextB(String value) {
    _uploadTextB = value;
  }


  List<String> _uploadImageA = [];
  List<String> get uploadImageA => _uploadImageA;
  set uploadImageA(List<String> value) {
    _uploadImageA = value;
  }


  void addToUploadImageA(String value) {
    uploadImageA.add(value);
  }


  void removeFromUploadImageA(String value) {
    uploadImageA.remove(value);
  }


  void removeAtIndexFromUploadImageA(int index) {
    if (index >= 0 && index < uploadImageA.length) {
      uploadImageA.removeAt(index);
      notifyListeners();
    }
  }

  void reorderUploadImageA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < uploadImageA.length && 
        newIndex >= 0 && newIndex < uploadImageA.length) {
      final item = uploadImageA.removeAt(oldIndex);
      uploadImageA.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontUploadImageA(int index) {
    if (index > 0 && index < uploadImageA.length) {
      final item = uploadImageA.removeAt(index);
      uploadImageA.insert(0, item);
      notifyListeners();
    }
  }

  void updateUploadImageAAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    uploadImageA[index] = updateFn(_uploadImageA[index]);
  }

  void insertAtIndexInUploadImageA(int index, String value) {
    uploadImageA.insert(index, value);
  }

  // 임시 이미지 파일 저장 (게시 전까지 File 객체로 유지)
  List<File> _tempImageFilesA = [];
  List<File> get tempImageFilesA => _tempImageFilesA;
  set tempImageFilesA(List<File> value) {
    _tempImageFilesA = value;
    notifyListeners();
  }

  void addToTempImageFilesA(File value) {
    _tempImageFilesA.add(value);
    notifyListeners();
  }

  void removeAtIndexFromTempImageFilesA(int index) {
    if (index >= 0 && index < _tempImageFilesA.length) {
      _tempImageFilesA.removeAt(index);
      notifyListeners();
    }
  }

  void clearTempImageFilesA() {
    _tempImageFilesA.clear();
    notifyListeners();
  }

  List<String> _uploadImageB = [];
  List<String> get uploadImageB => _uploadImageB;
  set uploadImageB(List<String> value) {
    _uploadImageB = value;
  }


  void addToUploadImageB(String value) {
    uploadImageB.add(value);
  }


  void removeFromUploadImageB(String value) {
    uploadImageB.remove(value);
  }


  void removeAtIndexFromUploadImageB(int index) {
    if (index >= 0 && index < uploadImageB.length) {
      uploadImageB.removeAt(index);
      notifyListeners();
    }
  }

  void reorderUploadImageB(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < uploadImageB.length && 
        newIndex >= 0 && newIndex < uploadImageB.length) {
      final item = uploadImageB.removeAt(oldIndex);
      uploadImageB.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontUploadImageB(int index) {
    if (index > 0 && index < uploadImageB.length) {
      final item = uploadImageB.removeAt(index);
      uploadImageB.insert(0, item);
      notifyListeners();
    }
  }

  void updateUploadImageBAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    uploadImageB[index] = updateFn(_uploadImageB[index]);
  }

  void insertAtIndexInUploadImageB(int index, String value) {
    uploadImageB.insert(index, value);
  }

  // 임시 이미지 파일 저장 (게시 전까지 File 객체로 유지)
  List<File> _tempImageFilesB = [];
  List<File> get tempImageFilesB => _tempImageFilesB;
  set tempImageFilesB(List<File> value) {
    _tempImageFilesB = value;
    notifyListeners();
  }

  void addToTempImageFilesB(File value) {
    _tempImageFilesB.add(value);
    notifyListeners();
  }

  void removeAtIndexFromTempImageFilesB(int index) {
    if (index >= 0 && index < _tempImageFilesB.length) {
      _tempImageFilesB.removeAt(index);
      notifyListeners();
    }
  }

  void clearTempImageFilesB() {
    _tempImageFilesB.clear();
    notifyListeners();
  }

  int _uploadImageEditing = 0;
  int get uploadImageEditing => _uploadImageEditing;
  set uploadImageEditing(int value) {
    _uploadImageEditing = value;
  }


  int _uploadTextEditing = 0;
  int get uploadTextEditing => _uploadTextEditing;
  set uploadTextEditing(int value) {
    _uploadTextEditing = value;
  }


  String _previewText = '';
  String get previewText => _previewText;
  set previewText(String value) {
    _previewText = value;
  }


  String _uploadVideoA = '';
  String get uploadVideoA => _uploadVideoA;
  set uploadVideoA(String value) {
    _uploadVideoA = value;
  }


  String _uploadVideoB = '';
  String get uploadVideoB => _uploadVideoB;
  set uploadVideoB(String value) {
    _uploadVideoB = value;
  }


  int _uploadVideoEdit = 0;
  int get uploadVideoEdit => _uploadVideoEdit;
  set uploadVideoEdit(int value) {
    _uploadVideoEdit = value;
  }


  bool _selectedVideoSet = false;
  bool get selectedVideoSet => _selectedVideoSet;
  set selectedVideoSet(bool value) {
    _selectedVideoSet = value;
  }


  String _uploadYoutubeA = '';
  String get uploadYoutubeA => _uploadYoutubeA;
  set uploadYoutubeA(String value) {
    _uploadYoutubeA = value;
  }

  String _uploadYoutubeB = '';
  String get uploadYoutubeB => _uploadYoutubeB;
  set uploadYoutubeB(String value) {
    _uploadYoutubeB = value;
  }

  String _uploadLinkA = '';
  String get uploadLinkA => _uploadLinkA;
  set uploadLinkA(String value) {
    _uploadLinkA = value;
  }

  String _uploadLinkB = '';
  String get uploadLinkB => _uploadLinkB;
  set uploadLinkB(String value) {
    _uploadLinkB = value;
  }

  String _uploadVideoPath = '';
  String get uploadVideoPath => _uploadVideoPath;
  set uploadVideoPath(String value) {
    _uploadVideoPath = value;
  }

  String _uploadPostId = '';
  String get uploadPostId => _uploadPostId;
  set uploadPostId(String value) {
    _uploadPostId = value;
  }

  double _uploadStartMs = 0.0;
  double get uploadStartMs => _uploadStartMs;
  set uploadStartMs(double value) {
    _uploadStartMs = value;
  }

  double _uploadEndMs = 0.0;
  double get uploadEndMs => _uploadEndMs;
  set uploadEndMs(double value) {
    _uploadEndMs = value;
  }

  String _uploadCoverBytes = '';
  String get uploadCoverBytes => _uploadCoverBytes;
  set uploadCoverBytes(String value) {
    _uploadCoverBytes = value;
  }

  double _uploadVideoAspectRatio = 1.77;
  double get uploadVideoAspectRatio => _uploadVideoAspectRatio;
  set uploadVideoAspectRatio(double value) {
    _uploadVideoAspectRatio = value;
  }

  String _questionTitle = '';
  String get questionTitle => _questionTitle;
  set questionTitle(String value) {
    _questionTitle = value;
  }

  String _questionDescription = '';
  String get questionDescription => _questionDescription;
  set questionDescription(String value) {
    _questionDescription = value;
  }

  bool _isVerticalLayout = true;
  bool get isVerticalLayout => _isVerticalLayout;
  set isVerticalLayout(bool value) {
    _isVerticalLayout = value;
  }

  // 이미지 비율 저장 (스마트 레이아웃 시스템용)
  List<double> _uploadImageAspectRatioA = [];
  List<double> get uploadImageAspectRatioA => _uploadImageAspectRatioA;
  set uploadImageAspectRatioA(List<double> value) {
    _uploadImageAspectRatioA = value;
  }

  void addToUploadImageAspectRatioA(double value) {
    _uploadImageAspectRatioA.add(value);
    notifyListeners();
  }

  void removeAtIndexFromUploadImageAspectRatioA(int index) {
    if (index >= 0 && index < _uploadImageAspectRatioA.length) {
      _uploadImageAspectRatioA.removeAt(index);
      notifyListeners();
    }
  }

  void reorderUploadImageAspectRatioA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _uploadImageAspectRatioA.length && 
        newIndex >= 0 && newIndex < _uploadImageAspectRatioA.length) {
      final item = _uploadImageAspectRatioA.removeAt(oldIndex);
      _uploadImageAspectRatioA.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontUploadImageAspectRatioA(int index) {
    if (index > 0 && index < _uploadImageAspectRatioA.length) {
      final item = _uploadImageAspectRatioA.removeAt(index);
      _uploadImageAspectRatioA.insert(0, item);
      notifyListeners();
    }
  }

  List<double> _uploadImageAspectRatioB = [];
  List<double> get uploadImageAspectRatioB => _uploadImageAspectRatioB;
  set uploadImageAspectRatioB(List<double> value) {
    _uploadImageAspectRatioB = value;
  }

  void addToUploadImageAspectRatioB(double value) {
    _uploadImageAspectRatioB.add(value);
    notifyListeners();
  }

  void removeAtIndexFromUploadImageAspectRatioB(int index) {
    if (index >= 0 && index < _uploadImageAspectRatioB.length) {
      _uploadImageAspectRatioB.removeAt(index);
      notifyListeners();
    }
  }

  void reorderUploadImageAspectRatioB(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _uploadImageAspectRatioB.length && 
        newIndex >= 0 && newIndex < _uploadImageAspectRatioB.length) {
      final item = _uploadImageAspectRatioB.removeAt(oldIndex);
      _uploadImageAspectRatioB.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontUploadImageAspectRatioB(int index) {
    if (index > 0 && index < _uploadImageAspectRatioB.length) {
      final item = _uploadImageAspectRatioB.removeAt(index);
      _uploadImageAspectRatioB.insert(0, item);
      notifyListeners();
    }
  }

  // 로컬 이미지 파일 경로 저장 (빠른 미리보기용)
  List<String> _localImagePathsA = [];
  List<String> get localImagePathsA => _localImagePathsA;
  set localImagePathsA(List<String> value) {
    _localImagePathsA = value;
    notifyListeners();
  }

  void addToLocalImagePathsA(String value) {
    _localImagePathsA.add(value);
    notifyListeners();
  }

  void removeAtIndexFromLocalImagePathsA(int index) {
    if (index >= 0 && index < _localImagePathsA.length) {
      _localImagePathsA.removeAt(index);
      notifyListeners();
    }
  }

  void clearLocalImagePathsA() {
    _localImagePathsA.clear();
    notifyListeners();
  }

  List<String> _localImagePathsB = [];
  List<String> get localImagePathsB => _localImagePathsB;
  set localImagePathsB(List<String> value) {
    _localImagePathsB = value;
    notifyListeners();
  }

  void addToLocalImagePathsB(String value) {
    _localImagePathsB.add(value);
    notifyListeners();
  }

  void removeAtIndexFromLocalImagePathsB(int index) {
    if (index >= 0 && index < _localImagePathsB.length) {
      _localImagePathsB.removeAt(index);
      notifyListeners();
    }
  }

  void clearLocalImagePathsB() {
    _localImagePathsB.clear();
    notifyListeners();
  }

  // AssetEntity ID 저장 (피커에서 선택 상태 표시용)
  List<String> _assetEntityIdsA = [];
  List<String> get assetEntityIdsA => _assetEntityIdsA;
  set assetEntityIdsA(List<String> value) {
    _assetEntityIdsA = value;
    notifyListeners();
  }

  void addToAssetEntityIdsA(String value) {
    _assetEntityIdsA.add(value);
    notifyListeners();
  }

  void removeAtIndexFromAssetEntityIdsA(int index) {
    if (index >= 0 && index < _assetEntityIdsA.length) {
      _assetEntityIdsA.removeAt(index);
      notifyListeners();
    }
  }

  void clearAssetEntityIdsA() {
    _assetEntityIdsA.clear();
    notifyListeners();
  }

  List<String> _assetEntityIdsB = [];
  List<String> get assetEntityIdsB => _assetEntityIdsB;
  set assetEntityIdsB(List<String> value) {
    _assetEntityIdsB = value;
    notifyListeners();
  }

  void addToAssetEntityIdsB(String value) {
    _assetEntityIdsB.add(value);
    notifyListeners();
  }

  void removeAtIndexFromAssetEntityIdsB(int index) {
    if (index >= 0 && index < _assetEntityIdsB.length) {
      _assetEntityIdsB.removeAt(index);
      notifyListeners();
    }
  }

  void clearAssetEntityIdsB() {
    _assetEntityIdsB.clear();
    notifyListeners();
  }

  // 로컬 경로와 원격 URL 매핑을 위한 헬퍼
  void reorderLocalImagePathsA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _localImagePathsA.length && 
        newIndex >= 0 && newIndex < _localImagePathsA.length) {
      final item = _localImagePathsA.removeAt(oldIndex);
      _localImagePathsA.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontLocalImagePathsA(int index) {
    if (index > 0 && index < _localImagePathsA.length) {
      final item = _localImagePathsA.removeAt(index);
      _localImagePathsA.insert(0, item);
      notifyListeners();
    }
  }

  void reorderLocalImagePathsB(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _localImagePathsB.length && 
        newIndex >= 0 && newIndex < _localImagePathsB.length) {
      final item = _localImagePathsB.removeAt(oldIndex);
      _localImagePathsB.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontLocalImagePathsB(int index) {
    if (index > 0 && index < _localImagePathsB.length) {
      final item = _localImagePathsB.removeAt(index);
      _localImagePathsB.insert(0, item);
      notifyListeners();
    }
  }

  // 업로드 상태 관리
  bool _isUploadingA = false;
  bool get isUploadingA => _isUploadingA;
  set isUploadingA(bool value) {
    _isUploadingA = value;
    notifyListeners();
  }

  bool _isUploadingB = false;
  bool get isUploadingB => _isUploadingB;
  set isUploadingB(bool value) {
    _isUploadingB = value;
    notifyListeners();
  }

  // 이미지 검열 상태 관리 - 동기식 검열로 전환되어 제거됨
  // 이제 uploadAndWaitForModeration을 사용하여 업로드 시점에 검열 완료

}
