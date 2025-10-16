import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/domain/entities/chat.dart';
import '/features/profile/domain/models/user_profile.dart';
import '/features/voting/presentation/widgets/chat_card/vote_card_message.dart';
import '/features/chat/domain/enums/message_delivery_status.dart';

/// 메시지 빌더 컴포넌트
///
/// 다양한 메시지 타입을 렌더링하는 로직을 담당합니다.
class ChatMessageBuilder {
  /// 커스텀 메시지 빌드 (VoteCard 등)
  static Widget buildCustomMessage(
    BuildContext context,
    core.CustomMessage message,
    int index, {
    required bool isSentByMe,
    core.MessageGroupStatus? groupStatus,
    Chat? chatDocument,
    UserProfile? currentUserRecord,
    String? searchQuery,
    bool isSearching = false,
    MessageDeliveryStatus? messageStatus,
  }) {
    final metadata = message.metadata ?? {};

    // Check if this is a vote message
    if (metadata['type'] == 'voteRequest' ||
        metadata['type'] == 'voteCreated') {
      // Build vote card
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
          optionAImages:
              (metadata['optionAImages'] as List<dynamic>?)?.cast<String>(),
          optionBImages:
              (metadata['optionBImages'] as List<dynamic>?)?.cast<String>(),
          aspectRatioA: metadata['aspectRatioA'],
          aspectRatioB: metadata['aspectRatioB'],
          cardStatus: metadata['cardStatus'] ?? 'votingRequest',
          voteEndTime: metadata['voteEndTime'] != null
              ? (metadata['voteEndTime'] is DateTime
                  ? metadata['voteEndTime']
                  : metadata['voteEndTime'].toDate())
              : null,
          userVotes: metadata['userVotes'],
          voteResults: metadata['voteResults'],
          isMe: isSentByMe,
          messageType: metadata['type'] ?? 'voteRequest',
          messageId: message.id,
          chatId: chatDocument?.id,
          currentUserName: currentUserRecord?.displayName ?? '사용자',
          senderDisplayName: metadata['authorName'] ?? '사용자',
          senderProfileImageUrl: metadata['authorPhotoUrl'],
          senderId: message.authorId, // 추가: 메시지 작성자 ID 전달
          showSenderProfile: true,
          searchQuery: isSearching ? searchQuery : null,
          timestamp: message.createdAt,
        ),
      );

      // Wrap with bubble container including time and status
      return Container(
        alignment: isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
        padding: EdgeInsets.only(
          left: isSentByMe ? 50 : 8,
          right: isSentByMe ? 16 : 50,
          bottom: 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // AI 프로필 이미지 추가 (AI가 보낸 메시지일 때만)
            if (!isSentByMe && message.authorId == 'ai_assistant') ...[
              Container(
                margin: const EdgeInsets.only(right: 8, bottom: 20),
                child: CircleAvatar(
                  radius: 16,
                  backgroundImage: const NetworkImage(
                      'https://picsum.photos/seed/ai_assistant/200'),
                  backgroundColor: VersusColors.primary,
                  child: const Text(
                    'AI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: isSentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
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
                        if (!isSentByMe && messageStatus != null) ...[
                          buildStatusIcon(messageStatus),
                          const SizedBox(width: 4),
                        ],
                        // Timestamp
                        if (message.createdAt != null)
                          Text(
                            formatMessageTime(message.createdAt!),
                            style: VersusTextStyles.labelSmall.copyWith(
                              fontSize: 12, // 10 → 12로 크기 증가
                              color: VersusColors.textPrimary, // 진한 색상으로 변경
                            ),
                          ),
                      ],
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

  /// 시스템 메시지 빌드 (날짜 헤더, 읽지 않은 메시지 구분선 등)
  static Widget buildSystemMessage(
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

  /// 메시지 상태 아이콘 빌드
  static Widget buildStatusIcon(MessageDeliveryStatus status) {
    IconData iconData;
    Color color;
    double size = 14;

    switch (status) {
      case MessageDeliveryStatus.sent:
        iconData = Icons.done;
        color = VersusColors.textSecondary.withValues(alpha: 0.5);
      case MessageDeliveryStatus.delivered:
        iconData = Icons.done_all;
        color = VersusColors.textSecondary.withValues(alpha: 0.7);
      case MessageDeliveryStatus.seen:
        iconData = Icons.done_all;
        color = VersusColors.primary;
      case MessageDeliveryStatus.unknown:
        iconData = Icons.access_time;
        color = VersusColors.textSecondary.withValues(alpha: 0.5);
    }

    return Icon(
      iconData,
      size: size,
      color: color,
    );
  }

  /// 메시지 시간 포맷팅
  static String formatMessageTime(DateTime timestamp) {
    // AM/PM 형식으로 고정 시간 표시
    return DateFormat('h:mm a').format(timestamp);
    // 예: "3:30 PM", "9:45 AM"
  }
}
