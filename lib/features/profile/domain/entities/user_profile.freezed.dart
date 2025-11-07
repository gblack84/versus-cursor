// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

// ============= Core Identity Fields =============
 String get uid; String get email; String? get displayName; String? get photoUrl; String? get phoneNumber;// ============= Profile Information =============
@LatLngConverter() LatLng? get location; String? get shortDescription; String? get gender; DateTime? get dateOfBirth; String? get language;// ============= System Timestamps =============
 DateTime? get createdTime; DateTime? get lastActive; DateTime? get lastActiveTime;// ============= Points System =============
 int get pointsA; int get pointsQ; int get totalAPoints; int get totalQPoints;// ============= Interests and Expertise =============
 List<String> get interests; List<String> get expertise; List<String> get hobbies; String? get jobCategory; String? get jobName;// ============= Premium Status =============
 bool get isPremiumUser;// ============= Anonymous Activity Counters =============
 int get anonymousPostsCount; int get anonymousCommentsCount; int get anonymousQuestionCount;// ============= Ranking System =============
 String? get currentRank; String? get currentTitle; DateTime? get rankChangeDate; DateTime? get titleChangeDate; bool get isRankEligible; int get rankEvaluationCount; List<String> get rankHistory; List<String> get titleHistory;// ============= Notification Settings =============
 bool get receiveRankUpdateNotifications; bool get receiveTitleUpdateNotifications;// ============= Character Selection =============
 String? get characterId;// ============= Social Connections =============
 List<String> get friends; List<String> get activeChats; List<String> get groupChats;// ============= System Fields =============
 String? get role; String? get title; Map<String, dynamic> get stats; Map<String, dynamic> get subscription;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.location, location) || other.location == location)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.lastActiveTime, lastActiveTime) || other.lastActiveTime == lastActiveTime)&&(identical(other.pointsA, pointsA) || other.pointsA == pointsA)&&(identical(other.pointsQ, pointsQ) || other.pointsQ == pointsQ)&&(identical(other.totalAPoints, totalAPoints) || other.totalAPoints == totalAPoints)&&(identical(other.totalQPoints, totalQPoints) || other.totalQPoints == totalQPoints)&&const DeepCollectionEquality().equals(other.interests, interests)&&const DeepCollectionEquality().equals(other.expertise, expertise)&&const DeepCollectionEquality().equals(other.hobbies, hobbies)&&(identical(other.jobCategory, jobCategory) || other.jobCategory == jobCategory)&&(identical(other.jobName, jobName) || other.jobName == jobName)&&(identical(other.isPremiumUser, isPremiumUser) || other.isPremiumUser == isPremiumUser)&&(identical(other.anonymousPostsCount, anonymousPostsCount) || other.anonymousPostsCount == anonymousPostsCount)&&(identical(other.anonymousCommentsCount, anonymousCommentsCount) || other.anonymousCommentsCount == anonymousCommentsCount)&&(identical(other.anonymousQuestionCount, anonymousQuestionCount) || other.anonymousQuestionCount == anonymousQuestionCount)&&(identical(other.currentRank, currentRank) || other.currentRank == currentRank)&&(identical(other.currentTitle, currentTitle) || other.currentTitle == currentTitle)&&(identical(other.rankChangeDate, rankChangeDate) || other.rankChangeDate == rankChangeDate)&&(identical(other.titleChangeDate, titleChangeDate) || other.titleChangeDate == titleChangeDate)&&(identical(other.isRankEligible, isRankEligible) || other.isRankEligible == isRankEligible)&&(identical(other.rankEvaluationCount, rankEvaluationCount) || other.rankEvaluationCount == rankEvaluationCount)&&const DeepCollectionEquality().equals(other.rankHistory, rankHistory)&&const DeepCollectionEquality().equals(other.titleHistory, titleHistory)&&(identical(other.receiveRankUpdateNotifications, receiveRankUpdateNotifications) || other.receiveRankUpdateNotifications == receiveRankUpdateNotifications)&&(identical(other.receiveTitleUpdateNotifications, receiveTitleUpdateNotifications) || other.receiveTitleUpdateNotifications == receiveTitleUpdateNotifications)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&const DeepCollectionEquality().equals(other.friends, friends)&&const DeepCollectionEquality().equals(other.activeChats, activeChats)&&const DeepCollectionEquality().equals(other.groupChats, groupChats)&&(identical(other.role, role) || other.role == role)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other.stats, stats)&&const DeepCollectionEquality().equals(other.subscription, subscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,location,shortDescription,gender,dateOfBirth,language,createdTime,lastActive,lastActiveTime,pointsA,pointsQ,totalAPoints,totalQPoints,const DeepCollectionEquality().hash(interests),const DeepCollectionEquality().hash(expertise),const DeepCollectionEquality().hash(hobbies),jobCategory,jobName,isPremiumUser,anonymousPostsCount,anonymousCommentsCount,anonymousQuestionCount,currentRank,currentTitle,rankChangeDate,titleChangeDate,isRankEligible,rankEvaluationCount,const DeepCollectionEquality().hash(rankHistory),const DeepCollectionEquality().hash(titleHistory),receiveRankUpdateNotifications,receiveTitleUpdateNotifications,characterId,const DeepCollectionEquality().hash(friends),const DeepCollectionEquality().hash(activeChats),const DeepCollectionEquality().hash(groupChats),role,title,const DeepCollectionEquality().hash(stats),const DeepCollectionEquality().hash(subscription)]);

@override
String toString() {
  return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, location: $location, shortDescription: $shortDescription, gender: $gender, dateOfBirth: $dateOfBirth, language: $language, createdTime: $createdTime, lastActive: $lastActive, lastActiveTime: $lastActiveTime, pointsA: $pointsA, pointsQ: $pointsQ, totalAPoints: $totalAPoints, totalQPoints: $totalQPoints, interests: $interests, expertise: $expertise, hobbies: $hobbies, jobCategory: $jobCategory, jobName: $jobName, isPremiumUser: $isPremiumUser, anonymousPostsCount: $anonymousPostsCount, anonymousCommentsCount: $anonymousCommentsCount, anonymousQuestionCount: $anonymousQuestionCount, currentRank: $currentRank, currentTitle: $currentTitle, rankChangeDate: $rankChangeDate, titleChangeDate: $titleChangeDate, isRankEligible: $isRankEligible, rankEvaluationCount: $rankEvaluationCount, rankHistory: $rankHistory, titleHistory: $titleHistory, receiveRankUpdateNotifications: $receiveRankUpdateNotifications, receiveTitleUpdateNotifications: $receiveTitleUpdateNotifications, characterId: $characterId, friends: $friends, activeChats: $activeChats, groupChats: $groupChats, role: $role, title: $title, stats: $stats, subscription: $subscription)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String? phoneNumber,@LatLngConverter() LatLng? location, String? shortDescription, String? gender, DateTime? dateOfBirth, String? language, DateTime? createdTime, DateTime? lastActive, DateTime? lastActiveTime, int pointsA, int pointsQ, int totalAPoints, int totalQPoints, List<String> interests, List<String> expertise, List<String> hobbies, String? jobCategory, String? jobName, bool isPremiumUser, int anonymousPostsCount, int anonymousCommentsCount, int anonymousQuestionCount, String? currentRank, String? currentTitle, DateTime? rankChangeDate, DateTime? titleChangeDate, bool isRankEligible, int rankEvaluationCount, List<String> rankHistory, List<String> titleHistory, bool receiveRankUpdateNotifications, bool receiveTitleUpdateNotifications, String? characterId, List<String> friends, List<String> activeChats, List<String> groupChats, String? role, String? title, Map<String, dynamic> stats, Map<String, dynamic> subscription
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? location = freezed,Object? shortDescription = freezed,Object? gender = freezed,Object? dateOfBirth = freezed,Object? language = freezed,Object? createdTime = freezed,Object? lastActive = freezed,Object? lastActiveTime = freezed,Object? pointsA = null,Object? pointsQ = null,Object? totalAPoints = null,Object? totalQPoints = null,Object? interests = null,Object? expertise = null,Object? hobbies = null,Object? jobCategory = freezed,Object? jobName = freezed,Object? isPremiumUser = null,Object? anonymousPostsCount = null,Object? anonymousCommentsCount = null,Object? anonymousQuestionCount = null,Object? currentRank = freezed,Object? currentTitle = freezed,Object? rankChangeDate = freezed,Object? titleChangeDate = freezed,Object? isRankEligible = null,Object? rankEvaluationCount = null,Object? rankHistory = null,Object? titleHistory = null,Object? receiveRankUpdateNotifications = null,Object? receiveTitleUpdateNotifications = null,Object? characterId = freezed,Object? friends = null,Object? activeChats = null,Object? groupChats = null,Object? role = freezed,Object? title = freezed,Object? stats = null,Object? subscription = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveTime: freezed == lastActiveTime ? _self.lastActiveTime : lastActiveTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pointsA: null == pointsA ? _self.pointsA : pointsA // ignore: cast_nullable_to_non_nullable
as int,pointsQ: null == pointsQ ? _self.pointsQ : pointsQ // ignore: cast_nullable_to_non_nullable
as int,totalAPoints: null == totalAPoints ? _self.totalAPoints : totalAPoints // ignore: cast_nullable_to_non_nullable
as int,totalQPoints: null == totalQPoints ? _self.totalQPoints : totalQPoints // ignore: cast_nullable_to_non_nullable
as int,interests: null == interests ? _self.interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self.expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,hobbies: null == hobbies ? _self.hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<String>,jobCategory: freezed == jobCategory ? _self.jobCategory : jobCategory // ignore: cast_nullable_to_non_nullable
as String?,jobName: freezed == jobName ? _self.jobName : jobName // ignore: cast_nullable_to_non_nullable
as String?,isPremiumUser: null == isPremiumUser ? _self.isPremiumUser : isPremiumUser // ignore: cast_nullable_to_non_nullable
as bool,anonymousPostsCount: null == anonymousPostsCount ? _self.anonymousPostsCount : anonymousPostsCount // ignore: cast_nullable_to_non_nullable
as int,anonymousCommentsCount: null == anonymousCommentsCount ? _self.anonymousCommentsCount : anonymousCommentsCount // ignore: cast_nullable_to_non_nullable
as int,anonymousQuestionCount: null == anonymousQuestionCount ? _self.anonymousQuestionCount : anonymousQuestionCount // ignore: cast_nullable_to_non_nullable
as int,currentRank: freezed == currentRank ? _self.currentRank : currentRank // ignore: cast_nullable_to_non_nullable
as String?,currentTitle: freezed == currentTitle ? _self.currentTitle : currentTitle // ignore: cast_nullable_to_non_nullable
as String?,rankChangeDate: freezed == rankChangeDate ? _self.rankChangeDate : rankChangeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,titleChangeDate: freezed == titleChangeDate ? _self.titleChangeDate : titleChangeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isRankEligible: null == isRankEligible ? _self.isRankEligible : isRankEligible // ignore: cast_nullable_to_non_nullable
as bool,rankEvaluationCount: null == rankEvaluationCount ? _self.rankEvaluationCount : rankEvaluationCount // ignore: cast_nullable_to_non_nullable
as int,rankHistory: null == rankHistory ? _self.rankHistory : rankHistory // ignore: cast_nullable_to_non_nullable
as List<String>,titleHistory: null == titleHistory ? _self.titleHistory : titleHistory // ignore: cast_nullable_to_non_nullable
as List<String>,receiveRankUpdateNotifications: null == receiveRankUpdateNotifications ? _self.receiveRankUpdateNotifications : receiveRankUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveTitleUpdateNotifications: null == receiveTitleUpdateNotifications ? _self.receiveTitleUpdateNotifications : receiveTitleUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as String?,friends: null == friends ? _self.friends : friends // ignore: cast_nullable_to_non_nullable
as List<String>,activeChats: null == activeChats ? _self.activeChats : activeChats // ignore: cast_nullable_to_non_nullable
as List<String>,groupChats: null == groupChats ? _self.groupChats : groupChats // ignore: cast_nullable_to_non_nullable
as List<String>,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,subscription: null == subscription ? _self.subscription : subscription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String? phoneNumber, @LatLngConverter()  LatLng? location,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String? language,  DateTime? createdTime,  DateTime? lastActive,  DateTime? lastActiveTime,  int pointsA,  int pointsQ,  int totalAPoints,  int totalQPoints,  List<String> interests,  List<String> expertise,  List<String> hobbies,  String? jobCategory,  String? jobName,  bool isPremiumUser,  int anonymousPostsCount,  int anonymousCommentsCount,  int anonymousQuestionCount,  String? currentRank,  String? currentTitle,  DateTime? rankChangeDate,  DateTime? titleChangeDate,  bool isRankEligible,  int rankEvaluationCount,  List<String> rankHistory,  List<String> titleHistory,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  String? characterId,  List<String> friends,  List<String> activeChats,  List<String> groupChats,  String? role,  String? title,  Map<String, dynamic> stats,  Map<String, dynamic> subscription)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.location,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.createdTime,_that.lastActive,_that.lastActiveTime,_that.pointsA,_that.pointsQ,_that.totalAPoints,_that.totalQPoints,_that.interests,_that.expertise,_that.hobbies,_that.jobCategory,_that.jobName,_that.isPremiumUser,_that.anonymousPostsCount,_that.anonymousCommentsCount,_that.anonymousQuestionCount,_that.currentRank,_that.currentTitle,_that.rankChangeDate,_that.titleChangeDate,_that.isRankEligible,_that.rankEvaluationCount,_that.rankHistory,_that.titleHistory,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.characterId,_that.friends,_that.activeChats,_that.groupChats,_that.role,_that.title,_that.stats,_that.subscription);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String? displayName,  String? photoUrl,  String? phoneNumber, @LatLngConverter()  LatLng? location,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String? language,  DateTime? createdTime,  DateTime? lastActive,  DateTime? lastActiveTime,  int pointsA,  int pointsQ,  int totalAPoints,  int totalQPoints,  List<String> interests,  List<String> expertise,  List<String> hobbies,  String? jobCategory,  String? jobName,  bool isPremiumUser,  int anonymousPostsCount,  int anonymousCommentsCount,  int anonymousQuestionCount,  String? currentRank,  String? currentTitle,  DateTime? rankChangeDate,  DateTime? titleChangeDate,  bool isRankEligible,  int rankEvaluationCount,  List<String> rankHistory,  List<String> titleHistory,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  String? characterId,  List<String> friends,  List<String> activeChats,  List<String> groupChats,  String? role,  String? title,  Map<String, dynamic> stats,  Map<String, dynamic> subscription)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.location,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.createdTime,_that.lastActive,_that.lastActiveTime,_that.pointsA,_that.pointsQ,_that.totalAPoints,_that.totalQPoints,_that.interests,_that.expertise,_that.hobbies,_that.jobCategory,_that.jobName,_that.isPremiumUser,_that.anonymousPostsCount,_that.anonymousCommentsCount,_that.anonymousQuestionCount,_that.currentRank,_that.currentTitle,_that.rankChangeDate,_that.titleChangeDate,_that.isRankEligible,_that.rankEvaluationCount,_that.rankHistory,_that.titleHistory,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.characterId,_that.friends,_that.activeChats,_that.groupChats,_that.role,_that.title,_that.stats,_that.subscription);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String? displayName,  String? photoUrl,  String? phoneNumber, @LatLngConverter()  LatLng? location,  String? shortDescription,  String? gender,  DateTime? dateOfBirth,  String? language,  DateTime? createdTime,  DateTime? lastActive,  DateTime? lastActiveTime,  int pointsA,  int pointsQ,  int totalAPoints,  int totalQPoints,  List<String> interests,  List<String> expertise,  List<String> hobbies,  String? jobCategory,  String? jobName,  bool isPremiumUser,  int anonymousPostsCount,  int anonymousCommentsCount,  int anonymousQuestionCount,  String? currentRank,  String? currentTitle,  DateTime? rankChangeDate,  DateTime? titleChangeDate,  bool isRankEligible,  int rankEvaluationCount,  List<String> rankHistory,  List<String> titleHistory,  bool receiveRankUpdateNotifications,  bool receiveTitleUpdateNotifications,  String? characterId,  List<String> friends,  List<String> activeChats,  List<String> groupChats,  String? role,  String? title,  Map<String, dynamic> stats,  Map<String, dynamic> subscription)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.uid,_that.email,_that.displayName,_that.photoUrl,_that.phoneNumber,_that.location,_that.shortDescription,_that.gender,_that.dateOfBirth,_that.language,_that.createdTime,_that.lastActive,_that.lastActiveTime,_that.pointsA,_that.pointsQ,_that.totalAPoints,_that.totalQPoints,_that.interests,_that.expertise,_that.hobbies,_that.jobCategory,_that.jobName,_that.isPremiumUser,_that.anonymousPostsCount,_that.anonymousCommentsCount,_that.anonymousQuestionCount,_that.currentRank,_that.currentTitle,_that.rankChangeDate,_that.titleChangeDate,_that.isRankEligible,_that.rankEvaluationCount,_that.rankHistory,_that.titleHistory,_that.receiveRankUpdateNotifications,_that.receiveTitleUpdateNotifications,_that.characterId,_that.friends,_that.activeChats,_that.groupChats,_that.role,_that.title,_that.stats,_that.subscription);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({required this.uid, required this.email, this.displayName, this.photoUrl, this.phoneNumber, @LatLngConverter() this.location, this.shortDescription, this.gender, this.dateOfBirth, this.language, this.createdTime, this.lastActive, this.lastActiveTime, this.pointsA = 0, this.pointsQ = 0, this.totalAPoints = 0, this.totalQPoints = 0, final  List<String> interests = const [], final  List<String> expertise = const [], final  List<String> hobbies = const [], this.jobCategory, this.jobName, this.isPremiumUser = false, this.anonymousPostsCount = 0, this.anonymousCommentsCount = 0, this.anonymousQuestionCount = 0, this.currentRank, this.currentTitle, this.rankChangeDate, this.titleChangeDate, this.isRankEligible = false, this.rankEvaluationCount = 0, final  List<String> rankHistory = const [], final  List<String> titleHistory = const [], this.receiveRankUpdateNotifications = false, this.receiveTitleUpdateNotifications = false, this.characterId, final  List<String> friends = const [], final  List<String> activeChats = const [], final  List<String> groupChats = const [], this.role, this.title, final  Map<String, dynamic> stats = const {}, final  Map<String, dynamic> subscription = const {}}): _interests = interests,_expertise = expertise,_hobbies = hobbies,_rankHistory = rankHistory,_titleHistory = titleHistory,_friends = friends,_activeChats = activeChats,_groupChats = groupChats,_stats = stats,_subscription = subscription,super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

// ============= Core Identity Fields =============
@override final  String uid;
@override final  String email;
@override final  String? displayName;
@override final  String? photoUrl;
@override final  String? phoneNumber;
// ============= Profile Information =============
@override@LatLngConverter() final  LatLng? location;
@override final  String? shortDescription;
@override final  String? gender;
@override final  DateTime? dateOfBirth;
@override final  String? language;
// ============= System Timestamps =============
@override final  DateTime? createdTime;
@override final  DateTime? lastActive;
@override final  DateTime? lastActiveTime;
// ============= Points System =============
@override@JsonKey() final  int pointsA;
@override@JsonKey() final  int pointsQ;
@override@JsonKey() final  int totalAPoints;
@override@JsonKey() final  int totalQPoints;
// ============= Interests and Expertise =============
 final  List<String> _interests;
// ============= Interests and Expertise =============
@override@JsonKey() List<String> get interests {
  if (_interests is EqualUnmodifiableListView) return _interests;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interests);
}

 final  List<String> _expertise;
@override@JsonKey() List<String> get expertise {
  if (_expertise is EqualUnmodifiableListView) return _expertise;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expertise);
}

 final  List<String> _hobbies;
@override@JsonKey() List<String> get hobbies {
  if (_hobbies is EqualUnmodifiableListView) return _hobbies;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hobbies);
}

@override final  String? jobCategory;
@override final  String? jobName;
// ============= Premium Status =============
@override@JsonKey() final  bool isPremiumUser;
// ============= Anonymous Activity Counters =============
@override@JsonKey() final  int anonymousPostsCount;
@override@JsonKey() final  int anonymousCommentsCount;
@override@JsonKey() final  int anonymousQuestionCount;
// ============= Ranking System =============
@override final  String? currentRank;
@override final  String? currentTitle;
@override final  DateTime? rankChangeDate;
@override final  DateTime? titleChangeDate;
@override@JsonKey() final  bool isRankEligible;
@override@JsonKey() final  int rankEvaluationCount;
 final  List<String> _rankHistory;
@override@JsonKey() List<String> get rankHistory {
  if (_rankHistory is EqualUnmodifiableListView) return _rankHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rankHistory);
}

 final  List<String> _titleHistory;
@override@JsonKey() List<String> get titleHistory {
  if (_titleHistory is EqualUnmodifiableListView) return _titleHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_titleHistory);
}

// ============= Notification Settings =============
@override@JsonKey() final  bool receiveRankUpdateNotifications;
@override@JsonKey() final  bool receiveTitleUpdateNotifications;
// ============= Character Selection =============
@override final  String? characterId;
// ============= Social Connections =============
 final  List<String> _friends;
// ============= Social Connections =============
@override@JsonKey() List<String> get friends {
  if (_friends is EqualUnmodifiableListView) return _friends;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_friends);
}

 final  List<String> _activeChats;
@override@JsonKey() List<String> get activeChats {
  if (_activeChats is EqualUnmodifiableListView) return _activeChats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_activeChats);
}

 final  List<String> _groupChats;
@override@JsonKey() List<String> get groupChats {
  if (_groupChats is EqualUnmodifiableListView) return _groupChats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_groupChats);
}

// ============= System Fields =============
@override final  String? role;
@override final  String? title;
 final  Map<String, dynamic> _stats;
@override@JsonKey() Map<String, dynamic> get stats {
  if (_stats is EqualUnmodifiableMapView) return _stats;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stats);
}

 final  Map<String, dynamic> _subscription;
@override@JsonKey() Map<String, dynamic> get subscription {
  if (_subscription is EqualUnmodifiableMapView) return _subscription;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_subscription);
}


/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.location, location) || other.location == location)&&(identical(other.shortDescription, shortDescription) || other.shortDescription == shortDescription)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.language, language) || other.language == language)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.lastActive, lastActive) || other.lastActive == lastActive)&&(identical(other.lastActiveTime, lastActiveTime) || other.lastActiveTime == lastActiveTime)&&(identical(other.pointsA, pointsA) || other.pointsA == pointsA)&&(identical(other.pointsQ, pointsQ) || other.pointsQ == pointsQ)&&(identical(other.totalAPoints, totalAPoints) || other.totalAPoints == totalAPoints)&&(identical(other.totalQPoints, totalQPoints) || other.totalQPoints == totalQPoints)&&const DeepCollectionEquality().equals(other._interests, _interests)&&const DeepCollectionEquality().equals(other._expertise, _expertise)&&const DeepCollectionEquality().equals(other._hobbies, _hobbies)&&(identical(other.jobCategory, jobCategory) || other.jobCategory == jobCategory)&&(identical(other.jobName, jobName) || other.jobName == jobName)&&(identical(other.isPremiumUser, isPremiumUser) || other.isPremiumUser == isPremiumUser)&&(identical(other.anonymousPostsCount, anonymousPostsCount) || other.anonymousPostsCount == anonymousPostsCount)&&(identical(other.anonymousCommentsCount, anonymousCommentsCount) || other.anonymousCommentsCount == anonymousCommentsCount)&&(identical(other.anonymousQuestionCount, anonymousQuestionCount) || other.anonymousQuestionCount == anonymousQuestionCount)&&(identical(other.currentRank, currentRank) || other.currentRank == currentRank)&&(identical(other.currentTitle, currentTitle) || other.currentTitle == currentTitle)&&(identical(other.rankChangeDate, rankChangeDate) || other.rankChangeDate == rankChangeDate)&&(identical(other.titleChangeDate, titleChangeDate) || other.titleChangeDate == titleChangeDate)&&(identical(other.isRankEligible, isRankEligible) || other.isRankEligible == isRankEligible)&&(identical(other.rankEvaluationCount, rankEvaluationCount) || other.rankEvaluationCount == rankEvaluationCount)&&const DeepCollectionEquality().equals(other._rankHistory, _rankHistory)&&const DeepCollectionEquality().equals(other._titleHistory, _titleHistory)&&(identical(other.receiveRankUpdateNotifications, receiveRankUpdateNotifications) || other.receiveRankUpdateNotifications == receiveRankUpdateNotifications)&&(identical(other.receiveTitleUpdateNotifications, receiveTitleUpdateNotifications) || other.receiveTitleUpdateNotifications == receiveTitleUpdateNotifications)&&(identical(other.characterId, characterId) || other.characterId == characterId)&&const DeepCollectionEquality().equals(other._friends, _friends)&&const DeepCollectionEquality().equals(other._activeChats, _activeChats)&&const DeepCollectionEquality().equals(other._groupChats, _groupChats)&&(identical(other.role, role) || other.role == role)&&(identical(other.title, title) || other.title == title)&&const DeepCollectionEquality().equals(other._stats, _stats)&&const DeepCollectionEquality().equals(other._subscription, _subscription));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,displayName,photoUrl,phoneNumber,location,shortDescription,gender,dateOfBirth,language,createdTime,lastActive,lastActiveTime,pointsA,pointsQ,totalAPoints,totalQPoints,const DeepCollectionEquality().hash(_interests),const DeepCollectionEquality().hash(_expertise),const DeepCollectionEquality().hash(_hobbies),jobCategory,jobName,isPremiumUser,anonymousPostsCount,anonymousCommentsCount,anonymousQuestionCount,currentRank,currentTitle,rankChangeDate,titleChangeDate,isRankEligible,rankEvaluationCount,const DeepCollectionEquality().hash(_rankHistory),const DeepCollectionEquality().hash(_titleHistory),receiveRankUpdateNotifications,receiveTitleUpdateNotifications,characterId,const DeepCollectionEquality().hash(_friends),const DeepCollectionEquality().hash(_activeChats),const DeepCollectionEquality().hash(_groupChats),role,title,const DeepCollectionEquality().hash(_stats),const DeepCollectionEquality().hash(_subscription)]);

@override
String toString() {
  return 'UserProfile(uid: $uid, email: $email, displayName: $displayName, photoUrl: $photoUrl, phoneNumber: $phoneNumber, location: $location, shortDescription: $shortDescription, gender: $gender, dateOfBirth: $dateOfBirth, language: $language, createdTime: $createdTime, lastActive: $lastActive, lastActiveTime: $lastActiveTime, pointsA: $pointsA, pointsQ: $pointsQ, totalAPoints: $totalAPoints, totalQPoints: $totalQPoints, interests: $interests, expertise: $expertise, hobbies: $hobbies, jobCategory: $jobCategory, jobName: $jobName, isPremiumUser: $isPremiumUser, anonymousPostsCount: $anonymousPostsCount, anonymousCommentsCount: $anonymousCommentsCount, anonymousQuestionCount: $anonymousQuestionCount, currentRank: $currentRank, currentTitle: $currentTitle, rankChangeDate: $rankChangeDate, titleChangeDate: $titleChangeDate, isRankEligible: $isRankEligible, rankEvaluationCount: $rankEvaluationCount, rankHistory: $rankHistory, titleHistory: $titleHistory, receiveRankUpdateNotifications: $receiveRankUpdateNotifications, receiveTitleUpdateNotifications: $receiveTitleUpdateNotifications, characterId: $characterId, friends: $friends, activeChats: $activeChats, groupChats: $groupChats, role: $role, title: $title, stats: $stats, subscription: $subscription)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String? displayName, String? photoUrl, String? phoneNumber,@LatLngConverter() LatLng? location, String? shortDescription, String? gender, DateTime? dateOfBirth, String? language, DateTime? createdTime, DateTime? lastActive, DateTime? lastActiveTime, int pointsA, int pointsQ, int totalAPoints, int totalQPoints, List<String> interests, List<String> expertise, List<String> hobbies, String? jobCategory, String? jobName, bool isPremiumUser, int anonymousPostsCount, int anonymousCommentsCount, int anonymousQuestionCount, String? currentRank, String? currentTitle, DateTime? rankChangeDate, DateTime? titleChangeDate, bool isRankEligible, int rankEvaluationCount, List<String> rankHistory, List<String> titleHistory, bool receiveRankUpdateNotifications, bool receiveTitleUpdateNotifications, String? characterId, List<String> friends, List<String> activeChats, List<String> groupChats, String? role, String? title, Map<String, dynamic> stats, Map<String, dynamic> subscription
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? displayName = freezed,Object? photoUrl = freezed,Object? phoneNumber = freezed,Object? location = freezed,Object? shortDescription = freezed,Object? gender = freezed,Object? dateOfBirth = freezed,Object? language = freezed,Object? createdTime = freezed,Object? lastActive = freezed,Object? lastActiveTime = freezed,Object? pointsA = null,Object? pointsQ = null,Object? totalAPoints = null,Object? totalQPoints = null,Object? interests = null,Object? expertise = null,Object? hobbies = null,Object? jobCategory = freezed,Object? jobName = freezed,Object? isPremiumUser = null,Object? anonymousPostsCount = null,Object? anonymousCommentsCount = null,Object? anonymousQuestionCount = null,Object? currentRank = freezed,Object? currentTitle = freezed,Object? rankChangeDate = freezed,Object? titleChangeDate = freezed,Object? isRankEligible = null,Object? rankEvaluationCount = null,Object? rankHistory = null,Object? titleHistory = null,Object? receiveRankUpdateNotifications = null,Object? receiveTitleUpdateNotifications = null,Object? characterId = freezed,Object? friends = null,Object? activeChats = null,Object? groupChats = null,Object? role = freezed,Object? title = freezed,Object? stats = null,Object? subscription = null,}) {
  return _then(_UserProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as LatLng?,shortDescription: freezed == shortDescription ? _self.shortDescription : shortDescription // ignore: cast_nullable_to_non_nullable
as String?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActive: freezed == lastActive ? _self.lastActive : lastActive // ignore: cast_nullable_to_non_nullable
as DateTime?,lastActiveTime: freezed == lastActiveTime ? _self.lastActiveTime : lastActiveTime // ignore: cast_nullable_to_non_nullable
as DateTime?,pointsA: null == pointsA ? _self.pointsA : pointsA // ignore: cast_nullable_to_non_nullable
as int,pointsQ: null == pointsQ ? _self.pointsQ : pointsQ // ignore: cast_nullable_to_non_nullable
as int,totalAPoints: null == totalAPoints ? _self.totalAPoints : totalAPoints // ignore: cast_nullable_to_non_nullable
as int,totalQPoints: null == totalQPoints ? _self.totalQPoints : totalQPoints // ignore: cast_nullable_to_non_nullable
as int,interests: null == interests ? _self._interests : interests // ignore: cast_nullable_to_non_nullable
as List<String>,expertise: null == expertise ? _self._expertise : expertise // ignore: cast_nullable_to_non_nullable
as List<String>,hobbies: null == hobbies ? _self._hobbies : hobbies // ignore: cast_nullable_to_non_nullable
as List<String>,jobCategory: freezed == jobCategory ? _self.jobCategory : jobCategory // ignore: cast_nullable_to_non_nullable
as String?,jobName: freezed == jobName ? _self.jobName : jobName // ignore: cast_nullable_to_non_nullable
as String?,isPremiumUser: null == isPremiumUser ? _self.isPremiumUser : isPremiumUser // ignore: cast_nullable_to_non_nullable
as bool,anonymousPostsCount: null == anonymousPostsCount ? _self.anonymousPostsCount : anonymousPostsCount // ignore: cast_nullable_to_non_nullable
as int,anonymousCommentsCount: null == anonymousCommentsCount ? _self.anonymousCommentsCount : anonymousCommentsCount // ignore: cast_nullable_to_non_nullable
as int,anonymousQuestionCount: null == anonymousQuestionCount ? _self.anonymousQuestionCount : anonymousQuestionCount // ignore: cast_nullable_to_non_nullable
as int,currentRank: freezed == currentRank ? _self.currentRank : currentRank // ignore: cast_nullable_to_non_nullable
as String?,currentTitle: freezed == currentTitle ? _self.currentTitle : currentTitle // ignore: cast_nullable_to_non_nullable
as String?,rankChangeDate: freezed == rankChangeDate ? _self.rankChangeDate : rankChangeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,titleChangeDate: freezed == titleChangeDate ? _self.titleChangeDate : titleChangeDate // ignore: cast_nullable_to_non_nullable
as DateTime?,isRankEligible: null == isRankEligible ? _self.isRankEligible : isRankEligible // ignore: cast_nullable_to_non_nullable
as bool,rankEvaluationCount: null == rankEvaluationCount ? _self.rankEvaluationCount : rankEvaluationCount // ignore: cast_nullable_to_non_nullable
as int,rankHistory: null == rankHistory ? _self._rankHistory : rankHistory // ignore: cast_nullable_to_non_nullable
as List<String>,titleHistory: null == titleHistory ? _self._titleHistory : titleHistory // ignore: cast_nullable_to_non_nullable
as List<String>,receiveRankUpdateNotifications: null == receiveRankUpdateNotifications ? _self.receiveRankUpdateNotifications : receiveRankUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,receiveTitleUpdateNotifications: null == receiveTitleUpdateNotifications ? _self.receiveTitleUpdateNotifications : receiveTitleUpdateNotifications // ignore: cast_nullable_to_non_nullable
as bool,characterId: freezed == characterId ? _self.characterId : characterId // ignore: cast_nullable_to_non_nullable
as String?,friends: null == friends ? _self._friends : friends // ignore: cast_nullable_to_non_nullable
as List<String>,activeChats: null == activeChats ? _self._activeChats : activeChats // ignore: cast_nullable_to_non_nullable
as List<String>,groupChats: null == groupChats ? _self._groupChats : groupChats // ignore: cast_nullable_to_non_nullable
as List<String>,role: freezed == role ? _self.role : role // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,stats: null == stats ? _self._stats : stats // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,subscription: null == subscription ? _self._subscription : subscription // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
