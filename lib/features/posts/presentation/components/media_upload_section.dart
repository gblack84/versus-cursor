import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '/features/posts/presentation/providers/media_upload_provider.dart';
import '/features/posts/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/posts/presentation/widgets/components/media_box_callbacks.dart';
import '/features/posts/presentation/widgets/components/layout_debug_info.dart';
import '/features/posts/domain/constants/dimensions.dart';
import '/services/ui/models/enums.dart';
import '/services/ui/models/box_calculation_params.dart';
import '/services/ui/models/box_sizes.dart';
import '/services/ui/injection/ui_service_injection.dart';

/// Media upload section component for post creation
class MediaUploadSection extends StatefulWidget {
  const MediaUploadSection({
    super.key,
    required this.isSingleMode,
    this.showDebugInfo = false,
    this.onMediaSelect,
  });
  final bool isSingleMode;
  final bool showDebugInfo;
  final Function(String box, {bool isAddMode, int? currentIndex})?
      onMediaSelect;

  @override
  State<MediaUploadSection> createState() => _MediaUploadSectionState();
}

class _MediaUploadSectionState extends State<MediaUploadSection> {
  late MediaBoxCallbacks _boxCallbacks;

  @override
  void initState() {
    super.initState();
    _boxCallbacks = MediaBoxCallbacks(context: context);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, MediaUploadProvider>(
      builder: (context, appState, uploadProvider, _) {
        // Calculate box sizes based on layout
        final params = QuestionParams(
          layoutType: uploadProvider.currentLayout,
          isVerticalRatio: uploadProvider.isVerticalRatio,
          aspectRatioA: _getAspectRatio(appState.uploadImageAspectRatioA, 'A'),
          aspectRatioB: widget.isSingleMode
              ? null
              : _getAspectRatio(appState.uploadImageAspectRatioB, 'B'),
          hasText: true,
          singleMode: widget.isSingleMode,
          maxWidth:
              MediaQuery.of(context).size.width - (Dimensions.pagePadding * 2),
        );

        final sizes = boxCalculator.calculate(params);

        return Column(
          children: [
            _buildLayoutContent(
              context: context,
              appState: appState,
              uploadProvider: uploadProvider,
              sizes: sizes,
            ),
            if (widget.showDebugInfo)
              LayoutDebugInfo(
                uploadProvider: uploadProvider,
                appState: appState,
                sizes: sizes,
              ),
          ],
        );
      },
    );
  }

  Widget _buildLayoutContent({
    required BuildContext context,
    required AppState appState,
    required MediaUploadProvider uploadProvider,
    required BoxSizes sizes,
  }) {
    final isVertical = uploadProvider.currentLayout == LayoutType.vertical;

    if (isVertical) {
      return Column(
        children: [
          _buildMediaSelectionBox(
            context: context,
            appState: appState,
            uploadProvider: uploadProvider,
            box: 'A',
            sizes: sizes,
          ),
          if (!widget.isSingleMode) ...[
            const SizedBox(height: 10),
            _buildMediaSelectionBox(
              context: context,
              appState: appState,
              uploadProvider: uploadProvider,
              box: 'B',
              sizes: sizes,
            ),
          ],
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMediaSelectionBox(
            context: context,
            appState: appState,
            uploadProvider: uploadProvider,
            box: 'A',
            sizes: sizes,
          ),
          if (!widget.isSingleMode) ...[
            const SizedBox(width: 10),
            _buildMediaSelectionBox(
              context: context,
              appState: appState,
              uploadProvider: uploadProvider,
              box: 'B',
              sizes: sizes,
            ),
          ],
        ],
      );
    }
  }

  Widget _buildMediaSelectionBox({
    required BuildContext context,
    required AppState appState,
    required MediaUploadProvider uploadProvider,
    required String box,
    required BoxSizes sizes,
  }) {
    final images = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
    final aspectRatios = box == 'A'
        ? appState.uploadImageAspectRatioA
        : appState.uploadImageAspectRatioB;
    final currentIndex = box == 'A'
        ? uploadProvider.currentImageIndexA
        : uploadProvider.currentImageIndexB;

    return MediaSelectionBoxMulti(
      box: box,
      images: images,
      aspectRatios: aspectRatios,
      currentImageIndex: currentIndex,
      dynamicWidth: box == 'A' ? sizes.boxA.width : sizes.boxB.width,
      dynamicHeight: box == 'A' ? sizes.boxA.height : sizes.boxB.height,
      absellected: widget.isSingleMode && box == 'B',
      onCancel: () =>
          _handleBoxCancel(box, images.length, uploadProvider, appState),
      onDeleteImage: (index) =>
          _handleImageDelete(box, index, uploadProvider, appState),
      onReorderImage: (index) => _handleImageReorder(box, index, appState),
      onPageChanged: (index) =>
          uploadProvider.updateCurrentImageIndex(box, index),
      onImageViewTap: () =>
          widget.onMediaSelect?.call(box, currentIndex: currentIndex),
      onPlaceholderTap: () => widget.onMediaSelect?.call(box),
      onAddImages: () => widget.onMediaSelect?.call(box, isAddMode: true),
      onEditImage: () => _handleImageEdit(box, currentIndex, appState),
    );
  }

  void _handleBoxCancel(String box, int imageCount,
      MediaUploadProvider uploadProvider, AppState appState) {
    setState(() {
      if (box == 'B' && imageCount == 0) {
        // Toggle single mode
        // This should be handled by parent widget
      }
    });
  }

  Future<void> _handleImageDelete(String box, int index,
      MediaUploadProvider uploadProvider, AppState appState) async {
    await uploadProvider.deleteImage(
      context: context,
      appState: appState,
      box: box,
      index: index,
    );
  }

  void _handleImageReorder(String box, int index, AppState appState) {
    if (box == 'A') {
      appState.moveToFrontUploadImageA(index);
    } else {
      appState.moveToFrontUploadImageB(index);
    }
  }

  void _handleImageEdit(String box, int currentIndex, AppState appState) {
    final images = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
    if (images.isNotEmpty && currentIndex < images.length) {
      widget.onMediaSelect?.call(box, currentIndex: currentIndex);
    }
  }

  double? _getAspectRatio(List<double> ratios, String box) {
    if (ratios.isEmpty) return null;

    // Calculate average aspect ratio
    double sum = 0;
    for (var ratio in ratios) {
      sum += ratio;
    }
    return sum / ratios.length;
  }
}
