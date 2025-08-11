import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:uuid/uuid.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:bot_toast/bot_toast.dart';
import '/core/app_utils.dart';
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/chat/vote_card_message.dart';
import '/pages/chat/services/chat_message_lifecycle_service.dart';
import '/pages/chat/services/chat_file_size_service.dart';
import '/services/unified_image_cache_service.dart';
import 'chat_detail_migration_service.dart';
import 'chat_detail_controller_v2.dart';

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
  final _fileSizeService = ChatFileSizeService();
  
  // Animation controllers
  late AnimationController _fabAnimationController;
  late Animation<double> _fabBounceAnimation;
  late AnimationController _fabScaleController;
  late Animation<double> _fabScaleAnimation;
  
  // User management
  core.User? _currentUser;
  UsersModel? _currentUserRecord;
  final Map<String, core.User> _usersCache = {};
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
  static const int _initialMessageLimit = 50;
  static const int _messagePageSize = 30;
  bool _hasMoreMessages = true;
  bool _isLoadingMore = false;
  bool _skipInitialSnapshot = true;  // 스트림의 첫 스냅샷 스킵
  
  // Initial loading state
  bool _isInitialLoading = true;
  
  // Bootstrap and scroll management
  bool _bootstrapped = false;
  bool _initialMessagesSet = false;  // Track if initial messages have been set
  bool _isAtBottom = false;  // 초기값 false - 스크롤 후 true로 변경
  bool _isNearBottom = false;  // 초기값 false - 스크롤 후 true로 변경
  DocumentSnapshot? _anchorDocument;
  DocumentSnapshot? _lastLoadedDocument;  // 마지막 로드된 문서 참조 (커서용)
  DateTime? _lastLoadedTimestamp;  // 마지막 로드된 메시지의 타임스탬프
  ScrollController? _scrollController;
  
  // AI chat detection
  bool get isAiChat => 
    widget.chatDocument?.chatName == 'AI 피클' ||
    (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);

  @override
  void initState() {
    super.initState();
    _chatController = ChatDetailControllerV2();
    
    // Initialize animation controllers
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _fabScaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabScaleController,
      curve: Curves.easeInOut,
    ));
    
    _bootstrap();  // Changed from _initializeChat to _bootstrap
  }

  @override
  void dispose() {
    // Update last read timestamp when leaving chat
    _updateLastReadAt();
    
    _messageSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chatController.dispose();
    _scrollController?.dispose();
    _fabAnimationController.dispose();
    _fabScaleController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    // 1. Load user info
    await _loadUserInfo();
    
    // 3. Load initial messages with get() - not stream
    if (widget.chatDocument == null) {
      setState(() {
        _isInitialLoading = false;
        _bootstrapped = true;
      });
      return;
    }
    
    Query<Map<String, dynamic>> initialQuery = widget.chatDocument!.reference
        .collection('messages')
        .orderBy('time_stamp', descending: false);
    
    // Load latest messages
    debugPrint('[Chat Detail] Loading initial messages...');
    final initialSnapshot = await initialQuery.limitToLast(_initialMessageLimit).get();
      
    if (initialSnapshot.docs.isEmpty) {
      debugPrint('[Chat Detail] No initial messages found');
      setState(() {
        _isInitialLoading = false;
        _bootstrapped = true;
        _isLoadingUsers = false;
      });
      return;
    }
    
    debugPrint('[Chat Detail] Loaded ${initialSnapshot.docs.length} initial messages');
    debugPrint('[Chat Detail] First doc ID: ${initialSnapshot.docs.first.id}');
    debugPrint('[Chat Detail] Last doc ID: ${initialSnapshot.docs.last.id}');
    
    // Convert messages
    final messages = <core.Message>[];
    for (final doc in initialSnapshot.docs) {
      final message = await _convertDocToMessage(doc);
      messages.add(message);
      debugPrint('[Chat Detail] Converted message: ${message.id}');
    }
    
    // Add date headers and set messages - only once
    // Flutter Chat UI v2 expects messages in chronological order (oldest first)
    if (!_initialMessagesSet) {
      final messagesWithHeaders = _addDateHeaders(messages);
      _chatController.setMessages(messagesWithHeaders);
      _initialMessagesSet = true;
    }
    
    _anchorDocument = initialSnapshot.docs.last;
    _lastLoadedDocument = initialSnapshot.docs.last;  // 커서 저장
    
    // 마지막 메시지의 타임스탬프 저장
    final lastDoc = initialSnapshot.docs.last;
    final lastTimestamp = lastDoc.data();
    if (lastTimestamp['time_stamp'] != null) {
      _lastLoadedTimestamp = (lastTimestamp['time_stamp'] as Timestamp).toDate();
      debugPrint('[Chat Detail] Last loaded timestamp: $_lastLoadedTimestamp');
    }
    
    // 4. Set initial loading complete
    setState(() {
      _isInitialLoading = false;
      _isLoadingUsers = false;
    });
    
    // 5. Reversed List 사용으로 자동으로 최신 메시지가 하단에 표시됨
    // 초기 스크롤 불필요
    _isAtBottom = true;  // Enable auto-scroll for new messages
    _isNearBottom = true;
    
    
    // 7. Update last read timestamp
    await _updateLastReadAt();
    
    // 8. Bootstrap complete, start incremental stream with a small delay
    _bootstrapped = true;
    Future.delayed(const Duration(milliseconds: 100), () {
      _startIncrementalStream();
    });
    
    // 8. Start listening to message status changes
    if (widget.chatDocument != null) {
      _listenToMessageStatuses();
    }
    
    // 9. Mark messages as seen
    await _markMessagesAsSeen();
    
    // 11. Mark messages as seen
    if (_currentUser != null && widget.chatDocument != null) {
      await _lifecycleService.markMessagesAsSeen(
        chatId: widget.chatDocument!.reference.id,
        currentUserId: _currentUser!.id,
      );
    }
  }
  
  Future<void> _loadUserInfo() async {
    // Initialize current user - more robust error handling
    try {
      // Always try to fetch from Users collection for consistency
      if (currentUserUid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUserUid)
            .get();
            
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          _currentUserRecord = UsersModel.fromSnapshot(userDoc);
          
          // Use multiple fallbacks for display name
          final displayName = userData['display_name'] ?? 
                             userData['handle'] ?? 
                             userData['email']?.split('@')[0] ?? 
                             '사용자';
          
          _currentUser = core.User(
            id: currentUserUid,
            name: displayName.toString().isNotEmpty ? displayName.toString() : '사용자',
            imageSource: userData['photo_url'],
          );
          
          _usersCache[_currentUser!.id] = _currentUser!;
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
    
    // Load chat participants
    if (widget.chatDocument != null) {
      await _loadChatParticipants();
    }
  }
  
  
  
  Future<void> _updateLastReadAt() async {
    if (widget.chatDocument == null || _currentUser == null) return;
    
    final lifecycleService = ChatMessageLifecycleService();
    await lifecycleService.updateLastReadAt(
      chatId: widget.chatDocument!.reference.id,
      userId: _currentUser!.id,
    );
  }
  
  Future<void> _markMessagesAsSeen() async {
    if (widget.chatDocument == null || _currentUser == null) return;
    
    final lifecycleService = ChatMessageLifecycleService();
    await lifecycleService.markMessagesAsSeen(
      chatId: widget.chatDocument!.reference.id,
      currentUserId: _currentUser!.id,
    );
  }
  
  Future<core.Message> _convertDocToMessage(DocumentSnapshot doc) async {
    final messageModel = MessagesModel.fromSnapshot(doc);
    final messageData = doc.data() as Map<String, dynamic>?;
    
    return await ChatDetailMigrationService.convertFirestoreToCore(
      messageModel,
      messageData,
      {},
    );
  }
  
  void _createDefaultUser() {
    _currentUser = core.User(
      id: currentUserUid.isNotEmpty ? currentUserUid : 'anonymous',
      name: '사용자',
    );
    _usersCache[_currentUser!.id] = _currentUser!;
    // 기본 UserRecord는 null로 유지 (displayName이 없어도 '사용자'로 표시됨)
  }
  
  Future<void> _loadChatParticipants() async {
    final participantIds = widget.chatDocument!.participantIds;
    
    for (final userId in participantIds) {
      if (userId.isEmpty) continue;
      
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          final userModel = UsersModel.fromSnapshot(userDoc);
          final coreUser = ChatDetailMigrationService.convertUsersModelToCore(userModel);
          _usersCache[userId] = coreUser;
        }
      } catch (e) {
        debugPrint('Error loading user $userId: $e');
      }
    }
  }
  
  void _startIncrementalStream() {
    if (!_bootstrapped || widget.chatDocument == null) return;
    
    // Reset skip flag for new stream
    _skipInitialSnapshot = true;
    
    Query query = widget.chatDocument!.reference
        .collection('messages')
        .orderBy('time_stamp', descending: false);
    
    // 커서 기반 필터링 - 초기 로드된 메시지 이후만 스트리밍
    if (_lastLoadedDocument != null) {
      query = query.startAfterDocument(_lastLoadedDocument!);
      debugPrint('[Chat Detail Stream] Starting stream after document: ${_lastLoadedDocument!.id}');
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
    
    switch (change.type) {
      case DocumentChangeType.added:
        // Add new message
        _chatController.insertMessage(message);
        
        // 새 메시지를 마지막 문서로 업데이트
        _lastLoadedDocument = change.doc;
        
        // Show FAB and animate if not at bottom and not from current user
        if (!_isAtBottom && message.authorId != _currentUser?.id) {
          // Trigger FAB animation
          if (!_fabScaleController.isAnimating && _fabScaleController.value == 0) {
            _fabScaleController.forward();
          }
          
          // Bounce animation for new message
          _fabAnimationController.forward().then((_) {
            _fabAnimationController.reverse();
          });
          
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
        break;
        
      case DocumentChangeType.removed:
        // Remove message
        final toRemove = _chatController.messages
            .firstWhere((m) => m.id == message.id, orElse: () => message);
        _chatController.removeMessage(toRemove);
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
      // Save current top message as anchor for scroll position preservation
      final anchorMessageId = _chatController.messages.isNotEmpty 
          ? _chatController.messages.first.id 
          : null;
      
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
      
      // Convert older messages
      final olderMessages = <core.Message>[];
      for (final doc in snapshot.docs) {
        final message = await _convertDocToMessage(doc);
        olderMessages.add(message);
      }
      
      // Merge with existing messages
      // Chat UI v2 expects chronological order (oldest first)
      final currentMessages = _chatController.messages.toList();
      olderMessages.addAll(currentMessages);  // Add newer messages after older ones
      
      // Update with date headers
      final messagesWithHeaders = _addDateHeaders(olderMessages);
      _chatController.setMessages(messagesWithHeaders);
      
      // Restore scroll position to anchor message
      if (anchorMessageId != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _chatController.scrollToMessage(anchorMessageId);
        });
      }
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
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }
    
    // Special case for AI assistant
    if (userId == 'ai_assistant') {
      final aiUser = const core.User(
        id: 'ai_assistant',
        name: 'AI 피클',
        imageSource: 'https://picsum.photos/seed/ai_assistant/200',
      );
      _usersCache[userId] = aiUser;
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
        _usersCache[userId] = coreUser;
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
  
  /// Handle sending a media message with file size calculation
  Future<void> _handleSendMediaMessage({
    required String mediaUrl,
    required String mediaType,
    String? localPath,
  }) async {
    if (widget.chatDocument == null) return;
    
    final messageId = const Uuid().v4();
    
    // Calculate file size
    int fileSize = 0;
    if (localPath != null) {
      fileSize = await _fileSizeService.getLocalFileSize(localPath);
    } else if (mediaUrl.isNotEmpty) {
      fileSize = await _fileSizeService.calculateMediaSize(mediaUrl);
    }
    
    // Create message in Firestore with media fields
    await MessagesModel.createDoc(widget.chatDocument!.reference)
        .set(createMessagesModelData(
      messageId: messageId,
      content: '',
      senderId: currentUserUid,
      timeStamp: getCurrentTimestamp(),
      mediaType: mediaType,
      imageUrl: mediaType == 'image' ? mediaUrl : '',
      videoUrl: mediaType == 'video' ? mediaUrl : '',
      mediaSize: fileSize,
    ));
    
    // Update chat metadata
    await widget.chatDocument!.reference.update({
      ...createChatsModelData(
        lastMessageContent: mediaType == 'image' ? '📷 사진' : '📹 비디오',
        lastMessageAt: getCurrentTimestamp(),
      ),
      'participantIds': FieldValue.arrayUnion([currentUserUid]),
    });
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
    try {
      // Pick assets using wechat_assets_picker
      final List<AssetEntity>? selectedAssets = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 10,
          requestType: RequestType.common,
          specialPickerType: SpecialPickerType.noPreview,
          pickerTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: VersusColors.primary,
            scaffoldBackgroundColor: Colors.black,
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );

      if (selectedAssets != null && selectedAssets.isNotEmpty) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
            ),
          ),
        );
        
        for (final asset in selectedAssets) {
          await _uploadAndSendAsset(asset);
        }
        
        Navigator.of(context).pop(); // Hide loading
      }
    } catch (e) {
      debugPrint('Error picking media from gallery: $e');
      BotToast.showText(text: '갤러리에서 미디어를 선택하는 중 오류가 발생했습니다.');
    }
  }
  
  Future<void> _pickMediaFromCamera() async {
    try {
      // Pick from camera using wechat_camera_picker
      final AssetEntity? pickedAsset = await CameraPicker.pickFromCamera(
        context,
        pickerConfig: const CameraPickerConfig(
          enableRecording: true,
          maximumRecordingDuration: Duration(seconds: 60),
        ),
      );

      if (pickedAsset != null) {
        // Show loading indicator
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(VersusColors.primary),
            ),
          ),
        );
        await _uploadAndSendAsset(pickedAsset);
        Navigator.of(context).pop(); // Hide loading
      }
    } catch (e) {
      debugPrint('Error picking media from camera: $e');
      BotToast.showText(text: '카메라에서 미디어를 촬영하는 중 오류가 발생했습니다.');
    }
  }

  /// Upload asset to Firebase Storage and send as message
  Future<void> _uploadAndSendAsset(AssetEntity asset) async {
    try {
      // Get file from asset
      final File? file = await asset.file;
      if (file == null) return;

      // Determine media type
      final bool isVideo = asset.type == AssetType.video;
      final String mediaType = isVideo ? 'video' : 'image';
      
      // Generate unique filename
      final String fileName = '${const Uuid().v4()}.${file.path.split('.').last}';
      final String storagePath = 'chat_media/${widget.chatDocument!.reference.id}/$fileName';
      
      // Upload to Firebase Storage
      final Reference storageRef = FirebaseStorage.instance.ref().child(storagePath);
      final UploadTask uploadTask = storageRef.putFile(file);
      
      // Get download URL
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();
      
      // Send media message
      await _handleSendMediaMessage(
        mediaUrl: downloadUrl,
        mediaType: mediaType,
        localPath: file.path,
      );
    } catch (e) {
      debugPrint('Error uploading asset: $e');
      BotToast.showText(text: '미디어 업로드 중 오류가 발생했습니다.');
    }
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
      // 디버그 로그
      print('Vote message metadata:');
      print('  cardStatus: ${metadata['cardStatus']}');
      print('  voteResults: ${metadata['voteResults']}');
      
      // Preload images for vote message
      final List<String> imageUrlsA = metadata['optionAImages'] != null 
          ? List<String>.from(metadata['optionAImages']) 
          : (metadata['optionAImage'] != null ? [metadata['optionAImage'] as String] : <String>[]);
      final List<String> imageUrlsB = metadata['optionBImages'] != null 
          ? List<String>.from(metadata['optionBImages']) 
          : (metadata['optionBImage'] != null ? [metadata['optionBImage'] as String] : <String>[]);
      
      // Preload images using UnifiedImageCacheService
      if (imageUrlsA.isNotEmpty || imageUrlsB.isNotEmpty) {
        UnifiedImageCacheService.instance.preloadVoteMessageImages(
          context,
          imageUrlsA: imageUrlsA,
          imageUrlsB: imageUrlsB,
        );
      }
      
      // Get message status for read indicators
      final messageStatus = _getMessageStatus(message.id);
      
      // Build the vote card with bubble wrapper
      // Wrap with KeyedSubtree to preserve scroll position during rebuilds
      final voteCard = KeyedSubtree(
        key: ValueKey(message.id),
        child: VoteCardMessage(
          postId: metadata['postId'] ?? '',
          title: metadata['title'] ?? '',
          description: metadata['description'],
          optionAText: metadata['optionAText'] ?? '',
          optionBText: metadata['optionBText'] ?? '',
          optionAImage: metadata['optionAImage'],
          optionBImage: metadata['optionBImage'],
          optionAImages: metadata['optionAImages'] != null 
              ? List<String>.from(metadata['optionAImages']) 
              : null,
          optionBImages: metadata['optionBImages'] != null 
              ? List<String>.from(metadata['optionBImages']) 
              : null,
          aspectRatioA: metadata['aspectRatioA'] != null 
              ? (metadata['aspectRatioA'] is double 
                  ? metadata['aspectRatioA'] 
                  : double.tryParse(metadata['aspectRatioA'].toString()))
              : null,  // null 유지하여 fallback 로직 활성화
          aspectRatioB: metadata['aspectRatioB'] != null 
              ? (metadata['aspectRatioB'] is double 
                  ? metadata['aspectRatioB'] 
                  : double.tryParse(metadata['aspectRatioB'].toString()))
              : null,  // null 유지하여 fallback 로직 활성화
          cardStatus: metadata['cardStatus'] ?? 'voting_request',  // Firebase의 card_status 사용
          voteEndTime: metadata['voteEndTime'] != null 
              ? (metadata['voteEndTime'] is DateTime 
                  ? metadata['voteEndTime'] 
                  : metadata['voteEndTime'].toDate())
              : null,
          userVotes: metadata['userVotes'],
          voteResults: metadata['voteResults'],  // 이미 올바른 형식으로 변환됨
          isMe: isSentByMe,
          messageType: metadata['type'] ?? 'vote_request',
          messageId: message.id,
          chatId: widget.chatDocument?.reference.id,
          currentUserName: _currentUserRecord?.displayName ?? '사용자',
          senderDisplayName: metadata['authorName'] ?? '사용자',  // 작성자 이름 추가
          senderProfileImageUrl: metadata['authorPhotoUrl'],  // 작성자 프로필 이미지 추가
          showSenderProfile: true,  // 프로필 표시 활성화
          searchQuery: _isSearching ? _searchQuery : null,
          timestamp: message.createdAt,  // 타임스탬프 추가
        ),
      );
      
      // Wrap with bubble container including time and status
      return Container(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: isSentByMe ? 50 : 16,
          right: isSentByMe ? 16 : 50,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: isSentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VersusColors.backgroundSecondary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isSentByMe ? 18 : 4),
                  bottomRight: Radius.circular(isSentByMe ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: voteCard,
            ),
            // Time and status row
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 8, right: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 받은 메시지에 읽음 상태 표시
                  if (!isSentByMe) ...[
                    _buildStatusIcon(messageStatus),
                    const SizedBox(width: 4),
                  ],
                  // Timestamp
                  if (message.createdAt != null)
                    Text(
                      _formatMessageTime(message.createdAt!),
                      style: VersusTextStyles.labelSmall.copyWith(
                        fontSize: 10,
                        color: VersusColors.textSecondary.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    
    // Default for unknown custom messages
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.md),
      child: Text(
        'Custom message: ${metadata['type'] ?? 'unknown'}',
        style: VersusTextStyles.bodyMedium,
      ),
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
    if (query.isEmpty) return;
    
    setState(() {
      _searchResults = _chatController.searchMessages(query);
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
  
  /// Build AI search input with KakaoTalk-style navigation
  Widget _buildAISearchInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: VersusColors.backgroundSecondary,
      child: Row(
        children: [
          // Search field
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: VersusColors.backgroundPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  // Search icon
                  Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: Icon(
                      Icons.search,
                      color: VersusColors.textSecondary,
                      size: 20,
                    ),
                  ),
                  // Text field
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _searchFocusNode,
                      onSubmitted: _performSearch,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        if (value.isEmpty) {
                          setState(() {
                            _searchResults = [];
                            _currentSearchIndex = 0;
                          });
                        }
                      },
                      style: VersusTextStyles.bodyMedium,
                      decoration: InputDecoration(
                        hintText: '검색',
                        hintStyle: VersusTextStyles.bodyMedium.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  // Search result counter
                  if (_searchResults.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '${_currentSearchIndex + 1}/${_searchResults.length}',
                        style: VersusTextStyles.bodySmall.copyWith(
                          color: VersusColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  // Navigation arrows
                  if (_searchResults.isNotEmpty) ...[
                    // Previous button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_upward,
                        color: VersusColors.textSecondary,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => _navigateToSearchResult(false),
                    ),
                    // Next button
                    IconButton(
                      icon: Icon(
                        Icons.arrow_downward,
                        color: VersusColors.textSecondary,
                        size: 18,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      onPressed: () => _navigateToSearchResult(true),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Close button
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.close,
              color: VersusColors.textPrimary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchResults = [];
                _currentSearchIndex = 0;
                _searchController.clear();
              });
            },
          ),
        ],
      ),
    );
  }
  
  /// Get message delivery status
  MessageDeliveryStatus _getMessageStatus(String messageId) {
    // 실시간 상태 맵에서 조회
    if (_messageStatuses.containsKey(messageId)) {
      return _messageStatuses[messageId]!;
    }
    // 기본값은 sent
    return MessageDeliveryStatus.sent;
  }
  
  /// Build status icon based on delivery status
  Widget _buildStatusIcon(MessageDeliveryStatus status) {
    IconData icon;
    Color color;
    
    switch (status) {
      case MessageDeliveryStatus.sent:
        icon = Icons.check;
        color = VersusColors.textSecondary.withValues(alpha: 0.5);
        break;
      case MessageDeliveryStatus.delivered:
        icon = Icons.done_all;
        color = VersusColors.textSecondary.withValues(alpha: 0.5);
        break;
      case MessageDeliveryStatus.seen:
        icon = Icons.done_all;
        color = VersusColors.primary;
        break;
      case MessageDeliveryStatus.unknown:
        icon = Icons.access_time;
        color = VersusColors.textSecondary.withValues(alpha: 0.3);
        break;
    }
    
    return Icon(
      icon,
      size: 14,
      color: color,
    );
  }
  
  /// Build loading indicator for initial load
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              VersusColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '메시지를 불러오는 중...',
            style: VersusTextStyles.bodyMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build loading indicator for pagination
  Widget _buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  VersusColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '이전 메시지 불러오는 중...',
              style: TextStyle(
                color: VersusColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Format message time
  String _formatMessageTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    // 항상 시간을 표시 (AM/PM 형식)
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? '오후' : '오전';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    // 오늘이면 시간만
    if (difference.inDays == 0 && 
        now.day == time.day && 
        now.month == time.month && 
        now.year == time.year) {
      return '$period $displayHour:$minute';
    } 
    // 어제면 "어제" + 시간
    else if (difference.inDays == 1 && 
             now.day - 1 == time.day && 
             now.month == time.month && 
             now.year == time.year) {
      return '어제 $period $displayHour:$minute';
    }
    // 그 외는 날짜 + 시간
    else {
      return '${time.month}/${time.day} $period $displayHour:$minute';
    }
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
      return Scaffold(
        backgroundColor: VersusColors.backgroundPrimary,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      body: Column(
        children: [
          // AppBar
          Container(
            color: VersusColors.backgroundSecondary,
            child: SafeArea(
              bottom: false,
              child: Container(
                height: 35.0,
                padding: const EdgeInsets.only(top: 5.0, bottom: 10.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: VersusColors.textPrimary,
                      width: 1.0,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: VersusColors.textPrimary,
                          size: 20.0,
                        ),
                      ),
                    ),
                    // Title
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Text(
                        widget.chatDocument?.chatName ?? '채팅',
                        style: TextStyle(
                          color: VersusColors.textPrimary,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Search button (only for AI chat)
                    if (isAiChat)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (_isSearching) {
                              _searchFocusNode.requestFocus();
                            }
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Icon(
                            _isSearching ? Icons.close : Icons.search,
                            color: VersusColors.textPrimary,
                            size: 20.0,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Chat content
          Expanded(
            child: _isInitialLoading 
              ? _buildLoadingIndicator()
              : Stack(
                  children: [
                    NotificationListener<ScrollNotification>(
                      onNotification: (notification) {
                        // Check if we've scrolled to the top (to load more messages)
                        if (notification is ScrollUpdateNotification) {
                          // Check if we're near the top
                          if (notification.metrics.pixels <= 100 &&
                              notification.metrics.pixels > 0 &&
                              !_isLoadingMore &&
                              _hasMoreMessages) {
                            _loadMoreMessages();
                          }
                          
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
                                _fabScaleController.reverse();
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
                    timeFormat: DateFormat('HH:mm'), // 시간만 표시 (15:30 형식)
                    onMessageSend: isAiChat ? null : _handleSendPressed,
                    onAttachmentTap: isAiChat ? null : _handleAttachmentPressed,
                    builders: core.Builders(
                      chatAnimatedListBuilder: (context, itemBuilder) {
                        return ChatAnimatedListReversed(
                          itemBuilder: itemBuilder,
                        );
                      },
                      composerBuilder: isAiChat && _isSearching
                          ? (context) => _buildAISearchInput()
                          : null,
                      customMessageBuilder: _buildCustomMessage,
                      systemMessageBuilder: _buildSystemMessage,
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
                          isAiChat 
                              ? 'AI 피클과 대화를 시작해보세요'
                              : '메시지를 보내서 대화를 시작하세요',
                          style: VersusTextStyles.headingMedium.copyWith(
                            color: VersusColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isAiChat
                              ? '질문을 입력하면 AI가 답변해드립니다'
                              : '첫 메시지를 보내보세요',
                          style: VersusTextStyles.bodyMedium.copyWith(
                            color: VersusColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                      ),
                    ),
                    ),
                    // Loading indicator for pagination
                    if (_isLoadingMore)
                      Positioned(
                        top: 50,
                        left: 0,
                        right: 0,
                        child: _buildLoadingMoreIndicator(),
                      ),
                    // FAB for new messages when not at bottom
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      bottom: _isAtBottom ? -100 : 16,
                      right: 16,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([
                          _fabScaleAnimation,
                          _fabBounceAnimation,
                        ]),
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _fabScaleAnimation.value * _fabBounceAnimation.value,
                            child: FloatingActionButton.extended(
                              onPressed: () {
                                // Scroll to bottom
                                _scrollToBottom();
                                _fabScaleController.reverse();
                              },
                              backgroundColor: VersusColors.primary,
                              icon: const Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                                size: 20,
                              ),
                              label: const Text(
                                '아래로',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
  
  /// Scroll to bottom of chat
  void _scrollToBottom() {
    if (_chatController.messages.isNotEmpty) {
      // flutter_chat_ui v2에서는 최신 메시지가 마지막
      final lastMessageId = _chatController.messages.last.id;
      _chatController.scrollToMessage(lastMessageId);
      setState(() {
        _isAtBottom = true;
      });
    }
  }
}