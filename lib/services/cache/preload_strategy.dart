import 'package:cloud_firestore/cloud_firestore.dart';
import 'unified_cache_service.dart';

/// Preload strategy for improving cache hit rates
///
/// This service implements intelligent preloading to increase cache efficiency
/// from the current 0-40% to target 60-80%.
class PreloadStrategy {
  // Singleton instance
  static final PreloadStrategy _instance = PreloadStrategy._internal();
  factory PreloadStrategy() => _instance;
  PreloadStrategy._internal();

  // Preload configuration
  static const int preloadChatCount = 10;
  static const int preloadMessageCount = 15;
  static const int preloadImageCount = 5;

  // Track preloading state
  final Set<String> _preloadingChats = {};
  final Set<String> _preloadedChats = {};

  /// Preload recent chats when user enters chat list
  ///
  /// This improves the experience when users tap on chats
  /// by having messages already cached.
  Future<void> preloadRecentChats(String userId) async {
    if (userId.isEmpty) return;

    try {
      QuerySnapshot<Map<String, dynamic>> recentChatsQuery;

      // 먼저 인덱스가 있는 쿼리 시도
      try {
        recentChatsQuery = await FirebaseFirestore.instance
            .collection('chats')
            .where('participantIds', arrayContains: userId)
            .orderBy('lastMessageAt', descending: true)
            .limit(preloadChatCount)
            .get();
      } catch (indexError) {
        // 인덱스 에러 발생 시 간단한 쿼리로 폴백

        // 대체 쿼리: participant_ids 조건만 사용
        try {
          recentChatsQuery = await FirebaseFirestore.instance
              .collection('chats')
              .where('participantIds', arrayContains: userId)
              .limit(preloadChatCount)
              .get();
        } catch (fallbackError) {
          // 그래도 실패하면 가장 단순한 쿼리 사용

          recentChatsQuery = await FirebaseFirestore.instance
              .collection('chats')
              .limit(preloadChatCount)
              .get();
        }
      }

      if (recentChatsQuery.docs.isEmpty) return;

      // Preload messages for each chat in parallel
      final preloadFutures = <Future>[];

      for (final chatDoc in recentChatsQuery.docs) {
        final chatId = chatDoc.id;

        // Skip if already preloading or preloaded
        if (_preloadingChats.contains(chatId) ||
            _preloadedChats.contains(chatId)) {
          continue;
        }

        _preloadingChats.add(chatId);

        // Preload messages for this chat
        preloadFutures.add(_preloadChatMessages(chatId).then((_) {
          _preloadingChats.remove(chatId);
          _preloadedChats.add(chatId);

          // Clean up old preloaded chats if too many
          if (_preloadedChats.length > preloadChatCount * 2) {
            _preloadedChats.clear();
          }
        }).catchError((e) {
          _preloadingChats.remove(chatId);
        }));
      }

      // Wait for all preloads to complete
      await Future.wait(preloadFutures);
    } catch (e) {
      // Error in preloadRecentChats
    }
  }

  /// Preload messages for a specific chat
  Future<void> _preloadChatMessages(String chatId) async {
    try {
      // Get recent messages
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timeStamp', descending: true)
          .limit(preloadMessageCount)
          .get();

      if (messagesQuery.docs.isEmpty) return;

      // Convert to generic Map and cache (no model dependency)
      final messages = messagesQuery.docs
          .map((doc) => {
                'id': doc.id,
                ...doc.data(),
              })
          .toList();

      // Cache the messages
      final cacheKey = 'chat_messages_$chatId';
      // Messages are already in JSON-compatible format
      final messagesJson = messages;
      await UnifiedCacheService.instance.set(cacheKey, messagesJson);
    } catch (e) {
      // Error preloading messages
    }
  }

  /// Preload user data for message authors
  ///
  /// This prevents the need to fetch user data when displaying messages
  Future<void> preloadUserData(List<String> userIds) async {
    if (userIds.isEmpty) return;

    try {
      // Remove duplicates
      final uniqueUserIds = userIds.toSet().toList();

      // Batch fetch user documents
      final userFutures = uniqueUserIds.map((userId) =>
          FirebaseFirestore.instance.collection('users').doc(userId).get());

      final userDocs = await Future.wait(userFutures);

      // Cache user data
      for (var i = 0; i < userDocs.length; i++) {
        if (userDocs[i].exists) {
          final userId = uniqueUserIds[i];
          final userData = userDocs[i].data()!;

          // Cache in UnifiedCacheService
          final cacheKey = 'user_$userId';
          await UnifiedCacheService.instance.set(cacheKey, userData);
        }
      }
    } catch (e) {
      // Error preloading user data
    }
  }

  /// Preload posts for home feed
  ///
  /// This improves the home feed loading experience
  Future<void> preloadHomeFeedPosts() async {
    try {
      // Get recent popular posts
      final postsQuery = await FirebaseFirestore.instance
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      if (postsQuery.docs.isEmpty) return;

      // Cache the posts
      final cacheKey = 'home_feed_posts';
      final postsData = postsQuery.docs.map((doc) => doc.data()).toList();
      await UnifiedCacheService.instance.set(cacheKey, postsData);
    } catch (e) {
      // Error preloading home feed
    }
  }

  /// Clear preload tracking (call on logout)
  void clearPreloadTracking() {
    _preloadingChats.clear();
    _preloadedChats.clear();
  }

  /// Get preload statistics
  Map<String, dynamic> getPreloadStats() {
    return {
      'preloadingChats': _preloadingChats.length,
      'preloadedChats': _preloadedChats.length,
      'totalCached': _preloadedChats.length,
    };
  }
}
