import 'package:cloud_firestore/cloud_firestore.dart';

/// 투표 알림 데이터 모델
class VotingNotification {
  final String notificationId;
  final String userId;
  final String type;
  final String sourceId; // postId
  final NotificationContent content;
  final DateTime createdAt;
  final bool read;
  final String targetAudience;
  final DateTime expiryTime;
  final String interactionType;
  final String targetReason;
  final DateTime? readAt;

  VotingNotification({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.sourceId,
    required this.content,
    required this.createdAt,
    required this.read,
    required this.targetAudience,
    required this.expiryTime,
    required this.interactionType,
    required this.targetReason,
    this.readAt,
  });

  /// Firestore 문서에서 생성
  factory VotingNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return VotingNotification(
      notificationId: doc.id,
      userId: data['user_id'] ?? '',
      type: data['type'] ?? 'voting_request',
      sourceId: data['source_id'] ?? '',
      content: NotificationContent.fromMap(data['content'] ?? {}),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
      targetAudience: data['target_audience'] ?? '',
      expiryTime: (data['expiry_time'] as Timestamp?)?.toDate() ?? DateTime.now(),
      interactionType: data['interaction_type'] ?? 'vote',
      targetReason: data['targetReason'] ?? '',
      readAt: (data['read_at'] as Timestamp?)?.toDate(),
    );
  }

  /// 만료 여부 확인
  bool get isExpired => DateTime.now().isAfter(expiryTime);
  
  /// 남은 시간 계산
  Duration get remainingTime => expiryTime.difference(DateTime.now());
  
  /// 남은 시간 문자열
  String get remainingTimeString {
    final remaining = remainingTime;
    if (remaining.isNegative) return '만료됨';
    
    if (remaining.inMinutes < 1) {
      return '${remaining.inSeconds}초 남음';
    } else if (remaining.inHours < 1) {
      return '${remaining.inMinutes}분 남음';
    } else {
      return '${remaining.inHours}시간 남음';
    }
  }
}

/// 알림 콘텐츠 데이터
class NotificationContent {
  final String title;
  final String message;
  final PostData postData;

  NotificationContent({
    required this.title,
    required this.message,
    required this.postData,
  });

  factory NotificationContent.fromMap(Map<String, dynamic> map) {
    return NotificationContent(
      title: map['title'] ?? '새로운 투표가 도착했어요!',
      message: map['message'] ?? '',
      postData: PostData.fromMap(map['postData'] ?? {}),
    );
  }
}

/// 투표 게시물 데이터
class PostData {
  final String questionTitle;
  final String optionA;
  final String optionB;
  final String? imageUrlA;
  final String? imageUrlB;
  final String authorName;
  final String? category;

  PostData({
    required this.questionTitle,
    required this.optionA,
    required this.optionB,
    this.imageUrlA,
    this.imageUrlB,
    required this.authorName,
    this.category,
  });

  factory PostData.fromMap(Map<String, dynamic> map) {
    return PostData(
      questionTitle: map['questionTitle'] ?? '',
      optionA: map['optionA'] ?? '',
      optionB: map['optionB'] ?? '',
      imageUrlA: map['imageUrlA'],
      imageUrlB: map['imageUrlB'],
      authorName: map['authorName'] ?? '익명',
      category: map['category'],
    );
  }
}