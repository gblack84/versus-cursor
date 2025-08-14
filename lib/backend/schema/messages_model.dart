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

  // "delivered_at" field - When message was delivered to server
  DateTime? _deliveredAt;
  DateTime? get deliveredAt => _deliveredAt;
  bool hasDeliveredAt() => _deliveredAt != null;

  // "seen_at" field - When message was seen by recipient
  DateTime? _seenAt;
  DateTime? get seenAt => _seenAt;
  bool hasSeenAt() => _seenAt != null;

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
  @deprecated
  bool? _userVoted;
  @deprecated
  bool get userVoted => _userVoted ?? false;
  bool hasUserVoted() => _userVotes != null && _userVotes!.isNotEmpty;

  // "vote_choice" field.
  @deprecated
  String? _voteChoice;
  @deprecated
  String get voteChoice => _voteChoice ?? '';
  bool hasVoteChoice() => _userVotes != null && _userVotes!.isNotEmpty;

  // "vote_results" field.
  Map<String, dynamic>? _voteResults;
  Map<String, dynamic> get voteResults => _voteResults ?? const {};
  bool hasVoteResults() => _voteResults != null;

  // "vote_participated_at" field.
  @deprecated
  DateTime? _voteParticipatedAt;
  @deprecated
  DateTime? get voteParticipatedAt => _voteParticipatedAt;
  bool hasVoteParticipatedAt() => _userVotes != null && _userVotes!.isNotEmpty;

  // "user_votes" field - 개별 사용자의 투표 정보를 추적하는 핵심 필드
  Map<String, dynamic>? _userVotes;
  Map<String, dynamic> get userVotes => _userVotes ?? const {};
  bool hasUserVotes() => _userVotes != null;

  // 헬퍼 메서드들
  /// 특정 사용자의 투표 정보 가져오기
  Map<String, dynamic>? getUserVote(String userId) {
    if (_userVotes == null) return null;
    return _userVotes![userId] as Map<String, dynamic>?;
  }

  /// 특정 사용자가 투표했는지 확인
  bool checkUserVoted(String userId) {
    if (_userVotes == null) return false;
    return _userVotes!.containsKey(userId);
  }

  /// 특정 사용자의 투표 선택 가져오기
  String? getUserVoteChoice(String userId) {
    final vote = getUserVote(userId);
    return vote?['option'] as String?;
  }

  /// 특정 사용자의 투표 시간 가져오기
  DateTime? getUserVoteTime(String userId) {
    final vote = getUserVote(userId);
    return vote?['voted_at'] as DateTime?;
  }

  // 기존 코드 호환성을 위한 getter (현재 사용자 기준)
  bool get userVotedCompat {
    // currentUserUid가 없으면 기존 필드 사용
    final userId = senderId; // 메시지 발신자를 기본값으로 사용
    return checkUserVoted(userId);
  }

  String get voteChoiceCompat {
    final userId = senderId; // 메시지 발신자를 기본값으로 사용
    return getUserVoteChoice(userId) ?? '';
  }

  DateTime? get voteParticipatedAtCompat {
    final userId = senderId; // 메시지 발신자를 기본값으로 사용
    return getUserVoteTime(userId);
  }

  // \"vote_aspect_ratio_a\" field.
  double? _voteAspectRatioA;
  double? get voteAspectRatioA => _voteAspectRatioA;
  bool hasVoteAspectRatioA() => _voteAspectRatioA != null;

  // \"vote_aspect_ratio_b\" field.
  double? _voteAspectRatioB;
  double? get voteAspectRatioB => _voteAspectRatioB;
  bool hasVoteAspectRatioB() => _voteAspectRatioB != null;

  // \"vote_results_a\" field.
  int? _voteResultsA;
  int get voteResultsA => _voteResultsA ?? 0;
  bool hasVoteResultsA() => _voteResultsA != null;

  // \"vote_results_b\" field.
  int? _voteResultsB;
  int get voteResultsB => _voteResultsB ?? 0;
  bool hasVoteResultsB() => _voteResultsB != null;

  // \"vote_percent_a\" field.
  double? _votePercentA;
  double get votePercentA => _votePercentA ?? 0.0;
  bool hasVotePercentA() => _votePercentA != null;

  // \"vote_percent_b\" field.
  double? _votePercentB;
  double get votePercentB => _votePercentB ?? 0.0;
  bool hasVotePercentB() => _votePercentB != null;

  // \"metadata\" field.
  Map<String, dynamic>? _metadata;
  Map<String, dynamic> get metadata => _metadata ?? const {};
  bool hasMetadata() => _metadata != null;

  DocumentReference get parentReference => reference.parent.parent!;

  // JSON serialization methods for caching
  Map<String, dynamic> toJson() {
    return {
      'message_id': _messageId,
      'sender_id': _senderId,
      'content': _content,
      'attachment_url': _attachmentUrl,
      'attachment_type': _attachmentType,
      'time_stamp': _timeStamp?.millisecondsSinceEpoch,
      'is_read': _isRead,
      'media_type': _mediaType,
      'image_url': _imageUrl,
      'video_url': _videoUrl,
      'thumbnail_url': _thumbnailUrl,
      'media_size': _mediaSize,
      'media_width': _mediaWidth,
      'media_height': _mediaHeight,
      'delivered_at': _deliveredAt?.millisecondsSinceEpoch,
      'seen_at': _seenAt?.millisecondsSinceEpoch,
      'message_type': _messageType,
      'receiver_id': _receiverId,
      'vote_post_id': _votePostId,
      'vote_title': _voteTitle,
      'vote_description': _voteDescription,
      'vote_option_a_text': _voteOptionAText,
      'vote_option_b_text': _voteOptionBText,
      'vote_option_a_image': _voteOptionAImage,
      'vote_option_b_image': _voteOptionBImage,
      'vote_option_a_images': _voteOptionAImages,
      'vote_option_b_images': _voteOptionBImages,
      'vote_status': _voteStatus,
      'vote_end_time': _voteEndTime?.millisecondsSinceEpoch,
      'card_status': _cardStatus,
      'vote_results': _voteResults,
      'user_votes': _userVotes,
      'vote_aspect_ratio_a': _voteAspectRatioA,
      'vote_aspect_ratio_b': _voteAspectRatioB,
      'vote_results_a': _voteResultsA,
      'vote_results_b': _voteResultsB,
      'vote_percent_a': _votePercentA,
      'vote_percent_b': _votePercentB,
      'metadata': _metadata,
    };
  }

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    final model = MessagesModel._(
      FirebaseFirestore.instance.doc('temp/temp'), // Temporary reference for cache
      json,  // Use actual json data as snapshotData instead of empty Map
    );
    
    // Set all fields from JSON
    model._messageId = json['message_id'] as String?;
    model._senderId = json['sender_id'] as String?;
    model._content = json['content'] as String?;
    model._attachmentUrl = json['attachment_url'] as String?;
    model._attachmentType = json['attachment_type'] as String?;
    model._timeStamp = json['time_stamp'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(json['time_stamp'] as int)
        : null;
    model._isRead = json['is_read'] as bool?;
    model._mediaType = json['media_type'] as String?;
    model._imageUrl = json['image_url'] as String?;
    model._videoUrl = json['video_url'] as String?;
    model._thumbnailUrl = json['thumbnail_url'] as String?;
    model._mediaSize = json['media_size'] as int?;
    model._mediaWidth = json['media_width'] as double?;
    model._mediaHeight = json['media_height'] as double?;
    model._deliveredAt = json['delivered_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['delivered_at'] as int)
        : null;
    model._seenAt = json['seen_at'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['seen_at'] as int)
        : null;
    model._messageType = json['message_type'] as String?;
    model._receiverId = json['receiver_id'] as String?;
    model._votePostId = json['vote_post_id'] as String?;
    model._voteTitle = json['vote_title'] as String?;
    model._voteDescription = json['vote_description'] as String?;
    model._voteOptionAText = json['vote_option_a_text'] as String?;
    model._voteOptionBText = json['vote_option_b_text'] as String?;
    model._voteOptionAImage = json['vote_option_a_image'] as String?;
    model._voteOptionBImage = json['vote_option_b_image'] as String?;
    model._voteOptionAImages = (json['vote_option_a_images'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    model._voteOptionBImages = (json['vote_option_b_images'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    model._voteStatus = json['vote_status'] as String?;
    model._voteEndTime = json['vote_end_time'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['vote_end_time'] as int)
        : null;
    model._cardStatus = json['card_status'] as String?;
    model._voteResults = json['vote_results'] as Map<String, dynamic>?;
    model._userVotes = json['user_votes'] as Map<String, dynamic>?;
    model._voteAspectRatioA = json['vote_aspect_ratio_a'] as double?;
    model._voteAspectRatioB = json['vote_aspect_ratio_b'] as double?;
    model._voteResultsA = json['vote_results_a'] as int?;
    model._voteResultsB = json['vote_results_b'] as int?;
    model._votePercentA = json['vote_percent_a'] as double?;
    model._votePercentB = json['vote_percent_b'] as double?;
    model._metadata = json['metadata'] as Map<String, dynamic>?;
    
    return model;
  }

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
    
    // Message lifecycle fields
    _deliveredAt = snapshotData['delivered_at'] as DateTime?;
    _seenAt = snapshotData['seen_at'] as DateTime?;
    
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
    // _userVoted = snapshotData['user_voted'] as bool?;  // deprecated - use user_votes instead
    // _voteChoice = snapshotData['vote_choice'] as String?;  // deprecated - use user_votes instead
    _voteResults = snapshotData['vote_results'] as Map<String, dynamic>?;
    // _voteParticipatedAt = snapshotData['vote_participated_at'] as DateTime?;  // deprecated - use user_votes instead
    _userVotes = snapshotData['user_votes'] as Map<String, dynamic>?;
    
    // AspectRatio and vote results fields
    _voteAspectRatioA = castToType<double>(snapshotData['vote_aspect_ratio_a']);
    _voteAspectRatioB = castToType<double>(snapshotData['vote_aspect_ratio_b']);
    _voteResultsA = castToType<int>(snapshotData['vote_results_a']);
    _voteResultsB = castToType<int>(snapshotData['vote_results_b']);
    _votePercentA = castToType<double>(snapshotData['vote_percent_a']);
    _votePercentB = castToType<double>(snapshotData['vote_percent_b']);
    
    _metadata = snapshotData['metadata'] as Map<String, dynamic>?;
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
  Map<String, dynamic>? userVotes,
  double? voteAspectRatioA,
  double? voteAspectRatioB,
  int? voteResultsA,
  int? voteResultsB,
  double? votePercentA,
  double? votePercentB,
  Map<String, dynamic>? metadata,
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
      'user_votes': userVotes,
      'vote_aspect_ratio_a': voteAspectRatioA,
      'vote_aspect_ratio_b': voteAspectRatioB,
      'vote_results_a': voteResultsA,
      'vote_results_b': voteResultsB,
      'vote_percent_a': votePercentA,
      'vote_percent_b': votePercentB,
      'metadata': metadata,
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
        // e1?.userVoted == e2?.userVoted &&  // deprecated - use userVotes
        // e1?.voteChoice == e2?.voteChoice &&  // deprecated - use userVotes
        e1?.voteResults == e2?.voteResults &&
        // e1?.voteParticipatedAt == e2?.voteParticipatedAt &&  // deprecated - use userVotes
        e1?.userVotes == e2?.userVotes;
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
        // e?.userVoted,  // deprecated - use userVotes
        // e?.voteChoice,  // deprecated - use userVotes
        e?.voteResults,
        // e?.voteParticipatedAt,  // deprecated - use userVotes
        e?.userVotes
      ]);

  @override
  bool isValidKey(Object? o) => o is MessagesModel;
}
