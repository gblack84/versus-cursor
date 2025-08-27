import 'package:flutter/material.dart';
import '../chat_detail_v2/chat_detail_controller_v2.dart';

/// 채팅 스크롤 관리 서비스
/// 스크롤 상태 추적 및 스크롤 동작 제어
class ChatScrollService {
  final ChatDetailControllerV2 _chatController;
  
  ScrollController? scrollController;
  bool isAtBottom = false;
  bool isNearBottom = false;
  
  ChatScrollService(this._chatController);
  
  /// 채팅 하단으로 스크롤
  void scrollToBottom() {
    if (_chatController.messages.isNotEmpty) {
      // flutter_chat_ui v2에서는 최신 메시지가 마지막
      final lastMessageId = _chatController.messages.last.id;
      _chatController.scrollToMessage(lastMessageId);
      updateScrollState(atBottom: true);
    }
  }
  
  /// 스크롤 상태 업데이트
  void updateScrollState({
    bool? atBottom,
    bool? nearBottom,
  }) {
    if (atBottom != null) {
      isAtBottom = atBottom;
    }
    if (nearBottom != null) {
      isNearBottom = nearBottom;
    }
  }
  
  /// 스크롤 리스너 설정
  void setupScrollListener(Function() onScrollChanged) {
    scrollController?.addListener(onScrollChanged);
  }
  
  /// 스크롤 위치 확인
  bool checkIfAtBottom() {
    if (scrollController == null) return false;
    
    final position = scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    
    // 하단에서 50픽셀 이내면 하단으로 간주
    return (maxScroll - currentScroll) <= 50;
  }
  
  /// 스크롤 위치가 하단 근처인지 확인
  bool checkIfNearBottom() {
    if (scrollController == null) return false;
    
    final position = scrollController!.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    
    // 하단에서 200픽셀 이내면 근처로 간주
    return (maxScroll - currentScroll) <= 200;
  }
  
  /// 리소스 정리
  void dispose() {
    scrollController?.dispose();
  }
}