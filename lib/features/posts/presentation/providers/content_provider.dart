import 'package:flutter/material.dart';

/// ContentProvider - 콘텐츠 생성 관련 상태 관리
/// 
/// AppState에서 분리된 콘텐츠 생성 관련 필드들을 관리합니다.
/// 텍스트 입력, 질문 제목/설명 등의 상태와 관련 기능을 포함합니다.
class ContentProvider extends ChangeNotifier {
  /// 내부 생성자
  ContentProvider._internal();

  /// 팩토리 생성자 (싱글톤 패턴)
  factory ContentProvider() {
    return _instance;
  }

  /// 싱글톤 인스턴스
  static ContentProvider _instance = ContentProvider._internal();

  /// 인스턴스 재설정 (테스트용)
  static void reset() {
    _instance = ContentProvider._internal();
  }

  // ======================================
  // 텍스트 콘텐츠 필드들
  // ======================================

  /// A박스 텍스트 콘텐츠
  String _uploadTextA = '';
  String get uploadTextA => _uploadTextA;
  set uploadTextA(String value) {
    _uploadTextA = value;
    notifyListeners();
  }

  /// B박스 텍스트 콘텐츠
  String _uploadTextB = '';
  String get uploadTextB => _uploadTextB;
  set uploadTextB(String value) {
    _uploadTextB = value;
    notifyListeners();
  }

  /// 미리보기 텍스트
  String _previewText = '';
  String get previewText => _previewText;
  set previewText(String value) {
    _previewText = value;
    notifyListeners();
  }

  /// 질문 제목
  String _questionTitle = '';
  String get questionTitle => _questionTitle;
  set questionTitle(String value) {
    _questionTitle = value;
    notifyListeners();
  }

  /// 질문 설명
  String _questionDescription = '';
  String get questionDescription => _questionDescription;
  set questionDescription(String value) {
    _questionDescription = value;
    notifyListeners();
  }

  // ======================================
  // 텍스트 편집 상태 관리
  // ======================================

  /// 현재 편집 중인 텍스트 인덱스
  int _uploadTextEditing = 0;
  int get uploadTextEditing => _uploadTextEditing;
  set uploadTextEditing(int value) {
    _uploadTextEditing = value;
    notifyListeners();
  }

  // ======================================
  // 편의 메서드들
  // ======================================

  /// 모든 텍스트 콘텐츠 초기화
  void clearAllContent() {
    _uploadTextA = '';
    _uploadTextB = '';
    _previewText = '';
    _questionTitle = '';
    _questionDescription = '';
    _uploadTextEditing = 0;
    notifyListeners();
  }

  /// A박스 텍스트 콘텐츠 초기화
  void clearContentA() {
    _uploadTextA = '';
    notifyListeners();
  }

  /// B박스 텍스트 콘텐츠 초기화
  void clearContentB() {
    _uploadTextB = '';
    notifyListeners();
  }

  /// 질문 관련 콘텐츠 초기화
  void clearQuestionContent() {
    _questionTitle = '';
    _questionDescription = '';
    notifyListeners();
  }

  /// A박스에 텍스트 콘텐츠가 있는지 확인
  bool get hasContentA {
    return _uploadTextA.isNotEmpty;
  }

  /// B박스에 텍스트 콘텐츠가 있는지 확인
  bool get hasContentB {
    return _uploadTextB.isNotEmpty;
  }

  /// 질문 콘텐츠가 있는지 확인
  bool get hasQuestionContent {
    return _questionTitle.isNotEmpty || _questionDescription.isNotEmpty;
  }

  /// 전체 콘텐츠가 있는지 확인
  bool get hasAnyContent {
    return hasContentA || 
           hasContentB || 
           hasQuestionContent ||
           _previewText.isNotEmpty;
  }
}