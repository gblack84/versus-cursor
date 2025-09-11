import 'package:wechat_camera_picker/wechat_camera_picker.dart';

// 카메라 피커를 위한 한국어 텍스트 델리게이트
class CustomKoreanCameraPickerTextDelegate extends CameraPickerTextDelegate {
  const CustomKoreanCameraPickerTextDelegate();

  @override
  String get confirm => '확인';

  @override
  String get shootingTips => '탭하여 사진 촬영, 길게 눌러 비디오 녹화';

  @override
  String get shootingWithRecordingTips => '탭하여 사진 촬영, 길게 눌러 비디오 녹화';

  @override
  String get shootingOnlyRecordingTips => '길게 눌러 비디오 녹화';

  @override
  String get shootingTapRecordingTips => '탭하여 녹화';

  @override
  String get loadFailed => '로드 실패';

  @override
  String get loading => '로딩 중...';

  @override
  String get saving => '저장 중...';

  @override
  String sCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front:
        return '전면 카메라';
      case CameraLensDirection.back:
        return '후면 카메라';
      case CameraLensDirection.external:
        return '외부 카메라';
    }
  }

  @override
  String? sCameraPreviewLabel(CameraLensDirection? value) {
    if (value == null) {
      return null;
    }
    return sCameraLensDirectionLabel(value);
  }

  @override
  String sFlashModeLabel(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return '플래시 끄기';
      case FlashMode.auto:
        return '플래시 자동';
      case FlashMode.always:
        return '플래시 켜기';
      case FlashMode.torch:
        return '손전등';
    }
  }

  @override
  String sSwitchCameraLensDirectionLabel(CameraLensDirection value) {
    switch (value) {
      case CameraLensDirection.front:
        return '후면 카메라로 전환';
      case CameraLensDirection.back:
        return '전면 카메라로 전환';
      case CameraLensDirection.external:
        return '외부 카메라로 전환';
    }
  }
}
