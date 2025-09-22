import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class VerificationStatusDisplay extends StatelessWidget {
  final bool? isVerified;

  const VerificationStatusDisplay({
    super.key,
    required this.isVerified,
  });

  @override
  Widget build(BuildContext context) {
    if (isVerified == null) {
      return SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.of(context).secondaryBackground,
          shape: BoxShape.rectangle,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (isVerified == true)
              Text(
                AppLocalizations.of(context).getText(
                  'ep61t57h' /* Authentication succeeded!! */,
                ),
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Color(0xFF8000FD),
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
            if (isVerified == false)
              Text(
                AppLocalizations.of(context).getText(
                  '85h4oe02' /* Authentication failed. Please ... */,
                ),
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Color(0xFFFF0000),
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w800,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
          ],
        ),
      ),
    );
  }
}