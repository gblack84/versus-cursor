import 'package:flutter/material.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/core/app_utils.dart';
import '/design_system/design_system.dart';
import '/pages/chat/chat_detail/chat_detail_widget.dart';

class ChatListWidget extends StatefulWidget {
  const ChatListWidget({Key? key}) : super(key: key);

  static String routeName = 'chat_list';
  static String routePath = '/chat/list';

  @override
  State<ChatListWidget> createState() => _ChatListWidgetState();
}

class _ChatListWidgetState extends State<ChatListWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Text(
          '채팅',
          style: VersusTextStyles.headingSmall.copyWith(
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.add_comment_outlined,
              color: Colors.black,
              size: 24.0,
            ),
            onPressed: () {
              // 새 채팅 시작
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('새 채팅 시작 기능은 준비 중입니다.')),
              );
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: StreamBuilder<List<ChatsModel>>(
          stream: queryChatsModel(
            queryBuilder: (chatsRecord) => chatsRecord
                .where('participantlds', arrayContains: currentUserUid)
                .orderBy('last_message_at', descending: true),
          ),
          builder: (context, snapshot) {
            // 로딩 중
            if (!snapshot.hasData) {
              return Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      VersusColors.primary,
                    ),
                  ),
                ),
              );
            }

            final chats = snapshot.data!;

            if (chats.isEmpty) {
              return _buildEmptyState();
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatItem = chats[index];
                return _buildChatItem(chatItem);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: VersusColors.textSecondary,
          ),
          VersusSpacing.gapMD,
          Text(
            '아직 채팅이 없습니다',
            style: VersusTextStyles.headingMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
          VersusSpacing.gapSM,
          Text(
            '투표 요청을 보내거나 받으면\n채팅이 시작됩니다',
            textAlign: TextAlign.center,
            style: VersusTextStyles.bodyMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(ChatsModel chat) {
    // AI 채팅방인지 확인
    final isAIChat = chat.participantlds.contains('ai_assistant') || 
                     chat.chatType == 'ai_chat';
    
    return InkWell(
      onTap: () {
        // 채팅 상세 페이지로 이동
        context.pushNamed(
          ChatDetailWidget.routeName,
          extra: <String, dynamic>{
            'chatDocument': chat,
            kTransitionInfoKey: TransitionInfo(
              hasTransition: true,
              transitionType: PageTransitionType.rightToLeft,
            ),
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: VersusColors.borderLight,
              width: 1.0,
            ),
          ),
        ),
        child: Padding(
          padding: VersusSpacing.paddingMD,
          child: Row(
            children: [
              // 프로필 이미지 또는 아바타
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isAIChat 
                      ? Colors.purple.withValues(alpha: 0.1)  // AI 채팅방은 보라색 배경
                      : VersusColors.primaryWithAlpha(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isAIChat ? Icons.smart_toy : Icons.person,  // AI는 로봇 아이콘
                    color: isAIChat ? Colors.purple : VersusColors.primary,
                    size: 28,
                  ),
                ),
              ),
              VersusSpacing.gapH(VersusSpacing.sm),
              // 채팅 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAIChat
                              ? 'AI 피클'  // AI 채팅방 이름
                              : (chat.chatName.isNotEmpty 
                                  ? chat.chatName 
                                  : '채팅'),
                          style: VersusTextStyles.buttonMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        if (chat.hasLastMessageAt())
                          Text(
                            _formatTime(chat.lastMessageAt!),
                            style: VersusTextStyles.labelSmall.copyWith(
                              color: VersusColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    VersusSpacing.gapXS,
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chat.lastMessageContent,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: VersusTextStyles.bodySmall.copyWith(
                              color: VersusColors.textSecondary,
                            ),
                          ),
                        ),
                        // 읽지 않은 메시지 표시
                        if (!chat.isRead)
                          Container(
                            margin: EdgeInsets.only(left: VersusSpacing.sm),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: VersusColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return '어제';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}일 전';
      } else {
        return DateFormat('MM/dd').format(dateTime);
      }
    } else if (difference.inHours > 0) {
      return '${difference.inHours}시간 전';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}분 전';
    } else {
      return '방금 전';
    }
  }
}