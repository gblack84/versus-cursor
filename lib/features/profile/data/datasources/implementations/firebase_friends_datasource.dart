import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/i_friends_datasource.dart';

/// Firebase Firestore 친구 DataSource 구현
///
/// **Note**: Firestore 구조
/// - users/{userId}/friends: Array of friend IDs
/// - users/{userId}/pendingFriendRequests: Array of requester IDs
/// - users/{userId}/sentFriendRequests: Array of target IDs
class FirebaseFriendsDataSource implements IFriendsDataSource {
  final FirebaseFirestore _firestore;

  FirebaseFriendsDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============= 기본 친구 관리 =============

  @override
  Future<List<String>> getFriends(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return [];

    final friends = data['friends'];
    if (friends is List) {
      return friends.cast<String>();
    }

    return [];
  }

  @override
  Stream<List<String>> watchFriends(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return <String>[];

      final friends = data['friends'];
      if (friends is List) {
        return friends.cast<String>();
      }

      return <String>[];
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendProfiles(String userId) async {
    final friendIds = await getFriends(userId);
    if (friendIds.isEmpty) return [];

    // Firestore 'in' query는 최대 10개까지
    final chunks = <List<String>>[];
    for (int i = 0; i < friendIds.length; i += 10) {
      chunks.add(friendIds.skip(i).take(10).toList());
    }

    final profiles = <Map<String, dynamic>>[];
    for (final chunk in chunks) {
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      profiles.addAll(snapshot.docs.map((doc) => doc.data()));
    }

    return profiles;
  }

  @override
  Stream<List<Map<String, dynamic>>> watchFriendProfiles(String userId) {
    return watchFriends(userId).asyncMap((friendIds) async {
      if (friendIds.isEmpty) return <Map<String, dynamic>>[];

      final chunks = <List<String>>[];
      for (int i = 0; i < friendIds.length; i += 10) {
        chunks.add(friendIds.skip(i).take(10).toList());
      }

      final profiles = <Map<String, dynamic>>[];
      for (final chunk in chunks) {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: chunk)
            .get();

        profiles.addAll(snapshot.docs.map((doc) => doc.data()));
      }

      return profiles;
    });
  }

  @override
  Future<void> removeFriend(String userId, String friendId) async {
    final batch = _firestore.batch();

    // 양방향 삭제
    batch.update(_firestore.collection('users').doc(userId), {
      'friends': FieldValue.arrayRemove([friendId])
    });

    batch.update(_firestore.collection('users').doc(friendId), {
      'friends': FieldValue.arrayRemove([userId])
    });

    await batch.commit();
  }

  // ============= 친구 요청 관리 =============

  @override
  Future<void> sendFriendRequest(String fromUserId, String toUserId) async {
    final batch = _firestore.batch();

    // fromUser의 sentFriendRequests에 추가
    batch.update(_firestore.collection('users').doc(fromUserId), {
      'sentFriendRequests': FieldValue.arrayUnion([toUserId])
    });

    // toUser의 pendingFriendRequests에 추가
    batch.update(_firestore.collection('users').doc(toUserId), {
      'pendingFriendRequests': FieldValue.arrayUnion([fromUserId])
    });

    await batch.commit();
  }

  @override
  Future<void> acceptFriendRequest(String userId, String requesterId) async {
    final batch = _firestore.batch();

    // 양방향 friends 배열에 추가
    batch.update(_firestore.collection('users').doc(userId), {
      'friends': FieldValue.arrayUnion([requesterId]),
      'pendingFriendRequests': FieldValue.arrayRemove([requesterId])
    });

    batch.update(_firestore.collection('users').doc(requesterId), {
      'friends': FieldValue.arrayUnion([userId]),
      'sentFriendRequests': FieldValue.arrayRemove([userId])
    });

    await batch.commit();
  }

  @override
  Future<void> rejectFriendRequest(String userId, String requesterId) async {
    final batch = _firestore.batch();

    // pendingFriendRequests에서 제거
    batch.update(_firestore.collection('users').doc(userId), {
      'pendingFriendRequests': FieldValue.arrayRemove([requesterId])
    });

    // sentFriendRequests에서 제거
    batch.update(_firestore.collection('users').doc(requesterId), {
      'sentFriendRequests': FieldValue.arrayRemove([userId])
    });

    await batch.commit();
  }

  @override
  Future<void> cancelFriendRequest(String userId, String targetUserId) async {
    final batch = _firestore.batch();

    // sentFriendRequests에서 제거
    batch.update(_firestore.collection('users').doc(userId), {
      'sentFriendRequests': FieldValue.arrayRemove([targetUserId])
    });

    // pendingFriendRequests에서 제거
    batch.update(_firestore.collection('users').doc(targetUserId), {
      'pendingFriendRequests': FieldValue.arrayRemove([userId])
    });

    await batch.commit();
  }

  @override
  Future<List<String>> getPendingFriendRequests(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return [];

    final requests = data['pendingFriendRequests'];
    if (requests is List) {
      return requests.cast<String>();
    }

    return [];
  }

  @override
  Stream<List<String>> watchPendingFriendRequests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return <String>[];

      final requests = data['pendingFriendRequests'];
      if (requests is List) {
        return requests.cast<String>();
      }

      return <String>[];
    });
  }

  @override
  Future<List<String>> getSentFriendRequests(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return [];

    final requests = data['sentFriendRequests'];
    if (requests is List) {
      return requests.cast<String>();
    }

    return [];
  }

  @override
  Stream<List<String>> watchSentFriendRequests(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      if (data == null) return <String>[];

      final requests = data['sentFriendRequests'];
      if (requests is List) {
        return requests.cast<String>();
      }

      return <String>[];
    });
  }

  // ============= 친구 상태 확인 =============

  @override
  Future<bool> areFriends(String userId1, String userId2) async {
    final friends = await getFriends(userId1);
    return friends.contains(userId2);
  }

  @override
  Future<bool> hasPendingFriendRequest(
      String fromUserId, String toUserId) async {
    final sentRequests = await getSentFriendRequests(fromUserId);
    return sentRequests.contains(toUserId);
  }

  @override
  Future<int> getFriendsCount(String userId) async {
    final friends = await getFriends(userId);
    return friends.length;
  }

  // ============= 친구 검색 및 추천 =============

  @override
  Future<List<String>> getMutualFriends(String userId1, String userId2) async {
    final friends1 = await getFriends(userId1);
    final friends2 = await getFriends(userId2);

    return friends1.where((id) => friends2.contains(id)).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendSuggestions(
    String userId, {
    int limit = 10,
  }) async {
    // AI 기반 추천은 Phase 5에서 구현
    // 현재는 공통 친구가 많은 사용자 추천
    final friends = await getFriends(userId);
    if (friends.isEmpty) return [];

    // 친구의 친구 조회
    final suggestionsMap = <String, int>{};

    for (final friendId in friends.take(5)) {
      // 최대 5명의 친구만 확인
      final friendsOfFriend = await getFriends(friendId);

      for (final potentialFriend in friendsOfFriend) {
        // 자신과 이미 친구인 사람 제외
        if (potentialFriend != userId && !friends.contains(potentialFriend)) {
          suggestionsMap[potentialFriend] =
              (suggestionsMap[potentialFriend] ?? 0) + 1;
        }
      }
    }

    // 공통 친구 수로 정렬
    final sortedSuggestions = suggestionsMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topSuggestions =
        sortedSuggestions.take(limit).map((e) => e.key).toList();

    if (topSuggestions.isEmpty) return [];

    // 프로필 정보 조회
    final profiles = <Map<String, dynamic>>[];
    final chunks = <List<String>>[];
    for (int i = 0; i < topSuggestions.length; i += 10) {
      chunks.add(topSuggestions.skip(i).take(10).toList());
    }

    for (final chunk in chunks) {
      final snapshot = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();

      profiles.addAll(snapshot.docs.map((doc) => doc.data()));
    }

    return profiles;
  }

  @override
  Future<List<Map<String, dynamic>>> searchFriends(
    String userId,
    String query,
  ) async {
    final friendIds = await getFriends(userId);
    if (friendIds.isEmpty) return [];

    // 친구 프로필 조회
    final profiles = await getFriendProfiles(userId);

    // 이름으로 필터링 (클라이언트 사이드)
    return profiles.where((profile) {
      final displayName = profile['displayName'] as String?;
      if (displayName == null) return false;

      return displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFriendsByInterest(
    String userId,
    String interest,
  ) async {
    final friendIds = await getFriends(userId);
    if (friendIds.isEmpty) return [];

    final profiles = await getFriendProfiles(userId);

    return profiles.where((profile) {
      final interests = profile['interests'];
      if (interests is List) {
        return interests.contains(interest);
      }
      return false;
    }).toList();
  }

  // ============= 온라인 상태 =============

  @override
  Future<List<String>> getOnlineFriends(String userId) async {
    final friendIds = await getFriends(userId);
    if (friendIds.isEmpty) return [];

    // 5분 이내 활동한 사용자를 온라인으로 간주
    final fiveMinutesAgo =
        Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 5)));

    final profiles = await getFriendProfiles(userId);

    final onlineFriends = profiles.where((profile) {
      final lastActiveTime = profile['lastActiveTime'];
      if (lastActiveTime is Timestamp) {
        return lastActiveTime.compareTo(fiveMinutesAgo) > 0;
      }
      return false;
    }).map((profile) => profile['uid'] as String).toList();

    return onlineFriends;
  }

  @override
  Stream<List<String>> watchOnlineFriends(String userId) {
    return watchFriendProfiles(userId).map((profiles) {
      final fiveMinutesAgo =
          Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 5)));

      return profiles.where((profile) {
        final lastActiveTime = profile['lastActiveTime'];
        if (lastActiveTime is Timestamp) {
          return lastActiveTime.compareTo(fiveMinutesAgo) > 0;
        }
        return false;
      }).map((profile) => profile['uid'] as String).toList();
    });
  }

  // ============= 친구 활동 =============

  @override
  Future<List<Map<String, dynamic>>> getRecentFriendsActivity(
    String userId, {
    int limit = 20,
  }) async {
    // Phase 5에서 별도 'activities' 컬렉션과 함께 구현
    // 현재는 빈 리스트 반환
    return [];
  }

  @override
  Future<void> updateFriendshipMetadata(
    String userId,
    String friendId,
    Map<String, dynamic> metadata,
  ) async {
    // Phase 5에서 별도 'friendships' 컬렉션과 함께 구현
    // 현재는 no-op
  }
}
