/// UserStats Domain Model
/// Clean Architecture - Domain Layer Entity
/// 
/// This model contains user gamification statistics, points, rankings,
/// and social metrics, separated from profile and authentication data
/// for better separation of concerns and performance optimization.
class UserStats {
  const UserStats({
    required this.userId,
    this.pointsA = 0,
    this.pointsQ = 0,
    this.totalAPoints = 0,
    this.totalQPoints = 0,
    this.currentRank = '',
    this.currentTitle = '',
    this.rankChangeDate,
    this.titleChangeDate,
    this.isRankEligible = false,
    this.rankEvaluationCount = 0,
    this.friends = const [],
    this.activeChats = const [],
    this.rankHistory = const [],
    this.titleHistory = const [],
    this.anonymousPostsCount = 0,
    this.anonymousCommentsCount = 0,
  });

  // Core Fields
  final String userId; // Foreign key to AuthUser.uid
  
  // Points System
  final int pointsA; // Answer points (current)
  final int pointsQ; // Question points (current)
  final int totalAPoints; // Total answer points (lifetime)
  final int totalQPoints; // Total question points (lifetime)
  
  // Ranking System
  final String currentRank;
  final String currentTitle;
  final DateTime? rankChangeDate;
  final DateTime? titleChangeDate;
  final bool isRankEligible;
  final int rankEvaluationCount;
  
  // Social Connections
  final List<String> friends; // Friend user IDs
  final List<String> activeChats; // Active chat IDs
  
  // History
  final List<String> rankHistory;
  final List<String> titleHistory;
  
  // Activity Metrics
  final int anonymousPostsCount;
  final int anonymousCommentsCount;

  /// Create UserStats from Map (Firestore or cache)
  factory UserStats.fromMap(Map<String, dynamic> data, String userId) {
    return UserStats(
      userId: userId,
      pointsA: data['pointsA'] ?? 0,
      pointsQ: data['pointsQ'] ?? 0,
      totalAPoints: data['totalAPoints'] ?? 0,
      totalQPoints: data['totalQPoints'] ?? 0,
      currentRank: data['currentRank'] ?? '',
      currentTitle: data['currentTitle'] ?? '',
      rankChangeDate: data['rankChangeDate']?.toDate(),
      titleChangeDate: data['titleChangeDate']?.toDate(),
      isRankEligible: data['isRankEligible'] ?? false,
      rankEvaluationCount: data['rankEvaluationCount'] ?? 0,
      friends: List<String>.from(data['friends'] ?? []),
      activeChats: List<String>.from(data['activeChats'] ?? []),
      rankHistory: List<String>.from(data['rankHistory'] ?? []),
      titleHistory: List<String>.from(data['titleHistory'] ?? []),
      anonymousPostsCount: data['anonymousPostsCount'] ?? 0,
      anonymousCommentsCount: data['anonymousCommentsCount'] ?? 0,
    );
  }

  /// Create UserStats from JSON (for caching)
  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] ?? '',
      pointsA: json['pointsA'] ?? 0,
      pointsQ: json['pointsQ'] ?? 0,
      totalAPoints: json['totalAPoints'] ?? 0,
      totalQPoints: json['totalQPoints'] ?? 0,
      currentRank: json['currentRank'] ?? '',
      currentTitle: json['currentTitle'] ?? '',
      rankChangeDate: json['rankChangeDate'] != null 
          ? DateTime.parse(json['rankChangeDate'])
          : null,
      titleChangeDate: json['titleChangeDate'] != null 
          ? DateTime.parse(json['titleChangeDate'])
          : null,
      isRankEligible: json['isRankEligible'] ?? false,
      rankEvaluationCount: json['rankEvaluationCount'] ?? 0,
      friends: List<String>.from(json['friends'] ?? []),
      activeChats: List<String>.from(json['activeChats'] ?? []),
      rankHistory: List<String>.from(json['rankHistory'] ?? []),
      titleHistory: List<String>.from(json['titleHistory'] ?? []),
      anonymousPostsCount: json['anonymousPostsCount'] ?? 0,
      anonymousCommentsCount: json['anonymousCommentsCount'] ?? 0,
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'totalAPoints': totalAPoints,
      'totalQPoints': totalQPoints,
      'currentRank': currentRank,
      'currentTitle': currentTitle,
      if (rankChangeDate != null) 'rankChangeDate': rankChangeDate,
      if (titleChangeDate != null) 'titleChangeDate': titleChangeDate,
      'isRankEligible': isRankEligible,
      'rankEvaluationCount': rankEvaluationCount,
      'friends': friends,
      'activeChats': activeChats,
      'rankHistory': rankHistory,
      'titleHistory': titleHistory,
      'anonymousPostsCount': anonymousPostsCount,
      'anonymousCommentsCount': anonymousCommentsCount,
    };
  }

  /// Convert to JSON for caching
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'pointsA': pointsA,
      'pointsQ': pointsQ,
      'totalAPoints': totalAPoints,
      'totalQPoints': totalQPoints,
      'currentRank': currentRank,
      'currentTitle': currentTitle,
      if (rankChangeDate != null) 'rankChangeDate': rankChangeDate!.toIso8601String(),
      if (titleChangeDate != null) 'titleChangeDate': titleChangeDate!.toIso8601String(),
      'isRankEligible': isRankEligible,
      'rankEvaluationCount': rankEvaluationCount,
      'friends': friends,
      'activeChats': activeChats,
      'rankHistory': rankHistory,
      'titleHistory': titleHistory,
      'anonymousPostsCount': anonymousPostsCount,
      'anonymousCommentsCount': anonymousCommentsCount,
    };
  }

  /// Create a copy with updated fields
  UserStats copyWith({
    String? userId,
    int? pointsA,
    int? pointsQ,
    int? totalAPoints,
    int? totalQPoints,
    String? currentRank,
    String? currentTitle,
    DateTime? rankChangeDate,
    DateTime? titleChangeDate,
    bool? isRankEligible,
    int? rankEvaluationCount,
    List<String>? friends,
    List<String>? activeChats,
    List<String>? rankHistory,
    List<String>? titleHistory,
    int? anonymousPostsCount,
    int? anonymousCommentsCount,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      pointsA: pointsA ?? this.pointsA,
      pointsQ: pointsQ ?? this.pointsQ,
      totalAPoints: totalAPoints ?? this.totalAPoints,
      totalQPoints: totalQPoints ?? this.totalQPoints,
      currentRank: currentRank ?? this.currentRank,
      currentTitle: currentTitle ?? this.currentTitle,
      rankChangeDate: rankChangeDate ?? this.rankChangeDate,
      titleChangeDate: titleChangeDate ?? this.titleChangeDate,
      isRankEligible: isRankEligible ?? this.isRankEligible,
      rankEvaluationCount: rankEvaluationCount ?? this.rankEvaluationCount,
      friends: friends ?? this.friends,
      activeChats: activeChats ?? this.activeChats,
      rankHistory: rankHistory ?? this.rankHistory,
      titleHistory: titleHistory ?? this.titleHistory,
      anonymousPostsCount: anonymousPostsCount ?? this.anonymousPostsCount,
      anonymousCommentsCount: anonymousCommentsCount ?? this.anonymousCommentsCount,
    );
  }

  /// Calculate total points
  int get totalPoints => totalAPoints + totalQPoints;

  /// Check if user has any points
  bool get hasPoints => totalPoints > 0;

  /// Get friend count
  int get friendCount => friends.length;

  /// Check if user has reached a milestone
  bool hasReachedMilestone(int milestone) => totalPoints >= milestone;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserStats && other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;

  @override
  String toString() {
    return 'UserStats(userId: $userId, totalPoints: $totalPoints, rank: $currentRank, friends: $friendCount)';
  }
}