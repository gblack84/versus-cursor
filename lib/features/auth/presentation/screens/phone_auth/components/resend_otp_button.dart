import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class ResendOtpButton extends StatelessWidget {
  final bool canResend;
  final int resendCount;
  final VoidCallback onPressed;

  const ResendOtpButton({
    super.key,
    required this.canResend,
    required this.resendCount,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: AppButtonWidget(
        onPressed: canResend ? onPressed : null,
        text: AppLocalizations.of(context).getText(
          '83b4yl7r' /* Resend verification code */,
        ),
        options: AppButtonOptions(
          height: 40.0,
          padding: EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
          iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
          color: canResend
              ? AppTheme.of(context).primary
              : AppTheme.of(context).secondaryText,
          textStyle: AppTheme.of(context).titleSmall.override(
                font: GoogleFonts.plusJakartaSans(),
                color: Colors.white,
                letterSpacing: 0.0,
              ),
          elevation: 3.0,
          borderSide: BorderSide(
            color: Colors.transparent,
            width: 1.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
          disabledColor: AppTheme.of(context).secondaryText,
        ),
      ),
    );
  }
}