import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart'
    show queryCollection, queryCollectionCount;
import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../dto/chat_dto.dart';
import '../dto/message_dto.dart';
import '../adapters/chat_media_upload_service.dart';

/// Implementation of chat repository with migrated backend query functions
class ChatRepositoryImpl implements IChatRepository {
  static ChatRepositoryImpl? _instance;
  static ChatRepositoryImpl get instance =>
      _instance ??= ChatRepositoryImpl._();

  ChatRepositoryImpl._();

  // MIGRATED: Chats queries (Clean Architecture v4.0)
  @override
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  }) =>
      queryCollectionCount(
        FirebaseFirestore.instance.collection('chats'),
        queryBuilder: (query) => query
            .where('participantIds', arrayContains: userId)
            .limit(limit == -1 ? 999999 : limit),
        limit: limit,
      );

  @override
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  }) =>
      queryCollection(
        FirebaseFirestore.instance.collection('chats'),
        ChatDto.fromFirestore,
        queryBuilder: (query) {
          var q = query.where('participantIds', arrayContains: userId);

          if (orderBy != null) {
            q = q.orderBy(orderBy, descending: descending);
          }

          if (limit > 0) {
            q = q.limit(limit);
          }

          return q;
        },
        limit: limit,
        singleRecord: false,
      ).map((dtos) => dtos.map((dto) => dto.toDomain()).toList());

  // MIGRATED: Messages queries (Clean Architecture v4.0)
  @override
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  }) {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId);

    return queryCollectionCount(
      chatRef.collection('messages'),
      limit: limit,
    );
  }

  /// Query messages by chatId (Clean Architecture v4.0)
  ///
  /// Repository에서만 Firestore 의존성을 갖고,
  /// UseCase는 chatId만 전달하도록 격리
  /// Pure Domain Entity 반환
  @override
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  }) {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId);

    return queryCollection(
      chatRef.collection('messages'),
      MessageDto.fromFirestore,
      queryBuilder: (query) {
        var q = query;

        if (orderBy != null) {
          q = q.orderBy(orderBy, descending: descending);
        } else {
          // 기본값: timeStamp 기준 내림차순 (최신순)
          q = q.orderBy('timeStamp', descending: true);
        }

        if (limit > 0) {
          q = q.limit(limit);
        }

        return q;
      },
      limit: limit,
      singleRecord: false,
    ).map((dtos) => dtos.map((dto) => dto.toDomain()).toList());
  }

  /// Load more messages before a specific message (Clean Architecture v4.0)
  ///
  /// 페이지네이션: messageId 이전의 메시지들을 로드
  /// Repository 내부에서만 DocumentSnapshot 처리
  /// Pure Domain Entity 반환
  @override
  Future<List<Message>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId);

    // lastMessageId의 DocumentSnapshot을 먼저 가져옴
    final lastMessageDoc = await chatRef
        .collection('messages')
        .doc(lastMessageId)
        .get();

    if (!lastMessageDoc.exists) {
      return []; // 메시지가 존재하지 않으면 빈 리스트 반환
    }

    // endBeforeDocument를 사용한 페이지네이션
    final messageDtos = await queryCollection(
      chatRef.collection('messages'),
      MessageDto.fromFirestore,
      queryBuilder: (query) => query
          .orderBy('timeStamp', descending: false)
          .endBeforeDocument(lastMessageDoc)
          .limitToLast(limit),
      limit: limit,
      singleRecord: false,
    ).first;

    return messageDtos.map((dto) => dto.toDomain()).toList();
  }

  // CRUD operations (Clean Architecture v4.0: Pure Domain Entity 사용)
  @override
  Future<Chat?> getChat(String chatId) async {
    final doc =
        await FirebaseFirestore.instance.collection('chats').doc(chatId).get();
    return doc.exists ? ChatDto.fromFirestore(doc).toDomain() : null;
  }

  @override
  Future<void> createChat(Chat chat) async {
    final chatDto = ChatDto.fromDomain(chat);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.id)
        .set(chatDto.toFirestore());
  }

  @override
  Future<void> updateChat(Chat chat) async {
    final chatDto = ChatDto.fromDomain(chat);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.id)
        .update(chatDto.toFirestore());
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await FirebaseFirestore.instance.collection('chats').doc(chatId).delete();
  }

  // Message operations (Clean Architecture v4.0: Pure Domain Entity 사용)
  @override
  Future<void> sendMessage(String chatId, Message message) async {
    final messageDto = MessageDto.fromDomain(message);
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageDto.toFirestore());
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Media upload operations (Clean Architecture v4.0)
  @override
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  }) async {
    // ChatMediaUploadService를 Data Layer 내부에서만 사용
    final uploadService = ChatMediaUploadService();

    if (mediaType == 'image') {
      // 이미지 업로드 (자동 압축 포함)
      final result = await uploadService.uploadChatImage(
        chatId: chatId,
        messageId: messageId,
        imageFile: file,
      );
      return result['url'] as String;
    } else if (mediaType == 'video') {
      // 비디오 업로드 (썸네일 자동 생성 포함)
      final result = await uploadService.uploadChatVideo(
        chatId: chatId,
        messageId: messageId,
        videoFile: file,
      );
      return result['url'] as String;
    } else {
      throw Exception('지원하지 않는 미디어 타입입니다: $mediaType');
    }
  }
}
