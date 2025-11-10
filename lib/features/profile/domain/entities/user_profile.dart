import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/types/lat_lng.dart';
import '/core/types/lat_lng_converter.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// UserProfile pure domain model (Clean Architecture v4.0)
///
/// **변경사항** (2025-01-20):
/// - Freezed sealed class로 전환 (352줄 → 107줄, 70% 감소)
/// - copyWith, toString, hashCode, == 자동 생성
/// - fromJson/toJson 자동 생성
/// - 213줄의 boilerplate 코드 제거
///
/// **이전 변경사항** (2025-01-20):
/// - FirestoreRecord 상속 제거 → 순수 Dart 클래스
/// - Private 필드 + Getter → Final public 필드
/// - has*() 메서드 제거 → Null check 직접 사용
/// - fromSnapshot(), collection 등 Firebase 메서드 제거 → DTO로 이동
/// - createUserProfileData() 제거 → UserProfileDto.toFirestore()로 이동
/// - UserProfileDocumentEquality 제거 → == operator 사용
/// - @Deprecated 필드 4개 제거
///
/// Represents a user's profile information and system state
@freezed
sealed class UserProfile with _$UserProfile {
  const UserProfile._();

  const factory UserProfile({
    // ============= Core Identity Fields =============
    required String uid,
    required String email,
    String? displayName,
    String? photoUrl,
    String? phoneNumber,

    // ============= Profile Information =============
    @LatLngConverter()
    LatLng? location,
    String? country,           // "South Korea" (정적, 프로필 식별)
    String? countryCode,       // "KR" (ISO 3166-1 alpha-2)
    String? shortDescription,
    String? gender,
    DateTime? dateOfBirth,
    String? language,

    // ============= System Timestamps =============
    DateTime? createdTime,
    DateTime? lastActive,
    DateTime? lastActiveTime,

    // ============= Points System =============
    @Default(0) int pointsA,
    @Default(0) int pointsQ,
    @Default(0) int totalAPoints,
    @Default(0) int totalQPoints,

    // ============= Interests and Expertise =============
    @Default([]) List<String> interests,
    @Default([]) List<String> expertise,
    @Default([]) List<String> hobbies,
    String? jobCategory,
    String? jobName,

    // ============= Premium Status =============
    @Default(false) bool isPremiumUser,

    // ============= Anonymous Activity Counters =============
    @Default(0) int anonymousPostsCount,
    @Default(0) int anonymousCommentsCount,
    @Default(0) int anonymousQuestionCount,

    // ============= Ranking System =============
    String? currentRank,
    String? currentTitle,
    DateTime? rankChangeDate,
    DateTime? titleChangeDate,
    @Default(false) bool isRankEligible,
    @Default(0) int rankEvaluationCount,
    @Default([]) List<String> rankHistory,
    @Default([]) List<String> titleHistory,

    // ============= Notification Settings =============
    @Default(false) bool receiveRankUpdateNotifications,
    @Default(false) bool receiveTitleUpdateNotifications,

    // ============= Character Selection =============
    String? characterId,

    // ============= Social Connections =============
    @Default([]) List<String> friends,
    @Default([]) List<String> activeChats,
    @Default([]) List<String> groupChats,

    // ============= System Fields =============
    String? role,
    String? title,
    @Default({}) Map<String, dynamic> stats,
    @Default({}) Map<String, dynamic> subscription,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  // ============= Business Logic Getters =============

  /// 총 포인트 (A형 + Q형)
  int get totalPoints => pointsA + pointsQ;

  /// 총 활동 포인트 (전체 A형 + 전체 Q형)
  int get totalActivityPoints => totalAPoints + totalQPoints;

  /// 프로필 완성도 (0.0 ~ 1.0)
  double get completionRate {
    int completedFields = 0;
    const int totalRequiredFields = 11; // 주요 필드 개수

    if (displayName != null && displayName!.isNotEmpty) completedFields++;
    if (photoUrl != null && photoUrl!.isNotEmpty) completedFields++;
    if (country != null && country!.isNotEmpty) completedFields++;
    if (shortDescription != null && shortDescription!.isNotEmpty) completedFields++;
    if (gender != null) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (language != null) completedFields++;
    if (jobCategory != null) completedFields++;
    if (jobName != null) completedFields++;
    if (interests.isNotEmpty) completedFields++;
    if (characterId != null) completedFields++;

    return completedFields / totalRequiredFields;
  }
}
