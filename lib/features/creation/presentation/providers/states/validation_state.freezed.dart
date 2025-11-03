// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'validation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ValidationResult {

 String get id; bool get isApproved; String? get rejectionReason; double get confidence; DateTime get timestamp; Map<String, dynamic>? get metadata;
/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationResultCopyWith<ValidationResult> get copyWith => _$ValidationResultCopyWithImpl<ValidationResult>(this as ValidationResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,isApproved,rejectionReason,confidence,timestamp,const DeepCollectionEquality().hash(metadata));

@override
String toString() {
  return 'ValidationResult(id: $id, isApproved: $isApproved, rejectionReason: $rejectionReason, confidence: $confidence, timestamp: $timestamp, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $ValidationResultCopyWith<$Res>  {
  factory $ValidationResultCopyWith(ValidationResult value, $Res Function(ValidationResult) _then) = _$ValidationResultCopyWithImpl;
@useResult
$Res call({
 String id, bool isApproved, String? rejectionReason, double confidence, DateTime timestamp, Map<String, dynamic>? metadata
});




}
/// @nodoc
class _$ValidationResultCopyWithImpl<$Res>
    implements $ValidationResultCopyWith<$Res> {
  _$ValidationResultCopyWithImpl(this._self, this._then);

  final ValidationResult _self;
  final $Res Function(ValidationResult) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? isApproved = null,Object? rejectionReason = freezed,Object? confidence = null,Object? timestamp = null,Object? metadata = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationResult].
extension ValidationResultPatterns on ValidationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationResult value)  $default,){
final _that = this;
switch (_that) {
case _ValidationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationResult value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  bool isApproved,  String? rejectionReason,  double confidence,  DateTime timestamp,  Map<String, dynamic>? metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
return $default(_that.id,_that.isApproved,_that.rejectionReason,_that.confidence,_that.timestamp,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  bool isApproved,  String? rejectionReason,  double confidence,  DateTime timestamp,  Map<String, dynamic>? metadata)  $default,) {final _that = this;
switch (_that) {
case _ValidationResult():
return $default(_that.id,_that.isApproved,_that.rejectionReason,_that.confidence,_that.timestamp,_that.metadata);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  bool isApproved,  String? rejectionReason,  double confidence,  DateTime timestamp,  Map<String, dynamic>? metadata)?  $default,) {final _that = this;
switch (_that) {
case _ValidationResult() when $default != null:
return $default(_that.id,_that.isApproved,_that.rejectionReason,_that.confidence,_that.timestamp,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc


class _ValidationResult extends ValidationResult {
  const _ValidationResult({required this.id, required this.isApproved, this.rejectionReason, required this.confidence, required this.timestamp, final  Map<String, dynamic>? metadata}): _metadata = metadata,super._();
  

@override final  String id;
@override final  bool isApproved;
@override final  String? rejectionReason;
@override final  double confidence;
@override final  DateTime timestamp;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationResultCopyWith<_ValidationResult> get copyWith => __$ValidationResultCopyWithImpl<_ValidationResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationResult&&(identical(other.id, id) || other.id == id)&&(identical(other.isApproved, isApproved) || other.isApproved == isApproved)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}


@override
int get hashCode => Object.hash(runtimeType,id,isApproved,rejectionReason,confidence,timestamp,const DeepCollectionEquality().hash(_metadata));

@override
String toString() {
  return 'ValidationResult(id: $id, isApproved: $isApproved, rejectionReason: $rejectionReason, confidence: $confidence, timestamp: $timestamp, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$ValidationResultCopyWith<$Res> implements $ValidationResultCopyWith<$Res> {
  factory _$ValidationResultCopyWith(_ValidationResult value, $Res Function(_ValidationResult) _then) = __$ValidationResultCopyWithImpl;
@override @useResult
$Res call({
 String id, bool isApproved, String? rejectionReason, double confidence, DateTime timestamp, Map<String, dynamic>? metadata
});




}
/// @nodoc
class __$ValidationResultCopyWithImpl<$Res>
    implements _$ValidationResultCopyWith<$Res> {
  __$ValidationResultCopyWithImpl(this._self, this._then);

  final _ValidationResult _self;
  final $Res Function(_ValidationResult) _then;

/// Create a copy of ValidationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? isApproved = null,Object? rejectionReason = freezed,Object? confidence = null,Object? timestamp = null,Object? metadata = freezed,}) {
  return _then(_ValidationResult(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,isApproved: null == isApproved ? _self.isApproved : isApproved // ignore: cast_nullable_to_non_nullable
as bool,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

/// @nodoc
mixin _$ValidationState {

/// Cache of validation results by ID
 Map<String, ValidationResult> get validationResults;/// Current validation status
 bool get isValidating;/// Current validation message
 String? get validationMessage;/// Current validation failure
 Failure? get validationFailure;/// Vision API results for Box A (for compatibility)
 Map<String, dynamic>? get visionResultA;/// Vision API results for Box B (for compatibility)
 Map<String, dynamic>? get visionResultB;
/// Create a copy of ValidationState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationStateCopyWith<ValidationState> get copyWith => _$ValidationStateCopyWithImpl<ValidationState>(this as ValidationState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationState&&const DeepCollectionEquality().equals(other.validationResults, validationResults)&&(identical(other.isValidating, isValidating) || other.isValidating == isValidating)&&(identical(other.validationMessage, validationMessage) || other.validationMessage == validationMessage)&&(identical(other.validationFailure, validationFailure) || other.validationFailure == validationFailure)&&const DeepCollectionEquality().equals(other.visionResultA, visionResultA)&&const DeepCollectionEquality().equals(other.visionResultB, visionResultB));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(validationResults),isValidating,validationMessage,validationFailure,const DeepCollectionEquality().hash(visionResultA),const DeepCollectionEquality().hash(visionResultB));

@override
String toString() {
  return 'ValidationState(validationResults: $validationResults, isValidating: $isValidating, validationMessage: $validationMessage, validationFailure: $validationFailure, visionResultA: $visionResultA, visionResultB: $visionResultB)';
}


}

/// @nodoc
abstract mixin class $ValidationStateCopyWith<$Res>  {
  factory $ValidationStateCopyWith(ValidationState value, $Res Function(ValidationState) _then) = _$ValidationStateCopyWithImpl;
@useResult
$Res call({
 Map<String, ValidationResult> validationResults, bool isValidating, String? validationMessage, Failure? validationFailure, Map<String, dynamic>? visionResultA, Map<String, dynamic>? visionResultB
});




}
/// @nodoc
class _$ValidationStateCopyWithImpl<$Res>
    implements $ValidationStateCopyWith<$Res> {
  _$ValidationStateCopyWithImpl(this._self, this._then);

  final ValidationState _self;
  final $Res Function(ValidationState) _then;

/// Create a copy of ValidationState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? validationResults = null,Object? isValidating = null,Object? validationMessage = freezed,Object? validationFailure = freezed,Object? visionResultA = freezed,Object? visionResultB = freezed,}) {
  return _then(_self.copyWith(
validationResults: null == validationResults ? _self.validationResults : validationResults // ignore: cast_nullable_to_non_nullable
as Map<String, ValidationResult>,isValidating: null == isValidating ? _self.isValidating : isValidating // ignore: cast_nullable_to_non_nullable
as bool,validationMessage: freezed == validationMessage ? _self.validationMessage : validationMessage // ignore: cast_nullable_to_non_nullable
as String?,validationFailure: freezed == validationFailure ? _self.validationFailure : validationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,visionResultA: freezed == visionResultA ? _self.visionResultA : visionResultA // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,visionResultB: freezed == visionResultB ? _self.visionResultB : visionResultB // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [ValidationState].
extension ValidationStatePatterns on ValidationState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ValidationState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ValidationState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ValidationState value)  $default,){
final _that = this;
switch (_that) {
case _ValidationState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ValidationState value)?  $default,){
final _that = this;
switch (_that) {
case _ValidationState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, ValidationResult> validationResults,  bool isValidating,  String? validationMessage,  Failure? validationFailure,  Map<String, dynamic>? visionResultA,  Map<String, dynamic>? visionResultB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ValidationState() when $default != null:
return $default(_that.validationResults,_that.isValidating,_that.validationMessage,_that.validationFailure,_that.visionResultA,_that.visionResultB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, ValidationResult> validationResults,  bool isValidating,  String? validationMessage,  Failure? validationFailure,  Map<String, dynamic>? visionResultA,  Map<String, dynamic>? visionResultB)  $default,) {final _that = this;
switch (_that) {
case _ValidationState():
return $default(_that.validationResults,_that.isValidating,_that.validationMessage,_that.validationFailure,_that.visionResultA,_that.visionResultB);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, ValidationResult> validationResults,  bool isValidating,  String? validationMessage,  Failure? validationFailure,  Map<String, dynamic>? visionResultA,  Map<String, dynamic>? visionResultB)?  $default,) {final _that = this;
switch (_that) {
case _ValidationState() when $default != null:
return $default(_that.validationResults,_that.isValidating,_that.validationMessage,_that.validationFailure,_that.visionResultA,_that.visionResultB);case _:
  return null;

}
}

}

/// @nodoc


class _ValidationState extends ValidationState {
  const _ValidationState({final  Map<String, ValidationResult> validationResults = const {}, this.isValidating = false, this.validationMessage, this.validationFailure, final  Map<String, dynamic>? visionResultA, final  Map<String, dynamic>? visionResultB}): _validationResults = validationResults,_visionResultA = visionResultA,_visionResultB = visionResultB,super._();
  

/// Cache of validation results by ID
 final  Map<String, ValidationResult> _validationResults;
/// Cache of validation results by ID
@override@JsonKey() Map<String, ValidationResult> get validationResults {
  if (_validationResults is EqualUnmodifiableMapView) return _validationResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_validationResults);
}

/// Current validation status
@override@JsonKey() final  bool isValidating;
/// Current validation message
@override final  String? validationMessage;
/// Current validation failure
@override final  Failure? validationFailure;
/// Vision API results for Box A (for compatibility)
 final  Map<String, dynamic>? _visionResultA;
/// Vision API results for Box A (for compatibility)
@override Map<String, dynamic>? get visionResultA {
  final value = _visionResultA;
  if (value == null) return null;
  if (_visionResultA is EqualUnmodifiableMapView) return _visionResultA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

/// Vision API results for Box B (for compatibility)
 final  Map<String, dynamic>? _visionResultB;
/// Vision API results for Box B (for compatibility)
@override Map<String, dynamic>? get visionResultB {
  final value = _visionResultB;
  if (value == null) return null;
  if (_visionResultB is EqualUnmodifiableMapView) return _visionResultB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of ValidationState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ValidationStateCopyWith<_ValidationState> get copyWith => __$ValidationStateCopyWithImpl<_ValidationState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ValidationState&&const DeepCollectionEquality().equals(other._validationResults, _validationResults)&&(identical(other.isValidating, isValidating) || other.isValidating == isValidating)&&(identical(other.validationMessage, validationMessage) || other.validationMessage == validationMessage)&&(identical(other.validationFailure, validationFailure) || other.validationFailure == validationFailure)&&const DeepCollectionEquality().equals(other._visionResultA, _visionResultA)&&const DeepCollectionEquality().equals(other._visionResultB, _visionResultB));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_validationResults),isValidating,validationMessage,validationFailure,const DeepCollectionEquality().hash(_visionResultA),const DeepCollectionEquality().hash(_visionResultB));

@override
String toString() {
  return 'ValidationState(validationResults: $validationResults, isValidating: $isValidating, validationMessage: $validationMessage, validationFailure: $validationFailure, visionResultA: $visionResultA, visionResultB: $visionResultB)';
}


}

/// @nodoc
abstract mixin class _$ValidationStateCopyWith<$Res> implements $ValidationStateCopyWith<$Res> {
  factory _$ValidationStateCopyWith(_ValidationState value, $Res Function(_ValidationState) _then) = __$ValidationStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, ValidationResult> validationResults, bool isValidating, String? validationMessage, Failure? validationFailure, Map<String, dynamic>? visionResultA, Map<String, dynamic>? visionResultB
});




}
/// @nodoc
class __$ValidationStateCopyWithImpl<$Res>
    implements _$ValidationStateCopyWith<$Res> {
  __$ValidationStateCopyWithImpl(this._self, this._then);

  final _ValidationState _self;
  final $Res Function(_ValidationState) _then;

/// Create a copy of ValidationState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? validationResults = null,Object? isValidating = null,Object? validationMessage = freezed,Object? validationFailure = freezed,Object? visionResultA = freezed,Object? visionResultB = freezed,}) {
  return _then(_ValidationState(
validationResults: null == validationResults ? _self._validationResults : validationResults // ignore: cast_nullable_to_non_nullable
as Map<String, ValidationResult>,isValidating: null == isValidating ? _self.isValidating : isValidating // ignore: cast_nullable_to_non_nullable
as bool,validationMessage: freezed == validationMessage ? _self.validationMessage : validationMessage // ignore: cast_nullable_to_non_nullable
as String?,validationFailure: freezed == validationFailure ? _self.validationFailure : validationFailure // ignore: cast_nullable_to_non_nullable
as Failure?,visionResultA: freezed == visionResultA ? _self._visionResultA : visionResultA // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,visionResultB: freezed == visionResultB ? _self._visionResultB : visionResultB // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on
