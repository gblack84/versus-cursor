import 'package:freezed_annotation/freezed_annotation.dart';
import '../value_objects/target_audience.dart';

part 'post_creation.freezed.dart';
part 'post_creation.g.dart';

/// Pure domain entity for PostCreation
/// 순수한 도메인 엔티티 - PostCreation
///
/// Creation Feature는 Post 생성과 투표 초기 설정을 담당
/// 실제 투표 실행과 결과는 Voting Feature가 담당
///
/// **Freezed Migration**: Equatable에서 Freezed로 마이그레이션
/// - 570+ 줄의 수동 boilerplate 제거
/// - 불변성 자동 보장
/// - copyWith, toJson, fromJson 자동 생성
@freezed
sealed class PostCreation with _$PostCreation {
  const PostCreation._();

  const factory PostCreation({
    String? id,
    required String userId,
    required String title,
    required String description,
    required PostOption optionA,
    required PostOption optionB,
    TargetAudience? targetAudience,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(PostStatus.draft) PostStatus status,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    VoteConfiguration? voteConfig,
    @Default(false) bool isAnonymous,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) = _PostCreation;

  factory PostCreation.fromJson(Map<String, dynamic> json) =>
      _$PostCreationFromJson(json);

  /// Backward compatibility: fromMap delegates to fromJson
  /// 하위 호환성: fromMap은 fromJson으로 위임
  factory PostCreation.fromMap(Map<String, dynamic> map) =>
      PostCreation.fromJson(map);

  /// Backward compatibility: toMap delegates to toJson
  /// 하위 호환성: toMap은 toJson으로 위임
  Map<String, dynamic> toMap() => toJson();

  // ============================================
  // Business Logic (비즈니스 로직)
  // ============================================

  /// Check if post is published
  bool get isPublished => status == PostStatus.published;

  /// Check if post is draft
  bool get isDraft => status == PostStatus.draft;

  /// Check if post is in voting state
  bool get isVoting => status == PostStatus.voting;

  /// Check if voting is completed
  bool get isCompleted => status == PostStatus.completed;

  /// Check if post has any images
  bool get hasImages =>
      optionA.imageUrls.isNotEmpty || optionB.imageUrls.isNotEmpty;

  /// Check if post has any videos
  bool get hasVideos =>
      (optionA.videoUrls?.isNotEmpty ?? false) ||
      (optionB.videoUrls?.isNotEmpty ?? false);

  /// Get total media count
  int get totalMediaCount =>
      optionA.imageUrls.length +
      optionB.imageUrls.length +
      (optionA.videoUrls?.length ?? 0) +
      (optionB.videoUrls?.length ?? 0);
}

/// Post option (A or B)
/// 게시물 옵션 (A 또는 B)
///
/// **Freezed Migration**: Equatable에서 Freezed로 마이그레이션
@freezed
sealed class PostOption with _$PostOption {
  const factory PostOption({
    String? text,
    @Default([]) List<String> imageUrls,
    List<String>? videoUrls,
    @Default([]) List<double> aspectRatios,
    Map<String, dynamic>? metadata,
  }) = _PostOption;

  factory PostOption.fromJson(Map<String, dynamic> json) =>
      _$PostOptionFromJson(json);

  /// Backward compatibility: fromMap delegates to fromJson
  factory PostOption.fromMap(Map<String, dynamic> map) =>
      PostOption.fromJson(map);
}

/// Vote configuration for a post (managed by Creation)
/// 게시물의 투표 설정 (Creation이 관리)
///
/// **Freezed Migration**: Equatable에서 Freezed로 마이그레이션
@freezed
sealed class VoteConfiguration with _$VoteConfiguration {
  const factory VoteConfiguration({
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    @Default(false) bool allowAnonymous,
    @Default(false) bool requiresExpansion,
    Map<String, dynamic>? settings,
  }) = _VoteConfiguration;

  factory VoteConfiguration.fromJson(Map<String, dynamic> json) =>
      _$VoteConfigurationFromJson(json);

  /// Backward compatibility: fromMap delegates to fromJson
  factory VoteConfiguration.fromMap(Map<String, dynamic> map) =>
      VoteConfiguration.fromJson(map);
}

/// Post status enum
/// 게시물 상태 열거형
enum PostStatus {
  draft, // 임시저장
  published, // 게시됨
  voting, // 투표중
  completed, // 투표완료
  archived, // 보관됨
  deleted, // 삭제됨
}
