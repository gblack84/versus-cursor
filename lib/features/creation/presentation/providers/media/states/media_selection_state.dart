import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/layout_type.dart';

part 'media_selection_state.freezed.dart';

/// Media selection state - Riverpod 3.x (Phase 2-7-1)
/// 미디어 선택 상태 관리를 위한 불변 State
///
/// **Migration**: MediaSelectionProvider → MediaSelectionNotifier
/// **Phase**: 2-7-1 (MediaSelection Freezed State 생성)
///
/// **State Variables** (19개):
/// - 선택된 파일 (A/B 박스별)
/// - 업로드된 URL
/// - 이미지 비율
/// - 로컬 경로
/// - AssetEntity ID
/// - 현재 인덱스
/// - 비디오 선택 여부
/// - B박스 표시 여부
/// - 레이아웃 타입 및 박스 크기
@freezed
sealed class MediaSelectionState with _$MediaSelectionState {
  const factory MediaSelectionState({
    // ============= File Selection (A/B Boxes) =============
    @Default([]) List<File> selectedFilesA,
    @Default([]) List<File> selectedFilesB,

    // ============= Uploaded URLs =============
    @Default([]) List<String> uploadedUrlsA,
    @Default([]) List<String> uploadedUrlsB,

    // ============= Aspect Ratios =============
    @Default([]) List<double> aspectRatiosA,
    @Default([]) List<double> aspectRatiosB,

    // ============= Local Paths (Fast Preview) =============
    @Default([]) List<String> localPathsA,
    @Default([]) List<String> localPathsB,

    // ============= AssetEntity IDs (Re-selection) =============
    @Default([]) List<String> assetEntityIdsA,
    @Default([]) List<String> assetEntityIdsB,

    // ============= Current Index (Carousel) =============
    @Default(0) int currentIndexA,
    @Default(0) int currentIndexB,

    // ============= Video Selection =============
    @Default(false) bool isVideoSelectedA,
    @Default(false) bool isVideoSelectedB,

    // ============= B Box Visibility =============
    @Default(false) bool isBoxBVisible,

    // ============= Layout State (Phase 5) =============
    @Default(LayoutType.horizontal) LayoutType currentLayout,
    double? boxWidthA,
    double? boxHeightA,
    double? boxWidthB,
    double? boxHeightB,
  }) = _MediaSelectionState;
}

// ============= Extension for Computed Properties =============

extension MediaSelectionStateX on MediaSelectionState {
  /// A 박스 선택된 미디어 개수
  int get countA => selectedFilesA.length;

  /// B 박스 선택된 미디어 개수
  int get countB => selectedFilesB.length;

  /// A 박스가 비어있는지
  bool get isBoxAEmpty => selectedFilesA.isEmpty;

  /// B 박스가 비어있는지
  bool get isBoxBEmpty => selectedFilesB.isEmpty;

  /// 전체 선택된 미디어 개수
  int get totalCount => countA + countB;

  /// B 박스에 추가 가능한지 검증
  /// A 박스가 비어있으면 B 박스에 추가 불가
  bool canAddToBoxB() {
    return selectedFilesA.isNotEmpty;
  }

  /// B 박스 검증 실패 메시지
  String? getBoxBValidationMessage() {
    if (selectedFilesA.isEmpty) {
      return 'A 항목을 먼저 입력해주세요';
    }
    return null;
  }
}

// ============= Constants =============

/// 최대 이미지 선택 개수
const int kMaxImages = 4;

/// 최대 비디오 선택 개수
const int kMaxVideos = 1;
