import 'package:flutter/material.dart';

/// 색상 상수
class AppColors {
  // Overlay Colors
  static final Color blackOverlay60 = Colors.black.withValues(alpha: 0.6);
  static final Color blackOverlay80 = Colors.black.withValues(alpha: 0.8);
  static final Color blackOverlay90 = Colors.black.withValues(alpha: 0.9);
  static final Color whiteOverlay50 = Colors.white.withValues(alpha: 0.5);

  // Error Colors
  static final Color errorRed = Colors.red.shade700;
  static final Color errorRedOverlay =
      Colors.red.shade700.withValues(alpha: 0.9);

  // Success Colors
  static final Color successGreen = Colors.green.shade700;
  static final Color successGreenOverlay =
      Colors.green.shade700.withValues(alpha: 0.9);

  // Base Colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;
}
