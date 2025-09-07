/// PostMetrics Domain Model
/// Clean Architecture - Domain Layer Entity
/// 
/// Manages analytics, statistics, and engagement metrics for posts.
/// Handles view counts, interaction rates, and trend analysis.
class PostMetrics {
  const PostMetrics({
    required this.postId,
    this.viewCount = 0,
    this.impressionCount = 0,
    this.reachCount = 0,
    this.commentCount = 0,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    this.reportCount = 0,
    this.participantCount = 0,
    this.interestCount = 0,
    this.engagementRate = 0.0,
    this.viralityScore = 0.0,
    this.trendingScore = 0.0,
    this.qualityScore = 0.0,
    this.firstInteractionAt,
    this.lastInteractionAt,
    this.peakInteractionAt,
    this.hourlyStats = const {},
    this.dailyStats = const {},
    this.demographicStats = const {},
    this.referralSources = const {},
    this.deviceStats = const {},
    this.regionStats = const {},
  });

  // Core Identity
  final String postId; // Foreign key to PostCore.id
  
  // View Metrics
  final int viewCount; // Total views
  final int impressionCount; // Total impressions (feed appearances)
  final int reachCount; // Unique users reached
  
  // Engagement Metrics
  final int commentCount;
  final int likeCount;
  final int dislikeCount;
  final int shareCount;
  final int saveCount;
  final int reportCount;
  final int participantCount; // Unique users who interacted
  final int interestCount; // Users who showed interest
  
  // Calculated Metrics
  final double engagementRate; // (interactions / impressions) * 100
  final double viralityScore; // Share rate and spread coefficient
  final double trendingScore; // Current trending strength
  final double qualityScore; // Content quality based on engagement
  
  // Temporal Analytics
  final DateTime? firstInteractionAt;
  final DateTime? lastInteractionAt;
  final DateTime? peakInteractionAt;
  
  // Advanced Analytics Maps
  final Map<String, dynamic> hourlyStats; // 24-hour breakdown
  final Map<String, dynamic> dailyStats; // 30-day breakdown
  final Map<String, dynamic> demographicStats; // Age, gender, location
  final Map<String, dynamic> referralSources; // Where traffic comes from
  final Map<String, dynamic> deviceStats; // Mobile, desktop, tablet
  final Map<String, dynamic> regionStats; // Geographic distribution

  // ============= Computed Properties =============
  
  /// Total interaction count
  int get totalInteractions => 
      commentCount + likeCount + dislikeCount + shareCount + saveCount;
  
  /// Like/dislike ratio
  double get likeRatio {
    final total = likeCount + dislikeCount;
    if (total == 0) return 0.0;
    return likeCount / total;
  }
  
  /// Net sentiment (likes - dislikes)
  int get netSentiment => likeCount - dislikeCount;
  
  /// Engagement per view
  double get engagementPerView {
    if (viewCount == 0) return 0.0;
    return totalInteractions / viewCount;
  }
  
  /// Average time between interactions
  Duration? get averageInteractionInterval {
    if (firstInteractionAt == null || lastInteractionAt == null) return null;
    if (totalInteractions <= 1) return null;
    
    final totalDuration = lastInteractionAt!.difference(firstInteractionAt!);
    return Duration(
      milliseconds: totalDuration.inMilliseconds ~/ (totalInteractions - 1)
    );
  }
  
  /// Check if post is viral
  bool get isViral => viralityScore > 0.7;
  
  /// Check if post is trending
  bool get isTrending => trendingScore > 0.5;
  
  /// Check if post is high quality
  bool get isHighQuality => qualityScore > 0.8;
  
  /// Check if post needs moderation
  bool get needsModeration => reportCount > 5;
  
  /// Get engagement level
  String get engagementLevel {
    if (engagementRate < 1) return 'very_low';
    if (engagementRate < 3) return 'low';
    if (engagementRate < 5) return 'medium';
    if (engagementRate < 10) return 'high';
    return 'very_high';
  }
  
  // ============= Analytics Methods =============
  
  /// Calculate engagement rate
  static double calculateEngagementRate({
    required int interactions,
    required int impressions,
  }) {
    if (impressions == 0) return 0.0;
    return (interactions / impressions) * 100;
  }
  
  /// Calculate virality score (0.0 to 1.0)
  static double calculateViralityScore({
    required int shares,
    required int views,
    required Duration age,
  }) {
    if (views == 0) return 0.0;
    
    final shareRate = shares / views;
    final velocityFactor = 1.0 / (1 + age.inHours / 24); // Decay over time
    
    return (shareRate * velocityFactor).clamp(0.0, 1.0);
  }
  
  /// Calculate trending score (0.0 to 1.0)
  static double calculateTrendingScore({
    required int recentInteractions,
    required int totalInteractions,
    required Duration timePeriod,
  }) {
    if (totalInteractions == 0) return 0.0;
    
    final recencyFactor = recentInteractions / totalInteractions;
    final velocityFactor = recentInteractions / (timePeriod.inHours + 1);
    
    return ((recencyFactor + velocityFactor) / 2).clamp(0.0, 1.0);
  }
  
  /// Calculate quality score (0.0 to 1.0)
  static double calculateQualityScore({
    required double likeRatio,
    required double engagementRate,
    required int reportCount,
    required int participantCount,
  }) {
    final sentimentScore = likeRatio;
    final engagementScore = (engagementRate / 10).clamp(0.0, 1.0);
    final reportPenalty = (1.0 - (reportCount / 10)).clamp(0.0, 1.0);
    final participationScore = (participantCount / 100).clamp(0.0, 1.0);
    
    return (sentimentScore * 0.3 + 
            engagementScore * 0.3 + 
            reportPenalty * 0.2 + 
            participationScore * 0.2);
  }
  
  // ============= State Updates =============
  
  /// Update with new interaction
  PostMetrics recordInteraction({
    required String type,
    Map<String, dynamic>? metadata,
  }) {
    final now = DateTime.now();
    
    return copyWith(
      commentCount: type == 'comment' ? commentCount + 1 : commentCount,
      likeCount: type == 'like' ? likeCount + 1 : likeCount,
      dislikeCount: type == 'dislike' ? dislikeCount + 1 : dislikeCount,
      shareCount: type == 'share' ? shareCount + 1 : shareCount,
      saveCount: type == 'save' ? saveCount + 1 : saveCount,
      reportCount: type == 'report' ? reportCount + 1 : reportCount,
      lastInteractionAt: now,
      firstInteractionAt: firstInteractionAt ?? now,
    );
  }
  
  /// Update view metrics
  PostMetrics recordView({
    bool isUnique = true,
    Map<String, dynamic>? metadata,
  }) {
    return copyWith(
      viewCount: viewCount + 1,
      reachCount: isUnique ? reachCount + 1 : reachCount,
    );
  }
  
  /// Update calculated metrics
  PostMetrics updateCalculatedMetrics() {
    return copyWith(
      engagementRate: calculateEngagementRate(
        interactions: totalInteractions,
        impressions: impressionCount,
      ),
      qualityScore: calculateQualityScore(
        likeRatio: likeRatio,
        engagementRate: engagementRate,
        reportCount: reportCount,
        participantCount: participantCount,
      ),
    );
  }
  
  // ============= Serialization =============
  
  /// Create from Firestore document
  factory PostMetrics.fromMap(Map<String, dynamic> data, String postId) {
    // Handle both old field names and new structure
    return PostMetrics(
      postId: postId,
      viewCount: data['viewCount'] ?? 0,
      impressionCount: data['impressionCount'] ?? 0,
      reachCount: data['reachCount'] ?? 0,
      commentCount: data['commentCount'] ?? data['commentcount'] ?? 0,
      likeCount: data['likeCount'] ?? data['likecount'] ?? 0,
      dislikeCount: data['dislikeCount'] ?? 0,
      shareCount: data['shareCount'] ?? data['sherecount'] ?? 0, // Note: typo in original
      saveCount: data['saveCount'] ?? data['savecount'] ?? 0,
      reportCount: data['reportCount'] ?? 0,
      participantCount: data['participantCount'] ?? data['participantcount'] ?? 0,
      interestCount: data['interestCount'] ?? data['interestcount'] ?? 0,
      engagementRate: (data['engagementRate'] ?? 0).toDouble(),
      viralityScore: (data['viralityScore'] ?? 0).toDouble(),
      trendingScore: (data['trendingScore'] ?? 0).toDouble(),
      qualityScore: (data['qualityScore'] ?? 0).toDouble(),
      firstInteractionAt: data['firstInteractionAt']?.toDate(),
      lastInteractionAt: data['lastInteractionAt']?.toDate(),
      peakInteractionAt: data['peakInteractionAt']?.toDate(),
      hourlyStats: Map<String, dynamic>.from(data['hourlyStats'] ?? {}),
      dailyStats: Map<String, dynamic>.from(data['dailyStats'] ?? {}),
      demographicStats: Map<String, dynamic>.from(data['demographicStats'] ?? {}),
      referralSources: Map<String, dynamic>.from(data['referralSources'] ?? {}),
      deviceStats: Map<String, dynamic>.from(data['deviceStats'] ?? {}),
      regionStats: Map<String, dynamic>.from(data['regionStats'] ?? {}),
    );
  }
  
  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'viewCount': viewCount,
      'impressionCount': impressionCount,
      'reachCount': reachCount,
      'commentCount': commentCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'shareCount': shareCount,
      'saveCount': saveCount,
      'reportCount': reportCount,
      'participantCount': participantCount,
      'interestCount': interestCount,
      'engagementRate': engagementRate,
      'viralityScore': viralityScore,
      'trendingScore': trendingScore,
      'qualityScore': qualityScore,
      if (firstInteractionAt != null) 'firstInteractionAt': firstInteractionAt,
      if (lastInteractionAt != null) 'lastInteractionAt': lastInteractionAt,
      if (peakInteractionAt != null) 'peakInteractionAt': peakInteractionAt,
      if (hourlyStats.isNotEmpty) 'hourlyStats': hourlyStats,
      if (dailyStats.isNotEmpty) 'dailyStats': dailyStats,
      if (demographicStats.isNotEmpty) 'demographicStats': demographicStats,
      if (referralSources.isNotEmpty) 'referralSources': referralSources,
      if (deviceStats.isNotEmpty) 'deviceStats': deviceStats,
      if (regionStats.isNotEmpty) 'regionStats': regionStats,
    };
  }
  
  /// Create a copy with updated fields
  PostMetrics copyWith({
    String? postId,
    int? viewCount,
    int? impressionCount,
    int? reachCount,
    int? commentCount,
    int? likeCount,
    int? dislikeCount,
    int? shareCount,
    int? saveCount,
    int? reportCount,
    int? participantCount,
    int? interestCount,
    double? engagementRate,
    double? viralityScore,
    double? trendingScore,
    double? qualityScore,
    DateTime? firstInteractionAt,
    DateTime? lastInteractionAt,
    DateTime? peakInteractionAt,
    Map<String, dynamic>? hourlyStats,
    Map<String, dynamic>? dailyStats,
    Map<String, dynamic>? demographicStats,
    Map<String, dynamic>? referralSources,
    Map<String, dynamic>? deviceStats,
    Map<String, dynamic>? regionStats,
  }) {
    return PostMetrics(
      postId: postId ?? this.postId,
      viewCount: viewCount ?? this.viewCount,
      impressionCount: impressionCount ?? this.impressionCount,
      reachCount: reachCount ?? this.reachCount,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      reportCount: reportCount ?? this.reportCount,
      participantCount: participantCount ?? this.participantCount,
      interestCount: interestCount ?? this.interestCount,
      engagementRate: engagementRate ?? this.engagementRate,
      viralityScore: viralityScore ?? this.viralityScore,
      trendingScore: trendingScore ?? this.trendingScore,
      qualityScore: qualityScore ?? this.qualityScore,
      firstInteractionAt: firstInteractionAt ?? this.firstInteractionAt,
      lastInteractionAt: lastInteractionAt ?? this.lastInteractionAt,
      peakInteractionAt: peakInteractionAt ?? this.peakInteractionAt,
      hourlyStats: hourlyStats ?? this.hourlyStats,
      dailyStats: dailyStats ?? this.dailyStats,
      demographicStats: demographicStats ?? this.demographicStats,
      referralSources: referralSources ?? this.referralSources,
      deviceStats: deviceStats ?? this.deviceStats,
      regionStats: regionStats ?? this.regionStats,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostMetrics && other.postId == postId;
  }
  
  @override
  int get hashCode => postId.hashCode;
  
  @override
  String toString() {
    return 'PostMetrics(postId: $postId, views: $viewCount, engagement: ${engagementRate.toStringAsFixed(2)}%)';
  }
}