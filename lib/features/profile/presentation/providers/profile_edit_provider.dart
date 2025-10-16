import 'dart:io';
import 'package:flutter/foundation.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 편집 Provider
///
/// **책임**:
/// - 프로필 편집 상태 관리
/// - 임시 변경사항 추적
/// - UseCase를 통한 업데이트 실행
/// - 프로필 로드 및 필드별 업데이트 지원
/// - 프로필 이미지 업로드 관리
///
/// **변경사항** (2025-01-20 Phase 1):
/// - createUserProfileData 제거 → UserProfile 생성자 직접 사용
/// - getDocumentFromData 제거 → UserProfile 생성자 직접 사용
/// - reference 사용 제거 → UseCase로 완전 전환
///
/// **변경사항** (2025-01-20 Phase 3.1):
/// - UploadProfileImageUseCase 통합
/// - uploadProfileImage 메서드 추가
class ProfileEditProvider extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;

  UserProfile? _editingProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  ProfileEditProvider({
    required UpdateUserProfileUseCase updateProfileUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
  })  : _updateProfileUseCase = updateProfileUseCase,
        _getUserProfileUseCase = getUserProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  // Getters
  UserProfile? get editingProfile => _editingProfile;
  UserProfile? get profile => _editingProfile; // Alias for screen compatibility
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasChanges => _hasChanges;

  /// 프로필 로드
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getUserProfileUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _editingProfile = null;
      },
      (profile) {
        _editingProfile = profile;
        _hasChanges = false;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

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

  /// 성별 업데이트
  ///
  /// **Phase 2 변경**: copyWith() 사용으로 보일러플레이트 제거
  void updateGender(String gender) {
    if (_editingProfile == null) return;

    _editingProfile = _editingProfile!.copyWith(gender: gender);
    _hasChanges = true;
    notifyListeners();
  }

  /// 프로필 저장 (필드별 업데이트 지원)
  ///
  /// **Phase 2 변경**: copyWith() 사용으로 보일러플레이트 제거
  Future<bool> saveProfile({
    String? displayName,
    String? shortDescription,
  }) async {
    if (_editingProfile == null) {
      _errorMessage = '프로필 정보가 없습니다';
      notifyListeners();
      return false;
    }

    // 필드 업데이트가 있으면 적용
    if (displayName != null || shortDescription != null) {
      _editingProfile = _editingProfile!.copyWith(
        displayName: displayName,
        shortDescription: shortDescription,
      );
      _hasChanges = true;
    }

    if (!_hasChanges) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(_editingProfile!);

    bool success = false;
    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
        _hasChanges = false;
        _errorMessage = null;
        success = true;
      },
    );

    _isLoading = false;
    notifyListeners();

    return success;
  }

  /// 편집 취소
  void cancelEditing() {
    _editingProfile = null;
    _hasChanges = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// 프로필 이미지 업로드
  ///
  /// **Phase 3.1 추가**: 이미지 업로드 및 프로필 자동 업데이트
  Future<bool> uploadProfileImage(File imageFile) async {
    if (_editingProfile == null) {
      _errorMessage = '프로필 정보가 없습니다';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // 1. 이미지 업로드
    final uploadResult = await _uploadImageUseCase.execute(
      userId: _editingProfile!.uid,
      imageFile: imageFile,
    );

    bool success = false;
    await uploadResult.fold(
      (failure) async {
        _errorMessage = failure.getUserMessage();
        _isLoading = false;
        notifyListeners();
      },
      (imageUrl) async {
        // 2. photoUrl 필드 업데이트 (Phase 2: copyWith() 사용)
        _editingProfile = _editingProfile!.copyWith(photoUrl: imageUrl);

        // 3. Firestore에 저장
        final saveResult = await _updateProfileUseCase.execute(_editingProfile!);

        saveResult.fold(
          (failure) {
            _errorMessage = failure.getUserMessage();
          },
          (_) {
            _hasChanges = false;
            _errorMessage = null;
            success = true;
          },
        );

        _isLoading = false;
        notifyListeners();
      },
    );

    return success;
  }
}
