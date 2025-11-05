import 'package:freezed_annotation/freezed_annotation.dart';

part 'target_audience_state.freezed.dart';

/// Target audience state - Riverpod 3.x (Phase 2-7)
/// 타겟 오디언스 설정 상태 관리를 위한 불변 State
///
/// **Migration**: TargetAudienceModel → TargetAudienceNotifier
/// **Phase**: 2-7 (TargetAudience Freezed State 생성)
///
/// **State Variables** (8개):
/// - collectionType: 수집 방식 ('quick', 'public', 'custom')
/// - targetCount: 목표 응답 수
/// - isPremium: 프리미엄 여부
/// - selectedInterests: 선택된 관심사
/// - selectedAgeGroup: 선택된 연령대
/// - selectedGender: 선택된 성별
/// - activeUserOnly: 활성 사용자만 대상
/// - currentStep: 현재 단계 (0-2)
@freezed
sealed class TargetAudienceState with _$TargetAudienceState {
  const factory TargetAudienceState({
    /// Collection type: 'quick' (빠른 수집), 'public' (공개), 'custom' (맞춤)
    @Default('quick') String collectionType,

    /// Target response count
    @Default(100) int targetCount,

    /// Premium tier status
    @Default(false) bool isPremium,

    /// Selected interests (Custom mode)
    @Default([]) List<String> selectedInterests,

    /// Selected age group (Custom mode)
    @Default('전체') String selectedAgeGroup,

    /// Selected gender: 'all', 'male', 'female'
    @Default('all') String selectedGender,

    /// Active users only filter
    @Default(true) bool activeUserOnly,

    /// Current wizard step (0: Type, 1: Count, 2: Custom)
    @Default(0) int currentStep,
  }) = _TargetAudienceState;
}

// ============= Extension for Computed Properties =============

extension TargetAudienceStateX on TargetAudienceState {
  /// Validation for current step
  /// 현재 단계 유효성 검사
  bool get isValid {
    // Step 0: Collection type is always selected
    if (currentStep == 0) return true;

    // Step 1: Target count must be positive
    if (currentStep == 1) return targetCount > 0;

    // Step 2: Custom settings validation
    if (currentStep == 2 && collectionType == 'custom') {
      // At least one criterion must be set
      return selectedInterests.isNotEmpty ||
          selectedAgeGroup != '전체' ||
          selectedGender != 'all';
    }

    return true;
  }

  /// Estimated collection time
  /// 예상 소요 시간
  String get estimatedTime {
    if (isPremium) {
      return '약 3-5분';
    } else {
      if (targetCount <= 50) {
        return '약 5-10분';
      } else if (targetCount <= 100) {
        return '약 10-15분';
      } else {
        return '약 15-30분';
      }
    }
  }

  /// Can proceed to next step
  /// 다음 단계 진행 가능 여부
  bool get canGoNext {
    if (currentStep == 2 && collectionType != 'custom') {
      return true; // Skip Step 3 if not custom
    }
    return isValid;
  }

  /// Is this the final step?
  /// 최종 단계 여부
  bool get isFinalStep {
    if (collectionType != 'custom' && currentStep == 1) {
      return true; // Step 2 is final if not custom
    }
    return currentStep == 2;
  }

  /// Convert to Firestore map (Firebase Functions compatible)
  /// Firestore 저장용 Map 변환
  Map<String, dynamic> toFirestoreMap() {
    final Map<String, dynamic> data = {
      'type': collectionType,
      'targetCount': targetCount,
      'isPremium': isPremium,
      'createdAt': DateTime.now(),
      'status': 'pending',
    };

    // Add custom criteria if custom collection type
    if (collectionType == 'custom') {
      // Convert Korean age group to English
      String convertedAgeGroup = selectedAgeGroup;
      if (selectedAgeGroup != '전체') {
        const ageMapping = {
          '10대': '10s',
          '20대': '20s',
          '30대': '30s',
          '40대': '40s',
          '50대 이상': '50s+',
        };
        convertedAgeGroup = ageMapping[selectedAgeGroup] ?? 'all';
      } else {
        convertedAgeGroup = 'all';
      }

      data['criteria'] = {
        'interests': selectedInterests,
        'ageGroup': convertedAgeGroup,
        'gender': selectedGender,
        'activeUserOnly': activeUserOnly,
      };
    }

    return data;
  }
}
