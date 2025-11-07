// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure()';
}


}

/// @nodoc
class $ChatFailureCopyWith<$Res>  {
$ChatFailureCopyWith(ChatFailure _, $Res Function(ChatFailure) __);
}


/// Adds pattern-matching-related methods to [ChatFailure].
extension ChatFailurePatterns on ChatFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( MessageSendFailed value)?  messageSendFailed,TResult Function( MessageLoadFailed value)?  messageLoadFailed,TResult Function( MessageDeleteFailed value)?  messageDeleteFailed,TResult Function( InvalidMessageContent value)?  invalidMessageContent,TResult Function( ChatNotFound value)?  chatNotFound,TResult Function( ChatCreationFailed value)?  chatCreationFailed,TResult Function( ChatLoadFailed value)?  chatLoadFailed,TResult Function( ParticipantNotFound value)?  participantNotFound,TResult Function( ParticipantLoadFailed value)?  participantLoadFailed,TResult Function( AIQueryFailed value)?  aiQueryFailed,TResult Function( AIStreamingError value)?  aiStreamingError,TResult Function( AINotInitialized value)?  aiNotInitialized,TResult Function( SearchFailed value)?  searchFailed,TResult Function( FriendRequestFailed value)?  friendRequestFailed,TResult Function( FriendLoadFailed value)?  friendLoadFailed,TResult Function( FollowToggleFailed value)?  followToggleFailed,TResult Function( NetworkError value)?  networkError,TResult Function( PermissionDenied value)?  permissionDenied,TResult Function( ServerError value)?  serverError,TResult Function( Unexpected value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case MessageSendFailed() when messageSendFailed != null:
return messageSendFailed(_that);case MessageLoadFailed() when messageLoadFailed != null:
return messageLoadFailed(_that);case MessageDeleteFailed() when messageDeleteFailed != null:
return messageDeleteFailed(_that);case InvalidMessageContent() when invalidMessageContent != null:
return invalidMessageContent(_that);case ChatNotFound() when chatNotFound != null:
return chatNotFound(_that);case ChatCreationFailed() when chatCreationFailed != null:
return chatCreationFailed(_that);case ChatLoadFailed() when chatLoadFailed != null:
return chatLoadFailed(_that);case ParticipantNotFound() when participantNotFound != null:
return participantNotFound(_that);case ParticipantLoadFailed() when participantLoadFailed != null:
return participantLoadFailed(_that);case AIQueryFailed() when aiQueryFailed != null:
return aiQueryFailed(_that);case AIStreamingError() when aiStreamingError != null:
return aiStreamingError(_that);case AINotInitialized() when aiNotInitialized != null:
return aiNotInitialized(_that);case SearchFailed() when searchFailed != null:
return searchFailed(_that);case FriendRequestFailed() when friendRequestFailed != null:
return friendRequestFailed(_that);case FriendLoadFailed() when friendLoadFailed != null:
return friendLoadFailed(_that);case FollowToggleFailed() when followToggleFailed != null:
return followToggleFailed(_that);case NetworkError() when networkError != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( MessageSendFailed value)  messageSendFailed,required TResult Function( MessageLoadFailed value)  messageLoadFailed,required TResult Function( MessageDeleteFailed value)  messageDeleteFailed,required TResult Function( InvalidMessageContent value)  invalidMessageContent,required TResult Function( ChatNotFound value)  chatNotFound,required TResult Function( ChatCreationFailed value)  chatCreationFailed,required TResult Function( ChatLoadFailed value)  chatLoadFailed,required TResult Function( ParticipantNotFound value)  participantNotFound,required TResult Function( ParticipantLoadFailed value)  participantLoadFailed,required TResult Function( AIQueryFailed value)  aiQueryFailed,required TResult Function( AIStreamingError value)  aiStreamingError,required TResult Function( AINotInitialized value)  aiNotInitialized,required TResult Function( SearchFailed value)  searchFailed,required TResult Function( FriendRequestFailed value)  friendRequestFailed,required TResult Function( FriendLoadFailed value)  friendLoadFailed,required TResult Function( FollowToggleFailed value)  followToggleFailed,required TResult Function( NetworkError value)  networkError,required TResult Function( PermissionDenied value)  permissionDenied,required TResult Function( ServerError value)  serverError,required TResult Function( Unexpected value)  unexpected,}){
final _that = this;
switch (_that) {
case MessageSendFailed():
return messageSendFailed(_that);case MessageLoadFailed():
return messageLoadFailed(_that);case MessageDeleteFailed():
return messageDeleteFailed(_that);case InvalidMessageContent():
return invalidMessageContent(_that);case ChatNotFound():
return chatNotFound(_that);case ChatCreationFailed():
return chatCreationFailed(_that);case ChatLoadFailed():
return chatLoadFailed(_that);case ParticipantNotFound():
return participantNotFound(_that);case ParticipantLoadFailed():
return participantLoadFailed(_that);case AIQueryFailed():
return aiQueryFailed(_that);case AIStreamingError():
return aiStreamingError(_that);case AINotInitialized():
return aiNotInitialized(_that);case SearchFailed():
return searchFailed(_that);case FriendRequestFailed():
return friendRequestFailed(_that);case FriendLoadFailed():
return friendLoadFailed(_that);case FollowToggleFailed():
return followToggleFailed(_that);case NetworkError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( MessageSendFailed value)?  messageSendFailed,TResult? Function( MessageLoadFailed value)?  messageLoadFailed,TResult? Function( MessageDeleteFailed value)?  messageDeleteFailed,TResult? Function( InvalidMessageContent value)?  invalidMessageContent,TResult? Function( ChatNotFound value)?  chatNotFound,TResult? Function( ChatCreationFailed value)?  chatCreationFailed,TResult? Function( ChatLoadFailed value)?  chatLoadFailed,TResult? Function( ParticipantNotFound value)?  participantNotFound,TResult? Function( ParticipantLoadFailed value)?  participantLoadFailed,TResult? Function( AIQueryFailed value)?  aiQueryFailed,TResult? Function( AIStreamingError value)?  aiStreamingError,TResult? Function( AINotInitialized value)?  aiNotInitialized,TResult? Function( SearchFailed value)?  searchFailed,TResult? Function( FriendRequestFailed value)?  friendRequestFailed,TResult? Function( FriendLoadFailed value)?  friendLoadFailed,TResult? Function( FollowToggleFailed value)?  followToggleFailed,TResult? Function( NetworkError value)?  networkError,TResult? Function( PermissionDenied value)?  permissionDenied,TResult? Function( ServerError value)?  serverError,TResult? Function( Unexpected value)?  unexpected,}){
final _that = this;
switch (_that) {
case MessageSendFailed() when messageSendFailed != null:
return messageSendFailed(_that);case MessageLoadFailed() when messageLoadFailed != null:
return messageLoadFailed(_that);case MessageDeleteFailed() when messageDeleteFailed != null:
return messageDeleteFailed(_that);case InvalidMessageContent() when invalidMessageContent != null:
return invalidMessageContent(_that);case ChatNotFound() when chatNotFound != null:
return chatNotFound(_that);case ChatCreationFailed() when chatCreationFailed != null:
return chatCreationFailed(_that);case ChatLoadFailed() when chatLoadFailed != null:
return chatLoadFailed(_that);case ParticipantNotFound() when participantNotFound != null:
return participantNotFound(_that);case ParticipantLoadFailed() when participantLoadFailed != null:
return participantLoadFailed(_that);case AIQueryFailed() when aiQueryFailed != null:
return aiQueryFailed(_that);case AIStreamingError() when aiStreamingError != null:
return aiStreamingError(_that);case AINotInitialized() when aiNotInitialized != null:
return aiNotInitialized(_that);case SearchFailed() when searchFailed != null:
return searchFailed(_that);case FriendRequestFailed() when friendRequestFailed != null:
return friendRequestFailed(_that);case FriendLoadFailed() when friendLoadFailed != null:
return friendLoadFailed(_that);case FollowToggleFailed() when followToggleFailed != null:
return followToggleFailed(_that);case NetworkError() when networkError != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  messageSendFailed,TResult Function()?  messageLoadFailed,TResult Function()?  messageDeleteFailed,TResult Function()?  invalidMessageContent,TResult Function()?  chatNotFound,TResult Function()?  chatCreationFailed,TResult Function()?  chatLoadFailed,TResult Function()?  participantNotFound,TResult Function()?  participantLoadFailed,TResult Function()?  aiQueryFailed,TResult Function()?  aiStreamingError,TResult Function()?  aiNotInitialized,TResult Function()?  searchFailed,TResult Function()?  friendRequestFailed,TResult Function()?  friendLoadFailed,TResult Function()?  followToggleFailed,TResult Function()?  networkError,TResult Function()?  permissionDenied,TResult Function()?  serverError,TResult Function( String? errorMessage)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case MessageSendFailed() when messageSendFailed != null:
return messageSendFailed();case MessageLoadFailed() when messageLoadFailed != null:
return messageLoadFailed();case MessageDeleteFailed() when messageDeleteFailed != null:
return messageDeleteFailed();case InvalidMessageContent() when invalidMessageContent != null:
return invalidMessageContent();case ChatNotFound() when chatNotFound != null:
return chatNotFound();case ChatCreationFailed() when chatCreationFailed != null:
return chatCreationFailed();case ChatLoadFailed() when chatLoadFailed != null:
return chatLoadFailed();case ParticipantNotFound() when participantNotFound != null:
return participantNotFound();case ParticipantLoadFailed() when participantLoadFailed != null:
return participantLoadFailed();case AIQueryFailed() when aiQueryFailed != null:
return aiQueryFailed();case AIStreamingError() when aiStreamingError != null:
return aiStreamingError();case AINotInitialized() when aiNotInitialized != null:
return aiNotInitialized();case SearchFailed() when searchFailed != null:
return searchFailed();case FriendRequestFailed() when friendRequestFailed != null:
return friendRequestFailed();case FriendLoadFailed() when friendLoadFailed != null:
return friendLoadFailed();case FollowToggleFailed() when followToggleFailed != null:
return followToggleFailed();case NetworkError() when networkError != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  messageSendFailed,required TResult Function()  messageLoadFailed,required TResult Function()  messageDeleteFailed,required TResult Function()  invalidMessageContent,required TResult Function()  chatNotFound,required TResult Function()  chatCreationFailed,required TResult Function()  chatLoadFailed,required TResult Function()  participantNotFound,required TResult Function()  participantLoadFailed,required TResult Function()  aiQueryFailed,required TResult Function()  aiStreamingError,required TResult Function()  aiNotInitialized,required TResult Function()  searchFailed,required TResult Function()  friendRequestFailed,required TResult Function()  friendLoadFailed,required TResult Function()  followToggleFailed,required TResult Function()  networkError,required TResult Function()  permissionDenied,required TResult Function()  serverError,required TResult Function( String? errorMessage)  unexpected,}) {final _that = this;
switch (_that) {
case MessageSendFailed():
return messageSendFailed();case MessageLoadFailed():
return messageLoadFailed();case MessageDeleteFailed():
return messageDeleteFailed();case InvalidMessageContent():
return invalidMessageContent();case ChatNotFound():
return chatNotFound();case ChatCreationFailed():
return chatCreationFailed();case ChatLoadFailed():
return chatLoadFailed();case ParticipantNotFound():
return participantNotFound();case ParticipantLoadFailed():
return participantLoadFailed();case AIQueryFailed():
return aiQueryFailed();case AIStreamingError():
return aiStreamingError();case AINotInitialized():
return aiNotInitialized();case SearchFailed():
return searchFailed();case FriendRequestFailed():
return friendRequestFailed();case FriendLoadFailed():
return friendLoadFailed();case FollowToggleFailed():
return followToggleFailed();case NetworkError():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  messageSendFailed,TResult? Function()?  messageLoadFailed,TResult? Function()?  messageDeleteFailed,TResult? Function()?  invalidMessageContent,TResult? Function()?  chatNotFound,TResult? Function()?  chatCreationFailed,TResult? Function()?  chatLoadFailed,TResult? Function()?  participantNotFound,TResult? Function()?  participantLoadFailed,TResult? Function()?  aiQueryFailed,TResult? Function()?  aiStreamingError,TResult? Function()?  aiNotInitialized,TResult? Function()?  searchFailed,TResult? Function()?  friendRequestFailed,TResult? Function()?  friendLoadFailed,TResult? Function()?  followToggleFailed,TResult? Function()?  networkError,TResult? Function()?  permissionDenied,TResult? Function()?  serverError,TResult? Function( String? errorMessage)?  unexpected,}) {final _that = this;
switch (_that) {
case MessageSendFailed() when messageSendFailed != null:
return messageSendFailed();case MessageLoadFailed() when messageLoadFailed != null:
return messageLoadFailed();case MessageDeleteFailed() when messageDeleteFailed != null:
return messageDeleteFailed();case InvalidMessageContent() when invalidMessageContent != null:
return invalidMessageContent();case ChatNotFound() when chatNotFound != null:
return chatNotFound();case ChatCreationFailed() when chatCreationFailed != null:
return chatCreationFailed();case ChatLoadFailed() when chatLoadFailed != null:
return chatLoadFailed();case ParticipantNotFound() when participantNotFound != null:
return participantNotFound();case ParticipantLoadFailed() when participantLoadFailed != null:
return participantLoadFailed();case AIQueryFailed() when aiQueryFailed != null:
return aiQueryFailed();case AIStreamingError() when aiStreamingError != null:
return aiStreamingError();case AINotInitialized() when aiNotInitialized != null:
return aiNotInitialized();case SearchFailed() when searchFailed != null:
return searchFailed();case FriendRequestFailed() when friendRequestFailed != null:
return friendRequestFailed();case FriendLoadFailed() when friendLoadFailed != null:
return friendLoadFailed();case FollowToggleFailed() when followToggleFailed != null:
return followToggleFailed();case NetworkError() when networkError != null:
return networkError();case PermissionDenied() when permissionDenied != null:
return permissionDenied();case ServerError() when serverError != null:
return serverError();case Unexpected() when unexpected != null:
return unexpected(_that.errorMessage);case _:
  return null;

}
}

}

/// @nodoc


class MessageSendFailed extends ChatFailure {
  const MessageSendFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageSendFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.messageSendFailed()';
}


}




/// @nodoc


class MessageLoadFailed extends ChatFailure {
  const MessageLoadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.messageLoadFailed()';
}


}




/// @nodoc


class MessageDeleteFailed extends ChatFailure {
  const MessageDeleteFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MessageDeleteFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.messageDeleteFailed()';
}


}




/// @nodoc


class InvalidMessageContent extends ChatFailure {
  const InvalidMessageContent(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InvalidMessageContent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.invalidMessageContent()';
}


}




/// @nodoc


class ChatNotFound extends ChatFailure {
  const ChatNotFound(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.chatNotFound()';
}


}




/// @nodoc


class ChatCreationFailed extends ChatFailure {
  const ChatCreationFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatCreationFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.chatCreationFailed()';
}


}




/// @nodoc


class ChatLoadFailed extends ChatFailure {
  const ChatLoadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.chatLoadFailed()';
}


}




/// @nodoc


class ParticipantNotFound extends ChatFailure {
  const ParticipantNotFound(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantNotFound);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.participantNotFound()';
}


}




/// @nodoc


class ParticipantLoadFailed extends ChatFailure {
  const ParticipantLoadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ParticipantLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.participantLoadFailed()';
}


}




/// @nodoc


class AIQueryFailed extends ChatFailure {
  const AIQueryFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIQueryFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.aiQueryFailed()';
}


}




/// @nodoc


class AIStreamingError extends ChatFailure {
  const AIStreamingError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AIStreamingError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.aiStreamingError()';
}


}




/// @nodoc


class AINotInitialized extends ChatFailure {
  const AINotInitialized(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AINotInitialized);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.aiNotInitialized()';
}


}




/// @nodoc


class SearchFailed extends ChatFailure {
  const SearchFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.searchFailed()';
}


}




/// @nodoc


class FriendRequestFailed extends ChatFailure {
  const FriendRequestFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendRequestFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.friendRequestFailed()';
}


}




/// @nodoc


class FriendLoadFailed extends ChatFailure {
  const FriendLoadFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FriendLoadFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.friendLoadFailed()';
}


}




/// @nodoc


class FollowToggleFailed extends ChatFailure {
  const FollowToggleFailed(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowToggleFailed);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.followToggleFailed()';
}


}




/// @nodoc


class NetworkError extends ChatFailure {
  const NetworkError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.networkError()';
}


}




/// @nodoc


class PermissionDenied extends ChatFailure {
  const PermissionDenied(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionDenied);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.permissionDenied()';
}


}




/// @nodoc


class ServerError extends ChatFailure {
  const ServerError(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServerError);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'ChatFailure.serverError()';
}


}




/// @nodoc


class Unexpected extends ChatFailure {
  const Unexpected([this.errorMessage]): super._();
  

 final  String? errorMessage;

/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedCopyWith<Unexpected> get copyWith => _$UnexpectedCopyWithImpl<Unexpected>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Unexpected&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage));
}


@override
int get hashCode => Object.hash(runtimeType,errorMessage);

@override
String toString() {
  return 'ChatFailure.unexpected(errorMessage: $errorMessage)';
}


}

/// @nodoc
abstract mixin class $UnexpectedCopyWith<$Res> implements $ChatFailureCopyWith<$Res> {
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

/// Create a copy of ChatFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? errorMessage = freezed,}) {
  return _then(Unexpected(
freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
