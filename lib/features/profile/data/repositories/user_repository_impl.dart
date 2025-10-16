import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/utils/app_utils.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/repositories/i_user_repository.dart';
import '../adapters/user_profile_adapter.dart';
import '../dto/user_profile_dto.dart';
import '/app/contracts/auth_contract.dart';
import '/app/contracts/user_contract.dart';

/// Implementation of user repository (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20 Phase 4):
/// - DTO 패턴 전면 도입: UserProfileDto, CharacterDto, InterestDto 사용
/// - Firebase 의존성 Data Layer로 격리
/// - fromSnapshot, createUserProfileData 등 레거시 메서드 제거
/// - Interface 변경사항 100% 반영
/// - CollectionReference를 private으로 관리
///
/// **Phase 2 추가 (2025-01-20)**:
/// - AuthContract 주입으로 현재 사용자 작업 지원
/// - getCurrentUserProfile(), updateCurrentUserProfile() 구현
/// - 싱글톤 패턴 유지하면서 의존성 주입 구조 적용
///
/// **Phase 6 추가 (2025-01-21)**:
/// - UserContract 구현으로 다른 Feature들에게 프로필 접근 제공
/// - Auth Feature의 프로필 생성/수정/삭제를 Profile Feature로 이관
class UserRepositoryImpl implements IUserRepository, UserContract {
  final AuthContract _authContract;

  static UserRepositoryImpl? _instance;

  /// 싱글톤 인스턴스 접근
  ///
  /// **주의**: initialize()를 먼저 호출해야 함
  static UserRepositoryImpl get instance {
    if (_instance == null) {
      throw StateError(
        'UserRepositoryImpl not initialized. '
        'Call UserRepositoryImpl.initialize(authContract) first in DI module.'
      );
    }
    return _instance!;
  }

  UserRepositoryImpl._(this._authContract);

  /// 싱글톤 초기화 (DI Module에서 호출)
  ///
  /// **사용 예시** (profile_module.dart):
  /// ```dart
  /// final authContract = sl<AuthContract>();
  /// UserRepositoryImpl.initialize(authContract);
  /// sl.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl.instance);
  /// ```
  static void initialize(AuthContract authContract) {
    _instance = UserRepositoryImpl._(authContract);
  }

  // ============= Private Collection References =============
  CollectionReference get _usersCollection =>
      FirebaseFirestore.instance.collection('users');

  // ============= Helper Methods =============

  /// Convert GeoPoint to LatLng
  LatLng? _geoPointToLatLng(GeoPoint? geoPoint) {
    if (geoPoint == null) return null;
    return LatLng(geoPoint.latitude, geoPoint.longitude);
  }

  /// Convert LatLng to GeoPoint
  GeoPoint? _latLngToGeoPoint(LatLng? latLng) {
    if (latLng == null) return null;
    return GeoPoint(latLng.latitude, latLng.longitude);
  }

  /// Convert UserProfileDto to UserProfile domain model
  UserProfile _dtoToDomain(UserProfileDto dto) {
    return UserProfile(
      uid: dto.uid ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName,
      photoUrl: dto.photoUrl,
      phoneNumber: dto.phoneNumber,
      location: _geoPointToLatLng(dto.location),
      shortDescription: dto.shortDescription,
      gender: dto.gender,
      dateOfBirth: dto.dateOfBirth,
      language: dto.language,
      createdTime: dto.createdTime,
      lastActive: dto.lastActive,
      lastActiveTime: dto.lastActiveTime,
      pointsA: dto.pointsA ?? 0,
      pointsQ: dto.pointsQ ?? 0,
      totalAPoints: dto.totalAPoints ?? 0,
      totalQPoints: dto.totalQPoints ?? 0,
      interests: dto.interests ?? const [],
      expertise: dto.expertise ?? const [],
      hobbies: dto.hobbies ?? const [],
      jobCategory: dto.jobCategory,
      jobName: dto.jobName,
      isPremiumUser: dto.isPremiumUser ?? false,
      anonymousPostsCount: dto.anonymousPostsCount ?? 0,
      anonymousCommentsCount: dto.anonymousCommentsCount ?? 0,
      anonymousQuestionCount: dto.anonymousQuestionCount ?? 0,
      currentRank: dto.currentRank,
      currentTitle: dto.currentTitle,
      rankChangeDate: dto.rankChangeDate,
      titleChangeDate: dto.titleChangeDate,
      isRankEligible: dto.isRankEligible ?? false,
      rankEvaluationCount: dto.rankEvaluationCount ?? 0,
      rankHistory: dto.rankHistory ?? const [],
      titleHistory: dto.titleHistory ?? const [],
      receiveRankUpdateNotifications: dto.receiveRankUpdateNotifications ?? false,
      receiveTitleUpdateNotifications: dto.receiveTitleUpdateNotifications ?? false,
      friends: dto.friends ?? const [],
      activeChats: dto.activeChats ?? const [],
      groupChats: dto.groupChats ?? const [],
      role: dto.role,
      title: dto.title,
      stats: dto.stats ?? const {},
      subscription: dto.subscription ?? const {},
    );
  }

  /// Convert UserProfile domain model to UserProfileDto
  UserProfileDto _domainToDto(UserProfile user) {
    return UserProfileDto(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      location: _latLngToGeoPoint(user.location),
      shortDescription: user.shortDescription,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      language: user.language,
      createdTime: user.createdTime,
      lastActive: user.lastActive,
      lastActiveTime: user.lastActiveTime,
      pointsA: user.pointsA,
      pointsQ: user.pointsQ,
      totalAPoints: user.totalAPoints,
      totalQPoints: user.totalQPoints,
      interests: user.interests,
      expertise: user.expertise,
      hobbies: user.hobbies,
      jobCategory: user.jobCategory,
      jobName: user.jobName,
      isPremiumUser: user.isPremiumUser,
      anonymousPostsCount: user.anonymousPostsCount,
      anonymousCommentsCount: user.anonymousCommentsCount,
      anonymousQuestionCount: user.anonymousQuestionCount,
      currentRank: user.currentRank,
      currentTitle: user.currentTitle,
      rankChangeDate: user.rankChangeDate,
      titleChangeDate: user.titleChangeDate,
      isRankEligible: user.isRankEligible,
      rankEvaluationCount: user.rankEvaluationCount,
      rankHistory: user.rankHistory,
      titleHistory: user.titleHistory,
      receiveRankUpdateNotifications: user.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: user.receiveTitleUpdateNotifications,
      friends: user.friends,
      activeChats: user.activeChats,
      groupChats: user.groupChats,
      role: user.role,
      title: user.title,
      stats: user.stats,
      subscription: user.subscription,
    );
  }

  // ============= Basic CRUD Operations =============

  @override
  Future<UserProfile?> getUserByUid(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists) return null;

      final data = doc.data() as Map<String, dynamic>;
      final dto = UserProfileDto.fromFirestore(data);
      return _dtoToDomain(dto);
    } catch (e) {
      print('Error getting user by UID: $e');
      return null;
    }
  }

  @override
  Future<UserProfile?> getUser(String userId) => getUserByUid(userId);

  // ============= 🆕 Real-time Streaming Operations =============

  @override
  Stream<UserProfile?> watchUserProfile(String userId) {
    try {
      // Firestore snapshots()로 실시간 리스닝
      // 👇 이 메서드가 WebSocket 기반 실시간 동기화의 핵심!
      return _usersCollection
          .doc(userId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              print('User not found: $userId');
              return null;
            }

            // Firestore Document → DTO → Domain Model 파이프라인
            final data = snapshot.data() as Map<String, dynamic>;
            final dto = UserProfileDto.fromFirestore(data);
            return _dtoToDomain(dto);
          })
          .handleError((error) {
            print('Stream error for user $userId: $error');
            return null;
          });
    } catch (e) {
      print('Error creating user stream for $userId: $e');
      // 에러 발생 시에도 안정적인 Stream 반환
      return Stream.value(null);
    }
  }

  @override
  Future<void> createUser(UserProfile user) async {
    final dto = _domainToDto(user);
    final data = dto.toFirestore();

    // Add createdTime if not present
    if (!data.containsKey('createdTime')) {
      data['createdTime'] = Timestamp.fromDate(getCurrentTimestamp());
    }

    await _usersCollection.doc(user.uid).set(data);
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _usersCollection.doc(uid).update(data);
  }

  @override
  Future<void> updateUserProfile(UserProfile user) async {
    final dto = _domainToDto(user);
    final data = dto.toFirestore();

    // Add lastActiveTime
    data['lastActiveTime'] = Timestamp.fromDate(getCurrentTimestamp());

    await _usersCollection.doc(user.uid).update(data);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _usersCollection.doc(uid).delete();
  }

  @override
  Future<bool> userExists(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    return doc.exists;
  }

  // ============= Search & Query Operations =============
  // TODO: 2025-01-21 삭제됨 - Feature 책임 분리
  //
  // Search 관련:
  //   - ISearchRepository.searchUsers() 사용 (Search Feature)
  //   - SearchRepositoryImpl.searchUsers() 구현
  //   - 참고: lib/features/search/data/repositories/search_repository_impl.dart
  //
  // Friends 관련:
  //   - IFriendsRepository.getFriendProfiles() 사용
  //   - IFriendsRepository.getFriendProfilesStream() 사용
  //   - 참고: lib/features/profile/domain/repositories/i_friends_repository.dart:28,31
  //
  // 삭제된 메서드 구현 (호출처 0건):
  //   - searchUsersByName() - Firestore displayName 쿼리 (14줄)
  //   - getUserFriends() - friends 배열 조회 (6줄)
  //   - getUsersByIds() - 대량 조회 청크 처리 (24줄)
  //   - queryFriendsList() - TODO 상태 빈 스트림 (5줄)

  // ============= Points & Ranking Operations =============
  // TODO: 향후 구현 예정 (2025-01-20 삭제됨)
  // - updateUserPoints(): 투표 시 포인트 증가 로직
  // - updateUserRanking(): 포인트 기반 랭킹 업데이트
  // 참고: Interface 정의도 함께 삭제됨 (i_user_repository.dart:57-62)

  // ============= Adapter Methods =============
  // TODO: 2025-01-21 삭제됨 - Migration Scaffolding 제거
  //
  // Bundle 관련:
  //   - UserProfileAdapter.toDomainModels() 내부 사용 유지 (getUserSettings만 사용)
  //   - UserProfileAdapter.createBundle() 제거됨 (호출처 0건)
  //   - UserProfileAdapter.bundleToLegacy() 제거됨 (호출처 0건)
  //
  // 삭제된 메서드 구현 (호출처 0건):
  //   - getUserBundleByUid() - UserProfile → Bundle 변환 (5줄)
  //   - updateUserWithBundle() - Bundle → UserProfile 변환 후 업데이트 (4줄)
  //   - createUserFromBundle() - Bundle → UserProfile 변환 후 생성 (4줄)

  // ============= ProfileInfo & Stats 조회 =============
  // TODO: 2025-01-20 삭제됨 - IProfileRepository 사용 권장
  //
  // ProfileInfo 관련:
  //   - ProfileRepositoryImpl.getProfileInfo() 사용
  //   - 참고: lib/features/profile/data/repositories/profile_repository_impl.dart:29
  //
  // UserStats 관련:
  //   - ProfileRepositoryImpl.getUserStats() 사용
  //   - 참고: lib/features/profile/data/repositories/profile_repository_impl.dart:156
  //
  // 삭제된 메서드 (호출처 0건):
  //   - getUserProfileInfo()
  //   - getUserStats()

  @override
  Future<UserSettings?> getUserSettings(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    return bundle.settings;
  }

  @override
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) {
    return updateUser(userId, settings);
  }

  // ============= Auth 데이터 조회 =============
  // TODO: 2025-01-21 삭제됨 - AuthContract 사용 권장
  //
  // Auth 정보는 AuthContract를 통해 직접 조회:
  //   - Repository에서 AuthContract 주입받아 사용
  //   - Firestore users 컬렉션 조회 불필요
  //   - 참고: lib/app/contracts/auth_contract.dart
  //
  // 삭제된 메서드 구현 (호출처 0건):
  //   - getAuthUserData() - UserProfile → auth Map 변환 (7줄)

  // ============= Query Methods =============
  // TODO: 향후 구현 예정 (2025-01-21 삭제됨)
  //
  // Admin Dashboard 관련:
  //   - Admin 페이지 미구현으로 삭제됨
  //   - role 필드(admin/tester) 존재
  //   - 테스트 계정 설정 완료
  //
  // 삭제된 메서드 구현 (호출처 0건):
  //   - queryUsers() - 사용자 목록 조회 (19줄)
  //   - queryUsersStream() - 사용자 목록 스트림 (19줄)
  //   - getUsersCount() - 사용자 수 통계 (4줄)
  //
  // 향후 구현 예시:
  //   ```dart
  //   Future<List<UserProfile>> queryUsers({int limit = -1}) async {
  //     Query query = _usersCollection;
  //     if (limit > 0) query = query.limit(limit);
  //     final snapshot = await query.get();
  //     return snapshot.docs.map((doc) {
  //       final data = doc.data() as Map<String, dynamic>;
  //       final dto = UserProfileDto.fromFirestore(data);
  //       return _dtoToDomain(dto);
  //     }).toList();
  //   }
  //
  //   Stream<List<UserProfile>> queryUsersStream({int limit = -1}) {
  //     Query query = _usersCollection;
  //     if (limit > 0) query = query.limit(limit);
  //     return query.snapshots().map((snapshot) {
  //       return snapshot.docs.map((doc) {
  //         final data = doc.data() as Map<String, dynamic>;
  //         final dto = UserProfileDto.fromFirestore(data);
  //         return _dtoToDomain(dto);
  //       }).toList();
  //     });
  //   }
  //
  //   Future<int> getUsersCount() async {
  //     final snapshot = await _usersCollection.count().get();
  //     return snapshot.count ?? 0;
  //   }
  //   ```

  // ============= Characters & Interest Queries =============
  // TODO: 2025-01-20 삭제됨 - 별도 Repository 사용 권장
  //
  // Characters 관련:
  //   - CharactersRepositoryImpl 사용
  //   - 참고: lib/features/profile/data/repositories/characters_repository_impl.dart
  //
  // Interest 관련:
  //   - InterestsRepositoryImpl 사용
  //   - 참고: lib/features/profile/data/repositories/interests_repository_impl.dart
  //
  // 삭제된 메서드 (호출처 0건):
  //   - queryCharacters(), getCharactersCount()
  //   - queryInterests(), getInterestsCount()

  // ============= Current User Operations (Phase 2) =============

  @override
  Future<UserProfile?> getCurrentUserProfile() async {
    final uid = _authContract.getCurrentUserId();
    if (uid == null || uid.isEmpty) {
      print('getCurrentUserProfile: No current user ID');
      return null;
    }

    try {
      return await getUserByUid(uid);
    } catch (e) {
      print('Error getting current user profile: $e');
      return null;
    }
  }

  @override
  Future<void> updateCurrentUserProfile(UserProfile user) async {
    final currentUid = _authContract.getCurrentUserId();

    if (currentUid == null || currentUid.isEmpty) {
      throw Exception('Cannot update profile: No current user logged in');
    }

    if (user.uid != currentUid) {
      throw Exception(
        'Security violation: Cannot update other user profile. '
        'Current user: $currentUid, Target user: ${user.uid}'
      );
    }

    return await updateUserProfile(user);
  }

  // ============= UserContract 구현 (Phase 6: 2025-01-21) =============
  // 다른 Feature들(특히 Auth Feature)이 프로필에 접근하기 위한 Contract 메서드들

  @override
  Future<void> createUserProfile({
    required String uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    // ✅ 기존 createUser 메서드 활용
    final user = UserProfile(
      uid: uid,
      email: email ?? '',
      displayName: displayName,
      photoUrl: photoUrl,
      phoneNumber: phoneNumber,
      createdTime: getCurrentTimestamp(),
      lastActive: getCurrentTimestamp(),
      role: 'user',
      isPremiumUser: false,
      pointsA: 0,
      pointsQ: 0,
      interests: const [],
      expertise: const [],
      hobbies: const [],
      friends: const [],
      activeChats: const [],
      groupChats: const [],
      anonymousPostsCount: 0,
      anonymousCommentsCount: 0,
      anonymousQuestionCount: 0,
      totalAPoints: 0,
      totalQPoints: 0,
      isRankEligible: false,
      rankEvaluationCount: 0,
      rankHistory: const [],
      titleHistory: const [],
      receiveRankUpdateNotifications: false,
      receiveTitleUpdateNotifications: false,
      stats: const {},
      subscription: const {},
    );

    await createUser(user);
  }

  @override
  Future<void> updateUserProfileData(String uid, Map<String, dynamic> data) {
    // ✅ 기존 updateUser 메서드 활용
    return updateUser(uid, data);
  }

  @override
  Future<void> deleteUserProfile(String uid) {
    // ✅ 기존 deleteUser 메서드 활용
    return deleteUser(uid);
  }

  @override
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    // ✅ 기존 getUserByUid 활용 후 Map으로 변환
    final user = await getUserByUid(userId);
    if (user == null) return null;

    final dto = _domainToDto(user);
    return dto.toFirestore();
  }

  @override
  Future<String?> getUserDisplayName(String userId) async {
    final user = await getUserByUid(userId);
    return user?.displayName;
  }

  @override
  Future<String?> getUserPhotoUrl(String userId) async {
    final user = await getUserByUid(userId);
    return user?.photoUrl;
  }

  @override
  Future<List<String>> getUserInterests(String userId) async {
    final user = await getUserByUid(userId);
    return user?.interests ?? const [];
  }

  @override
  Future<List<String>> getUserExpertise(String userId) async {
    final user = await getUserByUid(userId);
    return user?.expertise ?? const [];
  }

  @override
  Future<Map<String, int>> getUserPoints(String userId) async {
    final user = await getUserByUid(userId);
    if (user == null) {
      return {'pointsA': 0, 'pointsQ': 0};
    }
    return {
      'pointsA': user.pointsA,
      'pointsQ': user.pointsQ,
    };
  }

  @override
  Future<bool> isPremiumUser(String userId) async {
    final user = await getUserByUid(userId);
    return user?.isPremiumUser ?? false;
  }

  @override
  Future<String?> getUserRole(String userId) async {
    final user = await getUserByUid(userId);
    return user?.role;
  }
}
