import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'media_selection_state.freezed.dart';

/// Media Selection State
///
/// **Phase 3.5**: AppState 미디어 기능 대체
/// - Feature-First 아키텍처: AppState → MediaSelectionState
/// - Clean Architecture v4.0: Domain Layer Entity
///
/// **마이그레이션 근거**:
/// - AppState의 미디어 관련 프로퍼티 12개를 Freezed 불변 State로 전환
/// - Option A/B 각각 독립적인 상태 관리
/// - Riverpod 3.x Provider 패턴 준수
///
/// **상태 구조**:
/// - Option A: 업로드된 URL, 선택된 파일, 로컬 경로, 업로드 진행 상태
/// - Option B: 동일한 구조
/// - 각 Option은 독립적으로 초기화 및 리셋 가능
@freezed
sealed class MediaSelectionState with _$MediaSelectionState {
  const MediaSelectionState._();

  const factory MediaSelectionState({
    // ==================== Option A 상태 (6개 필드) ====================

    /// 업로드된 이미지 URL 목록 (Option A)
    ///
    /// **AppState 대체**: `List<String> uploadImageA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final urls = ref.watch(mediaSelectionProvider).uploadedUrlsA;
    /// ```
    @Default([]) List<String> uploadedUrlsA,

    /// 선택된 이미지 파일 목록 (Option A)
    ///
    /// **AppState 대체**: `List<File> tempImageFilesA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final files = ref.watch(mediaSelectionProvider).selectedFilesA;
    /// ```
    @Default([]) List<File> selectedFilesA,

    /// 이미지 가로세로 비율 목록 (Option A)
    ///
    /// **AppState 대체**: `List<double> uploadImageAspectRatioA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final ratios = ref.watch(mediaSelectionProvider).aspectRatiosA;
    /// ```
    @Default([]) List<double> aspectRatiosA,

    /// Asset Entity ID 목록 (Option A)
    ///
    /// **AppState 대체**: `List<String> assetEntityIdsA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final ids = ref.watch(mediaSelectionProvider).assetEntityIdsA;
    /// ```
    @Default([]) List<String> assetEntityIdsA,

    /// 로컬 이미지 경로 목록 (Option A)
    ///
    /// **AppState 대체**: `List<String> localImagePathsA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final paths = ref.watch(mediaSelectionProvider).localPathsA;
    /// ```
    @Default([]) List<String> localPathsA,

    /// 업로드 진행 중 여부 (Option A)
    ///
    /// **AppState 대체**: `bool isUploadingA`
    ///
    /// **사용 예시**:
    /// ```dart
    /// final isUploading = ref.watch(mediaSelectionProvider).isUploadingA;
    /// if (isUploading) CircularProgressIndicator();
    /// ```
    @Default(false) bool isUploadingA,

    // ==================== Option B 상태 (6개 필드) ====================

    /// 업로드된 이미지 URL 목록 (Option B)
    ///
    /// **AppState 대체**: `List<String> uploadImageB`
    @Default([]) List<String> uploadedUrlsB,

    /// 선택된 이미지 파일 목록 (Option B)
    ///
    /// **AppState 대체**: `List<File> tempImageFilesB`
    @Default([]) List<File> selectedFilesB,

    /// 이미지 가로세로 비율 목록 (Option B)
    ///
    /// **AppState 대체**: `List<double> uploadImageAspectRatioB`
    @Default([]) List<double> aspectRatiosB,

    /// Asset Entity ID 목록 (Option B)
    ///
    /// **AppState 대체**: `List<String> assetEntityIdsB`
    @Default([]) List<String> assetEntityIdsB,

    /// 로컬 이미지 경로 목록 (Option B)
    ///
    /// **AppState 대체**: `List<String> localImagePathsB`
    @Default([]) List<String> localPathsB,

    /// 업로드 진행 중 여부 (Option B)
    ///
    /// **AppState 대체**: `bool isUploadingB`
    @Default(false) bool isUploadingB,
  }) = _MediaSelectionState;

  /// Initial state factory
  ///
  /// **사용 예시**:
  /// ```dart
  /// @override
  /// MediaSelectionState build() => MediaSelectionState.initial();
  /// ```
  factory MediaSelectionState.initial() => const MediaSelectionState();
}
