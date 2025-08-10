import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';
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

class _ChatDetailWidgetV2State extends State<ChatDetailWidgetV2> {
  late ChatDetailControllerV2 _chatController;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Services
  final _lifecycleService = ChatMessageLifecycleService();
  final _fileSizeService = ChatFileSizeService();
  
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
  
  // AI chat detection
  bool get isAiChat => 
    widget.chatDocument?.chatName == 'AI 피클' ||
    (widget.chatDocument?.reference.id.startsWith('ai_assistant_') ?? false);

  @override
  void initState() {
    super.initState();
    _chatController = ChatDetailControllerV2();
    _initializeChat();
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _messageStatusSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    // Initialize current user - 더 강력한 에러 처리
    try {
      if (currentUserReference != null) {
        final currentUserDoc = await currentUserReference!.get();
        if (currentUserDoc.exists) {
          final currentUserRecord = UsersModel.fromSnapshot(currentUserDoc);
          _currentUserRecord = currentUserRecord;
          
          print('User loaded: ${currentUserRecord.displayName}'); // 디버그
          
          _currentUser = core.User(
            id: currentUserUid.isNotEmpty ? currentUserUid : 'anonymous',
            name: currentUserRecord.displayName ?? '사용자', // 기본값 추가
            imageSource: currentUserRecord.photoUrl,
          );
          
          _usersCache[_currentUser!.id] = _currentUser!;
        } else {
          print('User document does not exist'); // 디버그
          _createDefaultUser();
        }
      } else {
        print('currentUserReference is null'); // 디버그
        _createDefaultUser();
      }
    } catch (e) {
      print('Error loading user: $e'); // 디버그
      _createDefaultUser();
    }
    
    // Load chat participants
    if (widget.chatDocument != null) {
      await _loadChatParticipants();
      
      // Mark messages as seen when opening chat
      if (_currentUser != null) {
        await _lifecycleService.markMessagesAsSeen(
          chatId: widget.chatDocument!.reference.id,
          currentUserId: _currentUser!.id,
        );
      }
    }
    
    // Start listening to messages
    _listenToMessages();
    
    // Start listening to message status changes
    if (widget.chatDocument != null) {
      _listenToMessageStatuses();
    }
    
    setState(() {
      _isLoadingUsers = false;
    });
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
  
  void _listenToMessages() {
    if (widget.chatDocument == null) return;
    
    _messageSubscription = widget.chatDocument!.reference
        .collection('messages')
        .orderBy('time_stamp', descending: false)  // Get oldest first
        .limit(100)
        .snapshots()
        .listen((snapshot) {
      _processMessages(snapshot);
    });
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
  
  Future<void> _processMessages(QuerySnapshot snapshot) async {
    final messages = <core.Message>[];
    
    for (final doc in snapshot.docs) {
      final messageModel = MessagesModel.fromSnapshot(doc);
      final messageData = doc.data() as Map<String, dynamic>?;
      
      // Convert to core.Message (now async for file size calculation)
      final coreMessage = await ChatDetailMigrationService.convertFirestoreToCore(
        messageModel,
        messageData,
        {},
      );
      
      messages.add(coreMessage);
    }
    
    // 날짜별 구분선을 위해 메시지 사이에 시스템 메시지 추가
    final messagesWithDateHeaders = _addDateHeaders(messages);
    
    // flutter_chat_ui uses reverse: false internally
    // First message in list appears at top, last at bottom
    // Since Firestore returns oldest first, oldest will be at top, newest at bottom ✅
    
    // Update controller with new messages
    _chatController.setMessages(messagesWithDateHeaders);
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
      final voteCard = VoteCardMessage(
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
                : double.tryParse(metadata['aspectRatioA'].toString()) ?? 1.0)
            : 1.0,
        aspectRatioB: metadata['aspectRatioB'] != null 
            ? (metadata['aspectRatioB'] is double 
                ? metadata['aspectRatioB'] 
                : double.tryParse(metadata['aspectRatioB'].toString()) ?? 1.0)
            : 1.0,
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
  
  /// Build system message (date headers)
  Widget _buildSystemMessage(
    BuildContext context,
    core.SystemMessage message,
    int index, {
    core.MessageGroupStatus? groupStatus,
    bool isSentByMe = false,
  }) {
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
            child: Chat(
              currentUserId: _currentUser?.id ?? 'anonymous',
              resolveUser: _resolveUser,
              chatController: _chatController,
              theme: _buildChatTheme(),
              timeFormat: DateFormat('HH:mm'), // 시간만 표시 (15:30 형식)
              onMessageSend: isAiChat ? null : _handleSendPressed,
              onAttachmentTap: isAiChat ? null : _handleAttachmentPressed,
              builders: core.Builders(
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
        ],
      ),
    );
  }
}