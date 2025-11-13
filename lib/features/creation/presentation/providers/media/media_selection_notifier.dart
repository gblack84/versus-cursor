import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/core/types/layout_type.dart';
import '/core/utils/ui/box_sizing/aspect_ratio_analyzer.dart';
import '/features/creation/domain/usecases/media/ratio_calculator.dart';
import '/features/creation/domain/services/i_box_calculator_service.dart';
import '/app/di.dart';
import 'states/media_selection_state.dart';

part 'media_selection_notifier.g.dart';

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
@riverpod
class MediaSelection extends _$MediaSelection {
  @override
  MediaSelectionState build() {
    return const MediaSelectionState();
  }

  // ============= Image Selection =============

  /// Select images from gallery
  /// 갤러리에서 이미지 선택 (AssetEntity → File 변환)
  Future<void> selectImages({
    required String box,
    required List<AssetEntity> assets,
  }) async {
    // Convert AssetEntity to File
    final files = await Future.wait(
      assets.map((asset) => asset.file),
    );
    final validFiles = files.whereType<File>().toList();

    if (validFiles.isEmpty) return;

    // Calculate aspect ratios
    final aspectRatios = <double>[];
    final localPaths = <String>[];
    final assetEntityIds = <String>[];

    for (int i = 0; i < assets.length; i++) {
      final asset = assets[i];
      if (i < validFiles.length) {
        final file = validFiles[i];

        // Calculate aspect ratio
        final width = asset.width.toDouble();
        final height = asset.height.toDouble();
        final aspectRatio = width > 0 && height > 0 ? width / height : 1.0;

        aspectRatios.add(aspectRatio);
        localPaths.add(file.path);
        assetEntityIds.add(asset.id);
      }
    }

    // Update state immutably
    if (box == 'A') {
      state = state.copyWith(
        selectedFilesA: validFiles,
        aspectRatiosA: aspectRatios,
        localPathsA: localPaths,
        assetEntityIdsA: assetEntityIds,
        currentIndexA: 0,
        isVideoSelectedA: assets.first.type == AssetType.video,
      );
    } else if (box == 'B') {
      state = state.copyWith(
        selectedFilesB: validFiles,
        aspectRatiosB: aspectRatios,
        localPathsB: localPaths,
        assetEntityIdsB: assetEntityIds,
        currentIndexB: 0,
        isVideoSelectedB: assets.first.type == AssetType.video,
      );
    }
  }

  /// Add a single file (from editing or camera)
  /// 단일 파일 추가 (편집 또는 카메라에서)
  void addFile({
    required String box,
    required File file,
    required double aspectRatio,
    String? assetId,
  }) {
    if (box == 'A' && state.selectedFilesA.length < kMaxImages) {
      state = state.copyWith(
        selectedFilesA: [...state.selectedFilesA, file],
        localPathsA: [...state.localPathsA, file.path],
        aspectRatiosA: [...state.aspectRatiosA, aspectRatio],
        assetEntityIdsA: assetId != null
            ? [...state.assetEntityIdsA, assetId]
            : state.assetEntityIdsA,
      );
    } else if (box == 'B' && state.selectedFilesB.length < kMaxImages) {
      state = state.copyWith(
        selectedFilesB: [...state.selectedFilesB, file],
        localPathsB: [...state.localPathsB, file.path],
        aspectRatiosB: [...state.aspectRatiosB, aspectRatio],
        assetEntityIdsB: assetId != null
            ? [...state.assetEntityIdsB, assetId]
            : state.assetEntityIdsB,
      );
    }
  }

  /// Replace file at index (for editing)
  /// 인덱스 위치의 파일 교체 (편집용)
  void replaceFileAtIndex({
    required String box,
    required int index,
    required File file,
    required double aspectRatio,
  }) {
    if (box == 'A' && index >= 0 && index < state.selectedFilesA.length) {
      final newFiles = List<File>.from(state.selectedFilesA);
      final newPaths = List<String>.from(state.localPathsA);
      final newRatios = List<double>.from(state.aspectRatiosA);

      newFiles[index] = file;
      newPaths[index] = file.path;
      newRatios[index] = aspectRatio;

      state = state.copyWith(
        selectedFilesA: newFiles,
        localPathsA: newPaths,
        aspectRatiosA: newRatios,
      );
    } else if (box == 'B' && index >= 0 && index < state.selectedFilesB.length) {
      final newFiles = List<File>.from(state.selectedFilesB);
      final newPaths = List<String>.from(state.localPathsB);
      final newRatios = List<double>.from(state.aspectRatiosB);

      newFiles[index] = file;
      newPaths[index] = file.path;
      newRatios[index] = aspectRatio;

      state = state.copyWith(
        selectedFilesB: newFiles,
        localPathsB: newPaths,
        aspectRatiosB: newRatios,
      );
    }
  }

  /// Remove image at index
  /// 인덱스 위치의 이미지 제거
  void removeAtIndex({
    required String box,
    required int index,
  }) {
    if (box == 'A' && index >= 0 && index < state.selectedFilesA.length) {
      final newFiles = List<File>.from(state.selectedFilesA);
      final newPaths = List<String>.from(state.localPathsA);
      final newRatios = List<double>.from(state.aspectRatiosA);
      final newAssetIds = List<String>.from(state.assetEntityIdsA);
      final newUrls = List<String>.from(state.uploadedUrlsA);

      newFiles.removeAt(index);
      newPaths.removeAt(index);
      newRatios.removeAt(index);

      if (index < newAssetIds.length) {
        newAssetIds.removeAt(index);
      }
      if (index < newUrls.length) {
        newUrls.removeAt(index);
      }

      // Adjust current index if needed
      int newCurrentIndex = state.currentIndexA;
      if (newCurrentIndex >= newFiles.length && newCurrentIndex > 0) {
        newCurrentIndex = newFiles.length - 1;
      }

      state = state.copyWith(
        selectedFilesA: newFiles,
        localPathsA: newPaths,
        aspectRatiosA: newRatios,
        assetEntityIdsA: newAssetIds,
        uploadedUrlsA: newUrls,
        currentIndexA: newCurrentIndex,
      );
    } else if (box == 'B' && index >= 0 && index < state.selectedFilesB.length) {
      final newFiles = List<File>.from(state.selectedFilesB);
      final newPaths = List<String>.from(state.localPathsB);
      final newRatios = List<double>.from(state.aspectRatiosB);
      final newAssetIds = List<String>.from(state.assetEntityIdsB);
      final newUrls = List<String>.from(state.uploadedUrlsB);

      newFiles.removeAt(index);
      newPaths.removeAt(index);
      newRatios.removeAt(index);

      if (index < newAssetIds.length) {
        newAssetIds.removeAt(index);
      }
      if (index < newUrls.length) {
        newUrls.removeAt(index);
      }

      // Adjust current index if needed
      int newCurrentIndex = state.currentIndexB;
      if (newCurrentIndex >= newFiles.length && newCurrentIndex > 0) {
        newCurrentIndex = newFiles.length - 1;
      }

      state = state.copyWith(
        selectedFilesB: newFiles,
        localPathsB: newPaths,
        aspectRatiosB: newRatios,
        assetEntityIdsB: newAssetIds,
        uploadedUrlsB: newUrls,
        currentIndexB: newCurrentIndex,
      );
    }
  }

  /// Reorder images
  /// 이미지 순서 변경
  void reorderImages({
    required String box,
    required int oldIndex,
    required int newIndex,
  }) {
    if (box == 'A') {
      if (oldIndex >= 0 && oldIndex < state.selectedFilesA.length &&
          newIndex >= 0 && newIndex < state.selectedFilesA.length) {
        // Create mutable copies
        final newFiles = List<File>.from(state.selectedFilesA);
        final newPaths = List<String>.from(state.localPathsA);
        final newRatios = List<double>.from(state.aspectRatiosA);
        final newAssetIds = List<String>.from(state.assetEntityIdsA);
        final newUrls = List<String>.from(state.uploadedUrlsA);

        // Reorder all related lists
        final file = newFiles.removeAt(oldIndex);
        newFiles.insert(newIndex, file);

        final path = newPaths.removeAt(oldIndex);
        newPaths.insert(newIndex, path);

        final ratio = newRatios.removeAt(oldIndex);
        newRatios.insert(newIndex, ratio);

        if (oldIndex < newAssetIds.length) {
          final assetId = newAssetIds.removeAt(oldIndex);
          newAssetIds.insert(newIndex, assetId);
        }

        if (oldIndex < newUrls.length) {
          final url = newUrls.removeAt(oldIndex);
          newUrls.insert(newIndex, url);
        }

        state = state.copyWith(
          selectedFilesA: newFiles,
          localPathsA: newPaths,
          aspectRatiosA: newRatios,
          assetEntityIdsA: newAssetIds,
          uploadedUrlsA: newUrls,
        );
      }
    } else {
      if (oldIndex >= 0 && oldIndex < state.selectedFilesB.length &&
          newIndex >= 0 && newIndex < state.selectedFilesB.length) {
        // Create mutable copies
        final newFiles = List<File>.from(state.selectedFilesB);
        final newPaths = List<String>.from(state.localPathsB);
        final newRatios = List<double>.from(state.aspectRatiosB);
        final newAssetIds = List<String>.from(state.assetEntityIdsB);
        final newUrls = List<String>.from(state.uploadedUrlsB);

        // Reorder all related lists
        final file = newFiles.removeAt(oldIndex);
        newFiles.insert(newIndex, file);

        final path = newPaths.removeAt(oldIndex);
        newPaths.insert(newIndex, path);

        final ratio = newRatios.removeAt(oldIndex);
        newRatios.insert(newIndex, ratio);

        if (oldIndex < newAssetIds.length) {
          final assetId = newAssetIds.removeAt(oldIndex);
          newAssetIds.insert(newIndex, assetId);
        }

        if (oldIndex < newUrls.length) {
          final url = newUrls.removeAt(oldIndex);
          newUrls.insert(newIndex, url);
        }

        state = state.copyWith(
          selectedFilesB: newFiles,
          localPathsB: newPaths,
          aspectRatiosB: newRatios,
          assetEntityIdsB: newAssetIds,
          uploadedUrlsB: newUrls,
        );
      }
    }
  }

  /// Move image to front (for thumbnail selection)
  /// 이미지를 맨 앞으로 이동 (썸네일 선택)
  void moveToFront({
    required String box,
    required int index,
  }) {
    if (index > 0) {
      reorderImages(box: box, oldIndex: index, newIndex: 0);
    }
  }

  /// Update current viewing index
  /// 현재 보고 있는 인덱스 업데이트
  void updateCurrentIndex({
    required String box,
    required int index,
  }) {
    if (box == 'A' && index >= 0 && index < state.selectedFilesA.length) {
      state = state.copyWith(currentIndexA: index);
    } else if (box == 'B' && index >= 0 && index < state.selectedFilesB.length) {
      state = state.copyWith(currentIndexB: index);
    }
  }

  /// Update uploaded URLs after successful upload
  /// 업로드 성공 후 URL 업데이트
  void updateUploadedUrls({
    required String box,
    required List<String> urls,
  }) {
    if (box == 'A') {
      state = state.copyWith(uploadedUrlsA: List.from(urls));
    } else {
      state = state.copyWith(uploadedUrlsB: List.from(urls));
    }
  }

  /// Toggle video selection
  /// 비디오 선택 토글
  void toggleVideoSelection(String box) {
    if (box == 'A') {
      final newVideoSelected = !state.isVideoSelectedA;

      if (newVideoSelected) {
        // Clear images when switching to video
        state = state.copyWith(
          isVideoSelectedA: newVideoSelected,
          selectedFilesA: [],
          uploadedUrlsA: [],
          aspectRatiosA: [],
          localPathsA: [],
          assetEntityIdsA: [],
          currentIndexA: 0,
        );
      } else {
        state = state.copyWith(isVideoSelectedA: newVideoSelected);
      }
    } else {
      final newVideoSelected = !state.isVideoSelectedB;

      if (newVideoSelected) {
        // Clear images when switching to video
        state = state.copyWith(
          isVideoSelectedB: newVideoSelected,
          selectedFilesB: [],
          uploadedUrlsB: [],
          aspectRatiosB: [],
          localPathsB: [],
          assetEntityIdsB: [],
          currentIndexB: 0,
        );
      } else {
        state = state.copyWith(isVideoSelectedB: newVideoSelected);
      }
    }
  }

  /// Toggle B box visibility
  /// B박스 표시 토글
  void toggleBoxBVisibility() {
    state = state.copyWith(isBoxBVisible: !state.isBoxBVisible);
  }

  // ============= Layout Management (Phase 5 - Clean Architecture) =============

  /// Update layout based on aspect ratios
  /// 비율 기반 레이아웃 업데이트
  void updateLayout({
    required double containerWidth,
    required bool absellected,
  }) {
    // 이미지가 없으면 기본 레이아웃
    if (state.selectedFilesA.isEmpty && state.selectedFilesB.isEmpty) {
      state = state.copyWith(
        currentLayout: LayoutType.horizontal,
        boxWidthA: null,
        boxHeightA: null,
        boxWidthB: null,
        boxHeightB: null,
      );
      return;
    }

    // Aspect ratios 가져오기 (RatioCalculator로 대표 비율 계산)
    double? ratioA = state.aspectRatiosA.isNotEmpty
        ? RatioCalculator.getRatio(state.aspectRatiosA, box: 'A')
        : null;
    double? ratioB = (!absellected && state.aspectRatiosB.isNotEmpty)
        ? RatioCalculator.getRatio(state.aspectRatiosB, box: 'B')
        : null;

    // Provider가 Domain 정적 메서드 사용 (Widget이 아님)
    final layoutType = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);

    // Phase 1: Use Clean Architecture adapter (2025-11-10)
    final boxCalculatorService = getIt<IBoxCalculatorService>();

    if (layoutType == LayoutType.horizontal) {
      final data = boxCalculatorService.calculateForQuestion(
        containerWidth: containerWidth,
        layoutType: LayoutType.horizontal,
        aspectRatioA: ratioA,
        aspectRatioB: ratioB,
        hasImageA: state.selectedFilesA.isNotEmpty,
        hasImageB: state.selectedFilesB.isNotEmpty,
      );

      state = state.copyWith(
        currentLayout: LayoutType.horizontal,
        boxWidthA: data.sizeA.width,
        boxHeightA: data.sizeA.height,
        boxWidthB: data.sizeB.width,
        boxHeightB: data.sizeB.height,
      );
    } else {
      final data = boxCalculatorService.calculateForQuestion(
        containerWidth: containerWidth,
        layoutType: LayoutType.vertical,
        aspectRatioA: ratioA,
        aspectRatioB: ratioB,
        hasImageA: state.selectedFilesA.isNotEmpty,
        hasImageB: state.selectedFilesB.isNotEmpty,
      );

      state = state.copyWith(
        currentLayout: LayoutType.vertical,
        boxWidthA: data.sizeA.width,
        boxHeightA: data.sizeA.height,
        boxWidthB: data.sizeB.width,
        boxHeightB: data.sizeB.height,
      );
    }
  }

  /// Reset layout to default
  /// 레이아웃 초기화
  void resetLayout() {
    state = state.copyWith(
      currentLayout: LayoutType.horizontal,
      boxWidthA: null,
      boxHeightA: null,
      boxWidthB: null,
      boxHeightB: null,
    );
  }

  /// Clear all media in a box
  /// 박스의 모든 미디어 제거
  void clearBox(String box) {
    if (box == 'A') {
      state = state.copyWith(
        selectedFilesA: [],
        uploadedUrlsA: [],
        aspectRatiosA: [],
        localPathsA: [],
        assetEntityIdsA: [],
        currentIndexA: 0,
        isVideoSelectedA: false,
      );
    } else {
      state = state.copyWith(
        selectedFilesB: [],
        uploadedUrlsB: [],
        aspectRatiosB: [],
        localPathsB: [],
        assetEntityIdsB: [],
        currentIndexB: 0,
        isVideoSelectedB: false,
      );
    }
  }

  /// Clear all selections
  /// 모든 선택 초기화
  void clearAll() {
    state = const MediaSelectionState(); // Reset to initial state
  }

  /// Check if can add more images
  /// 더 추가할 수 있는지 확인
  bool canAddMore(String box) {
    if (box == 'A') {
      return state.isVideoSelectedA
          ? state.selectedFilesA.isEmpty
          : state.selectedFilesA.length < kMaxImages;
    } else {
      return state.isVideoSelectedB
          ? state.selectedFilesB.isEmpty
          : state.selectedFilesB.length < kMaxImages;
    }
  }

  /// Get selected AssetEntity IDs for picker
  /// 피커에서 사용할 선택된 AssetEntity ID 가져오기
  List<String> getSelectedAssetIds(String box) {
    return box == 'A'
        ? List.from(state.assetEntityIdsA)
        : List.from(state.assetEntityIdsB);
  }

  // ============= Aspect Ratio Calculation (RatioCalculator Integration) =============

  /// Get representative aspect ratio for box A
  /// A박스의 대표 비율 계산 (RatioCalculator 사용)
  ///
  /// Returns:
  /// - Calculated representative ratio for multiple images
  /// - 1.0 if no images selected
  ///
  /// Uses RatioCalculator with caching for performance optimization
  double getRepresentativeRatioA() {
    if (state.aspectRatiosA.isEmpty) return 1.0;
    return RatioCalculator.getRatio(state.aspectRatiosA, box: 'A');
  }

  /// Get representative aspect ratio for box B
  /// B박스의 대표 비율 계산 (RatioCalculator 사용)
  ///
  /// Returns:
  /// - Calculated representative ratio for multiple images
  /// - 1.0 if no images selected
  ///
  /// Uses RatioCalculator with caching for performance optimization
  double getRepresentativeRatioB() {
    if (state.aspectRatiosB.isEmpty) return 1.0;
    return RatioCalculator.getRatio(state.aspectRatiosB, box: 'B');
  }
}
