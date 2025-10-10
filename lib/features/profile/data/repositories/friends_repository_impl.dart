import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_friends_repository.dart';
import '../../domain/models/profile_info.dart';
import '../datasources/interfaces/i_friends_datasource.dart';

/// FriendsRepository 구현
///
/// **책임**:
/// - DataSource를 통한 친구 데이터 접근
/// - Map<String, dynamic> → Domain Model 변환
/// - 에러 처리
class FriendsRepositoryImpl implements IFriendsRepository {
  final IFriendsDataSource _dataSource;

  FriendsRepositoryImpl({
    required IFriendsDataSource dataSource,
  }) : _dataSource = dataSource;

  // ============= 기본 친구 관리 =============

  @override
  Future<List<String>> getFriends(String userId) async {
    try {
      return await _dataSource.getFriends(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<String>> getFriendsStream(String userId) {
    return _dataSource.watchFriends(userId);
  }

  @override
  Future<List<ProfileInfo>> getFriendProfiles(String userId) async {
    try {
      final profiles = await _dataSource.getFriendProfiles(userId);
      return _mapToProfileInfoList(profiles);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<ProfileInfo>> getFriendProfilesStream(String userId) {
    return _dataSource.watchFriendProfiles(userId).map(_mapToProfileInfoList);
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    try {
      await _dataSource.removeFriend(userId, friendId);
    } catch (e) {
      rethrow;
    }
  }

  // ============= 친구 요청 관리 =============

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    try {
      await _dataSource.sendFriendRequest(fromUserId, toUserId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    try {
      await _dataSource.acceptFriendRequest(userId, requesterId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    try {
      await _dataSource.rejectFriendRequest(userId, requesterId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> cancelFriendRequest(String userId, String targetUserId) async {
    try {
      await _dataSource.cancelFriendRequest(userId, targetUserId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getPendingFriendRequests(String userId) async {
    try {
      return await _dataSource.getPendingFriendRequests(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<String>> getPendingFriendRequestsStream(String userId) {
    return _dataSource.watchPendingFriendRequests(userId);
  }

  @override
  Future<List<String>> getSentFriendRequests(String userId) async {
    try {
      return await _dataSource.getSentFriendRequests(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<String>> getSentFriendRequestsStream(String userId) {
    return _dataSource.watchSentFriendRequests(userId);
  }

  // ============= 친구 상태 확인 =============

  @override
  Future<bool> areFriends(String userId1, String userId2) async {
    try {
      return await _dataSource.areFriends(userId1, userId2);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasPendingFriendRequest(
      String fromUserId, String toUserId) async {
    try {
      return await _dataSource.hasPendingFriendRequest(fromUserId, toUserId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int> getFriendsCount(String userId) async {
    try {
      return await _dataSource.getFriendsCount(userId);
    } catch (e) {
      return 0;
    }
  }

  // ============= 친구 검색 및 추천 =============

  @override
  Future<List<String>> getMutualFriends(String userId1, String userId2) async {
    try {
      return await _dataSource.getMutualFriends(userId1, userId2);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProfileInfo>> getFriendSuggestions(String userId,
      {int limit = 10}) async {
    try {
      final suggestions =
          await _dataSource.getFriendSuggestions(userId, limit: limit);
      return _mapToProfileInfoList(suggestions);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProfileInfo>> searchFriends(String userId, String query) async {
    try {
      final results = await _dataSource.searchFriends(userId, query);
      return _mapToProfileInfoList(results);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProfileInfo>> getFriendsByInterest(
      String userId, String interest) async {
    try {
      final results = await _dataSource.getFriendsByInterest(userId, interest);
      return _mapToProfileInfoList(results);
    } catch (e) {
      return [];
    }
  }

  // ============= 온라인 상태 =============

  @override
  Future<List<String>> getOnlineFriends(String userId) async {
    try {
      return await _dataSource.getOnlineFriends(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Stream<List<String>> getOnlineFriendsStream(String userId) {
    return _dataSource.watchOnlineFriends(userId);
  }

  // ============= 친구 활동 =============

  @override
  Future<List<Map<String, dynamic>>> getRecentFriendsActivity(String userId,
      {int limit = 20}) async {
    try {
      return await _dataSource.getRecentFriendsActivity(userId, limit: limit);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> updateFriendshipMetadata(
      String userId, String friendId, Map<String, dynamic> metadata) async {
    try {
      await _dataSource.updateFriendshipMetadata(userId, friendId, metadata);
    } catch (e) {
      rethrow;
    }
  }

  // ============= 헬퍼 메서드 =============

  List<ProfileInfo> _mapToProfileInfoList(List<Map<String, dynamic>> profiles) {
    return profiles.map((data) {
      return ProfileInfo(
        userId: data['uid'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        photoUrl: data['photoUrl'] as String?,
        shortDescription: data['shortDescription'] as String?,
        gender: data['gender'] as String?,
        dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
        location: data['location'] as GeoPoint?,
        interests: (data['interests'] as List<dynamic>?)?.cast<String>() ?? [],
        expertise: (data['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
        language: data['language'] as String? ?? 'en',
      );
    }).toList();
  }
}
