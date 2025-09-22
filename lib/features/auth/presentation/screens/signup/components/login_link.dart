import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class LoginLink extends StatelessWidget {
  final VoidCallback onTap;

  const LoginLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 20.0, 0.0, 12.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: RichText(
            textScaler: MediaQuery.of(context).textScaler,
            text: TextSpan(
              children: [
                TextSpan(
                  text: AppLocalizations.of(context).getText(
                    '0ksnf2xz', /* Already have an account?  */
                  ),
                  style: TextStyle(
                    color: AppTheme.of(context).secondaryText,
                  ),
                ),
                TextSpan(
                  text: AppLocalizations.of(context).getText(
                    'do58zhdd', /*  Log In here */
                  ),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(),
                        color: AppTheme.of(context).primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                ),
              ],
              style: AppTheme.of(context).bodyMedium,
            ),
          ),
        ),
      ),
    );
  }
}