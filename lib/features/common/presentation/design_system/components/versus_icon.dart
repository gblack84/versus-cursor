import 'package:flutter/material.dart';
import '../tokens/versus_icons.dart';
import '../tokens/versus_icon_data.dart';

/// VersusIcons를 자동으로 현재 스타일에 맞게 표시하는 위젯
class VersusIcon extends StatelessWidget {
  final VersusIconData iconData;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  
  const VersusIcon(
    this.iconData, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Icon(
      iconData.getIcon(VersusIcons.currentStyle),
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}