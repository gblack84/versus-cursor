import 'package:flutter/material.dart';

/// 애니메이션 관련 상수
class AnimationConstants {
  // Durations
  static const Duration shakeAnimationDuration = Duration(milliseconds: 200);
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
  static const Duration fadeInDuration = Duration(milliseconds: 150);
  static const Duration fadeOutDuration = Duration(milliseconds: 150);
  static const Duration debounceDuration = Duration(milliseconds: 500);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration errorToastDuration = Duration(seconds: 4);
  static const Duration loadingDialogDelay = Duration(milliseconds: 100);
  static const Duration moderationTimeout = Duration(seconds: 30);
  static const Duration uploadTimeout = Duration(seconds: 15);
  
  // Animation Values
  static const double shakeAnimationExtent = 8.0;
  
  // Toast Position
  static const Alignment toastAlignment = Alignment(0, 0.8);
}