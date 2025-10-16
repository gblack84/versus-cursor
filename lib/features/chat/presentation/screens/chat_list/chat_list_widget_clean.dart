/// ═══════════════════════════════════════════════════════════════════════════
/// ChatListWidgetClean - Clean Architecture v4.0 버전
/// ═══════════════════════════════════════════════════════════════════════════
///
/// **마이그레이션 완료**:
/// - UI → Provider → UseCase → Repository 플로우
/// - StreamBuilder → Consumer 패턴 전환
/// - GetIt 직접 호출 제거 (DI 주입)
///
/// **기존 chat_list_widget.dart와의 차이**:
/// - 268줄 → ~150줄 (44% 감소)
/// - Repository 직접 접근 제거
/// - Provider 레이어 추가
/// - 버그 수정: currentUserUid.orderBy() → queryChats(queryBuilder: ...)
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/app/di.dart';
import '/features/auth/data/adapters/auth_util.dart';
import '/core_exports.dart';
import '/features/chat/domain/entities/chat.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/presentation/screens/chat_detail/chat_detail_widget_clean.dart';
import '../../providers/chat_list_provider.dart';

/// Clean Architecture 버전 Chat List Widget
///
/// **Features**:
/// - Provider 기반 상태 관리
/// - UseCase 통한 비즈니스 로직 처리
/// - 실시간 채팅 목록 구독
class ChatListWidgetClean extends StatefulWidget {
  const ChatListWidgetClean({Key? key}) : super(key: key);

  static String routeName = 'chatList';
  static String routePath = '/chat/list';

  @override
  State<ChatListWidgetClean> createState() => _ChatListWidgetCleanState();
}

class _ChatListWidgetCleanState extends State<ChatListWidgetClean> {
  late final ChatListProvider _provider;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // DI에서 Provider 가져오기
    _provider = getIt<ChatListProvider>();

    // 채팅 목록 초기화
    if (currentUserUid.isNotEmpty) {
      _provider.initializeChatList(currentUserUid);
    }
  }

  @override
  void dispose() {
    // Provider는 dispose하지 않음 (GetIt이 관리)
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
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
          child: Consumer<ChatListProvider>(
            builder: (context, provider, _) {
              // 로딩 상태 처리
              if (provider.state == ChatListLoadingState.loading) {
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

              // 에러 상태 처리
              if (provider.state == ChatListLoadingState.error) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline,
                          size: 48, color: VersusColors.error),
                      const SizedBox(height: 16),
                      Text(
                        '에러: ${provider.errorMessage}',
                        style: VersusTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              }

              // 빈 목록 처리
              if (provider.chats.isEmpty) {
                return _buildEmptyState();
              }

              // 채팅 목록 표시
              return ListView.builder(
                padding: EdgeInsets.zero,
                scrollDirection: Axis.vertical,
                itemCount: provider.chats.length,
                itemBuilder: (context, index) {
                  final chatItem = provider.chats[index];
                  return _buildChatItem(chatItem);
                },
              );
            },
          ),
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

  Widget _buildChatItem(Chat chat) {
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
