import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/core/utils/app_utils.dart';
import '/services/cache/unified_cache_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/entities/user_profile_extensions.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/failures/profile_failure.dart';
import '../../domain/repositories/i_user_repository.dart';

/// UserRepository 구현 (Clean Architecture v4.0)
///
/// **Phase 4: Firebase-Centric v2.0 전환** (2025-01-29):
/// - DTO/Adapter 제거 → Extension 패턴 사용
/// - FirebaseFirestore 직접 사용 (이미 적용됨)
/// - _mapFirebaseException() 메서드 추가
/// - debugPrint 로깅 추가
/// - Auth Feature 패턴 100% 일치
///
/// **Contract 패턴 폐기** (2025-11-09):
/// - AuthContract → FirebaseAuth 직접 사용
/// - Firebase-Centric v2.0: 중간 추상화 제거
///
/// **Phase 2 (2025-01-20)**:
/// - FirebaseAuth 주입으로 현재 사용자 작업 지원
/// - getCurrentUserProfile(), updateCurrentUserProfile() 구현
/// - 싱글톤 패턴 유지하면서 의존성 주입 구조 적용
///
/// **Phase 6 (2025-01-21)**:
/// - Auth Feature의 프로필 생성/수정/삭제를 Profile Feature로 이관
///
/// **책임**:
/// - Firebase SDK를 통한 직접 사용자 데이터 접근
/// - Extension으로 Entity 변환
/// - Firebase Exception → ProfileFailure 매핑
/// - 싱글톤 패턴으로 전역 접근 제공
/// - FirebaseAuth를 통한 현재 사용자 관리
class UserRepositoryImpl implements IUserRepository {
  final FirebaseAuth _auth;
  final UnifiedCacheService _cacheService;

  static UserRepositoryImpl? _instance;

  /// 싱글톤 인스턴스 접근
  ///
  /// **주의**: initialize()를 먼저 호출해야 함
  static UserRepositoryImpl get instance {
    if (_instance == null) {
      throw StateError(
        'UserRepositoryImpl not initialized. '
        'Call UserRepositoryImpl.initialize(auth, cacheService) first in DI module.'
      );
    }
    return _instance!;
  }

  UserRepositoryImpl._(this._auth, this._cacheService);

  /// 싱글톤 초기화 (DI Module에서 호출)
  ///
  /// **사용 예시** (profile_module.dart):
  /// ```dart
  /// final auth = FirebaseAuth.instance;
  /// final cacheService = UnifiedCacheService.instance;
  /// UserRepositoryImpl.initialize(auth, cacheService);
  /// sl.registerLazySingleton<IUserRepository>(() => UserRepositoryImpl.instance);
  /// ```
  static void initialize(
    FirebaseAuth auth,
    UnifiedCacheService cacheService,
  ) {
    _instance = UserRepositoryImpl._(auth, cacheService);
  }

  // ============= Private Firestore Instance =============
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // ============= Basic CRUD Operations =============

  @override
  Future<Either<ProfileFailure, UserProfile>> getUserByUid(String uid) async {
    try {
      debugPrint('[UserRepository] Getting user by UID: $uid');

      // 🔥 3-Layer Cache 우선 조회
      final cachedResult = await _cacheService.getUserProfile(uid);
      final cachedProfile = cachedResult.fold(
        (failure) => null,  // Cache miss
        (profile) => profile,  // Cache hit
      );

      if (cachedProfile != null) {
        debugPrint('[UserRepository] User loaded from CACHE: ${cachedProfile.displayName}');
        return right(cachedProfile);
      }

      // Cache Miss - Firestore 조회
      final doc = await _firestore.collection('users').doc(uid).get();

      if (!doc.exists) {
        debugPrint('[UserRepository] User not found: $uid');
        return left(ProfileFailure.profileNotFound(userId: uid));
      }

      // Extension으로 변환
      final profile = UserProfileFirestore.fromFirestore(doc);

      // 🔥 캐시에 저장
      await _cacheService.setUserProfile(uid, profile);

      debugPrint('[UserRepository] User loaded from FIRESTORE: ${profile.displayName}');
      return right(profile);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get user by UID: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, UserProfile>> getUser(String userId) => getUserByUid(userId);

  // ============= 🆕 Real-time Streaming Operations =============

  @override
  Stream<UserProfile?> watchUserProfile(String userId) {
    try {
      debugPrint('[UserRepository] Starting to watch user profile: $userId');

      // Firestore snapshots()로 실시간 리스닝
      // 👇 이 메서드가 WebSocket 기반 실시간 동기화의 핵심!
      return _firestore
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) {
            if (!snapshot.exists) {
              debugPrint('[UserRepository] User not found in stream: $userId');
              return null;
            }

            // Extension으로 변환 (Firestore Document → Domain Model)
            final profile = UserProfileFirestore.fromFirestore(snapshot);
            debugPrint('[UserRepository] User profile updated in stream: ${profile.displayName}');
            return profile;
          })
          .handleError((error) {
            debugPrint('[UserRepository] Stream error for user $userId: $error');
            return null;
          });
    } catch (e) {
      debugPrint('[UserRepository] Error creating user stream for $userId: $e');
      // 에러 발생 시에도 안정적인 Stream 반환
      return Stream.value(null);
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> createUser(UserProfile user) async {
    try {
      debugPrint('[UserRepository] Creating user: ${user.uid}');

      // Extension으로 변환
      final data = user.toFirestore();

      // Add createdTime if not present
      if (!data.containsKey('createdTime')) {
        data['createdTime'] = Timestamp.fromDate(getCurrentTimestamp());
      }

      // 직접 Firebase SDK 사용
      await _firestore.collection('users').doc(user.uid).set(data);

      debugPrint('[UserRepository] User created successfully: ${user.displayName}');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to create user: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      debugPrint('[UserRepository] Updating user: $uid');

      // Natural idempotency via deterministic userId
      await _firestore.collection('users').doc(uid).update(data);

      // 🔥 캐시 무효화 (업데이트 후 캐시 클리어)
      await _cacheService.clearUserProfile(uid);

      debugPrint('[UserRepository] User updated successfully');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to update user: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserProfile(
    UserProfile user,
  ) async {
    try {
      debugPrint('[UserRepository] Updating user profile: ${user.uid}');

      // Extension으로 변환
      final data = user.toFirestore();

      // Add lastActiveTime
      data['lastActiveTime'] = Timestamp.fromDate(getCurrentTimestamp());

      // Natural idempotency via deterministic userId
      await _firestore.collection('users').doc(user.uid).update(data);

      // 🔥 캐시 무효화 (업데이트 후 캐시 클리어)
      await _cacheService.clearUserProfile(user.uid);

      debugPrint('[UserRepository] User profile updated successfully');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to update user profile: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, UserProfile>> updateLanguage(
    String languageCode,
  ) async {
    try {
      debugPrint('[UserRepository] Updating language to: $languageCode');

      // 1. 현재 사용자 ID 가져오기
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[UserRepository] No authenticated user');
        return left(const ProfileFailure.authenticationRequired());
      }

      final userId = currentUser.uid;

      // 2. Natural idempotency via deterministic userId
      await _firestore.collection('users').doc(userId).update({
        'language': languageCode,
        'lastActiveTime': Timestamp.fromDate(getCurrentTimestamp()),
      });

      // 3. 캐시 무효화 (업데이트 후 캐시 클리어)
      await _cacheService.clearUserProfile(userId);

      // 4. 업데이트된 프로필 가져오기
      final updatedProfileResult = await getUserByUid(userId);

      return updatedProfileResult.fold(
        (failure) {
          debugPrint('[UserRepository] Failed to get updated profile: $failure');
          return left(failure);
        },
        (updatedProfile) {
          debugPrint('[UserRepository] Language updated successfully to: ${updatedProfile.language}');
          return right(updatedProfile);
        },
      );
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to update language: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> deleteUser(
    String uid,
  ) async {
    try {
      debugPrint('[UserRepository] Deleting user: $uid');

      // Natural idempotency via deterministic userId
      await _firestore.collection('users').doc(uid).delete();

      // 🔥 캐시 무효화 (삭제 후 캐시 클리어)
      await _cacheService.clearUserProfile(uid);

      debugPrint('[UserRepository] User deleted successfully');
      return right(unit);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreWrite('Failed to delete user: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, bool>> userExists(String uid) async {
    try {
      debugPrint('[UserRepository] Checking user existence: $uid');

      // 직접 Firebase SDK 사용
      final doc = await _firestore.collection('users').doc(uid).get();

      debugPrint('[UserRepository] User exists: ${doc.exists}');
      return right(doc.exists);
    } on FirebaseException catch (e) {
      debugPrint('[UserRepository] Firebase error: ${e.code} - ${e.message}');
      return left(_mapFirebaseException(e));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to check user existence: $e'));
    }
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
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String uid) async {
    try {
      debugPrint('[UserRepository] Getting user settings for: $uid');

      final userProfileResult = await getUserByUid(uid);
      return userProfileResult.fold(
        (failure) => left(failure),
        (userProfile) {
          // UserProfile에서 UserSettings 직접 생성 (Adapter 제거)
          final settings = UserSettings(
            userId: userProfile.uid,
            isPremiumUser: userProfile.isPremiumUser,
            receiveRankUpdateNotifications: userProfile.receiveRankUpdateNotifications,
            receiveTitleUpdateNotifications: userProfile.receiveTitleUpdateNotifications,
            receiveVoteNotifications: true, // UserProfile에 없는 필드는 기본값
            receiveCommentNotifications: true,
            receiveFriendNotifications: true,
            subscription: userProfile.subscription,
            stats: userProfile.stats,
            privacySettings: {}, // UserProfile에 privacySettings 필드 없음
          );

          debugPrint('[UserRepository] User settings retrieved successfully');
          return right(settings);
        },
      );
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      debugPrint('[UserRepository] Unexpected error: $e');
      return left(ProfileFailure.firestoreRead('Failed to get user settings: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateUserSettings(
    String userId,
    Map<String, dynamic> settings,
  ) {
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
  Future<Either<ProfileFailure, UserProfile>> getCurrentUserProfile() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || uid.isEmpty) {
      return left(ProfileFailure.authenticationRequired());
    }

    try {
      return await getUserByUid(uid);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.firestoreRead('Failed to get current user profile: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, Unit>> updateCurrentUserProfile(UserProfile user) async {
    final currentUid = _auth.currentUser?.uid;

    if (currentUid == null || currentUid.isEmpty) {
      return left(ProfileFailure.authenticationRequired());
    }

    if (user.uid != currentUid) {
      return left(ProfileFailure.unauthorizedAccess(
        message: 'Security violation: Cannot update other user profile. '
                'Current user: $currentUid, Target user: ${user.uid}'
      ));
    }

    return await updateUserProfile(user);
  }

  // ============= Firebase Exception Mapping =============

  /// Firebase Exception → ProfileFailure 매핑
  ///
  /// **Auth Feature 참조 패턴**:
  /// ```dart
  /// // lib/features/auth/data/repositories/auth_repository_impl.dart
  /// AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
  ///   switch (e.code) {
  ///     case 'user-not-found': return const AuthFailure.userNotFound();
  ///     // ...
  ///   }
  /// }
  /// ```
  ProfileFailure _mapFirebaseException(FirebaseException e) {
    switch (e.code) {
      // 권한 에러
      case 'permission-denied':
        return ProfileFailure.permissionDenied('user profile');

      // 찾을 수 없음
      case 'not-found':
        return ProfileFailure.profileNotFound(userId: 'unknown');

      // 네트워크 에러
      case 'unavailable':
      case 'deadline-exceeded':
        return const ProfileFailure.network();

      // 잘못된 인수
      case 'invalid-argument':
        return ProfileFailure.firestoreWrite('Invalid user data format');

      // 할당량 초과
      case 'resource-exhausted':
        return ProfileFailure.firestoreWrite('Firebase quota exceeded');

      // 기타
      default:
        return ProfileFailure.unknown('Firebase: ${e.code} - ${e.message}');
    }
  }
}
