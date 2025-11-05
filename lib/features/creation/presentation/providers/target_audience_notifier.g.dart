// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'target_audience_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(TargetAudience)
const targetAudienceProvider = TargetAudienceProvider._();

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
final class TargetAudienceProvider
    extends $NotifierProvider<TargetAudience, TargetAudienceState> {
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
  const TargetAudienceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'targetAudienceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$targetAudienceHash();

  @$internal
  @override
  TargetAudience create() => TargetAudience();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TargetAudienceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TargetAudienceState>(value),
    );
  }
}

String _$targetAudienceHash() => r'86c2d2df5654122698ad50330a8af7e844ea82a9';

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

abstract class _$TargetAudience extends $Notifier<TargetAudienceState> {
  TargetAudienceState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TargetAudienceState, TargetAudienceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TargetAudienceState, TargetAudienceState>,
              TargetAudienceState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
