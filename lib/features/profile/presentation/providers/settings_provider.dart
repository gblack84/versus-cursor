import 'package:flutter/foundation.dart';
import '../../domain/usecases/settings/get_user_settings_usecase.dart';
import '../../domain/usecases/settings/update_user_settings_usecase.dart';
import '../../domain/usecases/profile/delete_user_profile_usecase.dart';
import '../../domain/models/user_settings.dart';

/// 설정 Provider
///
/// **책임**:
/// - 사용자 설정 상태 관리
/// - 설정 변경 추적
/// - UseCase를 통한 설정 업데이트
class SettingsProvider extends ChangeNotifier {
  final GetUserSettingsUseCase _getSettingsUseCase;
  final UpdateUserSettingsUseCase _updateSettingsUseCase;
  final DeleteUserProfileUseCase _deleteProfileUseCase;

  UserSettings? _settings;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDeleting = false;

  SettingsProvider({
    required GetUserSettingsUseCase getSettingsUseCase,
    required UpdateUserSettingsUseCase updateSettingsUseCase,
    required DeleteUserProfileUseCase deleteProfileUseCase,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _updateSettingsUseCase = updateSettingsUseCase,
        _deleteProfileUseCase = deleteProfileUseCase;

  // Getters
  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDeleting => _isDeleting;

  /// 설정 로드
  Future<void> loadSettings(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getSettingsUseCase.execute(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _settings = null;
      },
      (settings) {
        _settings = settings;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 설정 업데이트
  Future<void> updateSettings(String userId, UserSettings newSettings) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateSettingsUseCase.execute(
      userId,
      newSettings.toFirestore(),
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _settings = newSettings;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 개별 설정 토글
  Future<void> toggleSetting(
    String userId,
    UserSettings Function(UserSettings) updater,
  ) async {
    if (_settings == null) return;

    final newSettings = updater(_settings!);
    await updateSettings(userId, newSettings);
  }

  /// 계정 삭제 (Phase 6 복원)
  ///
  /// **사용 예시**:
  /// ```dart
  /// final success = await settingsProvider.deleteUserProfile(userId);
  /// if (success) {
  ///   // 로그아웃 및 startPage로 네비게이션
  /// }
  /// ```
  ///
  /// **GDPR Compliance**:
  /// - 사용자 데이터 완전 삭제
  /// - 복구 불가능
  /// - 확인 다이얼로그 필수 (UI에서 처리)
  ///
  /// **Phase 6 복원** (2025-01-21):
  /// - DeleteUserProfileUseCase 통합 완료
  /// - Settings 화면에서 사용
  Future<bool> deleteUserProfile(String userId) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _deleteProfileUseCase.execute(userId: userId);

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        success = false;
      },
      (_) {
        _errorMessage = null;
        success = true;
      },
    );

    _isDeleting = false;
    notifyListeners();

    return success;
  }
}
