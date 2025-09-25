import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '../../adapters/create_post_adapter.dart';
import '../../providers/create_post_provider_v2.dart';
import '/features/posts/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/posts/presentation/widgets/media/media_selection_flow_widget.dart';
import '/core/utils/media/aspect_ratio_analyzer.dart';
import '/services/ui/unified_box_calculator.dart';
import '/core/types/layout_type.dart';
import '/features/posts/domain/constants/dimensions.dart' as post_dimensions;
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
    return Consumer2<AppState, CreatePostProviderV2>(
      builder: (context, appState, cleanProvider, child) {
        // Adapter를 통해 상태 연결
        final adapter = CreatePostAdapter(
          cleanProvider: cleanProvider,
          legacyState: appState,
        );

        // 레이아웃 업데이트
        _updateLayoutBasedOnImages(appState);

        return Column(
          children: [
            // 레이아웃 정보 (디버그 모드에서만)
            if (kDebugMode) _buildLayoutDebugInfo(),

            // 메인 미디어 섹션
            _buildMediaSection(appState, adapter),

            // 경고 메시지
            if (_shouldShowWarning(appState))
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
    final images = box == 'A'
        ? appState.tempImageFilesA
        : appState.tempImageFilesB;

    final uploadedUrls = box == 'A'
        ? appState.uploadImageA
        : appState.uploadImageB;

    final boxWidth = box == 'A' ? _boxWidthA : _boxWidthB;
    final boxHeight = box == 'A' ? _boxHeightA : _boxHeightB;

    return GestureDetector(
      onTap: () => _handleBoxTap(box, appState, adapter),
      child: MediaSelectionBoxMulti(
        images: images.isNotEmpty
            ? images
            : uploadedUrls.map((url) => File(url)).toList(),
        box: box,
        isAbsellected: widget.absellected,
        dynamicHeight: boxHeight ?? post_dimensions.MediaDimensions.defaultBoxHeight,
        dynamicWidth: boxWidth,
        onTap: () => _handleBoxTap(box, appState, adapter),
        onEdit: images.isNotEmpty
            ? () => _handleImageEdit(box, appState, adapter)
            : null,
        onAddMore: images.isNotEmpty
            ? () => _handleAddMore(box, appState, adapter)
            : null,
        onToggleB: box == 'A' && images.isNotEmpty
            ? () => setState(() {
                // B박스 토글 로직
              })
            : null,
        onCancel: () => _handleDeleteImages(box, appState, adapter),
        validationSessionId: widget.validationSessionId,
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

  void _handleDeleteImages(
    String box,
    AppState appState,
    CreatePostAdapter adapter,
  ) {
    if (box == 'A') {
      adapter.updateTempImagesA([]);
      adapter.updateImagesA([]);
    } else {
      adapter.updateTempImagesB([]);
      adapter.updateImagesB([]);
    }
  }

  void _updateLayoutBasedOnImages(AppState appState) {
    // 이미지가 없으면 기본 레이아웃
    if (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) {
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

    if (appState.uploadImageAspectRatioA.isNotEmpty) {
      ratioA = appState.uploadImageAspectRatioA.first;
    }

    if (!widget.absellected && appState.uploadImageAspectRatioB.isNotEmpty) {
      ratioB = appState.uploadImageAspectRatioB.first;
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

  bool _shouldShowWarning(AppState appState) {
    // A박스가 비어있고 B박스에 이미지가 있는 경우
    return appState.tempImageFilesA.isEmpty &&
           appState.tempImageFilesB.isNotEmpty;
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