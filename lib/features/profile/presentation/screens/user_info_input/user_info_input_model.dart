import '/features/profile/domain/entities/user_profile.dart';
import '/core_exports.dart';
import '/app/widgets/index.dart';
import 'user_info_input_widget.dart' show UserInfoInputWidget;
import 'package:flutter/material.dart';

class UserInfoInputModel extends AppModel<UserInfoInputWidget> {
  ///  Local state fields for this page.

  String? selectedLanguage;
  String? selectedCountry;      // "South Korea"
  String? selectedCountryCode;  // "KR"

  bool agreed13old = false;

  ///  State fields for stateful widgets in this page.

  final formKey = GlobalKey<FormState>();
  // Stores action output result for [Backend Call - Read Document] action in user_info_input widget.
  UserProfile? userDocument;
  // State field(s) for DisplayName widget.
  FocusNode? displayNameFocusNode;
  TextEditingController? displayNameTextController;
  String? Function(BuildContext, String?)? displayNameTextControllerValidator;
  String? _displayNameTextControllerValidator(
      BuildContext context, String? val) {
    if (val == null || val.isEmpty) {
      return AppLocalizations.of(context).getText(
        'u59p36mu' /* Please enter the your display ... */,
      );
    }

    return null;
  }

  // State field(s) for ChoiceChips widget.
  FormFieldController<List<String>>? choiceChipsValueController;
  String? get choiceChipsValue =>
      choiceChipsValueController?.value?.firstOrNull;
  set choiceChipsValue(String? val) =>
      choiceChipsValueController?.value = val != null ? [val] : [];
  // State field(s) for Checkbox widget.
  bool? checkboxValue;

  @override
  void initState(BuildContext context) {
    displayNameTextControllerValidator = _displayNameTextControllerValidator;
  }

  @override
  void dispose() {
    displayNameFocusNode?.dispose();
    displayNameTextController?.dispose();
  }
}
