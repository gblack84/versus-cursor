import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/i_profile_repository.dart';
import '../../domain/models/profile_info.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/models/user_stats.dart';
import '../../domain/models/interest_model.dart';
import '../datasources/interfaces/i_profile_datasource.dart';
import '../datasources/interfaces/i_storage_datasource.dart';

/// ProfileRepository 구현
///
/// **책임**:
/// - DataSource를 통한 데이터 접근
/// - Map<String, dynamic> → Domain Model 변환
/// - 에러 처리
class ProfileRepositoryImpl implements IProfileRepository {
  final IProfileDataSource _dataSource;
  final IStorageDataSource _storageDataSource;

  ProfileRepositoryImpl({
    required IProfileDataSource dataSource,
    required IStorageDataSource storageDataSource,
  })  : _dataSource = dataSource,
        _storageDataSource = storageDataSource;

  // ============= ProfileInfo 관리 =============

  @override
  Future<ProfileInfo?> getProfileInfo(String userId) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) return null;

      return ProfileInfo(
        userId: data['uid'] as String? ?? userId,
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
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<ProfileInfo?> getProfileInfoStream(String userId) {
    return _dataSource.watchProfile(userId).map((data) {
      if (data == null) return null;

      return ProfileInfo(
        userId: data['uid'] as String? ?? userId,
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
    });
  }

  @override
  Future<void> updateProfileInfo(String userId, ProfileInfo profile) async {
    try {
      final data = profile.toFirestore();
      await _dataSource.updateProfile(userId, data);
    } catch (e) {
      rethrow;
    }
  }

  // ============= UserSettings 관리 =============

  @override
  Future<UserSettings?> getUserSettings(String userId) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) return null;

      return UserSettings(
        userId: data['uid'] as String? ?? userId,
        isPremiumUser: data['isPremiumUser'] as bool? ?? false,
        receiveRankUpdateNotifications:
            data['receiveRankUpdateNotifications'] as bool? ?? true,
        receiveTitleUpdateNotifications:
            data['receiveTitleUpdateNotifications'] as bool? ?? true,
        receiveVoteNotifications:
            data['receiveVoteNotifications'] as bool? ?? true,
        receiveCommentNotifications:
            data['receiveCommentNotifications'] as bool? ?? true,
        receiveFriendNotifications:
            data['receiveFriendNotifications'] as bool? ?? true,
        subscription: Map<String, dynamic>.from(
            data['subscription'] as Map<String, dynamic>? ?? {}),
        stats: Map<String, dynamic>.from(
            data['stats'] as Map<String, dynamic>? ?? {}),
        privacySettings: Map<String, dynamic>.from(
            data['privacySettings'] as Map<String, dynamic>? ?? {}),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserSettings?> getUserSettingsStream(String userId) {
    return _dataSource.watchProfile(userId).map((data) {
      if (data == null) return null;

      return UserSettings(
        userId: data['uid'] as String? ?? userId,
        isPremiumUser: data['isPremiumUser'] as bool? ?? false,
        receiveRankUpdateNotifications:
            data['receiveRankUpdateNotifications'] as bool? ?? true,
        receiveTitleUpdateNotifications:
            data['receiveTitleUpdateNotifications'] as bool? ?? true,
        receiveVoteNotifications:
            data['receiveVoteNotifications'] as bool? ?? true,
        receiveCommentNotifications:
            data['receiveCommentNotifications'] as bool? ?? true,
        receiveFriendNotifications:
            data['receiveFriendNotifications'] as bool? ?? true,
        subscription: Map<String, dynamic>.from(
            data['subscription'] as Map<String, dynamic>? ?? {}),
        stats: Map<String, dynamic>.from(
            data['stats'] as Map<String, dynamic>? ?? {}),
        privacySettings: Map<String, dynamic>.from(
            data['privacySettings'] as Map<String, dynamic>? ?? {}),
      );
    });
  }

  @override
  Future<void> updateUserSettings(
      String userId, UserSettings settings) async {
    try {
      final data = settings.toFirestore();
      await _dataSource.updateProfile(userId, data);
    } catch (e) {
      rethrow;
    }
  }

  // ============= UserStats 관리 =============

  @override
  Future<UserStats?> getUserStats(String userId) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) return null;

      return UserStats.fromMap(data, userId);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserStats?> getUserStatsStream(String userId) {
    return _dataSource.watchProfile(userId).map((data) {
      if (data == null) return null;
      return UserStats.fromMap(data, userId);
    });
  }

  @override
  Future<void> updateUserStats(String userId, UserStats stats) async {
    try {
      final data = stats.toFirestore();
      await _dataSource.updateProfile(userId, data);
    } catch (e) {
      rethrow;
    }
  }

  // ============= 필드 업데이트 =============

  @override
  Future<void> updateProfileField(
      String userId, String field, dynamic value) async {
    try {
      await _dataSource.updateField(userId, field, value);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> updateProfileFields(
      String userId, Map<String, dynamic> fields) async {
    try {
      await _dataSource.updateFields(userId, fields);
    } catch (e) {
      rethrow;
    }
  }

  // ============= 프로필 사진 관리 =============

  @override
  Future<String> uploadProfilePhoto(String userId, String imagePath) async {
    try {
      final file = await _readFile(imagePath);
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final downloadUrl = await _storageDataSource.uploadProfileImage(
        userId: userId,
        imageBytes: file,
        fileName: fileName,
      );

      await _dataSource.updateField(userId, 'photoUrl', downloadUrl);

      return downloadUrl;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteProfilePhoto(String userId) async {
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) return;

      final photoUrl = data['photoUrl'] as String?;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await _storageDataSource.deleteProfileImage(photoUrl);
        await _dataSource.updateField(userId, 'photoUrl', null);
      }
    } catch (e) {
      rethrow;
    }
  }

  // ============= 프로필 완성도 =============

  @override
  Future<bool> isProfileComplete(String userId) async {
    return await _dataSource.isProfileComplete(userId);
  }

  @override
  Future<double> getProfileCompletionPercentage(String userId) async {
    return await _dataSource.getProfileCompletionPercentage(userId);
  }

  @override
  Future<Map<String, dynamic>> getProfileCompletion(String userId) async {
    // 프로필 완성도 상세 정보 반환
    try {
      final data = await _dataSource.getProfile(userId);
      if (data == null) return {};

      final completion = <String, dynamic>{};
      completion['percentage'] = await getProfileCompletionPercentage(userId);
      completion['missingFields'] = <String>[];

      if (data['displayName'] == null || (data['displayName'] as String).isEmpty) {
        (completion['missingFields'] as List<String>).add('displayName');
      }
      if (data['photoUrl'] == null || (data['photoUrl'] as String).isEmpty) {
        (completion['missingFields'] as List<String>).add('photoUrl');
      }
      if (data['dateOfBirth'] == null) {
        (completion['missingFields'] as List<String>).add('dateOfBirth');
      }

      return completion;
    } catch (e) {
      return {};
    }
  }

  @override
  Future<List<InterestModel>> getUserInterests(String userId) async {
    // @Deprecated - IInterestsRepository 사용 권장
    // InterestModel은 Firestore 레코드이므로 여기서는 빈 리스트 반환
    return [];
  }

  // ============= 검색 및 추천 =============

  @override
  Future<List<ProfileInfo>> searchProfiles({
    String? query,
    List<String>? interests,
    String? gender,
    int? minAge,
    int? maxAge,
    double? maxDistance,
    GeoPoint? userLocation,
    int limit = 20,
  }) async {
    try {
      final results = await _dataSource.searchProfiles(
        query: query,
        interests: interests,
        gender: gender,
        minAge: minAge,
        maxAge: maxAge,
        maxDistance: maxDistance,
        userLocation: userLocation,
        limit: limit,
      );

      return results.map((data) {
        return ProfileInfo(
          userId: data['uid'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
          photoUrl: data['photoUrl'] as String?,
          shortDescription: data['shortDescription'] as String?,
          gender: data['gender'] as String?,
          dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
          location: data['location'] as GeoPoint?,
          interests:
              (data['interests'] as List<dynamic>?)?.cast<String>() ?? [],
          expertise:
              (data['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
          language: data['language'] as String? ?? 'en',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<ProfileInfo>> getSuggestedProfiles(String userId,
      {int limit = 10}) async {
    try {
      final results =
          await _dataSource.getSuggestedProfiles(userId, limit: limit);

      return results.map((data) {
        return ProfileInfo(
          userId: data['uid'] as String? ?? '',
          displayName: data['displayName'] as String? ?? '',
          photoUrl: data['photoUrl'] as String?,
          shortDescription: data['shortDescription'] as String?,
          gender: data['gender'] as String?,
          dateOfBirth: (data['dateOfBirth'] as Timestamp?)?.toDate(),
          location: data['location'] as GeoPoint?,
          interests:
              (data['interests'] as List<dynamic>?)?.cast<String>() ?? [],
          expertise:
              (data['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
          language: data['language'] as String? ?? 'en',
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  // ============= 소셜 기능 =============

  @override
  Future<void> blockUser(String userId, String blockedUserId) async {
    try {
      await _dataSource.blockUser(userId, blockedUserId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> unblockUser(String userId, String blockedUserId) async {
    try {
      await _dataSource.unblockUser(userId, blockedUserId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<String>> getBlockedUsers(String userId) async {
    try {
      return await _dataSource.getBlockedUsers(userId);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> reportUser(
      String userId, String reportedUserId, String reason) async {
    try {
      await _dataSource.reportUser(userId, reportedUserId, reason);
    } catch (e) {
      rethrow;
    }
  }

  // ============= 헬퍼 메서드 =============

  Future<List<int>> _readFile(String path) async {
    // Import dart:io in production
    // For now, throw UnimplementedError
    throw UnimplementedError(
      'File reading requires dart:io. Implement in production.',
    );
  }
}
