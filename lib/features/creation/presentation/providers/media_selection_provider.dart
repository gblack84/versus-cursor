import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/media_selection_state.dart';

part 'media_selection_provider.g.dart';

/// Media Selection Provider
///
/// **Phase 3.5**: AppState 미디어 기능 대체
/// - Feature-First 아키텍처: AppState → MediaSelectionProvider
/// - Clean Architecture v4.0: Presentation Layer Provider
/// - Riverpod 3.x: @riverpod class pattern
///
/// **마이그레이션 근거**:
/// - AppState의 미디어 관련 메서드를 Riverpod Provider로 전환
/// - Option A/B 독립적인 상태 관리
/// - 불변성 보장 (Freezed copyWith 패턴)
///
/// **제공 기능**:
/// - Option A/B 이미지 업로드 URL 관리
/// - 선택된 파일 관리
/// - Asset Entity ID 추적
/// - 로컬 경로 관리
/// - 업로드 진행 상태 관리
@riverpod
class MediaSelection extends _$MediaSelection {
  @override
  MediaSelectionState build() {
    return MediaSelectionState.initial();
  }

  // ==================== Option A 메서드 ====================

  /// 업로드된 URL 추가 (Option A)
  ///
  /// **AppState 대체**: `addToUploadImageA(String url)`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier)
  ///    .addUploadedUrlA(url, 1.5, 'asset_123');
  /// ```
  void addUploadedUrlA({
    required String url,
    required double aspectRatio,
    required String assetId,
  }) {
    state = state.copyWith(
      uploadedUrlsA: [...state.uploadedUrlsA, url],
      aspectRatiosA: [...state.aspectRatiosA, aspectRatio],
      assetEntityIdsA: [...state.assetEntityIdsA, assetId],
    );
  }

  /// 업로드된 URL 제거 (Option A)
  ///
  /// **AppState 대체**: `removeFromUploadImageA(int index)`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).removeUploadedUrlA(0);
  /// ```
  void removeUploadedUrlA(int index) {
    if (index < 0 || index >= state.uploadedUrlsA.length) return;

    final urls = List<String>.from(state.uploadedUrlsA)..removeAt(index);
    final ratios = List<double>.from(state.aspectRatiosA)..removeAt(index);
    final ids = List<String>.from(state.assetEntityIdsA)..removeAt(index);

    state = state.copyWith(
      uploadedUrlsA: urls,
      aspectRatiosA: ratios,
      assetEntityIdsA: ids,
    );
  }

  /// 업로드된 URL 재정렬 (Option A)
  ///
  /// **AppState 대체**: AppState에서 직접 수정하던 패턴을 메서드화
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier)
  ///    .reorderUploadedUrlsA(oldIndex: 0, newIndex: 2);
  /// ```
  void reorderUploadedUrlsA({
    required int oldIndex,
    required int newIndex,
  }) {
    if (oldIndex < 0 ||
        oldIndex >= state.uploadedUrlsA.length ||
        newIndex < 0 ||
        newIndex >= state.uploadedUrlsA.length) {
      return;
    }

    final urls = List<String>.from(state.uploadedUrlsA);
    final ratios = List<double>.from(state.aspectRatiosA);
    final ids = List<String>.from(state.assetEntityIdsA);

    final url = urls.removeAt(oldIndex);
    final ratio = ratios.removeAt(oldIndex);
    final id = ids.removeAt(oldIndex);

    urls.insert(newIndex, url);
    ratios.insert(newIndex, ratio);
    ids.insert(newIndex, id);

    state = state.copyWith(
      uploadedUrlsA: urls,
      aspectRatiosA: ratios,
      assetEntityIdsA: ids,
    );
  }

  /// 선택된 파일 설정 (Option A)
  ///
  /// **AppState 대체**: `tempImageFilesA = files`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier)
  ///    .setSelectedFilesA([File('/path/to/image.jpg')]);
  /// ```
  void setSelectedFilesA(List<File> files) {
    state = state.copyWith(selectedFilesA: files);
  }

  /// 로컬 경로 설정 (Option A)
  ///
  /// **AppState 대체**: `localImagePathsA = paths`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier)
  ///    .setLocalPathsA(['/path/to/image.jpg']);
  /// ```
  void setLocalPathsA(List<String> paths) {
    state = state.copyWith(localPathsA: paths);
  }

  /// 업로드 진행 상태 설정 (Option A)
  ///
  /// **AppState 대체**: `isUploadingA = uploading`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).setUploadingA(true);
  /// ```
  void setUploadingA(bool uploading) {
    state = state.copyWith(isUploadingA: uploading);
  }

  /// 업로드된 URL 전체 교체 (Option A)
  ///
  /// **AppState 대체**: `uploadImageA = urls`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier)
  ///    .setUploadedUrlsA(urls, ratios, ids);
  /// ```
  void setUploadedUrlsA({
    required List<String> urls,
    required List<double> aspectRatios,
    required List<String> assetIds,
  }) {
    state = state.copyWith(
      uploadedUrlsA: urls,
      aspectRatiosA: aspectRatios,
      assetEntityIdsA: assetIds,
    );
  }

  /// 선택된 파일 추가 (Option A)
  ///
  /// **AppState 대체**: `addToTempImageFilesA()`, `addToUploadImageAspectRatioA()`, `addToAssetEntityIdsA()`
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).addSelectedFileA(
  ///   file: File('/path/to/image.jpg'),
  ///   aspectRatio: 1.5,
  ///   assetId: 'asset_123',
  /// );
  /// ```
  void addSelectedFileA({
    required File file,
    required double aspectRatio,
    required String assetId,
  }) {
    state = state.copyWith(
      selectedFilesA: [...state.selectedFilesA, file],
      aspectRatiosA: [...state.aspectRatiosA, aspectRatio],
      assetEntityIdsA: [...state.assetEntityIdsA, assetId],
    );
  }

  // ==================== Option B 메서드 ====================

  /// 업로드된 URL 추가 (Option B)
  ///
  /// **AppState 대체**: `addToUploadImageB(String url)`
  void addUploadedUrlB({
    required String url,
    required double aspectRatio,
    required String assetId,
  }) {
    state = state.copyWith(
      uploadedUrlsB: [...state.uploadedUrlsB, url],
      aspectRatiosB: [...state.aspectRatiosB, aspectRatio],
      assetEntityIdsB: [...state.assetEntityIdsB, assetId],
    );
  }

  /// 업로드된 URL 제거 (Option B)
  ///
  /// **AppState 대체**: `removeFromUploadImageB(int index)`
  void removeUploadedUrlB(int index) {
    if (index < 0 || index >= state.uploadedUrlsB.length) return;

    final urls = List<String>.from(state.uploadedUrlsB)..removeAt(index);
    final ratios = List<double>.from(state.aspectRatiosB)..removeAt(index);
    final ids = List<String>.from(state.assetEntityIdsB)..removeAt(index);

    state = state.copyWith(
      uploadedUrlsB: urls,
      aspectRatiosB: ratios,
      assetEntityIdsB: ids,
    );
  }

  /// 업로드된 URL 재정렬 (Option B)
  ///
  /// **AppState 대체**: AppState에서 직접 수정하던 패턴을 메서드화
  void reorderUploadedUrlsB({
    required int oldIndex,
    required int newIndex,
  }) {
    if (oldIndex < 0 ||
        oldIndex >= state.uploadedUrlsB.length ||
        newIndex < 0 ||
        newIndex >= state.uploadedUrlsB.length) {
      return;
    }

    final urls = List<String>.from(state.uploadedUrlsB);
    final ratios = List<double>.from(state.aspectRatiosB);
    final ids = List<String>.from(state.assetEntityIdsB);

    final url = urls.removeAt(oldIndex);
    final ratio = ratios.removeAt(oldIndex);
    final id = ids.removeAt(oldIndex);

    urls.insert(newIndex, url);
    ratios.insert(newIndex, ratio);
    ids.insert(newIndex, id);

    state = state.copyWith(
      uploadedUrlsB: urls,
      aspectRatiosB: ratios,
      assetEntityIdsB: ids,
    );
  }

  /// 선택된 파일 설정 (Option B)
  ///
  /// **AppState 대체**: `tempImageFilesB = files`
  void setSelectedFilesB(List<File> files) {
    state = state.copyWith(selectedFilesB: files);
  }

  /// 로컬 경로 설정 (Option B)
  ///
  /// **AppState 대체**: `localImagePathsB = paths`
  void setLocalPathsB(List<String> paths) {
    state = state.copyWith(localPathsB: paths);
  }

  /// 업로드 진행 상태 설정 (Option B)
  ///
  /// **AppState 대체**: `isUploadingB = uploading`
  void setUploadingB(bool uploading) {
    state = state.copyWith(isUploadingB: uploading);
  }

  /// 업로드된 URL 전체 교체 (Option B)
  ///
  /// **AppState 대체**: `uploadImageB = urls`
  void setUploadedUrlsB({
    required List<String> urls,
    required List<double> aspectRatios,
    required List<String> assetIds,
  }) {
    state = state.copyWith(
      uploadedUrlsB: urls,
      aspectRatiosB: aspectRatios,
      assetEntityIdsB: assetIds,
    );
  }

  /// 선택된 파일 추가 (Option B)
  ///
  /// **AppState 대체**: `addToTempImageFilesB()`, `addToUploadImageAspectRatioB()`, `addToAssetEntityIdsB()`
  void addSelectedFileB({
    required File file,
    required double aspectRatio,
    required String assetId,
  }) {
    state = state.copyWith(
      selectedFilesB: [...state.selectedFilesB, file],
      aspectRatiosB: [...state.aspectRatiosB, aspectRatio],
      assetEntityIdsB: [...state.assetEntityIdsB, assetId],
    );
  }

  // ==================== 공통 메서드 ====================

  /// 전체 상태 초기화
  ///
  /// **AppState 대체**: 각 필드를 개별적으로 초기화하던 패턴을 메서드화
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).reset();
  /// ```
  void reset() {
    state = MediaSelectionState.initial();
  }

  /// Option A만 초기화
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).resetOptionA();
  /// ```
  void resetOptionA() {
    state = state.copyWith(
      uploadedUrlsA: [],
      selectedFilesA: [],
      aspectRatiosA: [],
      assetEntityIdsA: [],
      localPathsA: [],
      isUploadingA: false,
    );
  }

  /// Option B만 초기화
  ///
  /// **사용 예시**:
  /// ```dart
  /// ref.read(mediaSelectionProvider.notifier).resetOptionB();
  /// ```
  void resetOptionB() {
    state = state.copyWith(
      uploadedUrlsB: [],
      selectedFilesB: [],
      aspectRatiosB: [],
      assetEntityIdsB: [],
      localPathsB: [],
      isUploadingB: false,
    );
  }

  /// 특정 인덱스의 데이터 가져오기 (Option A)
  ///
  /// **반환값**: (url, aspectRatio, assetId)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final data = ref.read(mediaSelectionProvider.notifier).getMediaDataA(0);
  /// if (data != null) {
  ///   print('URL: ${data.$1}, Ratio: ${data.$2}, ID: ${data.$3}');
  /// }
  /// ```
  (String, double, String)? getMediaDataA(int index) {
    if (index < 0 || index >= state.uploadedUrlsA.length) return null;

    return (
      state.uploadedUrlsA[index],
      state.aspectRatiosA[index],
      state.assetEntityIdsA[index],
    );
  }

  /// 특정 인덱스의 데이터 가져오기 (Option B)
  ///
  /// **반환값**: (url, aspectRatio, assetId)
  (String, double, String)? getMediaDataB(int index) {
    if (index < 0 || index >= state.uploadedUrlsB.length) return null;

    return (
      state.uploadedUrlsB[index],
      state.aspectRatiosB[index],
      state.assetEntityIdsB[index],
    );
  }
}
