// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NotificationFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationFailure&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}

/// @nodoc
class $NotificationFailureCopyWith<$Res>  {
$NotificationFailureCopyWith(NotificationFailure _, $Res Function(NotificationFailure) __);
}


/// Adds pattern-matching-related methods to [NotificationFailure].
extension NotificationFailurePatterns on NotificationFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NotificationNotFound value)?  notificationNotFound,TResult Function( NotificationLoadFailed value)?  notificationLoadFailed,TResult Function( NotificationSendFailed value)?  notificationSendFailed,TResult Function( NotificationCreateFailed value)?  notificationCreateFailed,TResult Function( NotificationUpdateFailed value)?  notificationUpdateFailed,TResult Function( NotificationDeleteFailed value)?  notificationDeleteFailed,TResult Function( InvalidNotificationData value)?  invalidNotificationData,TResult Function( NotificationExpired value)?  notificationExpired,TResult Function( BroadcastFailed value)?  broadcastFailed,TResult Function( GroupingFailed value)?  groupingFailed,TResult Function( StreamingFailed value)?  streamingFailed,TResult Function( InitializationFailed value)?  initializationFailed,TResult Function( NetworkError value)?  networkError,TResult Function( PermissionDenied value)?  permissionDenied,TResult Function( ServerError value)?  serverError,TResult Function( Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NotificationNotFound() when notificationNotFound != null:
return notificationNotFound(_that);case NotificationLoadFailed() when notificationLoadFailed != null:
return notificationLoadFailed(_that);case NotificationSendFailed() when notificationSendFailed != null:
return notificationSendFailed(_that);case NotificationCreateFailed() when notificationCreateFailed != null:
return notificationCreateFailed(_that);case NotificationUpdateFailed() when notificationUpdateFailed != null:
return notificationUpdateFailed(_that);case NotificationDeleteFailed() when notificationDeleteFailed != null:
return notificationDeleteFailed(_that);case InvalidNotificationData() when invalidNotificationData != null:
return invalidNotificationData(_that);case NotificationExpired() when notificationExpired != null:
return notificationExpired(_that);case BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that);case GroupingFailed() when groupingFailed != null:
return groupingFailed(_that);case StreamingFailed() when streamingFailed != null:
return streamingFailed(_that);case InitializationFailed() when initializationFailed != null:
return initializationFailed(_that);case NetworkError() when networkError != null:
return networkError(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case ServerError() when serverError != null:
return serverError(_that);case Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NotificationNotFound value)  notificationNotFound,required TResult Function( NotificationLoadFailed value)  notificationLoadFailed,required TResult Function( NotificationSendFailed value)  notificationSendFailed,required TResult Function( NotificationCreateFailed value)  notificationCreateFailed,required TResult Function( NotificationUpdateFailed value)  notificationUpdateFailed,required TResult Function( NotificationDeleteFailed value)  notificationDeleteFailed,required TResult Function( InvalidNotificationData value)  invalidNotificationData,required TResult Function( NotificationExpired value)  notificationExpired,required TResult Function( BroadcastFailed value)  broadcastFailed,required TResult Function( GroupingFailed value)  groupingFailed,required TResult Function( StreamingFailed value)  streamingFailed,required TResult Function( InitializationFailed value)  initializationFailed,required TResult Function( NetworkError value)  networkError,required TResult Function( PermissionDenied value)  permissionDenied,required TResult Function( ServerError value)  serverError,required TResult Function( Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case NotificationNotFound():
return notificationNotFound(_that);case NotificationLoadFailed():
return notificationLoadFailed(_that);case NotificationSendFailed():
return notificationSendFailed(_that);case NotificationCreateFailed():
return notificationCreateFailed(_that);case NotificationUpdateFailed():
return notificationUpdateFailed(_that);case NotificationDeleteFailed():
return notificationDeleteFailed(_that);case InvalidNotificationData():
return invalidNotificationData(_that);case NotificationExpired():
return notificationExpired(_that);case BroadcastFailed():
return broadcastFailed(_that);case GroupingFailed():
return groupingFailed(_that);case StreamingFailed():
return streamingFailed(_that);case InitializationFailed():
return initializationFailed(_that);case NetworkError():
return networkError(_that);case PermissionDenied():
return permissionDenied(_that);case ServerError():
return serverError(_that);case Unexpected():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NotificationNotFound value)?  notificationNotFound,TResult? Function( NotificationLoadFailed value)?  notificationLoadFailed,TResult? Function( NotificationSendFailed value)?  notificationSendFailed,TResult? Function( NotificationCreateFailed value)?  notificationCreateFailed,TResult? Function( NotificationUpdateFailed value)?  notificationUpdateFailed,TResult? Function( NotificationDeleteFailed value)?  notificationDeleteFailed,TResult? Function( InvalidNotificationData value)?  invalidNotificationData,TResult? Function( NotificationExpired value)?  notificationExpired,TResult? Function( BroadcastFailed value)?  broadcastFailed,TResult? Function( GroupingFailed value)?  groupingFailed,TResult? Function( StreamingFailed value)?  streamingFailed,TResult? Function( InitializationFailed value)?  initializationFailed,TResult? Function( NetworkError value)?  networkError,TResult? Function( PermissionDenied value)?  permissionDenied,TResult? Function( ServerError value)?  serverError,TResult? Function( Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case NotificationNotFound() when notificationNotFound != null:
return notificationNotFound(_that);case NotificationLoadFailed() when notificationLoadFailed != null:
return notificationLoadFailed(_that);case NotificationSendFailed() when notificationSendFailed != null:
return notificationSendFailed(_that);case NotificationCreateFailed() when notificationCreateFailed != null:
return notificationCreateFailed(_that);case NotificationUpdateFailed() when notificationUpdateFailed != null:
return notificationUpdateFailed(_that);case NotificationDeleteFailed() when notificationDeleteFailed != null:
return notificationDeleteFailed(_that);case InvalidNotificationData() when invalidNotificationData != null:
return invalidNotificationData(_that);case NotificationExpired() when notificationExpired != null:
return notificationExpired(_that);case BroadcastFailed() when broadcastFailed != null:
return broadcastFailed(_that);case GroupingFailed() when groupingFailed != null:
return groupingFailed(_that);case StreamingFailed() when streamingFailed != null:
return streamingFailed(_that);case InitializationFailed() when initializationFailed != null:
return initializationFailed(_that);case NetworkError() when networkError != null:
return networkError(_that);case PermissionDenied() when permissionDenied != null:
return permissionDenied(_that);case ServerError() when serverError != null:
return serverError(_that);case Unexpected() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  notificationNotFound,TResult Function()?  notificationLoadFailed,TResult Function()?  notificationSendFailed,TResult Function()?  notificationCreateFailed,TResult Function()?  notificationUpdateFailed,TResult Function()?  notificationDeleteFailed,TResult Function()?  invalidNotificationData,TResult Function()?  notificationExpired,TResult Function()?  broadcastFailed,TResult Function()?  groupingFailed,TResult Function()?  streamingFailed,TResult Function()?  initializationFailed,TResult Function()?  networkError,TResult Function()?  permissionDenied,TResult Function()?  serverError,TResult Function( String? errorMessage)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NotificationNotFound() when notificationNotFound != null:
return notificationNotFound();case NotificationLoadFailed() when notificationLoadFailed != null:
return notificationLoadFailed();case NotificationSendFailed() when notificationSendFailed != null:
return notificationSendFailed();case NotificationCreateFailed() when notificationCreateFailed != null:
return notificationCreateFailed();case NotificationUpdateFailed() when notificationUpdateFailed != null:
return notificationUpdateFailed();case NotificationDeleteFailed() when notificationDeleteFailed != null:
return notificationDeleteFailed();case InvalidNotificationData() when invalidNotificationData != null:
return invalidNotificationData();case NotificationExpired() when notificationExpired != null:
return notificationExpired();case BroadcastFailed() when broadcastFailed != null:
return broadcastFailed();case GroupingFailed() when groupingFailed != null:
return groupingFailed();case StreamingFailed() when streamingFailed != null:
return streamingFailed();case InitializationFailed() when initializationFailed != null:
return initializationFailed();case NetworkError() when networkError != null:
return networkError();case PermissionDenied() when permissionDenied != null:
return permissionDenied();case ServerError() when serverError != null:
return serverError();case Unexpected() when unexpected != null:
return unexpected(_that.errorMessage);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  notificationNotFound,required TResult Function()  notificationLoadFailed,required TResult Function()  notificationSendFailed,required TResult Function()  notificationCreateFailed,required TResult Function()  notificationUpdateFailed,required TResult Function()  notificationDeleteFailed,required TResult Function()  invalidNotificationData,required TResult Function()  notificationExpired,required TResult Function()  broadcastFailed,required TResult Function()  groupingFailed,required TResult Function()  streamingFailed,required TResult Function()  initializationFailed,required TResult Function()  networkError,required TResult Function()  permissionDenied,required TResult Function()  serverError,required TResult Function( String? errorMessage)  unexpected,}) {final _that = this;
switch (_that) {
case NotificationNotFound():
return notificationNotFound();case NotificationLoadFailed():
return notificationLoadFailed();case NotificationSendFailed():
return notificationSendFailed();case NotificationCreateFailed():
return notificationCreateFailed();case NotificationUpdateFailed():
return notificationUpdateFailed();case NotificationDeleteFailed():
return notificationDeleteFailed();case InvalidNotificationData():
return invalidNotificationData();case NotificationExpired():
return notificationExpired();case BroadcastFailed():
return broadcastFailed();case GroupingFailed():
return groupingFailed();case StreamingFailed():
return streamingFailed();case InitializationFailed():
return initializationFailed();case NetworkError():
return networkError();case PermissionDenied():
return permissionDenied();case ServerError():
return serverError();case Unexpected():
return unexpected(_that.errorMessage);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  notificationNotFound,TResult? Function()?  notificationLoadFailed,TResult? Function()?  notificationSendFailed,TResult? Function()?  notificationCreateFailed,TResult? Function()?  notificationUpdateFailed,TResult? Function()?  notificationDeleteFailed,TResult? Function()?  invalidNotificationData,TResult? Function()?  notificationExpired,TResult? Function()?  broadcastFailed,TResult? Function()?  groupingFailed,TResult? Function()?  streamingFailed,TResult? Function()?  initializationFailed,TResult? Function()?  networkError,TResult? Function()?  permissionDenied,TResult? Function()?  serverError,TResult? Function( String? errorMessage)?  unexpected,}) {final _that = this;
switch (_that) {
case NotificationNotFound() when notificationNotFound != null:
return notificationNotFound();case NotificationLoadFailed() when notificationLoadFailed != null:
return notificationLoadFailed();case NotificationSendFailed() when notificationSendFailed != null:
return notificationSendFailed();case NotificationCreateFailed() when notificationCreateFailed != null:
return notificationCreateFailed();case NotificationUpdateFailed() when notificationUpdateFailed != null:
return notificationUpdateFailed();case NotificationDeleteFailed() when notificationDeleteFailed != null:
return notificationDeleteFailed();case InvalidNotificationData() when invalidNotificationData != null:
return invalidNotificationData();case NotificationExpired() when notificationExpired != null:
return notificationExpired();case BroadcastFailed() when broadcastFailed != null:
return broadcastFailed();case GroupingFailed() when groupingFailed != null:
return groupingFailed();case StreamingFailed() when streamingFailed != null:
return streamingFailed();case InitializationFailed() when initializationFailed != null:
return initializationFailed();case NetworkError() when networkError != null:
return networkError();case PermissionDenied() when permissionDenied != null:
return permissionDenied();case ServerError() when serverError != null:
return serverError();case Unexpected() when unexpected != null:
return unexpected(_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class NotificationNotFound extends NotificationFailure {
  const NotificationNotFound(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationNotFound&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationLoadFailed extends NotificationFailure {
  const NotificationLoadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationLoadFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationSendFailed extends NotificationFailure {
  const NotificationSendFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationSendFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationCreateFailed extends NotificationFailure {
  const NotificationCreateFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationCreateFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationUpdateFailed extends NotificationFailure {
  const NotificationUpdateFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationUpdateFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationDeleteFailed extends NotificationFailure {
  const NotificationDeleteFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationDeleteFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InvalidNotificationData extends NotificationFailure {
  const InvalidNotificationData(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidNotificationData&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NotificationExpired extends NotificationFailure {
  const NotificationExpired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationExpired&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class BroadcastFailed extends NotificationFailure {
  const BroadcastFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BroadcastFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class GroupingFailed extends NotificationFailure {
  const GroupingFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GroupingFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class StreamingFailed extends NotificationFailure {
  const StreamingFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StreamingFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class InitializationFailed extends NotificationFailure {
  const InitializationFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InitializationFailed&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class NetworkError extends NotificationFailure {
  const NetworkError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class PermissionDenied extends NotificationFailure {
  const PermissionDenied(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDenied&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class ServerError extends NotificationFailure {
  const ServerError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError&&super == other);
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode);



}




/// @nodoc


class Unexpected extends NotificationFailure {
  const Unexpected([this.errorMessage]): super._();
  

 final  String? errorMessage;

/// Create a copy of NotificationFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedCopyWith<Unexpected> get copyWith => _$UnexpectedCopyWithImpl<Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unexpected&&super == other&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,super.hashCode,errorMessage);



}

/// @nodoc
abstract mixin class $UnexpectedCopyWith<$Res> implements $NotificationFailureCopyWith<$Res> {
  factory $UnexpectedCopyWith(Unexpected value, $Res Function(Unexpected) _then) = _$UnexpectedCopyWithImpl;
@useResult
$Res call({
 String? errorMessage
});




}
/// @nodoc
class _$UnexpectedCopyWithImpl<$Res>
    implements $UnexpectedCopyWith<$Res> {
  _$UnexpectedCopyWithImpl(this._self, this._then);

  final Unexpected _self;
  final $Res Function(Unexpected) _then;

/// Create a copy of NotificationFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorMessage = freezed,}) {
  return _then(Unexpected(
freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
