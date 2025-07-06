import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/app_theme.dart';

class NextButton extends StatelessWidget {
  final bool showButton;
  final bool isValidating;
  final VoidCallback? onPressed;
  final double bottom;
  final double right;

  const NextButton({
    Key? key,
    required this.showButton,
    required this.isValidating,
    this.onPressed,
    this.bottom = 30.0,
    this.right = 20.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: bottom,
      right: right,
      child: AnimatedOpacity(
        opacity: showButton ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton.extended(
          onPressed: showButton && !isValidating ? onPressed : null,
          backgroundColor: isValidating 
              ? Colors.grey 
              : AppTheme.of(context).primary,
          icon: isValidating
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
          label: Text(
            isValidating ? '검증 중...' : '다음',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: Colors.white,
                  fontSize: 16.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ),
    );
  }
}