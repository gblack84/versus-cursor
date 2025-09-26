import 'package:flutter/material.dart';
import '../../domain/models/target_audience.dart';

/// Provider for managing target audience UI state
/// 타겟 오디언스 UI 상태 관리를 위한 Provider
class TargetAudienceProvider extends ChangeNotifier {
  // Domain model instance
  TargetAudience _targetAudience = TargetAudience(
    createdAt: DateTime.now(),
  );

  // UI-specific state
  int _currentStep = 0;

  /// Get current target audience configuration
  TargetAudience get targetAudience => _targetAudience;

  /// Get current UI step
  int get currentStep => _currentStep;

  /// Get collection type
  String get collectionType => _targetAudience.collectionType;

  /// Get target count
  int get targetCount => _targetAudience.targetCount;

  /// Get premium status
  bool get isPremium => _targetAudience.isPremium;

  /// Get selected interests
  List<String> get selectedInterests => _targetAudience.selectedInterests;

  /// Get selected age group
  String get selectedAgeGroup => _targetAudience.selectedAgeGroup;

  /// Get selected gender
  String get selectedGender => _targetAudience.selectedGender;

  /// Get active user only flag
  bool get activeUserOnly => _targetAudience.activeUserOnly;

  /// Set collection type
  void setCollectionType(String type) {
    _targetAudience = _targetAudience.copyWith(collectionType: type);
    notifyListeners();
  }

  /// Set target count
  void setTargetCount(int count) {
    _targetAudience = _targetAudience.copyWith(targetCount: count);
    notifyListeners();
  }

  /// Set premium status
  void setPremiumStatus(bool isPremium) {
    _targetAudience = _targetAudience.copyWith(isPremium: isPremium);
    notifyListeners();
  }

  /// Toggle interest selection
  void toggleInterest(String interest) {
    final interests = List<String>.from(_targetAudience.selectedInterests);
    if (interests.contains(interest)) {
      interests.remove(interest);
    } else {
      interests.add(interest);
    }
    _targetAudience = _targetAudience.copyWith(selectedInterests: interests);
    notifyListeners();
  }

  /// Clear all interests
  void clearInterests() {
    _targetAudience = _targetAudience.copyWith(selectedInterests: []);
    notifyListeners();
  }

  /// Set age group
  void setAgeGroup(String ageGroup) {
    _targetAudience = _targetAudience.copyWith(selectedAgeGroup: ageGroup);
    notifyListeners();
  }

  /// Set gender
  void setGender(String gender) {
    _targetAudience = _targetAudience.copyWith(selectedGender: gender);
    notifyListeners();
  }

  /// Set active user only flag
  void setActiveUserOnly(bool active) {
    _targetAudience = _targetAudience.copyWith(activeUserOnly: active);
    notifyListeners();
  }

  /// Update current UI step
  void setCurrentStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  /// Move to next step
  void nextStep() {
    if (canGoNext) {
      _currentStep++;
      notifyListeners();
    }
  }

  /// Move to previous step
  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  /// Check if current step is valid
  bool get isValid {
    // Step 1: Collection type is always valid
    if (_currentStep == 0) return true;

    // Step 2: Target count must be positive
    if (_currentStep == 1) return _targetAudience.targetCount > 0;

    // Step 3: Custom settings validation
    if (_currentStep == 2 && _targetAudience.collectionType == 'custom') {
      return _targetAudience.isCustomCriteriaValid;
    }

    return true;
  }

  /// Check if can proceed to next step
  bool get canGoNext {
    if (_currentStep == 2 && _targetAudience.collectionType != 'custom') {
      return true; // Skip step 3 for non-custom types
    }
    return isValid;
  }

  /// Check if current step is final
  bool get isFinalStep {
    if (_targetAudience.collectionType != 'custom' && _currentStep == 1) {
      return true; // Step 2 is final for non-custom types
    }
    return _currentStep == 2;
  }

  /// Get estimated time from domain model
  String get estimatedTime => _targetAudience.estimatedTime;

  /// Update entire target audience configuration
  void updateTargetAudience(TargetAudience audience) {
    _targetAudience = audience;
    notifyListeners();
  }

  /// Get Firestore-compatible map
  Map<String, dynamic> toMap() {
    return _targetAudience.toMap();
  }

  /// Reset all settings to default
  void reset() {
    _targetAudience = TargetAudience(
      createdAt: DateTime.now(),
    );
    _currentStep = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}