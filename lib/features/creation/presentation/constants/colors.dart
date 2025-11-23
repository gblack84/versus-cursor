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
  static final Color errorRedOverlay = Colors.red.shade700.withValues(
    alpha: 0.9,
  );

  // Success Colors
  static final Color successGreen = Colors.green.shade700;
  static final Color successGreenOverlay = Colors.green.shade700.withValues(
    alpha: 0.9,
  );

  // Base Colors
  static const Color black = Colors.black;
  static const Color white = Colors.white;
  static const Color transparent = Colors.transparent;

  // ===== Creation Feature - Box Colors =====
  // Migration: Phase 2 - Replace deprecated withOpacity() calls

  /// Box A background color (Blue with 10% opacity)
  /// Original: Colors.blue.withOpacity(0.1)
  /// Hex: #2196F3 with alpha 0x1A (26/255 ≈ 10%)
  static const Color boxABackground = Color(0x1A2196F3);

  /// Box B background color (Red with 10% opacity)
  /// Original: Colors.red.withOpacity(0.1)
  /// Hex: #F44336 with alpha 0x1A (26/255 ≈ 10%)
  static const Color boxBBackground = Color(0x1AF44336);

  /// Warning message background (Orange with 10% opacity)
  /// Original: Colors.orange.withOpacity(0.1)
  /// Hex: #FF9800 with alpha 0x1A (26/255 ≈ 10%)
  static const Color warningBackground = Color(0x1AFF9800);

  /// Debug layout info background (Grey with 10% opacity)
  /// Original: Colors.grey.withOpacity(0.1)
  /// Hex: #9E9E9E with alpha 0x1A (26/255 ≈ 10%)
  static const Color debugBackground = Color(0x1A9E9E9E);
}
