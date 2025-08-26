import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'phone_creat_account_widget.dart' show PhoneCreatAccountWidget;
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class PhoneCreatAccountModel extends AppModel<PhoneCreatAccountWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for CodeCuntry widget.
  FocusNode? codeCuntryFocusNode;
  TextEditingController? codeCuntryTextController;
  late MaskTextInputFormatter codeCuntryMask;
  String? Function(BuildContext, String?)? codeCuntryTextControllerValidator;
  // State field(s) for PhoneNumber widget.
  FocusNode? phoneNumberFocusNode;
  TextEditingController? phoneNumberTextController;
  String? Function(BuildContext, String?)? phoneNumberTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    codeCuntryFocusNode?.dispose();
    codeCuntryTextController?.dispose();

    phoneNumberFocusNode?.dispose();
    phoneNumberTextController?.dispose();
  }
}
