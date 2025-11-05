// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_selection_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Media selection notifier - Riverpod 3.x (Phase 2-7-1)
/// 미디어 선택 상태 관리를 위한 Notifier
///
/// **Migration**: MediaSelectionProvider → MediaSelectionNotifier
/// **Phase**: 2-7-1 (MediaSelection Riverpod Notifier 생성)
///
/// **Methods** (20개):
/// - selectImages: 이미지 선택 (AssetEntity → File 변환)
/// - addFile: 단일 파일 추가 (편집/카메라)
/// - replaceFileAtIndex: 파일 교체
/// - removeAtIndex: 이미지 제거
/// - reorderImages: 이미지 순서 변경
/// - moveToFront: 썸네일로 이동
/// - updateCurrentIndex: Carousel 인덱스 업데이트
/// - updateUploadedUrls: 업로드 URL 업데이트
/// - toggleVideoSelection: 비디오 선택 토글
/// - toggleBoxBVisibility: B박스 표시 토글
/// - updateLayout: 레이아웃 계산 및 업데이트
/// - resetLayout: 레이아웃 초기화
/// - clearBox: 박스 클리어
/// - clearAll: 전체 클리어
/// - canAddMore: 추가 가능 여부
/// - getSelectedAssetIds: AssetEntity ID 가져오기
/// - getRepresentativeRatioA: A박스 대표 비율
/// - getRepresentativeRatioB: B박스 대표 비율

@ProviderFor(MediaSelection)
const mediaSelectionProvider = MediaSelectionProvider._();

/// Media selection notifier - Riverpod 3.x (Phase 2-7-1)
/// 미디어 선택 상태 관리를 위한 Notifier
///
/// **Migration**: MediaSelectionProvider → MediaSelectionNotifier
/// **Phase**: 2-7-1 (MediaSelection Riverpod Notifier 생성)
///
/// **Methods** (20개):
/// - selectImages: 이미지 선택 (AssetEntity → File 변환)
/// - addFile: 단일 파일 추가 (편집/카메라)
/// - replaceFileAtIndex: 파일 교체
/// - removeAtIndex: 이미지 제거
/// - reorderImages: 이미지 순서 변경
/// - moveToFront: 썸네일로 이동
/// - updateCurrentIndex: Carousel 인덱스 업데이트
/// - updateUploadedUrls: 업로드 URL 업데이트
/// - toggleVideoSelection: 비디오 선택 토글
/// - toggleBoxBVisibility: B박스 표시 토글
/// - updateLayout: 레이아웃 계산 및 업데이트
/// - resetLayout: 레이아웃 초기화
/// - clearBox: 박스 클리어
/// - clearAll: 전체 클리어
/// - canAddMore: 추가 가능 여부
/// - getSelectedAssetIds: AssetEntity ID 가져오기
/// - getRepresentativeRatioA: A박스 대표 비율
/// - getRepresentativeRatioB: B박스 대표 비율
final class MediaSelectionProvider
    extends $NotifierProvider<MediaSelection, MediaSelectionState> {
  /// Media selection notifier - Riverpod 3.x (Phase 2-7-1)
  /// 미디어 선택 상태 관리를 위한 Notifier
  ///
  /// **Migration**: MediaSelectionProvider → MediaSelectionNotifier
  /// **Phase**: 2-7-1 (MediaSelection Riverpod Notifier 생성)
  ///
  /// **Methods** (20개):
  /// - selectImages: 이미지 선택 (AssetEntity → File 변환)
  /// - addFile: 단일 파일 추가 (편집/카메라)
  /// - replaceFileAtIndex: 파일 교체
  /// - removeAtIndex: 이미지 제거
  /// - reorderImages: 이미지 순서 변경
  /// - moveToFront: 썸네일로 이동
  /// - updateCurrentIndex: Carousel 인덱스 업데이트
  /// - updateUploadedUrls: 업로드 URL 업데이트
  /// - toggleVideoSelection: 비디오 선택 토글
  /// - toggleBoxBVisibility: B박스 표시 토글
  /// - updateLayout: 레이아웃 계산 및 업데이트
  /// - resetLayout: 레이아웃 초기화
  /// - clearBox: 박스 클리어
  /// - clearAll: 전체 클리어
  /// - canAddMore: 추가 가능 여부
  /// - getSelectedAssetIds: AssetEntity ID 가져오기
  /// - getRepresentativeRatioA: A박스 대표 비율
  /// - getRepresentativeRatioB: B박스 대표 비율
  const MediaSelectionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mediaSelectionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mediaSelectionHash();

  @$internal
  @override
  MediaSelection create() => MediaSelection();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MediaSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MediaSelectionState>(value),
    );
  }
}

String _$mediaSelectionHash() => r'017c876468969c38a2247f783e8c9e33cbc5c1c4';

/// Media selection notifier - Riverpod 3.x (Phase 2-7-1)
/// 미디어 선택 상태 관리를 위한 Notifier
///
/// **Migration**: MediaSelectionProvider → MediaSelectionNotifier
/// **Phase**: 2-7-1 (MediaSelection Riverpod Notifier 생성)
///
/// **Methods** (20개):
/// - selectImages: 이미지 선택 (AssetEntity → File 변환)
/// - addFile: 단일 파일 추가 (편집/카메라)
/// - replaceFileAtIndex: 파일 교체
/// - removeAtIndex: 이미지 제거
/// - reorderImages: 이미지 순서 변경
/// - moveToFront: 썸네일로 이동
/// - updateCurrentIndex: Carousel 인덱스 업데이트
/// - updateUploadedUrls: 업로드 URL 업데이트
/// - toggleVideoSelection: 비디오 선택 토글
/// - toggleBoxBVisibility: B박스 표시 토글
/// - updateLayout: 레이아웃 계산 및 업데이트
/// - resetLayout: 레이아웃 초기화
/// - clearBox: 박스 클리어
/// - clearAll: 전체 클리어
/// - canAddMore: 추가 가능 여부
/// - getSelectedAssetIds: AssetEntity ID 가져오기
/// - getRepresentativeRatioA: A박스 대표 비율
/// - getRepresentativeRatioB: B박스 대표 비율

abstract class _$MediaSelection extends $Notifier<MediaSelectionState> {
  MediaSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<MediaSelectionState, MediaSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<MediaSelectionState, MediaSelectionState>,
              MediaSelectionState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
