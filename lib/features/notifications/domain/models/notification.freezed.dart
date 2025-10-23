// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
Notification _$NotificationFromJson(
  Map<String, dynamic> json
) {
        switch (json['runtimeType']) {
                  case 'social':
          return SocialNotification.fromJson(
            json
          );
                case 'system':
          return SystemNotification.fromJson(
            json
          );
                case 'voting':
          return VotingNotification.fromJson(
            json
          );
        
          default:
            throw CheckedFromJsonException(
  json,
  'runtimeType',
  'Notification',
  'Invalid union type "${json['runtimeType']}"!'
);
        }
      
}

/// @nodoc
mixin _$Notification {

// Base notification 필드
 String get id; String get userId; String get type; String get title; String get content; DateTime get createdAt; DateTime? get readAt; bool get isRead; DateTime? get expiryTime; Map<String, dynamic> get metadata;
/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationCopyWith<Notification> get copyWith => _$NotificationCopyWithImpl<Notification>(this as Notification, _$identity);

  /// Serializes this Notification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Notification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,content,createdAt,readAt,isRead,expiryTime,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'Notification(id: $id, userId: $userId, type: $type, title: $title, content: $content, createdAt: $createdAt, readAt: $readAt, isRead: $isRead, expiryTime: $expiryTime, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $NotificationCopyWith<$Res>  {
  factory $NotificationCopyWith(Notification value, $Res Function(Notification) _then) = _$NotificationCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String type, String title, String content, DateTime createdAt, DateTime? readAt, bool isRead, DateTime? expiryTime, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$NotificationCopyWithImpl<$Res>
    implements $NotificationCopyWith<$Res> {
  _$NotificationCopyWithImpl(this._self, this._then);

  final Notification _self;
  final $Res Function(Notification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? content = null,Object? createdAt = null,Object? readAt = freezed,Object? isRead = null,Object? expiryTime = freezed,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Notification].
extension NotificationPatterns on Notification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( SocialNotification value)?  social,TResult Function( SystemNotification value)?  system,TResult Function( VotingNotification value)?  voting,required TResult orElse(),}){
final _that = this;
switch (_that) {
case SocialNotification() when social != null:
return social(_that);case SystemNotification() when system != null:
return system(_that);case VotingNotification() when voting != null:
return voting(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( SocialNotification value)  social,required TResult Function( SystemNotification value)  system,required TResult Function( VotingNotification value)  voting,}){
final _that = this;
switch (_that) {
case SocialNotification():
return social(_that);case SystemNotification():
return system(_that);case VotingNotification():
return voting(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( SocialNotification value)?  social,TResult? Function( SystemNotification value)?  system,TResult? Function( VotingNotification value)?  voting,}){
final _that = this;
switch (_that) {
case SocialNotification() when social != null:
return social(_that);case SystemNotification() when system != null:
return system(_that);case VotingNotification() when voting != null:
return voting(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SocialActionType actionType,  String fromUserId,  String fromUserName,  String? fromUserProfileUrl,  String? relatedPostId,  String? relatedCommentId,  String? relatedContent,  int? interactionCount)?  social,TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SystemAlertType alertType,  String? actionUrl,  String? actionLabel,  Map<String, String>? actionButtons,  String? iconUrl,  bool isDismissible)?  system,TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body,  NotificationPriority notificationPriority,  List<String> imageUrlsA,  List<String> imageUrlsB,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType)?  voting,required TResult orElse(),}) {final _that = this;
switch (_that) {
case SocialNotification() when social != null:
return social(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.actionType,_that.fromUserId,_that.fromUserName,_that.fromUserProfileUrl,_that.relatedPostId,_that.relatedCommentId,_that.relatedContent,_that.interactionCount);case SystemNotification() when system != null:
return system(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.alertType,_that.actionUrl,_that.actionLabel,_that.actionButtons,_that.iconUrl,_that.isDismissible);case VotingNotification() when voting != null:
return voting(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority,_that.imageUrlsA,_that.imageUrlsB,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SocialActionType actionType,  String fromUserId,  String fromUserName,  String? fromUserProfileUrl,  String? relatedPostId,  String? relatedCommentId,  String? relatedContent,  int? interactionCount)  social,required TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SystemAlertType alertType,  String? actionUrl,  String? actionLabel,  Map<String, String>? actionButtons,  String? iconUrl,  bool isDismissible)  system,required TResult Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body,  NotificationPriority notificationPriority,  List<String> imageUrlsA,  List<String> imageUrlsB,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType)  voting,}) {final _that = this;
switch (_that) {
case SocialNotification():
return social(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.actionType,_that.fromUserId,_that.fromUserName,_that.fromUserProfileUrl,_that.relatedPostId,_that.relatedCommentId,_that.relatedContent,_that.interactionCount);case SystemNotification():
return system(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.alertType,_that.actionUrl,_that.actionLabel,_that.actionButtons,_that.iconUrl,_that.isDismissible);case VotingNotification():
return voting(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority,_that.imageUrlsA,_that.imageUrlsB,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SocialActionType actionType,  String fromUserId,  String fromUserName,  String? fromUserProfileUrl,  String? relatedPostId,  String? relatedCommentId,  String? relatedContent,  int? interactionCount)?  social,TResult? Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  SystemAlertType alertType,  String? actionUrl,  String? actionLabel,  Map<String, String>? actionButtons,  String? iconUrl,  bool isDismissible)?  system,TResult? Function( String id,  String userId,  String type,  String title,  String content,  DateTime createdAt,  DateTime? readAt,  bool isRead,  DateTime? expiryTime,  Map<String, dynamic> metadata,  String postId,  String postTitle,  String postContent,  String? postDescription,  DateTime voteStartTime,  DateTime voteEndTime,  String? targetAudience,  int? currentVotesA,  int? currentVotesB,  bool hasVoted,  String? userVoteChoice,  String? senderId,  String? senderName,  String? body,  NotificationPriority notificationPriority,  List<String> imageUrlsA,  List<String> imageUrlsB,  double? aspectRatioA,  double? aspectRatioB,  String? layoutType)?  voting,}) {final _that = this;
switch (_that) {
case SocialNotification() when social != null:
return social(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.actionType,_that.fromUserId,_that.fromUserName,_that.fromUserProfileUrl,_that.relatedPostId,_that.relatedCommentId,_that.relatedContent,_that.interactionCount);case SystemNotification() when system != null:
return system(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.alertType,_that.actionUrl,_that.actionLabel,_that.actionButtons,_that.iconUrl,_that.isDismissible);case VotingNotification() when voting != null:
return voting(_that.id,_that.userId,_that.type,_that.title,_that.content,_that.createdAt,_that.readAt,_that.isRead,_that.expiryTime,_that.metadata,_that.postId,_that.postTitle,_that.postContent,_that.postDescription,_that.voteStartTime,_that.voteEndTime,_that.targetAudience,_that.currentVotesA,_that.currentVotesB,_that.hasVoted,_that.userVoteChoice,_that.senderId,_that.senderName,_that.body,_that.notificationPriority,_that.imageUrlsA,_that.imageUrlsB,_that.aspectRatioA,_that.aspectRatioB,_that.layoutType);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class SocialNotification extends Notification {
  const SocialNotification({required this.id, required this.userId, required this.type, required this.title, required this.content, required this.createdAt, this.readAt, required this.isRead, this.expiryTime, final  Map<String, dynamic> metadata = const {}, required this.actionType, required this.fromUserId, required this.fromUserName, this.fromUserProfileUrl, this.relatedPostId, this.relatedCommentId, this.relatedContent, this.interactionCount, final  String? $type}): _metadata = metadata,$type = $type ?? 'social',super._();
  factory SocialNotification.fromJson(Map<String, dynamic> json) => _$SocialNotificationFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
@override final  String title;
@override final  String content;
@override final  DateTime createdAt;
@override final  DateTime? readAt;
@override final  bool isRead;
@override final  DateTime? expiryTime;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// Social 전용 필드
 final  SocialActionType actionType;
 final  String fromUserId;
 final  String fromUserName;
 final  String? fromUserProfileUrl;
 final  String? relatedPostId;
 final  String? relatedCommentId;
 final  String? relatedContent;
 final  int? interactionCount;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialNotificationCopyWith<SocialNotification> get copyWith => _$SocialNotificationCopyWithImpl<SocialNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SocialNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.fromUserId, fromUserId) || other.fromUserId == fromUserId)&&(identical(other.fromUserName, fromUserName) || other.fromUserName == fromUserName)&&(identical(other.fromUserProfileUrl, fromUserProfileUrl) || other.fromUserProfileUrl == fromUserProfileUrl)&&(identical(other.relatedPostId, relatedPostId) || other.relatedPostId == relatedPostId)&&(identical(other.relatedCommentId, relatedCommentId) || other.relatedCommentId == relatedCommentId)&&(identical(other.relatedContent, relatedContent) || other.relatedContent == relatedContent)&&(identical(other.interactionCount, interactionCount) || other.interactionCount == interactionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,content,createdAt,readAt,isRead,expiryTime,const DeepCollectionEquality().hash(_metadata),actionType,fromUserId,fromUserName,fromUserProfileUrl,relatedPostId,relatedCommentId,relatedContent,interactionCount);

@override
String toString() {
  return 'Notification.social(id: $id, userId: $userId, type: $type, title: $title, content: $content, createdAt: $createdAt, readAt: $readAt, isRead: $isRead, expiryTime: $expiryTime, metadata: $metadata, actionType: $actionType, fromUserId: $fromUserId, fromUserName: $fromUserName, fromUserProfileUrl: $fromUserProfileUrl, relatedPostId: $relatedPostId, relatedCommentId: $relatedCommentId, relatedContent: $relatedContent, interactionCount: $interactionCount)';
}


}

/// @nodoc
abstract mixin class $SocialNotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory $SocialNotificationCopyWith(SocialNotification value, $Res Function(SocialNotification) _then) = _$SocialNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, String title, String content, DateTime createdAt, DateTime? readAt, bool isRead, DateTime? expiryTime, Map<String, dynamic> metadata, SocialActionType actionType, String fromUserId, String fromUserName, String? fromUserProfileUrl, String? relatedPostId, String? relatedCommentId, String? relatedContent, int? interactionCount
});




}
/// @nodoc
class _$SocialNotificationCopyWithImpl<$Res>
    implements $SocialNotificationCopyWith<$Res> {
  _$SocialNotificationCopyWithImpl(this._self, this._then);

  final SocialNotification _self;
  final $Res Function(SocialNotification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? content = null,Object? createdAt = null,Object? readAt = freezed,Object? isRead = null,Object? expiryTime = freezed,Object? metadata = null,Object? actionType = null,Object? fromUserId = null,Object? fromUserName = null,Object? fromUserProfileUrl = freezed,Object? relatedPostId = freezed,Object? relatedCommentId = freezed,Object? relatedContent = freezed,Object? interactionCount = freezed,}) {
  return _then(SocialNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as SocialActionType,fromUserId: null == fromUserId ? _self.fromUserId : fromUserId // ignore: cast_nullable_to_non_nullable
as String,fromUserName: null == fromUserName ? _self.fromUserName : fromUserName // ignore: cast_nullable_to_non_nullable
as String,fromUserProfileUrl: freezed == fromUserProfileUrl ? _self.fromUserProfileUrl : fromUserProfileUrl // ignore: cast_nullable_to_non_nullable
as String?,relatedPostId: freezed == relatedPostId ? _self.relatedPostId : relatedPostId // ignore: cast_nullable_to_non_nullable
as String?,relatedCommentId: freezed == relatedCommentId ? _self.relatedCommentId : relatedCommentId // ignore: cast_nullable_to_non_nullable
as String?,relatedContent: freezed == relatedContent ? _self.relatedContent : relatedContent // ignore: cast_nullable_to_non_nullable
as String?,interactionCount: freezed == interactionCount ? _self.interactionCount : interactionCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
@JsonSerializable()

class SystemNotification extends Notification {
  const SystemNotification({required this.id, required this.userId, required this.type, required this.title, required this.content, required this.createdAt, this.readAt, required this.isRead, this.expiryTime, final  Map<String, dynamic> metadata = const {}, required this.alertType, this.actionUrl, this.actionLabel, final  Map<String, String>? actionButtons, this.iconUrl, this.isDismissible = true, final  String? $type}): _metadata = metadata,_actionButtons = actionButtons,$type = $type ?? 'system',super._();
  factory SystemNotification.fromJson(Map<String, dynamic> json) => _$SystemNotificationFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String type;
@override final  String title;
@override final  String content;
@override final  DateTime createdAt;
@override final  DateTime? readAt;
@override final  bool isRead;
@override final  DateTime? expiryTime;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// System 전용 필드
 final  SystemAlertType alertType;
 final  String? actionUrl;
 final  String? actionLabel;
 final  Map<String, String>? _actionButtons;
 Map<String, String>? get actionButtons {
  final value = _actionButtons;
  if (value == null) return null;
  if (_actionButtons is EqualUnmodifiableMapView) return _actionButtons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  String? iconUrl;
@JsonKey() final  bool isDismissible;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SystemNotificationCopyWith<SystemNotification> get copyWith => _$SystemNotificationCopyWithImpl<SystemNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SystemNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SystemNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.alertType, alertType) || other.alertType == alertType)&&(identical(other.actionUrl, actionUrl) || other.actionUrl == actionUrl)&&(identical(other.actionLabel, actionLabel) || other.actionLabel == actionLabel)&&const DeepCollectionEquality().equals(other._actionButtons, _actionButtons)&&(identical(other.iconUrl, iconUrl) || other.iconUrl == iconUrl)&&(identical(other.isDismissible, isDismissible) || other.isDismissible == isDismissible));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,type,title,content,createdAt,readAt,isRead,expiryTime,const DeepCollectionEquality().hash(_metadata),alertType,actionUrl,actionLabel,const DeepCollectionEquality().hash(_actionButtons),iconUrl,isDismissible);

@override
String toString() {
  return 'Notification.system(id: $id, userId: $userId, type: $type, title: $title, content: $content, createdAt: $createdAt, readAt: $readAt, isRead: $isRead, expiryTime: $expiryTime, metadata: $metadata, alertType: $alertType, actionUrl: $actionUrl, actionLabel: $actionLabel, actionButtons: $actionButtons, iconUrl: $iconUrl, isDismissible: $isDismissible)';
}


}

/// @nodoc
abstract mixin class $SystemNotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory $SystemNotificationCopyWith(SystemNotification value, $Res Function(SystemNotification) _then) = _$SystemNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, String title, String content, DateTime createdAt, DateTime? readAt, bool isRead, DateTime? expiryTime, Map<String, dynamic> metadata, SystemAlertType alertType, String? actionUrl, String? actionLabel, Map<String, String>? actionButtons, String? iconUrl, bool isDismissible
});




}
/// @nodoc
class _$SystemNotificationCopyWithImpl<$Res>
    implements $SystemNotificationCopyWith<$Res> {
  _$SystemNotificationCopyWithImpl(this._self, this._then);

  final SystemNotification _self;
  final $Res Function(SystemNotification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? content = null,Object? createdAt = null,Object? readAt = freezed,Object? isRead = null,Object? expiryTime = freezed,Object? metadata = null,Object? alertType = null,Object? actionUrl = freezed,Object? actionLabel = freezed,Object? actionButtons = freezed,Object? iconUrl = freezed,Object? isDismissible = null,}) {
  return _then(SystemNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,alertType: null == alertType ? _self.alertType : alertType // ignore: cast_nullable_to_non_nullable
as SystemAlertType,actionUrl: freezed == actionUrl ? _self.actionUrl : actionUrl // ignore: cast_nullable_to_non_nullable
as String?,actionLabel: freezed == actionLabel ? _self.actionLabel : actionLabel // ignore: cast_nullable_to_non_nullable
as String?,actionButtons: freezed == actionButtons ? _self._actionButtons : actionButtons // ignore: cast_nullable_to_non_nullable
as Map<String, String>?,iconUrl: freezed == iconUrl ? _self.iconUrl : iconUrl // ignore: cast_nullable_to_non_nullable
as String?,isDismissible: null == isDismissible ? _self.isDismissible : isDismissible // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
@JsonSerializable()

class VotingNotification extends Notification {
  const VotingNotification({required this.id, required this.userId, required this.type, required this.title, required this.content, required this.createdAt, this.readAt, required this.isRead, this.expiryTime, final  Map<String, dynamic> metadata = const {}, required this.postId, required this.postTitle, required this.postContent, this.postDescription, required this.voteStartTime, required this.voteEndTime, this.targetAudience, this.currentVotesA, this.currentVotesB, this.hasVoted = false, this.userVoteChoice, this.senderId, this.senderName, this.body, this.notificationPriority = NotificationPriority.medium, final  List<String> imageUrlsA = const [], final  List<String> imageUrlsB = const [], this.aspectRatioA, this.aspectRatioB, this.layoutType, final  String? $type}): _metadata = metadata,_imageUrlsA = imageUrlsA,_imageUrlsB = imageUrlsB,$type = $type ?? 'voting',super._();
  factory VotingNotification.fromJson(Map<String, dynamic> json) => _$VotingNotificationFromJson(json);

// Base notification 필드
@override final  String id;
@override final  String userId;
@override final  String type;
@override final  String title;
@override final  String content;
@override final  DateTime createdAt;
@override final  DateTime? readAt;
@override final  bool isRead;
@override final  DateTime? expiryTime;
 final  Map<String, dynamic> _metadata;
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}

// Voting 전용 필드 (확장됨)
 final  String postId;
 final  String postTitle;
 final  String postContent;
 final  String? postDescription;
 final  DateTime voteStartTime;
 final  DateTime voteEndTime;
 final  String? targetAudience;
 final  int? currentVotesA;
 final  int? currentVotesB;
@JsonKey() final  bool hasVoted;
 final  String? userVoteChoice;
 final  String? senderId;
 final  String? senderName;
 final  String? body;
@JsonKey() final  NotificationPriority notificationPriority;
// 이미지 URL 리스트 (기존 필드 유지)
 final  List<String> _imageUrlsA;
// 이미지 URL 리스트 (기존 필드 유지)
@JsonKey() List<String> get imageUrlsA {
  if (_imageUrlsA is EqualUnmodifiableListView) return _imageUrlsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrlsA);
}

 final  List<String> _imageUrlsB;
@JsonKey() List<String> get imageUrlsB {
  if (_imageUrlsB is EqualUnmodifiableListView) return _imageUrlsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imageUrlsB);
}

// Aspect Ratio (레이아웃 계산용)
 final  double? aspectRatioA;
 final  double? aspectRatioB;
 final  String? layoutType;

@JsonKey(name: 'runtimeType')
final String $type;


/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VotingNotificationCopyWith<VotingNotification> get copyWith => _$VotingNotificationCopyWithImpl<VotingNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VotingNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VotingNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.expiryTime, expiryTime) || other.expiryTime == expiryTime)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.postId, postId) || other.postId == postId)&&(identical(other.postTitle, postTitle) || other.postTitle == postTitle)&&(identical(other.postContent, postContent) || other.postContent == postContent)&&(identical(other.postDescription, postDescription) || other.postDescription == postDescription)&&(identical(other.voteStartTime, voteStartTime) || other.voteStartTime == voteStartTime)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.currentVotesA, currentVotesA) || other.currentVotesA == currentVotesA)&&(identical(other.currentVotesB, currentVotesB) || other.currentVotesB == currentVotesB)&&(identical(other.hasVoted, hasVoted) || other.hasVoted == hasVoted)&&(identical(other.userVoteChoice, userVoteChoice) || other.userVoteChoice == userVoteChoice)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.senderName, senderName) || other.senderName == senderName)&&(identical(other.body, body) || other.body == body)&&(identical(other.notificationPriority, notificationPriority) || other.notificationPriority == notificationPriority)&&const DeepCollectionEquality().equals(other._imageUrlsA, _imageUrlsA)&&const DeepCollectionEquality().equals(other._imageUrlsB, _imageUrlsB)&&(identical(other.aspectRatioA, aspectRatioA) || other.aspectRatioA == aspectRatioA)&&(identical(other.aspectRatioB, aspectRatioB) || other.aspectRatioB == aspectRatioB)&&(identical(other.layoutType, layoutType) || other.layoutType == layoutType));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,type,title,content,createdAt,readAt,isRead,expiryTime,const DeepCollectionEquality().hash(_metadata),postId,postTitle,postContent,postDescription,voteStartTime,voteEndTime,targetAudience,currentVotesA,currentVotesB,hasVoted,userVoteChoice,senderId,senderName,body,notificationPriority,const DeepCollectionEquality().hash(_imageUrlsA),const DeepCollectionEquality().hash(_imageUrlsB),aspectRatioA,aspectRatioB,layoutType]);

@override
String toString() {
  return 'Notification.voting(id: $id, userId: $userId, type: $type, title: $title, content: $content, createdAt: $createdAt, readAt: $readAt, isRead: $isRead, expiryTime: $expiryTime, metadata: $metadata, postId: $postId, postTitle: $postTitle, postContent: $postContent, postDescription: $postDescription, voteStartTime: $voteStartTime, voteEndTime: $voteEndTime, targetAudience: $targetAudience, currentVotesA: $currentVotesA, currentVotesB: $currentVotesB, hasVoted: $hasVoted, userVoteChoice: $userVoteChoice, senderId: $senderId, senderName: $senderName, body: $body, notificationPriority: $notificationPriority, imageUrlsA: $imageUrlsA, imageUrlsB: $imageUrlsB, aspectRatioA: $aspectRatioA, aspectRatioB: $aspectRatioB, layoutType: $layoutType)';
}


}

/// @nodoc
abstract mixin class $VotingNotificationCopyWith<$Res> implements $NotificationCopyWith<$Res> {
  factory $VotingNotificationCopyWith(VotingNotification value, $Res Function(VotingNotification) _then) = _$VotingNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String type, String title, String content, DateTime createdAt, DateTime? readAt, bool isRead, DateTime? expiryTime, Map<String, dynamic> metadata, String postId, String postTitle, String postContent, String? postDescription, DateTime voteStartTime, DateTime voteEndTime, String? targetAudience, int? currentVotesA, int? currentVotesB, bool hasVoted, String? userVoteChoice, String? senderId, String? senderName, String? body, NotificationPriority notificationPriority, List<String> imageUrlsA, List<String> imageUrlsB, double? aspectRatioA, double? aspectRatioB, String? layoutType
});




}
/// @nodoc
class _$VotingNotificationCopyWithImpl<$Res>
    implements $VotingNotificationCopyWith<$Res> {
  _$VotingNotificationCopyWithImpl(this._self, this._then);

  final VotingNotification _self;
  final $Res Function(VotingNotification) _then;

/// Create a copy of Notification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? type = null,Object? title = null,Object? content = null,Object? createdAt = null,Object? readAt = freezed,Object? isRead = null,Object? expiryTime = freezed,Object? metadata = null,Object? postId = null,Object? postTitle = null,Object? postContent = null,Object? postDescription = freezed,Object? voteStartTime = null,Object? voteEndTime = null,Object? targetAudience = freezed,Object? currentVotesA = freezed,Object? currentVotesB = freezed,Object? hasVoted = null,Object? userVoteChoice = freezed,Object? senderId = freezed,Object? senderName = freezed,Object? body = freezed,Object? notificationPriority = null,Object? imageUrlsA = null,Object? imageUrlsB = null,Object? aspectRatioA = freezed,Object? aspectRatioB = freezed,Object? layoutType = freezed,}) {
  return _then(VotingNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,expiryTime: freezed == expiryTime ? _self.expiryTime : expiryTime // ignore: cast_nullable_to_non_nullable
as DateTime?,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,postTitle: null == postTitle ? _self.postTitle : postTitle // ignore: cast_nullable_to_non_nullable
as String,postContent: null == postContent ? _self.postContent : postContent // ignore: cast_nullable_to_non_nullable
as String,postDescription: freezed == postDescription ? _self.postDescription : postDescription // ignore: cast_nullable_to_non_nullable
as String?,voteStartTime: null == voteStartTime ? _self.voteStartTime : voteStartTime // ignore: cast_nullable_to_non_nullable
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
as NotificationPriority,imageUrlsA: null == imageUrlsA ? _self._imageUrlsA : imageUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>,imageUrlsB: null == imageUrlsB ? _self._imageUrlsB : imageUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>,aspectRatioA: freezed == aspectRatioA ? _self.aspectRatioA : aspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,aspectRatioB: freezed == aspectRatioB ? _self.aspectRatioB : aspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,layoutType: freezed == layoutType ? _self.layoutType : layoutType // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
