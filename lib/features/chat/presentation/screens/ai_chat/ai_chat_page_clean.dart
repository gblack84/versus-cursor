/// ═══════════════════════════════════════════════════════════════════════════
/// AIChatPageClean - 투표 AI 채팅방 (ai_assistant_{userId})
/// ═══════════════════════════════════════════════════════════════════════════
///
/// **⚠️ 중요: 이 채팅방의 역할**:
/// ✅ 투표 카드 중계 전용 (AI가 메신저 역할)
/// ✅ 발신자 → AI → 수신자 형태로 투표 전달
/// ✅ 사용자 입력 불가 (읽기 전용)
/// ❌ AI 대화 기능 없음 (ai_helper_chat_page.dart 사용)
///
/// **마이그레이션 완료**:
/// - UI → Provider → UseCase → Repository 플로우
/// - 모든 비즈니스 로직 Provider로 이동
/// - DI를 통한 의존성 주입
///
/// **기존 ai_chat_page_v2.dart와의 차이**:
/// - 956줄 → ~350줄 (63% 감소)
/// - 모든 Firestore 직접 접근 제거
/// - State 상태 변수 제거 (Provider로 통합)
///
/// ═══════════════════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import 'package:intl/intl.dart';
import 'dart:async';

import '/core/constants/app_constants.dart';
import '/core/design_system/design_system.dart';
import '/features/chat/domain/constants/chat_constants.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/chat/data/adapters/flutter_chat_user_adapter.dart';
import '/features/chat/presentation/adapters/flutter_chat_adapter.dart';
import '/features/voting/domain/constants/voting_constants.dart';
import '/features/voting/presentation/chat_vote_card/vote_card/vote_card_widget.dart';
import '/core/types/layout_type.dart';
import '/services/ui/unified_box_calculator.dart';
import '/core/utils/media/aspect_ratio_analyzer.dart';
import '/services/ui/responsive_breakpoints.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/image/unified_image_cache_service.dart';
import 'ai_chat_controller.dart';
import '../../providers/chat_providers.dart';
import '../../providers/chat_params.dart';

/// Clean Architecture + Riverpod 버전 AI Chat Page
///
/// **Features**:
/// - Riverpod 기반 상태 관리
/// - UseCase 통한 비즈니스 로직 처리
/// - AIChatController를 통한 AI 스트리밍
/// - 검색 기능 (composerBuilder 통합)
class AIChatPageClean extends ConsumerStatefulWidget {
  const AIChatPageClean({
    super.key,
    required this.aiChatId,
  });

  static const String routeName = 'AIChat';
  static const String routePath = '/ai-chat';

  final String? aiChatId;

  @override
  ConsumerState<AIChatPageClean> createState() => _AIChatPageCleanState();
}

class _AIChatPageCleanState extends ConsumerState<AIChatPageClean>
    with TickerProviderStateMixin {
  late final AIChatController _chatController;
  final _userCacheService = FlutterChatUserAdapter.instance;

  // 메시지 캐싱 (검색/페이지네이션용)
  List<Message> _cachedMessages = [];
  String? _lastMessageId;
  bool _hasMore = true;

  // Firebase Auth helpers
  String get currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  String? get currentUserDisplayName => FirebaseAuth.instance.currentUser?.displayName;

  // 현재 사용자 정보
  String get currentUserId => currentUserUid.isNotEmpty ? currentUserUid : 'anonymous';

  // 검색 관련
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // 애니메이션 컨트롤러
  late AnimationController _fabAnimationController;
  late Animation<double> _fabBounceAnimation;
  late AnimationController _fabScaleController;
  late Animation<double> _fabScaleAnimation;

  // 스크롤 상태
  bool _showFab = false;
  // ignore: unused_field (Future feature: auto-scroll when new message arrives)
  bool _isNearBottom = false;

  // 검색 상태
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // AIChatController 초기화
    _chatController = AIChatController();

    // TODO: 실제 API 키로 교체 필요
    // AI 서비스 초기화는 필요 시 UseCase에서 처리

    // 애니메이션 초기화
    _fabAnimationController = AnimationController(
      duration: AppConstants.fabAnimationDuration,
      vsync: this,
    );
    _fabBounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabScaleController = AnimationController(
      duration: ChatConstants.fabScaleAnimationDuration,
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabScaleController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _chatController.dispose();
    _searchController.dispose();
    _fabAnimationController.dispose();
    _fabScaleController.dispose();
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

  /// 사용자 ID로부터 User 객체 resolve
  ///
  /// **Clean Architecture v4.0**: FlutterChatUserAdapter를 통해 사용자 정보 로드
  /// - AI 사용자 자동 처리
  /// - Firestore 로드 및 캐싱
  /// - 에러 처리 포함
  Future<core.User?> _resolveUser(String userId) async {
    return await _userCacheService.getUser(userId);
  }

  /// ❌ [잘못된 아키텍처] 메시지 전송 핸들러
  ///
  /// **이 메서드는 실행되지 않아야 합니다**:
  /// - 투표 AI 채팅방은 읽기 전용 (투표 카드 중계 전용)
  /// - 사용자 입력은 항상 비활성화 상태
  /// - AI 대화는 ai_helper_chat_page.dart에서 구현
  ///
  /// **TODO**: 이 메서드를 완전히 제거하고 composerBuilder: SizedBox.shrink() 사용
  Future<void> _handleSendPressed(String text) async {
    // ❌ 이 채팅방은 투표 AI 채팅방 (ai_assistant_{userId})
    // ❌ 투표 카드 중계 전용 - 사용자 입력 불가
    // ❌ AI 스트리밍 구현하지 말 것!
    // ✅ AI 대화는 ai_helper_chat_page.dart에서 구현
    debugPrint('⚠️ 투표 AI 채팅방은 읽기 전용입니다. AI 대화는 ai_helper_chat_page.dart를 사용하세요.');
  }

  /// ❌ [잘못된 위치] AI 스트림 처리 메서드
  ///
  /// **이 메서드는 여기에 구현되면 안 됩니다**:
  /// - 투표 AI 채팅방 (ai_assistant_{userId})은 투표 카드 중계 전용
  /// - AI 스트리밍은 ai_helper_chat_page.dart에 구현
  ///
  /// **TODO**: 이 주석 코드를 ai_helper_chat_page.dart로 이동
  // void _handleAIStream(Stream<String> stream, String messageId) {
  //   String accumulatedText = '';
  //   stream.listen(
  //     (chunk) {
  //       accumulatedText += chunk;
  //       _chatController.updateStreamingMessage(messageId, accumulatedText);
  //     },
  //     onDone: () {
  //       if (accumulatedText.isNotEmpty) {
  //         _chatController.finalizeStreamingMessage(messageId, accumulatedText);
  //       }
  //     },
  //     onError: (error) {
  //       _chatController.markStreamingMessageFailed(messageId, error.toString());
  //     },
  //   );
  // }

  /// 커스텀 메시지 빌더 (VoteCardMessage)
  Widget _buildCustomMessage(
    BuildContext context,
    core.CustomMessage message,
    int index, {
    required bool isSentByMe,
    core.MessageGroupStatus? groupStatus,
  }) {
    final metadata = message.metadata ?? {};

    // 투표 메시지 체크
    if (metadata['type'] == AppConstants.messageTypeVoteRequest ||
        metadata['type'] == AppConstants.messageTypeVoteCreated) {
      // Extract image lists
      final optionAImages =
          (metadata['optionAImages'] as List<dynamic>?)?.cast<String>() ?? [];
      final optionBImages =
          (metadata['optionBImages'] as List<dynamic>?)?.cast<String>() ?? [];

      // Determine layout type from aspect ratios
      final aspectRatioA = metadata['aspectRatioA'] as double?;
      final aspectRatioB = metadata['aspectRatioB'] as double?;
      final layoutType = AspectRatioAnalyzer.getOptimalLayout(
        aspectRatioA,
        aspectRatioB,
      );

      // Calculate box sizes for message card
      final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
      final boxSizes = UnifiedBoxCalculator.calculateForMessageCard(
        bubbleWidth: maxMessageWidth,
        layoutType: layoutType,
        aspectRatioA: aspectRatioA,
        aspectRatioB: aspectRatioB,
        hasImageA: optionAImages.isNotEmpty,
        hasImageB: optionBImages.isNotEmpty,
      );

      return KeyedSubtree(
        key: ValueKey(message.id),
        child: VoteCardWidget(
          postId: metadata['postId'] ?? '',
          title: metadata['title'] ?? '',
          description: metadata['description'],
          optionAText: metadata['optionAText'] ?? '',
          optionBText: metadata['optionBText'] ?? '',
          optionAImages: optionAImages,
          optionBImages: optionBImages,
          boxSizes: boxSizes,
          isHorizontal: layoutType == LayoutType.horizontal,
          cardStatus: metadata['cardStatus'] ?? VotingConstants.cardStatusVotingRequest,
          voteEndTime: metadata['voteEndTime'] != null
              ? (metadata['voteEndTime'] is DateTime
                  ? metadata['voteEndTime']
                  : metadata['voteEndTime'].toDate())
              : null,
          userVotes: metadata['userVotes'],
          voteResults: metadata['voteResults'],
          isMe: isSentByMe,
          currentUserName: currentUserDisplayName,
          searchQuery: _searchQuery.isNotEmpty ? _searchController.text : '',
        ),
      );
    }

    // 기본 커스텀 메시지
    return Container(
      padding: const EdgeInsets.all(12),
      child: Text(
        'Custom message: ${metadata['type'] ?? 'unknown'}',
        style: VersusTextStyles.bodyMedium,
      ),
    );
  }

  /// 로컬 검색 수행
  void _performSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  /// 검색 입력창 (composerBuilder에서 사용)
  Widget _buildSearchInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: VersusColors.backgroundSecondary,
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          _performSearch(value);
        },
        onSubmitted: (query) {
          if (query.isNotEmpty) {
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
          // ❌ Stop 버튼 TODO 제거됨 (투표 AI 채팅방은 AI 스트리밍 미지원)
          // ✅ AI 스트리밍은 ai_helper_chat_page.dart에서 구현
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

  /// Scroll to bottom
  void _scrollToBottom() {
    final messages = _chatController.messages;
    if (messages.isNotEmpty) {
      _chatController.scrollToMessage(
        messages.last.id,
        duration: AppConstants.scrollAnimationDuration,
      );
    }
  }

  /// Animate FAB bounce
  // ignore: unused_element (Future feature: bounce animation on new message)
  void _animateFabBounce() {
    _fabAnimationController.forward().then((_) {
      _fabAnimationController.reverse();
    });
  }

  /// 페이지네이션: 이전 메시지 로드
  Future<void> _loadMoreMessages() async {
    if (!_hasMore || _lastMessageId == null || widget.aiChatId == null) return;

    final loadMoreUseCase = ref.read(loadMoreMessagesUseCaseProvider);
    final result = await loadMoreUseCase.execute(
      chatId: widget.aiChatId!,
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

  /// Scroll notification handler
  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      final offset = notification.metrics.pixels;
      final maxScroll = notification.metrics.maxScrollExtent;

      // Check if near bottom
      _isNearBottom = maxScroll - offset < ChatConstants.loadMoreThreshold;

      // Show/hide FAB
      if (offset > ChatConstants.fabShowThreshold && !_showFab) {
        setState(() {
          _showFab = true;
        });
        _fabScaleController.forward();
      } else if (offset <= ChatConstants.fabShowThreshold && _showFab) {
        setState(() {
          _showFab = false;
        });
        _fabScaleController.reverse();
      }

      // Load more messages
      if (offset <= ChatConstants.loadMoreThreshold && _hasMore) {
        _loadMoreMessages();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.aiChatId == null) {
      return const Scaffold(
        body: Center(child: Text('AI 채팅방 정보가 없습니다')),
      );
    }

    // ✅ Riverpod: StreamProvider를 watch (자동 초기화, 자동 dispose)
    final asyncMessages = ref.watch(chatMessagesStreamProvider(
      ChatMessagesParams(
        chatId: widget.aiChatId!,
        limit: ChatConstants.initialMessageLoadCount,
      ),
    ));

    return Scaffold(
        backgroundColor: VersusColors.backgroundPrimary,
        appBar: AppBar(
          backgroundColor: VersusColors.backgroundSecondary,
          toolbarHeight: 56.0,
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
                    _searchController.clear();
                    _performSearch('');
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
                NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: Chat(
                    currentUserId: currentUserId,
                    resolveUser: _resolveUser,
                    chatController: _chatController,
                    theme: _buildChatTheme(),
                    timeFormat: DateFormat('h:mm a'),
                    onMessageSend: _handleSendPressed,
                    builders: core.Builders(
                      // ✅ 투표 AI 채팅방은 사용자 입력 비활성화
                      // - 검색 모드: 검색창만 표시
                      // - 일반 모드: 입력창 완전 숨김 (SizedBox.shrink)
                      composerBuilder: (context) => _isSearching
                          ? _buildSearchInput()      // 검색 모드: 검색창
                          : SizedBox.shrink(),       // 일반 모드: 입력창 숨김
                      chatAnimatedListBuilder: (context, itemBuilder) {
                        return ChatAnimatedListReversed(
                          itemBuilder: itemBuilder,
                        );
                      },
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
                ),
                // FAB for scroll to bottom
                if (_showFab)
                  Positioned(
                    bottom: 80,
                    right: 16,
                    child: ScaleTransition(
                      scale: _fabScaleAnimation,
                      child: AnimatedBuilder(
                        animation: _fabBounceAnimation,
                        builder: (context, child) => Transform.scale(
                          scale: _fabBounceAnimation.value,
                          child: FloatingActionButton(
                            mini: true,
                            backgroundColor: VersusColors.primary,
                            onPressed: _scrollToBottom,
                            child: const Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
    );
  }
}
