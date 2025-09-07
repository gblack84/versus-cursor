import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

/// Repository interface for user profile operations
/// Defines the contract for user data access and management
abstract class IUserRepository {
  /// Get user profile stream by reference
  Stream<UserProfile> getUserStream(DocumentReference ref);
  
  /// Get user profile by reference (one-time fetch)
  Future<UserProfile> getUserOnce(DocumentReference ref);
  
  /// Get user profile by UID
  Future<UserProfile?> getUserByUid(String uid);
  
  /// Get user profile stream by UID
  Stream<UserProfile?> getUserStreamByUid(String uid);
  
  /// Create a new user profile
  Future<void> createUser(UserProfile user);
  
  /// Update user profile
  Future<void> updateUser(String uid, Map<String, dynamic> data);
  
  /// Update user profile with UserProfile object
  Future<void> updateUserProfile(UserProfile user);
  
  /// Delete user profile
  Future<void> deleteUser(String uid);
  
  /// Search users by display name
  Future<List<UserProfile>> searchUsersByName(String query, {int limit = 10});
  
  /// Get user friends list
  Future<List<UserProfile>> getUserFriends(String uid);
  
  /// Get users by list of UIDs
  Future<List<UserProfile>> getUsersByIds(List<String> uids);
  
  /// Update user points
  Future<void> updateUserPoints(String uid, int pointsA, int pointsQ);
  
  /// Update user ranking
  Future<void> updateUserRanking(String uid, String rank, String title);
  
  /// Get users count with optional query builder
  Future<int> getUsersCount({Query Function(Query)? queryBuilder});
  
  /// Query users with stream
  Stream<List<UserProfile>> queryUsers({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });
  
  /// Query users one-time
  Future<List<UserProfile>> queryUsersOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });
  
  /// Check if user exists
  Future<bool> userExists(String uid);
  
  /// Get user reference by UID
  DocumentReference getUserReference(String uid);
  
  /// Get users collection reference
  CollectionReference get usersCollection;
}
