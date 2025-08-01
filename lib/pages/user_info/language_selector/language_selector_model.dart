import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_utils.dart';
import 'language_selector_widget.dart' show LanguageSelectorWidget;
import 'package:flutter/material.dart';

class LanguageSelectorModel extends AppModel<LanguageSelectorWidget> {
  ///  Local state fields for this component.

  String? selectedLanguage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Action blocks.
  Future saveLanguageToFirestore(BuildContext context) async {
    await currentUserReference!.update(createUsersModelData(
      role: '',
    ));
  }
}
