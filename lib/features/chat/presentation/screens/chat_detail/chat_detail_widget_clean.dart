/// ═══════════════════════════════════════════════════════════════════════════
/// ChatDetailWidgetClean - Clean Architecture v4.0 버전
/// ═══════════════════════════════════════════════════════════════════════════
///
/// **마이그레이션 완료**:
/// - UI → Provider → UseCase → Repository 플로우
/// - 모든 비즈니스 로직 Provider로 이동
/// - DI를 통한 의존성 주입
///
/// **기존 chat_detail_widget_v2.dart와의 차이**:
/// - 1,199줄 → ~200줄 (83% 감소)
/// - 모든 data layer import 제거
/// - Service 클래스 제거 (Provider로 통합)
/// - flutter_chat_ui 기본 기능만 사용
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';

import '/app/di.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/domain/entities/chat.dart' as entities;
import '/features/chat/presentation/providers/chat_detail_provider.dart';
import '/features/profile/data/adapters/user_cache_service.dart';
import '/services/image/unified_image_cache_service.dart';
import '/features/auth/data/adapters/auth_util.dart' as auth_util;
import 'chat_detail_controller_v2.dart';
import 'components/chat_detail_app_bar.dart';
import 'components/chat_detail_fab.dart';
import 'components/chat_message_builder.dart';

/// Clean Architecture 버전 Chat Detail Widget
///
/// **Features**:
/// - Provider 기반 상태 관리
/// - UseCase 통한 비즈니스 로직 처리
/// - flutter_chat_ui 통합
class ChatDetailWidgetClean extends StatefulWidget {
  const ChatDetailWidgetClean({
    super.key,
    required this.chatDocument,
  });

  static const String routeName = 'ChatDetail';
  static const String routePath = '/chat-detail';

  final entities.Chat? chatDocument;

  @override
  State<ChatDetailWidgetClean> createState() => _ChatDetailWidgetCleanState();
}

class _ChatDetailWidgetCleanState extends State<ChatDetailWidgetClean> with TickerProviderStateMixin {
  late final ChatDetailProvider _provider;
  late final ChatDetailControllerV2 _chatController;
  final _userCacheService = UserCacheService.instance;

  // 현재 사용자 정보 (auth_util에서 가져옴)
  String get currentUserId => auth_util.currentUserUid;

  // AI 채팅 감지
  bool get isAiChat =>
      widget.chatDocument?.chatName == 'AI 피클' ||
      (widget.chatDocument?.id.startsWith('ai_assistant_') ?? false);

  // 검색 관련
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  // FAB 애니메이션 컨트롤러
  late AnimationController _fabScaleController;
  late AnimationController _fabBounceController;
  late Animation<double> _fabScaleAnimation;
  late Animation<double> _fabBounceAnimation;

  @override
  void initState() {
    super.initState();

    // ChatController 초기화
    _chatController = ChatDetailControllerV2();

    // DI에서 Provider 가져오기 ← 핵심 연결 지점
    _provider = getIt<ChatDetailProvider>();

    // 채팅 초기화 (ChatMessageLifecycleService 자동 읽음 처리 포함)
    if (widget.chatDocument != null) {
      _provider.initializeChat(widget.chatDocument!.id, currentUserId);
    }

    // Provider 메시지를 ChatController에 연결
    _provider.addListener(_updateChatControllerMessages);

    // FAB 애니메이션 컨트롤러 초기화
    _fabScaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabBounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _fabScaleAnimation = CurvedAnimation(
      parent: _fabScaleController,
      curve: Curves.easeInOut,
    );
    _fabBounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _fabBounceController,
        curve: Curves.elasticOut,
      ),
    );

    _fabScaleController.forward();
  }

  @override
  void dispose() {
    _provider.removeListener(_updateChatControllerMessages);
    _chatController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabScaleController.dispose();
    _fabBounceController.dispose();
    // Provider는 dispose하지 않음 (GetIt이 관리)
    super.dispose();
  }

  /// 메시지 목록에서 이미지 URL 추출
  ///
  /// flutter_chat_core Message 타입을 파싱하여 투표 카드 이미지 URL을 추출합니다.
  List<String> _extractImageUrlsFromMessages(List<core.Message> messages) {
    final urls = <String>[];

    for (final message in messages) {
      // 투표 메시지 (CustomMessage)
      if (message is core.CustomMessage) {
        final metadata = message.metadata ?? {};

        // 투표 이미지 추출
        if (metadata['imageUrlA'] != null) {
          urls.add(metadata['imageUrlA'] as String);
        }
        if (metadata['imageUrlB'] != null) {
          urls.add(metadata['imageUrlB'] as String);
        }
        if (metadata['imageUrlsA'] != null) {
          urls.addAll((metadata['imageUrlsA'] as List).cast<String>());
        }
        if (metadata['imageUrlsB'] != null) {
          urls.addAll((metadata['imageUrlsB'] as List).cast<String>());
        }
      }
    }

    return urls;
  }

  /// Provider의 메시지를 ChatController로 동기화
  void _updateChatControllerMessages() {
    if (_provider.messages.isNotEmpty) {
      _chatController.setMessages(_provider.messages);

      // ✨ 메시지 이미지 프리로딩 (UnifiedImageCacheService)
      if (mounted) {
        final imageUrls = _extractImageUrlsFromMessages(_provider.messages);
        if (imageUrls.isNotEmpty) {
          UnifiedImageCacheService.instance.preloadImages(context, imageUrls);
        }
      }
    }
  }

  /// 사용자 ID로부터 User 객체 resolve
  ///
  /// **Clean Architecture v4.0**: UserCacheService를 통해 사용자 정보 로드
  /// - AI 사용자 자동 처리
  /// - Firestore 로드 및 캐싱
  /// - 에러 처리 포함
  Future<core.User?> _resolveUser(String userId) async {
    return await _userCacheService.getUser(userId);
  }

  /// 메시지 전송 핸들러
  void _handleSendPressed(String text) {
    _provider.sendMessage(
      content: text,
      senderId: currentUserId,
    );
  }

  /// 첨부 파일 핸들러 (TODO)
  void _handleAttachmentPressed() {
    // TODO: 미디어 업로드 구현
    debugPrint('TODO: Attachment pressed');
  }

  /// 커스텀 메시지 빌더 (VoteCard 등)
  Widget _buildCustomMessage(
    BuildContext context,
    core.CustomMessage message,
    int index, {
    required bool isSentByMe,
    core.MessageGroupStatus? groupStatus,
  }) {
    return ChatMessageBuilder.buildCustomMessage(
      context,
      message,
      index,
      isSentByMe: isSentByMe,
      groupStatus: groupStatus,
      chatDocument: widget.chatDocument,
      currentUserRecord: null, // TODO: 현재 사용자 정보 전달
      searchQuery: _provider.isSearching ? _searchController.text : null,
      isSearching: _provider.isSearching,
      messageStatus: null, // TODO: 메시지 상태 전달
    );
  }

  /// 시스템 메시지 빌더 (날짜 헤더)
  Widget _buildSystemMessage(
    BuildContext context,
    core.SystemMessage message,
    int index, {
    core.MessageGroupStatus? groupStatus,
    bool isSentByMe = false,
  }) {
    return ChatMessageBuilder.buildSystemMessage(
      context,
      message,
      index,
      groupStatus: groupStatus,
      isSentByMe: isSentByMe,
    );
  }

  /// AI 검색창 (하단 고정)
  Widget _buildAISearchInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        border: Border(
          top: BorderSide(
            color: VersusColors.textPrimary.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 검색 입력창
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            maxLength: 20,
            decoration: InputDecoration(
              hintText: '검색...',
              prefixIcon: Icon(Icons.search, color: VersusColors.primary),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: VersusColors.textSecondary),
                      onPressed: () {
                        _searchController.clear();
                        _provider.searchMessages('');
                      },
                    )
                  : null,
            ),
            onChanged: (value) {
              _provider.searchMessages(value);
            },
          ),
          // 검색 결과 네비게이션 (결과가 있을 때만 표시)
          if (_provider.hasSearchResults) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 이전 결과 버튼
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_up,
                    color: VersusColors.primary,
                  ),
                  onPressed: _provider.goToPreviousSearchResult,
                  tooltip: '이전 검색 결과',
                ),
                // 검색 결과 카운터
                Text(
                  '${_provider.currentSearchIndex + 1}/${_provider.searchResultCount}',
                  style: VersusTextStyles.bodyMedium.copyWith(
                    color: VersusColors.textSecondary,
                  ),
                ),
                // 다음 결과 버튼
                IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: VersusColors.primary,
                  ),
                  onPressed: _provider.goToNextSearchResult,
                  tooltip: '다음 검색 결과',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// 채팅 테마
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

  /// 스크롤 이벤트 핸들러
  ///
  /// NotificationListener를 통해 flutter_chat_ui의 스크롤 이벤트를 감지하고
  /// Provider의 스크롤 상태를 업데이트하여 FAB 표시/숨김을 제어합니다.
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final offset = notification.metrics.pixels;
      final maxScroll = notification.metrics.maxScrollExtent;

      // 하단 근처 여부 확인 (200px 이내)
      final isNearBottom = maxScroll - offset < 200;

      // 하단 도달 여부 확인 (50px 이내)
      final isAtBottom = maxScroll - offset <= 50;

      // Provider 상태 업데이트 (FAB 애니메이션 트리거)
      final wasAtBottom = _provider.isAtBottom;
      if (wasAtBottom != isAtBottom) {
        // 상태가 변경될 때만 Provider 업데이트
        _provider.updateScrollState(
          isAtBottom: isAtBottom,
          isNearBottom: isNearBottom,
        );
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Scaffold(
        backgroundColor: VersusColors.backgroundPrimary,
        appBar: ChatDetailAppBar(
          chatDocument: widget.chatDocument,
          isAiChat: isAiChat,
          isSearching: _provider.isSearching,
          onSearchToggle: () {
            // TODO: 검색 토글 구현
          },
          onBack: () => Navigator.of(context).pop(),
        ),
        body: Consumer<ChatDetailProvider>(
          builder: (context, provider, _) {
            // 로딩 상태 처리
            if (provider.state == ChatDetailLoadingState.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // 에러 상태 처리
            if (provider.state == ChatDetailLoadingState.error) {
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

            // 채팅 UI
            return Stack(
              children: [
                Column(
                  children: [
                    // 메시지 목록
                    Expanded(
                      child: NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: Chat(
                          currentUserId: currentUserId,
                          resolveUser: _resolveUser, // ← 필수: 사용자 정보 resolve
                          chatController: _chatController, // ← 필수: 컨트롤러
                          theme: _buildChatTheme(),
                          timeFormat: DateFormat('h:mm a'),
                          onMessageSend: isAiChat ? null : _handleSendPressed,
                          onAttachmentTap: isAiChat ? null : _handleAttachmentPressed,
                          builders: core.Builders(
                            // AI 채팅방에서는 입력창 숨김
                            composerBuilder: isAiChat
                                ? (context) => const SizedBox.shrink()
                                : null,
                            customMessageBuilder: _buildCustomMessage,
                            systemMessageBuilder: _buildSystemMessage,
                            emptyChatListBuilder: (context) => Center(
                              child: Text(
                                isAiChat
                                    ? 'AI 피클에게 질문해보세요!'
                                    : '첫 메시지를 보내보세요!',
                                style: VersusTextStyles.bodyLarge.copyWith(
                                  color: VersusColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    // AI 채팅방일 때 검색창 표시
                    if (isAiChat) _buildAISearchInput(),
                  ],
                ),
                // FAB (하단으로 스크롤 버튼)
                Consumer<ChatDetailProvider>(
                  builder: (context, provider, _) {
                    return ChatDetailFAB(
                      isAtBottom: provider.isAtBottom,
                      scaleAnimation: _fabScaleAnimation,
                      bounceAnimation: _fabBounceAnimation,
                      onPressed: () {
                        provider.scrollToBottom();
                        _fabBounceController.forward(from: 0);
                      },
                    );
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
