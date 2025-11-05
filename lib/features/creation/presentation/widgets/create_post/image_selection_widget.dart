import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/creation_providers.dart';
import '../../providers/create_post_notifier.dart'; // For createPostProvider
import '../../providers/states/create_post_state.dart'; // For CreatePostState
import '../../providers/media/states/media_selection_state.dart'; // For MediaSelectionState
import '/features/creation/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/creation/presentation/widgets/media/media_selection_flow_widget.dart';
import '/core/types/layout_type.dart'; // Phase 5: Provider의 LayoutType 읽기용 (직접 생성 안 함)
import '/features/creation/presentation/constants/dimensions.dart' as post_dimensions;
import '/features/creation/presentation/constants/colors.dart'; // Phase 2: Box colors
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Image selection component extracted from InPutPostImageWidget
///
/// This widget handles all image selection and management functionality
/// including image picking, editing, and layout management.
///
/// **Migrated to Riverpod 3.x** (Phase 2-13)
class ImageSelectionWidget extends ConsumerStatefulWidget {
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
  ConsumerState<ImageSelectionWidget> createState() => _ImageSelectionWidgetState();
}

class _ImageSelectionWidgetState extends ConsumerState<ImageSelectionWidget> {
  @override
  Widget build(BuildContext context) {
    // Riverpod 3.x: ref.watch() 사용
    final createPostState = ref.watch(createPostProvider);
    final mediaSelectionState = ref.watch(mediaSelectionProvider);

    // Phase 5 Clean Architecture: Provider가 레이아웃 관리
    // Widget은 Provider 상태만 읽음
    _updateLayoutIfNeeded(mediaSelectionState);

    return Column(
      children: [
        // 레이아웃 정보 (디버그 모드에서만)
        if (kDebugMode) _buildLayoutDebugInfo(mediaSelectionState),

        // 메인 미디어 섹션
        _buildMediaSection(createPostState, mediaSelectionState),

        // 경고 메시지
        if (_shouldShowWarning(createPostState))
          _buildWarningMessage(),
      ],
    );
  }

  Widget _buildMediaSection(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {

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
          _buildMediaBoxes(createPostState, mediaSelectionState),
        ],
      ),
    );
  }

  Widget _buildMediaBoxes(CreatePostState createPostState, MediaSelectionState mediaSelectionState) {
    // Phase 5: Provider의 레이아웃 상태 사용
    final isHorizontal = mediaSelectionState.currentLayout == LayoutType.horizontal;

    if (isHorizontal) {
      // 가로 레이아웃
      return Row(
        children: [
          Expanded(
            child: _buildMediaBox(
              box: 'A',
              createPostState: createPostState,
              mediaSelectionState: mediaSelectionState,
            ),
          ),
          if (!widget.absellected) ...[
            const SizedBox(width: 8),
            Expanded(
              child: _buildMediaBox(
                box: 'B',
                createPostState: createPostState,
                mediaSelectionState: mediaSelectionState,
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
            createPostState: createPostState,
            mediaSelectionState: mediaSelectionState,
          ),
          if (!widget.absellected) ...[
            const SizedBox(height: 8),
            _buildMediaBox(
              box: 'B',
              createPostState: createPostState,
              mediaSelectionState: mediaSelectionState,
            ),
          ],
        ],
      );
    }
  }

  Widget _buildMediaBox({
    required String box,
    required CreatePostState createPostState,
    required MediaSelectionState mediaSelectionState,
  }) {
    final images = box == 'A'
        ? mediaSelectionState.selectedFilesA
        : mediaSelectionState.selectedFilesB;

    final uploadedUrls = box == 'A'
        ? mediaSelectionState.uploadedUrlsA
        : mediaSelectionState.uploadedUrlsB;

    // Phase 5: Provider의 박스 크기 사용
    final boxWidth = box == 'A' ? mediaSelectionState.boxWidthA : mediaSelectionState.boxWidthB;
    final boxHeight = box == 'A' ? mediaSelectionState.boxHeightA : mediaSelectionState.boxHeightB;

    return GestureDetector(
      onTap: () => _handleBoxTap(box, createPostState, mediaSelectionState),
      child: MediaSelectionBoxMulti(
        label: box,
        isSelected: widget.absellected,
        isVideoSelected: mediaSelectionState.isVideoSelectedA,
        isHorizontal: mediaSelectionState.currentLayout == LayoutType.horizontal,
        boxColor: box == 'A' ? AppColors.boxABackground : AppColors.boxBBackground,
        imageUrls: uploadedUrls,
        imageFiles: images.isNotEmpty ? images : null,
        dynamicHeight: boxHeight ?? post_dimensions.MediaDimensions.defaultBoxHeight,
        dynamicWidth: boxWidth,
        onTap: () => _handleBoxTap(box, createPostState, mediaSelectionState),
        onEditTap: images.isNotEmpty
            ? () => _handleImageEdit(box, createPostState, mediaSelectionState)
            : null,
        onAddImageTap: images.isNotEmpty
            ? () => _handleAddMore(box, createPostState, mediaSelectionState)
            : null,
        showPlusIcon: box == 'A' && !widget.absellected,
        onPlusIconTap: box == 'A' && !widget.absellected
            ? () {
                // B박스 토글 로직 - Notifier를 통해 업데이트
                ref.read(mediaSelectionProvider.notifier).toggleBoxBVisibility();
              }
            : null,
        onCancel: (index) => _handleDeleteImage(box, index, createPostState, mediaSelectionState),
        onCurrentIndexChanged: (index) {
          // Notifier를 통해 currentIndex 업데이트
          ref.read(mediaSelectionProvider.notifier).updateCurrentIndex(box: box, index: index);
        },
      ),
    );
  }

  Future<void> _handleBoxTap(
    String box,
    CreatePostState createPostState,
    MediaSelectionState mediaSelectionState,
  ) async {
    // B박스 검증: A박스가 비어있으면 경고
    if (box == 'B' && mediaSelectionState.selectedFilesA.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('A 항목을 먼저 선택해주세요'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final mediaSelectionNotifier = ref.read(mediaSelectionProvider.notifier);

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

            // MediaSelectionNotifier를 통해 상태 업데이트
            await mediaSelectionNotifier.selectImages(
              box: box,
              assets: assets,
            );

            // CreatePostNotifier에도 동기화
            final createPostNotifier = ref.read(createPostProvider.notifier);
            if (box == 'A') {
              createPostNotifier.updateImagesA(validFiles);
            } else {
              createPostNotifier.updateImagesB(validFiles);
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
    CreatePostState createPostState,
    MediaSelectionState mediaSelectionState,
  ) async {
    widget.onImageEdit?.call(box);
  }

  Future<void> _handleAddMore(
    String box,
    CreatePostState createPostState,
    MediaSelectionState mediaSelectionState,
  ) async {
    await _handleBoxTap(box, createPostState, mediaSelectionState);
  }

  void _handleDeleteImage(
    String box,
    int index,
    CreatePostState createPostState,
    MediaSelectionState mediaSelectionState,
  ) {
    // MediaSelectionNotifier를 통해 삭제
    final mediaSelectionNotifier = ref.read(mediaSelectionProvider.notifier);
    mediaSelectionNotifier.removeAtIndex(box: box, index: index);

    // CreatePostNotifier도 동기화
    final createPostNotifier = ref.read(createPostProvider.notifier);
    final updatedState = ref.read(mediaSelectionProvider);
    if (box == 'A') {
      createPostNotifier.updateImagesA(updatedState.selectedFilesA);
    } else {
      createPostNotifier.updateImagesB(updatedState.selectedFilesB);
    }
  }

  /// Phase 5 Clean Architecture: Widget은 Notifier에 위임만 함
  /// Widget → Notifier → Domain/Service (올바른 패턴)
  void _updateLayoutIfNeeded(MediaSelectionState mediaSelectionState) {
    final screenWidth = MediaQuery.of(context).size.width - 32; // 패딩 제외

    // Notifier가 레이아웃 관리 책임을 가짐
    ref.read(mediaSelectionProvider.notifier).updateLayout(
      containerWidth: screenWidth,
      absellected: widget.absellected,
    );
  }

  bool _shouldShowWarning(CreatePostState createPostState) {
    // A박스가 비어있고 B박스에 이미지가 있는 경우
    final formData = createPostState.formData;
    return formData.imagesA.isEmpty && formData.imagesB.isNotEmpty;
  }

  Widget _buildWarningMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningBackground,
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

  Widget _buildLayoutDebugInfo(MediaSelectionState mediaSelectionState) {
    // Phase 5: State의 레이아웃 정보 사용
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.debugBackground,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Layout: ${mediaSelectionState.currentLayout} | '
        'A: ${mediaSelectionState.boxWidthA?.toStringAsFixed(0)}x${mediaSelectionState.boxHeightA?.toStringAsFixed(0)} | '
        'B: ${mediaSelectionState.boxWidthB?.toStringAsFixed(0)}x${mediaSelectionState.boxHeightB?.toStringAsFixed(0)}',
        style: const TextStyle(fontSize: 10),
      ),
    );
  }
}