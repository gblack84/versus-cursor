// Firebase Remote DataSource Implementation for Chat Feature
// Clean Architecture v4.0 - Data Layer

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart'
    show queryCollection, queryCollectionCount;
import 'i_chat_remote_datasource.dart';
import '../models/chat_dto.dart';
import '../models/message_dto.dart';
import '../services/chat_media_upload_service.dart';

/// Firebase implementation of Chat Remote Datasource
///
/// Handles all Firestore interactions for chats and messages
/// Migrated from ChatRepositoryImpl to follow Clean Architecture v4.0
class FirebaseChatRemoteDatasource implements IChatRemoteDatasource {
  final FirebaseFirestore _firestore;

  FirebaseChatRemoteDatasource({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore;

  // ========== Chat Queries ==========

  @override
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  }) =>
      queryCollectionCount(
        _firestore.collection('chats'),
        queryBuilder: (query) => query
            .where('participantIds', arrayContains: userId)
            .limit(limit == -1 ? 999999 : limit),
        limit: limit,
      );

  @override
  Stream<List<ChatDto>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  }) =>
      queryCollection(
        _firestore.collection('chats'),
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
      );

  @override
  Future<ChatDto?> getChat(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    return doc.exists ? ChatDto.fromFirestore(doc) : null;
  }

  // ========== Message Queries ==========

  @override
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  }) {
    final chatRef = _firestore.collection('chats').doc(chatId);

    return queryCollectionCount(
      chatRef.collection('messages'),
      limit: limit,
    );
  }

  @override
  Stream<List<MessageDto>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  }) {
    final chatRef = _firestore.collection('chats').doc(chatId);

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
    );
  }

  @override
  Future<List<MessageDto>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);

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

    return messageDtos;
  }

  // ========== Chat CRUD Operations ==========

  @override
  Future<void> createChat(ChatDto chat) async {
    await _firestore
        .collection('chats')
        .doc(chat.id)
        .set(chat.toFirestore());
  }

  @override
  Future<void> updateChat(ChatDto chat) async {
    await _firestore
        .collection('chats')
        .doc(chat.id)
        .update(chat.toFirestore());
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await _firestore.collection('chats').doc(chatId).delete();
  }

  // ========== Message CRUD Operations ==========

  @override
  Future<void> sendMessage(String chatId, MessageDto message) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toFirestore());
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // ========== Media Upload Operations ==========

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

  // ========== Friends Management Operations ==========

  @override
  Stream<List<dynamic>> getRecommendedFriends({
    required String currentUserId,
    String sortBy = 'totalAPoints',
    int limit = 20,
  }) {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .orderBy('uid') // 복합 쿼리를 위한 보조 정렬
        .orderBy(sortBy, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Stream<List<dynamic>> searchUsers({
    required String currentUserId,
    required String query,
  }) {
    // Firestore는 부분 문자열 검색을 지원하지 않으므로
    // 클라이언트 측에서 필터링하거나 Algolia/Elasticsearch 사용 권장
    // 여기서는 간단히 displayName이 query로 시작하는 사용자 검색
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: currentUserId)
        .orderBy('uid')
        .orderBy('displayName')
        .startAt([query])
        .endAt(['$query\uf8ff']) // Unicode 최대값으로 범위 쿼리
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }

  @override
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  }) async {
    // friendRequests 서브컬렉션에 요청 추가
    await _firestore
        .collection('users')
        .doc(toUserId)
        .collection('friendRequests')
        .doc(fromUserId)
        .set({
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> followUser(String userId, String targetUserId) async {
    // following 서브컬렉션에 추가
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(targetUserId)
        .set({
      'userId': userId,
      'targetUserId': targetUserId,
      'followedAt': FieldValue.serverTimestamp(),
    });

    // followers 서브컬렉션에도 추가 (양방향)
    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(userId)
        .set({
      'userId': targetUserId,
      'followerId': userId,
      'followedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> unfollowUser(String userId, String targetUserId) async {
    // following 서브컬렉션에서 삭제
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(targetUserId)
        .delete();

    // followers 서브컬렉션에서도 삭제 (양방향)
    await _firestore
        .collection('users')
        .doc(targetUserId)
        .collection('followers')
        .doc(userId)
        .delete();
  }

  @override
  Future<bool> isFollowing(String userId, String targetUserId) async {
    final doc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('following')
        .doc(targetUserId)
        .get();

    return doc.exists;
  }
}
