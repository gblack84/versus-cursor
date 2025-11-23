import 'package:wechat_assets_picker/wechat_assets_picker.dart';

// 한국어 텍스트 델리게이트
class CustomKoreanAssetPickerTextDelegate extends AssetPickerTextDelegate {
  const CustomKoreanAssetPickerTextDelegate();

  @override
  String get confirm => '확인';

  @override
  String get cancel => '취소';

  @override
  String get edit => '편집';

  @override
  String get gifIndicator => 'GIF';

  @override
  String get loadFailed => '로드 실패';

  @override
  String get original => '원본';

  @override
  String get preview => '미리보기';

  @override
  String get select => '선택';

  @override
  String get emptyList => '사진이 없습니다';

  @override
  String get unSupportedAssetType => '지원하지 않는 형식';

  @override
  String get unableToAccessAll => '모든 사진에 접근할 수 없습니다';

  @override
  String get viewingLimitedAssetsTip => '앱에서 접근 가능한 사진만 표시됩니다.';

  @override
  String get changeAccessibleLimitedAssets => '접근 가능한 사진 업데이트';

  @override
  String get accessAllTip =>
      '앱이 일부 사진에만 접근 가능합니다.\n'
      '설정에서 모든 사진 접근을 허용해주세요.';

  @override
  String get goToSystemSettings => '시스템 설정';

  @override
  String get accessLimitedAssets => '제한된 접근으로 계속';

  @override
  String get accessiblePathName => '접근 가능한 사진';
}
