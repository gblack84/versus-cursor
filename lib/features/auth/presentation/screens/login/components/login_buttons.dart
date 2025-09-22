import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';

class LoginButtons extends StatelessWidget {
  final VoidCallback onEmailLogin;
  final VoidCallback onPhoneLogin;

  const LoginButtons({
    super.key,
    required this.onEmailLogin,
    required this.onPhoneLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Email Login Button
        Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 16.0),
            child: AppButtonWidget(
              onPressed: onEmailLogin,
              text: AppLocalizations.of(context).getText(
                '4wwn8ov8', // Log in
              ),
              options: AppButtonOptions(
                width: 230.0,
                height: 52.0,
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.black,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                      color: Colors.white,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
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
        ),
        // Phone Login Button
        Align(
          alignment: AlignmentDirectional(0.0, 0.0),
          child: Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
            child: AppButtonWidget(
              onPressed: onPhoneLogin,
              text: AppLocalizations.of(context).getText(
                'uk1cwrhu', // Phone Log in
              ),
              options: AppButtonOptions(
                width: 230.0,
                height: 52.0,
                padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                color: Colors.black,
                textStyle: AppTheme.of(context).titleSmall.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                      ),
                      color: Colors.white,
                      fontSize: 16.0,
                      letterSpacing: 0.0,
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
        ),
      ],
    );
  }
}