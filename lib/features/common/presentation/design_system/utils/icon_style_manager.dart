import 'dart:io';
import '/features/common/presentation/design_system/tokens/versus_icon_data.dart';
import '/features/common/presentation/design_system/tokens/versus_icons.dart';

/// 아이콘 스타일 관리자
/// 
/// 플랫폼별 기본 아이콘 스타일을 설정하고, 사용자 선호도를 관리합니다.
/// iOS/macOS에서는 SF Symbols를, 다른 플랫폼에서는 Material Icons를 기본으로 사용합니다.
class IconStyleManager {
  /// 플랫폼에 따른 자동 스타일 설정
  /// 
  /// iOS/macOS: SF Symbols
  /// 기타 플랫폼: Material Icons
  static VersusIconStyle getDefaultStyle() {
    if (Platform.isIOS || Platform.isMacOS) {
      return VersusIconStyle.sfSymbols;
    }
    return VersusIconStyle.material;
  }
  
  /// 사용자 설정에 따른 스타일 변경
  /// 
  /// [style] 적용할 아이콘 스타일
  /// 
  /// 영구 저장을 위해서는 SharedPreferences 통합이 필요합니다:
  /// ```dart
  /// final prefs = await SharedPreferences.getInstance();
  /// await prefs.setString('icon_style', style.toString());
  /// ```
  static void setIconStyle(VersusIconStyle style) {
    VersusIcons.currentStyle = style;
  }
  
  /// 현재 아이콘 스타일 가져오기
  static VersusIconStyle getCurrentStyle() {
    return VersusIcons.currentStyle;
  }
  
  /// 초기화 - 앱 시작 시 호출
  /// 
  /// 플랫폼 기본 스타일을 설정합니다.
  /// 사용자 설정 영구 저장을 위해서는 다음과 같이 구현할 수 있습니다:
  /// 
  /// ```dart
  /// static Future<void> initialize() async {
  ///   final prefs = await SharedPreferences.getInstance();
  ///   final savedStyle = prefs.getString('icon_style');
  ///   
  ///   if (savedStyle != null) {
  ///     VersusIcons.currentStyle = VersusIconStyle.values.firstWhere(
  ///       (e) => e.toString() == savedStyle,
  ///       orElse: () => getDefaultStyle(),
  ///     );
  ///   } else {
  ///     VersusIcons.currentStyle = getDefaultStyle();
  ///   }
  /// }
  /// ```
  static void initialize() {
    // 플랫폼에 맞는 기본 스타일 설정
    VersusIcons.currentStyle = getDefaultStyle();
  }
}