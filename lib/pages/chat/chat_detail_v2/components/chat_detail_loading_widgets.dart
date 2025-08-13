import 'package:flutter/material.dart';
import '/design_system/design_system.dart';

/// 채팅 상세 페이지의 로딩 관련 위젯 모음
class ChatDetailLoadingWidgets {
  /// 초기 로딩 인디케이터
  static Widget buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              VersusColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '메시지를 불러오는 중...',
            style: VersusTextStyles.bodyMedium.copyWith(
              color: VersusColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// 더 많은 메시지 로딩 인디케이터
  static Widget buildLoadingMoreIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  VersusColors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '이전 메시지 불러오는 중...',
              style: TextStyle(
                color: VersusColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 빈 채팅 리스트 빌더
  static Widget buildEmptyChatList(bool isAiChat) {
    return Center(
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
              isAiChat 
                  ? 'AI 피클과 대화를 시작해보세요'
                  : '메시지를 보내서 대화를 시작하세요',
              style: VersusTextStyles.headingMedium.copyWith(
                color: VersusColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAiChat
                  ? '질문을 입력하면 AI가 답변해드립니다'
                  : '첫 메시지를 보내보세요',
              style: VersusTextStyles.bodyMedium.copyWith(
                color: VersusColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 사용자 로딩 중 화면
  static Widget buildUserLoadingScreen() {
    return Scaffold(
      backgroundColor: VersusColors.backgroundPrimary,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}