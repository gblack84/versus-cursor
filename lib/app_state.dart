import 'package:flutter/material.dart';

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

  // Alias for FlutterFlow compatibility
  String get DisplayName => _displayName;
  set DisplayName(String value) {
    _displayName = value;
  }

  String _uploadTextA = '';
  String get uploadTextA => _uploadTextA;
  set uploadTextA(String value) {
    _uploadTextA = value;
  }

  // Alias for FlutterFlow compatibility
  String get upLoadTextA => _uploadTextA;
  set upLoadTextA(String value) {
    _uploadTextA = value;
  }

  String _uploadTextB = '';
  String get uploadTextB => _uploadTextB;
  set uploadTextB(String value) {
    _uploadTextB = value;
  }

  // Alias for FlutterFlow compatibility
  String get upLoadTextB => _uploadTextB;
  set upLoadTextB(String value) {
    _uploadTextB = value;
  }

  List<String> _uploadImageA = [];
  List<String> get uploadImageA => _uploadImageA;
  set uploadImageA(List<String> value) {
    _uploadImageA = value;
  }

  // Alias for FlutterFlow compatibility
  List<String> get UpLoadImageA => _uploadImageA;
  set UpLoadImageA(List<String> value) {
    _uploadImageA = value;
  }

  void addToUploadImageA(String value) {
    uploadImageA.add(value);
  }

  // Alias for FlutterFlow compatibility
  void addToUpLoadImageA(String value) {
    uploadImageA.add(value);
  }

  void removeFromUploadImageA(String value) {
    uploadImageA.remove(value);
  }

  // Alias for FlutterFlow compatibility
  void removeFromUpLoadImageA(String value) {
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

  List<String> _uploadImageB = [];
  List<String> get uploadImageB => _uploadImageB;
  set uploadImageB(List<String> value) {
    _uploadImageB = value;
  }

  // Alias for FlutterFlow compatibility
  List<String> get UpLoadImageB => _uploadImageB;
  set UpLoadImageB(List<String> value) {
    _uploadImageB = value;
  }

  void addToUploadImageB(String value) {
    uploadImageB.add(value);
  }

  // Alias for FlutterFlow compatibility
  void addToUpLoadImageB(String value) {
    uploadImageB.add(value);
  }

  void removeFromUploadImageB(String value) {
    uploadImageB.remove(value);
  }

  // Alias for FlutterFlow compatibility
  void removeFromUpLoadImageB(String value) {
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

  int _uploadImageEditing = 0;
  int get uploadImageEditing => _uploadImageEditing;
  set uploadImageEditing(int value) {
    _uploadImageEditing = value;
  }

  // Alias for FlutterFlow compatibility
  int get upLoadImageEditing => _uploadImageEditing;
  set upLoadImageEditing(int value) {
    _uploadImageEditing = value;
  }

  int _uploadTextEditing = 0;
  int get uploadTextEditing => _uploadTextEditing;
  set uploadTextEditing(int value) {
    _uploadTextEditing = value;
  }

  // Alias for FlutterFlow compatibility
  int get upLoadTextEditing => _uploadTextEditing;
  set upLoadTextEditing(int value) {
    _uploadTextEditing = value;
  }

  String _previewText = '';
  String get previewText => _previewText;
  set previewText(String value) {
    _previewText = value;
  }

  // Alias for FlutterFlow compatibility
  String get PreviewText => _previewText;
  set PreviewText(String value) {
    _previewText = value;
  }

  String _uploadVideoA = '';
  String get uploadVideoA => _uploadVideoA;
  set uploadVideoA(String value) {
    _uploadVideoA = value;
  }

  // Alias for FlutterFlow compatibility
  String get UpLoadvideoA => _uploadVideoA;
  set UpLoadvideoA(String value) {
    _uploadVideoA = value;
  }

  String _uploadVideoB = '';
  String get uploadVideoB => _uploadVideoB;
  set uploadVideoB(String value) {
    _uploadVideoB = value;
  }

  // Alias for FlutterFlow compatibility
  String get UpLoadvideoB => _uploadVideoB;
  set UpLoadvideoB(String value) {
    _uploadVideoB = value;
  }

  int _uploadVideoEdit = 0;
  int get uploadVideoEdit => _uploadVideoEdit;
  set uploadVideoEdit(int value) {
    _uploadVideoEdit = value;
  }

  // Alias for FlutterFlow compatibility
  int get UpLoadVideoEdit => _uploadVideoEdit;
  set UpLoadVideoEdit(int value) {
    _uploadVideoEdit = value;
  }

  bool _selectedVideoSet = false;
  bool get selectedVideoSet => _selectedVideoSet;
  set selectedVideoSet(bool value) {
    _selectedVideoSet = value;
  }

  // Alias for FlutterFlow compatibility
  bool get sellectedvideoset => _selectedVideoSet;
  set sellectedvideoset(bool value) {
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
}
