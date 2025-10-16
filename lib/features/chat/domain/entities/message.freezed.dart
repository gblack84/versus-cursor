// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Message {

// ========== Basic Message Fields ==========
/// 메시지 고유 ID
 String get id;/// 부모 채팅방 경로
 String get parentPath;/// 메시지 ID (messageId 필드)
 String get messageId;/// 발신자 ID
 String get senderId;/// 메시지 내용
 String get content;/// 첨부 파일 URL
 String get attachmentUrl;/// 첨부 파일 타입
 String get attachmentType;/// 메시지 생성 시간
 DateTime? get timeStamp;/// 읽음 여부
 bool get isRead;/// 메시지 타입 (text, image, video, vote_request)
 String get messageType;// ========== Media Fields ==========
/// 미디어 타입 (text, image, video)
 String get mediaType;/// 이미지 URL
 String get imageUrl;/// 비디오 URL
 String get videoUrl;/// 썸네일 URL
 String get thumbnailUrl;/// 미디어 크기 (bytes)
 int get mediaSize;/// 미디어 너비
 double? get mediaWidth;/// 미디어 높이
 double? get mediaHeight;// ========== Message Lifecycle ==========
/// 서버에 전달된 시간
 DateTime? get deliveredAt;/// 수신자가 본 시간
 DateTime? get seenAt;// ========== Vote Card Fields ==========
/// 투표 요청을 받는 사용자 ID
 String get receiverId;/// 연결된 게시물 ID
 String get votePostId;/// 투표 제목
 String get voteTitle;/// 투표 설명
 String get voteDescription;/// 옵션 A 텍스트
 String get voteOptionAText;/// 옵션 B 텍스트
 String get voteOptionBText;/// 옵션 A 단일 이미지 (legacy)
 String get voteOptionAImage;/// 옵션 B 단일 이미지 (legacy)
 String get voteOptionBImage;/// 옵션 A 이미지 목록
 List<String> get voteOptionAImages;/// 옵션 B 이미지 목록
 List<String> get voteOptionBImages;/// 투표 상태 (pending, completed, expired)
 String get voteStatus;/// 투표 카드 상태
 String get cardStatus;/// 투표 종료 시간
 DateTime? get voteEndTime;/// 투표 결과 (legacy - Map<String, dynamic>)
 Map<String, dynamic> get voteResults;/// 사용자별 투표 정보 (userId → {option: 'A'/'B', votedAt: DateTime})
 Map<String, dynamic> get userVotes;/// 옵션 A 이미지 비율
 double? get voteAspectRatioA;/// 옵션 B 이미지 비율
 double? get voteAspectRatioB;/// 옵션 A 투표 수
 int get voteResultsA;/// 옵션 B 투표 수
 int get voteResultsB;/// 옵션 A 투표 비율 (%)
 double get votePercentA;/// 옵션 B 투표 비율 (%)
 double get votePercentB;// ========== Metadata ==========
/// 추가 메타데이터
 Map<String, dynamic> get metadata;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.parentPath, parentPath) || other.parentPath == parentPath)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediaSize, mediaSize) || other.mediaSize == mediaSize)&&(identical(other.mediaWidth, mediaWidth) || other.mediaWidth == mediaWidth)&&(identical(other.mediaHeight, mediaHeight) || other.mediaHeight == mediaHeight)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.votePostId, votePostId) || other.votePostId == votePostId)&&(identical(other.voteTitle, voteTitle) || other.voteTitle == voteTitle)&&(identical(other.voteDescription, voteDescription) || other.voteDescription == voteDescription)&&(identical(other.voteOptionAText, voteOptionAText) || other.voteOptionAText == voteOptionAText)&&(identical(other.voteOptionBText, voteOptionBText) || other.voteOptionBText == voteOptionBText)&&(identical(other.voteOptionAImage, voteOptionAImage) || other.voteOptionAImage == voteOptionAImage)&&(identical(other.voteOptionBImage, voteOptionBImage) || other.voteOptionBImage == voteOptionBImage)&&const DeepCollectionEquality().equals(other.voteOptionAImages, voteOptionAImages)&&const DeepCollectionEquality().equals(other.voteOptionBImages, voteOptionBImages)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.cardStatus, cardStatus) || other.cardStatus == cardStatus)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&const DeepCollectionEquality().equals(other.voteResults, voteResults)&&const DeepCollectionEquality().equals(other.userVotes, userVotes)&&(identical(other.voteAspectRatioA, voteAspectRatioA) || other.voteAspectRatioA == voteAspectRatioA)&&(identical(other.voteAspectRatioB, voteAspectRatioB) || other.voteAspectRatioB == voteAspectRatioB)&&(identical(other.voteResultsA, voteResultsA) || other.voteResultsA == voteResultsA)&&(identical(other.voteResultsB, voteResultsB) || other.voteResultsB == voteResultsB)&&(identical(other.votePercentA, votePercentA) || other.votePercentA == votePercentA)&&(identical(other.votePercentB, votePercentB) || other.votePercentB == votePercentB)&&const DeepCollectionEquality().equals(other.metadata, metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentPath,messageId,senderId,content,attachmentUrl,attachmentType,timeStamp,isRead,messageType,mediaType,imageUrl,videoUrl,thumbnailUrl,mediaSize,mediaWidth,mediaHeight,deliveredAt,seenAt,receiverId,votePostId,voteTitle,voteDescription,voteOptionAText,voteOptionBText,voteOptionAImage,voteOptionBImage,const DeepCollectionEquality().hash(voteOptionAImages),const DeepCollectionEquality().hash(voteOptionBImages),voteStatus,cardStatus,voteEndTime,const DeepCollectionEquality().hash(voteResults),const DeepCollectionEquality().hash(userVotes),voteAspectRatioA,voteAspectRatioB,voteResultsA,voteResultsB,votePercentA,votePercentB,const DeepCollectionEquality().hash(metadata)]);

@override
String toString() {
  return 'Message(id: $id, parentPath: $parentPath, messageId: $messageId, senderId: $senderId, content: $content, attachmentUrl: $attachmentUrl, attachmentType: $attachmentType, timeStamp: $timeStamp, isRead: $isRead, messageType: $messageType, mediaType: $mediaType, imageUrl: $imageUrl, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, mediaSize: $mediaSize, mediaWidth: $mediaWidth, mediaHeight: $mediaHeight, deliveredAt: $deliveredAt, seenAt: $seenAt, receiverId: $receiverId, votePostId: $votePostId, voteTitle: $voteTitle, voteDescription: $voteDescription, voteOptionAText: $voteOptionAText, voteOptionBText: $voteOptionBText, voteOptionAImage: $voteOptionAImage, voteOptionBImage: $voteOptionBImage, voteOptionAImages: $voteOptionAImages, voteOptionBImages: $voteOptionBImages, voteStatus: $voteStatus, cardStatus: $cardStatus, voteEndTime: $voteEndTime, voteResults: $voteResults, userVotes: $userVotes, voteAspectRatioA: $voteAspectRatioA, voteAspectRatioB: $voteAspectRatioB, voteResultsA: $voteResultsA, voteResultsB: $voteResultsB, votePercentA: $votePercentA, votePercentB: $votePercentB, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
 String id, String parentPath, String messageId, String senderId, String content, String attachmentUrl, String attachmentType, DateTime? timeStamp, bool isRead, String messageType, String mediaType, String imageUrl, String videoUrl, String thumbnailUrl, int mediaSize, double? mediaWidth, double? mediaHeight, DateTime? deliveredAt, DateTime? seenAt, String receiverId, String votePostId, String voteTitle, String voteDescription, String voteOptionAText, String voteOptionBText, String voteOptionAImage, String voteOptionBImage, List<String> voteOptionAImages, List<String> voteOptionBImages, String voteStatus, String cardStatus, DateTime? voteEndTime, Map<String, dynamic> voteResults, Map<String, dynamic> userVotes, double? voteAspectRatioA, double? voteAspectRatioB, int voteResultsA, int voteResultsB, double votePercentA, double votePercentB, Map<String, dynamic> metadata
});




}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentPath = null,Object? messageId = null,Object? senderId = null,Object? content = null,Object? attachmentUrl = null,Object? attachmentType = null,Object? timeStamp = freezed,Object? isRead = null,Object? messageType = null,Object? mediaType = null,Object? imageUrl = null,Object? videoUrl = null,Object? thumbnailUrl = null,Object? mediaSize = null,Object? mediaWidth = freezed,Object? mediaHeight = freezed,Object? deliveredAt = freezed,Object? seenAt = freezed,Object? receiverId = null,Object? votePostId = null,Object? voteTitle = null,Object? voteDescription = null,Object? voteOptionAText = null,Object? voteOptionBText = null,Object? voteOptionAImage = null,Object? voteOptionBImage = null,Object? voteOptionAImages = null,Object? voteOptionBImages = null,Object? voteStatus = null,Object? cardStatus = null,Object? voteEndTime = freezed,Object? voteResults = null,Object? userVotes = null,Object? voteAspectRatioA = freezed,Object? voteAspectRatioB = freezed,Object? voteResultsA = null,Object? voteResultsB = null,Object? votePercentA = null,Object? votePercentB = null,Object? metadata = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentPath: null == parentPath ? _self.parentPath : parentPath // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachmentUrl: null == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as String,timeStamp: freezed == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,mediaSize: null == mediaSize ? _self.mediaSize : mediaSize // ignore: cast_nullable_to_non_nullable
as int,mediaWidth: freezed == mediaWidth ? _self.mediaWidth : mediaWidth // ignore: cast_nullable_to_non_nullable
as double?,mediaHeight: freezed == mediaHeight ? _self.mediaHeight : mediaHeight // ignore: cast_nullable_to_non_nullable
as double?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,votePostId: null == votePostId ? _self.votePostId : votePostId // ignore: cast_nullable_to_non_nullable
as String,voteTitle: null == voteTitle ? _self.voteTitle : voteTitle // ignore: cast_nullable_to_non_nullable
as String,voteDescription: null == voteDescription ? _self.voteDescription : voteDescription // ignore: cast_nullable_to_non_nullable
as String,voteOptionAText: null == voteOptionAText ? _self.voteOptionAText : voteOptionAText // ignore: cast_nullable_to_non_nullable
as String,voteOptionBText: null == voteOptionBText ? _self.voteOptionBText : voteOptionBText // ignore: cast_nullable_to_non_nullable
as String,voteOptionAImage: null == voteOptionAImage ? _self.voteOptionAImage : voteOptionAImage // ignore: cast_nullable_to_non_nullable
as String,voteOptionBImage: null == voteOptionBImage ? _self.voteOptionBImage : voteOptionBImage // ignore: cast_nullable_to_non_nullable
as String,voteOptionAImages: null == voteOptionAImages ? _self.voteOptionAImages : voteOptionAImages // ignore: cast_nullable_to_non_nullable
as List<String>,voteOptionBImages: null == voteOptionBImages ? _self.voteOptionBImages : voteOptionBImages // ignore: cast_nullable_to_non_nullable
as List<String>,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,cardStatus: null == cardStatus ? _self.cardStatus : cardStatus // ignore: cast_nullable_to_non_nullable
as String,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteResults: null == voteResults ? _self.voteResults : voteResults // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userVotes: null == userVotes ? _self.userVotes : userVotes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,voteAspectRatioA: freezed == voteAspectRatioA ? _self.voteAspectRatioA : voteAspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,voteAspectRatioB: freezed == voteAspectRatioB ? _self.voteAspectRatioB : voteAspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,voteResultsA: null == voteResultsA ? _self.voteResultsA : voteResultsA // ignore: cast_nullable_to_non_nullable
as int,voteResultsB: null == voteResultsB ? _self.voteResultsB : voteResultsB // ignore: cast_nullable_to_non_nullable
as int,votePercentA: null == votePercentA ? _self.votePercentA : votePercentA // ignore: cast_nullable_to_non_nullable
as double,votePercentB: null == votePercentB ? _self.votePercentB : votePercentB // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self.metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String parentPath,  String messageId,  String senderId,  String content,  String attachmentUrl,  String attachmentType,  DateTime? timeStamp,  bool isRead,  String messageType,  String mediaType,  String imageUrl,  String videoUrl,  String thumbnailUrl,  int mediaSize,  double? mediaWidth,  double? mediaHeight,  DateTime? deliveredAt,  DateTime? seenAt,  String receiverId,  String votePostId,  String voteTitle,  String voteDescription,  String voteOptionAText,  String voteOptionBText,  String voteOptionAImage,  String voteOptionBImage,  List<String> voteOptionAImages,  List<String> voteOptionBImages,  String voteStatus,  String cardStatus,  DateTime? voteEndTime,  Map<String, dynamic> voteResults,  Map<String, dynamic> userVotes,  double? voteAspectRatioA,  double? voteAspectRatioB,  int voteResultsA,  int voteResultsB,  double votePercentA,  double votePercentB,  Map<String, dynamic> metadata)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.parentPath,_that.messageId,_that.senderId,_that.content,_that.attachmentUrl,_that.attachmentType,_that.timeStamp,_that.isRead,_that.messageType,_that.mediaType,_that.imageUrl,_that.videoUrl,_that.thumbnailUrl,_that.mediaSize,_that.mediaWidth,_that.mediaHeight,_that.deliveredAt,_that.seenAt,_that.receiverId,_that.votePostId,_that.voteTitle,_that.voteDescription,_that.voteOptionAText,_that.voteOptionBText,_that.voteOptionAImage,_that.voteOptionBImage,_that.voteOptionAImages,_that.voteOptionBImages,_that.voteStatus,_that.cardStatus,_that.voteEndTime,_that.voteResults,_that.userVotes,_that.voteAspectRatioA,_that.voteAspectRatioB,_that.voteResultsA,_that.voteResultsB,_that.votePercentA,_that.votePercentB,_that.metadata);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String parentPath,  String messageId,  String senderId,  String content,  String attachmentUrl,  String attachmentType,  DateTime? timeStamp,  bool isRead,  String messageType,  String mediaType,  String imageUrl,  String videoUrl,  String thumbnailUrl,  int mediaSize,  double? mediaWidth,  double? mediaHeight,  DateTime? deliveredAt,  DateTime? seenAt,  String receiverId,  String votePostId,  String voteTitle,  String voteDescription,  String voteOptionAText,  String voteOptionBText,  String voteOptionAImage,  String voteOptionBImage,  List<String> voteOptionAImages,  List<String> voteOptionBImages,  String voteStatus,  String cardStatus,  DateTime? voteEndTime,  Map<String, dynamic> voteResults,  Map<String, dynamic> userVotes,  double? voteAspectRatioA,  double? voteAspectRatioB,  int voteResultsA,  int voteResultsB,  double votePercentA,  double votePercentB,  Map<String, dynamic> metadata)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.parentPath,_that.messageId,_that.senderId,_that.content,_that.attachmentUrl,_that.attachmentType,_that.timeStamp,_that.isRead,_that.messageType,_that.mediaType,_that.imageUrl,_that.videoUrl,_that.thumbnailUrl,_that.mediaSize,_that.mediaWidth,_that.mediaHeight,_that.deliveredAt,_that.seenAt,_that.receiverId,_that.votePostId,_that.voteTitle,_that.voteDescription,_that.voteOptionAText,_that.voteOptionBText,_that.voteOptionAImage,_that.voteOptionBImage,_that.voteOptionAImages,_that.voteOptionBImages,_that.voteStatus,_that.cardStatus,_that.voteEndTime,_that.voteResults,_that.userVotes,_that.voteAspectRatioA,_that.voteAspectRatioB,_that.voteResultsA,_that.voteResultsB,_that.votePercentA,_that.votePercentB,_that.metadata);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String parentPath,  String messageId,  String senderId,  String content,  String attachmentUrl,  String attachmentType,  DateTime? timeStamp,  bool isRead,  String messageType,  String mediaType,  String imageUrl,  String videoUrl,  String thumbnailUrl,  int mediaSize,  double? mediaWidth,  double? mediaHeight,  DateTime? deliveredAt,  DateTime? seenAt,  String receiverId,  String votePostId,  String voteTitle,  String voteDescription,  String voteOptionAText,  String voteOptionBText,  String voteOptionAImage,  String voteOptionBImage,  List<String> voteOptionAImages,  List<String> voteOptionBImages,  String voteStatus,  String cardStatus,  DateTime? voteEndTime,  Map<String, dynamic> voteResults,  Map<String, dynamic> userVotes,  double? voteAspectRatioA,  double? voteAspectRatioB,  int voteResultsA,  int voteResultsB,  double votePercentA,  double votePercentB,  Map<String, dynamic> metadata)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.parentPath,_that.messageId,_that.senderId,_that.content,_that.attachmentUrl,_that.attachmentType,_that.timeStamp,_that.isRead,_that.messageType,_that.mediaType,_that.imageUrl,_that.videoUrl,_that.thumbnailUrl,_that.mediaSize,_that.mediaWidth,_that.mediaHeight,_that.deliveredAt,_that.seenAt,_that.receiverId,_that.votePostId,_that.voteTitle,_that.voteDescription,_that.voteOptionAText,_that.voteOptionBText,_that.voteOptionAImage,_that.voteOptionBImage,_that.voteOptionAImages,_that.voteOptionBImages,_that.voteStatus,_that.cardStatus,_that.voteEndTime,_that.voteResults,_that.userVotes,_that.voteAspectRatioA,_that.voteAspectRatioB,_that.voteResultsA,_that.voteResultsB,_that.votePercentA,_that.votePercentB,_that.metadata);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message extends Message {
  const _Message({required this.id, required this.parentPath, required this.messageId, required this.senderId, required this.content, this.attachmentUrl = '', this.attachmentType = '', this.timeStamp, required this.isRead, this.messageType = 'text', this.mediaType = 'text', this.imageUrl = '', this.videoUrl = '', this.thumbnailUrl = '', this.mediaSize = 0, this.mediaWidth, this.mediaHeight, this.deliveredAt, this.seenAt, this.receiverId = '', this.votePostId = '', this.voteTitle = '', this.voteDescription = '', this.voteOptionAText = '', this.voteOptionBText = '', this.voteOptionAImage = '', this.voteOptionBImage = '', final  List<String> voteOptionAImages = const [], final  List<String> voteOptionBImages = const [], this.voteStatus = 'pending', this.cardStatus = '', this.voteEndTime, final  Map<String, dynamic> voteResults = const {}, final  Map<String, dynamic> userVotes = const {}, this.voteAspectRatioA, this.voteAspectRatioB, this.voteResultsA = 0, this.voteResultsB = 0, this.votePercentA = 0.0, this.votePercentB = 0.0, final  Map<String, dynamic> metadata = const {}}): _voteOptionAImages = voteOptionAImages,_voteOptionBImages = voteOptionBImages,_voteResults = voteResults,_userVotes = userVotes,_metadata = metadata,super._();
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

// ========== Basic Message Fields ==========
/// 메시지 고유 ID
@override final  String id;
/// 부모 채팅방 경로
@override final  String parentPath;
/// 메시지 ID (messageId 필드)
@override final  String messageId;
/// 발신자 ID
@override final  String senderId;
/// 메시지 내용
@override final  String content;
/// 첨부 파일 URL
@override@JsonKey() final  String attachmentUrl;
/// 첨부 파일 타입
@override@JsonKey() final  String attachmentType;
/// 메시지 생성 시간
@override final  DateTime? timeStamp;
/// 읽음 여부
@override final  bool isRead;
/// 메시지 타입 (text, image, video, vote_request)
@override@JsonKey() final  String messageType;
// ========== Media Fields ==========
/// 미디어 타입 (text, image, video)
@override@JsonKey() final  String mediaType;
/// 이미지 URL
@override@JsonKey() final  String imageUrl;
/// 비디오 URL
@override@JsonKey() final  String videoUrl;
/// 썸네일 URL
@override@JsonKey() final  String thumbnailUrl;
/// 미디어 크기 (bytes)
@override@JsonKey() final  int mediaSize;
/// 미디어 너비
@override final  double? mediaWidth;
/// 미디어 높이
@override final  double? mediaHeight;
// ========== Message Lifecycle ==========
/// 서버에 전달된 시간
@override final  DateTime? deliveredAt;
/// 수신자가 본 시간
@override final  DateTime? seenAt;
// ========== Vote Card Fields ==========
/// 투표 요청을 받는 사용자 ID
@override@JsonKey() final  String receiverId;
/// 연결된 게시물 ID
@override@JsonKey() final  String votePostId;
/// 투표 제목
@override@JsonKey() final  String voteTitle;
/// 투표 설명
@override@JsonKey() final  String voteDescription;
/// 옵션 A 텍스트
@override@JsonKey() final  String voteOptionAText;
/// 옵션 B 텍스트
@override@JsonKey() final  String voteOptionBText;
/// 옵션 A 단일 이미지 (legacy)
@override@JsonKey() final  String voteOptionAImage;
/// 옵션 B 단일 이미지 (legacy)
@override@JsonKey() final  String voteOptionBImage;
/// 옵션 A 이미지 목록
 final  List<String> _voteOptionAImages;
/// 옵션 A 이미지 목록
@override@JsonKey() List<String> get voteOptionAImages {
  if (_voteOptionAImages is EqualUnmodifiableListView) return _voteOptionAImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voteOptionAImages);
}

/// 옵션 B 이미지 목록
 final  List<String> _voteOptionBImages;
/// 옵션 B 이미지 목록
@override@JsonKey() List<String> get voteOptionBImages {
  if (_voteOptionBImages is EqualUnmodifiableListView) return _voteOptionBImages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_voteOptionBImages);
}

/// 투표 상태 (pending, completed, expired)
@override@JsonKey() final  String voteStatus;
/// 투표 카드 상태
@override@JsonKey() final  String cardStatus;
/// 투표 종료 시간
@override final  DateTime? voteEndTime;
/// 투표 결과 (legacy - Map<String, dynamic>)
 final  Map<String, dynamic> _voteResults;
/// 투표 결과 (legacy - Map<String, dynamic>)
@override@JsonKey() Map<String, dynamic> get voteResults {
  if (_voteResults is EqualUnmodifiableMapView) return _voteResults;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_voteResults);
}

/// 사용자별 투표 정보 (userId → {option: 'A'/'B', votedAt: DateTime})
 final  Map<String, dynamic> _userVotes;
/// 사용자별 투표 정보 (userId → {option: 'A'/'B', votedAt: DateTime})
@override@JsonKey() Map<String, dynamic> get userVotes {
  if (_userVotes is EqualUnmodifiableMapView) return _userVotes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_userVotes);
}

/// 옵션 A 이미지 비율
@override final  double? voteAspectRatioA;
/// 옵션 B 이미지 비율
@override final  double? voteAspectRatioB;
/// 옵션 A 투표 수
@override@JsonKey() final  int voteResultsA;
/// 옵션 B 투표 수
@override@JsonKey() final  int voteResultsB;
/// 옵션 A 투표 비율 (%)
@override@JsonKey() final  double votePercentA;
/// 옵션 B 투표 비율 (%)
@override@JsonKey() final  double votePercentB;
// ========== Metadata ==========
/// 추가 메타데이터
 final  Map<String, dynamic> _metadata;
// ========== Metadata ==========
/// 추가 메타데이터
@override@JsonKey() Map<String, dynamic> get metadata {
  if (_metadata is EqualUnmodifiableMapView) return _metadata;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metadata);
}


/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.parentPath, parentPath) || other.parentPath == parentPath)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.senderId, senderId) || other.senderId == senderId)&&(identical(other.content, content) || other.content == content)&&(identical(other.attachmentUrl, attachmentUrl) || other.attachmentUrl == attachmentUrl)&&(identical(other.attachmentType, attachmentType) || other.attachmentType == attachmentType)&&(identical(other.timeStamp, timeStamp) || other.timeStamp == timeStamp)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.messageType, messageType) || other.messageType == messageType)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.videoUrl, videoUrl) || other.videoUrl == videoUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.mediaSize, mediaSize) || other.mediaSize == mediaSize)&&(identical(other.mediaWidth, mediaWidth) || other.mediaWidth == mediaWidth)&&(identical(other.mediaHeight, mediaHeight) || other.mediaHeight == mediaHeight)&&(identical(other.deliveredAt, deliveredAt) || other.deliveredAt == deliveredAt)&&(identical(other.seenAt, seenAt) || other.seenAt == seenAt)&&(identical(other.receiverId, receiverId) || other.receiverId == receiverId)&&(identical(other.votePostId, votePostId) || other.votePostId == votePostId)&&(identical(other.voteTitle, voteTitle) || other.voteTitle == voteTitle)&&(identical(other.voteDescription, voteDescription) || other.voteDescription == voteDescription)&&(identical(other.voteOptionAText, voteOptionAText) || other.voteOptionAText == voteOptionAText)&&(identical(other.voteOptionBText, voteOptionBText) || other.voteOptionBText == voteOptionBText)&&(identical(other.voteOptionAImage, voteOptionAImage) || other.voteOptionAImage == voteOptionAImage)&&(identical(other.voteOptionBImage, voteOptionBImage) || other.voteOptionBImage == voteOptionBImage)&&const DeepCollectionEquality().equals(other._voteOptionAImages, _voteOptionAImages)&&const DeepCollectionEquality().equals(other._voteOptionBImages, _voteOptionBImages)&&(identical(other.voteStatus, voteStatus) || other.voteStatus == voteStatus)&&(identical(other.cardStatus, cardStatus) || other.cardStatus == cardStatus)&&(identical(other.voteEndTime, voteEndTime) || other.voteEndTime == voteEndTime)&&const DeepCollectionEquality().equals(other._voteResults, _voteResults)&&const DeepCollectionEquality().equals(other._userVotes, _userVotes)&&(identical(other.voteAspectRatioA, voteAspectRatioA) || other.voteAspectRatioA == voteAspectRatioA)&&(identical(other.voteAspectRatioB, voteAspectRatioB) || other.voteAspectRatioB == voteAspectRatioB)&&(identical(other.voteResultsA, voteResultsA) || other.voteResultsA == voteResultsA)&&(identical(other.voteResultsB, voteResultsB) || other.voteResultsB == voteResultsB)&&(identical(other.votePercentA, votePercentA) || other.votePercentA == votePercentA)&&(identical(other.votePercentB, votePercentB) || other.votePercentB == votePercentB)&&const DeepCollectionEquality().equals(other._metadata, _metadata));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,parentPath,messageId,senderId,content,attachmentUrl,attachmentType,timeStamp,isRead,messageType,mediaType,imageUrl,videoUrl,thumbnailUrl,mediaSize,mediaWidth,mediaHeight,deliveredAt,seenAt,receiverId,votePostId,voteTitle,voteDescription,voteOptionAText,voteOptionBText,voteOptionAImage,voteOptionBImage,const DeepCollectionEquality().hash(_voteOptionAImages),const DeepCollectionEquality().hash(_voteOptionBImages),voteStatus,cardStatus,voteEndTime,const DeepCollectionEquality().hash(_voteResults),const DeepCollectionEquality().hash(_userVotes),voteAspectRatioA,voteAspectRatioB,voteResultsA,voteResultsB,votePercentA,votePercentB,const DeepCollectionEquality().hash(_metadata)]);

@override
String toString() {
  return 'Message(id: $id, parentPath: $parentPath, messageId: $messageId, senderId: $senderId, content: $content, attachmentUrl: $attachmentUrl, attachmentType: $attachmentType, timeStamp: $timeStamp, isRead: $isRead, messageType: $messageType, mediaType: $mediaType, imageUrl: $imageUrl, videoUrl: $videoUrl, thumbnailUrl: $thumbnailUrl, mediaSize: $mediaSize, mediaWidth: $mediaWidth, mediaHeight: $mediaHeight, deliveredAt: $deliveredAt, seenAt: $seenAt, receiverId: $receiverId, votePostId: $votePostId, voteTitle: $voteTitle, voteDescription: $voteDescription, voteOptionAText: $voteOptionAText, voteOptionBText: $voteOptionBText, voteOptionAImage: $voteOptionAImage, voteOptionBImage: $voteOptionBImage, voteOptionAImages: $voteOptionAImages, voteOptionBImages: $voteOptionBImages, voteStatus: $voteStatus, cardStatus: $cardStatus, voteEndTime: $voteEndTime, voteResults: $voteResults, userVotes: $userVotes, voteAspectRatioA: $voteAspectRatioA, voteAspectRatioB: $voteAspectRatioB, voteResultsA: $voteResultsA, voteResultsB: $voteResultsB, votePercentA: $votePercentA, votePercentB: $votePercentB, metadata: $metadata)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
 String id, String parentPath, String messageId, String senderId, String content, String attachmentUrl, String attachmentType, DateTime? timeStamp, bool isRead, String messageType, String mediaType, String imageUrl, String videoUrl, String thumbnailUrl, int mediaSize, double? mediaWidth, double? mediaHeight, DateTime? deliveredAt, DateTime? seenAt, String receiverId, String votePostId, String voteTitle, String voteDescription, String voteOptionAText, String voteOptionBText, String voteOptionAImage, String voteOptionBImage, List<String> voteOptionAImages, List<String> voteOptionBImages, String voteStatus, String cardStatus, DateTime? voteEndTime, Map<String, dynamic> voteResults, Map<String, dynamic> userVotes, double? voteAspectRatioA, double? voteAspectRatioB, int voteResultsA, int voteResultsB, double votePercentA, double votePercentB, Map<String, dynamic> metadata
});




}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentPath = null,Object? messageId = null,Object? senderId = null,Object? content = null,Object? attachmentUrl = null,Object? attachmentType = null,Object? timeStamp = freezed,Object? isRead = null,Object? messageType = null,Object? mediaType = null,Object? imageUrl = null,Object? videoUrl = null,Object? thumbnailUrl = null,Object? mediaSize = null,Object? mediaWidth = freezed,Object? mediaHeight = freezed,Object? deliveredAt = freezed,Object? seenAt = freezed,Object? receiverId = null,Object? votePostId = null,Object? voteTitle = null,Object? voteDescription = null,Object? voteOptionAText = null,Object? voteOptionBText = null,Object? voteOptionAImage = null,Object? voteOptionBImage = null,Object? voteOptionAImages = null,Object? voteOptionBImages = null,Object? voteStatus = null,Object? cardStatus = null,Object? voteEndTime = freezed,Object? voteResults = null,Object? userVotes = null,Object? voteAspectRatioA = freezed,Object? voteAspectRatioB = freezed,Object? voteResultsA = null,Object? voteResultsB = null,Object? votePercentA = null,Object? votePercentB = null,Object? metadata = null,}) {
  return _then(_Message(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentPath: null == parentPath ? _self.parentPath : parentPath // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,senderId: null == senderId ? _self.senderId : senderId // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,attachmentUrl: null == attachmentUrl ? _self.attachmentUrl : attachmentUrl // ignore: cast_nullable_to_non_nullable
as String,attachmentType: null == attachmentType ? _self.attachmentType : attachmentType // ignore: cast_nullable_to_non_nullable
as String,timeStamp: freezed == timeStamp ? _self.timeStamp : timeStamp // ignore: cast_nullable_to_non_nullable
as DateTime?,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,messageType: null == messageType ? _self.messageType : messageType // ignore: cast_nullable_to_non_nullable
as String,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,videoUrl: null == videoUrl ? _self.videoUrl : videoUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: null == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String,mediaSize: null == mediaSize ? _self.mediaSize : mediaSize // ignore: cast_nullable_to_non_nullable
as int,mediaWidth: freezed == mediaWidth ? _self.mediaWidth : mediaWidth // ignore: cast_nullable_to_non_nullable
as double?,mediaHeight: freezed == mediaHeight ? _self.mediaHeight : mediaHeight // ignore: cast_nullable_to_non_nullable
as double?,deliveredAt: freezed == deliveredAt ? _self.deliveredAt : deliveredAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenAt: freezed == seenAt ? _self.seenAt : seenAt // ignore: cast_nullable_to_non_nullable
as DateTime?,receiverId: null == receiverId ? _self.receiverId : receiverId // ignore: cast_nullable_to_non_nullable
as String,votePostId: null == votePostId ? _self.votePostId : votePostId // ignore: cast_nullable_to_non_nullable
as String,voteTitle: null == voteTitle ? _self.voteTitle : voteTitle // ignore: cast_nullable_to_non_nullable
as String,voteDescription: null == voteDescription ? _self.voteDescription : voteDescription // ignore: cast_nullable_to_non_nullable
as String,voteOptionAText: null == voteOptionAText ? _self.voteOptionAText : voteOptionAText // ignore: cast_nullable_to_non_nullable
as String,voteOptionBText: null == voteOptionBText ? _self.voteOptionBText : voteOptionBText // ignore: cast_nullable_to_non_nullable
as String,voteOptionAImage: null == voteOptionAImage ? _self.voteOptionAImage : voteOptionAImage // ignore: cast_nullable_to_non_nullable
as String,voteOptionBImage: null == voteOptionBImage ? _self.voteOptionBImage : voteOptionBImage // ignore: cast_nullable_to_non_nullable
as String,voteOptionAImages: null == voteOptionAImages ? _self._voteOptionAImages : voteOptionAImages // ignore: cast_nullable_to_non_nullable
as List<String>,voteOptionBImages: null == voteOptionBImages ? _self._voteOptionBImages : voteOptionBImages // ignore: cast_nullable_to_non_nullable
as List<String>,voteStatus: null == voteStatus ? _self.voteStatus : voteStatus // ignore: cast_nullable_to_non_nullable
as String,cardStatus: null == cardStatus ? _self.cardStatus : cardStatus // ignore: cast_nullable_to_non_nullable
as String,voteEndTime: freezed == voteEndTime ? _self.voteEndTime : voteEndTime // ignore: cast_nullable_to_non_nullable
as DateTime?,voteResults: null == voteResults ? _self._voteResults : voteResults // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,userVotes: null == userVotes ? _self._userVotes : userVotes // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,voteAspectRatioA: freezed == voteAspectRatioA ? _self.voteAspectRatioA : voteAspectRatioA // ignore: cast_nullable_to_non_nullable
as double?,voteAspectRatioB: freezed == voteAspectRatioB ? _self.voteAspectRatioB : voteAspectRatioB // ignore: cast_nullable_to_non_nullable
as double?,voteResultsA: null == voteResultsA ? _self.voteResultsA : voteResultsA // ignore: cast_nullable_to_non_nullable
as int,voteResultsB: null == voteResultsB ? _self.voteResultsB : voteResultsB // ignore: cast_nullable_to_non_nullable
as int,votePercentA: null == votePercentA ? _self.votePercentA : votePercentA // ignore: cast_nullable_to_non_nullable
as double,votePercentB: null == votePercentB ? _self.votePercentB : votePercentB // ignore: cast_nullable_to_non_nullable
as double,metadata: null == metadata ? _self._metadata : metadata // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
