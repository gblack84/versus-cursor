// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'creation_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$CreationFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreationFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreationFailure()';
}


}

/// @nodoc
class $CreationFailureCopyWith<$Res>  {
$CreationFailureCopyWith(CreationFailure _, $Res Function(CreationFailure) __);
}


/// Adds pattern-matching-related methods to [CreationFailure].
extension CreationFailurePatterns on CreationFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( CreateContentFailed value)?  createContentFailed,TResult Function( ImageUploadFailed value)?  imageUploadFailed,TResult Function( ModerationFailed value)?  moderationFailed,TResult Function( TargetAudienceFailed value)?  targetAudienceFailed,TResult Function( CreationValidationFailed value)?  creationValidationFailed,TResult Function( PostCreationRepositoryFailed value)?  postCreationRepositoryFailed,TResult Function( MediaRepositoryFailed value)?  mediaRepositoryFailed,TResult Function( MetricsRepositoryFailed value)?  metricsRepositoryFailed,TResult Function( ModerationRepositoryFailed value)?  moderationRepositoryFailed,TResult Function( VisibilityRepositoryFailed value)?  visibilityRepositoryFailed,TResult Function( FirestoreWriteFailed value)?  firestoreWriteFailed,TResult Function( AIModerationFailed value)?  aiModerationFailed,TResult Function( MediaProcessingFailed value)?  mediaProcessingFailed,TResult Function( AudienceConfigurationFailed value)?  audienceConfigurationFailed,TResult Function( PostValidationFailed value)?  postValidationFailed,required TResult orElse(),}){
final _that = this;
switch (_that) {
case CreateContentFailed() when createContentFailed != null:
return createContentFailed(_that);case ImageUploadFailed() when imageUploadFailed != null:
return imageUploadFailed(_that);case ModerationFailed() when moderationFailed != null:
return moderationFailed(_that);case TargetAudienceFailed() when targetAudienceFailed != null:
return targetAudienceFailed(_that);case CreationValidationFailed() when creationValidationFailed != null:
return creationValidationFailed(_that);case PostCreationRepositoryFailed() when postCreationRepositoryFailed != null:
return postCreationRepositoryFailed(_that);case MediaRepositoryFailed() when mediaRepositoryFailed != null:
return mediaRepositoryFailed(_that);case MetricsRepositoryFailed() when metricsRepositoryFailed != null:
return metricsRepositoryFailed(_that);case ModerationRepositoryFailed() when moderationRepositoryFailed != null:
return moderationRepositoryFailed(_that);case VisibilityRepositoryFailed() when visibilityRepositoryFailed != null:
return visibilityRepositoryFailed(_that);case FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that);case AIModerationFailed() when aiModerationFailed != null:
return aiModerationFailed(_that);case MediaProcessingFailed() when mediaProcessingFailed != null:
return mediaProcessingFailed(_that);case AudienceConfigurationFailed() when audienceConfigurationFailed != null:
return audienceConfigurationFailed(_that);case PostValidationFailed() when postValidationFailed != null:
return postValidationFailed(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( CreateContentFailed value)  createContentFailed,required TResult Function( ImageUploadFailed value)  imageUploadFailed,required TResult Function( ModerationFailed value)  moderationFailed,required TResult Function( TargetAudienceFailed value)  targetAudienceFailed,required TResult Function( CreationValidationFailed value)  creationValidationFailed,required TResult Function( PostCreationRepositoryFailed value)  postCreationRepositoryFailed,required TResult Function( MediaRepositoryFailed value)  mediaRepositoryFailed,required TResult Function( MetricsRepositoryFailed value)  metricsRepositoryFailed,required TResult Function( ModerationRepositoryFailed value)  moderationRepositoryFailed,required TResult Function( VisibilityRepositoryFailed value)  visibilityRepositoryFailed,required TResult Function( FirestoreWriteFailed value)  firestoreWriteFailed,required TResult Function( AIModerationFailed value)  aiModerationFailed,required TResult Function( MediaProcessingFailed value)  mediaProcessingFailed,required TResult Function( AudienceConfigurationFailed value)  audienceConfigurationFailed,required TResult Function( PostValidationFailed value)  postValidationFailed,}){
final _that = this;
switch (_that) {
case CreateContentFailed():
return createContentFailed(_that);case ImageUploadFailed():
return imageUploadFailed(_that);case ModerationFailed():
return moderationFailed(_that);case TargetAudienceFailed():
return targetAudienceFailed(_that);case CreationValidationFailed():
return creationValidationFailed(_that);case PostCreationRepositoryFailed():
return postCreationRepositoryFailed(_that);case MediaRepositoryFailed():
return mediaRepositoryFailed(_that);case MetricsRepositoryFailed():
return metricsRepositoryFailed(_that);case ModerationRepositoryFailed():
return moderationRepositoryFailed(_that);case VisibilityRepositoryFailed():
return visibilityRepositoryFailed(_that);case FirestoreWriteFailed():
return firestoreWriteFailed(_that);case AIModerationFailed():
return aiModerationFailed(_that);case MediaProcessingFailed():
return mediaProcessingFailed(_that);case AudienceConfigurationFailed():
return audienceConfigurationFailed(_that);case PostValidationFailed():
return postValidationFailed(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( CreateContentFailed value)?  createContentFailed,TResult? Function( ImageUploadFailed value)?  imageUploadFailed,TResult? Function( ModerationFailed value)?  moderationFailed,TResult? Function( TargetAudienceFailed value)?  targetAudienceFailed,TResult? Function( CreationValidationFailed value)?  creationValidationFailed,TResult? Function( PostCreationRepositoryFailed value)?  postCreationRepositoryFailed,TResult? Function( MediaRepositoryFailed value)?  mediaRepositoryFailed,TResult? Function( MetricsRepositoryFailed value)?  metricsRepositoryFailed,TResult? Function( ModerationRepositoryFailed value)?  moderationRepositoryFailed,TResult? Function( VisibilityRepositoryFailed value)?  visibilityRepositoryFailed,TResult? Function( FirestoreWriteFailed value)?  firestoreWriteFailed,TResult? Function( AIModerationFailed value)?  aiModerationFailed,TResult? Function( MediaProcessingFailed value)?  mediaProcessingFailed,TResult? Function( AudienceConfigurationFailed value)?  audienceConfigurationFailed,TResult? Function( PostValidationFailed value)?  postValidationFailed,}){
final _that = this;
switch (_that) {
case CreateContentFailed() when createContentFailed != null:
return createContentFailed(_that);case ImageUploadFailed() when imageUploadFailed != null:
return imageUploadFailed(_that);case ModerationFailed() when moderationFailed != null:
return moderationFailed(_that);case TargetAudienceFailed() when targetAudienceFailed != null:
return targetAudienceFailed(_that);case CreationValidationFailed() when creationValidationFailed != null:
return creationValidationFailed(_that);case PostCreationRepositoryFailed() when postCreationRepositoryFailed != null:
return postCreationRepositoryFailed(_that);case MediaRepositoryFailed() when mediaRepositoryFailed != null:
return mediaRepositoryFailed(_that);case MetricsRepositoryFailed() when metricsRepositoryFailed != null:
return metricsRepositoryFailed(_that);case ModerationRepositoryFailed() when moderationRepositoryFailed != null:
return moderationRepositoryFailed(_that);case VisibilityRepositoryFailed() when visibilityRepositoryFailed != null:
return visibilityRepositoryFailed(_that);case FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that);case AIModerationFailed() when aiModerationFailed != null:
return aiModerationFailed(_that);case MediaProcessingFailed() when mediaProcessingFailed != null:
return mediaProcessingFailed(_that);case AudienceConfigurationFailed() when audienceConfigurationFailed != null:
return audienceConfigurationFailed(_that);case PostValidationFailed() when postValidationFailed != null:
return postValidationFailed(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  createContentFailed,TResult Function()?  imageUploadFailed,TResult Function( List<String> rejectedReasons)?  moderationFailed,TResult Function()?  targetAudienceFailed,TResult Function( Map<String, String> fieldErrors)?  creationValidationFailed,TResult Function( String operation,  String? postId)?  postCreationRepositoryFailed,TResult Function( String mediaType,  List<String> failedPaths)?  mediaRepositoryFailed,TResult Function( String metricType)?  metricsRepositoryFailed,TResult Function( String moderationStep,  List<String> rejectedReasons)?  moderationRepositoryFailed,TResult Function( String visibility)?  visibilityRepositoryFailed,TResult Function( String collectionPath,  String operation,  Map<String, dynamic>? attemptedData,  String? code)?  firestoreWriteFailed,TResult Function( String aiProvider,  double confidenceScore,  List<String> detectedCategories,  String? suggestions,  List<String> rejectedReasons)?  aiModerationFailed,TResult Function( MediaProcessingStep failedStep,  List<String> affectedFiles,  String? details)?  mediaProcessingFailed,TResult Function( String invalidField,  dynamic attemptedValue,  String validationRule)?  audienceConfigurationFailed,TResult Function( List<String> missingFields,  List<String> invalidFields,  Map<String, String> fieldErrors)?  postValidationFailed,required TResult orElse(),}) {final _that = this;
switch (_that) {
case CreateContentFailed() when createContentFailed != null:
return createContentFailed();case ImageUploadFailed() when imageUploadFailed != null:
return imageUploadFailed();case ModerationFailed() when moderationFailed != null:
return moderationFailed(_that.rejectedReasons);case TargetAudienceFailed() when targetAudienceFailed != null:
return targetAudienceFailed();case CreationValidationFailed() when creationValidationFailed != null:
return creationValidationFailed(_that.fieldErrors);case PostCreationRepositoryFailed() when postCreationRepositoryFailed != null:
return postCreationRepositoryFailed(_that.operation,_that.postId);case MediaRepositoryFailed() when mediaRepositoryFailed != null:
return mediaRepositoryFailed(_that.mediaType,_that.failedPaths);case MetricsRepositoryFailed() when metricsRepositoryFailed != null:
return metricsRepositoryFailed(_that.metricType);case ModerationRepositoryFailed() when moderationRepositoryFailed != null:
return moderationRepositoryFailed(_that.moderationStep,_that.rejectedReasons);case VisibilityRepositoryFailed() when visibilityRepositoryFailed != null:
return visibilityRepositoryFailed(_that.visibility);case FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that.collectionPath,_that.operation,_that.attemptedData,_that.code);case AIModerationFailed() when aiModerationFailed != null:
return aiModerationFailed(_that.aiProvider,_that.confidenceScore,_that.detectedCategories,_that.suggestions,_that.rejectedReasons);case MediaProcessingFailed() when mediaProcessingFailed != null:
return mediaProcessingFailed(_that.failedStep,_that.affectedFiles,_that.details);case AudienceConfigurationFailed() when audienceConfigurationFailed != null:
return audienceConfigurationFailed(_that.invalidField,_that.attemptedValue,_that.validationRule);case PostValidationFailed() when postValidationFailed != null:
return postValidationFailed(_that.missingFields,_that.invalidFields,_that.fieldErrors);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  createContentFailed,required TResult Function()  imageUploadFailed,required TResult Function( List<String> rejectedReasons)  moderationFailed,required TResult Function()  targetAudienceFailed,required TResult Function( Map<String, String> fieldErrors)  creationValidationFailed,required TResult Function( String operation,  String? postId)  postCreationRepositoryFailed,required TResult Function( String mediaType,  List<String> failedPaths)  mediaRepositoryFailed,required TResult Function( String metricType)  metricsRepositoryFailed,required TResult Function( String moderationStep,  List<String> rejectedReasons)  moderationRepositoryFailed,required TResult Function( String visibility)  visibilityRepositoryFailed,required TResult Function( String collectionPath,  String operation,  Map<String, dynamic>? attemptedData,  String? code)  firestoreWriteFailed,required TResult Function( String aiProvider,  double confidenceScore,  List<String> detectedCategories,  String? suggestions,  List<String> rejectedReasons)  aiModerationFailed,required TResult Function( MediaProcessingStep failedStep,  List<String> affectedFiles,  String? details)  mediaProcessingFailed,required TResult Function( String invalidField,  dynamic attemptedValue,  String validationRule)  audienceConfigurationFailed,required TResult Function( List<String> missingFields,  List<String> invalidFields,  Map<String, String> fieldErrors)  postValidationFailed,}) {final _that = this;
switch (_that) {
case CreateContentFailed():
return createContentFailed();case ImageUploadFailed():
return imageUploadFailed();case ModerationFailed():
return moderationFailed(_that.rejectedReasons);case TargetAudienceFailed():
return targetAudienceFailed();case CreationValidationFailed():
return creationValidationFailed(_that.fieldErrors);case PostCreationRepositoryFailed():
return postCreationRepositoryFailed(_that.operation,_that.postId);case MediaRepositoryFailed():
return mediaRepositoryFailed(_that.mediaType,_that.failedPaths);case MetricsRepositoryFailed():
return metricsRepositoryFailed(_that.metricType);case ModerationRepositoryFailed():
return moderationRepositoryFailed(_that.moderationStep,_that.rejectedReasons);case VisibilityRepositoryFailed():
return visibilityRepositoryFailed(_that.visibility);case FirestoreWriteFailed():
return firestoreWriteFailed(_that.collectionPath,_that.operation,_that.attemptedData,_that.code);case AIModerationFailed():
return aiModerationFailed(_that.aiProvider,_that.confidenceScore,_that.detectedCategories,_that.suggestions,_that.rejectedReasons);case MediaProcessingFailed():
return mediaProcessingFailed(_that.failedStep,_that.affectedFiles,_that.details);case AudienceConfigurationFailed():
return audienceConfigurationFailed(_that.invalidField,_that.attemptedValue,_that.validationRule);case PostValidationFailed():
return postValidationFailed(_that.missingFields,_that.invalidFields,_that.fieldErrors);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  createContentFailed,TResult? Function()?  imageUploadFailed,TResult? Function( List<String> rejectedReasons)?  moderationFailed,TResult? Function()?  targetAudienceFailed,TResult? Function( Map<String, String> fieldErrors)?  creationValidationFailed,TResult? Function( String operation,  String? postId)?  postCreationRepositoryFailed,TResult? Function( String mediaType,  List<String> failedPaths)?  mediaRepositoryFailed,TResult? Function( String metricType)?  metricsRepositoryFailed,TResult? Function( String moderationStep,  List<String> rejectedReasons)?  moderationRepositoryFailed,TResult? Function( String visibility)?  visibilityRepositoryFailed,TResult? Function( String collectionPath,  String operation,  Map<String, dynamic>? attemptedData,  String? code)?  firestoreWriteFailed,TResult? Function( String aiProvider,  double confidenceScore,  List<String> detectedCategories,  String? suggestions,  List<String> rejectedReasons)?  aiModerationFailed,TResult? Function( MediaProcessingStep failedStep,  List<String> affectedFiles,  String? details)?  mediaProcessingFailed,TResult? Function( String invalidField,  dynamic attemptedValue,  String validationRule)?  audienceConfigurationFailed,TResult? Function( List<String> missingFields,  List<String> invalidFields,  Map<String, String> fieldErrors)?  postValidationFailed,}) {final _that = this;
switch (_that) {
case CreateContentFailed() when createContentFailed != null:
return createContentFailed();case ImageUploadFailed() when imageUploadFailed != null:
return imageUploadFailed();case ModerationFailed() when moderationFailed != null:
return moderationFailed(_that.rejectedReasons);case TargetAudienceFailed() when targetAudienceFailed != null:
return targetAudienceFailed();case CreationValidationFailed() when creationValidationFailed != null:
return creationValidationFailed(_that.fieldErrors);case PostCreationRepositoryFailed() when postCreationRepositoryFailed != null:
return postCreationRepositoryFailed(_that.operation,_that.postId);case MediaRepositoryFailed() when mediaRepositoryFailed != null:
return mediaRepositoryFailed(_that.mediaType,_that.failedPaths);case MetricsRepositoryFailed() when metricsRepositoryFailed != null:
return metricsRepositoryFailed(_that.metricType);case ModerationRepositoryFailed() when moderationRepositoryFailed != null:
return moderationRepositoryFailed(_that.moderationStep,_that.rejectedReasons);case VisibilityRepositoryFailed() when visibilityRepositoryFailed != null:
return visibilityRepositoryFailed(_that.visibility);case FirestoreWriteFailed() when firestoreWriteFailed != null:
return firestoreWriteFailed(_that.collectionPath,_that.operation,_that.attemptedData,_that.code);case AIModerationFailed() when aiModerationFailed != null:
return aiModerationFailed(_that.aiProvider,_that.confidenceScore,_that.detectedCategories,_that.suggestions,_that.rejectedReasons);case MediaProcessingFailed() when mediaProcessingFailed != null:
return mediaProcessingFailed(_that.failedStep,_that.affectedFiles,_that.details);case AudienceConfigurationFailed() when audienceConfigurationFailed != null:
return audienceConfigurationFailed(_that.invalidField,_that.attemptedValue,_that.validationRule);case PostValidationFailed() when postValidationFailed != null:
return postValidationFailed(_that.missingFields,_that.invalidFields,_that.fieldErrors);case _:
  return null;

}
}

}

/// @nodoc


class CreateContentFailed extends CreationFailure {
  const CreateContentFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateContentFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreationFailure.createContentFailed()';
}


}




/// @nodoc


class ImageUploadFailed extends CreationFailure {
  const ImageUploadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageUploadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreationFailure.imageUploadFailed()';
}


}




/// @nodoc


class ModerationFailed extends CreationFailure {
  const ModerationFailed({final  List<String> rejectedReasons = const []}): _rejectedReasons = rejectedReasons,super._();
  

 final  List<String> _rejectedReasons;
@JsonKey() List<String> get rejectedReasons {
  if (_rejectedReasons is EqualUnmodifiableListView) return _rejectedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectedReasons);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationFailedCopyWith<ModerationFailed> get copyWith => _$ModerationFailedCopyWithImpl<ModerationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationFailed&&const DeepCollectionEquality().equals(other._rejectedReasons, _rejectedReasons));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_rejectedReasons));

@override
String toString() {
  return 'CreationFailure.moderationFailed(rejectedReasons: $rejectedReasons)';
}


}

/// @nodoc
abstract mixin class $ModerationFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $ModerationFailedCopyWith(ModerationFailed value, $Res Function(ModerationFailed) _then) = _$ModerationFailedCopyWithImpl;
@useResult
$Res call({
 List<String> rejectedReasons
});




}
/// @nodoc
class _$ModerationFailedCopyWithImpl<$Res>
    implements $ModerationFailedCopyWith<$Res> {
  _$ModerationFailedCopyWithImpl(this._self, this._then);

  final ModerationFailed _self;
  final $Res Function(ModerationFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? rejectedReasons = null,}) {
  return _then(ModerationFailed(
rejectedReasons: null == rejectedReasons ? _self._rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class TargetAudienceFailed extends CreationFailure {
  const TargetAudienceFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TargetAudienceFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'CreationFailure.targetAudienceFailed()';
}


}




/// @nodoc


class CreationValidationFailed extends CreationFailure {
  const CreationValidationFailed({final  Map<String, String> fieldErrors = const {}}): _fieldErrors = fieldErrors,super._();
  

 final  Map<String, String> _fieldErrors;
@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreationValidationFailedCopyWith<CreationValidationFailed> get copyWith => _$CreationValidationFailedCopyWithImpl<CreationValidationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreationValidationFailed&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'CreationFailure.creationValidationFailed(fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $CreationValidationFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $CreationValidationFailedCopyWith(CreationValidationFailed value, $Res Function(CreationValidationFailed) _then) = _$CreationValidationFailedCopyWithImpl;
@useResult
$Res call({
 Map<String, String> fieldErrors
});




}
/// @nodoc
class _$CreationValidationFailedCopyWithImpl<$Res>
    implements $CreationValidationFailedCopyWith<$Res> {
  _$CreationValidationFailedCopyWithImpl(this._self, this._then);

  final CreationValidationFailed _self;
  final $Res Function(CreationValidationFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? fieldErrors = null,}) {
  return _then(CreationValidationFailed(
fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

/// @nodoc


class PostCreationRepositoryFailed extends CreationFailure {
  const PostCreationRepositoryFailed({required this.operation, this.postId}): super._();
  

 final  String operation;
// 'create', 'update', 'delete'
 final  String? postId;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostCreationRepositoryFailedCopyWith<PostCreationRepositoryFailed> get copyWith => _$PostCreationRepositoryFailedCopyWithImpl<PostCreationRepositoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostCreationRepositoryFailed&&(identical(other.operation, operation) || other.operation == operation)&&(identical(other.postId, postId) || other.postId == postId));
}


@override
int get hashCode => Object.hash(runtimeType,operation,postId);

@override
String toString() {
  return 'CreationFailure.postCreationRepositoryFailed(operation: $operation, postId: $postId)';
}


}

/// @nodoc
abstract mixin class $PostCreationRepositoryFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $PostCreationRepositoryFailedCopyWith(PostCreationRepositoryFailed value, $Res Function(PostCreationRepositoryFailed) _then) = _$PostCreationRepositoryFailedCopyWithImpl;
@useResult
$Res call({
 String operation, String? postId
});




}
/// @nodoc
class _$PostCreationRepositoryFailedCopyWithImpl<$Res>
    implements $PostCreationRepositoryFailedCopyWith<$Res> {
  _$PostCreationRepositoryFailedCopyWithImpl(this._self, this._then);

  final PostCreationRepositoryFailed _self;
  final $Res Function(PostCreationRepositoryFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? operation = null,Object? postId = freezed,}) {
  return _then(PostCreationRepositoryFailed(
operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,postId: freezed == postId ? _self.postId : postId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class MediaRepositoryFailed extends CreationFailure {
  const MediaRepositoryFailed({required this.mediaType, required final  List<String> failedPaths}): _failedPaths = failedPaths,super._();
  

 final  String mediaType;
// 'image', 'video'
 final  List<String> _failedPaths;
// 'image', 'video'
 List<String> get failedPaths {
  if (_failedPaths is EqualUnmodifiableListView) return _failedPaths;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_failedPaths);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaRepositoryFailedCopyWith<MediaRepositoryFailed> get copyWith => _$MediaRepositoryFailedCopyWithImpl<MediaRepositoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaRepositoryFailed&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&const DeepCollectionEquality().equals(other._failedPaths, _failedPaths));
}


@override
int get hashCode => Object.hash(runtimeType,mediaType,const DeepCollectionEquality().hash(_failedPaths));

@override
String toString() {
  return 'CreationFailure.mediaRepositoryFailed(mediaType: $mediaType, failedPaths: $failedPaths)';
}


}

/// @nodoc
abstract mixin class $MediaRepositoryFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $MediaRepositoryFailedCopyWith(MediaRepositoryFailed value, $Res Function(MediaRepositoryFailed) _then) = _$MediaRepositoryFailedCopyWithImpl;
@useResult
$Res call({
 String mediaType, List<String> failedPaths
});




}
/// @nodoc
class _$MediaRepositoryFailedCopyWithImpl<$Res>
    implements $MediaRepositoryFailedCopyWith<$Res> {
  _$MediaRepositoryFailedCopyWithImpl(this._self, this._then);

  final MediaRepositoryFailed _self;
  final $Res Function(MediaRepositoryFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mediaType = null,Object? failedPaths = null,}) {
  return _then(MediaRepositoryFailed(
mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,failedPaths: null == failedPaths ? _self._failedPaths : failedPaths // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class MetricsRepositoryFailed extends CreationFailure {
  const MetricsRepositoryFailed({required this.metricType}): super._();
  

 final  String metricType;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MetricsRepositoryFailedCopyWith<MetricsRepositoryFailed> get copyWith => _$MetricsRepositoryFailedCopyWithImpl<MetricsRepositoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MetricsRepositoryFailed&&(identical(other.metricType, metricType) || other.metricType == metricType));
}


@override
int get hashCode => Object.hash(runtimeType,metricType);

@override
String toString() {
  return 'CreationFailure.metricsRepositoryFailed(metricType: $metricType)';
}


}

/// @nodoc
abstract mixin class $MetricsRepositoryFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $MetricsRepositoryFailedCopyWith(MetricsRepositoryFailed value, $Res Function(MetricsRepositoryFailed) _then) = _$MetricsRepositoryFailedCopyWithImpl;
@useResult
$Res call({
 String metricType
});




}
/// @nodoc
class _$MetricsRepositoryFailedCopyWithImpl<$Res>
    implements $MetricsRepositoryFailedCopyWith<$Res> {
  _$MetricsRepositoryFailedCopyWithImpl(this._self, this._then);

  final MetricsRepositoryFailed _self;
  final $Res Function(MetricsRepositoryFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? metricType = null,}) {
  return _then(MetricsRepositoryFailed(
metricType: null == metricType ? _self.metricType : metricType // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ModerationRepositoryFailed extends CreationFailure {
  const ModerationRepositoryFailed({required this.moderationStep, final  List<String> rejectedReasons = const []}): _rejectedReasons = rejectedReasons,super._();
  

 final  String moderationStep;
// 'text', 'image', 'ai'
 final  List<String> _rejectedReasons;
// 'text', 'image', 'ai'
@JsonKey() List<String> get rejectedReasons {
  if (_rejectedReasons is EqualUnmodifiableListView) return _rejectedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectedReasons);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ModerationRepositoryFailedCopyWith<ModerationRepositoryFailed> get copyWith => _$ModerationRepositoryFailedCopyWithImpl<ModerationRepositoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ModerationRepositoryFailed&&(identical(other.moderationStep, moderationStep) || other.moderationStep == moderationStep)&&const DeepCollectionEquality().equals(other._rejectedReasons, _rejectedReasons));
}


@override
int get hashCode => Object.hash(runtimeType,moderationStep,const DeepCollectionEquality().hash(_rejectedReasons));

@override
String toString() {
  return 'CreationFailure.moderationRepositoryFailed(moderationStep: $moderationStep, rejectedReasons: $rejectedReasons)';
}


}

/// @nodoc
abstract mixin class $ModerationRepositoryFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $ModerationRepositoryFailedCopyWith(ModerationRepositoryFailed value, $Res Function(ModerationRepositoryFailed) _then) = _$ModerationRepositoryFailedCopyWithImpl;
@useResult
$Res call({
 String moderationStep, List<String> rejectedReasons
});




}
/// @nodoc
class _$ModerationRepositoryFailedCopyWithImpl<$Res>
    implements $ModerationRepositoryFailedCopyWith<$Res> {
  _$ModerationRepositoryFailedCopyWithImpl(this._self, this._then);

  final ModerationRepositoryFailed _self;
  final $Res Function(ModerationRepositoryFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? moderationStep = null,Object? rejectedReasons = null,}) {
  return _then(ModerationRepositoryFailed(
moderationStep: null == moderationStep ? _self.moderationStep : moderationStep // ignore: cast_nullable_to_non_nullable
as String,rejectedReasons: null == rejectedReasons ? _self._rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class VisibilityRepositoryFailed extends CreationFailure {
  const VisibilityRepositoryFailed({required this.visibility}): super._();
  

 final  String visibility;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VisibilityRepositoryFailedCopyWith<VisibilityRepositoryFailed> get copyWith => _$VisibilityRepositoryFailedCopyWithImpl<VisibilityRepositoryFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VisibilityRepositoryFailed&&(identical(other.visibility, visibility) || other.visibility == visibility));
}


@override
int get hashCode => Object.hash(runtimeType,visibility);

@override
String toString() {
  return 'CreationFailure.visibilityRepositoryFailed(visibility: $visibility)';
}


}

/// @nodoc
abstract mixin class $VisibilityRepositoryFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $VisibilityRepositoryFailedCopyWith(VisibilityRepositoryFailed value, $Res Function(VisibilityRepositoryFailed) _then) = _$VisibilityRepositoryFailedCopyWithImpl;
@useResult
$Res call({
 String visibility
});




}
/// @nodoc
class _$VisibilityRepositoryFailedCopyWithImpl<$Res>
    implements $VisibilityRepositoryFailedCopyWith<$Res> {
  _$VisibilityRepositoryFailedCopyWithImpl(this._self, this._then);

  final VisibilityRepositoryFailed _self;
  final $Res Function(VisibilityRepositoryFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? visibility = null,}) {
  return _then(VisibilityRepositoryFailed(
visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class FirestoreWriteFailed extends CreationFailure {
  const FirestoreWriteFailed({required this.collectionPath, required this.operation, final  Map<String, dynamic>? attemptedData, this.code}): _attemptedData = attemptedData,super._();
  

 final  String collectionPath;
 final  String operation;
// 'add', 'update', 'delete'
 final  Map<String, dynamic>? _attemptedData;
// 'add', 'update', 'delete'
 Map<String, dynamic>? get attemptedData {
  final value = _attemptedData;
  if (value == null) return null;
  if (_attemptedData is EqualUnmodifiableMapView) return _attemptedData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  String? code;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FirestoreWriteFailedCopyWith<FirestoreWriteFailed> get copyWith => _$FirestoreWriteFailedCopyWithImpl<FirestoreWriteFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FirestoreWriteFailed&&(identical(other.collectionPath, collectionPath) || other.collectionPath == collectionPath)&&(identical(other.operation, operation) || other.operation == operation)&&const DeepCollectionEquality().equals(other._attemptedData, _attemptedData)&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,collectionPath,operation,const DeepCollectionEquality().hash(_attemptedData),code);

@override
String toString() {
  return 'CreationFailure.firestoreWriteFailed(collectionPath: $collectionPath, operation: $operation, attemptedData: $attemptedData, code: $code)';
}


}

/// @nodoc
abstract mixin class $FirestoreWriteFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $FirestoreWriteFailedCopyWith(FirestoreWriteFailed value, $Res Function(FirestoreWriteFailed) _then) = _$FirestoreWriteFailedCopyWithImpl;
@useResult
$Res call({
 String collectionPath, String operation, Map<String, dynamic>? attemptedData, String? code
});




}
/// @nodoc
class _$FirestoreWriteFailedCopyWithImpl<$Res>
    implements $FirestoreWriteFailedCopyWith<$Res> {
  _$FirestoreWriteFailedCopyWithImpl(this._self, this._then);

  final FirestoreWriteFailed _self;
  final $Res Function(FirestoreWriteFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? collectionPath = null,Object? operation = null,Object? attemptedData = freezed,Object? code = freezed,}) {
  return _then(FirestoreWriteFailed(
collectionPath: null == collectionPath ? _self.collectionPath : collectionPath // ignore: cast_nullable_to_non_nullable
as String,operation: null == operation ? _self.operation : operation // ignore: cast_nullable_to_non_nullable
as String,attemptedData: freezed == attemptedData ? _self._attemptedData : attemptedData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,code: freezed == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AIModerationFailed extends CreationFailure {
  const AIModerationFailed({required this.aiProvider, required this.confidenceScore, required final  List<String> detectedCategories, this.suggestions, final  List<String> rejectedReasons = const []}): _detectedCategories = detectedCategories,_rejectedReasons = rejectedReasons,super._();
  

 final  String aiProvider;
// 'perspective', 'gemini', 'vision'
 final  double confidenceScore;
 final  List<String> _detectedCategories;
 List<String> get detectedCategories {
  if (_detectedCategories is EqualUnmodifiableListView) return _detectedCategories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_detectedCategories);
}

 final  String? suggestions;
 final  List<String> _rejectedReasons;
@JsonKey() List<String> get rejectedReasons {
  if (_rejectedReasons is EqualUnmodifiableListView) return _rejectedReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rejectedReasons);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AIModerationFailedCopyWith<AIModerationFailed> get copyWith => _$AIModerationFailedCopyWithImpl<AIModerationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIModerationFailed&&(identical(other.aiProvider, aiProvider) || other.aiProvider == aiProvider)&&(identical(other.confidenceScore, confidenceScore) || other.confidenceScore == confidenceScore)&&const DeepCollectionEquality().equals(other._detectedCategories, _detectedCategories)&&(identical(other.suggestions, suggestions) || other.suggestions == suggestions)&&const DeepCollectionEquality().equals(other._rejectedReasons, _rejectedReasons));
}


@override
int get hashCode => Object.hash(runtimeType,aiProvider,confidenceScore,const DeepCollectionEquality().hash(_detectedCategories),suggestions,const DeepCollectionEquality().hash(_rejectedReasons));

@override
String toString() {
  return 'CreationFailure.aiModerationFailed(aiProvider: $aiProvider, confidenceScore: $confidenceScore, detectedCategories: $detectedCategories, suggestions: $suggestions, rejectedReasons: $rejectedReasons)';
}


}

/// @nodoc
abstract mixin class $AIModerationFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $AIModerationFailedCopyWith(AIModerationFailed value, $Res Function(AIModerationFailed) _then) = _$AIModerationFailedCopyWithImpl;
@useResult
$Res call({
 String aiProvider, double confidenceScore, List<String> detectedCategories, String? suggestions, List<String> rejectedReasons
});




}
/// @nodoc
class _$AIModerationFailedCopyWithImpl<$Res>
    implements $AIModerationFailedCopyWith<$Res> {
  _$AIModerationFailedCopyWithImpl(this._self, this._then);

  final AIModerationFailed _self;
  final $Res Function(AIModerationFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? aiProvider = null,Object? confidenceScore = null,Object? detectedCategories = null,Object? suggestions = freezed,Object? rejectedReasons = null,}) {
  return _then(AIModerationFailed(
aiProvider: null == aiProvider ? _self.aiProvider : aiProvider // ignore: cast_nullable_to_non_nullable
as String,confidenceScore: null == confidenceScore ? _self.confidenceScore : confidenceScore // ignore: cast_nullable_to_non_nullable
as double,detectedCategories: null == detectedCategories ? _self._detectedCategories : detectedCategories // ignore: cast_nullable_to_non_nullable
as List<String>,suggestions: freezed == suggestions ? _self.suggestions : suggestions // ignore: cast_nullable_to_non_nullable
as String?,rejectedReasons: null == rejectedReasons ? _self._rejectedReasons : rejectedReasons // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}

/// @nodoc


class MediaProcessingFailed extends CreationFailure {
  const MediaProcessingFailed({required this.failedStep, required final  List<String> affectedFiles, this.details}): _affectedFiles = affectedFiles,super._();
  

 final  MediaProcessingStep failedStep;
 final  List<String> _affectedFiles;
 List<String> get affectedFiles {
  if (_affectedFiles is EqualUnmodifiableListView) return _affectedFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_affectedFiles);
}

 final  String? details;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaProcessingFailedCopyWith<MediaProcessingFailed> get copyWith => _$MediaProcessingFailedCopyWithImpl<MediaProcessingFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaProcessingFailed&&(identical(other.failedStep, failedStep) || other.failedStep == failedStep)&&const DeepCollectionEquality().equals(other._affectedFiles, _affectedFiles)&&(identical(other.details, details) || other.details == details));
}


@override
int get hashCode => Object.hash(runtimeType,failedStep,const DeepCollectionEquality().hash(_affectedFiles),details);

@override
String toString() {
  return 'CreationFailure.mediaProcessingFailed(failedStep: $failedStep, affectedFiles: $affectedFiles, details: $details)';
}


}

/// @nodoc
abstract mixin class $MediaProcessingFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $MediaProcessingFailedCopyWith(MediaProcessingFailed value, $Res Function(MediaProcessingFailed) _then) = _$MediaProcessingFailedCopyWithImpl;
@useResult
$Res call({
 MediaProcessingStep failedStep, List<String> affectedFiles, String? details
});




}
/// @nodoc
class _$MediaProcessingFailedCopyWithImpl<$Res>
    implements $MediaProcessingFailedCopyWith<$Res> {
  _$MediaProcessingFailedCopyWithImpl(this._self, this._then);

  final MediaProcessingFailed _self;
  final $Res Function(MediaProcessingFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failedStep = null,Object? affectedFiles = null,Object? details = freezed,}) {
  return _then(MediaProcessingFailed(
failedStep: null == failedStep ? _self.failedStep : failedStep // ignore: cast_nullable_to_non_nullable
as MediaProcessingStep,affectedFiles: null == affectedFiles ? _self._affectedFiles : affectedFiles // ignore: cast_nullable_to_non_nullable
as List<String>,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc


class AudienceConfigurationFailed extends CreationFailure {
  const AudienceConfigurationFailed({required this.invalidField, required this.attemptedValue, required this.validationRule}): super._();
  

 final  String invalidField;
 final  dynamic attemptedValue;
 final  String validationRule;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AudienceConfigurationFailedCopyWith<AudienceConfigurationFailed> get copyWith => _$AudienceConfigurationFailedCopyWithImpl<AudienceConfigurationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AudienceConfigurationFailed&&(identical(other.invalidField, invalidField) || other.invalidField == invalidField)&&const DeepCollectionEquality().equals(other.attemptedValue, attemptedValue)&&(identical(other.validationRule, validationRule) || other.validationRule == validationRule));
}


@override
int get hashCode => Object.hash(runtimeType,invalidField,const DeepCollectionEquality().hash(attemptedValue),validationRule);

@override
String toString() {
  return 'CreationFailure.audienceConfigurationFailed(invalidField: $invalidField, attemptedValue: $attemptedValue, validationRule: $validationRule)';
}


}

/// @nodoc
abstract mixin class $AudienceConfigurationFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $AudienceConfigurationFailedCopyWith(AudienceConfigurationFailed value, $Res Function(AudienceConfigurationFailed) _then) = _$AudienceConfigurationFailedCopyWithImpl;
@useResult
$Res call({
 String invalidField, dynamic attemptedValue, String validationRule
});




}
/// @nodoc
class _$AudienceConfigurationFailedCopyWithImpl<$Res>
    implements $AudienceConfigurationFailedCopyWith<$Res> {
  _$AudienceConfigurationFailedCopyWithImpl(this._self, this._then);

  final AudienceConfigurationFailed _self;
  final $Res Function(AudienceConfigurationFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? invalidField = null,Object? attemptedValue = freezed,Object? validationRule = null,}) {
  return _then(AudienceConfigurationFailed(
invalidField: null == invalidField ? _self.invalidField : invalidField // ignore: cast_nullable_to_non_nullable
as String,attemptedValue: freezed == attemptedValue ? _self.attemptedValue : attemptedValue // ignore: cast_nullable_to_non_nullable
as dynamic,validationRule: null == validationRule ? _self.validationRule : validationRule // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PostValidationFailed extends CreationFailure {
  const PostValidationFailed({required final  List<String> missingFields, required final  List<String> invalidFields, final  Map<String, String> fieldErrors = const {}}): _missingFields = missingFields,_invalidFields = invalidFields,_fieldErrors = fieldErrors,super._();
  

 final  List<String> _missingFields;
 List<String> get missingFields {
  if (_missingFields is EqualUnmodifiableListView) return _missingFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_missingFields);
}

 final  List<String> _invalidFields;
 List<String> get invalidFields {
  if (_invalidFields is EqualUnmodifiableListView) return _invalidFields;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_invalidFields);
}

 final  Map<String, String> _fieldErrors;
@JsonKey() Map<String, String> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableMapView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_fieldErrors);
}


/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PostValidationFailedCopyWith<PostValidationFailed> get copyWith => _$PostValidationFailedCopyWithImpl<PostValidationFailed>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PostValidationFailed&&const DeepCollectionEquality().equals(other._missingFields, _missingFields)&&const DeepCollectionEquality().equals(other._invalidFields, _invalidFields)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_missingFields),const DeepCollectionEquality().hash(_invalidFields),const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'CreationFailure.postValidationFailed(missingFields: $missingFields, invalidFields: $invalidFields, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $PostValidationFailedCopyWith<$Res> implements $CreationFailureCopyWith<$Res> {
  factory $PostValidationFailedCopyWith(PostValidationFailed value, $Res Function(PostValidationFailed) _then) = _$PostValidationFailedCopyWithImpl;
@useResult
$Res call({
 List<String> missingFields, List<String> invalidFields, Map<String, String> fieldErrors
});




}
/// @nodoc
class _$PostValidationFailedCopyWithImpl<$Res>
    implements $PostValidationFailedCopyWith<$Res> {
  _$PostValidationFailedCopyWithImpl(this._self, this._then);

  final PostValidationFailed _self;
  final $Res Function(PostValidationFailed) _then;

/// Create a copy of CreationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? missingFields = null,Object? invalidFields = null,Object? fieldErrors = null,}) {
  return _then(PostValidationFailed(
missingFields: null == missingFields ? _self._missingFields : missingFields // ignore: cast_nullable_to_non_nullable
as List<String>,invalidFields: null == invalidFields ? _self._invalidFields : invalidFields // ignore: cast_nullable_to_non_nullable
as List<String>,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as Map<String, String>,
  ));
}


}

// dart format on
