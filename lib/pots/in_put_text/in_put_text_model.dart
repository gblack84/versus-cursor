import '/flutter_flow/flutter_flow_util.dart';
import 'in_put_text_widget.dart' show InPutTextWidget;
import 'package:flutter/material.dart';

class InPutTextModel extends FlutterFlowModel<InPutTextWidget> {
  ///  Local state fields for this component.

  String sheetText = '';

  ///  State fields for stateful widgets in this component.

  final formKey = GlobalKey<FormState>();
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode;
  TextEditingController? textController;
  String? Function(BuildContext, String?)? textControllerValidator;
  String? _textControllerValidator(BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return FFLocalizations.of(context).getText(
        '0zfp2fn2' /* sheetText is required */,
      );
    }

    return null;
  }

  @override
  void initState(BuildContext context) {
    textControllerValidator = _textControllerValidator;
  }

  @override
  void dispose() {
    textFieldFocusNode?.dispose();
    textController?.dispose();
  }

  /// Action blocks.
  Future edittext(
    BuildContext context, {
    String? ssheet,
  }) async {
    sheetText = textController.text;
  }
}
