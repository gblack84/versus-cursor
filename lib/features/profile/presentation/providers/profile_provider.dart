import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 Provider (Clean Architecture v4.0)
///
/// **책임**:
/// - 프로필 상태 관리
/// - UseCase를 통한 비즈니스 로직 실행
/// - UI 상태 업데이트 (로딩, 에러)
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  // ignore: unused_field - 향후 프로필 업데이트 기능에 사용 예정
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileProvider({
    required GetUserProfileUseCase getProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase;

  // Getters
  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 프로필 로드
  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProfileUseCase.execute(userId: userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _profile = null;
      },
      (profile) {
        _profile = profile;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 프로필 이미지 업로드
  Future<void> uploadProfileImage(String userId, File imageFile) async {
    _isLoading = true;
    notifyListeners();

    final result = await _uploadImageUseCase.execute(
      userId: userId,
      imageFile: imageFile,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (imageUrl) async {
        // UserProfile은 immutable이므로 Firestore에 직접 업데이트
        if (_profile != null) {
          await _profile!.reference.update({'photoUrl': imageUrl});
          // 업데이트 후 다시 로드하여 최신 상태 반영
          await loadProfile(userId);
        }
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

}
