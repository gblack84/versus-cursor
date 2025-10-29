/// 📌 현재 상태: 미사용 (TODO: 구현 필요)
///
/// ⚠️ 문제점:
/// - 채팅방에서 투표 카드 클릭 시 투표 제출이 작동하지 않음
/// - chat_message_builder.dart에서 VoteCardWidget 생성 시 onVote 콜백을 제공하지 않음
/// - 투표 다이얼로그만 표시되고 실제 투표는 제출되지 않음
///
/// ✅ 이 파일의 역할:
/// - 채팅 메시지로 표시된 투표 카드에서 직접 투표 처리
/// - 재투표 및 미참여자 투표 지원
/// - voteSubmissionControllerProvider를 통한 완전한 투표 제출 로직 제공
///
/// 🔧 구현 방법:
///
/// Option 1: 이 파일을 직접 사용 (권장)
/// ```dart
/// // chat_message_builder.dart에서:
/// class VoteRequestMessage extends BaseVoteMessage with BaseVoteMessageStateMixin {
///   @override
///   Widget build(BuildContext context) {
///     return GestureDetector(
///       onTap: () => submitVote('A'),  // 직접 투표 처리
///       child: VoteCardWidget(...),
///     );
///   }
/// }
/// ```
///
/// Option 2: VoteCardWidget에 onVote 콜백 제공
/// ```dart
/// // chat_message_builder.dart에서:
/// VoteCardWidget(
///   // ... 기존 파라미터들 ...
///   onVote: (option) async {
///     final controller = ref.read(voteSubmissionControllerProvider);
///     await controller.submitVote(
///       postId: metadata['postId'],
///       userId: currentUserUid,
///       choice: option,
///       messageId: message.id,
///       chatId: chatId,
///     );
///   },
/// )
/// ```
///
/// 📊 현재 투표 플로우 분석:
///
/// ✅ 알림 플로우 (Firebase-Centric 라우팅 방식):
///   NotificationOverlayProvider
///     → Firebase에서 Post 데이터 읽기
///     → AlertDialog 표시
///     → context.push('/chatDetail?chatId=...') 라우팅
///     → 투표 페이지에서 직접 투표 처리
///
/// ❌ 채팅 플로우 (작동 안 함):
///   VoteCardWidget (onVote: null)
///     → VotingNotificationDialog
///     → widget.onVote!(option)
///     → null이므로 투표 제출 안 됨!
///
/// 🎯 구현 우선순위: HIGH (채팅방 투표 기능 완전 차단 상태)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '/core/design_system/design_system.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../providers/vote_providers.dart';

/// 채팅 메시지로 표시되는 투표 카드의 기본 클래스
///
/// Riverpod ConsumerStatefulWidget으로 구현되어 Provider 접근 가능
///
/// 📌 사용 예시:
/// ```dart
/// class VoteRequestMessage extends BaseVoteMessage with BaseVoteMessageStateMixin {
///   const VoteRequestMessage({
///     super.key,
///     required super.postId,
///     required super.messageId,
///     required super.chatId,
///     // ... 기타 파라미터
///   });
///
///   @override
///   Widget build(BuildContext context) {
///     return Column(
///       children: [
///         VoteCardWidget(...),
///         Row(
///           children: [
///             ElevatedButton(
///               onPressed: () => submitVote('A'),
///               child: Text('A에 투표'),
///             ),
///             ElevatedButton(
///               onPressed: () => submitVote('B'),
///               child: Text('B에 투표'),
///             ),
///           ],
///         ),
///       ],
///     );
///   }
/// }
/// ```
abstract class BaseVoteMessage extends ConsumerStatefulWidget {
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
/// Riverpod ConsumerState와 함께 사용되며, ref를 통해 Provider 접근 가능
/// VoteStateCoordinator와 함께 사용되며, 타이머 관리는 VoteStateCoordinator가 담당
mixin BaseVoteMessageStateMixin<T extends BaseVoteMessage> on ConsumerState<T> {
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

  // Firebase Auth helper
  String get currentUserUid => FirebaseAuth.instance.currentUser?.uid ?? '';

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
  ///
  /// 📌 TODO: 이 메서드를 활성화하려면 위의 구현 방법 중 하나를 선택하세요
  ///
  /// Riverpod VoteSubmissionController를 사용하여 투표 처리:
  /// - userId는 GetIt의 AuthContract에서 자동 획득
  /// - 에러 시 SnackBar로 사용자에게 피드백 제공
  /// - 성공 시 자동으로 UI 업데이트 (VoteStateCoordinator를 통해)
  ///
  /// 사용 예시:
  /// ```dart
  /// ElevatedButton(
  ///   onPressed: () => submitVote('A'),
  ///   child: Text('A에 투표'),
  /// )
  /// ```
  Future<void> submitVote(String option) async {
    // VoteSubmissionController를 통해 투표 제출
    final controller = ref.read(voteSubmissionControllerProvider);
    final result = await controller.submitVote(
      postId: widget.postId,
      userId: currentUserUid,
      choice: option,
      messageId: widget.messageId,
      chatId: widget.chatId,
    );

    // 결과에 따라 UI 피드백 표시
    if (mounted) {
      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
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
