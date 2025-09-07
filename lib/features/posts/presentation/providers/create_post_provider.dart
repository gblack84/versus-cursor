import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import '/core_exports.dart';
import '/backend/backend.dart';
import '/features/auth/data/services/auth_util.dart';
import '/features/posts/data/services/validation_service.dart';
import '/features/posts/data/services/moderation/models/moderation_result.dart' as ai;
import '/services/content/content_filter.dart';
import '/services/ui/models/enums.dart';
import '/services/ui/injection/ui_service_injection.dart';
import '/features/posts/domain/usecases/media/ratio_calculator.dart';
import '/features/posts/data/services/error/error_handler.dart';
import '/features/posts/presentation/utils/debug_helper.dart';

/// Provider for managing post creation business logic
class CreatePostProvider extends ChangeNotifier {

  CreatePostProvider() {
    _initialize();
  }
  // Text Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController textAController = TextEditingController();
  final TextEditingController textBController = TextEditingController();

  // Focus Nodes
  final FocusNode titleFocusNode = FocusNode();
  final FocusNode descriptionFocusNode = FocusNode();
  final FocusNode textAFocusNode = FocusNode();
  final FocusNode textBFocusNode = FocusNode();

  // State Management
  bool _isValidating = false;
  bool _isShowingDialog = false;
  bool _isSingleMode = false;
  LayoutType _currentLayout = LayoutType.horizontal;
  String? _validationMessage;
  String _validationSessionId = '';
  
  // Getters
  bool get isValidating => _isValidating;
  bool get isShowingDialog => _isShowingDialog;
  bool get isSingleMode => _isSingleMode;
  LayoutType get currentLayout => _currentLayout;
  String? get validationMessage => _validationMessage;
  String get validationSessionId => _validationSessionId;

  void _initialize() {
    // Generate validation session ID
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch.toString().substring(10);
    _validationSessionId = '${timestamp}_$random';
    
    // Initialize content filter
    ContentFilter.initialize();
  }

  /// Check if all required fields are filled
  bool areRequiredFieldsFilled() {
    return titleController.text.isNotEmpty &&
           textAController.text.isNotEmpty &&
           (!_isSingleMode || textBController.text.isNotEmpty);
  }

  /// Toggle single/dual mode
  void toggleSingleMode() {
    _isSingleMode = !_isSingleMode;
    notifyListeners();
  }

  /// Update layout type
  void updateLayout(LayoutType layout) {
    if (_currentLayout != layout) {
      _currentLayout = layout;
      notifyListeners();
    }
  }

  /// Validate all text fields with AI moderation
  Future<ValidationResult> validateTexts({
    required BuildContext context,
    required AppState appState,
  }) async {
    _isValidating = true;
    _validationMessage = null;
    notifyListeners();

    try {
      // Create validation request
      final request = TextValidationRequest(
        title: titleController.text,
        description: descriptionController.text,
        optionA: textAController.text,
        optionB: _isSingleMode ? '' : textBController.text,
        sessionId: _validationSessionId,
      );

      // Validate texts
      final validationService = ValidationService();
      final result = await validationService.validateAllTexts(
        request: request,
        context: context,
        onValidationUpdate: (message) {
          _validationMessage = message;
          notifyListeners();
        },
      );

      return result;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Save post to Firestore
  Future<void> savePost({
    required BuildContext context,
    required AppState appState,
    required Map<String, dynamic> targetAudience,
    ai.GeminiModerationResult? geminiResult,
  }) async {
    final user = currentUser;
    if (user == null) {
      ErrorHandler.showErrorToast('로그인이 필요합니다.');
      return;
    }

    _isValidating = true;
    notifyListeners();

    try {
      // Get user document
      final userDoc = await UsersModel.getDocumentOnce(
        GetIt.instance<FirebaseFirestore>().collection('users').doc(user.uid)
      );

      // Calculate aspect ratios
      final aspectRatioA = appState.uploadImageAspectRatioA.isNotEmpty 
          ? RatioCalculator.getRatio(appState.uploadImageAspectRatioA, box: 'A')
          : null;
      final aspectRatioB = (_isSingleMode || appState.uploadImageAspectRatioB.isEmpty)
          ? null
          : RatioCalculator.getRatio(appState.uploadImageAspectRatioB, box: 'B');

      // Determine layout type
      String layoutType;
      if (_isSingleMode) {
        layoutType = 'single';
      } else if (aspectRatioA != null || aspectRatioB != null) {
        final analyzedLayout = layoutAnalyzer.getOptimalLayout(aspectRatioA, aspectRatioB);
        layoutType = analyzedLayout.name;
      } else {
        layoutType = _currentLayout == LayoutType.horizontal ? 'horizontal' : 'vertical';
      }

      // Create post data
      final postData = createPostsModelData(
        userid: user.uid,
        uid: user.uid,
        email: user.email,
        displayName: userDoc.displayName,
        photoUrl: userDoc.photoUrl,
        content: descriptionController.text,
        questionTitle: titleController.text,
        createdAt: DateTime.now(),
        createdTime: DateTime.now(),
        optionA: {
          'title': textAController.text,
          'mediaUrls': appState.uploadImageA,
          'mediaType': 'image',
          'aspectRatio': aspectRatioA,
        },
        optionB: _isSingleMode ? null : {
          'title': textBController.text,
          'mediaUrls': appState.uploadImageB,
          'mediaType': 'image',
          'aspectRatio': aspectRatioB,
        },
        layoutType: layoutType,
        targetAudience: targetAudience,
        expectedRatioA: geminiResult?.expectedRatioA ?? 0.5,
        expectedRatioB: geminiResult?.expectedRatioB ?? 0.5,
      );

      // Save to Firestore
      await PostsModel.collection.add(postData);
      
      // Clear form data
      clearForm(appState);
      
      ErrorHandler.showSuccessToast('질문이 성공적으로 등록되었습니다!');
    } catch (e) {
      ErrorHandler.handle(
        e,
        type: ErrorType.database,
        customMessage: '게시물 저장 중 오류가 발생했습니다.',
        context: context,
      );
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Clear all form data
  void clearForm(AppState appState) {
    titleController.clear();
    descriptionController.clear();
    textAController.clear();
    textBController.clear();
    
    appState.update(() {
      appState.uploadImageA = [];
      appState.uploadImageB = [];
      appState.tempImageFilesA = [];
      appState.tempImageFilesB = [];
      appState.uploadImageAspectRatioA = [];
      appState.uploadImageAspectRatioB = [];
      appState.assetEntityIdsA = [];
      appState.assetEntityIdsB = [];
      appState.questionTitle = '';
      appState.questionDescription = '';
      appState.uploadTextA = '';
      appState.uploadTextB = '';
    });
    
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    textAController.dispose();
    textBController.dispose();
    titleFocusNode.dispose();
    descriptionFocusNode.dispose();
    textAFocusNode.dispose();
    textBFocusNode.dispose();
    super.dispose();
  }
}