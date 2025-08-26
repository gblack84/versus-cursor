import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '/features/common/presentation/design_system/design_system.dart';
import '/components/notifications/voting_notification_dialog.dart';
import '/features/common/data/services/responsive_breakpoints.dart';
import '/posts/in_put_post_image/helpers/aspect_ratio_analyzer.dart';
import '/features/common/data/services/unified_box_calculator.dart';
import '/services/unified_image_cache_service.dart';
import '/services/vote_state_coordinator.dart';
import '/models/vote_state.dart';
import 'base_vote_message.dart';

/// AI 피클 채팅에서 사용되는 투표 카드 메시지 위젯
/// 4가지 상태를 지원: voting_request, in_progress, completed, not_participated
class VoteCardMessage extends BaseVoteMessage {
  final String? searchQuery;
  
  const VoteCardMessage({
    super.key,
    required super.postId,
    required super.title,
    super.description,
    required super.optionAText,
    required super.optionBText,
    super.optionAImage,
    super.optionBImage,
    super.optionAImages,
    super.optionBImages,
    super.aspectRatioA,
    super.aspectRatioB,
    required super.cardStatus,
    super.voteEndTime,
    super.userVotes,
    super.voteResults,
    required super.isMe,
    super.timestamp,
    required super.messageType,
    super.messageId,
    super.chatId,
    super.currentUserName,
    super.senderProfileImageUrl,
    super.senderDisplayName,
    super.senderId,
    super.showSenderProfile,
    this.searchQuery,
  });

  @override
  State<VoteCardMessage> createState() => _VoteCardMessageState();
}

class _VoteCardMessageState extends State<VoteCardMessage> 
    with BaseVoteMessageStateMixin<VoteCardMessage>, TickerProviderStateMixin {
  // 투표 상태 변경 애니메이션
  bool _isVoting = false;
  
  // 전역 캐시 맵 (메시지별 BoxSizes 저장)
  static final Map<String, BoxSizes> _globalBoxSizesCache = {};
  
  // 캐싱 변수 추가 (중복 계산 방지)
  LayoutType? _cachedLayoutType;
  BoxSizes? _cachedBoxSizes;
  
  // 통합 투표 상태 스트림
  late Stream<VoteStateData> _voteStateStream;
  
  // VoteStateCoordinator 사용
  @override
  bool get useVoteStateCoordinator => true;

  @override
  void initState() {
    super.initState();
    // MediaQuery 접근은 didChangeDependencies에서 처리
    
    // 통합 상태 스트림 초기화
    _voteStateStream = VoteStateCoordinator.instance.getVoteStateStream(
      postId: widget.postId,
      voteEndTime: widget.voteEndTime,
      initialStatus: widget.cardStatus,
      userVotes: widget.userVotes,
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // 여기서는 MediaQuery 안전하게 접근 가능
    final screenWidth = MediaQuery.sizeOf(context).width.toInt();
    final cacheKey = '${widget.messageId ?? widget.postId}_$screenWidth';
    if (_globalBoxSizesCache.containsKey(cacheKey)) {
      _cachedBoxSizes = _globalBoxSizesCache[cacheKey];
    }
  }
  
  @override
  void didUpdateWidget(VoteCardMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // postId가 변경되거나 주요 속성이 변경되면 스트림 재생성
    if (oldWidget.postId != widget.postId ||
        oldWidget.voteEndTime != widget.voteEndTime ||
        oldWidget.cardStatus != widget.cardStatus) {
      // 이전 상태 정리
      VoteStateCoordinator.instance.dispose(oldWidget.postId);
      
      // 새 스트림 생성
      _voteStateStream = VoteStateCoordinator.instance.getVoteStateStream(
        postId: widget.postId,
        voteEndTime: widget.voteEndTime,
        initialStatus: widget.cardStatus,
        userVotes: widget.userVotes,
      );
    }
    
    // aspectRatio가 변경되면 캐시 무효화
    if (oldWidget.aspectRatioA != widget.aspectRatioA ||
        oldWidget.aspectRatioB != widget.aspectRatioB ||
        oldWidget.effectiveImageUrlsA.length != widget.effectiveImageUrlsA.length ||
        oldWidget.effectiveImageUrlsB.length != widget.effectiveImageUrlsB.length) {
      _cachedLayoutType = null;
      _cachedBoxSizes = null;
    }
  }

  @override
  void dispose() {
    // 통합 상태 스트림 정리
    VoteStateCoordinator.instance.dispose(widget.postId);
    super.dispose();
  }
  
  // VoteState enum을 문자열로 변환
  String _mapStateToString(VoteState state) {
    switch (state) {
      case VoteState.votingRequest:
        return 'votingRequest';
      case VoteState.completed:
        return 'completed';
      case VoteState.expired:
        return 'expired';
      case VoteState.notParticipated:
        return 'notParticipated';
      case VoteState.inProgress:
        return 'inProgress';
    }
  }
  
  // VoteState enum에 따른 상태 정보 가져오기
  Map<String, dynamic> _getStatusInfoForState(VoteState state, bool hasUserVoted) {
    final statusInfo = <String, dynamic>{};
    
    switch (state) {
      case VoteState.votingRequest:
        statusInfo['text'] = '피클요청';
        statusInfo['color'] = VersusColors.primary;
        statusInfo['icon'] = Icons.how_to_vote;
        break;
      case VoteState.inProgress:
        // 사용자가 투표했는지 확인
        if (hasUserVoted) {
          statusInfo['text'] = 'Pick 완료!(진행중)';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.check_circle_outline;
        } else {
          statusInfo['text'] = '진행중';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.timer;
        }
        break;
      case VoteState.completed:
        statusInfo['text'] = '완료';
        statusInfo['color'] = VersusColors.success;
        statusInfo['icon'] = Icons.check_circle;
        break;
      case VoteState.expired:
        statusInfo['text'] = '만료';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.timer_off;
        break;
      case VoteState.notParticipated:
        statusInfo['text'] = '미참여';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.block;
        break;
    }
    
    return statusInfo;
  }
  
  
  // 검색어 하이라이팅 헬퍼 메서드
  Widget _highlightText(String text, TextStyle baseStyle) {
    if (widget.searchQuery == null || widget.searchQuery!.isEmpty) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    final lowerText = text.toLowerCase();
    final lowerQuery = widget.searchQuery!.toLowerCase();
    final index = lowerText.indexOf(lowerQuery);
    
    if (index == -1) {
      return Text(
        text,
        style: baseStyle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    // 검색어가 포함된 경우 하이라이팅
    final beforeText = text.substring(0, index);
    final matchText = text.substring(index, index + widget.searchQuery!.length);
    final afterText = text.substring(index + widget.searchQuery!.length);
    
    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: beforeText, style: baseStyle),
          TextSpan(
            text: matchText,
            style: baseStyle.copyWith(
              backgroundColor: VersusColors.primary.withValues(alpha: 0.3),
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(text: afterText, style: baseStyle),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    // 통합 상태 스트림 사용
    return StreamBuilder<VoteStateData>(
      stream: _voteStateStream,
      builder: (context, snapshot) {
        // 에러 처리
        if (snapshot.hasError) {
          debugPrint('[VoteCard] Stream 에러: ${snapshot.error}');
          // 에러 시 기본 상태로 폴백
          return _buildUnifiedVoteCard(
            VoteStateData(
              state: _mapInitialStatus(widget.cardStatus),
              voteEndTime: widget.voteEndTime,
            ),
          );
        }
        
        // 데이터 확인
        final stateData = snapshot.data ?? VoteStateData(
          state: _mapInitialStatus(widget.cardStatus),
          voteEndTime: widget.voteEndTime,
        );
        
        // 디버그 로그
        if (snapshot.hasData) {
          debugPrint('[VoteCard] 통합 상태 수신 - postId: ${widget.postId}');
          debugPrint('  - state: ${stateData.state}');
          debugPrint('  - remainingTime: ${stateData.remainingTime}');
          debugPrint('  - isTimerExpired: ${stateData.isTimerExpired}');
          debugPrint('  - hasUserVoted: ${stateData.hasUserVoted}');
        }
        
        return _buildUnifiedVoteCard(stateData);
      },
    );
  }
  
  // 초기 상태를 VoteState enum으로 변환
  VoteState _mapInitialStatus(String status) {
    switch (status) {
      case 'votingRequest':
        return VoteState.votingRequest;
      case 'completed':
        return VoteState.completed;
      case 'expired':
        return VoteState.expired;
      case 'notParticipated':
        return VoteState.notParticipated;
      case 'inProgress':
        return VoteState.inProgress;
      default:
        return VoteState.inProgress;
    }
  }
  
  Widget _buildUnifiedVoteCard(VoteStateData stateData) {
    // VoteState enum을 문자열로 변환 (기존 메서드 호환성 유지)
    final effectiveStatus = _mapStateToString(stateData.state);
    
    // 상태 정보 가져오기 (사용자 투표 여부 반영)
    final statusInfo = _getStatusInfoForState(stateData.state, stateData.hasUserVoted);
    
    // vote_request 타입일 때 상태 텍스트를 '대기중'으로 오버라이드
    if (widget.messageType == 'voteRequest' && stateData.state == VoteState.votingRequest) {
      statusInfo['text'] = '대기중';
    }
    
    return Semantics(
      button: true,
      label: '투표 요청: ${widget.title}',
      hint: '탭하여 투표하기',
      value: '상태: ${statusInfo['text']}',
      excludeSemantics: _isVoting,
      child: Focus(
        canRequestFocus: !_isVoting,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey.keyLabel == 'Enter' || 
                event.logicalKey.keyLabel == ' ') {
              if (!_isVoting) {
                setState(() {
                  _isVoting = true;
                });
                _handleTap();
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    setState(() {
                      _isVoting = false;
                    });
                  }
                });
              }
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: GestureDetector(
          onTap: _isVoting ? null : _handleTap,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 새로운 프로필 헤더 (최상단)
                  _buildProfileHeader(statusInfo),
                  const SizedBox(height: VersusSpacing.md),
                  
                  _buildTitle(),
                  if (widget.description != null && widget.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _buildDescription(),
                  ],
                  const SizedBox(height: VersusSpacing.sm),
                  _buildSmartLayout(),
                  if (_shouldShowTimer(effectiveStatus, stateData.voteEndTime)) ...[
                    const SizedBox(height: VersusSpacing.sm),
                    _buildTimer(stateData),
                  ],
                  if (_shouldShowAction(effectiveStatus)) ...[
                    const SizedBox(height: VersusSpacing.sm),
                    _buildActionButton(effectiveStatus),
                  ],
                  if (_shouldShowResult(effectiveStatus)) ...[
                    const SizedBox(height: VersusSpacing.sm),
                    _buildResults(),
                  ],
                  // 타임스탬프는 이제 버블에서 표시되므로 여기서는 제거
                ],
              ),
              // 투표 중 오버레이
              if (_isVoting)
                Positioned.fill(
                  child: Semantics(
                    label: '투표 처리 중',
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white.withValues(alpha: 0.9),
                          ),
                          semanticsLabel: '로딩 중',
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(Map<String, dynamic> statusInfo) {
    // isMe에 따라 표시할 이름과 프로필 결정 (발신자 정보 표시)
    final displayName = widget.isMe 
        ? (widget.currentUserName ?? '나')
        : (widget.senderDisplayName ?? '알 수 없는 사용자');
    
    // 프로필 이미지도 isMe에 따라 결정 (현재는 발신자 프로필만 있음)
    final hasProfileImage = widget.senderProfileImageUrl?.isNotEmpty ?? false;
    
    return Row(
      children: [
        // 프로필 이미지
        GestureDetector(
          onTap: () {
            // TODO: 프로필 페이지로 이동
            debugPrint('Navigate to profile: $displayName');
          },
          child: CircleAvatar(
            radius: 20,
            backgroundImage: hasProfileImage && !widget.isMe
                ? CachedNetworkImageProvider(widget.senderProfileImageUrl!)
                : null,
            backgroundColor: hasProfileImage && !widget.isMe
                ? Colors.transparent 
                : VersusColors.borderLight,
            child: !hasProfileImage || widget.isMe
                ? Icon(
                    Icons.person,
                    size: 24,
                    color: VersusColors.textSecondary,
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),
        
        // 중간 영역: Pikle 브랜딩 + 발신자 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pikle 도착! 라인
              Row(
                children: [
                  Image.asset(
                    'assets/images/pikle_icon.png',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    // isMe에 따라 다른 텍스트 표시
                    widget.isMe
                        ? '내가 만든 피클' 
                        : 'Pikle 도착!',
                    style: VersusTextStyles.labelMedium.copyWith(
                      color: VersusColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              
              // 발신자 정보
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: widget.isMe ? '나' : displayName,
                        style: VersusTextStyles.labelSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: VersusColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: widget.isMe
                            ? ' • 투표 생성됨'
                            : '님이 물어봅니다',
                        style: VersusTextStyles.labelSmall.copyWith(
                          color: VersusColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 오른쪽: 상태 배지
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: VersusSpacing.xs,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: (statusInfo['color'] as Color).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                statusInfo['icon'] as IconData,
                size: 12,
                color: statusInfo['color'] as Color,
              ),
              const SizedBox(width: 4),
              Text(
                statusInfo['text'] as String,
                style: VersusTextStyles.labelSmall.copyWith(
                  fontSize: 11,
                  color: statusInfo['color'] as Color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTitle() {
    return _highlightText(
      widget.title,
      VersusTextStyles.bodyLarge.copyWith(
        color: VersusColors.textPrimary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
  
  Widget _buildDescription() {
    return _highlightText(
      widget.description!,
      VersusTextStyles.bodySmall.copyWith(
        color: VersusColors.textSecondary,
      ),
    );
  }
  
  Widget _buildSmartLayout() {
    // 레이아웃 타입 결정 (캐싱됨)
    final layoutType = _getLayoutType();
    
    // BoxSizes를 여기서 한 번만 계산 (캐싱)
    if (_cachedBoxSizes == null) {
      final maxMessageWidth = ResponsiveBreakpoints.getMaxMessageWidth(context);
      _cachedBoxSizes = UnifiedBoxCalculator.calculateForMessageCard(
        bubbleWidth: maxMessageWidth,
        layoutType: layoutType,
        aspectRatioA: widget.aspectRatioA,
        aspectRatioB: widget.aspectRatioB,
        hasImageA: widget.effectiveImageUrlsA.isNotEmpty,
        hasImageB: widget.effectiveImageUrlsB.isNotEmpty,
      );
      
      // 전역 캐시에 저장 - 화면 너비 포함
      final screenWidth = MediaQuery.sizeOf(context).width.toInt();
      final cacheKey = '${widget.messageId ?? widget.postId}_$screenWidth';
      _globalBoxSizesCache[cacheKey] = _cachedBoxSizes!;
      
      // LRU 캐시 관리 - 최대 100개 유지
      if (_globalBoxSizesCache.length > 100) {
        _globalBoxSizesCache.remove(_globalBoxSizesCache.keys.first);
      }
    }
    
    // 단일 이미지 모드 체크 (B가 이미지 없이 텍스트만 있을 때)
    final bool hasOnlyTextB = widget.effectiveImageUrlsB.isEmpty && widget.optionBText.isNotEmpty;
    
    // 단일 이미지 모드일 때는 하나의 박스만 표시
    if (hasOnlyTextB) {
      return _buildSingleImageBox(_cachedBoxSizes!);
    }
    
    // 일반 상태
    if (layoutType == LayoutType.horizontal) {
      return _buildHorizontalLayout(_cachedBoxSizes!);
    } else {
      return _buildVerticalLayout(_cachedBoxSizes!);
    }
  }

  Widget _buildHorizontalLayout(BoxSizes boxSizes) {
    return SizedBox(
      height: boxSizes.unifiedHeight,
      child: Row(
        children: [
          Expanded(
            child: _buildSmartOptionBox(
              label: 'A',
              text: widget.optionAText,
              imageUrl: widget.optionAImage,
              imageUrls: widget.effectiveImageUrlsA,
              color: const Color(0xFFFF6B6B),
              aspectRatio: widget.aspectRatioA,
              isSingleImageMode: false,
              dualModeSecondTitle: null,
              boxHeight: boxSizes.unifiedHeight,  // 높이 전달
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _buildSmartOptionBox(
              label: 'B',
              text: widget.optionBText,
              imageUrl: widget.optionBImage,
              imageUrls: widget.effectiveImageUrlsB,
              color: const Color(0xFF4ECDC4),
              aspectRatio: widget.aspectRatioB,
              isSingleImageMode: false,
              dualModeSecondTitle: null,
              boxHeight: boxSizes.unifiedHeight,  // 높이 전달
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(BoxSizes boxSizes) {
    final unifiedHeight = boxSizes.unifiedHeight;
    
    return Column(
      children: [
        SizedBox(
          height: unifiedHeight,
          child: _buildSmartOptionBox(
            label: 'A',
            text: widget.optionAText,
            imageUrl: widget.optionAImage,
            imageUrls: widget.effectiveImageUrlsA,
            color: const Color(0xFFFF6B6B),
            aspectRatio: widget.aspectRatioA,
            isSingleImageMode: false,
            dualModeSecondTitle: null,
            boxHeight: unifiedHeight,  // 높이 전달
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: unifiedHeight,
          child: _buildSmartOptionBox(
            label: 'B',
            text: widget.optionBText,
            imageUrl: widget.optionBImage,
            imageUrls: widget.effectiveImageUrlsB,
            color: const Color(0xFF4ECDC4),
            aspectRatio: widget.aspectRatioB,
            isSingleImageMode: false,
            dualModeSecondTitle: null,
            boxHeight: unifiedHeight,  // 높이 전달
          ),
        ),
      ],
    );
  }
  
  Widget _buildSmartOptionBox({
    required String label,
    required String text,
    String? imageUrl,
    List<String>? imageUrls,
    required Color color,
    double? aspectRatio,
    bool isSingleImageMode = false,
    String? dualModeSecondTitle,
    double? boxHeight,  // 박스 높이 파라미터 추가
  }) {
    // 멀티이미지 우선 사용
    final effectiveImageUrl = (imageUrls != null && imageUrls.isNotEmpty) 
        ? imageUrls.first : imageUrl;
    final hasMultipleImages = (imageUrls != null && imageUrls.length > 1);
    
    // 효과적인 높이 계산 (폴백 처리)
    final double effectiveHeight = boxHeight ?? 200;  // 기본값 200px
    
    return Semantics(
      label: '옵션 $label: $text',
      image: effectiveImageUrl != null,
      button: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
        height: effectiveHeight,  // 고정 높이 설정
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              SizedBox.expand(  // Positioned.fill + AspectRatio 제거, SizedBox.expand로 교체
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: CachedNetworkImage(
                    imageUrl: effectiveImageUrl,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,  // 중앙 정렬로 일관성 확보
                    // 통합 이미지 캐시 서비스 사용
                    memCacheWidth: _calculateDynamicCacheWidth(),
                    maxWidthDiskCache: UnifiedImageCacheService.MAX_CACHE_WIDTH,
                    fadeInDuration: const Duration(milliseconds: 200),
                    fadeOutDuration: const Duration(milliseconds: 100),
                    placeholder: (context, url) => Container(
                      color: color.withValues(alpha: 0.05),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: color.withValues(alpha: 0.05),
                      child: Center(
                        child: Icon(
                          Icons.error_outline,
                          color: color.withValues(alpha: 0.6),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 그라데이션 오버레이
            if (effectiveImageUrl != null && effectiveImageUrl.isNotEmpty)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isSingleImageMode
                          ? [
                              Colors.black.withValues(alpha: 0.85),
                              Colors.transparent,
                            ]
                          : [
                              Colors.black.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                      stops: isSingleImageMode
                          ? const [0.0, 0.3]  // 단일: 30%까지
                          : const [0.0, 0.2],  // 멀티: 20%까지
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSingleImageMode && dualModeSecondTitle != null) ...[
                    // 단일 이미지 모드: A/B 타이틀 함께 표시
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A 옵션
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B6B).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'A',
                                style: VersusTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                text,
                                style: VersusTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // B 옵션
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4ECDC4).withValues(alpha: 0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'B',
                                style: VersusTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                dualModeSecondTitle,
                                style: VersusTextStyles.bodySmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ] else ...[
                    // 일반 모드: 각 옵션 텍스트만 표시
                    Row(
                      children: [
                        // 멀티이미지에서도 A/B 라벨 표시
                        if (!isSingleImageMode)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: label == 'A' 
                                  ? const Color(0xFFFF6B6B).withValues(alpha: 0.8)
                                  : const Color(0xFF4ECDC4).withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              label,
                              style: VersusTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        if (!isSingleImageMode)
                          const SizedBox(width: 6),
                        Expanded(
                          child: widget.searchQuery != null && widget.searchQuery!.isNotEmpty
                              ? _highlightText(
                                  text,
                                  VersusTextStyles.bodySmall.copyWith(
                                    color: effectiveImageUrl != null ? Colors.white : color,
                                    fontWeight: FontWeight.w600,
                                    shadows: effectiveImageUrl != null
                                        ? [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                )
                              : Text(
                                  text,
                                  style: VersusTextStyles.bodySmall.copyWith(
                                    color: effectiveImageUrl != null ? Colors.white : color,
                                    fontWeight: FontWeight.w600,
                                    shadows: effectiveImageUrl != null
                                        ? [
                                            Shadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: 4,
                                            ),
                                          ]
                                        : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // 멀티이미지 인디케이터
            if (hasMultipleImages)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSingleImageBox(BoxSizes boxSizes) {
    // 단일 이미지 모드: B가 텍스트만 있을 때 하나의 박스에 A/B 모두 표시
    return SizedBox(
      height: boxSizes.unifiedHeight,
      child: _buildSmartOptionBox(
        label: 'A',  // 라벨은 A로 표시하지만
        text: widget.optionAText,
        imageUrl: widget.optionAImage,
        imageUrls: widget.effectiveImageUrlsA,
        color: const Color(0xFFFF6B6B),
        aspectRatio: widget.aspectRatioA,
        isSingleImageMode: true,
        dualModeSecondTitle: widget.optionBText,  // B 옵션 텍스트도 함께 전달
        boxHeight: boxSizes.unifiedHeight,  // 높이 전달
      ),
    );
  }

  LayoutType _getLayoutType() {
    // 캐시된 값이 있으면 반환
    if (_cachedLayoutType != null) {
      return _cachedLayoutType!;
    }
    
    final hasImageA = widget.optionAImage != null || (widget.optionAImages?.isNotEmpty ?? false);
    final hasImageB = widget.optionBImage != null || (widget.optionBImages?.isNotEmpty ?? false);
    
    // aspectRatio가 없거나 기본값(1.0)인 경우 fallback 로직 사용
    // 1.0은 종종 기본값으로 설정되므로 실제 정사각형이 아닐 수 있음
    final bool isAspectRatioMissing = 
        (widget.aspectRatioA == null || widget.aspectRatioA == 1.0) && 
        (widget.aspectRatioB == null || widget.aspectRatioB == 1.0);
    
    if (isAspectRatioMissing) {
      if (hasImageA && hasImageB) {
        // 이미지가 둘 다 있으면 가로 배치 (기본값)
        _cachedLayoutType = LayoutType.horizontal;
        return _cachedLayoutType!;
      } else if (hasImageA || hasImageB) {
        // 이미지가 하나만 있으면 single
        _cachedLayoutType = LayoutType.single;
        return _cachedLayoutType!;
      } else {
        // 이미지가 없으면 가로 레이아웃
        _cachedLayoutType = LayoutType.horizontal;
        return _cachedLayoutType!;
      }
    }
    
    // AspectRatioAnalyzer를 사용하여 최적 레이아웃 결정
    final layout = AspectRatioAnalyzer.getOptimalLayout(
      widget.aspectRatioA,
      widget.aspectRatioB,
    );
    
    _cachedLayoutType = layout;
    return _cachedLayoutType!;
  }
  
  
  /// 동적 캐시 너비 계산
  int _calculateDynamicCacheWidth() {
    // 캐시된 박스 크기가 있으면 사용
    if (_cachedBoxSizes != null) {
      final layoutType = _getLayoutType();
      
      if (layoutType == LayoutType.horizontal) {
        // 가로 배치: 박스 너비 기준
        final width = MediaQuery.of(context).size.width / 2;
        return UnifiedImageCacheService.calculateMemCacheWidth(width);
      } else if (layoutType == LayoutType.vertical) {
        // 세로 배치: 통일된 높이 기준
        final height = _cachedBoxSizes!.unifiedHeight;
        return UnifiedImageCacheService.calculateMemCacheWidth(height);
      } else {
        // 단일 이미지: 전체 너비 기준
        final width = MediaQuery.of(context).size.width * 0.9;
        return UnifiedImageCacheService.calculateMemCacheWidth(width);
      }
    }
    
    // 기본값
    return UnifiedImageCacheService.MIN_CACHE_WIDTH;
  }
  
  // 타이머 표시 여부 판단
  bool _shouldShowTimer(String status, DateTime? endTime) {
    return (status == 'votingRequest' || status == 'inProgress') && 
           endTime != null;
  }
  
  // 액션 버튼 표시 여부 판단
  bool _shouldShowAction(String status) {
    return status == 'votingRequest' || status == 'inProgress';
  }
  
  // 결과 표시 여부 판단
  bool _shouldShowResult(String status) {
    return status == 'completed';
  }
  
  // 타이머 위젯 빌드 (통합 상태의 남은 시간 사용)
  Widget _buildTimer(VoteStateData stateData) {
    // 이미 계산된 남은 시간 사용
    if (stateData.remainingTime != null && stateData.remainingTime!.inSeconds > 0) {
      final duration = stateData.remainingTime!;
      final minutes = duration.inMinutes;
      final seconds = duration.inSeconds % 60;
      final remainingText = '${minutes}분 ${seconds}초 남음';
      
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: VersusColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            remainingText,
            style: VersusTextStyles.bodySmall.copyWith(
              color: VersusColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }
    
    // 타이머 만료
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.timer_off,
          size: 16,
          color: VersusColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          '투표 종료',
          style: VersusTextStyles.bodySmall.copyWith(
            color: VersusColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton(String status) {
    // 버튼 텍스트 결정
    String buttonText;
    if (widget.isMe) {
      // 내가 만든 투표
      buttonText = '투표 현황 보기';
    } else {
      // 남이 만든 투표
      buttonText = status == 'votingRequest' ? '투표하기' : '투표 현황 보기';
    }
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleActionTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: VersusColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: VersusSpacing.sm,
          ),
        ),
        child: Text(
          buttonText,
          style: VersusTextStyles.buttonMedium.copyWith(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  Widget _buildResults() {
    final displayName = widget.currentUserName ?? '나';
    
    return Container(
      padding: const EdgeInsets.all(VersusSpacing.sm),
      decoration: BoxDecoration(
        color: VersusColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '피클! 피클! 피클!',
              style: TextStyle(
                fontSize: 18,
                color: VersusColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              '$displayName님 결과를 보러오세요!',
              style: TextStyle(
                fontSize: 14,
                color: VersusColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  
  
  void _handleTap() {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    if (widget.cardStatus == 'votingRequest') {
      _showVotingDialog();
    } else {
      // 게시물 페이지로 이동
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
    
    // 짧은 딜레이 후 상태 리셋
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }
  
  void _handleActionTap() {
    if (_isVoting) return;
    
    setState(() {
      _isVoting = true;
    });
    
    if (widget.cardStatus == 'votingRequest') {
      _showVotingDialog();
    } else {
      context.pushNamed(
        'PostView',
        queryParameters: {'postId': widget.postId},
      );
    }
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _isVoting = false;
        });
      }
    });
  }
  
  void _showVotingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: VotingNotificationDialog(
          question: widget.title,
          optionA: widget.optionAText,
          optionB: widget.optionBText,
          imageUrlA: widget.optionAImage,
          imageUrlB: widget.optionBImage,
          imageUrlsA: widget.optionAImages,
          imageUrlsB: widget.optionBImages,
          aspectRatioA: widget.aspectRatioA,
          aspectRatioB: widget.aspectRatioB,
          onVote: (option) async {
            // 투표 처리
            await submitVote(option);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDismiss: (hasVoted) {
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
  
}