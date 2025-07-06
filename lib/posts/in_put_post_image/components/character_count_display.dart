import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/core/app_theme.dart';
import '/services/perspective_api_service.dart';

class CharacterCountDisplay extends StatelessWidget {
  final TextEditingController? controller;
  final int maxLength;
  final bool isEmpty;
  final bool hasBlockedWord;
  final PerspectiveResult? validationResult;
  final String emptyMessage;
  final String toxicMessage;
  final String blockedMessage;

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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final showError = isEmpty || hasBlockedWord || (validationResult?.isToxic ?? false);
    
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20.0, 4.5, 20.0, 0.0),
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

  String _getErrorMessage() {
    if (isEmpty) {
      return emptyMessage;
    } else if (validationResult?.isToxic ?? false) {
      return toxicMessage;
    } else if (hasBlockedWord) {
      return blockedMessage;
    }
    return '';
  }
}