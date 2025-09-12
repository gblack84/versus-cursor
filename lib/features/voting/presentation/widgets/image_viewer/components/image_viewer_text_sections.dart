import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';

/// 이미지 뷰어 하단 텍스트 섹션
///
/// 질문, 옵션, 설명을 표시하고 확장/축소 기능을 제공합니다.
class ImageViewerTextSections extends StatefulWidget {
  final String question;
  final String optionA;
  final String optionB;
  final String? description;
  final String currentBoxType;
  final bool isSingleMode;

  const ImageViewerTextSections({
    Key? key,
    required this.question,
    required this.optionA,
    required this.optionB,
    this.description,
    required this.currentBoxType,
    required this.isSingleMode,
  }) : super(key: key);

  @override
  State<ImageViewerTextSections> createState() => _ImageViewerTextSectionsState();
}

class _ImageViewerTextSectionsState extends State<ImageViewerTextSections> {
  bool _isQuestionExpanded = false;
  bool _isDescriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isA = widget.currentBoxType == 'A';
    final labelColor = isA ? VersusColors.primary : VersusColors.secondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black,
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const questionStyle = TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          );
          const descriptionStyle = TextStyle(
            color: Colors.white70,
            fontSize: 14,
            height: 1.5,
          );

          final questionExceedsLimit = _exceedsMaxLines(
            widget.question,
            questionStyle,
            constraints.maxWidth - 50,
            2,
          );

          final descriptionExceedsLimit = widget.description != null &&
              widget.description!.isNotEmpty &&
              _exceedsMaxLines(
                widget.description!,
                descriptionStyle,
                constraints.maxWidth - 50,
                3,
              );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQuestionSection(questionStyle, questionExceedsLimit),
              const SizedBox(height: 12),
              _buildOptionSection(labelColor),
              if (widget.description != null && widget.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildDescriptionSection(descriptionStyle, descriptionExceedsLimit),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildQuestionSection(TextStyle style, bool exceedsLimit) {
    return GestureDetector(
      onTap: exceedsLimit
          ? () => setState(() => _isQuestionExpanded = !_isQuestionExpanded)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Q: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: AnimatedCrossFade(
                firstChild: Text(
                  widget.question,
                  style: style,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.question,
                  style: style,
                ),
                crossFadeState: _isQuestionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
            if (exceedsLimit)
              AnimatedRotation(
                turns: _isQuestionExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.expand_more,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionSection(Color labelColor) {
    if (widget.isSingleMode) {
      // 단일 이미지 모드: A/B 타이틀 모두 표시
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOptionRow('A', widget.optionA, VersusColors.primary),
          const SizedBox(height: 8),
          _buildOptionRow('B', widget.optionB, VersusColors.secondary),
        ],
      );
    } else {
      // 듀얼 모드: 현재 보고 있는 이미지의 타이틀만 표시
      final isA = widget.currentBoxType == 'A';
      return _buildOptionRow(
        isA ? 'A' : 'B',
        isA ? widget.optionA : widget.optionB,
        labelColor,
      );
    }
  }

  Widget _buildOptionRow(String label, String text, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(TextStyle style, bool exceedsLimit) {
    return GestureDetector(
      onTap: exceedsLimit
          ? () => setState(() => _isDescriptionExpanded = !_isDescriptionExpanded)
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'D: ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
            Expanded(
              child: AnimatedCrossFade(
                firstChild: Text(
                  widget.description!,
                  style: style,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                secondChild: Text(
                  widget.description!,
                  style: style,
                ),
                crossFadeState: _isDescriptionExpanded
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 200),
              ),
            ),
            if (exceedsLimit)
              AnimatedRotation(
                turns: _isDescriptionExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: const Icon(
                  Icons.expand_more,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _exceedsMaxLines(String text, TextStyle style, double maxWidth, int maxLines) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);

    return textPainter.didExceedMaxLines;
  }
}