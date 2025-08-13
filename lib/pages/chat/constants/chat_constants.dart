import 'package:flutter/material.dart';

/// 채팅 시스템에서 사용되는 상수 모음
class ChatConstants {
  ChatConstants._();
  
  // ==================== 메시지 로딩 관련 ====================
  
  /// 초기 메시지 로드 개수
  static const int initialMessageLoadCount = 30;
  
  /// 추가 메시지 로드 개수 (페이지네이션)
  static const int paginationMessageCount = 20;
  
  /// 스크롤 임계값 (이 픽셀 이내일 때 추가 로드)
  static const double loadMoreThreshold = 100;
  
  /// 스크롤 임계값 (FAB 표시/숨김)
  static const double fabShowThreshold = 500;
  
  // ==================== 애니메이션 관련 ====================
  
  /// FAB 애니메이션 시간
  static const Duration fabAnimationDuration = Duration(milliseconds: 200);
  
  /// FAB 스케일 애니메이션 시간
  static const Duration fabScaleAnimationDuration = Duration(milliseconds: 300);
  
  /// 자동 스크롤 딜레이
  static const Duration autoScrollDelay = Duration(milliseconds: 100);
  
  /// 투표 상태 리셋 딜레이
  static const Duration votingStateResetDelay = Duration(milliseconds: 500);
  
  /// 스크롤 애니메이션 시간
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);
  
  // ==================== 투표 카드 관련 ====================
  
  /// 투표 카드 색상 A
  static const Color voteColorA = Color(0xFFFF6B6B);
  
  /// 투표 카드 색상 B
  static const Color voteColorB = Color(0xFF4ECDC4);
  
  /// 투표 카드 모서리 반경
  static const double voteCardBorderRadius = 10.0;
  
  /// 투표 옵션 박스 모서리 반경
  static const double voteOptionBorderRadius = 7.0;
  
  /// 투표 카드 기본 높이
  static const double voteCardDefaultHeight = 200.0;
  
  // ==================== 캐시 관련 ====================
  
  /// 사용자 캐시 유지 개수
  static const int userCacheKeepCount = 100;
  
  /// 사용자 로딩 타임아웃 (100ms x 50 = 5초)
  static const int userLoadingTimeoutIterations = 50;
  static const Duration userLoadingCheckInterval = Duration(milliseconds: 100);
  
  // ==================== 메시지 타입 ====================
  
  static const String messageTypeText = 'text';
  static const String messageTypeImage = 'image';
  static const String messageTypeVoteRequest = 'vote_request';
  static const String messageTypeVoteCreated = 'vote_created';
  static const String messageTypeSystem = 'system';
  
  // ==================== 투표 상태 ====================
  
  static const String cardStatusVotingRequest = 'voting_request';
  static const String cardStatusVoting = 'voting';
  static const String cardStatusCompleted = 'completed';
  
  // ==================== AI 사용자 정보 ====================
  
  static const String aiUserId = 'ai_assistant';
  static const String aiUserName = 'AI 피클';
  static const String aiUserAvatar = 'https://picsum.photos/seed/ai_assistant/200';
  
  // ==================== UI 사이즈 ====================
  
  /// 메시지 카드 너비 비율 (화면 대비)
  static const double messageCardWidthRatio = 0.92;
  
  /// 프로필 아바타 반경
  static const double profileAvatarRadius = 20.0;
  
  /// 상태 배지 아이콘 크기
  static const double statusBadgeIconSize = 12.0;
  
  /// 멀티이미지 인디케이터 아이콘 크기
  static const double multiImageIndicatorIconSize = 12.0;
  
  // ==================== 그라데이션 설정 ====================
  
  /// 싱글 이미지 모드 그라데이션 정지 지점
  static const List<double> singleImageGradientStops = [0.0, 0.3];
  
  /// 멀티 이미지 모드 그라데이션 정지 지점
  static const List<double> multiImageGradientStops = [0.0, 0.2];
  
  // ==================== 텍스트 설정 ====================
  
  /// 읽지 않은 메시지 텍스트
  static const String unreadMessagesText = '읽지 않은 메시지';
  
  /// 투표 완료 메시지
  static const String voteCompletedText = '피클! 피클! 피클!';
  
  /// 알 수 없는 사용자 텍스트
  static const String unknownUserText = '알 수 없는 사용자';
  
  /// 기본 사용자 이름
  static const String defaultUserName = 'User';
}