// upload_choice_bottom_sheet_widget.dart 임시 제거 - 새로운 업로드 위젯 구현 필요
import 'dart:async';
import '/core_exports.dart';
import '/services/content/content_filter.dart';
import '/features/posts/presentation/screens/viewer/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import 'package:bot_toast/bot_toast.dart';
import '/features/posts/presentation/utils/no_animation_page_route.dart';
import '/features/auth/data/services/auth_util.dart';
import 'in_put_post_image_model.dart';
export 'in_put_post_image_model.dart';
import '/features/posts/domain/usecases/media/aspect_ratio_analyzer.dart';
import '/services/ui/unified_box_calculator.dart';
import '/features/posts/presentation/widgets/components/media_box_callbacks.dart';
import '/features/posts/domain/usecases/media/ratio_calculator.dart';
import '/features/posts/presentation/widgets/components/media_selection_box_multi.dart';
import '/features/posts/presentation/widgets/components/character_count_display.dart';
import '/features/posts/presentation/widgets/components/next_button.dart';
import '/features/posts/presentation/widgets/components/simple_validated_field.dart';
import '/features/posts/presentation/widgets/components/layout_debug_info.dart';
import '/features/posts/presentation/widgets/components/warning_message.dart';
import '/features/posts/data/services/validation_service.dart';
import '/features/posts/presentation/widgets/components/input_field_builder.dart';
import '/features/posts/presentation/widgets/media/media_selection_flow_widget.dart';
import '/features/posts/presentation/widgets/dialogs/target_audience_dialog.dart';
import '/features/posts/presentation/utils/debug_helper.dart';
import '/features/posts/data/services/storage/storage_service.dart';
import '/features/posts/data/services/media/media_upload_service.dart';
import '/features/posts/data/services/error/error_handler.dart';
import '/features/posts/domain/constants/dimensions.dart';
import '/features/posts/domain/constants/animation_constants.dart';
import '/features/posts/domain/constants/field_styles.dart';
import '/features/posts/data/services/media/selection_result_processor.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import '/features/posts/data/services/moderation/models/moderation_result.dart' as ai;

class InPutPostImageWidget extends StatefulWidget {
  const InPutPostImageWidget({super.key});

  static String routeName = 'InPutPostImage';
  static String routePath = '/inPutPostImage';

  @override
  State<InPutPostImageWidget> createState() => _InPutPostImageWidgetState();
}

class _InPutPostImageWidgetState extends State<InPutPostImageWidget>
    with SingleTickerProviderStateMixin {
  late InPutPostImageModel _model;
  Timer? _layoutUpdateTimer;
  bool _isUpdatingLayout = false;
  AppState? _appState;  // AppState 참조 저장

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Consumer 최적화를 위한 이전 상태 추적
  int _lastImageCount = 0;
  


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InPutPostImageModel());

    // 콘텐츠 필터 초기화
    ContentFilter.initialize();

    _model.scrollController ??= ScrollController();
    _model.scrollController!.addListener(_scrollListener);
    
    // 검증 세션 ID 생성 (타임스탬프 + 랜덤 문자열)
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch.toString().substring(10);
    _model.validationSessionId = '${timestamp}_$random';
    
    // 초기 레이아웃 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      // 초기 상태 설정
      _lastImageCount = appState.tempImageFilesA.length + appState.tempImageFilesB.length;
      
      // B박스 자동 숨김 로직 제거 - 사용자 요청에 따라 A/B 모두 표시
      // 이제 페이지 진입 시 A/B 박스가 모두 표시됩니다 (absellected = false 유지)
      DebugHelper.logLayout('[Debug] 초기화: A/B 박스 모두 표시 (absellected = false)');
      
      // 초기 레이아웃 설정은 _performLayoutUpdate를 직접 호출
      if (_lastImageCount > 0) {
        _performLayoutUpdate();
      }
    });

    _initializeControllers();
    
    // 흔들림 애니메이션 초기화
    _model.shakeController = AnimationController(
      duration: AnimationConstants.shakeAnimationDuration,
      vsync: this,
    );
    
    _model.shakeAnimation = Tween<double>(
      begin: 0,
      end: AnimationConstants.shakeAnimationExtent,
    ).animate(CurvedAnimation(
      parent: _model.shakeController!,
      curve: Curves.easeInOut,
    ));

    // 초기 빌드 후 실행될 작업이 있으면 여기에 추가
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // AppState를 저장하여 dispose에서 사용
    _appState = context.read<AppState>();
  }

  /// 텍스트 컨트롤러 초기화
  void _initializeControllers() {
    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();
    
    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();
    
    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();
    
    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();
  }

  void _scrollListener() {
    if (!mounted) return;
    
    final isNearBottom = _model.scrollController!.position.pixels >=
        _model.scrollController!.position.maxScrollExtent - Dimensions.scrollThreshold;
    
    // 필수 필드가 채워져 있을 때만 스크롤에 따라 버튼 표시
    final shouldShow = isNearBottom || _areRequiredFieldsFilled();
    
    if (shouldShow != _model.showNextButton) {
      setState(() {
        _model.showNextButton = shouldShow;
      });
    }
  }

  /// 이미지 비율에 따라 레이아웃 자동 결정 (Debounced)
  void _updateLayoutBasedOnImages() {
    // 기존 타이머가 있다면 취소
    _layoutUpdateTimer?.cancel();
    
    // 300ms 후에 업데이트 실행 (debounce)
    _layoutUpdateTimer = Timer(const Duration(milliseconds: 300), () {
      _performLayoutUpdate();
    });
  }
  
  /// 실제 레이아웃 업데이트 수행
  void _performLayoutUpdate() {
    // mounted 체크
    if (!mounted) return;
    
    // 이미 업데이트 중이면 스킵
    if (_isUpdatingLayout) return;
    
    _isUpdatingLayout = true;
    
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      // B박스가 방금 표시된 경우 세로형 이미지 감지 및 레이아웃 자동 변경
      if (!_model.absellected && appState.tempImageFilesB.isEmpty && 
          appState.uploadImageAspectRatioA.isNotEmpty) {
        // A박스 이미지 비율로 레이아웃 결정
        final ratioA = RatioCalculator.getRatio(appState.uploadImageAspectRatioA, box: 'A');
        
        // 세로형 이미지면 세로 배치로 자동 변경
        if (ratioA < 1.0) {
          setState(() {
            _model.currentLayout = LayoutType.vertical;
            _model.isRatioVertical = false;  // 세로 배치(위/아래)
            _model.isRatioHorizontal = true;
          });
          DebugHelper.logLayout('[Debug] B박스 추가 - 세로형 이미지 감지, 세로 배치로 변경');
        }
      }
    
    // 디버그: B박스 상태 확인
    DebugHelper.logLayout('[Debug] B박스 상태 확인:');
    DebugHelper.logLayout('  - tempImageFilesB 개수: ${appState.tempImageFilesB.length}');
    DebugHelper.logLayout('  - uploadImageAspectRatioB 개수: ${appState.uploadImageAspectRatioB.length}');
    DebugHelper.logLayout('  - absellected: ${_model.absellected}');
    
    // 이미지가 하나도 없으면 기본 레이아웃(horizontal)으로 초기화
    if (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) {
      if (_model.currentLayout != LayoutType.horizontal) {
        // mounted 체크 추가
        if (mounted) {
          setState(() {
            _model.currentLayout = LayoutType.horizontal;
            _model.isRatioVertical = true;  // 가로 배치(좌/우)
            _model.isRatioHorizontal = false;
          });
        }
      }
      return;
    }
    
    // A박스와 B박스의 첫 번째 이미지 비율 가져오기
    double? ratioA;
    double? ratioB;
    
    if (appState.uploadImageAspectRatioA.isNotEmpty) {
      // 기존 로직 (첫 번째 이미지만 사용)
      // ratioA = appState.uploadImageAspectRatioA.first;
      
      // 새로운 로직 (하이브리드 계산)
      ratioA = RatioCalculator.getRatio(appState.uploadImageAspectRatioA, box: 'A');
      DebugHelper.logLayout('[Debug] A박스 비율 계산됨: $ratioA');
    }
    
    // absellected가 true이면 B박스 비율은 무시
    if (!_model.absellected && appState.uploadImageAspectRatioB.isNotEmpty) {
      // 기존 로직 (첫 번째 이미지만 사용)
      // ratioB = appState.uploadImageAspectRatioB.first;
      
      // 새로운 로직 (하이브리드 계산)
      ratioB = RatioCalculator.getRatio(appState.uploadImageAspectRatioB, box: 'B');
      DebugHelper.logLayout('[Debug] B박스 비율 계산됨: $ratioB');
    } else {
      DebugHelper.logLayout('[Debug] B박스 비율 무시됨 (absellected=${_model.absellected})');
    }
    
    // 스마트 레이아웃 결정
    LayoutType optimalLayout;
    if (_model.absellected) {
      // 단일 이미지 모드에서는 항상 single 레이아웃 사용
      optimalLayout = LayoutType.single;
      DebugHelper.logLayout('[Debug] 단일 이미지 모드 - LayoutType.single 사용');
    } else if (ratioA != null && ratioB == null && appState.tempImageFilesB.isEmpty) {
      // A박스만 있는 경우에도 이미지 비율에 따라 레이아웃 결정
      final orientation = AspectRatioAnalyzer.getOrientation(ratioA);
      if (orientation == ImageOrientation.landscape) {
        // 가로형 이미지 → 세로 배치가 더 적합
        optimalLayout = LayoutType.vertical;
      } else if (orientation == ImageOrientation.portrait) {
        // 세로형 이미지 → 가로 배치가 더 적합
        optimalLayout = LayoutType.horizontal;
      } else {
        // 정사각형 → 기본 가로 배치
        optimalLayout = LayoutType.horizontal;
      }
    } else {
      // 일반적인 경우 (A/B 둘 다 있거나 B만 있는 경우)
      optimalLayout = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);
    }
    
    // 레이아웃이 변경된 경우에만 업데이트
    if (_model.currentLayout != optimalLayout) {
      // mounted 체크 추가 - dispose된 후 setState 호출 방지
      if (mounted) {
        setState(() {
          _model.currentLayout = optimalLayout;
          
          // 기존 토글 상태도 함께 업데이트 (호환성)
          // 주의: isRatioVertical이 true면 UI에서 가로 배치(좌/우)를 표시
          // isRatioHorizontal이 true면 UI에서 세로 배치(위/아래)를 표시
          if (optimalLayout == LayoutType.vertical) {
            // 세로 배치 = 이미지가 위/아래로 배치
            _model.isRatioVertical = false;
            _model.isRatioHorizontal = true;
          } else {
            // 가로 배치 = 이미지가 좌/우로 배치
            _model.isRatioVertical = true;
            _model.isRatioHorizontal = false;
          }
        });
      }
    }
    } finally {
      _isUpdatingLayout = false;
    }
  }

  /// 필수 필드가 모두 채워졌는지 확인
  bool _areRequiredFieldsFilled() {
    return (_model.textController1?.text.trim().isNotEmpty ?? false) && // Question Title
           (_model.textController3?.text.trim().isNotEmpty ?? false) && // A title
           (_model.textController4?.text.trim().isNotEmpty ?? false);   // B title
  }

  /// 질문 제목 섹션 빌드
  Widget _buildQuestionTitleSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(
              Dimensions.defaultPadding, Dimensions.verticalSpacing, Dimensions.defaultPadding, 0.0),
          child: InputFieldBuilder.buildQuestionTitleField(
            context: context,
            controller: _model.textController1!,
            focusNode: _model.textFieldFocusNode1!,
            model: _model,
            onRequiredFieldsCheck: _checkRequiredFieldsAndUpdateButton,
            onBlockedWordChanged: (isBlocked) {
              if (mounted) {
                setState(() {
                  _model.hasBlockedWordInTitle = isBlocked;
                });
              }
            },
          ),
        ),
        CharacterCountDisplay(
          controller: _model.textController1,
          maxLength: 60,
          isEmpty: _model.isQuestionTitleEmpty,
          hasBlockedWord: _model.hasBlockedWordInTitle,
          validationResult: _model.validationResults[FieldStyles.questionTitle],
          horizontalPadding: 22.0, // 10 + 12
          hasValidated: _model.hasValidated,
        ),
        LayoutDebugInfo(currentLayout: _model.currentLayout),
      ],
    );
  }

  /// 필수 필드 체크 및 버튼 표시 업데이트
  void _checkRequiredFieldsAndUpdateButton() {
    final shouldShowButton = _areRequiredFieldsFilled();
    if (shouldShowButton != _model.showNextButton) {
      setState(() {
        _model.showNextButton = shouldShowButton;
      });
    }
  }

  /// 모든 텍스트 필드 검증
  Future<void> _validateAllTexts() async {
    try {
      // 로딩 상태 표시 및 검증 시도 표시
      setState(() {
        _model.isValidating = true;
        _model.hasValidated = true;
        _model.validationMessage = "내용을 검토하고 있습니다...";
      });

      final appState = context.read<AppState>();
      
      // 이미지가 있다면 먼저 업로드
      if (appState.tempImageFilesA.isNotEmpty || appState.tempImageFilesB.isNotEmpty) {
        setState(() {
          _model.validationMessage = "이미지를 업로드하고 있습니다...";
        });
        
        try {
          // A박스 이미지 업로드
          if (appState.tempImageFilesA.isNotEmpty) {
            DebugHelper.log('A박스 이미지 업로드 중: ${appState.tempImageFilesA.length}개');
            final urlsA = await MediaUploadService.uploadTempFiles(
              files: appState.tempImageFilesA,
              box: 'A',
              sessionId: _model.validationSessionId,
            );
            appState.update(() {
              appState.uploadImageA.clear();
              appState.uploadImageA.addAll(urlsA);
            });
          }
          
          // B박스 이미지 업로드
          if (appState.tempImageFilesB.isNotEmpty) {
            DebugHelper.log('B박스 이미지 업로드 중: ${appState.tempImageFilesB.length}개');
            final urlsB = await MediaUploadService.uploadTempFiles(
              files: appState.tempImageFilesB,
              box: 'B',
              sessionId: _model.validationSessionId,
            );
            appState.update(() {
              appState.uploadImageB.clear();
              appState.uploadImageB.addAll(urlsB);
            });
          }
          
          setState(() {
            _model.validationMessage = "내용을 검토하고 있습니다...";
          });
        } catch (uploadError) {
          DebugHelper.logError('이미지 업로드 실패', uploadError);
          _showSnackBar('이미지 업로드 중 오류가 발생했습니다.', isError: true);
          setState(() {
            _model.isValidating = false;
          });
          return;
        }
      }
      // ValidationService를 사용하여 검증
      final result = await ValidationService.validateAllTexts(
        questionTitle: _model.textController1?.text,
        description: _model.textController2?.text,
        aTitle: _model.textController3?.text,
        bTitle: _model.textController4?.text,
        context: context,
        onProgressUpdate: (message) {
          if (mounted) {
            setState(() {
              _model.validationMessage = message;
            });
          }
        },
        visionDataA: _model.visionResultA,
        visionDataB: _model.visionResultB,
        sessionId: _model.validationSessionId,
        documentId: _model.validationDocumentId,
        revisionCount: _model.validationRevisionCount,
      );

      // Gemini 결과에서 문서 ID 업데이트
      if (result.geminiResult?.documentId != null) {
        _model.validationDocumentId = result.geminiResult!.documentId;
        _model.validationRevisionCount++;
        DebugHelper.log('검증 문서 ID 업데이트: ${_model.validationDocumentId}, revision: ${_model.validationRevisionCount}');
      }
      
      // 사용자가 수정하기를 선택했는지 확인
      DebugHelper.log('[검증 결과] userRequestedModification: ${result.userRequestedModification}');
      
      // 상태 변경이 필요한지 확인
      final needsUpdate = 
          _model.isQuestionTitleEmpty != result.emptyResult.isQuestionTitleEmpty ||
          _model.isATitleEmpty != result.emptyResult.isATitleEmpty ||
          _model.isBTitleEmpty != result.emptyResult.isBTitleEmpty ||
          _model.hasValidationViolations != (!result.isValid && result.violations.isNotEmpty);
      
      if (needsUpdate) {
        setState(() {
          // 빈 필드 상태 업데이트
          _model.isQuestionTitleEmpty = result.emptyResult.isQuestionTitleEmpty;
          _model.isATitleEmpty = result.emptyResult.isATitleEmpty;
          _model.isBTitleEmpty = result.emptyResult.isBTitleEmpty;

          // 검증 결과 업데이트
          // _model.validationResults = result.validationResults; // AI Moderation으로 이동됨
          _model.hasValidationViolations = !result.isValid && result.violations.isNotEmpty;
          
          // 검증 통과 시 비어있음 에러 상태 초기화
          if (result.isValid) {
            _model.isQuestionTitleEmpty = false;
            _model.isATitleEmpty = false;
            _model.isBTitleEmpty = false;
          }
        });
      }
      // 3단계: 결과 처리
      if (result.errorMessage != null) {
        _showSnackBar(result.errorMessage!, isError: true);
        await _cleanupUploadedImages(); // 에러 시에도 정리
      } else if (!result.isValid && result.violations.isNotEmpty) {
        // BLOCK 케이스
        setState(() {
          _model.isShowingDialog = true;
          _model.validationMessage = null;
        });
        
        await ValidationService.showViolationDialog(context, result.violations, geminiResult: result.geminiResult);
        
        setState(() {
          _model.isShowingDialog = false;
        });
        
        await _cleanupUploadedImages(); // 업로드된 이미지 삭제
        return; // 로컬 파일은 유지
      } else if (result.isValid) {
        // PROCEED 또는 PROCEED_WITH_SUGGESTION 케이스
        
        // 사용자가 수정하기를 선택한 경우 처리
        if (result.userRequestedModification) {
          DebugHelper.log('[수정하기 선택] userRequestedModification = true');
          DebugHelper.log('[수정하기 선택] Firebase Storage 이미지 삭제 시작');
          DebugHelper.log('[수정하기 선택] uploadImageA: ${context.read<AppState>().uploadImageA}');
          DebugHelper.log('[수정하기 선택] uploadImageB: ${context.read<AppState>().uploadImageB}');
          await _cleanupUploadedImages(); // 업로드된 이미지 삭제
          DebugHelper.log('[수정하기 선택] cleanup 완료');
          
          if (mounted) {
            setState(() {
              _model.isValidating = false;
              _model.validationMessage = null;
            });
          }
          return; // 로컬 파일은 유지
        }
        
        // PROCEED_WITH_SUGGESTION 처리는 이제 ValidationService에서 처리됨
        // 여기서는 다이얼로그를 다시 표시하지 않음
        
        // 검증 통과 또는 계속하기 선택 - AppState에 텍스트 저장
        context.read<AppState>().update(() {
          final appState = context.read<AppState>();
          appState.uploadTextA = _model.textController3?.text ?? '';
          appState.uploadTextB = _model.textController4?.text ?? '';
          appState.questionTitle = _model.textController1?.text ?? '';
          appState.questionDescription = _model.textController2?.text ?? '';
          appState.isVerticalLayout = _model.isRatioVertical;
        });
        
        // 타겟 오디언스 다이얼로그 표시
        setState(() {
          _model.isShowingDialog = true;
          _model.validationMessage = null;
        });
        
        DebugHelper.log('[_validateAllTexts] TargetAudienceDialog.show() 호출 전');
        final targetAudience = await TargetAudienceDialog.show(context);
        DebugHelper.log('[_validateAllTexts] TargetAudienceDialog.show() 반환값: $targetAudience');
        
        setState(() {
          _model.isShowingDialog = false;
        });
        
        if (targetAudience == null) {
          DebugHelper.log('[_validateAllTexts] targetAudience가 null - 사용자가 취소함');
          // 사용자가 취소함
          await _cleanupUploadedImages(); // 업로드된 이미지 삭제
          setState(() {
            _model.isValidating = false;
            _model.validationMessage = null;
          });
          return; // 로컬 파일은 유지
        }
        
        DebugHelper.log('[_validateAllTexts] targetAudience 값 확인:');
        DebugHelper.log('  - type: ${targetAudience['type']}');
        DebugHelper.log('  - targetCount: ${targetAudience['targetCount']}');
        DebugHelper.log('  - isPremium: ${targetAudience['isPremium']}');
        
        // Firestore 저장 진행
        DebugHelper.log('[_validateAllTexts] _saveToFirestore 호출 시작');
        await _saveToFirestore(targetAudience, result.geminiResult);
        DebugHelper.log('[_validateAllTexts] _saveToFirestore 호출 완료');
      }

    } catch (e) {
      DebugHelper.logError('[_validateAllTexts] catch 블록 진입', e);
      // 에러 발생 시에도 정리
      await _cleanupUploadedImages();
      
      // AI 검증으로 인한 정상적인 차단은 에러로 처리하지 않음
      if (e.toString().contains('콘텐츠가 차단되었습니다') || 
          e.toString().contains('사용자가 수정을 선택했습니다')) {
        return;
      }
      
      // 실제 에러만 처리
      ErrorHandler.handle(
        e,
        type: ErrorType.validation,
        customMessage: '텍스트 검증 중 오류가 발생했습니다.',
        context: context,
      );
    } finally {
      DebugHelper.log('[_validateAllTexts] finally 블록 진입');
      setState(() {
        _model.isValidating = false;
        _model.validationMessage = null;
        _model.isShowingDialog = false;  // 에러 발생 시에도 초기화
      });
    }
  }


  /// Bot Toast로 메시지 표시
  void _showSnackBar(String message, {bool isError = false}) {
    if (isError) {
      ErrorHandler.handle(
        message,
        type: ErrorType.unknown,
        customMessage: message,
        context: context,
      );
    } else {
      ErrorHandler.showSuccessToast(message);
    }
  }
  

  /// 미디어 타입 선택 다이얼로그
  Future<void> _openAssetsPicker(BuildContext parentContext, String box, {bool isAddMode = false, int? currentIndex}) async {
    final appState = context.read<AppState>();
    
    // Navigator.push로 즉시 전환
    final result = await Navigator.push<Map<String, dynamic>>(
      parentContext,
      NoAnimationPageRoute(
        builder: (context) => MediaSelectionFlowWidget(
          box: box,
          model: _model,
          isAddMode: isAddMode,
          currentIndex: currentIndex,
          existingAssetIds: box == 'A' 
            ? appState.assetEntityIdsA
            : appState.assetEntityIdsB,
          existingImageUrls: box == 'A'
            ? appState.uploadImageA
            : appState.uploadImageB,
          existingAspectRatios: box == 'A'
            ? appState.uploadImageAspectRatioA
            : appState.uploadImageAspectRatioB,
          onComplete: (imageUrl) {
            // 검열 통과 후 호출됨
            DebugHelper.logModeration('검열 통과 및 업로드 완료: $imageUrl');
            // 레이아웃은 Consumer에서 자동으로 처리됨
          },
          onMultiComplete: (imageUrls) {
            // 검열 통과 후 호출됨
            DebugHelper.logModeration('검열 통과 및 업로드 완료: ${imageUrls.length}개');
            // 레이아웃은 Consumer에서 자동으로 처리됨
          },
        ),
      ),
    );
    
    // 이미지 처리 중인 경우 로딩 표시
    if (result != null && result['action'] == 'processing' && isAddMode) {
      final selectedAssets = result['selectedAssets'] as List<AssetEntity>?;
      if (selectedAssets != null) {
        // 로딩 토스트 표시
        final cancel = BotToast.showCustomLoading(
          toastBuilder: (_) => Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withValues(alpha: 0.7),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
          ),
          allowClick: false,
          clickClose: false,
        );
        
        // SelectionResultProcessor 직접 실행
        try {
          final processor = SelectionResultProcessor(
            context: context,
            appState: appState,
            box: box,
            existingAssetIds: box == 'A' 
              ? appState.assetEntityIdsA
              : appState.assetEntityIdsB,
            onProgressUpdate: (progress) {
              // 진행률 업데이트 (필요시 사용)
            },
            onMultiComplete: (imageUrls) {
              // 멀티 이미지 완료 처리
              DebugHelper.logModeration('검열 통과 및 업로드 완료: ${imageUrls.length}개');
              // 레이아웃은 Consumer에서 자동으로 처리됨
            },
            onProcessingComplete: () {
              // 처리 완료 시 로딩 토스트 제거
              cancel();
            },
          );
          
          await processor.processSelectionResult(selectedAssets);
        } catch (e) {
          cancel();
          _showSnackBar('이미지 처리 중 오류가 발생했습니다', isError: true);
        }
      }
    }
  }

  Future<void> _saveToFirestore(Map<String, dynamic> targetAudience, ai.GeminiModerationResult? geminiResult) async {
    DebugHelper.log('[_saveToFirestore] ========== 게시물 저장 시작 ==========');
    DebugHelper.log('[_saveToFirestore] targetAudience: $targetAudience');
    DebugHelper.log('[_saveToFirestore] 예상 투표 비율 - A: ${geminiResult?.expectedRatioA ?? 0.5}, B: ${geminiResult?.expectedRatioB ?? 0.5}');
    
    try {
      final user = currentUser;
      DebugHelper.log('[_saveToFirestore] 현재 사용자: ${user?.uid}');
      
      if (user == null) {
        DebugHelper.log('[_saveToFirestore] 사용자가 로그인되지 않음');
        _showSnackBar('로그인이 필요합니다.', isError: true);
        return;
      }

      setState(() {
        _model.isValidating = true;
      });

      final appState = context.read<AppState>();
      
      // 이미 업로드된 URL 사용 (중복 업로드 제거)
      final uploadedUrlsA = appState.uploadImageA;
      final uploadedUrlsB = appState.uploadImageB;
      
      DebugHelper.log('[_saveToFirestore] 업로드된 이미지 URL:');
      DebugHelper.log('  - A박스: ${uploadedUrlsA.length}개');
      DebugHelper.log('  - B박스: ${uploadedUrlsB.length}개');
      
      // 사용자 정보 가져오기
      DebugHelper.log('[_saveToFirestore] 사용자 정보 조회 중...');
      final userDoc = await UsersModel.getDocumentOnce(
        FirebaseFirestore.instance.collection('users').doc(user.uid)
      );

      // aspectRatio 계산
      final aspectRatioA = appState.uploadImageAspectRatioA.isNotEmpty 
          ? RatioCalculator.getRatio(appState.uploadImageAspectRatioA, box: 'A')
          : null;
      final aspectRatioB = (_model.absellected || appState.uploadImageAspectRatioB.isEmpty)
          ? null
          : RatioCalculator.getRatio(appState.uploadImageAspectRatioB, box: 'B');
      
      // layoutType 결정 - AspectRatioAnalyzer 사용
      String layoutType;
      if (_model.absellected || (appState.uploadImageB.isEmpty && appState.uploadTextB.isNotEmpty)) {
        layoutType = 'single';
      } else if (aspectRatioA != null || aspectRatioB != null) {
        // 이미지가 있으면 AspectRatioAnalyzer로 최적 레이아웃 결정
        final analyzedLayout = AspectRatioAnalyzer.getOptimalLayout(aspectRatioA, aspectRatioB);
        layoutType = analyzedLayout.name;
        DebugHelper.log('[_saveToFirestore] AspectRatioAnalyzer 사용:');
        DebugHelper.log('  - 분석 결과: ${analyzedLayout.name}');
        DebugHelper.log('  - UI 상태: ${_model.currentLayout.name}');
      } else {
        // 이미지가 없으면 UI 상태 사용
        layoutType = _model.currentLayout == LayoutType.horizontal ? 'horizontal' : 'vertical';
      }
          
      DebugHelper.log('[_saveToFirestore] AspectRatio 정보:');
      DebugHelper.log('  - A박스: $aspectRatioA');
      DebugHelper.log('  - B박스: $aspectRatioB');
      DebugHelper.log('  - 단일 이미지 모드: ${_model.absellected}');
      DebugHelper.log('  - 레이아웃 타입: $layoutType');
      
      // Posts 문서 생성
      final postsRecordData = {
        ...createPostsModelData(
          userid: user.uid,
          uid: user.uid,
          email: user.email,
          displayName: userDoc.displayName,
          photoUrl: userDoc.photoUrl,
          content: appState.questionDescription,
          questionTitle: appState.questionTitle,
          createdAt: DateTime.now(),
          createdTime: DateTime.now(),
          category: '', // 카테고리 선택 기능 추가 시 업데이트
          isAnonymous: false,
          visibility: 1, // 1: public
          commentcount: 0,
          likecount: 0,
          participantcount: 0,
          creatorInfo: {
            'uid': user.uid,
            'displayName': userDoc.displayName,
            'photoUrl': userDoc.photoUrl,
          },
          optionA: {
            'title': appState.uploadTextA,
            'mediaUrls': uploadedUrlsA,
            'mediaType': 'image',
            'aspectRatio': aspectRatioA,
          },
          optionB: {
            'title': appState.uploadTextB,
            'mediaUrls': uploadedUrlsB,
            'mediaType': 'image',
            'aspectRatio': aspectRatioB,
          },
          stats: {
            'voteCountA': 0,
            'voteCountB': 0,
            'totalVotes': 0,
          },
          moderation: {
            'status': 'approved',
            'aiScore': 0,
            'expected_ratio_a': geminiResult?.expectedRatioA ?? 0.5,
            'expected_ratio_b': geminiResult?.expectedRatioB ?? 0.5,
          },
          targetAudience: targetAudience,
        ),
        'description': appState.questionDescription,  // Firebase Functions를 위한 description 필드 추가
        'isNotificationEnabled': true,  // 알림 전송 활성화
        'layoutType': layoutType,  // 레이아웃 타입 저장
      };

      // Firestore에 저장
      DebugHelper.log('[_saveToFirestore] Firestore에 게시물 저장 시작...');
      final postRef = await PostsModel.collection.add(postsRecordData);
      DebugHelper.log('[_saveToFirestore] ✅ 게시물 저장 성공! ID: ${postRef.id}');
      
      // Firestore 일관성을 위한 지연 추가
      DebugHelper.log('[_saveToFirestore] Firestore 일관성을 위해 500ms 대기 중...');
      await Future.delayed(const Duration(milliseconds: 500));

      // PollDetails 서브컬렉션 생성
      DebugHelper.log('[_saveToFirestore] PollDetails 서브컬렉션 생성 중...');
      final pollDetailsData = createPollDetailsModelData(
        option1: appState.uploadTextA,
        option2: appState.uploadTextB,
        option1MediaUrl: uploadedUrlsA.isNotEmpty ? uploadedUrlsA.first : null,
        option2MediaUrl: uploadedUrlsB.isNotEmpty ? uploadedUrlsB.first : null,
        option1MediaType: 'image',
        option2MediaType: 'image',
        resultTime: 7, // 7일 후 결과 공개
      );

      await PollDetailsModel.createDoc(postRef).set(pollDetailsData);
      DebugHelper.log('[_saveToFirestore] ✅ PollDetails 저장 성공!');

      // 멀티이미지 데이터 검증
      DebugHelper.log('[_saveToFirestore] 멀티이미지 데이터 검증:');
      DebugHelper.log('  - uploadedUrlsA: ${uploadedUrlsA.length}개');
      DebugHelper.log('  - uploadedUrlsB: ${uploadedUrlsB.length}개');
      DebugHelper.log('  - imageUrlsA: $uploadedUrlsA');
      DebugHelper.log('  - imageUrlsB: $uploadedUrlsB');

      // 성공 시 전체 정리 (이미지는 삭제하지 않음 - 게시물에서 사용 중)
      DebugHelper.log('[_saveToFirestore] 전체 데이터 정리 중... (이미지는 유지)');
      await _cleanupAllData(deleteImages: false);
      DebugHelper.log('[_saveToFirestore] ✅ 데이터 정리 완료');

      // 검증 세션 초기화 (새로운 게시물 작성을 위해)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = DateTime.now().microsecondsSinceEpoch.toString().substring(10);
      _model.validationSessionId = '${timestamp}_$random';
      _model.validationDocumentId = null;
      _model.validationRevisionCount = 0;
      DebugHelper.log('[_saveToFirestore] 검증 세션 초기화 완료 - 새 세션 ID: ${_model.validationSessionId}');

      setState(() {
        _model.isValidating = false;
      });

      // 성공 메시지 표시
      DebugHelper.log('[_saveToFirestore] 성공 메시지 표시');
      _showSnackBar('게시물이 성공적으로 저장되었습니다!');
      
      DebugHelper.log('[_saveToFirestore] ========== 게시물 저장 완료 ==========');
      
      // 텍스트 필드 초기화
      _model.textController1?.clear();
      _model.textController2?.clear();
      _model.textController3?.clear();
      _model.textController4?.clear();
      
      // 스크롤을 맨 위로
      _model.scrollController?.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

    } catch (e) {
      ErrorHandler.handle(
        e,
        type: ErrorType.storage,
        customMessage: '저장 중 오류가 발생했습니다.',
        context: context,
      );
      setState(() {
        _model.isValidating = false;
      });
    }
  }


  /// 흔들림 애니메이션 실행
  void _triggerShakeAnimation() {
    _model.shakeController?.forward().then((_) {
      _model.shakeController?.reverse();
    });
  }

  /// 미디어 선택 섹션 빌드
  Widget _buildMediaSection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, Dimensions.defaultPadding, 0.0, 0.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
            ),
            child: _buildMediaBoxes(),
          ),
        ),
        _buildWarningMessage(),
      ],
    );
  }

  /// B박스 경고 표시 (흔들림 애니메이션만 실행)
  void _showBBoxWarning() {
    _triggerShakeAnimation();
  }

  /// 박스 크기 계산
  (Size, Size) _calculateBoxSizes(double? aspectRatioA, double? aspectRatioB, AppState appState) {
    // A 박스만 선택된 경우 (absellected가 true일 때만)
    if (_model.absellected) {
      DebugHelper.logLayout('[Debug] ========== 단일 이미지 모드 크기 계산 ==========');
      DebugHelper.logLayout('[Debug] aspectRatioA: $aspectRatioA');
      DebugHelper.logLayout('[Debug] 이미지 있음: ${appState.tempImageFilesA.isNotEmpty}');
      
      final sizes = UnifiedBoxCalculator.calculateForQuestion(
        containerWidth: MediaQuery.of(context).size.width,
        layoutType: LayoutType.single,
        aspectRatioA: aspectRatioA,
        hasImageA: true,
        hasImageB: false,
      );
      final size = sizes.sizeA;
      
      DebugHelper.logLayout('[Debug] 계산된 박스 크기: ${size.width} x ${size.height}');
      DebugHelper.logLayout('[Debug] ========== 계산 완료 ==========');
      return (size, size);
    }
    
    // 스마트 레이아웃 적용 (B박스가 비어있어도 레이아웃 계산)
    final sizes = UnifiedBoxCalculator.calculateForQuestion(
      containerWidth: MediaQuery.of(context).size.width,
      layoutType: _model.currentLayout,
      aspectRatioA: (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) ? null : aspectRatioA,
      aspectRatioB: (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) ? null : aspectRatioB,
      hasImageA: appState.tempImageFilesA.isNotEmpty,
      hasImageB: !_model.absellected, // B박스가 표시되면 항상 true로 설정하여 두 박스 모드로 계산
    );
    final unifiedSize = Size(sizes.boxWidth, sizes.unifiedHeight);
    
    return (unifiedSize, unifiedSize);
  }


  /// 박스 탭 처리
  Future<void> _handleBoxTap(String box) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (box == 'B' && appState.tempImageFilesA.isEmpty) {
      _showBBoxWarning();
    } else {
      final imageFiles = box == 'A' ? appState.tempImageFilesA : appState.tempImageFilesB;
      final imageUrls = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
      
      if (imageFiles.isEmpty && imageUrls.isEmpty) {
        await _openAssetsPicker(context, box);
      } else if (imageFiles.isNotEmpty) {
        // File 기반 이미지 뷰어로 이동
        final imagePaths = imageFiles.map((file) => file.path).toList();
        context.pushNamed(
          ImageViewerPage.routeName,
          queryParameters: {
            'imagePaths': imagePaths.join('|'), // 구분자로 | 사용
            'initialIndex': box == 'A' 
              ? _model.currentImageIndexA.toString() 
              : _model.currentImageIndexB.toString(),
            'box': box,
          },
        );
      } else {
        // URL 기반 이미지 뷰어로 이동
        context.pushNamed(
          ImageViewerPage.routeName,
          queryParameters: {
            'imageUrls': imageUrls.join(','),
            'initialIndex': box == 'A' 
              ? _model.currentImageIndexA.toString() 
              : _model.currentImageIndexB.toString(),
            'box': box,
          },
        );
      }
    }
  }

  /// 이미지 편집 처리
  Future<void> _handleImageEdit(String box) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final imageFiles = box == 'A' ? appState.tempImageFilesA : appState.tempImageFilesB;
    final imageUrls = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
    
    if (imageFiles.isEmpty && imageUrls.isEmpty) return;
    
    final currentIndex = (imageFiles.isNotEmpty ? imageFiles.length : imageUrls.length) == 1 
      ? 0 
      : (box == 'A' ? _model.currentImageIndexA : _model.currentImageIndexB);
    
    // File 기반 편집
    if (imageFiles.isNotEmpty) {
      await Navigator.push(
        context,
        NoAnimationPageRoute(
          builder: (context) => MediaSelectionFlowWidget(
            box: box,
            model: _model,
            initialImageFile: imageFiles[currentIndex],
            startWithEditor: true,
            currentIndex: currentIndex,
            existingImageFiles: imageFiles.length > 1 ? imageFiles : null,
            existingAspectRatios: imageFiles.length > 1 
              ? (box == 'A' ? appState.uploadImageAspectRatioA : appState.uploadImageAspectRatioB)
              : null,
            existingAssetIds: imageFiles.length > 1
              ? (box == 'A' ? appState.assetEntityIdsA : appState.assetEntityIdsB)
              : null,
            onComplete: (newImageUrl) {
              // File 기반에서는 onFileComplete를 사용해야 함
              _showSnackBar('이미지가 수정되었습니다.');
              // 레이아웃은 Consumer에서 자동으로 처리됨
            },
            onFileComplete: (newImageFile) {
              // 편집된 파일로 교체 - 인덱스 범위 검증
              if ((box == 'A' && currentIndex < appState.tempImageFilesA.length) ||
                  (box == 'B' && currentIndex < appState.tempImageFilesB.length)) {
                appState.update(() {
                  if (box == 'A') {
                    appState.tempImageFilesA[currentIndex] = newImageFile;
                  } else {
                    appState.tempImageFilesB[currentIndex] = newImageFile;
                  }
                });
                _showSnackBar('이미지가 수정되었습니다.');
                // 레이아웃은 Consumer에서 자동으로 처리됨
              }
            },
          ),
        ),
      );
    } else {
      // URL 기반 편집 (하위 호환성)
      await Navigator.push(
        context,
        NoAnimationPageRoute(
          builder: (context) => MediaSelectionFlowWidget(
            box: box,
            model: _model,
            initialImageUrl: imageUrls[currentIndex],
            startWithEditor: true,
            existingImageUrls: imageUrls.length > 1 ? imageUrls : null,
            existingAspectRatios: imageUrls.length > 1 
              ? (box == 'A' ? appState.uploadImageAspectRatioA : appState.uploadImageAspectRatioB)
              : null,
            onComplete: (newImageUrl) {
              appState.update(() {
                if (box == 'A') {
                  appState.uploadImageA[currentIndex] = newImageUrl;
                } else {
                  appState.uploadImageB[currentIndex] = newImageUrl;
                }
              });
              _showSnackBar('이미지가 수정되었습니다.');
              // 레이아웃은 Consumer에서 자동으로 처리됨
            },
          ),
        ),
      );
    }
  }

  /// Consumer 위젯 통합 - 미디어 박스 빌드
  Widget _buildMediaBoxes() {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        // 이미지 수 변경 감지
        final currentImageCount = appState.tempImageFilesA.length + appState.tempImageFilesB.length;
        
        // 이미지 수가 변경되었을 때만 레이아웃 업데이트
        if (_lastImageCount != currentImageCount) {
          _lastImageCount = currentImageCount;
          // debounced update 호출
          _updateLayoutBasedOnImages();
        }
        
        // 현재 레이아웃에 따른 비율 계산 (매 빌드마다 계산하지 않음)
        // 이미지가 있으면 레이아웃 타입과 무관하게 항상 비율 계산
        final currentAspectRatioA = appState.tempImageFilesA.isNotEmpty && 
            appState.uploadImageAspectRatioA.isNotEmpty 
                ? RatioCalculator.getRatio(appState.uploadImageAspectRatioA, box: 'A')
                : null;
        // absellected가 true이면 B박스의 비율은 계산하지 않음
        final currentAspectRatioB = !_model.absellected &&
            appState.tempImageFilesB.isNotEmpty && 
            appState.uploadImageAspectRatioB.isNotEmpty 
                ? RatioCalculator.getRatio(appState.uploadImageAspectRatioB, box: 'B')
                : null;
        
        DebugHelper.logLayout('[Debug] Consumer에서 aspectRatio 계산:');
        DebugHelper.logLayout('  - currentAspectRatioA: $currentAspectRatioA');
        DebugHelper.logLayout('  - currentAspectRatioB: $currentAspectRatioB');
        DebugHelper.logLayout('  - absellected: ${_model.absellected}');
        DebugHelper.logLayout('  - currentLayout: ${_model.currentLayout}');
        
        final boxSizes = _calculateBoxSizes(currentAspectRatioA, currentAspectRatioB, appState);
        
        return _buildMediaLayoutContent(
          isAbsellected: _model.absellected,
          boxSizeA: boxSizes.$1,
          boxSizeB: boxSizes.$2,
          appState: appState,
        );
      },
    );
  }

  /// Consumer 위젯 통합 - 경고 메시지
  Widget _buildWarningMessage() {
    return Consumer<AppState>(
      builder: (context, appState, _) {
        if (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isNotEmpty) {
          return WarningMessage(message: 'A 먼저 이미지를 추가해주세요');
        }
        return SizedBox.shrink();
      },
    );
  }

  /// 공통 TextStyle 생성 헬퍼 메서드
  TextStyle _getTextStyle({
    required TextStyle baseStyle,
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
  }) => baseStyle.override(
    font: GoogleFonts.plusJakartaSans(
      fontWeight: fontWeight ?? baseStyle.fontWeight,
      fontStyle: baseStyle.fontStyle,
    ),
    fontSize: fontSize,
    letterSpacing: letterSpacing ?? 0.0,
    fontWeight: fontWeight ?? baseStyle.fontWeight,
    fontStyle: baseStyle.fontStyle,
    color: color,
  );

  /// A/B 타이틀 필드를 생성하는 공통 메서드
  Widget _buildTitleField({
    required TextEditingController? controller,
    required FocusNode? focusNode,
    required String labelKey,
    required String hintKey,
    required String fieldName,
    required bool isEmpty,
    required bool hasBlockedWord,
    required Function(String value, String fieldName, bool isBlocked) onFieldChanged,
    required VoidCallback onFieldCleared,
  }) {
    return Align(
      alignment: AlignmentDirectional(-1.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(20.0, 2.0, 20.0, 0.0),
        child: Container(
          width: 400.0,
          child: SimpleValidatedField(
            controller: controller,
            focusNode: focusNode,
            labelKey: labelKey,
            hintKey: hintKey,
            fieldName: fieldName,
            validationResult: _model.validationResults[fieldName],
            onFieldChanged: onFieldChanged,
            onFieldCleared: onFieldCleared,
            onRequiredFieldsCheck: _checkRequiredFieldsAndUpdateButton,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // 리스너와 타이머 먼저 정리
    _model.scrollController?.removeListener(_scrollListener);
    _layoutUpdateTimer?.cancel();
    
    // 페이지 나갈 때 업로드된 이미지 정리
    // Future.microtask를 사용하여 dispose 완료 후 실행
    if (_appState != null) {
      final appStateCopy = _appState;
      // dispose 후에도 안전하게 실행되도록 Future로 예약
      Future.microtask(() async {
        try {
          if (appStateCopy != null) {
            await _cleanupUploadedImagesWithAppState(appStateCopy);
          }
        } catch (e) {
          DebugHelper.error('dispose 후 이미지 정리 중 에러', error: e);
        }
      });
    }
    
    _model.dispose();
    super.dispose();
  }

  /// 레이아웃에 따른 미디어 선택 박스 배치를 생성하는 메서드
  Widget _buildMediaLayoutContent({
    required bool isAbsellected,
    required Size boxSizeA,
    required Size boxSizeB,
    required AppState appState,
  }) {
    // A박스 위젯 생성 (공통)
    final aBoxWidget = _buildMediaSelectionBox(
      box: 'A',
      width: boxSizeA.width,
      height: boxSizeA.height,
      isSelected: isAbsellected,
      isVideoSelected: _model.isVideoSelectedA,
      imageUrls: [],  // File 기반으로 변경, URL은 사용하지 않음
      showPlusIcon: isAbsellected,  // B박스가 숨겨진 상태일 때 + 아이콘 표시
      isHorizontal: _model.isRatioVertical,
      boxColor: AppTheme.of(context).primary,
      appState: appState,
      shakeAnimation: null,
    );

    // B박스 위젯 생성 (공통)
    final bBoxWidget = _buildMediaSelectionBox(
      box: 'B',
      width: boxSizeB.width,
      height: boxSizeB.height,
      isSelected: false,
      isVideoSelected: _model.isVideoSelectedB,
      imageUrls: [],  // File 기반으로 변경, URL은 사용하지 않음
      showPlusIcon: false,
      isHorizontal: _model.isRatioVertical,
      boxColor: AppTheme.of(context).secondary,
      appState: appState,
      shakeAnimation: _model.shakeAnimation,
    );

    if (_model.isRatioVertical) {
      // 가로 배치 (좌/우)
      if (isAbsellected) {
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(Dimensions.smallPadding * 2, 0.0, Dimensions.smallPadding * 2, 0.0),
          child: Center(
            child: SizedBox(
              width: boxSizeA.width,
              height: boxSizeA.height,
              child: aBoxWidget,
            ),
          ),
        );
      } else {
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(Dimensions.smallPadding * 2, 0.0, Dimensions.smallPadding * 2, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SizedBox(
                  height: boxSizeA.height,
                  child: aBoxWidget,
                ),
              ),
              SizedBox(width: Dimensions.smallPadding * 2),
              Expanded(
                child: SizedBox(
                  height: boxSizeB.height,
                  child: bBoxWidget,
                ),
              ),
            ],
          ),
        );
      }
    } else if (_model.isRatioHorizontal) {
      // 세로 배치 (위/아래)
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(Dimensions.smallPadding, 0.0, Dimensions.smallPadding, Dimensions.smallPadding),
            child: SizedBox(
              width: boxSizeA.width,
              height: boxSizeA.height,
              child: aBoxWidget,
            ),
          ),
          if (!isAbsellected)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(Dimensions.smallPadding, Dimensions.smallPadding, Dimensions.smallPadding, 0.0),
              child: SizedBox(
                width: boxSizeB.width,
                height: boxSizeB.height,
                child: bBoxWidget,
              ),
            ),
        ],
      );
    }
    
    return Container(); // 안전장치
  }

  /// MediaSelectionBoxMulti 위젯을 생성하는 헬퍼 메서드
  Widget _buildMediaSelectionBox({
    required String box,
    required double width,
    required double height,
    required bool isSelected,
    required bool isVideoSelected,
    required List<String> imageUrls,
    required bool showPlusIcon,
    required bool isHorizontal,
    required Color boxColor,
    required AppState appState,
    Animation<double>? shakeAnimation,
  }) {
    // 디버그 로그 추가
    if (_model.absellected && box == 'A') {
      DebugHelper.logLayout('[Debug] 단일 이미지 모드 - MediaSelectionBox 높이: $height');
    }
    
    final callbacks = MediaBoxCallbacks(
      context: context,
      model: _model,
      showBBoxWarning: _showBBoxWarning,
      openAssetsPicker: _openAssetsPicker,
      showSnackBar: () => _showSnackBar('이미지가 수정되었습니다.'),
      updateLayout: () {}, // 레이아웃은 Consumer에서 자동 처리
      setState: setState,
    );
    
    return MediaSelectionBoxMulti(
      label: box,
      isSelected: isSelected,
      isVideoSelected: isVideoSelected,
      imageUrls: imageUrls,
      imageFiles: box == 'A' ? appState.tempImageFilesA : appState.tempImageFilesB,
      showPlusIcon: showPlusIcon,
      dynamicHeight: height,
      dynamicWidth: width,
      shakeAnimation: shakeAnimation,
      isHorizontal: isHorizontal,
      boxColor: boxColor,
      onTap: () => _handleBoxTap(box),
      onCancel: (index) => setState(() => callbacks.deleteImage(box, index)),
      onPlusIconTap: () => setState(() => callbacks.toggleBoxVisibility()),
      onEditTap: () => _handleImageEdit(box),
      onAddImageTap: () => callbacks.handleAddImage(box, box == 'A' ? _model.currentImageIndexA : _model.currentImageIndexB),
      onCurrentIndexChanged: (index) => setState(() => callbacks.updateCurrentIndex(box, index)),
    );
  }

  /// AppState를 인자로 받는 정리 메서드 (dispose에서 사용)
  Future<void> _cleanupUploadedImagesWithAppState(AppState appState) async {
    // 디버그 로그 추가
    DebugHelper.log('[_cleanupUploadedImagesWithAppState] 시작');
    DebugHelper.log('[_cleanupUploadedImagesWithAppState] uploadImageA: ${appState.uploadImageA.length}개');
    DebugHelper.log('[_cleanupUploadedImagesWithAppState] uploadImageB: ${appState.uploadImageB.length}개');
    
    // Firebase Storage에서 업로드된 이미지 삭제
    final urlsToDelete = [
      ...appState.uploadImageA,
      ...appState.uploadImageB,
    ];
    
    if (urlsToDelete.isNotEmpty) {
      try {
        DebugHelper.log('Firebase Storage에서 이미지 삭제 시작: ${urlsToDelete.length}개');
        
        // URL 로깅
        for (int i = 0; i < urlsToDelete.length; i++) {
          DebugHelper.log('[삭제할 URL ${i+1}] ${urlsToDelete[i]}');
        }
        
        final results = await StorageService.deleteMultipleImages(urlsToDelete);
        
        // 삭제 결과 로깅
        int successCount = 0;
        results.forEach((url, success) {
          if (success) {
            successCount++;
            DebugHelper.log('[삭제 성공] $url');
          } else {
            DebugHelper.logError('이미지 삭제 실패', url);
          }
        });
        
        DebugHelper.log('이미지 삭제 완료: 성공 $successCount/${urlsToDelete.length}개');
      } catch (e) {
        DebugHelper.logError('이미지 삭제 중 오류', e);
      }
    } else {
      DebugHelper.log('[_cleanupUploadedImagesWithAppState] 삭제할 이미지가 없습니다');
    }
    
    // AppState 정리 - setState 없이 직접 수정
    // 이미 dispose 후이므로 update() 메서드는 setState를 호출하지 않음
    try {
      // 직접 clear하여 setState 호출 방지
      appState.uploadImageA.clear();
      appState.uploadImageB.clear();
      // update 메서드 호출 제거하여 setState 방지
    } catch (e) {
      // 이미 dispose된 경우 무시
      DebugHelper.log('[_cleanupUploadedImagesWithAppState] AppState 정리 스킵 (already disposed)');
    }
    
    DebugHelper.log('[_cleanupUploadedImagesWithAppState] 완료');
  }

  /// Firebase Storage에서 업로드된 이미지만 삭제 (로컬 파일은 유지)
  Future<void> _cleanupUploadedImages() async {
    if (!mounted) return;
    final appState = context.read<AppState>();
    
    // 디버그 로그 추가
    DebugHelper.log('[_cleanupUploadedImages] 시작');
    DebugHelper.log('[_cleanupUploadedImages] uploadImageA: ${appState.uploadImageA.length}개');
    DebugHelper.log('[_cleanupUploadedImages] uploadImageB: ${appState.uploadImageB.length}개');
    
    // Firebase Storage에서 업로드된 이미지 삭제
    final urlsToDelete = [
      ...appState.uploadImageA,
      ...appState.uploadImageB,
    ];
    
    if (urlsToDelete.isNotEmpty) {
      try {
        DebugHelper.log('Firebase Storage에서 이미지 삭제 시작: ${urlsToDelete.length}개');
        
        // URL 로깅
        for (int i = 0; i < urlsToDelete.length; i++) {
          DebugHelper.log('[삭제할 URL ${i+1}] ${urlsToDelete[i]}');
        }
        
        final results = await StorageService.deleteMultipleImages(urlsToDelete);
        
        // 삭제 결과 로깅
        int successCount = 0;
        results.forEach((url, success) {
          if (success) {
            successCount++;
            DebugHelper.log('[삭제 성공] $url');
          } else {
            DebugHelper.logError('이미지 삭제 실패', url);
          }
        });
        
        DebugHelper.log('이미지 삭제 완료: 성공 $successCount/${urlsToDelete.length}개');
      } catch (e) {
        DebugHelper.logError('이미지 삭제 중 오류', e);
      }
    } else {
      DebugHelper.log('[_cleanupUploadedImages] 삭제할 이미지가 없습니다');
    }
    
    // AppState 정리 (URL만, 로컬 파일은 유지)
    appState.update(() {
      appState.uploadImageA.clear();
      appState.uploadImageB.clear();
    });
    
    DebugHelper.log('[_cleanupUploadedImages] 완료');
  }

  /// 모든 임시 데이터 정리 (페이지 나갈 때 또는 성공 후)
  /// @param deleteImages - true면 Firebase Storage의 이미지도 삭제, false면 AppState만 정리
  Future<void> _cleanupAllData({bool deleteImages = true}) async {
    // deleteImages가 true일 때만 업로드된 이미지 정리
    if (deleteImages) {
      await _cleanupUploadedImages();
    }
    
    final appState = context.read<AppState>();
    
    // AppState의 모든 데이터 정리
    appState.update(() {
      // Firebase URLs 정리 (게시물 저장 성공 시에도 필요)
      appState.uploadImageA.clear();
      appState.uploadImageB.clear();
      
      // 로컬 파일도 정리
      appState.tempImageFilesA.clear();
      appState.tempImageFilesB.clear();
      appState.assetEntityIdsA.clear();
      appState.assetEntityIdsB.clear();
      appState.uploadImageAspectRatioA.clear();
      appState.uploadImageAspectRatioB.clear();
      
      // 텍스트 정리
      appState.uploadTextA = '';
      appState.uploadTextB = '';
      appState.questionTitle = '';
      appState.questionDescription = '';
    });
    
    // Vision 데이터 정리
    _model.visionResultA = null;
    _model.visionResultB = null;
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0.0),
          child: AppBar(
            backgroundColor: AppTheme.of(context).primary,
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context).getText(
                'w04dob8j' /* Page Title */,
              ),
              style: _getTextStyle(
                baseStyle: AppTheme.of(context).headlineMedium,
                color: Colors.white,
                fontSize: Dimensions.appBarFontSize,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: Dimensions.appBarElevation,
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            color: AppTheme.of(context).secondaryBackground,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _model.scrollController,
                primary: false,
                child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            // 질문 제목 섹션
                            _buildQuestionTitleSection(),
                            // 미디어 선택 섹션
                            _buildMediaSection(),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 3.0, 10.0, 0.0),
                              child: SimpleValidatedField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                labelKey: '94dz6d39',
                                hintKey: 'gipyr3sq',
                                fieldName: FieldStyles.description,
                                validationResult: _model.validationResults[FieldStyles.description],
                                onFieldChanged: (value, fieldName, isBlocked) {
                                  _model.hasBlockedWordInDescription = isBlocked;
                                  setState(() {});
                                },
                                onFieldCleared: () {
                                  _model.validationResults.remove(FieldStyles.description);
                                  _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                  _model.hasBlockedWordInDescription = false;
                                  setState(() {});
                                },
                              ),
                            ),
                            // Description 글자 수 및 경고 표시
                            CharacterCountDisplay(
                              controller: _model.textController2,
                              maxLength: 200,
                              isEmpty: false,  // Description은 필수 필드가 아님
                              hasBlockedWord: _model.hasBlockedWordInDescription,
                              validationResult: _model.validationResults[FieldStyles.description],
                              horizontalPadding: 22.0, // 10 + 12
                              hasValidated: _model.hasValidated,
                            ),
                            _buildTitleField(
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              labelKey: 'jvx92fb4',
                              hintKey: 'tkzl6wqo',
                              fieldName: FieldStyles.textA,
                              isEmpty: _model.isATitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInATitle,
                              onFieldChanged: (value, fieldName, isBlocked) {
                                _model.hasBlockedWordInATitle = isBlocked;
                                _model.isATitleEmpty = value.trim().isEmpty;
                                setState(() {});
                              },
                              onFieldCleared: () {
                                _model.isATitleEmpty = true;
                                _model.validationResults.remove(FieldStyles.textA);
                                _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                _model.hasBlockedWordInATitle = false;
                                setState(() {});
                              },
                            ),
                            // A title 글자 수 및 경고 표시
                            CharacterCountDisplay(
                              controller: _model.textController3,
                              maxLength: 20,
                              isEmpty: _model.isATitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInATitle,
                              validationResult: _model.validationResults[FieldStyles.textA],
                              horizontalPadding: 32.0, // 20 + 12
                              hasValidated: _model.hasValidated,
                            ),
                            _buildTitleField(
                              controller: _model.textController4,
                              focusNode: _model.textFieldFocusNode4,
                              labelKey: 't8flxbe7',
                              hintKey: 'gwsufdly',
                              fieldName: FieldStyles.textB,
                              isEmpty: _model.isBTitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInBTitle,
                              onFieldChanged: (value, fieldName, isBlocked) {
                                _model.hasBlockedWordInBTitle = isBlocked;
                                _model.isBTitleEmpty = value.trim().isEmpty;
                                setState(() {});
                              },
                              onFieldCleared: () {
                                _model.isBTitleEmpty = true;
                                _model.validationResults.remove(FieldStyles.textB);
                                _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                _model.hasBlockedWordInBTitle = false;
                                setState(() {});
                              },
                            ),
                            // B title 글자 수 및 경고 표시
                            CharacterCountDisplay(
                              controller: _model.textController4,
                              maxLength: 20,
                              isEmpty: _model.isBTitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInBTitle,
                              validationResult: _model.validationResults[FieldStyles.textB],
                              blockedMessage: '⚠️ 부적절한 언어가 포함됨',
                              horizontalPadding: 32.0, // 20 + 12
                              hasValidated: _model.hasValidated,
                            ),
                            // 스크롤 감지를 위한 최소 여백
                            SizedBox(height: 100.0),
                          ],
                        ),
              ),
              // 검증 중 메시지 오버레이
              if (_model.isValidating && _model.validationMessage != null && !_model.isShowingDialog)
                Positioned(
                  bottom: 100,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _model.validationMessage!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Next button overlay
              NextButton(
                showButton: _model.showNextButton && !_model.isValidating && !_model.isShowingDialog,
                onPressed: () async {
                  DebugHelper.log('[NextButton] 다음 버튼 클릭');
                  await _validateAllTexts();
                  DebugHelper.log('[NextButton] _validateAllTexts 완료');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

