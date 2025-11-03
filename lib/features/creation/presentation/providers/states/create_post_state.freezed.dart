// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PostFormData {

 String get title; String get description; String get textA; String get textB; List<File> get imagesA; List<File> get imagesB; TargetAudience? get targetAudience; bool get isAnonymous; bool get isSingleMode;
/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostFormDataCopyWith<PostFormData> get copyWith => _$PostFormDataCopyWithImpl<PostFormData>(this as PostFormData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostFormData&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.textA, textA) || other.textA == textA)&&(identical(other.textB, textB) || other.textB == textB)&&const DeepCollectionEquality().equals(other.imagesA, imagesA)&&const DeepCollectionEquality().equals(other.imagesB, imagesB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.isSingleMode, isSingleMode) || other.isSingleMode == isSingleMode));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,textA,textB,const DeepCollectionEquality().hash(imagesA),const DeepCollectionEquality().hash(imagesB),targetAudience,isAnonymous,isSingleMode);

@override
String toString() {
  return 'PostFormData(title: $title, description: $description, textA: $textA, textB: $textB, imagesA: $imagesA, imagesB: $imagesB, targetAudience: $targetAudience, isAnonymous: $isAnonymous, isSingleMode: $isSingleMode)';
}


}

/// @nodoc
abstract mixin class $PostFormDataCopyWith<$Res>  {
  factory $PostFormDataCopyWith(PostFormData value, $Res Function(PostFormData) _then) = _$PostFormDataCopyWithImpl;
@useResult
$Res call({
 String title, String description, String textA, String textB, List<File> imagesA, List<File> imagesB, TargetAudience? targetAudience, bool isAnonymous, bool isSingleMode
});


$TargetAudienceCopyWith<$Res>? get targetAudience;

}
/// @nodoc
class _$PostFormDataCopyWithImpl<$Res>
    implements $PostFormDataCopyWith<$Res> {
  _$PostFormDataCopyWithImpl(this._self, this._then);

  final PostFormData _self;
  final $Res Function(PostFormData) _then;

/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = null,Object? description = null,Object? textA = null,Object? textB = null,Object? imagesA = null,Object? imagesB = null,Object? targetAudience = freezed,Object? isAnonymous = null,Object? isSingleMode = null,}) {
  return _then(_self.copyWith(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,textA: null == textA ? _self.textA : textA // ignore: cast_nullable_to_non_nullable
as String,textB: null == textB ? _self.textB : textB // ignore: cast_nullable_to_non_nullable
as String,imagesA: null == imagesA ? _self.imagesA : imagesA // ignore: cast_nullable_to_non_nullable
as List<File>,imagesB: null == imagesB ? _self.imagesB : imagesB // ignore: cast_nullable_to_non_nullable
as List<File>,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,isSingleMode: null == isSingleMode ? _self.isSingleMode : isSingleMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}
}


/// Adds pattern-matching-related methods to [PostFormData].
extension PostFormDataPatterns on PostFormData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PostFormData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PostFormData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PostFormData value)  $default,){
final _that = this;
switch (_that) {
case _PostFormData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PostFormData value)?  $default,){
final _that = this;
switch (_that) {
case _PostFormData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String title,  String description,  String textA,  String textB,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous,  bool isSingleMode)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PostFormData() when $default != null:
return $default(_that.title,_that.description,_that.textA,_that.textB,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous,_that.isSingleMode);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String title,  String description,  String textA,  String textB,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous,  bool isSingleMode)  $default,) {final _that = this;
switch (_that) {
case _PostFormData():
return $default(_that.title,_that.description,_that.textA,_that.textB,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous,_that.isSingleMode);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String title,  String description,  String textA,  String textB,  List<File> imagesA,  List<File> imagesB,  TargetAudience? targetAudience,  bool isAnonymous,  bool isSingleMode)?  $default,) {final _that = this;
switch (_that) {
case _PostFormData() when $default != null:
return $default(_that.title,_that.description,_that.textA,_that.textB,_that.imagesA,_that.imagesB,_that.targetAudience,_that.isAnonymous,_that.isSingleMode);case _:
  return null;

}
}

}

/// @nodoc


class _PostFormData extends PostFormData {
  const _PostFormData({this.title = '', this.description = '', this.textA = '', this.textB = '', final  List<File> imagesA = const [], final  List<File> imagesB = const [], this.targetAudience, this.isAnonymous = false, this.isSingleMode = false}): _imagesA = imagesA,_imagesB = imagesB,super._();
  

@override@JsonKey() final  String title;
@override@JsonKey() final  String description;
@override@JsonKey() final  String textA;
@override@JsonKey() final  String textB;
 final  List<File> _imagesA;
@override@JsonKey() List<File> get imagesA {
  if (_imagesA is EqualUnmodifiableListView) return _imagesA;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesA);
}

 final  List<File> _imagesB;
@override@JsonKey() List<File> get imagesB {
  if (_imagesB is EqualUnmodifiableListView) return _imagesB;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_imagesB);
}

@override final  TargetAudience? targetAudience;
@override@JsonKey() final  bool isAnonymous;
@override@JsonKey() final  bool isSingleMode;

/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PostFormDataCopyWith<_PostFormData> get copyWith => __$PostFormDataCopyWithImpl<_PostFormData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PostFormData&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.textA, textA) || other.textA == textA)&&(identical(other.textB, textB) || other.textB == textB)&&const DeepCollectionEquality().equals(other._imagesA, _imagesA)&&const DeepCollectionEquality().equals(other._imagesB, _imagesB)&&(identical(other.targetAudience, targetAudience) || other.targetAudience == targetAudience)&&(identical(other.isAnonymous, isAnonymous) || other.isAnonymous == isAnonymous)&&(identical(other.isSingleMode, isSingleMode) || other.isSingleMode == isSingleMode));
}


@override
int get hashCode => Object.hash(runtimeType,title,description,textA,textB,const DeepCollectionEquality().hash(_imagesA),const DeepCollectionEquality().hash(_imagesB),targetAudience,isAnonymous,isSingleMode);

@override
String toString() {
  return 'PostFormData(title: $title, description: $description, textA: $textA, textB: $textB, imagesA: $imagesA, imagesB: $imagesB, targetAudience: $targetAudience, isAnonymous: $isAnonymous, isSingleMode: $isSingleMode)';
}


}

/// @nodoc
abstract mixin class _$PostFormDataCopyWith<$Res> implements $PostFormDataCopyWith<$Res> {
  factory _$PostFormDataCopyWith(_PostFormData value, $Res Function(_PostFormData) _then) = __$PostFormDataCopyWithImpl;
@override @useResult
$Res call({
 String title, String description, String textA, String textB, List<File> imagesA, List<File> imagesB, TargetAudience? targetAudience, bool isAnonymous, bool isSingleMode
});


@override $TargetAudienceCopyWith<$Res>? get targetAudience;

}
/// @nodoc
class __$PostFormDataCopyWithImpl<$Res>
    implements _$PostFormDataCopyWith<$Res> {
  __$PostFormDataCopyWithImpl(this._self, this._then);

  final _PostFormData _self;
  final $Res Function(_PostFormData) _then;

/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = null,Object? description = null,Object? textA = null,Object? textB = null,Object? imagesA = null,Object? imagesB = null,Object? targetAudience = freezed,Object? isAnonymous = null,Object? isSingleMode = null,}) {
  return _then(_PostFormData(
title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,textA: null == textA ? _self.textA : textA // ignore: cast_nullable_to_non_nullable
as String,textB: null == textB ? _self.textB : textB // ignore: cast_nullable_to_non_nullable
as String,imagesA: null == imagesA ? _self._imagesA : imagesA // ignore: cast_nullable_to_non_nullable
as List<File>,imagesB: null == imagesB ? _self._imagesB : imagesB // ignore: cast_nullable_to_non_nullable
as List<File>,targetAudience: freezed == targetAudience ? _self.targetAudience : targetAudience // ignore: cast_nullable_to_non_nullable
as TargetAudience?,isAnonymous: null == isAnonymous ? _self.isAnonymous : isAnonymous // ignore: cast_nullable_to_non_nullable
as bool,isSingleMode: null == isSingleMode ? _self.isSingleMode : isSingleMode // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PostFormData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TargetAudienceCopyWith<$Res>? get targetAudience {
    if (_self.targetAudience == null) {
    return null;
  }

  return $TargetAudienceCopyWith<$Res>(_self.targetAudience!, (value) {
    return _then(_self.copyWith(targetAudience: value));
  });
}
}

/// @nodoc
mixin _$CreatePostState {

 PostFormData get formData; LoadingState get loadingState; ModerationStatus get moderationStatus; double get uploadProgress; String? get errorMessage; String? get moderationMessage; PostCreation? get createdPost; Map<String, PerspectiveResult> get validationResults;
/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreatePostStateCopyWith<CreatePostState> get copyWith => _$CreatePostStateCopyWithImpl<CreatePostState>(this as CreatePostState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreatePostState&&(identical(other.formData, formData) || other.formData == formData)&&(identical(other.loadingState, loadingState) || other.loadingState == loadingState)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.uploadProgress, uploadProgress) || other.uploadProgress == uploadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.moderationMessage, moderationMessage) || other.moderationMessage == moderationMessage)&&(identical(other.createdPost, createdPost) || other.createdPost == createdPost)&&const DeepCollectionEquality().equals(other.validationResults, validationResults));
}


@override
int get hashCode => Object.hash(runtimeType,formData,loadingState,moderationStatus,uploadProgress,errorMessage,moderationMessage,createdPost,const DeepCollectionEquality().hash(validationResults));

@override
String toString() {
  return 'CreatePostState(formData: $formData, loadingState: $loadingState, moderationStatus: $moderationStatus, uploadProgress: $uploadProgress, errorMessage: $errorMessage, moderationMessage: $moderationMessage, createdPost: $createdPost, validationResults: $validationResults)';
}


}

/// @nodoc
abstract mixin class $CreatePostStateCopyWith<$Res>  {
  factory $CreatePostStateCopyWith(CreatePostState value, $Res Function(CreatePostState) _then) = _$CreatePostStateCopyWithImpl;
@useResult
$Res call({
 PostFormData formData, LoadingState loadingState, ModerationStatus moderationStatus, double uploadProgress, String? errorMessage, String? moderationMessage, PostCreation? createdPost, Map<String, PerspectiveResult> validationResults
});


$PostFormDataCopyWith<$Res> get formData;$PostCreationCopyWith<$Res>? get createdPost;

}
/// @nodoc
class _$CreatePostStateCopyWithImpl<$Res>
    implements $CreatePostStateCopyWith<$Res> {
  _$CreatePostStateCopyWithImpl(this._self, this._then);

  final CreatePostState _self;
  final $Res Function(CreatePostState) _then;

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? formData = null,Object? loadingState = null,Object? moderationStatus = null,Object? uploadProgress = null,Object? errorMessage = freezed,Object? moderationMessage = freezed,Object? createdPost = freezed,Object? validationResults = null,}) {
  return _then(_self.copyWith(
formData: null == formData ? _self.formData : formData // ignore: cast_nullable_to_non_nullable
as PostFormData,loadingState: null == loadingState ? _self.loadingState : loadingState // ignore: cast_nullable_to_non_nullable
as LoadingState,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus,uploadProgress: null == uploadProgress ? _self.uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,moderationMessage: freezed == moderationMessage ? _self.moderationMessage : moderationMessage // ignore: cast_nullable_to_non_nullable
as String?,createdPost: freezed == createdPost ? _self.createdPost : createdPost // ignore: cast_nullable_to_non_nullable
as PostCreation?,validationResults: null == validationResults ? _self.validationResults : validationResults // ignore: cast_nullable_to_non_nullable
as Map<String, PerspectiveResult>,
  ));
}
/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFormDataCopyWith<$Res> get formData {
  
  return $PostFormDataCopyWith<$Res>(_self.formData, (value) {
    return _then(_self.copyWith(formData: value));
  });
}/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationCopyWith<$Res>? get createdPost {
    if (_self.createdPost == null) {
    return null;
  }

  return $PostCreationCopyWith<$Res>(_self.createdPost!, (value) {
    return _then(_self.copyWith(createdPost: value));
  });
}
}


/// Adds pattern-matching-related methods to [CreatePostState].
extension CreatePostStatePatterns on CreatePostState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreatePostState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreatePostState value)  $default,){
final _that = this;
switch (_that) {
case _CreatePostState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreatePostState value)?  $default,){
final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PostFormData formData,  LoadingState loadingState,  ModerationStatus moderationStatus,  double uploadProgress,  String? errorMessage,  String? moderationMessage,  PostCreation? createdPost,  Map<String, PerspectiveResult> validationResults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
return $default(_that.formData,_that.loadingState,_that.moderationStatus,_that.uploadProgress,_that.errorMessage,_that.moderationMessage,_that.createdPost,_that.validationResults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PostFormData formData,  LoadingState loadingState,  ModerationStatus moderationStatus,  double uploadProgress,  String? errorMessage,  String? moderationMessage,  PostCreation? createdPost,  Map<String, PerspectiveResult> validationResults)  $default,) {final _that = this;
switch (_that) {
case _CreatePostState():
return $default(_that.formData,_that.loadingState,_that.moderationStatus,_that.uploadProgress,_that.errorMessage,_that.moderationMessage,_that.createdPost,_that.validationResults);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PostFormData formData,  LoadingState loadingState,  ModerationStatus moderationStatus,  double uploadProgress,  String? errorMessage,  String? moderationMessage,  PostCreation? createdPost,  Map<String, PerspectiveResult> validationResults)?  $default,) {final _that = this;
switch (_that) {
case _CreatePostState() when $default != null:
return $default(_that.formData,_that.loadingState,_that.moderationStatus,_that.uploadProgress,_that.errorMessage,_that.moderationMessage,_that.createdPost,_that.validationResults);case _:
  return null;

}
}

}

/// @nodoc


class _CreatePostState extends CreatePostState {
  const _CreatePostState({this.formData = const PostFormData(), this.loadingState = LoadingState.idle, this.moderationStatus = ModerationStatus.pending, this.uploadProgress = 0.0, this.errorMessage, this.moderationMessage, this.createdPost, final  Map<String, PerspectiveResult> validationResults = const {}}): _validationResults = validationResults,super._();
  

@override@JsonKey() final  PostFormData formData;
@override@JsonKey() final  LoadingState loadingState;
@override@JsonKey() final  ModerationStatus moderationStatus;
@override@JsonKey() final  double uploadProgress;
@override final  String? errorMessage;
@override final  String? moderationMessage;
@override final  PostCreation? createdPost;
 final  Map<String, PerspectiveResult> _validationResults;
@override@JsonKey() Map<String, PerspectiveResult> get validationResults {
  if (_validationResults is EqualUnmodifiableMapView) return _validationResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_validationResults);
}


/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreatePostStateCopyWith<_CreatePostState> get copyWith => __$CreatePostStateCopyWithImpl<_CreatePostState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreatePostState&&(identical(other.formData, formData) || other.formData == formData)&&(identical(other.loadingState, loadingState) || other.loadingState == loadingState)&&(identical(other.moderationStatus, moderationStatus) || other.moderationStatus == moderationStatus)&&(identical(other.uploadProgress, uploadProgress) || other.uploadProgress == uploadProgress)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.moderationMessage, moderationMessage) || other.moderationMessage == moderationMessage)&&(identical(other.createdPost, createdPost) || other.createdPost == createdPost)&&const DeepCollectionEquality().equals(other._validationResults, _validationResults));
}


@override
int get hashCode => Object.hash(runtimeType,formData,loadingState,moderationStatus,uploadProgress,errorMessage,moderationMessage,createdPost,const DeepCollectionEquality().hash(_validationResults));

@override
String toString() {
  return 'CreatePostState(formData: $formData, loadingState: $loadingState, moderationStatus: $moderationStatus, uploadProgress: $uploadProgress, errorMessage: $errorMessage, moderationMessage: $moderationMessage, createdPost: $createdPost, validationResults: $validationResults)';
}


}

/// @nodoc
abstract mixin class _$CreatePostStateCopyWith<$Res> implements $CreatePostStateCopyWith<$Res> {
  factory _$CreatePostStateCopyWith(_CreatePostState value, $Res Function(_CreatePostState) _then) = __$CreatePostStateCopyWithImpl;
@override @useResult
$Res call({
 PostFormData formData, LoadingState loadingState, ModerationStatus moderationStatus, double uploadProgress, String? errorMessage, String? moderationMessage, PostCreation? createdPost, Map<String, PerspectiveResult> validationResults
});


@override $PostFormDataCopyWith<$Res> get formData;@override $PostCreationCopyWith<$Res>? get createdPost;

}
/// @nodoc
class __$CreatePostStateCopyWithImpl<$Res>
    implements _$CreatePostStateCopyWith<$Res> {
  __$CreatePostStateCopyWithImpl(this._self, this._then);

  final _CreatePostState _self;
  final $Res Function(_CreatePostState) _then;

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? formData = null,Object? loadingState = null,Object? moderationStatus = null,Object? uploadProgress = null,Object? errorMessage = freezed,Object? moderationMessage = freezed,Object? createdPost = freezed,Object? validationResults = null,}) {
  return _then(_CreatePostState(
formData: null == formData ? _self.formData : formData // ignore: cast_nullable_to_non_nullable
as PostFormData,loadingState: null == loadingState ? _self.loadingState : loadingState // ignore: cast_nullable_to_non_nullable
as LoadingState,moderationStatus: null == moderationStatus ? _self.moderationStatus : moderationStatus // ignore: cast_nullable_to_non_nullable
as ModerationStatus,uploadProgress: null == uploadProgress ? _self.uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as double,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,moderationMessage: freezed == moderationMessage ? _self.moderationMessage : moderationMessage // ignore: cast_nullable_to_non_nullable
as String?,createdPost: freezed == createdPost ? _self.createdPost : createdPost // ignore: cast_nullable_to_non_nullable
as PostCreation?,validationResults: null == validationResults ? _self._validationResults : validationResults // ignore: cast_nullable_to_non_nullable
as Map<String, PerspectiveResult>,
  ));
}

/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostFormDataCopyWith<$Res> get formData {
  
  return $PostFormDataCopyWith<$Res>(_self.formData, (value) {
    return _then(_self.copyWith(formData: value));
  });
}/// Create a copy of CreatePostState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PostCreationCopyWith<$Res>? get createdPost {
    if (_self.createdPost == null) {
    return null;
  }

  return $PostCreationCopyWith<$Res>(_self.createdPost!, (value) {
    return _then(_self.copyWith(createdPost: value));
  });
}
}

// dart format on
