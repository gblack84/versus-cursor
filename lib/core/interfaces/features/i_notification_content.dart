import 'dart:async';
import '../common/i_content_model.dart';

/// 알림 컨텐츠 추상화 인터페이스
/// 
/// notifications 피처에서 다양한 타입의 컨텐츠를 처리할 때
/// 구체적인 구현에 의존하지 않도록 추상화합니다.
/// 
/// 투표, 댓글, 좋아요 등 다양한 알림 유형을 통일된 방식으로 처리합니다.
abstract class INotificationContent {
  /// 알림 고유 ID
  String get id;
  
  /// 알림 타입
  NotificationType get type;
  
  /// 제목
  String get title;
  
  /// 내용/설명
  String get content;
  
  /// 발신자 ID
  String get senderId;
  
  /// 수신자 ID
  String get recipientId;
  
  /// 관련 컨텐츠 ID (포스트, 댓글 등)
  String? get relatedContentId;
  
  /// 생성 시간
  DateTime get createdAt;
  
  /// 만료 시간 (선택사항)
  DateTime? get expiryTime;
  
  /// 읽음 여부
  bool get isRead;
  
  /// 해제 여부 (사용자가 닫은 알림)
  bool get isDismissed;
  
  /// 우선순위 (높을수록 우선 표시)
  int get priority;
  
  /// 알림 데이터 (타입별 추가 정보)
  Map<String, dynamic> get data;
  
  /// 알림 액션 목록 (투표, 확인, 무시 등)
  List<NotificationAction> get actions;
  
  /// 미디어 컨텐츠 (이미지, 비디오 등)
  List<NotificationMedia> get mediaItems;
}

/// Versus 투표 알림 전용 인터페이스
abstract class IVoteNotificationContent extends INotificationContent {
  /// 투표 포스트 제목
  String get postTitle;
  
  /// A 옵션 제목
  String get optionATitle;
  
  /// B 옵션 제목
  String get optionBTitle;
  
  /// A 옵션 이미지 URL 목록
  List<String> get optionAImageUrls;
  
  /// B 옵션 이미지 URL 목록
  List<String> get optionBImageUrls;
  
  /// 투표 시작 시간
  DateTime? get voteStartTime;
  
  /// 투표 종료 시간
  DateTime? get voteEndTime;
  
  /// 레이아웃 타입
  String? get layoutType;
  
  /// 남은 투표 시간
  Duration? get remainingTime {
    if (voteEndTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(voteEndTime!)) return Duration.zero;
    return voteEndTime!.difference(now);
  }
  
  /// 투표가 만료되었는지 여부
  bool get isVoteExpired {
    if (voteEndTime == null) return false;
    return DateTime.now().isAfter(voteEndTime!);
  }
}

/// 알림 타입 열거형
enum NotificationType {
  votingRequest,    // 투표 요청
  voteResult,       // 투표 결과
  comment,          // 댓글
  like,             // 좋아요
  follow,           // 팔로우
  mention,          // 멘션
  system,           // 시스템 알림
  achievement,      // 성취/업적
  reminder,         // 리마인더
}

/// 알림 액션
class NotificationAction {
  final String id;
  final String label;
  final NotificationActionType type;
  final Map<String, dynamic>? data;
  
  const NotificationAction({
    required this.id,
    required this.label,
    required this.type,
    this.data,
  });
}

/// 알림 액션 타입
enum NotificationActionType {
  vote,         // 투표
  view,         // 보기
  dismiss,      // 무시
  later,        // 나중에
  block,        // 차단
  report,       // 신고
  share,        // 공유
  reply,        // 답변
}

/// 알림 미디어 아이템
class NotificationMedia {
  final String id;
  final NotificationMediaType type;
  final String url;
  final String? thumbnailUrl;
  final Map<String, dynamic>? metadata;
  
  const NotificationMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnailUrl,
    this.metadata,
  });
}

/// 알림 미디어 타입
enum NotificationMediaType {
  image,
  video,
  audio,
  document,
  link,
}

/// 알림 우선순위
enum NotificationPriority {
  low(1),
  normal(5),
  high(10),
  urgent(20),
  critical(50);
  
  const NotificationPriority(this.value);
  final int value;
}

/// 알림 컨텐츠 서비스 인터페이스
/// 
/// 알림 컨텐츠의 생성, 수정, 조회를 담당하는 서비스
abstract class INotificationContentService {
  /// 투표 알림 컨텐츠 생성
  Future<IVoteNotificationContent> createVoteNotification({
    required String senderId,
    required String recipientId,
    required String postId,
    required IVersusContentModel post,
    DateTime? expiryTime,
  });
  
  /// 알림 컨텐츠 조회
  Future<INotificationContent?> getNotificationContent(String notificationId);
  
  /// 알림 컨텐츠 목록 조회
  Future<List<INotificationContent>> getNotificationContents({
    required String userId,
    NotificationType? type,
    bool unreadOnly = false,
    int limit = 50,
  });
  
  /// 알림 읽음 상태 업데이트
  Future<void> markAsRead(String notificationId);
  
  /// 알림 해제 상태 업데이트
  Future<void> markAsDismissed(String notificationId);
  
  /// 만료된 알림 정리
  Future<void> cleanupExpiredNotifications(String userId);
  
  /// 알림 컨텐츠 실시간 감시
  Stream<List<INotificationContent>> watchNotificationContents({
    required String userId,
    NotificationType? type,
    bool unreadOnly = false,
  });
}