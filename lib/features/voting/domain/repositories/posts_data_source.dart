/// Domain interface for accessing post-related data from voting feature
/// 
/// This interface follows Dependency Inversion Principle to avoid
/// direct dependency on Posts feature's data layer
abstract class PostsDataSource {
  /// Get ranked posts for voting calculations
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  });
  
  /// Get a single ranked post by ID
  Future<RankedPostsData?> getRankedPostById(String postId);
}

/// Domain model for ranked posts data
/// This is a simplified interface that voting feature needs
class RankedPostsData {
  final String postId;
  final int rank;
  final double score;
  final int votesA;
  final int votesB;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? category;

  RankedPostsData({
    required this.postId,
    required this.rank,
    required this.score,
    required this.votesA,
    required this.votesB,
    this.createdAt,
    this.updatedAt,
    this.category,
  });
}