import 'dart:async';
import '../common/i_content_model.dart';

/// Posts 서비스 추상화 인터페이스
/// 
/// notifications 피처가 posts 피처의 구체적인 구현에 의존하지 않도록
/// 필요한 메서드들을 추상화합니다.
/// 
/// 의존성 역전 원칙(DIP)을 적용하여 notifications가 이 인터페이스에만 의존하고,
/// posts 피처가 이 인터페이스를 구현하도록 합니다.
abstract class IPostService {
  /// 포스트 ID로 컨텐츠 조회
  /// 
  /// Returns null if post doesn't exist
  Future<IVersusContentModel?> getPost(String postId);
  
  /// 포스트 존재 여부 확인
  Future<bool> postExists(String postId);
  
  /// 포스트 생성자 ID 조회
  Future<String?> getPostCreatorId(String postId);
  
  /// 사용자의 포스트 목록 조회
  /// 
  /// [userId] - 조회할 사용자 ID
  /// [limit] - 조회할 최대 개수 (기본값: 50)
  /// [includeInactive] - 비활성 포스트 포함 여부 (기본값: false)
  Future<List<IVersusContentModel>> getUserPosts({
    required String userId,
    int limit = 50,
    bool includeInactive = false,
  });
  
  /// 타겟 오디언스 정보와 함께 포스트 생성
  /// 
  /// [contentData] - 포스트 내용 데이터
  /// [targetAudience] - 타겟 오디언스 설정
  /// 
  /// Returns 생성된 포스트 ID
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> contentData,
    required Map<String, dynamic> targetAudience,
  });
  
  /// 포스트 알림 상태 업데이트
  /// 
  /// 알림이 전송되었음을 표시하고 전송 시간을 기록합니다.
  Future<void> updatePostNotificationStatus({
    required String postId,
    required bool notificationsSent,
    DateTime? notificationsSentAt,
  });
  
  /// 포스트 투표 수 업데이트
  /// 
  /// 실시간 투표 결과를 반영합니다.
  Future<void> updatePostVotes({
    required String postId,
    required int votesA,
    required int votesB,
  });
  
  /// 포스트 상태 업데이트
  /// 
  /// 투표 상태, 활성화 상태 등을 업데이트합니다.
  Future<void> updatePostStatus({
    required String postId,
    VoteStatus? voteStatus,
    bool? isActive,
    Map<String, dynamic>? additionalData,
  });
  
  /// 사용자별 타겟 오디언스 통계 조회
  /// 
  /// 알림 효율성 분석을 위한 통계 정보를 제공합니다.
  Future<List<PostTargetAudienceStats>> getUserPostsWithTargetAudience({
    required String userId,
    int limit = 100,
  });
  
  /// 포스트 실시간 변경 감시
  /// 
  /// 투표 결과, 상태 변경 등을 실시간으로 감지합니다.
  Stream<IVersusContentModel> watchPost(String postId);
  
  /// 사용자 포스트 목록 실시간 감시
  Stream<List<IVersusContentModel>> watchUserPosts({
    required String userId,
    int limit = 20,
  });
}

/// 포스트 타겟 오디언스 통계
/// 
/// 알림 시스템에서 타겟팅 효율성을 분석하기 위한 통계 정보
class PostTargetAudienceStats {
  final String postId;
  final String postTitle;
  final Map<String, dynamic> targetAudience;
  final int notificationsSent;
  final int votesReceived;
  final DateTime createdAt;
  final DateTime? notificationsSentAt;
  
  const PostTargetAudienceStats({
    required this.postId,
    required this.postTitle,
    required this.targetAudience,
    required this.notificationsSent,
    required this.votesReceived,
    required this.createdAt,
    this.notificationsSentAt,
  });
  
  /// 알림 전환율 (투표 수 / 알림 수)
  double get conversionRate {
    if (notificationsSent == 0) return 0.0;
    return votesReceived / notificationsSent;
  }
}

/// 포스트 조회 필터
class PostFilter {
  final VoteStatus? status;
  final bool? isActive;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final List<String>? tags;
  
  const PostFilter({
    this.status,
    this.isActive,
    this.createdAfter,
    this.createdBefore,
    this.tags,
  });
}