import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/create_post_provider_v2.dart';
import '../../providers/media/media_selection_provider.dart';
import '/features/creation/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/creation/presentation/widgets/media/media_selection_flow_widget.dart';
import '/core/types/layout_type.dart'; // Phase 5: Provider의 LayoutType 읽기용 (직접 생성 안 함)
import '/features/creation/domain/constants/dimensions.dart' as post_dimensions;
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
  @override
  Widget build(BuildContext context) {
    return Consumer2<CreatePostProviderV2, MediaSelectionProvider>(
      builder: (context, provider, mediaSelection, child) {
        // Phase 5 Clean Architecture: Provider가 레이아웃 관리
        // Widget은 Provider 상태만 읽음
        _updateLayoutIfNeeded(mediaSelection);

        return Column(
          children: [
            // 레이아웃 정보 (디버그 모드에서만)
            if (kDebugMode) _buildLayoutDebugInfo(mediaSelection),

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

  Widget _buildMediaSection(CreatePostProviderV2 provider) {
    // MediaSelectionProvider는 context에서 직접 가져옴
    final mediaSelection = Provider.of<MediaSelectionProvider>(context, listen: false);

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
          _buildMediaBoxes(provider, mediaSelection),
        ],
      ),
    );
  }

  Widget _buildMediaBoxes(CreatePostProviderV2 provider, MediaSelectionProvider mediaSelection) {
    // Phase 5: Provider의 레이아웃 상태 사용
    final isHorizontal = mediaSelection.currentLayout == LayoutType.horizontal;

    if (isHorizontal) {
      // 가로 레이아웃
      return Row(
        children: [
          Expanded(
            child: _buildMediaBox(
              box: 'A',
              provider: provider,
              mediaSelection: mediaSelection,
            ),
          ),
          if (!widget.absellected) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaBox(
                box: 'B',
                provider: provider,
                mediaSelection: mediaSelection,
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
            provider: provider,
            mediaSelection: mediaSelection,
          ),
          if (!widget.absellected) ...[
            const SizedBox(height: 8),
            _buildMediaBox(
              box: 'B',
              provider: provider,
              mediaSelection: mediaSelection,
            ),
          ],
        ],
      );
    }
  }

  Widget _buildMediaBox({
    required String box,
    required CreatePostProviderV2 provider,
    required MediaSelectionProvider mediaSelection,
  }) {
    final images = box == 'A'
        ? mediaSelection.selectedFilesA
        : mediaSelection.selectedFilesB;

    final uploadedUrls = box == 'A'
        ? mediaSelection.uploadedUrlsA
        : mediaSelection.uploadedUrlsB;

    // Phase 5: Provider의 박스 크기 사용
    final boxWidth = box == 'A' ? mediaSelection.boxWidthA : mediaSelection.boxWidthB;
    final boxHeight = box == 'A' ? mediaSelection.boxHeightA : mediaSelection.boxHeightB;

    return GestureDetector(
      onTap: () => _handleBoxTap(box, provider, mediaSelection),
      child: MediaSelectionBoxMulti(
        label: box,
        isSelected: widget.absellected,
        isVideoSelected: mediaSelection.isVideoSelectedA,
        isHorizontal: mediaSelection.currentLayout == LayoutType.horizontal,
        boxColor: box == 'A' ? Colors.blue.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        imageUrls: uploadedUrls,
        imageFiles: images.isNotEmpty ? images : null,
        dynamicHeight: boxHeight ?? post_dimensions.MediaDimensions.defaultBoxHeight,
        dynamicWidth: boxWidth,
        onTap: () => _handleBoxTap(box, provider, mediaSelection),
        onEditTap: images.isNotEmpty
            ? () => _handleImageEdit(box, provider, mediaSelection)
            : null,
        onAddImageTap: images.isNotEmpty
            ? () => _handleAddMore(box, provider, mediaSelection)
            : null,
        showPlusIcon: box == 'A' && !widget.absellected,
        onPlusIconTap: box == 'A' && !widget.absellected
            ? () => setState(() {
                // B박스 토글 로직
                mediaSelection.toggleBoxBVisibility();
              })
            : null,
        onCancel: (index) => _handleDeleteImage(box, index, provider, mediaSelection),
        onCurrentIndexChanged: (index) => mediaSelection.updateCurrentIndex(box: box, index: index),
      ),
    );
  }

  Future<void> _handleBoxTap(
    String box,
    CreatePostProviderV2 provider,
    MediaSelectionProvider mediaSelection,
  ) async {
    // B박스 검증: A박스가 비어있으면 경고
    if (box == 'B' && !mediaSelection.canAddToBoxB()) {
      final message = mediaSelection.getBoxBValidationMessage();
      if (message != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // 이미지 선택 플로우
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return MediaSelectionFlowWidget(
          box: box,
          onComplete: (String imageUrl) {
            // Legacy parameter - not used in Phase 5
          },
          onImagesSelected: (List<AssetEntity> assets) async {
            // AssetEntity를 File로 변환
            final files = await Future.wait(
              assets.map((asset) => asset.file),
            );

            final validFiles = files.whereType<File>().toList();

            // MediaSelectionProvider를 통해 상태 업데이트
            await mediaSelection.selectImages(
              box: box,
              assets: assets,
            );

            // Provider에도 동기화
            if (box == 'A') {
              provider.updateImagesA(validFiles);
            } else {
              provider.updateImagesB(validFiles);
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
    CreatePostProviderV2 provider,
    MediaSelectionProvider mediaSelection,
  ) async {
    widget.onImageEdit?.call(box);
  }

  Future<void> _handleAddMore(
    String box,
    CreatePostProviderV2 provider,
    MediaSelectionProvider mediaSelection,
  ) async {
    await _handleBoxTap(box, provider, mediaSelection);
  }

  void _handleDeleteImage(
    String box,
    int index,
    CreatePostProviderV2 provider,
    MediaSelectionProvider mediaSelection,
  ) {
    // MediaSelectionProvider에서 직접 삭제
    mediaSelection.removeAtIndex(box: box, index: index);

    // Provider도 동기화
    if (box == 'A') {
      provider.updateImagesA(mediaSelection.selectedFilesA);
    } else {
      provider.updateImagesB(mediaSelection.selectedFilesB);
    }
  }

  /// Phase 5 Clean Architecture: Widget은 Provider에 위임만 함
  /// Widget → Provider → Domain/Service (올바른 패턴)
  void _updateLayoutIfNeeded(MediaSelectionProvider mediaSelection) {
    final screenWidth = MediaQuery.of(context).size.width - 32; // 패딩 제외

    // Provider가 레이아웃 관리 책임을 가짐
    mediaSelection.updateLayout(
      containerWidth: screenWidth,
      absellected: widget.absellected,
    );
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

  Widget _buildLayoutDebugInfo(MediaSelectionProvider mediaSelection) {
    // Phase 5: Provider의 레이아웃 상태 사용
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Layout: ${mediaSelection.currentLayout} | '
        'A: ${mediaSelection.boxWidthA?.toStringAsFixed(0)}x${mediaSelection.boxHeightA?.toStringAsFixed(0)} | '
        'B: ${mediaSelection.boxWidthB?.toStringAsFixed(0)}x${mediaSelection.boxHeightB?.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}