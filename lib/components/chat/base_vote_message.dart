import 'dart:async';
import 'package:flutter/material.dart';
import '/design_system/design_system.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/services/vote_status_service.dart';
import '/utils/vote_message_helper.dart';

/// 투표 메시지의 공통 로직을 담은 추상 클래스
abstract class BaseVoteMessage extends StatefulWidget {
  const BaseVoteMessage({
    super.key,
    required this.postId,
    required this.title,
    this.description,
    required this.optionAText,
    required this.optionBText,
    this.optionAImage,
    this.optionBImage,
    this.optionAImages,
    this.optionBImages,
    this.aspectRatioA,
    this.aspectRatioB,
    required this.cardStatus,
    this.voteEndTime,
    this.userVotes,
    this.voteResults,
    required this.isMe,
    this.timestamp,
    required this.messageType,
    this.messageId,
    this.chatId,
    this.currentUserName,
  });

  final String postId;
  final String title;
  final String? description;
  final String optionAText;
  final String optionBText;
  final String? optionAImage;
  final String? optionBImage;
  final List<String>? optionAImages;
  final List<String>? optionBImages;
  final double? aspectRatioA;
  final double? aspectRatioB;
  final String cardStatus;
  final DateTime? voteEndTime;
  final Map<String, dynamic>? userVotes;
  final Map<String, dynamic>? voteResults;
  final bool isMe;
  final DateTime? timestamp;
  final String messageType;
  final String? messageId;
  final String? chatId;
  final String? currentUserName;

  /// 현재 사용자가 투표했는지 확인
  bool get hasCurrentUserVoted {
    if (userVotes == null) return false;
    return userVotes!.containsKey(currentUserUid);
  }

  /// 현재 사용자의 투표 선택
  String? get currentUserChoice {
    if (userVotes == null) return null;
    final vote = userVotes![currentUserUid] as Map<String, dynamic>?;
    return vote?['option'] as String?;
  }

  /// 현재 사용자의 투표 시간
  DateTime? get currentUserVoteTime {
    if (userVotes == null) return null;
    final vote = userVotes![currentUserUid] as Map<String, dynamic>?;
    return vote?['voted_at'] as DateTime?;
  }

  /// A박스의 이미지 URL 리스트 반환
  List<String> get effectiveImageUrlsA {
    if (optionAImages != null && optionAImages!.isNotEmpty) {
      return optionAImages!;
    }
    if (optionAImage != null && optionAImage!.isNotEmpty) {
      return [optionAImage!];
    }
    return [];
  }

  /// B박스의 이미지 URL 리스트 반환
  List<String> get effectiveImageUrlsB {
    if (optionBImages != null && optionBImages!.isNotEmpty) {
      return optionBImages!;
    }
    if (optionBImage != null && optionBImage!.isNotEmpty) {
      return [optionBImage!];
    }
    return [];
  }

  /// 현재 사용자의 투표 상태 가져오기
  String get currentUserVoteStatus {
    final status = VoteStatusService.getUserVoteStatus(
      userVotes: userVotes,
      userId: currentUserUid,
      cardStatus: cardStatus,
      voteEndTime: voteEndTime,
    );
    
    // 로그는 VoteStatusService에서 이미 출력하므로 제거
    // 중복 로그 방지를 위해 여기서는 출력하지 않음
    
    return status;
  }
}

/// 투표 메시지 상태 관리를 위한 mixin
mixin BaseVoteMessageStateMixin<T extends BaseVoteMessage> on State<T> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (widget.voteEndTime != null && 
        (widget.cardStatus == 'voting_request' || widget.cardStatus == 'in_progress')) {
      _updateRemainingTime();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _updateRemainingTime();
      });
    }
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    final endTime = widget.voteEndTime;
    
    if (endTime != null && endTime.isAfter(now)) {
      final newRemainingTime = endTime.difference(now);
      
      // 표시되는 시간이 실제로 변경될 때만 setState 호출
      // 초 단위가 아닌 분:초 형식으로 표시되므로, 실제 표시가 바뀔 때만 업데이트
      final oldFormatted = formatRemainingTime();
      _remainingTime = newRemainingTime;
      final newFormatted = formatRemainingTime();
      
      if (oldFormatted != newFormatted) {
        setState(() {
          _remainingTime = newRemainingTime;
        });
      }
    } else {
      _timer?.cancel();
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = Duration.zero;
        });
      }
    }
  }

  /// 남은 시간 포맷팅
  String formatRemainingTime() {
    if (_remainingTime.inSeconds <= 0) {
      return '투표 종료';
    }
    
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    return '${minutes}분 ${seconds}초 남음';
  }

  /// 시간 표시 여부
  bool shouldShowTimer() {
    return (widget.cardStatus == 'voting_request' || 
            widget.cardStatus == 'in_progress') &&
           widget.voteEndTime != null &&
           _remainingTime.inSeconds > 0;
  }

  /// 액션 버튼 표시 여부
  bool shouldShowAction() {
    return widget.cardStatus == 'voting_request' || 
           (widget.cardStatus == 'in_progress' && widget.messageType == 'vote_created');
  }

  /// 결과 표시 여부
  bool shouldShowResult() {
    return widget.cardStatus == 'completed' && widget.voteResults != null;
  }

  /// 투표 상태 정보 가져오기
  Map<String, dynamic> getStatusInfo() {
    final statusInfo = <String, dynamic>{};
    
    switch (widget.cardStatus) {
      case 'voting_request':
        statusInfo['text'] = '피클요청';
        statusInfo['color'] = VersusColors.primary;
        statusInfo['icon'] = Icons.how_to_vote;
        break;
      case 'in_progress':
        // 사용자가 투표했는지 확인 (VoteCardMessage에서만 적용)
        if (widget.hasCurrentUserVoted) {
          statusInfo['text'] = 'Pick 완료!(진행중)';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.check_circle_outline;
        } else {
          statusInfo['text'] = '진행중';
          statusInfo['color'] = Colors.blue;
          statusInfo['icon'] = Icons.timer;
        }
        break;
      case 'completed':
        statusInfo['text'] = '완료';
        statusInfo['color'] = VersusColors.success;
        statusInfo['icon'] = Icons.check_circle;
        break;
      case 'not_participated':
        statusInfo['text'] = '미참여';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.block;
        break;
      default:
        statusInfo['text'] = '알 수 없음';
        statusInfo['color'] = VersusColors.textSecondary;
        statusInfo['icon'] = Icons.help;
    }
    
    // VoteMessageHelper의 아이콘 사용
    statusInfo['icon'] = VoteMessageHelper.getStatusIcon(widget.cardStatus);
    
    return statusInfo;
  }

  /// 시간 포맷팅
  String formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return '방금';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }

  /// 투표 제출
  Future<void> submitVote(String option) async {
    try {
      await VoteStatusService.submitVote(
        postId: widget.postId,
        userId: currentUserUid,
        choice: option,
        messageId: widget.messageId,
        chatId: widget.chatId,
        onError: (error) {
          // 스낵바로 에러 표시
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
      );
    } catch (e) {
      // 사용자에게 에러 표시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('투표 처리 중 오류가 발생했습니다'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      rethrow;
    }
  }

  /// 상태 배지 위젯 빌드
  Widget buildStatusBadge(Map<String, dynamic> statusInfo) {
    return Container(
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
    );
  }

  /// 타이머 위젯 빌드
  Widget buildTimer() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: VersusSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: VersusColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timer,
            size: 14,
            color: VersusColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            formatRemainingTime(),
            style: VersusTextStyles.labelSmall.copyWith(
              color: VersusColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// 타임스탬프 위젯 빌드
  Widget buildTimestamp() {
    if (widget.timestamp == null) return const SizedBox.shrink();
    
    return Text(
      formatTime(widget.timestamp!),
      style: VersusTextStyles.labelSmall.copyWith(
        fontSize: 11,
        color: VersusColors.textSecondary.withValues(alpha: 0.8),
      ),
    );
  }
}