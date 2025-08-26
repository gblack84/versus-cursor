import 'package:flutter/material.dart';
import '/core_exports.dart';

class WarningMessage extends StatelessWidget {
  const WarningMessage({
    Key? key,
    required this.message,
    this.textStyle,
  }) : super(key: key);

  final String message;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 0.0),
      child: Text(
        message,
        style: textStyle ?? TextStyle(
          color: AppTheme.of(context).error,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}