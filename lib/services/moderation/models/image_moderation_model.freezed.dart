// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_moderation_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImageModerationModel {

 String? get id; String? get imageUrl; String? get downloadUrl; String? get filePath; String? get userId; String? get moderationStatus; SafeSearchResults? get safeSearchResults; DateTime? get moderatedAt; String? get blurredUrl; String? get action; String? get error; List<LabelAnnotation> get labels; String? get detectedText; List<LogoAnnotation> get logos; List<LocalizedObject> get objects; List<ColorInfo> get dominantColors; List<FaceAnnotation> get faces;
/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageModerationModelCopyWith<ImageModerationModel> get copyWith => _$ImageModerationModelCopyWithImpl<ImageModerationModel>(this as ImageModerationModel, _$identity);

  /// Serializes this ImageModerationModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageModerationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.safeSearchResults, safeSearchResults) || other.safeSearchResults == safeSearchResults)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt)&&(identical(other.blurredUrl, blurredUrl) || other.blurredUrl == blurredUrl)&&(identical(other.action, action) || other.action == action)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.labels, labels)&&(identical(other.detectedText, detectedText) || other.detectedText == detectedText)&&const DeepCollectionEquality().equals(other.logos, logos)&&const DeepCollectionEquality().equals(other.objects, objects)&&const DeepCollectionEquality().equals(other.dominantColors, dominantColors)&&const DeepCollectionEquality().equals(other.faces, faces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,downloadUrl,filePath,userId,moderationStatus,safeSearchResults,moderatedAt,blurredUrl,action,error,const DeepCollectionEquality().hash(labels),detectedText,const DeepCollectionEquality().hash(logos),const DeepCollectionEquality().hash(objects),const DeepCollectionEquality().hash(dominantColors),const DeepCollectionEquality().hash(faces));

@override
String toString() {
  return 'ImageModerationModel(id: $id, imageUrl: $imageUrl, downloadUrl: $downloadUrl, filePath: $filePath, userId: $userId, moderationStatus: $moderationStatus, safeSearchResults: $safeSearchResults, moderatedAt: $moderatedAt, blurredUrl: $blurredUrl, action: $action, error: $error, labels: $labels, detectedText: $detectedText, logos: $logos, objects: $objects, dominantColors: $dominantColors, faces: $faces)';
}


}

/// @nodoc
abstract mixin class $ImageModerationModelCopyWith<$Res>  {
  factory $ImageModerationModelCopyWith(ImageModerationModel value, $Res Function(ImageModerationModel) _then) = _$ImageModerationModelCopyWithImpl;
@useResult
$Res call({
 String? id, String? imageUrl, String? downloadUrl, String? filePath, String? userId, String? moderationStatus, SafeSearchResults? safeSearchResults, DateTime? moderatedAt, String? blurredUrl, String? action, String? error, List<LabelAnnotation> labels, String? detectedText, List<LogoAnnotation> logos, List<LocalizedObject> objects, List<ColorInfo> dominantColors, List<FaceAnnotation> faces
});


$SafeSearchResultsCopyWith<$Res>? get safeSearchResults;

}
/// @nodoc
class _$ImageModerationModelCopyWithImpl<$Res>
    implements $ImageModerationModelCopyWith<$Res> {
  _$ImageModerationModelCopyWithImpl(this._self, this._then);

  final ImageModerationModel _self;
  final $Res Function(ImageModerationModel) _then;

/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? imageUrl = freezed,Object? downloadUrl = freezed,Object? filePath = freezed,Object? userId = freezed,Object? moderationStatus = freezed,Object? safeSearchResults = freezed,Object? moderatedAt = freezed,Object? blurredUrl = freezed,Object? action = freezed,Object? error = freezed,Object? labels = null,Object? detectedText = freezed,Object? logos = null,Object? objects = null,Object? dominantColors = null,Object? faces = null,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,safeSearchResults: freezed == safeSearchResults ? _self.safeSearchResults : safeSearchResults // ignore: cast_nullable_to_non_nullable
as SafeSearchResults?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blurredUrl: freezed == blurredUrl ? _self.blurredUrl : blurredUrl // ignore: cast_nullable_to_non_nullable
as String?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self.labels : labels // ignore: cast_nullable_to_non_nullable
as List<LabelAnnotation>,detectedText: freezed == detectedText ? _self.detectedText : detectedText // ignore: cast_nullable_to_non_nullable
as String?,logos: null == logos ? _self.logos : logos // ignore: cast_nullable_to_non_nullable
as List<LogoAnnotation>,objects: null == objects ? _self.objects : objects // ignore: cast_nullable_to_non_nullable
as List<LocalizedObject>,dominantColors: null == dominantColors ? _self.dominantColors : dominantColors // ignore: cast_nullable_to_non_nullable
as List<ColorInfo>,faces: null == faces ? _self.faces : faces // ignore: cast_nullable_to_non_nullable
as List<FaceAnnotation>,
  ));
}
/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SafeSearchResultsCopyWith<$Res>? get safeSearchResults {
    if (_self.safeSearchResults == null) {
    return null;
  }

  return $SafeSearchResultsCopyWith<$Res>(_self.safeSearchResults!, (value) {
    return _then(_self.copyWith(safeSearchResults: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageModerationModel].
extension ImageModerationModelPatterns on ImageModerationModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageModerationModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageModerationModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageModerationModel value)  $default,){
final _that = this;
switch (_that) {
case _ImageModerationModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageModerationModel value)?  $default,){
final _that = this;
switch (_that) {
case _ImageModerationModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id,  String? imageUrl,  String? downloadUrl,  String? filePath,  String? userId,  String? moderationStatus,  SafeSearchResults? safeSearchResults,  DateTime? moderatedAt,  String? blurredUrl,  String? action,  String? error,  List<LabelAnnotation> labels,  String? detectedText,  List<LogoAnnotation> logos,  List<LocalizedObject> objects,  List<ColorInfo> dominantColors,  List<FaceAnnotation> faces)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageModerationModel() when $default != null:
return $default(_that.id,_that.imageUrl,_that.downloadUrl,_that.filePath,_that.userId,_that.moderationStatus,_that.safeSearchResults,_that.moderatedAt,_that.blurredUrl,_that.action,_that.error,_that.labels,_that.detectedText,_that.logos,_that.objects,_that.dominantColors,_that.faces);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id,  String? imageUrl,  String? downloadUrl,  String? filePath,  String? userId,  String? moderationStatus,  SafeSearchResults? safeSearchResults,  DateTime? moderatedAt,  String? blurredUrl,  String? action,  String? error,  List<LabelAnnotation> labels,  String? detectedText,  List<LogoAnnotation> logos,  List<LocalizedObject> objects,  List<ColorInfo> dominantColors,  List<FaceAnnotation> faces)  $default,) {final _that = this;
switch (_that) {
case _ImageModerationModel():
return $default(_that.id,_that.imageUrl,_that.downloadUrl,_that.filePath,_that.userId,_that.moderationStatus,_that.safeSearchResults,_that.moderatedAt,_that.blurredUrl,_that.action,_that.error,_that.labels,_that.detectedText,_that.logos,_that.objects,_that.dominantColors,_that.faces);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id,  String? imageUrl,  String? downloadUrl,  String? filePath,  String? userId,  String? moderationStatus,  SafeSearchResults? safeSearchResults,  DateTime? moderatedAt,  String? blurredUrl,  String? action,  String? error,  List<LabelAnnotation> labels,  String? detectedText,  List<LogoAnnotation> logos,  List<LocalizedObject> objects,  List<ColorInfo> dominantColors,  List<FaceAnnotation> faces)?  $default,) {final _that = this;
switch (_that) {
case _ImageModerationModel() when $default != null:
return $default(_that.id,_that.imageUrl,_that.downloadUrl,_that.filePath,_that.userId,_that.moderationStatus,_that.safeSearchResults,_that.moderatedAt,_that.blurredUrl,_that.action,_that.error,_that.labels,_that.detectedText,_that.logos,_that.objects,_that.dominantColors,_that.faces);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageModerationModel extends ImageModerationModel {
  const _ImageModerationModel({this.id, this.imageUrl, this.downloadUrl, this.filePath, this.userId, this.moderationStatus, this.safeSearchResults, this.moderatedAt, this.blurredUrl, this.action, this.error, final  List<LabelAnnotation> labels = const [], this.detectedText, final  List<LogoAnnotation> logos = const [], final  List<LocalizedObject> objects = const [], final  List<ColorInfo> dominantColors = const [], final  List<FaceAnnotation> faces = const []}): _labels = labels,_logos = logos,_objects = objects,_dominantColors = dominantColors,_faces = faces,super._();
  factory _ImageModerationModel.fromJson(Map<String, dynamic> json) => _$ImageModerationModelFromJson(json);

@override final  String? id;
@override final  String? imageUrl;
@override final  String? downloadUrl;
@override final  String? filePath;
@override final  String? userId;
@override final  String? moderationStatus;
@override final  SafeSearchResults? safeSearchResults;
@override final  DateTime? moderatedAt;
@override final  String? blurredUrl;
@override final  String? action;
@override final  String? error;
 final  List<LabelAnnotation> _labels;
@override@JsonKey() List<LabelAnnotation> get labels {
  if (_labels is EqualUnmodifiableListView) return _labels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_labels);
}

@override final  String? detectedText;
 final  List<LogoAnnotation> _logos;
@override@JsonKey() List<LogoAnnotation> get logos {
  if (_logos is EqualUnmodifiableListView) return _logos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_logos);
}

 final  List<LocalizedObject> _objects;
@override@JsonKey() List<LocalizedObject> get objects {
  if (_objects is EqualUnmodifiableListView) return _objects;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_objects);
}

 final  List<ColorInfo> _dominantColors;
@override@JsonKey() List<ColorInfo> get dominantColors {
  if (_dominantColors is EqualUnmodifiableListView) return _dominantColors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dominantColors);
}

 final  List<FaceAnnotation> _faces;
@override@JsonKey() List<FaceAnnotation> get faces {
  if (_faces is EqualUnmodifiableListView) return _faces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_faces);
}


/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageModerationModelCopyWith<_ImageModerationModel> get copyWith => __$ImageModerationModelCopyWithImpl<_ImageModerationModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageModerationModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageModerationModel&&(identical(other.id, id) || other.id == id)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.downloadUrl, downloadUrl) || other.downloadUrl == downloadUrl)&&(identical(other.filePath, filePath) || other.filePath == filePath)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.safeSearchResults, safeSearchResults) || other.safeSearchResults == safeSearchResults)&&(identical(other.moderatedAt, moderatedAt) || other.moderatedAt == moderatedAt)&&(identical(other.blurredUrl, blurredUrl) || other.blurredUrl == blurredUrl)&&(identical(other.action, action) || other.action == action)&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._labels, _labels)&&(identical(other.detectedText, detectedText) || other.detectedText == detectedText)&&const DeepCollectionEquality().equals(other._logos, _logos)&&const DeepCollectionEquality().equals(other._objects, _objects)&&const DeepCollectionEquality().equals(other._dominantColors, _dominantColors)&&const DeepCollectionEquality().equals(other._faces, _faces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,imageUrl,downloadUrl,filePath,userId,moderationStatus,safeSearchResults,moderatedAt,blurredUrl,action,error,const DeepCollectionEquality().hash(_labels),detectedText,const DeepCollectionEquality().hash(_logos),const DeepCollectionEquality().hash(_objects),const DeepCollectionEquality().hash(_dominantColors),const DeepCollectionEquality().hash(_faces));

@override
String toString() {
  return 'ImageModerationModel(id: $id, imageUrl: $imageUrl, downloadUrl: $downloadUrl, filePath: $filePath, userId: $userId, moderationStatus: $moderationStatus, safeSearchResults: $safeSearchResults, moderatedAt: $moderatedAt, blurredUrl: $blurredUrl, action: $action, error: $error, labels: $labels, detectedText: $detectedText, logos: $logos, objects: $objects, dominantColors: $dominantColors, faces: $faces)';
}


}

/// @nodoc
abstract mixin class _$ImageModerationModelCopyWith<$Res> implements $ImageModerationModelCopyWith<$Res> {
  factory _$ImageModerationModelCopyWith(_ImageModerationModel value, $Res Function(_ImageModerationModel) _then) = __$ImageModerationModelCopyWithImpl;
@override @useResult
$Res call({
 String? id, String? imageUrl, String? downloadUrl, String? filePath, String? userId, String? moderationStatus, SafeSearchResults? safeSearchResults, DateTime? moderatedAt, String? blurredUrl, String? action, String? error, List<LabelAnnotation> labels, String? detectedText, List<LogoAnnotation> logos, List<LocalizedObject> objects, List<ColorInfo> dominantColors, List<FaceAnnotation> faces
});


@override $SafeSearchResultsCopyWith<$Res>? get safeSearchResults;

}
/// @nodoc
class __$ImageModerationModelCopyWithImpl<$Res>
    implements _$ImageModerationModelCopyWith<$Res> {
  __$ImageModerationModelCopyWithImpl(this._self, this._then);

  final _ImageModerationModel _self;
  final $Res Function(_ImageModerationModel) _then;

/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? imageUrl = freezed,Object? downloadUrl = freezed,Object? filePath = freezed,Object? userId = freezed,Object? moderationStatus = freezed,Object? safeSearchResults = freezed,Object? moderatedAt = freezed,Object? blurredUrl = freezed,Object? action = freezed,Object? error = freezed,Object? labels = null,Object? detectedText = freezed,Object? logos = null,Object? objects = null,Object? dominantColors = null,Object? faces = null,}) {
  return _then(_ImageModerationModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,downloadUrl: freezed == downloadUrl ? _self.downloadUrl : downloadUrl // ignore: cast_nullable_to_non_nullable
as String?,filePath: freezed == filePath ? _self.filePath : filePath // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,moderationStatus: freezed == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as String?,safeSearchResults: freezed == safeSearchResults ? _self.safeSearchResults : safeSearchResults // ignore: cast_nullable_to_non_nullable
as SafeSearchResults?,moderatedAt: freezed == moderatedAt ? _self.moderatedAt : moderatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,blurredUrl: freezed == blurredUrl ? _self.blurredUrl : blurredUrl // ignore: cast_nullable_to_non_nullable
as String?,action: freezed == action ? _self.action : action // ignore: cast_nullable_to_non_nullable
as String?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,labels: null == labels ? _self._labels : labels // ignore: cast_nullable_to_non_nullable
as List<LabelAnnotation>,detectedText: freezed == detectedText ? _self.detectedText : detectedText // ignore: cast_nullable_to_non_nullable
as String?,logos: null == logos ? _self._logos : logos // ignore: cast_nullable_to_non_nullable
as List<LogoAnnotation>,objects: null == objects ? _self._objects : objects // ignore: cast_nullable_to_non_nullable
as List<LocalizedObject>,dominantColors: null == dominantColors ? _self._dominantColors : dominantColors // ignore: cast_nullable_to_non_nullable
as List<ColorInfo>,faces: null == faces ? _self._faces : faces // ignore: cast_nullable_to_non_nullable
as List<FaceAnnotation>,
  ));
}

/// Create a copy of ImageModerationModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SafeSearchResultsCopyWith<$Res>? get safeSearchResults {
    if (_self.safeSearchResults == null) {
    return null;
  }

  return $SafeSearchResultsCopyWith<$Res>(_self.safeSearchResults!, (value) {
    return _then(_self.copyWith(safeSearchResults: value));
  });
}
}


/// @nodoc
mixin _$SafeSearchResults {

 String? get adult; String? get spoof; String? get medical; String? get violence; String? get racy;
/// Create a copy of SafeSearchResults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SafeSearchResultsCopyWith<SafeSearchResults> get copyWith => _$SafeSearchResultsCopyWithImpl<SafeSearchResults>(this as SafeSearchResults, _$identity);

  /// Serializes this SafeSearchResults to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SafeSearchResults&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.spoof, spoof) || other.spoof == spoof)&&(identical(other.medical, medical) || other.medical == medical)&&(identical(other.violence, violence) || other.violence == violence)&&(identical(other.racy, racy) || other.racy == racy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,adult,spoof,medical,violence,racy);

@override
String toString() {
  return 'SafeSearchResults(adult: $adult, spoof: $spoof, medical: $medical, violence: $violence, racy: $racy)';
}


}

/// @nodoc
abstract mixin class $SafeSearchResultsCopyWith<$Res>  {
  factory $SafeSearchResultsCopyWith(SafeSearchResults value, $Res Function(SafeSearchResults) _then) = _$SafeSearchResultsCopyWithImpl;
@useResult
$Res call({
 String? adult, String? spoof, String? medical, String? violence, String? racy
});




}
/// @nodoc
class _$SafeSearchResultsCopyWithImpl<$Res>
    implements $SafeSearchResultsCopyWith<$Res> {
  _$SafeSearchResultsCopyWithImpl(this._self, this._then);

  final SafeSearchResults _self;
  final $Res Function(SafeSearchResults) _then;

/// Create a copy of SafeSearchResults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? adult = freezed,Object? spoof = freezed,Object? medical = freezed,Object? violence = freezed,Object? racy = freezed,}) {
  return _then(_self.copyWith(
adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as String?,spoof: freezed == spoof ? _self.spoof : spoof // ignore: cast_nullable_to_non_nullable
as String?,medical: freezed == medical ? _self.medical : medical // ignore: cast_nullable_to_non_nullable
as String?,violence: freezed == violence ? _self.violence : violence // ignore: cast_nullable_to_non_nullable
as String?,racy: freezed == racy ? _self.racy : racy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SafeSearchResults].
extension SafeSearchResultsPatterns on SafeSearchResults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SafeSearchResults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SafeSearchResults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SafeSearchResults value)  $default,){
final _that = this;
switch (_that) {
case _SafeSearchResults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SafeSearchResults value)?  $default,){
final _that = this;
switch (_that) {
case _SafeSearchResults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? adult,  String? spoof,  String? medical,  String? violence,  String? racy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SafeSearchResults() when $default != null:
return $default(_that.adult,_that.spoof,_that.medical,_that.violence,_that.racy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? adult,  String? spoof,  String? medical,  String? violence,  String? racy)  $default,) {final _that = this;
switch (_that) {
case _SafeSearchResults():
return $default(_that.adult,_that.spoof,_that.medical,_that.violence,_that.racy);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? adult,  String? spoof,  String? medical,  String? violence,  String? racy)?  $default,) {final _that = this;
switch (_that) {
case _SafeSearchResults() when $default != null:
return $default(_that.adult,_that.spoof,_that.medical,_that.violence,_that.racy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SafeSearchResults implements SafeSearchResults {
  const _SafeSearchResults({this.adult, this.spoof, this.medical, this.violence, this.racy});
  factory _SafeSearchResults.fromJson(Map<String, dynamic> json) => _$SafeSearchResultsFromJson(json);

@override final  String? adult;
@override final  String? spoof;
@override final  String? medical;
@override final  String? violence;
@override final  String? racy;

/// Create a copy of SafeSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SafeSearchResultsCopyWith<_SafeSearchResults> get copyWith => __$SafeSearchResultsCopyWithImpl<_SafeSearchResults>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SafeSearchResultsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SafeSearchResults&&(identical(other.adult, adult) || other.adult == adult)&&(identical(other.spoof, spoof) || other.spoof == spoof)&&(identical(other.medical, medical) || other.medical == medical)&&(identical(other.violence, violence) || other.violence == violence)&&(identical(other.racy, racy) || other.racy == racy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,adult,spoof,medical,violence,racy);

@override
String toString() {
  return 'SafeSearchResults(adult: $adult, spoof: $spoof, medical: $medical, violence: $violence, racy: $racy)';
}


}

/// @nodoc
abstract mixin class _$SafeSearchResultsCopyWith<$Res> implements $SafeSearchResultsCopyWith<$Res> {
  factory _$SafeSearchResultsCopyWith(_SafeSearchResults value, $Res Function(_SafeSearchResults) _then) = __$SafeSearchResultsCopyWithImpl;
@override @useResult
$Res call({
 String? adult, String? spoof, String? medical, String? violence, String? racy
});




}
/// @nodoc
class __$SafeSearchResultsCopyWithImpl<$Res>
    implements _$SafeSearchResultsCopyWith<$Res> {
  __$SafeSearchResultsCopyWithImpl(this._self, this._then);

  final _SafeSearchResults _self;
  final $Res Function(_SafeSearchResults) _then;

/// Create a copy of SafeSearchResults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? adult = freezed,Object? spoof = freezed,Object? medical = freezed,Object? violence = freezed,Object? racy = freezed,}) {
  return _then(_SafeSearchResults(
adult: freezed == adult ? _self.adult : adult // ignore: cast_nullable_to_non_nullable
as String?,spoof: freezed == spoof ? _self.spoof : spoof // ignore: cast_nullable_to_non_nullable
as String?,medical: freezed == medical ? _self.medical : medical // ignore: cast_nullable_to_non_nullable
as String?,violence: freezed == violence ? _self.violence : violence // ignore: cast_nullable_to_non_nullable
as String?,racy: freezed == racy ? _self.racy : racy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$LabelAnnotation {

 String get description; double get score; double? get topicality;
/// Create a copy of LabelAnnotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LabelAnnotationCopyWith<LabelAnnotation> get copyWith => _$LabelAnnotationCopyWithImpl<LabelAnnotation>(this as LabelAnnotation, _$identity);

  /// Serializes this LabelAnnotation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LabelAnnotation&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score)&&(identical(other.topicality, topicality) || other.topicality == topicality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score,topicality);

@override
String toString() {
  return 'LabelAnnotation(description: $description, score: $score, topicality: $topicality)';
}


}

/// @nodoc
abstract mixin class $LabelAnnotationCopyWith<$Res>  {
  factory $LabelAnnotationCopyWith(LabelAnnotation value, $Res Function(LabelAnnotation) _then) = _$LabelAnnotationCopyWithImpl;
@useResult
$Res call({
 String description, double score, double? topicality
});




}
/// @nodoc
class _$LabelAnnotationCopyWithImpl<$Res>
    implements $LabelAnnotationCopyWith<$Res> {
  _$LabelAnnotationCopyWithImpl(this._self, this._then);

  final LabelAnnotation _self;
  final $Res Function(LabelAnnotation) _then;

/// Create a copy of LabelAnnotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? score = null,Object? topicality = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,topicality: freezed == topicality ? _self.topicality : topicality // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [LabelAnnotation].
extension LabelAnnotationPatterns on LabelAnnotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LabelAnnotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LabelAnnotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LabelAnnotation value)  $default,){
final _that = this;
switch (_that) {
case _LabelAnnotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LabelAnnotation value)?  $default,){
final _that = this;
switch (_that) {
case _LabelAnnotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  double score,  double? topicality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LabelAnnotation() when $default != null:
return $default(_that.description,_that.score,_that.topicality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  double score,  double? topicality)  $default,) {final _that = this;
switch (_that) {
case _LabelAnnotation():
return $default(_that.description,_that.score,_that.topicality);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  double score,  double? topicality)?  $default,) {final _that = this;
switch (_that) {
case _LabelAnnotation() when $default != null:
return $default(_that.description,_that.score,_that.topicality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LabelAnnotation implements LabelAnnotation {
  const _LabelAnnotation({required this.description, required this.score, this.topicality});
  factory _LabelAnnotation.fromJson(Map<String, dynamic> json) => _$LabelAnnotationFromJson(json);

@override final  String description;
@override final  double score;
@override final  double? topicality;

/// Create a copy of LabelAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LabelAnnotationCopyWith<_LabelAnnotation> get copyWith => __$LabelAnnotationCopyWithImpl<_LabelAnnotation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LabelAnnotationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LabelAnnotation&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score)&&(identical(other.topicality, topicality) || other.topicality == topicality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score,topicality);

@override
String toString() {
  return 'LabelAnnotation(description: $description, score: $score, topicality: $topicality)';
}


}

/// @nodoc
abstract mixin class _$LabelAnnotationCopyWith<$Res> implements $LabelAnnotationCopyWith<$Res> {
  factory _$LabelAnnotationCopyWith(_LabelAnnotation value, $Res Function(_LabelAnnotation) _then) = __$LabelAnnotationCopyWithImpl;
@override @useResult
$Res call({
 String description, double score, double? topicality
});




}
/// @nodoc
class __$LabelAnnotationCopyWithImpl<$Res>
    implements _$LabelAnnotationCopyWith<$Res> {
  __$LabelAnnotationCopyWithImpl(this._self, this._then);

  final _LabelAnnotation _self;
  final $Res Function(_LabelAnnotation) _then;

/// Create a copy of LabelAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? score = null,Object? topicality = freezed,}) {
  return _then(_LabelAnnotation(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,topicality: freezed == topicality ? _self.topicality : topicality // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$LogoAnnotation {

 String get description; double get score;
/// Create a copy of LogoAnnotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LogoAnnotationCopyWith<LogoAnnotation> get copyWith => _$LogoAnnotationCopyWithImpl<LogoAnnotation>(this as LogoAnnotation, _$identity);

  /// Serializes this LogoAnnotation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LogoAnnotation&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score);

@override
String toString() {
  return 'LogoAnnotation(description: $description, score: $score)';
}


}

/// @nodoc
abstract mixin class $LogoAnnotationCopyWith<$Res>  {
  factory $LogoAnnotationCopyWith(LogoAnnotation value, $Res Function(LogoAnnotation) _then) = _$LogoAnnotationCopyWithImpl;
@useResult
$Res call({
 String description, double score
});




}
/// @nodoc
class _$LogoAnnotationCopyWithImpl<$Res>
    implements $LogoAnnotationCopyWith<$Res> {
  _$LogoAnnotationCopyWithImpl(this._self, this._then);

  final LogoAnnotation _self;
  final $Res Function(LogoAnnotation) _then;

/// Create a copy of LogoAnnotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? score = null,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [LogoAnnotation].
extension LogoAnnotationPatterns on LogoAnnotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LogoAnnotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LogoAnnotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LogoAnnotation value)  $default,){
final _that = this;
switch (_that) {
case _LogoAnnotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LogoAnnotation value)?  $default,){
final _that = this;
switch (_that) {
case _LogoAnnotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  double score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LogoAnnotation() when $default != null:
return $default(_that.description,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  double score)  $default,) {final _that = this;
switch (_that) {
case _LogoAnnotation():
return $default(_that.description,_that.score);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  double score)?  $default,) {final _that = this;
switch (_that) {
case _LogoAnnotation() when $default != null:
return $default(_that.description,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LogoAnnotation implements LogoAnnotation {
  const _LogoAnnotation({required this.description, required this.score});
  factory _LogoAnnotation.fromJson(Map<String, dynamic> json) => _$LogoAnnotationFromJson(json);

@override final  String description;
@override final  double score;

/// Create a copy of LogoAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LogoAnnotationCopyWith<_LogoAnnotation> get copyWith => __$LogoAnnotationCopyWithImpl<_LogoAnnotation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LogoAnnotationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LogoAnnotation&&(identical(other.description, description) || other.description == description)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,score);

@override
String toString() {
  return 'LogoAnnotation(description: $description, score: $score)';
}


}

/// @nodoc
abstract mixin class _$LogoAnnotationCopyWith<$Res> implements $LogoAnnotationCopyWith<$Res> {
  factory _$LogoAnnotationCopyWith(_LogoAnnotation value, $Res Function(_LogoAnnotation) _then) = __$LogoAnnotationCopyWithImpl;
@override @useResult
$Res call({
 String description, double score
});




}
/// @nodoc
class __$LogoAnnotationCopyWithImpl<$Res>
    implements _$LogoAnnotationCopyWith<$Res> {
  __$LogoAnnotationCopyWithImpl(this._self, this._then);

  final _LogoAnnotation _self;
  final $Res Function(_LogoAnnotation) _then;

/// Create a copy of LogoAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? score = null,}) {
  return _then(_LogoAnnotation(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$LocalizedObject {

 String get name; double get score; Map<String, dynamic>? get boundingPoly;
/// Create a copy of LocalizedObject
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LocalizedObjectCopyWith<LocalizedObject> get copyWith => _$LocalizedObjectCopyWithImpl<LocalizedObject>(this as LocalizedObject, _$identity);

  /// Serializes this LocalizedObject to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LocalizedObject&&(identical(other.name, name) || other.name == name)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other.boundingPoly, boundingPoly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,score,const DeepCollectionEquality().hash(boundingPoly));

@override
String toString() {
  return 'LocalizedObject(name: $name, score: $score, boundingPoly: $boundingPoly)';
}


}

/// @nodoc
abstract mixin class $LocalizedObjectCopyWith<$Res>  {
  factory $LocalizedObjectCopyWith(LocalizedObject value, $Res Function(LocalizedObject) _then) = _$LocalizedObjectCopyWithImpl;
@useResult
$Res call({
 String name, double score, Map<String, dynamic>? boundingPoly
});




}
/// @nodoc
class _$LocalizedObjectCopyWithImpl<$Res>
    implements $LocalizedObjectCopyWith<$Res> {
  _$LocalizedObjectCopyWithImpl(this._self, this._then);

  final LocalizedObject _self;
  final $Res Function(LocalizedObject) _then;

/// Create a copy of LocalizedObject
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? score = null,Object? boundingPoly = freezed,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,boundingPoly: freezed == boundingPoly ? _self.boundingPoly : boundingPoly // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [LocalizedObject].
extension LocalizedObjectPatterns on LocalizedObject {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LocalizedObject value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LocalizedObject() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LocalizedObject value)  $default,){
final _that = this;
switch (_that) {
case _LocalizedObject():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LocalizedObject value)?  $default,){
final _that = this;
switch (_that) {
case _LocalizedObject() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  double score,  Map<String, dynamic>? boundingPoly)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LocalizedObject() when $default != null:
return $default(_that.name,_that.score,_that.boundingPoly);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  double score,  Map<String, dynamic>? boundingPoly)  $default,) {final _that = this;
switch (_that) {
case _LocalizedObject():
return $default(_that.name,_that.score,_that.boundingPoly);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  double score,  Map<String, dynamic>? boundingPoly)?  $default,) {final _that = this;
switch (_that) {
case _LocalizedObject() when $default != null:
return $default(_that.name,_that.score,_that.boundingPoly);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LocalizedObject implements LocalizedObject {
  const _LocalizedObject({required this.name, required this.score, final  Map<String, dynamic>? boundingPoly}): _boundingPoly = boundingPoly;
  factory _LocalizedObject.fromJson(Map<String, dynamic> json) => _$LocalizedObjectFromJson(json);

@override final  String name;
@override final  double score;
 final  Map<String, dynamic>? _boundingPoly;
@override Map<String, dynamic>? get boundingPoly {
  final value = _boundingPoly;
  if (value == null) return null;
  if (_boundingPoly is EqualUnmodifiableMapView) return _boundingPoly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of LocalizedObject
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LocalizedObjectCopyWith<_LocalizedObject> get copyWith => __$LocalizedObjectCopyWithImpl<_LocalizedObject>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LocalizedObjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LocalizedObject&&(identical(other.name, name) || other.name == name)&&(identical(other.score, score) || other.score == score)&&const DeepCollectionEquality().equals(other._boundingPoly, _boundingPoly));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,score,const DeepCollectionEquality().hash(_boundingPoly));

@override
String toString() {
  return 'LocalizedObject(name: $name, score: $score, boundingPoly: $boundingPoly)';
}


}

/// @nodoc
abstract mixin class _$LocalizedObjectCopyWith<$Res> implements $LocalizedObjectCopyWith<$Res> {
  factory _$LocalizedObjectCopyWith(_LocalizedObject value, $Res Function(_LocalizedObject) _then) = __$LocalizedObjectCopyWithImpl;
@override @useResult
$Res call({
 String name, double score, Map<String, dynamic>? boundingPoly
});




}
/// @nodoc
class __$LocalizedObjectCopyWithImpl<$Res>
    implements _$LocalizedObjectCopyWith<$Res> {
  __$LocalizedObjectCopyWithImpl(this._self, this._then);

  final _LocalizedObject _self;
  final $Res Function(_LocalizedObject) _then;

/// Create a copy of LocalizedObject
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? score = null,Object? boundingPoly = freezed,}) {
  return _then(_LocalizedObject(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,boundingPoly: freezed == boundingPoly ? _self._boundingPoly : boundingPoly // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}


/// @nodoc
mixin _$ColorInfo {

 Map<String, dynamic> get color; double get score; double? get pixelFraction;
/// Create a copy of ColorInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ColorInfoCopyWith<ColorInfo> get copyWith => _$ColorInfoCopyWithImpl<ColorInfo>(this as ColorInfo, _$identity);

  /// Serializes this ColorInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ColorInfo&&const DeepCollectionEquality().equals(other.color, color)&&(identical(other.score, score) || other.score == score)&&(identical(other.pixelFraction, pixelFraction) || other.pixelFraction == pixelFraction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(color),score,pixelFraction);

@override
String toString() {
  return 'ColorInfo(color: $color, score: $score, pixelFraction: $pixelFraction)';
}


}

/// @nodoc
abstract mixin class $ColorInfoCopyWith<$Res>  {
  factory $ColorInfoCopyWith(ColorInfo value, $Res Function(ColorInfo) _then) = _$ColorInfoCopyWithImpl;
@useResult
$Res call({
 Map<String, dynamic> color, double score, double? pixelFraction
});




}
/// @nodoc
class _$ColorInfoCopyWithImpl<$Res>
    implements $ColorInfoCopyWith<$Res> {
  _$ColorInfoCopyWithImpl(this._self, this._then);

  final ColorInfo _self;
  final $Res Function(ColorInfo) _then;

/// Create a copy of ColorInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? color = null,Object? score = null,Object? pixelFraction = freezed,}) {
  return _then(_self.copyWith(
color: null == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,pixelFraction: freezed == pixelFraction ? _self.pixelFraction : pixelFraction // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [ColorInfo].
extension ColorInfoPatterns on ColorInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ColorInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ColorInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ColorInfo value)  $default,){
final _that = this;
switch (_that) {
case _ColorInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ColorInfo value)?  $default,){
final _that = this;
switch (_that) {
case _ColorInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, dynamic> color,  double score,  double? pixelFraction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ColorInfo() when $default != null:
return $default(_that.color,_that.score,_that.pixelFraction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, dynamic> color,  double score,  double? pixelFraction)  $default,) {final _that = this;
switch (_that) {
case _ColorInfo():
return $default(_that.color,_that.score,_that.pixelFraction);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, dynamic> color,  double score,  double? pixelFraction)?  $default,) {final _that = this;
switch (_that) {
case _ColorInfo() when $default != null:
return $default(_that.color,_that.score,_that.pixelFraction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ColorInfo implements ColorInfo {
  const _ColorInfo({required final  Map<String, dynamic> color, required this.score, this.pixelFraction}): _color = color;
  factory _ColorInfo.fromJson(Map<String, dynamic> json) => _$ColorInfoFromJson(json);

 final  Map<String, dynamic> _color;
@override Map<String, dynamic> get color {
  if (_color is EqualUnmodifiableMapView) return _color;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_color);
}

@override final  double score;
@override final  double? pixelFraction;

/// Create a copy of ColorInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ColorInfoCopyWith<_ColorInfo> get copyWith => __$ColorInfoCopyWithImpl<_ColorInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ColorInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ColorInfo&&const DeepCollectionEquality().equals(other._color, _color)&&(identical(other.score, score) || other.score == score)&&(identical(other.pixelFraction, pixelFraction) || other.pixelFraction == pixelFraction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_color),score,pixelFraction);

@override
String toString() {
  return 'ColorInfo(color: $color, score: $score, pixelFraction: $pixelFraction)';
}


}

/// @nodoc
abstract mixin class _$ColorInfoCopyWith<$Res> implements $ColorInfoCopyWith<$Res> {
  factory _$ColorInfoCopyWith(_ColorInfo value, $Res Function(_ColorInfo) _then) = __$ColorInfoCopyWithImpl;
@override @useResult
$Res call({
 Map<String, dynamic> color, double score, double? pixelFraction
});




}
/// @nodoc
class __$ColorInfoCopyWithImpl<$Res>
    implements _$ColorInfoCopyWith<$Res> {
  __$ColorInfoCopyWithImpl(this._self, this._then);

  final _ColorInfo _self;
  final $Res Function(_ColorInfo) _then;

/// Create a copy of ColorInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? color = null,Object? score = null,Object? pixelFraction = freezed,}) {
  return _then(_ColorInfo(
color: null == color ? _self._color : color // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,pixelFraction: freezed == pixelFraction ? _self.pixelFraction : pixelFraction // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$FaceAnnotation {

 String? get joyLikelihood; String? get sorrowLikelihood; String? get angerLikelihood; String? get surpriseLikelihood; double? get detectionConfidence;
/// Create a copy of FaceAnnotation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FaceAnnotationCopyWith<FaceAnnotation> get copyWith => _$FaceAnnotationCopyWithImpl<FaceAnnotation>(this as FaceAnnotation, _$identity);

  /// Serializes this FaceAnnotation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FaceAnnotation&&(identical(other.joyLikelihood, joyLikelihood) || other.joyLikelihood == joyLikelihood)&&(identical(other.sorrowLikelihood, sorrowLikelihood) || other.sorrowLikelihood == sorrowLikelihood)&&(identical(other.angerLikelihood, angerLikelihood) || other.angerLikelihood == angerLikelihood)&&(identical(other.surpriseLikelihood, surpriseLikelihood) || other.surpriseLikelihood == surpriseLikelihood)&&(identical(other.detectionConfidence, detectionConfidence) || other.detectionConfidence == detectionConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,joyLikelihood,sorrowLikelihood,angerLikelihood,surpriseLikelihood,detectionConfidence);

@override
String toString() {
  return 'FaceAnnotation(joyLikelihood: $joyLikelihood, sorrowLikelihood: $sorrowLikelihood, angerLikelihood: $angerLikelihood, surpriseLikelihood: $surpriseLikelihood, detectionConfidence: $detectionConfidence)';
}


}

/// @nodoc
abstract mixin class $FaceAnnotationCopyWith<$Res>  {
  factory $FaceAnnotationCopyWith(FaceAnnotation value, $Res Function(FaceAnnotation) _then) = _$FaceAnnotationCopyWithImpl;
@useResult
$Res call({
 String? joyLikelihood, String? sorrowLikelihood, String? angerLikelihood, String? surpriseLikelihood, double? detectionConfidence
});




}
/// @nodoc
class _$FaceAnnotationCopyWithImpl<$Res>
    implements $FaceAnnotationCopyWith<$Res> {
  _$FaceAnnotationCopyWithImpl(this._self, this._then);

  final FaceAnnotation _self;
  final $Res Function(FaceAnnotation) _then;

/// Create a copy of FaceAnnotation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? joyLikelihood = freezed,Object? sorrowLikelihood = freezed,Object? angerLikelihood = freezed,Object? surpriseLikelihood = freezed,Object? detectionConfidence = freezed,}) {
  return _then(_self.copyWith(
joyLikelihood: freezed == joyLikelihood ? _self.joyLikelihood : joyLikelihood // ignore: cast_nullable_to_non_nullable
as String?,sorrowLikelihood: freezed == sorrowLikelihood ? _self.sorrowLikelihood : sorrowLikelihood // ignore: cast_nullable_to_non_nullable
as String?,angerLikelihood: freezed == angerLikelihood ? _self.angerLikelihood : angerLikelihood // ignore: cast_nullable_to_non_nullable
as String?,surpriseLikelihood: freezed == surpriseLikelihood ? _self.surpriseLikelihood : surpriseLikelihood // ignore: cast_nullable_to_non_nullable
as String?,detectionConfidence: freezed == detectionConfidence ? _self.detectionConfidence : detectionConfidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [FaceAnnotation].
extension FaceAnnotationPatterns on FaceAnnotation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FaceAnnotation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FaceAnnotation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FaceAnnotation value)  $default,){
final _that = this;
switch (_that) {
case _FaceAnnotation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FaceAnnotation value)?  $default,){
final _that = this;
switch (_that) {
case _FaceAnnotation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? joyLikelihood,  String? sorrowLikelihood,  String? angerLikelihood,  String? surpriseLikelihood,  double? detectionConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FaceAnnotation() when $default != null:
return $default(_that.joyLikelihood,_that.sorrowLikelihood,_that.angerLikelihood,_that.surpriseLikelihood,_that.detectionConfidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? joyLikelihood,  String? sorrowLikelihood,  String? angerLikelihood,  String? surpriseLikelihood,  double? detectionConfidence)  $default,) {final _that = this;
switch (_that) {
case _FaceAnnotation():
return $default(_that.joyLikelihood,_that.sorrowLikelihood,_that.angerLikelihood,_that.surpriseLikelihood,_that.detectionConfidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? joyLikelihood,  String? sorrowLikelihood,  String? angerLikelihood,  String? surpriseLikelihood,  double? detectionConfidence)?  $default,) {final _that = this;
switch (_that) {
case _FaceAnnotation() when $default != null:
return $default(_that.joyLikelihood,_that.sorrowLikelihood,_that.angerLikelihood,_that.surpriseLikelihood,_that.detectionConfidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FaceAnnotation implements FaceAnnotation {
  const _FaceAnnotation({this.joyLikelihood, this.sorrowLikelihood, this.angerLikelihood, this.surpriseLikelihood, this.detectionConfidence});
  factory _FaceAnnotation.fromJson(Map<String, dynamic> json) => _$FaceAnnotationFromJson(json);

@override final  String? joyLikelihood;
@override final  String? sorrowLikelihood;
@override final  String? angerLikelihood;
@override final  String? surpriseLikelihood;
@override final  double? detectionConfidence;

/// Create a copy of FaceAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FaceAnnotationCopyWith<_FaceAnnotation> get copyWith => __$FaceAnnotationCopyWithImpl<_FaceAnnotation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FaceAnnotationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FaceAnnotation&&(identical(other.joyLikelihood, joyLikelihood) || other.joyLikelihood == joyLikelihood)&&(identical(other.sorrowLikelihood, sorrowLikelihood) || other.sorrowLikelihood == sorrowLikelihood)&&(identical(other.angerLikelihood, angerLikelihood) || other.angerLikelihood == angerLikelihood)&&(identical(other.surpriseLikelihood, surpriseLikelihood) || other.surpriseLikelihood == surpriseLikelihood)&&(identical(other.detectionConfidence, detectionConfidence) || other.detectionConfidence == detectionConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,joyLikelihood,sorrowLikelihood,angerLikelihood,surpriseLikelihood,detectionConfidence);

@override
String toString() {
  return 'FaceAnnotation(joyLikelihood: $joyLikelihood, sorrowLikelihood: $sorrowLikelihood, angerLikelihood: $angerLikelihood, surpriseLikelihood: $surpriseLikelihood, detectionConfidence: $detectionConfidence)';
}


}

/// @nodoc
abstract mixin class _$FaceAnnotationCopyWith<$Res> implements $FaceAnnotationCopyWith<$Res> {
  factory _$FaceAnnotationCopyWith(_FaceAnnotation value, $Res Function(_FaceAnnotation) _then) = __$FaceAnnotationCopyWithImpl;
@override @useResult
$Res call({
 String? joyLikelihood, String? sorrowLikelihood, String? angerLikelihood, String? surpriseLikelihood, double? detectionConfidence
});




}
/// @nodoc
class __$FaceAnnotationCopyWithImpl<$Res>
    implements _$FaceAnnotationCopyWith<$Res> {
  __$FaceAnnotationCopyWithImpl(this._self, this._then);

  final _FaceAnnotation _self;
  final $Res Function(_FaceAnnotation) _then;

/// Create a copy of FaceAnnotation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? joyLikelihood = freezed,Object? sorrowLikelihood = freezed,Object? angerLikelihood = freezed,Object? surpriseLikelihood = freezed,Object? detectionConfidence = freezed,}) {
  return _then(_FaceAnnotation(
joyLikelihood: freezed == joyLikelihood ? _self.joyLikelihood : joyLikelihood // ignore: cast_nullable_to_non_nullable
as String?,sorrowLikelihood: freezed == sorrowLikelihood ? _self.sorrowLikelihood : sorrowLikelihood // ignore: cast_nullable_to_non_nullable
as String?,angerLikelihood: freezed == angerLikelihood ? _self.angerLikelihood : angerLikelihood // ignore: cast_nullable_to_non_nullable
as String?,surpriseLikelihood: freezed == surpriseLikelihood ? _self.surpriseLikelihood : surpriseLikelihood // ignore: cast_nullable_to_non_nullable
as String?,detectionConfidence: freezed == detectionConfidence ? _self.detectionConfidence : detectionConfidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
