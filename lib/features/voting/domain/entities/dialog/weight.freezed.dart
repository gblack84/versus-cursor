// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weight.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Weight {

/// 관심사 이름 (필수)
 String get nameInterest;/// 관심사 점수 (필수)
 int get scoreInterest;
/// Create a copy of Weight
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeightCopyWith<Weight> get copyWith => _$WeightCopyWithImpl<Weight>(this as Weight, _$identity);

  /// Serializes this Weight to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Weight&&(identical(other.nameInterest, nameInterest) || other.nameInterest == nameInterest)&&(identical(other.scoreInterest, scoreInterest) || other.scoreInterest == scoreInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameInterest,scoreInterest);

@override
String toString() {
  return 'Weight(nameInterest: $nameInterest, scoreInterest: $scoreInterest)';
}


}

/// @nodoc
abstract mixin class $WeightCopyWith<$Res>  {
  factory $WeightCopyWith(Weight value, $Res Function(Weight) _then) = _$WeightCopyWithImpl;
@useResult
$Res call({
 String nameInterest, int scoreInterest
});




}
/// @nodoc
class _$WeightCopyWithImpl<$Res>
    implements $WeightCopyWith<$Res> {
  _$WeightCopyWithImpl(this._self, this._then);

  final Weight _self;
  final $Res Function(Weight) _then;

/// Create a copy of Weight
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nameInterest = null,Object? scoreInterest = null,}) {
  return _then(_self.copyWith(
nameInterest: null == nameInterest ? _self.nameInterest : nameInterest // ignore: cast_nullable_to_non_nullable
as String,scoreInterest: null == scoreInterest ? _self.scoreInterest : scoreInterest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [Weight].
extension WeightPatterns on Weight {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Weight value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Weight() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Weight value)  $default,){
final _that = this;
switch (_that) {
case _Weight():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Weight value)?  $default,){
final _that = this;
switch (_that) {
case _Weight() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String nameInterest,  int scoreInterest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Weight() when $default != null:
return $default(_that.nameInterest,_that.scoreInterest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String nameInterest,  int scoreInterest)  $default,) {final _that = this;
switch (_that) {
case _Weight():
return $default(_that.nameInterest,_that.scoreInterest);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String nameInterest,  int scoreInterest)?  $default,) {final _that = this;
switch (_that) {
case _Weight() when $default != null:
return $default(_that.nameInterest,_that.scoreInterest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Weight extends Weight {
  const _Weight({this.nameInterest = '', this.scoreInterest = 0}): super._();
  factory _Weight.fromJson(Map<String, dynamic> json) => _$WeightFromJson(json);

/// 관심사 이름 (필수)
@override@JsonKey() final  String nameInterest;
/// 관심사 점수 (필수)
@override@JsonKey() final  int scoreInterest;

/// Create a copy of Weight
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeightCopyWith<_Weight> get copyWith => __$WeightCopyWithImpl<_Weight>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeightToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Weight&&(identical(other.nameInterest, nameInterest) || other.nameInterest == nameInterest)&&(identical(other.scoreInterest, scoreInterest) || other.scoreInterest == scoreInterest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nameInterest,scoreInterest);

@override
String toString() {
  return 'Weight(nameInterest: $nameInterest, scoreInterest: $scoreInterest)';
}


}

/// @nodoc
abstract mixin class _$WeightCopyWith<$Res> implements $WeightCopyWith<$Res> {
  factory _$WeightCopyWith(_Weight value, $Res Function(_Weight) _then) = __$WeightCopyWithImpl;
@override @useResult
$Res call({
 String nameInterest, int scoreInterest
});




}
/// @nodoc
class __$WeightCopyWithImpl<$Res>
    implements _$WeightCopyWith<$Res> {
  __$WeightCopyWithImpl(this._self, this._then);

  final _Weight _self;
  final $Res Function(_Weight) _then;

/// Create a copy of Weight
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nameInterest = null,Object? scoreInterest = null,}) {
  return _then(_Weight(
nameInterest: null == nameInterest ? _self.nameInterest : nameInterest // ignore: cast_nullable_to_non_nullable
as String,scoreInterest: null == scoreInterest ? _self.scoreInterest : scoreInterest // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
