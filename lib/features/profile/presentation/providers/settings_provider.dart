import 'package:flutter/foundation.dart';
import '../../domain/usecases/settings/get_user_settings_usecase.dart';
import '../../domain/usecases/settings/update_user_settings_usecase.dart';
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

  UserSettings? _settings;
  bool _isLoading = false;
  String? _errorMessage;

  SettingsProvider({
    required GetUserSettingsUseCase getSettingsUseCase,
    required UpdateUserSettingsUseCase updateSettingsUseCase,
  })  : _getSettingsUseCase = getSettingsUseCase,
        _updateSettingsUseCase = updateSettingsUseCase;

  // Getters
  UserSettings? get settings => _settings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
}
