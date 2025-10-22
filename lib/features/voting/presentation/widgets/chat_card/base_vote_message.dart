import 'package:flutter/material.dart';
import '/core/design_system/design_system.dart';
import 'package:get_it/get_it.dart';
import '/app/contracts/auth_contract.dart';
import '/features/voting/domain/services/vote_status_service.dart';

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
    this.senderProfileImageUrl,
    this.senderDisplayName,
    this.senderId,
    this.showSenderProfile = false,
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
  final String? senderProfileImageUrl;
  final String? senderDisplayName;
  final String? senderId;
  final bool showSenderProfile;

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
}

/// 투표 메시지 상태 관리를 위한 mixin
/// VoteStateCoordinator와 함께 사용되며, 타이머 관리는 VoteStateCoordinator가 담당
mixin BaseVoteMessageStateMixin<T extends BaseVoteMessage> on State<T> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(T oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
  }

  // AuthContract helper
  String get currentUserUid => GetIt.instance<AuthContract>().getCurrentUserId() ?? '';

  /// 현재 사용자가 투표했는지 확인
  bool get hasCurrentUserVoted {
    if (widget.userVotes == null) return false;
    return widget.userVotes!.containsKey(currentUserUid);
  }

  /// 현재 사용자의 투표 선택
  String? get currentUserChoice {
    if (widget.userVotes == null) return null;
    final vote = widget.userVotes![currentUserUid] as Map<String, dynamic>?;
    return vote?['option'] as String?;
  }

  /// 현재 사용자의 투표 시간
  DateTime? get currentUserVoteTime {
    if (widget.userVotes == null) return null;
    final vote = widget.userVotes![currentUserUid] as Map<String, dynamic>?;
    return vote?['votedAt'] as DateTime?;
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

  /// 타임스탬프 위젯 빌드
  Widget buildTimestamp() {
    if (widget.timestamp == null) return const SizedBox.shrink();

    return Text(
      formatTime(widget.timestamp!),
      style: VersusTextStyles.labelSmall.copyWith(
        fontSize: 12, // 11 → 12로 크기 증가
        color: VersusColors.textPrimary, // 훨씬 진한 색상으로 변경
      ),
    );
  }
}
