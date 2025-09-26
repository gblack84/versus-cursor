import '../../domain/entities/post.dart' as entity;
import '../../domain/models/post.dart' as model;
import '../../domain/models/media_content.dart';
import '../../domain/models/creator_info.dart';
import '../../domain/models/vote_data.dart';
import '../../domain/models/post_stats.dart';
import '../../domain/models/target_audience.dart';
import '../../../../core_exports.dart';

/// Adapter for converting between domain entity Post and domain model Post
///
/// This adapter enables gradual migration from the existing model structure
/// to the new Clean Architecture entity structure.
class PostModelAdapter {
  /// Convert entity Post to model Post
  static model.Post fromEntity(entity.Post entityPost) {
    return model.Post(
      id: entityPost.id ?? '',
      creatorInfo: CreatorInfo(
        userid: entityPost.userId,
        uid: entityPost.userId,
        email: '', // Not available in entity
        displayName: '', // Not available in entity
        photoUrl: '', // Not available in entity
        createdTime: entityPost.createdAt,
      ),
      questionTitle: entityPost.title,
      description: entityPost.description,
      content: entityPost.description, // Use description as content
      optionA: MediaContent(
        text: entityPost.optionA.text ?? '',
        imageUrls: entityPost.optionA.imageUrls,
        videoUrls: entityPost.optionA.videoUrls ?? [],
        aspectRatio: entityPost.optionA.aspectRatios.isNotEmpty
            ? entityPost.optionA.aspectRatios.first
            : null,
        mediaType: entityPost.optionA.imageUrls.isNotEmpty
            ? 'image'
            : (entityPost.optionA.videoUrls?.isNotEmpty ?? false
                ? 'video'
                : 'text'),
      ),
      optionB: MediaContent(
        text: entityPost.optionB.text ?? '',
        imageUrls: entityPost.optionB.imageUrls,
        videoUrls: entityPost.optionB.videoUrls ?? [],
        aspectRatio: entityPost.optionB.aspectRatios.isNotEmpty
            ? entityPost.optionB.aspectRatios.first
            : null,
        mediaType: entityPost.optionB.imageUrls.isNotEmpty
            ? 'image'
            : (entityPost.optionB.videoUrls?.isNotEmpty ?? false
                ? 'video'
                : 'text'),
      ),
      voteData: VoteData(
        votesA: entityPost.votesA,
        votesB: entityPost.votesB,
        totalVotes: entityPost.votesA + entityPost.votesB,
        voteStartTime: entityPost.voteStartTime,
        voteEndTime: entityPost.voteEndTime,
        isVotingActive: _isVotingActive(
          entityPost.voteStartTime,
          entityPost.voteEndTime,
        ),
        votedUserIds: [], // Not available in entity
        voteStatus: _getVoteStatus(
          entityPost.voteStartTime,
          entityPost.voteEndTime,
        ),
        voteCompleted: _isVoteCompleted(entityPost.voteEndTime),
      ),
      stats: PostStats(
        likeCount: entityPost.likeCount,
        commentCount: entityPost.commentCount,
        shareCount: 0, // Not available in entity
        viewCount: 0, // Not available in entity
        reportCount: 0, // Not available in entity
      ),
      createdAt: entityPost.createdAt,
      updatedAt: entityPost.updatedAt,
      location: null, // Not available in entity
      tags: [], // Not available in entity
      category: '', // Not available in entity
      visibility: 0, // Default visibility
      isAnonymous: entityPost.isAnonymous,
      premiumRequired: false, // Not available in entity
      targetAudience: entityPost.targetAudience?.toMap() ?? {},
      moderation: entityPost.metadata?['moderation'] ?? {},
    );
  }

  /// Convert model Post to entity Post
  static entity.Post toEntity(model.Post modelPost) {
    return entity.Post(
      id: modelPost.id,
      userId: modelPost.creatorInfo.userid,
      title: modelPost.questionTitle,
      description: modelPost.description,
      optionA: entity.PostOption(
        text: modelPost.optionA.text.isNotEmpty ? modelPost.optionA.text : null,
        imageUrls: modelPost.optionA.imageUrls,
        videoUrls: modelPost.optionA.videoUrls.isNotEmpty
            ? modelPost.optionA.videoUrls
            : null,
        aspectRatios: modelPost.optionA.aspectRatio != null
            ? [modelPost.optionA.aspectRatio!]
            : [],
        metadata: {
          'mediaType': modelPost.optionA.mediaType,
        },
      ),
      optionB: entity.PostOption(
        text: modelPost.optionB.text.isNotEmpty ? modelPost.optionB.text : null,
        imageUrls: modelPost.optionB.imageUrls,
        videoUrls: modelPost.optionB.videoUrls.isNotEmpty
            ? modelPost.optionB.videoUrls
            : null,
        aspectRatios: modelPost.optionB.aspectRatio != null
            ? [modelPost.optionB.aspectRatio!]
            : [],
        metadata: {
          'mediaType': modelPost.optionB.mediaType,
        },
      ),
      targetAudience: _convertTargetAudience(modelPost.targetAudience),
      createdAt: modelPost.createdAt,
      updatedAt: modelPost.updatedAt,
      status: _getPostStatus(modelPost),
      likeCount: modelPost.stats.likeCount,
      commentCount: modelPost.stats.commentCount,
      votesA: modelPost.voteData.votesA,
      votesB: modelPost.voteData.votesB,
      voteStartTime: modelPost.voteData.voteStartTime,
      voteEndTime: modelPost.voteData.voteEndTime,
      isAnonymous: modelPost.isAnonymous,
      metadata: {
        'moderation': modelPost.moderation,
        'tags': modelPost.tags,
        'category': modelPost.category,
        'visibility': modelPost.visibility,
        'premiumRequired': modelPost.premiumRequired,
        'location': modelPost.location != null
            ? {
                'latitude': modelPost.location!.latitude,
                'longitude': modelPost.location!.longitude,
              }
            : null,
        'creatorInfo': {
          'displayName': modelPost.creatorInfo.displayName,
          'photoUrl': modelPost.creatorInfo.photoUrl,
          'email': modelPost.creatorInfo.email,
        },
      },
    );
  }

  /// Convert List of entity Posts to List of model Posts
  static List<model.Post> fromEntities(List<entity.Post> entityPosts) {
    return entityPosts.map((post) => fromEntity(post)).toList();
  }

  /// Convert List of model Posts to List of entity Posts
  static List<entity.Post> toEntities(List<model.Post> modelPosts) {
    return modelPosts.map((post) => toEntity(post)).toList();
  }

  // Helper methods
  static bool _isVotingActive(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) return false;
    final now = DateTime.now();
    return now.isAfter(startTime) && now.isBefore(endTime);
  }

  static String _getVoteStatus(DateTime? startTime, DateTime? endTime) {
    if (startTime == null || endTime == null) return 'inactive';
    if (_isVotingActive(startTime, endTime)) return 'active';
    if (DateTime.now().isAfter(endTime)) return 'completed';
    return 'pending';
  }

  static bool _isVoteCompleted(DateTime? endTime) {
    if (endTime == null) return false;
    return DateTime.now().isAfter(endTime);
  }

  static entity.PostStatus _getPostStatus(model.Post modelPost) {
    // Determine status based on vote data
    if (modelPost.voteData.voteCompleted) {
      return entity.PostStatus.completed;
    } else if (_isVotingActive(
        modelPost.voteData.voteStartTime, modelPost.voteData.voteEndTime)) {
      return entity.PostStatus.voting;
    } else if (modelPost.visibility == 0) {
      return entity.PostStatus.draft;
    } else {
      return entity.PostStatus.published;
    }
  }

  static TargetAudience? _convertTargetAudience(Map<String, dynamic> audienceMap) {
    if (audienceMap.isEmpty) return null;

    try {
      return TargetAudience(
        mode: audienceMap['mode'] ?? 'public',
        selectedUserIds: List<String>.from(audienceMap['selectedUserIds'] ?? []),
        filters: Map<String, dynamic>.from(audienceMap['filters'] ?? {}),
        maxUsers: audienceMap['maxUsers'] ?? 10,
        createdAt: audienceMap['createdAt'] is DateTime
            ? audienceMap['createdAt']
            : DateTime.now(),
      );
    } catch (e) {
      print('Error converting target audience: $e');
      return null;
    }
  }
}