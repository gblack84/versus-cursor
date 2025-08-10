import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/design_system/design_system.dart';
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/chat/vote_card_message.dart';
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

class _AIChatPageV2State extends State<AIChatPageV2> {
  late final AIChatController _chatController;
  late final String _currentUserId;
  
  // User cache for resolveUser
  final Map<String, core.User> _usersCache = {};
  
  // Search state
  String _searchQuery = '';
  bool _isSearching = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize chat controller
    _chatController = AIChatController();
    
    // Get current user ID
    _currentUserId = currentUserUid.isNotEmpty ? currentUserUid : 'anonymous';
    
    // Initialize AI with API key (you need to set this)
    // TODO: Get API key from environment or Firebase Remote Config
    // _chatController.initializeAI('YOUR_GEMINI_API_KEY');
    
    // Load existing messages if any
    _loadMessages();
  }
  
  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }
  
  /// Load existing messages from Firestore
  Future<void> _loadMessages() async {
    if (widget.aiChatId == null) return;
    
    // TODO: Load messages from Firestore and convert them
    // This would be similar to the existing chat_detail implementation
  }
  
  /// Resolve user from ID
  Future<core.User?> _resolveUser(String userId) async {
    // Check cache first
    if (_usersCache.containsKey(userId)) {
      return _usersCache[userId];
    }
    
    // Special case for AI assistant
    if (userId == AIChatController.aiUserId) {
      final aiUser = const core.User(
        id: AIChatController.aiUserId,
        name: AIChatController.aiUserName,
        imageSource: 'https://picsum.photos/seed/ai_assistant/200',
      );
      _usersCache[userId] = aiUser;
      return aiUser;
    }
    
    // Special case for current user
    if (userId == _currentUserId) {
      final currentUser = core.User(
        id: _currentUserId,
        name: currentUserDisplayName.isNotEmpty ? currentUserDisplayName : 'User',
        imageSource: currentUserPhoto,
      );
      _usersCache[userId] = currentUser;
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
        _usersCache[userId] = user;
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
      return VoteCardMessage(
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
      body: Chat(
        currentUserId: _currentUserId,
        resolveUser: _resolveUser,
        chatController: _chatController,
        theme: _buildChatTheme(),
        onMessageSend: _handleSendPressed,
        onAttachmentTap: _handleAttachmentPressed,
        builders: core.Builders(
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
        ),
      ),
    );
  }
}