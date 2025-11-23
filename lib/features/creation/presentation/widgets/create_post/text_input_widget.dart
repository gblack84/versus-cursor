import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/create_post_notifier.dart';
import '/core/utils/helpers/debounce.dart';
import '../components/input_field_builder.dart';
import '../components/simple_validated_field.dart';
import '../components/character_count_display.dart';
import '/features/creation/presentation/constants/field_styles.dart';

/// Text input component for post creation
///
/// Migrated to Riverpod 3.x (Phase 2-6)
/// Handles title, description, and option text inputs with validation
/// - Uses InputFieldBuilder for Title and Description (SimpleValidatedField)
/// - Uses basic TextFormField for Option A/B
class TextInputWidget extends ConsumerStatefulWidget {
  final Function(String)? onTitleChanged;
  final Function(String)? onDescriptionChanged;
  final Function(String)? onTextAChanged;
  final Function(String)? onTextBChanged;
  final bool showTitle;
  final bool showDescription;
  final bool showOptionA;
  final bool showOptionB;
  final String? validationSessionId;

  const TextInputWidget({
    super.key,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onTextAChanged,
    this.onTextBChanged,
    this.showTitle = true,
    this.showDescription = true,
    this.showOptionA = true,
    this.showOptionB = true,
    this.validationSessionId,
  });

  @override
  ConsumerState<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends ConsumerState<TextInputWidget> {
  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _textAController;
  late TextEditingController _textBController;

  // Focus nodes
  final FocusNode _titleFocus = FocusNode();
  final FocusNode _descriptionFocus = FocusNode();
  final FocusNode _textAFocus = FocusNode();
  final FocusNode _textBFocus = FocusNode();

  // Debounce for validation
  Debounce? _titleDebounce;
  Debounce? _descriptionDebounce;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupDebounce();
  }

  void _initializeControllers() {
    final createPostState = ref.read(createPostProvider);

    _titleController = TextEditingController(
      text: createPostState.formData.title,
    );
    _descriptionController = TextEditingController(
      text: createPostState.formData.description,
    );
    _textAController = TextEditingController(
      text: createPostState.formData.textA,
    );
    _textBController = TextEditingController(
      text: createPostState.formData.textB,
    );

    // Add listeners only for Option fields
    // Title/Description are handled by InputFieldBuilder callbacks
    _textAController.addListener(_onTextAChanged);
    _textBController.addListener(_onTextBChanged);
  }

  void _setupDebounce() {
    // Debounce instances for Title/Description validation
    _titleDebounce = Debounce(milliseconds: 500);
    _descriptionDebounce = Debounce(milliseconds: 500);
  }

  void _onTextAChanged() {
    final text = _textAController.text;
    final notifier = ref.read(createPostProvider.notifier);

    // Update provider directly
    notifier.updateTextA(text);
    widget.onTextAChanged?.call(text);
  }

  void _onTextBChanged() {
    final text = _textBController.text;
    final notifier = ref.read(createPostProvider.notifier);

    // Update provider directly
    notifier.updateTextB(text);
    widget.onTextBChanged?.call(text);
  }

  // Validation methods removed - now using Provider's ValidatePostUseCase

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.fromSTEB(10.0, 3.0, 10.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 입력
          if (widget.showTitle) ...[
            _buildTitleField(),
            const SizedBox(height: 16),
          ],

          // 설명 입력
          if (widget.showDescription) ...[
            _buildDescriptionField(),
            const SizedBox(height: 16),
          ],

          // 옵션 텍스트 A
          if (widget.showOptionA) _buildOptionAField(),

          // 옵션 텍스트 B
          if (widget.showOptionB) ...[
            const SizedBox(height: 16),
            _buildOptionBField(),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    final state = ref.watch(createPostProvider);

    return Column(
      children: [
        InputFieldBuilder.buildTitleField(
          context: context,
          controller: _titleController,
          focusNode: _titleFocus,
          onFieldChanged: (value, fieldName, isBlocked) {
            // Update provider
            ref.read(createPostProvider.notifier).updateTitle(value);

            // Trigger debounced validation
            _titleDebounce?.run(() async {
              await ref.read(createPostProvider.notifier).validateTitle(value);
            });

            // Call external callback
            widget.onTitleChanged?.call(value);
          },
          onFieldCleared: () {
            ref
                .read(createPostProvider.notifier)
                .clearValidationResult(FieldStyles.questionTitle);
            widget.onTitleChanged?.call('');
          },
          onRequiredFieldsCheck: () {
            // Optional: Can trigger form validation check
          },
          validationResult: state.validationResults[FieldStyles.questionTitle],
        ),
        CharacterCountDisplay(
          controller: _titleController,
          maxLength:
              FieldStyles.fieldConfigs[FieldStyles.questionTitle]!.maxLength!,
          isEmpty: _titleController.text.isEmpty,
          horizontalPadding: 22.0, // Title/Description use 22.0
          validationResult: state.validationResults[FieldStyles.questionTitle],
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    final state = ref.watch(createPostProvider);

    return Column(
      children: [
        InputFieldBuilder.buildDescriptionField(
          context: context,
          controller: _descriptionController,
          focusNode: _descriptionFocus,
          onFieldChanged: (value, fieldName, isBlocked) {
            // Update provider
            ref.read(createPostProvider.notifier).updateDescription(value);

            // Trigger debounced validation
            _descriptionDebounce?.run(() async {
              await ref
                  .read(createPostProvider.notifier)
                  .validateDescription(value);
            });

            // Call external callback
            widget.onDescriptionChanged?.call(value);
          },
          onFieldCleared: () {
            ref
                .read(createPostProvider.notifier)
                .clearValidationResult(FieldStyles.description);
            widget.onDescriptionChanged?.call('');
          },
          onRequiredFieldsCheck: () {
            // Optional: Can trigger form validation check
          },
          validationResult: state.validationResults[FieldStyles.description],
        ),
        CharacterCountDisplay(
          controller: _descriptionController,
          maxLength:
              FieldStyles.fieldConfigs[FieldStyles.description]!.maxLength!,
          isEmpty: _descriptionController.text.isEmpty,
          horizontalPadding: 22.0, // Title/Description use 22.0
          validationResult: state.validationResults[FieldStyles.description],
        ),
      ],
    );
  }

  Widget _buildOptionAField() {
    final state = ref.watch(createPostProvider);

    return Column(
      children: [
        SimpleValidatedField(
          controller: _textAController,
          focusNode: _textAFocus,
          labelKey: 'option_a_label', // A 옵션 라벨
          hintKey: 'option_a_hint', // A 옵션 힌트
          fieldName: FieldStyles.textA,
          validationResult: state.validationResults[FieldStyles.textA],
          onFieldChanged: (value, fieldName, isBlocked) {
            ref.read(createPostProvider.notifier).updateTextA(value);
            widget.onTextAChanged?.call(value);
          },
          onFieldCleared: () {
            ref
                .read(createPostProvider.notifier)
                .clearValidationResult(FieldStyles.textA);
          },
          onRequiredFieldsCheck: () {
            // Optional: Can trigger form validation check
          },
        ),
        CharacterCountDisplay(
          controller: _textAController,
          maxLength: FieldStyles.fieldConfigs[FieldStyles.textA]!.maxLength!,
          isEmpty: _textAController.text.isEmpty,
          horizontalPadding: 32.0, // Options use 32.0
          validationResult: state.validationResults[FieldStyles.textA],
        ),
      ],
    );
  }

  Widget _buildOptionBField() {
    final state = ref.watch(createPostProvider);

    return Column(
      children: [
        SimpleValidatedField(
          controller: _textBController,
          focusNode: _textBFocus,
          labelKey: 'option_b_label', // B 옵션 라벨
          hintKey: 'option_b_hint', // B 옵션 힌트
          fieldName: FieldStyles.textB,
          validationResult: state.validationResults[FieldStyles.textB],
          onFieldChanged: (value, fieldName, isBlocked) {
            ref.read(createPostProvider.notifier).updateTextB(value);
            widget.onTextBChanged?.call(value);
          },
          onFieldCleared: () {
            ref
                .read(createPostProvider.notifier)
                .clearValidationResult(FieldStyles.textB);
          },
          onRequiredFieldsCheck: () {
            // Optional: Can trigger form validation check
          },
        ),
        CharacterCountDisplay(
          controller: _textBController,
          maxLength: FieldStyles.fieldConfigs[FieldStyles.textB]!.maxLength!,
          isEmpty: _textBController.text.isEmpty,
          horizontalPadding: 32.0, // Options use 32.0
          validationResult: state.validationResults[FieldStyles.textB],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _textAController.dispose();
    _textBController.dispose();
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _textAFocus.dispose();
    _textBFocus.dispose();
    _titleDebounce?.dispose();
    _descriptionDebounce?.dispose();
    super.dispose();
  }
}
