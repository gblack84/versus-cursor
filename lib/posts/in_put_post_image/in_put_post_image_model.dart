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
