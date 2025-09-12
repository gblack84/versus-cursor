import 'dart:async';
import 'package:flutter/material.dart';

/// 투표 서비스 추상화 인터페이스
/// 
/// notifications 피처가 voting 피처의 구체적인 구현에 의존하지 않도록
/// 필요한 메서드들을 추상화합니다.
/// 
/// UI 표시, 투표 처리, 상태 관리 등 투표 관련 핵심 기능을 정의합니다.
abstract class IVoteService {
  /// 투표 알림 UI 표시
  /// 
  /// [context] - Flutter BuildContext
  /// [notification] - 표시할 투표 알림 정보
  /// [onVote] - 투표 선택 시 콜백 (A: true, B: false)
  /// [onDismiss] - 알림 닫기 시 콜백 (투표했는지 여부 전달)
  Future<void> showVotingNotification({
    required BuildContext context,
    required IVoteNotification notification,
    required Future<void> Function(bool optionA) onVote,
    required void Function(bool hasVoted) onDismiss,
  });
  
  /// 사용자가 특정 포스트에 투표했는지 확인
  Future<bool> hasUserVoted({
    required String userId,
    required String postId,
  });
  
  /// 사용자의 투표 기록 조회
  /// 
  /// Returns A 옵션에 투표했으면 true, B 옵션이면 false, 투표하지 않았으면 null
  Future<bool?> getUserVoteOption({
    required String userId,
    required String postId,
  });
  
  /// 투표 실행
  /// 
  /// [userId] - 투표자 ID
  /// [postId] - 투표할 포스트 ID
  /// [optionA] - true면 A 옵션, false면 B 옵션
  /// [notificationId] - 알림 ID (선택사항)
  Future<VoteResult> castVote({
    required String userId,
    required String postId,
    required bool optionA,
    String? notificationId,
  });
  
  /// 투표 제출 (레거시 호환용)
  /// 
  /// GlobalNotificationManager에서 사용하는 메서드
  /// [postId] - 투표할 포스트 ID
  /// [userId] - 투표자 ID  
  /// [choice] - 'A' 또는 'B'
  /// [messageId] - 메시지 ID (선택사항)
  /// [chatId] - 채팅 ID (선택사항)
  /// [onError] - 에러 콜백 (선택사항)
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  });
  
  /// 투표 취소
  /// 
  /// 투표 제한 시간 내에서만 가능합니다.
  Future<VoteResult> cancelVote({
    required String userId,
    required String postId,
  });
  
  /// 포스트의 실시간 투표 상태 감시
  /// 
  /// 투표 수, 투표 상태 변경 등을 실시간으로 감지합니다.
  Stream<IVoteStatus> watchVoteStatus(String postId);
  
  /// 투표 타이머 관리
  /// 
  /// 투표 시작/종료 시간을 관리하고 타이머를 표시합니다.
  Stream<Duration> watchVoteTimer(String postId);
  
  /// UI 컨텍스트 설정
  /// 
  /// 알림 표시를 위한 BuildContext를 설정합니다.
  void setUIContext(BuildContext context);
  
  /// UI 컨텍스트 존재 여부
  bool get hasUIContext;
  
  /// 투표 시스템 초기화
  Future<void> initialize();
  
  /// 리소스 정리
  void dispose();
}

/// 투표 알림 정보 인터페이스
abstract class IVoteNotification {
  String get id;
  String get postId;
  String get userId;
  String get type;
  Map<String, dynamic> get data;
  DateTime get createdAt;
  
  // 투표 옵션 정보
  String get optionATitle;
  String get optionBTitle;
  List<String> get optionAImageUrls;
  List<String> get optionBImageUrls;
  
  // 타이머 정보
  DateTime? get voteStartTime;
  DateTime? get voteEndTime;
  
  // 레이아웃 정보
  String? get layoutType;
}

/// 투표 상태 정보 인터페이스
abstract class IVoteStatus {
  String get postId;
  int get votesA;
  int get votesB;
  VoteStatus get status;
  DateTime? get startTime;
  DateTime? get endTime;
  
  /// 총 투표 수
  int get totalVotes => votesA + votesB;
  
  /// A 옵션 득표율 (0.0 ~ 1.0)
  double get optionARate {
    if (totalVotes == 0) return 0.0;
    return votesA / totalVotes;
  }
  
  /// B 옵션 득표율 (0.0 ~ 1.0)
  double get optionBRate {
    if (totalVotes == 0) return 0.0;
    return votesB / totalVotes;
  }
  
  /// 남은 시간 (투표 진행 중일 때)
  Duration? get remainingTime {
    if (status != VoteStatus.active || endTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(endTime!)) return Duration.zero;
    return endTime!.difference(now);
  }
}

/// 투표 결과
class VoteResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;
  
  const VoteResult({
    required this.success,
    this.error,
    this.data,
  });
  
  factory VoteResult.success([Map<String, dynamic>? data]) {
    return VoteResult(success: true, data: data);
  }
  
  factory VoteResult.failure(String error) {
    return VoteResult(success: false, error: error);
  }
}

/// 투표 옵션
enum VoteOption {
  optionA,
  optionB,
}

/// 투표 상태
enum VoteStatus {
  pending,
  active,
  completed,
  expired,
  cancelled,
}

/// 투표 제한 사유
enum VoteRestrictionReason {
  alreadyVoted,
  voteExpired,
  voteNotStarted,
  postNotFound,
  userNotFound,
  systemError,
}