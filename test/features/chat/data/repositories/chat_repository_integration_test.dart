import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:versus_space/services/batch/batch_service.dart';
import 'package:versus_space/services/cache/unified_cache_service.dart';
import 'package:versus_space/services/cache/failures/cache_failure.dart';

/// Integration tests for ChatRepositoryImpl BatchService operations
///
/// These tests verify the complete end-to-end flow of batch operations:
/// - Firestore query → Batch operations → State changes → Cache invalidation
///
/// Unlike unit tests, these tests use real implementations (not mocks):
/// - FakeFirebaseFirestore for realistic Firestore interactions
/// - Real BatchService with actual chunking logic
/// - FakeUnifiedCacheService to verify cache invalidation
///
/// **PHASE 7 Focus**: Testing deleteChat() with 500+ messages (auto-chunking)
void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late BatchService batchService;
  late FakeUnifiedCacheService fakeCacheService;
  late ChatRepositoryImpl repository;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    batchService = BatchService(firestore: fakeFirestore);  // ✅ Inject FakeFirebaseFirestore
    fakeCacheService = FakeUnifiedCacheService();
    repository = ChatRepositoryImpl(
      firestore: fakeFirestore,
      batchService: batchService,
      cacheService: fakeCacheService,
    );
  });

  group('Integration: deleteChat', () {
    test('should handle chat with < 500 messages (single batch)', () async {
      // Arrange: Create chat with 50 messages
      final chatId = 'small-chat-id';
      final userId1 = 'user1';
      final userId2 = 'user2';

      // Create chat document
      await fakeFirestore.collection('chats').doc(chatId).set({
        'participantIds': [userId1, userId2],
        'lastMessage': 'Hello',
        'lastMessageTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // Create 50 messages
      for (int i = 0; i < 50; i++) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': userId1,
          'text': 'Message $i',
          'timestamp': Timestamp.now(),
        });
      }

      // Create 2 participants
      for (final userId in [userId1, userId2]) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('participants')
            .doc(userId)
            .set({
          'userId': userId,
          'joinedAt': Timestamp.now(),
        });
      }

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert 1: Result is success
      expect(result.isRight(), true);

      // Assert 2: Verify chat document deleted
      final chatDoc = await fakeFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, false, reason: 'Chat document should be deleted');

      // Assert 3: Verify all messages deleted
      final messagesSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      expect(messagesSnapshot.docs, isEmpty, reason: 'All messages should be deleted');

      // Assert 4: Verify all participants deleted
      final participantsSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('participants')
          .get();
      expect(participantsSnapshot.docs, isEmpty, reason: 'All participants should be deleted');
    });

    test('should handle chat with 500+ messages (auto-chunking)', () async {
      // Arrange: Create chat with 700 messages (requires 2 batches)
      final chatId = 'large-chat-id';
      final userId1 = 'user1';
      final userId2 = 'user2';

      // Create chat document
      await fakeFirestore.collection('chats').doc(chatId).set({
        'participantIds': [userId1, userId2],
        'lastMessage': 'Hello',
        'lastMessageTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // Create 700 messages (forces auto-chunking)
      for (int i = 0; i < 700; i++) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': userId1,
          'text': 'Message $i',
          'timestamp': Timestamp.now(),
        });
      }

      // Create 2 participants
      for (final userId in [userId1, userId2]) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('participants')
            .doc(userId)
            .set({
          'userId': userId,
          'joinedAt': Timestamp.now(),
        });
      }

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert 1: Result is success
      expect(result.isRight(), true);

      // Assert 2: Verify Firestore state - chat document deleted
      final chatDoc = await fakeFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, false, reason: 'Chat document should be deleted');

      // Assert 3: Verify all 700 messages deleted
      final messagesSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      expect(messagesSnapshot.docs, isEmpty,
          reason: 'All 700 messages should be deleted via auto-chunking');

      // Assert 4: Verify all participants deleted
      final participantsSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('participants')
          .get();
      expect(participantsSnapshot.docs, isEmpty, reason: 'All participants should be deleted');
    });

    test('should handle chat with 1000+ messages (multiple chunks)', () async {
      // Arrange: Create chat with 1200 messages (requires 3 batches: 500 + 500 + 200)
      final chatId = 'huge-chat-id';
      final userId1 = 'user1';
      final userId2 = 'user2';

      // Create chat document
      await fakeFirestore.collection('chats').doc(chatId).set({
        'participantIds': [userId1, userId2],
        'lastMessage': 'Hello',
        'lastMessageTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // Create 1200 messages (forces 3 chunks)
      for (int i = 0; i < 1200; i++) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .add({
          'senderId': userId1,
          'text': 'Message $i',
          'timestamp': Timestamp.now(),
        });
      }

      // Create 2 participants
      for (final userId in [userId1, userId2]) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('participants')
            .doc(userId)
            .set({
          'userId': userId,
          'joinedAt': Timestamp.now(),
        });
      }

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert 1: Result is success
      expect(result.isRight(), true);

      // Assert 2: Verify all 1200 messages deleted
      final messagesSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();
      expect(messagesSnapshot.docs.length, 0,
          reason: 'All 1200 messages should be deleted via 3 chunks');

      // Assert 3: Verify chat document deleted
      final chatDoc = await fakeFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, false);
    });

    test('should handle empty chat (no messages)', () async {
      // Arrange: Create chat with 0 messages
      final chatId = 'empty-chat-id';
      final userId1 = 'user1';
      final userId2 = 'user2';

      // Create chat document only
      await fakeFirestore.collection('chats').doc(chatId).set({
        'participantIds': [userId1, userId2],
        'lastMessage': '',
        'lastMessageTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // Create 2 participants
      for (final userId in [userId1, userId2]) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('participants')
            .doc(userId)
            .set({
          'userId': userId,
          'joinedAt': Timestamp.now(),
        });
      }

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert 1: Result is success
      expect(result.isRight(), true);

      // Assert 2: Verify chat document deleted
      final chatDoc = await fakeFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, false);
    });

    test('should return failure when chat not found', () async {
      // Arrange: Non-existent chat ID
      final chatId = 'non-existent-chat-id';

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert: Result is failure
      expect(result.isLeft(), true);
    });

    test('should handle chat with participants correctly', () async {
      // Arrange: Create chat with participants
      final chatId = 'participants-test-chat-id';
      final userId1 = 'user1';
      final userId2 = 'user2';

      await fakeFirestore.collection('chats').doc(chatId).set({
        'participantIds': [userId1, userId2],
        'lastMessage': 'Test',
        'lastMessageTime': Timestamp.now(),
        'createdAt': Timestamp.now(),
      });

      // Create participants
      for (final userId in [userId1, userId2]) {
        await fakeFirestore
            .collection('chats')
            .doc(chatId)
            .collection('participants')
            .doc(userId)
            .set({
          'userId': userId,
          'joinedAt': Timestamp.now(),
        });
      }

      // Act: Execute deleteChat
      final result = await repository.deleteChat(chatId: chatId);

      // Assert 1: Success
      expect(result.isRight(), true);

      // Assert 2: Verify chat document deleted
      final chatDoc = await fakeFirestore.collection('chats').doc(chatId).get();
      expect(chatDoc.exists, false);

      // Assert 3: Verify participants deleted
      final participantsSnapshot = await fakeFirestore
          .collection('chats')
          .doc(chatId)
          .collection('participants')
          .get();
      expect(participantsSnapshot.docs, isEmpty,
          reason: 'All participants should be deleted');

      // Assert 4: Verify cache was invalidated
      expect(fakeCacheService.removeCalls.isNotEmpty, true,
          reason: 'Cache should be invalidated on chat deletion');
    });
  });
}

/// Fake implementation of UnifiedCacheService for integration testing
///
/// This implementation returns Either types to match the actual interface
/// and tracks invalidation/remove calls for verification.
class FakeUnifiedCacheService implements UnifiedCacheService {
  final List<String> invalidateCalls = [];
  final List<String> removeCalls = [];
  final List<String> clearCalls = [];
  final Map<String, dynamic> _cache = {};

  @override
  Future<Either<CacheFailure, void>> invalidate(
    String pattern, {
    CacheLayer? layer,
  }) async {
    invalidateCalls.add(pattern);
    _cache.remove(pattern);
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> clear({CacheLayer? layer}) async {
    clearCalls.add('clear');
    _cache.clear();
    return right(null);
  }

  @override
  Future<Either<CacheFailure, T>> get<T>(
    String key, {
    CacheLayer? layer,
  }) async {
    final value = _cache[key];
    if (value == null) {
      return left(const CacheFailure.notFound());
    }
    return right(value as T);
  }

  @override
  Future<Either<CacheFailure, void>> set<T>(
    String key,
    T value, {
    Duration? ttl,
    CacheLayer? layer,
  }) async {
    _cache[key] = value;
    return right(null);
  }

  @override
  Future<Either<CacheFailure, void>> remove(
    String key, {
    CacheLayer? layer,
  }) async {
    removeCalls.add(key);  // ✅ Track remove() calls
    _cache.remove(key);
    return right(null);
  }

  @override
  Future<void> init() async {
    // No-op for fake implementation
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
