import '../../domain/models/user_profile.dart';
import '../models/user_profile_dto.dart';
import '../../../../core_exports.dart';

/// UserProfile Mapper
///
/// **책임**: DTO와 Domain Model 간 양방향 변환
///
/// **변경사항** (2025-01-20 Phase 1 & 6):
/// - getDocumentFromData 제거 → UserProfile 생성자 직접 호출
/// - nullable 필드에 null-safe 체크 추가
class UserProfileMapper {
  /// DTO → Domain Model
  ///
  /// **Phase 1 변경**: UserProfile 생성자를 직접 사용
  static UserProfile toDomain(
    UserProfileDto dto,
    DocumentReference reference,
  ) {
    // LatLng 변환을 위해 core_exports에서 가져옴
    final LatLng? latLng = dto.location != null
        ? LatLng(dto.location!.latitude, dto.location!.longitude)
        : null;

    return UserProfile(
      uid: dto.uid ?? '',
      email: dto.email ?? '',
      displayName: dto.displayName,
      photoUrl: dto.photoUrl,
      phoneNumber: dto.phoneNumber,
      location: latLng,
      shortDescription: dto.shortDescription,
      gender: dto.gender,
      dateOfBirth: dto.dateOfBirth,
      language: dto.language,
      createdTime: dto.createdTime,
      lastActive: dto.lastActive,
      lastActiveTime: dto.lastActiveTime,
      pointsA: dto.pointsA ?? 0,
      pointsQ: dto.pointsQ ?? 0,
      totalAPoints: dto.totalAPoints ?? 0,
      totalQPoints: dto.totalQPoints ?? 0,
      interests: dto.interests ?? const [],
      expertise: dto.expertise ?? const [],
      hobbies: dto.hobbies ?? const [],
      jobCategory: dto.jobCategory,
      jobName: dto.jobName,
      isPremiumUser: dto.isPremiumUser ?? false,
      anonymousPostsCount: dto.anonymousPostsCount ?? 0,
      anonymousCommentsCount: dto.anonymousCommentsCount ?? 0,
      anonymousQuestionCount: dto.anonymousQuestionCount ?? 0,
      currentRank: dto.currentRank,
      currentTitle: dto.currentTitle,
      rankChangeDate: dto.rankChangeDate,
      titleChangeDate: dto.titleChangeDate,
      isRankEligible: dto.isRankEligible ?? false,
      rankEvaluationCount: dto.rankEvaluationCount ?? 0,
      rankHistory: dto.rankHistory ?? const [],
      titleHistory: dto.titleHistory ?? const [],
      receiveRankUpdateNotifications:
          dto.receiveRankUpdateNotifications ?? false,
      receiveTitleUpdateNotifications:
          dto.receiveTitleUpdateNotifications ?? false,
      characterId: dto.characterId,
      friends: dto.friends ?? const [],
      activeChats: dto.activeChats ?? const [],
      groupChats: dto.groupChats ?? const [],
      role: dto.role,
      title: dto.title,
      stats: dto.stats ?? const {},
      subscription: dto.subscription ?? const {},
    );
  }

  /// Domain Model → DTO
  ///
  /// **Phase 6 변경**: nullable 필드에 null-safe 체크 추가
  static UserProfileDto fromDomain(UserProfile profile) {
    // LatLng → GeoPoint 변환
    final GeoPoint? geoPoint = profile.location != null
        ? GeoPoint(profile.location!.latitude, profile.location!.longitude)
        : null;

    return UserProfileDto(
      uid: profile.uid,
      email: profile.email,
      displayName: profile.displayName,
      photoUrl:
          (profile.photoUrl?.isNotEmpty == true) ? profile.photoUrl : null,
      phoneNumber: (profile.phoneNumber?.isNotEmpty == true)
          ? profile.phoneNumber
          : null,
      location: geoPoint,
      shortDescription: (profile.shortDescription?.isNotEmpty == true)
          ? profile.shortDescription
          : null,
      gender: (profile.gender?.isNotEmpty == true) ? profile.gender : null,
      dateOfBirth: profile.dateOfBirth,
      language:
          (profile.language?.isNotEmpty == true) ? profile.language : null,
      createdTime: profile.createdTime,
      lastActive: profile.lastActive,
      lastActiveTime: profile.lastActiveTime,
      pointsA: profile.pointsA,
      pointsQ: profile.pointsQ,
      totalAPoints: profile.totalAPoints,
      totalQPoints: profile.totalQPoints,
      interests: profile.interests.isNotEmpty ? profile.interests : null,
      expertise: profile.expertise.isNotEmpty ? profile.expertise : null,
      hobbies: profile.hobbies.isNotEmpty ? profile.hobbies : null,
      jobCategory: profile.jobCategory,
      jobName: profile.jobName,
      isPremiumUser: profile.isPremiumUser,
      anonymousPostsCount: profile.anonymousPostsCount,
      anonymousCommentsCount: profile.anonymousCommentsCount,
      anonymousQuestionCount: profile.anonymousQuestionCount,
      currentRank: (profile.currentRank?.isNotEmpty == true)
          ? profile.currentRank
          : null,
      currentTitle: (profile.currentTitle?.isNotEmpty == true)
          ? profile.currentTitle
          : null,
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
      characterId: (profile.characterId?.isNotEmpty == true) ? profile.characterId : null,
      friends: profile.friends.isNotEmpty ? profile.friends : null,
      activeChats:
          profile.activeChats.isNotEmpty ? profile.activeChats : null,
      groupChats: profile.groupChats.isNotEmpty ? profile.groupChats : null,
      role: (profile.role?.isNotEmpty == true) ? profile.role : null,
      title: (profile.title?.isNotEmpty == true) ? profile.title : null,
      stats: profile.stats.isNotEmpty ? profile.stats : null,
      subscription:
          profile.subscription.isNotEmpty ? profile.subscription : null,
    );
  }
}
