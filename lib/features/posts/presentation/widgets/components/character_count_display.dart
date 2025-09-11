import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core_exports.dart';
import '/services/moderation/perspective_api_service.dart';

class CharacterCountDisplay extends StatefulWidget {
  final TextEditingController? controller;
  final int maxLength;
  final bool isEmpty;
  final bool hasBlockedWord;
  final PerspectiveResult? validationResult;
  final String emptyMessage;
  final String toxicMessage;
  final String blockedMessage;
  final double horizontalPadding;
  final bool hasValidated;

  const CharacterCountDisplay({
    Key? key,
    this.controller,
    required this.maxLength,
    required this.isEmpty,
    this.hasBlockedWord = false,
    this.validationResult,
    this.emptyMessage = '필수 항목입니다',
    this.toxicMessage = '독성 콘텐츠가 감지되었습니다',
    this.blockedMessage = '⚠️ 부적절한 언어가 포함됨',
    this.horizontalPadding = 22.0,
    this.hasValidated = false,
  }) : super(key: key);

  @override
  State<CharacterCountDisplay> createState() => _CharacterCountDisplayState();
}

class _CharacterCountDisplayState extends State<CharacterCountDisplay> {
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
    final showError = (widget.isEmpty && widget.hasValidated) ||
        widget.hasBlockedWord ||
        (widget.validationResult?.isToxic ?? false);

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
          widget.horizontalPadding, 4.5, widget.horizontalPadding, 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 경고 메시지
          if (showError)
            Flexible(
              child: Text(
                _getErrorMessage(),
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.plusJakartaSans(),
                      color: AppTheme.of(context).error,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            )
          else
            const SizedBox.shrink(),

          // 오른쪽: 글자 수 (항상 표시)
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

  String _getErrorMessage() {
    if (widget.isEmpty) {
      return widget.emptyMessage;
    } else if (widget.validationResult?.isToxic ?? false) {
      return widget.toxicMessage;
    } else if (widget.hasBlockedWord) {
      return widget.blockedMessage;
    }
    return '';
  }
}
