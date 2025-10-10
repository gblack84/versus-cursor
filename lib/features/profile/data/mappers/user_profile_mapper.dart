import '../../domain/models/user_profile.dart';
import '../dto/user_profile_dto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core_exports.dart';

/// UserProfile Mapper
///
/// **책임**: DTO와 Domain Model 간 양방향 변환
///
/// **Note**: UserProfile은 현재 FirestoreRecord를 상속하므로
/// 실제 변환은 Phase 6에서 FirestoreRecord 제거 후 완전히 구현됩니다.
/// 현재는 DTO의 toFirestore/fromFirestore를 통한 간접 변환을 지원합니다.
class UserProfileMapper {
  /// DTO → Domain Model
  ///
  /// **현재 제한사항**: UserProfile이 FirestoreRecord를 상속하므로
  /// 직접 생성자를 사용할 수 없습니다.
  /// fromSnapshot 또는 getDocumentFromData 사용 필요
  static UserProfile toDomain(
    UserProfileDto dto,
    DocumentReference reference,
  ) {
    final firestoreData = dto.toFirestore();
    return UserProfile.getDocumentFromData(firestoreData, reference);
  }

  /// Domain Model → DTO
  static UserProfileDto fromDomain(UserProfile profile) {
    // LatLng → GeoPoint 변환
    final GeoPoint? geoPoint = profile.location != null
        ? GeoPoint(profile.location!.latitude, profile.location!.longitude)
        : null;

    return UserProfileDto(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl: profile.photoUrl.isNotEmpty ? profile.photoUrl : null,
      phoneNumber:
          profile.phoneNumber.isNotEmpty ? profile.phoneNumber : null,
      location: geoPoint,
      shortDescription: profile.shortDescription.isNotEmpty
          ? profile.shortDescription
          : null,
      gender: profile.gender.isNotEmpty ? profile.gender : null,
      dateOfBirth: profile.dateOfBirth,
      language: profile.language.isNotEmpty ? profile.language : null,
      createdTime: profile.createdTime,
      lastActive: profile.lastActive,
      lastActiveTime: profile.lastActiveTime,
      pointsA: profile.pointsA,
      pointsQ: profile.pointsQ,
      totalAPoints: profile.totalAPoints,
      totalQPoints: profile.totalQPoints,
      interests: profile.interests.isNotEmpty ? profile.interests : null,
      expertise: profile.expertise.isNotEmpty ? profile.expertise : null,
      isPremiumUser: profile.isPremiumUser,
      anonymousPostsCount: profile.anonymousPostsCount,
      anonymousCommentsCount: profile.anonymousCommentsCount,
      anonymousQuestionCount: profile.anonymousQuestionCount,
      currentRank:
          profile.currentRank.isNotEmpty ? profile.currentRank : null,
      currentTitle:
          profile.currentTitle.isNotEmpty ? profile.currentTitle : null,
      rankChangeDate: profile.rankChangeDate,
      titleChangeDate: profile.titleChangeDate,
      isRankEligible: profile.isRankEligible,
      rankEvaluationCount: profile.rankEvaluationCount,
      rankHistory:
          profile.rankHistory.isNotEmpty ? profile.rankHistory : null,
      titleHistory:
          profile.titleHistory.isNotEmpty ? profile.titleHistory : null,
      receiveRankUpdateNotifications: profile.receiveRankUpdateNotifications,
      receiveTitleUpdateNotifications: profile.receiveTitleUpdateNotifications,
      friends: profile.friends.isNotEmpty ? profile.friends : null,
      activeChats:
          profile.activeChats.isNotEmpty ? profile.activeChats : null,
      groupChats: profile.groupChats.isNotEmpty ? profile.groupChats : null,
      role: profile.role.isNotEmpty ? profile.role : null,
      title: profile.title.isNotEmpty ? profile.title : null,
      stats: profile.stats.isNotEmpty ? profile.stats : null,
      subscription:
          profile.subscription.isNotEmpty ? profile.subscription : null,
    );
  }
}
