import 'package:flutter/material.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/voting/domain/models/versus_box_size_data.dart';

/// 투표 UI 처리를 위한 델리게이트 인터페이스
///
/// GlobalNotificationManager와 UI 계층 간의 의존성을 분리하기 위한 추상화
abstract class IVoteUIDelegate {
  /// 투표 요청을 UI에 표시
  ///
  /// [notification] 표시할 알림 객체
  /// [context] UI 컨텍스트
  /// [onVote] 투표 선택 시 콜백
  /// [onDismiss] 알림 닫기 시 콜백
  Future<void> showVotingNotification({
    required domain.Notification notification,
    required BuildContext context,
    required String question,
    required String optionA,
    required String optionB,
    String? imageUrlA,
    String? imageUrlB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    String? description,
    String? authorName,
    VersusBoxSizeData? sizeData,
    required Future<void> Function(String selectedOption) onVote,
    required void Function(bool hasVoted) onDismiss,
  });

  /// 현재 표시 가능한 UI 컨텍스트가 있는지 확인
  bool isUIContextAvailable();

  /// UI 컨텍스트 준비 대기
  Future<BuildContext?> waitForUIContext(
      {Duration timeout = const Duration(seconds: 10)});
}