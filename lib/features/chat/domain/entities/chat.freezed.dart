// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Chat {

/// 채팅방 고유 ID
 String get id;/// 채팅방 식별자
 String get chatId;/// 채팅방 타입 (1:1, group 등)
 String get chatType;/// 참여자 ID 목록
 List<String> get participantIds;/// 채팅방 이름
 String get chatName;/// 마지막 메시지 내용
 String get lastMessageContent;/// 마지막 메시지 시간
 DateTime? get lastMessageAt;/// 읽음 여부
 bool get isRead;/// 생성 시간
 DateTime? get createdAt;/// 사용자별 마지막 읽은 시간
 Map<String, DateTime> get lastReadTimestamps;// ========== TODO: Profile Feature로 이동 예정 ==========
// 현재는 DTO 호환성을 위해 유지
// Phase 4에서 제거 예정
/// 사용자 이메일 (TODO: Profile feature로 이동)
 String get email;/// 사용자 표시 이름 (TODO: Profile feature로 이동)
 String get displayName;/// 사용자 프로필 사진 URL (TODO: Profile feature로 이동)
 String get photoUrl;/// 사용자 UID (TODO: Profile feature로 이동)
 String get uid;/// 사용자 생성 시간 (TODO: Profile feature로 이동)
 DateTime? get createdTime;/// 전화번호 (TODO: Profile feature로 이동)
 String get phoneNumber;
/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatCopyWith<Chat> get copyWith => _$ChatCopyWithImpl<Chat>(this as Chat, _$identity);

  /// Serializes this Chat to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatType, chatType) || other.chatType == chatType)&&const DeepCollectionEquality().equals(other.participantIds, participantIds)&&(identical(other.chatName, chatName) || other.chatName == chatName)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other.lastReadTimestamps, lastReadTimestamps)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,chatType,const DeepCollectionEquality().hash(participantIds),chatName,lastMessageContent,lastMessageAt,isRead,createdAt,const DeepCollectionEquality().hash(lastReadTimestamps),email,displayName,photoUrl,uid,createdTime,phoneNumber);

@override
String toString() {
  return 'Chat(id: $id, chatId: $chatId, chatType: $chatType, participantIds: $participantIds, chatName: $chatName, lastMessageContent: $lastMessageContent, lastMessageAt: $lastMessageAt, isRead: $isRead, createdAt: $createdAt, lastReadTimestamps: $lastReadTimestamps, email: $email, displayName: $displayName, photoUrl: $photoUrl, uid: $uid, createdTime: $createdTime, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $ChatCopyWith<$Res>  {
  factory $ChatCopyWith(Chat value, $Res Function(Chat) _then) = _$ChatCopyWithImpl;
@useResult
$Res call({
 String id, String chatId, String chatType, List<String> participantIds, String chatName, String lastMessageContent, DateTime? lastMessageAt, bool isRead, DateTime? createdAt, Map<String, DateTime> lastReadTimestamps, String email, String displayName, String photoUrl, String uid, DateTime? createdTime, String phoneNumber
});




}
/// @nodoc
class _$ChatCopyWithImpl<$Res>
    implements $ChatCopyWith<$Res> {
  _$ChatCopyWithImpl(this._self, this._then);

  final Chat _self;
  final $Res Function(Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? chatId = null,Object? chatType = null,Object? participantIds = null,Object? chatName = null,Object? lastMessageContent = null,Object? lastMessageAt = freezed,Object? isRead = null,Object? createdAt = freezed,Object? lastReadTimestamps = null,Object? email = null,Object? displayName = null,Object? photoUrl = null,Object? uid = null,Object? createdTime = freezed,Object? phoneNumber = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,chatType: null == chatType ? _self.chatType : chatType // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self.participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,chatName: null == chatName ? _self.chatName : chatName // ignore: cast_nullable_to_non_nullable
as String,lastMessageContent: null == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadTimestamps: null == lastReadTimestamps ? _self.lastReadTimestamps : lastReadTimestamps // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Chat].
extension ChatPatterns on Chat {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Chat value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Chat value)  $default,){
final _that = this;
switch (_that) {
case _Chat():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Chat value)?  $default,){
final _that = this;
switch (_that) {
case _Chat() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String chatId,  String chatType,  List<String> participantIds,  String chatName,  String lastMessageContent,  DateTime? lastMessageAt,  bool isRead,  DateTime? createdAt,  Map<String, DateTime> lastReadTimestamps,  String email,  String displayName,  String photoUrl,  String uid,  DateTime? createdTime,  String phoneNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.chatId,_that.chatType,_that.participantIds,_that.chatName,_that.lastMessageContent,_that.lastMessageAt,_that.isRead,_that.createdAt,_that.lastReadTimestamps,_that.email,_that.displayName,_that.photoUrl,_that.uid,_that.createdTime,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String chatId,  String chatType,  List<String> participantIds,  String chatName,  String lastMessageContent,  DateTime? lastMessageAt,  bool isRead,  DateTime? createdAt,  Map<String, DateTime> lastReadTimestamps,  String email,  String displayName,  String photoUrl,  String uid,  DateTime? createdTime,  String phoneNumber)  $default,) {final _that = this;
switch (_that) {
case _Chat():
return $default(_that.id,_that.chatId,_that.chatType,_that.participantIds,_that.chatName,_that.lastMessageContent,_that.lastMessageAt,_that.isRead,_that.createdAt,_that.lastReadTimestamps,_that.email,_that.displayName,_that.photoUrl,_that.uid,_that.createdTime,_that.phoneNumber);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String chatId,  String chatType,  List<String> participantIds,  String chatName,  String lastMessageContent,  DateTime? lastMessageAt,  bool isRead,  DateTime? createdAt,  Map<String, DateTime> lastReadTimestamps,  String email,  String displayName,  String photoUrl,  String uid,  DateTime? createdTime,  String phoneNumber)?  $default,) {final _that = this;
switch (_that) {
case _Chat() when $default != null:
return $default(_that.id,_that.chatId,_that.chatType,_that.participantIds,_that.chatName,_that.lastMessageContent,_that.lastMessageAt,_that.isRead,_that.createdAt,_that.lastReadTimestamps,_that.email,_that.displayName,_that.photoUrl,_that.uid,_that.createdTime,_that.phoneNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Chat extends Chat {
  const _Chat({required this.id, required this.chatId, required this.chatType, required final  List<String> participantIds, required this.chatName, required this.lastMessageContent, this.lastMessageAt, required this.isRead, this.createdAt, required final  Map<String, DateTime> lastReadTimestamps, this.email = '', this.displayName = '', this.photoUrl = '', this.uid = '', this.createdTime, this.phoneNumber = ''}): _participantIds = participantIds,_lastReadTimestamps = lastReadTimestamps,super._();
  factory _Chat.fromJson(Map<String, dynamic> json) => _$ChatFromJson(json);

/// 채팅방 고유 ID
@override final  String id;
/// 채팅방 식별자
@override final  String chatId;
/// 채팅방 타입 (1:1, group 등)
@override final  String chatType;
/// 참여자 ID 목록
 final  List<String> _participantIds;
/// 참여자 ID 목록
@override List<String> get participantIds {
  if (_participantIds is EqualUnmodifiableListView) return _participantIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_participantIds);
}

/// 채팅방 이름
@override final  String chatName;
/// 마지막 메시지 내용
@override final  String lastMessageContent;
/// 마지막 메시지 시간
@override final  DateTime? lastMessageAt;
/// 읽음 여부
@override final  bool isRead;
/// 생성 시간
@override final  DateTime? createdAt;
/// 사용자별 마지막 읽은 시간
 final  Map<String, DateTime> _lastReadTimestamps;
/// 사용자별 마지막 읽은 시간
@override Map<String, DateTime> get lastReadTimestamps {
  if (_lastReadTimestamps is EqualUnmodifiableMapView) return _lastReadTimestamps;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_lastReadTimestamps);
}

// ========== TODO: Profile Feature로 이동 예정 ==========
// 현재는 DTO 호환성을 위해 유지
// Phase 4에서 제거 예정
/// 사용자 이메일 (TODO: Profile feature로 이동)
@override@JsonKey() final  String email;
/// 사용자 표시 이름 (TODO: Profile feature로 이동)
@override@JsonKey() final  String displayName;
/// 사용자 프로필 사진 URL (TODO: Profile feature로 이동)
@override@JsonKey() final  String photoUrl;
/// 사용자 UID (TODO: Profile feature로 이동)
@override@JsonKey() final  String uid;
/// 사용자 생성 시간 (TODO: Profile feature로 이동)
@override final  DateTime? createdTime;
/// 전화번호 (TODO: Profile feature로 이동)
@override@JsonKey() final  String phoneNumber;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatCopyWith<_Chat> get copyWith => __$ChatCopyWithImpl<_Chat>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ChatToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Chat&&(identical(other.id, id) || other.id == id)&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.chatType, chatType) || other.chatType == chatType)&&const DeepCollectionEquality().equals(other._participantIds, _participantIds)&&(identical(other.chatName, chatName) || other.chatName == chatName)&&(identical(other.lastMessageContent, lastMessageContent) || other.lastMessageContent == lastMessageContent)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&const DeepCollectionEquality().equals(other._lastReadTimestamps, _lastReadTimestamps)&&(identical(other.email, email) || other.email == email)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.createdTime, createdTime) || other.createdTime == createdTime)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chatId,chatType,const DeepCollectionEquality().hash(_participantIds),chatName,lastMessageContent,lastMessageAt,isRead,createdAt,const DeepCollectionEquality().hash(_lastReadTimestamps),email,displayName,photoUrl,uid,createdTime,phoneNumber);

@override
String toString() {
  return 'Chat(id: $id, chatId: $chatId, chatType: $chatType, participantIds: $participantIds, chatName: $chatName, lastMessageContent: $lastMessageContent, lastMessageAt: $lastMessageAt, isRead: $isRead, createdAt: $createdAt, lastReadTimestamps: $lastReadTimestamps, email: $email, displayName: $displayName, photoUrl: $photoUrl, uid: $uid, createdTime: $createdTime, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class _$ChatCopyWith<$Res> implements $ChatCopyWith<$Res> {
  factory _$ChatCopyWith(_Chat value, $Res Function(_Chat) _then) = __$ChatCopyWithImpl;
@override @useResult
$Res call({
 String id, String chatId, String chatType, List<String> participantIds, String chatName, String lastMessageContent, DateTime? lastMessageAt, bool isRead, DateTime? createdAt, Map<String, DateTime> lastReadTimestamps, String email, String displayName, String photoUrl, String uid, DateTime? createdTime, String phoneNumber
});




}
/// @nodoc
class __$ChatCopyWithImpl<$Res>
    implements _$ChatCopyWith<$Res> {
  __$ChatCopyWithImpl(this._self, this._then);

  final _Chat _self;
  final $Res Function(_Chat) _then;

/// Create a copy of Chat
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? chatId = null,Object? chatType = null,Object? participantIds = null,Object? chatName = null,Object? lastMessageContent = null,Object? lastMessageAt = freezed,Object? isRead = null,Object? createdAt = freezed,Object? lastReadTimestamps = null,Object? email = null,Object? displayName = null,Object? photoUrl = null,Object? uid = null,Object? createdTime = freezed,Object? phoneNumber = null,}) {
  return _then(_Chat(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,chatType: null == chatType ? _self.chatType : chatType // ignore: cast_nullable_to_non_nullable
as String,participantIds: null == participantIds ? _self._participantIds : participantIds // ignore: cast_nullable_to_non_nullable
as List<String>,chatName: null == chatName ? _self.chatName : chatName // ignore: cast_nullable_to_non_nullable
as String,lastMessageContent: null == lastMessageContent ? _self.lastMessageContent : lastMessageContent // ignore: cast_nullable_to_non_nullable
as String,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastReadTimestamps: null == lastReadTimestamps ? _self._lastReadTimestamps : lastReadTimestamps // ignore: cast_nullable_to_non_nullable
as Map<String, DateTime>,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,photoUrl: null == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,createdTime: freezed == createdTime ? _self.createdTime : createdTime // ignore: cast_nullable_to_non_nullable
as DateTime?,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
