import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

/// 채팅 메시지 변환 및 관리를 위한 통합 서비스
///
/// chat_detail_widget_v2와 ai_chat_page_v2에서 중복되던
/// 메시지 변환 로직을 통합하여 관리합니다.
class ChatMessageService {
  static final ChatMessageService _instance = ChatMessageService._internal();
  factory ChatMessageService() => _instance;
  ChatMessageService._internal();

  /// Firestore 문서를 flutter_chat_ui의 Message 객체로 변환
  ///
  /// 다양한 메시지 타입을 지원:
  /// - text: 일반 텍스트 메시지
  /// - image: 이미지 메시지
  /// - vote_request/vote_created: 투표 카드 메시지
  /// - system: 시스템 메시지 (읽지 않은 메시지 구분선 등)
  static Future<core.Message?> convertDocumentToMessage(
    DocumentSnapshot doc,
  ) async {
    try {
      final data = doc.data() as Map<String, dynamic>;
      final messageId = doc.id;
      final senderId = data['senderId'] ?? data['userId'] ?? '';
      final content = data['content'] ?? data['text'] ?? '';
      final timestamp = data['timeStamp'] as Timestamp?;
      final messageType = data['messageType'] ?? 'text';

      // 필수 데이터가 없으면 null 반환
      if (senderId.isEmpty || timestamp == null) {
        return null;
      }

      final createdAt = timestamp.toDate();

      // 메시지 타입별 처리
      switch (messageType) {
        case 'voteRequest':
        case 'voteCreated':
          return _createVoteMessage(
              messageId, senderId, createdAt, data, messageType);

        case 'system':
          return core.SystemMessage(
            id: messageId,
            text: content,
            createdAt: createdAt,
            authorId: 'system',
          );

        case 'image':
          return _createImageMessage(messageId, senderId, createdAt, data);

        case 'text':
        default:
          return core.TextMessage(
            id: messageId,
            authorId: senderId,
            text: content,
            createdAt: createdAt,
          );
      }
    } catch (e) {
      print('Error converting document to message: $e');
      return null;
    }
  }

  /// 투표 카드 메시지 생성
  static core.CustomMessage _createVoteMessage(
    String messageId,
    String senderId,
    DateTime createdAt,
    Map<String, dynamic> data,
    String messageType,
  ) {
    return core.CustomMessage(
      id: messageId,
      authorId: senderId,
      createdAt: createdAt,
      metadata: {
        'type': messageType,
        'postId': data['postId'],
        'title': data['voteTitle'],
        'description': data['voteDescription'],
        'optionAText': data['voteOptionAText'],
        'optionBText': data['voteOptionBText'],
        'optionAImage': data['voteOptionAImage'],
        'optionBImage': data['voteOptionBImage'],
        'optionAImages': data['voteOptionAImages'],
        'optionBImages': data['voteOptionBImages'],
        'aspectRatioA': data['voteOptionAAspectRatio'],
        'aspectRatioB': data['voteOptionBAspectRatio'],
        'cardStatus': data['cardStatus'],
        'voteEndTime': data['voteEndTime'],
        'userVotes': data['userVotes'],
        'voteResults': data['voteResults'],
        'receiverId': data['receiverId'],
      },
    );
  }

  /// 이미지 메시지 생성
  static core.ImageMessage _createImageMessage(
    String messageId,
    String senderId,
    DateTime createdAt,
    Map<String, dynamic> data,
  ) {
    final imageUrl = data['imageUrl'] ?? data['image'] ?? '';
    final metadata = <String, dynamic>{};

    // 이미지 메타데이터 추가
    if (data['width'] != null) metadata['width'] = data['width'];
    if (data['height'] != null) metadata['height'] = data['height'];
    if (data['size'] != null) metadata['size'] = data['size'];

    return core.ImageMessage(
      id: messageId,
      authorId: senderId,
      createdAt: createdAt,
      source: imageUrl,
      size: data['size']?.toDouble(),
      metadata: metadata.isNotEmpty ? metadata : null,
    );
  }

  /// 여러 문서를 메시지 리스트로 일괄 변환 (병렬 처리)
  static Future<List<core.Message>> convertDocumentsToMessages(
    List<QueryDocumentSnapshot> docs,
  ) async {
    // 병렬 처리로 성능 최적화
    final messageFutures = docs.map((doc) => convertDocumentToMessage(doc));
    final messages = await Future.wait(messageFutures);

    // null 제거 후 반환
    return messages
        .where((message) => message != null)
        .cast<core.Message>()
        .toList();
  }

  /// 메시지 메타데이터 업데이트
  static Map<String, dynamic> updateMessageMetadata(
    Map<String, dynamic> currentMetadata,
    Map<String, dynamic> updates,
  ) {
    final newMetadata = Map<String, dynamic>.from(currentMetadata);
    newMetadata.addAll(updates);
    return newMetadata;
  }

  /// 메시지 상태 확인 헬퍼
  static bool isVoteMessage(core.Message message) {
    if (message is! core.CustomMessage) return false;
    final type = message.metadata?['type'] as String?;
    return type == 'voteRequest' || type == 'voteCreated';
  }

  static bool isSystemMessage(core.Message message) {
    return message is core.SystemMessage;
  }

  static bool isImageMessage(core.Message message) {
    return message is core.ImageMessage;
  }

  static bool isTextMessage(core.Message message) {
    return message is core.TextMessage;
  }

  /// 메시지 정렬 헬퍼
  static List<core.Message> sortMessagesByTime(
    List<core.Message> messages, {
    bool ascending = true,
  }) {
    final sorted = List<core.Message>.from(messages);
    sorted.sort((a, b) {
      // null 체크 추가
      final aTime = a.createdAt;
      final bTime = b.createdAt;

      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return ascending ? -1 : 1;
      if (bTime == null) return ascending ? 1 : -1;

      final comparison = aTime.compareTo(bTime);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// 메시지 필터링 헬퍼
  static List<core.Message> filterMessagesByAuthor(
    List<core.Message> messages,
    String authorId,
  ) {
    return messages.where((msg) => msg.authorId == authorId).toList();
  }

  static List<core.Message> filterMessagesByType<T extends core.Message>(
    List<core.Message> messages,
  ) {
    return messages.whereType<T>().toList();
  }

  /// 메시지 중복 제거 헬퍼
  static List<core.Message> removeDuplicateMessages(
    List<core.Message> messages,
  ) {
    final seen = <String>{};
    return messages.where((msg) => seen.add(msg.id)).toList();
  }
}
