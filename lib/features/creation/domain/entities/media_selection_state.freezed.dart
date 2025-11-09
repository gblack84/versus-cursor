// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_selection_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$MediaSelectionState {

// ==================== Option A 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option A)
///
/// **AppState 대체**: `List<String> uploadImageA`
///
/// **사용 예시**:
/// ```dart
/// final urls = ref.watch(mediaSelectionProvider).uploadedUrlsA;
/// ```
 List<String> get uploadedUrlsA;/// 선택된 이미지 파일 목록 (Option A)
///
/// **AppState 대체**: `List<File> tempImageFilesA`
///
/// **사용 예시**:
/// ```dart
/// final files = ref.watch(mediaSelectionProvider).selectedFilesA;
/// ```
 List<File> get selectedFilesA;/// 이미지 가로세로 비율 목록 (Option A)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioA`
///
/// **사용 예시**:
/// ```dart
/// final ratios = ref.watch(mediaSelectionProvider).aspectRatiosA;
/// ```
 List<double> get aspectRatiosA;/// Asset Entity ID 목록 (Option A)
///
/// **AppState 대체**: `List<String> assetEntityIdsA`
///
/// **사용 예시**:
/// ```dart
/// final ids = ref.watch(mediaSelectionProvider).assetEntityIdsA;
/// ```
 List<String> get assetEntityIdsA;/// 로컬 이미지 경로 목록 (Option A)
///
/// **AppState 대체**: `List<String> localImagePathsA`
///
/// **사용 예시**:
/// ```dart
/// final paths = ref.watch(mediaSelectionProvider).localPathsA;
/// ```
 List<String> get localPathsA;/// 업로드 진행 중 여부 (Option A)
///
/// **AppState 대체**: `bool isUploadingA`
///
/// **사용 예시**:
/// ```dart
/// final isUploading = ref.watch(mediaSelectionProvider).isUploadingA;
/// if (isUploading) CircularProgressIndicator();
/// ```
 bool get isUploadingA;// ==================== Option B 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option B)
///
/// **AppState 대체**: `List<String> uploadImageB`
 List<String> get uploadedUrlsB;/// 선택된 이미지 파일 목록 (Option B)
///
/// **AppState 대체**: `List<File> tempImageFilesB`
 List<File> get selectedFilesB;/// 이미지 가로세로 비율 목록 (Option B)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioB`
 List<double> get aspectRatiosB;/// Asset Entity ID 목록 (Option B)
///
/// **AppState 대체**: `List<String> assetEntityIdsB`
 List<String> get assetEntityIdsB;/// 로컬 이미지 경로 목록 (Option B)
///
/// **AppState 대체**: `List<String> localImagePathsB`
 List<String> get localPathsB;/// 업로드 진행 중 여부 (Option B)
///
/// **AppState 대체**: `bool isUploadingB`
 bool get isUploadingB;
/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaSelectionStateCopyWith<MediaSelectionState> get copyWith => _$MediaSelectionStateCopyWithImpl<MediaSelectionState>(this as MediaSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaSelectionState&&const DeepCollectionEquality().equals(other.uploadedUrlsA, uploadedUrlsA)&&const DeepCollectionEquality().equals(other.selectedFilesA, selectedFilesA)&&const DeepCollectionEquality().equals(other.aspectRatiosA, aspectRatiosA)&&const DeepCollectionEquality().equals(other.assetEntityIdsA, assetEntityIdsA)&&const DeepCollectionEquality().equals(other.localPathsA, localPathsA)&&(identical(other.isUploadingA, isUploadingA) || other.isUploadingA == isUploadingA)&&const DeepCollectionEquality().equals(other.uploadedUrlsB, uploadedUrlsB)&&const DeepCollectionEquality().equals(other.selectedFilesB, selectedFilesB)&&const DeepCollectionEquality().equals(other.aspectRatiosB, aspectRatiosB)&&const DeepCollectionEquality().equals(other.assetEntityIdsB, assetEntityIdsB)&&const DeepCollectionEquality().equals(other.localPathsB, localPathsB)&&(identical(other.isUploadingB, isUploadingB) || other.isUploadingB == isUploadingB));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(uploadedUrlsA),const DeepCollectionEquality().hash(selectedFilesA),const DeepCollectionEquality().hash(aspectRatiosA),const DeepCollectionEquality().hash(assetEntityIdsA),const DeepCollectionEquality().hash(localPathsA),isUploadingA,const DeepCollectionEquality().hash(uploadedUrlsB),const DeepCollectionEquality().hash(selectedFilesB),const DeepCollectionEquality().hash(aspectRatiosB),const DeepCollectionEquality().hash(assetEntityIdsB),const DeepCollectionEquality().hash(localPathsB),isUploadingB);

@override
String toString() {
  return 'MediaSelectionState(uploadedUrlsA: $uploadedUrlsA, selectedFilesA: $selectedFilesA, aspectRatiosA: $aspectRatiosA, assetEntityIdsA: $assetEntityIdsA, localPathsA: $localPathsA, isUploadingA: $isUploadingA, uploadedUrlsB: $uploadedUrlsB, selectedFilesB: $selectedFilesB, aspectRatiosB: $aspectRatiosB, assetEntityIdsB: $assetEntityIdsB, localPathsB: $localPathsB, isUploadingB: $isUploadingB)';
}


}

/// @nodoc
abstract mixin class $MediaSelectionStateCopyWith<$Res>  {
  factory $MediaSelectionStateCopyWith(MediaSelectionState value, $Res Function(MediaSelectionState) _then) = _$MediaSelectionStateCopyWithImpl;
@useResult
$Res call({
 List<String> uploadedUrlsA, List<File> selectedFilesA, List<double> aspectRatiosA, List<String> assetEntityIdsA, List<String> localPathsA, bool isUploadingA, List<String> uploadedUrlsB, List<File> selectedFilesB, List<double> aspectRatiosB, List<String> assetEntityIdsB, List<String> localPathsB, bool isUploadingB
});




}
/// @nodoc
class _$MediaSelectionStateCopyWithImpl<$Res>
    implements $MediaSelectionStateCopyWith<$Res> {
  _$MediaSelectionStateCopyWithImpl(this._self, this._then);

  final MediaSelectionState _self;
  final $Res Function(MediaSelectionState) _then;

/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uploadedUrlsA = null,Object? selectedFilesA = null,Object? aspectRatiosA = null,Object? assetEntityIdsA = null,Object? localPathsA = null,Object? isUploadingA = null,Object? uploadedUrlsB = null,Object? selectedFilesB = null,Object? aspectRatiosB = null,Object? assetEntityIdsB = null,Object? localPathsB = null,Object? isUploadingB = null,}) {
  return _then(_self.copyWith(
uploadedUrlsA: null == uploadedUrlsA ? _self.uploadedUrlsA : uploadedUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFilesA: null == selectedFilesA ? _self.selectedFilesA : selectedFilesA // ignore: cast_nullable_to_non_nullable
as List<File>,aspectRatiosA: null == aspectRatiosA ? _self.aspectRatiosA : aspectRatiosA // ignore: cast_nullable_to_non_nullable
as List<double>,assetEntityIdsA: null == assetEntityIdsA ? _self.assetEntityIdsA : assetEntityIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsA: null == localPathsA ? _self.localPathsA : localPathsA // ignore: cast_nullable_to_non_nullable
as List<String>,isUploadingA: null == isUploadingA ? _self.isUploadingA : isUploadingA // ignore: cast_nullable_to_non_nullable
as bool,uploadedUrlsB: null == uploadedUrlsB ? _self.uploadedUrlsB : uploadedUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFilesB: null == selectedFilesB ? _self.selectedFilesB : selectedFilesB // ignore: cast_nullable_to_non_nullable
as List<File>,aspectRatiosB: null == aspectRatiosB ? _self.aspectRatiosB : aspectRatiosB // ignore: cast_nullable_to_non_nullable
as List<double>,assetEntityIdsB: null == assetEntityIdsB ? _self.assetEntityIdsB : assetEntityIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsB: null == localPathsB ? _self.localPathsB : localPathsB // ignore: cast_nullable_to_non_nullable
as List<String>,isUploadingB: null == isUploadingB ? _self.isUploadingB : isUploadingB // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaSelectionState].
extension MediaSelectionStatePatterns on MediaSelectionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaSelectionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaSelectionState value)  $default,){
final _that = this;
switch (_that) {
case _MediaSelectionState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaSelectionState value)?  $default,){
final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> uploadedUrlsA,  List<File> selectedFilesA,  List<double> aspectRatiosA,  List<String> assetEntityIdsA,  List<String> localPathsA,  bool isUploadingA,  List<String> uploadedUrlsB,  List<File> selectedFilesB,  List<double> aspectRatiosB,  List<String> assetEntityIdsB,  List<String> localPathsB,  bool isUploadingB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
return $default(_that.uploadedUrlsA,_that.selectedFilesA,_that.aspectRatiosA,_that.assetEntityIdsA,_that.localPathsA,_that.isUploadingA,_that.uploadedUrlsB,_that.selectedFilesB,_that.aspectRatiosB,_that.assetEntityIdsB,_that.localPathsB,_that.isUploadingB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> uploadedUrlsA,  List<File> selectedFilesA,  List<double> aspectRatiosA,  List<String> assetEntityIdsA,  List<String> localPathsA,  bool isUploadingA,  List<String> uploadedUrlsB,  List<File> selectedFilesB,  List<double> aspectRatiosB,  List<String> assetEntityIdsB,  List<String> localPathsB,  bool isUploadingB)  $default,) {final _that = this;
switch (_that) {
case _MediaSelectionState():
return $default(_that.uploadedUrlsA,_that.selectedFilesA,_that.aspectRatiosA,_that.assetEntityIdsA,_that.localPathsA,_that.isUploadingA,_that.uploadedUrlsB,_that.selectedFilesB,_that.aspectRatiosB,_that.assetEntityIdsB,_that.localPathsB,_that.isUploadingB);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> uploadedUrlsA,  List<File> selectedFilesA,  List<double> aspectRatiosA,  List<String> assetEntityIdsA,  List<String> localPathsA,  bool isUploadingA,  List<String> uploadedUrlsB,  List<File> selectedFilesB,  List<double> aspectRatiosB,  List<String> assetEntityIdsB,  List<String> localPathsB,  bool isUploadingB)?  $default,) {final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
return $default(_that.uploadedUrlsA,_that.selectedFilesA,_that.aspectRatiosA,_that.assetEntityIdsA,_that.localPathsA,_that.isUploadingA,_that.uploadedUrlsB,_that.selectedFilesB,_that.aspectRatiosB,_that.assetEntityIdsB,_that.localPathsB,_that.isUploadingB);case _:
  return null;

}
}

}

/// @nodoc


class _MediaSelectionState implements MediaSelectionState {
  const _MediaSelectionState({final  List<String> uploadedUrlsA = const [], final  List<File> selectedFilesA = const [], final  List<double> aspectRatiosA = const [], final  List<String> assetEntityIdsA = const [], final  List<String> localPathsA = const [], this.isUploadingA = false, final  List<String> uploadedUrlsB = const [], final  List<File> selectedFilesB = const [], final  List<double> aspectRatiosB = const [], final  List<String> assetEntityIdsB = const [], final  List<String> localPathsB = const [], this.isUploadingB = false}): _uploadedUrlsA = uploadedUrlsA,_selectedFilesA = selectedFilesA,_aspectRatiosA = aspectRatiosA,_assetEntityIdsA = assetEntityIdsA,_localPathsA = localPathsA,_uploadedUrlsB = uploadedUrlsB,_selectedFilesB = selectedFilesB,_aspectRatiosB = aspectRatiosB,_assetEntityIdsB = assetEntityIdsB,_localPathsB = localPathsB;
  

// ==================== Option A 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option A)
///
/// **AppState 대체**: `List<String> uploadImageA`
///
/// **사용 예시**:
/// ```dart
/// final urls = ref.watch(mediaSelectionProvider).uploadedUrlsA;
/// ```
 final  List<String> _uploadedUrlsA;
// ==================== Option A 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option A)
///
/// **AppState 대체**: `List<String> uploadImageA`
///
/// **사용 예시**:
/// ```dart
/// final urls = ref.watch(mediaSelectionProvider).uploadedUrlsA;
/// ```
@override@JsonKey() List<String> get uploadedUrlsA {
  if (_uploadedUrlsA is EqualUnmodifiableListView) return _uploadedUrlsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadedUrlsA);
}

/// 선택된 이미지 파일 목록 (Option A)
///
/// **AppState 대체**: `List<File> tempImageFilesA`
///
/// **사용 예시**:
/// ```dart
/// final files = ref.watch(mediaSelectionProvider).selectedFilesA;
/// ```
 final  List<File> _selectedFilesA;
/// 선택된 이미지 파일 목록 (Option A)
///
/// **AppState 대체**: `List<File> tempImageFilesA`
///
/// **사용 예시**:
/// ```dart
/// final files = ref.watch(mediaSelectionProvider).selectedFilesA;
/// ```
@override@JsonKey() List<File> get selectedFilesA {
  if (_selectedFilesA is EqualUnmodifiableListView) return _selectedFilesA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFilesA);
}

/// 이미지 가로세로 비율 목록 (Option A)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioA`
///
/// **사용 예시**:
/// ```dart
/// final ratios = ref.watch(mediaSelectionProvider).aspectRatiosA;
/// ```
 final  List<double> _aspectRatiosA;
/// 이미지 가로세로 비율 목록 (Option A)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioA`
///
/// **사용 예시**:
/// ```dart
/// final ratios = ref.watch(mediaSelectionProvider).aspectRatiosA;
/// ```
@override@JsonKey() List<double> get aspectRatiosA {
  if (_aspectRatiosA is EqualUnmodifiableListView) return _aspectRatiosA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatiosA);
}

/// Asset Entity ID 목록 (Option A)
///
/// **AppState 대체**: `List<String> assetEntityIdsA`
///
/// **사용 예시**:
/// ```dart
/// final ids = ref.watch(mediaSelectionProvider).assetEntityIdsA;
/// ```
 final  List<String> _assetEntityIdsA;
/// Asset Entity ID 목록 (Option A)
///
/// **AppState 대체**: `List<String> assetEntityIdsA`
///
/// **사용 예시**:
/// ```dart
/// final ids = ref.watch(mediaSelectionProvider).assetEntityIdsA;
/// ```
@override@JsonKey() List<String> get assetEntityIdsA {
  if (_assetEntityIdsA is EqualUnmodifiableListView) return _assetEntityIdsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetEntityIdsA);
}

/// 로컬 이미지 경로 목록 (Option A)
///
/// **AppState 대체**: `List<String> localImagePathsA`
///
/// **사용 예시**:
/// ```dart
/// final paths = ref.watch(mediaSelectionProvider).localPathsA;
/// ```
 final  List<String> _localPathsA;
/// 로컬 이미지 경로 목록 (Option A)
///
/// **AppState 대체**: `List<String> localImagePathsA`
///
/// **사용 예시**:
/// ```dart
/// final paths = ref.watch(mediaSelectionProvider).localPathsA;
/// ```
@override@JsonKey() List<String> get localPathsA {
  if (_localPathsA is EqualUnmodifiableListView) return _localPathsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localPathsA);
}

/// 업로드 진행 중 여부 (Option A)
///
/// **AppState 대체**: `bool isUploadingA`
///
/// **사용 예시**:
/// ```dart
/// final isUploading = ref.watch(mediaSelectionProvider).isUploadingA;
/// if (isUploading) CircularProgressIndicator();
/// ```
@override@JsonKey() final  bool isUploadingA;
// ==================== Option B 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option B)
///
/// **AppState 대체**: `List<String> uploadImageB`
 final  List<String> _uploadedUrlsB;
// ==================== Option B 상태 (6개 필드) ====================
/// 업로드된 이미지 URL 목록 (Option B)
///
/// **AppState 대체**: `List<String> uploadImageB`
@override@JsonKey() List<String> get uploadedUrlsB {
  if (_uploadedUrlsB is EqualUnmodifiableListView) return _uploadedUrlsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadedUrlsB);
}

/// 선택된 이미지 파일 목록 (Option B)
///
/// **AppState 대체**: `List<File> tempImageFilesB`
 final  List<File> _selectedFilesB;
/// 선택된 이미지 파일 목록 (Option B)
///
/// **AppState 대체**: `List<File> tempImageFilesB`
@override@JsonKey() List<File> get selectedFilesB {
  if (_selectedFilesB is EqualUnmodifiableListView) return _selectedFilesB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFilesB);
}

/// 이미지 가로세로 비율 목록 (Option B)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioB`
 final  List<double> _aspectRatiosB;
/// 이미지 가로세로 비율 목록 (Option B)
///
/// **AppState 대체**: `List<double> uploadImageAspectRatioB`
@override@JsonKey() List<double> get aspectRatiosB {
  if (_aspectRatiosB is EqualUnmodifiableListView) return _aspectRatiosB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatiosB);
}

/// Asset Entity ID 목록 (Option B)
///
/// **AppState 대체**: `List<String> assetEntityIdsB`
 final  List<String> _assetEntityIdsB;
/// Asset Entity ID 목록 (Option B)
///
/// **AppState 대체**: `List<String> assetEntityIdsB`
@override@JsonKey() List<String> get assetEntityIdsB {
  if (_assetEntityIdsB is EqualUnmodifiableListView) return _assetEntityIdsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetEntityIdsB);
}

/// 로컬 이미지 경로 목록 (Option B)
///
/// **AppState 대체**: `List<String> localImagePathsB`
 final  List<String> _localPathsB;
/// 로컬 이미지 경로 목록 (Option B)
///
/// **AppState 대체**: `List<String> localImagePathsB`
@override@JsonKey() List<String> get localPathsB {
  if (_localPathsB is EqualUnmodifiableListView) return _localPathsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localPathsB);
}

/// 업로드 진행 중 여부 (Option B)
///
/// **AppState 대체**: `bool isUploadingB`
@override@JsonKey() final  bool isUploadingB;

/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaSelectionStateCopyWith<_MediaSelectionState> get copyWith => __$MediaSelectionStateCopyWithImpl<_MediaSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaSelectionState&&const DeepCollectionEquality().equals(other._uploadedUrlsA, _uploadedUrlsA)&&const DeepCollectionEquality().equals(other._selectedFilesA, _selectedFilesA)&&const DeepCollectionEquality().equals(other._aspectRatiosA, _aspectRatiosA)&&const DeepCollectionEquality().equals(other._assetEntityIdsA, _assetEntityIdsA)&&const DeepCollectionEquality().equals(other._localPathsA, _localPathsA)&&(identical(other.isUploadingA, isUploadingA) || other.isUploadingA == isUploadingA)&&const DeepCollectionEquality().equals(other._uploadedUrlsB, _uploadedUrlsB)&&const DeepCollectionEquality().equals(other._selectedFilesB, _selectedFilesB)&&const DeepCollectionEquality().equals(other._aspectRatiosB, _aspectRatiosB)&&const DeepCollectionEquality().equals(other._assetEntityIdsB, _assetEntityIdsB)&&const DeepCollectionEquality().equals(other._localPathsB, _localPathsB)&&(identical(other.isUploadingB, isUploadingB) || other.isUploadingB == isUploadingB));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_uploadedUrlsA),const DeepCollectionEquality().hash(_selectedFilesA),const DeepCollectionEquality().hash(_aspectRatiosA),const DeepCollectionEquality().hash(_assetEntityIdsA),const DeepCollectionEquality().hash(_localPathsA),isUploadingA,const DeepCollectionEquality().hash(_uploadedUrlsB),const DeepCollectionEquality().hash(_selectedFilesB),const DeepCollectionEquality().hash(_aspectRatiosB),const DeepCollectionEquality().hash(_assetEntityIdsB),const DeepCollectionEquality().hash(_localPathsB),isUploadingB);

@override
String toString() {
  return 'MediaSelectionState(uploadedUrlsA: $uploadedUrlsA, selectedFilesA: $selectedFilesA, aspectRatiosA: $aspectRatiosA, assetEntityIdsA: $assetEntityIdsA, localPathsA: $localPathsA, isUploadingA: $isUploadingA, uploadedUrlsB: $uploadedUrlsB, selectedFilesB: $selectedFilesB, aspectRatiosB: $aspectRatiosB, assetEntityIdsB: $assetEntityIdsB, localPathsB: $localPathsB, isUploadingB: $isUploadingB)';
}


}

/// @nodoc
abstract mixin class _$MediaSelectionStateCopyWith<$Res> implements $MediaSelectionStateCopyWith<$Res> {
  factory _$MediaSelectionStateCopyWith(_MediaSelectionState value, $Res Function(_MediaSelectionState) _then) = __$MediaSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 List<String> uploadedUrlsA, List<File> selectedFilesA, List<double> aspectRatiosA, List<String> assetEntityIdsA, List<String> localPathsA, bool isUploadingA, List<String> uploadedUrlsB, List<File> selectedFilesB, List<double> aspectRatiosB, List<String> assetEntityIdsB, List<String> localPathsB, bool isUploadingB
});




}
/// @nodoc
class __$MediaSelectionStateCopyWithImpl<$Res>
    implements _$MediaSelectionStateCopyWith<$Res> {
  __$MediaSelectionStateCopyWithImpl(this._self, this._then);

  final _MediaSelectionState _self;
  final $Res Function(_MediaSelectionState) _then;

/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uploadedUrlsA = null,Object? selectedFilesA = null,Object? aspectRatiosA = null,Object? assetEntityIdsA = null,Object? localPathsA = null,Object? isUploadingA = null,Object? uploadedUrlsB = null,Object? selectedFilesB = null,Object? aspectRatiosB = null,Object? assetEntityIdsB = null,Object? localPathsB = null,Object? isUploadingB = null,}) {
  return _then(_MediaSelectionState(
uploadedUrlsA: null == uploadedUrlsA ? _self._uploadedUrlsA : uploadedUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFilesA: null == selectedFilesA ? _self._selectedFilesA : selectedFilesA // ignore: cast_nullable_to_non_nullable
as List<File>,aspectRatiosA: null == aspectRatiosA ? _self._aspectRatiosA : aspectRatiosA // ignore: cast_nullable_to_non_nullable
as List<double>,assetEntityIdsA: null == assetEntityIdsA ? _self._assetEntityIdsA : assetEntityIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsA: null == localPathsA ? _self._localPathsA : localPathsA // ignore: cast_nullable_to_non_nullable
as List<String>,isUploadingA: null == isUploadingA ? _self.isUploadingA : isUploadingA // ignore: cast_nullable_to_non_nullable
as bool,uploadedUrlsB: null == uploadedUrlsB ? _self._uploadedUrlsB : uploadedUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>,selectedFilesB: null == selectedFilesB ? _self._selectedFilesB : selectedFilesB // ignore: cast_nullable_to_non_nullable
as List<File>,aspectRatiosB: null == aspectRatiosB ? _self._aspectRatiosB : aspectRatiosB // ignore: cast_nullable_to_non_nullable
as List<double>,assetEntityIdsB: null == assetEntityIdsB ? _self._assetEntityIdsB : assetEntityIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsB: null == localPathsB ? _self._localPathsB : localPathsB // ignore: cast_nullable_to_non_nullable
as List<String>,isUploadingB: null == isUploadingB ? _self.isUploadingB : isUploadingB // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
