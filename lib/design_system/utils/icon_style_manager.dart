import 'dart:io';
import '../tokens/versus_icon_data.dart';
import '../tokens/versus_icons.dart';

class IconStyleManager {
  /// 플랫폼에 따른 자동 스타일 설정
  static VersusIconStyle getDefaultStyle() {
    if (Platform.isIOS || Platform.isMacOS) {
      return VersusIconStyle.sfSymbols;
    }
    return VersusIconStyle.material;
  }
  
  /// 사용자 설정에 따른 스타일 변경
  static void setIconStyle(VersusIconStyle style) {
    VersusIcons.currentStyle = style;
    // TODO: SharedPreferences에 저장하는 로직 추가 가능
  }
  
  /// 현재 아이콘 스타일 가져오기
  static VersusIconStyle getCurrentStyle() {
    return VersusIcons.currentStyle;
  }
  
  /// 초기화 - 앱 시작 시 호출
  static void initialize() {
    // 플랫폼에 맞는 기본 스타일 설정
    VersusIcons.currentStyle = getDefaultStyle();
    
    // TODO: SharedPreferences에서 사용자 설정 읽어오기
    // final prefs = await SharedPreferences.getInstance();
    // final savedStyle = prefs.getString('icon_style');
    // if (savedStyle != null) {
    //   VersusIcons.currentStyle = VersusIconStyle.values.firstWhere(
    //     (e) => e.toString() == savedStyle,
    //     orElse: () => getDefaultStyle(),
    //   );
    // }
  }
}