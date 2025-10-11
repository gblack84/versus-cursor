import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart'
    show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/core/utils/app_utils.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/profile_info.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/user_stats.dart';
import '../../../auth/domain/models/auth_user.dart';
import '../../domain/repositories/i_user_repository.dart';
import '/features/profile/domain/models/characters_model.dart';
import '/features/profile/domain/models/interest_model.dart';
import '../adapters/user_profile_adapter.dart';

/// Implementation of user repository following RepoMover patterns
class UserRepositoryImpl implements IUserRepository {
  static UserRepositoryImpl? _instance;
  static UserRepositoryImpl get instance =>
      _instance ??= UserRepositoryImpl._();

  UserRepositoryImpl._();

  @override
  CollectionReference get usersCollection =>
      FirebaseFirestore.instance.collection('users');

  @override
  Stream<UserProfile> getUserStream(DocumentReference ref) =>
      ref.snapshots().map((s) => UserProfile.fromSnapshot(s));

  @override
  Future<UserProfile> getUserOnce(DocumentReference ref) =>
      ref.get().then((s) => UserProfile.fromSnapshot(s));

  @override
  Future<UserProfile?> getUserByUid(String uid) async {
    try {
      final doc = await usersCollection.doc(uid).get();
      if (!doc.exists) return null;
      return UserProfile.fromSnapshot(doc);
    } catch (e) {
      print('Error getting user by UID: $e');
      return null;
    }
  }

  @override
  Future<UserProfile?> getUser(String userId) => getUserByUid(userId);

  @override
  Stream<UserProfile?> getUserStreamByUid(String uid) {
    return usersCollection
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserProfile.fromSnapshot(doc) : null);
  }

  @override
  Stream<List<UserProfile>> queryFriendsList() {
    // TODO: Implement proper friends list query
    // For now, return empty stream
    return Stream.value([]);
  }

  @override
  Future<void> updateUserSettings(String userId, Map<String, dynamic> settings) {
    return updateUser(userId, settings);
  }

  @override
  Future<void> createUser(UserProfile user) async {
    final data = createUserProfileData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      createdTime: user.createdTime ?? getCurrentTimestamp(),
      location: user.location,
      interests: user.interests,
      expertise: user.expertise,
      isPremiumUser: user.isPremiumUser,
      role: user.role,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      language: user.language,
    );

    await usersCollection.doc(user.uid).set(data);
  }

  @override
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await usersCollection.doc(uid).update(data);
  }

  @override
  Future<void> updateUserProfile(UserProfile user) async {
    final data = createUserProfileData(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      phoneNumber: user.phoneNumber,
      location: user.location,
      interests: user.interests,
      expertise: user.expertise,
      isPremiumUser: user.isPremiumUser,
      pointsA: user.pointsA,
      pointsQ: user.pointsQ,
      totalAPoints: user.totalAPoints,
      totalQPoints: user.totalQPoints,
      currentRank: user.currentRank,
      currentTitle: user.currentTitle,
      shortDescription: user.shortDescription,
      role: user.role,
      gender: user.gender,
      dateOfBirth: user.dateOfBirth,
      language: user.language,
      lastActiveTime: getCurrentTimestamp(),
    );

    await usersCollection.doc(user.uid).update(data);
  }

  @override
  Future<void> deleteUser(String uid) async {
    await usersCollection.doc(uid).delete();
  }

  @override
  Future<List<UserProfile>> searchUsersByName(String query,
      {int limit = 10}) async {
    final querySnapshot = await usersCollection
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
        .limit(limit)
        .get();

    return querySnapshot.docs
        .map((doc) => UserProfile.fromSnapshot(doc))
        .toList();
  }

  @override
  Future<List<UserProfile>> getUserFriends(String uid) async {
    final userDoc = await getUserByUid(uid);
    if (userDoc == null || userDoc.friends.isEmpty) return [];

    return getUsersByIds(userDoc.friends);
  }

  @override
  Future<List<UserProfile>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];

    // Firestore 'in' queries are limited to 10 items
    final chunks = <List<String>>[];
    for (int i = 0; i < uids.length; i += 10) {
      chunks.add(uids.skip(i).take(10).toList());
    }

    final users = <UserProfile>[];
    for (final chunk in chunks) {
      final querySnapshot = await usersCollection
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      users.addAll(
          querySnapshot.docs.map((doc) => UserProfile.fromSnapshot(doc)));
    }

    return users;
  }

  @override
  Future<void> updateUserPoints(String uid, int pointsA, int pointsQ) async {
    final currentUser = await getUserByUid(uid);
    if (currentUser == null) return;

    await updateUser(uid, {
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'totalAPoints':
          currentUser.totalAPoints + (pointsA - currentUser.pointsA),
      'totalQPoints':
          currentUser.totalQPoints + (pointsQ - currentUser.pointsQ),
      'lastActiveTime': getCurrentTimestamp(),
    });
  }

  @override
  Future<void> updateUserRanking(String uid, String rank, String title) async {
    final currentUser = await getUserByUid(uid);
    if (currentUser == null) return;

    final now = getCurrentTimestamp();
    final rankHistory = List<String>.from(currentUser.rankHistory);
    final titleHistory = List<String>.from(currentUser.titleHistory);

    if (currentUser.currentRank != rank) {
      rankHistory
          .add('${currentUser.currentRank}:${now.millisecondsSinceEpoch}');
    }

    if (currentUser.currentTitle != title) {
      titleHistory
          .add('${currentUser.currentTitle}:${now.millisecondsSinceEpoch}');
    }

    await updateUser(uid, {
      'currentRank': rank,
      'currentTitle': title,
      'rankChangeDate': now,
      'titleChangeDate': now,
      'rankHistory': rankHistory,
      'titleHistory': titleHistory,
      'rankEvaluationCount': currentUser.rankEvaluationCount + 1,
    });
  }

  // ============= ADAPTER METHODS (NEW) =============
  // These methods provide access to the new domain models
  // while maintaining backward compatibility with legacy code

  /// Get user as separate domain models using Adapter
  Future<UserProfileBundle?> getUserBundleByUid(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    return UserProfileAdapter.createBundle(userProfile);
  }

  /// Get user profile info only
  Future<ProfileInfo?> getUserProfileInfo(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    return bundle.profile;
  }

  /// Get user settings only
  Future<UserSettings?> getUserSettings(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    return bundle.settings;
  }

  /// Get user stats only
  Future<UserStats?> getUserStats(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    return bundle.stats;
  }

  /// Get auth user data only
  Future<AuthUser?> getAuthUser(String uid) async {
    final userProfile = await getUserByUid(uid);
    if (userProfile == null) return null;
    final bundle = UserProfileAdapter.toDomainModels(userProfile);
    return bundle.auth;
  }

  /// Update user using domain models
  Future<void> updateUserWithBundle(UserProfileBundle bundle) async {
    final userProfile = bundle.toLegacy();
    await updateUserProfile(userProfile);
  }

  /// Create user from domain models
  Future<void> createUserFromBundle(UserProfileBundle bundle) async {
    final userProfile = bundle.toLegacy();
    await createUser(userProfile);
  }

  @override
  Future<int> getUsersCount({Query Function(Query)? queryBuilder}) =>
      queryCollectionCount(
        usersCollection,
        queryBuilder: queryBuilder,
      );

  @override
  Stream<List<UserProfile>> queryUsers({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        usersCollection,
        UserProfile.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  @override
  Future<List<UserProfile>> queryUsersOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        usersCollection,
        UserProfile.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  @override
  Future<bool> userExists(String uid) async {
    final doc = await usersCollection.doc(uid).get();
    return doc.exists;
  }

  @override
  DocumentReference getUserReference(String uid) => usersCollection.doc(uid);

  // MIGRATED: Users queries (lines 62-97 from backend.dart)
  Future<int> queryUsersModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        UserProfile.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<UserProfile>> queryUsersModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        UserProfile.collection,
        UserProfile.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<UserProfile>> queryUsersModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        UserProfile.collection,
        UserProfile.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Characters queries (lines 1497-1532 from backend.dart)
  Future<int> queryCharactersModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        CharactersModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<CharactersModel>> queryCharactersModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        CharactersModel.collection,
        CharactersModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<CharactersModel>> queryCharactersModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        CharactersModel.collection,
        CharactersModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Interest queries (lines 838-873 from backend.dart)
  Future<int> queryInterestModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        InterestModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<InterestModel>> queryInterestModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        InterestModel.collection,
        InterestModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<InterestModel>> queryInterestModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        InterestModel.collection,
        InterestModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );
}
