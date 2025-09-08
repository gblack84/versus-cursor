import '../models/profile_info.dart';

/// Repository interface for friends/social operations
/// Manages friend relationships and social connections
abstract class IFriendsRepository {
  /// Send friend request
  Future<void> sendFriendRequest(String fromUserId, String toUserId);
  
  /// Accept friend request
  Future<void> acceptFriendRequest(String userId, String requesterId);
  
  /// Reject friend request
  Future<void> rejectFriendRequest(String userId, String requesterId);
  
  /// Cancel friend request
  Future<void> cancelFriendRequest(String userId, String targetUserId);
  
  /// Remove friend
  Future<void> removeFriend(String userId, String friendId);
  
  /// Get friends list
  Future<List<String>> getFriends(String userId);
  
  /// Get friends list stream
  Stream<List<String>> getFriendsStream(String userId);
  
  /// Get friend profiles
  Future<List<ProfileInfo>> getFriendProfiles(String userId);
  
  /// Get friend profiles stream
  Stream<List<ProfileInfo>> getFriendProfilesStream(String userId);
  
  /// Get pending friend requests (received)
  Future<List<String>> getPendingFriendRequests(String userId);
  
  /// Get pending friend requests stream
  Stream<List<String>> getPendingFriendRequestsStream(String userId);
  
  /// Get sent friend requests
  Future<List<String>> getSentFriendRequests(String userId);
  
  /// Get sent friend requests stream
  Stream<List<String>> getSentFriendRequestsStream(String userId);
  
  /// Check if users are friends
  Future<bool> areFriends(String userId1, String userId2);
  
  /// Check if friend request exists
  Future<bool> hasPendingFriendRequest(String fromUserId, String toUserId);
  
  /// Get mutual friends
  Future<List<String>> getMutualFriends(String userId1, String userId2);
  
  /// Get friend suggestions
  Future<List<ProfileInfo>> getFriendSuggestions(String userId, {int limit = 10});
  
  /// Get friends count
  Future<int> getFriendsCount(String userId);
  
  /// Get online friends
  Future<List<String>> getOnlineFriends(String userId);
  
  /// Get online friends stream
  Stream<List<String>> getOnlineFriendsStream(String userId);
  
  /// Search friends
  Future<List<ProfileInfo>> searchFriends(String userId, String query);
  
  /// Get friends by interest
  Future<List<ProfileInfo>> getFriendsByInterest(String userId, String interest);
  
  /// Get recent friends activity
  Future<List<Map<String, dynamic>>> getRecentFriendsActivity(String userId, {int limit = 20});
  
  /// Update friend relationship metadata
  Future<void> updateFriendshipMetadata(String userId, String friendId, Map<String, dynamic> metadata);
}