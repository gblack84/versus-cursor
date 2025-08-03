import 'package:flutter/material.dart';
import '/design_system/design_system.dart';
import '/utils/responsive_breakpoints.dart';

/// VoteRequestMessage가 로딩 중일 때 표시되는 스켈레톤 UI
class VoteRequestMessageSkeleton extends StatefulWidget {
  const VoteRequestMessageSkeleton({
    super.key,
    required this.isMe,
  });

  final bool isMe;

  @override
  State<VoteRequestMessageSkeleton> createState() => _VoteRequestMessageSkeletonState();
}

class _VoteRequestMessageSkeletonState extends State<VoteRequestMessageSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _shimmerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: ResponsiveBreakpoints.getMessageMargin(context, widget.isMe),
      decoration: BoxDecoration(
        color: widget.isMe ? VersusColors.primary : VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(16),
          topRight: const Radius.circular(16),
          bottomLeft: Radius.circular(widget.isMe ? 16 : 4),
          bottomRight: Radius.circular(widget.isMe ? 4 : 16),
        ),
      ),
      child: AnimatedBuilder(
        animation: _shimmerAnimation,
        builder: (context, child) {
          return Padding(
            padding: const EdgeInsets.all(VersusSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    _buildSkeletonBox(16, 16),
                    const SizedBox(width: VersusSpacing.xs),
                    _buildSkeletonBox(60, 14),
                    const Spacer(),
                    _buildSkeletonBox(50, 20),
                  ],
                ),
                const SizedBox(height: VersusSpacing.sm),
                
                // 제목
                _buildSkeletonBox(double.infinity, 20),
                const SizedBox(height: 8),
                _buildSkeletonBox(200, 16),
                const SizedBox(height: VersusSpacing.sm),
                
                // A vs B 박스
                SizedBox(
                  height: ResponsiveBreakpoints.getVsBoxHeight(context, true, false),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildSkeletonBox(double.infinity, double.infinity),
                      ),
                      const SizedBox(width: VersusSpacing.xs),
                      _buildSkeletonBox(20, 16),
                      const SizedBox(width: VersusSpacing.xs),
                      Expanded(
                        child: _buildSkeletonBox(double.infinity, double.infinity),
                      ),
                    ],
                  ),
                ),
                
                // 타임스탬프
                const SizedBox(height: VersusSpacing.xs),
                _buildSkeletonBox(60, 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height) {
    return Container(
      width: width == double.infinity ? null : width,
      height: height == double.infinity ? null : height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: widget.isMe
            ? Colors.white.withValues(alpha: 0.1 + (_shimmerAnimation.value * 0.1))
            : Colors.grey.withValues(alpha: 0.1 + (_shimmerAnimation.value * 0.1)),
      ),
    );
  }
}