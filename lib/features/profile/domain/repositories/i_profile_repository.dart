import '../models/profile_info.dart';

/// Repository interface for profile operations (Clean Architecture v4.0)
///
/// **Phase 6 대규모 정리** (2025-01-21):
/// - 20개 → 3개 메서드로 축소 (85% 감소)
/// - 호출처 0건 메서드 완전 삭제
/// - DataSource 레벨 구현만 사용하는 메서드만 보존
///
/// **Phase 6 복원** (2025-01-21):
/// - getProfileInfo() 복원 (성능 최적화 필수 기능)
///
abstract class IProfileRepository {
  // ============= 프로필 완성도 =============

  /// 프로필 완성도 확인
  ///
  /// **사용처**: AccountManagementUseCase (Auth Feature)
  /// **구현**: DataSource 레벨에서 필수 필드 체크
  Future<bool> isProfileComplete(String userId);

  /// 프로필 완성도 퍼센트
  ///
  /// **사용처**: GetProfileCompletionUseCase, DataSource 내부
  /// **구현**: 필수 필드 개수 기반 계산
  Future<double> getProfileCompletionPercentage(String userId);

  // ============= 경량 프로필 조회 =============

  /// ProfileInfo 경량 조회 (10개 필드만)
  ///
  /// **사용처**: GetProfileInfoUseCase
  /// **성능**: UserProfile 대비 75% 대역폭 절감 (42개 → 10개 필드)
  /// **반환 필드**:
  /// - Core: userId, displayName, photoUrl, shortDescription
  /// - Details: gender, dateOfBirth, language
  /// - Lists: interests[], expertise[]
  /// - Location: location (LatLng)
  ///
  /// **반환**:
  /// - null: 사용자가 존재하지 않음
  /// - ProfileInfo: 경량 프로필 정보
  Future<ProfileInfo?> getProfileInfo(String userId);

  // ============= 삭제된 메서드 (2025-01-21) =============
  // TODO: 향후 재구현 가이드
  //
  // **ProfileInfo 관리** (2개 삭제):
  //   - getProfileInfoStream() → 스트림 미사용, Future 조회만 사용
  //   - updateProfileInfo() → UpdateUserProfileUseCase 사용
  //
  // **UserSettings 관리** (3개 삭제):
  //   - getUserSettings() → IUserRepository.getUserSettings() 사용
  //   - getUserSettingsStream() → 스트림 미사용
  //   - updateUserSettings() → UpdateUserSettingsUseCase 존재
  //
  // **UserStats 관리** (3개 삭제):
  //   - getUserStats() → IUserRepository.getUserStats() 중복
  //   - getUserStatsStream() → 스트림 미사용
  //   - updateUserStats() → Voting Feature에서 구현 예정
  //
  // **필드 업데이트** (2개 삭제):
  //   - updateProfileField() → 미래 기능 (단일 필드 업데이트)
  //   - updateProfileFields() → 미래 기능 (다중 필드 업데이트)
  //
  // **프로필 사진 관리** (2개 삭제):
  //   - uploadProfilePhoto() → UploadProfileImageUseCase 사용 (IProfileStorageRepository)
  //   - deleteProfilePhoto() → DeleteProfileImageUseCase 생성 필요
  //
  // **관심사 조회** (1개 삭제):
  //   - getUserInterests() → GetUserInterestsUseCase 사용 (IInterestsRepository)
  //
  // **프로필 완성도 상세** (1개 삭제):
  //   - getProfileCompletion() → 미래 기능 (완성도 상세 정보)
  //
  // **검색 및 추천** (2개 삭제 + UseCase 삭제):
  //   - searchProfiles() → Search Feature 구현 시 재생성
  //   - getSuggestedProfiles() → 추천 알고리즘 구현 시 재생성
  //
  // **소셜 기능** (4개 삭제 + UseCase 삭제):
  //   - blockUser() → Social Feature 구현 시 재생성
  //   - unblockUser() → Social Feature 구현 시 재생성
  //   - getBlockedUsers() → Social Feature 구현 시 재생성
  //   - reportUser() → Social Feature 구현 시 재생성
  //
  // **재구현 시 참고**:
  //   - ProfileRepositoryImpl 삭제된 구현 코드 참조
  //   - DataSource 레벨 메서드 존재 여부 확인
  //   - UseCase → Repository → DataSource 순서로 구현
}
