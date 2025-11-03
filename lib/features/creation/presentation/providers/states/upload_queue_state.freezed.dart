// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'upload_queue_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UploadTask {

 String get id; String get box; List<File> get files; DateTime get createdAt; UploadStatus get status; double get progress; List<String>? get uploadedUrls; String? get errorMessage;
/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadTaskCopyWith<UploadTask> get copyWith => _$UploadTaskCopyWithImpl<UploadTask>(this as UploadTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.box, box) || other.box == box)&&const DeepCollectionEquality().equals(other.files, files)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other.uploadedUrls, uploadedUrls)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,box,const DeepCollectionEquality().hash(files),createdAt,status,progress,const DeepCollectionEquality().hash(uploadedUrls),errorMessage);

@override
String toString() {
  return 'UploadTask(id: $id, box: $box, files: $files, createdAt: $createdAt, status: $status, progress: $progress, uploadedUrls: $uploadedUrls, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $UploadTaskCopyWith<$Res>  {
  factory $UploadTaskCopyWith(UploadTask value, $Res Function(UploadTask) _then) = _$UploadTaskCopyWithImpl;
@useResult
$Res call({
 String id, String box, List<File> files, DateTime createdAt, UploadStatus status, double progress, List<String>? uploadedUrls, String? errorMessage
});




}
/// @nodoc
class _$UploadTaskCopyWithImpl<$Res>
    implements $UploadTaskCopyWith<$Res> {
  _$UploadTaskCopyWithImpl(this._self, this._then);

  final UploadTask _self;
  final $Res Function(UploadTask) _then;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? box = null,Object? files = null,Object? createdAt = null,Object? status = null,Object? progress = null,Object? uploadedUrls = freezed,Object? errorMessage = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self.files : files // ignore: cast_nullable_to_non_nullable
as List<File>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,uploadedUrls: freezed == uploadedUrls ? _self.uploadedUrls : uploadedUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadTask].
extension UploadTaskPatterns on UploadTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadTask value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadTask value)  $default,){
final _that = this;
switch (_that) {
case _UploadTask():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadTask value)?  $default,){
final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String box,  List<File> files,  DateTime createdAt,  UploadStatus status,  double progress,  List<String>? uploadedUrls,  String? errorMessage)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that.id,_that.box,_that.files,_that.createdAt,_that.status,_that.progress,_that.uploadedUrls,_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String box,  List<File> files,  DateTime createdAt,  UploadStatus status,  double progress,  List<String>? uploadedUrls,  String? errorMessage)  $default,) {final _that = this;
switch (_that) {
case _UploadTask():
return $default(_that.id,_that.box,_that.files,_that.createdAt,_that.status,_that.progress,_that.uploadedUrls,_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String box,  List<File> files,  DateTime createdAt,  UploadStatus status,  double progress,  List<String>? uploadedUrls,  String? errorMessage)?  $default,) {final _that = this;
switch (_that) {
case _UploadTask() when $default != null:
return $default(_that.id,_that.box,_that.files,_that.createdAt,_that.status,_that.progress,_that.uploadedUrls,_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class _UploadTask extends UploadTask {
  const _UploadTask({required this.id, required this.box, required final  List<File> files, required this.createdAt, this.status = UploadStatus.pending, this.progress = 0.0, final  List<String>? uploadedUrls, this.errorMessage}): _files = files,_uploadedUrls = uploadedUrls,super._();
  

@override final  String id;
@override final  String box;
 final  List<File> _files;
@override List<File> get files {
  if (_files is EqualUnmodifiableListView) return _files;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_files);
}

@override final  DateTime createdAt;
@override@JsonKey() final  UploadStatus status;
@override@JsonKey() final  double progress;
 final  List<String>? _uploadedUrls;
@override List<String>? get uploadedUrls {
  final value = _uploadedUrls;
  if (value == null) return null;
  if (_uploadedUrls is EqualUnmodifiableListView) return _uploadedUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  String? errorMessage;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadTaskCopyWith<_UploadTask> get copyWith => __$UploadTaskCopyWithImpl<_UploadTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadTask&&(identical(other.id, id) || other.id == id)&&(identical(other.box, box) || other.box == box)&&const DeepCollectionEquality().equals(other._files, _files)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.progress, progress) || other.progress == progress)&&const DeepCollectionEquality().equals(other._uploadedUrls, _uploadedUrls)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,id,box,const DeepCollectionEquality().hash(_files),createdAt,status,progress,const DeepCollectionEquality().hash(_uploadedUrls),errorMessage);

@override
String toString() {
  return 'UploadTask(id: $id, box: $box, files: $files, createdAt: $createdAt, status: $status, progress: $progress, uploadedUrls: $uploadedUrls, errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class _$UploadTaskCopyWith<$Res> implements $UploadTaskCopyWith<$Res> {
  factory _$UploadTaskCopyWith(_UploadTask value, $Res Function(_UploadTask) _then) = __$UploadTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String box, List<File> files, DateTime createdAt, UploadStatus status, double progress, List<String>? uploadedUrls, String? errorMessage
});




}
/// @nodoc
class __$UploadTaskCopyWithImpl<$Res>
    implements _$UploadTaskCopyWith<$Res> {
  __$UploadTaskCopyWithImpl(this._self, this._then);

  final _UploadTask _self;
  final $Res Function(_UploadTask) _then;

/// Create a copy of UploadTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? box = null,Object? files = null,Object? createdAt = null,Object? status = null,Object? progress = null,Object? uploadedUrls = freezed,Object? errorMessage = freezed,}) {
  return _then(_UploadTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,box: null == box ? _self.box : box // ignore: cast_nullable_to_non_nullable
as String,files: null == files ? _self._files : files // ignore: cast_nullable_to_non_nullable
as List<File>,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as UploadStatus,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,uploadedUrls: freezed == uploadedUrls ? _self._uploadedUrls : uploadedUrls // ignore: cast_nullable_to_non_nullable
as List<String>?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$UploadError {

 String get taskId; String get message; DateTime get timestamp; int? get retryCount;
/// Create a copy of UploadError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadErrorCopyWith<UploadError> get copyWith => _$UploadErrorCopyWithImpl<UploadError>(this as UploadError, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadError&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,message,timestamp,retryCount);

@override
String toString() {
  return 'UploadError(taskId: $taskId, message: $message, timestamp: $timestamp, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class $UploadErrorCopyWith<$Res>  {
  factory $UploadErrorCopyWith(UploadError value, $Res Function(UploadError) _then) = _$UploadErrorCopyWithImpl;
@useResult
$Res call({
 String taskId, String message, DateTime timestamp, int? retryCount
});




}
/// @nodoc
class _$UploadErrorCopyWithImpl<$Res>
    implements $UploadErrorCopyWith<$Res> {
  _$UploadErrorCopyWithImpl(this._self, this._then);

  final UploadError _self;
  final $Res Function(UploadError) _then;

/// Create a copy of UploadError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? message = null,Object? timestamp = null,Object? retryCount = freezed,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: freezed == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadError].
extension UploadErrorPatterns on UploadError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadError value)  $default,){
final _that = this;
switch (_that) {
case _UploadError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadError value)?  $default,){
final _that = this;
switch (_that) {
case _UploadError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String message,  DateTime timestamp,  int? retryCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadError() when $default != null:
return $default(_that.taskId,_that.message,_that.timestamp,_that.retryCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String message,  DateTime timestamp,  int? retryCount)  $default,) {final _that = this;
switch (_that) {
case _UploadError():
return $default(_that.taskId,_that.message,_that.timestamp,_that.retryCount);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String message,  DateTime timestamp,  int? retryCount)?  $default,) {final _that = this;
switch (_that) {
case _UploadError() when $default != null:
return $default(_that.taskId,_that.message,_that.timestamp,_that.retryCount);case _:
  return null;

}
}

}

/// @nodoc


class _UploadError implements UploadError {
  const _UploadError({required this.taskId, required this.message, required this.timestamp, this.retryCount});
  

@override final  String taskId;
@override final  String message;
@override final  DateTime timestamp;
@override final  int? retryCount;

/// Create a copy of UploadError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadErrorCopyWith<_UploadError> get copyWith => __$UploadErrorCopyWithImpl<_UploadError>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadError&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.message, message) || other.message == message)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.retryCount, retryCount) || other.retryCount == retryCount));
}


@override
int get hashCode => Object.hash(runtimeType,taskId,message,timestamp,retryCount);

@override
String toString() {
  return 'UploadError(taskId: $taskId, message: $message, timestamp: $timestamp, retryCount: $retryCount)';
}


}

/// @nodoc
abstract mixin class _$UploadErrorCopyWith<$Res> implements $UploadErrorCopyWith<$Res> {
  factory _$UploadErrorCopyWith(_UploadError value, $Res Function(_UploadError) _then) = __$UploadErrorCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String message, DateTime timestamp, int? retryCount
});




}
/// @nodoc
class __$UploadErrorCopyWithImpl<$Res>
    implements _$UploadErrorCopyWith<$Res> {
  __$UploadErrorCopyWithImpl(this._self, this._then);

  final _UploadError _self;
  final $Res Function(_UploadError) _then;

/// Create a copy of UploadError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? message = null,Object? timestamp = null,Object? retryCount = freezed,}) {
  return _then(_UploadError(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,retryCount: freezed == retryCount ? _self.retryCount : retryCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$UploadQueueState {

/// Active upload tasks by ID
 Map<String, UploadTask> get activeTasks;/// Upload progress tracking by task ID
 Map<String, double> get uploadProgress;/// Upload errors by task ID
 Map<String, UploadError> get uploadErrors;/// Upload queue (pending tasks)
 List<UploadTask> get uploadQueue;/// Currently uploading flag
 bool get isUploading;/// Retry counts by task ID
 Map<String, int> get retryCounts;
/// Create a copy of UploadQueueState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadQueueStateCopyWith<UploadQueueState> get copyWith => _$UploadQueueStateCopyWithImpl<UploadQueueState>(this as UploadQueueState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadQueueState&&const DeepCollectionEquality().equals(other.activeTasks, activeTasks)&&const DeepCollectionEquality().equals(other.uploadProgress, uploadProgress)&&const DeepCollectionEquality().equals(other.uploadErrors, uploadErrors)&&const DeepCollectionEquality().equals(other.uploadQueue, uploadQueue)&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&const DeepCollectionEquality().equals(other.retryCounts, retryCounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(activeTasks),const DeepCollectionEquality().hash(uploadProgress),const DeepCollectionEquality().hash(uploadErrors),const DeepCollectionEquality().hash(uploadQueue),isUploading,const DeepCollectionEquality().hash(retryCounts));

@override
String toString() {
  return 'UploadQueueState(activeTasks: $activeTasks, uploadProgress: $uploadProgress, uploadErrors: $uploadErrors, uploadQueue: $uploadQueue, isUploading: $isUploading, retryCounts: $retryCounts)';
}


}

/// @nodoc
abstract mixin class $UploadQueueStateCopyWith<$Res>  {
  factory $UploadQueueStateCopyWith(UploadQueueState value, $Res Function(UploadQueueState) _then) = _$UploadQueueStateCopyWithImpl;
@useResult
$Res call({
 Map<String, UploadTask> activeTasks, Map<String, double> uploadProgress, Map<String, UploadError> uploadErrors, List<UploadTask> uploadQueue, bool isUploading, Map<String, int> retryCounts
});




}
/// @nodoc
class _$UploadQueueStateCopyWithImpl<$Res>
    implements $UploadQueueStateCopyWith<$Res> {
  _$UploadQueueStateCopyWithImpl(this._self, this._then);

  final UploadQueueState _self;
  final $Res Function(UploadQueueState) _then;

/// Create a copy of UploadQueueState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? activeTasks = null,Object? uploadProgress = null,Object? uploadErrors = null,Object? uploadQueue = null,Object? isUploading = null,Object? retryCounts = null,}) {
  return _then(_self.copyWith(
activeTasks: null == activeTasks ? _self.activeTasks : activeTasks // ignore: cast_nullable_to_non_nullable
as Map<String, UploadTask>,uploadProgress: null == uploadProgress ? _self.uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as Map<String, double>,uploadErrors: null == uploadErrors ? _self.uploadErrors : uploadErrors // ignore: cast_nullable_to_non_nullable
as Map<String, UploadError>,uploadQueue: null == uploadQueue ? _self.uploadQueue : uploadQueue // ignore: cast_nullable_to_non_nullable
as List<UploadTask>,isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,retryCounts: null == retryCounts ? _self.retryCounts : retryCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadQueueState].
extension UploadQueueStatePatterns on UploadQueueState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadQueueState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadQueueState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadQueueState value)  $default,){
final _that = this;
switch (_that) {
case _UploadQueueState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadQueueState value)?  $default,){
final _that = this;
switch (_that) {
case _UploadQueueState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Map<String, UploadTask> activeTasks,  Map<String, double> uploadProgress,  Map<String, UploadError> uploadErrors,  List<UploadTask> uploadQueue,  bool isUploading,  Map<String, int> retryCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadQueueState() when $default != null:
return $default(_that.activeTasks,_that.uploadProgress,_that.uploadErrors,_that.uploadQueue,_that.isUploading,_that.retryCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Map<String, UploadTask> activeTasks,  Map<String, double> uploadProgress,  Map<String, UploadError> uploadErrors,  List<UploadTask> uploadQueue,  bool isUploading,  Map<String, int> retryCounts)  $default,) {final _that = this;
switch (_that) {
case _UploadQueueState():
return $default(_that.activeTasks,_that.uploadProgress,_that.uploadErrors,_that.uploadQueue,_that.isUploading,_that.retryCounts);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Map<String, UploadTask> activeTasks,  Map<String, double> uploadProgress,  Map<String, UploadError> uploadErrors,  List<UploadTask> uploadQueue,  bool isUploading,  Map<String, int> retryCounts)?  $default,) {final _that = this;
switch (_that) {
case _UploadQueueState() when $default != null:
return $default(_that.activeTasks,_that.uploadProgress,_that.uploadErrors,_that.uploadQueue,_that.isUploading,_that.retryCounts);case _:
  return null;

}
}

}

/// @nodoc


class _UploadQueueState extends UploadQueueState {
  const _UploadQueueState({final  Map<String, UploadTask> activeTasks = const {}, final  Map<String, double> uploadProgress = const {}, final  Map<String, UploadError> uploadErrors = const {}, final  List<UploadTask> uploadQueue = const [], this.isUploading = false, final  Map<String, int> retryCounts = const {}}): _activeTasks = activeTasks,_uploadProgress = uploadProgress,_uploadErrors = uploadErrors,_uploadQueue = uploadQueue,_retryCounts = retryCounts,super._();
  

/// Active upload tasks by ID
 final  Map<String, UploadTask> _activeTasks;
/// Active upload tasks by ID
@override@JsonKey() Map<String, UploadTask> get activeTasks {
  if (_activeTasks is EqualUnmodifiableMapView) return _activeTasks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_activeTasks);
}

/// Upload progress tracking by task ID
 final  Map<String, double> _uploadProgress;
/// Upload progress tracking by task ID
@override@JsonKey() Map<String, double> get uploadProgress {
  if (_uploadProgress is EqualUnmodifiableMapView) return _uploadProgress;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_uploadProgress);
}

/// Upload errors by task ID
 final  Map<String, UploadError> _uploadErrors;
/// Upload errors by task ID
@override@JsonKey() Map<String, UploadError> get uploadErrors {
  if (_uploadErrors is EqualUnmodifiableMapView) return _uploadErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_uploadErrors);
}

/// Upload queue (pending tasks)
 final  List<UploadTask> _uploadQueue;
/// Upload queue (pending tasks)
@override@JsonKey() List<UploadTask> get uploadQueue {
  if (_uploadQueue is EqualUnmodifiableListView) return _uploadQueue;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_uploadQueue);
}

/// Currently uploading flag
@override@JsonKey() final  bool isUploading;
/// Retry counts by task ID
 final  Map<String, int> _retryCounts;
/// Retry counts by task ID
@override@JsonKey() Map<String, int> get retryCounts {
  if (_retryCounts is EqualUnmodifiableMapView) return _retryCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_retryCounts);
}


/// Create a copy of UploadQueueState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadQueueStateCopyWith<_UploadQueueState> get copyWith => __$UploadQueueStateCopyWithImpl<_UploadQueueState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadQueueState&&const DeepCollectionEquality().equals(other._activeTasks, _activeTasks)&&const DeepCollectionEquality().equals(other._uploadProgress, _uploadProgress)&&const DeepCollectionEquality().equals(other._uploadErrors, _uploadErrors)&&const DeepCollectionEquality().equals(other._uploadQueue, _uploadQueue)&&(identical(other.isUploading, isUploading) || other.isUploading == isUploading)&&const DeepCollectionEquality().equals(other._retryCounts, _retryCounts));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_activeTasks),const DeepCollectionEquality().hash(_uploadProgress),const DeepCollectionEquality().hash(_uploadErrors),const DeepCollectionEquality().hash(_uploadQueue),isUploading,const DeepCollectionEquality().hash(_retryCounts));

@override
String toString() {
  return 'UploadQueueState(activeTasks: $activeTasks, uploadProgress: $uploadProgress, uploadErrors: $uploadErrors, uploadQueue: $uploadQueue, isUploading: $isUploading, retryCounts: $retryCounts)';
}


}

/// @nodoc
abstract mixin class _$UploadQueueStateCopyWith<$Res> implements $UploadQueueStateCopyWith<$Res> {
  factory _$UploadQueueStateCopyWith(_UploadQueueState value, $Res Function(_UploadQueueState) _then) = __$UploadQueueStateCopyWithImpl;
@override @useResult
$Res call({
 Map<String, UploadTask> activeTasks, Map<String, double> uploadProgress, Map<String, UploadError> uploadErrors, List<UploadTask> uploadQueue, bool isUploading, Map<String, int> retryCounts
});




}
/// @nodoc
class __$UploadQueueStateCopyWithImpl<$Res>
    implements _$UploadQueueStateCopyWith<$Res> {
  __$UploadQueueStateCopyWithImpl(this._self, this._then);

  final _UploadQueueState _self;
  final $Res Function(_UploadQueueState) _then;

/// Create a copy of UploadQueueState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? activeTasks = null,Object? uploadProgress = null,Object? uploadErrors = null,Object? uploadQueue = null,Object? isUploading = null,Object? retryCounts = null,}) {
  return _then(_UploadQueueState(
activeTasks: null == activeTasks ? _self._activeTasks : activeTasks // ignore: cast_nullable_to_non_nullable
as Map<String, UploadTask>,uploadProgress: null == uploadProgress ? _self._uploadProgress : uploadProgress // ignore: cast_nullable_to_non_nullable
as Map<String, double>,uploadErrors: null == uploadErrors ? _self._uploadErrors : uploadErrors // ignore: cast_nullable_to_non_nullable
as Map<String, UploadError>,uploadQueue: null == uploadQueue ? _self._uploadQueue : uploadQueue // ignore: cast_nullable_to_non_nullable
as List<UploadTask>,isUploading: null == isUploading ? _self.isUploading : isUploading // ignore: cast_nullable_to_non_nullable
as bool,retryCounts: null == retryCounts ? _self._retryCounts : retryCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}


}

// dart format on
