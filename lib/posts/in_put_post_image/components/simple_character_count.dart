import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/app_theme.dart';

class SimpleCharacterCount extends StatelessWidget {
  final TextEditingController? controller;
  final int maxLength;
  
  const SimpleCharacterCount({
    Key? key,
    this.controller,
    required this.maxLength,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.5, 10.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${controller?.text.length ?? 0}/$maxLength',
            style: AppTheme.of(context).bodySmall.override(
              font: GoogleFonts.plusJakartaSans(),
              color: AppTheme.of(context).secondaryText,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}