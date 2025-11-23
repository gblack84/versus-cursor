import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class NextButton extends StatelessWidget {
  final bool showButton;
  final VoidCallback? onPressed;
  final double bottom;
  final double right;

  const NextButton({
    Key? key,
    required this.showButton,
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
          onPressed: showButton ? onPressed : null,
          backgroundColor: AppTheme.of(context).primary,
          icon: const Icon(Icons.arrow_forward, color: Colors.white),
          label: Text(
            '다음',
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
