import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class MessagesModel extends FirestoreRecord {
  MessagesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "message_id" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  bool hasMessageId() => _messageId != null;

  // "sender_id" field.
  String? _senderId;
  String get senderId => _senderId ?? '';
  bool hasSenderId() => _senderId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "attachment_url" field.
  String? _attachmentUrl;
  String get attachmentUrl => _attachmentUrl ?? '';
  bool hasAttachmentUrl() => _attachmentUrl != null;

  // "attachment_type" field.
  String? _attachmentType;
  String get attachmentType => _attachmentType ?? '';
  bool hasAttachmentType() => _attachmentType != null;

  // "time_stamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "media_type" field.
  String? _mediaType;
  String get mediaType => _mediaType ?? 'text';
  bool hasMediaType() => _mediaType != null;

  // "image_url" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "video_url" field.
  String? _videoUrl;
  String get videoUrl => _videoUrl ?? '';
  bool hasVideoUrl() => _videoUrl != null;

  // "thumbnail_url" field.
  String? _thumbnailUrl;
  String get thumbnailUrl => _thumbnailUrl ?? '';
  bool hasThumbnailUrl() => _thumbnailUrl != null;

  // "media_size" field.
  int? _mediaSize;
  int get mediaSize => _mediaSize ?? 0;
  bool hasMediaSize() => _mediaSize != null;

  // "media_width" field.
  double? _mediaWidth;
  double? get mediaWidth => _mediaWidth;
  bool hasMediaWidth() => _mediaWidth != null;

  // "media_height" field.
  double? _mediaHeight;
  double? get mediaHeight => _mediaHeight;
  bool hasMediaHeight() => _mediaHeight != null;

  // "message_type" field.
  String? _messageType;
  String get messageType => _messageType ?? 'text';
  bool hasMessageType() => _messageType != null;

  // Vote request fields
  // "vote_post_id" field.
  String? _votePostId;
  String get votePostId => _votePostId ?? '';
  bool hasVotePostId() => _votePostId != null;

  // "vote_title" field.
  String? _voteTitle;
  String get voteTitle => _voteTitle ?? '';
  bool hasVoteTitle() => _voteTitle != null;

  // "vote_description" field.
  String? _voteDescription;
  String get voteDescription => _voteDescription ?? '';
  bool hasVoteDescription() => _voteDescription != null;

  // "vote_option_a_text" field.
  String? _voteOptionAText;
  String get voteOptionAText => _voteOptionAText ?? '';
  bool hasVoteOptionAText() => _voteOptionAText != null;

  // "vote_option_b_text" field.
  String? _voteOptionBText;
  String get voteOptionBText => _voteOptionBText ?? '';
  bool hasVoteOptionBText() => _voteOptionBText != null;

  // "vote_option_a_image" field.
  String? _voteOptionAImage;
  String get voteOptionAImage => _voteOptionAImage ?? '';
  bool hasVoteOptionAImage() => _voteOptionAImage != null;

  // "vote_option_b_image" field.
  String? _voteOptionBImage;
  String get voteOptionBImage => _voteOptionBImage ?? '';
  bool hasVoteOptionBImage() => _voteOptionBImage != null;

  // "vote_status" field.
  String? _voteStatus;
  String get voteStatus => _voteStatus ?? 'pending';
  bool hasVoteStatus() => _voteStatus != null;

  // NEW: Missing vote-related fields
  // "receiver_id" field.
  String? _receiverId;
  String get receiverId => _receiverId ?? '';
  bool hasReceiverId() => _receiverId != null;

  // "vote_option_a_images" field.
  List<String>? _voteOptionAImages;
  List<String> get voteOptionAImages => _voteOptionAImages ?? const [];
  bool hasVoteOptionAImages() => _voteOptionAImages != null;

  // "vote_option_b_images" field.
  List<String>? _voteOptionBImages;
  List<String> get voteOptionBImages => _voteOptionBImages ?? const [];
  bool hasVoteOptionBImages() => _voteOptionBImages != null;

  // "card_status" field.
  String? _cardStatus;
  String get cardStatus => _cardStatus ?? '';
  bool hasCardStatus() => _cardStatus != null;

  // "vote_end_time" field.
  DateTime? _voteEndTime;
  DateTime? get voteEndTime => _voteEndTime;
  bool hasVoteEndTime() => _voteEndTime != null;

  // "user_voted" field.
  bool? _userVoted;
  bool get userVoted => _userVoted ?? false;
  bool hasUserVoted() => _userVoted != null;

  // "vote_choice" field.
  String? _voteChoice;
  String get voteChoice => _voteChoice ?? '';
  bool hasVoteChoice() => _voteChoice != null;

  // "vote_results" field.
  Map<String, dynamic>? _voteResults;
  Map<String, dynamic> get voteResults => _voteResults ?? const {};
  bool hasVoteResults() => _voteResults != null;

  // "vote_participated_at" field.
  DateTime? _voteParticipatedAt;
  DateTime? get voteParticipatedAt => _voteParticipatedAt;
  bool hasVoteParticipatedAt() => _voteParticipatedAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _messageId = snapshotData['message_id'] as String?;
    _senderId = snapshotData['sender_id'] as String?;
    _content = snapshotData['content'] as String?;
    _attachmentUrl = snapshotData['attachment_url'] as String?;
    _attachmentType = snapshotData['attachment_type'] as String?;
    _timeStamp = snapshotData['time_stamp'] as DateTime?;
    _isRead = snapshotData['is_read'] as bool?;
    
    // Media fields
    _mediaType = snapshotData['media_type'] as String?;
    _imageUrl = snapshotData['image_url'] as String?;
    _videoUrl = snapshotData['video_url'] as String?;
    _thumbnailUrl = snapshotData['thumbnail_url'] as String?;
    _mediaSize = castToType<int>(snapshotData['media_size']);
    _mediaWidth = castToType<double>(snapshotData['media_width']);
    _mediaHeight = castToType<double>(snapshotData['media_height']);
    
    // Message type
    _messageType = snapshotData['message_type'] as String?;
    
    // Vote request fields
    _votePostId = snapshotData['vote_post_id'] as String?;
    _voteTitle = snapshotData['vote_title'] as String?;
    _voteDescription = snapshotData['vote_description'] as String?;
    _voteOptionAText = snapshotData['vote_option_a_text'] as String?;
    _voteOptionBText = snapshotData['vote_option_b_text'] as String?;
    _voteOptionAImage = snapshotData['vote_option_a_image'] as String?;
    _voteOptionBImage = snapshotData['vote_option_b_image'] as String?;
    _voteStatus = snapshotData['vote_status'] as String?;
    
    // Initialize new vote-related fields
    _receiverId = snapshotData['receiver_id'] as String?;
    _voteOptionAImages = getDataList(snapshotData['vote_option_a_images']);
    _voteOptionBImages = getDataList(snapshotData['vote_option_b_images']);
    _cardStatus = snapshotData['card_status'] as String?;
    _voteEndTime = snapshotData['vote_end_time'] as DateTime?;
    _userVoted = snapshotData['user_voted'] as bool?;
    _voteChoice = snapshotData['vote_choice'] as String?;
    _voteResults = snapshotData['vote_results'] as Map<String, dynamic>?;
    _voteParticipatedAt = snapshotData['vote_participated_at'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('messages')
          : FirebaseFirestore.instance.collectionGroup('messages');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('messages').doc(id);

  static Stream<MessagesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => MessagesModel.fromSnapshot(s));

  static Future<MessagesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => MessagesModel.fromSnapshot(s));

  static MessagesModel fromSnapshot(DocumentSnapshot snapshot) =>
      MessagesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static MessagesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      MessagesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'MessagesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is MessagesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createMessagesModelData({
  String? messageId,
  String? senderId,
  String? content,
  String? attachmentUrl,
  String? attachmentType,
  DateTime? timeStamp,
  bool? isRead,
  String? mediaType,
  String? imageUrl,
  String? videoUrl,
  String? thumbnailUrl,
  int? mediaSize,
  double? mediaWidth,
  double? mediaHeight,
  String? messageType,
  String? votePostId,
  String? voteTitle,
  String? voteDescription,
  String? voteOptionAText,
  String? voteOptionBText,
  String? voteOptionAImage,
  String? voteOptionBImage,
  String? voteStatus,
  String? receiverId,
  List<String>? voteOptionAImages,
  List<String>? voteOptionBImages,
  String? cardStatus,
  DateTime? voteEndTime,
  bool? userVoted,
  String? voteChoice,
  Map<String, dynamic>? voteResults,
  DateTime? voteParticipatedAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'message_id': messageId,
      'sender_id': senderId,
      'content': content,
      'attachment_url': attachmentUrl,
      'attachment_type': attachmentType,
      'time_stamp': timeStamp,
      'is_read': isRead,
      'media_type': mediaType,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'thumbnail_url': thumbnailUrl,
      'media_size': mediaSize,
      'media_width': mediaWidth,
      'media_height': mediaHeight,
      'message_type': messageType,
      'vote_post_id': votePostId,
      'vote_title': voteTitle,
      'vote_description': voteDescription,
      'vote_option_a_text': voteOptionAText,
      'vote_option_b_text': voteOptionBText,
      'vote_option_a_image': voteOptionAImage,
      'vote_option_b_image': voteOptionBImage,
      'vote_status': voteStatus,
      'receiver_id': receiverId,
      'vote_option_a_images': voteOptionAImages,
      'vote_option_b_images': voteOptionBImages,
      'card_status': cardStatus,
      'vote_end_time': voteEndTime,
      'user_voted': userVoted,
      'vote_choice': voteChoice,
      'vote_results': voteResults,
      'vote_participated_at': voteParticipatedAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class MessagesModelDocumentEquality implements Equality<MessagesModel> {
  const MessagesModelDocumentEquality();

  @override
  bool equals(MessagesModel? e1, MessagesModel? e2) {
    const listEquality = ListEquality();
    return e1?.messageId == e2?.messageId &&
        e1?.senderId == e2?.senderId &&
        e1?.content == e2?.content &&
        e1?.attachmentUrl == e2?.attachmentUrl &&
        e1?.attachmentType == e2?.attachmentType &&
        e1?.timeStamp == e2?.timeStamp &&
        e1?.isRead == e2?.isRead &&
        e1?.mediaType == e2?.mediaType &&
        e1?.imageUrl == e2?.imageUrl &&
        e1?.videoUrl == e2?.videoUrl &&
        e1?.thumbnailUrl == e2?.thumbnailUrl &&
        e1?.mediaSize == e2?.mediaSize &&
        e1?.mediaWidth == e2?.mediaWidth &&
        e1?.mediaHeight == e2?.mediaHeight &&
        e1?.messageType == e2?.messageType &&
        e1?.votePostId == e2?.votePostId &&
        e1?.voteTitle == e2?.voteTitle &&
        e1?.voteDescription == e2?.voteDescription &&
        e1?.voteOptionAText == e2?.voteOptionAText &&
        e1?.voteOptionBText == e2?.voteOptionBText &&
        e1?.voteOptionAImage == e2?.voteOptionAImage &&
        e1?.voteOptionBImage == e2?.voteOptionBImage &&
        e1?.voteStatus == e2?.voteStatus &&
        e1?.receiverId == e2?.receiverId &&
        listEquality.equals(e1?.voteOptionAImages, e2?.voteOptionAImages) &&
        listEquality.equals(e1?.voteOptionBImages, e2?.voteOptionBImages) &&
        e1?.cardStatus == e2?.cardStatus &&
        e1?.voteEndTime == e2?.voteEndTime &&
        e1?.userVoted == e2?.userVoted &&
        e1?.voteChoice == e2?.voteChoice &&
        e1?.voteResults == e2?.voteResults &&
        e1?.voteParticipatedAt == e2?.voteParticipatedAt;
  }

  @override
  int hash(MessagesModel? e) => const ListEquality().hash([
        e?.messageId,
        e?.senderId,
        e?.content,
        e?.attachmentUrl,
        e?.attachmentType,
        e?.timeStamp,
        e?.isRead,
        e?.mediaType,
        e?.imageUrl,
        e?.videoUrl,
        e?.thumbnailUrl,
        e?.mediaSize,
        e?.mediaWidth,
        e?.mediaHeight,
        e?.messageType,
        e?.votePostId,
        e?.voteTitle,
        e?.voteDescription,
        e?.voteOptionAText,
        e?.voteOptionBText,
        e?.voteOptionAImage,
        e?.voteOptionBImage,
        e?.voteStatus,
        e?.receiverId,
        e?.voteOptionAImages,
        e?.voteOptionBImages,
        e?.cardStatus,
        e?.voteEndTime,
        e?.userVoted,
        e?.voteChoice,
        e?.voteResults,
        e?.voteParticipatedAt
      ]);

  @override
  bool isValidKey(Object? o) => o is MessagesModel;
}
