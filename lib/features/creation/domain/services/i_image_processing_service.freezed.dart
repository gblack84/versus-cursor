// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'i_image_processing_service.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ImageProcessingResult {

 List<File> get approvedFiles; List<double> get approvedRatios; List<String> get approvedAssetIds; Map<String, List<int>> get rejectedReasons; List<int> get rejectedIndices; int get rejectedCount; bool get allRejected;
/// Create a copy of ImageProcessingResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageProcessingResultCopyWith<ImageProcessingResult> get copyWith => _$ImageProcessingResultCopyWithImpl<ImageProcessingResult>(this as ImageProcessingResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageProcessingResult&&const DeepCollectionEquality().equals(other.approvedFiles, approvedFiles)&&const DeepCollectionEquality().equals(other.approvedRatios, approvedRatios)&&const DeepCollectionEquality().equals(other.approvedAssetIds, approvedAssetIds)&&const DeepCollectionEquality().equals(other.rejectedReasons, rejectedReasons)&&const DeepCollectionEquality().equals(other.rejectedIndices, rejectedIndices)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&(identical(other.allRejected, allRejected) || other.allRejected == allRejected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(approvedFiles),const DeepCollectionEquality().hash(approvedRatios),const DeepCollectionEquality().hash(approvedAssetIds),const DeepCollectionEquality().hash(rejectedReasons),const DeepCollectionEquality().hash(rejectedIndices),rejectedCount,allRejected);

@override
String toString() {
  return 'ImageProcessingResult(approvedFiles: $approvedFiles, approvedRatios: $approvedRatios, approvedAssetIds: $approvedAssetIds, rejectedReasons: $rejectedReasons, rejectedIndices: $rejectedIndices, rejectedCount: $rejectedCount, allRejected: $allRejected)';
}


}

/// @nodoc
abstract mixin class $ImageProcessingResultCopyWith<$Res>  {
  factory $ImageProcessingResultCopyWith(ImageProcessingResult value, $Res Function(ImageProcessingResult) _then) = _$ImageProcessingResultCopyWithImpl;
@useResult
$Res call({
 List<File> approvedFiles, List<double> approvedRatios, List<String> approvedAssetIds, Map<String, List<int>> rejectedReasons, List<int> rejectedIndices, int rejectedCount, bool allRejected
});




}
/// @nodoc
class _$ImageProcessingResultCopyWithImpl<$Res>
    implements $ImageProcessingResultCopyWith<$Res> {
  _$ImageProcessingResultCopyWithImpl(this._self, this._then);

  final ImageProcessingResult _self;
  final $Res Function(ImageProcessingResult) _then;

/// Create a copy of ImageProcessingResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? approvedFiles = null,Object? approvedRatios = null,Object? approvedAssetIds = null,Object? rejectedReasons = null,Object? rejectedIndices = null,Object? rejectedCount = null,Object? allRejected = null,}) {
  return _then(_self.copyWith(
approvedFiles: null == approvedFiles ? _self.approvedFiles : approvedFiles // ignore: cast_nullable_to_non_nullable
as List<File>,approvedRatios: null == approvedRatios ? _self.approvedRatios : approvedRatios // ignore: cast_nullable_to_non_nullable
as List<double>,approvedAssetIds: null == approvedAssetIds ? _self.approvedAssetIds : approvedAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,rejectedReasons: null == rejectedReasons ? _self.rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,rejectedIndices: null == rejectedIndices ? _self.rejectedIndices : rejectedIndices // ignore: cast_nullable_to_non_nullable
as List<int>,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,allRejected: null == allRejected ? _self.allRejected : allRejected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageProcessingResult].
extension ImageProcessingResultPatterns on ImageProcessingResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageProcessingResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageProcessingResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageProcessingResult value)  $default,){
final _that = this;
switch (_that) {
case _ImageProcessingResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageProcessingResult value)?  $default,){
final _that = this;
switch (_that) {
case _ImageProcessingResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<File> approvedFiles,  List<double> approvedRatios,  List<String> approvedAssetIds,  Map<String, List<int>> rejectedReasons,  List<int> rejectedIndices,  int rejectedCount,  bool allRejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageProcessingResult() when $default != null:
return $default(_that.approvedFiles,_that.approvedRatios,_that.approvedAssetIds,_that.rejectedReasons,_that.rejectedIndices,_that.rejectedCount,_that.allRejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<File> approvedFiles,  List<double> approvedRatios,  List<String> approvedAssetIds,  Map<String, List<int>> rejectedReasons,  List<int> rejectedIndices,  int rejectedCount,  bool allRejected)  $default,) {final _that = this;
switch (_that) {
case _ImageProcessingResult():
return $default(_that.approvedFiles,_that.approvedRatios,_that.approvedAssetIds,_that.rejectedReasons,_that.rejectedIndices,_that.rejectedCount,_that.allRejected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<File> approvedFiles,  List<double> approvedRatios,  List<String> approvedAssetIds,  Map<String, List<int>> rejectedReasons,  List<int> rejectedIndices,  int rejectedCount,  bool allRejected)?  $default,) {final _that = this;
switch (_that) {
case _ImageProcessingResult() when $default != null:
return $default(_that.approvedFiles,_that.approvedRatios,_that.approvedAssetIds,_that.rejectedReasons,_that.rejectedIndices,_that.rejectedCount,_that.allRejected);case _:
  return null;

}
}

}

/// @nodoc


class _ImageProcessingResult extends ImageProcessingResult {
  const _ImageProcessingResult({required final  List<File> approvedFiles, required final  List<double> approvedRatios, required final  List<String> approvedAssetIds, required final  Map<String, List<int>> rejectedReasons, required final  List<int> rejectedIndices, required this.rejectedCount, required this.allRejected}): _approvedFiles = approvedFiles,_approvedRatios = approvedRatios,_approvedAssetIds = approvedAssetIds,_rejectedReasons = rejectedReasons,_rejectedIndices = rejectedIndices,super._();
  

 final  List<File> _approvedFiles;
@override List<File> get approvedFiles {
  if (_approvedFiles is EqualUnmodifiableListView) return _approvedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvedFiles);
}

 final  List<double> _approvedRatios;
@override List<double> get approvedRatios {
  if (_approvedRatios is EqualUnmodifiableListView) return _approvedRatios;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvedRatios);
}

 final  List<String> _approvedAssetIds;
@override List<String> get approvedAssetIds {
  if (_approvedAssetIds is EqualUnmodifiableListView) return _approvedAssetIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_approvedAssetIds);
}

 final  Map<String, List<int>> _rejectedReasons;
@override Map<String, List<int>> get rejectedReasons {
  if (_rejectedReasons is EqualUnmodifiableMapView) return _rejectedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rejectedReasons);
}

 final  List<int> _rejectedIndices;
@override List<int> get rejectedIndices {
  if (_rejectedIndices is EqualUnmodifiableListView) return _rejectedIndices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectedIndices);
}

@override final  int rejectedCount;
@override final  bool allRejected;

/// Create a copy of ImageProcessingResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageProcessingResultCopyWith<_ImageProcessingResult> get copyWith => __$ImageProcessingResultCopyWithImpl<_ImageProcessingResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageProcessingResult&&const DeepCollectionEquality().equals(other._approvedFiles, _approvedFiles)&&const DeepCollectionEquality().equals(other._approvedRatios, _approvedRatios)&&const DeepCollectionEquality().equals(other._approvedAssetIds, _approvedAssetIds)&&const DeepCollectionEquality().equals(other._rejectedReasons, _rejectedReasons)&&const DeepCollectionEquality().equals(other._rejectedIndices, _rejectedIndices)&&(identical(other.rejectedCount, rejectedCount) || other.rejectedCount == rejectedCount)&&(identical(other.allRejected, allRejected) || other.allRejected == allRejected));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_approvedFiles),const DeepCollectionEquality().hash(_approvedRatios),const DeepCollectionEquality().hash(_approvedAssetIds),const DeepCollectionEquality().hash(_rejectedReasons),const DeepCollectionEquality().hash(_rejectedIndices),rejectedCount,allRejected);

@override
String toString() {
  return 'ImageProcessingResult(approvedFiles: $approvedFiles, approvedRatios: $approvedRatios, approvedAssetIds: $approvedAssetIds, rejectedReasons: $rejectedReasons, rejectedIndices: $rejectedIndices, rejectedCount: $rejectedCount, allRejected: $allRejected)';
}


}

/// @nodoc
abstract mixin class _$ImageProcessingResultCopyWith<$Res> implements $ImageProcessingResultCopyWith<$Res> {
  factory _$ImageProcessingResultCopyWith(_ImageProcessingResult value, $Res Function(_ImageProcessingResult) _then) = __$ImageProcessingResultCopyWithImpl;
@override @useResult
$Res call({
 List<File> approvedFiles, List<double> approvedRatios, List<String> approvedAssetIds, Map<String, List<int>> rejectedReasons, List<int> rejectedIndices, int rejectedCount, bool allRejected
});




}
/// @nodoc
class __$ImageProcessingResultCopyWithImpl<$Res>
    implements _$ImageProcessingResultCopyWith<$Res> {
  __$ImageProcessingResultCopyWithImpl(this._self, this._then);

  final _ImageProcessingResult _self;
  final $Res Function(_ImageProcessingResult) _then;

/// Create a copy of ImageProcessingResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? approvedFiles = null,Object? approvedRatios = null,Object? approvedAssetIds = null,Object? rejectedReasons = null,Object? rejectedIndices = null,Object? rejectedCount = null,Object? allRejected = null,}) {
  return _then(_ImageProcessingResult(
approvedFiles: null == approvedFiles ? _self._approvedFiles : approvedFiles // ignore: cast_nullable_to_non_nullable
as List<File>,approvedRatios: null == approvedRatios ? _self._approvedRatios : approvedRatios // ignore: cast_nullable_to_non_nullable
as List<double>,approvedAssetIds: null == approvedAssetIds ? _self._approvedAssetIds : approvedAssetIds // ignore: cast_nullable_to_non_nullable
as List<String>,rejectedReasons: null == rejectedReasons ? _self._rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as Map<String, List<int>>,rejectedIndices: null == rejectedIndices ? _self._rejectedIndices : rejectedIndices // ignore: cast_nullable_to_non_nullable
as List<int>,rejectedCount: null == rejectedCount ? _self.rejectedCount : rejectedCount // ignore: cast_nullable_to_non_nullable
as int,allRejected: null == allRejected ? _self.allRejected : allRejected // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc
mixin _$SingleImageResult {

 bool get success; File? get file; double? get aspectRatio; String? get assetId; String? get rejectionReason; ModerationResult? get moderationResult;
/// Create a copy of SingleImageResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SingleImageResultCopyWith<SingleImageResult> get copyWith => _$SingleImageResultCopyWithImpl<SingleImageResult>(this as SingleImageResult, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SingleImageResult&&(identical(other.success, success) || other.success == success)&&(identical(other.file, file) || other.file == file)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.moderationResult, moderationResult) || other.moderationResult == moderationResult));
}


@override
int get hashCode => Object.hash(runtimeType,success,file,aspectRatio,assetId,rejectionReason,moderationResult);

@override
String toString() {
  return 'SingleImageResult(success: $success, file: $file, aspectRatio: $aspectRatio, assetId: $assetId, rejectionReason: $rejectionReason, moderationResult: $moderationResult)';
}


}

/// @nodoc
abstract mixin class $SingleImageResultCopyWith<$Res>  {
  factory $SingleImageResultCopyWith(SingleImageResult value, $Res Function(SingleImageResult) _then) = _$SingleImageResultCopyWithImpl;
@useResult
$Res call({
 bool success, File? file, double? aspectRatio, String? assetId, String? rejectionReason, ModerationResult? moderationResult
});




}
/// @nodoc
class _$SingleImageResultCopyWithImpl<$Res>
    implements $SingleImageResultCopyWith<$Res> {
  _$SingleImageResultCopyWithImpl(this._self, this._then);

  final SingleImageResult _self;
  final $Res Function(SingleImageResult) _then;

/// Create a copy of SingleImageResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? success = null,Object? file = freezed,Object? aspectRatio = freezed,Object? assetId = freezed,Object? rejectionReason = freezed,Object? moderationResult = freezed,}) {
  return _then(_self.copyWith(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,moderationResult: freezed == moderationResult ? _self.moderationResult : moderationResult // ignore: cast_nullable_to_non_nullable
as ModerationResult?,
  ));
}

}


/// Adds pattern-matching-related methods to [SingleImageResult].
extension SingleImageResultPatterns on SingleImageResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SingleImageResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SingleImageResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SingleImageResult value)  $default,){
final _that = this;
switch (_that) {
case _SingleImageResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SingleImageResult value)?  $default,){
final _that = this;
switch (_that) {
case _SingleImageResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool success,  File? file,  double? aspectRatio,  String? assetId,  String? rejectionReason,  ModerationResult? moderationResult)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SingleImageResult() when $default != null:
return $default(_that.success,_that.file,_that.aspectRatio,_that.assetId,_that.rejectionReason,_that.moderationResult);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool success,  File? file,  double? aspectRatio,  String? assetId,  String? rejectionReason,  ModerationResult? moderationResult)  $default,) {final _that = this;
switch (_that) {
case _SingleImageResult():
return $default(_that.success,_that.file,_that.aspectRatio,_that.assetId,_that.rejectionReason,_that.moderationResult);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool success,  File? file,  double? aspectRatio,  String? assetId,  String? rejectionReason,  ModerationResult? moderationResult)?  $default,) {final _that = this;
switch (_that) {
case _SingleImageResult() when $default != null:
return $default(_that.success,_that.file,_that.aspectRatio,_that.assetId,_that.rejectionReason,_that.moderationResult);case _:
  return null;

}
}

}

/// @nodoc


class _SingleImageResult extends SingleImageResult {
  const _SingleImageResult({required this.success, this.file, this.aspectRatio, this.assetId, this.rejectionReason, this.moderationResult}): super._();
  

@override final  bool success;
@override final  File? file;
@override final  double? aspectRatio;
@override final  String? assetId;
@override final  String? rejectionReason;
@override final  ModerationResult? moderationResult;

/// Create a copy of SingleImageResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SingleImageResultCopyWith<_SingleImageResult> get copyWith => __$SingleImageResultCopyWithImpl<_SingleImageResult>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SingleImageResult&&(identical(other.success, success) || other.success == success)&&(identical(other.file, file) || other.file == file)&&(identical(other.aspectRatio, aspectRatio) || other.aspectRatio == aspectRatio)&&(identical(other.assetId, assetId) || other.assetId == assetId)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.moderationResult, moderationResult) || other.moderationResult == moderationResult));
}


@override
int get hashCode => Object.hash(runtimeType,success,file,aspectRatio,assetId,rejectionReason,moderationResult);

@override
String toString() {
  return 'SingleImageResult(success: $success, file: $file, aspectRatio: $aspectRatio, assetId: $assetId, rejectionReason: $rejectionReason, moderationResult: $moderationResult)';
}


}

/// @nodoc
abstract mixin class _$SingleImageResultCopyWith<$Res> implements $SingleImageResultCopyWith<$Res> {
  factory _$SingleImageResultCopyWith(_SingleImageResult value, $Res Function(_SingleImageResult) _then) = __$SingleImageResultCopyWithImpl;
@override @useResult
$Res call({
 bool success, File? file, double? aspectRatio, String? assetId, String? rejectionReason, ModerationResult? moderationResult
});




}
/// @nodoc
class __$SingleImageResultCopyWithImpl<$Res>
    implements _$SingleImageResultCopyWith<$Res> {
  __$SingleImageResultCopyWithImpl(this._self, this._then);

  final _SingleImageResult _self;
  final $Res Function(_SingleImageResult) _then;

/// Create a copy of SingleImageResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? success = null,Object? file = freezed,Object? aspectRatio = freezed,Object? assetId = freezed,Object? rejectionReason = freezed,Object? moderationResult = freezed,}) {
  return _then(_SingleImageResult(
success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as File?,aspectRatio: freezed == aspectRatio ? _self.aspectRatio : aspectRatio // ignore: cast_nullable_to_non_nullable
as double?,assetId: freezed == assetId ? _self.assetId : assetId // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,moderationResult: freezed == moderationResult ? _self.moderationResult : moderationResult // ignore: cast_nullable_to_non_nullable
as ModerationResult?,
  ));
}


}

// dart format on
