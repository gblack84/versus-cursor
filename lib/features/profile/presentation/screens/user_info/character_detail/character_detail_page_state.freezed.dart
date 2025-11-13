// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'character_detail_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CharacterDetailPageState implements DiagnosticableTreeMixin {

/// Selected character ID
 String? get selectedCharacterId;/// Selected character profile image URL
 String get selectedCharacterUrl;/// Upload progress flag for profile image
 bool get isDataUploading;/// Uploaded local file (profile image)
 AppUploadedFile? get uploadedLocalFile;/// Uploaded file URL (Firebase Storage)
 String get uploadedFileUrl;
/// Create a copy of CharacterDetailPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CharacterDetailPageStateCopyWith<CharacterDetailPageState> get copyWith => _$CharacterDetailPageStateCopyWithImpl<CharacterDetailPageState>(this as CharacterDetailPageState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CharacterDetailPageState'))
    ..add(DiagnosticsProperty('selectedCharacterId', selectedCharacterId))..add(DiagnosticsProperty('selectedCharacterUrl', selectedCharacterUrl))..add(DiagnosticsProperty('isDataUploading', isDataUploading))..add(DiagnosticsProperty('uploadedLocalFile', uploadedLocalFile))..add(DiagnosticsProperty('uploadedFileUrl', uploadedFileUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CharacterDetailPageState&&(identical(other.selectedCharacterId, selectedCharacterId) || other.selectedCharacterId == selectedCharacterId)&&(identical(other.selectedCharacterUrl, selectedCharacterUrl) || other.selectedCharacterUrl == selectedCharacterUrl)&&(identical(other.isDataUploading, isDataUploading) || other.isDataUploading == isDataUploading)&&(identical(other.uploadedLocalFile, uploadedLocalFile) || other.uploadedLocalFile == uploadedLocalFile)&&(identical(other.uploadedFileUrl, uploadedFileUrl) || other.uploadedFileUrl == uploadedFileUrl));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCharacterId,selectedCharacterUrl,isDataUploading,uploadedLocalFile,uploadedFileUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CharacterDetailPageState(selectedCharacterId: $selectedCharacterId, selectedCharacterUrl: $selectedCharacterUrl, isDataUploading: $isDataUploading, uploadedLocalFile: $uploadedLocalFile, uploadedFileUrl: $uploadedFileUrl)';
}


}

/// @nodoc
abstract mixin class $CharacterDetailPageStateCopyWith<$Res>  {
  factory $CharacterDetailPageStateCopyWith(CharacterDetailPageState value, $Res Function(CharacterDetailPageState) _then) = _$CharacterDetailPageStateCopyWithImpl;
@useResult
$Res call({
 String? selectedCharacterId, String selectedCharacterUrl, bool isDataUploading, AppUploadedFile? uploadedLocalFile, String uploadedFileUrl
});




}
/// @nodoc
class _$CharacterDetailPageStateCopyWithImpl<$Res>
    implements $CharacterDetailPageStateCopyWith<$Res> {
  _$CharacterDetailPageStateCopyWithImpl(this._self, this._then);

  final CharacterDetailPageState _self;
  final $Res Function(CharacterDetailPageState) _then;

/// Create a copy of CharacterDetailPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? selectedCharacterId = freezed,Object? selectedCharacterUrl = null,Object? isDataUploading = null,Object? uploadedLocalFile = freezed,Object? uploadedFileUrl = null,}) {
  return _then(_self.copyWith(
selectedCharacterId: freezed == selectedCharacterId ? _self.selectedCharacterId : selectedCharacterId // ignore: cast_nullable_to_non_nullable
as String?,selectedCharacterUrl: null == selectedCharacterUrl ? _self.selectedCharacterUrl : selectedCharacterUrl // ignore: cast_nullable_to_non_nullable
as String,isDataUploading: null == isDataUploading ? _self.isDataUploading : isDataUploading // ignore: cast_nullable_to_non_nullable
as bool,uploadedLocalFile: freezed == uploadedLocalFile ? _self.uploadedLocalFile : uploadedLocalFile // ignore: cast_nullable_to_non_nullable
as AppUploadedFile?,uploadedFileUrl: null == uploadedFileUrl ? _self.uploadedFileUrl : uploadedFileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CharacterDetailPageState].
extension CharacterDetailPageStatePatterns on CharacterDetailPageState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CharacterDetailPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CharacterDetailPageState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CharacterDetailPageState value)  $default,){
final _that = this;
switch (_that) {
case _CharacterDetailPageState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CharacterDetailPageState value)?  $default,){
final _that = this;
switch (_that) {
case _CharacterDetailPageState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? selectedCharacterId,  String selectedCharacterUrl,  bool isDataUploading,  AppUploadedFile? uploadedLocalFile,  String uploadedFileUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CharacterDetailPageState() when $default != null:
return $default(_that.selectedCharacterId,_that.selectedCharacterUrl,_that.isDataUploading,_that.uploadedLocalFile,_that.uploadedFileUrl);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? selectedCharacterId,  String selectedCharacterUrl,  bool isDataUploading,  AppUploadedFile? uploadedLocalFile,  String uploadedFileUrl)  $default,) {final _that = this;
switch (_that) {
case _CharacterDetailPageState():
return $default(_that.selectedCharacterId,_that.selectedCharacterUrl,_that.isDataUploading,_that.uploadedLocalFile,_that.uploadedFileUrl);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? selectedCharacterId,  String selectedCharacterUrl,  bool isDataUploading,  AppUploadedFile? uploadedLocalFile,  String uploadedFileUrl)?  $default,) {final _that = this;
switch (_that) {
case _CharacterDetailPageState() when $default != null:
return $default(_that.selectedCharacterId,_that.selectedCharacterUrl,_that.isDataUploading,_that.uploadedLocalFile,_that.uploadedFileUrl);case _:
  return null;

}
}

}

/// @nodoc


class _CharacterDetailPageState extends CharacterDetailPageState with DiagnosticableTreeMixin {
  const _CharacterDetailPageState({this.selectedCharacterId, this.selectedCharacterUrl = '\" \"', this.isDataUploading = false, this.uploadedLocalFile, this.uploadedFileUrl = ''}): super._();
  

/// Selected character ID
@override final  String? selectedCharacterId;
/// Selected character profile image URL
@override@JsonKey() final  String selectedCharacterUrl;
/// Upload progress flag for profile image
@override@JsonKey() final  bool isDataUploading;
/// Uploaded local file (profile image)
@override final  AppUploadedFile? uploadedLocalFile;
/// Uploaded file URL (Firebase Storage)
@override@JsonKey() final  String uploadedFileUrl;

/// Create a copy of CharacterDetailPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CharacterDetailPageStateCopyWith<_CharacterDetailPageState> get copyWith => __$CharacterDetailPageStateCopyWithImpl<_CharacterDetailPageState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'CharacterDetailPageState'))
    ..add(DiagnosticsProperty('selectedCharacterId', selectedCharacterId))..add(DiagnosticsProperty('selectedCharacterUrl', selectedCharacterUrl))..add(DiagnosticsProperty('isDataUploading', isDataUploading))..add(DiagnosticsProperty('uploadedLocalFile', uploadedLocalFile))..add(DiagnosticsProperty('uploadedFileUrl', uploadedFileUrl));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CharacterDetailPageState&&(identical(other.selectedCharacterId, selectedCharacterId) || other.selectedCharacterId == selectedCharacterId)&&(identical(other.selectedCharacterUrl, selectedCharacterUrl) || other.selectedCharacterUrl == selectedCharacterUrl)&&(identical(other.isDataUploading, isDataUploading) || other.isDataUploading == isDataUploading)&&(identical(other.uploadedLocalFile, uploadedLocalFile) || other.uploadedLocalFile == uploadedLocalFile)&&(identical(other.uploadedFileUrl, uploadedFileUrl) || other.uploadedFileUrl == uploadedFileUrl));
}


@override
int get hashCode => Object.hash(runtimeType,selectedCharacterId,selectedCharacterUrl,isDataUploading,uploadedLocalFile,uploadedFileUrl);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'CharacterDetailPageState(selectedCharacterId: $selectedCharacterId, selectedCharacterUrl: $selectedCharacterUrl, isDataUploading: $isDataUploading, uploadedLocalFile: $uploadedLocalFile, uploadedFileUrl: $uploadedFileUrl)';
}


}

/// @nodoc
abstract mixin class _$CharacterDetailPageStateCopyWith<$Res> implements $CharacterDetailPageStateCopyWith<$Res> {
  factory _$CharacterDetailPageStateCopyWith(_CharacterDetailPageState value, $Res Function(_CharacterDetailPageState) _then) = __$CharacterDetailPageStateCopyWithImpl;
@override @useResult
$Res call({
 String? selectedCharacterId, String selectedCharacterUrl, bool isDataUploading, AppUploadedFile? uploadedLocalFile, String uploadedFileUrl
});




}
/// @nodoc
class __$CharacterDetailPageStateCopyWithImpl<$Res>
    implements _$CharacterDetailPageStateCopyWith<$Res> {
  __$CharacterDetailPageStateCopyWithImpl(this._self, this._then);

  final _CharacterDetailPageState _self;
  final $Res Function(_CharacterDetailPageState) _then;

/// Create a copy of CharacterDetailPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? selectedCharacterId = freezed,Object? selectedCharacterUrl = null,Object? isDataUploading = null,Object? uploadedLocalFile = freezed,Object? uploadedFileUrl = null,}) {
  return _then(_CharacterDetailPageState(
selectedCharacterId: freezed == selectedCharacterId ? _self.selectedCharacterId : selectedCharacterId // ignore: cast_nullable_to_non_nullable
as String?,selectedCharacterUrl: null == selectedCharacterUrl ? _self.selectedCharacterUrl : selectedCharacterUrl // ignore: cast_nullable_to_non_nullable
as String,isDataUploading: null == isDataUploading ? _self.isDataUploading : isDataUploading // ignore: cast_nullable_to_non_nullable
as bool,uploadedLocalFile: freezed == uploadedLocalFile ? _self.uploadedLocalFile : uploadedLocalFile // ignore: cast_nullable_to_non_nullable
as AppUploadedFile?,uploadedFileUrl: null == uploadedFileUrl ? _self.uploadedFileUrl : uploadedFileUrl // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
