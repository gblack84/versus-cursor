import 'package:flutter/material.dart';

/// 타겟 오디언스 설정을 위한 모델 클래스
class TargetAudienceModel extends ChangeNotifier {
  // 수집 방식
  String _collectionType = 'quick'; // quick, public, custom
  String get collectionType => _collectionType;
  set collectionType(String value) {
    _collectionType = value;
    notifyListeners();
  }

  // 목표 응답 수
  int _targetCount = 100;
  int get targetCount => _targetCount;
  set targetCount(int value) {
    _targetCount = value;
    notifyListeners();
  }

  // 프리미엄 여부
  bool _isPremium = false;
  bool get isPremium => _isPremium;
  set isPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  // Custom 설정 - 관심사
  final List<String> _selectedInterests = [];
  List<String> get selectedInterests => List.unmodifiable(_selectedInterests);
  
  void toggleInterest(String interest) {
    if (_selectedInterests.contains(interest)) {
      _selectedInterests.remove(interest);
    } else {
      _selectedInterests.add(interest);
    }
    notifyListeners();
  }

  void clearInterests() {
    _selectedInterests.clear();
    notifyListeners();
  }

  // Custom 설정 - 연령대
  String _selectedAgeGroup = '전체';
  String get selectedAgeGroup => _selectedAgeGroup;
  set selectedAgeGroup(String value) {
    _selectedAgeGroup = value;
    notifyListeners();
  }

  // Custom 설정 - 성별
  String _selectedGender = 'all';
  String get selectedGender => _selectedGender;
  set selectedGender(String value) {
    _selectedGender = value;
    notifyListeners();
  }

  // Custom 설정 - 활성 사용자만
  bool _activeUserOnly = true;
  bool get activeUserOnly => _activeUserOnly;
  set activeUserOnly(bool value) {
    _activeUserOnly = value;
    notifyListeners();
  }

  // UI 상태
  int _currentStep = 0;
  int get currentStep => _currentStep;
  set currentStep(int value) {
    _currentStep = value;
    notifyListeners();
  }

  // 유효성 검사
  bool get isValid {
    // Step 1: 수집 방식은 항상 선택됨
    if (_currentStep == 0) return true;
    
    // Step 2: 목표 수는 항상 유효
    if (_currentStep == 1) return _targetCount > 0;
    
    // Step 3: Custom 설정일 때만 검사
    if (_currentStep == 2 && _collectionType == 'custom') {
      // 최소 하나의 조건은 설정해야 함
      return _selectedInterests.isNotEmpty || 
             _selectedAgeGroup != '전체' || 
             _selectedGender != 'all';
    }
    
    return true;
  }

  // 예상 소요 시간 계산
  String get estimatedTime {
    if (_isPremium) {
      return '약 3-5분';
    } else {
      if (_targetCount <= 50) {
        return '약 5-10분';
      } else if (_targetCount <= 100) {
        return '약 10-15분';
      } else {
        return '약 15-30분';
      }
    }
  }

  // 다음 단계로 이동 가능 여부
  bool get canGoNext {
    if (_currentStep == 2 && _collectionType != 'custom') {
      return true; // Custom이 아니면 Step 3 건너뜀
    }
    return isValid;
  }

  // 최종 단계 여부
  bool get isFinalStep {
    if (_collectionType != 'custom' && _currentStep == 1) {
      return true; // Custom이 아니면 Step 2가 마지막
    }
    return _currentStep == 2;
  }

  // Firestore 저장용 Map 변환
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> data = {
      'collectionType': _collectionType,
      'targetCount': _targetCount,
      'isPremium': _isPremium,
      'createdAt': DateTime.now(),
      'status': {
        'current': 'setting',
        'collectedCount': 0,
        'startedAt': null,
        'completedAt': null,
      },
    };

    // Custom 설정인 경우 criteria 추가
    if (_collectionType == 'custom') {
      data['criteria'] = {
        'interests': _selectedInterests,
        'ageGroup': _selectedAgeGroup,
        'gender': _selectedGender,
        'activeUserOnly': _activeUserOnly,
      };
    }

    return data;
  }

  // 초기화
  void reset() {
    _collectionType = 'quick';
    _targetCount = 100;
    _isPremium = false;
    _selectedInterests.clear();
    _selectedAgeGroup = '전체';
    _selectedGender = 'all';
    _activeUserOnly = true;
    _currentStep = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}