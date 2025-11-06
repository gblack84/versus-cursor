// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_creation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostCreation {

 String? get id; String get userId; String get title; String get description; PostOption get optionA; PostOption get optionB; TargetAudience? get targetAudience; DateTime get createdAt; DateTime? get updatedAt; PostStatus get status; int get likeCount; int get commentCount; VoteConfiguration? get voteConfig; bool get isAnonymous; String? get category; List<String>? get tags; Map<String, dynamic>? get metadata;
/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreationCopyWith<PostCreation> get copyWith => _$PostCreationCopyWithImpl<PostCreation>(this as PostCreation, _$identity);

  /// Serializes this PostCreation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreation&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.optionA, optionA) || other.optionA == optionA)&&(identical(other.optionB, optionB) || other.optionB == optionB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.voteConfig, voteConfig) || other.voteConfig == voteConfig)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,description,optionA,optionB,targetAudience,createdAt,updatedAt,status,likeCount,commentCount,voteConfig,isAnonymous,category,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PostCreation(id: $id, userId: $userId, title: $title, description: $description, optionA: $optionA, optionB: $optionB, targetAudience: $targetAudience, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, likeCount: $likeCount, commentCount: $commentCount, voteConfig: $voteConfig, isAnonymous: $isAnonymous, category: $category, tags: $tags, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PostCreationCopyWith<$Res>  {
  factory $PostCreationCopyWith(PostCreation value, $Res Function(PostCreation) _then) = _$PostCreationCopyWithImpl;
@useResult
$Res call({
 String? id, String userId, String title, String description, PostOption optionA, PostOption optionB, TargetAudience? targetAudience, DateTime createdAt, DateTime? updatedAt, PostStatus status, int likeCount, int commentCount, VoteConfiguration? voteConfig, bool isAnonymous, String? category, List<String>? tags, Map<String, dynamic>? metadata
});


$PostOptionCopyWith<$Res> get optionA;$PostOptionCopyWith<$Res> get optionB;$TargetAudienceCopyWith<$Res>? get targetAudience;$VoteConfigurationCopyWith<$Res>? get voteConfig;

}
/// @nodoc
class _$PostCreationCopyWithImpl<$Res>
    implements $PostCreationCopyWith<$Res> {
  _$PostCreationCopyWithImpl(this._self, this._then);

  final PostCreation _self;
  final $Res Function(PostCreation) _then;

/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = null,Object? title = null,Object? description = null,Object? optionA = null,Object? optionB = null,Object? targetAudience = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? voteConfig = freezed,Object? isAnonymous = null,Object? category = freezed,Object? tags = freezed,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,optionA: null == optionA ? _self.optionA : optionA // ignore: cast_nullable_to_non_nullable
as PostOption,optionB: null == optionB ? _self.optionB : optionB // ignore: cast_nullable_to_non_nullable
as PostOption,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,voteConfig: freezed == voteConfig ? _self.voteConfig : voteConfig // ignore: cast_nullable_to_non_nullable
as VoteConfiguration?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}
/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostOptionCopyWith<$Res> get optionA {
  
  return $PostOptionCopyWith<$Res>(_self.optionA, (value) {
    return _then(_self.copyWith(optionA: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostOptionCopyWith<$Res> get optionB {
  
  return $PostOptionCopyWith<$Res>(_self.optionB, (value) {
    return _then(_self.copyWith(optionB: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteConfigurationCopyWith<$Res>? get voteConfig {
    if (_self.voteConfig == null) {
    return null;
  }

  return $VoteConfigurationCopyWith<$Res>(_self.voteConfig!, (value) {
    return _then(_self.copyWith(voteConfig: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostCreation].
extension PostCreationPatterns on PostCreation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostCreation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostCreation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostCreation value)  $default,){
final _that = this;
switch (_that) {
case _PostCreation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostCreation value)?  $default,){
final _that = this;
switch (_that) {
case _PostCreation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String userId,  String title,  String description,  PostOption optionA,  PostOption optionB,  TargetAudience? targetAudience,  DateTime createdAt,  DateTime? updatedAt,  PostStatus status,  int likeCount,  int commentCount,  VoteConfiguration? voteConfig,  bool isAnonymous,  String? category,  List<String>? tags,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostCreation() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.description,_that.optionA,_that.optionB,_that.targetAudience,_that.createdAt,_that.updatedAt,_that.status,_that.likeCount,_that.commentCount,_that.voteConfig,_that.isAnonymous,_that.category,_that.tags,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String userId,  String title,  String description,  PostOption optionA,  PostOption optionB,  TargetAudience? targetAudience,  DateTime createdAt,  DateTime? updatedAt,  PostStatus status,  int likeCount,  int commentCount,  VoteConfiguration? voteConfig,  bool isAnonymous,  String? category,  List<String>? tags,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PostCreation():
return $default(_that.id,_that.userId,_that.title,_that.description,_that.optionA,_that.optionB,_that.targetAudience,_that.createdAt,_that.updatedAt,_that.status,_that.likeCount,_that.commentCount,_that.voteConfig,_that.isAnonymous,_that.category,_that.tags,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String userId,  String title,  String description,  PostOption optionA,  PostOption optionB,  TargetAudience? targetAudience,  DateTime createdAt,  DateTime? updatedAt,  PostStatus status,  int likeCount,  int commentCount,  VoteConfiguration? voteConfig,  bool isAnonymous,  String? category,  List<String>? tags,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PostCreation() when $default != null:
return $default(_that.id,_that.userId,_that.title,_that.description,_that.optionA,_that.optionB,_that.targetAudience,_that.createdAt,_that.updatedAt,_that.status,_that.likeCount,_that.commentCount,_that.voteConfig,_that.isAnonymous,_that.category,_that.tags,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostCreation extends PostCreation {
  const _PostCreation({this.id, required this.userId, required this.title, required this.description, required this.optionA, required this.optionB, this.targetAudience, required this.createdAt, this.updatedAt, this.status = PostStatus.draft, this.likeCount = 0, this.commentCount = 0, this.voteConfig, this.isAnonymous = false, this.category, final  List<String>? tags, final  Map<String, dynamic>? metadata}): _tags = tags,_metadata = metadata,super._();
  factory _PostCreation.fromJson(Map<String, dynamic> json) => _$PostCreationFromJson(json);

@override final  String? id;
@override final  String userId;
@override final  String title;
@override final  String description;
@override final  PostOption optionA;
@override final  PostOption optionB;
@override final  TargetAudience? targetAudience;
@override final  DateTime createdAt;
@override final  DateTime? updatedAt;
@override@JsonKey() final  PostStatus status;
@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override final  VoteConfiguration? voteConfig;
@override@JsonKey() final  bool isAnonymous;
@override final  String? category;
 final  List<String>? _tags;
@override List<String>? get tags {
  final value = _tags;
  if (value == null) return null;
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostCreationCopyWith<_PostCreation> get copyWith => __$PostCreationCopyWithImpl<_PostCreation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostCreationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostCreation&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.optionA, optionA) || other.optionA == optionA)&&(identical(other.optionB, optionB) || other.optionB == optionB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.voteConfig, voteConfig) || other.voteConfig == voteConfig)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.category, category) || other.category == category)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,title,description,optionA,optionB,targetAudience,createdAt,updatedAt,status,likeCount,commentCount,voteConfig,isAnonymous,category,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PostCreation(id: $id, userId: $userId, title: $title, description: $description, optionA: $optionA, optionB: $optionB, targetAudience: $targetAudience, createdAt: $createdAt, updatedAt: $updatedAt, status: $status, likeCount: $likeCount, commentCount: $commentCount, voteConfig: $voteConfig, isAnonymous: $isAnonymous, category: $category, tags: $tags, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PostCreationCopyWith<$Res> implements $PostCreationCopyWith<$Res> {
  factory _$PostCreationCopyWith(_PostCreation value, $Res Function(_PostCreation) _then) = __$PostCreationCopyWithImpl;
@override @useResult
$Res call({
 String? id, String userId, String title, String description, PostOption optionA, PostOption optionB, TargetAudience? targetAudience, DateTime createdAt, DateTime? updatedAt, PostStatus status, int likeCount, int commentCount, VoteConfiguration? voteConfig, bool isAnonymous, String? category, List<String>? tags, Map<String, dynamic>? metadata
});


@override $PostOptionCopyWith<$Res> get optionA;@override $PostOptionCopyWith<$Res> get optionB;@override $TargetAudienceCopyWith<$Res>? get targetAudience;@override $VoteConfigurationCopyWith<$Res>? get voteConfig;

}
/// @nodoc
class __$PostCreationCopyWithImpl<$Res>
    implements _$PostCreationCopyWith<$Res> {
  __$PostCreationCopyWithImpl(this._self, this._then);

  final _PostCreation _self;
  final $Res Function(_PostCreation) _then;

/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = null,Object? title = null,Object? description = null,Object? optionA = null,Object? optionB = null,Object? targetAudience = freezed,Object? createdAt = null,Object? updatedAt = freezed,Object? status = null,Object? likeCount = null,Object? commentCount = null,Object? voteConfig = freezed,Object? isAnonymous = null,Object? category = freezed,Object? tags = freezed,Object? metadata = freezed,}) {
  return _then(_PostCreation(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,optionA: null == optionA ? _self.optionA : optionA // ignore: cast_nullable_to_non_nullable
as PostOption,optionB: null == optionB ? _self.optionB : optionB // ignore: cast_nullable_to_non_nullable
as PostOption,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PostStatus,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,voteConfig: freezed == voteConfig ? _self.voteConfig : voteConfig // ignore: cast_nullable_to_non_nullable
as VoteConfiguration?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,tags: freezed == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>?,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostOptionCopyWith<$Res> get optionA {
  
  return $PostOptionCopyWith<$Res>(_self.optionA, (value) {
    return _then(_self.copyWith(optionA: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostOptionCopyWith<$Res> get optionB {
  
  return $PostOptionCopyWith<$Res>(_self.optionB, (value) {
    return _then(_self.copyWith(optionB: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}/// Create a copy of PostCreation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteConfigurationCopyWith<$Res>? get voteConfig {
    if (_self.voteConfig == null) {
    return null;
  }

  return $VoteConfigurationCopyWith<$Res>(_self.voteConfig!, (value) {
    return _then(_self.copyWith(voteConfig: value));
  });
}
}


/// @nodoc
mixin _$PostOption {

 String? get text; List<String> get imageUrls; List<String>? get videoUrls; List<double> get aspectRatios; Map<String, dynamic>? get metadata;
/// Create a copy of PostOption
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostOptionCopyWith<PostOption> get copyWith => _$PostOptionCopyWithImpl<PostOption>(this as PostOption, _$identity);

  /// Serializes this PostOption to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostOption&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other.imageUrls, imageUrls)&&const DeepCollectionEquality().equals(other.videoUrls, videoUrls)&&const DeepCollectionEquality().equals(other.aspectRatios, aspectRatios)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(imageUrls),const DeepCollectionEquality().hash(videoUrls),const DeepCollectionEquality().hash(aspectRatios),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'PostOption(text: $text, imageUrls: $imageUrls, videoUrls: $videoUrls, aspectRatios: $aspectRatios, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $PostOptionCopyWith<$Res>  {
  factory $PostOptionCopyWith(PostOption value, $Res Function(PostOption) _then) = _$PostOptionCopyWithImpl;
@useResult
$Res call({
 String? text, List<String> imageUrls, List<String>? videoUrls, List<double> aspectRatios, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$PostOptionCopyWithImpl<$Res>
    implements $PostOptionCopyWith<$Res> {
  _$PostOptionCopyWithImpl(this._self, this._then);

  final PostOption _self;
  final $Res Function(PostOption) _then;

/// Create a copy of PostOption
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? text = freezed,Object? imageUrls = null,Object? videoUrls = freezed,Object? aspectRatios = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self.imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrls: freezed == videoUrls ? _self.videoUrls : videoUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,aspectRatios: null == aspectRatios ? _self.aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [PostOption].
extension PostOptionPatterns on PostOption {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostOption value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostOption() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostOption value)  $default,){
final _that = this;
switch (_that) {
case _PostOption():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostOption value)?  $default,){
final _that = this;
switch (_that) {
case _PostOption() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? text,  List<String> imageUrls,  List<String>? videoUrls,  List<double> aspectRatios,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostOption() when $default != null:
return $default(_that.text,_that.imageUrls,_that.videoUrls,_that.aspectRatios,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? text,  List<String> imageUrls,  List<String>? videoUrls,  List<double> aspectRatios,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _PostOption():
return $default(_that.text,_that.imageUrls,_that.videoUrls,_that.aspectRatios,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? text,  List<String> imageUrls,  List<String>? videoUrls,  List<double> aspectRatios,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _PostOption() when $default != null:
return $default(_that.text,_that.imageUrls,_that.videoUrls,_that.aspectRatios,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PostOption implements PostOption {
  const _PostOption({this.text, final  List<String> imageUrls = const [], final  List<String>? videoUrls, final  List<double> aspectRatios = const [], final  Map<String, dynamic>? metadata}): _imageUrls = imageUrls,_videoUrls = videoUrls,_aspectRatios = aspectRatios,_metadata = metadata;
  factory _PostOption.fromJson(Map<String, dynamic> json) => _$PostOptionFromJson(json);

@override final  String? text;
 final  List<String> _imageUrls;
@override@JsonKey() List<String> get imageUrls {
  if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrls);
}

 final  List<String>? _videoUrls;
@override List<String>? get videoUrls {
  final value = _videoUrls;
  if (value == null) return null;
  if (_videoUrls is EqualUnmodifiableListView) return _videoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<double> _aspectRatios;
@override@JsonKey() List<double> get aspectRatios {
  if (_aspectRatios is EqualUnmodifiableListView) return _aspectRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatios);
}

 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of PostOption
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostOptionCopyWith<_PostOption> get copyWith => __$PostOptionCopyWithImpl<_PostOption>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PostOptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostOption&&(identical(other.text, text) || other.text == text)&&const DeepCollectionEquality().equals(other._imageUrls, _imageUrls)&&const DeepCollectionEquality().equals(other._videoUrls, _videoUrls)&&const DeepCollectionEquality().equals(other._aspectRatios, _aspectRatios)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,text,const DeepCollectionEquality().hash(_imageUrls),const DeepCollectionEquality().hash(_videoUrls),const DeepCollectionEquality().hash(_aspectRatios),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'PostOption(text: $text, imageUrls: $imageUrls, videoUrls: $videoUrls, aspectRatios: $aspectRatios, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$PostOptionCopyWith<$Res> implements $PostOptionCopyWith<$Res> {
  factory _$PostOptionCopyWith(_PostOption value, $Res Function(_PostOption) _then) = __$PostOptionCopyWithImpl;
@override @useResult
$Res call({
 String? text, List<String> imageUrls, List<String>? videoUrls, List<double> aspectRatios, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$PostOptionCopyWithImpl<$Res>
    implements _$PostOptionCopyWith<$Res> {
  __$PostOptionCopyWithImpl(this._self, this._then);

  final _PostOption _self;
  final $Res Function(_PostOption) _then;

/// Create a copy of PostOption
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? text = freezed,Object? imageUrls = null,Object? videoUrls = freezed,Object? aspectRatios = null,Object? metadata = freezed,}) {
  return _then(_PostOption(
text: freezed == text ? _self.text : text // ignore: cast_nullable_to_non_nullable
as String?,imageUrls: null == imageUrls ? _self._imageUrls : imageUrls // ignore: cast_nullable_to_non_nullable
as List<String>,videoUrls: freezed == videoUrls ? _self._videoUrls : videoUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,aspectRatios: null == aspectRatios ? _self._aspectRatios : aspectRatios // ignore: cast_nullable_to_non_nullable
as List<double>,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$VoteConfiguration {

 DateTime? get startTime; DateTime? get endTime; int? get duration; bool get allowAnonymous; bool get requiresExpansion; Map<String, dynamic>? get settings;
/// Create a copy of VoteConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteConfigurationCopyWith<VoteConfiguration> get copyWith => _$VoteConfigurationCopyWithImpl<VoteConfiguration>(this as VoteConfiguration, _$identity);

  /// Serializes this VoteConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteConfiguration&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.allowAnonymous, allowAnonymous) || other.allowAnonymous == allowAnonymous)&&(identical(other.requiresExpansion, requiresExpansion) || other.requiresExpansion == requiresExpansion)&&const DeepCollectionEquality().equals(other.settings, settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,duration,allowAnonymous,requiresExpansion,const DeepCollectionEquality().hash(settings));

@override
String toString() {
  return 'VoteConfiguration(startTime: $startTime, endTime: $endTime, duration: $duration, allowAnonymous: $allowAnonymous, requiresExpansion: $requiresExpansion, settings: $settings)';
}


}

/// @nodoc
abstract mixin class $VoteConfigurationCopyWith<$Res>  {
  factory $VoteConfigurationCopyWith(VoteConfiguration value, $Res Function(VoteConfiguration) _then) = _$VoteConfigurationCopyWithImpl;
@useResult
$Res call({
 DateTime? startTime, DateTime? endTime, int? duration, bool allowAnonymous, bool requiresExpansion, Map<String, dynamic>? settings
});




}
/// @nodoc
class _$VoteConfigurationCopyWithImpl<$Res>
    implements $VoteConfigurationCopyWith<$Res> {
  _$VoteConfigurationCopyWithImpl(this._self, this._then);

  final VoteConfiguration _self;
  final $Res Function(VoteConfiguration) _then;

/// Create a copy of VoteConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? startTime = freezed,Object? endTime = freezed,Object? duration = freezed,Object? allowAnonymous = null,Object? requiresExpansion = null,Object? settings = freezed,}) {
  return _then(_self.copyWith(
startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,allowAnonymous: null == allowAnonymous ? _self.allowAnonymous : allowAnonymous // ignore: cast_nullable_to_non_nullable
as bool,requiresExpansion: null == requiresExpansion ? _self.requiresExpansion : requiresExpansion // ignore: cast_nullable_to_non_nullable
as bool,settings: freezed == settings ? _self.settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteConfiguration].
extension VoteConfigurationPatterns on VoteConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _VoteConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _VoteConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime? startTime,  DateTime? endTime,  int? duration,  bool allowAnonymous,  bool requiresExpansion,  Map<String, dynamic>? settings)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteConfiguration() when $default != null:
return $default(_that.startTime,_that.endTime,_that.duration,_that.allowAnonymous,_that.requiresExpansion,_that.settings);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime? startTime,  DateTime? endTime,  int? duration,  bool allowAnonymous,  bool requiresExpansion,  Map<String, dynamic>? settings)  $default,) {final _that = this;
switch (_that) {
case _VoteConfiguration():
return $default(_that.startTime,_that.endTime,_that.duration,_that.allowAnonymous,_that.requiresExpansion,_that.settings);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime? startTime,  DateTime? endTime,  int? duration,  bool allowAnonymous,  bool requiresExpansion,  Map<String, dynamic>? settings)?  $default,) {final _that = this;
switch (_that) {
case _VoteConfiguration() when $default != null:
return $default(_that.startTime,_that.endTime,_that.duration,_that.allowAnonymous,_that.requiresExpansion,_that.settings);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteConfiguration implements VoteConfiguration {
  const _VoteConfiguration({this.startTime, this.endTime, this.duration, this.allowAnonymous = false, this.requiresExpansion = false, final  Map<String, dynamic>? settings}): _settings = settings;
  factory _VoteConfiguration.fromJson(Map<String, dynamic> json) => _$VoteConfigurationFromJson(json);

@override final  DateTime? startTime;
@override final  DateTime? endTime;
@override final  int? duration;
@override@JsonKey() final  bool allowAnonymous;
@override@JsonKey() final  bool requiresExpansion;
 final  Map<String, dynamic>? _settings;
@override Map<String, dynamic>? get settings {
  final value = _settings;
  if (value == null) return null;
  if (_settings is EqualUnmodifiableMapView) return _settings;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of VoteConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteConfigurationCopyWith<_VoteConfiguration> get copyWith => __$VoteConfigurationCopyWithImpl<_VoteConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteConfiguration&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.allowAnonymous, allowAnonymous) || other.allowAnonymous == allowAnonymous)&&(identical(other.requiresExpansion, requiresExpansion) || other.requiresExpansion == requiresExpansion)&&const DeepCollectionEquality().equals(other._settings, _settings));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,startTime,endTime,duration,allowAnonymous,requiresExpansion,const DeepCollectionEquality().hash(_settings));

@override
String toString() {
  return 'VoteConfiguration(startTime: $startTime, endTime: $endTime, duration: $duration, allowAnonymous: $allowAnonymous, requiresExpansion: $requiresExpansion, settings: $settings)';
}


}

/// @nodoc
abstract mixin class _$VoteConfigurationCopyWith<$Res> implements $VoteConfigurationCopyWith<$Res> {
  factory _$VoteConfigurationCopyWith(_VoteConfiguration value, $Res Function(_VoteConfiguration) _then) = __$VoteConfigurationCopyWithImpl;
@override @useResult
$Res call({
 DateTime? startTime, DateTime? endTime, int? duration, bool allowAnonymous, bool requiresExpansion, Map<String, dynamic>? settings
});




}
/// @nodoc
class __$VoteConfigurationCopyWithImpl<$Res>
    implements _$VoteConfigurationCopyWith<$Res> {
  __$VoteConfigurationCopyWithImpl(this._self, this._then);

  final _VoteConfiguration _self;
  final $Res Function(_VoteConfiguration) _then;

/// Create a copy of VoteConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? startTime = freezed,Object? endTime = freezed,Object? duration = freezed,Object? allowAnonymous = null,Object? requiresExpansion = null,Object? settings = freezed,}) {
  return _then(_VoteConfiguration(
startTime: freezed == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime?,endTime: freezed == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime?,duration: freezed == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as int?,allowAnonymous: null == allowAnonymous ? _self.allowAnonymous : allowAnonymous // ignore: cast_nullable_to_non_nullable
as bool,requiresExpansion: null == requiresExpansion ? _self.requiresExpansion : requiresExpansion // ignore: cast_nullable_to_non_nullable
as bool,settings: freezed == settings ? _self._settings : settings // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
