// Phase 3: Riverpod
import '/core_exports.dart';
import 'language_selector_widget.dart' show LanguageSelectorWidget;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/features/profile/presentation/providers/profile_notifiers.dart';
import '/features/profile/domain/entities/user_profile.dart';
import '/app/contracts/auth_contract.dart';
import 'package:get_it/get_it.dart';

/// 언어 선택 모델 (Riverpod)
///
/// **Clean Architecture v4.0 + Riverpod**:
/// - ✅ ProfileActions 사용
/// - ✅ WidgetRef 기반 상태 관리
class LanguageSelectorModel extends AppModel<LanguageSelectorWidget> {
  ///  Local state fields for this component.

  String? selectedLanguage;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}

  /// Phase 3: Riverpod - ProfileActions 사용
  ///
  /// **Note**: 현재 이 메서드는 사용되지 않음 (widget에서 setAppLanguage 직접 호출)
  /// 향후 사용을 위해 Riverpod으로 업데이트
  Future saveLanguageToFirestore(
    BuildContext context,
    WidgetRef ref,
  ) async {
    if (selectedLanguage == null) return;

    // AuthContract에서 현재 userId 가져오기
    final authContract = GetIt.instance<AuthContract>();
    final userId = authContract.getCurrentUserId();

    if (userId == null) return;

    // 현재 프로필 가져오기
    final profileState = ref.read(profileStreamProvider(userId));

    UserProfile? currentProfile;
    profileState.when(
      loading: () => currentProfile = null,
      error: (error, stackTrace) => currentProfile = null,
      data: (profile) => currentProfile = profile,
    );

    if (currentProfile == null) return;

    // copyWith()로 업데이트된 프로필 생성
    final updatedProfile = currentProfile!.copyWith(
      language: selectedLanguage,
    );

    // ProfileActions.updateProfile() 호출
    await ProfileActions.updateProfile(
      ref: ref,
      userId: userId,
      updatedProfile: updatedProfile,
      onSuccess: () {
        // 성공 처리 (선택적)
      },
      onError: (message) {
        // 에러 처리 (선택적)
      },
    );
  }
}
