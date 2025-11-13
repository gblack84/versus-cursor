// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moderation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AIModerationResult {

 bool get isValid; String get severity;// 'pass', 'warning', 'error'
 List<String> get violations; TextModerationResult? get textResult; ImageModerationResult? get imageResult; GeminiModerationResult? get geminiResult; String? get errorMessage;
/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIModerationResultCopyWith<AIModerationResult> get copyWith => _$AIModerationResultCopyWithImpl<AIModerationResult>(this as AIModerationResult, _$identity);

  /// Serializes this AIModerationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIModerationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other.violations, violations)&&(identical(other.textResult, textResult) || other.textResult == textResult)&&(identical(other.imageResult, imageResult) || other.imageResult == imageResult)&&(identical(other.geminiResult, geminiResult) || other.geminiResult == geminiResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,severity,const DeepCollectionEquality().hash(violations),textResult,imageResult,geminiResult,errorMessage);

@override
String toString() {
  return 'AIModerationResult(isValid: $isValid, severity: $severity, violations: $violations, textResult: $textResult, imageResult: $imageResult, geminiResult: $geminiResult, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $AIModerationResultCopyWith<$Res>  {
  factory $AIModerationResultCopyWith(AIModerationResult value, $Res Function(AIModerationResult) _then) = _$AIModerationResultCopyWithImpl;
@useResult
$Res call({
 bool isValid, String severity, List<String> violations, TextModerationResult? textResult, ImageModerationResult? imageResult, GeminiModerationResult? geminiResult, String? errorMessage
});


$TextModerationResultCopyWith<$Res>? get textResult;$ImageModerationResultCopyWith<$Res>? get imageResult;$GeminiModerationResultCopyWith<$Res>? get geminiResult;

}
/// @nodoc
class _$AIModerationResultCopyWithImpl<$Res>
    implements $AIModerationResultCopyWith<$Res> {
  _$AIModerationResultCopyWithImpl(this._self, this._then);

  final AIModerationResult _self;
  final $Res Function(AIModerationResult) _then;

/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? severity = null,Object? violations = null,Object? textResult = freezed,Object? imageResult = freezed,Object? geminiResult = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,violations: null == violations ? _self.violations : violations // ignore: cast_nullable_to_non_nullable
as List<String>,textResult: freezed == textResult ? _self.textResult : textResult // ignore: cast_nullable_to_non_nullable
as TextModerationResult?,imageResult: freezed == imageResult ? _self.imageResult : imageResult // ignore: cast_nullable_to_non_nullable
as ImageModerationResult?,geminiResult: freezed == geminiResult ? _self.geminiResult : geminiResult // ignore: cast_nullable_to_non_nullable
as GeminiModerationResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextModerationResultCopyWith<$Res>? get textResult {
    if (_self.textResult == null) {
    return null;
  }

  return $TextModerationResultCopyWith<$Res>(_self.textResult!, (value) {
    return _then(_self.copyWith(textResult: value));
  });
}/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageModerationResultCopyWith<$Res>? get imageResult {
    if (_self.imageResult == null) {
    return null;
  }

  return $ImageModerationResultCopyWith<$Res>(_self.imageResult!, (value) {
    return _then(_self.copyWith(imageResult: value));
  });
}/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeminiModerationResultCopyWith<$Res>? get geminiResult {
    if (_self.geminiResult == null) {
    return null;
  }

  return $GeminiModerationResultCopyWith<$Res>(_self.geminiResult!, (value) {
    return _then(_self.copyWith(geminiResult: value));
  });
}
}


/// Adds pattern-matching-related methods to [AIModerationResult].
extension AIModerationResultPatterns on AIModerationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AIModerationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AIModerationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AIModerationResult value)  $default,){
final _that = this;
switch (_that) {
case _AIModerationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AIModerationResult value)?  $default,){
final _that = this;
switch (_that) {
case _AIModerationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  String severity,  List<String> violations,  TextModerationResult? textResult,  ImageModerationResult? imageResult,  GeminiModerationResult? geminiResult,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AIModerationResult() when $default != null:
return $default(_that.isValid,_that.severity,_that.violations,_that.textResult,_that.imageResult,_that.geminiResult,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  String severity,  List<String> violations,  TextModerationResult? textResult,  ImageModerationResult? imageResult,  GeminiModerationResult? geminiResult,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _AIModerationResult():
return $default(_that.isValid,_that.severity,_that.violations,_that.textResult,_that.imageResult,_that.geminiResult,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  String severity,  List<String> violations,  TextModerationResult? textResult,  ImageModerationResult? imageResult,  GeminiModerationResult? geminiResult,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _AIModerationResult() when $default != null:
return $default(_that.isValid,_that.severity,_that.violations,_that.textResult,_that.imageResult,_that.geminiResult,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AIModerationResult extends AIModerationResult {
  const _AIModerationResult({required this.isValid, required this.severity, required final  List<String> violations, this.textResult, this.imageResult, this.geminiResult, this.errorMessage}): _violations = violations,super._();
  factory _AIModerationResult.fromJson(Map<String, dynamic> json) => _$AIModerationResultFromJson(json);

@override final  bool isValid;
@override final  String severity;
// 'pass', 'warning', 'error'
 final  List<String> _violations;
// 'pass', 'warning', 'error'
@override List<String> get violations {
  if (_violations is EqualUnmodifiableListView) return _violations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_violations);
}

@override final  TextModerationResult? textResult;
@override final  ImageModerationResult? imageResult;
@override final  GeminiModerationResult? geminiResult;
@override final  String? errorMessage;

/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AIModerationResultCopyWith<_AIModerationResult> get copyWith => __$AIModerationResultCopyWithImpl<_AIModerationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AIModerationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AIModerationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.severity, severity) || other.severity == severity)&&const DeepCollectionEquality().equals(other._violations, _violations)&&(identical(other.textResult, textResult) || other.textResult == textResult)&&(identical(other.imageResult, imageResult) || other.imageResult == imageResult)&&(identical(other.geminiResult, geminiResult) || other.geminiResult == geminiResult)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,severity,const DeepCollectionEquality().hash(_violations),textResult,imageResult,geminiResult,errorMessage);

@override
String toString() {
  return 'AIModerationResult(isValid: $isValid, severity: $severity, violations: $violations, textResult: $textResult, imageResult: $imageResult, geminiResult: $geminiResult, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$AIModerationResultCopyWith<$Res> implements $AIModerationResultCopyWith<$Res> {
  factory _$AIModerationResultCopyWith(_AIModerationResult value, $Res Function(_AIModerationResult) _then) = __$AIModerationResultCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, String severity, List<String> violations, TextModerationResult? textResult, ImageModerationResult? imageResult, GeminiModerationResult? geminiResult, String? errorMessage
});


@override $TextModerationResultCopyWith<$Res>? get textResult;@override $ImageModerationResultCopyWith<$Res>? get imageResult;@override $GeminiModerationResultCopyWith<$Res>? get geminiResult;

}
/// @nodoc
class __$AIModerationResultCopyWithImpl<$Res>
    implements _$AIModerationResultCopyWith<$Res> {
  __$AIModerationResultCopyWithImpl(this._self, this._then);

  final _AIModerationResult _self;
  final $Res Function(_AIModerationResult) _then;

/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? severity = null,Object? violations = null,Object? textResult = freezed,Object? imageResult = freezed,Object? geminiResult = freezed,Object? errorMessage = freezed,}) {
  return _then(_AIModerationResult(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,violations: null == violations ? _self._violations : violations // ignore: cast_nullable_to_non_nullable
as List<String>,textResult: freezed == textResult ? _self.textResult : textResult // ignore: cast_nullable_to_non_nullable
as TextModerationResult?,imageResult: freezed == imageResult ? _self.imageResult : imageResult // ignore: cast_nullable_to_non_nullable
as ImageModerationResult?,geminiResult: freezed == geminiResult ? _self.geminiResult : geminiResult // ignore: cast_nullable_to_non_nullable
as GeminiModerationResult?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TextModerationResultCopyWith<$Res>? get textResult {
    if (_self.textResult == null) {
    return null;
  }

  return $TextModerationResultCopyWith<$Res>(_self.textResult!, (value) {
    return _then(_self.copyWith(textResult: value));
  });
}/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImageModerationResultCopyWith<$Res>? get imageResult {
    if (_self.imageResult == null) {
    return null;
  }

  return $ImageModerationResultCopyWith<$Res>(_self.imageResult!, (value) {
    return _then(_self.copyWith(imageResult: value));
  });
}/// Create a copy of AIModerationResult
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GeminiModerationResultCopyWith<$Res>? get geminiResult {
    if (_self.geminiResult == null) {
    return null;
  }

  return $GeminiModerationResultCopyWith<$Res>(_self.geminiResult!, (value) {
    return _then(_self.copyWith(geminiResult: value));
  });
}
}


/// @nodoc
mixin _$TextModerationResult {

 Map<String, double> get scores; bool get isToxic; String? get detectedCategory; double get confidence;
/// Create a copy of TextModerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TextModerationResultCopyWith<TextModerationResult> get copyWith => _$TextModerationResultCopyWithImpl<TextModerationResult>(this as TextModerationResult, _$identity);

  /// Serializes this TextModerationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TextModerationResult&&const DeepCollectionEquality().equals(other.scores, scores)&&(identical(other.isToxic, isToxic) || other.isToxic == isToxic)&&(identical(other.detectedCategory, detectedCategory) || other.detectedCategory == detectedCategory)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(scores),isToxic,detectedCategory,confidence);

@override
String toString() {
  return 'TextModerationResult(scores: $scores, isToxic: $isToxic, detectedCategory: $detectedCategory, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class $TextModerationResultCopyWith<$Res>  {
  factory $TextModerationResultCopyWith(TextModerationResult value, $Res Function(TextModerationResult) _then) = _$TextModerationResultCopyWithImpl;
@useResult
$Res call({
 Map<String, double> scores, bool isToxic, String? detectedCategory, double confidence
});




}
/// @nodoc
class _$TextModerationResultCopyWithImpl<$Res>
    implements $TextModerationResultCopyWith<$Res> {
  _$TextModerationResultCopyWithImpl(this._self, this._then);

  final TextModerationResult _self;
  final $Res Function(TextModerationResult) _then;

/// Create a copy of TextModerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? scores = null,Object? isToxic = null,Object? detectedCategory = freezed,Object? confidence = null,}) {
  return _then(_self.copyWith(
scores: null == scores ? _self.scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isToxic: null == isToxic ? _self.isToxic : isToxic // ignore: cast_nullable_to_non_nullable
as bool,detectedCategory: freezed == detectedCategory ? _self.detectedCategory : detectedCategory // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [TextModerationResult].
extension TextModerationResultPatterns on TextModerationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TextModerationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TextModerationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TextModerationResult value)  $default,){
final _that = this;
switch (_that) {
case _TextModerationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TextModerationResult value)?  $default,){
final _that = this;
switch (_that) {
case _TextModerationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, double> scores,  bool isToxic,  String? detectedCategory,  double confidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TextModerationResult() when $default != null:
return $default(_that.scores,_that.isToxic,_that.detectedCategory,_that.confidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, double> scores,  bool isToxic,  String? detectedCategory,  double confidence)  $default,) {final _that = this;
switch (_that) {
case _TextModerationResult():
return $default(_that.scores,_that.isToxic,_that.detectedCategory,_that.confidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, double> scores,  bool isToxic,  String? detectedCategory,  double confidence)?  $default,) {final _that = this;
switch (_that) {
case _TextModerationResult() when $default != null:
return $default(_that.scores,_that.isToxic,_that.detectedCategory,_that.confidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TextModerationResult implements TextModerationResult {
  const _TextModerationResult({required final  Map<String, double> scores, required this.isToxic, this.detectedCategory, required this.confidence}): _scores = scores;
  factory _TextModerationResult.fromJson(Map<String, dynamic> json) => _$TextModerationResultFromJson(json);

 final  Map<String, double> _scores;
@override Map<String, double> get scores {
  if (_scores is EqualUnmodifiableMapView) return _scores;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_scores);
}

@override final  bool isToxic;
@override final  String? detectedCategory;
@override final  double confidence;

/// Create a copy of TextModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TextModerationResultCopyWith<_TextModerationResult> get copyWith => __$TextModerationResultCopyWithImpl<_TextModerationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TextModerationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TextModerationResult&&const DeepCollectionEquality().equals(other._scores, _scores)&&(identical(other.isToxic, isToxic) || other.isToxic == isToxic)&&(identical(other.detectedCategory, detectedCategory) || other.detectedCategory == detectedCategory)&&(identical(other.confidence, confidence) || other.confidence == confidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_scores),isToxic,detectedCategory,confidence);

@override
String toString() {
  return 'TextModerationResult(scores: $scores, isToxic: $isToxic, detectedCategory: $detectedCategory, confidence: $confidence)';
}


}

/// @nodoc
abstract mixin class _$TextModerationResultCopyWith<$Res> implements $TextModerationResultCopyWith<$Res> {
  factory _$TextModerationResultCopyWith(_TextModerationResult value, $Res Function(_TextModerationResult) _then) = __$TextModerationResultCopyWithImpl;
@override @useResult
$Res call({
 Map<String, double> scores, bool isToxic, String? detectedCategory, double confidence
});




}
/// @nodoc
class __$TextModerationResultCopyWithImpl<$Res>
    implements _$TextModerationResultCopyWith<$Res> {
  __$TextModerationResultCopyWithImpl(this._self, this._then);

  final _TextModerationResult _self;
  final $Res Function(_TextModerationResult) _then;

/// Create a copy of TextModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? scores = null,Object? isToxic = null,Object? detectedCategory = freezed,Object? confidence = null,}) {
  return _then(_TextModerationResult(
scores: null == scores ? _self._scores : scores // ignore: cast_nullable_to_non_nullable
as Map<String, double>,isToxic: null == isToxic ? _self.isToxic : isToxic // ignore: cast_nullable_to_non_nullable
as bool,detectedCategory: freezed == detectedCategory ? _self.detectedCategory : detectedCategory // ignore: cast_nullable_to_non_nullable
as String?,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ImageModerationResult {

 bool get isAppropriate; String? get reason; Map<String, String> get safeSearchAnnotations; bool get hasText; String? get extractedText;
/// Create a copy of ImageModerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageModerationResultCopyWith<ImageModerationResult> get copyWith => _$ImageModerationResultCopyWithImpl<ImageModerationResult>(this as ImageModerationResult, _$identity);

  /// Serializes this ImageModerationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageModerationResult&&(identical(other.isAppropriate, isAppropriate) || other.isAppropriate == isAppropriate)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other.safeSearchAnnotations, safeSearchAnnotations)&&(identical(other.hasText, hasText) || other.hasText == hasText)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAppropriate,reason,const DeepCollectionEquality().hash(safeSearchAnnotations),hasText,extractedText);

@override
String toString() {
  return 'ImageModerationResult(isAppropriate: $isAppropriate, reason: $reason, safeSearchAnnotations: $safeSearchAnnotations, hasText: $hasText, extractedText: $extractedText)';
}


}

/// @nodoc
abstract mixin class $ImageModerationResultCopyWith<$Res>  {
  factory $ImageModerationResultCopyWith(ImageModerationResult value, $Res Function(ImageModerationResult) _then) = _$ImageModerationResultCopyWithImpl;
@useResult
$Res call({
 bool isAppropriate, String? reason, Map<String, String> safeSearchAnnotations, bool hasText, String? extractedText
});




}
/// @nodoc
class _$ImageModerationResultCopyWithImpl<$Res>
    implements $ImageModerationResultCopyWith<$Res> {
  _$ImageModerationResultCopyWithImpl(this._self, this._then);

  final ImageModerationResult _self;
  final $Res Function(ImageModerationResult) _then;

/// Create a copy of ImageModerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isAppropriate = null,Object? reason = freezed,Object? safeSearchAnnotations = null,Object? hasText = null,Object? extractedText = freezed,}) {
  return _then(_self.copyWith(
isAppropriate: null == isAppropriate ? _self.isAppropriate : isAppropriate // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,safeSearchAnnotations: null == safeSearchAnnotations ? _self.safeSearchAnnotations : safeSearchAnnotations // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasText: null == hasText ? _self.hasText : hasText // ignore: cast_nullable_to_non_nullable
as bool,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageModerationResult].
extension ImageModerationResultPatterns on ImageModerationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageModerationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageModerationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageModerationResult value)  $default,){
final _that = this;
switch (_that) {
case _ImageModerationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageModerationResult value)?  $default,){
final _that = this;
switch (_that) {
case _ImageModerationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isAppropriate,  String? reason,  Map<String, String> safeSearchAnnotations,  bool hasText,  String? extractedText)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageModerationResult() when $default != null:
return $default(_that.isAppropriate,_that.reason,_that.safeSearchAnnotations,_that.hasText,_that.extractedText);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isAppropriate,  String? reason,  Map<String, String> safeSearchAnnotations,  bool hasText,  String? extractedText)  $default,) {final _that = this;
switch (_that) {
case _ImageModerationResult():
return $default(_that.isAppropriate,_that.reason,_that.safeSearchAnnotations,_that.hasText,_that.extractedText);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isAppropriate,  String? reason,  Map<String, String> safeSearchAnnotations,  bool hasText,  String? extractedText)?  $default,) {final _that = this;
switch (_that) {
case _ImageModerationResult() when $default != null:
return $default(_that.isAppropriate,_that.reason,_that.safeSearchAnnotations,_that.hasText,_that.extractedText);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageModerationResult implements ImageModerationResult {
  const _ImageModerationResult({required this.isAppropriate, this.reason, required final  Map<String, String> safeSearchAnnotations, required this.hasText, this.extractedText}): _safeSearchAnnotations = safeSearchAnnotations;
  factory _ImageModerationResult.fromJson(Map<String, dynamic> json) => _$ImageModerationResultFromJson(json);

@override final  bool isAppropriate;
@override final  String? reason;
 final  Map<String, String> _safeSearchAnnotations;
@override Map<String, String> get safeSearchAnnotations {
  if (_safeSearchAnnotations is EqualUnmodifiableMapView) return _safeSearchAnnotations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_safeSearchAnnotations);
}

@override final  bool hasText;
@override final  String? extractedText;

/// Create a copy of ImageModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageModerationResultCopyWith<_ImageModerationResult> get copyWith => __$ImageModerationResultCopyWithImpl<_ImageModerationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageModerationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageModerationResult&&(identical(other.isAppropriate, isAppropriate) || other.isAppropriate == isAppropriate)&&(identical(other.reason, reason) || other.reason == reason)&&const DeepCollectionEquality().equals(other._safeSearchAnnotations, _safeSearchAnnotations)&&(identical(other.hasText, hasText) || other.hasText == hasText)&&(identical(other.extractedText, extractedText) || other.extractedText == extractedText));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isAppropriate,reason,const DeepCollectionEquality().hash(_safeSearchAnnotations),hasText,extractedText);

@override
String toString() {
  return 'ImageModerationResult(isAppropriate: $isAppropriate, reason: $reason, safeSearchAnnotations: $safeSearchAnnotations, hasText: $hasText, extractedText: $extractedText)';
}


}

/// @nodoc
abstract mixin class _$ImageModerationResultCopyWith<$Res> implements $ImageModerationResultCopyWith<$Res> {
  factory _$ImageModerationResultCopyWith(_ImageModerationResult value, $Res Function(_ImageModerationResult) _then) = __$ImageModerationResultCopyWithImpl;
@override @useResult
$Res call({
 bool isAppropriate, String? reason, Map<String, String> safeSearchAnnotations, bool hasText, String? extractedText
});




}
/// @nodoc
class __$ImageModerationResultCopyWithImpl<$Res>
    implements _$ImageModerationResultCopyWith<$Res> {
  __$ImageModerationResultCopyWithImpl(this._self, this._then);

  final _ImageModerationResult _self;
  final $Res Function(_ImageModerationResult) _then;

/// Create a copy of ImageModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isAppropriate = null,Object? reason = freezed,Object? safeSearchAnnotations = null,Object? hasText = null,Object? extractedText = freezed,}) {
  return _then(_ImageModerationResult(
isAppropriate: null == isAppropriate ? _self.isAppropriate : isAppropriate // ignore: cast_nullable_to_non_nullable
as bool,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,safeSearchAnnotations: null == safeSearchAnnotations ? _self._safeSearchAnnotations : safeSearchAnnotations // ignore: cast_nullable_to_non_nullable
as Map<String, String>,hasText: null == hasText ? _self.hasText : hasText // ignore: cast_nullable_to_non_nullable
as bool,extractedText: freezed == extractedText ? _self.extractedText : extractedText // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$GeminiModerationResult {

 bool get isValid; String get reason; String get severity; String get suggestions; double get confidence; String? get documentId; double get expectedRatioA; double get expectedRatioB;
/// Create a copy of GeminiModerationResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GeminiModerationResultCopyWith<GeminiModerationResult> get copyWith => _$GeminiModerationResultCopyWithImpl<GeminiModerationResult>(this as GeminiModerationResult, _$identity);

  /// Serializes this GeminiModerationResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GeminiModerationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.suggestions, suggestions) || other.suggestions == suggestions)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.expectedRatioA, expectedRatioA) || other.expectedRatioA == expectedRatioA)&&(identical(other.expectedRatioB, expectedRatioB) || other.expectedRatioB == expectedRatioB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,reason,severity,suggestions,confidence,documentId,expectedRatioA,expectedRatioB);

@override
String toString() {
  return 'GeminiModerationResult(isValid: $isValid, reason: $reason, severity: $severity, suggestions: $suggestions, confidence: $confidence, documentId: $documentId, expectedRatioA: $expectedRatioA, expectedRatioB: $expectedRatioB)';
}


}

/// @nodoc
abstract mixin class $GeminiModerationResultCopyWith<$Res>  {
  factory $GeminiModerationResultCopyWith(GeminiModerationResult value, $Res Function(GeminiModerationResult) _then) = _$GeminiModerationResultCopyWithImpl;
@useResult
$Res call({
 bool isValid, String reason, String severity, String suggestions, double confidence, String? documentId, double expectedRatioA, double expectedRatioB
});




}
/// @nodoc
class _$GeminiModerationResultCopyWithImpl<$Res>
    implements $GeminiModerationResultCopyWith<$Res> {
  _$GeminiModerationResultCopyWithImpl(this._self, this._then);

  final GeminiModerationResult _self;
  final $Res Function(GeminiModerationResult) _then;

/// Create a copy of GeminiModerationResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isValid = null,Object? reason = null,Object? severity = null,Object? suggestions = null,Object? confidence = null,Object? documentId = freezed,Object? expectedRatioA = null,Object? expectedRatioB = null,}) {
  return _then(_self.copyWith(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,expectedRatioA: null == expectedRatioA ? _self.expectedRatioA : expectedRatioA // ignore: cast_nullable_to_non_nullable
as double,expectedRatioB: null == expectedRatioB ? _self.expectedRatioB : expectedRatioB // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [GeminiModerationResult].
extension GeminiModerationResultPatterns on GeminiModerationResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GeminiModerationResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GeminiModerationResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GeminiModerationResult value)  $default,){
final _that = this;
switch (_that) {
case _GeminiModerationResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GeminiModerationResult value)?  $default,){
final _that = this;
switch (_that) {
case _GeminiModerationResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isValid,  String reason,  String severity,  String suggestions,  double confidence,  String? documentId,  double expectedRatioA,  double expectedRatioB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GeminiModerationResult() when $default != null:
return $default(_that.isValid,_that.reason,_that.severity,_that.suggestions,_that.confidence,_that.documentId,_that.expectedRatioA,_that.expectedRatioB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isValid,  String reason,  String severity,  String suggestions,  double confidence,  String? documentId,  double expectedRatioA,  double expectedRatioB)  $default,) {final _that = this;
switch (_that) {
case _GeminiModerationResult():
return $default(_that.isValid,_that.reason,_that.severity,_that.suggestions,_that.confidence,_that.documentId,_that.expectedRatioA,_that.expectedRatioB);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isValid,  String reason,  String severity,  String suggestions,  double confidence,  String? documentId,  double expectedRatioA,  double expectedRatioB)?  $default,) {final _that = this;
switch (_that) {
case _GeminiModerationResult() when $default != null:
return $default(_that.isValid,_that.reason,_that.severity,_that.suggestions,_that.confidence,_that.documentId,_that.expectedRatioA,_that.expectedRatioB);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GeminiModerationResult implements GeminiModerationResult {
  const _GeminiModerationResult({required this.isValid, required this.reason, required this.severity, required this.suggestions, required this.confidence, this.documentId, this.expectedRatioA = 0.5, this.expectedRatioB = 0.5});
  factory _GeminiModerationResult.fromJson(Map<String, dynamic> json) => _$GeminiModerationResultFromJson(json);

@override final  bool isValid;
@override final  String reason;
@override final  String severity;
@override final  String suggestions;
@override final  double confidence;
@override final  String? documentId;
@override@JsonKey() final  double expectedRatioA;
@override@JsonKey() final  double expectedRatioB;

/// Create a copy of GeminiModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GeminiModerationResultCopyWith<_GeminiModerationResult> get copyWith => __$GeminiModerationResultCopyWithImpl<_GeminiModerationResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GeminiModerationResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GeminiModerationResult&&(identical(other.isValid, isValid) || other.isValid == isValid)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.suggestions, suggestions) || other.suggestions == suggestions)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.expectedRatioA, expectedRatioA) || other.expectedRatioA == expectedRatioA)&&(identical(other.expectedRatioB, expectedRatioB) || other.expectedRatioB == expectedRatioB));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isValid,reason,severity,suggestions,confidence,documentId,expectedRatioA,expectedRatioB);

@override
String toString() {
  return 'GeminiModerationResult(isValid: $isValid, reason: $reason, severity: $severity, suggestions: $suggestions, confidence: $confidence, documentId: $documentId, expectedRatioA: $expectedRatioA, expectedRatioB: $expectedRatioB)';
}


}

/// @nodoc
abstract mixin class _$GeminiModerationResultCopyWith<$Res> implements $GeminiModerationResultCopyWith<$Res> {
  factory _$GeminiModerationResultCopyWith(_GeminiModerationResult value, $Res Function(_GeminiModerationResult) _then) = __$GeminiModerationResultCopyWithImpl;
@override @useResult
$Res call({
 bool isValid, String reason, String severity, String suggestions, double confidence, String? documentId, double expectedRatioA, double expectedRatioB
});




}
/// @nodoc
class __$GeminiModerationResultCopyWithImpl<$Res>
    implements _$GeminiModerationResultCopyWith<$Res> {
  __$GeminiModerationResultCopyWithImpl(this._self, this._then);

  final _GeminiModerationResult _self;
  final $Res Function(_GeminiModerationResult) _then;

/// Create a copy of GeminiModerationResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isValid = null,Object? reason = null,Object? severity = null,Object? suggestions = null,Object? confidence = null,Object? documentId = freezed,Object? expectedRatioA = null,Object? expectedRatioB = null,}) {
  return _then(_GeminiModerationResult(
isValid: null == isValid ? _self.isValid : isValid // ignore: cast_nullable_to_non_nullable
as bool,reason: null == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,suggestions: null == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,expectedRatioA: null == expectedRatioA ? _self.expectedRatioA : expectedRatioA // ignore: cast_nullable_to_non_nullable
as double,expectedRatioB: null == expectedRatioB ? _self.expectedRatioB : expectedRatioB // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ModerationRequest {

 String? get questionTitle; String? get description; String? get titleA; String? get titleB; List<String>? get imageUrlsA; List<String>? get imageUrlsB; Map<String, dynamic>? get visionDataA; Map<String, dynamic>? get visionDataB; String get userId; Map<String, dynamic>? get metadata; String? get sessionId; String? get documentId; int? get revisionCount;
/// Create a copy of ModerationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationRequestCopyWith<ModerationRequest> get copyWith => _$ModerationRequestCopyWithImpl<ModerationRequest>(this as ModerationRequest, _$identity);

  /// Serializes this ModerationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationRequest&&(identical(other.questionTitle, questionTitle) || other.questionTitle == questionTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.titleA, titleA) || other.titleA == titleA)&&(identical(other.titleB, titleB) || other.titleB == titleB)&&const DeepCollectionEquality().equals(other.imageUrlsA, imageUrlsA)&&const DeepCollectionEquality().equals(other.imageUrlsB, imageUrlsB)&&const DeepCollectionEquality().equals(other.visionDataA, visionDataA)&&const DeepCollectionEquality().equals(other.visionDataB, visionDataB)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other.metadata, metadata)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionTitle,description,titleA,titleB,const DeepCollectionEquality().hash(imageUrlsA),const DeepCollectionEquality().hash(imageUrlsB),const DeepCollectionEquality().hash(visionDataA),const DeepCollectionEquality().hash(visionDataB),userId,const DeepCollectionEquality().hash(metadata),sessionId,documentId,revisionCount);

@override
String toString() {
  return 'ModerationRequest(questionTitle: $questionTitle, description: $description, titleA: $titleA, titleB: $titleB, imageUrlsA: $imageUrlsA, imageUrlsB: $imageUrlsB, visionDataA: $visionDataA, visionDataB: $visionDataB, userId: $userId, metadata: $metadata, sessionId: $sessionId, documentId: $documentId, revisionCount: $revisionCount)';
}


}

/// @nodoc
abstract mixin class $ModerationRequestCopyWith<$Res>  {
  factory $ModerationRequestCopyWith(ModerationRequest value, $Res Function(ModerationRequest) _then) = _$ModerationRequestCopyWithImpl;
@useResult
$Res call({
 String? questionTitle, String? description, String? titleA, String? titleB, List<String>? imageUrlsA, List<String>? imageUrlsB, Map<String, dynamic>? visionDataA, Map<String, dynamic>? visionDataB, String userId, Map<String, dynamic>? metadata, String? sessionId, String? documentId, int? revisionCount
});




}
/// @nodoc
class _$ModerationRequestCopyWithImpl<$Res>
    implements $ModerationRequestCopyWith<$Res> {
  _$ModerationRequestCopyWithImpl(this._self, this._then);

  final ModerationRequest _self;
  final $Res Function(ModerationRequest) _then;

/// Create a copy of ModerationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? questionTitle = freezed,Object? description = freezed,Object? titleA = freezed,Object? titleB = freezed,Object? imageUrlsA = freezed,Object? imageUrlsB = freezed,Object? visionDataA = freezed,Object? visionDataB = freezed,Object? userId = null,Object? metadata = freezed,Object? sessionId = freezed,Object? documentId = freezed,Object? revisionCount = freezed,}) {
  return _then(_self.copyWith(
questionTitle: freezed == questionTitle ? _self.questionTitle : questionTitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,titleA: freezed == titleA ? _self.titleA : titleA // ignore: cast_nullable_to_non_nullable
as String?,titleB: freezed == titleB ? _self.titleB : titleB // ignore: cast_nullable_to_non_nullable
as String?,imageUrlsA: freezed == imageUrlsA ? _self.imageUrlsA : imageUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrlsB: freezed == imageUrlsB ? _self.imageUrlsB : imageUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>?,visionDataA: freezed == visionDataA ? _self.visionDataA : visionDataA // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,visionDataB: freezed == visionDataB ? _self.visionDataB : visionDataB // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,revisionCount: freezed == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [ModerationRequest].
extension ModerationRequestPatterns on ModerationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ModerationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ModerationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ModerationRequest value)  $default,){
final _that = this;
switch (_that) {
case _ModerationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ModerationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ModerationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? questionTitle,  String? description,  String? titleA,  String? titleB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  Map<String, dynamic>? visionDataA,  Map<String, dynamic>? visionDataB,  String userId,  Map<String, dynamic>? metadata,  String? sessionId,  String? documentId,  int? revisionCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ModerationRequest() when $default != null:
return $default(_that.questionTitle,_that.description,_that.titleA,_that.titleB,_that.imageUrlsA,_that.imageUrlsB,_that.visionDataA,_that.visionDataB,_that.userId,_that.metadata,_that.sessionId,_that.documentId,_that.revisionCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? questionTitle,  String? description,  String? titleA,  String? titleB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  Map<String, dynamic>? visionDataA,  Map<String, dynamic>? visionDataB,  String userId,  Map<String, dynamic>? metadata,  String? sessionId,  String? documentId,  int? revisionCount)  $default,) {final _that = this;
switch (_that) {
case _ModerationRequest():
return $default(_that.questionTitle,_that.description,_that.titleA,_that.titleB,_that.imageUrlsA,_that.imageUrlsB,_that.visionDataA,_that.visionDataB,_that.userId,_that.metadata,_that.sessionId,_that.documentId,_that.revisionCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? questionTitle,  String? description,  String? titleA,  String? titleB,  List<String>? imageUrlsA,  List<String>? imageUrlsB,  Map<String, dynamic>? visionDataA,  Map<String, dynamic>? visionDataB,  String userId,  Map<String, dynamic>? metadata,  String? sessionId,  String? documentId,  int? revisionCount)?  $default,) {final _that = this;
switch (_that) {
case _ModerationRequest() when $default != null:
return $default(_that.questionTitle,_that.description,_that.titleA,_that.titleB,_that.imageUrlsA,_that.imageUrlsB,_that.visionDataA,_that.visionDataB,_that.userId,_that.metadata,_that.sessionId,_that.documentId,_that.revisionCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ModerationRequest implements ModerationRequest {
  const _ModerationRequest({this.questionTitle, this.description, this.titleA, this.titleB, final  List<String>? imageUrlsA, final  List<String>? imageUrlsB, final  Map<String, dynamic>? visionDataA, final  Map<String, dynamic>? visionDataB, required this.userId, final  Map<String, dynamic>? metadata, this.sessionId, this.documentId, this.revisionCount}): _imageUrlsA = imageUrlsA,_imageUrlsB = imageUrlsB,_visionDataA = visionDataA,_visionDataB = visionDataB,_metadata = metadata;
  factory _ModerationRequest.fromJson(Map<String, dynamic> json) => _$ModerationRequestFromJson(json);

@override final  String? questionTitle;
@override final  String? description;
@override final  String? titleA;
@override final  String? titleB;
 final  List<String>? _imageUrlsA;
@override List<String>? get imageUrlsA {
  final value = _imageUrlsA;
  if (value == null) return null;
  if (_imageUrlsA is EqualUnmodifiableListView) return _imageUrlsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _imageUrlsB;
@override List<String>? get imageUrlsB {
  final value = _imageUrlsB;
  if (value == null) return null;
  if (_imageUrlsB is EqualUnmodifiableListView) return _imageUrlsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  Map<String, dynamic>? _visionDataA;
@override Map<String, dynamic>? get visionDataA {
  final value = _visionDataA;
  if (value == null) return null;
  if (_visionDataA is EqualUnmodifiableMapView) return _visionDataA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, dynamic>? _visionDataB;
@override Map<String, dynamic>? get visionDataB {
  final value = _visionDataB;
  if (value == null) return null;
  if (_visionDataB is EqualUnmodifiableMapView) return _visionDataB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String userId;
 final  Map<String, dynamic>? _metadata;
@override Map<String, dynamic>? get metadata {
  final value = _metadata;
  if (value == null) return null;
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override final  String? sessionId;
@override final  String? documentId;
@override final  int? revisionCount;

/// Create a copy of ModerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ModerationRequestCopyWith<_ModerationRequest> get copyWith => __$ModerationRequestCopyWithImpl<_ModerationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ModerationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ModerationRequest&&(identical(other.questionTitle, questionTitle) || other.questionTitle == questionTitle)&&(identical(other.description, description) || other.description == description)&&(identical(other.titleA, titleA) || other.titleA == titleA)&&(identical(other.titleB, titleB) || other.titleB == titleB)&&const DeepCollectionEquality().equals(other._imageUrlsA, _imageUrlsA)&&const DeepCollectionEquality().equals(other._imageUrlsB, _imageUrlsB)&&const DeepCollectionEquality().equals(other._visionDataA, _visionDataA)&&const DeepCollectionEquality().equals(other._visionDataB, _visionDataB)&&(identical(other.userId, userId) || other.userId == userId)&&const DeepCollectionEquality().equals(other._metadata, _metadata)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.documentId, documentId) || other.documentId == documentId)&&(identical(other.revisionCount, revisionCount) || other.revisionCount == revisionCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,questionTitle,description,titleA,titleB,const DeepCollectionEquality().hash(_imageUrlsA),const DeepCollectionEquality().hash(_imageUrlsB),const DeepCollectionEquality().hash(_visionDataA),const DeepCollectionEquality().hash(_visionDataB),userId,const DeepCollectionEquality().hash(_metadata),sessionId,documentId,revisionCount);

@override
String toString() {
  return 'ModerationRequest(questionTitle: $questionTitle, description: $description, titleA: $titleA, titleB: $titleB, imageUrlsA: $imageUrlsA, imageUrlsB: $imageUrlsB, visionDataA: $visionDataA, visionDataB: $visionDataB, userId: $userId, metadata: $metadata, sessionId: $sessionId, documentId: $documentId, revisionCount: $revisionCount)';
}


}

/// @nodoc
abstract mixin class _$ModerationRequestCopyWith<$Res> implements $ModerationRequestCopyWith<$Res> {
  factory _$ModerationRequestCopyWith(_ModerationRequest value, $Res Function(_ModerationRequest) _then) = __$ModerationRequestCopyWithImpl;
@override @useResult
$Res call({
 String? questionTitle, String? description, String? titleA, String? titleB, List<String>? imageUrlsA, List<String>? imageUrlsB, Map<String, dynamic>? visionDataA, Map<String, dynamic>? visionDataB, String userId, Map<String, dynamic>? metadata, String? sessionId, String? documentId, int? revisionCount
});




}
/// @nodoc
class __$ModerationRequestCopyWithImpl<$Res>
    implements _$ModerationRequestCopyWith<$Res> {
  __$ModerationRequestCopyWithImpl(this._self, this._then);

  final _ModerationRequest _self;
  final $Res Function(_ModerationRequest) _then;

/// Create a copy of ModerationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? questionTitle = freezed,Object? description = freezed,Object? titleA = freezed,Object? titleB = freezed,Object? imageUrlsA = freezed,Object? imageUrlsB = freezed,Object? visionDataA = freezed,Object? visionDataB = freezed,Object? userId = null,Object? metadata = freezed,Object? sessionId = freezed,Object? documentId = freezed,Object? revisionCount = freezed,}) {
  return _then(_ModerationRequest(
questionTitle: freezed == questionTitle ? _self.questionTitle : questionTitle // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,titleA: freezed == titleA ? _self.titleA : titleA // ignore: cast_nullable_to_non_nullable
as String?,titleB: freezed == titleB ? _self.titleB : titleB // ignore: cast_nullable_to_non_nullable
as String?,imageUrlsA: freezed == imageUrlsA ? _self._imageUrlsA : imageUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>?,imageUrlsB: freezed == imageUrlsB ? _self._imageUrlsB : imageUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>?,visionDataA: freezed == visionDataA ? _self._visionDataA : visionDataA // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,visionDataB: freezed == visionDataB ? _self._visionDataB : visionDataB // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,metadata: freezed == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,sessionId: freezed == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String?,documentId: freezed == documentId ? _self.documentId : documentId // ignore: cast_nullable_to_non_nullable
as String?,revisionCount: freezed == revisionCount ? _self.revisionCount : revisionCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
