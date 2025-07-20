import 'package:flutter/material.dart';

/// 아이콘 스타일 열거형
enum VersusIconStyle {
  material,    // Material Icons (Google)
  sfSymbols,   // SF Symbols (Apple)
  cupertino,   // Cupertino Icons (Flutter 내장)
}

/// 플랫폼별 아이콘 데이터
class VersusIconData {
  final IconData material;
  final IconData? sfSymbol;
  final IconData? cupertino;
  
  const VersusIconData({
    required this.material,
    this.sfSymbol,
    this.cupertino,
  });
  
  /// 현재 스타일에 맞는 아이콘 반환
  IconData getIcon(VersusIconStyle style) {
    switch (style) {
      case VersusIconStyle.sfSymbols:
        return sfSymbol ?? material;
      case VersusIconStyle.cupertino:
        return cupertino ?? material;
      case VersusIconStyle.material:
        return material;
    }
  }
}