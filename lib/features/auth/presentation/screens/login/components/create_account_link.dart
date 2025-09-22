import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class CreateAccountLink extends StatelessWidget {
  final VoidCallback onTap;

  const CreateAccountLink({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
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
                    'rvc8mjrx', // Don't have an account?
                  ),
                  style: TextStyle(),
                ),
                TextSpan(
                  text: AppLocalizations.of(context).getText(
                    '8nm4k29v', // Create Account
                  ),
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w600,
                        ),
                        color: Color(0xFF101213),
                        fontSize: 14.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                )
              ],
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                    ),
                    color: Colors.black,
                    fontSize: 14.0,
                    letterSpacing: 0.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}