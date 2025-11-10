// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'navigation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NavigationState {

/// 현재 네비게이션 모드
 NavigationMode get mode;/// 메인 모드 탭 인덱스
 int get mainTabIndex;/// 채팅 모드 탭 인덱스
 int get chatTabIndex;
/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NavigationStateCopyWith<NavigationState> get copyWith => _$NavigationStateCopyWithImpl<NavigationState>(this as NavigationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NavigationState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.mainTabIndex, mainTabIndex) || other.mainTabIndex == mainTabIndex)&&(identical(other.chatTabIndex, chatTabIndex) || other.chatTabIndex == chatTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,mode,mainTabIndex,chatTabIndex);

@override
String toString() {
  return 'NavigationState(mode: $mode, mainTabIndex: $mainTabIndex, chatTabIndex: $chatTabIndex)';
}


}

/// @nodoc
abstract mixin class $NavigationStateCopyWith<$Res>  {
  factory $NavigationStateCopyWith(NavigationState value, $Res Function(NavigationState) _then) = _$NavigationStateCopyWithImpl;
@useResult
$Res call({
 NavigationMode mode, int mainTabIndex, int chatTabIndex
});




}
/// @nodoc
class _$NavigationStateCopyWithImpl<$Res>
    implements $NavigationStateCopyWith<$Res> {
  _$NavigationStateCopyWithImpl(this._self, this._then);

  final NavigationState _self;
  final $Res Function(NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? mode = null,Object? mainTabIndex = null,Object? chatTabIndex = null,}) {
  return _then(_self.copyWith(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NavigationMode,mainTabIndex: null == mainTabIndex ? _self.mainTabIndex : mainTabIndex // ignore: cast_nullable_to_non_nullable
as int,chatTabIndex: null == chatTabIndex ? _self.chatTabIndex : chatTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [NavigationState].
extension NavigationStatePatterns on NavigationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NavigationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NavigationState value)  $default,){
final _that = this;
switch (_that) {
case _NavigationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NavigationState value)?  $default,){
final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( NavigationMode mode,  int mainTabIndex,  int chatTabIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.mode,_that.mainTabIndex,_that.chatTabIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( NavigationMode mode,  int mainTabIndex,  int chatTabIndex)  $default,) {final _that = this;
switch (_that) {
case _NavigationState():
return $default(_that.mode,_that.mainTabIndex,_that.chatTabIndex);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( NavigationMode mode,  int mainTabIndex,  int chatTabIndex)?  $default,) {final _that = this;
switch (_that) {
case _NavigationState() when $default != null:
return $default(_that.mode,_that.mainTabIndex,_that.chatTabIndex);case _:
  return null;

}
}

}

/// @nodoc


class _NavigationState extends NavigationState {
  const _NavigationState({this.mode = NavigationMode.main, this.mainTabIndex = 0, this.chatTabIndex = 0}): super._();
  

/// 현재 네비게이션 모드
@override@JsonKey() final  NavigationMode mode;
/// 메인 모드 탭 인덱스
@override@JsonKey() final  int mainTabIndex;
/// 채팅 모드 탭 인덱스
@override@JsonKey() final  int chatTabIndex;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NavigationStateCopyWith<_NavigationState> get copyWith => __$NavigationStateCopyWithImpl<_NavigationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NavigationState&&(identical(other.mode, mode) || other.mode == mode)&&(identical(other.mainTabIndex, mainTabIndex) || other.mainTabIndex == mainTabIndex)&&(identical(other.chatTabIndex, chatTabIndex) || other.chatTabIndex == chatTabIndex));
}


@override
int get hashCode => Object.hash(runtimeType,mode,mainTabIndex,chatTabIndex);

@override
String toString() {
  return 'NavigationState(mode: $mode, mainTabIndex: $mainTabIndex, chatTabIndex: $chatTabIndex)';
}


}

/// @nodoc
abstract mixin class _$NavigationStateCopyWith<$Res> implements $NavigationStateCopyWith<$Res> {
  factory _$NavigationStateCopyWith(_NavigationState value, $Res Function(_NavigationState) _then) = __$NavigationStateCopyWithImpl;
@override @useResult
$Res call({
 NavigationMode mode, int mainTabIndex, int chatTabIndex
});




}
/// @nodoc
class __$NavigationStateCopyWithImpl<$Res>
    implements _$NavigationStateCopyWith<$Res> {
  __$NavigationStateCopyWithImpl(this._self, this._then);

  final _NavigationState _self;
  final $Res Function(_NavigationState) _then;

/// Create a copy of NavigationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? mode = null,Object? mainTabIndex = null,Object? chatTabIndex = null,}) {
  return _then(_NavigationState(
mode: null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as NavigationMode,mainTabIndex: null == mainTabIndex ? _self.mainTabIndex : mainTabIndex // ignore: cast_nullable_to_non_nullable
as int,chatTabIndex: null == chatTabIndex ? _self.chatTabIndex : chatTabIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
