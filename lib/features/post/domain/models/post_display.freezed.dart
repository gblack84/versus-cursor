// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_display.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostDisplay {

// Identification
 String get id; String get userId; String get displayName; String get photoUrl;// Content
 String get questionTitle; String? get description; String? get optionAText; String? get optionBText;// Single image URLs (for backward compatibility)
 String? get optionAImageUrl; String? get optionBImageUrl;// Multiple images support
 List<String>? get optionAImages; List<double>? get optionAAspectRatios; List<String>? get optionBImages; List<double>? get optionBAspectRatios; String get layoutType;// Voting
 int get votesA; int get votesB; String get voteStatus; bool get voteCompleted; int? get voteStartTime;// Store as milliseconds since epoch
 int? get voteEndTime;// Store as milliseconds since epoch
// Metrics
 int get commentCount; int get likeCount; int get shareCount;// Metadata
 int get createdAt;// Store as milliseconds since epoch
 bool get isAnonymous; String get status; Map<String, dynamic>? get targetAudience;
/// Create a copy of PostDisplay
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDisplayCopyWith<PostDisplay> get copyWith => _$PostDisplayCopyWithImpl<PostDisplay>(this as PostDisplay, _$identity);

  /// Serializes this PostDisplay to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDisplay&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.questionTitle, questionTitle) || other.questionTitle == questionTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.optionAText, optionAText) || other.optionAText == optionAText)&&(identical(other.optionBText, optionBText) || other.optionBText == optionBText)&&(identical(other.optionAImageUrl, optionAImageUrl) || other.optionAImageUrl == optionAImageUrl)&&(identical(other.optionBImageUrl, optionBImageUrl) || other.optionBImageUrl == optionBImageUrl)&&const DeepCollectionEquality().equals(other.optionAImages, optionAImages)&&const DeepCollectionEquality().equals(other.optionAAspectRatios, optionAAspectRatios)&&const DeepCollectionEquality().equals(other.optionBImages, optionBImages)&&const DeepCollectionEquality().equals(other.optionBAspectRatios, optionBAspectRatios)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.targetAudience, targetAudience));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,displayName,photoUrl,questionTitle,description,optionAText,optionBText,optionAImageUrl,optionBImageUrl,const DeepCollectionEquality().hash(optionAImages),const DeepCollectionEquality().hash(optionAAspectRatios),const DeepCollectionEquality().hash(optionBImages),const DeepCollectionEquality().hash(optionBAspectRatios),layoutType,votesA,votesB,voteStatus,voteCompleted,voteStartTime,voteEndTime,commentCount,likeCount,shareCount,createdAt,isAnonymous,status,const DeepCollectionEquality().hash(targetAudience)]);

@override
String toString() {
  return 'PostDisplay(id: $id, userId: $userId, displayName: $displayName, photoUrl: $photoUrl, questionTitle: $questionTitle, description: $description, optionAText: $optionAText, optionBText: $optionBText, optionAImageUrl: $optionAImageUrl, optionBImageUrl: $optionBImageUrl, optionAImages: $optionAImages, optionAAspectRatios: $optionAAspectRatios, optionBImages: $optionBImages, optionBAspectRatios: $optionBAspectRatios, layoutType: $layoutType, votesA: $votesA, votesB: $votesB, voteStatus: $voteStatus, voteCompleted: $voteCompleted, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, commentCount: $commentCount, likeCount: $likeCount, shareCount: $shareCount, createdAt: $createdAt, isAnonymous: $isAnonymous, status: $status, targetAudience: $targetAudience)';
}


}

/// @nodoc
abstract mixin class $PostDisplayCopyWith<$Res>  {
  factory $PostDisplayCopyWith(PostDisplay value, $Res Function(PostDisplay) _then) = _$PostDisplayCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String displayName, String photoUrl, String questionTitle, String? description, String? optionAText, String? optionBText, String? optionAImageUrl, String? optionBImageUrl, List<String>? optionAImages, List<double>? optionAAspectRatios, List<String>? optionBImages, List<double>? optionBAspectRatios, String layoutType, int votesA, int votesB, String voteStatus, bool voteCompleted, int? voteStartTime, int? voteEndTime, int commentCount, int likeCount, int shareCount, int createdAt, bool isAnonymous, String status, Map<String, dynamic>? targetAudience
});




}
/// @nodoc
class _$PostDisplayCopyWithImpl<$Res>
    implements $PostDisplayCopyWith<$Res> {
  _$PostDisplayCopyWithImpl(this._self, this._then);

  final PostDisplay _self;
  final $Res Function(PostDisplay) _then;

/// Create a copy of PostDisplay
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? displayName = null,Object? photoUrl = null,Object? questionTitle = null,Object? description = freezed,Object? optionAText = freezed,Object? optionBText = freezed,Object? optionAImageUrl = freezed,Object? optionBImageUrl = freezed,Object? optionAImages = freezed,Object? optionAAspectRatios = freezed,Object? optionBImages = freezed,Object? optionBAspectRatios = freezed,Object? layoutType = null,Object? votesA = null,Object? votesB = null,Object? voteStatus = null,Object? voteCompleted = null,Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? commentCount = null,Object? likeCount = null,Object? shareCount = null,Object? createdAt = null,Object? isAnonymous = null,Object? status = null,Object? targetAudience = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,questionTitle: null == questionTitle ? _self.questionTitle : questionTitle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,optionAText: freezed == optionAText ? _self.optionAText : optionAText // ignore: cast_nullable_to_non_nullable
as String?,optionBText: freezed == optionBText ? _self.optionBText : optionBText // ignore: cast_nullable_to_non_nullable
as String?,optionAImageUrl: freezed == optionAImageUrl ? _self.optionAImageUrl : optionAImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionBImageUrl: freezed == optionBImageUrl ? _self.optionBImageUrl : optionBImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionAImages: freezed == optionAImages ? _self.optionAImages : optionAImages // ignore: cast_nullable_to_non_nullable
as List<String>?,optionAAspectRatios: freezed == optionAAspectRatios ? _self.optionAAspectRatios : optionAAspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>?,optionBImages: freezed == optionBImages ? _self.optionBImages : optionBImages // ignore: cast_nullable_to_non_nullable
as List<String>?,optionBAspectRatios: freezed == optionBAspectRatios ? _self.optionBAspectRatios : optionBAspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>?,layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as int?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as int?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostDisplay].
extension PostDisplayPatterns on PostDisplay {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostDisplay value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostDisplay() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostDisplay value)  $default,){
final _that = this;
switch (_that) {
case _PostDisplay():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostDisplay value)?  $default,){
final _that = this;
switch (_that) {
case _PostDisplay() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String displayName,  String photoUrl,  String questionTitle,  String? description,  String? optionAText,  String? optionBText,  String? optionAImageUrl,  String? optionBImageUrl,  List<String>? optionAImages,  List<double>? optionAAspectRatios,  List<String>? optionBImages,  List<double>? optionBAspectRatios,  String layoutType,  int votesA,  int votesB,  String voteStatus,  bool voteCompleted,  int? voteStartTime,  int? voteEndTime,  int commentCount,  int likeCount,  int shareCount,  int createdAt,  bool isAnonymous,  String status,  Map<String, dynamic>? targetAudience)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostDisplay() when $default != null:
return $default(_that.id,_that.userId,_that.displayName,_that.photoUrl,_that.questionTitle,_that.description,_that.optionAText,_that.optionBText,_that.optionAImageUrl,_that.optionBImageUrl,_that.optionAImages,_that.optionAAspectRatios,_that.optionBImages,_that.optionBAspectRatios,_that.layoutType,_that.votesA,_that.votesB,_that.voteStatus,_that.voteCompleted,_that.voteStartTime,_that.voteEndTime,_that.commentCount,_that.likeCount,_that.shareCount,_that.createdAt,_that.isAnonymous,_that.status,_that.targetAudience);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String displayName,  String photoUrl,  String questionTitle,  String? description,  String? optionAText,  String? optionBText,  String? optionAImageUrl,  String? optionBImageUrl,  List<String>? optionAImages,  List<double>? optionAAspectRatios,  List<String>? optionBImages,  List<double>? optionBAspectRatios,  String layoutType,  int votesA,  int votesB,  String voteStatus,  bool voteCompleted,  int? voteStartTime,  int? voteEndTime,  int commentCount,  int likeCount,  int shareCount,  int createdAt,  bool isAnonymous,  String status,  Map<String, dynamic>? targetAudience)  $default,) {final _that = this;
switch (_that) {
case _PostDisplay():
return $default(_that.id,_that.userId,_that.displayName,_that.photoUrl,_that.questionTitle,_that.description,_that.optionAText,_that.optionBText,_that.optionAImageUrl,_that.optionBImageUrl,_that.optionAImages,_that.optionAAspectRatios,_that.optionBImages,_that.optionBAspectRatios,_that.layoutType,_that.votesA,_that.votesB,_that.voteStatus,_that.voteCompleted,_that.voteStartTime,_that.voteEndTime,_that.commentCount,_that.likeCount,_that.shareCount,_that.createdAt,_that.isAnonymous,_that.status,_that.targetAudience);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String displayName,  String photoUrl,  String questionTitle,  String? description,  String? optionAText,  String? optionBText,  String? optionAImageUrl,  String? optionBImageUrl,  List<String>? optionAImages,  List<double>? optionAAspectRatios,  List<String>? optionBImages,  List<double>? optionBAspectRatios,  String layoutType,  int votesA,  int votesB,  String voteStatus,  bool voteCompleted,  int? voteStartTime,  int? voteEndTime,  int commentCount,  int likeCount,  int shareCount,  int createdAt,  bool isAnonymous,  String status,  Map<String, dynamic>? targetAudience)?  $default,) {final _that = this;
switch (_that) {
case _PostDisplay() when $default != null:
return $default(_that.id,_that.userId,_that.displayName,_that.photoUrl,_that.questionTitle,_that.description,_that.optionAText,_that.optionBText,_that.optionAImageUrl,_that.optionBImageUrl,_that.optionAImages,_that.optionAAspectRatios,_that.optionBImages,_that.optionBAspectRatios,_that.layoutType,_that.votesA,_that.votesB,_that.voteStatus,_that.voteCompleted,_that.voteStartTime,_that.voteEndTime,_that.commentCount,_that.likeCount,_that.shareCount,_that.createdAt,_that.isAnonymous,_that.status,_that.targetAudience);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostDisplay extends PostDisplay {
  const _PostDisplay({required this.id, required this.userId, required this.displayName, required this.photoUrl, required this.questionTitle, this.description, this.optionAText, this.optionBText, this.optionAImageUrl, this.optionBImageUrl, final  List<String>? optionAImages, final  List<double>? optionAAspectRatios, final  List<String>? optionBImages, final  List<double>? optionBAspectRatios, this.layoutType = 'vertical', this.votesA = 0, this.votesB = 0, this.voteStatus = 'pending', this.voteCompleted = false, this.voteStartTime, this.voteEndTime, this.commentCount = 0, this.likeCount = 0, this.shareCount = 0, required this.createdAt, this.isAnonymous = false, this.status = 'published', final  Map<String, dynamic>? targetAudience}): _optionAImages = optionAImages,_optionAAspectRatios = optionAAspectRatios,_optionBImages = optionBImages,_optionBAspectRatios = optionBAspectRatios,_targetAudience = targetAudience,super._();
  factory _PostDisplay.fromJson(Map<String, dynamic> json) => _$PostDisplayFromJson(json);

// Identification
@override final  String id;
@override final  String userId;
@override final  String displayName;
@override final  String photoUrl;
// Content
@override final  String questionTitle;
@override final  String? description;
@override final  String? optionAText;
@override final  String? optionBText;
// Single image URLs (for backward compatibility)
@override final  String? optionAImageUrl;
@override final  String? optionBImageUrl;
// Multiple images support
 final  List<String>? _optionAImages;
// Multiple images support
@override List<String>? get optionAImages {
  final value = _optionAImages;
  if (value == null) return null;
  if (_optionAImages is EqualUnmodifiableListView) return _optionAImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<double>? _optionAAspectRatios;
@override List<double>? get optionAAspectRatios {
  final value = _optionAAspectRatios;
  if (value == null) return null;
  if (_optionAAspectRatios is EqualUnmodifiableListView) return _optionAAspectRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _optionBImages;
@override List<String>? get optionBImages {
  final value = _optionBImages;
  if (value == null) return null;
  if (_optionBImages is EqualUnmodifiableListView) return _optionBImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<double>? _optionBAspectRatios;
@override List<double>? get optionBAspectRatios {
  final value = _optionBAspectRatios;
  if (value == null) return null;
  if (_optionBAspectRatios is EqualUnmodifiableListView) return _optionBAspectRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String layoutType;
// Voting
@override@JsonKey() final  int votesA;
@override@JsonKey() final  int votesB;
@override@JsonKey() final  String voteStatus;
@override@JsonKey() final  bool voteCompleted;
@override final  int? voteStartTime;
// Store as milliseconds since epoch
@override final  int? voteEndTime;
// Store as milliseconds since epoch
// Metrics
@override@JsonKey() final  int commentCount;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int shareCount;
// Metadata
@override final  int createdAt;
// Store as milliseconds since epoch
@override@JsonKey() final  bool isAnonymous;
@override@JsonKey() final  String status;
 final  Map<String, dynamic>? _targetAudience;
@override Map<String, dynamic>? get targetAudience {
  final value = _targetAudience;
  if (value == null) return null;
  if (_targetAudience is EqualUnmodifiableMapView) return _targetAudience;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PostDisplay
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostDisplayCopyWith<_PostDisplay> get copyWith => __$PostDisplayCopyWithImpl<_PostDisplay>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostDisplayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostDisplay&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.questionTitle, questionTitle) || other.questionTitle == questionTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.optionAText, optionAText) || other.optionAText == optionAText)&&(identical(other.optionBText, optionBText) || other.optionBText == optionBText)&&(identical(other.optionAImageUrl, optionAImageUrl) || other.optionAImageUrl == optionAImageUrl)&&(identical(other.optionBImageUrl, optionBImageUrl) || other.optionBImageUrl == optionBImageUrl)&&const DeepCollectionEquality().equals(other._optionAImages, _optionAImages)&&const DeepCollectionEquality().equals(other._optionAAspectRatios, _optionAAspectRatios)&&const DeepCollectionEquality().equals(other._optionBImages, _optionBImages)&&const DeepCollectionEquality().equals(other._optionBAspectRatios, _optionBAspectRatios)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType)&&(identical(other.votesA, votesA) || other.votesA == votesA)&&(identical(other.votesB, votesB) || other.votesB == votesB)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.voteCompleted, voteCompleted) || other.voteCompleted == voteCompleted)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.shareCount, shareCount) || other.shareCount == shareCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._targetAudience, _targetAudience));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,displayName,photoUrl,questionTitle,description,optionAText,optionBText,optionAImageUrl,optionBImageUrl,const DeepCollectionEquality().hash(_optionAImages),const DeepCollectionEquality().hash(_optionAAspectRatios),const DeepCollectionEquality().hash(_optionBImages),const DeepCollectionEquality().hash(_optionBAspectRatios),layoutType,votesA,votesB,voteStatus,voteCompleted,voteStartTime,voteEndTime,commentCount,likeCount,shareCount,createdAt,isAnonymous,status,const DeepCollectionEquality().hash(_targetAudience)]);

@override
String toString() {
  return 'PostDisplay(id: $id, userId: $userId, displayName: $displayName, photoUrl: $photoUrl, questionTitle: $questionTitle, description: $description, optionAText: $optionAText, optionBText: $optionBText, optionAImageUrl: $optionAImageUrl, optionBImageUrl: $optionBImageUrl, optionAImages: $optionAImages, optionAAspectRatios: $optionAAspectRatios, optionBImages: $optionBImages, optionBAspectRatios: $optionBAspectRatios, layoutType: $layoutType, votesA: $votesA, votesB: $votesB, voteStatus: $voteStatus, voteCompleted: $voteCompleted, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, commentCount: $commentCount, likeCount: $likeCount, shareCount: $shareCount, createdAt: $createdAt, isAnonymous: $isAnonymous, status: $status, targetAudience: $targetAudience)';
}


}

/// @nodoc
abstract mixin class _$PostDisplayCopyWith<$Res> implements $PostDisplayCopyWith<$Res> {
  factory _$PostDisplayCopyWith(_PostDisplay value, $Res Function(_PostDisplay) _then) = __$PostDisplayCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String displayName, String photoUrl, String questionTitle, String? description, String? optionAText, String? optionBText, String? optionAImageUrl, String? optionBImageUrl, List<String>? optionAImages, List<double>? optionAAspectRatios, List<String>? optionBImages, List<double>? optionBAspectRatios, String layoutType, int votesA, int votesB, String voteStatus, bool voteCompleted, int? voteStartTime, int? voteEndTime, int commentCount, int likeCount, int shareCount, int createdAt, bool isAnonymous, String status, Map<String, dynamic>? targetAudience
});




}
/// @nodoc
class __$PostDisplayCopyWithImpl<$Res>
    implements _$PostDisplayCopyWith<$Res> {
  __$PostDisplayCopyWithImpl(this._self, this._then);

  final _PostDisplay _self;
  final $Res Function(_PostDisplay) _then;

/// Create a copy of PostDisplay
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? displayName = null,Object? photoUrl = null,Object? questionTitle = null,Object? description = freezed,Object? optionAText = freezed,Object? optionBText = freezed,Object? optionAImageUrl = freezed,Object? optionBImageUrl = freezed,Object? optionAImages = freezed,Object? optionAAspectRatios = freezed,Object? optionBImages = freezed,Object? optionBAspectRatios = freezed,Object? layoutType = null,Object? votesA = null,Object? votesB = null,Object? voteStatus = null,Object? voteCompleted = null,Object? voteStartTime = freezed,Object? voteEndTime = freezed,Object? commentCount = null,Object? likeCount = null,Object? shareCount = null,Object? createdAt = null,Object? isAnonymous = null,Object? status = null,Object? targetAudience = freezed,}) {
  return _then(_PostDisplay(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,questionTitle: null == questionTitle ? _self.questionTitle : questionTitle // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,optionAText: freezed == optionAText ? _self.optionAText : optionAText // ignore: cast_nullable_to_non_nullable
as String?,optionBText: freezed == optionBText ? _self.optionBText : optionBText // ignore: cast_nullable_to_non_nullable
as String?,optionAImageUrl: freezed == optionAImageUrl ? _self.optionAImageUrl : optionAImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionBImageUrl: freezed == optionBImageUrl ? _self.optionBImageUrl : optionBImageUrl // ignore: cast_nullable_to_non_nullable
as String?,optionAImages: freezed == optionAImages ? _self._optionAImages : optionAImages // ignore: cast_nullable_to_non_nullable
as List<String>?,optionAAspectRatios: freezed == optionAAspectRatios ? _self._optionAAspectRatios : optionAAspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>?,optionBImages: freezed == optionBImages ? _self._optionBImages : optionBImages // ignore: cast_nullable_to_non_nullable
as List<String>?,optionBAspectRatios: freezed == optionBAspectRatios ? _self._optionBAspectRatios : optionBAspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>?,layoutType: null == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String,votesA: null == votesA ? _self.votesA : votesA // ignore: cast_nullable_to_non_nullable
as int,votesB: null == votesB ? _self.votesB : votesB // ignore: cast_nullable_to_non_nullable
as int,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,voteCompleted: null == voteCompleted ? _self.voteCompleted : voteCompleted // ignore: cast_nullable_to_non_nullable
as bool,voteStartTime: freezed == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as int?,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as int?,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,shareCount: null == shareCount ? _self.shareCount : shareCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,targetAudience: freezed == targetAudience ? _self._targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
