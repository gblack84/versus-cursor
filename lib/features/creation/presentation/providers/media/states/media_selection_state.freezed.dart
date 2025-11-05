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

// ============= File Selection (A/B Boxes) =============
 List<File> get selectedFilesA; List<File> get selectedFilesB;// ============= Uploaded URLs =============
 List<String> get uploadedUrlsA; List<String> get uploadedUrlsB;// ============= Aspect Ratios =============
 List<double> get aspectRatiosA; List<double> get aspectRatiosB;// ============= Local Paths (Fast Preview) =============
 List<String> get localPathsA; List<String> get localPathsB;// ============= AssetEntity IDs (Re-selection) =============
 List<String> get assetEntityIdsA; List<String> get assetEntityIdsB;// ============= Current Index (Carousel) =============
 int get currentIndexA; int get currentIndexB;// ============= Video Selection =============
 bool get isVideoSelectedA; bool get isVideoSelectedB;// ============= B Box Visibility =============
 bool get isBoxBVisible;// ============= Layout State (Phase 5) =============
 LayoutType get currentLayout; double? get boxWidthA; double? get boxHeightA; double? get boxWidthB; double? get boxHeightB;
/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaSelectionStateCopyWith<MediaSelectionState> get copyWith => _$MediaSelectionStateCopyWithImpl<MediaSelectionState>(this as MediaSelectionState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaSelectionState&&const DeepCollectionEquality().equals(other.selectedFilesA, selectedFilesA)&&const DeepCollectionEquality().equals(other.selectedFilesB, selectedFilesB)&&const DeepCollectionEquality().equals(other.uploadedUrlsA, uploadedUrlsA)&&const DeepCollectionEquality().equals(other.uploadedUrlsB, uploadedUrlsB)&&const DeepCollectionEquality().equals(other.aspectRatiosA, aspectRatiosA)&&const DeepCollectionEquality().equals(other.aspectRatiosB, aspectRatiosB)&&const DeepCollectionEquality().equals(other.localPathsA, localPathsA)&&const DeepCollectionEquality().equals(other.localPathsB, localPathsB)&&const DeepCollectionEquality().equals(other.assetEntityIdsA, assetEntityIdsA)&&const DeepCollectionEquality().equals(other.assetEntityIdsB, assetEntityIdsB)&&(identical(other.currentIndexA, currentIndexA) || other.currentIndexA == currentIndexA)&&(identical(other.currentIndexB, currentIndexB) || other.currentIndexB == currentIndexB)&&(identical(other.isVideoSelectedA, isVideoSelectedA) || other.isVideoSelectedA == isVideoSelectedA)&&(identical(other.isVideoSelectedB, isVideoSelectedB) || other.isVideoSelectedB == isVideoSelectedB)&&(identical(other.isBoxBVisible, isBoxBVisible) || other.isBoxBVisible == isBoxBVisible)&&(identical(other.currentLayout, currentLayout) || other.currentLayout == currentLayout)&&(identical(other.boxWidthA, boxWidthA) || other.boxWidthA == boxWidthA)&&(identical(other.boxHeightA, boxHeightA) || other.boxHeightA == boxHeightA)&&(identical(other.boxWidthB, boxWidthB) || other.boxWidthB == boxWidthB)&&(identical(other.boxHeightB, boxHeightB) || other.boxHeightB == boxHeightB));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(selectedFilesA),const DeepCollectionEquality().hash(selectedFilesB),const DeepCollectionEquality().hash(uploadedUrlsA),const DeepCollectionEquality().hash(uploadedUrlsB),const DeepCollectionEquality().hash(aspectRatiosA),const DeepCollectionEquality().hash(aspectRatiosB),const DeepCollectionEquality().hash(localPathsA),const DeepCollectionEquality().hash(localPathsB),const DeepCollectionEquality().hash(assetEntityIdsA),const DeepCollectionEquality().hash(assetEntityIdsB),currentIndexA,currentIndexB,isVideoSelectedA,isVideoSelectedB,isBoxBVisible,currentLayout,boxWidthA,boxHeightA,boxWidthB,boxHeightB]);

@override
String toString() {
  return 'MediaSelectionState(selectedFilesA: $selectedFilesA, selectedFilesB: $selectedFilesB, uploadedUrlsA: $uploadedUrlsA, uploadedUrlsB: $uploadedUrlsB, aspectRatiosA: $aspectRatiosA, aspectRatiosB: $aspectRatiosB, localPathsA: $localPathsA, localPathsB: $localPathsB, assetEntityIdsA: $assetEntityIdsA, assetEntityIdsB: $assetEntityIdsB, currentIndexA: $currentIndexA, currentIndexB: $currentIndexB, isVideoSelectedA: $isVideoSelectedA, isVideoSelectedB: $isVideoSelectedB, isBoxBVisible: $isBoxBVisible, currentLayout: $currentLayout, boxWidthA: $boxWidthA, boxHeightA: $boxHeightA, boxWidthB: $boxWidthB, boxHeightB: $boxHeightB)';
}


}

/// @nodoc
abstract mixin class $MediaSelectionStateCopyWith<$Res>  {
  factory $MediaSelectionStateCopyWith(MediaSelectionState value, $Res Function(MediaSelectionState) _then) = _$MediaSelectionStateCopyWithImpl;
@useResult
$Res call({
 List<File> selectedFilesA, List<File> selectedFilesB, List<String> uploadedUrlsA, List<String> uploadedUrlsB, List<double> aspectRatiosA, List<double> aspectRatiosB, List<String> localPathsA, List<String> localPathsB, List<String> assetEntityIdsA, List<String> assetEntityIdsB, int currentIndexA, int currentIndexB, bool isVideoSelectedA, bool isVideoSelectedB, bool isBoxBVisible, LayoutType currentLayout, double? boxWidthA, double? boxHeightA, double? boxWidthB, double? boxHeightB
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
@pragma('vm:prefer-inline') @override $Res call({Object? selectedFilesA = null,Object? selectedFilesB = null,Object? uploadedUrlsA = null,Object? uploadedUrlsB = null,Object? aspectRatiosA = null,Object? aspectRatiosB = null,Object? localPathsA = null,Object? localPathsB = null,Object? assetEntityIdsA = null,Object? assetEntityIdsB = null,Object? currentIndexA = null,Object? currentIndexB = null,Object? isVideoSelectedA = null,Object? isVideoSelectedB = null,Object? isBoxBVisible = null,Object? currentLayout = null,Object? boxWidthA = freezed,Object? boxHeightA = freezed,Object? boxWidthB = freezed,Object? boxHeightB = freezed,}) {
  return _then(_self.copyWith(
selectedFilesA: null == selectedFilesA ? _self.selectedFilesA : selectedFilesA // ignore: cast_nullable_to_non_nullable
as List<File>,selectedFilesB: null == selectedFilesB ? _self.selectedFilesB : selectedFilesB // ignore: cast_nullable_to_non_nullable
as List<File>,uploadedUrlsA: null == uploadedUrlsA ? _self.uploadedUrlsA : uploadedUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>,uploadedUrlsB: null == uploadedUrlsB ? _self.uploadedUrlsB : uploadedUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>,aspectRatiosA: null == aspectRatiosA ? _self.aspectRatiosA : aspectRatiosA // ignore: cast_nullable_to_non_nullable
as List<double>,aspectRatiosB: null == aspectRatiosB ? _self.aspectRatiosB : aspectRatiosB // ignore: cast_nullable_to_non_nullable
as List<double>,localPathsA: null == localPathsA ? _self.localPathsA : localPathsA // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsB: null == localPathsB ? _self.localPathsB : localPathsB // ignore: cast_nullable_to_non_nullable
as List<String>,assetEntityIdsA: null == assetEntityIdsA ? _self.assetEntityIdsA : assetEntityIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,assetEntityIdsB: null == assetEntityIdsB ? _self.assetEntityIdsB : assetEntityIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,currentIndexA: null == currentIndexA ? _self.currentIndexA : currentIndexA // ignore: cast_nullable_to_non_nullable
as int,currentIndexB: null == currentIndexB ? _self.currentIndexB : currentIndexB // ignore: cast_nullable_to_non_nullable
as int,isVideoSelectedA: null == isVideoSelectedA ? _self.isVideoSelectedA : isVideoSelectedA // ignore: cast_nullable_to_non_nullable
as bool,isVideoSelectedB: null == isVideoSelectedB ? _self.isVideoSelectedB : isVideoSelectedB // ignore: cast_nullable_to_non_nullable
as bool,isBoxBVisible: null == isBoxBVisible ? _self.isBoxBVisible : isBoxBVisible // ignore: cast_nullable_to_non_nullable
as bool,currentLayout: null == currentLayout ? _self.currentLayout : currentLayout // ignore: cast_nullable_to_non_nullable
as LayoutType,boxWidthA: freezed == boxWidthA ? _self.boxWidthA : boxWidthA // ignore: cast_nullable_to_non_nullable
as double?,boxHeightA: freezed == boxHeightA ? _self.boxHeightA : boxHeightA // ignore: cast_nullable_to_non_nullable
as double?,boxWidthB: freezed == boxWidthB ? _self.boxWidthB : boxWidthB // ignore: cast_nullable_to_non_nullable
as double?,boxHeightB: freezed == boxHeightB ? _self.boxHeightB : boxHeightB // ignore: cast_nullable_to_non_nullable
as double?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<File> selectedFilesA,  List<File> selectedFilesB,  List<String> uploadedUrlsA,  List<String> uploadedUrlsB,  List<double> aspectRatiosA,  List<double> aspectRatiosB,  List<String> localPathsA,  List<String> localPathsB,  List<String> assetEntityIdsA,  List<String> assetEntityIdsB,  int currentIndexA,  int currentIndexB,  bool isVideoSelectedA,  bool isVideoSelectedB,  bool isBoxBVisible,  LayoutType currentLayout,  double? boxWidthA,  double? boxHeightA,  double? boxWidthB,  double? boxHeightB)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
return $default(_that.selectedFilesA,_that.selectedFilesB,_that.uploadedUrlsA,_that.uploadedUrlsB,_that.aspectRatiosA,_that.aspectRatiosB,_that.localPathsA,_that.localPathsB,_that.assetEntityIdsA,_that.assetEntityIdsB,_that.currentIndexA,_that.currentIndexB,_that.isVideoSelectedA,_that.isVideoSelectedB,_that.isBoxBVisible,_that.currentLayout,_that.boxWidthA,_that.boxHeightA,_that.boxWidthB,_that.boxHeightB);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<File> selectedFilesA,  List<File> selectedFilesB,  List<String> uploadedUrlsA,  List<String> uploadedUrlsB,  List<double> aspectRatiosA,  List<double> aspectRatiosB,  List<String> localPathsA,  List<String> localPathsB,  List<String> assetEntityIdsA,  List<String> assetEntityIdsB,  int currentIndexA,  int currentIndexB,  bool isVideoSelectedA,  bool isVideoSelectedB,  bool isBoxBVisible,  LayoutType currentLayout,  double? boxWidthA,  double? boxHeightA,  double? boxWidthB,  double? boxHeightB)  $default,) {final _that = this;
switch (_that) {
case _MediaSelectionState():
return $default(_that.selectedFilesA,_that.selectedFilesB,_that.uploadedUrlsA,_that.uploadedUrlsB,_that.aspectRatiosA,_that.aspectRatiosB,_that.localPathsA,_that.localPathsB,_that.assetEntityIdsA,_that.assetEntityIdsB,_that.currentIndexA,_that.currentIndexB,_that.isVideoSelectedA,_that.isVideoSelectedB,_that.isBoxBVisible,_that.currentLayout,_that.boxWidthA,_that.boxHeightA,_that.boxWidthB,_that.boxHeightB);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<File> selectedFilesA,  List<File> selectedFilesB,  List<String> uploadedUrlsA,  List<String> uploadedUrlsB,  List<double> aspectRatiosA,  List<double> aspectRatiosB,  List<String> localPathsA,  List<String> localPathsB,  List<String> assetEntityIdsA,  List<String> assetEntityIdsB,  int currentIndexA,  int currentIndexB,  bool isVideoSelectedA,  bool isVideoSelectedB,  bool isBoxBVisible,  LayoutType currentLayout,  double? boxWidthA,  double? boxHeightA,  double? boxWidthB,  double? boxHeightB)?  $default,) {final _that = this;
switch (_that) {
case _MediaSelectionState() when $default != null:
return $default(_that.selectedFilesA,_that.selectedFilesB,_that.uploadedUrlsA,_that.uploadedUrlsB,_that.aspectRatiosA,_that.aspectRatiosB,_that.localPathsA,_that.localPathsB,_that.assetEntityIdsA,_that.assetEntityIdsB,_that.currentIndexA,_that.currentIndexB,_that.isVideoSelectedA,_that.isVideoSelectedB,_that.isBoxBVisible,_that.currentLayout,_that.boxWidthA,_that.boxHeightA,_that.boxWidthB,_that.boxHeightB);case _:
  return null;

}
}

}

/// @nodoc


class _MediaSelectionState implements MediaSelectionState {
  const _MediaSelectionState({final  List<File> selectedFilesA = const [], final  List<File> selectedFilesB = const [], final  List<String> uploadedUrlsA = const [], final  List<String> uploadedUrlsB = const [], final  List<double> aspectRatiosA = const [], final  List<double> aspectRatiosB = const [], final  List<String> localPathsA = const [], final  List<String> localPathsB = const [], final  List<String> assetEntityIdsA = const [], final  List<String> assetEntityIdsB = const [], this.currentIndexA = 0, this.currentIndexB = 0, this.isVideoSelectedA = false, this.isVideoSelectedB = false, this.isBoxBVisible = false, this.currentLayout = LayoutType.horizontal, this.boxWidthA, this.boxHeightA, this.boxWidthB, this.boxHeightB}): _selectedFilesA = selectedFilesA,_selectedFilesB = selectedFilesB,_uploadedUrlsA = uploadedUrlsA,_uploadedUrlsB = uploadedUrlsB,_aspectRatiosA = aspectRatiosA,_aspectRatiosB = aspectRatiosB,_localPathsA = localPathsA,_localPathsB = localPathsB,_assetEntityIdsA = assetEntityIdsA,_assetEntityIdsB = assetEntityIdsB;
  

// ============= File Selection (A/B Boxes) =============
 final  List<File> _selectedFilesA;
// ============= File Selection (A/B Boxes) =============
@override@JsonKey() List<File> get selectedFilesA {
  if (_selectedFilesA is EqualUnmodifiableListView) return _selectedFilesA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFilesA);
}

 final  List<File> _selectedFilesB;
@override@JsonKey() List<File> get selectedFilesB {
  if (_selectedFilesB is EqualUnmodifiableListView) return _selectedFilesB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedFilesB);
}

// ============= Uploaded URLs =============
 final  List<String> _uploadedUrlsA;
// ============= Uploaded URLs =============
@override@JsonKey() List<String> get uploadedUrlsA {
  if (_uploadedUrlsA is EqualUnmodifiableListView) return _uploadedUrlsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadedUrlsA);
}

 final  List<String> _uploadedUrlsB;
@override@JsonKey() List<String> get uploadedUrlsB {
  if (_uploadedUrlsB is EqualUnmodifiableListView) return _uploadedUrlsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadedUrlsB);
}

// ============= Aspect Ratios =============
 final  List<double> _aspectRatiosA;
// ============= Aspect Ratios =============
@override@JsonKey() List<double> get aspectRatiosA {
  if (_aspectRatiosA is EqualUnmodifiableListView) return _aspectRatiosA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatiosA);
}

 final  List<double> _aspectRatiosB;
@override@JsonKey() List<double> get aspectRatiosB {
  if (_aspectRatiosB is EqualUnmodifiableListView) return _aspectRatiosB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_aspectRatiosB);
}

// ============= Local Paths (Fast Preview) =============
 final  List<String> _localPathsA;
// ============= Local Paths (Fast Preview) =============
@override@JsonKey() List<String> get localPathsA {
  if (_localPathsA is EqualUnmodifiableListView) return _localPathsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localPathsA);
}

 final  List<String> _localPathsB;
@override@JsonKey() List<String> get localPathsB {
  if (_localPathsB is EqualUnmodifiableListView) return _localPathsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_localPathsB);
}

// ============= AssetEntity IDs (Re-selection) =============
 final  List<String> _assetEntityIdsA;
// ============= AssetEntity IDs (Re-selection) =============
@override@JsonKey() List<String> get assetEntityIdsA {
  if (_assetEntityIdsA is EqualUnmodifiableListView) return _assetEntityIdsA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetEntityIdsA);
}

 final  List<String> _assetEntityIdsB;
@override@JsonKey() List<String> get assetEntityIdsB {
  if (_assetEntityIdsB is EqualUnmodifiableListView) return _assetEntityIdsB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_assetEntityIdsB);
}

// ============= Current Index (Carousel) =============
@override@JsonKey() final  int currentIndexA;
@override@JsonKey() final  int currentIndexB;
// ============= Video Selection =============
@override@JsonKey() final  bool isVideoSelectedA;
@override@JsonKey() final  bool isVideoSelectedB;
// ============= B Box Visibility =============
@override@JsonKey() final  bool isBoxBVisible;
// ============= Layout State (Phase 5) =============
@override@JsonKey() final  LayoutType currentLayout;
@override final  double? boxWidthA;
@override final  double? boxHeightA;
@override final  double? boxWidthB;
@override final  double? boxHeightB;

/// Create a copy of MediaSelectionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaSelectionStateCopyWith<_MediaSelectionState> get copyWith => __$MediaSelectionStateCopyWithImpl<_MediaSelectionState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaSelectionState&&const DeepCollectionEquality().equals(other._selectedFilesA, _selectedFilesA)&&const DeepCollectionEquality().equals(other._selectedFilesB, _selectedFilesB)&&const DeepCollectionEquality().equals(other._uploadedUrlsA, _uploadedUrlsA)&&const DeepCollectionEquality().equals(other._uploadedUrlsB, _uploadedUrlsB)&&const DeepCollectionEquality().equals(other._aspectRatiosA, _aspectRatiosA)&&const DeepCollectionEquality().equals(other._aspectRatiosB, _aspectRatiosB)&&const DeepCollectionEquality().equals(other._localPathsA, _localPathsA)&&const DeepCollectionEquality().equals(other._localPathsB, _localPathsB)&&const DeepCollectionEquality().equals(other._assetEntityIdsA, _assetEntityIdsA)&&const DeepCollectionEquality().equals(other._assetEntityIdsB, _assetEntityIdsB)&&(identical(other.currentIndexA, currentIndexA) || other.currentIndexA == currentIndexA)&&(identical(other.currentIndexB, currentIndexB) || other.currentIndexB == currentIndexB)&&(identical(other.isVideoSelectedA, isVideoSelectedA) || other.isVideoSelectedA == isVideoSelectedA)&&(identical(other.isVideoSelectedB, isVideoSelectedB) || other.isVideoSelectedB == isVideoSelectedB)&&(identical(other.isBoxBVisible, isBoxBVisible) || other.isBoxBVisible == isBoxBVisible)&&(identical(other.currentLayout, currentLayout) || other.currentLayout == currentLayout)&&(identical(other.boxWidthA, boxWidthA) || other.boxWidthA == boxWidthA)&&(identical(other.boxHeightA, boxHeightA) || other.boxHeightA == boxHeightA)&&(identical(other.boxWidthB, boxWidthB) || other.boxWidthB == boxWidthB)&&(identical(other.boxHeightB, boxHeightB) || other.boxHeightB == boxHeightB));
}


@override
int get hashCode => Object.hashAll([runtimeType,const DeepCollectionEquality().hash(_selectedFilesA),const DeepCollectionEquality().hash(_selectedFilesB),const DeepCollectionEquality().hash(_uploadedUrlsA),const DeepCollectionEquality().hash(_uploadedUrlsB),const DeepCollectionEquality().hash(_aspectRatiosA),const DeepCollectionEquality().hash(_aspectRatiosB),const DeepCollectionEquality().hash(_localPathsA),const DeepCollectionEquality().hash(_localPathsB),const DeepCollectionEquality().hash(_assetEntityIdsA),const DeepCollectionEquality().hash(_assetEntityIdsB),currentIndexA,currentIndexB,isVideoSelectedA,isVideoSelectedB,isBoxBVisible,currentLayout,boxWidthA,boxHeightA,boxWidthB,boxHeightB]);

@override
String toString() {
  return 'MediaSelectionState(selectedFilesA: $selectedFilesA, selectedFilesB: $selectedFilesB, uploadedUrlsA: $uploadedUrlsA, uploadedUrlsB: $uploadedUrlsB, aspectRatiosA: $aspectRatiosA, aspectRatiosB: $aspectRatiosB, localPathsA: $localPathsA, localPathsB: $localPathsB, assetEntityIdsA: $assetEntityIdsA, assetEntityIdsB: $assetEntityIdsB, currentIndexA: $currentIndexA, currentIndexB: $currentIndexB, isVideoSelectedA: $isVideoSelectedA, isVideoSelectedB: $isVideoSelectedB, isBoxBVisible: $isBoxBVisible, currentLayout: $currentLayout, boxWidthA: $boxWidthA, boxHeightA: $boxHeightA, boxWidthB: $boxWidthB, boxHeightB: $boxHeightB)';
}


}

/// @nodoc
abstract mixin class _$MediaSelectionStateCopyWith<$Res> implements $MediaSelectionStateCopyWith<$Res> {
  factory _$MediaSelectionStateCopyWith(_MediaSelectionState value, $Res Function(_MediaSelectionState) _then) = __$MediaSelectionStateCopyWithImpl;
@override @useResult
$Res call({
 List<File> selectedFilesA, List<File> selectedFilesB, List<String> uploadedUrlsA, List<String> uploadedUrlsB, List<double> aspectRatiosA, List<double> aspectRatiosB, List<String> localPathsA, List<String> localPathsB, List<String> assetEntityIdsA, List<String> assetEntityIdsB, int currentIndexA, int currentIndexB, bool isVideoSelectedA, bool isVideoSelectedB, bool isBoxBVisible, LayoutType currentLayout, double? boxWidthA, double? boxHeightA, double? boxWidthB, double? boxHeightB
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
@override @pragma('vm:prefer-inline') $Res call({Object? selectedFilesA = null,Object? selectedFilesB = null,Object? uploadedUrlsA = null,Object? uploadedUrlsB = null,Object? aspectRatiosA = null,Object? aspectRatiosB = null,Object? localPathsA = null,Object? localPathsB = null,Object? assetEntityIdsA = null,Object? assetEntityIdsB = null,Object? currentIndexA = null,Object? currentIndexB = null,Object? isVideoSelectedA = null,Object? isVideoSelectedB = null,Object? isBoxBVisible = null,Object? currentLayout = null,Object? boxWidthA = freezed,Object? boxHeightA = freezed,Object? boxWidthB = freezed,Object? boxHeightB = freezed,}) {
  return _then(_MediaSelectionState(
selectedFilesA: null == selectedFilesA ? _self._selectedFilesA : selectedFilesA // ignore: cast_nullable_to_non_nullable
as List<File>,selectedFilesB: null == selectedFilesB ? _self._selectedFilesB : selectedFilesB // ignore: cast_nullable_to_non_nullable
as List<File>,uploadedUrlsA: null == uploadedUrlsA ? _self._uploadedUrlsA : uploadedUrlsA // ignore: cast_nullable_to_non_nullable
as List<String>,uploadedUrlsB: null == uploadedUrlsB ? _self._uploadedUrlsB : uploadedUrlsB // ignore: cast_nullable_to_non_nullable
as List<String>,aspectRatiosA: null == aspectRatiosA ? _self._aspectRatiosA : aspectRatiosA // ignore: cast_nullable_to_non_nullable
as List<double>,aspectRatiosB: null == aspectRatiosB ? _self._aspectRatiosB : aspectRatiosB // ignore: cast_nullable_to_non_nullable
as List<double>,localPathsA: null == localPathsA ? _self._localPathsA : localPathsA // ignore: cast_nullable_to_non_nullable
as List<String>,localPathsB: null == localPathsB ? _self._localPathsB : localPathsB // ignore: cast_nullable_to_non_nullable
as List<String>,assetEntityIdsA: null == assetEntityIdsA ? _self._assetEntityIdsA : assetEntityIdsA // ignore: cast_nullable_to_non_nullable
as List<String>,assetEntityIdsB: null == assetEntityIdsB ? _self._assetEntityIdsB : assetEntityIdsB // ignore: cast_nullable_to_non_nullable
as List<String>,currentIndexA: null == currentIndexA ? _self.currentIndexA : currentIndexA // ignore: cast_nullable_to_non_nullable
as int,currentIndexB: null == currentIndexB ? _self.currentIndexB : currentIndexB // ignore: cast_nullable_to_non_nullable
as int,isVideoSelectedA: null == isVideoSelectedA ? _self.isVideoSelectedA : isVideoSelectedA // ignore: cast_nullable_to_non_nullable
as bool,isVideoSelectedB: null == isVideoSelectedB ? _self.isVideoSelectedB : isVideoSelectedB // ignore: cast_nullable_to_non_nullable
as bool,isBoxBVisible: null == isBoxBVisible ? _self.isBoxBVisible : isBoxBVisible // ignore: cast_nullable_to_non_nullable
as bool,currentLayout: null == currentLayout ? _self.currentLayout : currentLayout // ignore: cast_nullable_to_non_nullable
as LayoutType,boxWidthA: freezed == boxWidthA ? _self.boxWidthA : boxWidthA // ignore: cast_nullable_to_non_nullable
as double?,boxHeightA: freezed == boxHeightA ? _self.boxHeightA : boxHeightA // ignore: cast_nullable_to_non_nullable
as double?,boxWidthB: freezed == boxWidthB ? _self.boxWidthB : boxWidthB // ignore: cast_nullable_to_non_nullable
as double?,boxHeightB: freezed == boxHeightB ? _self.boxHeightB : boxHeightB // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
