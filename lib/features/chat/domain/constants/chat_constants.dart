/// 채팅 시스템 전용 상수
///
/// Chat Feature에서만 사용되는 상수들을 정의합니다.
/// - 메시지 로딩 및 페이지네이션
/// - 메시지 타입 정의
/// - 채팅 UI 스타일
/// - 사용자 캐시 관리
///
/// **전역 상수는 이동됨**:
/// - AI 사용자 정보 → /core/constants/app_constants.dart
/// - 투표 관련 상수 → /features/voting/domain/constants/voting_constants.dart
class ChatConstants {
  ChatConstants._();

  // ==================== 메시지 로딩 관련 ====================

  /// 초기 메시지 로드 개수
  ///
  /// 채팅방 진입 시 최초로 가져오는 메시지 수
  ///
  /// 사용처:
  /// - ChatDetailProvider.initializeChat()
  /// - AIChatProvider.initializeChat()
  static const int initialMessageLoadCount = 30;

  /// 추가 메시지 로드 개수 (페이지네이션)
  ///
  /// 스크롤 시 추가로 로드할 메시지 수
  ///
  /// 사용처:
  /// - ChatDetailProvider.loadMoreMessages()
  /// - AIChatProvider.loadMoreMessages()
  static const int paginationMessageCount = 20;

  /// 스크롤 임계값 - 추가 메시지 로드 (픽셀)
  ///
  /// 화면 상단에서 이 거리 이내로 스크롤하면 이전 메시지 로드
  ///
  /// 사용처:
  /// - ChatDetailWidgetV2 스크롤 리스너
  static const double loadMoreThreshold = 100;

  /// 스크롤 임계값 - FAB 표시/숨김 (픽셀)
  ///
  /// 화면 하단에서 이 거리 이상 떨어지면 "맨 아래로" FAB 표시
  ///
  /// 사용처:
  /// - ChatDetailWidgetV2._handleScroll()
  static const double fabShowThreshold = 500;

  // ==================== 애니메이션 관련 ====================

  /// FAB 스케일 애니메이션 시간
  ///
  /// 300ms = "맨 아래로" 버튼의 크기 변화 애니메이션
  ///
  /// 사용처:
  /// - ChatDetailWidgetV2 FAB 빌더
  static const Duration fabScaleAnimationDuration = Duration(milliseconds: 300);

  // ==================== 캐시 관련 ====================

  /// 사용자 캐시 유지 개수
  ///
  /// 메모리에 유지할 최대 사용자 정보 수
  ///
  /// 사용처:
  /// - UserCacheService LRU 캐시
  static const int userCacheKeepCount = 100;

  /// 사용자 로딩 타임아웃 반복 횟수
  ///
  /// 100ms x 50 = 5초 최대 대기 시간
  ///
  /// 사용처:
  /// - ChatDetailWidgetV2._loadChatParticipants()
  static const int userLoadingTimeoutIterations = 50;

  /// 사용자 로딩 체크 간격
  ///
  /// 사용자 정보 로딩 상태를 100ms마다 확인
  ///
  /// 사용처:
  /// - ChatDetailWidgetV2._loadChatParticipants()
  static const Duration userLoadingCheckInterval = Duration(milliseconds: 100);

  // ==================== 메시지 타입 ====================

  /// 텍스트 메시지 타입
  ///
  /// 일반 텍스트 채팅 메시지
  static const String messageTypeText = 'text';

  /// 이미지 메시지 타입
  ///
  /// 이미지가 포함된 메시지
  static const String messageTypeImage = 'image';

  /// 투표 요청 메시지 타입
  ///
  /// 사용자에게 투표를 요청하는 메시지
  static const String messageTypeVoteRequest = 'voteRequest';

  /// 투표 생성 메시지 타입
  ///
  /// 새 투표가 생성되었음을 알리는 메시지
  static const String messageTypeVoteCreated = 'voteCreated';

  /// 시스템 메시지 타입
  ///
  /// 시스템 알림 메시지 (입장/퇴장 등)
  static const String messageTypeSystem = 'system';

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
}
