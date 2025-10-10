import 'package:cloud_firestore/cloud_firestore.dart';
import '../interfaces/i_profile_datasource.dart';
import 'dart:math' show cos, sqrt, asin;

/// Firebase Firestore 프로필 DataSource 구현
class FirebaseProfileDataSource implements IProfileDataSource {
  final FirebaseFirestore _firestore;

  FirebaseProfileDataSource({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============= 기본 CRUD =============

  @override
  Future<Map<String, dynamic>?> getProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }

  @override
  Future<void> createProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).set(data);
  }

  @override
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }

  @override
  Future<void> deleteProfile(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  @override
  Stream<Map<String, dynamic>?> watchProfile(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.data());
  }

  // ============= 필드 업데이트 =============

  @override
  Future<void> updateField(String userId, String field, dynamic value) async {
    await _firestore.collection('users').doc(userId).update({field: value});
  }

  @override
  Future<void> updateFields(String userId, Map<String, dynamic> fields) async {
    await _firestore.collection('users').doc(userId).update(fields);
  }

  // ============= 검색 및 쿼리 =============

  @override
  Future<List<Map<String, dynamic>>> searchProfiles({
    String? query,
    List<String>? interests,
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    GeoPoint? userLocation,
    int limit = 20,
  }) async {
    Query<Map<String, dynamic>> queryRef = _firestore.collection('users');

    // 이름 검색 (prefix matching)
    if (query != null && query.isNotEmpty) {
      queryRef = queryRef
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThanOrEqualTo: query + '\uf8ff');
    }

    // 성별 필터
    if (gender != null && gender.isNotEmpty) {
      queryRef = queryRef.where('gender', isEqualTo: gender);
    }

    // 관심사 필터 (array-contains-any는 최대 10개까지)
    if (interests != null && interests.isNotEmpty) {
      final limitedInterests = interests.take(10).toList();
      queryRef =
          queryRef.where('interests', arrayContainsAny: limitedInterests);
    }

    queryRef = queryRef.limit(limit);

    final snapshot = await queryRef.get();
    final results = snapshot.docs.map((doc) => doc.data()).toList();

    // 나이 및 거리 필터링 (클라이언트 사이드)
    return results.where((data) {
      // 나이 필터
      if (minAge != null || maxAge != null) {
        final dateOfBirth = (data['dateOfBirth'] as Timestamp?)?.toDate();
        if (dateOfBirth != null) {
          final age = DateTime.now().year - dateOfBirth.year;
          if (minAge != null && age < minAge) return false;
          if (maxAge != null && age > maxAge) return false;
        }
      }

      // 거리 필터
      if (maxDistance != null && userLocation != null) {
        final profileLocation = data['location'] as GeoPoint?;
        if (profileLocation != null) {
          final distance = _calculateDistance(
            userLocation.latitude,
            userLocation.longitude,
            profileLocation.latitude,
            profileLocation.longitude,
          );
          if (distance > maxDistance) return false;
        }
      }

      return true;
    }).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getSuggestedProfiles(
    String userId, {
    int limit = 10,
  }) async {
    // AI 기반 추천은 Phase 5에서 구현
    // 현재는 최근 활동 사용자 반환
    final snapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, isNotEqualTo: userId)
        .orderBy(FieldPath.documentId)
        .orderBy('lastActiveTime', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  // ============= 소셜 기능 =============

  @override
  Future<void> blockUser(String userId, String blockedUserId) async {
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'blockedUsers': FieldValue.arrayUnion([blockedUserId])
    });
  }

  @override
  Future<void> unblockUser(String userId, String blockedUserId) async {
    final userDoc = _firestore.collection('users').doc(userId);

    await userDoc.update({
      'blockedUsers': FieldValue.arrayRemove([blockedUserId])
    });
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    final data = doc.data();

    if (data == null) return [];

    final blockedUsers = data['blockedUsers'];
    if (blockedUsers is List) {
      return blockedUsers.cast<String>();
    }

    return [];
  }

  @override
  Future<void> reportUser(
    String userId,
    String reportedUserId,
    String reason,
  ) async {
    await _firestore.collection('reports').add({
      'reporterId': userId,
      'reportedUserId': reportedUserId,
      'reason': reason,
      'timestamp': FieldValue.serverTimestamp(),
      'status': 'pending',
    });
  }

  // ============= 프로필 완성도 =============

  @override
  Future<bool> isProfileComplete(String userId) async {
    final percentage = await getProfileCompletionPercentage(userId);
    return percentage >= 100.0;
  }

  @override
  Future<double> getProfileCompletionPercentage(String userId) async {
    final data = await getProfile(userId);
    if (data == null) return 0.0;

    int completed = 0;
    int total = 9;

    if (data['displayName'] != null &&
        (data['displayName'] as String).isNotEmpty) completed++;
    if (data['photoUrl'] != null && (data['photoUrl'] as String).isNotEmpty) {
      completed++;
    }
    if (data['shortDescription'] != null &&
        (data['shortDescription'] as String).isNotEmpty) completed++;
    if (data['gender'] != null && (data['gender'] as String).isNotEmpty) {
      completed++;
    }
    if (data['dateOfBirth'] != null) completed++;
    if (data['location'] != null) completed++;
    if (data['interests'] != null && (data['interests'] as List).isNotEmpty) {
      completed++;
    }
    if (data['expertise'] != null && (data['expertise'] as List).isNotEmpty) {
      completed++;
    }
    if (data['language'] != null && (data['language'] as String).isNotEmpty) {
      completed++;
    }

    return (completed / total) * 100.0;
  }

  // ============= 헬퍼 메서드 =============

  /// Haversine 공식을 사용한 거리 계산 (km)
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 -
        cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;

    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}
