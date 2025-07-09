// upload_choice_bottom_sheet_widget.dart 임시 제거 - 새로운 업로드 위젯 구현 필요
import '/core/app_theme.dart';
import '/core/app_utils.dart';
import '/utils/content_filter.dart';
import '/widgets/highlighted_text_field.dart';
import '/pages/image_viewer/image_viewer_page.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import 'in_put_post_image_model.dart';
export 'in_put_post_image_model.dart';
import 'helpers/aspect_ratio_analyzer.dart';
import 'helpers/dynamic_box_calculator.dart';
import 'helpers/media_box_callbacks.dart';
import 'components/media_selection_box_multi.dart';
import 'components/character_count_display.dart';
import 'components/next_button.dart';
import 'components/simple_validated_field.dart';
import 'components/simple_character_count.dart';
import 'components/layout_debug_info.dart';
import 'components/warning_message.dart';
import 'services/validation_service.dart';
import 'widgets/media_selection_flow_widget.dart';

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
  
  // Consumer 최적화를 위한 이전 이미지 수 추적
  int _lastImageCount = 0;

  // 상수 정의
  static const Duration _shakeAnimationDuration = Duration(milliseconds: 200);
  
  static const double _defaultPadding = 10.0;
  static const double _smallPadding = 2.5;
  static const double _largeFontSize = 30.0;
  static const double _scrollThreshold = 100.0;
  static const double _iconSize = 22.0;
  static const double _appBarFontSize = 22.0;
  static const double _appBarElevation = 2.0;
  static const double _verticalSpacing = 15.0;
  static const double _inputFontSize = 30.0;

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
      // 초기 이미지 수 설정
      _lastImageCount = appState.uploadImageA.length + appState.uploadImageB.length;
      
      if (appState.uploadImageAspectRatioA.isNotEmpty || 
          appState.uploadImageAspectRatioB.isNotEmpty) {
        _updateLayoutBasedOnImages();
      }
    });

    _initializeControllers();
    
    // 흔들림 애니메이션 초기화
    _model.shakeController = AnimationController(
      duration: _shakeAnimationDuration,
      vsync: this,
    );
    
    _model.shakeAnimation = Tween<double>(
      begin: 0,
      end: 8,
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
    final isNearBottom = _model.scrollController!.position.pixels >=
        _model.scrollController!.position.maxScrollExtent - _scrollThreshold;
    
    if (isNearBottom != _model.showNextButton) {
      setState(() {
        _model.showNextButton = isNearBottom;
      });
    }
  }

  /// 이미지 비율에 따라 레이아웃 자동 결정
  void _updateLayoutBasedOnImages() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (!kReleaseMode) {
      print('=== 스마트 레이아웃 업데이트 시작 ===');
      print('A 이미지 개수: ${appState.uploadImageA.length}');
      print('B 이미지 개수: ${appState.uploadImageB.length}');
      print('A 비율 정보 개수: ${appState.uploadImageAspectRatioA.length}');
      print('B 비율 정보 개수: ${appState.uploadImageAspectRatioB.length}');
    }
    
    // 이미지가 하나도 없으면 기본 레이아웃(horizontal)으로 초기화
    if (appState.uploadImageA.isEmpty && appState.uploadImageB.isEmpty) {
      if (!kReleaseMode) print('이미지가 없어 기본 레이아웃(horizontal)으로 초기화');
      if (_model.currentLayout != LayoutType.horizontal) {
        setState(() {
          _model.currentLayout = LayoutType.horizontal;
          _model.isRatioVertical = true;  // 가로 배치(좌/우)
          _model.isRatioHorizontal = false;
        });
      }
      return;
    }
    
    // A박스와 B박스의 첫 번째 이미지 비율 가져오기
    double? ratioA;
    double? ratioB;
    
    if (appState.uploadImageAspectRatioA.isNotEmpty) {
      ratioA = appState.uploadImageAspectRatioA.first;
      if (!kReleaseMode) print('A 이미지 비율: $ratioA');
    }
    
    if (appState.uploadImageAspectRatioB.isNotEmpty) {
      ratioB = appState.uploadImageAspectRatioB.first;
      if (!kReleaseMode) print('B 이미지 비율: $ratioB');
    }
    
    // 스마트 레이아웃 결정
    final optimalLayout = AspectRatioAnalyzer.getOptimalLayout(ratioA, ratioB);
    if (!kReleaseMode) print('결정된 레이아웃: ${AspectRatioAnalyzer.getLayoutDescription(optimalLayout)}');
    
    // 레이아웃이 변경된 경우에만 업데이트
    if (_model.currentLayout != optimalLayout) {
      setState(() {
        _model.currentLayout = optimalLayout;
        
        // 기존 토글 상태도 함께 업데이트 (호환성)
        // 주의: isRatioVertical이 true면 UI에서 가로 배치(좌/우)를 표시
        // isRatioHorizontal이 true면 UI에서 세로 배치(위/아래)를 표시
        if (optimalLayout == LayoutType.vertical) {
          // 세로 배치 = 이미지가 위/아래로 배치
          _model.isRatioVertical = false;
          _model.isRatioHorizontal = true;
          if (!kReleaseMode) print('세로 배치(위/아래)로 변경');
        } else {
          // 가로 배치 = 이미지가 좌/우로 배치
          _model.isRatioVertical = true;
          _model.isRatioHorizontal = false;
          if (!kReleaseMode) print('가로 배치(좌/우)로 변경');
        }
      });
    } else {
      if (!kReleaseMode) print('레이아웃 변경 없음');
    }
    
    if (!kReleaseMode) print('=== 스마트 레이아웃 업데이트 완료 ===');
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
              _defaultPadding, _verticalSpacing, _defaultPadding, 0.0),
          child: ValidatedTextField(
            controller: _model.textController1,
            focusNode: _model.textFieldFocusNode1,
            onChanged: (value) {
              // 텍스트가 비어있으면 에러 초기화
              if (value.trim().isEmpty) {
                if (_model.isQuestionTitleEmpty || 
                    _model.validationResults.containsKey('questionTitle') || 
                    _model.hasBlockedWordInTitle) {
                  setState(() {
                    _model.isQuestionTitleEmpty = false;
                    _model.validationResults.remove('questionTitle');
                    _model.hasBlockedWordInTitle = false;
                  });
                }
              }
              
              // 필수 필드 체크
              _checkRequiredFieldsAndUpdateButton();
              
              // 디바운스된 필터링
              EasyDebounce.debounce(
                '_model.textController1',
                Duration(milliseconds: 500),
                () {
                  final result = ContentFilter.filterText(value);
                  if (_model.hasBlockedWordInTitle != result.isBlocked) {
                    setState(() {
                      _model.hasBlockedWordInTitle = result.isBlocked;
                    });
                  }
                },
              );
            },
            validationResult: _model.validationResults['questionTitle'],
            showValidationResults: false,
            decoration: _getInputDecoration(
              context: context,
              hintText: AppLocalizations.of(context).getText(
                'jr6l0zdb' /* Enter question title */,
              ),
              labelText: AppLocalizations.of(context).getText(
                '5kzcbgop' /* Question Title */,
              ),
              fontSize: _largeFontSize,
              suffixIcon: _model.textController1!.text.isNotEmpty
                  ? InkWell(
                      onTap: () async {
                        _model.textController1?.clear();
                        _model.validationResults.remove('questionTitle');
                        _model.hasValidationViolations = false;
                        _model.hasBlockedWordInTitle = false;
                      },
                      child: Icon(
                        Icons.clear,
                        color: AppTheme.of(context).primaryText,
                        size: _iconSize,
                      ),
                    )
                  : null,
            ),
            style: _getTextStyle(
              baseStyle: AppTheme.of(context).bodyMedium,
              fontSize: _inputFontSize,
            ),
            minLines: 1,
            maxLines: 5,
            textInputAction: TextInputAction.done,
            maxLength: 60,
          ),
        ),
        CharacterCountDisplay(
          controller: _model.textController1,
          maxLength: 60,
          isEmpty: _model.isQuestionTitleEmpty,
          hasBlockedWord: _model.hasBlockedWordInTitle,
          validationResult: _model.validationResults['questionTitle'],
        ),
        LayoutDebugInfo(currentLayout: _model.currentLayout),
      ],
    );
  }

  /// 필수 필드 체크 및 버튼 표시 업데이트
  void _checkRequiredFieldsAndUpdateButton() {
    if (_areRequiredFieldsFilled() && !_model.showNextButton) {
      setState(() {
        _model.showNextButton = true;
      });
    }
  }

  /// 모든 텍스트 필드 검증
  Future<void> _validateAllTexts() async {
    try {
      // 로딩 상태 표시
      setState(() {
        _model.isValidating = true;
      });

      // ValidationService를 사용하여 검증
      final result = await ValidationService.validateAllTexts(
        questionTitle: _model.textController1?.text,
        description: _model.textController2?.text,
        aTitle: _model.textController3?.text,
        bTitle: _model.textController4?.text,
      );

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
        
        // Firestore에 저장
        await _saveToFirestore();
      }

    } catch (e) {
      if (!kReleaseMode) print('텍스트 검증 오류: $e');
      _showSnackBar('텍스트 검증 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _model.isValidating = false;
      });
    }
  }


  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  /// 미디어 타입 선택 다이얼로그
  Future<void> _openAssetsPicker(BuildContext parentContext, String box, {bool isAddMode = false, int? currentIndex}) async {
    final appState = context.read<AppState>();
    
    // 통합 플로우 모달로 열기
    await showModalBottomSheet(
      context: parentContext,
      isScrollControlled: true,
      useSafeArea: true,  // SafeArea 적용
      backgroundColor: Colors.black,  // 검은색 배경
      barrierColor: Colors.black87,  // 배리어도 검은색
      builder: (modalContext) => MediaSelectionFlowWidget(
        box: box,
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
          // 백그라운드 업로드 완료 시 호출되지만, 이미 로컬 이미지로 처리했으므로 추가 작업 불필요
          if (!kReleaseMode) print('백그라운드 업로드 완료: $imageUrl');
          
          // 스마트 레이아웃 업데이트 (단일 이미지도 처리)
          _updateLayoutBasedOnImages();
        },
        onMultiComplete: (imageUrls) {
          // 백그라운드 업로드 완료 시 호출되지만, 이미 로컬 이미지로 처리했으므로 추가 작업 불형요
          if (!kReleaseMode) print('백그라운드 업로드 완료: ${imageUrls.length}개');
          
          // 스마트 레이아웃 업데이트
          _updateLayoutBasedOnImages();
          
          // 성공 메시지는 로컬 저장 시점에 이미 표시됨
        },
      ),
    );
  }

  Future<void> _saveToFirestore() async {
    try {
      final user = currentUser;
      if (user == null) {
        _showSnackBar('로그인이 필요합니다.');
        return;
      }

      setState(() {
        _model.isValidating = true;
      });

      final appState = context.read<AppState>();
      
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
          'mediaUrls': appState.uploadImageA,
          'mediaType': 'image',
        },
        optionB: {
          'title': appState.uploadTextB,
          'mediaUrls': appState.uploadImageB,
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
      );

      // Firestore에 저장
      final postRef = await PostsRecord.collection.add(postsRecordData);

      // PollDetails 서브컬렉션 생성
      final pollDetailsData = createPollDetailsRecordData(
        option1: appState.uploadTextA,
        option2: appState.uploadTextB,
        option1MediaUrl: appState.uploadImageA.isNotEmpty ? appState.uploadImageA.first : null,
        option2MediaUrl: appState.uploadImageB.isNotEmpty ? appState.uploadImageB.first : null,
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
      if (!kReleaseMode) print('Firestore 저장 오류: $e');
      _showSnackBar('저장 중 오류가 발생했습니다: ${e.toString()}');
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
          padding: EdgeInsetsDirectional.fromSTEB(0.0, _defaultPadding, 0.0, 0.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
            ),
            child: Consumer<AppState>(
              builder: (context, appState, child) {
                final aspectRatioA = appState.uploadImageA.isNotEmpty && appState.uploadImageAspectRatioA.isNotEmpty 
                    ? appState.uploadImageAspectRatioA.first 
                    : null;
                final aspectRatioB = appState.uploadImageB.isNotEmpty && appState.uploadImageAspectRatioB.isNotEmpty 
                    ? appState.uploadImageAspectRatioB.first 
                    : null;
                
                final boxSizes = _calculateBoxSizes(aspectRatioA, aspectRatioB, appState);
                
                return _buildMediaLayoutContent(
                  isAbsellected: _model.absellected,
                  boxSizeA: boxSizes.$1,
                  boxSizeB: boxSizes.$2,
                  appState: appState,
                );
              },
            ),
          ),
        ),
        Consumer<AppState>(
          builder: (context, appState, _) {
            if (appState.uploadImageA.isEmpty && appState.uploadImageB.isNotEmpty) {
              return WarningMessage(message: 'A 먼저 이미지를 추가해주세요');
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  /// B박스 경고 표시 (흔들림 애니메이션만 실행)
  void _showBBoxWarning() {
    _triggerShakeAnimation();
  }

  /// 박스 크기 계산
  (Size, Size) _calculateBoxSizes(double? aspectRatioA, double? aspectRatioB, AppState appState) {
    if (_model.absellected) {
      final size = DynamicBoxCalculator.getBoxSize(
        context: context,
        layoutType: _model.currentLayout,
        box: 'A',
        aspectRatio: aspectRatioA,
        hasOtherBox: false,
      );
      return (size, size);
    }
    
    final unifiedSize = DynamicBoxCalculator.getUnifiedSize(
      context: context,
      layoutType: _model.currentLayout,
      aspectRatioA: (appState.uploadImageA.isEmpty && appState.uploadImageB.isEmpty) ? null : aspectRatioA,
      aspectRatioB: (appState.uploadImageA.isEmpty && appState.uploadImageB.isEmpty) ? null : aspectRatioB,
    );
    
    if (!kReleaseMode && appState.uploadImageA.isEmpty && appState.uploadImageB.isEmpty) {
      print('대기 상태 박스 크기: ${unifiedSize.height}px, 레이아웃: ${_model.currentLayout}');
    } else if (!kReleaseMode) {
      print('이미지 있는 상태 박스 크기: ${unifiedSize.height}px');
    }
    
    return (unifiedSize, unifiedSize);
  }


  /// 박스 탭 처리
  Future<void> _handleBoxTap(String box) async {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (box == 'B' && appState.uploadImageA.isEmpty) {
      _showBBoxWarning();
    } else {
      final images = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
      if (images.isEmpty) {
        await _openAssetsPicker(context, box);
      } else {
        context.pushNamed(
          ImageViewerPage.routeName,
          queryParameters: {
            'imageUrls': images.join(','),
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
    final images = box == 'A' ? appState.uploadImageA : appState.uploadImageB;
    
    if (images.isEmpty) return;
    
    final currentIndex = images.length == 1 
      ? 0 
      : (box == 'A' ? _model.currentImageIndexA : _model.currentImageIndexB);
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MediaSelectionFlowWidget(
        box: box,
        initialImageUrl: images[currentIndex],
        startWithEditor: true,
        existingImageUrls: images.length > 1 ? images : null,
        existingAspectRatios: images.length > 1 
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
          if (images.length > 1) _updateLayoutBasedOnImages();
        },
      ),
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

  /// 공통 InputDecoration 생성 헬퍼 메서드
  InputDecoration _getInputDecoration({
    required BuildContext context,
    required String hintText,
    required double fontSize,
    String? labelText,
    Widget? suffixIcon,
    double borderWidth = 3.0,
    bool isDense = false,
  }) {
    final border = UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.black, width: borderWidth),
      borderRadius: BorderRadius.circular(12.0),
    );
    return InputDecoration(
      isDense: isDense,
      labelText: labelText,
      labelStyle: _getTextStyle(baseStyle: AppTheme.of(context).bodyMedium, fontSize: fontSize),
      alignLabelWithHint: false,
      hintText: hintText,
      hintStyle: _getTextStyle(baseStyle: AppTheme.of(context).labelMedium, fontSize: fontSize),
      enabledBorder: border,
      focusedBorder: border,
      errorBorder: border,
      focusedErrorBorder: border,
      filled: true,
      fillColor: AppTheme.of(context).secondaryBackground,
      suffixIcon: suffixIcon,
    );
  }

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
            maxLength: 20,
            maxLines: 5,
            minLines: 1,
            fontSize: 14.0,
            borderWidth: 2.0,
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
      imageUrls: appState.uploadImageA,
      showPlusIcon: isAbsellected,
      isHorizontal: _model.isRatioVertical,
      boxColor: AppTheme.of(context).primary,
      shakeAnimation: null,
    );

    // B박스 위젯 생성 (공통)
    final bBoxWidget = _buildMediaSelectionBox(
      box: 'B',
      width: boxSizeB.width,
      height: boxSizeB.height,
      isSelected: false,
      isVideoSelected: _model.isVideoSelectedB,
      imageUrls: appState.uploadImageB,
      showPlusIcon: false,
      isHorizontal: _model.isRatioVertical,
      boxColor: AppTheme.of(context).secondary,
      shakeAnimation: _model.shakeAnimation,
    );

    if (_model.isRatioVertical) {
      // 가로 배치 (좌/우)
      if (isAbsellected) {
        return Padding(
          padding: EdgeInsetsDirectional.fromSTEB(_smallPadding * 2, 0.0, _smallPadding * 2, 0.0),
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
          padding: EdgeInsetsDirectional.fromSTEB(_smallPadding * 2, 0.0, _smallPadding * 2, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: SizedBox(
                  height: boxSizeA.height,
                  child: aBoxWidget,
                ),
              ),
              SizedBox(width: _smallPadding * 2),
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
            padding: EdgeInsetsDirectional.fromSTEB(_smallPadding, 0.0, _smallPadding, _smallPadding),
            child: SizedBox(
              width: boxSizeA.width,
              height: boxSizeA.height,
              child: aBoxWidget,
            ),
          ),
          if (!isAbsellected)
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(_smallPadding, _smallPadding, _smallPadding, 0.0),
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
    Animation<double>? shakeAnimation,
  }) {
    final callbacks = MediaBoxCallbacks(
      context: context,
      model: _model,
      showBBoxWarning: _showBBoxWarning,
      openAssetsPicker: _openAssetsPicker,
      showSnackBar: () => _showSnackBar('이미지가 수정되었습니다.'),
      updateLayout: _updateLayoutBasedOnImages,
    );
    
    return MediaSelectionBoxMulti(
      label: box,
      isSelected: isSelected,
      isVideoSelected: isVideoSelected,
      imageUrls: imageUrls,
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
                fontSize: _appBarFontSize,
              ),
            ),
            actions: [],
            centerTitle: false,
            elevation: _appBarElevation,
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
              // AppState의 이미지 리스트 변경 감지
              Consumer<AppState>(
                builder: (context, appState, _) {
                  // 현재 전체 이미지 수 계산
                  final currentImageCount = appState.uploadImageA.length + appState.uploadImageB.length;
                  
                  // 이미지 수가 실제로 변경되었을 때만 레이아웃 업데이트
                  if (_lastImageCount != currentImageCount) {
                    _lastImageCount = currentImageCount;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        _updateLayoutBasedOnImages();
                      }
                    });
                  }
                  
                  return SizedBox.shrink(); // 보이지 않는 위젯
                },
              ),
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
                                fieldName: 'description',
                                maxLength: 200,
                                maxLines: 5,
                                minLines: 1,
                                fontSize: 30.0,
                                borderWidth: 2.0,
                                isDense: false,
                                validationResult: _model.validationResults['description'],
                                onFieldChanged: (value, fieldName, isBlocked) {
                                  // ContentFilter is handled in SimpleValidatedField
                                },
                                onFieldCleared: () {
                                  _model.validationResults.remove('description');
                                  _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                  setState(() {});
                                },
                              ),
                            ),
                            // Description 글자 수 표시
                            SimpleCharacterCount(
                              controller: _model.textController2,
                              maxLength: 200,
                            ),
                            _buildTitleField(
                              controller: _model.textController3,
                              focusNode: _model.textFieldFocusNode3,
                              labelKey: 'jvx92fb4',
                              hintKey: 'tkzl6wqo',
                              fieldName: 'aTitle',
                              isEmpty: _model.isATitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInATitle,
                              onFieldChanged: (value, fieldName, isBlocked) {
                                _model.hasBlockedWordInATitle = isBlocked;
                                setState(() {});
                              },
                              onFieldCleared: () {
                                _model.isATitleEmpty = false;
                                _model.validationResults.remove('aTitle');
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
                              validationResult: _model.validationResults['aTitle'],
                            ),
                            _buildTitleField(
                              controller: _model.textController4,
                              focusNode: _model.textFieldFocusNode4,
                              labelKey: 't8flxbe7',
                              hintKey: 'gwsufdly',
                              fieldName: 'bTitle',
                              isEmpty: _model.isBTitleEmpty,
                              hasBlockedWord: _model.hasBlockedWordInBTitle,
                              onFieldChanged: (value, fieldName, isBlocked) {
                                _model.hasBlockedWordInBTitle = isBlocked;
                                setState(() {});
                              },
                              onFieldCleared: () {
                                _model.isBTitleEmpty = false;
                                _model.validationResults.remove('bTitle');
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
                              validationResult: _model.validationResults['bTitle'],
                              blockedMessage: '⚠️ 부적절한 언어가 포함됨',
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

