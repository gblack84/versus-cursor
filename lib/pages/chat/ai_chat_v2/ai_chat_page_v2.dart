/// ═══════════════════════════════════════════════════════════════════════════
/// AIChatPageV2 - 미래 AI 어시스턴트 기능 (현재 미사용)
/// ═══════════════════════════════════════════════════════════════════════════
/// 
/// ⚠️ 현재 상태: 미사용 - 라우팅에 등록되지 않음
/// 
/// 🎯 미래 용도: AI 어시스턴트와의 대화 전용 페이지
/// 
/// 📅 계획된 기능:
///   - 앱 사용법 안내: AI가 앱 기능 설명
///   - 설정 도움말: 사용자 설정 가이드
///   - 일반 대화: ChatGPT 스타일 실시간 대화
///   - 학습 기능: 사용자 패턴 학습 및 추천
/// 
/// ⚠️ 주의: ChatDetailWidgetV2와 다른 용도입니다!
///   - ChatDetailWidgetV2: 현재 모든 채팅 처리 (투표 카드 포함)
///   - AIChatPageV2: 미래 AI 어시스턴트 전용 (Gemini AI와 대화)
/// 
/// 📦 Dependencies: flutter_chat_ui v2.9.0, Gemini AI SDK
/// ═══════════════════════════════════════════════════════════════════════════

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/chat/vote_card_message.dart';
import '/pages/chat/services/chat_message_lifecycle_service.dart';
import '/pages/chat/services/chat_message_service.dart';
import '/services/user_cache_service.dart';
import 'ai_chat_controller.dart';

/// AI Chat Page using flutter_chat_ui v2
/// 
/// This is the new AI chat page that uses flutter_chat_ui v2.9.0
/// with streaming support for AI responses.
class AIChatPageV2 extends StatefulWidget {
  final ChatsModel? chatDocument;
  final String? aiChatId;
  
  const AIChatPageV2({
    Key? key,
    this.chatDocument,
    this.aiChatId,
  }) : super(key: key);
  
  @override
  State<AIChatPageV2> createState() => _AIChatPageV2State();
}

class _AIChatPageV2State extends State<AIChatPageV2> 
    with TickerProviderStateMixin {
  late final AIChatController _chatController;
  late final String _currentUserId;
  
  // User cache service
  final UserCacheService _userCacheService = UserCacheService.instance;
  
  // Search state
  String _searchQuery = '';
  bool _isSearching = false;
  
  // Bootstrap and stream management
  bool _isBootstrapping = true;
  StreamSubscription<QuerySnapshot>? _messagesSubscription;
  final Map<String, core.Message> _messageCache = {};
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;
  DocumentSnapshot? _lastDocument;
  DocumentSnapshot? _lastLoadedDocument;  // 마지막 로드된 문서 참조 (커서용)
  DateTime? _lastLoadedTimestamp;  // 마지막 로드된 메시지의 타임스탬프
  bool _skipInitialSnapshot = true;  // 스트림의 첫 스냅샷 스킵
  
  // Animation controllers
  late AnimationController _fabAnimationController;
  late Animation<double> _fabBounceAnimation;
  late AnimationController _fabScaleController;
  late Animation<double> _fabScaleAnimation;
  
  // Scroll state
  final ScrollController _scrollController = ScrollController();
  bool _showFab = false;
  bool _isNearBottom = false;  // 초기값 false - 스크롤 후 true로 변경
  bool _initialMessagesSet = false;  // Track if initial messages have been set
  
  // Lifecycle service
  final ChatMessageLifecycleService _lifecycleService = ChatMessageLifecycleService();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize chat controller
    _chatController = AIChatController();
    
    // Get current user ID
    _currentUserId = currentUserUid.isNotEmpty ? currentUserUid : 'anonymous';
    
    // Initialize animations
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _fabScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabScaleController,
      curve: Curves.elasticOut,
    ));
    
    // Setup scroll listener
    _scrollController.addListener(_onScroll);
    
    // Initialize AI with API key (you need to set this)
    // TODO: Get API key from environment or Firebase Remote Config
    // _chatController.initializeAI('YOUR_GEMINI_API_KEY');
    
    // Bootstrap the chat
    _bootstrap();
  }
  
  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _fabAnimationController.dispose();
    _fabScaleController.dispose();
    _chatController.dispose();
    super.dispose();
  }
  
  /// Bootstrap the chat
  Future<void> _bootstrap() async {
    setState(() {
      _isBootstrapping = true;
    });
    
    try {
      // 1. Load latest messages
      await _loadInitialMessages();
      
      // 2. Reversed List 사용으로 자동으로 최신 메시지가 하단에 표시됨
      // 초기 스크롤 불필요
      _isNearBottom = true;  // 자동 스크롤 활성화
      
      // 3. Start incremental stream immediately
      _startIncrementalStream();
      
      // 4. Mark messages as seen
      if (widget.aiChatId != null) {
        await _lifecycleService.markMessagesAsSeen(
          chatId: widget.aiChatId!,
          currentUserId: _currentUserId,
        );
      }
    } finally {
      setState(() {
        _isBootstrapping = false;
      });
    }
  }
  
  /// Load initial messages
  Future<void> _loadInitialMessages() async {
    if (widget.aiChatId == null) return;
    
    if (kDebugMode) {
      debugPrint('[AI Chat] Loading initial messages...');
    }
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.aiChatId)
          .collection('messages')
          .orderBy('time_stamp', descending: false)
          .limitToLast(30)
          .get();
      
      if (query.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('[AI Chat] Loaded ${query.docs.length} initial messages');
          debugPrint('[AI Chat] First doc ID: ${query.docs.first.id}');
          debugPrint('[AI Chat] Last doc ID: ${query.docs.last.id}');
        }
        
        _lastDocument = query.docs.first;  // 가장 오래된 문서 (페이지네이션용)
        _hasMoreMessages = query.docs.length >= 30;
        
        final messages = await _convertDocumentsToMessages(query.docs);
        
        // Clear existing messages and set new ones
        _messageCache.clear();
        for (final message in messages) {
          _messageCache[message.id] = message;
          if (kDebugMode) {
            debugPrint('[AI Chat] Cached message: ${message.id}');
          }
        }
        
        // 모든 문서 ID를 저장 (스트림에서 중복 체크용)
        _lastLoadedDocument = query.docs.last;  // 가장 최신 문서를 커서로 저장
        
        // 마지막 메시지의 타임스탬프 저장
        final lastDoc = query.docs.last;
        final lastTimestamp = lastDoc.data();
        if (lastTimestamp['time_stamp'] != null) {
          _lastLoadedTimestamp = (lastTimestamp['time_stamp'] as Timestamp).toDate();
          if (kDebugMode) {
            debugPrint('[AI Chat] Last loaded timestamp: $_lastLoadedTimestamp');
          }
        }
        
        // Set messages only once
        // Flutter Chat UI v2 expects messages in chronological order (oldest first)
        if (!_initialMessagesSet) {
          _chatController.setMessages(messages);
          _initialMessagesSet = true;
          debugPrint('[AI Chat] Initial messages set to controller');
        }
      } else {
        debugPrint('[AI Chat] No initial messages found');
      }
    } catch (e) {
      print('Error loading initial messages: $e');
    }
  }
  
  /// Start incremental stream for new messages
  void _startIncrementalStream() {
    if (widget.aiChatId == null) return;
    
    // Cancel existing subscription
    _messagesSubscription?.cancel();
    
    // Reset skip flag for new stream
    _skipInitialSnapshot = true;
    
    // Build query
    Query query = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.aiChatId)
        .collection('messages')
        .orderBy('time_stamp', descending: false);
    
    // 커서 기반 필터링 - 초기 로드된 메시지 이후만 스트리밍
    if (_lastLoadedDocument != null) {
      query = query.startAfterDocument(_lastLoadedDocument!);
      debugPrint('[AI Chat Stream] Starting stream after document: ${_lastLoadedDocument!.id}');
    } else {
      debugPrint('[AI Chat Stream] Starting stream without cursor - will skip initial snapshot');
    }
    
    // Start new subscription with metadata changes disabled
    _messagesSubscription = query.snapshots(includeMetadataChanges: false).listen((snapshot) async {
      if (_isBootstrapping) {
        debugPrint('[AI Chat Stream] Skipping - still bootstrapping');
        return;
      }
      
      // Skip the initial snapshot from stream
      if (_skipInitialSnapshot) {
        _skipInitialSnapshot = false;
        debugPrint('[AI Chat Stream] Skipping initial snapshot');
        return;
      }
      
      // Skip if no actual changes
      if (snapshot.docChanges.isEmpty) {
        return;
      }
      
      // Debug logging to track stream changes
      final addedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.added).length;
      final modifiedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.modified).length;
      final removedCount = snapshot.docChanges.where((c) => c.type == DocumentChangeType.removed).length;
      
      if (addedCount > 0 || modifiedCount > 0 || removedCount > 0) {
        debugPrint('[AI Chat Stream] Changes: added=$addedCount, modified=$modifiedCount, removed=$removedCount');
        debugPrint('[AI Chat Stream] Processing ${snapshot.docChanges.length} changes...');
        debugPrint('[AI Chat Stream] Current cache size: ${_messageCache.length}');
      }
      
      for (final change in snapshot.docChanges) {
        final messageId = change.doc.id;
        
        switch (change.type) {
          case DocumentChangeType.added:
            // Only add if not in cache (prevents duplicates)
            if (!_messageCache.containsKey(messageId)) {
              debugPrint('[AI Chat Stream] Adding new message: $messageId');
              final message = await _convertDocumentToMessage(change.doc);
              if (message != null) {
                _messageCache[messageId] = message;
                _chatController.insertMessage(message);
                
                // 새 메시지를 마지막 문서로 업데이트
                _lastLoadedDocument = change.doc;
                
                // Play haptic feedback for new messages from others
                if (message.authorId != _currentUserId) {
                  HapticFeedback.lightImpact();
                  
                  // Auto-scroll if near bottom
                  if (_isNearBottom) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      _scrollToBottom();
                    });
                  }
                  
                  // Animate FAB for new messages
                  _animateFabBounce();
                }
              }
            } else {
              debugPrint('[AI Chat Stream] Message already in cache, skipping: $messageId');
            }
            break;
            
          case DocumentChangeType.modified:
            // Only update if message exists in cache
            if (_messageCache.containsKey(messageId)) {
              final message = await _convertDocumentToMessage(change.doc);
              if (message != null) {
                final oldMessage = _messageCache[messageId];
                if (oldMessage != null) {
                  _messageCache[messageId] = message;
                  _chatController.updateMessage(oldMessage, message);
                  debugPrint('[AI Chat Stream] Updated message: $messageId');
                }
              }
            }
            break;
            
          case DocumentChangeType.removed:
            final message = _messageCache[messageId];
            if (message != null) {
              _messageCache.remove(messageId);
              _chatController.removeMessage(message);
            }
            break;
        }
      }
      
      // Mark messages as seen
      _markMessagesAsSeen();
    });
  }
  
  /// Convert Firestore documents to messages
  Future<List<core.Message>> _convertDocumentsToMessages(
      List<QueryDocumentSnapshot> docs) async {
    // Use ChatMessageService for conversion
    return await ChatMessageService.convertDocumentsToMessages(docs);
  }
  
  /// Convert single Firestore document to message
  Future<core.Message?> _convertDocumentToMessage(
      DocumentSnapshot doc) async {
    // Use ChatMessageService for conversion
    return await ChatMessageService.convertDocumentToMessage(doc);
  }
  
  /// Scroll event handler
  void _onScroll() {
    if (_scrollController.hasClients) {
      final offset = _scrollController.offset;
      final maxScroll = _scrollController.position.maxScrollExtent;
      
      // Check if near bottom (within 100 pixels)
      _isNearBottom = maxScroll - offset < 100;
      
      // Show/hide FAB based on scroll position
      if (offset > 500 && !_showFab) {
        setState(() {
          _showFab = true;
        });
        _fabScaleController.forward();
      } else if (offset <= 500 && _showFab) {
        setState(() {
          _showFab = false;
        });
        _fabScaleController.reverse();
      }
      
      // Load more messages when reaching top
      if (offset <= 100 && !_isLoadingMore && _hasMoreMessages) {
        _loadMoreMessages();
      }
    }
  }
  
  /// Load more messages (pagination)
  Future<void> _loadMoreMessages() async {
    if (_isLoadingMore || !_hasMoreMessages || widget.aiChatId == null) {
      return;
    }
    
    setState(() {
      _isLoadingMore = true;
    });
    
    try {
      final query = await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.aiChatId)
          .collection('messages')
          .orderBy('time_stamp', descending: false)
          .endBefore([_lastDocument!['time_stamp']])
          .limitToLast(20)
          .get();
      
      if (query.docs.isNotEmpty) {
        _lastDocument = query.docs.first;
        _hasMoreMessages = query.docs.length >= 20;
        
        final messages = await _convertDocumentsToMessages(query.docs);
        
        // Add to cache
        for (final message in messages) {
          if (!_messageCache.containsKey(message.id)) {
            _messageCache[message.id] = message;
          }
        }
        
        // Add older messages at the beginning of the list
        // Chat UI v2 expects chronological order (oldest first)
        final currentMessages = _chatController.messages.toList();
        messages.addAll(currentMessages);
        _chatController.setMessages(messages);
      } else {
        _hasMoreMessages = false;
      }
    } catch (e) {
      print('Error loading more messages: $e');
    } finally {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }
  
  /// Mark messages as seen
  Future<void> _markMessagesAsSeen() async {
    if (widget.aiChatId == null) return;
    
    try {
      await _lifecycleService.markMessagesAsSeen(
        chatId: widget.aiChatId!,
        currentUserId: _currentUserId,
      );
      
      // Update last read timestamp
      await _lifecycleService.updateLastReadAt(
        chatId: widget.aiChatId!,
        userId: _currentUserId,
      );
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }
  
  /// Animate FAB bounce
  void _animateFabBounce() {
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });
  }
  
  /// Scroll to bottom
  void _scrollToBottom() {
    // ChatController의 scrollToMessage 메서드 사용
    final messages = _chatController.messages;
    if (messages.isNotEmpty) {
      _chatController.scrollToMessage(
        messages.last.id,
        duration: const Duration(milliseconds: 300),
      );
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
    if (userId == AIChatController.aiUserId) {
      final aiUser = const core.User(
        id: AIChatController.aiUserId,
        name: AIChatController.aiUserName,
        imageSource: 'https://picsum.photos/seed/ai_assistant/200',
      );
      _userCacheService.updateUser(aiUser);
      return aiUser;
    }
    
    // Special case for current user - fetch from Users collection for consistency
    if (userId == _currentUserId) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUserId)
            .get();
        
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          // Use multiple fallbacks for display name
          final displayName = userData['display_name'] ?? 
                             userData['handle'] ?? 
                             userData['email']?.split('@')[0] ?? 
                             'User';
          
          final currentUser = core.User(
            id: _currentUserId,
            name: displayName.toString().isNotEmpty ? displayName.toString() : 'User',
            imageSource: userData['photo_url'] ?? currentUserPhoto,
          );
          _userCacheService.updateUser(currentUser);
          return currentUser;
        }
      } catch (e) {
        debugPrint('Error loading current user: $e');
      }
      
      // Fallback to global values
      final currentUser = core.User(
        id: _currentUserId,
        name: currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'User',
        imageSource: currentUserPhoto,
      );
      _userCacheService.updateUser(currentUser);
      return currentUser;
    }
    
    // Load user from Firestore
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        final user = core.User(
          id: userId,
          name: userData['display_name'] ?? 'User',
          imageSource: userData['photo_url'],
        );
        _userCacheService.updateUser(user);
        return user;
      }
    } catch (e) {
      debugPrint('Error loading user $userId: $e');
    }
    
    return null;
  }
  
  /// Handle sending a message
  void _handleSendPressed(String text) {
    // Send query to AI
    _chatController.sendAIQuery(
      query: text,
      currentUserId: _currentUserId,
    );
    
    // Mark messages as seen when sending
    _markMessagesAsSeen();
  }
  
  /// Handle attachment button press
  void _handleAttachmentPressed() {
    // TODO: Implement attachment handling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attachments not yet supported')),
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
    final metadata = message.metadata ?? {};
    
    // Check if this is a vote message
    if (metadata['type'] == 'vote_request' || metadata['type'] == 'vote_created') {
      // Wrap with KeyedSubtree to preserve scroll position during rebuilds
      return KeyedSubtree(
        key: ValueKey(message.id),
        child: VoteCardMessage(
          postId: metadata['postId'] ?? '',
          title: metadata['title'] ?? '',
          description: metadata['description'],
          optionAText: metadata['optionAText'] ?? '',
          optionBText: metadata['optionBText'] ?? '',
          optionAImage: metadata['optionAImage'],
          optionBImage: metadata['optionBImage'],
          optionAImages: metadata['optionAImages'],
          optionBImages: metadata['optionBImages'],
          aspectRatioA: metadata['aspectRatioA'],
          aspectRatioB: metadata['aspectRatioB'],
          cardStatus: metadata['cardStatus'] ?? 'voting_request',
          voteEndTime: metadata['voteEndTime'] != null 
              ? (metadata['voteEndTime'] is DateTime 
                  ? metadata['voteEndTime'] 
                  : metadata['voteEndTime'].toDate())
              : null,
          userVotes: metadata['userVotes'],
          voteResults: metadata['voteResults'],
          isMe: isSentByMe,
          messageType: metadata['type'] ?? 'vote_request',
          messageId: message.id,
          chatId: widget.aiChatId,
          currentUserName: currentUserDisplayName,
          searchQuery: _searchQuery,
        ),
      );
    }
    
    // Default text representation for unknown custom messages
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Custom message: ${metadata['type'] ?? 'unknown'}',
        style: VersusTextStyles.bodyMedium,
      ),
    );
  }
  
  /// Build search input widget
  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: VersusColors.backgroundSecondary,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            // Send search query to AI
            _handleSendPressed(query);
          }
        },
        decoration: InputDecoration(
          hintText: 'AI 피클에게 물어보세요...',
          hintStyle: VersusTextStyles.bodyMedium.copyWith(
            color: VersusColors.textSecondary,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: VersusColors.textSecondary,
          ),
          suffixIcon: _chatController.isStreaming
              ? IconButton(
                  icon: const Icon(Icons.stop),
                  onPressed: () {
                    _chatController.cancelStream();
                  },
                  color: VersusColors.error,
                )
              : null,
          filled: true,
          fillColor: VersusColors.backgroundPrimary,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
  
  /// Build system message (unread divider)
  Widget _buildSystemMessage(
    BuildContext context,
    core.SystemMessage message,
    int index, {
    core.MessageGroupStatus? groupStatus,
    bool isSentByMe = false,
  }) {
    // Build unread messages divider
    if (message.text.contains('읽지 않은 메시지')) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Divider(
                color: VersusColors.error,
                thickness: 1,
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: VersusColors.error,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: VersusColors.error,
                thickness: 1,
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }
  
  /// Build chat theme
  core.ChatTheme _buildChatTheme() {
    return core.ChatTheme.light().copyWith(
      colors: core.ChatColors(
        primary: VersusColors.primary,
        onPrimary: Colors.white,
        surface: VersusColors.backgroundPrimary,
        onSurface: VersusColors.textPrimary,
        surfaceContainer: VersusColors.backgroundSecondary,
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
    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: VersusColors.backgroundSecondary,
        toolbarHeight: 56.0,  // Android 표준 높이로 조정
        title: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: VersusColors.primary,
              child: const Text(
                'AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'AI 피클',
              style: VersusTextStyles.headingMedium.copyWith(
                color: VersusColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          if (_isSearching)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isSearching = false;
                  _searchQuery = '';
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true;
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              // Handle scroll events
              if (notification is ScrollUpdateNotification) {
                _onScroll();
              }
              return false;
            },
            child: Chat(
              currentUserId: _currentUserId,
              resolveUser: _resolveUser,
              chatController: _chatController,
              theme: _buildChatTheme(),
              onMessageSend: _handleSendPressed,
              onAttachmentTap: _handleAttachmentPressed,
              builders: core.Builders(
                chatAnimatedListBuilder: (context, itemBuilder) {
                  return ChatAnimatedListReversed(
                    itemBuilder: itemBuilder,
                  );
                },
                composerBuilder: _isSearching
                    ? (context) => _buildSearchInput()
                    : null,
                customMessageBuilder: _buildCustomMessage,
                emptyChatListBuilder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: VersusColors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'AI 피클과 대화를 시작해보세요',
                          style: VersusTextStyles.headingMedium.copyWith(
                            color: VersusColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '질문을 입력하면 AI가 답변해드립니다',
                          style: VersusTextStyles.bodyMedium.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                systemMessageBuilder: _buildSystemMessage,
              ),
            ),
          ),
          
          // Loading indicator at top when loading more
          if (_isLoadingMore)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 40,
                color: VersusColors.backgroundSecondary.withValues(alpha: 0.9),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
          
          // FAB for scroll to bottom
          if (_showFab)
            Positioned(
              bottom: 80,
              right: 16,
              child: ScaleTransition(
                scale: _fabScaleAnimation,
                child: AnimatedBuilder(
                  animation: _fabBounceAnimation,
                  builder: (context, child) => Transform.scale(
                    scale: _fabBounceAnimation.value,
                    child: FloatingActionButton(
                      mini: true,
                      backgroundColor: VersusColors.primary,
                      onPressed: _scrollToBottom,
                      child: const Icon(
                        Icons.arrow_downward,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}