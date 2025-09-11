import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '/core/types/layout_type.dart';
import '/core/domain/ports/i_user_service.dart';
import '/features/notifications/domain/models/notification.dart' as domain;
import '/features/voting/presentation/dialogs/voting_dialog.dart';
import '/features/voting/domain/models/versus_box_size_data.dart';
import '/features/voting/domain/ports/i_vote_ui_delegate.dart';
import '/core_exports.dart';
import '/features/posts/presentation/utils/debug_helper.dart';

/// 투표 UI 관리자
///
/// Presentation 레이어에서 투표 UI 표시를 담당합니다.
/// IVoteUIDelegate 인터페이스를 구현하여 비즈니스 로직과 분리합니다.
class VoteUIManager implements IVoteUIDelegate {
  static final VoteUIManager _instance =
      VoteUIManager._internal();
  static VoteUIManager get instance => _instance;

  VoteUIManager._internal();

  /// 현재 표시 중인 다이얼로그
  bool _isShowingDialog = false;

  /// 컨텍스트 (Optional - Coordinator에서 설정)
  BuildContext? _context;

  /// User Service (lazy initialized)
  IUserService? _userService;
  IUserService get userService =>
      _userService ??= GetIt.instance<IUserService>();

  /// 컨텍스트 설정
  void setContext(BuildContext context) {
    _context = context;
  }

  /// 컨텍스트 확인
  bool get hasContext =>
      _context != null || appNavigatorKey.currentContext != null;

  /// 리소스 정리
  void dispose() {
    _context = null;
    _isShowingDialog = false;
  }

  @override
  bool isUIContextAvailable() {
    final context = appNavigatorKey.currentContext;
    final isAuthenticated = userService.isAuthenticated;
    return context != null && isAuthenticated;
  }

  @override
  Future<BuildContext?> waitForUIContext(
      {Duration timeout = const Duration(seconds: 10)}) async {
    final endTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(endTime)) {
      final context = appNavigatorKey.currentContext;
      final isAuthenticated = userService.isAuthenticated;

      if (context != null && isAuthenticated) {
        return context;
      }

      await Future.delayed(const Duration(milliseconds: 500));
    }

    return null;
  }

  @override
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
  }) async {
    if (_isShowingDialog) {
      DebugHelper.warning('이미 다이얼로그 표시 중', tag: 'VoteUIManager');
      return;
    }

    _isShowingDialog = true;

    try {
      await _showVotingDialog(
        notification: notification,
        context: context,
        question: question,
        optionA: optionA,
        optionB: optionB,
        imageUrlA: imageUrlA,
        imageUrlB: imageUrlB,
        imageUrlsA: imageUrlsA,
        imageUrlsB: imageUrlsB,
        description: description,
        authorName: authorName,
        sizeData: sizeData,
        onVote: onVote,
        onDismiss: onDismiss,
      );
    } finally {
      _isShowingDialog = false;
    }
  }

  /// 투표 다이얼로그 표시 (내부 메서드)
  Future<void> _showVotingDialog({
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
  }) async {
    final notificationId = notification.id;

    DebugHelper.logOnce('notif_show_$notificationId',
        '투표 요청 표시: ${DebugHelper.maskSensitive(notificationId)}',
        tag: 'VoteUIManager', level: LogLevel.INFO);

    // 기본 VersusBoxSizeData 생성 (필요한 경우)
    final finalSizeData = sizeData ?? _createDefaultSizeData(context);

    // showDialog를 사용하여 알림 표시
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(dialogContext).size.width * 0.04,
              vertical: MediaQuery.of(dialogContext).size.height * 0.05),
          alignment: Alignment.topCenter,
          child: VotingNotificationDialog(
            question: question,
            optionA: optionA,
            optionB: optionB,
            imageUrlA: imageUrlA,
            imageUrlB: imageUrlB,
            imageUrlsA: imageUrlsA,
            imageUrlsB: imageUrlsB,
            description: description,
            sizeData: finalSizeData,
            showDebugInfo: false,
            authorName: authorName,
            onVote: (selectedOption) async {
              DebugHelper.info('투표 완료: $selectedOption',
                  tag: 'VoteUIManager');

              // 다이얼로그 먼저 닫기
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              // 투표 처리
              await onVote(selectedOption);
            },
            onDismiss: (hasVoted) {
              // 다이얼로그 닫기
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }

              // 닫기 처리
              onDismiss(hasVoted);
            },
          ),
        );
      },
    );

    DebugHelper.info('투표 다이얼로그 닫힘', tag: 'VoteUIManager');
  }

  /// 기본 VersusBoxSizeData 생성
  VersusBoxSizeData _createDefaultSizeData(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);

    return VersusBoxSizeData(
      layoutType: LayoutType.horizontal,
      aspectRatioA: null,
      aspectRatioB: null,
      originalSizeA: baseSize,
      originalSizeB: baseSize,
      screenWidth: screenWidth,
      createdAt: DateTime.now(),
      hasImageA: false,
      hasImageB: false,
    );
  }

  /// 컨텍스트별 VersusBoxSizeData 생성
  VersusBoxSizeData? createSizeDataFromAspectRatios({
    required BuildContext context,
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
    bool hasImageA = false,
    bool hasImageB = false,
  }) {
    if (aspectRatioA == null && aspectRatioB == null) {
      return null;
    }

    try {
      // 레이아웃 타입 파싱
      LayoutType parsedLayoutType = LayoutType.horizontal;
      if (layoutType != null) {
        parsedLayoutType = LayoutType.values.firstWhere(
          (e) => e.name == layoutType,
          orElse: () => LayoutType.horizontal,
        );
      }

      // 기본 박스 크기
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;
      final baseSize = Size(screenWidth * 0.7, screenHeight * 0.5);

      return VersusBoxSizeData(
        layoutType: parsedLayoutType,
        aspectRatioA: aspectRatioA,
        aspectRatioB: aspectRatioB,
        originalSizeA: baseSize,
        originalSizeB: baseSize,
        screenWidth: screenWidth,
        createdAt: DateTime.now(),
        hasImageA: hasImageA,
        hasImageB: hasImageB,
      );
    } catch (e) {
      DebugHelper.warning('VersusBoxSizeData 생성 실패',
          tag: 'VoteUIManager');
      return null;
    }
  }

  /// 다이얼로그 표시 여부 확인
  bool get isShowingDialog => _isShowingDialog;
}
