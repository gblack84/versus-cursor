import '/core/app_utils.dart';
import '/services/perspective_api_service.dart';
import 'in_put_post_image_widget.dart' show InPutPostImageWidget;
import 'package:flutter/material.dart';

class InPutPostImageModel extends AppModel<InPutPostImageWidget> {
  ///  Local state fields for this page.

  bool absellected = false;

  bool isRatioVertical = true;

  bool isRatioHorizontal = false;

  bool showNextButton = false;
  
  // 비디오 선택 상태
  bool isVideoSelectedA = false;
  bool isVideoSelectedB = false;

  // 금지어 감지 상태
  bool hasBlockedWordInTitle = false;
  bool hasBlockedWordInATitle = false;
  bool hasBlockedWordInBTitle = false;

  // Perspective API 검증 관련
  bool isValidating = false;
  Map<String, PerspectiveResult> validationResults = {};
  bool hasValidationViolations = false;
  
  // 필수 필드 비어있음 에러 상태
  bool isQuestionTitleEmpty = false;
  bool isATitleEmpty = false;
  bool isBTitleEmpty = false;
  
  // B박스 경고 메시지 표시 상태
  bool showBBoxWarning = false;
  
  // 흔들림 애니메이션 컨트롤러
  AnimationController? shakeController;
  Animation<double>? shakeAnimation;

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
