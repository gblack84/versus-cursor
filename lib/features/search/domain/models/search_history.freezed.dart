// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_history.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchHistory {

 String get searchId; String get userId; String get query; DateTime? get date;
/// Create a copy of SearchHistory
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchHistoryCopyWith<SearchHistory> get copyWith => _$SearchHistoryCopyWithImpl<SearchHistory>(this as SearchHistory, _$identity);

  /// Serializes this SearchHistory to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchHistory&&(identical(other.searchId, searchId) || other.searchId == searchId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.query, query) || other.query == query)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchId,userId,query,date);

@override
String toString() {
  return 'SearchHistory(searchId: $searchId, userId: $userId, query: $query, date: $date)';
}


}

/// @nodoc
abstract mixin class $SearchHistoryCopyWith<$Res>  {
  factory $SearchHistoryCopyWith(SearchHistory value, $Res Function(SearchHistory) _then) = _$SearchHistoryCopyWithImpl;
@useResult
$Res call({
 String searchId, String userId, String query, DateTime? date
});




}
/// @nodoc
class _$SearchHistoryCopyWithImpl<$Res>
    implements $SearchHistoryCopyWith<$Res> {
  _$SearchHistoryCopyWithImpl(this._self, this._then);

  final SearchHistory _self;
  final $Res Function(SearchHistory) _then;

/// Create a copy of SearchHistory
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? searchId = null,Object? userId = null,Object? query = null,Object? date = freezed,}) {
  return _then(_self.copyWith(
searchId: null == searchId ? _self.searchId : searchId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [SearchHistory].
extension SearchHistoryPatterns on SearchHistory {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchHistory value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchHistory() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchHistory value)  $default,){
final _that = this;
switch (_that) {
case _SearchHistory():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchHistory value)?  $default,){
final _that = this;
switch (_that) {
case _SearchHistory() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String searchId,  String userId,  String query,  DateTime? date)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchHistory() when $default != null:
return $default(_that.searchId,_that.userId,_that.query,_that.date);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String searchId,  String userId,  String query,  DateTime? date)  $default,) {final _that = this;
switch (_that) {
case _SearchHistory():
return $default(_that.searchId,_that.userId,_that.query,_that.date);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String searchId,  String userId,  String query,  DateTime? date)?  $default,) {final _that = this;
switch (_that) {
case _SearchHistory() when $default != null:
return $default(_that.searchId,_that.userId,_that.query,_that.date);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SearchHistory extends SearchHistory {
  const _SearchHistory({required this.searchId, required this.userId, required this.query, this.date}): super._();
  factory _SearchHistory.fromJson(Map<String, dynamic> json) => _$SearchHistoryFromJson(json);

@override final  String searchId;
@override final  String userId;
@override final  String query;
@override final  DateTime? date;

/// Create a copy of SearchHistory
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchHistoryCopyWith<_SearchHistory> get copyWith => __$SearchHistoryCopyWithImpl<_SearchHistory>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SearchHistoryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchHistory&&(identical(other.searchId, searchId) || other.searchId == searchId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.query, query) || other.query == query)&&(identical(other.date, date) || other.date == date));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,searchId,userId,query,date);

@override
String toString() {
  return 'SearchHistory(searchId: $searchId, userId: $userId, query: $query, date: $date)';
}


}

/// @nodoc
abstract mixin class _$SearchHistoryCopyWith<$Res> implements $SearchHistoryCopyWith<$Res> {
  factory _$SearchHistoryCopyWith(_SearchHistory value, $Res Function(_SearchHistory) _then) = __$SearchHistoryCopyWithImpl;
@override @useResult
$Res call({
 String searchId, String userId, String query, DateTime? date
});




}
/// @nodoc
class __$SearchHistoryCopyWithImpl<$Res>
    implements _$SearchHistoryCopyWith<$Res> {
  __$SearchHistoryCopyWithImpl(this._self, this._then);

  final _SearchHistory _self;
  final $Res Function(_SearchHistory) _then;

/// Create a copy of SearchHistory
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? searchId = null,Object? userId = null,Object? query = null,Object? date = freezed,}) {
  return _then(_SearchHistory(
searchId: null == searchId ? _self.searchId : searchId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
