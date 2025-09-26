import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core_exports.dart';
import '/features/creation/presentation/providers/create_post_provider.dart';
import '/features/creation/presentation/providers/media_upload_provider.dart';
import '/features/creation/presentation/components/media_upload_section.dart';
import '/features/creation/presentation/components/text_input_section.dart';
import '/features/creation/presentation/widgets/components/next_button.dart';
import '/features/creation/presentation/widgets/components/warning_message.dart';
import '/features/creation/presentation/widgets/dialogs/target_audience_dialog.dart';
import '/features/creation/presentation/utils/no_animation_page_route.dart';
import '/features/creation/presentation/widgets/media/media_selection_flow_widget.dart';
import '/features/creation/domain/constants/animation_constants.dart';
import 'in_put_post_image_model.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

/// Refactored post creation screen using clean architecture
class InPutPostImageScreen extends StatefulWidget {
  const InPutPostImageScreen({super.key});

  static String routeName = 'InPutPostImage';
  static String routePath = '/inPutPostImage';

  @override
  State<InPutPostImageScreen> createState() => _InPutPostImageScreenState();
}

class _InPutPostImageScreenState extends State<InPutPostImageScreen>
    with SingleTickerProviderStateMixin {
  late InPutPostImageModel _model;
  late CreatePostProvider _createProvider;
  late MediaUploadProvider _uploadProvider;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController? _scrollController;
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;

  bool _showNextButton = false;
  bool _hasValidated = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InPutPostImageModel());

    // Initialize providers
    _createProvider = CreatePostProvider();
    _uploadProvider = MediaUploadProvider();

    // Initialize scroll controller
    _scrollController = ScrollController();
    _scrollController!.addListener(_scrollListener);

    // Initialize shake animation
    _shakeController = AnimationController(
      duration: AnimationConstants.shakeAnimationDuration,
      vsync: this,
    );

    _shakeAnimation = Tween<double>(
      begin: 0,
      end: AnimationConstants.shakeAnimationExtent,
    ).animate(CurvedAnimation(
      parent: _shakeController!,
      curve: Curves.easeInOut,
    ));
  }

  void _scrollListener() {
    if (!mounted) return;

    final isNearBottom = _scrollController!.position.pixels >=
        _scrollController!.position.maxScrollExtent - 100;

    final shouldShow =
        isNearBottom || _createProvider.areRequiredFieldsFilled();

    if (shouldShow != _showNextButton) {
      setState(() {
        _showNextButton = shouldShow;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _createProvider),
        ChangeNotifierProvider.value(value: _uploadProvider),
      ],
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          key: scaffoldKey,
          backgroundColor: Colors.black,
          body: SafeArea(
            child: Stack(
              children: [
                _buildMainContent(),
                _buildNextButton(),
                if (_createProvider.isValidating) _buildLoadingOverlay(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final hasImageInA = appState.tempImageFilesA.isNotEmpty;
        final hasImageInB = appState.tempImageFilesB.isNotEmpty;
        final isBEmpty =
            appState.tempImageFilesB.isEmpty && appState.uploadTextB.isEmpty;

        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Title section
              _buildTitleSection(),

              const SizedBox(height: 30),

              // Text input section
              TextInputSection(
                hasValidated: _hasValidated,
                onFieldChanged: _checkRequiredFields,
              ),

              const SizedBox(height: 20),

              // Media upload section
              MediaUploadSection(
                isSingleMode: _model.absellected,
                showDebugInfo: false, // Set to true for debugging
                onMediaSelect: _handleMediaSelection,
              ),

              // Warning message if needed
              if (!hasImageInA && hasImageInB)
                const WarningMessage(
                  message: 'A 박스에 이미지를 먼저 추가해주세요',
                ),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '질문 작성',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              // Toggle single mode button
              IconButton(
                icon: Icon(
                  _model.absellected
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _model.absellected = !_model.absellected;
                    _createProvider.toggleSingleMode();
                  });
                },
              ),
              const Text(
                'A만 사용',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      bottom: _showNextButton ? 20 : -100,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _shakeAnimation!,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(_shakeAnimation!.value, 0),
            child: NextButton(
              onPressed: _handleNextButton,
              isEnabled: _createProvider.areRequiredFieldsFilled(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              _createProvider.validationMessage ?? '처리 중...',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleMediaSelection(
    String box, {
    bool isAddMode = false,
    int? currentIndex,
  }) async {
    final appState = context.read<AppState>();

    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      NoAnimationPageRoute(
        builder: (context) => MediaSelectionFlowWidget(
          box: box,
          model: _model,
          isAddMode: isAddMode,
          currentIndex: currentIndex,
          existingAssetIds:
              box == 'A' ? appState.assetEntityIdsA : appState.assetEntityIdsB,
          existingImageUrls:
              box == 'A' ? appState.uploadImageA : appState.uploadImageB,
          existingAspectRatios: box == 'A'
              ? appState.uploadImageAspectRatioA
              : appState.uploadImageAspectRatioB,
          onComplete: (imageUrl) {
            // Handle single image completion
          },
          onMultiComplete: (imageUrls) {
            // Handle multiple images completion
          },
        ),
      ),
    );

    // Process result if needed
    if (result != null && result['action'] == 'processing' && isAddMode) {
      await _processSelectedAssets(result['selectedAssets'], box, appState);
    }
  }

  Future<void> _processSelectedAssets(
    List<AssetEntity>? assets,
    String box,
    AppState appState,
  ) async {
    if (assets == null) return;

    setState(() {
      _isProcessing = true;
    });

    final cancel = BotToast.showCustomLoading(
      toastBuilder: (_) => _buildProcessingOverlay(),
      allowClick: false,
      clickClose: false,
    );

    try {
      await _uploadProvider.processAssets(
        context: context,
        appState: appState,
        assets: assets,
        box: box,
        isAddMode: true,
      );
    } finally {
      cancel();
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Widget _buildProcessingOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                '안전성 검사중 입니다...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleNextButton() async {
    if (!_createProvider.areRequiredFieldsFilled()) {
      setState(() {
        _hasValidated = true;
      });
      _triggerShakeAnimation();
      return;
    }

    final appState = context.read<AppState>();

    // Validate texts
    final validationResult = await _createProvider.validateTexts(
      context: context,
      appState: appState,
    );

    if (!validationResult.success) {
      // Validation failed
      return;
    }

    // Show target audience dialog
    final targetAudience = await TargetAudienceDialog.show(context);
    if (targetAudience == null) {
      // User cancelled
      await _uploadProvider.cleanupUploadedImages(appState);
      return;
    }

    // Save to Firestore
    await _createProvider.savePost(
      context: context,
      appState: appState,
      targetAudience: targetAudience,
      geminiResult: validationResult.geminiResult,
    );

    // Navigate back or to success screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _triggerShakeAnimation() {
    _shakeController!.forward().then((_) {
      _shakeController!.reverse();
    });
  }

  void _checkRequiredFields() {
    setState(() {
      _showNextButton = _createProvider.areRequiredFieldsFilled();
    });
  }

  @override
  void dispose() {
    _createProvider.dispose();
    _uploadProvider.dispose();
    _scrollController?.dispose();
    _shakeController?.dispose();
    _model.dispose();
    super.dispose();
  }
}
