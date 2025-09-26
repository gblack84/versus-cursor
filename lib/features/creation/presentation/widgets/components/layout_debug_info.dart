import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/app/state/app_state.dart';
import '/core/utils/media/aspect_ratio_analyzer.dart';
import '/core/types/layout_type.dart';

class LayoutDebugInfo extends StatelessWidget {
  const LayoutDebugInfo({
    Key? key,
    required this.currentLayout,
  }) : super(key: key);

  final LayoutType currentLayout;

  @override
  Widget build(BuildContext context) {
    if (const bool.fromEnvironment('dart.vm.product')) {
      return SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(8.0),
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          final aRatio = appState.uploadImageAspectRatioA.isNotEmpty
              ? appState.uploadImageAspectRatioA.first.toStringAsFixed(2)
              : 'N/A';
          final bRatio = appState.uploadImageAspectRatioB.isNotEmpty
              ? appState.uploadImageAspectRatioB.first.toStringAsFixed(2)
              : 'N/A';
          final layoutDesc =
              AspectRatioAnalyzer.getLayoutDescription(currentLayout);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🔍 스마트 레이아웃 디버그',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.0,
                ),
              ),
              SizedBox(height: 4.0),
              Text('A 비율: $aRatio | B 비율: $bRatio',
                  style: TextStyle(fontSize: 11.0)),
              Text('현재 레이아웃: $layoutDesc', style: TextStyle(fontSize: 11.0)),
            ],
          );
        },
      ),
    );
  }
}
