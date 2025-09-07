import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/firebase/firestore/utils/schema_util.dart';

import '/core_exports.dart';

class MessagesModel extends FirestoreRecord {
  MessagesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "messageId" field.
  String? _messageId;
  String get messageId => _messageId ?? '';
  bool hasMessageId() => _messageId != null;

  // "senderId" field.
  String? _senderId;
  String get senderId => _senderId ?? '';
  bool hasSenderId() => _senderId != null;

  // "content" field.
  String? _content;
  String get content => _content ?? '';
  bool hasContent() => _content != null;

  // "attachmentUrl" field.
  String? _attachmentUrl;
  String get attachmentUrl => _attachmentUrl ?? '';
  bool hasAttachmentUrl() => _attachmentUrl != null;

  // "attachmentType" field.
  String? _attachmentType;
  String get attachmentType => _attachmentType ?? '';
  bool hasAttachmentType() => _attachmentType != null;

  // "timeStamp" field.
  DateTime? _timeStamp;
  DateTime? get timeStamp => _timeStamp;
  bool hasTimeStamp() => _timeStamp != null;

  // "isRead" field.
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
  // "votePostId" field.
  String? _votePostId;
  String get votePostId => _votePostId ?? '';
  bool hasVotePostId() => _votePostId != null;

  // "voteTitle" field.
  String? _voteTitle;
  String get voteTitle => _voteTitle ?? '';
  bool hasVoteTitle() => _voteTitle != null;

  // "voteDescription" field.
  String? _voteDescription;
  String get voteDescription => _voteDescription ?? '';
  bool hasVoteDescription() => _voteDescription != null;

  // "voteOptionAText" field.
  String? _voteOptionAText;
  String get voteOptionAText => _voteOptionAText ?? '';
  bool hasVoteOptionAText() => _voteOptionAText != null;

  // "voteOptionBText" field.
  String? _voteOptionBText;
  String get voteOptionBText => _voteOptionBText ?? '';
  bool hasVoteOptionBText() => _voteOptionBText != null;

  // "voteOptionAImage" field.
  String? _voteOptionAImage;
  String get voteOptionAImage => _voteOptionAImage ?? '';
  bool hasVoteOptionAImage() => _voteOptionAImage != null;

  // "voteOptionBImage" field.
  String? _voteOptionBImage;
  String get voteOptionBImage => _voteOptionBImage ?? '';
  bool hasVoteOptionBImage() => _voteOptionBImage != null;

  // "voteStatus" field.
  String? _voteStatus;
  String get voteStatus => _voteStatus ?? 'pending';
  bool hasVoteStatus() => _voteStatus != null;

  // NEW: Missing vote-related fields
  // "receiverId" field.
  String? _receiverId;
  String get receiverId => _receiverId ?? '';
  bool hasReceiverId() => _receiverId != null;

  // "voteOptionAImages" field.
  List<String>? _voteOptionAImages;
  List<String> get voteOptionAImages => _voteOptionAImages ?? const [];
  bool hasVoteOptionAImages() => _voteOptionAImages != null;

  // "voteOptionBImages" field.
  List<String>? _voteOptionBImages;
  List<String> get voteOptionBImages => _voteOptionBImages ?? const [];
  bool hasVoteOptionBImages() => _voteOptionBImages != null;

  // "cardStatus" field.
  String? _cardStatus;
  String get cardStatus => _cardStatus ?? '';
  bool hasCardStatus() => _cardStatus != null;

  // "voteEndTime" field.
  DateTime? _voteEndTime;
  DateTime? get voteEndTime => _voteEndTime;
  bool hasVoteEndTime() => _voteEndTime != null;

  // "userVoted" field.
  @deprecated
  bool? _userVoted;
  @deprecated
  bool get userVoted => _userVoted ?? false;
  bool hasUserVoted() => _userVotes != null && _userVotes!.isNotEmpty;

  // "voteChoice" field.
  @deprecated
  String? _voteChoice;
  @deprecated
  String get voteChoice => _voteChoice ?? '';
  bool hasVoteChoice() => _userVotes != null && _userVotes!.isNotEmpty;

  // "voteResults" field.
  Map<String, dynamic>? _voteResults;
  Map<String, dynamic> get voteResults => _voteResults ?? const {};
  bool hasVoteResults() => _voteResults != null;

  // "voteParticipatedAt" field.
  @deprecated
  DateTime? _voteParticipatedAt;
  @deprecated
  DateTime? get voteParticipatedAt => _voteParticipatedAt;
  bool hasVoteParticipatedAt() => _userVotes != null && _userVotes!.isNotEmpty;

  // "userVotes" field - 개별 사용자의 투표 정보를 추적하는 핵심 필드
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
    return vote?['votedAt'] as DateTime?;
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

  // "voteAspectRatioA" field.
  double? _voteAspectRatioA;
  double? get voteAspectRatioA => _voteAspectRatioA;
  bool hasVoteAspectRatioA() => _voteAspectRatioA != null;

  // "voteAspectRatioB" field.
  double? _voteAspectRatioB;
  double? get voteAspectRatioB => _voteAspectRatioB;
  bool hasVoteAspectRatioB() => _voteAspectRatioB != null;

  // "voteResultsA" field.
  int? _voteResultsA;
  int get voteResultsA => _voteResultsA ?? 0;
  bool hasVoteResultsA() => _voteResultsA != null;

  // "voteResultsB" field.
  int? _voteResultsB;
  int get voteResultsB => _voteResultsB ?? 0;
  bool hasVoteResultsB() => _voteResultsB != null;

  // "votePercentA" field.
  double? _votePercentA;
  double get votePercentA => _votePercentA ?? 0.0;
  bool hasVotePercentA() => _votePercentA != null;

  // "votePercentB" field.
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
      'messageId': _messageId,
      'senderId': _senderId,
      'content': _content,
      'attachmentUrl': _attachmentUrl,
      'attachmentType': _attachmentType,
      'timeStamp': _timeStamp?.millisecondsSinceEpoch,
      'isRead': _isRead,
      'mediaType': _mediaType,
      'imageUrl': _imageUrl,
      'videoUrl': _videoUrl,
      'thumbnailUrl': _thumbnailUrl,
      'mediaSize': _mediaSize,
      'mediaWidth': _mediaWidth,
      'mediaHeight': _mediaHeight,
      'deliveredAt': _deliveredAt?.millisecondsSinceEpoch,
      'seenAt': _seenAt?.millisecondsSinceEpoch,
      'messageType': _messageType,
      'receiverId': _receiverId,
      'votePostId': _votePostId,
      'voteTitle': _voteTitle,
      'voteDescription': _voteDescription,
      'voteOptionAText': _voteOptionAText,
      'voteOptionBText': _voteOptionBText,
      'voteOptionAImage': _voteOptionAImage,
      'voteOptionBImage': _voteOptionBImage,
      'voteOptionAImages': _voteOptionAImages,
      'voteOptionBImages': _voteOptionBImages,
      'voteStatus': _voteStatus,
      'voteEndTime': _voteEndTime?.millisecondsSinceEpoch,
      'cardStatus': _cardStatus,
      'voteResults': _voteResults,
      'userVotes': _userVotes,
      'voteAspectRatioA': _voteAspectRatioA,
      'voteAspectRatioB': _voteAspectRatioB,
      'voteResultsA': _voteResultsA,
      'voteResultsB': _voteResultsB,
      'votePercentA': _votePercentA,
      'votePercentB': _votePercentB,
      'metadata': _metadata,
    };
  }

  factory MessagesModel.fromJson(Map<String, dynamic> json) {
    final model = MessagesModel._(
      FirebaseFirestore.instance.doc('temp/temp'), // Temporary reference for cache
      json,  // Use actual json data as snapshotData instead of empty Map
    );
    
    // Helper function to safely parse DateTime from various formats
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      
      try {
        if (value is int) {
          // Milliseconds since epoch
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else if (value is Timestamp) {
          // Firebase Timestamp
          return value.toDate();
        } else if (value is String) {
          // ISO 8601 string
          return DateTime.tryParse(value);
        } else if (value is DateTime) {
          // Already a DateTime
          return value;
        }
      } catch (e) {
        // Log error but don't crash
        print('Error parsing DateTime from value: $value, type: ${value.runtimeType}');
      }
      return null;
    }
    
    // Set all fields from JSON
    model._messageId = json['messageId'] as String?;
    model._senderId = json['senderId'] as String?;
    model._content = json['content'] as String?;
    model._attachmentUrl = json['attachmentUrl'] as String?;
    model._attachmentType = json['attachmentType'] as String?;
    model._timeStamp = parseDateTime(json['timeStamp']);
    model._isRead = json['isRead'] as bool?;
    model._mediaType = json['mediaType'] as String?;
    model._imageUrl = json['imageUrl'] as String?;
    model._videoUrl = json['videoUrl'] as String?;
    model._thumbnailUrl = json['thumbnailUrl'] as String?;
    model._mediaSize = json['mediaSize'] as int?;
    model._mediaWidth = json['mediaWidth'] as double?;
    model._mediaHeight = json['mediaHeight'] as double?;
    model._deliveredAt = parseDateTime(json['deliveredAt']);
    model._seenAt = parseDateTime(json['seenAt']);
    model._messageType = json['messageType'] as String?;
    model._receiverId = json['receiverId'] as String?;
    model._votePostId = json['votePostId'] as String?;
    model._voteTitle = json['voteTitle'] as String?;
    model._voteDescription = json['voteDescription'] as String?;
    model._voteOptionAText = json['voteOptionAText'] as String?;
    model._voteOptionBText = json['voteOptionBText'] as String?;
    model._voteOptionAImage = json['voteOptionAImage'] as String?;
    model._voteOptionBImage = json['voteOptionBImage'] as String?;
    model._voteOptionAImages = (json['voteOptionAImages'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    model._voteOptionBImages = (json['voteOptionBImages'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList();
    model._voteStatus = json['voteStatus'] as String?;
    model._voteEndTime = parseDateTime(json['voteEndTime']);
    model._cardStatus = json['cardStatus'] as String?;
    model._voteResults = json['voteResults'] as Map<String, dynamic>?;
    model._userVotes = json['userVotes'] as Map<String, dynamic>?;
    model._voteAspectRatioA = json['voteAspectRatioA'] as double?;
    model._voteAspectRatioB = json['voteAspectRatioB'] as double?;
    model._voteResultsA = json['voteResultsA'] as int?;
    model._voteResultsB = json['voteResultsB'] as int?;
    model._votePercentA = json['votePercentA'] as double?;
    model._votePercentB = json['votePercentB'] as double?;
    model._metadata = json['metadata'] as Map<String, dynamic>?;
    
    return model;
  }

  void _initializeFields() {
    _messageId = snapshotData['messageId'] as String?;
    _senderId = snapshotData['senderId'] as String?;
    _content = snapshotData['content'] as String?;
    _attachmentUrl = snapshotData['attachmentUrl'] as String?;
    _attachmentType = snapshotData['attachmentType'] as String?;
    _timeStamp = snapshotData['timeStamp'] as DateTime?;
    _isRead = snapshotData['isRead'] as bool?;
    
    // Media fields
    _mediaType = snapshotData['mediaType'] as String?;
    _imageUrl = snapshotData['imageUrl'] as String?;
    _videoUrl = snapshotData['videoUrl'] as String?;
    _thumbnailUrl = snapshotData['thumbnailUrl'] as String?;
    _mediaSize = castToType<int>(snapshotData['mediaSize']);
    _mediaWidth = castToType<double>(snapshotData['mediaWidth']);
    _mediaHeight = castToType<double>(snapshotData['mediaHeight']);
    
    // Message lifecycle fields
    _deliveredAt = snapshotData['deliveredAt'] as DateTime?;
    _seenAt = snapshotData['seenAt'] as DateTime?;
    
    // Message type
    _messageType = snapshotData['messageType'] as String?;
    
    // Vote request fields
    _votePostId = snapshotData['votePostId'] as String?;
    _voteTitle = snapshotData['voteTitle'] as String?;
    _voteDescription = snapshotData['voteDescription'] as String?;
    _voteOptionAText = snapshotData['voteOptionAText'] as String?;
    _voteOptionBText = snapshotData['voteOptionBText'] as String?;
    _voteOptionAImage = snapshotData['voteOptionAImage'] as String?;
    _voteOptionBImage = snapshotData['voteOptionBImage'] as String?;
    _voteStatus = snapshotData['voteStatus'] as String?;
    
    // Initialize new vote-related fields
    _receiverId = snapshotData['receiverId'] as String?;
    _voteOptionAImages = getDataList(snapshotData['voteOptionAImages']);
    _voteOptionBImages = getDataList(snapshotData['voteOptionBImages']);
    _cardStatus = snapshotData['cardStatus'] as String?;
    _voteEndTime = snapshotData['voteEndTime'] as DateTime?;
    _voteResults = snapshotData['voteResults'] as Map<String, dynamic>?;
    _userVotes = snapshotData['userVotes'] as Map<String, dynamic>?;
    
    // AspectRatio and vote results fields
    _voteAspectRatioA = castToType<double>(snapshotData['voteAspectRatioA']);
    _voteAspectRatioB = castToType<double>(snapshotData['voteAspectRatioB']);
    _voteResultsA = castToType<int>(snapshotData['voteResultsA']);
    _voteResultsB = castToType<int>(snapshotData['voteResultsB']);
    _votePercentA = castToType<double>(snapshotData['votePercentA']);
    _votePercentB = castToType<double>(snapshotData['votePercentB']);
    
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
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'timeStamp': timeStamp,
      'isRead': isRead,
      'mediaType': mediaType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaSize': mediaSize,
      'mediaWidth': mediaWidth,
      'mediaHeight': mediaHeight,
      'messageType': messageType,
      'votePostId': votePostId,
      'voteTitle': voteTitle,
      'voteDescription': voteDescription,
      'voteOptionAText': voteOptionAText,
      'voteOptionBText': voteOptionBText,
      'voteOptionAImage': voteOptionAImage,
      'voteOptionBImage': voteOptionBImage,
      'voteStatus': voteStatus,
      'receiverId': receiverId,
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBImages': voteOptionBImages,
      'cardStatus': cardStatus,
      'voteEndTime': voteEndTime,
      'userVoted': userVoted,  // deprecated but kept for backwards compatibility
      'voteChoice': voteChoice,  // deprecated but kept for backwards compatibility
      'voteResults': voteResults,
      'voteParticipatedAt': voteParticipatedAt,  // deprecated but kept for backwards compatibility
      'userVotes': userVotes,
      'voteAspectRatioA': voteAspectRatioA,
      'voteAspectRatioB': voteAspectRatioB,
      'voteResultsA': voteResultsA,
      'voteResultsB': voteResultsB,
      'votePercentA': votePercentA,
      'votePercentB': votePercentB,
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
