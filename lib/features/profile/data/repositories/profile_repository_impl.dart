import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/models/profile_info.dart';
import '../datasources/interfaces/i_profile_datasource.dart';

/// ProfileRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 6 대규모 정리** (2025-01-21):
/// - 20개 → 3개 메서드로 축소 (85% 감소)
/// - 프로필 완성도 + 경량 조회 메서드만 보존
/// - IStorageDataSource 의존성 제거 (uploadProfilePhoto 삭제로 인해)
///
/// **Phase 6 복원** (2025-01-21):
/// - getProfileInfo() 복원 (성능 최적화 필수 기능)
///
/// **책임**:
/// - DataSource를 통한 프로필 경량 조회
/// - DataSource를 통한 프로필 완성도 확인
/// - Map → Domain Model 변환
/// - 에러 처리
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _dataSource;

  ProfileRepositoryImpl({
    required IProfileDataSource dataSource,
  }) : _dataSource = dataSource;

  // ============= ProfileInfo 관리 =============

  @override
  Future<ProfileInfo?> getProfileInfo(String userId) async {
    final data = await _dataSource.getProfileInfoData(userId);
    if (data == null) return null;

    // DataSource returns serialized Map compatible with fromJson
    return ProfileInfo.fromJson(data);
  }

  // TODO: 2025-01-21 삭제됨 - 스트림 및 업데이트 메서드
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - getProfileInfoStream() → 스트림 미사용, Future 조회만 사용
  //   - updateProfileInfo() → UpdateUserProfileUseCase 생성 필요

  // ============= UserSettings 관리 =============
  // TODO: 2025-01-21 삭제됨 - IUserRepository 사용 또는 UseCase 생성
  //
  // 삭제된 메서드 (3개, 호출처 0건):
  //   - getUserSettings() → IUserRepository.getUserSettings() 사용
  //   - getUserSettingsStream() → 스트림 미사용
  //   - updateUserSettings() → UpdateUserSettingsUseCase 존재

  // ============= UserStats 관리 =============
  // TODO: 2025-01-21 삭제됨 - IUserRepository 사용 또는 Voting Feature에서 구현 예정
  //
  // 삭제된 메서드 (3개, 호출처 0건):
  //   - getUserStats() → IUserRepository.getUserStats() 중복
  //   - getUserStatsStream() → 스트림 미사용
  //   - updateUserStats() → Voting Feature에서 구현 예정

  // ============= 필드 업데이트 =============
  // TODO: 2025-01-21 삭제됨 - 미래 기능
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - updateProfileField() → 단일 필드 업데이트 미래 기능
  //   - updateProfileFields() → 다중 필드 업데이트 미래 기능

  // ============= 프로필 사진 관리 =============
  // TODO: 2025-01-21 삭제됨 - UseCase 사용
  //
  // 삭제된 메서드 (2개, 호출처 0건):
  //   - uploadProfilePhoto() → UploadProfileImageUseCase 사용 (IProfileStorageRepository)
  //   - deleteProfilePhoto() → DeleteProfileImageUseCase 생성 필요

  // ============= 프로필 완성도 =============

  @override
  Future<bool> isProfileComplete(String userId) async {
    return await _dataSource.isProfileComplete(userId);
  }

  @override
  Future<double> getProfileCompletionPercentage(String userId) async {
    return await _dataSource.getProfileCompletionPercentage(userId);
  }

  // TODO: 2025-01-21 삭제됨
  // 삭제된 메서드 (1개, 호출처 0건):
  //   - getProfileCompletion() → 미래 기능 (완성도 상세 정보)

  // TODO: 2025-01-21 삭제됨
  // 삭제된 메서드 (1개, 호출처 0건):
  //   - getUserInterests() → GetUserInterestsUseCase 사용 (IInterestsRepository)

  // ============= 검색 및 추천 =============
  // TODO: 2025-01-21 삭제됨 - Search Feature 구현 시 재생성
  //
  // 삭제된 메서드 (2개 + UseCase 2개 삭제):
  //   - searchProfiles() → SearchProfilesUseCase 삭제됨
  //   - getSuggestedProfiles() → GetSuggestedProfilesUseCase 삭제됨
  //
  // **향후 재구현 시**:
  //   - Search Feature 별도 구현
  //   - Algolia 또는 Firestore Query 사용
  //   - 거리 기반 검색 (GeoPoint + Haversine)
  //   - 관심사/나이/성별 필터링

  // ============= 소셜 기능 =============
  // TODO: 2025-01-21 삭제됨 - Social Feature 구현 시 재생성
  //
  // 삭제된 메서드 (4개 + UseCase 2개 삭제):
  //   - blockUser() → BlockUserUseCase 삭제됨
  //   - unblockUser() → UseCase 미생성, 삭제됨
  //   - getBlockedUsers() → UseCase 미생성, 삭제됨
  //   - reportUser() → ReportUserUseCase 삭제됨
  //
  // **향후 재구현 시**:
  //   - Social Feature 별도 구현
  //   - Firestore 서브컬렉션 (blockedUsers, reports)
  //   - 차단 사용자 필터링 로직
  //   - 신고 사유 분류 시스템
}
