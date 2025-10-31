import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/chat/domain/entities/message.dart';

/// Message Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
/// - Helper 함수로 타입 안전성 확보
/// - Vote Card 복잡한 필드 처리
///
/// **PHASE 5 Complete**: Extension Pattern 100% 적용
extension MessageFirestore on Message {
  /// Firestore DocumentSnapshot → Message Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore
  ///     .collection('chats').doc(chatId)
  ///     .collection('messages').doc(messageId).get();
  /// final message = MessageFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **처리 필드 (45개)**:
  /// - 기본: id, parentPath, messageId, senderId, content, timeStamp 등
  /// - 미디어: mediaType, imageUrl, videoUrl, thumbnailUrl 등
  /// - Vote Card (10개): votePostId, voteOptionAImages, voteStatus 등
  /// - Lifecycle: deliveredAt, seenAt, voteEndTime
  static Message fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    // parentPath 추출 (예: "chats/chatId")
    final parentPath = doc.reference.parent.path;

    return Message(
      // ===== Basic Message Fields =====
      id: doc.id,
      parentPath: parentPath,
      messageId: data['messageId'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      content: data['content'] as String? ?? '',
      attachmentUrl: data['attachmentUrl'] as String? ?? '',
      attachmentType: data['attachmentType'] as String? ?? '',
      timeStamp: _parseDateTime(data['timeStamp']),
      isRead: _parseBool(data['isRead']),
      messageType: data['messageType'] as String? ?? 'text',

      // ===== Media Fields =====
      mediaType: data['mediaType'] as String? ?? 'text',
      imageUrl: data['imageUrl'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String? ?? '',
      mediaSize: _parseInt(data['mediaSize']),
      mediaWidth: _parseDoubleNullable(data['mediaWidth']),
      mediaHeight: _parseDoubleNullable(data['mediaHeight']),

      // ===== Message Lifecycle =====
      deliveredAt: _parseDateTime(data['deliveredAt']),
      seenAt: _parseDateTime(data['seenAt']),

      // ===== Vote Card Fields (10개) =====
      receiverId: data['receiverId'] as String? ?? '',
      votePostId: data['votePostId'] as String? ?? '',
      voteTitle: data['voteTitle'] as String? ?? '',
      voteDescription: data['voteDescription'] as String? ?? '',
      voteOptionAText: data['voteOptionAText'] as String? ?? '',
      voteOptionBText: data['voteOptionBText'] as String? ?? '',

      // Legacy single image fields
      voteOptionAImage: data['voteOptionAImage'] as String? ?? '',
      voteOptionBImage: data['voteOptionBImage'] as String? ?? '',

      // New multi-image fields (Array)
      voteOptionAImages: _parseStringList(data['voteOptionAImages']),
      voteOptionBImages: _parseStringList(data['voteOptionBImages']),

      voteStatus: data['voteStatus'] as String? ?? 'pending',
      cardStatus: data['cardStatus'] as String? ?? '',
      voteEndTime: _parseDateTime(data['voteEndTime']),

      // Vote Results (Complex Maps)
      voteResults: _parseMap(data['voteResults']),
      userVotes: _parseMap(data['userVotes']),

      // Vote Image Aspect Ratios
      voteAspectRatioA: _parseDoubleNullable(data['voteAspectRatioA']),
      voteAspectRatioB: _parseDoubleNullable(data['voteAspectRatioB']),

      // Vote Counts & Percentages
      voteResultsA: _parseInt(data['voteResultsA']),
      voteResultsB: _parseInt(data['voteResultsB']),
      votePercentA: _parseDouble(data['votePercentA']),
      votePercentB: _parseDouble(data['votePercentB']),

      // ===== Metadata =====
      metadata: _parseMap(data['metadata']),
    );
  }

  /// Message Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final message = Message(...);
  /// await firestore
  ///     .collection('chats').doc(chatId)
  ///     .collection('messages').doc(message.id)
  ///     .set(message.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // ===== Basic Message Fields =====
      'messageId': messageId,
      'senderId': senderId,
      'content': content,
      'attachmentUrl': attachmentUrl,
      'attachmentType': attachmentType,
      if (timeStamp != null) 'timeStamp': Timestamp.fromDate(timeStamp!),
      'isRead': isRead,
      'messageType': messageType,

      // ===== Media Fields =====
      'mediaType': mediaType,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaSize': mediaSize,
      if (mediaWidth != null) 'mediaWidth': mediaWidth,
      if (mediaHeight != null) 'mediaHeight': mediaHeight,

      // ===== Message Lifecycle =====
      if (deliveredAt != null) 'deliveredAt': Timestamp.fromDate(deliveredAt!),
      if (seenAt != null) 'seenAt': Timestamp.fromDate(seenAt!),

      // ===== Vote Card Fields =====
      'receiverId': receiverId,
      'votePostId': votePostId,
      'voteTitle': voteTitle,
      'voteDescription': voteDescription,
      'voteOptionAText': voteOptionAText,
      'voteOptionBText': voteOptionBText,

      // Legacy single image fields
      'voteOptionAImage': voteOptionAImage,
      'voteOptionBImage': voteOptionBImage,

      // New multi-image fields (Array)
      'voteOptionAImages': voteOptionAImages,
      'voteOptionBImages': voteOptionBImages,

      'voteStatus': voteStatus,
      'cardStatus': cardStatus,
      if (voteEndTime != null) 'voteEndTime': Timestamp.fromDate(voteEndTime!),

      // Vote Results (Complex Maps)
      'voteResults': voteResults,
      'userVotes': userVotes,

      // Vote Image Aspect Ratios
      if (voteAspectRatioA != null) 'voteAspectRatioA': voteAspectRatioA,
      if (voteAspectRatioB != null) 'voteAspectRatioB': voteAspectRatioB,

      // Vote Counts & Percentages
      'voteResultsA': voteResultsA,
      'voteResultsB': voteResultsB,
      'votePercentA': votePercentA,
      'votePercentB': votePercentB,

      // ===== Metadata =====
      'metadata': metadata,
    };
  }

  // ========== Helper Functions ==========

  /// DateTime 안전 파싱
  ///
  /// **지원 타입**:
  /// - Timestamp (Firestore)
  /// - DateTime (Entity)
  /// - int (millisecondsSinceEpoch)
  /// - null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// String List 안전 파싱
  ///
  /// **Vote Card 이미지 배열 전용**:
  /// - voteOptionAImages
  /// - voteOptionBImages
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// Generic Map 안전 파싱
  ///
  /// **사용 처**:
  /// - voteResults: Map<String, dynamic>
  /// - userVotes: Map<String, dynamic>
  /// - metadata: Map<String, dynamic>
  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  /// Int 안전 파싱 (기본값 지원)
  ///
  /// **사용 처**:
  /// - mediaSize: int
  /// - voteResultsA/B: int
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  /// Double 안전 파싱 (nullable 버전)
  ///
  /// **사용 처**:
  /// - mediaWidth/Height: double?
  /// - voteAspectRatioA/B: double?
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  /// Double 안전 파싱 (기본값 지원)
  ///
  /// **사용 처**:
  /// - votePercentA/B: double (기본값 0.0)
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  /// Bool 안전 파싱
  ///
  /// **사용 처**:
  /// - isRead: bool
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }
}
