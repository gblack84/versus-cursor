import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';

class SimpleCharacterCount extends StatefulWidget {
  final TextEditingController? controller;
  final int maxLength;

  const SimpleCharacterCount({
    Key? key,
    this.controller,
    required this.maxLength,
  }) : super(key: key);

  @override
  State<SimpleCharacterCount> createState() => _SimpleCharacterCountState();
}

class _SimpleCharacterCountState extends State<SimpleCharacterCount> {
  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_updateState);
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.5, 10.0, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${widget.controller?.text.length ?? 0}/${widget.maxLength}',
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
