import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/domain/models/chats_model.dart';

/// 채팅 상세 페이지의 AppBar 컴포넌트
class ChatDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final ChatsModel? chatDocument;
  final bool isAiChat;
  final bool isSearching;
  final VoidCallback onSearchToggle;
  final VoidCallback onBack;

  const ChatDetailAppBar({
    super.key,
    required this.chatDocument,
    required this.isAiChat,
    required this.isSearching,
    required this.onSearchToggle,
    required this.onBack,
  });

  @override
  Size get preferredSize => const Size.fromHeight(45.0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: VersusColors.backgroundSecondary,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 45.0,
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
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
                onTap: onBack,
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
                  chatDocument?.chatName ?? '채팅',
                  style: TextStyle(
                    color: VersusColors.textPrimary,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              // Search button removed - now search is always shown in composer for AI chat
            ],
          ),
        ),
      ),
    );
  }
}
