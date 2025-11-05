import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'states/target_audience_state.dart';

part 'target_audience_notifier.g.dart';

/// Target audience notifier - Riverpod 3.x (Phase 2-7)
/// 타겟 오디언스 설정 관리를 위한 Notifier
///
/// **Migration**: TargetAudienceModel → TargetAudienceNotifier
/// **Phase**: 2-7 (TargetAudience Riverpod Notifier 생성)
///
/// **Methods** (10개):
/// - setCollectionType: 수집 방식 설정
/// - setTargetCount: 목표 수 설정
/// - setIsPremium: 프리미엄 설정
/// - toggleInterest: 관심사 토글
/// - clearInterests: 관심사 초기화
/// - setAgeGroup: 연령대 설정
/// - setGender: 성별 설정
/// - setActiveUserOnly: 활성 사용자 필터 설정
/// - nextStep / previousStep: 단계 이동
/// - reset: 전체 초기화
@riverpod
class TargetAudience extends _$TargetAudience {
  @override
  TargetAudienceState build() {
    return const TargetAudienceState();
  }

  // ============= Collection Type =============

  /// Set collection type
  /// 수집 방식 설정 ('quick', 'public', 'custom')
  void setCollectionType(String type) {
    state = state.copyWith(collectionType: type);
  }

  // ============= Target Count =============

  /// Set target response count
  /// 목표 응답 수 설정
  void setTargetCount(int count) {
    if (count > 0) {
      state = state.copyWith(targetCount: count);
    }
  }

  // ============= Premium Status =============

  /// Set premium status
  /// 프리미엄 여부 설정
  void setIsPremium(bool isPremium) {
    state = state.copyWith(isPremium: isPremium);
  }

  // ============= Custom Settings - Interests =============

  /// Toggle interest selection
  /// 관심사 선택 토글
  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.selectedInterests);

    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }

    state = state.copyWith(selectedInterests: currentInterests);
  }

  /// Clear all selected interests
  /// 선택된 관심사 모두 제거
  void clearInterests() {
    state = state.copyWith(selectedInterests: []);
  }

  // ============= Custom Settings - Age Group =============

  /// Set age group filter
  /// 연령대 필터 설정
  void setAgeGroup(String ageGroup) {
    state = state.copyWith(selectedAgeGroup: ageGroup);
  }

  // ============= Custom Settings - Gender =============

  /// Set gender filter
  /// 성별 필터 설정 ('all', 'male', 'female')
  void setGender(String gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // ============= Custom Settings - Active User Filter =============

  /// Toggle active user only filter
  /// 활성 사용자만 필터 토글
  void setActiveUserOnly(bool activeOnly) {
    state = state.copyWith(activeUserOnly: activeOnly);
  }

  // ============= Wizard Navigation =============

  /// Move to next step
  /// 다음 단계로 이동
  void nextStep() {
    if (state.canGoNext) {
      final nextStep = state.currentStep + 1;

      // Skip Step 2 (Custom settings) if not custom type
      if (nextStep == 2 && state.collectionType != 'custom') {
        // Already at final step
        return;
      }

      state = state.copyWith(currentStep: nextStep);
    }
  }

  /// Move to previous step
  /// 이전 단계로 이동
  void previousStep() {
    if (state.currentStep > 0) {
      final prevStep = state.currentStep - 1;
      state = state.copyWith(currentStep: prevStep);
    }
  }

  /// Set specific step
  /// 특정 단계로 이동
  void setStep(int step) {
    if (step >= 0 && step <= 2) {
      state = state.copyWith(currentStep: step);
    }
  }

  // ============= Reset =============

  /// Reset all settings to default
  /// 모든 설정 초기화
  void reset() {
    state = const TargetAudienceState();
  }

  // ============= Helper Methods =============

  /// Get Firestore-compatible map
  /// Firestore 저장용 Map 가져오기
  Map<String, dynamic> toFirestoreMap() {
    return state.toFirestoreMap();
  }

  /// Check if configuration is valid for submission
  /// 제출 가능한 유효한 설정인지 확인
  bool get isReadyForSubmit {
    return state.isValid && state.isFinalStep;
  }
}
