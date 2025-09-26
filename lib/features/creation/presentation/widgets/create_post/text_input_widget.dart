import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/core_exports.dart';
import '../../adapters/create_post_adapter.dart';
import '../../providers/create_post_provider_v2.dart';
import '/core/utils/debounce.dart';

/// Text input component for post creation
///
/// Handles title, description, and option text inputs with validation
class TextInputWidget extends StatefulWidget {
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
  State<TextInputWidget> createState() => _TextInputWidgetState();
}

class _TextInputWidgetState extends State<TextInputWidget> {
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

  // Validation
  String? _titleError;
  String? _descriptionError;
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
    final appState = Provider.of<AppState>(context, listen: false);

    _titleController = TextEditingController(text: appState.questionTitle);
    _descriptionController = TextEditingController(text: appState.questionDescription);
    _textAController = TextEditingController(text: appState.uploadTextA);
    _textBController = TextEditingController(text: appState.uploadTextB);

    // Add listeners
    _titleController.addListener(_onTitleChanged);
    _descriptionController.addListener(_onDescriptionChanged);
    _textAController.addListener(_onTextAChanged);
    _textBController.addListener(_onTextBChanged);
  }

  void _setupDebounce() {
    _titleDebounce = Debounce(milliseconds: 500);
    _descriptionDebounce = Debounce(milliseconds: 500);
  }

  void _onTitleChanged() {
    final text = _titleController.text;
    widget.onTitleChanged?.call(text);

    // Debounced validation
    _titleDebounce?.run(() {
      _validateTitle(text);
    });
  }

  void _onDescriptionChanged() {
    final text = _descriptionController.text;
    widget.onDescriptionChanged?.call(text);

    // Debounced validation
    _descriptionDebounce?.run(() {
      _validateDescription(text);
    });
  }

  void _onTextAChanged() {
    final text = _textAController.text;
    widget.onTextAChanged?.call(text);
  }

  void _onTextBChanged() {
    final text = _textBController.text;
    widget.onTextBChanged?.call(text);
  }

  void _validateTitle(String text) {
    if (text.isEmpty) {
      setState(() {
        _titleError = '제목을 입력해주세요';
      });
      return;
    }

    if (text.length < 2) {
      setState(() {
        _titleError = '제목은 최소 2자 이상이어야 합니다';
      });
      return;
    }

    setState(() {
      _titleError = null;
    });
  }

  void _validateDescription(String text) {
    if (text.isEmpty) {
      setState(() {
        _descriptionError = '설명을 입력해주세요';
      });
      return;
    }

    if (text.length < 5) {
      setState(() {
        _descriptionError = '설명은 최소 5자 이상이어야 합니다';
      });
      return;
    }

    setState(() {
      _descriptionError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AppState, CreatePostProviderV2>(
      builder: (context, appState, cleanProvider, child) {
        final adapter = CreatePostAdapter(
          cleanProvider: cleanProvider,
          legacyState: appState,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 입력
              _buildTitleField(adapter),
              const SizedBox(height: 16),

              // 설명 입력
              _buildDescriptionField(adapter),
              const SizedBox(height: 16),

              // 옵션 텍스트 A
              _buildOptionTextField(
                label: 'A 옵션 텍스트',
                controller: _textAController,
                focusNode: _textAFocus,
                errorText: _textAError,
                hintText: 'A 옵션에 대한 설명을 입력하세요',
                onChanged: (text) => adapter.updateTextA(text),
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
                  onChanged: (text) => adapter.updateTextB(text),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleField(CreatePostAdapter adapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '질문 제목 *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _titleController,
          focusNode: _titleFocus,
          maxLength: 60,
          decoration: InputDecoration(
            hintText: '어떤 선택을 물어보고 싶으신가요?',
            errorText: _titleError,
            counterText: '${_titleController.text.length}/60',
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          onChanged: (text) {
            adapter.updateTitle(text);
            _onTitleChanged();
          },
        ),
      ],
    );
  }

  Widget _buildDescriptionField(CreatePostAdapter adapter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '설명 *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _descriptionController,
          focusNode: _descriptionFocus,
          maxLength: 400,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '자세한 설명을 작성해주세요',
            errorText: _descriptionError,
            counterText: '${_descriptionController.text.length}/400',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: Theme.of(context).dividerColor,
              ),
            ),
          ),
          onChanged: (text) {
            adapter.updateDescription(text);
            _onDescriptionChanged();
          },
        ),
      ],
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