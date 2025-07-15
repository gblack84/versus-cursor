// upload_choice_bottom_sheet_widget.dart 임시 제거 - 새로운 업로드 위젯 구현 필요
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/utils/content_filter.dart';
import '/pages/image_viewer/image_viewer_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import 'utils/no_animation_page_route.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'in_put_post_image_model.dart';
export 'in_put_post_image_model.dart';
import 'helpers/aspect_ratio_analyzer.dart';
import 'helpers/dynamic_box_calculator.dart';
import 'helpers/media_box_callbacks.dart';
import 'helpers/ratio_calculator.dart';
import 'components/media_selection_box_multi.dart';
import 'components/character_count_display.dart';
import 'components/next_button.dart';
import 'components/simple_validated_field.dart';
import 'components/simple_character_count.dart';
import 'components/layout_debug_info.dart';
import 'components/warning_message.dart';
import 'services/validation_service.dart';
import 'helpers/input_field_builder.dart';
import 'widgets/media_selection_flow_widget.dart';
import 'widgets/dialogs/target_audience_dialog.dart';
import 'utils/debug_helper.dart';
import 'utils/error_handler.dart';
import 'constants/dimensions.dart';
import 'constants/animation_constants.dart';
import 'constants/field_styles.dart';
import 'services/media_upload_service.dart';

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

  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Consumer 최적화를 위한 이전 상태 추적
  int _lastImageCount = 0;
  double? _lastAspectRatioA;
  double? _lastAspectRatioB;
  


  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InPutPostImageModel());

    // 콘텐츠 필터 초기화
    ContentFilter.initialize();

    _model.scrollController ??= ScrollController();
    _model.scrollController!.addListener(_scrollListener);
    
    // 초기 레이아웃 설정 - 비율 정보가 있을 때만
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      // 초기 상태 설정
      _lastImageCount = appState.tempImageFilesA.length + appState.tempImageFilesB.length;
      _lastAspectRatioA = appState.uploadImageAspectRatioA.isNotEmpty ? appState.uploadImageAspectRatioA.first : null;
      _lastAspectRatioB = appState.uploadImageAspectRatioB.isNotEmpty ? appState.uploadImageAspectRatioB.first : null;
      
      if (_lastAspectRatioA != null || _lastAspectRatioB != null) {
        _updateLayoutBasedOnImages();
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

  /// 이미지 비율에 따라 레이아웃 자동 결정
  void _updateLayoutBasedOnImages() {
    // mounted 체크 추가
    if (!mounted) return;
    
    final appState = Provider.of<AppState>(context, listen: false);
    
    DebugHelper.runInDebug(() {
      DebugHelper.logLayout('=== 스마트 레이아웃 업데이트 시작 ===');
      DebugHelper.logLayout('A 이미지 개수: ${appState.tempImageFilesA.length}');
      DebugHelper.logLayout('B 이미지 개수: ${appState.tempImageFilesB.length}');
      DebugHelper.logLayout('A 비율 정보 개수: ${appState.uploadImageAspectRatioA.length}');
      DebugHelper.logLayout('B 비율 정보 개수: ${appState.uploadImageAspectRatioB.length}');
    });
    
    // 이미지가 하나도 없으면 기본 레이아웃(horizontal)으로 초기화
    if (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) {
      DebugHelper.logLayout('이미지가 없어 기본 레이아웃(horizontal)으로 초기화');
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
      ratioA = RatioCalculator.getRatio(appState.uploadImageAspectRatioA);
      DebugHelper.logLayout('A 이미지 비율: $ratioA');
    }
    
    if (appState.uploadImageAspectRatioB.isNotEmpty) {
      // 기존 로직 (첫 번째 이미지만 사용)
      // ratioB = appState.uploadImageAspectRatioB.first;
      
      // 새로운 로직 (하이브리드 계산)
      ratioB = RatioCalculator.getRatio(appState.uploadImageAspectRatioB);
      DebugHelper.logLayout('B 이미지 비율: $ratioB');
    }
    
    // 스마트 레이아웃 결정 - A박스만 있어도 레이아웃 계산
    LayoutType optimalLayout;
    if (ratioA != null && ratioB == null && appState.tempImageFilesB.isEmpty) {
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
      DebugHelper.logLayout('A박스만 있음 - 이미지 방향: $orientation');
    } else {
      // 일반적인 경우 (A/B 둘 다 있거나 B만 있는 경우)
      optimalLayout = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);
    }
    
    DebugHelper.logLayout('결정된 레이아웃: ${AspectRatioAnalyzer.getLayoutDescription(optimalLayout)}');
    
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
            DebugHelper.logLayout('세로 배치(위/아래)로 변경');
          } else {
            // 가로 배치 = 이미지가 좌/우로 배치
            _model.isRatioVertical = true;
            _model.isRatioHorizontal = false;
            DebugHelper.logLayout('가로 배치(좌/우)로 변경');
          }
        });
      }
    } else {
      DebugHelper.logLayout('레이아웃 변경 없음');
    }
    
    DebugHelper.logLayout('=== 스마트 레이아웃 업데이트 완료 ===');
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
      });

      // ValidationService를 사용하여 검증
      final result = await ValidationService.validateAllTexts(
        questionTitle: _model.textController1?.text,
        description: _model.textController2?.text,
        aTitle: _model.textController3?.text,
        bTitle: _model.textController4?.text,
      );

      // 상태 변경이 필요한지 확인
      final needsUpdate = 
          _model.isQuestionTitleEmpty != result.emptyResult.isQuestionTitleEmpty ||
          _model.isATitleEmpty != result.emptyResult.isATitleEmpty ||
          _model.isBTitleEmpty != result.emptyResult.isBTitleEmpty ||
          _model.validationResults != result.validationResults ||
          _model.hasValidationViolations != (!result.isValid && result.violations.isNotEmpty);
      
      if (needsUpdate) {
        setState(() {
          // 빈 필드 상태 업데이트
          _model.isQuestionTitleEmpty = result.emptyResult.isQuestionTitleEmpty;
          _model.isATitleEmpty = result.emptyResult.isATitleEmpty;
          _model.isBTitleEmpty = result.emptyResult.isBTitleEmpty;

          // 검증 결과 업데이트
          _model.validationResults = result.validationResults;
          _model.hasValidationViolations = !result.isValid && result.violations.isNotEmpty;
          
          // 검증 통과 시 비어있음 에러 상태 초기화
          if (result.isValid) {
            _model.isQuestionTitleEmpty = false;
            _model.isATitleEmpty = false;
            _model.isBTitleEmpty = false;
          }
        });
      }

      if (result.errorMessage != null) {
        _showSnackBar(result.errorMessage!);
      } else if (!result.isValid && result.violations.isNotEmpty) {
        ValidationService.showViolationDialog(context, result.violations);
      } else if (result.isValid) {
        // 검증 완료 - AppState에 텍스트 저장
        context.read<AppState>().update(() {
          final appState = context.read<AppState>();
          appState.uploadTextA = _model.textController3?.text ?? '';
          appState.uploadTextB = _model.textController4?.text ?? '';
          appState.questionTitle = _model.textController1?.text ?? '';
          appState.questionDescription = _model.textController2?.text ?? '';
          appState.isVerticalLayout = _model.isRatioVertical;
        });
        
        // 타겟 오디언스 다이얼로그 표시
        final targetAudience = await TargetAudienceDialog.show(context);
        
        if (targetAudience != null) {
          // 타겟 설정이 완료되면 Firestore에 저장
          await _saveToFirestore(targetAudience);
        }
      }

    } catch (e) {
      ErrorHandler.handle(
        e,
        type: ErrorType.validation,
        customMessage: '텍스트 검증 중 오류가 발생했습니다.',
        context: context,
      );
    } finally {
      setState(() {
        _model.isValidating = false;
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
    await Navigator.push(
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
            
            // 스마트 레이아웃 업데이트 (단일 이미지도 처리)
            _updateLayoutBasedOnImages();
          },
          onMultiComplete: (imageUrls) {
            // 검열 통과 후 호출됨
            DebugHelper.logModeration('검열 통과 및 업로드 완료: ${imageUrls.length}개');
            
            // 스마트 레이아웃 업데이트
            _updateLayoutBasedOnImages();
          },
        ),
      ),
    );
  }

  Future<void> _saveToFirestore(Map<String, dynamic> targetAudience) async {
    try {
      final user = currentUser;
      if (user == null) {
        _showSnackBar('로그인이 필요합니다.', isError: true);
        return;
      }

      setState(() {
        _model.isValidating = true;
      });

      final appState = context.read<AppState>();
      
      // 임시 파일들을 Firebase Storage에 업로드
      List<String> uploadedUrlsA = [];
      List<String> uploadedUrlsB = [];
      
      if (appState.tempImageFilesA.isNotEmpty) {
        DebugHelper.log('A박스 이미지 업로드 중: ${appState.tempImageFilesA.length}개');
        uploadedUrlsA = await MediaUploadService.uploadTempFiles(
          files: appState.tempImageFilesA,
          box: 'A',
        );
      }
      
      if (appState.tempImageFilesB.isNotEmpty) {
        DebugHelper.log('B박스 이미지 업로드 중: ${appState.tempImageFilesB.length}개');
        uploadedUrlsB = await MediaUploadService.uploadTempFiles(
          files: appState.tempImageFilesB,
          box: 'B',
        );
      }
      
      // 사용자 정보 가져오기
      final userDoc = await UsersRecord.getDocumentOnce(
        FirebaseFirestore.instance.collection('users').doc(user.uid)
      );

      // Posts 문서 생성
      final postsRecordData = createPostsRecordData(
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
        },
        optionB: {
          'title': appState.uploadTextB,
          'mediaUrls': uploadedUrlsB,
          'mediaType': 'image',
        },
        stats: {
          'voteCountA': 0,
          'voteCountB': 0,
          'totalVotes': 0,
        },
        moderation: {
          'status': 'approved',
          'aiScore': 0,
        },
        targetAudience: targetAudience,
      );

      // Firestore에 저장
      final postRef = await PostsRecord.collection.add(postsRecordData);

      // PollDetails 서브컬렉션 생성
      final pollDetailsData = createPollDetailsRecordData(
        option1: appState.uploadTextA,
        option2: appState.uploadTextB,
        option1MediaUrl: uploadedUrlsA.isNotEmpty ? uploadedUrlsA.first : null,
        option2MediaUrl: uploadedUrlsB.isNotEmpty ? uploadedUrlsB.first : null,
        option1MediaType: 'image',
        option2MediaType: 'image',
        resultTime: 7, // 7일 후 결과 공개
      );

      await PollDetailsRecord.createDoc(postRef).set(pollDetailsData);

      // AppState 초기화
      appState.update(() {
        appState.uploadTextA = '';
        appState.uploadTextB = '';
        appState.uploadImageA = [];
        appState.uploadImageB = [];
        appState.clearTempImageFilesA();
        appState.clearTempImageFilesB();
        appState.uploadImageAspectRatioA = [];
        appState.uploadImageAspectRatioB = [];
        appState.assetEntityIdsA = [];
        appState.assetEntityIdsB = [];
        appState.questionTitle = '';
        appState.questionDescription = '';
      });

      setState(() {
        _model.isValidating = false;
      });

      // 성공 메시지 표시
      _showSnackBar('게시물이 성공적으로 저장되었습니다!');
      
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
      final size = DynamicBoxCalculator.getBoxSize(
        context: context,
        layoutType: LayoutType.single,
        box: 'A',
        aspectRatio: aspectRatioA,
        hasOtherBox: false,
      );
      
      DebugHelper.runInDebug(() {
        DebugHelper.logLayout('A박스만 선택됨 - 크기: ${size.height}px');
      });
      
      return (size, size);
    }
    
    // 스마트 레이아웃 적용 (B박스가 비어있어도 레이아웃 계산)
    final unifiedSize = DynamicBoxCalculator.getUnifiedSize(
      context: context,
      layoutType: _model.currentLayout,
      aspectRatioA: (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) ? null : aspectRatioA,
      aspectRatioB: (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) ? null : aspectRatioB,
    );
    
    DebugHelper.runInDebug(() {
      if (appState.tempImageFilesA.isEmpty && appState.tempImageFilesB.isEmpty) {
        DebugHelper.logLayout('대기 상태 박스 크기: ${unifiedSize.height}px, 레이아웃: ${_model.currentLayout}');
      } else {
        DebugHelper.logLayout('스마트 레이아웃 박스 크기: ${unifiedSize.height}px, 레이아웃: ${_model.currentLayout}');
      }
    });
    
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
              if (imageFiles.length > 1) _updateLayoutBasedOnImages();
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
                if (imageFiles.length > 1) _updateLayoutBasedOnImages();
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
              if (imageUrls.length > 1) _updateLayoutBasedOnImages();
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
        // 이미지 수와 비율 변경 감지
        final currentImageCount = appState.tempImageFilesA.length + appState.tempImageFilesB.length;
        final currentAspectRatioA = appState.tempImageFilesA.isNotEmpty && appState.uploadImageAspectRatioA.isNotEmpty 
            ? RatioCalculator.getRatio(appState.uploadImageAspectRatioA)  // 하이브리드 계산 사용
            : null;
        final currentAspectRatioB = appState.tempImageFilesB.isNotEmpty && appState.uploadImageAspectRatioB.isNotEmpty 
            ? RatioCalculator.getRatio(appState.uploadImageAspectRatioB)  // 하이브리드 계산 사용
            : null;
        
        // 상태가 변경되었을 때만 레이아웃 업데이트
        if (_lastImageCount != currentImageCount || 
            _lastAspectRatioA != currentAspectRatioA || 
            _lastAspectRatioB != currentAspectRatioB) {
          _lastImageCount = currentImageCount;
          _lastAspectRatioA = currentAspectRatioA;
          _lastAspectRatioB = currentAspectRatioB;
          
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _updateLayoutBasedOnImages();
            }
          });
        }
        
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
    _model.scrollController?.removeListener(_scrollListener);
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
      showPlusIcon: isAbsellected,
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
    final callbacks = MediaBoxCallbacks(
      context: context,
      model: _model,
      showBBoxWarning: _showBBoxWarning,
      openAssetsPicker: _openAssetsPicker,
      showSnackBar: () => _showSnackBar('이미지가 수정되었습니다.'),
      updateLayout: _updateLayoutBasedOnImages,
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
              // Next button overlay
              NextButton(
                showButton: _model.showNextButton,
                isValidating: _model.isValidating,
                onPressed: () async {
                  await _validateAllTexts();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

