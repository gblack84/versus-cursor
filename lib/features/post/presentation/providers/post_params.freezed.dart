// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$FeedParams {

 int get limit; FeedSortBy get sortBy; FeedFilter? get filter;
/// Create a copy of FeedParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FeedParamsCopyWith<FeedParams> get copyWith => _$FeedParamsCopyWithImpl<FeedParams>(this as FeedParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FeedParams&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,limit,sortBy,filter);

@override
String toString() {
  return 'FeedParams(limit: $limit, sortBy: $sortBy, filter: $filter)';
}


}

/// @nodoc
abstract mixin class $FeedParamsCopyWith<$Res>  {
  factory $FeedParamsCopyWith(FeedParams value, $Res Function(FeedParams) _then) = _$FeedParamsCopyWithImpl;
@useResult
$Res call({
 int limit, FeedSortBy sortBy, FeedFilter? filter
});




}
/// @nodoc
class _$FeedParamsCopyWithImpl<$Res>
    implements $FeedParamsCopyWith<$Res> {
  _$FeedParamsCopyWithImpl(this._self, this._then);

  final FeedParams _self;
  final $Res Function(FeedParams) _then;

/// Create a copy of FeedParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = null,Object? sortBy = null,Object? filter = freezed,}) {
  return _then(_self.copyWith(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as FeedSortBy,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FeedFilter?,
  ));
}

}


/// Adds pattern-matching-related methods to [FeedParams].
extension FeedParamsPatterns on FeedParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FeedParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FeedParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FeedParams value)  $default,){
final _that = this;
switch (_that) {
case _FeedParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FeedParams value)?  $default,){
final _that = this;
switch (_that) {
case _FeedParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int limit,  FeedSortBy sortBy,  FeedFilter? filter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FeedParams() when $default != null:
return $default(_that.limit,_that.sortBy,_that.filter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int limit,  FeedSortBy sortBy,  FeedFilter? filter)  $default,) {final _that = this;
switch (_that) {
case _FeedParams():
return $default(_that.limit,_that.sortBy,_that.filter);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int limit,  FeedSortBy sortBy,  FeedFilter? filter)?  $default,) {final _that = this;
switch (_that) {
case _FeedParams() when $default != null:
return $default(_that.limit,_that.sortBy,_that.filter);case _:
  return null;

}
}

}

/// @nodoc


class _FeedParams implements FeedParams {
  const _FeedParams({this.limit = 20, this.sortBy = FeedSortBy.latest, this.filter});
  

@override@JsonKey() final  int limit;
@override@JsonKey() final  FeedSortBy sortBy;
@override final  FeedFilter? filter;

/// Create a copy of FeedParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FeedParamsCopyWith<_FeedParams> get copyWith => __$FeedParamsCopyWithImpl<_FeedParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FeedParams&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.sortBy, sortBy) || other.sortBy == sortBy)&&(identical(other.filter, filter) || other.filter == filter));
}


@override
int get hashCode => Object.hash(runtimeType,limit,sortBy,filter);

@override
String toString() {
  return 'FeedParams(limit: $limit, sortBy: $sortBy, filter: $filter)';
}


}

/// @nodoc
abstract mixin class _$FeedParamsCopyWith<$Res> implements $FeedParamsCopyWith<$Res> {
  factory _$FeedParamsCopyWith(_FeedParams value, $Res Function(_FeedParams) _then) = __$FeedParamsCopyWithImpl;
@override @useResult
$Res call({
 int limit, FeedSortBy sortBy, FeedFilter? filter
});




}
/// @nodoc
class __$FeedParamsCopyWithImpl<$Res>
    implements _$FeedParamsCopyWith<$Res> {
  __$FeedParamsCopyWithImpl(this._self, this._then);

  final _FeedParams _self;
  final $Res Function(_FeedParams) _then;

/// Create a copy of FeedParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = null,Object? sortBy = null,Object? filter = freezed,}) {
  return _then(_FeedParams(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,sortBy: null == sortBy ? _self.sortBy : sortBy // ignore: cast_nullable_to_non_nullable
as FeedSortBy,filter: freezed == filter ? _self.filter : filter // ignore: cast_nullable_to_non_nullable
as FeedFilter?,
  ));
}


}

/// @nodoc
mixin _$PostDetailParams {

 String get postId;
/// Create a copy of PostDetailParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostDetailParamsCopyWith<PostDetailParams> get copyWith => _$PostDetailParamsCopyWithImpl<PostDetailParams>(this as PostDetailParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostDetailParams&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,postId);

@override
String toString() {
  return 'PostDetailParams(postId: $postId)';
}


}

/// @nodoc
abstract mixin class $PostDetailParamsCopyWith<$Res>  {
  factory $PostDetailParamsCopyWith(PostDetailParams value, $Res Function(PostDetailParams) _then) = _$PostDetailParamsCopyWithImpl;
@useResult
$Res call({
 String postId
});




}
/// @nodoc
class _$PostDetailParamsCopyWithImpl<$Res>
    implements $PostDetailParamsCopyWith<$Res> {
  _$PostDetailParamsCopyWithImpl(this._self, this._then);

  final PostDetailParams _self;
  final $Res Function(PostDetailParams) _then;

/// Create a copy of PostDetailParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? postId = null,}) {
  return _then(_self.copyWith(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PostDetailParams].
extension PostDetailParamsPatterns on PostDetailParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostDetailParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostDetailParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostDetailParams value)  $default,){
final _that = this;
switch (_that) {
case _PostDetailParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostDetailParams value)?  $default,){
final _that = this;
switch (_that) {
case _PostDetailParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String postId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostDetailParams() when $default != null:
return $default(_that.postId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String postId)  $default,) {final _that = this;
switch (_that) {
case _PostDetailParams():
return $default(_that.postId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String postId)?  $default,) {final _that = this;
switch (_that) {
case _PostDetailParams() when $default != null:
return $default(_that.postId);case _:
  return null;

}
}

}

/// @nodoc


class _PostDetailParams implements PostDetailParams {
  const _PostDetailParams({required this.postId});
  

@override final  String postId;

/// Create a copy of PostDetailParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostDetailParamsCopyWith<_PostDetailParams> get copyWith => __$PostDetailParamsCopyWithImpl<_PostDetailParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostDetailParams&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,postId);

@override
String toString() {
  return 'PostDetailParams(postId: $postId)';
}


}

/// @nodoc
abstract mixin class _$PostDetailParamsCopyWith<$Res> implements $PostDetailParamsCopyWith<$Res> {
  factory _$PostDetailParamsCopyWith(_PostDetailParams value, $Res Function(_PostDetailParams) _then) = __$PostDetailParamsCopyWithImpl;
@override @useResult
$Res call({
 String postId
});




}
/// @nodoc
class __$PostDetailParamsCopyWithImpl<$Res>
    implements _$PostDetailParamsCopyWith<$Res> {
  __$PostDetailParamsCopyWithImpl(this._self, this._then);

  final _PostDetailParams _self;
  final $Res Function(_PostDetailParams) _then;

/// Create a copy of PostDetailParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? postId = null,}) {
  return _then(_PostDetailParams(
postId: null == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$TrendingPostsParams {

 int get limit;
/// Create a copy of TrendingPostsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingPostsParamsCopyWith<TrendingPostsParams> get copyWith => _$TrendingPostsParamsCopyWithImpl<TrendingPostsParams>(this as TrendingPostsParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingPostsParams&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,limit);

@override
String toString() {
  return 'TrendingPostsParams(limit: $limit)';
}


}

/// @nodoc
abstract mixin class $TrendingPostsParamsCopyWith<$Res>  {
  factory $TrendingPostsParamsCopyWith(TrendingPostsParams value, $Res Function(TrendingPostsParams) _then) = _$TrendingPostsParamsCopyWithImpl;
@useResult
$Res call({
 int limit
});




}
/// @nodoc
class _$TrendingPostsParamsCopyWithImpl<$Res>
    implements $TrendingPostsParamsCopyWith<$Res> {
  _$TrendingPostsParamsCopyWithImpl(this._self, this._then);

  final TrendingPostsParams _self;
  final $Res Function(TrendingPostsParams) _then;

/// Create a copy of TrendingPostsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = null,}) {
  return _then(_self.copyWith(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingPostsParams].
extension TrendingPostsParamsPatterns on TrendingPostsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingPostsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingPostsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingPostsParams value)  $default,){
final _that = this;
switch (_that) {
case _TrendingPostsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingPostsParams value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingPostsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingPostsParams() when $default != null:
return $default(_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int limit)  $default,) {final _that = this;
switch (_that) {
case _TrendingPostsParams():
return $default(_that.limit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int limit)?  $default,) {final _that = this;
switch (_that) {
case _TrendingPostsParams() when $default != null:
return $default(_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _TrendingPostsParams implements TrendingPostsParams {
  const _TrendingPostsParams({this.limit = 20});
  

@override@JsonKey() final  int limit;

/// Create a copy of TrendingPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingPostsParamsCopyWith<_TrendingPostsParams> get copyWith => __$TrendingPostsParamsCopyWithImpl<_TrendingPostsParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingPostsParams&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,limit);

@override
String toString() {
  return 'TrendingPostsParams(limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$TrendingPostsParamsCopyWith<$Res> implements $TrendingPostsParamsCopyWith<$Res> {
  factory _$TrendingPostsParamsCopyWith(_TrendingPostsParams value, $Res Function(_TrendingPostsParams) _then) = __$TrendingPostsParamsCopyWithImpl;
@override @useResult
$Res call({
 int limit
});




}
/// @nodoc
class __$TrendingPostsParamsCopyWithImpl<$Res>
    implements _$TrendingPostsParamsCopyWith<$Res> {
  __$TrendingPostsParamsCopyWithImpl(this._self, this._then);

  final _TrendingPostsParams _self;
  final $Res Function(_TrendingPostsParams) _then;

/// Create a copy of TrendingPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = null,}) {
  return _then(_TrendingPostsParams(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$PopularPostsParams {

 int get limit; Duration? get timeWindow;
/// Create a copy of PopularPostsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PopularPostsParamsCopyWith<PopularPostsParams> get copyWith => _$PopularPostsParamsCopyWithImpl<PopularPostsParams>(this as PopularPostsParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PopularPostsParams&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.timeWindow, timeWindow) || other.timeWindow == timeWindow));
}


@override
int get hashCode => Object.hash(runtimeType,limit,timeWindow);

@override
String toString() {
  return 'PopularPostsParams(limit: $limit, timeWindow: $timeWindow)';
}


}

/// @nodoc
abstract mixin class $PopularPostsParamsCopyWith<$Res>  {
  factory $PopularPostsParamsCopyWith(PopularPostsParams value, $Res Function(PopularPostsParams) _then) = _$PopularPostsParamsCopyWithImpl;
@useResult
$Res call({
 int limit, Duration? timeWindow
});




}
/// @nodoc
class _$PopularPostsParamsCopyWithImpl<$Res>
    implements $PopularPostsParamsCopyWith<$Res> {
  _$PopularPostsParamsCopyWithImpl(this._self, this._then);

  final PopularPostsParams _self;
  final $Res Function(PopularPostsParams) _then;

/// Create a copy of PopularPostsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? limit = null,Object? timeWindow = freezed,}) {
  return _then(_self.copyWith(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,timeWindow: freezed == timeWindow ? _self.timeWindow : timeWindow // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}

}


/// Adds pattern-matching-related methods to [PopularPostsParams].
extension PopularPostsParamsPatterns on PopularPostsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PopularPostsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PopularPostsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PopularPostsParams value)  $default,){
final _that = this;
switch (_that) {
case _PopularPostsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PopularPostsParams value)?  $default,){
final _that = this;
switch (_that) {
case _PopularPostsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int limit,  Duration? timeWindow)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PopularPostsParams() when $default != null:
return $default(_that.limit,_that.timeWindow);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int limit,  Duration? timeWindow)  $default,) {final _that = this;
switch (_that) {
case _PopularPostsParams():
return $default(_that.limit,_that.timeWindow);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int limit,  Duration? timeWindow)?  $default,) {final _that = this;
switch (_that) {
case _PopularPostsParams() when $default != null:
return $default(_that.limit,_that.timeWindow);case _:
  return null;

}
}

}

/// @nodoc


class _PopularPostsParams implements PopularPostsParams {
  const _PopularPostsParams({this.limit = 20, this.timeWindow});
  

@override@JsonKey() final  int limit;
@override final  Duration? timeWindow;

/// Create a copy of PopularPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PopularPostsParamsCopyWith<_PopularPostsParams> get copyWith => __$PopularPostsParamsCopyWithImpl<_PopularPostsParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PopularPostsParams&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.timeWindow, timeWindow) || other.timeWindow == timeWindow));
}


@override
int get hashCode => Object.hash(runtimeType,limit,timeWindow);

@override
String toString() {
  return 'PopularPostsParams(limit: $limit, timeWindow: $timeWindow)';
}


}

/// @nodoc
abstract mixin class _$PopularPostsParamsCopyWith<$Res> implements $PopularPostsParamsCopyWith<$Res> {
  factory _$PopularPostsParamsCopyWith(_PopularPostsParams value, $Res Function(_PopularPostsParams) _then) = __$PopularPostsParamsCopyWithImpl;
@override @useResult
$Res call({
 int limit, Duration? timeWindow
});




}
/// @nodoc
class __$PopularPostsParamsCopyWithImpl<$Res>
    implements _$PopularPostsParamsCopyWith<$Res> {
  __$PopularPostsParamsCopyWithImpl(this._self, this._then);

  final _PopularPostsParams _self;
  final $Res Function(_PopularPostsParams) _then;

/// Create a copy of PopularPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? limit = null,Object? timeWindow = freezed,}) {
  return _then(_PopularPostsParams(
limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,timeWindow: freezed == timeWindow ? _self.timeWindow : timeWindow // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

/// @nodoc
mixin _$UserPostsParams {

 String get userId; int get limit;
/// Create a copy of UserPostsParams
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserPostsParamsCopyWith<UserPostsParams> get copyWith => _$UserPostsParamsCopyWithImpl<UserPostsParams>(this as UserPostsParams, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserPostsParams&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,userId,limit);

@override
String toString() {
  return 'UserPostsParams(userId: $userId, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $UserPostsParamsCopyWith<$Res>  {
  factory $UserPostsParamsCopyWith(UserPostsParams value, $Res Function(UserPostsParams) _then) = _$UserPostsParamsCopyWithImpl;
@useResult
$Res call({
 String userId, int limit
});




}
/// @nodoc
class _$UserPostsParamsCopyWithImpl<$Res>
    implements $UserPostsParamsCopyWith<$Res> {
  _$UserPostsParamsCopyWithImpl(this._self, this._then);

  final UserPostsParams _self;
  final $Res Function(UserPostsParams) _then;

/// Create a copy of UserPostsParams
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? limit = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UserPostsParams].
extension UserPostsParamsPatterns on UserPostsParams {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserPostsParams value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserPostsParams() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserPostsParams value)  $default,){
final _that = this;
switch (_that) {
case _UserPostsParams():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserPostsParams value)?  $default,){
final _that = this;
switch (_that) {
case _UserPostsParams() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserPostsParams() when $default != null:
return $default(_that.userId,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int limit)  $default,) {final _that = this;
switch (_that) {
case _UserPostsParams():
return $default(_that.userId,_that.limit);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _UserPostsParams() when $default != null:
return $default(_that.userId,_that.limit);case _:
  return null;

}
}

}

/// @nodoc


class _UserPostsParams implements UserPostsParams {
  const _UserPostsParams({required this.userId, this.limit = -1});
  

@override final  String userId;
@override@JsonKey() final  int limit;

/// Create a copy of UserPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserPostsParamsCopyWith<_UserPostsParams> get copyWith => __$UserPostsParamsCopyWithImpl<_UserPostsParams>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserPostsParams&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.limit, limit) || other.limit == limit));
}


@override
int get hashCode => Object.hash(runtimeType,userId,limit);

@override
String toString() {
  return 'UserPostsParams(userId: $userId, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$UserPostsParamsCopyWith<$Res> implements $UserPostsParamsCopyWith<$Res> {
  factory _$UserPostsParamsCopyWith(_UserPostsParams value, $Res Function(_UserPostsParams) _then) = __$UserPostsParamsCopyWithImpl;
@override @useResult
$Res call({
 String userId, int limit
});




}
/// @nodoc
class __$UserPostsParamsCopyWithImpl<$Res>
    implements _$UserPostsParamsCopyWith<$Res> {
  __$UserPostsParamsCopyWithImpl(this._self, this._then);

  final _UserPostsParams _self;
  final $Res Function(_UserPostsParams) _then;

/// Create a copy of UserPostsParams
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? limit = null,}) {
  return _then(_UserPostsParams(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
