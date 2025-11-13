/// ═══════════════════════════════════════════════════════════════════════════
/// ChatListWidgetClean - Clean Architecture v4.0 + Riverpod 2.x
/// ═══════════════════════════════════════════════════════════════════════════
///
/// **Phase 2 마이그레이션 완료**:
/// - ChangeNotifier → Riverpod StreamProvider
/// - StatefulWidget → ConsumerWidget
/// - 수동 초기화 제거 (자동 Stream 시작)
/// - AsyncValue.when() 패턴 적용
///
/// **코드 감소**:
/// - 332줄 → ~250줄 (25% 감소)
/// - initState/dispose 제거
/// - State 관리 로직 제거
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bot_toast/bot_toast.dart';
import '/features/auth/presentation/providers/auth_providers.dart';

import '/core_exports.dart';
import '/features/chat/domain/entities/chat.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart';
import '../../providers/chat_providers.dart';
import '../../providers/chat_params.dart';

/// Clean Architecture + Riverpod 버전 Chat List Widget
///
/// **Features**:
/// - Riverpod StreamProvider 기반 상태 관리
/// - 자동 Stream 구독/해제 (autoDispose)
/// - AsyncValue.when() 패턴으로 loading/error/data 자동 분기
/// - 실시간 채팅 목록 구독
class ChatListWidgetClean extends ConsumerWidget {
  const ChatListWidgetClean({Key? key}) : super(key: key);

  static String routeName = 'chatList';
  static String routePath = '/chat/list';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Phase C-2: Auth Provider 사용
    final currentUserUid = ref.watch(currentUserIdProvider).value ?? '';

    // ✅ Riverpod: StreamProvider를 watch (자동 초기화, 자동 dispose)
    final asyncChats = ref.watch(chatListStreamProvider(
      ChatListParams(userId: currentUserUid, limit: 50),
    ));

    return Scaffold(
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
              BotToast.showText(text: '새 채팅 시작 기능은 준비 중입니다.');
            },
          ),
        ],
        centerTitle: true,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        // ✅ AsyncValue.when()으로 loading/error/data 자동 분기
        child: asyncChats.when(
          // Loading 상태
          loading: () => Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  VersusColors.primary,
                ),
              ),
            ),
          ),
          // Error 상태
          error: (error, stack) {
            final errorMessage = error.toString();
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: VersusColors.error),
                  const SizedBox(height: 16),
                  Text(
                    '에러: $errorMessage',
                    style: VersusTextStyles.bodyLarge,
                  ),
                ],
              ),
            );
          },
          // Success 상태
          data: (chats) {
            // 빈 목록 처리
            if (chats.isEmpty) {
              return _buildEmptyState();
            }

            // 채팅 목록 표시
            return ListView.builder(
              padding: EdgeInsets.zero,
              scrollDirection: Axis.vertical,
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chatItem = chats[index];
                return _buildChatItem(context, chatItem);
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

  Widget _buildChatItem(BuildContext context, Chat chat) {
    // AI 채팅방인지 확인
    final isAIChat = chat.participantIds.contains('ai_assistant') ||
        chat.chatType == 'aiChat';

    return InkWell(
      onTap: () {
        // 채팅 상세 페이지로 이동
        context.pushNamed(
          ChatDetailWidgetClean.routeName,
          extra: <String, dynamic>{
            'chatDocument': chat,
            kTransitionInfoKey: TransitionInfo(
              hasTransition: false, // 애니메이션 제거로 스크롤 점프 문제 해결
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
                      ? Colors.purple.withValues(alpha: 0.1) // AI 채팅방은 보라색 배경
                      : VersusColors.primaryWithAlpha(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isAIChat ? Icons.smart_toy : Icons.person, // AI는 로봇 아이콘
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
                              ? 'AI 피클' // AI 채팅방 이름
                              : (chat.chatName.isNotEmpty
                                  ? chat.chatName
                                  : '채팅'),
                          style: VersusTextStyles.buttonMedium.copyWith(
                            color: Colors.black,
                          ),
                        ),
                        if (chat.lastMessageAt != null)
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
                            // AI 채팅방은 더 깔끔한 메시지 표시
                            isAIChat &&
                                    chat.lastMessageContent.startsWith('[투표]')
                                ? chat.lastMessageContent // 이미 포맷팅된 메시지
                                : chat.lastMessageContent,
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
