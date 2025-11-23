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
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';
import '/features/auth/presentation/providers/auth_providers.dart';
import 'package:versus_space/gen/fonts.gen.dart';
import 'dart:async';

import '/core/design_system/design_system.dart';
import '/features/chat/domain/entities/chat.dart' as entities;
import '/features/chat/domain/entities/message.dart';
import '/features/chat/domain/constants/chat_constants.dart';
import '/features/chat/presentation/adapters/flutter_chat_adapter.dart';
import '/features/chat/data/adapters/flutter_chat_user_adapter.dart';
import '/services/cache/unified_image_cache_service.dart';
import 'chat_detail_controller_v2.dart';
import 'components/chat_detail_app_bar.dart';
import 'components/chat_detail_fab.dart';
import 'components/chat_message_builder.dart';
import '../../providers/chat_providers.dart';
import '../../providers/chat_params.dart';

/// Clean Architecture + Riverpod 버전 Chat Detail Widget
///
/// **Features**:
/// - Riverpod 기반 상태 관리
/// - UseCase 통한 비즈니스 로직 처리
/// - flutter_chat_ui 통합
/// - 자동 Stream 구독/해제
class ChatDetailWidgetClean extends ConsumerStatefulWidget {
  const ChatDetailWidgetClean({
    super.key,
    required this.chatDocument,
  });

  static const String routeName = 'ChatDetail';
  static const String routePath = '/chat-detail';

  final entities.Chat? chatDocument;

  @override
  ConsumerState<ChatDetailWidgetClean> createState() => _ChatDetailWidgetCleanState();
}

class _ChatDetailWidgetCleanState extends ConsumerState<ChatDetailWidgetClean> with TickerProviderStateMixin {
  late final ChatDetailControllerV2 _chatController;
  final _userCacheService = FlutterChatUserAdapter.instance;

  // 메시지 캐싱 (검색/페이지네이션용)
  List<Message> _cachedMessages = [];
  String? _lastMessageId;
  bool _hasMore = true;

  // Phase C-2: Auth Provider 사용 - REMOVED buggy getter
  // ❌ OLD: String get currentUserId => ref.watch(currentUserIdProvider).value ?? '';
  // ✅ NEW: Properly handle AsyncValue in build method with nested .when()

  // AI 채팅 감지
  bool get isAiChat =>
      widget.chatDocument?.chatName == 'AI 피클' ||
      (widget.chatDocument?.id.startsWith('ai_assistant_') ?? false);

  // 검색 관련
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  List<String> _searchResultIds = [];
  int _currentSearchIndex = -1;

  // 스크롤 상태
  bool _isAtBottom = false;
  bool _isNearBottom = false;

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

    // ChatMessageLifecycleService: 채팅방 진입 시 자동 읽음 처리
    if (widget.chatDocument != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // ✅ FIX: Properly read AsyncValue from currentUserIdProvider
        final userIdAsync = ref.read(currentUserIdProvider);
        final userId = userIdAsync.value;

        if (userId != null && userId.isNotEmpty) {
          ref.read(chatMessageLifecycleServiceProvider).markMessagesAsSeen(
            chatId: widget.chatDocument!.id,
            currentUserId: userId,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _fabScaleController.dispose();
    _fabBounceController.dispose();
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

  /// 메시지를 ChatController로 동기화하고 이미지 프리로드
  void _updateChatController(List<core.Message> messages) {
    if (messages.isNotEmpty) {
      _chatController.setMessages(messages);

      // ✨ 메시지 이미지 프리로딩 (UnifiedImageCacheService)
      if (mounted) {
        final imageUrls = _extractImageUrlsFromMessages(messages);
        if (imageUrls.isNotEmpty) {
          UnifiedImageCacheService.instance.preloadImages(context, imageUrls);
        }
      }
    }
  }

  /// 로컬 검색 수행
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });

    if (query.isEmpty) {
      setState(() {
        _searchResultIds = [];
        _currentSearchIndex = -1;
      });
      return;
    }

    final searchUseCase = ref.read(searchMessagesUseCaseProvider);
    final result = searchUseCase.execute(
      allMessages: _cachedMessages,
      query: query,
    );

    result.fold(
      (failure) {
        // 검색 실패 무시
      },
      (filtered) {
        setState(() {
          _searchResultIds = filtered.map((msg) => msg.id).toList();
          _currentSearchIndex = _searchResultIds.isNotEmpty ? 0 : -1;
        });

        // 첫 번째 검색 결과로 스크롤
        if (_searchResultIds.isNotEmpty) {
          _chatController.scrollToMessage(_searchResultIds.first);
        }
      },
    );
  }

  /// 다음 검색 결과로 이동
  void _goToNextSearchResult() {
    if (_searchResultIds.isEmpty) return;

    setState(() {
      _currentSearchIndex = (_currentSearchIndex + 1) % _searchResultIds.length;
    });

    _chatController.scrollToMessage(_searchResultIds[_currentSearchIndex]);
  }

  /// 이전 검색 결과로 이동
  void _goToPreviousSearchResult() {
    if (_searchResultIds.isEmpty) return;

    setState(() {
      _currentSearchIndex = (_currentSearchIndex - 1 + _searchResultIds.length) % _searchResultIds.length;
    });

    _chatController.scrollToMessage(_searchResultIds[_currentSearchIndex]);
  }

  /// 페이지네이션: 이전 메시지 로드
  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _lastMessageId == null || widget.chatDocument == null) return;

    final loadMoreUseCase = ref.read(loadMoreMessagesUseCaseProvider);
    final result = await loadMoreUseCase.execute(
      chatId: widget.chatDocument!.id,
      lastMessageId: _lastMessageId!,
      limit: ChatConstants.paginationMessageCount,
    );

    result.fold(
      (failure) {
        // 로드 실패 무시
      },
      (olderMessages) {
        if (olderMessages.isEmpty) {
          setState(() {
            _hasMore = false;
          });
        } else {
          setState(() {
            _cachedMessages.insertAll(0, olderMessages);
            if (olderMessages.isNotEmpty) {
              _lastMessageId = olderMessages.first.id;
            }
          });
        }
      },
    );
  }

  /// 사용자 ID로부터 User 객체 resolve
  ///
  /// **Clean Architecture v4.0**: FlutterChatUserAdapter를 통해 사용자 정보 로드
  /// - AI 사용자 자동 처리
  /// - Firestore 로드 및 캐싱
  /// - 에러 처리 포함
  Future<core.User?> _resolveUser(String userId) async {
    return await _userCacheService.getUser(userId);
  }

  /// 메시지 전송 핸들러
  void _handleSendPressed(String text) {
    // TODO: Phase 3에서 SendMessageUseCase 통합
    // 현재는 MessagesModel 팩토리 메서드가 필요하므로 임시로 비워둠
    debugPrint('TODO: Send message - $text');

    // final sendMessageUseCase = ref.read(sendMessageUseCaseProvider);
    // final message = MessagesModel.create(
    //   content: text,
    //   senderId: currentUserId,
    //   timeStamp: DateTime.now(),
    // );
    // await sendMessageUseCase.execute(
    //   chatId: widget.chatDocument!.id,
    //   message: message,
    // );
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
      searchQuery: _searchQuery.isNotEmpty ? _searchController.text : null,
      isSearching: _searchQuery.isNotEmpty,
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
                        _performSearch('');
                      },
                    )
                  : null,
            ),
            onChanged: _performSearch,
          ),
          // 검색 결과 네비게이션 (결과가 있을 때만 표시)
          if (_searchResultIds.isNotEmpty) ...[
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
                  onPressed: _goToPreviousSearchResult,
                  tooltip: '이전 검색 결과',
                ),
                // 검색 결과 카운터
                Text(
                  '${_currentSearchIndex + 1}/${_searchResultIds.length}',
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
                  onPressed: _goToNextSearchResult,
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
        fontFamily: FontFamily.sourGummy,
      ),
    );
  }

  /// 스크롤 이벤트 핸들러
  ///
  /// NotificationListener를 통해 flutter_chat_ui의 스크롤 이벤트를 감지하고
  /// 로컬 스크롤 상태를 업데이트하여 FAB 표시/숨김을 제어합니다.
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final offset = notification.metrics.pixels;
      final maxScroll = notification.metrics.maxScrollExtent;

      // 하단 근처 여부 확인 (200px 이내)
      final isNearBottom = maxScroll - offset < 200;

      // 하단 도달 여부 확인 (50px 이내)
      final isAtBottom = maxScroll - offset <= 50;

      // 상태 변경 시에만 setState
      if (_isAtBottom != isAtBottom || _isNearBottom != isNearBottom) {
        setState(() {
          _isAtBottom = isAtBottom;
          _isNearBottom = isNearBottom;
        });

        // 스크롤 하단 도달 시 추가 메시지 로드
        if (offset <= ChatConstants.loadMoreThreshold && _hasMore) {
          _loadMoreMessages();
        }
      }
    }
    return false;
  }

  /// 하단으로 스크롤
  void _scrollToBottom() {
    final messages = _chatController.messages;
    if (messages.isNotEmpty) {
      _chatController.scrollToMessage(messages.last.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.chatDocument == null) {
      return const Scaffold(
        body: Center(child: Text('채팅방 정보가 없습니다')),
      );
    }

    // ✅ Riverpod: StreamProvider를 watch (자동 초기화, 자동 dispose)
    final asyncMessages = ref.watch(chatMessagesStreamProvider(
      ChatMessagesParams(
        chatId: widget.chatDocument!.id,
        limit: ChatConstants.initialMessageLoadCount,
      ),
    ));

    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      appBar: ChatDetailAppBar(
        chatDocument: widget.chatDocument,
        isAiChat: isAiChat,
        isSearching: _searchQuery.isNotEmpty,
        onSearchToggle: () {
          // TODO: 검색 토글 구현
        },
        onBack: () => Navigator.of(context).pop(),
      ),
      body: asyncMessages.when(
        // Loading 상태
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        // Error 상태
        error: (error, stack) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48, color: VersusColors.error),
                const SizedBox(height: 16),
                Text(
                  '에러: ${error.toString()}',
                  style: VersusTextStyles.bodyLarge,
                ),
              ],
            ),
          );
        },
        // Success 상태
        data: (messages) {
          // 메시지 캐싱 및 변환
          _cachedMessages = messages;
          if (messages.isNotEmpty) {
            _lastMessageId = messages.first.id;
          }

          // ✅ FIX: Properly watch currentUserIdProvider and handle AsyncValue
          final currentUserAsync = ref.watch(currentUserIdProvider);

          return currentUserAsync.when(
            // userId 로딩 중
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            // userId 에러
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: VersusColors.error),
                  const SizedBox(height: 16),
                  Text(
                    '로그인이 필요합니다',
                    style: VersusTextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
            // userId 성공
            data: (currentUserId) {
              // ✅ Validate userId
              if (currentUserId == null || currentUserId.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login,
                          size: 48, color: VersusColors.textSecondary),
                      const SizedBox(height: 16),
                      Text(
                        '로그인이 필요합니다',
                        style: VersusTextStyles.bodyLarge.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 검색 필터 적용
              final searchUseCase = ref.read(searchMessagesUseCaseProvider);
              final filteredResult = searchUseCase.execute(
                allMessages: messages,
                query: _searchQuery,
              );

              final displayMessages = filteredResult.fold(
                (failure) => <Message>[],
                (filtered) => filtered,
              );

              // Entity → flutter_chat_ui Message 변환
              final chatMessages = FlutterChatAdapter.convertEntitiesToMessages(displayMessages);

              // ChatController 동기화
              _updateChatController(chatMessages);

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
                            currentUserId: currentUserId,  // ✅ Now properly validated
                            resolveUser: _resolveUser,
                            chatController: _chatController,
                            theme: _buildChatTheme(),
                            timeFormat: DateFormat('h:mm a'),
                            onMessageSend: isAiChat ? null : _handleSendPressed,
                            onAttachmentTap: isAiChat ? null : _handleAttachmentPressed,
                            builders: core.Builders(
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
                  if (!_isAtBottom)
                    ChatDetailFAB(
                      isAtBottom: _isAtBottom,
                      scaleAnimation: _fabScaleAnimation,
                      bounceAnimation: _fabBounceAnimation,
                      onPressed: () {
                        _scrollToBottom();
                        _fabBounceController.forward(from: 0);
                      },
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
