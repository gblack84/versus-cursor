// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moderate_content_usecase.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ModerationDecision {

 bool get isApproved; String? get reason; double get confidence; List<String> get detectedCategories;// Step 5: AI 검열 카테고리
 Map<String, dynamic>? get metadata;
/// Create a copy of ModerationDecision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationDecisionCopyWith<ModerationDecision> get copyWith => _$ModerationDecisionCopyWithImpl<ModerationDecision>(this as ModerationDecision, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationDecision&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other.detectedCategories, detectedCategories)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,isApproved,reason,confidence,const DeepCollectionEquality().hash(detectedCategories),const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ModerationDecision(isApproved: $isApproved, reason: $reason, confidence: $confidence, detectedCategories: $detectedCategories, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ModerationDecisionCopyWith<$Res>  {
  factory $ModerationDecisionCopyWith(ModerationDecision value, $Res Function(ModerationDecision) _then) = _$ModerationDecisionCopyWithImpl;
@useResult
$Res call({
 bool isApproved, String? reason, double confidence, List<String> detectedCategories, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ModerationDecisionCopyWithImpl<$Res>
    implements $ModerationDecisionCopyWith<$Res> {
  _$ModerationDecisionCopyWithImpl(this._self, this._then);

  final ModerationDecision _self;
  final $Res Function(ModerationDecision) _then;

/// Create a copy of ModerationDecision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isApproved = null,Object? reason = freezed,Object? confidence = null,Object? detectedCategories = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detectedCategories: null == detectedCategories ? _self.detectedCategories : detectedCategories // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationDecision].
extension ModerationDecisionPatterns on ModerationDecision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationDecision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationDecision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationDecision value)  $default,){
final _that = this;
switch (_that) {
case _ModerationDecision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationDecision value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationDecision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isApproved,  String? reason,  double confidence,  List<String> detectedCategories,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationDecision() when $default != null:
return $default(_that.isApproved,_that.reason,_that.confidence,_that.detectedCategories,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isApproved,  String? reason,  double confidence,  List<String> detectedCategories,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ModerationDecision():
return $default(_that.isApproved,_that.reason,_that.confidence,_that.detectedCategories,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isApproved,  String? reason,  double confidence,  List<String> detectedCategories,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ModerationDecision() when $default != null:
return $default(_that.isApproved,_that.reason,_that.confidence,_that.detectedCategories,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _ModerationDecision extends ModerationDecision {
  const _ModerationDecision({required this.isApproved, this.reason, required this.confidence, final  List<String> detectedCategories = const [], final  Map<String, dynamic>? metadata}): _detectedCategories = detectedCategories,_metadata = metadata,super._();
  

@override final  bool isApproved;
@override final  String? reason;
@override final  double confidence;
 final  List<String> _detectedCategories;
@override@JsonKey() List<String> get detectedCategories {
  if (_detectedCategories is EqualUnmodifiableListView) return _detectedCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detectedCategories);
}

// Step 5: AI 검열 카테고리
 final  Map<String, dynamic>? _metadata;
// Step 5: AI 검열 카테고리
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ModerationDecision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationDecisionCopyWith<_ModerationDecision> get copyWith => __$ModerationDecisionCopyWithImpl<_ModerationDecision>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationDecision&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&const DeepCollectionEquality().equals(other._detectedCategories, _detectedCategories)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,isApproved,reason,confidence,const DeepCollectionEquality().hash(_detectedCategories),const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ModerationDecision(isApproved: $isApproved, reason: $reason, confidence: $confidence, detectedCategories: $detectedCategories, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ModerationDecisionCopyWith<$Res> implements $ModerationDecisionCopyWith<$Res> {
  factory _$ModerationDecisionCopyWith(_ModerationDecision value, $Res Function(_ModerationDecision) _then) = __$ModerationDecisionCopyWithImpl;
@override @useResult
$Res call({
 bool isApproved, String? reason, double confidence, List<String> detectedCategories, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ModerationDecisionCopyWithImpl<$Res>
    implements _$ModerationDecisionCopyWith<$Res> {
  __$ModerationDecisionCopyWithImpl(this._self, this._then);

  final _ModerationDecision _self;
  final $Res Function(_ModerationDecision) _then;

/// Create a copy of ModerationDecision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isApproved = null,Object? reason = freezed,Object? confidence = null,Object? detectedCategories = null,Object? metadata = freezed,}) {
  return _then(_ModerationDecision(
isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,detectedCategories: null == detectedCategories ? _self._detectedCategories : detectedCategories // ignore: cast_nullable_to_non_nullable
as List<String>,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
