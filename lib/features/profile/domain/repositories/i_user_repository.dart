import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/profile_info.dart';
import '../models/user_settings.dart';
import '../models/user_stats.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../models/characters_model.dart';
import '../models/interest_model.dart';
import '../../data/adapters/user_profile_adapter.dart';

/// Repository interface for User-related operations
///
/// **Phase 3 Note**: UserRepository는 레거시 코드와의 호환성을 위해
/// UserProfile 모델을 직접 사용하되, UserProfileAdapter를 통해
/// Clean Architecture 도메인 모델들과 변환 가능
abstract class IUserRepository {
  // ============= Collection Reference =============

  CollectionReference get usersCollection;

  // ============= Basic CRUD Operations =============

  /// 사용자 조회 (UserProfile)
  Future<UserProfile?> getUserByUid(String uid);

  /// 사용자 조회 (alias for getUserByUid)
  Future<UserProfile?> getUser(String userId);

  /// 사용자 스트림 (UserProfile)
  Stream<UserProfile?> getUserStreamByUid(String uid);

  /// 사용자 생성
  Future<void> createUser(UserProfile user);

  /// 사용자 업데이트 (Map)
  Future<void> updateUser(String uid, Map<String, dynamic> data);

  /// 사용자 프로필 업데이트 (UserProfile)
  Future<void> updateUserProfile(UserProfile user);

  /// 사용자 삭제
  Future<void> deleteUser(String uid);

  /// 사용자 존재 여부 확인
  Future<bool> userExists(String uid);

  // ============= Search & Query Operations =============

  /// 이름으로 사용자 검색
  Future<List<UserProfile>> searchUsersByName(String query, {int limit = 10});

  /// ID 리스트로 사용자 조회 (batch, chunked)
  Future<List<UserProfile>> getUsersByIds(List<String> uids);

  /// 친구 목록 조회
  Future<List<UserProfile>> getUserFriends(String uid);

  /// 친구 목록 스트림 조회
  Stream<List<UserProfile>> queryFriendsList();

  // ============= Points & Ranking Operations =============

  /// 포인트 업데이트 (pointsA, pointsQ, total 자동 계산)
  Future<void> updateUserPoints(String uid, int pointsA, int pointsQ);

  /// 랭킹 업데이트 (history 자동 추가)
  Future<void> updateUserRanking(String uid, String rank, String title);

  // ============= Adapter Methods (NEW) =============
  // Clean Architecture 도메인 모델과의 변환

  /// UserProfile → UserProfileBundle 변환
  Future<UserProfileBundle?> getUserBundleByUid(String uid);

  /// ProfileInfo 조회
  Future<ProfileInfo?> getUserProfileInfo(String uid);

  /// UserSettings 조회
  Future<UserSettings?> getUserSettings(String uid);

  /// UserSettings 업데이트
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings);

  /// UserStats 조회
  Future<UserStats?> getUserStats(String uid);

  /// AuthUser 조회
  Future<AuthUser?> getAuthUser(String uid);

  /// UserProfileBundle → UserProfile 변환 및 업데이트
  Future<void> updateUserWithBundle(UserProfileBundle bundle);

  /// UserProfileBundle → UserProfile 변환 및 생성
  Future<void> createUserFromBundle(UserProfileBundle bundle);

  // ============= Legacy Query Methods =============
  // FlutterFlow 레거시 코드 호환성

  Stream<UserProfile> getUserStream(DocumentReference ref);
  Future<UserProfile> getUserOnce(DocumentReference ref);

  Future<int> getUsersCount({Query Function(Query)? queryBuilder});

  Stream<List<UserProfile>> queryUsers({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<List<UserProfile>> queryUsersOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // Characters queries
  Stream<List<CharactersModel>> queryCharactersModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryCharactersModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Interest queries
  Stream<List<InterestModel>> queryInterestModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryInterestModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // ============= Helper Methods =============

  /// DocumentReference 조회
  DocumentReference getUserReference(String uid);
}
