import 'package:flutter/foundation.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/models/user_profile.dart';

/// 프로필 편집 Provider
///
/// **책임**:
/// - 프로필 편집 상태 관리
/// - 임시 변경사항 추적
/// - UseCase를 통한 업데이트 실행
/// - 프로필 로드 및 필드별 업데이트 지원
class ProfileEditProvider extends ChangeNotifier {
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;

  UserProfile? _editingProfile;
  bool _isLoading = false;
  String? _errorMessage;
  bool _hasChanges = false;

  ProfileEditProvider({
    required UpdateUserProfileUseCase updateProfileUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
  })  : _updateProfileUseCase = updateProfileUseCase,
        _getUserProfileUseCase = getUserProfileUseCase;

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
  void updateGender(String gender) {
    if (_editingProfile == null) return;

    // UserProfile은 immutable이므로 createUserProfileData로 새로 생성
    final updatedData = createUserProfileData(
      uid: _editingProfile!.uid,
      email: _editingProfile!.email,
      displayName: _editingProfile!.displayName,
      photoUrl: _editingProfile!.photoUrl,
      phoneNumber: _editingProfile!.phoneNumber,
      location: _editingProfile!.location,
      shortDescription: _editingProfile!.shortDescription,
      gender: gender, // 업데이트할 필드
      dateOfBirth: _editingProfile!.dateOfBirth,
      language: _editingProfile!.language,
      createdTime: _editingProfile!.createdTime,
      lastActive: _editingProfile!.lastActive,
      lastActiveTime: _editingProfile!.lastActiveTime,
      pointsA: _editingProfile!.pointsA,
      pointsQ: _editingProfile!.pointsQ,
      totalAPoints: _editingProfile!.totalAPoints,
      totalQPoints: _editingProfile!.totalQPoints,
      isPremiumUser: _editingProfile!.isPremiumUser,
      anonymousPostsCount: _editingProfile!.anonymousPostsCount,
      anonymousCommentsCount: _editingProfile!.anonymousCommentsCount,
      anonymousQuestionCount: _editingProfile!.anonymousQuestionCount,
      currentRank: _editingProfile!.currentRank,
      currentTitle: _editingProfile!.currentTitle,
      rankChangeDate: _editingProfile!.rankChangeDate,
      titleChangeDate: _editingProfile!.titleChangeDate,
      isRankEligible: _editingProfile!.isRankEligible,
      rankEvaluationCount: _editingProfile!.rankEvaluationCount,
      receiveRankUpdateNotifications:
          _editingProfile!.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications:
          _editingProfile!.receiveTitleUpdateNotifications,
      role: _editingProfile!.role,
      title: _editingProfile!.title,
      stats: _editingProfile!.stats,
      subscription: _editingProfile!.subscription,
    );

    _editingProfile = UserProfile.getDocumentFromData(
      updatedData,
      _editingProfile!.reference,
    );
    _hasChanges = true;
    notifyListeners();
  }

  /// 프로필 저장 (필드별 업데이트 지원)
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
      final updatedData = createUserProfileData(
        uid: _editingProfile!.uid,
        email: _editingProfile!.email,
        displayName: displayName ?? _editingProfile!.displayName,
        photoUrl: _editingProfile!.photoUrl,
        phoneNumber: _editingProfile!.phoneNumber,
        location: _editingProfile!.location,
        shortDescription:
            shortDescription ?? _editingProfile!.shortDescription,
        gender: _editingProfile!.gender,
        dateOfBirth: _editingProfile!.dateOfBirth,
        language: _editingProfile!.language,
        createdTime: _editingProfile!.createdTime,
        lastActive: _editingProfile!.lastActive,
        lastActiveTime: _editingProfile!.lastActiveTime,
        pointsA: _editingProfile!.pointsA,
        pointsQ: _editingProfile!.pointsQ,
        totalAPoints: _editingProfile!.totalAPoints,
        totalQPoints: _editingProfile!.totalQPoints,
        isPremiumUser: _editingProfile!.isPremiumUser,
        anonymousPostsCount: _editingProfile!.anonymousPostsCount,
        anonymousCommentsCount: _editingProfile!.anonymousCommentsCount,
        anonymousQuestionCount: _editingProfile!.anonymousQuestionCount,
        currentRank: _editingProfile!.currentRank,
        currentTitle: _editingProfile!.currentTitle,
        rankChangeDate: _editingProfile!.rankChangeDate,
        titleChangeDate: _editingProfile!.titleChangeDate,
        isRankEligible: _editingProfile!.isRankEligible,
        rankEvaluationCount: _editingProfile!.rankEvaluationCount,
        receiveRankUpdateNotifications:
            _editingProfile!.receiveRankUpdateNotifications,
        receiveTitleUpdateNotifications:
            _editingProfile!.receiveTitleUpdateNotifications,
        role: _editingProfile!.role,
        title: _editingProfile!.title,
        stats: _editingProfile!.stats,
        subscription: _editingProfile!.subscription,
      );

      _editingProfile = UserProfile.getDocumentFromData(
        updatedData,
        _editingProfile!.reference,
      );
      _hasChanges = true;
    }

    if (!_hasChanges) {
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(
      profile: _editingProfile!,
    );

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
}
