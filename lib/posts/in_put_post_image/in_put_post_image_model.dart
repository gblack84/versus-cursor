import '/core/app_utils.dart';
import '/services/perspective_api_service.dart';
import 'in_put_post_image_widget.dart' show InPutPostImageWidget;
import 'package:flutter/material.dart';
import 'helpers/aspect_ratio_analyzer.dart';

class InPutPostImageModel extends AppModel<InPutPostImageWidget> {
  ///  Local state fields for this page.

  bool absellected = false;

  // 기존 토글 상태 (점진적 마이그레이션을 위해 유지)
  // 주의: isRatioVertical이 true면 UI에서 가로 배치(좌/우)를 표시
  bool isRatioVertical = true;  // 기본값: 가로 배치(좌/우)
  bool isRatioHorizontal = false;

  // 스마트 레이아웃 시스템 - 토글 대신 자동 결정
  // 기본값을 horizontal로 설정 (isRatioVertical = true와 일치)
  LayoutType currentLayout = LayoutType.horizontal;

  bool showNextButton = false;
  
  // 비디오 선택 상태
  bool isVideoSelectedA = false;
  bool isVideoSelectedB = false;

  // 금지어 감지 상태
  bool hasBlockedWordInTitle = false;
  bool hasBlockedWordInDescription = false;
  bool hasBlockedWordInATitle = false;
  bool hasBlockedWordInBTitle = false;

  // Perspective API 검증 관련
  bool isValidating = false;
  String? validationMessage;  // 검증 중 메시지 표시용
  Map<String, PerspectiveResult> validationResults = {};
  bool hasValidationViolations = false;
  
  // 필수 필드 비어있음 에러 상태
  bool isQuestionTitleEmpty = true;
  bool isATitleEmpty = true;
  bool isBTitleEmpty = true;
  
  // 검증 시도 여부 (다음 버튼 클릭 여부)
  bool hasValidated = false;
  
  // 흔들림 애니메이션 컨트롤러
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;
  
  // Current image index for each box
  int currentImageIndexA = 0;
  int currentImageIndexB = 0;
  
  // Edit mode detection
  bool isEditMode = false;
  DocumentReference? existingPostRef;
  String? existingPostId;

  ///  State fields for stateful widgets in this page.

  // Scroll controller for detecting scroll end
  ScrollController? scrollController;

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode3;
  TextEditingController? textController3;
  String? Function(BuildContext, String?)? textController3Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode4;
  TextEditingController? textController4;
  String? Function(BuildContext, String?)? textController4Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    scrollController?.dispose();
    shakeController?.dispose();

    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldFocusNode3?.dispose();
    textController3?.dispose();

    textFieldFocusNode4?.dispose();
    textController4?.dispose();
  }
}
