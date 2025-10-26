// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vote_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VoteStateData {

/// 현재 투표 상태
 VoteState get state;/// 남은 시간 (타이머가 있는 경우)
 Duration? get remainingTime;/// 투표 결과 (완료된 경우)
 Map<String, dynamic>? get voteResults;/// 타이머 만료 여부
 bool get isTimerExpired;/// 투표 종료 시간
 DateTime? get voteEndTime;/// 에러 메시지 (에러 발생 시)
 String? get errorMessage;/// 사용자가 이미 투표했는지 여부
 bool get hasUserVoted;/// 사용자의 투표 선택 (A 또는 B)
 String? get userChoice;
/// Create a copy of VoteStateData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VoteStateDataCopyWith<VoteStateData> get copyWith => _$VoteStateDataCopyWithImpl<VoteStateData>(this as VoteStateData, _$identity);

  /// Serializes this VoteStateData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VoteStateData&&(identical(other.state, state) || other.state == state)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&const DeepCollectionEquality().equals(other.voteResults, voteResults)&&(identical(other.isTimerExpired, isTimerExpired) || other.isTimerExpired == isTimerExpired)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasUserVoted, hasUserVoted) || other.hasUserVoted == hasUserVoted)&&(identical(other.userChoice, userChoice) || other.userChoice == userChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,remainingTime,const DeepCollectionEquality().hash(voteResults),isTimerExpired,voteEndTime,errorMessage,hasUserVoted,userChoice);

@override
String toString() {
  return 'VoteStateData(state: $state, remainingTime: $remainingTime, voteResults: $voteResults, isTimerExpired: $isTimerExpired, voteEndTime: $voteEndTime, errorMessage: $errorMessage, hasUserVoted: $hasUserVoted, userChoice: $userChoice)';
}


}

/// @nodoc
abstract mixin class $VoteStateDataCopyWith<$Res>  {
  factory $VoteStateDataCopyWith(VoteStateData value, $Res Function(VoteStateData) _then) = _$VoteStateDataCopyWithImpl;
@useResult
$Res call({
 VoteState state, Duration? remainingTime, Map<String, dynamic>? voteResults, bool isTimerExpired, DateTime? voteEndTime, String? errorMessage, bool hasUserVoted, String? userChoice
});




}
/// @nodoc
class _$VoteStateDataCopyWithImpl<$Res>
    implements $VoteStateDataCopyWith<$Res> {
  _$VoteStateDataCopyWithImpl(this._self, this._then);

  final VoteStateData _self;
  final $Res Function(VoteStateData) _then;

/// Create a copy of VoteStateData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? state = null,Object? remainingTime = freezed,Object? voteResults = freezed,Object? isTimerExpired = null,Object? voteEndTime = freezed,Object? errorMessage = freezed,Object? hasUserVoted = null,Object? userChoice = freezed,}) {
  return _then(_self.copyWith(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as VoteState,remainingTime: freezed == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as Duration?,voteResults: freezed == voteResults ? _self.voteResults : voteResults // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isTimerExpired: null == isTimerExpired ? _self.isTimerExpired : isTimerExpired // ignore: cast_nullable_to_non_nullable
as bool,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasUserVoted: null == hasUserVoted ? _self.hasUserVoted : hasUserVoted // ignore: cast_nullable_to_non_nullable
as bool,userChoice: freezed == userChoice ? _self.userChoice : userChoice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VoteStateData].
extension VoteStateDataPatterns on VoteStateData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VoteStateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VoteStateData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VoteStateData value)  $default,){
final _that = this;
switch (_that) {
case _VoteStateData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VoteStateData value)?  $default,){
final _that = this;
switch (_that) {
case _VoteStateData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( VoteState state,  Duration? remainingTime,  Map<String, dynamic>? voteResults,  bool isTimerExpired,  DateTime? voteEndTime,  String? errorMessage,  bool hasUserVoted,  String? userChoice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VoteStateData() when $default != null:
return $default(_that.state,_that.remainingTime,_that.voteResults,_that.isTimerExpired,_that.voteEndTime,_that.errorMessage,_that.hasUserVoted,_that.userChoice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( VoteState state,  Duration? remainingTime,  Map<String, dynamic>? voteResults,  bool isTimerExpired,  DateTime? voteEndTime,  String? errorMessage,  bool hasUserVoted,  String? userChoice)  $default,) {final _that = this;
switch (_that) {
case _VoteStateData():
return $default(_that.state,_that.remainingTime,_that.voteResults,_that.isTimerExpired,_that.voteEndTime,_that.errorMessage,_that.hasUserVoted,_that.userChoice);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( VoteState state,  Duration? remainingTime,  Map<String, dynamic>? voteResults,  bool isTimerExpired,  DateTime? voteEndTime,  String? errorMessage,  bool hasUserVoted,  String? userChoice)?  $default,) {final _that = this;
switch (_that) {
case _VoteStateData() when $default != null:
return $default(_that.state,_that.remainingTime,_that.voteResults,_that.isTimerExpired,_that.voteEndTime,_that.errorMessage,_that.hasUserVoted,_that.userChoice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VoteStateData extends VoteStateData {
  const _VoteStateData({required this.state, this.remainingTime, final  Map<String, dynamic>? voteResults, this.isTimerExpired = false, this.voteEndTime, this.errorMessage, this.hasUserVoted = false, this.userChoice}): _voteResults = voteResults,super._();
  factory _VoteStateData.fromJson(Map<String, dynamic> json) => _$VoteStateDataFromJson(json);

/// 현재 투표 상태
@override final  VoteState state;
/// 남은 시간 (타이머가 있는 경우)
@override final  Duration? remainingTime;
/// 투표 결과 (완료된 경우)
 final  Map<String, dynamic>? _voteResults;
/// 투표 결과 (완료된 경우)
@override Map<String, dynamic>? get voteResults {
  final value = _voteResults;
  if (value == null) return null;
  if (_voteResults is EqualUnmodifiableMapView) return _voteResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// 타이머 만료 여부
@override@JsonKey() final  bool isTimerExpired;
/// 투표 종료 시간
@override final  DateTime? voteEndTime;
/// 에러 메시지 (에러 발생 시)
@override final  String? errorMessage;
/// 사용자가 이미 투표했는지 여부
@override@JsonKey() final  bool hasUserVoted;
/// 사용자의 투표 선택 (A 또는 B)
@override final  String? userChoice;

/// Create a copy of VoteStateData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VoteStateDataCopyWith<_VoteStateData> get copyWith => __$VoteStateDataCopyWithImpl<_VoteStateData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VoteStateDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VoteStateData&&(identical(other.state, state) || other.state == state)&&(identical(other.remainingTime, remainingTime) || other.remainingTime == remainingTime)&&const DeepCollectionEquality().equals(other._voteResults, _voteResults)&&(identical(other.isTimerExpired, isTimerExpired) || other.isTimerExpired == isTimerExpired)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.hasUserVoted, hasUserVoted) || other.hasUserVoted == hasUserVoted)&&(identical(other.userChoice, userChoice) || other.userChoice == userChoice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,state,remainingTime,const DeepCollectionEquality().hash(_voteResults),isTimerExpired,voteEndTime,errorMessage,hasUserVoted,userChoice);

@override
String toString() {
  return 'VoteStateData(state: $state, remainingTime: $remainingTime, voteResults: $voteResults, isTimerExpired: $isTimerExpired, voteEndTime: $voteEndTime, errorMessage: $errorMessage, hasUserVoted: $hasUserVoted, userChoice: $userChoice)';
}


}

/// @nodoc
abstract mixin class _$VoteStateDataCopyWith<$Res> implements $VoteStateDataCopyWith<$Res> {
  factory _$VoteStateDataCopyWith(_VoteStateData value, $Res Function(_VoteStateData) _then) = __$VoteStateDataCopyWithImpl;
@override @useResult
$Res call({
 VoteState state, Duration? remainingTime, Map<String, dynamic>? voteResults, bool isTimerExpired, DateTime? voteEndTime, String? errorMessage, bool hasUserVoted, String? userChoice
});




}
/// @nodoc
class __$VoteStateDataCopyWithImpl<$Res>
    implements _$VoteStateDataCopyWith<$Res> {
  __$VoteStateDataCopyWithImpl(this._self, this._then);

  final _VoteStateData _self;
  final $Res Function(_VoteStateData) _then;

/// Create a copy of VoteStateData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? state = null,Object? remainingTime = freezed,Object? voteResults = freezed,Object? isTimerExpired = null,Object? voteEndTime = freezed,Object? errorMessage = freezed,Object? hasUserVoted = null,Object? userChoice = freezed,}) {
  return _then(_VoteStateData(
state: null == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as VoteState,remainingTime: freezed == remainingTime ? _self.remainingTime : remainingTime // ignore: cast_nullable_to_non_nullable
as Duration?,voteResults: freezed == voteResults ? _self._voteResults : voteResults // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,isTimerExpired: null == isTimerExpired ? _self.isTimerExpired : isTimerExpired // ignore: cast_nullable_to_non_nullable
as bool,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,hasUserVoted: null == hasUserVoted ? _self.hasUserVoted : hasUserVoted // ignore: cast_nullable_to_non_nullable
as bool,userChoice: freezed == userChoice ? _self.userChoice : userChoice // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
