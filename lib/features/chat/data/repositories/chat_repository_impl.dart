import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';

import '../../domain/repositories/i_chat_repository.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/message.dart';
import '../../domain/failures/chat_failure.dart';
import '../../domain/entities/chat_extensions.dart';
import '../../domain/entities/message_extensions.dart';
import '/app/contracts/chat_contract.dart';
import '/core/utils/idempotency_service.dart';
import '/services/cache/unified_cache_service.dart';

/// Implementation of chat repository with Clean Architecture v4.0 + 3-Layer Caching
///
/// **Firebase-Centric v2.0 Architecture** (PHASE 5):
/// - Direct Firestore access with Extension pattern
/// - Removed DataSource/DTO/Mapper layers → Single-step conversion
/// - Firestore → Extension → Entity (1단계)
///
/// **PHASE 3: 3-Layer Caching Integration** (2025-10-31):
/// - Cache-First pattern: L1 Memory < 10ms → L2 Hive 10-30ms → L3 Firestore 50-100ms
/// - Write-Through strategy: Update cache on all data changes
/// - Cascade Invalidation: Clear related caches on CRUD operations
///
/// **PHASE 4: CRUD Cleanup & Idempotency** (2025-01-31):
/// - IdempotencyService 통합: 중복 작업 방지
/// - Transaction 기반 CRUD: 서브컬렉션 정리 + 원자성 보장
/// - Either 패턴: 명시적 에러 처리
/// - deleteChat(): messages/participants 서브컬렉션 완전 정리
///
/// **Dual Interface Pattern**:
/// - Implements both IChatRepository (Port) and ChatContract
/// - Same instance serves internal and external interfaces
/// - Registered in DI with both types
class ChatRepositoryImpl implements IChatRepository, ChatContract {
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;
  final IdempotencyService _idempotencyService;
  final FirebaseFirestore _firestore;

  ChatRepositoryImpl({
    required IdempotencyService idempotencyService,
    required FirebaseFirestore firestore,
  })  : _idempotencyService = idempotencyService,
        _firestore = firestore;

  // PHASE 5: Direct Firestore query with Extension pattern
  @override
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  }) async {
    final query = _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId);

    final snapshot = await (limit > 0 ? query.limit(limit).get() : query.get());
    return snapshot.size;
  }

  /// Query chats with Cache-First pattern (PHASE 5: Extension Pattern)
  ///
  /// **Performance**:
  /// - Cache Hit (L1): <10ms - 즉시 응답
  /// - Cache Hit (L2): 10-30ms - Hive 로컬 DB
  /// - Cache Miss: 300-500ms - Firestore 네트워크 요청
  ///
  /// **Strategy**:
  /// 1. 캐시 확인 → 즉시 yield right(cachedChats) (백그라운드 동기화)
  /// 2. Firestore Stream 구독 → 실시간 업데이트
  /// 3. Extension 메서드로 변환: ChatFirestore.fromFirestore()
  /// 4. 캐시 업데이트 (Write-Through)
  /// 5. 에러 발생 시 → yield left(ChatFailure)
  ///
  /// **PHASE 5 Complete**: Firebase-Centric v2.0 with Extension Pattern
  @override
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  }) async* {
    try {
      // 1. ✅ Cache-First: L1 → L2 → L3 (background sync)
      final cachedMaps = await _cacheService.get<List<dynamic>>('chat_list_$userId');
      if (cachedMaps != null && cachedMaps.isNotEmpty) {
        final cachedChats = cachedMaps
            .map((map) => Chat.fromJson(Map<String, dynamic>.from(map as Map)))
            .toList();
        yield right(cachedChats); // ✅ Either 래핑: <10ms 즉시 응답
      }

      // 2. ✅ Direct Firestore Query: Real-time stream
      final query = _firestore
          .collection('chats')
          .where('participantIds', arrayContains: userId)
          .orderBy(orderBy ?? 'lastMessageAt', descending: descending)
          .limit(limit);

      await for (final snapshot in query.snapshots()) {
        // 3. ✅ Extension Pattern: Firestore → Entity (1단계)
        final chats = snapshot.docs
            .map((doc) => ChatFirestore.fromFirestore(doc))
            .toList();

        // 4. ✅ Write-Through: Cache 업데이트
        final chatMaps = chats.map((chat) => chat.toJson()).toList();
        await _cacheService.set(
          'chat_list_$userId',
          chatMaps,
          ttl: const Duration(minutes: 10),
        );

        yield right(chats); // ✅ Either 래핑: 성공
      }
    } on FirebaseException catch (e, stackTrace) {
      // Firebase 에러 처리 (네트워크, 권한 등)
      if (kDebugMode) {
        print('❌ [ChatRepository] Firestore error in queryChats: ${e.code} - ${e.message}');
        print('Stack trace: $stackTrace');
      }
      yield left(Unexpected('Firestore error: ${e.code} - ${e.message}'));
    } on Exception catch (e, stackTrace) {
      // 일반 에러 처리 (Cache, Extension 등)
      if (kDebugMode) {
        print('❌ [ChatRepository] Error in queryChats: ${e.toString()}');
        print('Stack trace: $stackTrace');
      }
      yield left(Unexpected(e.toString()));
    }
  }

  // PHASE 5: Direct Firestore query with Extension pattern
  @override
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  }) async {
    final query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    final snapshot = await (limit > 0 ? query.limit(limit).get() : query.get());
    return snapshot.size;
  }

  /// Query messages by chatId with Cache-First pattern (PHASE 5: Extension Pattern)
  ///
  /// **Performance**:
  /// - Cache Hit (L1): <1ms - 메모리에서 즉시 응답
  /// - Cache Hit (L2): 10-30ms - Hive 로컬 DB
  /// - Cache Hit (L3): 50-100ms - Firestore 오프라인 캐시
  /// - Cache Miss: 300-500ms - Firestore 네트워크 요청
  ///
  /// **Strategy**:
  /// 1. 캐시 확인 → 즉시 yield right(cachedMessages) (백그라운드 동기화)
  /// 2. Firestore Stream 구독 → 실시간 메시지 업데이트
  /// 3. Extension 메서드로 변환: MessageFirestore.fromFirestore()
  /// 4. 캐시 업데이트 (Write-Through)
  /// 5. 에러 발생 시 → yield left(ChatFailure)
  ///
  /// **Use Case**: ChatDetailWidget에서 메시지 로드 시 <10ms 응답
  ///
  /// **PHASE 5 Complete**: Firebase-Centric v2.0 with Extension Pattern
  @override
  Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  }) async* {
    try {
      // 1. ✅ Cache-First: L1 → L2 → L3 (97% 빠른 응답)
      final cachedMaps = await _cacheService.get<List<dynamic>>('chat_messages_$chatId');
      if (cachedMaps != null && cachedMaps.isNotEmpty) {
        final cachedMessages = cachedMaps
            .map((map) => Message.fromJson(Map<String, dynamic>.from(map as Map)))
            .toList();
        yield right(cachedMessages); // ✅ Either 래핑: <10ms 즉시 응답
      }

      // 2. ✅ Direct Firestore Query: Real-time stream
      final query = _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy(orderBy ?? 'timeStamp', descending: descending)
          .limit(limit);

      await for (final snapshot in query.snapshots()) {
        // 3. ✅ Extension Pattern: Firestore → Entity (1단계)
        final messages = snapshot.docs
            .map((doc) => MessageFirestore.fromFirestore(doc))
            .toList();

        // 4. ✅ Write-Through: Cache 업데이트
        final messageMaps = messages.map((msg) => msg.toJson()).toList();
        await _cacheService.set(
          'chat_messages_$chatId',
          messageMaps,
          ttl: const Duration(minutes: 5),
        );

        yield right(messages); // ✅ Either 래핑: 성공
      }
    } on FirebaseException catch (e, stackTrace) {
      // Firebase 에러 처리 (네트워크, 권한 등)
      if (kDebugMode) {
        print('❌ [ChatRepository] Firestore error in queryMessagesByChatId: ${e.code} - ${e.message}');
        print('Stack trace: $stackTrace');
      }
      yield left(Unexpected('Firestore error: ${e.code} - ${e.message}'));
    } on Exception catch (e, stackTrace) {
      // 일반 에러 처리 (Cache, Extension 등)
      if (kDebugMode) {
        print('❌ [ChatRepository] Error in queryMessagesByChatId: ${e.toString()}');
        print('Stack trace: $stackTrace');
      }
      yield left(Unexpected(e.toString()));
    }
  }

  /// Load more messages before a specific message (PHASE 5: Extension Pattern)
  ///
  /// 페이지네이션: messageId 이전의 메시지들을 로드
  /// Direct Firestore query with Extension pattern
  @override
  Future<List<Message>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  }) async {
    // 1. Get the lastMessage document as startAfter cursor
    final lastMessageDoc = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(lastMessageId)
        .get();

    if (!lastMessageDoc.exists) {
      return [];
    }

    // 2. Query messages before lastMessage (pagination)
    final query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timeStamp', descending: false)
        .startAfterDocument(lastMessageDoc)
        .limit(limit);

    final snapshot = await query.get();

    // 3. Extension Pattern: Firestore → Entity (1단계)
    return snapshot.docs
        .map((doc) => MessageFirestore.fromFirestore(doc))
        .toList();
  }

  // ========== CRUD operations (Phase 4: Either Pattern + Idempotency) ==========

  /// Get chat by ID with Either pattern (PHASE 5: Extension Pattern)
  ///
  /// **Returns**: Either<ChatFailure, Chat>
  /// - Left: ChatNotFound if chat doesn't exist
  /// - Right: Chat entity
  @override
  Future<Either<ChatFailure, Chat>> getChat(String chatId) async {
    try {
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        return left(const ChatNotFound());
      }

      final chat = ChatFirestore.fromFirestore(chatDoc);
      return right(chat);
    } catch (e, stackTrace) {
      debugPrint('Failed to get chat: $e');
      debugPrint(stackTrace.toString());
      return left(Unexpected(e.toString()));
    }
  }

  /// Create chat with Idempotency (PHASE 5: Extension Pattern)
  ///
  /// **Idempotency**: eventId로 중복 생성 방지
  /// **Transaction**: 원자적 생성 보장
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> createChat({
    required Chat chat,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Either<ChatFailure, Unit>>(
        entityType: 'chat_create',
        entityId: chat.chatId,
        userId: chat.participantIds.first,
        eventId: eventId,
        operation: (transaction) async {
          // Create chat document with Extension pattern
          final chatRef = _firestore.collection('chats').doc(chat.chatId);
          transaction.set(chatRef, chat.toFirestore());

          // Invalidate cache (outside transaction)
          Future.microtask(() async {
            for (final userId in chat.participantIds) {
              await _cacheService.remove('chat_list_$userId');
            }
          });

          return right(unit);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to create chat: $e');
      debugPrint(stackTrace.toString());
      return left(const ChatCreationFailed());
    }
  }

  /// Update chat with Idempotency (PHASE 5: Extension Pattern)
  ///
  /// **Idempotency**: eventId로 중복 업데이트 방지
  /// **Transaction**: 원자적 업데이트 보장
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> updateChat({
    required Chat chat,
    required String eventId,
  }) async {
    try {
      return await _idempotencyService.executeIdempotent<Either<ChatFailure, Unit>>(
        entityType: 'chat_update',
        entityId: chat.chatId,
        userId: chat.participantIds.first,
        eventId: eventId,
        operation: (transaction) async {
          // Update chat document with Extension pattern
          final chatRef = _firestore.collection('chats').doc(chat.chatId);
          transaction.update(chatRef, chat.toFirestore());

          // Invalidate cache (outside transaction)
          Future.microtask(() async {
            for (final userId in chat.participantIds) {
              await _cacheService.remove('chat_list_$userId');
            }
            await _cacheService.remove('chat_${chat.chatId}');
          });

          return right(unit);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to update chat: $e');
      debugPrint(stackTrace.toString());
      return left(Unexpected(e.toString()));
    }
  }

  /// Delete chat with complete subcollection cleanup (PHASE 4)
  ///
  /// **Transaction-based Cleanup**:
  /// - messages 서브컬렉션 완전 삭제
  /// - participants 서브컬렉션 삭제 (존재 시)
  /// - chat 문서 삭제
  /// - 원자성 보장 (Transaction)
  ///
  /// **Idempotency**: eventId로 중복 삭제 방지
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> deleteChat({
    required String chatId,
    required String eventId,
  }) async {
    try {
      // 1. Get chat to access participantIds for cache invalidation
      final chatResult = await getChat(chatId);
      final chat = chatResult.fold(
        (failure) => null,
        (c) => c,
      );

      if (chat == null) {
        return left(const ChatNotFound());
      }

      // 2. Execute idempotent transaction
      return await _idempotencyService.executeIdempotent<Either<ChatFailure, Unit>>(
        entityType: 'chat_delete',
        entityId: chatId,
        userId: chat.participantIds.first,
        eventId: eventId,
        operation: (transaction) async {
          // 2-1. Delete messages subcollection
          final messagesSnapshot = await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .get();

          for (final doc in messagesSnapshot.docs) {
            transaction.delete(doc.reference);
          }

          // 2-2. Delete participants subcollection (if exists)
          try {
            final participantsSnapshot = await _firestore
                .collection('chats')
                .doc(chatId)
                .collection('participants')
                .get();

            for (final doc in participantsSnapshot.docs) {
              transaction.delete(doc.reference);
            }
          } catch (_) {
            // participants subcollection may not exist, continue
          }

          // 2-3. Delete chat document
          transaction.delete(_firestore.collection('chats').doc(chatId));

          // 2-4. Invalidate cache (outside transaction to avoid blocking)
          Future.microtask(() async {
            for (final userId in chat.participantIds) {
              // CASCADE 무효화: 채팅 목록 + 메시지 + 단일 채팅 캐시
              await _cacheService.remove('chat_list_$userId');
              await _cacheService.remove('chat_messages_$chatId');
              await _cacheService.remove('chat_$chatId');
            }
          });

          return right(unit);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to delete chat: $e');
      debugPrint(stackTrace.toString());
      return left(Unexpected(e.toString()));
    }
  }

  // ========== Message operations (Phase 4: Either Pattern + Idempotency) ==========

  /// Send message with Transaction and Idempotency (PHASE 5: Extension Pattern)
  ///
  /// **Transaction**: 메시지 생성 + lastMessageAt 업데이트 원자적 처리
  /// **Idempotency**: eventId로 중복 전송 방지
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  }) async {
    try {
      // 1. Get chat for participantIds (for cache invalidation)
      final chatResult = await getChat(chatId);
      final chat = chatResult.fold(
        (failure) => null,
        (c) => c,
      );

      if (chat == null) {
        return left(const ChatNotFound());
      }

      // 2. Execute idempotent transaction
      return await _idempotencyService.executeIdempotent<Either<ChatFailure, Unit>>(
        entityType: 'message_send',
        entityId: message.id,
        userId: message.senderId,
        eventId: eventId,
        operation: (transaction) async {
          // 2-1. Create message document with Extension pattern
          final messageRef = _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(message.id);

          transaction.set(messageRef, message.toFirestore());

          // 2-2. Update chat's lastMessageAt
          final chatRef = _firestore.collection('chats').doc(chatId);
          transaction.update(chatRef, {
            'lastMessageAt': FieldValue.serverTimestamp(),
          });

          // 2-3. Invalidate caches (outside transaction)
          Future.microtask(() async {
            await _cacheService.remove('chat_messages_$chatId');
            for (final userId in chat.participantIds) {
              await _cacheService.remove('chat_list_$userId');
            }
          });

          return right(unit);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to send message: $e');
      debugPrint(stackTrace.toString());
      return left(const MessageSendFailed());
    }
  }

  /// Delete message with Idempotency (PHASE 4)
  ///
  /// **Idempotency**: eventId로 중복 삭제 방지
  /// **Transaction**: 원자적 삭제 보장
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> deleteMessage({
    required String chatId,
    required String messageId,
    required String eventId,
  }) async {
    try {
      // Get current user for idempotency userId
      // Note: In a real scenario, we'd get this from auth service
      // For now, we'll use a placeholder
      const userId = 'current_user'; // TODO: Get from AuthService

      return await _idempotencyService.executeIdempotent<Either<ChatFailure, Unit>>(
        entityType: 'message_delete',
        entityId: messageId,
        userId: userId,
        eventId: eventId,
        operation: (transaction) async {
          // Delete message document
          final messageRef = _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .doc(messageId);

          transaction.delete(messageRef);

          // Invalidate cache (outside transaction)
          Future.microtask(() async {
            await _cacheService.remove('chat_messages_$chatId');
          });

          return right(unit);
        },
      );
    } catch (e, stackTrace) {
      debugPrint('Failed to delete message: $e');
      debugPrint(stackTrace.toString());
      return left(Unexpected(e.toString()));
    }
  }

  // Media upload operations (Clean Architecture v4.0)
  // TODO: uploadMedia 메서드는 별도 MediaUploadService로 분리 (Chat Feature의 책임 아님)
  // 미디어 업로드는 독립적인 서비스 레이어에서 처리하는 것이 적절
  @override
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  }) async {
    // Temporary implementation - should be moved to MediaUploadService
    throw UnimplementedError(
      'uploadMedia should be implemented in a separate MediaUploadService. '
      'This is not part of Chat Feature Extension Pattern migration.',
    );
  }

  // Friends management operations (Chat Feature 내 친구 관리)
  // 모든 친구 관리 기능은 Chat 사이클 내에서 Direct Firestore로 구현

  /// 친구 추천 목록 조회 (PHASE 5: Direct Firestore)
  ///
  /// **Returns**: Stream<Either<ChatFailure, List<dynamic>>>
  @override
  Stream<Either<ChatFailure, List<dynamic>>> getRecommendedFriends({
    required String currentUserId,
    String sortBy = 'totalAPoints',
    int limit = 20,
  }) async* {
    try {
      final query = _firestore
          .collection('users')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .orderBy(FieldPath.documentId) // Required for inequality
          .orderBy(sortBy, descending: true)
          .limit(limit);

      await for (final snapshot in query.snapshots()) {
        final users = snapshot.docs.map((doc) => doc.data()).toList();
        yield right(users);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to get recommended friends: $e');
      debugPrint(stackTrace.toString());
      yield left(const FriendLoadFailed());
    }
  }

  /// 사용자 검색 (PHASE 5: Direct Firestore)
  ///
  /// **Returns**: Stream<Either<ChatFailure, List<dynamic>>>
  @override
  Stream<Either<ChatFailure, List<dynamic>>> searchUsers({
    required String currentUserId,
    required String query,
  }) async* {
    try {
      // Simple prefix search on displayName field
      final q = _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: '$query\uf8ff')
          .where(FieldPath.documentId, isNotEqualTo: currentUserId)
          .limit(50);

      await for (final snapshot in q.snapshots()) {
        final users = snapshot.docs.map((doc) => doc.data()).toList();
        yield right(users);
      }
    } catch (e, stackTrace) {
      debugPrint('Failed to search users: $e');
      debugPrint(stackTrace.toString());
      yield left(const SearchFailed());
    }
  }

  /// 친구 요청 보내기 (Chat Feature)
  /// TODO: Chat Repository에서 Direct Firestore로 구현 (친구 관리는 Chat 사이클 내에서 처리)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
    required String eventId,
  }) async {
    // TODO: Direct Firestore 구현 필요 - friend_requests 컬렉션 생성 및 트랜잭션 처리
    return left(const Unexpected('sendFriendRequest not yet implemented'));
  }

  /// 사용자 팔로우 (Chat Feature)
  /// TODO: Chat Repository에서 Direct Firestore로 구현 (친구 관리는 Chat 사이클 내에서 처리)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> followUser({
    required String userId,
    required String targetUserId,
    required String eventId,
  }) async {
    // TODO: Direct Firestore 구현 필요 - users/{userId}/following 서브컬렉션 업데이트
    return left(const Unexpected('followUser not yet implemented'));
  }

  /// 사용자 언팔로우 (Chat Feature)
  /// TODO: Chat Repository에서 Direct Firestore로 구현 (친구 관리는 Chat 사이클 내에서 처리)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  @override
  Future<Either<ChatFailure, Unit>> unfollowUser({
    required String userId,
    required String targetUserId,
    required String eventId,
  }) async {
    // TODO: Direct Firestore 구현 필요 - users/{userId}/following 서브컬렉션에서 제거
    return left(const Unexpected('unfollowUser not yet implemented'));
  }

  /// 팔로우 여부 확인 (PHASE 5: Direct Firestore)
  ///
  /// **Returns**: Either<ChatFailure, bool>
  @override
  Future<Either<ChatFailure, bool>> isFollowing({
    required String userId,
    required String targetUserId,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        return right(false);
      }

      final data = userDoc.data();
      final following = data?['following'] as List<dynamic>? ?? [];
      return right(following.contains(targetUserId));
    } catch (e, stackTrace) {
      debugPrint('Failed to check following status: $e');
      debugPrint(stackTrace.toString());
      return left(Unexpected(e.toString()));
    }
  }
}
