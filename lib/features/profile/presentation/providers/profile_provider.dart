import 'package:flutter/foundation.dart';
import 'dart:io';
import '../../domain/usecases/profile/get_user_profile_usecase.dart';
import '../../domain/usecases/profile/get_current_user_profile_usecase.dart';
import '../../domain/usecases/profile/update_user_profile_usecase.dart';
import '../../domain/usecases/profile/upload_profile_image_usecase.dart';
import '../../domain/usecases/profile/get_profile_completion_usecase.dart';
import '../../domain/usecases/profile/get_profile_info_usecase.dart';
import '../../domain/usecases/profile/watch_user_profile_usecase.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/profile_info.dart';

/// 프로필 Provider (Clean Architecture v4.0)
///
/// **책임**:
/// - 프로필 상태 관리
/// - UseCase를 통한 비즈니스 로직 실행
/// - UI 상태 업데이트 (로딩, 에러)
///
/// **Phase 2 추가** (2025-01-20):
/// - GetCurrentUserProfileUseCase 추가
/// - loadCurrentUserProfile(), updateCurrentUserLanguage() 메서드 추가
/// - UI는 현재 사용자 ID를 몰라도 프로필 작업 가능
class ProfileProvider extends ChangeNotifier {
  final GetUserProfileUseCase _getProfileUseCase;
  final GetCurrentUserProfileUseCase _getCurrentProfileUseCase;
  final UpdateUserProfileUseCase _updateProfileUseCase;
  final UploadProfileImageUseCase _uploadImageUseCase;
  final GetProfileCompletionUseCase _getProfileCompletionUseCase;
  final GetProfileInfoUseCase _getProfileInfoUseCase;
  final WatchUserProfileUseCase _watchProfileUseCase;

  UserProfile? _profile;
  ProfileInfo? _profileInfo;
  bool _isLoading = false;
  String? _errorMessage;
  double? _completionPercentage;
  bool _isLoadingCompletion = false;

  ProfileProvider({
    required GetUserProfileUseCase getProfileUseCase,
    required GetCurrentUserProfileUseCase getCurrentProfileUseCase,
    required UpdateUserProfileUseCase updateProfileUseCase,
    required UploadProfileImageUseCase uploadImageUseCase,
    required GetProfileCompletionUseCase getProfileCompletionUseCase,
    required GetProfileInfoUseCase getProfileInfoUseCase,
    required WatchUserProfileUseCase watchProfileUseCase,
  })  : _getProfileUseCase = getProfileUseCase,
        _getCurrentProfileUseCase = getCurrentProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _uploadImageUseCase = uploadImageUseCase,
        _getProfileCompletionUseCase = getProfileCompletionUseCase,
        _getProfileInfoUseCase = getProfileInfoUseCase,
        _watchProfileUseCase = watchProfileUseCase;

  // Getters
  UserProfile? get profile => _profile;
  ProfileInfo? get profileInfo => _profileInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  double? get completionPercentage => _completionPercentage;
  bool get isLoadingCompletion => _isLoadingCompletion;

  /// 프로필 로드 (특정 사용자)
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

  /// 현재 사용자 프로필 로드 (Phase 2: Clean Architecture)
  ///
  /// **장점**:
  /// - UI는 현재 사용자 ID를 몰라도 됨
  /// - Repository가 AuthContract로 자동으로 ID 획득
  /// - 코드 간결화: `loadCurrentUserProfile()` vs `loadProfile(currentUserUid)`
  Future<void> loadCurrentUserProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getCurrentProfileUseCase.execute();

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

  /// 프로필 업데이트
  Future<void> updateProfile(UserProfile profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(profile);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
      },
      (_) {
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
        // UserProfile은 immutable이므로 copyWith()로 업데이트
        if (_profile != null) {
          final updatedProfile = _profile!.copyWith(
            photoUrl: imageUrl,
          );

          // UseCase를 통해 업데이트
          await _updateProfileUseCase.execute(updatedProfile);

          // 업데이트 후 다시 로드하여 최신 상태 반영
          await loadProfile(userId);
        }
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  /// 현재 사용자 언어 업데이트 (Phase 2: Clean Architecture)
  ///
  /// **사용 예시**:
  /// ```dart
  /// await profileProvider.updateCurrentUserLanguage('ko');
  /// ```
  ///
  /// **장점**:
  /// - 언어 변경만 간단하게 처리
  /// - 내부적으로 loadCurrentUserProfile() → copyWith() → updateProfile() 플로우
  Future<void> updateCurrentUserLanguage(String language) async {
    // 1. 현재 프로필 로드 (캐시된 _profile이 없을 수 있으므로)
    if (_profile == null) {
      await loadCurrentUserProfile();
      if (_profile == null) {
        _errorMessage = '프로필을 불러올 수 없습니다';
        notifyListeners();
        return;
      }
    }

    // 2. 언어 업데이트
    final updatedProfile = _profile!.copyWith(language: language);

    // 3. 프로필 업데이트
    await updateProfile(updatedProfile);
  }

  /// 프로필 완성도 조회 (Phase 6)
  ///
  /// **사용 예시**:
  /// ```dart
  /// await profileProvider.getProfileCompletion(userId);
  /// final completion = profileProvider.completionPercentage; // 66.67
  /// ```
  ///
  /// **완성도 계산 기준** (9개 필수 항목):
  /// - displayName, photoUrl, shortDescription
  /// - gender, dateOfBirth, location
  /// - interests, expertise, language
  Future<void> getProfileCompletion(String userId) async {
    _isLoadingCompletion = true;
    notifyListeners();

    final result = await _getProfileCompletionUseCase.execute(userId);

    result.fold(
      (failure) {
        debugPrint('Failed to get profile completion: ${failure.getUserMessage()}');
        _completionPercentage = null;
      },
      (percentage) {
        _completionPercentage = percentage;
      },
    );

    _isLoadingCompletion = false;
    notifyListeners();
  }

  /// 경량 프로필 정보 로드 (Phase 6.1: 성능 최적화)
  ///
  /// **사용 시나리오**:
  /// - UserInfoDisplayScreen (기본 정보만 표시)
  /// - Chat 사용자 리스트 (이름, 사진만 필요)
  /// - Search 결과 (프리뷰 카드)
  /// - 단순 프로필 화면 (포인트, 랭킹 불필요)
  ///
  /// **성능 비교**:
  /// | 메서드 | 필드 수 | 대역폭 | 사용처 |
  /// |--------|---------|--------|--------|
  /// | loadProfile() | 42개 | 2.5KB | 복잡한 화면 (편집, 통계) |
  /// | loadProfileInfo() | 10개 | 0.6KB | 단순 화면 (표시만) |
  ///
  /// **절감 효과**: 75% 대역폭 절감 (42 → 10 필드)
  ///
  /// **포함 필드 (10개)**:
  /// - Core: userId, displayName, photoUrl
  /// - Details: shortDescription, gender, dateOfBirth, language
  /// - Lists: interests[], expertise[]
  /// - Location: location (LatLng)
  ///
  /// **사용 예시**:
  /// ```dart
  /// // 단순 프로필 표시 화면
  /// await profileProvider.loadProfileInfo(userId);
  /// final profileInfo = profileProvider.profileInfo;
  ///
  /// Text(profileInfo?.displayName ?? 'Unknown');
  /// ```
  ///
  /// **Added**: 2025-01-20 Phase 6 Domain Layer 성능 최적화
  Future<void> loadProfileInfo(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _getProfileInfoUseCase.execute(userId);

    result.fold(
      (failure) {
        _errorMessage = failure.getUserMessage();
        _profileInfo = null;
      },
      (profileInfo) {
        _profileInfo = profileInfo;
        _errorMessage = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }


  // ============= 🆕 Real-time Streaming Operations =============

  /// 다른 사용자 프로필 실시간 감시
  ///
  /// **Use Case**: UserInfoDisplayScreen에서 사용
  /// - 다른 사용자의 프로필을 볼 때 실시간 업데이트
  /// - 프로필 사진 변경 시 즉시 반영
  /// - 닉네임, 소개글 변경 시 자동 업데이트
  ///
  /// **Real-World Scenario**:
  /// ```
  /// 시나리오: 철수가 프로필을 수정하는데, 영희가 철수 프로필을 보고 있음
  ///
  /// T+0s   영희: 철수 프로필 화면 진입
  ///        → watchOtherUserProfile('cheolsu_id') 시작
  ///        → StreamBuilder가 현재 프로필 표시
  ///
  /// T+10s  철수: 프로필 사진 + 소개글 수정
  ///        → updateUserProfile() 호출
  ///        → Firestore 문서 업데이트
  ///
  /// T+10.2s 영희: 자동으로 새 프로필 표시! 🎉
  ///        → Firestore가 스트림에 새 데이터 푸시
  ///        → StreamBuilder가 UI 리빌드
  ///        → 수동 새로고침 불필요
  /// ```
  ///
  /// **Example Usage**:
  /// ```dart
  /// // UI에서 사용
  /// final provider = Provider.of<ProfileProvider>(context, listen: false);
  /// final stream = provider.watchOtherUserProfile('user_123');
  ///
  /// return StreamBuilder<UserProfile?>(
  ///   stream: stream,
  ///   builder: (context, snapshot) {
  ///     if (snapshot.connectionState == ConnectionState.waiting) {
  ///       return ProfileLoadingIndicator();
  ///     }
  ///
  ///     if (snapshot.hasError) {
  ///       return ErrorMessage(message: snapshot.error.toString());
  ///     }
  ///
  ///     if (!snapshot.hasData || snapshot.data == null) {
  ///       return EmptyProfileMessage();
  ///     }
  ///
  ///     final profile = snapshot.data!;
  ///     return ProfileHeader(profile: profile);  // 자동 업데이트!
  ///   },
  /// );
  /// ```
  ///
  /// **Architecture Pattern**: Hybrid Provider + Stream
  /// - Stream: 지속적인 데이터 제공 (StreamBuilder 사용)
  /// - Provider: 에러 상태 관리 (notifyListeners() 호출)
  /// - Best of both worlds: 실시간 동기화 + 타입 안전한 에러 처리
  ///
  /// **Performance**:
  /// - Firestore WebSocket 기반 실시간 리스닝
  /// - 문서 변경 시에만 이벤트 발생 (불필요한 읽기 없음)
  /// - 자동 재연결 (네트워크 끊김 시)
  ///
  /// **Error Handling**:
  /// - 에러 발생 시 _errorMessage 업데이트
  /// - notifyListeners()로 Provider 리스너들에게 알림
  /// - StreamBuilder는 snapshot.hasError로 에러 감지 가능
  ///
  /// **Returns**: Stream<UserProfile?>
  /// - null: 사용자가 존재하지 않거나 삭제됨
  /// - UserProfile: 실시간 업데이트되는 프로필 데이터
  ///
  /// **Added**: 2025-01-20 Profile Feature Real-time Sync Implementation
  Stream<UserProfile?> watchOtherUserProfile(String userId) {
    return _watchProfileUseCase
        .execute(userId: userId)
        .map((result) => result.fold(
              (failure) {
                // Either의 Left (에러)
                _errorMessage = failure.getUserMessage();
                notifyListeners(); // Provider 리스너들에게 에러 알림
                return null;
              },
              (profile) {
                // Either의 Right (성공)
                _errorMessage = null;
                return profile;
              },
            ));
  }

}
