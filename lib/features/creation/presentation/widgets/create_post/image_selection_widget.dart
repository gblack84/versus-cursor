import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/create_post_provider_v2.dart';
import '../../providers/media/media_selection_provider.dart';
import '../../providers/media/media_state_coordinator.dart';
import '/app/di/creation_module.dart';
import '/features/creation/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/creation/presentation/widgets/media/media_selection_flow_widget.dart';
import '/core/utils/media/aspect_ratio_analyzer.dart';
import '/services/ui/unified_box_calculator.dart';
import '/core/types/layout_type.dart';
import '/features/creation/domain/constants/dimensions.dart' as post_dimensions;
import '/core/utils/debug_helper.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Image selection component extracted from InPutPostImageWidget
///
/// This widget handles all image selection and management functionality
/// including image picking, editing, and layout management.
class ImageSelectionWidget extends StatefulWidget {
  final Function(List<File> images, String box)? onImagesSelected;
  final Function(String box)? onImageEdit;
  final Function(String box, int index)? onImageDelete;
  final bool absellected; // A/B 박스 선택 상태
  final bool isDynamic; // 동적 레이아웃 여부
  final String? validationSessionId;

  const ImageSelectionWidget({
    super.key,
    this.onImagesSelected,
    this.onImageEdit,
    this.onImageDelete,
    this.absellected = false,
    this.isDynamic = true,
    this.validationSessionId,
  });

  @override
  State<ImageSelectionWidget> createState() => _ImageSelectionWidgetState();
}

class _ImageSelectionWidgetState extends State<ImageSelectionWidget> {
  LayoutType _currentLayout = LayoutType.horizontal;
  double? _boxWidthA;
  double? _boxHeightA;
  double? _boxWidthB;
  double? _boxHeightB;

  @override
  Widget build(BuildContext context) {
    return Consumer2<CreatePostProviderV2, MediaSelectionProvider>(
      builder: (context, provider, mediaSelection, child) {
        // Phase 5 Migration: MediaSelectionProvider 사용
        // 직접 Provider 사용으로 변경

        // 레이아웃 업데이트 - MediaSelectionProvider의 aspectRatio 사용 (Phase 5)
        _updateLayoutBasedOnImages(provider); // Provider 직접 사용

        return Column(
          children: [
            // 레이아웃 정보 (디버그 모드에서만)
            if (kDebugMode) _buildLayoutDebugInfo(),

            // 메인 미디어 섹션
            _buildMediaSection(provider),

            // 경고 메시지
            if (_shouldShowWarning(provider))
              _buildWarningMessage(),
          ],
        );
      },
    );
  }

  Widget _buildMediaSection(AppState appState, CreatePostAdapter adapter) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 라벨
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'A vs B 이미지 선택',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // 미디어 박스들
          _buildMediaBoxes(appState, adapter),
        ],
      ),
    );
  }

  Widget _buildMediaBoxes(AppState appState, CreatePostAdapter adapter) {
    final isHorizontal = _currentLayout == LayoutType.horizontal;

    if (isHorizontal) {
      // 가로 레이아웃
      return Row(
        children: [
          Expanded(
            child: _buildMediaBox(
              box: 'A',
              appState: appState,
              adapter: adapter,
            ),
          ),
          if (!widget.absellected) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaBox(
                box: 'B',
                appState: appState,
                adapter: adapter,
              ),
            ),
          ],
        ],
      );
    } else {
      // 세로 레이아웃
      return Column(
        children: [
          _buildMediaBox(
            box: 'A',
            appState: appState,
            adapter: adapter,
          ),
          if (!widget.absellected) ...[
            const SizedBox(height: 8),
            _buildMediaBox(
              box: 'B',
              appState: appState,
              adapter: adapter,
            ),
          ],
        ],
      );
    }
  }

  Widget _buildMediaBox({
    required String box,
    required AppState appState,
    required CreatePostAdapter adapter,
  }) {
    // Phase 5: MediaSelectionProvider 사용
    final mediaSelection = Provider.of<MediaSelectionProvider>(context, listen: false);

    final images = box == 'A'
        ? mediaSelection.selectedFilesA
        : mediaSelection.selectedFilesB;

    final uploadedUrls = box == 'A'
        ? mediaSelection.uploadedUrlsA
        : mediaSelection.uploadedUrlsB;

    final boxWidth = box == 'A' ? _boxWidthA : _boxWidthB;
    final boxHeight = box == 'A' ? _boxHeightA : _boxHeightB;

    return GestureDetector(
      onTap: () => _handleBoxTap(box, appState, adapter),
      child: MediaSelectionBoxMulti(
        label: box,
        isSelected: widget.absellected,
        isVideoSelected: mediaSelection.isVideoSelectedA,
        isHorizontal: _currentLayout == LayoutType.horizontal,
        boxColor: box == 'A' ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        imageUrls: uploadedUrls,
        imageFiles: images.isNotEmpty ? images : null,
        dynamicHeight: boxHeight ?? post_dimensions.MediaDimensions.defaultBoxHeight,
        dynamicWidth: boxWidth,
        onTap: () => _handleBoxTap(box, appState, adapter),
        onEditTap: images.isNotEmpty
            ? () => _handleImageEdit(box, appState, adapter)
            : null,
        onAddImageTap: images.isNotEmpty
            ? () => _handleAddMore(box, appState, adapter)
            : null,
        showPlusIcon: box == 'A' && !widget.absellected,
        onPlusIconTap: box == 'A' && !widget.absellected
            ? () => setState(() {
                // B박스 토글 로직
                mediaSelection.toggleBoxBVisibility();
              })
            : null,
        onCancel: (index) => _handleDeleteImage(box, index, appState, adapter),
        onCurrentIndexChanged: (index) => mediaSelection.updateCurrentIndex(box: box, index: index),
      ),
    );
  }

  Future<void> _handleBoxTap(
    String box,
    AppState appState,
    CreatePostAdapter adapter,
  ) async {
    // 이미지 선택 플로우
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MediaSelectionFlowWidget(
          box: box,
          onImagesSelected: (List<AssetEntity> assets) async {
            // AssetEntity를 File로 변환
            final files = await Future.wait(
              assets.map((asset) => asset.file),
            );

            final validFiles = files.whereType<File>().toList();

            // Adapter를 통해 상태 업데이트
            if (box == 'A') {
              adapter.updateTempImagesA(validFiles);
            } else {
              adapter.updateTempImagesB(validFiles);
            }

            // 콜백 호출
            widget.onImagesSelected?.call(validFiles, box);
          },
        );
      },
    );
  }

  Future<void> _handleImageEdit(
    String box,
    AppState appState,
    CreatePostAdapter adapter,
  ) async {
    widget.onImageEdit?.call(box);
  }

  Future<void> _handleAddMore(
    String box,
    AppState appState,
    CreatePostAdapter adapter,
  ) async {
    await _handleBoxTap(box, appState, adapter);
  }

  void _handleDeleteImage(
    String box,
    int index,
    AppState appState,
    CreatePostAdapter adapter,
  ) {
    // Phase 5: MediaSelectionProvider 사용
    final mediaSelection = Provider.of<MediaSelectionProvider>(context, listen: false);

    // MediaSelectionProvider에서 직접 삭제
    mediaSelection.removeAtIndex(box: box, index: index);

    // Adapter도 업데이트 (backward compatibility)
    if (box == 'A') {
      adapter.updateTempImagesA(mediaSelection.selectedFilesA);
      adapter.updateImagesA(mediaSelection.uploadedUrlsA);
    } else {
      adapter.updateTempImagesB(mediaSelection.selectedFilesB);
      adapter.updateImagesB(mediaSelection.uploadedUrlsB);
    }
  }

  void _handleDeleteImages(
    String box,
    AppState appState,
    CreatePostAdapter adapter,
  ) {
    // Phase 5: 전체 삭제
    final mediaSelection = Provider.of<MediaSelectionProvider>(context, listen: false);
    mediaSelection.clearBox(box);

    if (box == 'A') {
      adapter.updateTempImagesA([]);
      adapter.updateImagesA([]);
    } else {
      adapter.updateTempImagesB([]);
      adapter.updateImagesB([]);
    }
  }

  void _updateLayoutBasedOnImages(AppState appState) {
    // Phase 5: MediaSelectionProvider 사용
    final mediaSelection = Provider.of<MediaSelectionProvider>(context, listen: false);

    // 이미지가 없으면 기본 레이아웃
    if (mediaSelection.selectedFilesA.isEmpty && mediaSelection.selectedFilesB.isEmpty) {
      setState(() {
        _currentLayout = LayoutType.horizontal;
        _boxWidthA = null;
        _boxHeightA = null;
        _boxWidthB = null;
        _boxHeightB = null;
      });
      return;
    }

    // Aspect ratio 분석
    double? ratioA;
    double? ratioB;

    if (mediaSelection.aspectRatiosA.isNotEmpty) {
      ratioA = mediaSelection.aspectRatiosA.first;
    }

    if (!widget.absellected && mediaSelection.aspectRatiosB.isNotEmpty) {
      ratioB = mediaSelection.aspectRatiosB.first;
    }

    // 레이아웃 결정
    final analyzer = AspectRatioAnalyzer();
    final layoutType = analyzer.determineLayout(
      ratioA: ratioA,
      ratioB: ratioB,
    );

    // 박스 크기 계산
    final screenWidth = MediaQuery.of(context).size.width - 32; // 패딩 제외
    final calculator = UnifiedBoxCalculator();

    if (layoutType == LayoutType.horizontal) {
      final data = calculator.calculateBoxSizes(
        containerWidth: screenWidth,
        aspectRatioA: ratioA,
        aspectRatioB: ratioB,
        layoutType: LayoutType.horizontal,
      );

      setState(() {
        _currentLayout = LayoutType.horizontal;
        _boxWidthA = data.widthA;
        _boxHeightA = data.heightA;
        _boxWidthB = data.widthB;
        _boxHeightB = data.heightB;
      });
    } else {
      final data = calculator.calculateBoxSizes(
        containerWidth: screenWidth,
        aspectRatioA: ratioA,
        aspectRatioB: ratioB,
        layoutType: LayoutType.vertical,
      );

      setState(() {
        _currentLayout = LayoutType.vertical;
        _boxWidthA = data.widthA;
        _boxHeightA = data.heightA;
        _boxWidthB = data.widthB;
        _boxHeightB = data.heightB;
      });
    }
  }

  bool _shouldShowWarning(CreatePostProviderV2 provider) {
    // A박스가 비어있고 B박스에 이미지가 있는 경우
    final formData = provider.formData;
    return formData.imagesA.isEmpty && formData.imagesB.isNotEmpty;
  }

  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning, color: Colors.orange),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'A 항목을 먼저 입력해주세요',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayoutDebugInfo() {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Layout: $_currentLayout | '
        'A: ${_boxWidthA?.toStringAsFixed(0)}x${_boxHeightA?.toStringAsFixed(0)} | '
        'B: ${_boxWidthB?.toStringAsFixed(0)}x${_boxHeightB?.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}