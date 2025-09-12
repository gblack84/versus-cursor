import 'package:flutter/material.dart';
import '../../../constants/voting_dialog_constraints.dart';

/// Animation configurations and builders for the voting dialog
class VotingDialogAnimations {
  final AnimationController controller;
  late final Animation<Offset> slideAnimation;
  late final Animation<double> fadeAnimation;
  late final Animation<double> scaleAnimation;

  VotingDialogAnimations({required this.controller}) {
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Slide animation from top
    slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutBack,
    ));

    // Fade animation
    fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeIn,
    ));

    // Scale animation for vote confirmation
    scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }

  /// Create animation controller with proper duration
  static AnimationController createController(TickerProvider vsync) {
    return AnimationController(
      duration: VotingDialogConstraints.slideAnimationDuration,
      vsync: vsync,
    );
  }

  /// Build slide transition widget
  Widget buildSlideTransition({required Widget child}) {
    return SlideTransition(
      position: slideAnimation,
      child: child,
    );
  }

  /// Build fade transition widget
  Widget buildFadeTransition({required Widget child}) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  /// Build combined transitions
  Widget buildCombinedTransitions({required Widget child}) {
    return buildSlideTransition(
      child: buildFadeTransition(
        child: child,
      ),
    );
  }

  /// Build scale animation for vote confirmation
  Widget buildScaleTransition({required Widget child}) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: child,
    );
  }

  /// Animate in the dialog
  Future<void> animateIn() async {
    await controller.forward();
  }

  /// Animate out the dialog
  Future<void> animateOut() async {
    await controller.reverse();
  }

  /// Dispose of animations
  void dispose() {
    if (controller.isAnimating) {
      controller.stop();
    }
    controller.dispose();
  }
}