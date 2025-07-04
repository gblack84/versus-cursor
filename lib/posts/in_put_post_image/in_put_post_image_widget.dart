// upload_choice_bottom_sheet_widget.dart 임시 제거 - 새로운 업로드 위젯 구현 필요
import '/core/app_theme.dart';
import '/core/app_toggle_icon.dart';
import '/core/app_utils.dart';
import '/utils/content_filter.dart';
import '/services/perspective_api_service.dart';
import '/widgets/highlighted_text_field.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'in_put_post_image_model.dart';
export 'in_put_post_image_model.dart';

class InPutPostImageWidget extends StatefulWidget {
  const InPutPostImageWidget({super.key});

  static String routeName = 'InPutPostImage';
  static String routePath = '/inPutPostImage';

  @override
  State<InPutPostImageWidget> createState() => _InPutPostImageWidgetState();
}

class _InPutPostImageWidgetState extends State<InPutPostImageWidget> {
  late InPutPostImageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InPutPostImageModel());

    // 콘텐츠 필터 초기화
    ContentFilter.initialize();

    _model.scrollController ??= ScrollController();
    _model.scrollController!.addListener(_scrollListener);

    _model.textController1 ??= TextEditingController();
    _model.textFieldFocusNode1 ??= FocusNode();

    _model.textController2 ??= TextEditingController();
    _model.textFieldFocusNode2 ??= FocusNode();

    _model.textController3 ??= TextEditingController();
    _model.textFieldFocusNode3 ??= FocusNode();

    _model.textController4 ??= TextEditingController();
    _model.textFieldFocusNode4 ??= FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
  }

  void _scrollListener() {
    if (_model.scrollController!.position.pixels >=
        _model.scrollController!.position.maxScrollExtent - 100) {
      if (!_model.showNextButton) {
        setState(() {
          _model.showNextButton = true;
        });
      }
    } else {
      if (_model.showNextButton) {
        setState(() {
          _model.showNextButton = false;
        });
      }
    }
  }

  /// 필수 필드가 모두 채워졌는지 확인
  bool _areRequiredFieldsFilled() {
    return (_model.textController1?.text.trim().isNotEmpty ?? false) && // Question Title
           (_model.textController3?.text.trim().isNotEmpty ?? false) && // A title
           (_model.textController4?.text.trim().isNotEmpty ?? false);   // B title
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

      // 필수 필드 체크
      bool hasEmptyField = false;
      
      setState(() {
        _model.isQuestionTitleEmpty = _model.textController1?.text.trim().isEmpty ?? true;
        _model.isATitleEmpty = _model.textController3?.text.trim().isEmpty ?? true;
        _model.isBTitleEmpty = _model.textController4?.text.trim().isEmpty ?? true;
        
        hasEmptyField = _model.isQuestionTitleEmpty || _model.isATitleEmpty || _model.isBTitleEmpty;
      });
      
      if (hasEmptyField) {
        setState(() {
          _model.isValidating = false;
        });
        return;
      }

      // 모든 텍스트 필드 내용 수집
      final textsToValidate = <String, String>{};
      
      if (_model.textController1?.text.isNotEmpty == true) {
        textsToValidate['questionTitle'] = _model.textController1!.text;
      }
      if (_model.textController2?.text.isNotEmpty == true) {
        textsToValidate['description'] = _model.textController2!.text;
      }
      if (_model.textController3?.text.isNotEmpty == true) {
        textsToValidate['aTitle'] = _model.textController3!.text;
      }
      if (_model.textController4?.text.isNotEmpty == true) {
        textsToValidate['bTitle'] = _model.textController4!.text;
      }

      if (textsToValidate.isEmpty) {
        _showSnackBar('입력된 텍스트가 없습니다.');
        return;
      }

      // Perspective API로 검증
      final results = await PerspectiveApiService.analyzeMultipleTexts(textsToValidate);
      
      // 검증 결과 처리
      bool hasViolations = false;
      List<String> violations = [];

      results.forEach((fieldName, result) {
        if (result.isToxic) {
          hasViolations = true;
          String fieldDisplayName = _getFieldDisplayName(fieldName);
          String categoryName = _getTopCategoryName(result);
          violations.add('$fieldDisplayName: $categoryName');
        }
      });

      setState(() {
        _model.validationResults = results;
        _model.hasValidationViolations = hasViolations;
        // 검증 통과 시 비어있음 에러 상태 초기화
        if (!hasViolations) {
          _model.isQuestionTitleEmpty = false;
          _model.isATitleEmpty = false;
          _model.isBTitleEmpty = false;
        }
      });

      if (hasViolations) {
        _showViolationDialog(violations);
      } else {
        // 검증 완료 - AppState에 텍스트 저장
        context.read<AppState>().update(() {
          final appState = context.read<AppState>();
          appState.uploadTextA = _model.textController3?.text ?? '';
          appState.uploadTextB = _model.textController4?.text ?? '';
          appState.questionTitle = _model.textController1?.text ?? '';
          appState.questionDescription = _model.textController2?.text ?? '';
          appState.isVerticalLayout = _model.isRatioVertical;
        });
        
        // 미디어 선택 기능 임시 비활성화
        _showSnackBar('미디어 업로드 기능을 새로 구현해야 합니다.');
      }

    } catch (e) {
      print('텍스트 검증 오류: $e');
      _showSnackBar('텍스트 검증 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _model.isValidating = false;
      });
    }
  }

  /// 필드명을 사용자 친화적 이름으로 변환
  String _getFieldDisplayName(String fieldName) {
    switch (fieldName) {
      case 'questionTitle':
        return 'Question Title';
      case 'description':
        return 'Description';
      case 'aTitle':
        return 'A title';
      case 'bTitle':
        return 'B title';
      default:
        return fieldName;
    }
  }

  /// 가장 높은 점수의 카테고리명 반환
  String _getTopCategoryName(PerspectiveResult result) {
    String topCategory = '';
    double maxScore = 0.0;
    
    result.allScores.forEach((category, score) {
      if (score > maxScore) {
        maxScore = score;
        topCategory = category;
      }
    });
    
    switch (topCategory) {
      case 'PROFANITY':
        return '욕설 감지';
      case 'THREAT':
        return '위협적 표현';
      case 'INSULT':
        return '모욕적 표현';
      case 'TOXICITY':
        return '독성 콘텐츠';
      default:
        return '부적절한 내용';
    }
  }

  /// 위반 사항 다이얼로그 표시
  void _showViolationDialog(List<String> violations) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('부적절한 내용 감지'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('다음 항목에서 부적절한 내용이 감지되었습니다:'),
              SizedBox(height: 10),
              ...violations.map((violation) => Padding(
                padding: EdgeInsets.symmetric(vertical: 2),
                child: Text('• $violation', style: TextStyle(color: Colors.red)),
              )),
              SizedBox(height: 10),
              Text('내용을 수정한 후 다시 시도해주세요.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _model.dispose();

    super.dispose();
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
              style: AppTheme.of(context).headlineMedium.override(
                    font: GoogleFonts.plusJakartaSans(
                      fontWeight: AppTheme.of(context)
                          .headlineMedium
                          .fontWeight,
                      fontStyle:
                          AppTheme.of(context).headlineMedium.fontStyle,
                    ),
                    color: Colors.white,
                    fontSize: 22.0,
                    letterSpacing: 0.0,
                    fontWeight:
                        AppTheme.of(context).headlineMedium.fontWeight,
                    fontStyle:
                        AppTheme.of(context).headlineMedium.fontStyle,
                  ),
            ),
            actions: [],
            centerTitle: false,
            elevation: 2.0,
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
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.of(context)
                                    .secondaryBackground,
                                shape: BoxShape.rectangle,
                              ),
                            ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 15.0, 10.0, 0.0),
                              child: ValidatedTextField(
                                controller: _model.textController1,
                                focusNode: _model.textFieldFocusNode1,
                                onChanged: (value) {
                                  // 실시간 글자 수 업데이트
                                  setState(() {
                                    // 텍스트가 비어있으면 에러 초기화
                                    if (value.trim().isEmpty) {
                                      _model.isQuestionTitleEmpty = false;
                                      _model.validationResults.remove('questionTitle');
                                      _model.hasBlockedWordInTitle = false;
                                    }
                                  });
                                  
                                  // 필수 필드 체크
                                  _checkRequiredFieldsAndUpdateButton();
                                  
                                  // 디바운스된 필터링
                                  EasyDebounce.debounce(
                                    '_model.textController1',
                                    Duration(milliseconds: 500),
                                    () {
                                      final result = ContentFilter.filterText(value);
                                      _model.hasBlockedWordInTitle = result.isBlocked;
                                      setState(() {});
                                    },
                                  );
                                },
                                validationResult: _model.validationResults['questionTitle'],
                                showValidationResults: false, // 에러는 필드 외부에서 표시
                                decoration: InputDecoration(
                                  isDense: false,
                                  labelText:
                                      AppLocalizations.of(context).getText(
                                    '5kzcbgop' /* Question Title */,
                                  ),
                                  labelStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 30.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  alignLabelWithHint: false,
                                  hintText: AppLocalizations.of(context).getText(
                                    'jr6l0zdb' /* Enter question title */,
                                  ),
                                  hintStyle: AppTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 30.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 3.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.of(context)
                                      .secondaryBackground,
                                  suffixIcon: _model
                                          .textController1!.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () async {
                                            _model.textController1?.clear();
                                            // 검증 결과도 초기화
                                            _model.validationResults.remove('questionTitle');
                                            _model.hasValidationViolations = false;
                                            _model.hasBlockedWordInTitle = false;
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            size: 22,
                                          ),
                                        )
                                      : null,
                                ),
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 30.0,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                                minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.done,
                                maxLength: 60,
                              ),
                            ),
                            // Question Title 글자 수 및 경고 표시
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.5, 10.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 왼쪽: 경고 메시지
                                  if (_model.hasBlockedWordInTitle || _model.isQuestionTitleEmpty || _model.validationResults['questionTitle']?.isToxic == true)
                                    Text(
                                      _model.isQuestionTitleEmpty 
                                        ? '필수 항목입니다'
                                        : _model.validationResults['questionTitle']?.isToxic == true
                                          ? '독성 콘텐츠가 감지되었습니다'
                                          : '⚠️ 부적절한 언어가 포함됨',
                                      style: AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: AppTheme.of(context).error,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  // 오른쪽: 글자 수
                                  Text(
                                    '${_model.textController1?.text.length ?? 0}/60',
                                    style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppTheme.of(context)
                                    .secondaryBackground,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ToggleIcon(
                                    onPressed: () async {
                                      setState(() =>
                                          _model.isRatioVertical =
                                              !_model.isRatioVertical);
                                      _model.isRatioVertical = true;
                                      _model.isRatioHorizontal = false;
                                      setState(() {});
                                    },
                                    value: _model.isRatioVertical,
                                    onIcon: Icon(
                                      Icons.panorama_vertical_select,
                                      color:
                                          AppTheme.of(context).primary,
                                      size: 35.0,
                                    ),
                                    offIcon: Icon(
                                      Icons.panorama_vertical,
                                      color: AppTheme.of(context)
                                          .secondaryText,
                                      size: 35.0,
                                    ),
                                  ),
                                  ToggleIcon(
                                    onPressed: () async {
                                      setState(() =>
                                          _model.isRatioHorizontal =
                                              !_model.isRatioHorizontal);
                                      _model.isRatioHorizontal = true;
                                      _model.isRatioVertical = false;
                                      setState(() {});
                                    },
                                    value: _model.isRatioHorizontal,
                                    onIcon: Icon(
                                      Icons.panorama_horizontal_select,
                                      color:
                                          AppTheme.of(context).primary,
                                      size: 35.0,
                                    ),
                                    offIcon: Icon(
                                      Icons.panorama_horizontal,
                                      color: AppTheme.of(context)
                                          .secondaryText,
                                      size: 35.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_model.isRatioVertical)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 10.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            0.0, 0.0, 2.5, 0.0),
                                        child: Container(
                                          width: _model.absellected == true
                                              ? 380.0
                                              : 190.0,
                                          height: _model.absellected == true
                                              ? 600.0
                                              : 310.0,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context)
                                                .primary,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 0.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.image,
                                                  color: AppTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size:
                                                      _model.absellected == true
                                                          ? 300.0
                                                          : 140.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: Padding(
                                                  padding: EdgeInsets.all(10.0),
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .getText(
                                                      'fw81zr5s' /* A */,
                                                    ),
                                                    style: AppTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 50.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              if (_model.absellected)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.absellected =
                                                            false;
                                                        setState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color:
                                                            AppTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size:
                                                            _model.absellected ==
                                                                    true
                                                                ? 40.0
                                                                : 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!_model.absellected)
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  2.5, 0.0, 0.0, 0.0),
                                          child: Container(
                                            width: 190.0,
                                            height: 310.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppTheme.of(context)
                                                      .secondary,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(20.0),
                                                bottomRight:
                                                    Radius.circular(20.0),
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(20.0),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 0.0),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.image,
                                                    color: AppTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 140.0,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .getText(
                                                        'ncslnwz1' /* B */,
                                                      ),
                                                      style:
                                                          AppTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 50.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(10.0),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.absellected =
                                                            true;
                                                        setState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.cancel_outlined,
                                                        color:
                                                            AppTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            if (_model.isRatioHorizontal)
                              Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    0.0, 10.0, 0.0, 0.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Padding(
                                        padding: EdgeInsetsDirectional.fromSTEB(
                                            2.5, 0.0, 2.5, 2.5),
                                        child: Container(
                                          width: double.infinity,
                                          height: _model.absellected == true
                                              ? 350.0
                                              : 200.0,
                                          decoration: BoxDecoration(
                                            color: AppTheme.of(context)
                                                .primary,
                                            borderRadius: BorderRadius.only(
                                              bottomLeft: Radius.circular(20.0),
                                              bottomRight:
                                                  Radius.circular(20.0),
                                              topLeft: Radius.circular(20.0),
                                              topRight: Radius.circular(20.0),
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    0.0, 1.0),
                                                child: FaIcon(
                                                  FontAwesomeIcons.image,
                                                  color: AppTheme.of(
                                                          context)
                                                      .primaryText,
                                                  size:
                                                      _model.absellected == true
                                                          ? 300.0
                                                          : 180.0,
                                                ),
                                              ),
                                              Align(
                                                alignment: AlignmentDirectional(
                                                    -1.0, -1.0),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    AppLocalizations.of(context)
                                                        .getText(
                                                      'ma3u1a6g' /* A */,
                                                    ),
                                                    style: AppTheme.of(
                                                            context)
                                                        .bodyMedium
                                                        .override(
                                                          font: GoogleFonts
                                                              .plusJakartaSans(
                                                            fontWeight:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                            fontStyle:
                                                                AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                          ),
                                                          fontSize: 50.0,
                                                          letterSpacing: 0.0,
                                                          fontWeight:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontWeight,
                                                          fontStyle:
                                                              AppTheme.of(
                                                                      context)
                                                                  .bodyMedium
                                                                  .fontStyle,
                                                        ),
                                                  ),
                                                ),
                                              ),
                                              if (_model.absellected)
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(14.0),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.absellected =
                                                            false;
                                                        setState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.add,
                                                        color:
                                                            AppTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size:
                                                            _model.absellected ==
                                                                    true
                                                                ? 40.0
                                                                : 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (!_model.absellected)
                                        Padding(
                                          padding:
                                              EdgeInsetsDirectional.fromSTEB(
                                                  2.5, 2.5, 2.5, 0.0),
                                          child: Container(
                                            width: double.infinity,
                                            height: 200.0,
                                            decoration: BoxDecoration(
                                              color:
                                                  AppTheme.of(context)
                                                      .secondary,
                                              borderRadius: BorderRadius.only(
                                                bottomLeft:
                                                    Radius.circular(20.0),
                                                bottomRight:
                                                    Radius.circular(20.0),
                                                topLeft: Radius.circular(20.0),
                                                topRight: Radius.circular(20.0),
                                              ),
                                            ),
                                            child: Stack(
                                              children: [
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          0.0, 1.0),
                                                  child: FaIcon(
                                                    FontAwesomeIcons.image,
                                                    color: AppTheme.of(
                                                            context)
                                                        .primaryText,
                                                    size: 180.0,
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          -1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text(
                                                      AppLocalizations.of(
                                                              context)
                                                          .getText(
                                                        '6nrudz4v' /* B */,
                                                      ),
                                                      style:
                                                          AppTheme.of(
                                                                  context)
                                                              .bodyMedium
                                                              .override(
                                                                font: GoogleFonts
                                                                    .plusJakartaSans(
                                                                  fontWeight: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontWeight,
                                                                  fontStyle: AppTheme.of(
                                                                          context)
                                                                      .bodyMedium
                                                                      .fontStyle,
                                                                ),
                                                                fontSize: 50.0,
                                                                letterSpacing:
                                                                    0.0,
                                                                fontWeight: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontWeight,
                                                                fontStyle: AppTheme.of(
                                                                        context)
                                                                    .bodyMedium
                                                                    .fontStyle,
                                                              ),
                                                    ),
                                                  ),
                                                ),
                                                Align(
                                                  alignment:
                                                      AlignmentDirectional(
                                                          1.0, -1.0),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(14.0),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      focusColor:
                                                          Colors.transparent,
                                                      hoverColor:
                                                          Colors.transparent,
                                                      highlightColor:
                                                          Colors.transparent,
                                                      onTap: () async {
                                                        _model.absellected =
                                                            true;
                                                        setState(() {});
                                                      },
                                                      child: Icon(
                                                        Icons.cancel_outlined,
                                                        color:
                                                            AppTheme.of(
                                                                    context)
                                                                .primaryText,
                                                        size: 24.0,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(
                                  10.0, 3.0, 10.0, 0.0),
                              child: ValidatedTextField(
                                controller: _model.textController2,
                                focusNode: _model.textFieldFocusNode2,
                                onChanged: (value) {
                                  // 실시간 글자 수 업데이트
                                  setState(() {
                                    // 텍스트가 비어있으면 에러 초기화
                                    if (value.trim().isEmpty) {
                                      _model.validationResults.remove('description');
                                    }
                                  });
                                },
                                validationResult: _model.validationResults['description'],
                                showValidationResults: false, // 에러는 필드 외부에서 표시
                                minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.done,
                                maxLength: 200,
                                decoration: InputDecoration(
                                  isDense: true,
                                  labelText:
                                      AppLocalizations.of(context).getText(
                                    '94dz6d39' /* Description */,
                                  ),
                                  labelStyle: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 30.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                  alignLabelWithHint: false,
                                  hintText: AppLocalizations.of(context).getText(
                                    'gipyr3sq' /* Enter Description */,
                                  ),
                                  hintStyle: AppTheme.of(context)
                                      .labelMedium
                                      .override(
                                        font: GoogleFonts.plusJakartaSans(
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .labelMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .labelMedium
                                                  .fontStyle,
                                        ),
                                        fontSize: 14.0,
                                        letterSpacing: 0.0,
                                        fontWeight: AppTheme.of(context)
                                            .labelMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .labelMedium
                                            .fontStyle,
                                      ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  focusedErrorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  filled: true,
                                  fillColor: AppTheme.of(context)
                                      .secondaryBackground,
                                  suffixIcon: _model
                                          .textController2!.text.isNotEmpty
                                      ? InkWell(
                                          onTap: () async {
                                            _model.textController2?.clear();
                                            // 검증 결과도 초기화
                                            _model.validationResults.remove('description');
                                            _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.clear,
                                            color: AppTheme.of(context)
                                                .primaryText,
                                            size: 22,
                                          ),
                                        )
                                      : null,
                                ),
                                style: AppTheme.of(context)
                                    .bodyMedium
                                    .override(
                                      font: GoogleFonts.plusJakartaSans(
                                        fontWeight: AppTheme.of(context)
                                            .bodyMedium
                                            .fontWeight,
                                        fontStyle: AppTheme.of(context)
                                            .bodyMedium
                                            .fontStyle,
                                      ),
                                      fontSize: 16.0,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context)
                                          .bodyMedium
                                          .fontWeight,
                                      fontStyle: AppTheme.of(context)
                                          .bodyMedium
                                          .fontStyle,
                                    ),
                              ),
                            ),
                            // Description 글자 수 표시
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(10.0, 4.5, 10.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '${_model.textController2?.text.length ?? 0}/200',
                                    style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 2.0, 20.0, 0.0),
                                child: Container(
                                  width: 400.0,
                                  child: ValidatedTextField(
                                    controller: _model.textController3,
                                    focusNode: _model.textFieldFocusNode3,
                                    onChanged: (value) {
                                      // 실시간 글자 수 업데이트
                                      setState(() {
                                        // 텍스트가 비어있으면 에러 초기화
                                        if (value.trim().isEmpty) {
                                          _model.isATitleEmpty = false;
                                          _model.validationResults.remove('aTitle');
                                          _model.hasBlockedWordInATitle = false;
                                        }
                                      });
                                      
                                      // 필수 필드 체크
                                      _checkRequiredFieldsAndUpdateButton();
                                      
                                      // 디바운스된 필터링
                                      EasyDebounce.debounce(
                                        '_model.textController3',
                                        Duration(milliseconds: 500),
                                        () {
                                          final result = ContentFilter.filterText(value);
                                          _model.hasBlockedWordInATitle = result.isBlocked;
                                          setState(() {});
                                        },
                                      );
                                    },
                                    validationResult: _model.validationResults['aTitle'],
                                    showValidationResults: false, // 에러는 필드 외부에서 표시
                                    minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.done,
                                maxLength: 20,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        'jvx92fb4' /* A title */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      alignLabelWithHint: false,
                                      hintText:
                                          AppLocalizations.of(context).getText(
                                        'tkzl6wqo' /* Tell me about A... */,
                                      ),
                                      hintStyle: AppTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedErrorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .secondaryBackground,
                                      suffixIcon: _model
                                              .textController3!.text.isNotEmpty
                                          ? InkWell(
                                              onTap: () async {
                                                _model.textController3?.clear();
                                                // 검증 결과도 초기화
                                                _model.validationResults.remove('aTitle');
                                                _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                                _model.hasBlockedWordInATitle = false;
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.clear,
                                                size: 22,
                                              ),
                                            )
                                          : null,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            // A title 글자 수 및 경고 표시
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 4.5, 20.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 왼쪽: 경고 메시지
                                  if (_model.hasBlockedWordInATitle || _model.isATitleEmpty || _model.validationResults['aTitle']?.isToxic == true)
                                    Text(
                                      _model.isATitleEmpty 
                                        ? '필수 항목입니다'
                                        : _model.validationResults['aTitle']?.isToxic == true
                                          ? '독성 콘텐츠가 감지되었습니다'
                                          : '⚠️ 부적절한 언어가 포함됨',
                                      style: AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: AppTheme.of(context).error,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  // 오른쪽: 글자 수
                                  Text(
                                    '${_model.textController3?.text.length ?? 0}/20',
                                    style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Align(
                              alignment: AlignmentDirectional(-1.0, 0.0),
                              child: Padding(
                                padding: EdgeInsetsDirectional.fromSTEB(
                                    20.0, 2.0, 20.0, 0.0),
                                child: Container(
                                  width: 400.0,
                                  child: ValidatedTextField(
                                    controller: _model.textController4,
                                    focusNode: _model.textFieldFocusNode4,
                                    onChanged: (value) {
                                      // 실시간 글자 수 업데이트
                                      setState(() {
                                        // 텍스트가 비어있으면 에러 초기화
                                        if (value.trim().isEmpty) {
                                          _model.isBTitleEmpty = false;
                                          _model.validationResults.remove('bTitle');
                                          _model.hasBlockedWordInBTitle = false;
                                        }
                                      });
                                      
                                      // 필수 필드 체크
                                      _checkRequiredFieldsAndUpdateButton();
                                      
                                      // 디바운스된 필터링
                                      EasyDebounce.debounce(
                                        '_model.textController4',
                                        Duration(milliseconds: 500),
                                        () {
                                          final result = ContentFilter.filterText(value);
                                          _model.hasBlockedWordInBTitle = result.isBlocked;
                                          setState(() {});
                                        },
                                      );
                                    },
                                    validationResult: _model.validationResults['bTitle'],
                                    showValidationResults: false, // 에러는 필드 외부에서 표시
                                    minLines: 1,
                                maxLines: 5,
                                textInputAction: TextInputAction.done,
                                maxLength: 20,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      labelText:
                                          AppLocalizations.of(context).getText(
                                        't8flxbe7' /* B title */,
                                      ),
                                      labelStyle: AppTheme.of(context)
                                          .titleSmall
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .titleSmall
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .titleSmall
                                                    .fontStyle,
                                          ),
                                      alignLabelWithHint: false,
                                      hintText:
                                          AppLocalizations.of(context).getText(
                                        'gwsufdly' /* Tell me about B... */,
                                      ),
                                      hintStyle: AppTheme.of(context)
                                          .labelMedium
                                          .override(
                                            font: GoogleFonts.plusJakartaSans(
                                              fontWeight:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontWeight,
                                              fontStyle:
                                                  AppTheme.of(context)
                                                      .labelMedium
                                                      .fontStyle,
                                            ),
                                            letterSpacing: 0.0,
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .labelMedium
                                                    .fontStyle,
                                          ),
                                      enabledBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: Colors.black,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      errorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      focusedErrorBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: AppTheme.of(context)
                                              .error,
                                          width: 2.0,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      filled: true,
                                      fillColor: AppTheme.of(context)
                                          .secondaryBackground,
                                      suffixIcon: _model
                                              .textController4!.text.isNotEmpty
                                          ? InkWell(
                                              onTap: () async {
                                                _model.textController4?.clear();
                                                // 검증 결과도 초기화
                                                _model.validationResults.remove('bTitle');
                                                _model.hasValidationViolations = _model.validationResults.values.any((r) => r.isToxic);
                                                _model.hasBlockedWordInBTitle = false;
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.clear,
                                                size: 22,
                                              ),
                                            )
                                          : null,
                                    ),
                                    style: AppTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          font: GoogleFonts.plusJakartaSans(
                                            fontWeight:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontWeight,
                                            fontStyle:
                                                AppTheme.of(context)
                                                    .bodyMedium
                                                    .fontStyle,
                                          ),
                                          letterSpacing: 0.0,
                                          fontWeight:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontWeight,
                                          fontStyle:
                                              AppTheme.of(context)
                                                  .bodyMedium
                                                  .fontStyle,
                                        ),
                                  ),
                                ),
                              ),
                            ),
                            // B title 글자 수 및 경고 표시
                            Padding(
                              padding: EdgeInsetsDirectional.fromSTEB(20.0, 4.5, 20.0, 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // 왼쪽: 경고 메시지
                                  if (_model.hasBlockedWordInBTitle || _model.isBTitleEmpty || _model.validationResults['bTitle']?.isToxic == true)
                                    Text(
                                      _model.isBTitleEmpty 
                                        ? '필수 항목입니다'
                                        : _model.validationResults['bTitle']?.isToxic == true
                                          ? '독성 콘텐츠가 감지되었습니다'
                                          : '⚠️ 부적절한 언어가 포함눨',
                                      style: AppTheme.of(context).bodySmall.override(
                                        font: GoogleFonts.plusJakartaSans(),
                                        color: AppTheme.of(context).error,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  else
                                    const SizedBox.shrink(),
                                  // 오른쪽: 글자 수
                                  Text(
                                    '${_model.textController4?.text.length ?? 0}/20',
                                    style: AppTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.plusJakartaSans(),
                                      color: AppTheme.of(context).secondaryText,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 스크롤 감지를 위한 최소 여백
                            SizedBox(height: 100.0),
                          ],
                        ),
              ),
              // Next button overlay
              Positioned(
                bottom: 30.0,
                right: 20.0,
                child: AnimatedOpacity(
                  opacity: _model.showNextButton ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: FloatingActionButton.extended(
                    onPressed: _model.showNextButton && !_model.isValidating
                        ? () async {
                            await _validateAllTexts();
                          }
                        : null,
                    backgroundColor: _model.isValidating 
                        ? Colors.grey 
                        : AppTheme.of(context).primary,
                    icon: _model.isValidating
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                          ),
                    label: Text(
                      _model.isValidating ? '검증 중...' : '다음',
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.plusJakartaSans(),
                            color: Colors.white,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
