import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/user_settings.dart';
import '../models/user_profile_dto.dart';
import '../models/user_settings_dto.dart';
import 'user_profile_mapper.dart';
import 'user_settings_mapper.dart';

/// 통합 Firestore 매퍼
///
/// **책임**:
/// - 여러 Mapper를 통합한 편의 기능 제공
/// - Firestore 문서 참조와 함께 변환 수행
/// - 공통 변환 로직 중앙화
class ProfileFirestoreMapper {
  /// Firestore 문서 → UserProfile
  static Future<UserProfile?> getUserProfileFromFirestore(
    String userId,
    FirebaseFirestore firestore,
  ) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;

    final dto = UserProfileDto.fromFirestore(doc.data()!);
    return UserProfileMapper.toDomain(dto, doc.reference);
  }

  /// Firestore 문서 → UserSettings
  static Future<UserSettings?> getUserSettingsFromFirestore(
    String userId,
    FirebaseFirestore firestore,
  ) async {
    final doc = await firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;

    // UserSettings 필드만 추출
    final data = doc.data()!;
    final settingsData = {
      'userId': data['userId'],
      'isPremiumUser': data['isPremiumUser'],
      'receiveRankUpdateNotifications': data['receiveRankUpdateNotifications'],
      'receiveTitleUpdateNotifications':
          data['receiveTitleUpdateNotifications'],
      'receiveVoteNotifications': data['receiveVoteNotifications'],
      'receiveCommentNotifications': data['receiveCommentNotifications'],
      'receiveFriendNotifications': data['receiveFriendNotifications'],
      'subscription': data['subscription'],
      'stats': data['stats'],
      'privacySettings': data['privacySettings'],
    };

    final dto = UserSettingsDto.fromFirestore(settingsData);
    return UserSettingsMapper.toDomain(dto);
  }

  /// UserProfile → Firestore 문서 업데이트
  static Future<void> updateUserProfileInFirestore(
    UserProfile profile,
    FirebaseFirestore firestore,
  ) async {
    final dto = UserProfileMapper.fromDomain(profile);
    final data = dto.toFirestore();

    await firestore.collection('users').doc(profile.uid).update(data);
  }

  /// UserSettings → Firestore 문서 업데이트
  static Future<void> updateUserSettingsInFirestore(
    UserSettings settings,
    FirebaseFirestore firestore,
  ) async {
    final dto = UserSettingsMapper.fromDomain(settings);
    final data = dto.toFirestore();

    await firestore.collection('users').doc(settings.userId).update(data);
  }
}
