import 'package:flutter/foundation.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
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
          final displayName = userData['display_name'] ?? 
                             userData['handle'] ?? 
                             userData['email']?.split('@')[0] ?? 
                             '사용자';
          
          currentUser = core.User(
            id: currentUserUid,
            name: displayName.toString().isNotEmpty ? displayName.toString() : '사용자',
            imageSource: userData['photo_url'],
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
        
        // 문서 정보는 캐시된 메시지에서 설정할 수 없으므로 null로 유지
        anchorDocument = null;
        lastLoadedDocument = null;
        
        // 마지막 메시지 타임스탬프 저장
        if (cachedMessages.isNotEmpty) {
          lastLoadedTimestamp = cachedMessages.last.timeStamp;
        }
        
        return messages;
      }
    } catch (e) {
      debugPrint('[Chat Init] Cache read failed, falling back to Firestore: $e');
    }
    
    // 캐시 미스 시 Firestore에서 로드
    Query<Map<String, dynamic>> initialQuery = chatDocument.reference
        .collection('messages')
        .orderBy('time_stamp', descending: false);
    
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
    if (lastTimestamp['time_stamp'] != null) {
      lastLoadedTimestamp = (lastTimestamp['time_stamp'] as Timestamp).toDate();
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