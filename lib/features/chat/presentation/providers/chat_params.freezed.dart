// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatListParams {

 String get userId; int get limit; String get orderBy; bool get descending;
/// Create a copy of ChatListParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatListParamsCopyWith<ChatListParams> get copyWith => _$ChatListParamsCopyWithImpl<ChatListParams>(this as ChatListParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatListParams&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.descending, descending) || other.descending == descending));
}


@override
int get hashCode => Object.hash(runtimeType,userId,limit,orderBy,descending);

@override
String toString() {
  return 'ChatListParams(userId: $userId, limit: $limit, orderBy: $orderBy, descending: $descending)';
}


}

/// @nodoc
abstract mixin class $ChatListParamsCopyWith<$Res>  {
  factory $ChatListParamsCopyWith(ChatListParams value, $Res Function(ChatListParams) _then) = _$ChatListParamsCopyWithImpl;
@useResult
$Res call({
 String userId, int limit, String orderBy, bool descending
});




}
/// @nodoc
class _$ChatListParamsCopyWithImpl<$Res>
    implements $ChatListParamsCopyWith<$Res> {
  _$ChatListParamsCopyWithImpl(this._self, this._then);

  final ChatListParams _self;
  final $Res Function(ChatListParams) _then;

/// Create a copy of ChatListParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? limit = null,Object? orderBy = null,Object? descending = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,descending: null == descending ? _self.descending : descending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatListParams].
extension ChatListParamsPatterns on ChatListParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatListParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatListParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatListParams value)  $default,){
final _that = this;
switch (_that) {
case _ChatListParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatListParams value)?  $default,){
final _that = this;
switch (_that) {
case _ChatListParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int limit,  String orderBy,  bool descending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatListParams() when $default != null:
return $default(_that.userId,_that.limit,_that.orderBy,_that.descending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int limit,  String orderBy,  bool descending)  $default,) {final _that = this;
switch (_that) {
case _ChatListParams():
return $default(_that.userId,_that.limit,_that.orderBy,_that.descending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int limit,  String orderBy,  bool descending)?  $default,) {final _that = this;
switch (_that) {
case _ChatListParams() when $default != null:
return $default(_that.userId,_that.limit,_that.orderBy,_that.descending);case _:
  return null;

}
}

}

/// @nodoc


class _ChatListParams extends ChatListParams {
  const _ChatListParams({required this.userId, this.limit = 50, this.orderBy = 'lastMessageAt', this.descending = true}): super._();
  

@override final  String userId;
@override@JsonKey() final  int limit;
@override@JsonKey() final  String orderBy;
@override@JsonKey() final  bool descending;

/// Create a copy of ChatListParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatListParamsCopyWith<_ChatListParams> get copyWith => __$ChatListParamsCopyWithImpl<_ChatListParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatListParams&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.descending, descending) || other.descending == descending));
}


@override
int get hashCode => Object.hash(runtimeType,userId,limit,orderBy,descending);

@override
String toString() {
  return 'ChatListParams(userId: $userId, limit: $limit, orderBy: $orderBy, descending: $descending)';
}


}

/// @nodoc
abstract mixin class _$ChatListParamsCopyWith<$Res> implements $ChatListParamsCopyWith<$Res> {
  factory _$ChatListParamsCopyWith(_ChatListParams value, $Res Function(_ChatListParams) _then) = __$ChatListParamsCopyWithImpl;
@override @useResult
$Res call({
 String userId, int limit, String orderBy, bool descending
});




}
/// @nodoc
class __$ChatListParamsCopyWithImpl<$Res>
    implements _$ChatListParamsCopyWith<$Res> {
  __$ChatListParamsCopyWithImpl(this._self, this._then);

  final _ChatListParams _self;
  final $Res Function(_ChatListParams) _then;

/// Create a copy of ChatListParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? limit = null,Object? orderBy = null,Object? descending = null,}) {
  return _then(_ChatListParams(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,descending: null == descending ? _self.descending : descending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$ChatMessagesParams {

 String get chatId; int get limit; String get orderBy; bool get descending;
/// Create a copy of ChatMessagesParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatMessagesParamsCopyWith<ChatMessagesParams> get copyWith => _$ChatMessagesParamsCopyWithImpl<ChatMessagesParams>(this as ChatMessagesParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatMessagesParams&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.descending, descending) || other.descending == descending));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,limit,orderBy,descending);

@override
String toString() {
  return 'ChatMessagesParams(chatId: $chatId, limit: $limit, orderBy: $orderBy, descending: $descending)';
}


}

/// @nodoc
abstract mixin class $ChatMessagesParamsCopyWith<$Res>  {
  factory $ChatMessagesParamsCopyWith(ChatMessagesParams value, $Res Function(ChatMessagesParams) _then) = _$ChatMessagesParamsCopyWithImpl;
@useResult
$Res call({
 String chatId, int limit, String orderBy, bool descending
});




}
/// @nodoc
class _$ChatMessagesParamsCopyWithImpl<$Res>
    implements $ChatMessagesParamsCopyWith<$Res> {
  _$ChatMessagesParamsCopyWithImpl(this._self, this._then);

  final ChatMessagesParams _self;
  final $Res Function(ChatMessagesParams) _then;

/// Create a copy of ChatMessagesParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? chatId = null,Object? limit = null,Object? orderBy = null,Object? descending = null,}) {
  return _then(_self.copyWith(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,descending: null == descending ? _self.descending : descending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatMessagesParams].
extension ChatMessagesParamsPatterns on ChatMessagesParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatMessagesParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatMessagesParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatMessagesParams value)  $default,){
final _that = this;
switch (_that) {
case _ChatMessagesParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatMessagesParams value)?  $default,){
final _that = this;
switch (_that) {
case _ChatMessagesParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String chatId,  int limit,  String orderBy,  bool descending)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatMessagesParams() when $default != null:
return $default(_that.chatId,_that.limit,_that.orderBy,_that.descending);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String chatId,  int limit,  String orderBy,  bool descending)  $default,) {final _that = this;
switch (_that) {
case _ChatMessagesParams():
return $default(_that.chatId,_that.limit,_that.orderBy,_that.descending);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String chatId,  int limit,  String orderBy,  bool descending)?  $default,) {final _that = this;
switch (_that) {
case _ChatMessagesParams() when $default != null:
return $default(_that.chatId,_that.limit,_that.orderBy,_that.descending);case _:
  return null;

}
}

}

/// @nodoc


class _ChatMessagesParams extends ChatMessagesParams {
  const _ChatMessagesParams({required this.chatId, this.limit = 30, this.orderBy = 'timestamp', this.descending = true}): super._();
  

@override final  String chatId;
@override@JsonKey() final  int limit;
@override@JsonKey() final  String orderBy;
@override@JsonKey() final  bool descending;

/// Create a copy of ChatMessagesParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatMessagesParamsCopyWith<_ChatMessagesParams> get copyWith => __$ChatMessagesParamsCopyWithImpl<_ChatMessagesParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatMessagesParams&&(identical(other.chatId, chatId) || other.chatId == chatId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.orderBy, orderBy) || other.orderBy == orderBy)&&(identical(other.descending, descending) || other.descending == descending));
}


@override
int get hashCode => Object.hash(runtimeType,chatId,limit,orderBy,descending);

@override
String toString() {
  return 'ChatMessagesParams(chatId: $chatId, limit: $limit, orderBy: $orderBy, descending: $descending)';
}


}

/// @nodoc
abstract mixin class _$ChatMessagesParamsCopyWith<$Res> implements $ChatMessagesParamsCopyWith<$Res> {
  factory _$ChatMessagesParamsCopyWith(_ChatMessagesParams value, $Res Function(_ChatMessagesParams) _then) = __$ChatMessagesParamsCopyWithImpl;
@override @useResult
$Res call({
 String chatId, int limit, String orderBy, bool descending
});




}
/// @nodoc
class __$ChatMessagesParamsCopyWithImpl<$Res>
    implements _$ChatMessagesParamsCopyWith<$Res> {
  __$ChatMessagesParamsCopyWithImpl(this._self, this._then);

  final _ChatMessagesParams _self;
  final $Res Function(_ChatMessagesParams) _then;

/// Create a copy of ChatMessagesParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? chatId = null,Object? limit = null,Object? orderBy = null,Object? descending = null,}) {
  return _then(_ChatMessagesParams(
chatId: null == chatId ? _self.chatId : chatId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,orderBy: null == orderBy ? _self.orderBy : orderBy // ignore: cast_nullable_to_non_nullable
as String,descending: null == descending ? _self.descending : descending // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$RecommendedFriendsParams {

 String get currentUserId; int get limit; String get sortBy;
/// Create a copy of RecommendedFriendsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendedFriendsParamsCopyWith<RecommendedFriendsParams> get copyWith => _$RecommendedFriendsParamsCopyWithImpl<RecommendedFriendsParams>(this as RecommendedFriendsParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendedFriendsParams&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId,limit,sortBy);

@override
String toString() {
  return 'RecommendedFriendsParams(currentUserId: $currentUserId, limit: $limit, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class $RecommendedFriendsParamsCopyWith<$Res>  {
  factory $RecommendedFriendsParamsCopyWith(RecommendedFriendsParams value, $Res Function(RecommendedFriendsParams) _then) = _$RecommendedFriendsParamsCopyWithImpl;
@useResult
$Res call({
 String currentUserId, int limit, String sortBy
});




}
/// @nodoc
class _$RecommendedFriendsParamsCopyWithImpl<$Res>
    implements $RecommendedFriendsParamsCopyWith<$Res> {
  _$RecommendedFriendsParamsCopyWithImpl(this._self, this._then);

  final RecommendedFriendsParams _self;
  final $Res Function(RecommendedFriendsParams) _then;

/// Create a copy of RecommendedFriendsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentUserId = null,Object? limit = null,Object? sortBy = null,}) {
  return _then(_self.copyWith(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendedFriendsParams].
extension RecommendedFriendsParamsPatterns on RecommendedFriendsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendedFriendsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendedFriendsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendedFriendsParams value)  $default,){
final _that = this;
switch (_that) {
case _RecommendedFriendsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendedFriendsParams value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendedFriendsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentUserId,  int limit,  String sortBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendedFriendsParams() when $default != null:
return $default(_that.currentUserId,_that.limit,_that.sortBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentUserId,  int limit,  String sortBy)  $default,) {final _that = this;
switch (_that) {
case _RecommendedFriendsParams():
return $default(_that.currentUserId,_that.limit,_that.sortBy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentUserId,  int limit,  String sortBy)?  $default,) {final _that = this;
switch (_that) {
case _RecommendedFriendsParams() when $default != null:
return $default(_that.currentUserId,_that.limit,_that.sortBy);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendedFriendsParams extends RecommendedFriendsParams {
  const _RecommendedFriendsParams({required this.currentUserId, this.limit = 20, this.sortBy = 'totalAPoints'}): super._();
  

@override final  String currentUserId;
@override@JsonKey() final  int limit;
@override@JsonKey() final  String sortBy;

/// Create a copy of RecommendedFriendsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendedFriendsParamsCopyWith<_RecommendedFriendsParams> get copyWith => __$RecommendedFriendsParamsCopyWithImpl<_RecommendedFriendsParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendedFriendsParams&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId,limit,sortBy);

@override
String toString() {
  return 'RecommendedFriendsParams(currentUserId: $currentUserId, limit: $limit, sortBy: $sortBy)';
}


}

/// @nodoc
abstract mixin class _$RecommendedFriendsParamsCopyWith<$Res> implements $RecommendedFriendsParamsCopyWith<$Res> {
  factory _$RecommendedFriendsParamsCopyWith(_RecommendedFriendsParams value, $Res Function(_RecommendedFriendsParams) _then) = __$RecommendedFriendsParamsCopyWithImpl;
@override @useResult
$Res call({
 String currentUserId, int limit, String sortBy
});




}
/// @nodoc
class __$RecommendedFriendsParamsCopyWithImpl<$Res>
    implements _$RecommendedFriendsParamsCopyWith<$Res> {
  __$RecommendedFriendsParamsCopyWithImpl(this._self, this._then);

  final _RecommendedFriendsParams _self;
  final $Res Function(_RecommendedFriendsParams) _then;

/// Create a copy of RecommendedFriendsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentUserId = null,Object? limit = null,Object? sortBy = null,}) {
  return _then(_RecommendedFriendsParams(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$SearchFriendsParams {

 String get currentUserId; String get query;
/// Create a copy of SearchFriendsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchFriendsParamsCopyWith<SearchFriendsParams> get copyWith => _$SearchFriendsParamsCopyWithImpl<SearchFriendsParams>(this as SearchFriendsParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFriendsParams&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId,query);

@override
String toString() {
  return 'SearchFriendsParams(currentUserId: $currentUserId, query: $query)';
}


}

/// @nodoc
abstract mixin class $SearchFriendsParamsCopyWith<$Res>  {
  factory $SearchFriendsParamsCopyWith(SearchFriendsParams value, $Res Function(SearchFriendsParams) _then) = _$SearchFriendsParamsCopyWithImpl;
@useResult
$Res call({
 String currentUserId, String query
});




}
/// @nodoc
class _$SearchFriendsParamsCopyWithImpl<$Res>
    implements $SearchFriendsParamsCopyWith<$Res> {
  _$SearchFriendsParamsCopyWithImpl(this._self, this._then);

  final SearchFriendsParams _self;
  final $Res Function(SearchFriendsParams) _then;

/// Create a copy of SearchFriendsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentUserId = null,Object? query = null,}) {
  return _then(_self.copyWith(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchFriendsParams].
extension SearchFriendsParamsPatterns on SearchFriendsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchFriendsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchFriendsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchFriendsParams value)  $default,){
final _that = this;
switch (_that) {
case _SearchFriendsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchFriendsParams value)?  $default,){
final _that = this;
switch (_that) {
case _SearchFriendsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentUserId,  String query)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchFriendsParams() when $default != null:
return $default(_that.currentUserId,_that.query);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentUserId,  String query)  $default,) {final _that = this;
switch (_that) {
case _SearchFriendsParams():
return $default(_that.currentUserId,_that.query);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentUserId,  String query)?  $default,) {final _that = this;
switch (_that) {
case _SearchFriendsParams() when $default != null:
return $default(_that.currentUserId,_that.query);case _:
  return null;

}
}

}

/// @nodoc


class _SearchFriendsParams extends SearchFriendsParams {
  const _SearchFriendsParams({required this.currentUserId, required this.query}): super._();
  

@override final  String currentUserId;
@override final  String query;

/// Create a copy of SearchFriendsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchFriendsParamsCopyWith<_SearchFriendsParams> get copyWith => __$SearchFriendsParamsCopyWithImpl<_SearchFriendsParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchFriendsParams&&(identical(other.currentUserId, currentUserId) || other.currentUserId == currentUserId)&&(identical(other.query, query) || other.query == query));
}


@override
int get hashCode => Object.hash(runtimeType,currentUserId,query);

@override
String toString() {
  return 'SearchFriendsParams(currentUserId: $currentUserId, query: $query)';
}


}

/// @nodoc
abstract mixin class _$SearchFriendsParamsCopyWith<$Res> implements $SearchFriendsParamsCopyWith<$Res> {
  factory _$SearchFriendsParamsCopyWith(_SearchFriendsParams value, $Res Function(_SearchFriendsParams) _then) = __$SearchFriendsParamsCopyWithImpl;
@override @useResult
$Res call({
 String currentUserId, String query
});




}
/// @nodoc
class __$SearchFriendsParamsCopyWithImpl<$Res>
    implements _$SearchFriendsParamsCopyWith<$Res> {
  __$SearchFriendsParamsCopyWithImpl(this._self, this._then);

  final _SearchFriendsParams _self;
  final $Res Function(_SearchFriendsParams) _then;

/// Create a copy of SearchFriendsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentUserId = null,Object? query = null,}) {
  return _then(_SearchFriendsParams(
currentUserId: null == currentUserId ? _self.currentUserId : currentUserId // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
