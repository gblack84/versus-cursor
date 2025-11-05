import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/create_post_notifier.dart';
import '/core/utils/debounce.dart';
import '../components/input_field_builder.dart';
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
  final bool showOptionB;
  final String? validationSessionId;

  const TextInputWidget({
    super.key,
    this.onTitleChanged,
    this.onDescriptionChanged,
    this.onTextAChanged,
    this.onTextBChanged,
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

  // Validation (only for Option fields - Title/Description use InputFieldBuilder)
  String? _textAError;
  String? _textBError;

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

    _titleController = TextEditingController(text: createPostState.formData.title);
    _descriptionController = TextEditingController(text: createPostState.formData.description);
    _textAController = TextEditingController(text: createPostState.formData.textA);
    _textBController = TextEditingController(text: createPostState.formData.textB);

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
    final notifier = ref.read(createPostProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목 입력
          _buildTitleField(),
          const SizedBox(height: 16),

          // 설명 입력
          _buildDescriptionField(),
          const SizedBox(height: 16),

          // 옵션 텍스트 A
          _buildOptionTextField(
            label: 'A 옵션 텍스트',
            controller: _textAController,
            focusNode: _textAFocus,
            errorText: _textAError,
            hintText: 'A 옵션에 대한 설명을 입력하세요',
            onChanged: (text) => notifier.updateTextA(text),
          ),

          // 옵션 텍스트 B
          if (widget.showOptionB) ...[
            const SizedBox(height: 16),
            _buildOptionTextField(
              label: 'B 옵션 텍스트',
              controller: _textBController,
              focusNode: _textBFocus,
              errorText: _textBError,
              hintText: 'B 옵션에 대한 설명을 입력하세요',
              onChanged: (text) => notifier.updateTextB(text),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleField() {
    final notifier = ref.read(createPostProvider.notifier);
    final state = ref.watch(createPostProvider);

    return InputFieldBuilder.buildTitleField(
      context: context,
      controller: _titleController,
      focusNode: _titleFocus,
      onFieldChanged: (value, fieldName, isBlocked) {
        // Update provider
        notifier.updateTitle(value);

        // Trigger debounced validation
        _titleDebounce?.run(() async {
          await notifier.validateTitle(value);
        });

        // Call external callback
        widget.onTitleChanged?.call(value);
      },
      onFieldCleared: () {
        notifier.clearValidationResult(FieldStyles.questionTitle);
        widget.onTitleChanged?.call('');
      },
      onRequiredFieldsCheck: () {
        // Optional: Can trigger form validation check
      },
      validationResult: state.validationResults[FieldStyles.questionTitle],
    );
  }

  Widget _buildDescriptionField() {
    final notifier = ref.read(createPostProvider.notifier);
    final state = ref.watch(createPostProvider);

    return InputFieldBuilder.buildDescriptionField(
      context: context,
      controller: _descriptionController,
      focusNode: _descriptionFocus,
      onFieldChanged: (value, fieldName, isBlocked) {
        // Update provider
        notifier.updateDescription(value);

        // Trigger debounced validation
        _descriptionDebounce?.run(() async {
          await notifier.validateDescription(value);
        });

        // Call external callback
        widget.onDescriptionChanged?.call(value);
      },
      onFieldCleared: () {
        notifier.clearValidationResult(FieldStyles.description);
        widget.onDescriptionChanged?.call('');
      },
      onRequiredFieldsCheck: () {
        // Optional: Can trigger form validation check
      },
      validationResult: state.validationResults[FieldStyles.description],
    );
  }

  Widget _buildOptionTextField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    String? hintText,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          maxLines: 2,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            errorText: errorText,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.red,
              ),
            ),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
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