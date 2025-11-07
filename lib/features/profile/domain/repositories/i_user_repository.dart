import 'package:fpdart/fpdart.dart';
import '../entities/user_profile.dart';
import '../entities/user_settings.dart';
import '../failures/profile_failure.dart';

/// Repository interface for User-related operations (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20 Phase 3):
/// - Firebase 타입 제거: CollectionReference, DocumentReference, Query 제거
/// - 모든 메서드가 String uid 기반으로 변경
/// - 레거시 Query 메서드들 @Deprecated 처리
/// - Clean Architecture 원칙 준수: Domain Layer는 Infrastructure에 의존하지 않음
abstract class IUserRepository {
  // ============= Basic CRUD Operations =============

  /// 사용자 조회 (UserProfile)
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 사용자 프로필
  /// - `Left(ProfileFailure.profileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> getUserByUid(String uid);

  /// 사용자 조회 (alias for getUserByUid)
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 사용자 프로필
  /// - `Left(ProfileFailure.profileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> getUser(String userId);

  // ============= 🆕 Real-time Streaming Operations =============

  /// 사용자 프로필 실시간 감시
  ///
  /// **Use Case**: 다른 사용자의 프로필을 볼 때 실시간 업데이트
  /// - 프로필 사진 변경 시 즉시 반영
  /// - 닉네임, 소개글 변경 시 자동 업데이트
  /// - 관심사, 직업 정보 변경 시 동기화
  ///
  /// **Real-World Scenario**:
  /// ```
  /// 시나리오: 철수가 프로필 사진을 변경하는데, 영희가 철수 프로필을 보고 있음
  ///
  /// T+0s   영희: 철수 프로필 화면 진입 → watchUserProfile('cheolsu_id') 시작
  /// T+0s   영희: 현재 프로필 사진 A 표시
  /// T+10s  철수: 프로필 사진 B로 변경 → Firestore 업데이트
  /// T+10.2s 영희: 자동으로 사진 B 표시! 🎉 (수동 새로고침 불필요)
  /// ```
  ///
  /// **Example**:
  /// ```dart
  /// // UI에서 사용
  /// final stream = repository.watchUserProfile('user_123');
  ///
  /// stream.listen((profile) {
  ///   if (profile != null) {
  ///     print('Profile updated: ${profile.displayName}');
  ///     print('Photo: ${profile.photoUrl}');
  ///   }
  /// });
  /// ```
  ///
  /// **Returns**: Stream<UserProfile?>
  /// - null: 사용자가 존재하지 않거나 삭제됨
  /// - UserProfile: 실시간 업데이트되는 프로필 데이터
  ///
  /// **Performance**:
  /// - Firestore WebSocket 기반 실시간 리스닝
  /// - 문서 변경 시에만 이벤트 발생 (불필요한 읽기 없음)
  /// - 자동 재연결 (네트워크 끊김 시)
  ///
  /// **Added**: 2025-01-20 Profile Feature Real-time Sync
  Stream<UserProfile?> watchUserProfile(String userId);

  /// 사용자 생성
  ///
  /// **Returns**:
  /// - `Right(unit)`: 생성 성공
  /// - `Left(ProfileFailure)`: 생성 실패
  Future<Either<ProfileFailure, Unit>> createUser(UserProfile user);

  /// 사용자 업데이트 (Map)
  ///
  /// **Parameters**:
  /// - `uid`: 사용자 ID
  /// - `data`: 업데이트할 데이터
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  /// - `Left(ProfileFailure.duplicateOperation)`: 이미 처리된 작업
  Future<Either<ProfileFailure, Unit>> updateUser(
    String uid,
    Map<String, dynamic> data, {
    String? eventId,
  });

  /// 사용자 프로필 업데이트 (UserProfile)
  ///
  /// **Parameters**:
  /// - `user`: 업데이트할 프로필
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  /// - `Left(ProfileFailure.duplicateOperation)`: 이미 처리된 작업
  Future<Either<ProfileFailure, Unit>> updateUserProfile(
    UserProfile user, {
    String? eventId,
  });

  /// 사용자 삭제
  ///
  /// **Parameters**:
  /// - `uid`: 삭제할 사용자 ID
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(unit)`: 삭제 성공
  /// - `Left(ProfileFailure)`: 삭제 실패
  /// - `Left(ProfileFailure.duplicateOperation)`: 이미 처리된 작업
  Future<Either<ProfileFailure, Unit>> deleteUser(
    String uid, {
    String? eventId,
  });

  /// 사용자 존재 여부 확인
  ///
  /// **Returns**:
  /// - `Right(true)`: 사용자 존재
  /// - `Right(false)`: 사용자 없음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, bool>> userExists(String uid);

  // ============= Search & Query Operations =============
  // TODO: 2025-01-21 삭제됨 - Feature 책임 분리
  //
  // Search 관련:
  //   - ISearchRepository.searchUsers() 사용 (Search Feature)
  //   - 참고: lib/features/search/domain/repositories/i_search_repository.dart:54-58
  //
  // Friends 관련:
  //   - IFriendsRepository.getFriendProfiles() 사용
  //   - IFriendsRepository.getFriendProfilesStream() 사용
  //   - 참고: lib/features/profile/domain/repositories/i_friends_repository.dart:28,31
  //
  // 삭제된 메서드 (호출처 0건):
  //   - searchUsersByName() → Search Feature로 이동
  //   - getUsersByIds() → 내부 헬퍼 메서드 (불필요)
  //   - getUserFriends() → IFriendsRepository 사용
  //   - queryFriendsList() → IFriendsRepository 사용

  // ============= Points & Ranking Operations =============
  // TODO: 향후 구현 예정 (2025-01-20 삭제됨)
  // - updateUserPoints(): 투표 시 포인트 증가 로직
  // - updateUserRanking(): 포인트 기반 랭킹 업데이트
  // 현재는 필드만 유지하고 UI에서 표시만 가능
  // 참고: ProfilePointsCard는 계속 작동함 (profile_page_widget.dart:160)

  // ============= Adapter Methods =============
  // TODO: 2025-01-21 삭제됨 - Migration Scaffolding 제거
  //
  // Bundle 관련:
  //   - UserProfileAdapter는 Repository 내부에서만 사용 (유효)
  //   - 공개 Bundle 메서드는 호출처 0건으로 제거됨
  //
  // 삭제된 메서드 (호출처 0건):
  //   - getUserBundleByUid() → UserProfileAdapter는 내부 전용
  //   - updateUserWithBundle() → updateUserProfile() 직접 사용
  //   - createUserFromBundle() → createUser() 직접 사용

  // ============= ProfileInfo & Stats 조회 =============
  // TODO: 2025-01-20 삭제됨 - IProfileRepository 사용 권장
  //
  // ProfileInfo 관련:
  //   - IProfileRepository.getProfileInfo() 사용
  //   - GetProfileInfoUseCase → IProfileRepository
  //   - 참고: lib/features/profile/domain/repositories/i_profile_repository.dart:11
  //
  // UserStats 관련:
  //   - IProfileRepository.getUserStats() 사용
  //   - 참고: lib/features/profile/domain/repositories/i_profile_repository.dart:29
  //
  // 삭제된 메서드 (호출처 0건):
  //   - getUserProfileInfo() → getProfileInfo() 사용
  //   - getUserStats() → getUserStats() 사용

  /// UserSettings 조회
  ///
  /// **Returns**:
  /// - `Right(UserSettings)`: 사용자 설정
  /// - `Left(ProfileFailure.profileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String uid);

  /// UserSettings 업데이트
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `settings`: 업데이트할 설정
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  /// - `Left(ProfileFailure.duplicateOperation)`: 이미 처리된 작업
  Future<Either<ProfileFailure, Unit>> updateUserSettings(
    String userId,
    Map<String, dynamic> settings, {
    String? eventId,
  });

  // ============= Auth 데이터 조회 =============
  // TODO: 2025-01-21 삭제됨 - AuthContract 사용 권장
  //
  // Auth 정보 조회:
  //   - AuthContract.getCurrentUserId() - uid
  //   - AuthContract.getCurrentUserEmail() - email
  //   - AuthContract.currentUserDisplayName - displayName
  //   - AuthContract.currentUserPhoto - photoUrl
  //   - AuthContract.currentPhoneNumber - phoneNumber
  //   - AuthContract.isEmailVerified - isEmailVerified
  //   - AuthContract.isAnonymous - isAnonymous
  //   - 참고: lib/app/contracts/auth_contract.dart
  //
  // 삭제된 메서드 (호출처 0건):
  //   - getAuthUserData() → AuthContract의 개별 getter 사용

  // ============= Query Methods =============
  // TODO: 향후 구현 예정 (2025-01-21 삭제됨)
  //
  // Admin Dashboard 관련:
  //   - queryUsers() - 사용자 목록 조회
  //   - queryUsersStream() - 사용자 목록 스트림
  //   - getUsersCount() - 사용자 수 통계
  //
  // 현재 상태:
  //   - 호출처 0건으로 삭제됨
  //   - Admin 페이지 미구현 상태
  //
  // 향후 구현 시:
  //   - Admin Dashboard 구현 후
  //   - 사용자 관리 UI 필요 시
  //   - 통계 대시보드 구현 시
  //   - role 필드(admin/tester) 활용
  //   - 참고: lib/features/profile/data/repositories/user_repository_impl.dart (구현 예시)

  // ============= Characters & Interest Queries =============
  // TODO: 2025-01-20 삭제됨 - 별도 Repository 사용 권장
  //
  // Characters 관련:
  //   - ICharactersRepository 사용 (5개 메서드)
  //   - CharactersProvider → 3개 UseCases
  //   - 참고: lib/features/profile/domain/repositories/i_characters_repository.dart
  //
  // Interest 관련:
  //   - IInterestsRepository 사용 (5개 메서드)
  //   - InterestsProvider → 2개 UseCases
  //   - 참고: lib/features/profile/domain/repositories/i_interests_repository.dart
  //
  // 삭제된 메서드 (호출처 0건):
  //   - queryCharacters(), getCharactersCount()
  //   - queryInterests(), getInterestsCount()

  // ============= Current User Operations (Phase 2: Clean Architecture) =============

  /// 현재 로그인한 사용자 프로필 조회
  ///
  /// **Phase 2**: AuthContract를 통해 현재 사용자 ID 획득
  /// Repository Implementation에서 AuthContract 주입받아 사용
  /// Presentation 레이어는 이 메서드만 호출하면 됨
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 현재 사용자 프로필
  /// - `Left(ProfileFailure.profileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> getCurrentUserProfile();

  /// 현재 로그인한 사용자 프로필 업데이트
  ///
  /// **Phase 2**: 보안 검증 포함
  /// - 현재 사용자 ID와 업데이트하려는 프로필 ID 일치 여부 검증
  /// - 불일치 시 Exception 발생
  ///
  /// **Returns**:
  /// - `Right(unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, Unit>> updateCurrentUserProfile(UserProfile user);
}
