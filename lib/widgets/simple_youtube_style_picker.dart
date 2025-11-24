import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

/// 유튜브 스타일의 간단한 이미지 피커
/// 바텀시트로 표시되며, 최소한의 UI만 제공
class SimpleYoutubeStylePicker extends StatefulWidget {
  final int maxSelection;
  final Function(List<AssetEntity>) onConfirm;

  const SimpleYoutubeStylePicker({
    super.key,
    this.maxSelection = 4,
    required this.onConfirm,
  });

  /// 바텀시트로 표시
  static Future<List<AssetEntity>?> show(
    BuildContext context, {
    int maxSelection = 4,
  }) async {
    return showModalBottomSheet<List<AssetEntity>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SimpleYoutubeStylePicker(
            maxSelection: maxSelection,
            onConfirm: (assets) => Navigator.pop(context, assets),
          ),
        ),
      ),
    );
  }

  @override
  State<SimpleYoutubeStylePicker> createState() =>
      _SimpleYoutubeStylePickerState();
}

class _SimpleYoutubeStylePickerState extends State<SimpleYoutubeStylePicker> {
  List<AssetEntity> _images = [];
  final List<AssetEntity> _selected = [];
  bool _isLoading = true;
  int _currentPage = 0;
  static const int _pageSize = 80;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  /// 갤러리에서 이미지 로드
  Future<void> _loadImages() async {
    try {
      // 권한 요청
      final PermissionState ps = await PhotoManager.requestPermissionExtend();
      if (!ps.isAuth) {
        if (mounted) {
          Navigator.pop(context);
        }
        return;
      }

      // 최근 항목 앨범에서 이미지 가져오기
      final List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
        onlyAll: true, // "최근 항목"만
      );

      if (albums.isEmpty) return;

      // 페이지네이션으로 이미지 로드
      final List<AssetEntity> assets = await albums[0].getAssetListPaged(
        page: _currentPage,
        size: _pageSize,
      );

      if (mounted) {
        setState(() {
          _images.addAll(assets);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('이미지 로드 실패: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 이미지 선택/해제
  void _toggleSelection(AssetEntity asset) {
    setState(() {
      if (_selected.contains(asset)) {
        _selected.remove(asset);
      } else if (_selected.length < widget.maxSelection) {
        _selected.add(asset);
      } else {
        // 최대 개수 초과 시 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('최대 ${widget.maxSelection}개까지 선택 가능합니다'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 상단 헤더
        _buildHeader(),

        // 이미지 그리드
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildImageGrid(),
        ),
      ],
    );
  }

  /// 상단 헤더 (취소/완료 버튼)
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[800]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 취소 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),

          // 선택 개수 표시
          Text(
            '${_selected.length}/${widget.maxSelection}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 완료 버튼
          TextButton(
            onPressed: _selected.isEmpty
                ? null
                : () => widget.onConfirm(_selected),
            child: Text(
              '완료',
              style: TextStyle(
                color: _selected.isEmpty ? Colors.grey : Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 이미지 그리드
  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4열
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _images.length,
      itemBuilder: (context, index) {
        final asset = _images[index];
        final isSelected = _selected.contains(asset);
        final selectionIndex = _selected.indexOf(asset);

        return GestureDetector(
          onTap: () => _toggleSelection(asset),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 썸네일 이미지
              AssetEntityImage(
                asset,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize.square(300),
                fit: BoxFit.cover,
              ),

              // 선택 시 어두운 오버레이
              if (isSelected)
                Container(
                  color: Colors.black.withOpacity(0.3),
                ),

              // 선택 순서 표시
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.blue : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Text(
                            '${selectionIndex + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
