import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/design_system/design_system.dart';

/// Chat UI Adapter for V1 to V2 compatibility
/// 
/// This adapter maps legacy UI patterns to flutter_chat_ui components.
class ChatUIAdapter {
  
  /// Convert legacy chat theme to flutter_chat_ui theme
  static core.ChatTheme getLegacyChatTheme({
    bool isDarkMode = true,
    Color? primaryColor,
    Color? backgroundColor,
  }) {
    if (isDarkMode) {
      return core.ChatTheme.dark().copyWith(
        colors: core.ChatColors(
          primary: primaryColor ?? VersusColors.primary,
          onPrimary: Colors.white,
          surface: backgroundColor ?? VersusColors.backgroundPrimary,
          onSurface: VersusColors.textPrimary,
          surfaceContainer: VersusColors.backgroundSecondary,
          surfaceContainerLow: VersusColors.backgroundPrimary,
          surfaceContainerHigh: VersusColors.backgroundSecondary,
        ),
        typography: core.ChatTypography.standard(
          fontFamily: 'SourGummy',
        ),
      );
    } else {
      return core.ChatTheme.light().copyWith(
        colors: core.ChatColors(
          primary: primaryColor ?? VersusColors.primary,
          onPrimary: Colors.white,
          surface: backgroundColor ?? Colors.white,
          onSurface: Colors.black87,
          surfaceContainer: Colors.grey[100]!,
          surfaceContainerLow: Colors.white,
          surfaceContainerHigh: Colors.grey[200]!,
        ),
        typography: core.ChatTypography.standard(
          fontFamily: 'SourGummy',
        ),
      );
    }
  }
  
  /// Build legacy-style message bubble
  static Widget buildLegacyMessageBubble({
    required Widget child,
    required bool isMe,
    required DateTime timestamp,
    bool showTimestamp = true,
  }) {
    return Container(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      padding: EdgeInsets.only(
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? VersusColors.primary : VersusColors.backgroundSecondary,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
            ),
            child: child,
          ),
          if (showTimestamp)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
              child: Text(
                _formatTimestamp(timestamp),
                style: VersusTextStyles.labelSmall.copyWith(
                  color: VersusColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Build legacy-style avatar
  static Widget buildLegacyAvatar({
    required String userId,
    String? imageUrl,
    String? displayName,
    double size = 36,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: VersusColors.primaryWithAlpha(0.1),
        image: imageUrl != null && imageUrl.isNotEmpty
            ? DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageUrl == null || imageUrl.isEmpty
          ? Center(
              child: Text(
                displayName?.isNotEmpty == true 
                    ? displayName![0].toUpperCase()
                    : '?',
                style: VersusTextStyles.bodyMedium.copyWith(
                  color: VersusColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
  
  /// Build legacy-style typing indicator
  static Widget buildLegacyTypingIndicator({
    required String userName,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$userName님이 입력 중',
            style: VersusTextStyles.bodySmall.copyWith(
              color: VersusColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 20,
            height: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300 + (index * 100)),
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: VersusColors.textSecondary,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build legacy-style date separator
  static Widget buildLegacyDateSeparator(DateTime date) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: VersusColors.borderLight,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _formatDate(date),
              style: VersusTextStyles.labelSmall.copyWith(
                color: VersusColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: VersusColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build legacy-style empty chat placeholder
  static Widget buildLegacyEmptyChat({
    bool isAIChat = false,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isAIChat ? Icons.smart_toy_outlined : Icons.chat_bubble_outline,
              size: 64,
              color: VersusColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isAIChat 
                  ? 'AI 피클과 대화를 시작해보세요'
                  : '메시지를 보내서 대화를 시작하세요',
              style: VersusTextStyles.headingMedium.copyWith(
                color: VersusColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAIChat
                  ? '질문을 입력하면 AI가 답변해드립니다'
                  : '첫 메시지를 보내보세요',
              style: VersusTextStyles.bodyMedium.copyWith(
                color: VersusColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build legacy-style unread messages indicator
  static Widget buildLegacyUnreadIndicator({
    required int count,
  }) {
    if (count <= 0) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: VersusColors.error,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: VersusTextStyles.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Format timestamp for display
  static String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
  
  /// Format date for separator
  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);
    
    if (dateOnly == today) {
      return '오늘';
    } else if (dateOnly == yesterday) {
      return '어제';
    } else if (date.year == now.year) {
      return '${date.month}월 ${date.day}일';
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }
}