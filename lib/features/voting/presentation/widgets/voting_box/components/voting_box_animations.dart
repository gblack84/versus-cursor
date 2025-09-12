import 'package:flutter/material.dart';

/// Animation wrapper for voting box
class VotingBoxAnimations extends StatelessWidget {
  final AnimationController? animationController;
  final Widget child;
  final bool enableScale;
  final bool enableFade;
  final bool enableRotation;

  const VotingBoxAnimations({
    Key? key,
    this.animationController,
    required this.child,
    this.enableScale = true,
    this.enableFade = false,
    this.enableRotation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (animationController == null) {
      return child;
    }

    return AnimatedBuilder(
      animation: animationController!,
      builder: (context, _) {
        Widget result = child;

        // Apply scale animation
        if (enableScale) {
          result = Transform.scale(
            scale: 0.95 + (0.05 * animationController!.value),
            child: result,
          );
        }

        // Apply fade animation
        if (enableFade) {
          result = Opacity(
            opacity: animationController!.value,
            child: result,
          );
        }

        // Apply rotation animation
        if (enableRotation) {
          result = Transform.rotate(
            angle: animationController!.value * 0.1,
            child: result,
          );
        }

        return result;
      },
    );
  }
}

/// Animated container for voting box with built-in animations
class AnimatedVotingBox extends StatefulWidget {
  final Widget child;
  final Duration animationDuration;
  final bool autoPlay;
  final bool repeat;

  const AnimatedVotingBox({
    Key? key,
    required this.child,
    this.animationDuration = const Duration(milliseconds: 300),
    this.autoPlay = false,
    this.repeat = false,
  }) : super(key: key);

  @override
  State<AnimatedVotingBox> createState() => _AnimatedVotingBoxState();
}

class _AnimatedVotingBoxState extends State<AnimatedVotingBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.autoPlay) {
      if (widget.repeat) {
        _controller.repeat(reverse: true);
      } else {
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void playAnimation() {
    _controller.forward();
  }

  void reverseAnimation() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: widget.child,
          ),
        );
      },
    );
  }
}

/// Pulse animation for selected voting box
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.isActive = false,
    this.duration = const Duration(seconds: 1),
    this.minScale = 0.95,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.isActive) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isActive) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: widget.child,
        );
      },
    );
  }
}