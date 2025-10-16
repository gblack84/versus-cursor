import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/message.dart';

/// Data Transfer Object for Message
///
/// **Clean Architecture v4.0 - DTO Layer**:
/// - Firestore DocumentSnapshot → MessageDto 변환
/// - Firestore 타입을 순수 Dart 타입으로 변환
/// - Domain Entity로의 변환은 toDomain()에서 처리 (Phase 2에서 구현)
///
/// **필드 카테고리**:
/// - Basic Message: id, messageId, senderId, content, attachmentUrl/Type, timeStamp, isRead
/// - Media: mediaType, imageUrl, videoUrl, thumbnailUrl, mediaSize/Width/Height
/// - Lifecycle: deliveredAt, seenAt
/// - Vote Card: votePostId, voteTitle, voteOptionA/B*, voteResults, userVotes
/// - Metadata: metadata
class MessageDto {
  // ========== Basic Message Fields ==========
  /// 메시지 문서 ID (reference.id)
  final String id;

  /// 부모 채팅방 경로 (parent reference path)
  final String parentPath;

  /// 메시지 ID (messageId 필드)
  final String messageId;

  /// 발신자 ID
  final String senderId;

  /// 메시지 내용
  final String content;

  /// 첨부 파일 URL
  final String attachmentUrl;

  /// 첨부 파일 타입
  final String attachmentType;

  /// 메시지 생성 시간
  final DateTime? timeStamp;

  /// 읽음 여부
  final bool isRead;

  /// 메시지 타입 (text, vote_request 등)
  final String messageType;

  // ========== Media Fields ==========
  /// 미디어 타입 (text, image, video)
  final String mediaType;

  /// 이미지 URL
  final String imageUrl;

  /// 비디오 URL
  final String videoUrl;

  /// 썸네일 URL
  final String thumbnailUrl;

  /// 미디어 크기 (bytes)
  final int mediaSize;

  /// 미디어 너비
  final double? mediaWidth;

  /// 미디어 높이
  final double? mediaHeight;

  // ========== Message Lifecycle ==========
  /// 서버에 전달된 시간
  final DateTime? deliveredAt;

  /// 수신자가 본 시간
  final DateTime? seenAt;

  // ========== Vote Card Fields ==========
  /// 투표 요청을 받는 사용자 ID
  final String receiverId;

  /// 연결된 게시물 ID
  final String votePostId;

  /// 투표 제목
  final String voteTitle;

  /// 투표 설명
  final String voteDescription;

  /// 옵션 A 텍스트
  final String voteOptionAText;

  /// 옵션 B 텍스트
  final String voteOptionBText;

  /// 옵션 A 단일 이미지 (legacy)
  final String voteOptionAImage;

  /// 옵션 B 단일 이미지 (legacy)
  final String voteOptionBImage;

  /// 옵션 A 이미지 목록
  final List<String> voteOptionAImages;

  /// 옵션 B 이미지 목록
  final List<String> voteOptionBImages;

  /// 투표 상태 (pending, completed, expired)
  final String voteStatus;

  /// 투표 카드 상태 (진행중, 완료 등)
  final String cardStatus;

  /// 투표 종료 시간
  final DateTime? voteEndTime;

  /// 투표 결과 (legacy - Map<String, dynamic>)
  final Map<String, dynamic> voteResults;

  /// 사용자별 투표 정보 (userId → {option: 'A'/'B', votedAt: DateTime})
  final Map<String, dynamic> userVotes;

  /// 옵션 A 이미지 비율
  final double? voteAspectRatioA;

  /// 옵션 B 이미지 비율
  final double? voteAspectRatioB;

  /// 옵션 A 투표 수
  final int voteResultsA;

  /// 옵션 B 투표 수
  final int voteResultsB;

  /// 옵션 A 투표 비율 (%)
  final double votePercentA;

  /// 옵션 B 투표 비율 (%)
  final double votePercentB;

  // ========== Metadata ==========
  /// 추가 메타데이터
  final Map<String, dynamic> metadata;

  const MessageDto({
    required this.id,
    required this.parentPath,
    required this.messageId,
    required this.senderId,
    required this.content,
    required this.attachmentUrl,
    required this.attachmentType,
    this.timeStamp,
    required this.isRead,
    required this.messageType,
    required this.mediaType,
    required this.imageUrl,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.mediaSize,
    this.mediaWidth,
    this.mediaHeight,
    this.deliveredAt,
    this.seenAt,
    required this.receiverId,
    required this.votePostId,
    required this.voteTitle,
    required this.voteDescription,
    required this.voteOptionAText,
    required this.voteOptionBText,
    required this.voteOptionAImage,
    required this.voteOptionBImage,
    required this.voteOptionAImages,
    required this.voteOptionBImages,
    required this.voteStatus,
    required this.cardStatus,
    this.voteEndTime,
    required this.voteResults,
    required this.userVotes,
    this.voteAspectRatioA,
    this.voteAspectRatioB,
    required this.voteResultsA,
    required this.voteResultsB,
    required this.votePercentA,
    required this.votePercentB,
    required this.metadata,
  });

  /// Firestore DocumentSnapshot → MessageDto 변환
  ///
  /// **변환 내역**:
  /// - DocumentReference → String id
  /// - parent.parent → String parentPath
  /// - Timestamp → DateTime
  /// - null-safe 기본값 적용
  factory MessageDto.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    // Helper: Timestamp/DateTime 안전 변환
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;

      try {
        if (value is int) {
          return DateTime.fromMillisecondsSinceEpoch(value);
        } else if (value is Timestamp) {
          return value.toDate();
        } else if (value is String) {
          return DateTime.tryParse(value);
        } else if (value is DateTime) {
          return value;
        }
      } catch (e) {
        // Silent fail - 로그는 Repository에서 처리
      }
      return null;
    }

    // Helper: List<String> 안전 변환
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return [];
    }

    // Helper: Map<String, dynamic> 안전 변환
    Map<String, dynamic> parseMap(dynamic value) {
      if (value == null) return {};
      if (value is Map<String, dynamic>) return value;
      if (value is Map) {
        return value.cast<String, dynamic>();
      }
      return {};
    }

    // Helper: int 안전 변환
    int parseInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper: double 안전 변환
    double parseDouble(dynamic value, {double defaultValue = 0.0}) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper: double? 안전 변환 (null 허용)
    double? parseDoubleNullable(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    // Parent path 추출
    String parentPath = '';
    final parent = snapshot.reference.parent.parent;
    if (parent != null) {
      parentPath = parent.path;
    }

    return MessageDto(
      id: snapshot.id,
      parentPath: parentPath,
      messageId: data['messageId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      attachmentUrl: data['attachmentUrl'] as String? ?? '',
      attachmentType: data['attachmentType'] as String? ?? '',
      timeStamp: parseDateTime(data['timeStamp']),
      isRead: data['isRead'] as bool? ?? false,
      messageType: data['messageType'] as String? ?? 'text',
      mediaType: data['mediaType'] as String? ?? 'text',
      imageUrl: data['imageUrl'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      mediaSize: parseInt(data['mediaSize']),
      mediaWidth: parseDoubleNullable(data['mediaWidth']),
      mediaHeight: parseDoubleNullable(data['mediaHeight']),
      deliveredAt: parseDateTime(data['deliveredAt']),
      seenAt: parseDateTime(data['seenAt']),
      receiverId: data['receiverId'] as String? ?? '',
      votePostId: data['votePostId'] as String? ?? '',
      voteTitle: data['voteTitle'] as String? ?? '',
      voteDescription: data['voteDescription'] as String? ?? '',
      voteOptionAText: data['voteOptionAText'] as String? ?? '',
      voteOptionBText: data['voteOptionBText'] as String? ?? '',
      voteOptionAImage: data['voteOptionAImage'] as String? ?? '',
      voteOptionBImage: data['voteOptionBImage'] as String? ?? '',
      voteOptionAImages: parseStringList(data['voteOptionAImages']),
      voteOptionBImages: parseStringList(data['voteOptionBImages']),
      voteStatus: data['voteStatus'] as String? ?? 'pending',
      cardStatus: data['cardStatus'] as String? ?? '',
      voteEndTime: parseDateTime(data['voteEndTime']),
      voteResults: parseMap(data['voteResults']),
      userVotes: parseMap(data['userVotes']),
      voteAspectRatioA: parseDoubleNullable(data['voteAspectRatioA']),
      voteAspectRatioB: parseDoubleNullable(data['voteAspectRatioB']),
      voteResultsA: parseInt(data['voteResultsA']),
      voteResultsB: parseInt(data['voteResultsB']),
      votePercentA: parseDouble(data['votePercentA']),
      votePercentB: parseDouble(data['votePercentB']),
      metadata: parseMap(data['metadata']),
    );
  }

  /// MessageDto → Firestore Document 변환
  ///
  /// **사용처**: Repository에서 메시지 생성/업데이트 시 사용
  Map<String, dynamic> toFirestore() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'timeStamp': timeStamp != null ? Timestamp.fromDate(timeStamp!) : null,
      'isRead': isRead,
      'messageType': messageType,
      'mediaType': mediaType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaSize': mediaSize,
      'mediaWidth': mediaWidth,
      'mediaHeight': mediaHeight,
      'deliveredAt': deliveredAt != null ? Timestamp.fromDate(deliveredAt!) : null,
      'seenAt': seenAt != null ? Timestamp.fromDate(seenAt!) : null,
      'receiverId': receiverId,
      'votePostId': votePostId,
      'voteTitle': voteTitle,
      'voteDescription': voteDescription,
      'voteOptionAText': voteOptionAText,
      'voteOptionBText': voteOptionBText,
      'voteOptionAImage': voteOptionAImage,
      'voteOptionBImage': voteOptionBImage,
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBImages': voteOptionBImages,
      'voteStatus': voteStatus,
      'cardStatus': cardStatus,
      'voteEndTime': voteEndTime != null ? Timestamp.fromDate(voteEndTime!) : null,
      'voteResults': voteResults,
      'userVotes': userVotes,
      'voteAspectRatioA': voteAspectRatioA,
      'voteAspectRatioB': voteAspectRatioB,
      'voteResultsA': voteResultsA,
      'voteResultsB': voteResultsB,
      'votePercentA': votePercentA,
      'votePercentB': votePercentB,
      'metadata': metadata,
    };
  }

  /// JSON 직렬화 (Hive 캐싱용)
  ///
  /// **사용처**: UnifiedCacheService에서 메시지 캐싱 시 사용
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parentPath': parentPath,
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      'timeStamp': timeStamp?.millisecondsSinceEpoch,
      'isRead': isRead,
      'messageType': messageType,
      'mediaType': mediaType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaSize': mediaSize,
      'mediaWidth': mediaWidth,
      'mediaHeight': mediaHeight,
      'deliveredAt': deliveredAt?.millisecondsSinceEpoch,
      'seenAt': seenAt?.millisecondsSinceEpoch,
      'receiverId': receiverId,
      'votePostId': votePostId,
      'voteTitle': voteTitle,
      'voteDescription': voteDescription,
      'voteOptionAText': voteOptionAText,
      'voteOptionBText': voteOptionBText,
      'voteOptionAImage': voteOptionAImage,
      'voteOptionBImage': voteOptionBImage,
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBImages': voteOptionBImages,
      'voteStatus': voteStatus,
      'cardStatus': cardStatus,
      'voteEndTime': voteEndTime?.millisecondsSinceEpoch,
      'voteResults': voteResults,
      'userVotes': userVotes,
      'voteAspectRatioA': voteAspectRatioA,
      'voteAspectRatioB': voteAspectRatioB,
      'voteResultsA': voteResultsA,
      'voteResultsB': voteResultsB,
      'votePercentA': votePercentA,
      'votePercentB': votePercentB,
      'metadata': metadata,
    };
  }

  /// JSON → MessageDto 역직렬화 (Hive 캐싱용)
  ///
  /// **사용처**: UnifiedCacheService에서 캐시 복원 시 사용
  factory MessageDto.fromJson(Map<String, dynamic> json) {
    // Helper: DateTime 파싱
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
      if (value is String) return DateTime.tryParse(value);
      if (value is DateTime) return value;
      return null;
    }

    return MessageDto(
      id: json['id'] as String? ?? '',
      parentPath: json['parentPath'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      senderId: json['senderId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String? ?? '',
      attachmentType: json['attachmentType'] as String? ?? '',
      timeStamp: parseDateTime(json['timeStamp']),
      isRead: json['isRead'] as bool? ?? false,
      messageType: json['messageType'] as String? ?? 'text',
      mediaType: json['mediaType'] as String? ?? 'text',
      imageUrl: json['imageUrl'] as String? ?? '',
      videoUrl: json['videoUrl'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      mediaSize: json['mediaSize'] as int? ?? 0,
      mediaWidth: json['mediaWidth'] as double?,
      mediaHeight: json['mediaHeight'] as double?,
      deliveredAt: parseDateTime(json['deliveredAt']),
      seenAt: parseDateTime(json['seenAt']),
      receiverId: json['receiverId'] as String? ?? '',
      votePostId: json['votePostId'] as String? ?? '',
      voteTitle: json['voteTitle'] as String? ?? '',
      voteDescription: json['voteDescription'] as String? ?? '',
      voteOptionAText: json['voteOptionAText'] as String? ?? '',
      voteOptionBText: json['voteOptionBText'] as String? ?? '',
      voteOptionAImage: json['voteOptionAImage'] as String? ?? '',
      voteOptionBImage: json['voteOptionBImage'] as String? ?? '',
      voteOptionAImages: (json['voteOptionAImages'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      voteOptionBImages: (json['voteOptionBImages'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      voteStatus: json['voteStatus'] as String? ?? 'pending',
      cardStatus: json['cardStatus'] as String? ?? '',
      voteEndTime: parseDateTime(json['voteEndTime']),
      voteResults: json['voteResults'] as Map<String, dynamic>? ?? {},
      userVotes: json['userVotes'] as Map<String, dynamic>? ?? {},
      voteAspectRatioA: json['voteAspectRatioA'] as double?,
      voteAspectRatioB: json['voteAspectRatioB'] as double?,
      voteResultsA: json['voteResultsA'] as int? ?? 0,
      voteResultsB: json['voteResultsB'] as int? ?? 0,
      votePercentA: json['votePercentA'] as double? ?? 0.0,
      votePercentB: json['votePercentB'] as double? ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  // ========== Helper Methods (기존 MessagesModel 호환) ==========

  /// 특정 사용자의 투표 정보 가져오기
  Map<String, dynamic>? getUserVote(String userId) {
    return userVotes[userId] as Map<String, dynamic>?;
  }

  /// 특정 사용자가 투표했는지 확인
  bool checkUserVoted(String userId) {
    return userVotes.containsKey(userId);
  }

  /// 특정 사용자의 투표 선택 가져오기
  String? getUserVoteChoice(String userId) {
    final vote = getUserVote(userId);
    return vote?['option'] as String?;
  }

  /// 특정 사용자의 투표 시간 가져오기
  DateTime? getUserVoteTime(String userId) {
    final vote = getUserVote(userId);
    final timestamp = vote?['votedAt'];
    if (timestamp is DateTime) return timestamp;
    if (timestamp is Timestamp) return timestamp.toDate();
    return null;
  }

  /// MessageDto → Domain Entity 변환
  ///
  /// **Clean Architecture v4.0**:
  /// - DTO (Infrastructure) → Entity (Domain)
  /// - 순수 Dart 타입만 사용
  /// - Firestore 의존성 제거
  ///
  /// **사용처**: Repository에서 Domain Layer로 데이터 전달 시
  Message toDomain() {
    return Message(
      id: id,
      parentPath: parentPath,
      messageId: messageId,
      senderId: senderId,
      content: content,
      attachmentUrl: attachmentUrl,
      attachmentType: attachmentType,
      timeStamp: timeStamp,
      isRead: isRead,
      messageType: messageType,
      mediaType: mediaType,
      imageUrl: imageUrl,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      mediaSize: mediaSize,
      mediaWidth: mediaWidth,
      mediaHeight: mediaHeight,
      deliveredAt: deliveredAt,
      seenAt: seenAt,
      receiverId: receiverId,
      votePostId: votePostId,
      voteTitle: voteTitle,
      voteDescription: voteDescription,
      voteOptionAText: voteOptionAText,
      voteOptionBText: voteOptionBText,
      voteOptionAImage: voteOptionAImage,
      voteOptionBImage: voteOptionBImage,
      voteOptionAImages: List.unmodifiable(voteOptionAImages),
      voteOptionBImages: List.unmodifiable(voteOptionBImages),
      voteStatus: voteStatus,
      cardStatus: cardStatus,
      voteEndTime: voteEndTime,
      voteResults: Map.unmodifiable(voteResults),
      userVotes: Map.unmodifiable(userVotes),
      voteAspectRatioA: voteAspectRatioA,
      voteAspectRatioB: voteAspectRatioB,
      voteResultsA: voteResultsA,
      voteResultsB: voteResultsB,
      votePercentA: votePercentA,
      votePercentB: votePercentB,
      metadata: Map.unmodifiable(metadata),
    );
  }

  /// Domain Entity → DTO 변환
  ///
  /// **Clean Architecture v4.0**:
  /// - Entity (Domain) → DTO (Infrastructure)
  /// - Repository에서 Firestore로 저장 시 사용
  ///
  /// **사용처**: sendMessage 등에서 사용
  factory MessageDto.fromDomain(Message entity) {
    return MessageDto(
      id: entity.id,
      parentPath: entity.parentPath,
      messageId: entity.messageId,
      senderId: entity.senderId,
      content: entity.content,
      attachmentUrl: entity.attachmentUrl,
      attachmentType: entity.attachmentType,
      timeStamp: entity.timeStamp,
      isRead: entity.isRead,
      messageType: entity.messageType,
      mediaType: entity.mediaType,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      mediaSize: entity.mediaSize,
      mediaWidth: entity.mediaWidth,
      mediaHeight: entity.mediaHeight,
      deliveredAt: entity.deliveredAt,
      seenAt: entity.seenAt,
      receiverId: entity.receiverId,
      votePostId: entity.votePostId,
      voteTitle: entity.voteTitle,
      voteDescription: entity.voteDescription,
      voteOptionAText: entity.voteOptionAText,
      voteOptionBText: entity.voteOptionBText,
      voteOptionAImage: entity.voteOptionAImage,
      voteOptionBImage: entity.voteOptionBImage,
      voteOptionAImages: entity.voteOptionAImages.toList(),
      voteOptionBImages: entity.voteOptionBImages.toList(),
      voteStatus: entity.voteStatus,
      cardStatus: entity.cardStatus,
      voteEndTime: entity.voteEndTime,
      voteResults: Map<String, dynamic>.from(entity.voteResults),
      userVotes: Map<String, dynamic>.from(entity.userVotes),
      voteAspectRatioA: entity.voteAspectRatioA,
      voteAspectRatioB: entity.voteAspectRatioB,
      voteResultsA: entity.voteResultsA,
      voteResultsB: entity.voteResultsB,
      votePercentA: entity.votePercentA,
      votePercentB: entity.votePercentB,
      metadata: Map<String, dynamic>.from(entity.metadata),
    );
  }

  /// MessageDto 복사 (일부 필드 변경)
  MessageDto copyWith({
    String? id,
    String? parentPath,
    String? messageId,
    String? senderId,
    String? content,
    String? attachmentUrl,
    String? attachmentType,
    DateTime? timeStamp,
    bool? isRead,
    String? messageType,
    String? mediaType,
    String? imageUrl,
    String? videoUrl,
    String? thumbnailUrl,
    int? mediaSize,
    double? mediaWidth,
    double? mediaHeight,
    DateTime? deliveredAt,
    DateTime? seenAt,
    String? receiverId,
    String? votePostId,
    String? voteTitle,
    String? voteDescription,
    String? voteOptionAText,
    String? voteOptionBText,
    String? voteOptionAImage,
    String? voteOptionBImage,
    List<String>? voteOptionAImages,
    List<String>? voteOptionBImages,
    String? voteStatus,
    String? cardStatus,
    DateTime? voteEndTime,
    Map<String, dynamic>? voteResults,
    Map<String, dynamic>? userVotes,
    double? voteAspectRatioA,
    double? voteAspectRatioB,
    int? voteResultsA,
    int? voteResultsB,
    double? votePercentA,
    double? votePercentB,
    Map<String, dynamic>? metadata,
  }) {
    return MessageDto(
      id: id ?? this.id,
      parentPath: parentPath ?? this.parentPath,
      messageId: messageId ?? this.messageId,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      attachmentType: attachmentType ?? this.attachmentType,
      timeStamp: timeStamp ?? this.timeStamp,
      isRead: isRead ?? this.isRead,
      messageType: messageType ?? this.messageType,
      mediaType: mediaType ?? this.mediaType,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaSize: mediaSize ?? this.mediaSize,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      seenAt: seenAt ?? this.seenAt,
      receiverId: receiverId ?? this.receiverId,
      votePostId: votePostId ?? this.votePostId,
      voteTitle: voteTitle ?? this.voteTitle,
      voteDescription: voteDescription ?? this.voteDescription,
      voteOptionAText: voteOptionAText ?? this.voteOptionAText,
      voteOptionBText: voteOptionBText ?? this.voteOptionBText,
      voteOptionAImage: voteOptionAImage ?? this.voteOptionAImage,
      voteOptionBImage: voteOptionBImage ?? this.voteOptionBImage,
      voteOptionAImages: voteOptionAImages ?? this.voteOptionAImages,
      voteOptionBImages: voteOptionBImages ?? this.voteOptionBImages,
      voteStatus: voteStatus ?? this.voteStatus,
      cardStatus: cardStatus ?? this.cardStatus,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      voteResults: voteResults ?? this.voteResults,
      userVotes: userVotes ?? this.userVotes,
      voteAspectRatioA: voteAspectRatioA ?? this.voteAspectRatioA,
      voteAspectRatioB: voteAspectRatioB ?? this.voteAspectRatioB,
      voteResultsA: voteResultsA ?? this.voteResultsA,
      voteResultsB: voteResultsB ?? this.voteResultsB,
      votePercentA: votePercentA ?? this.votePercentA,
      votePercentB: votePercentB ?? this.votePercentB,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() =>
      'MessageDto(id: $id, senderId: $senderId, messageType: $messageType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          messageId == other.messageId;

  @override
  int get hashCode => id.hashCode ^ messageId.hashCode;
}
