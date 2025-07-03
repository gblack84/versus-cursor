import 'package:flutter/material.dart';
import '/services/perspective_api_service.dart';

/// 독성 단어를 빨간색으로 하이라이팅하는 커스텀 텍스트 필드
class HighlightedTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final PerspectiveResult? validationResult;
  final bool showHighlights;

  const HighlightedTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.style,
    this.decoration,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.validationResult,
    this.showHighlights = false,
  }) : super(key: key);

  @override
  State<HighlightedTextField> createState() => _HighlightedTextFieldState();
}

class _HighlightedTextFieldState extends State<HighlightedTextField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 실제 입력 필드
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          style: widget.style,
          decoration: widget.decoration?.copyWith(
            errorText: widget.validationResult?.isToxic == true
                ? '부적절한 내용이 감지되었습니다'
                : null,
          ) ?? InputDecoration(
            hintText: widget.hintText,
            errorText: widget.validationResult?.isToxic == true
                ? '부적절한 내용이 감지되었습니다'
                : null,
          ),
        ),
        
        // 하이라이팅된 텍스트 표시 (검증 결과가 있고 독성이 감지된 경우)
        if (widget.showHighlights && 
            widget.validationResult?.isToxic == true && 
            widget.controller?.text.isNotEmpty == true)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '문제가 감지된 내용:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                  ),
                ),
                const SizedBox(height: 4),
                _buildHighlightedText(),
              ],
            ),
          ),
      ],
    );
  }

  /// 독성 단어를 빨간색으로 하이라이팅한 텍스트 위젯 생성
  Widget _buildHighlightedText() {
    final text = widget.controller?.text ?? '';
    final toxicSpans = widget.validationResult?.toxicSpans ?? [];
    
    if (text.isEmpty || toxicSpans.isEmpty) {
      return Text(text, style: widget.style);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    // 독성 구간들을 정렬 (시작 위치 기준)
    final sortedSpans = List<ToxicSpan>.from(toxicSpans)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final toxicSpan in sortedSpans) {
      // 독성 구간 이전의 정상 텍스트
      if (currentIndex < toxicSpan.start) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, toxicSpan.start),
          style: widget.style,
        ));
      }

      // 독성 단어 (빨간색으로 하이라이팅)
      spans.add(TextSpan(
        text: text.substring(toxicSpan.start, toxicSpan.end),
        style: (widget.style ?? const TextStyle()).copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.red.shade100,
        ),
      ));

      currentIndex = toxicSpan.end;
    }

    // 마지막 독성 구간 이후의 정상 텍스트
    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: widget.style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}

/// 독성 검증 결과와 함께 표시되는 텍스트 필드 래퍼
class ValidatedTextField extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final TextStyle? style;
  final InputDecoration? decoration;
  final Function(String)? onChanged;
  final int? maxLines;
  final int? minLines;
  final TextInputAction? textInputAction;
  final int? maxLength;
  final PerspectiveResult? validationResult;
  final bool showValidationResults;

  const ValidatedTextField({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.style,
    this.decoration,
    this.onChanged,
    this.maxLines = 1,
    this.minLines = 1,
    this.textInputAction,
    this.maxLength,
    this.validationResult,
    this.showValidationResults = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 독성 단어가 감지된 경우 하이라이팅된 텍스트 표시
    if (showValidationResults && 
        validationResult?.isToxic == true && 
        controller?.text.isNotEmpty == true) {
      return _buildHighlightedTextField(context);
    }
    
    // 일반 텍스트 필드
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: maxLines,
      minLines: minLines,
      textInputAction: textInputAction,
      maxLength: maxLength,
      style: style,
      decoration: decoration?.copyWith(
        errorText: null, // 에러 텍스트는 필드 외부에서 처리
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
        counterText: '',
      ) ?? InputDecoration(
        hintText: hintText,
        errorText: null, // 에러 텍스트는 필드 외부에서 처리
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
        counterText: '',
      ),
    );
  }

  /// 하이라이팅된 텍스트 필드 (독성 감지 시)
  Widget _buildHighlightedTextField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // 하이라이팅된 텍스트 오버레이
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  padding: decoration?.contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: _buildHighlightedText(),
                  ),
                ),
              ),
            ),
            // 일반 텍스트 필드 (투명하게)
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              maxLines: maxLines,
              minLines: minLines,
              textInputAction: textInputAction,
              maxLength: maxLength,
              style: style,
              decoration: decoration?.copyWith(
                counterText: '',
              ),
            ),
          ],
        ),
        // 에러 메시지 표시
        if (validationResult?.isToxic == true)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(
              _getErrorMessage(),
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// 독성 단어를 빨간색으로 하이라이팅한 텍스트
  Widget _buildHighlightedText() {
    final text = controller?.text ?? '';
    final toxicSpans = validationResult?.toxicSpans ?? [];
    
    if (text.isEmpty || toxicSpans.isEmpty) {
      return Text(text, style: style);
    }

    List<TextSpan> spans = [];
    int currentIndex = 0;

    final sortedSpans = List<ToxicSpan>.from(toxicSpans)
      ..sort((a, b) => a.start.compareTo(b.start));

    for (final toxicSpan in sortedSpans) {
      if (currentIndex < toxicSpan.start) {
        spans.add(TextSpan(
          text: text.substring(currentIndex, toxicSpan.start),
          style: style,
        ));
      }

      spans.add(TextSpan(
        text: text.substring(toxicSpan.start, toxicSpan.end),
        style: (style ?? const TextStyle()).copyWith(
          color: Colors.red,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.red.shade100,
        ),
      ));

      currentIndex = toxicSpan.end;
    }

    if (currentIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(currentIndex),
        style: style,
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 에러 메시지 생성
  String _getErrorMessage() {
    if (validationResult == null || !validationResult!.isToxic) {
      return '';
    }

    // 가장 높은 점수의 카테고리 찾기
    String topCategory = '';
    double maxScore = 0.0;
    
    validationResult!.allScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });
    
    switch (topCategory) {
      case 'PROFANITY':
        return '욕설이 포함되어 있습니다';
      case 'THREAT':
        return '위협적인 내용이 포함되어 있습니다';
      case 'INSULT':
        return '모욕적인 내용이 포함되어 있습니다';
      case 'TOXICITY':
        return '독성 콘텐츠가 감지되었습니다';
      default:
        return '부적절한 내용이 감지되었습니다';
    }
  }
}