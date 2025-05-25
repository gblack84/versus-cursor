import 'package:flutter/material.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
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

  String _DisplayName = '';
  String get DisplayName => _DisplayName;
  set DisplayName(String value) {
    _DisplayName = value;
  }

  String _upLoadTextA = '';
  String get upLoadTextA => _upLoadTextA;
  set upLoadTextA(String value) {
    _upLoadTextA = value;
  }

  String _upLoadTextB = '';
  String get upLoadTextB => _upLoadTextB;
  set upLoadTextB(String value) {
    _upLoadTextB = value;
  }

  List<String> _UpLoadImageA = [];
  List<String> get UpLoadImageA => _UpLoadImageA;
  set UpLoadImageA(List<String> value) {
    _UpLoadImageA = value;
  }

  void addToUpLoadImageA(String value) {
    UpLoadImageA.add(value);
  }

  void removeFromUpLoadImageA(String value) {
    UpLoadImageA.remove(value);
  }

  void removeAtIndexFromUpLoadImageA(int index) {
    UpLoadImageA.removeAt(index);
  }

  void updateUpLoadImageAAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    UpLoadImageA[index] = updateFn(_UpLoadImageA[index]);
  }

  void insertAtIndexInUpLoadImageA(int index, String value) {
    UpLoadImageA.insert(index, value);
  }

  List<String> _UpLoadImageB = [];
  List<String> get UpLoadImageB => _UpLoadImageB;
  set UpLoadImageB(List<String> value) {
    _UpLoadImageB = value;
  }

  void addToUpLoadImageB(String value) {
    UpLoadImageB.add(value);
  }

  void removeFromUpLoadImageB(String value) {
    UpLoadImageB.remove(value);
  }

  void removeAtIndexFromUpLoadImageB(int index) {
    UpLoadImageB.removeAt(index);
  }

  void updateUpLoadImageBAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    UpLoadImageB[index] = updateFn(_UpLoadImageB[index]);
  }

  void insertAtIndexInUpLoadImageB(int index, String value) {
    UpLoadImageB.insert(index, value);
  }

  int _upLoadImageEditing = 0;
  int get upLoadImageEditing => _upLoadImageEditing;
  set upLoadImageEditing(int value) {
    _upLoadImageEditing = value;
  }

  int _upLoadTextEditing = 0;
  int get upLoadTextEditing => _upLoadTextEditing;
  set upLoadTextEditing(int value) {
    _upLoadTextEditing = value;
  }

  String _PreviewText = '';
  String get PreviewText => _PreviewText;
  set PreviewText(String value) {
    _PreviewText = value;
  }

  String _UpLoadvideoA = '';
  String get UpLoadvideoA => _UpLoadvideoA;
  set UpLoadvideoA(String value) {
    _UpLoadvideoA = value;
  }

  String _UpLoadvideoB = '';
  String get UpLoadvideoB => _UpLoadvideoB;
  set UpLoadvideoB(String value) {
    _UpLoadvideoB = value;
  }

  int _UpLoadVideoEdit = 0;
  int get UpLoadVideoEdit => _UpLoadVideoEdit;
  set UpLoadVideoEdit(int value) {
    _UpLoadVideoEdit = value;
  }

  bool _sellectedvideoset = false;
  bool get sellectedvideoset => _sellectedvideoset;
  set sellectedvideoset(bool value) {
    _sellectedvideoset = value;
  }

  String _UpLoadYoutubeA = '';
  String get UpLoadYoutubeA => _UpLoadYoutubeA;
  set UpLoadYoutubeA(String value) {
    _UpLoadYoutubeA = value;
  }

  String _UpLoadYoutubeB = '';
  String get UpLoadYoutubeB => _UpLoadYoutubeB;
  set UpLoadYoutubeB(String value) {
    _UpLoadYoutubeB = value;
  }

  String _UpLoadLinkA = '';
  String get UpLoadLinkA => _UpLoadLinkA;
  set UpLoadLinkA(String value) {
    _UpLoadLinkA = value;
  }

  String _UpLoadLinkB = '';
  String get UpLoadLinkB => _UpLoadLinkB;
  set UpLoadLinkB(String value) {
    _UpLoadLinkB = value;
  }

  String _editedVideoPath = '';
  String get editedVideoPath => _editedVideoPath;
  set editedVideoPath(String value) {
    _editedVideoPath = value;
  }

  String _editedCoverPath = '';
  String get editedCoverPath => _editedCoverPath;
  set editedCoverPath(String value) {
    _editedCoverPath = value;
  }

  String _TempPath = '';
  String get TempPath => _TempPath;
  set TempPath(String value) {
    _TempPath = value;
  }
}
