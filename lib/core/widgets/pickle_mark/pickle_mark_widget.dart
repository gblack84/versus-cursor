import 'package:flutter/material.dart';
import 'package:versus_space/gen/assets.gen.dart';
export 'pickle_mark_provider.dart';

class PickleMarkWidget extends StatelessWidget {
  const PickleMarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Assets.images_pikle_icon.image(
        width: 100.0,
        height: 100.0,
        fit: BoxFit.contain,
      ),
    );
  }
}
