import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class SignupButtons extends StatelessWidget {
  final VoidCallback onEmailSignup;
  final VoidCallback onPhoneSignup;

  const SignupButtons({
    super.key,
    required this.onEmailSignup,
    required this.onPhoneSignup,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email Signup Button
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 10.0),
          child: AppButtonWidget(
            onPressed: onEmailSignup,
            text: AppLocalizations.of(context).getText(
              'ifzwhrve', /* Create Account */
            ),
            icon: Icon(
              Icons.alternate_email,
              size: 16.0,
            ),
            options: AppButtonOptions(
              width: 370.0,
              height: 44.0,
              padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconAlignment: IconAlignment.end,
              iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
              iconColor: Colors.white,
              color: Colors.black,
              textStyle: AppTheme.of(context).titleSmall.override(
                    font: GoogleFonts.plusJakartaSans(),
                    color: Colors.white,
                  ),
              elevation: 10.0,
              borderSide: BorderSide(
                color: Colors.transparent,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
        // Phone Signup Button
        AppButtonWidget(
          onPressed: onPhoneSignup,
          text: AppLocalizations.of(context).getText(
            'kfty848b', /* Create Account With Phone */
          ),
          icon: Icon(
            Icons.phone_iphone,
            size: 16.0,
          ),
          options: AppButtonOptions(
            width: 370.0,
            height: 44.0,
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconAlignment: IconAlignment.end,
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconColor: Colors.white,
            color: Colors.black,
            textStyle: AppTheme.of(context).titleSmall.override(
                  font: GoogleFonts.plusJakartaSans(),
                  color: Colors.white,
                ),
            elevation: 5.0,
            borderSide: BorderSide(
              color: Colors.transparent,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ],
    );
  }
}