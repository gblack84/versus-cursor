// Phase 2: Clean Architecture - ProfileProvider만 사용
import '/features/profile/presentation/providers/profile_provider.dart';
import '/core_exports.dart';
import 'language_selector_widget.dart' show LanguageSelectorWidget;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class LanguageSelectorModel extends AppModel<LanguageSelectorWidget> {
  ///  Local state fields for this component.

  String? selectedLanguage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Action blocks.
  Future saveLanguageToFirestore(BuildContext context) async {
    // Phase 2: Clean Architecture 완성
    if (selectedLanguage == null) return;

    final profileProvider = GetIt.instance<ProfileProvider>();

    // ProfileProvider가 제공하는 편리한 메서드 사용
    // 내부적으로: loadCurrentUserProfile() → copyWith(language) → updateProfile()
    // UI는 AuthContract를 전혀 몰라도 됨!
    await profileProvider.updateCurrentUserLanguage(selectedLanguage!);

    // 에러 처리 (선택적)
    if (profileProvider.errorMessage != null) {
      // TODO: 필요시 에러 토스트 표시
    }
  }
}
