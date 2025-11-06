// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_ui_state_notifier.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VoteUIState {

 bool get hasVoted; String? get selectedOption; DateTime? get voteTimestamp; bool get isAnimating;
/// Create a copy of VoteUIState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteUIStateCopyWith<VoteUIState> get copyWith => _$VoteUIStateCopyWithImpl<VoteUIState>(this as VoteUIState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteUIState&&(identical(other.hasVoted, hasVoted) || other.hasVoted == hasVoted)&&(identical(other.selectedOption, selectedOption) || other.selectedOption == selectedOption)&&(identical(other.voteTimestamp, voteTimestamp) || other.voteTimestamp == voteTimestamp)&&(identical(other.isAnimating, isAnimating) || other.isAnimating == isAnimating));
}


@override
int get hashCode => Object.hash(runtimeType,hasVoted,selectedOption,voteTimestamp,isAnimating);

@override
String toString() {
  return 'VoteUIState(hasVoted: $hasVoted, selectedOption: $selectedOption, voteTimestamp: $voteTimestamp, isAnimating: $isAnimating)';
}


}

/// @nodoc
abstract mixin class $VoteUIStateCopyWith<$Res>  {
  factory $VoteUIStateCopyWith(VoteUIState value, $Res Function(VoteUIState) _then) = _$VoteUIStateCopyWithImpl;
@useResult
$Res call({
 bool hasVoted, String? selectedOption, DateTime? voteTimestamp, bool isAnimating
});




}
/// @nodoc
class _$VoteUIStateCopyWithImpl<$Res>
    implements $VoteUIStateCopyWith<$Res> {
  _$VoteUIStateCopyWithImpl(this._self, this._then);

  final VoteUIState _self;
  final $Res Function(VoteUIState) _then;

/// Create a copy of VoteUIState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hasVoted = null,Object? selectedOption = freezed,Object? voteTimestamp = freezed,Object? isAnimating = null,}) {
  return _then(_self.copyWith(
hasVoted: null == hasVoted ? _self.hasVoted : hasVoted // ignore: cast_nullable_to_non_nullable
as bool,selectedOption: freezed == selectedOption ? _self.selectedOption : selectedOption // ignore: cast_nullable_to_non_nullable
as String?,voteTimestamp: freezed == voteTimestamp ? _self.voteTimestamp : voteTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnimating: null == isAnimating ? _self.isAnimating : isAnimating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteUIState].
extension VoteUIStatePatterns on VoteUIState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteUIState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteUIState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteUIState value)  $default,){
final _that = this;
switch (_that) {
case _VoteUIState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteUIState value)?  $default,){
final _that = this;
switch (_that) {
case _VoteUIState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool hasVoted,  String? selectedOption,  DateTime? voteTimestamp,  bool isAnimating)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteUIState() when $default != null:
return $default(_that.hasVoted,_that.selectedOption,_that.voteTimestamp,_that.isAnimating);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool hasVoted,  String? selectedOption,  DateTime? voteTimestamp,  bool isAnimating)  $default,) {final _that = this;
switch (_that) {
case _VoteUIState():
return $default(_that.hasVoted,_that.selectedOption,_that.voteTimestamp,_that.isAnimating);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool hasVoted,  String? selectedOption,  DateTime? voteTimestamp,  bool isAnimating)?  $default,) {final _that = this;
switch (_that) {
case _VoteUIState() when $default != null:
return $default(_that.hasVoted,_that.selectedOption,_that.voteTimestamp,_that.isAnimating);case _:
  return null;

}
}

}

/// @nodoc


class _VoteUIState implements VoteUIState {
  const _VoteUIState({this.hasVoted = false, this.selectedOption = null, this.voteTimestamp = null, this.isAnimating = false});
  

@override@JsonKey() final  bool hasVoted;
@override@JsonKey() final  String? selectedOption;
@override@JsonKey() final  DateTime? voteTimestamp;
@override@JsonKey() final  bool isAnimating;

/// Create a copy of VoteUIState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteUIStateCopyWith<_VoteUIState> get copyWith => __$VoteUIStateCopyWithImpl<_VoteUIState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteUIState&&(identical(other.hasVoted, hasVoted) || other.hasVoted == hasVoted)&&(identical(other.selectedOption, selectedOption) || other.selectedOption == selectedOption)&&(identical(other.voteTimestamp, voteTimestamp) || other.voteTimestamp == voteTimestamp)&&(identical(other.isAnimating, isAnimating) || other.isAnimating == isAnimating));
}


@override
int get hashCode => Object.hash(runtimeType,hasVoted,selectedOption,voteTimestamp,isAnimating);

@override
String toString() {
  return 'VoteUIState(hasVoted: $hasVoted, selectedOption: $selectedOption, voteTimestamp: $voteTimestamp, isAnimating: $isAnimating)';
}


}

/// @nodoc
abstract mixin class _$VoteUIStateCopyWith<$Res> implements $VoteUIStateCopyWith<$Res> {
  factory _$VoteUIStateCopyWith(_VoteUIState value, $Res Function(_VoteUIState) _then) = __$VoteUIStateCopyWithImpl;
@override @useResult
$Res call({
 bool hasVoted, String? selectedOption, DateTime? voteTimestamp, bool isAnimating
});




}
/// @nodoc
class __$VoteUIStateCopyWithImpl<$Res>
    implements _$VoteUIStateCopyWith<$Res> {
  __$VoteUIStateCopyWithImpl(this._self, this._then);

  final _VoteUIState _self;
  final $Res Function(_VoteUIState) _then;

/// Create a copy of VoteUIState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hasVoted = null,Object? selectedOption = freezed,Object? voteTimestamp = freezed,Object? isAnimating = null,}) {
  return _then(_VoteUIState(
hasVoted: null == hasVoted ? _self.hasVoted : hasVoted // ignore: cast_nullable_to_non_nullable
as bool,selectedOption: freezed == selectedOption ? _self.selectedOption : selectedOption // ignore: cast_nullable_to_non_nullable
as String?,voteTimestamp: freezed == voteTimestamp ? _self.voteTimestamp : voteTimestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isAnimating: null == isAnimating ? _self.isAnimating : isAnimating // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
