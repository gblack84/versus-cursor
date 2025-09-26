import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// 플로팅 카메라 버튼이 있는 커스텀 피커 델리게이트
class CameraFloatingButtonDelegate extends DefaultAssetPickerBuilderDelegate {
  CameraFloatingButtonDelegate({
    required super.provider,
    required super.initialPermission,
    super.gridCount,
    super.pickerTheme,
    super.specialItemPosition,
    super.specialItemBuilder,
    super.loadingIndicatorBuilder,
    super.shouldRevertGrid,
    super.limitedPermissionOverlayPredicate,
    super.pathNameBuilder,
    super.textDelegate,
    super.themeColor,
    super.locale,
    super.keepScrollOffset,
    required this.onCameraPressed,
  });

  final Future<void> Function() onCameraPressed;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 기본 피커 UI
        super.build(context),

        // 플로팅 카메라 버튼
        Positioned(
          bottom: 100, // 하단 바 위
          right: 16,
          child: FloatingActionButton(
            heroTag: 'camera_fab',
            backgroundColor: Theme.of(context).primaryColor,
            onPressed: onCameraPressed,
            child: const Icon(
              Icons.camera_alt,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}
