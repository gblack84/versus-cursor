import 'package:flutter/material.dart';

/// 투표 시스템 전용 상수
///
/// Voting Feature에서만 사용되는 상수들을 정의합니다.
/// - 투표 UI 색상 및 스타일
/// - 투표 상태 값
/// - 투표 애니메이션 설정
class VotingConstants {
  VotingConstants._();

  // ==================== 투표 색상 ====================
  // 투표 카드에서 A/B 옵션을 구분하는 색상

  /// 투표 옵션 A 색상 (빨간색)
  ///
  /// 사용처:
  /// - VoteCardMessage에서 A옵션 박스 배경
  /// - VoteOptionBox A 버튼 색상
  /// - 투표 진행바 A옵션 색상
  static const Color voteColorA = Color(0xFFFF6B6B);

  /// 투표 옵션 B 색상 (청록색)
  ///
  /// 사용처:
  /// - VoteCardMessage에서 B옵션 박스 배경
  /// - VoteOptionBox B 버튼 색상
  /// - 투표 진행바 B옵션 색상
  static const Color voteColorB = Color(0xFF4ECDC4);

  // ==================== 투표 UI 스타일 ====================

  /// 투표 카드 모서리 둥글기 (픽셀)
  ///
  /// 사용처:
  /// - VoteCardMessage BorderRadius
  /// - VotingNotificationDialog 카드 스타일
  static const double voteCardBorderRadius = 10.0;

  /// 투표 옵션 버튼 모서리 둥글기 (픽셀)
  ///
  /// 사용처:
  /// - VoteOptionBox A/B 버튼
  /// - 투표 다이얼로그 버튼
  static const double voteOptionBorderRadius = 7.0;

  /// 투표 카드 기본 높이 (픽셀)
  ///
  /// 사용처:
  /// - VoteCardMessage 최소 높이
  /// - 스마트 레이아웃 시스템 기본값
  static const double voteCardDefaultHeight = 200.0;

  /// 메시지 카드 너비 비율 (화면 너비 대비)
  ///
  /// 0.92 = 화면 너비의 92% 사용 (좌우 4% 여백)
  ///
  /// 사용처:
  /// - VoteCardMessage 카드 너비 계산
  /// - VotingNotificationDialog 다이얼로그 너비
  /// - VoteOptionBox 컨테이너 너비
  static const double messageCardWidthRatio = 0.92;

  /// 멀티이미지 인디케이터 아이콘 크기 (픽셀)
  ///
  /// 12px = 작은 페이지 인디케이터 도트 크기
  ///
  /// 사용처:
  /// - VoteCardMessage 이미지 인디케이터
  /// - VoteOptionBox PageView 인디케이터
  /// - 이미지 개수 표시 아이콘
  static const double multiImageIndicatorIconSize = 12.0;

  /// 단일 이미지 그라데이션 정지점
  ///
  /// [0.0, 0.3] = 상단 0%에서 시작하여 30% 위치까지 그라데이션
  ///
  /// 사용처:
  /// - VoteOptionBox 단일 이미지 배경 그라데이션
  /// - 상단 그림자 효과 생성
  static const List<double> singleImageGradientStops = [0.0, 0.3];

  /// 멀티 이미지 그라데이션 정지점
  ///
  /// [0.0, 0.2] = 상단 0%에서 시작하여 20% 위치까지 그라데이션
  ///
  /// 사용처:
  /// - VoteOptionBox 멀티 이미지 배경 그라데이션
  /// - 더 짧은 그림자 효과 (멀티 이미지는 공간이 적음)
  static const List<double> multiImageGradientStops = [0.0, 0.2];

  // ==================== 투표 상태 문자열 ====================
  // 투표 카드의 생명주기 상태

  /// 투표 요청 상태 - 사용자가 아직 투표하지 않음
  ///
  /// 사용처:
  /// - MessagesModel.cardStatus 필드
  /// - AI 채팅방에서 새 투표 카드 전송 시
  /// - VoteCardMessage 상태 판단
  static const String cardStatusVotingRequest = 'votingRequest';

  /// 투표 진행중 상태 - 사용자가 투표했으나 아직 완료되지 않음
  ///
  /// 사용처:
  /// - 투표 제출 후 상태 업데이트
  /// - 타이머 표시 중 상태
  static const String cardStatusVoting = 'voting';

  /// 투표 완료 상태 - 투표가 종료되고 결과 표시
  ///
  /// 사용처:
  /// - 10분 타이머 완료 시
  /// - Firebase Functions에서 자동 완료 처리 시
  /// - 투표 결과 표시
  static const String cardStatusCompleted = 'completed';

  // ==================== UI 텍스트 ====================

  /// 투표 완료 알림 텍스트
  ///
  /// 투표가 완료되었을 때 표시하는 축하 메시지
  ///
  /// 사용처:
  /// - VoteCardMessage 완료 상태 표시
  /// - VoteResultDisplay 결과 헤더
  /// - VoteResultsWidget 완료 알림
  static const String voteCompletedText = '피클! 피클! 피클!';

  // ==================== 애니메이션 Duration ====================

  /// 투표 상태 리셋 지연 시간
  ///
  /// 500ms = 사용자가 투표 완료 메시지를 읽을 시간
  ///
  /// 사용처:
  /// - 투표 완료 후 UI 상태 초기화
  /// - 다음 투표 준비
  static const Duration votingStateResetDelay = Duration(milliseconds: 500);
}
