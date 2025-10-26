// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteNotification {

// ===== 공통 알림 필드 (Notification에서 가져옴) =====
 String get id; String get userId; DateTime get createdAt; bool get isRead; String get title; String get content; DateTime? get readAt; DateTime? get expiryTime; Map<String, dynamic> get metadata;// ===== 투표 전용 필드 =====
 String get postId; String get postTitle; String get postContent; String? get postDescription; VoteOptions get voteOptions; DateTime get voteStartTime; DateTime get voteEndTime; String? get targetAudience; int? get currentVotesA; int? get currentVotesB; bool get hasVoted; String? get userVoteChoice; String? get senderId; String? get senderName; String? get body;@JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson) NotificationPriority get notificationPriority;
/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteNotificationCopyWith<VoteNotification> get copyWith => _$VoteNotificationCopyWithImpl<VoteNotification>(this as VoteNotification, _$identity);

  /// Serializes this VoteNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postTitle, postTitle) || other.postTitle == postTitle)&&(identical(other.postContent, postContent) || other.postContent == postContent)&&(identical(other.postDescription, postDescription) || other.postDescription == postDescription)&&(identical(other.voteOptions, voteOptions) || other.voteOptions == voteOptions)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.currentVotesA, currentVotesA) || other.currentVotesA == currentVotesA)&&(identical(other.currentVotesB, currentVotesB) || other.currentVotesB == currentVotesB)&&(identical(other.hasVoted, hasVoted) || other.hasVoted == hasVoted)&&(identical(other.userVoteChoice, userVoteChoice) || other.userVoteChoice == userVoteChoice)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.body, body) || other.body == body)&&(identical(other.notificationPriority, notificationPriority) || other.notificationPriority == notificationPriority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,createdAt,isRead,title,content,readAt,expiryTime,const DeepCollectionEquality().hash(metadata),postId,postTitle,postContent,postDescription,voteOptions,voteStartTime,voteEndTime,targetAudience,currentVotesA,currentVotesB,hasVoted,userVoteChoice,senderId,senderName,body,notificationPriority]);

@override
String toString() {
  return 'VoteNotification(id: $id, userId: $userId, createdAt: $createdAt, isRead: $isRead, title: $title, content: $content, readAt: $readAt, expiryTime: $expiryTime, metadata: $metadata, postId: $postId, postTitle: $postTitle, postContent: $postContent, postDescription: $postDescription, voteOptions: $voteOptions, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, targetAudience: $targetAudience, currentVotesA: $currentVotesA, currentVotesB: $currentVotesB, hasVoted: $hasVoted, userVoteChoice: $userVoteChoice, senderId: $senderId, senderName: $senderName, body: $body, notificationPriority: $notificationPriority)';
}


}

/// @nodoc
abstract mixin class $VoteNotificationCopyWith<$Res>  {
  factory $VoteNotificationCopyWith(VoteNotification value, $Res Function(VoteNotification) _then) = _$VoteNotificationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, DateTime createdAt, bool isRead, String title, String content, DateTime? readAt, DateTime? expiryTime, Map<String, dynamic> metadata, String postId, String postTitle, String postContent, String? postDescription, VoteOptions voteOptions, DateTime voteStartTime, DateTime voteEndTime, String? targetAudience, int? currentVotesA, int? currentVotesB, bool hasVoted, String? userVoteChoice, String? senderId, String? senderName, String? body,@JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson) NotificationPriority notificationPriority
});


$VoteOptionsCopyWith<$Res> get voteOptions;

}
/// @nodoc
class _$VoteNotificationCopyWithImpl<$Res>
    implements $VoteNotificationCopyWith<$Res> {
  _$VoteNotificationCopyWithImpl(this._self, this._then);

  final VoteNotification _self;
  final $Res Function(VoteNotification) _then;

/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? createdAt = null,Object? isRead = null,Object? title = null,Object? content = null,Object? readAt = freezed,Object? expiryTime = freezed,Object? metadata = null,Object? postId = null,Object? postTitle = null,Object? postContent = null,Object? postDescription = freezed,Object? voteOptions = null,Object? voteStartTime = null,Object? voteEndTime = null,Object? targetAudience = freezed,Object? currentVotesA = freezed,Object? currentVotesB = freezed,Object? hasVoted = null,Object? userVoteChoice = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? body = freezed,Object? notificationPriority = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,postTitle: null == postTitle ? _self.postTitle : postTitle // ignore: cast_nullable_to_non_nullable
as String,postContent: null == postContent ? _self.postContent : postContent // ignore: cast_nullable_to_non_nullable
as String,postDescription: freezed == postDescription ? _self.postDescription : postDescription // ignore: cast_nullable_to_non_nullable
as String?,voteOptions: null == voteOptions ? _self.voteOptions : voteOptions // ignore: cast_nullable_to_non_nullable
as VoteOptions,voteStartTime: null == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime,voteEndTime: null == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as String?,currentVotesA: freezed == currentVotesA ? _self.currentVotesA : currentVotesA // ignore: cast_nullable_to_non_nullable
as int?,currentVotesB: freezed == currentVotesB ? _self.currentVotesB : currentVotesB // ignore: cast_nullable_to_non_nullable
as int?,hasVoted: null == hasVoted ? _self.hasVoted : hasVoted // ignore: cast_nullable_to_non_nullable
as bool,userVoteChoice: freezed == userVoteChoice ? _self.userVoteChoice : userVoteChoice // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,notificationPriority: null == notificationPriority ? _self.notificationPriority : notificationPriority // ignore: cast_nullable_to_non_nullable
as NotificationPriority,
  ));
}
/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteOptionsCopyWith<$Res> get voteOptions {
  
  return $VoteOptionsCopyWith<$Res>(_self.voteOptions, (value) {
    return _then(_self.copyWith(voteOptions: value));
  });
}
}


/// Adds pattern-matching-related methods to [VoteNotification].
extension VoteNotificationPatterns on VoteNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteNotification value)  $default,){
final _that = this;
switch (_that) {
case _VoteNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteNotification value)?  $default,){
final _that = this;
switch (_that) {
case _VoteNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime createdAt,  bool isRead,  String title,  String content,  DateTime? readAt,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  VoteOptions voteOptions,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body, @JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson)  NotificationPriority notificationPriority)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteNotification() when $default != null:
return $default(_that.id,_that.userId,_that.createdAt,_that.isRead,_that.title,_that.content,_that.readAt,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteOptions,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  DateTime createdAt,  bool isRead,  String title,  String content,  DateTime? readAt,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  VoteOptions voteOptions,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body, @JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson)  NotificationPriority notificationPriority)  $default,) {final _that = this;
switch (_that) {
case _VoteNotification():
return $default(_that.id,_that.userId,_that.createdAt,_that.isRead,_that.title,_that.content,_that.readAt,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteOptions,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  DateTime createdAt,  bool isRead,  String title,  String content,  DateTime? readAt,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  VoteOptions voteOptions,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body, @JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson)  NotificationPriority notificationPriority)?  $default,) {final _that = this;
switch (_that) {
case _VoteNotification() when $default != null:
return $default(_that.id,_that.userId,_that.createdAt,_that.isRead,_that.title,_that.content,_that.readAt,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteOptions,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteNotification extends VoteNotification {
  const _VoteNotification({required this.id, required this.userId, required this.createdAt, required this.isRead, required this.title, required this.content, this.readAt, this.expiryTime, final  Map<String, dynamic> metadata = const {}, required this.postId, required this.postTitle, required this.postContent, this.postDescription, required this.voteOptions, required this.voteStartTime, required this.voteEndTime, this.targetAudience, this.currentVotesA, this.currentVotesB, this.hasVoted = false, this.userVoteChoice, this.senderId, this.senderName, this.body, @JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson) this.notificationPriority = NotificationPriority.medium}): _metadata = metadata,super._();
  factory _VoteNotification.fromJson(Map<String, dynamic> json) => _$VoteNotificationFromJson(json);

// ===== 공통 알림 필드 (Notification에서 가져옴) =====
@override final  String id;
@override final  String userId;
@override final  DateTime createdAt;
@override final  bool isRead;
@override final  String title;
@override final  String content;
@override final  DateTime? readAt;
@override final  DateTime? expiryTime;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// ===== 투표 전용 필드 =====
@override final  String postId;
@override final  String postTitle;
@override final  String postContent;
@override final  String? postDescription;
@override final  VoteOptions voteOptions;
@override final  DateTime voteStartTime;
@override final  DateTime voteEndTime;
@override final  String? targetAudience;
@override final  int? currentVotesA;
@override final  int? currentVotesB;
@override@JsonKey() final  bool hasVoted;
@override final  String? userVoteChoice;
@override final  String? senderId;
@override final  String? senderName;
@override final  String? body;
@override@JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson) final  NotificationPriority notificationPriority;

/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteNotificationCopyWith<_VoteNotification> get copyWith => __$VoteNotificationCopyWithImpl<_VoteNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postTitle, postTitle) || other.postTitle == postTitle)&&(identical(other.postContent, postContent) || other.postContent == postContent)&&(identical(other.postDescription, postDescription) || other.postDescription == postDescription)&&(identical(other.voteOptions, voteOptions) || other.voteOptions == voteOptions)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.currentVotesA, currentVotesA) || other.currentVotesA == currentVotesA)&&(identical(other.currentVotesB, currentVotesB) || other.currentVotesB == currentVotesB)&&(identical(other.hasVoted, hasVoted) || other.hasVoted == hasVoted)&&(identical(other.userVoteChoice, userVoteChoice) || other.userVoteChoice == userVoteChoice)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.body, body) || other.body == body)&&(identical(other.notificationPriority, notificationPriority) || other.notificationPriority == notificationPriority));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,createdAt,isRead,title,content,readAt,expiryTime,const DeepCollectionEquality().hash(_metadata),postId,postTitle,postContent,postDescription,voteOptions,voteStartTime,voteEndTime,targetAudience,currentVotesA,currentVotesB,hasVoted,userVoteChoice,senderId,senderName,body,notificationPriority]);

@override
String toString() {
  return 'VoteNotification(id: $id, userId: $userId, createdAt: $createdAt, isRead: $isRead, title: $title, content: $content, readAt: $readAt, expiryTime: $expiryTime, metadata: $metadata, postId: $postId, postTitle: $postTitle, postContent: $postContent, postDescription: $postDescription, voteOptions: $voteOptions, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, targetAudience: $targetAudience, currentVotesA: $currentVotesA, currentVotesB: $currentVotesB, hasVoted: $hasVoted, userVoteChoice: $userVoteChoice, senderId: $senderId, senderName: $senderName, body: $body, notificationPriority: $notificationPriority)';
}


}

/// @nodoc
abstract mixin class _$VoteNotificationCopyWith<$Res> implements $VoteNotificationCopyWith<$Res> {
  factory _$VoteNotificationCopyWith(_VoteNotification value, $Res Function(_VoteNotification) _then) = __$VoteNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, DateTime createdAt, bool isRead, String title, String content, DateTime? readAt, DateTime? expiryTime, Map<String, dynamic> metadata, String postId, String postTitle, String postContent, String? postDescription, VoteOptions voteOptions, DateTime voteStartTime, DateTime voteEndTime, String? targetAudience, int? currentVotesA, int? currentVotesB, bool hasVoted, String? userVoteChoice, String? senderId, String? senderName, String? body,@JsonKey(fromJson: NotificationPriority.fromJson, toJson: _notificationPriorityToJson) NotificationPriority notificationPriority
});


@override $VoteOptionsCopyWith<$Res> get voteOptions;

}
/// @nodoc
class __$VoteNotificationCopyWithImpl<$Res>
    implements _$VoteNotificationCopyWith<$Res> {
  __$VoteNotificationCopyWithImpl(this._self, this._then);

  final _VoteNotification _self;
  final $Res Function(_VoteNotification) _then;

/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? createdAt = null,Object? isRead = null,Object? title = null,Object? content = null,Object? readAt = freezed,Object? expiryTime = freezed,Object? metadata = null,Object? postId = null,Object? postTitle = null,Object? postContent = null,Object? postDescription = freezed,Object? voteOptions = null,Object? voteStartTime = null,Object? voteEndTime = null,Object? targetAudience = freezed,Object? currentVotesA = freezed,Object? currentVotesB = freezed,Object? hasVoted = null,Object? userVoteChoice = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? body = freezed,Object? notificationPriority = null,}) {
  return _then(_VoteNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,postTitle: null == postTitle ? _self.postTitle : postTitle // ignore: cast_nullable_to_non_nullable
as String,postContent: null == postContent ? _self.postContent : postContent // ignore: cast_nullable_to_non_nullable
as String,postDescription: freezed == postDescription ? _self.postDescription : postDescription // ignore: cast_nullable_to_non_nullable
as String?,voteOptions: null == voteOptions ? _self.voteOptions : voteOptions // ignore: cast_nullable_to_non_nullable
as VoteOptions,voteStartTime: null == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
as DateTime,voteEndTime: null == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as String?,currentVotesA: freezed == currentVotesA ? _self.currentVotesA : currentVotesA // ignore: cast_nullable_to_non_nullable
as int?,currentVotesB: freezed == currentVotesB ? _self.currentVotesB : currentVotesB // ignore: cast_nullable_to_non_nullable
as int?,hasVoted: null == hasVoted ? _self.hasVoted : hasVoted // ignore: cast_nullable_to_non_nullable
as bool,userVoteChoice: freezed == userVoteChoice ? _self.userVoteChoice : userVoteChoice // ignore: cast_nullable_to_non_nullable
as String?,senderId: freezed == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String?,senderName: freezed == senderName ? _self.senderName : senderName // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,notificationPriority: null == notificationPriority ? _self.notificationPriority : notificationPriority // ignore: cast_nullable_to_non_nullable
as NotificationPriority,
  ));
}

/// Create a copy of VoteNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VoteOptionsCopyWith<$Res> get voteOptions {
  
  return $VoteOptionsCopyWith<$Res>(_self.voteOptions, (value) {
    return _then(_self.copyWith(voteOptions: value));
  });
}
}

// dart format on
