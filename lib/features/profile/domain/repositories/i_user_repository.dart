import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import '../models/friends_list_model.dart';
import '../models/settings_model.dart';
import '../models/characters_model.dart';

/// Repository interface for User-related operations
/// This interface defines the contract for user and profile functionality
abstract class IUserRepository {
  // User queries
  Stream<List<UserProfile>> queryUsers({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryUsersCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  Future<UserProfile?> queryUsersSingleRecord({
    Query Function(Query)? queryBuilder,
    bool singleRecord = true,
  });

  // Friends list queries
  Stream<List<FriendsListModel>> queryFriendsList({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryFriendsListCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Settings queries
  Stream<List<SettingsModel>> querySettings({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> querySettingsCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Characters queries
  Stream<List<CharactersModel>> queryCharacters({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryCharactersCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // CRUD operations
  Future<UserProfile?> getUser(String userId);
  Future<void> createUser(UserProfile user);
  Future<void> updateUser(UserProfile user);
  Future<void> deleteUser(String userId);

  // Settings operations
  Future<SettingsModel?> getUserSettings(String userId);
  Future<void> updateUserSettings(String userId, SettingsModel settings);

  // Character operations
  Future<CharactersModel?> getUserCharacter(String userId);
  Future<void> updateUserCharacter(String userId, CharactersModel character);

  // Helper methods for Firebase operations
  DocumentReference getUserReference(String userId);
  Future<UserProfile?> getUserById(String userId);

  // Factory method for creating user data
  Map<String, dynamic> createUsersModelData({
    String? email,
    String? displayName,
    String? photoUrl,
    String? uid,
    DateTime? createdTime,
    String? phoneNumber,
    DateTime? lastActive,
    String? bio,
    bool? isPublic,
    String? username,
    String? website,
    String? role,
  });
}
