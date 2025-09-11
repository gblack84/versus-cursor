import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';

class InAppNotificationDialog extends StatefulWidget {
  final String title;
  final String message;
  final String buttonText;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const InAppNotificationDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = '참여하기',
    required this.onTap,
    this.onDismiss,
  });

  @override
  State<InAppNotificationDialog> createState() =>
      _InAppNotificationDialogState();
}

class _InAppNotificationDialogState extends State<InAppNotificationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0), // 화면 위에서
      end: Offset.zero, // 현재 위치로
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    // 5초 후 자동 사라짐
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _dismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    if (widget.onDismiss != null) {
      widget.onDismiss!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Material(
            elevation: 8,
            borderRadius: VersusRadius.dialog,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    VersusColors.primary,
                    VersusColors.primary.withValues(alpha: 0.8)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: VersusRadius.dialog,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: VersusSpacing.paddingMD,
                child: Row(
                  children: [
                    // 아이콘
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: VersusRadius.radiusCircular,
                      ),
                      child: Center(
                        child: Icon(
                          VersusIcons.target.getIcon(VersusIcons.currentStyle),
                          size: 24,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ),
                    VersusSpacing.gapH(VersusSpacing.sm),

                    // 텍스트 영역
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.title,
                            style: VersusTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          VersusSpacing.gapXS,
                          Text(
                            widget.message,
                            style: VersusTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 버튼들
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 참여 버튼
                        ElevatedButton(
                          onPressed: () {
                            _dismiss();
                            widget.onTap();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: VersusColors.primary,
                            padding: VersusSpacing.buttonInternal,
                            shape: VersusRadius.buttonShape,
                          ),
                          child: Text(
                            widget.buttonText,
                            style: VersusTextStyles.buttonSmall.copyWith(
                              color: VersusColors.primary,
                            ),
                          ),
                        ),

                        // 닫기 버튼
                        TextButton(
                          onPressed: _dismiss,
                          child: Icon(
                            Icons.close,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
