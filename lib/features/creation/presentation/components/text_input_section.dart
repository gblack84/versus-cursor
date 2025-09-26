import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/features/creation/presentation/providers/create_post_provider.dart';
import '/features/creation/presentation/widgets/components/simple_validated_field.dart';
import '/features/creation/presentation/widgets/components/character_count_display.dart';
import '/features/creation/domain/constants/field_styles.dart';
import '/features/creation/domain/constants/text_limits.dart';

/// Text input section component for post creation
class TextInputSection extends StatefulWidget {
  const TextInputSection({
    super.key,
    this.hasValidated = false,
    this.onFieldChanged,
  });
  final bool hasValidated;
  final Function? onFieldChanged;

  @override
  State<TextInputSection> createState() => _TextInputSectionState();
}

class _TextInputSectionState extends State<TextInputSection> {
  // Track field states
  final Map<String, bool> _fieldEmpty = {
    'title': true,
    'description': true,
    'optionA': true,
    'optionB': true,
  };

  @override
  Widget build(BuildContext context) {
    return Consumer<CreatePostProvider>(
      builder: (context, provider, _) {
        return Column(
          children: [
            // Question Title
            _buildTitleField(provider),

            const SizedBox(height: 12),

            // Description (optional)
            _buildDescriptionField(provider),

            const SizedBox(height: 20),

            // Option A Text
            _buildOptionField(
              provider: provider,
              controller: provider.textAController,
              focusNode: provider.textAFocusNode,
              label: 'A',
              fieldKey: 'optionA',
            ),

            if (!provider.isSingleMode) ...[
              const SizedBox(height: 12),

              // Option B Text
              _buildOptionField(
                provider: provider,
                controller: provider.textBController,
                focusNode: provider.textBFocusNode,
                label: 'B',
                fieldKey: 'optionB',
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildTitleField(CreatePostProvider provider) {
    final config = FieldStyles.questionTitle;

    return SimpleValidatedField(
      controller: provider.titleController,
      focusNode: provider.titleFocusNode,
      placeholder: config.placeholder,
      maxLength: config.maxLength,
      maxLines: config.maxLines,
      minLines: config.minLines,
      required: config.required,
      showCounter: config.showCounter,
      hasValidated: widget.hasValidated,
      errorText:
          widget.hasValidated && _fieldEmpty['title']! ? '제목은 필수 항목입니다' : null,
      onChanged: (val) {
        setState(() {
          _fieldEmpty['title'] = val.isEmpty;
        });
        widget.onFieldChanged?.call();
      },
    );
  }

  Widget _buildDescriptionField(CreatePostProvider provider) {
    final config = FieldStyles.questionDescription;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SimpleValidatedField(
          controller: provider.descriptionController,
          focusNode: provider.descriptionFocusNode,
          placeholder: config.placeholder,
          maxLength: config.maxLength,
          maxLines: config.maxLines,
          minLines: config.minLines,
          required: config.required,
          showCounter: false, // We show custom counter
          hasValidated: widget.hasValidated,
          onChanged: (val) {
            setState(() {
              _fieldEmpty['description'] = val.isEmpty;
            });
            widget.onFieldChanged?.call();
          },
        ),
        CharacterCountDisplay(
          currentLength: provider.descriptionController.text.length,
          maxLength: TextLimits.descriptionMaxLength,
        ),
      ],
    );
  }

  Widget _buildOptionField({
    required CreatePostProvider provider,
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String fieldKey,
  }) {
    final config =
        label == 'A' ? FieldStyles.optionATitle : FieldStyles.optionBTitle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: label == 'A'
                    ? const Color(0xFF4A90E2)
                    : const Color(0xFFF5A623),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SimpleValidatedField(
                controller: controller,
                focusNode: focusNode,
                placeholder: config.placeholder,
                maxLength: config.maxLength,
                maxLines: config.maxLines,
                minLines: config.minLines,
                required: config.required,
                showCounter: false, // We show custom counter
                hasValidated: widget.hasValidated,
                errorText: widget.hasValidated && _fieldEmpty[fieldKey]!
                    ? '$label 옵션은 필수 항목입니다'
                    : null,
                onChanged: (val) {
                  setState(() {
                    _fieldEmpty[fieldKey] = val.isEmpty;
                  });
                  widget.onFieldChanged?.call();
                },
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: CharacterCountDisplay(
            currentLength: controller.text.length,
            maxLength: TextLimits.optionMaxLength,
          ),
        ),
      ],
    );
  }
}
