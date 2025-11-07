// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'algolia_result_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AlgoliaResult {

 List<dynamic> get hits; int get totalHits; int get page; int get nbPages; int get hitsPerPage;
/// Create a copy of AlgoliaResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AlgoliaResultCopyWith<AlgoliaResult> get copyWith => _$AlgoliaResultCopyWithImpl<AlgoliaResult>(this as AlgoliaResult, _$identity);

  /// Serializes this AlgoliaResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlgoliaResult&&const DeepCollectionEquality().equals(other.hits, hits)&&(identical(other.totalHits, totalHits) || other.totalHits == totalHits)&&(identical(other.page, page) || other.page == page)&&(identical(other.nbPages, nbPages) || other.nbPages == nbPages)&&(identical(other.hitsPerPage, hitsPerPage) || other.hitsPerPage == hitsPerPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(hits),totalHits,page,nbPages,hitsPerPage);

@override
String toString() {
  return 'AlgoliaResult(hits: $hits, totalHits: $totalHits, page: $page, nbPages: $nbPages, hitsPerPage: $hitsPerPage)';
}


}

/// @nodoc
abstract mixin class $AlgoliaResultCopyWith<$Res>  {
  factory $AlgoliaResultCopyWith(AlgoliaResult value, $Res Function(AlgoliaResult) _then) = _$AlgoliaResultCopyWithImpl;
@useResult
$Res call({
 List<dynamic> hits, int totalHits, int page, int nbPages, int hitsPerPage
});




}
/// @nodoc
class _$AlgoliaResultCopyWithImpl<$Res>
    implements $AlgoliaResultCopyWith<$Res> {
  _$AlgoliaResultCopyWithImpl(this._self, this._then);

  final AlgoliaResult _self;
  final $Res Function(AlgoliaResult) _then;

/// Create a copy of AlgoliaResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? hits = null,Object? totalHits = null,Object? page = null,Object? nbPages = null,Object? hitsPerPage = null,}) {
  return _then(_self.copyWith(
hits: null == hits ? _self.hits : hits // ignore: cast_nullable_to_non_nullable
as List<dynamic>,totalHits: null == totalHits ? _self.totalHits : totalHits // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,nbPages: null == nbPages ? _self.nbPages : nbPages // ignore: cast_nullable_to_non_nullable
as int,hitsPerPage: null == hitsPerPage ? _self.hitsPerPage : hitsPerPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [AlgoliaResult].
extension AlgoliaResultPatterns on AlgoliaResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AlgoliaResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AlgoliaResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AlgoliaResult value)  $default,){
final _that = this;
switch (_that) {
case _AlgoliaResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AlgoliaResult value)?  $default,){
final _that = this;
switch (_that) {
case _AlgoliaResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<dynamic> hits,  int totalHits,  int page,  int nbPages,  int hitsPerPage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AlgoliaResult() when $default != null:
return $default(_that.hits,_that.totalHits,_that.page,_that.nbPages,_that.hitsPerPage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<dynamic> hits,  int totalHits,  int page,  int nbPages,  int hitsPerPage)  $default,) {final _that = this;
switch (_that) {
case _AlgoliaResult():
return $default(_that.hits,_that.totalHits,_that.page,_that.nbPages,_that.hitsPerPage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<dynamic> hits,  int totalHits,  int page,  int nbPages,  int hitsPerPage)?  $default,) {final _that = this;
switch (_that) {
case _AlgoliaResult() when $default != null:
return $default(_that.hits,_that.totalHits,_that.page,_that.nbPages,_that.hitsPerPage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AlgoliaResult extends AlgoliaResult {
  const _AlgoliaResult({required final  List<dynamic> hits, required this.totalHits, required this.page, required this.nbPages, this.hitsPerPage = 20}): _hits = hits,super._();
  factory _AlgoliaResult.fromJson(Map<String, dynamic> json) => _$AlgoliaResultFromJson(json);

 final  List<dynamic> _hits;
@override List<dynamic> get hits {
  if (_hits is EqualUnmodifiableListView) return _hits;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_hits);
}

@override final  int totalHits;
@override final  int page;
@override final  int nbPages;
@override@JsonKey() final  int hitsPerPage;

/// Create a copy of AlgoliaResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AlgoliaResultCopyWith<_AlgoliaResult> get copyWith => __$AlgoliaResultCopyWithImpl<_AlgoliaResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AlgoliaResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AlgoliaResult&&const DeepCollectionEquality().equals(other._hits, _hits)&&(identical(other.totalHits, totalHits) || other.totalHits == totalHits)&&(identical(other.page, page) || other.page == page)&&(identical(other.nbPages, nbPages) || other.nbPages == nbPages)&&(identical(other.hitsPerPage, hitsPerPage) || other.hitsPerPage == hitsPerPage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_hits),totalHits,page,nbPages,hitsPerPage);

@override
String toString() {
  return 'AlgoliaResult(hits: $hits, totalHits: $totalHits, page: $page, nbPages: $nbPages, hitsPerPage: $hitsPerPage)';
}


}

/// @nodoc
abstract mixin class _$AlgoliaResultCopyWith<$Res> implements $AlgoliaResultCopyWith<$Res> {
  factory _$AlgoliaResultCopyWith(_AlgoliaResult value, $Res Function(_AlgoliaResult) _then) = __$AlgoliaResultCopyWithImpl;
@override @useResult
$Res call({
 List<dynamic> hits, int totalHits, int page, int nbPages, int hitsPerPage
});




}
/// @nodoc
class __$AlgoliaResultCopyWithImpl<$Res>
    implements _$AlgoliaResultCopyWith<$Res> {
  __$AlgoliaResultCopyWithImpl(this._self, this._then);

  final _AlgoliaResult _self;
  final $Res Function(_AlgoliaResult) _then;

/// Create a copy of AlgoliaResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? hits = null,Object? totalHits = null,Object? page = null,Object? nbPages = null,Object? hitsPerPage = null,}) {
  return _then(_AlgoliaResult(
hits: null == hits ? _self._hits : hits // ignore: cast_nullable_to_non_nullable
as List<dynamic>,totalHits: null == totalHits ? _self.totalHits : totalHits // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,nbPages: null == nbPages ? _self.nbPages : nbPages // ignore: cast_nullable_to_non_nullable
as int,hitsPerPage: null == hitsPerPage ? _self.hitsPerPage : hitsPerPage // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
