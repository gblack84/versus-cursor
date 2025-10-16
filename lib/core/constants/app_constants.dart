/// 앱 전역에서 사용되는 공통 상수
///
/// Feature 간 공유되는 상수를 정의합니다.
/// - AI 사용자 정보: chat/voting/profile에서 공유
/// - UI 공통 사이즈: 모든 feature에서 사용하는 일관된 크기
/// - 애니메이션 Duration: 앱 전체 애니메이션 속도 통일
class AppConstants {
  AppConstants._();

  // ==================== AI 사용자 정보 ====================
  // chat, voting, profile feature에서 공유

  /// AI 챗봇 사용자 ID
  ///
  /// 사용처:
  /// - 채팅 목록에서 AI 채팅방 구별
  /// - 메시지 발신자가 AI인지 확인
  /// - 투표 완료 후 AI 채팅방으로 메시지 전송
  static const String aiUserId = 'ai_assistant';

  /// AI 챗봇 표시 이름
  ///
  /// 사용처:
  /// - UI에 친근한 이름으로 표시
  /// - 채팅 목록, 메시지 헤더에 표시
  static const String aiUserName = 'AI 피클';

  /// AI 챗봇 프로필 이미지 URL
  ///
  /// 사용처:
  /// - 채팅 목록 아바타
  /// - 메시지 발신자 아바타
  /// - 투표 카드 AI 아바타
  static const String aiUserAvatar =
      'https://picsum.photos/seed/ai_assistant/200';

  // ==================== UI 공통 사이즈 ====================
  // 앱 전체 디자인 시스템 통일

  /// 프로필 아바타 반경 (픽셀)
  ///
  /// 사용처:
  /// - 피드 게시물 작성자 아바타
  /// - 투표 카드 헤더 아바타
  /// - 프로필 편집 미리보기
  /// - 인기/트렌딩 게시물 아바타
  static const double profileAvatarRadius = 20.0;

  // ==================== 애니메이션 Duration ====================
  // 일관된 사용자 경험을 위한 애니메이션 속도 통일

  /// FAB (Floating Action Button) 애니메이션 시간
  ///
  /// 200ms = 인간이 가장 자연스럽게 느끼는 속도
  ///
  /// 사용처:
  /// - 채팅방 "맨 아래로" 버튼
  /// - FAB 나타남/사라짐 효과
  static const Duration fabAnimationDuration = Duration(milliseconds: 200);

  /// 스크롤 애니메이션 시간
  ///
  /// 300ms = 스크롤에 최적화된 시간
  ///
  /// 사용처:
  /// - 새 메시지 도착 시 자동 스크롤
  /// - FAB 클릭 시 맨 아래로 이동
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);

  /// 자동 스크롤 시작 전 대기 시간
  ///
  /// 100ms = 위젯 렌더링 대기 (약 6 프레임)
  ///
  /// 사용처:
  /// - 새 메시지 추가 후 스크롤
  /// - 키보드 올라올 때 스크롤 조정
  static const Duration autoScrollDelay = Duration(milliseconds: 100);

  // ==================== 메시지 타입 (전역) ====================
  // chat, voting feature에서 공유

  /// 텍스트 메시지 타입
  ///
  /// 일반 텍스트 채팅 메시지
  ///
  /// 사용처:
  /// - ChatMessageService 메시지 타입 판단
  /// - 메시지 빌더 타입 분기
  static const String messageTypeText = 'text';

  /// 이미지 메시지 타입
  ///
  /// 이미지가 포함된 메시지
  ///
  /// 사용처:
  /// - ChatMediaPicker 미디어 타입 설정
  /// - 메시지 전송 시 타입 지정
  static const String messageTypeImage = 'image';

  /// 투표 요청 메시지 타입
  ///
  /// 사용자에게 투표를 요청하는 메시지
  ///
  /// 사용처:
  /// - AI 채팅방 투표 카드 전송
  /// - VoteStatusService 투표 메시지 필터링
  /// - VoteCardMessage 타입 판단
  static const String messageTypeVoteRequest = 'voteRequest';

  /// 투표 생성 메시지 타입
  ///
  /// 새 투표가 생성되었음을 알리는 메시지
  ///
  /// 사용처:
  /// - ChatMessageBuilder 투표 카드 렌더링
  /// - 메시지 타입 분기 로직
  static const String messageTypeVoteCreated = 'voteCreated';

  /// 시스템 메시지 타입
  ///
  /// 시스템 알림 메시지 (입장/퇴장, 읽지 않은 메시지 구분선 등)
  ///
  /// 사용처:
  /// - ChatMessageService 시스템 메시지 처리
  /// - 날짜 헤더, 알림 표시
  static const String messageTypeSystem = 'system';

  // ==================== UI 텍스트 (전역) ====================
  // chat, voting, profile feature에서 공유

  /// 알 수 없는 사용자 표시 텍스트
  ///
  /// 사용자 정보를 불러올 수 없을 때 표시
  ///
  /// 사용처:
  /// - VoteCardMessage 발신자 이름 폴백
  /// - VoteCardHeader 사용자 이름 폴백
  static const String unknownUserText = '알 수 없는 사용자';

  /// 기본 사용자 이름
  ///
  /// displayName이 null이거나 비어있을 때 사용하는 기본값
  ///
  /// 사용처:
  /// - UserCacheService 사용자 이름 추출 폴백
  /// - 프로필 정보 없을 때 대체 이름
  static const String defaultUserName = 'User';
}
