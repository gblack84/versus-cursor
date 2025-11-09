import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'phone_creat_account_widget.dart' show PhoneCreatAccountWidget;
import 'package:flutter/material.dart';

class PhoneCreatAccountModel extends AppModel<PhoneCreatAccountWidget> {
  ///  State fields for stateful widgets in this page.

  // State field(s) for Country Selection (CountrySelectorWidget)
  String? selectedCountryCode;  // "+82", "+1", etc.
  String? selectedCountryName;  // "South Korea", "United States", etc.

  // State field(s) for PhoneNumber widget.
  FocusNode? phoneNumberFocusNode;
  TextEditingController? phoneNumberTextController;
  String? Function(BuildContext, String?)? phoneNumberTextControllerValidator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    phoneNumberFocusNode?.dispose();
    phoneNumberTextController?.dispose();
  }
}
