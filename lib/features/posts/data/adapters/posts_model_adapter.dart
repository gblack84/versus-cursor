import 'package:cloud_firestore/cloud_firestore.dart';
// Removed backend dependency - using cloud_firestore GeoPoint directly
import '../../domain/models/post_core.dart';
import '../../domain/models/post_content.dart';
import '../../domain/models/post_voting.dart';
import '../../domain/models/post_metrics.dart';
import '../../domain/models/media_content.dart';
import '../models/posts_model.dart';

/// PostBundle - Convenience class to group the 4 domain models
class PostBundle {
  const PostBundle({
    required this.core,
    required this.content,
    required this.voting,
    required this.metrics,
  });

  final PostCore core;
  final PostContent content;
  final PostVoting voting;
  final PostMetrics metrics;

  /// Get the post ID (consistent across all models)
  String get postId => core.id;

  /// Check if all models are for the same post
  bool get isConsistent => 
      core.id == content.postId && 
      core.id == voting.postId && 
      core.id == metrics.postId;
}

/// PostsModelAdapter - Converts between legacy PostsModel and new domain models
class PostsModelAdapter {
  
  // ============= CONVERSION METHODS =============
  
  /// Converts legacy PostsModel to tuple of 4 domain models
  static PostBundle toDomainModels(PostsModel postsModel) {
    final postId = postsModel.reference.id;
    
    return PostBundle(
      core: _convertToPostCore(postsModel, postId),
      content: _convertToPostContent(postsModel, postId),
      voting: _convertToPostVoting(postsModel, postId),
      metrics: _convertToPostMetrics(postsModel, postId),
    );
  }
  
  /// Converts 4 domain models back to legacy PostsModel
  static PostsModel fromDomainModels(PostBundle bundle) {
    if (!bundle.isConsistent) {
      throw ArgumentError('All domain models must have the same postId');
    }
    
    final data = <String, dynamic>{
      // PostCore fields
      ..._convertFromPostCore(bundle.core),
      
      // PostContent fields  
      ..._convertFromPostContent(bundle.content),
      
      // PostVoting fields
      ..._convertFromPostVoting(bundle.voting),
      
      // PostMetrics fields
      ..._convertFromPostMetrics(bundle.metrics),
    };

    return PostsModel.getDocumentFromData(
      data,
      FirebaseFirestore.instance.collection('posts').doc(bundle.postId),
    );
  }

  // ============= INDIVIDUAL CONVERSIONS =============

  /// Convert PostsModel to PostCore
  static PostCore _convertToPostCore(PostsModel postsModel, String postId) {
    return PostCore(
      id: postId,
      questionTitle: postsModel.questionTitle,
      description: postsModel.description.isNotEmpty ? postsModel.description : null,
      content: postsModel.content.isNotEmpty ? postsModel.content : null,
      userId: postsModel.userid.isNotEmpty ? postsModel.userid : postsModel.uid,
      createdAt: postsModel.createdAt ?? DateTime.now(),
      updatedAt: postsModel.updatedAt,
      category: postsModel.category.isNotEmpty ? postsModel.category : null,
      tags: postsModel.tags,
      visibility: _convertVisibilityToString(postsModel.visibility),
      isAnonymous: postsModel.isAnonymous,
      premiumRequired: postsModel.premiumRequired,
      location: postsModel.location != null 
          ? GeoPoint(postsModel.location!.latitude, postsModel.location!.longitude)
          : null,
    );
  }

  /// Convert PostsModel to PostContent
  static PostContent _convertToPostContent(PostsModel postsModel, String postId) {
    return PostContent(
      postId: postId,
      optionA: MediaContent.fromMap(postsModel.optionA),
      optionB: MediaContent.fromMap(postsModel.optionB),
      layoutType: _determineLayoutType(postsModel),
      targetAudience: postsModel.targetAudience.isNotEmpty ? postsModel.targetAudience : null,
      moderation: postsModel.moderation.isNotEmpty ? postsModel.moderation : null,
      processingStatus: 'completed', // Legacy models are assumed processed
      processedAt: postsModel.createdAt,
    );
  }

  /// Convert PostsModel to PostVoting
  static PostVoting _convertToPostVoting(PostsModel postsModel, String postId) {
    return PostVoting(
      postId: postId,
      voteStartTime: postsModel.voteStartTime,
      voteEndTime: postsModel.voteEndTime,
      voteStatus: postsModel.voteStatus.isNotEmpty ? postsModel.voteStatus : 'pending',
      voteCompleted: postsModel.voteCompleted || postsModel.isVotingComplete,
      voteCompletedAt: postsModel.voteCompletedAt,
      voteCancelledAt: postsModel.voteCancelledAt,
      voteCancelledReason: postsModel.voteCancelledReason.isNotEmpty ? postsModel.voteCancelledReason : null,
      voteTimeout: const Duration(minutes: 10), // Default timeout
      votesA: postsModel.votesA,
      votesB: postsModel.votesB,
      votedUserIdsA: postsModel.votedUserIdsA,
      votedUserIdsB: postsModel.votedUserIdsB,
      displayVotesA: postsModel.displayVotesA > 0 ? postsModel.displayVotesA : null,
      displayVotesB: postsModel.displayVotesB > 0 ? postsModel.displayVotesB : null,
      notificationsSent: postsModel.notificationsSent,
      notificationsSentAt: postsModel.notificationsSentAt,
      expansionPointsUsed: postsModel.expansionPointsUsed,
      expandedUserCount: postsModel.expandedUserCount,
      expansionStatus: postsModel.expansionStatus.isNotEmpty ? postsModel.expansionStatus : 'none',
    );
  }

  /// Convert PostsModel to PostMetrics
  static PostMetrics _convertToPostMetrics(PostsModel postsModel, String postId) {
    return PostMetrics(
      postId: postId,
      commentCount: postsModel.commentcount,
      likeCount: postsModel.likecount,
      shareCount: postsModel.sherecount, // Note: original typo preserved
      saveCount: postsModel.savecount,
      reportCount: postsModel.reportCount,
      participantCount: postsModel.participantcount,
      interestCount: postsModel.interestcount,
      // Calculate engagement metrics
      engagementRate: _calculateEngagementRate(postsModel),
      qualityScore: _calculateQualityScore(postsModel),
      // Temporal data
      firstInteractionAt: postsModel.createdAt,
      lastInteractionAt: postsModel.updatedAt ?? postsModel.createdAt,
    );
  }

  // ============= REVERSE CONVERSIONS =============

  /// Convert PostCore back to map data
  static Map<String, dynamic> _convertFromPostCore(PostCore core) {
    return {
      'questionTitle': core.questionTitle,
      if (core.description != null) 'description': core.description,
      if (core.content != null) 'content': core.content,
      'userid': core.userId,
      'uid': core.userId, // For backward compatibility
      'createdAt': core.createdAt,
      if (core.updatedAt != null) 'updatedAt': core.updatedAt,
      if (core.category != null) 'category': core.category,
      'tags': core.tags,
      'visibility': _convertVisibilityToInt(core.visibility),
      'isAnonymous': core.isAnonymous,
      'premiumRequired': core.premiumRequired,
      if (core.location != null) 'location': core.location,
      
      // Add legacy user info fields for compatibility
      'email': '', // These would need to be retrieved from user profile
      'displayName': '',
      'photoUrl': '',
      'phoneNumber': '',
      'createdTime': core.createdAt,
      'creatorInfo': {
        'userid': core.userId,
        'uid': core.userId,
      },
    };
  }

  /// Convert PostContent back to map data
  static Map<String, dynamic> _convertFromPostContent(PostContent content) {
    return {
      'optionA': content.optionA.toMap(),
      'optionB': content.optionB.toMap(),
      'layoutType': content.layoutType,
      if (content.targetAudience != null) 'targetAudience': content.targetAudience,
      if (content.moderation != null) 'moderation': content.moderation,
    };
  }

  /// Convert PostVoting back to map data  
  static Map<String, dynamic> _convertFromPostVoting(PostVoting voting) {
    return {
      if (voting.voteStartTime != null) 'voteStartTime': voting.voteStartTime,
      if (voting.voteEndTime != null) 'voteEndTime': voting.voteEndTime,
      'voteStatus': voting.voteStatus,
      'voteCompleted': voting.voteCompleted,
      'isVotingComplete': voting.voteCompleted, // For backward compatibility
      if (voting.voteCompletedAt != null) 'voteCompletedAt': voting.voteCompletedAt,
      if (voting.voteCancelledAt != null) 'voteCancelledAt': voting.voteCancelledAt,
      if (voting.voteCancelledReason != null) 'voteCancelledReason': voting.voteCancelledReason,
      'voteTimeout': false, // Legacy boolean field
      'votesA': voting.votesA,
      'votesB': voting.votesB,
      'votedUserIdsA': voting.votedUserIdsA,
      'votedUserIdsB': voting.votedUserIdsB,
      'totalVotes': voting.totalVotes,
      if (voting.displayVotesA != null) 'displayVotesA': voting.displayVotesA,
      if (voting.displayVotesB != null) 'displayVotesB': voting.displayVotesB,
      'notificationsSent': voting.notificationsSent,
      if (voting.notificationsSentAt != null) 'notificationsSentAt': voting.notificationsSentAt,
      'expansionPointsUsed': voting.expansionPointsUsed,
      'expandedUserCount': voting.expandedUserCount,
      'expansionStatus': voting.expansionStatus,
      
      // Additional legacy fields for display percentages and actual votes
      'displayPercentA': voting.totalVotes > 0 ? ((voting.displayVotesAFinal / voting.totalVotes) * 100).round() : 0,
      'displayPercentB': voting.totalVotes > 0 ? ((voting.displayVotesBFinal / voting.totalVotes) * 100).round() : 0,
      'actualVotesA': voting.votesA,
      'actualVotesB': voting.votesB,
      'actualTotalVotes': voting.totalVotes,
    };
  }

  /// Convert PostMetrics back to map data
  static Map<String, dynamic> _convertFromPostMetrics(PostMetrics metrics) {
    return {
      'commentcount': metrics.commentCount,
      'likecount': metrics.likeCount,
      'sherecount': metrics.shareCount, // Preserve original typo
      'savecount': metrics.saveCount,
      'reportCount': metrics.reportCount,
      'participantcount': metrics.participantCount,
      'interestcount': metrics.interestCount,
      
      // Legacy stats object
      'stats': {
        'commentCount': metrics.commentCount,
        'likeCount': metrics.likeCount,
        'shareCount': metrics.shareCount,
        'saveCount': metrics.saveCount,
        'participantCount': metrics.participantCount,
        'reportCount': metrics.reportCount,
      },
      
      // Reporting fields
      'isReported': metrics.reportCount > 0,
      'reportedBy': [], // Would need to be maintained separately
      
      // Comment management
      'initialCommentLimit': 10, // Default value
      'currentCommentCount': metrics.commentCount,
      'option': [], // Legacy field - empty list
    };
  }

  // ============= HELPER METHODS =============

  /// Convert integer visibility to string
  static String _convertVisibilityToString(int visibility) {
    switch (visibility) {
      case 0:
        return 'public';
      case 1:
        return 'private';
      case 2:
        return 'friends';
      default:
        return 'public';
    }
  }

  /// Convert string visibility to integer
  static int _convertVisibilityToInt(String visibility) {
    switch (visibility) {
      case 'public':
        return 0;
      case 'private':
        return 1;
      case 'friends':
        return 2;
      default:
        return 0;
    }
  }

  /// Determine layout type from PostsModel data
  static String _determineLayoutType(PostsModel postsModel) {
    // Try to infer from content
    final optionA = MediaContent.fromMap(postsModel.optionA);
    final optionB = MediaContent.fromMap(postsModel.optionB);
    
    if (optionB.isEmpty) return 'single';
    
    // Use aspect ratios to determine layout
    if (optionA.aspectRatio != null && optionB.aspectRatio != null) {
      final ratioA = optionA.aspectRatio!;
      final ratioB = optionB.aspectRatio!;
      
      // Both portrait
      if (ratioA < 1.0 && ratioB < 1.0) return 'horizontal';
      // Both landscape  
      if (ratioA > 1.5 && ratioB > 1.5) return 'vertical';
    }
    
    return 'vertical'; // Default
  }

  /// Calculate engagement rate from legacy data
  static double _calculateEngagementRate(PostsModel postsModel) {
    final interactions = postsModel.commentcount + postsModel.likecount + 
                        postsModel.sherecount + postsModel.savecount;
    final impressions = postsModel.participantcount;
    
    if (impressions == 0) return 0.0;
    return (interactions / impressions) * 100;
  }

  /// Calculate quality score from legacy data
  static double _calculateQualityScore(PostsModel postsModel) {
    final likeRatio = postsModel.likecount / (postsModel.likecount + 1); // Avoid division by zero
    final engagementRate = _calculateEngagementRate(postsModel);
    final reportPenalty = (1.0 - (postsModel.reportCount / 10)).clamp(0.0, 1.0);
    
    return (likeRatio * 0.4 + 
            (engagementRate / 10).clamp(0.0, 1.0) * 0.4 +
            reportPenalty * 0.2);
  }

  // ============= BATCH CONVERSIONS =============

  /// Convert list of PostsModels to PostBundles
  static List<PostBundle> toDomainModelsList(List<PostsModel> postsModels) {
    return postsModels.map(toDomainModels).toList();
  }

  /// Convert list of PostBundles to PostsModels
  static List<PostsModel> fromDomainModelsList(List<PostBundle> bundles) {
    return bundles.map(fromDomainModels).toList();
  }

  // ============= CONVENIENCE METHODS =============

  /// Extract just the PostCore from PostsModel
  static PostCore extractCore(PostsModel postsModel) {
    return _convertToPostCore(postsModel, postsModel.reference.id);
  }

  /// Extract just the PostContent from PostsModel
  static PostContent extractContent(PostsModel postsModel) {
    return _convertToPostContent(postsModel, postsModel.reference.id);
  }

  /// Extract just the PostVoting from PostsModel  
  static PostVoting extractVoting(PostsModel postsModel) {
    return _convertToPostVoting(postsModel, postsModel.reference.id);
  }

  /// Extract just the PostMetrics from PostsModel
  static PostMetrics extractMetrics(PostsModel postsModel) {
    return _convertToPostMetrics(postsModel, postsModel.reference.id);
  }
}