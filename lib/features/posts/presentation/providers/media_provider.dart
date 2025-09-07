import 'package:flutter/material.dart';
import 'dart:io';

/// MediaProvider - 미디어 관련 상태 관리
/// 
/// AppState에서 분리된 미디어 관련 필드들을 관리합니다.
/// 이미지, 비디오, YouTube 링크 등의 상태와 관련 기능을 포함합니다.
class MediaProvider extends ChangeNotifier {
  /// 내부 생성자
  MediaProvider._internal();

  /// 팩토리 생성자 (싱글톤 패턴)
  factory MediaProvider() {
    return _instance;
  }

  /// 싱글톤 인스턴스
  static MediaProvider _instance = MediaProvider._internal();

  /// 인스턴스 재설정 (테스트용)
  static void reset() {
    _instance = MediaProvider._internal();
  }

  // ======================================
  // 이미지 관련 필드들 (A/B)
  // ======================================

  /// A박스 업로드된 이미지 URL 리스트 (Firebase Storage)
  List<String> _uploadImageA = [];
  List<String> get uploadImageA => _uploadImageA;
  set uploadImageA(List<String> value) {
    _uploadImageA = value;
    notifyListeners();
  }

  /// B박스 업로드된 이미지 URL 리스트 (Firebase Storage)
  List<String> _uploadImageB = [];
  List<String> get uploadImageB => _uploadImageB;
  set uploadImageB(List<String> value) {
    _uploadImageB = value;
    notifyListeners();
  }

  /// A박스 임시 이미지 파일 객체들 (업로드 전)
  List<File> _tempImageFilesA = [];
  List<File> get tempImageFilesA => _tempImageFilesA;
  set tempImageFilesA(List<File> value) {
    _tempImageFilesA = value;
    notifyListeners();
  }

  /// B박스 임시 이미지 파일 객체들 (업로드 전)
  List<File> _tempImageFilesB = [];
  List<File> get tempImageFilesB => _tempImageFilesB;
  set tempImageFilesB(List<File> value) {
    _tempImageFilesB = value;
    notifyListeners();
  }

  /// A박스 이미지들의 화면비 리스트 (스마트 레이아웃용)
  List<double> _uploadImageAspectRatioA = [];
  List<double> get uploadImageAspectRatioA => _uploadImageAspectRatioA;
  set uploadImageAspectRatioA(List<double> value) {
    _uploadImageAspectRatioA = value;
    notifyListeners();
  }

  /// B박스 이미지들의 화면비 리스트 (스마트 레이아웃용)
  List<double> _uploadImageAspectRatioB = [];
  List<double> get uploadImageAspectRatioB => _uploadImageAspectRatioB;
  set uploadImageAspectRatioB(List<double> value) {
    _uploadImageAspectRatioB = value;
    notifyListeners();
  }

  /// A박스 로컬 이미지 파일 경로들 (빠른 미리보기용)
  List<String> _localImagePathsA = [];
  List<String> get localImagePathsA => _localImagePathsA;
  set localImagePathsA(List<String> value) {
    _localImagePathsA = value;
    notifyListeners();
  }

  /// B박스 로컬 이미지 파일 경로들 (빠른 미리보기용)
  List<String> _localImagePathsB = [];
  List<String> get localImagePathsB => _localImagePathsB;
  set localImagePathsB(List<String> value) {
    _localImagePathsB = value;
    notifyListeners();
  }

  /// A박스 AssetEntity ID들 (피커 선택 상태 표시용)
  List<String> _assetEntityIdsA = [];
  List<String> get assetEntityIdsA => _assetEntityIdsA;
  set assetEntityIdsA(List<String> value) {
    _assetEntityIdsA = value;
    notifyListeners();
  }

  /// B박스 AssetEntity ID들 (피커 선택 상태 표시용)
  List<String> _assetEntityIdsB = [];
  List<String> get assetEntityIdsB => _assetEntityIdsB;
  set assetEntityIdsB(List<String> value) {
    _assetEntityIdsB = value;
    notifyListeners();
  }

  // ======================================
  // 비디오 관련 필드들
  // ======================================

  /// A박스 업로드된 비디오 URL (Firebase Storage)
  String _uploadVideoA = '';
  String get uploadVideoA => _uploadVideoA;
  set uploadVideoA(String value) {
    _uploadVideoA = value;
    notifyListeners();
  }

  /// B박스 업로드된 비디오 URL (Firebase Storage)
  String _uploadVideoB = '';
  String get uploadVideoB => _uploadVideoB;
  set uploadVideoB(String value) {
    _uploadVideoB = value;
    notifyListeners();
  }

  /// 현재 처리 중인 비디오 파일 경로
  String _uploadVideoPath = '';
  String get uploadVideoPath => _uploadVideoPath;
  set uploadVideoPath(String value) {
    _uploadVideoPath = value;
    notifyListeners();
  }

  /// 비디오 화면비
  double _uploadVideoAspectRatio = 1.77;
  double get uploadVideoAspectRatio => _uploadVideoAspectRatio;
  set uploadVideoAspectRatio(double value) {
    _uploadVideoAspectRatio = value;
    notifyListeners();
  }

  /// 비디오 선택 여부
  bool _selectedVideoSet = false;
  bool get selectedVideoSet => _selectedVideoSet;
  set selectedVideoSet(bool value) {
    _selectedVideoSet = value;
    notifyListeners();
  }

  // ======================================
  // YouTube 및 링크 관련 필드들
  // ======================================

  /// A박스 YouTube URL
  String _uploadYoutubeA = '';
  String get uploadYoutubeA => _uploadYoutubeA;
  set uploadYoutubeA(String value) {
    _uploadYoutubeA = value;
    notifyListeners();
  }

  /// B박스 YouTube URL
  String _uploadYoutubeB = '';
  String get uploadYoutubeB => _uploadYoutubeB;
  set uploadYoutubeB(String value) {
    _uploadYoutubeB = value;
    notifyListeners();
  }

  /// A박스 일반 링크 URL
  String _uploadLinkA = '';
  String get uploadLinkA => _uploadLinkA;
  set uploadLinkA(String value) {
    _uploadLinkA = value;
    notifyListeners();
  }

  /// B박스 일반 링크 URL
  String _uploadLinkB = '';
  String get uploadLinkB => _uploadLinkB;
  set uploadLinkB(String value) {
    _uploadLinkB = value;
    notifyListeners();
  }

  // ======================================
  // 편집 상태 관리 필드들
  // ======================================

  /// 현재 편집 중인 이미지 인덱스
  int _uploadImageEditing = 0;
  int get uploadImageEditing => _uploadImageEditing;
  set uploadImageEditing(int value) {
    _uploadImageEditing = value;
    notifyListeners();
  }

  /// 비디오 편집 상태
  int _uploadVideoEdit = 0;
  int get uploadVideoEdit => _uploadVideoEdit;
  set uploadVideoEdit(int value) {
    _uploadVideoEdit = value;
    notifyListeners();
  }

  /// A박스 업로드 진행 상태
  bool _isUploadingA = false;
  bool get isUploadingA => _isUploadingA;
  set isUploadingA(bool value) {
    _isUploadingA = value;
    notifyListeners();
  }

  /// B박스 업로드 진행 상태
  bool _isUploadingB = false;
  bool get isUploadingB => _isUploadingB;
  set isUploadingB(bool value) {
    _isUploadingB = value;
    notifyListeners();
  }

  // ======================================
  // 비디오 편집 관련 필드들
  // ======================================

  /// 비디오 트리밍 시작 시간 (밀리초)
  double _uploadStartMs = 0.0;
  double get uploadStartMs => _uploadStartMs;
  set uploadStartMs(double value) {
    _uploadStartMs = value;
    notifyListeners();
  }

  /// 비디오 트리밍 종료 시간 (밀리초)
  double _uploadEndMs = 0.0;
  double get uploadEndMs => _uploadEndMs;
  set uploadEndMs(double value) {
    _uploadEndMs = value;
    notifyListeners();
  }

  /// 비디오 커버 이미지 (Base64 인코딩)
  String _uploadCoverBytes = '';
  String get uploadCoverBytes => _uploadCoverBytes;
  set uploadCoverBytes(String value) {
    _uploadCoverBytes = value;
    notifyListeners();
  }

  /// 연결된 게시물 ID
  String _uploadPostId = '';
  String get uploadPostId => _uploadPostId;
  set uploadPostId(String value) {
    _uploadPostId = value;
    notifyListeners();
  }

  // ======================================
  // A박스 이미지 관련 메서드들
  // ======================================

  /// A박스에 이미지 URL 추가
  void addToUploadImageA(String value) {
    _uploadImageA.add(value);
    notifyListeners();
  }

  /// A박스에서 이미지 URL 제거
  void removeFromUploadImageA(String value) {
    _uploadImageA.remove(value);
    notifyListeners();
  }

  /// A박스 특정 인덱스의 이미지 제거
  void removeAtIndexFromUploadImageA(int index) {
    if (index >= 0 && index < _uploadImageA.length) {
      _uploadImageA.removeAt(index);
      notifyListeners();
    }
  }

  /// A박스 이미지 순서 변경
  void reorderUploadImageA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _uploadImageA.length && 
        newIndex >= 0 && newIndex < _uploadImageA.length) {
      final item = _uploadImageA.removeAt(oldIndex);
      _uploadImageA.insert(newIndex, item);
      notifyListeners();
    }
  }

  /// A박스 이미지를 맨 앞으로 이동
  void moveToFrontUploadImageA(int index) {
    if (index > 0 && index < _uploadImageA.length) {
      final item = _uploadImageA.removeAt(index);
      _uploadImageA.insert(0, item);
      notifyListeners();
    }
  }

  /// A박스 특정 인덱스 이미지 업데이트
  void updateUploadImageAAtIndex(int index, String Function(String) updateFn) {
    if (index >= 0 && index < _uploadImageA.length) {
      _uploadImageA[index] = updateFn(_uploadImageA[index]);
      notifyListeners();
    }
  }

  /// A박스 특정 위치에 이미지 삽입
  void insertAtIndexInUploadImageA(int index, String value) {
    _uploadImageA.insert(index, value);
    notifyListeners();
  }

  // ======================================
  // A박스 임시 파일 관련 메서드들
  // ======================================

  /// A박스에 임시 파일 추가
  void addToTempImageFilesA(File value) {
    _tempImageFilesA.add(value);
    notifyListeners();
  }

  /// A박스 특정 인덱스의 임시 파일 제거
  void removeAtIndexFromTempImageFilesA(int index) {
    if (index >= 0 && index < _tempImageFilesA.length) {
      _tempImageFilesA.removeAt(index);
      notifyListeners();
    }
  }

  /// A박스 모든 임시 파일 제거
  void clearTempImageFilesA() {
    _tempImageFilesA.clear();
    notifyListeners();
  }

  // ======================================
  // A박스 화면비 관련 메서드들
  // ======================================

  /// A박스에 화면비 추가
  void addToUploadImageAspectRatioA(double value) {
    _uploadImageAspectRatioA.add(value);
    notifyListeners();
  }

  /// A박스 특정 인덱스의 화면비 제거
  void removeAtIndexFromUploadImageAspectRatioA(int index) {
    if (index >= 0 && index < _uploadImageAspectRatioA.length) {
      _uploadImageAspectRatioA.removeAt(index);
      notifyListeners();
    }
  }

  /// A박스 화면비 순서 변경
  void reorderUploadImageAspectRatioA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _uploadImageAspectRatioA.length && 
        newIndex >= 0 && newIndex < _uploadImageAspectRatioA.length) {
      final item = _uploadImageAspectRatioA.removeAt(oldIndex);
      _uploadImageAspectRatioA.insert(newIndex, item);
      notifyListeners();
    }
  }

  /// A박스 화면비를 맨 앞으로 이동
  void moveToFrontUploadImageAspectRatioA(int index) {
    if (index > 0 && index < _uploadImageAspectRatioA.length) {
      final item = _uploadImageAspectRatioA.removeAt(index);
      _uploadImageAspectRatioA.insert(0, item);
      notifyListeners();
    }
  }

  // ======================================
  // A박스 로컬 경로 관련 메서드들
  // ======================================

  /// A박스에 로컬 경로 추가
  void addToLocalImagePathsA(String value) {
    _localImagePathsA.add(value);
    notifyListeners();
  }

  /// A박스 특정 인덱스의 로컬 경로 제거
  void removeAtIndexFromLocalImagePathsA(int index) {
    if (index >= 0 && index < _localImagePathsA.length) {
      _localImagePathsA.removeAt(index);
      notifyListeners();
    }
  }

  /// A박스 모든 로컬 경로 제거
  void clearLocalImagePathsA() {
    _localImagePathsA.clear();
    notifyListeners();
  }

  /// A박스 로컬 경로 순서 변경
  void reorderLocalImagePathsA(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _localImagePathsA.length && 
        newIndex >= 0 && newIndex < _localImagePathsA.length) {
      final item = _localImagePathsA.removeAt(oldIndex);
      _localImagePathsA.insert(newIndex, item);
      notifyListeners();
    }
  }

  /// A박스 로컬 경로를 맨 앞으로 이동
  void moveToFrontLocalImagePathsA(int index) {
    if (index > 0 && index < _localImagePathsA.length) {
      final item = _localImagePathsA.removeAt(index);
      _localImagePathsA.insert(0, item);
      notifyListeners();
    }
  }

  // ======================================
  // A박스 AssetEntity ID 관련 메서드들
  // ======================================

  /// A박스에 AssetEntity ID 추가
  void addToAssetEntityIdsA(String value) {
    _assetEntityIdsA.add(value);
    notifyListeners();
  }

  /// A박스 특정 인덱스의 AssetEntity ID 제거
  void removeAtIndexFromAssetEntityIdsA(int index) {
    if (index >= 0 && index < _assetEntityIdsA.length) {
      _assetEntityIdsA.removeAt(index);
      notifyListeners();
    }
  }

  /// A박스 모든 AssetEntity ID 제거
  void clearAssetEntityIdsA() {
    _assetEntityIdsA.clear();
    notifyListeners();
  }

  // ======================================
  // B박스 이미지 관련 메서드들 (A박스와 동일한 패턴)
  // ======================================

  void addToUploadImageB(String value) {
    _uploadImageB.add(value);
    notifyListeners();
  }

  void removeFromUploadImageB(String value) {
    _uploadImageB.remove(value);
    notifyListeners();
  }

  void removeAtIndexFromUploadImageB(int index) {
    if (index >= 0 && index < _uploadImageB.length) {
      _uploadImageB.removeAt(index);
      notifyListeners();
    }
  }

  void reorderUploadImageB(int oldIndex, int newIndex) {
    if (oldIndex >= 0 && oldIndex < _uploadImageB.length && 
        newIndex >= 0 && newIndex < _uploadImageB.length) {
      final item = _uploadImageB.removeAt(oldIndex);
      _uploadImageB.insert(newIndex, item);
      notifyListeners();
    }
  }

  void moveToFrontUploadImageB(int index) {
    if (index > 0 && index < _uploadImageB.length) {
      final item = _uploadImageB.removeAt(index);
      _uploadImageB.insert(0, item);
      notifyListeners();
    }
  }

  void updateUploadImageBAtIndex(int index, String Function(String) updateFn) {
    if (index >= 0 && index < _uploadImageB.length) {
      _uploadImageB[index] = updateFn(_uploadImageB[index]);
      notifyListeners();
    }
  }

  void insertAtIndexInUploadImageB(int index, String value) {
    _uploadImageB.insert(index, value);
    notifyListeners();
  }

  // ======================================
  // B박스 임시 파일 관련 메서드들
  // ======================================

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

  // ======================================
  // B박스 화면비 관련 메서드들
  // ======================================

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

  // ======================================
  // B박스 로컬 경로 관련 메서드들
  // ======================================

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

  // ======================================
  // B박스 AssetEntity ID 관련 메서드들
  // ======================================

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

  // ======================================
  // 편의 메서드들
  // ======================================

  /// 모든 미디어 데이터 초기화
  void clearAllMedia() {
    // 이미지 관련
    _uploadImageA.clear();
    _uploadImageB.clear();
    _tempImageFilesA.clear();
    _tempImageFilesB.clear();
    _uploadImageAspectRatioA.clear();
    _uploadImageAspectRatioB.clear();
    _localImagePathsA.clear();
    _localImagePathsB.clear();
    _assetEntityIdsA.clear();
    _assetEntityIdsB.clear();

    // 비디오 관련
    _uploadVideoA = '';
    _uploadVideoB = '';
    _uploadVideoPath = '';
    _uploadVideoAspectRatio = 1.77;
    _selectedVideoSet = false;

    // 링크 관련
    _uploadYoutubeA = '';
    _uploadYoutubeB = '';
    _uploadLinkA = '';
    _uploadLinkB = '';

    // 편집 상태 관련
    _uploadImageEditing = 0;
    _uploadVideoEdit = 0;
    _isUploadingA = false;
    _isUploadingB = false;

    // 비디오 편집 관련
    _uploadStartMs = 0.0;
    _uploadEndMs = 0.0;
    _uploadCoverBytes = '';
    _uploadPostId = '';

    notifyListeners();
  }

  /// A박스의 모든 데이터 초기화
  void clearMediaA() {
    _uploadImageA.clear();
    _tempImageFilesA.clear();
    _uploadImageAspectRatioA.clear();
    _localImagePathsA.clear();
    _assetEntityIdsA.clear();
    _uploadVideoA = '';
    _uploadYoutubeA = '';
    _uploadLinkA = '';
    _isUploadingA = false;
    notifyListeners();
  }

  /// B박스의 모든 데이터 초기화
  void clearMediaB() {
    _uploadImageB.clear();
    _tempImageFilesB.clear();
    _uploadImageAspectRatioB.clear();
    _localImagePathsB.clear();
    _assetEntityIdsB.clear();
    _uploadVideoB = '';
    _uploadYoutubeB = '';
    _uploadLinkB = '';
    _isUploadingB = false;
    notifyListeners();
  }

  /// A박스에 미디어 콘텐츠가 있는지 확인
  bool get hasMediaA {
    return _uploadImageA.isNotEmpty ||
           _tempImageFilesA.isNotEmpty ||
           _uploadVideoA.isNotEmpty ||
           _uploadYoutubeA.isNotEmpty ||
           _uploadLinkA.isNotEmpty;
  }

  /// B박스에 미디어 콘텐츠가 있는지 확인
  bool get hasMediaB {
    return _uploadImageB.isNotEmpty ||
           _tempImageFilesB.isNotEmpty ||
           _uploadVideoB.isNotEmpty ||
           _uploadYoutubeB.isNotEmpty ||
           _uploadLinkB.isNotEmpty;
  }
}