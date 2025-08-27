import 'package:flutter/material.dart';
export 'pickle_mark_model.dart';

class PickleMarkWidget extends StatelessWidget {
  const PickleMarkWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Image.asset(
        'assets/images/pikle_icon.png',
        width: 100.0,
        height: 100.0,
        fit: BoxFit.contain,
      ),
    );
  }
}