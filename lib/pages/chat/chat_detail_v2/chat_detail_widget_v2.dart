/// ═══════════════════════════════════════════════════════════════════════════
/// ChatDetailWidgetV2 - 현재 사용 중인 모든 채팅 처리 컴포넌트
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// 🎯 역할: Versus Space의 모든 채팅 기능을 처리하는 핵심 컴포넌트
/// 
/// ✅ 담당 기능:
///   - 일반 채팅: 사용자 간 1:1 메시지
///   - 투표 카드: AI가 생성한 투표 요청 표시 및 상호작용
///   - 검색 기능: AI 채팅방에서만 활성화 (chatName == 'AI 피클')
/// 
/// 📱 AI 채팅방 검색 UI (2025-08-14 업데이트):
///   - 검색창 위치: 하단 배치 (카카오톡 스타일)
///   - 메시지 입력창: AI 채팅방에서 숨김 처리
///   - 입력 제한: 최대 20자, 자동수정 비활성화
///   - UI 개선: 텍스트 수직 중앙 정렬, 아이콘 패딩 최적화
/// 
/// ⚠️ 주의: AIChatPageV2와 다른 용도입니다!
///   - ChatDetailWidgetV2: 현재 사용 중, 모든 채팅 처리
///   - AIChatPageV2: 미래 AI 어시스턴트 전용 (현재 미사용)
/// 
/// 📦 Dependencies: flutter_chat_ui v2.9.0, flutter_chat_core v2.8.0
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:uuid/uuid.dart';
import '/core/app_utils.dart';
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/pages/chat/services/chat_message_lifecycle_service.dart';
import '/pages/chat/services/chat_media_upload_service.dart';
import '/pages/chat/services/chat_initialization_service.dart';
import '/pages/chat/services/chat_scroll_service.dart';
import '/pages/chat/services/chat_animation_service.dart';
import '/services/user_cache_service.dart';
import 'chat_detail_migration_service.dart';
import 'chat_detail_controller_v2.dart';
import 'components/chat_message_builder.dart';
import 'components/chat_detail_app_bar.dart';
import 'components/chat_detail_fab.dart';
import 'components/chat_detail_loading_widgets.dart';

/// Chat Detail Widget using flutter_chat_ui v2
/// 
/// This is the properly migrated chat detail page that uses flutter_chat_ui v2.9.0
/// with full support for scrolling, search, and custom messages.
class ChatDetailWidgetV2 extends StatefulWidget {
  const ChatDetailWidgetV2({
    super.key,
    required this.chatDocument,
  });

  static const String routeName = 'ChatDetail';
  static const String routePath = '/chat-detail';

  final ChatsModel? chatDocument;

  @override
  State<ChatDetailWidgetV2> createState() => _ChatDetailWidgetV2State();
}

class _ChatDetailWidgetV2State extends State<ChatDetailWidgetV2> 
    with TickerProviderStateMixin {
  late ChatDetailControllerV2 _chatController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Services
  final _lifecycleService = ChatMessageLifecycleService();
  final _userCacheService = UserCacheService.instance;
  late ChatInitializationService _initService;
  late ChatScrollService _scrollService;
  late ChatAnimationService _animationService;
  
  // User management
  core.User? _currentUser;
  UsersModel? _currentUserRecord;
  bool _isLoadingUsers = true;
  
  // Media upload - prepared for future implementation
  // final ChatMediaUploadService _mediaUploadService = ChatMediaUploadService();
  // bool _isUploadingMedia = false;
  
  // Search functionality
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<core.Message> _searchResults = [];
  int _currentSearchIndex = 0;
  
  // Message subscription
  StreamSubscription<QuerySnapshot>? _messageSubscription;
  
  // Message status subscription
  StreamSubscription<Map<String, MessageDeliveryStatus>>? _messageStatusSubscription;
  Map<String, MessageDeliveryStatus> _messageStatuses = {};
  
  // Pagination
  static const int _initialMessageLimit = 30;
  static const int _messagePageSize = 20;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;
  bool _skipInitialSnapshot = true;  // 스트림의 첫 스냅샷 스킵
  
  // Debounce timer for scroll events to prevent frame drops
  Timer? _scrollDebounceTimer;
  
  // Initial loading state
  bool _isInitialLoading = true;
  
  // Bootstrap and scroll management
  bool _bootstrapped = false;
  bool _initialMessagesSet = false;  // Track if initial messages have been set
  bool _isAtBottom = false;  // 초기값 false - 스크롤 후 true로 변경
  bool _isNearBottom = false;  // 초기값 false - 스크롤 후 true로 변경
  DocumentSnapshot? _anchorDocument;
  DocumentSnapshot? _lastLoadedDocument;  // 마지막 로드된 문서 참조 (커서용)
  // DateTime? _lastLoadedTimestamp;  // 서비스로 이동됨
  // Scroll controller is now managed by ChatScrollService
  
  // AI chat detection
  bool get isAiChat => 
    widget.chatDocument?.chatName == 'AI 피클' ||
    (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);

  @override
  void initState() {
    super.initState();
    _chatController = ChatDetailControllerV2();
    
    // Initialize services
    _initService = ChatInitializationService();
    _scrollService = ChatScrollService(_chatController);
    _animationService = ChatAnimationService();
    
    // Initialize animations
    _animationService.initializeAnimations(this);
    
    _bootstrap();  // Changed from _initializeChat to _bootstrap
  }

  @override
  void dispose() {
    // Update last read timestamp when leaving chat
    _updateLastReadAt();
    
    _scrollDebounceTimer?.cancel();
    _messageSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chatController.dispose();
    _scrollService.dispose();
    _animationService.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // 서비스를 통한 초기화
    final result = await _initService.bootstrap(
      chatDocument: widget.chatDocument,
      initialMessageLimit: _initialMessageLimit,
    );
    
    // 결과 저장
    _currentUser = result.currentUser;
    _currentUserRecord = result.currentUserRecord;
    _anchorDocument = result.anchorDocument;
    _lastLoadedDocument = result.lastLoadedDocument;
    // _lastLoadedTimestamp는 서비스에서 관리
    
    // 메시지 설정
    if (result.messages.isNotEmpty && !_initialMessagesSet) {
      final messagesWithHeaders = _addDateHeaders(result.messages);
      _chatController.setMessages(messagesWithHeaders);
      _initialMessagesSet = true;
    }
    
    // 스크롤 상태 초기화
    _scrollService.updateScrollState(atBottom: true, nearBottom: true);
    _isAtBottom = true;
    _isNearBottom = true;
    
    _bootstrapped = true;
    
    // UI 업데이트
    setState(() {
      _isInitialLoading = false;
      _isLoadingUsers = false;
    });
    
    // 스트림 시작
    if (widget.chatDocument != null) {
      _startIncrementalStream();
      _listenToMessageStatuses();
    }
  }
  
  Future<void> _updateLastReadAt() async {
    if (widget.chatDocument == null || _currentUser == null) return;
    
    await _lifecycleService.updateLastReadAt(
      chatId: widget.chatDocument!.reference.id,
      userId: _currentUser!.id,
    );
  }
  
  Future<core.Message> _convertDocToMessage(DocumentSnapshot doc) async {
    final messageModel = MessagesModel.fromSnapshot(doc);
    final messageData = doc.data() as Map<String, dynamic>?;
    
    return await ChatDetailMigrationService.convertFirestoreToCore(
      messageModel,
      messageData,
      {},
      isAiChat: isAiChat,
    );
  }
  
  void _startIncrementalStream() {
    if (!_bootstrapped || widget.chatDocument == null) return;
    
    // Reset skip flag for new stream
    _skipInitialSnapshot = true;
    
    Query query = widget.chatDocument!.reference
        .collection('messages')
        .orderBy('time_stamp', descending: false);
    
    // 커서 기반 필터링 - 초기 로드된 메시지 이후만 스트리밍
    // 문서가 있으면 문서 기반, 없으면 타임스탬프 기반 커서 사용
    if (_lastLoadedDocument != null) {
      query = query.startAfterDocument(_lastLoadedDocument!);
      debugPrint('[Chat Detail Stream] Starting stream after document: ${_lastLoadedDocument!.id}');
    } else if (_initService.lastLoadedTimestamp != null) {
      // 캐시에서 로드한 경우 타임스탬프 기반 커서 사용
      query = query.where('time_stamp', isGreaterThan: Timestamp.fromDate(_initService.lastLoadedTimestamp!));
      debugPrint('[Chat Detail Stream] Starting stream after timestamp: ${_initService.lastLoadedTimestamp}');
      // 타임스탬프 커서 사용 시 초기 스냅샷 스킵하지 않음 (새 메시지만 오기 때문)
      _skipInitialSnapshot = false;
    } else {
      debugPrint('[Chat Detail Stream] Starting stream without cursor - will skip initial snapshot');
    }
    
    _messageSubscription = query.snapshots(includeMetadataChanges: false).listen(_onIncrementalUpdate);
  }
  
  void _onIncrementalUpdate(QuerySnapshot snapshot) {
    if (!_bootstrapped) {
      debugPrint('[Chat Detail Stream] Skipping - not bootstrapped');
      return;
    }
    
    // Skip the initial snapshot from stream
    if (_skipInitialSnapshot) {
      _skipInitialSnapshot = false;
      debugPrint('[Chat Detail Stream] Skipping initial snapshot');
      return;
    }
    
    // Skip if no actual changes
    if (snapshot.docChanges.isEmpty) {
      return;
    }
    
    debugPrint('[Chat Detail Stream] Changes detected: ${snapshot.docChanges.length}');
    debugPrint('[Chat Detail Stream] Added: ${snapshot.docChanges.where((c) => c.type == DocumentChangeType.added).length}');
    debugPrint('[Chat Detail Stream] Modified: ${snapshot.docChanges.where((c) => c.type == DocumentChangeType.modified).length}');
    debugPrint('[Chat Detail Stream] Removed: ${snapshot.docChanges.where((c) => c.type == DocumentChangeType.removed).length}');
    
    // Debug logging to track stream changes
    final addedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.added).length;
    final modifiedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.modified).length;
    final removedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.removed).length;
    
    if (addedCount > 0 || modifiedCount > 0 || removedCount > 0) {
      debugPrint('[Chat Stream] Changes: added=$addedCount, modified=$modifiedCount, removed=$removedCount');
      debugPrint('[Chat Stream] Processing ${snapshot.docChanges.length} changes...');
    }
    
    for (final change in snapshot.docChanges) {
      _processDocumentChange(change);
    }
  }
  
  Future<void> _processDocumentChange(DocumentChange change) async {
    final message = await _convertDocToMessage(change.doc);
    final chatId = widget.chatDocument?.reference.id;
    
    switch (change.type) {
      case DocumentChangeType.added:
        // Add new message
        _chatController.insertMessage(message);
        
        // 새 메시지를 마지막 문서로 업데이트
        _lastLoadedDocument = change.doc;
        
        // 캐시에도 추가 (실시간 동기화)
        if (chatId != null) {
          try {
            final messageModel = MessagesModel.fromSnapshot(change.doc);
            await _initService.addMessageToCache(chatId, messageModel);
            
            if (kDebugMode) {
              debugPrint('[Chat Detail] Added message to cache: ${message.id}');
            }
          } catch (e) {
            debugPrint('[Chat Detail] Failed to add message to cache: $e');
          }
        }
        
        // Show FAB and animate if not at bottom and not from current user
        if (!_isAtBottom && message.authorId != _currentUser?.id) {
          // Trigger FAB animation
          if (!_animationService.fabScaleController.isAnimating && _animationService.fabScaleController.value == 0) {
            _animationService.showFab();
          }
          
          // Bounce animation for new message
          _animationService.playFabBounce();
          
          // Haptic feedback for new message
          HapticFeedback.lightImpact();
        }
        
        // Auto-scroll if near bottom and not from current user
        if (_isNearBottom && message.authorId != _currentUser?.id) {
          _scrollToBottom();
        }
        
        // Update last loaded timestamp
        // Update last loaded document for cursor
        _lastLoadedDocument = change.doc;
        break;
        
      case DocumentChangeType.modified:
        // Update existing message
        final oldMessage = _chatController.messages
            .firstWhere((m) => m.id == message.id, orElse: () => message);
        _chatController.updateMessage(oldMessage, message);
        
        // 캐시에서도 업데이트
        if (chatId != null) {
          try {
            final messageModel = MessagesModel.fromSnapshot(change.doc);
            await _initService.updateMessageInCache(chatId, messageModel);
            
            if (kDebugMode) {
              debugPrint('[Chat Detail] Updated message in cache: ${message.id}');
            }
          } catch (e) {
            debugPrint('[Chat Detail] Failed to update message in cache: $e');
          }
        }
        break;
        
      case DocumentChangeType.removed:
        // Remove message
        final toRemove = _chatController.messages
            .firstWhere((m) => m.id == message.id, orElse: () => message);
        _chatController.removeMessage(toRemove);
        
        // 캐시에서도 제거
        if (chatId != null) {
          try {
            await _initService.removeMessageFromCache(chatId, message.id);
            
            if (kDebugMode) {
              debugPrint('[Chat Detail] Removed message from cache: ${message.id}');
            }
          } catch (e) {
            debugPrint('[Chat Detail] Failed to remove message from cache: $e');
          }
        }
        break;
    }
  }
  
  /// Load more messages for pagination
  Future<void> _loadMoreMessages() async {
    if (!_hasMoreMessages || _isLoadingMore || !_bootstrapped) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      
      // Load older messages
      Query query = widget.chatDocument!.reference
          .collection('messages')
          .orderBy('time_stamp', descending: false)
          .limit(_messagePageSize);
      
      if (_anchorDocument != null) {
        // Load messages before the anchor document
        query = query.endBefore([
          (_anchorDocument!.data() as Map<String, dynamic>)['time_stamp']
        ]);
      }
      
      final snapshot = await query.get();
      
      if (snapshot.docs.isEmpty) {
        setState(() {
          _hasMoreMessages = false;
        });
        return;
      }
      
      // Update anchor for next pagination
      _anchorDocument = snapshot.docs.first;
      
      // Convert older messages in parallel
      final messageFutures = snapshot.docs.map((doc) => _convertDocToMessage(doc));
      final olderMessages = await Future.wait(messageFutures);
      
      // Get existing message IDs to prevent duplicates
      final existingIds = _chatController.messages
          .where((m) => m.id.isNotEmpty)
          .map((m) => m.id)
          .toSet();
      
      // Filter out duplicate messages
      final uniqueOlderMessages = olderMessages
          .where((msg) => msg.id.isNotEmpty && !existingIds.contains(msg.id))
          .toList();
      
      // If all messages were duplicates, we've reached the end
      if (uniqueOlderMessages.isEmpty) {
        setState(() {
          _hasMoreMessages = false;
        });
        return;
      }
      
      // Merge with existing messages
      // Chat UI v2 expects chronological order (oldest first)
      final currentMessages = _chatController.messages.toList();
      uniqueOlderMessages.addAll(currentMessages);  // Add newer messages after older ones
      
      // Update with date headers
      final messagesWithHeaders = _addDateHeaders(uniqueOlderMessages);
      _chatController.setMessages(messagesWithHeaders);
    } catch (e) {
      debugPrint('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  
  /// Listen to message status changes
  void _listenToMessageStatuses() {
    if (widget.chatDocument == null) return;
    
    _messageStatusSubscription = _lifecycleService.watchMessageStatuses(
      chatId: widget.chatDocument!.reference.id,
    ).listen((statusMap) {
      setState(() {
        _messageStatuses = statusMap;
      });
    });
  }
  
  
  /// Add date header system messages between different days
  List<core.Message> _addDateHeaders(List<core.Message> messages) {
    if (messages.isEmpty) return messages;
    
    final result = <core.Message>[];
    DateTime? lastDate;
    
    for (final message in messages) {
      final messageDate = message.createdAt;
      
      if (messageDate != null) {
        // 날짜가 바뀌었으면 날짜 헤더 추가
        if (lastDate == null || 
            lastDate.day != messageDate.day ||
            lastDate.month != messageDate.month ||
            lastDate.year != messageDate.year) {
          
          // 시스템 메시지로 날짜 헤더 추가
          result.add(
            core.Message.system(
              id: 'date_${messageDate.millisecondsSinceEpoch}',
              text: _formatDateHeader(messageDate),
              createdAt: messageDate,
              authorId: 'system', // 시스템 메시지용 작성자 ID
            ),
          );
          
          lastDate = messageDate;
        }
      }
      
      result.add(message);
    }
    
    return result;
  }
  
  /// Format date header
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    // 오늘
    if (difference.inDays == 0 && 
        now.day == date.day && 
        now.month == date.month && 
        now.year == date.year) {
      return '오늘';
    }
    // 어제
    else if (difference.inDays == 1 && 
             now.day - 1 == date.day && 
             now.month == date.month && 
             now.year == date.year) {
      return '어제';
    }
    // 이번 주
    else if (difference.inDays < 7) {
      const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
      return '${date.month}월 ${date.day}일 ${weekdays[date.weekday % 7]}요일';
    }
    // 그 외
    else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }
  
  /// Resolve user from ID
  Future<core.User?> _resolveUser(String userId) async {
    // Check cache first
    final cachedUser = await _userCacheService.getUser(userId);
    if (cachedUser != null) {
      return cachedUser;
    }
    
    // Special case for AI assistant
    if (userId == 'ai_assistant') {
      final aiUser = const core.User(
        id: 'ai_assistant',
        name: 'AI 피클',
        imageSource: 'https://picsum.photos/seed/ai_assistant/200',
      );
      _userCacheService.updateUser(aiUser);
      return aiUser;
    }
    
    // Load from Firestore
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final userModel = UsersModel.fromSnapshot(userDoc);
        final coreUser = ChatDetailMigrationService.convertUsersModelToCore(userModel);
        _userCacheService.updateUser(coreUser);
        return coreUser;
      }
    } catch (e) {
      debugPrint('Error loading user $userId: $e');
    }
    
    return null;
  }
  
  /// Handle sending a message
  void _handleSendPressed(String text) async {
    if (widget.chatDocument == null) return;
    
    final messageId = const Uuid().v4();
    
    // Create message in Firestore
    await MessagesModel.createDoc(widget.chatDocument!.reference)
        .set(createMessagesModelData(
      messageId: messageId,
      content: text,
      senderId: currentUserUid,
      timeStamp: getCurrentTimestamp(),
    ));
    
    // Update chat metadata
    await widget.chatDocument!.reference.update({
      ...createChatsModelData(
        lastMessageContent: text,
        lastMessageAt: getCurrentTimestamp(),
      ),
      'participantIds': FieldValue.arrayUnion([currentUserUid]),
    });
  }
  
  /// Handle sending a media message
  void _handleSendMediaMessage(String mediaUrl, String mediaType, String? localPath) async {
    if (widget.chatDocument == null) return;
    
    await ChatMediaUploadService.sendMediaMessage(
      chatDocument: widget.chatDocument!,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      localPath: localPath,
    );
  }
  
  /// Handle attachment button press
  void _handleAttachmentPressed() {
    // Show media selection bottom sheet
    showModalBottomSheet(
      context: context,
      backgroundColor: VersusColors.backgroundPrimary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(VersusSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: VersusSpacing.md),
              decoration: BoxDecoration(
                color: VersusColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              '미디어 선택',
              style: VersusTextStyles.headingSmall,
            ),
            const SizedBox(height: VersusSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildMediaOption(
                  icon: Icons.photo_library,
                  label: '갤러리',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMediaFromGallery();
                  },
                ),
                _buildMediaOption(
                  icon: Icons.camera_alt,
                  label: '카메라',
                  onTap: () {
                    Navigator.pop(context);
                    _pickMediaFromCamera();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMediaOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(VersusSpacing.md),
        child: Column(
          children: [
            Icon(icon, size: 32, color: VersusColors.primary),
            const SizedBox(height: VersusSpacing.xs),
            Text(label, style: VersusTextStyles.bodySmall),
          ],
        ),
      ),
    );
  }
  
  Future<void> _pickMediaFromGallery() async {
    await ChatMediaUploadService.pickMediaFromGallery(
      context: context,
      chatDocument: widget.chatDocument!,
      onMediaUploaded: _handleSendMediaMessage,
    );
  }
  
  Future<void> _pickMediaFromCamera() async {
    await ChatMediaUploadService.pickMediaFromCamera(
      context: context,
      chatDocument: widget.chatDocument!,
      onMediaUploaded: _handleSendMediaMessage,
    );
  }

  
  /// Build custom message widget (for VoteCardMessage)
  Widget _buildCustomMessage(
    BuildContext context,
    core.CustomMessage message,
    int index, {
    required bool isSentByMe,
    core.MessageGroupStatus? groupStatus,
  }) {
    // Delegate to ChatMessageBuilder
    return ChatMessageBuilder.buildCustomMessage(
      context,
      message,
      index,
      isSentByMe: isSentByMe,
      groupStatus: groupStatus,
      chatDocument: widget.chatDocument,
      currentUserRecord: _currentUserRecord,
      searchQuery: _searchQuery,
      isSearching: _isSearching,
      messageStatus: _messageStatuses[message.id],
    );
  }
  
  
  /// Build system message (date headers and unread divider)
  Widget _buildSystemMessage(
    BuildContext context,
    core.SystemMessage message,
    int index, {
    core.MessageGroupStatus? groupStatus,
    bool isSentByMe = false,
  }) {
    // Special handling for unread divider
    if (message.id == 'unread-divider') {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: VersusColors.primary.withValues(alpha: 0.3),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: VersusColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: VersusColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_downward,
                    size: 14,
                    color: VersusColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    message.text,
                    style: VersusTextStyles.labelSmall.copyWith(
                      color: VersusColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: VersusColors.primary.withValues(alpha: 0.3),
              ),
            ),
          ],
        ),
      );
    }
    
    // Normal date header
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: VersusColors.backgroundSecondary.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.text,
            style: VersusTextStyles.labelSmall.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Perform search and highlight results
  void _performSearch(String query) {
    // Trim whitespace from query
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return;
    
    setState(() {
      _isSearching = true;  // Enable search highlighting
      _searchQuery = trimmedQuery;  // Update search query with trimmed value
      _searchResults = _chatController.searchMessages(trimmedQuery);
      _currentSearchIndex = 0;
      
      if (_searchResults.isNotEmpty) {
        // Scroll to first result
        _chatController.scrollToMessage(_searchResults[0].id);
      }
    });
  }
  
  /// Navigate to next/previous search result
  void _navigateToSearchResult(bool next) {
    if (_searchResults.isEmpty) return;
    
    setState(() {
      if (next) {
        // Navigate to next result (circular)
        _currentSearchIndex = (_currentSearchIndex + 1) % _searchResults.length;
      } else {
        // Navigate to previous result (circular)
        _currentSearchIndex = (_currentSearchIndex - 1 + _searchResults.length) % _searchResults.length;
      }
      
      // Scroll to current result
      _chatController.scrollToMessage(_searchResults[_currentSearchIndex].id);
    });
  }
  
  /// Build AI search input for bottom placement
  Widget _buildAISearchInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: VersusColors.textPrimary.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: VersusColors.backgroundPrimary,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: VersusColors.textPrimary.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              // Search icon
              Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: Icon(
                  Icons.search,
                  color: VersusColors.primary,
                  size: 22,
                ),
              ),
              // Text field
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  textAlign: TextAlign.left,  // Left align text
                  textAlignVertical: TextAlignVertical.center,  // Vertically center text
                  maxLength: 20,  // 최대 20자 제한
                  buildCounter: (context, {required currentLength, required isFocused, required maxLength}) => null,  // 카운터 숨기기
                  textInputAction: TextInputAction.search,  // 키보드에 검색 버튼 표시
                  autocorrect: false,  // 자동 수정 비활성화
                  enableSuggestions: false,  // 제안 비활성화
                  decoration: InputDecoration.collapsed(
                    hintText: '검색...',
                    hintStyle: VersusTextStyles.bodyMedium.copyWith(
                      color: VersusColors.textSecondary,
                    ),
                  ),
                  onSubmitted: _performSearch,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                      _isSearching = value.isNotEmpty;  // Enable highlighting when text exists
                    });
                    if (value.isEmpty) {
                      setState(() {
                        _searchResults = [];
                        _currentSearchIndex = 0;
                        _isSearching = false;  // Disable highlighting when empty
                      });
                    }
                  },
                  style: VersusTextStyles.bodyMedium.copyWith(
                    color: VersusColors.textPrimary,
                  ),
                ),
              ),
              // Search result counter
              if (_searchResults.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: VersusColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentSearchIndex + 1}/${_searchResults.length}',
                      style: VersusTextStyles.bodySmall.copyWith(
                        color: VersusColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              // Navigation arrows
              if (_searchResults.isNotEmpty) ...[
                // Previous button
                InkWell(
                  onTap: () => _navigateToSearchResult(false),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.keyboard_arrow_up,
                      color: VersusColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                // Next button
                InkWell(
                  onTap: () => _navigateToSearchResult(true),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: VersusColors.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
              ],
              // Clear button when there's text
              if (_searchQuery.isNotEmpty)
                InkWell(
                  onTap: () {
                    setState(() {
                      _searchQuery = '';
                      _searchResults = [];
                      _currentSearchIndex = 0;
                      _isSearching = false;  // Disable highlighting when cleared
                      _searchController.clear();
                    });
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.clear,
                      color: VersusColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
            ],
          ),
        ),
    );
  }
  
  /// Build chat theme
  core.ChatTheme _buildChatTheme() {
    return core.ChatTheme.light().copyWith(
      colors: core.ChatColors(
        primary: VersusColors.primary,
        onPrimary: Colors.white,
        surface: VersusColors.backgroundPrimary,  // 채팅방 배경
        onSurface: VersusColors.textPrimary,
        surfaceContainer: VersusColors.backgroundSecondary,  // 메시지 버블 배경
        surfaceContainerLow: VersusColors.backgroundPrimary,
        surfaceContainerHigh: VersusColors.backgroundSecondary,
      ),
      typography: core.ChatTypography.standard(
        fontFamily: 'SourGummy',
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoadingUsers) {
      return ChatDetailLoadingWidgets.buildUserLoadingScreen();
    }
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: ChatDetailAppBar(
        chatDocument: widget.chatDocument,
        isAiChat: isAiChat,
        isSearching: _isSearching,
        onSearchToggle: () {
          setState(() {
            _isSearching = !_isSearching;
            if (_isSearching) {
              _searchFocusNode.requestFocus();
            }
          });
        },
        onBack: () => context.pop(),
      ),
      body: Column(
        children: [
          // Chat content
          Expanded(
            child: _isInitialLoading 
              ? ChatDetailLoadingWidgets.buildLoadingIndicator()
              : Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // Check if we've scrolled to the top (to load more messages)
                        if (notification is ScrollUpdateNotification) {
                          // Debounce scroll events to prevent excessive calls and frame drops
                          _scrollDebounceTimer?.cancel();
                          _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
                            // Check if we're near the top
                            if (notification.metrics.pixels <= 100 &&
                                notification.metrics.pixels > 0 &&
                                !_isLoadingMore &&
                                _hasMoreMessages) {
                              _loadMoreMessages();
                            }
                          });
                          
                          // Check if we're at bottom (within 24px tolerance)
                          final isAtBottom = notification.metrics.pixels >= 
                              notification.metrics.maxScrollExtent - 24;
                          
                          // Check if we're near bottom (within 100px)
                          final isNearBottom = notification.metrics.pixels >= 
                              notification.metrics.maxScrollExtent - 100;
                          
                          if (_isAtBottom != isAtBottom || _isNearBottom != isNearBottom) {
                            setState(() {
                              _isAtBottom = isAtBottom;
                              _isNearBottom = isNearBottom;
                              
                              // Hide FAB when at bottom
                              if (isAtBottom) {
                                _animationService.hideFab();
                              }
                            });
                          }
                        }
                        return false;
                      },
                      child: Chat(
                    currentUserId: _currentUser?.id ?? 'anonymous',
                    resolveUser: _resolveUser,
                    chatController: _chatController,
                    theme: _buildChatTheme(),
                    timeFormat: DateFormat('h:mm a'), // AM/PM 형식 (3:30 PM)
                    onMessageSend: isAiChat ? null : _handleSendPressed,
                    onAttachmentTap: isAiChat ? null : _handleAttachmentPressed,
                    builders: core.Builders(
                      // Hide input field completely for AI chat
                      composerBuilder: isAiChat 
                          ? (context) => const SizedBox.shrink()
                          : null,
                      chatAnimatedListBuilder: (context, itemBuilder) {
                        return ChatAnimatedListReversed(
                          itemBuilder: itemBuilder,
                        );
                      },
                      customMessageBuilder: _buildCustomMessage,
                      systemMessageBuilder: _buildSystemMessage,
                      emptyChatListBuilder: (context) => 
                        ChatDetailLoadingWidgets.buildEmptyChatList(isAiChat),
                      ),
                    ),
                    ),
                    // Loading indicator for pagination
                    if (_isLoadingMore)
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: ChatDetailLoadingWidgets.buildLoadingMoreIndicator(),
                      ),
                    // FAB for new messages when not at bottom
                    ChatDetailFAB(
                      isAtBottom: _isAtBottom,
                      scaleAnimation: _animationService.fabScaleAnimation,
                      bounceAnimation: _animationService.fabBounceAnimation,
                      onPressed: () {
                        _scrollToBottom();
                        _animationService.hideFab();
                      },
                    ),
                  ],
                ),
              ),
          // AI 채팅방일 때 하단에 검색창 표시
          if (isAiChat) _buildAISearchInput(),
        ],
      ),
    );
  }
  
  /// Scroll to bottom of chat
  void _scrollToBottom() {
    _scrollService.scrollToBottom();
    setState(() {
      _isAtBottom = _scrollService.isAtBottom;
    });
  }
}