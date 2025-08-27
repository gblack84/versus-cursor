import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/backend/backend.dart';
import '/features/auth/data/services/auth_util.dart';
import '/services/user_cache_service.dart';
import '/services/cache/unified_cache_service.dart';
import '../chat_detail_v2/chat_detail_migration_service.dart';
import 'chat_message_lifecycle_service.dart';

/// 채팅 초기화 서비스
/// 채팅방 입장 시 필요한 모든 초기화 작업을 담당
class ChatInitializationService {
  final UserCacheService _userCacheService = UserCacheService.instance;
  final UnifiedCacheService _cacheService = UnifiedCacheService.instance;
  final ChatMessageLifecycleService _lifecycleService = ChatMessageLifecycleService();
  
  core.User? currentUser;
  UsersModel? currentUserRecord;
  DocumentSnapshot? anchorDocument;
  DocumentSnapshot? lastLoadedDocument;
  DateTime? lastLoadedTimestamp;
  
  /// 채팅 초기화 전체 프로세스
  Future<BootstrapResult> bootstrap({
    required ChatsModel? chatDocument,
    required int initialMessageLimit,
  }) async {
    // 1. 사용자 정보 로드
    await loadUserInfo();
    
    // 2. 채팅 문서가 없으면 조기 종료
    if (chatDocument == null) {
      return BootstrapResult(
        isSuccessful: true,
        messages: [],
        currentUser: currentUser,
        currentUserRecord: currentUserRecord,
      );
    }
    
    // 3. 초기 메시지 로드
    final messages = await loadInitialMessages(
      chatDocument: chatDocument,
      messageLimit: initialMessageLimit,
    );
    
    // 4. 채팅 참여자 정보 로드
    await loadChatParticipants(chatDocument);
    
    // 5. 마지막 읽은 시간 업데이트
    await updateLastReadAt(chatDocument);
    
    // 6. 메시지를 읽음으로 표시
    if (currentUser != null) {
      await _lifecycleService.markMessagesAsSeen(
        chatId: chatDocument.reference.id,
        currentUserId: currentUser!.id,
      );
    }
    
    return BootstrapResult(
      isSuccessful: true,
      messages: messages,
      currentUser: currentUser,
      currentUserRecord: currentUserRecord,
      anchorDocument: anchorDocument,
      lastLoadedDocument: lastLoadedDocument,
      lastLoadedTimestamp: lastLoadedTimestamp,
    );
  }
  
  /// 현재 사용자 정보 로드
  Future<void> loadUserInfo() async {
    try {
      if (currentUserUid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          currentUserRecord = UsersModel.fromSnapshot(userDoc);
          
          // 다중 fallback으로 표시 이름 결정
          final displayName = userData['displayName'] ?? 
                             userData['handle'] ?? 
                             userData['email']?.split('@')[0] ?? 
                             '사용자';
          
          currentUser = core.User(
            id: currentUserUid,
            name: displayName.toString().isNotEmpty ? displayName.toString() : '사용자',
            imageSource: userData['photoUrl'],
          );
          
          _userCacheService.updateUser(currentUser!);
        } else {
          _createDefaultUser();
        }
      } else {
        _createDefaultUser();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _createDefaultUser();
    }
  }
  
  /// 초기 메시지 로드 (캐시 우선)
  Future<List<core.Message>> loadInitialMessages({
    required ChatsModel chatDocument,
    required int messageLimit,
  }) async {
    final chatId = chatDocument.reference.id;
    
    // 먼저 캐시에서 시도
    try {
      final cachedMessages = await _cacheService.getChatMessages(chatId);
      if (cachedMessages.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[Chat Init] Loaded ${cachedMessages.length} messages from cache');
        }
        
        // 병렬로 메시지 변환
        final messageFutures = cachedMessages.map((model) async {
          final messageData = model.snapshotData;
          return await ChatDetailMigrationService.convertFirestoreToCore(
            model,
            messageData,
            {},
            isAiChat: chatId.startsWith('ai_assistant_'),
          );
        });
        final messages = await Future.wait(messageFutures);
        
        // 중요: 캐시에서 로드할 때도 타임스탬프 정보 보존
        // 이를 통해 스트림이 올바른 지점부터 시작할 수 있음
        anchorDocument = null;  // 문서는 없지만
        lastLoadedDocument = null;  // 이것도 null이지만
        
        // 마지막 메시지 타임스탬프는 반드시 저장 (스트림 커서로 사용)
        if (cachedMessages.isNotEmpty) {
          lastLoadedTimestamp = cachedMessages.last.timeStamp;
          
          if (kDebugMode) {
            debugPrint('[Chat Init] Cache loaded - Last timestamp for stream cursor: $lastLoadedTimestamp');
          }
        }
        
        return messages;
      }
    } catch (e) {
      debugPrint('[Chat Init] Cache read failed, falling back to Firestore: $e');
    }
    
    // 캐시 미스 시 Firestore에서 로드
    Query<Map<String, dynamic>> initialQuery = chatDocument.reference
        .collection('messages')
        .orderBy('timeStamp', descending: false);
    
    if (kDebugMode) {
      debugPrint('[Chat Init] Loading initial messages from Firestore...');
    }
    
    final initialSnapshot = await initialQuery.limitToLast(messageLimit).get();
    
    if (initialSnapshot.docs.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Chat Init] No initial messages found');
      }
      return [];
    }
    
    if (kDebugMode) {
      debugPrint('[Chat Init] Loaded ${initialSnapshot.docs.length} initial messages');
    }
    
    // 병렬로 메시지 변환
    final messageFutures = initialSnapshot.docs.map((doc) => _convertDocToMessage(doc, chatId: chatId));
    final messages = await Future.wait(messageFutures);
    
    if (kDebugMode) {
      debugPrint('[Chat Init] Converted ${messages.length} messages in parallel');
    }
    
    // 문서 정보 저장
    anchorDocument = initialSnapshot.docs.last;
    lastLoadedDocument = initialSnapshot.docs.last;
    
    // 마지막 메시지 타임스탬프 저장
    final lastDoc = initialSnapshot.docs.last;
    final lastTimestamp = lastDoc.data();
    if (lastTimestamp['timeStamp'] != null) {
      lastLoadedTimestamp = (lastTimestamp['timeStamp'] as Timestamp).toDate();
      if (kDebugMode) {
        debugPrint('[Chat Init] Last loaded timestamp: $lastLoadedTimestamp');
      }
    }
    
    // 캐시에 저장 
    final messagesModels = initialSnapshot.docs
        .map((doc) => MessagesModel.fromSnapshot(doc))
        .toList();
    await _cacheService.setChatMessages(chatId, messagesModels);
    
    return messages;
  }
  
  /// 채팅 참여자 정보 로드
  Future<void> loadChatParticipants(ChatsModel chatDocument) async {
    final participantIds = chatDocument.participantIds;
    
    // 캐시되지 않은 사용자만 필터링
    final uncachedUserIds = participantIds
        .where((id) => id.isNotEmpty && !_userCacheService.isCached(id))
        .toList();
    
    if (uncachedUserIds.isEmpty) return;
    
    // 병렬로 사용자 정보 로드
    final userFutures = uncachedUserIds.map((userId) async {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          final userModel = UsersModel.fromSnapshot(userDoc);
          final coreUser = ChatDetailMigrationService.convertUsersModelToCore(userModel);
          _userCacheService.updateUser(coreUser);
        }
      } catch (e) {
        debugPrint('Error loading user $userId: $e');
      }
    });
    
    await Future.wait(userFutures);
  }
  
  /// 마지막 읽은 시간 업데이트
  Future<void> updateLastReadAt(ChatsModel chatDocument) async {
    if (currentUser == null) return;
    
    await _lifecycleService.updateLastReadAt(
      chatId: chatDocument.reference.id,
      userId: currentUser!.id,
    );
  }
  
  /// 캐시에 메시지 추가
  Future<void> addMessageToCache(String chatId, MessagesModel message) async {
    try {
      final cachedMessages = await _cacheService.getChatMessages(chatId);
      
      // 중복 체크
      if (cachedMessages.any((m) => m.reference.id == message.reference.id)) {
        return;
      }
      
      // 새 메시지 추가
      cachedMessages.add(message);
      
      // 시간순 정렬
      cachedMessages.sort((a, b) {
        final aTime = a.timeStamp;
        final bTime = b.timeStamp;
        if (aTime == null || bTime == null) return 0;
        return aTime.compareTo(bTime);
      });
      
      // 캐시 업데이트
      await _cacheService.setChatMessages(chatId, cachedMessages);
    } catch (e) {
      debugPrint('[Chat Init] Failed to add message to cache: $e');
    }
  }
  
  /// 캐시에서 메시지 업데이트
  Future<void> updateMessageInCache(String chatId, MessagesModel updatedMessage) async {
    try {
      final cachedMessages = await _cacheService.getChatMessages(chatId);
      
      // 메시지 찾아서 업데이트
      final index = cachedMessages.indexWhere(
        (m) => m.reference.id == updatedMessage.reference.id
      );
      
      if (index != -1) {
        cachedMessages[index] = updatedMessage;
        await _cacheService.setChatMessages(chatId, cachedMessages);
      }
    } catch (e) {
      debugPrint('[Chat Init] Failed to update message in cache: $e');
    }
  }
  
  /// 캐시에서 메시지 제거
  Future<void> removeMessageFromCache(String chatId, String messageId) async {
    try {
      final cachedMessages = await _cacheService.getChatMessages(chatId);
      
      // 메시지 제거
      cachedMessages.removeWhere((m) => m.reference.id == messageId);
      
      // 캐시 업데이트
      await _cacheService.setChatMessages(chatId, cachedMessages);
    } catch (e) {
      debugPrint('[Chat Init] Failed to remove message from cache: $e');
    }
  }
  
  /// Firestore 문서를 Core 메시지로 변환
  Future<core.Message> _convertDocToMessage(DocumentSnapshot doc, {String? chatId}) async {
    final messageModel = MessagesModel.fromSnapshot(doc);
    final messageData = doc.data() as Map<String, dynamic>?;
    
    return await ChatDetailMigrationService.convertFirestoreToCore(
      messageModel,
      messageData,
      {},
      isAiChat: chatId?.startsWith('ai_assistant_') ?? false,
    );
  }
  
  /// 기본 사용자 생성
  void _createDefaultUser() {
    currentUser = core.User(
      id: currentUserUid.isNotEmpty ? currentUserUid : 'anonymous',
      name: '사용자',
    );
    _userCacheService.updateUser(currentUser!);
  }
}

/// 초기화 결과 클래스
class BootstrapResult {
  final bool isSuccessful;
  final List<core.Message> messages;
  final core.User? currentUser;
  final UsersModel? currentUserRecord;
  final DocumentSnapshot? anchorDocument;
  final DocumentSnapshot? lastLoadedDocument;
  final DateTime? lastLoadedTimestamp;
  
  BootstrapResult({
    required this.isSuccessful,
    required this.messages,
    this.currentUser,
    this.currentUserRecord,
    this.anchorDocument,
    this.lastLoadedDocument,
    this.lastLoadedTimestamp,
  });
}