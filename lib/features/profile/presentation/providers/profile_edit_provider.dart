import 'package:flutter/foundation.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 편집 Provider
///
/// **책임**:
/// - 프로필 편집 상태 관리
/// - 임시 변경사항 추적
/// - UseCase를 통한 업데이트 실행
class ProfileEditProvider extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateProfileUseCase;

  UserProfile? _editingProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  ProfileEditProvider({
    required UpdateUserProfileUseCase updateProfileUseCase,
  }) : _updateProfileUseCase = updateProfileUseCase;

  // Getters
  UserProfile? get editingProfile => _editingProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChanges => _hasChanges;

  /// 편집 시작
  void startEditing(UserProfile profile) {
    _editingProfile = profile;
    _hasChanges = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 필드 업데이트
  void updateField(UserProfile updatedProfile) {
    _editingProfile = updatedProfile;
    _hasChanges = true;
    notifyListeners();
  }

  /// 프로필 저장
  Future<void> saveProfile(String userId) async {
    if (_editingProfile == null || !_hasChanges) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      userId: userId,
      profile: _editingProfile!,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (profile) {
        _editingProfile = profile;
        _hasChanges = false;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 편집 취소
  void cancelEditing() {
    _editingProfile = null;
    _hasChanges = false;
    _errorMessage = null;
    notifyListeners();
  }
}
