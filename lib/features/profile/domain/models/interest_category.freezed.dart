// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'interest_category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InterestCategory {

 String get interestId; String get nameInterest; List<String> get userIds; List<String> get subCategories;
/// Create a copy of InterestCategory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterestCategoryCopyWith<InterestCategory> get copyWith => _$InterestCategoryCopyWithImpl<InterestCategory>(this as InterestCategory, _$identity);

  /// Serializes this InterestCategory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterestCategory&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.nameInterest, nameInterest) || other.nameInterest == nameInterest)&&const DeepCollectionEquality().equals(other.userIds, userIds)&&const DeepCollectionEquality().equals(other.subCategories, subCategories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,interestId,nameInterest,const DeepCollectionEquality().hash(userIds),const DeepCollectionEquality().hash(subCategories));

@override
String toString() {
  return 'InterestCategory(interestId: $interestId, nameInterest: $nameInterest, userIds: $userIds, subCategories: $subCategories)';
}


}

/// @nodoc
abstract mixin class $InterestCategoryCopyWith<$Res>  {
  factory $InterestCategoryCopyWith(InterestCategory value, $Res Function(InterestCategory) _then) = _$InterestCategoryCopyWithImpl;
@useResult
$Res call({
 String interestId, String nameInterest, List<String> userIds, List<String> subCategories
});




}
/// @nodoc
class _$InterestCategoryCopyWithImpl<$Res>
    implements $InterestCategoryCopyWith<$Res> {
  _$InterestCategoryCopyWithImpl(this._self, this._then);

  final InterestCategory _self;
  final $Res Function(InterestCategory) _then;

/// Create a copy of InterestCategory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? interestId = null,Object? nameInterest = null,Object? userIds = null,Object? subCategories = null,}) {
  return _then(_self.copyWith(
interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,nameInterest: null == nameInterest ? _self.nameInterest : nameInterest // ignore: cast_nullable_to_non_nullable
as String,userIds: null == userIds ? _self.userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,subCategories: null == subCategories ? _self.subCategories : subCategories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [InterestCategory].
extension InterestCategoryPatterns on InterestCategory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterestCategory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterestCategory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterestCategory value)  $default,){
final _that = this;
switch (_that) {
case _InterestCategory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterestCategory value)?  $default,){
final _that = this;
switch (_that) {
case _InterestCategory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String interestId,  String nameInterest,  List<String> userIds,  List<String> subCategories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterestCategory() when $default != null:
return $default(_that.interestId,_that.nameInterest,_that.userIds,_that.subCategories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String interestId,  String nameInterest,  List<String> userIds,  List<String> subCategories)  $default,) {final _that = this;
switch (_that) {
case _InterestCategory():
return $default(_that.interestId,_that.nameInterest,_that.userIds,_that.subCategories);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String interestId,  String nameInterest,  List<String> userIds,  List<String> subCategories)?  $default,) {final _that = this;
switch (_that) {
case _InterestCategory() when $default != null:
return $default(_that.interestId,_that.nameInterest,_that.userIds,_that.subCategories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterestCategory implements InterestCategory {
  const _InterestCategory({required this.interestId, required this.nameInterest, final  List<String> userIds = const [], final  List<String> subCategories = const []}): _userIds = userIds,_subCategories = subCategories;
  factory _InterestCategory.fromJson(Map<String, dynamic> json) => _$InterestCategoryFromJson(json);

@override final  String interestId;
@override final  String nameInterest;
 final  List<String> _userIds;
@override@JsonKey() List<String> get userIds {
  if (_userIds is EqualUnmodifiableListView) return _userIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_userIds);
}

 final  List<String> _subCategories;
@override@JsonKey() List<String> get subCategories {
  if (_subCategories is EqualUnmodifiableListView) return _subCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_subCategories);
}


/// Create a copy of InterestCategory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterestCategoryCopyWith<_InterestCategory> get copyWith => __$InterestCategoryCopyWithImpl<_InterestCategory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterestCategoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterestCategory&&(identical(other.interestId, interestId) || other.interestId == interestId)&&(identical(other.nameInterest, nameInterest) || other.nameInterest == nameInterest)&&const DeepCollectionEquality().equals(other._userIds, _userIds)&&const DeepCollectionEquality().equals(other._subCategories, _subCategories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,interestId,nameInterest,const DeepCollectionEquality().hash(_userIds),const DeepCollectionEquality().hash(_subCategories));

@override
String toString() {
  return 'InterestCategory(interestId: $interestId, nameInterest: $nameInterest, userIds: $userIds, subCategories: $subCategories)';
}


}

/// @nodoc
abstract mixin class _$InterestCategoryCopyWith<$Res> implements $InterestCategoryCopyWith<$Res> {
  factory _$InterestCategoryCopyWith(_InterestCategory value, $Res Function(_InterestCategory) _then) = __$InterestCategoryCopyWithImpl;
@override @useResult
$Res call({
 String interestId, String nameInterest, List<String> userIds, List<String> subCategories
});




}
/// @nodoc
class __$InterestCategoryCopyWithImpl<$Res>
    implements _$InterestCategoryCopyWith<$Res> {
  __$InterestCategoryCopyWithImpl(this._self, this._then);

  final _InterestCategory _self;
  final $Res Function(_InterestCategory) _then;

/// Create a copy of InterestCategory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? interestId = null,Object? nameInterest = null,Object? userIds = null,Object? subCategories = null,}) {
  return _then(_InterestCategory(
interestId: null == interestId ? _self.interestId : interestId // ignore: cast_nullable_to_non_nullable
as String,nameInterest: null == nameInterest ? _self.nameInterest : nameInterest // ignore: cast_nullable_to_non_nullable
as String,userIds: null == userIds ? _self._userIds : userIds // ignore: cast_nullable_to_non_nullable
as List<String>,subCategories: null == subCategories ? _self._subCategories : subCategories // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

// dart format on
