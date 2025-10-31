// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interest.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Interest {

/// 관심사 고유 ID
 String get id;/// 관심사 이름
 String get name;/// 관심사 카테고리 (job, expertise, hobby)
 String get category;/// 가중치 (우선순위, 0.0 ~ 1.0)
 double get weight;/// 선택된 날짜
 DateTime? get selectedAt;
/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterestCopyWith<Interest> get copyWith => _$InterestCopyWithImpl<Interest>(this as Interest, _$identity);

  /// Serializes this Interest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Interest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.selectedAt, selectedAt) || other.selectedAt == selectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,weight,selectedAt);

@override
String toString() {
  return 'Interest(id: $id, name: $name, category: $category, weight: $weight, selectedAt: $selectedAt)';
}


}

/// @nodoc
abstract mixin class $InterestCopyWith<$Res>  {
  factory $InterestCopyWith(Interest value, $Res Function(Interest) _then) = _$InterestCopyWithImpl;
@useResult
$Res call({
 String id, String name, String category, double weight, DateTime? selectedAt
});




}
/// @nodoc
class _$InterestCopyWithImpl<$Res>
    implements $InterestCopyWith<$Res> {
  _$InterestCopyWithImpl(this._self, this._then);

  final Interest _self;
  final $Res Function(Interest) _then;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? category = null,Object? weight = null,Object? selectedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,selectedAt: freezed == selectedAt ? _self.selectedAt : selectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Interest].
extension InterestPatterns on Interest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Interest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Interest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Interest value)  $default,){
final _that = this;
switch (_that) {
case _Interest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Interest value)?  $default,){
final _that = this;
switch (_that) {
case _Interest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String category,  double weight,  DateTime? selectedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Interest() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.weight,_that.selectedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String category,  double weight,  DateTime? selectedAt)  $default,) {final _that = this;
switch (_that) {
case _Interest():
return $default(_that.id,_that.name,_that.category,_that.weight,_that.selectedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String category,  double weight,  DateTime? selectedAt)?  $default,) {final _that = this;
switch (_that) {
case _Interest() when $default != null:
return $default(_that.id,_that.name,_that.category,_that.weight,_that.selectedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Interest extends Interest {
  const _Interest({required this.id, required this.name, required this.category, this.weight = 0.5, this.selectedAt}): super._();
  factory _Interest.fromJson(Map<String, dynamic> json) => _$InterestFromJson(json);

/// 관심사 고유 ID
@override final  String id;
/// 관심사 이름
@override final  String name;
/// 관심사 카테고리 (job, expertise, hobby)
@override final  String category;
/// 가중치 (우선순위, 0.0 ~ 1.0)
@override@JsonKey() final  double weight;
/// 선택된 날짜
@override final  DateTime? selectedAt;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterestCopyWith<_Interest> get copyWith => __$InterestCopyWithImpl<_Interest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Interest&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.category, category) || other.category == category)&&(identical(other.weight, weight) || other.weight == weight)&&(identical(other.selectedAt, selectedAt) || other.selectedAt == selectedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,category,weight,selectedAt);

@override
String toString() {
  return 'Interest(id: $id, name: $name, category: $category, weight: $weight, selectedAt: $selectedAt)';
}


}

/// @nodoc
abstract mixin class _$InterestCopyWith<$Res> implements $InterestCopyWith<$Res> {
  factory _$InterestCopyWith(_Interest value, $Res Function(_Interest) _then) = __$InterestCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String category, double weight, DateTime? selectedAt
});




}
/// @nodoc
class __$InterestCopyWithImpl<$Res>
    implements _$InterestCopyWith<$Res> {
  __$InterestCopyWithImpl(this._self, this._then);

  final _Interest _self;
  final $Res Function(_Interest) _then;

/// Create a copy of Interest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? category = null,Object? weight = null,Object? selectedAt = freezed,}) {
  return _then(_Interest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,weight: null == weight ? _self.weight : weight // ignore: cast_nullable_to_non_nullable
as double,selectedAt: freezed == selectedAt ? _self.selectedAt : selectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
