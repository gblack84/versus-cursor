import '/core/interfaces/features/i_post_service.dart';
import '/core/interfaces/common/i_content_model.dart';

/// Mock implementation of IPostService for notifications feature
/// 
/// This is a temporary implementation until Posts feature provides
/// a proper implementation of IPostService interface
class MockPostServiceAdapter implements IPostService {
  // Test data storage
  final Map<String, IVersusContentModel> _posts = {};
  
  MockPostServiceAdapter() {
    _initTestData();
  }
  
  void _initTestData() {
    // Initialize with some test data
    final testPost = MockVersusContentModel(
      id: 'test_post_1',
      title: 'Test Post 1',
      content: 'This is a test post content',
      optionAText: 'Option A',
      optionBText: 'Option B',
      optionAImageUrls: ['https://example.com/imageA.jpg'],
      optionBImageUrls: ['https://example.com/imageB.jpg'],
      votesA: 10,
      votesB: 5,
      creatorId: 'test_user_1',
      createdAt: DateTime.now().subtract(Duration(hours: 1)),
      isActive: true,
      voteStatus: VoteStatus.active,
    );
    
    _posts[testPost.id] = testPost;
  }
  
  @override
  Future<IVersusContentModel?> getPost(String postId) async {
    await Future.delayed(Duration(milliseconds: 100)); // Simulate network delay
    return _posts[postId];
  }
  
  @override
  Future<bool> postExists(String postId) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _posts.containsKey(postId);
  }
  
  @override
  Future<String?> getPostCreatorId(String postId) async {
    await Future.delayed(Duration(milliseconds: 50));
    return _posts[postId]?.creatorId;
  }
  
  @override
  Future<List<IVersusContentModel>> getUserPosts({
    required String userId,
    int limit = 50,
    bool includeInactive = false,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    return _posts.values
        .where((post) => 
            post.creatorId == userId && 
            (includeInactive || post.isActive))
        .take(limit)
        .toList();
  }
  
  @override
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> contentData,
    required Map<String, dynamic> targetAudience,
  }) async {
    await Future.delayed(Duration(milliseconds: 300));
    
    final postId = 'mock_post_${DateTime.now().millisecondsSinceEpoch}';
    final post = MockVersusContentModel(
      id: postId,
      title: contentData['title'] ?? 'Mock Post',
      content: contentData['content'] ?? 'Mock content',
      optionAText: contentData['optionAText'] ?? 'Option A',
      optionBText: contentData['optionBText'] ?? 'Option B',
      optionAImageUrls: List<String>.from(contentData['optionAImageUrls'] ?? []),
      optionBImageUrls: List<String>.from(contentData['optionBImageUrls'] ?? []),
      votesA: 0,
      votesB: 0,
      creatorId: contentData['creatorId'] ?? 'unknown',
      createdAt: DateTime.now(),
      isActive: true,
      voteStatus: VoteStatus.active,
    );
    
    _posts[postId] = post;
    return postId;
  }
  
  @override
  Future<void> updatePostNotificationStatus({
    required String postId,
    required bool notificationsSent,
    DateTime? notificationsSentAt,
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    // In mock implementation, we just simulate the update
    print('Mock: Updated notification status for post $postId');
  }
  
  @override
  Future<void> updatePostVotes({
    required String postId,
    required int votesA,
    required int votesB,
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    final post = _posts[postId];
    if (post is MockVersusContentModel) {
      _posts[postId] = post.copyWith(votesA: votesA, votesB: votesB);
    }
  }
  
  @override
  Future<void> updatePostStatus({
    required String postId,
    VoteStatus? voteStatus,
    bool? isActive,
    Map<String, dynamic>? additionalData,
  }) async {
    await Future.delayed(Duration(milliseconds: 100));
    final post = _posts[postId];
    if (post is MockVersusContentModel) {
      _posts[postId] = post.copyWith(
        voteStatus: voteStatus ?? post.voteStatus,
        isActive: isActive ?? post.isActive,
      );
    }
  }
  
  @override
  Future<List<PostTargetAudienceStats>> getUserPostsWithTargetAudience({
    required String userId,
    int limit = 100,
  }) async {
    await Future.delayed(Duration(milliseconds: 200));
    
    final userPosts = await getUserPosts(userId: userId, limit: limit);
    return userPosts.map((post) => PostTargetAudienceStats(
      postId: post.id,
      postTitle: post.title,
      targetAudience: {'mode': 'public', 'filters': []},
      notificationsSent: post.votesA + post.votesB + 10,
      votesReceived: post.votesA + post.votesB,
      createdAt: post.createdAt,
      notificationsSentAt: post.createdAt.add(Duration(minutes: 5)),
    )).toList();
  }
  
  @override
  Stream<IVersusContentModel> watchPost(String postId) {
    // Simple implementation: return current post and close stream
    return Stream.fromFuture(getPost(postId)).where((post) => post != null).cast<IVersusContentModel>();
  }
  
  @override
  Stream<List<IVersusContentModel>> watchUserPosts({
    required String userId,
    int limit = 20,
  }) {
    // Simple implementation: return current posts and close stream
    return Stream.fromFuture(getUserPosts(userId: userId, limit: limit));
  }
}

/// Mock implementation of IVersusContentModel for testing
class MockVersusContentModel implements IVersusContentModel {
  @override
  final String id;
  
  @override
  final String title;
  
  @override
  final String content;
  
  final String optionAText;
  
  final String optionBText;
  
  @override
  final List<String> optionAImageUrls;
  
  @override
  final List<String> optionBImageUrls;
  
  @override
  final int votesA;
  
  @override
  final int votesB;
  
  @override
  final String creatorId;
  
  @override
  final DateTime createdAt;
  
  @override
  final bool isActive;
  
  @override
  final VoteStatus voteStatus;
  
  const MockVersusContentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.optionAText,
    required this.optionBText,
    required this.optionAImageUrls,
    required this.optionBImageUrls,
    required this.votesA,
    required this.votesB,
    required this.creatorId,
    required this.createdAt,
    required this.isActive,
    required this.voteStatus,
  });
  
  MockVersusContentModel copyWith({
    String? id,
    String? title,
    String? content,
    String? optionAText,
    String? optionBText,
    List<String>? optionAImageUrls,
    List<String>? optionBImageUrls,
    int? votesA,
    int? votesB,
    String? creatorId,
    DateTime? createdAt,
    bool? isActive,
    VoteStatus? voteStatus,
  }) {
    return MockVersusContentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      optionAText: optionAText ?? this.optionAText,
      optionBText: optionBText ?? this.optionBText,
      optionAImageUrls: optionAImageUrls ?? this.optionAImageUrls,
      optionBImageUrls: optionBImageUrls ?? this.optionBImageUrls,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      creatorId: creatorId ?? this.creatorId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      voteStatus: voteStatus ?? this.voteStatus,
    );
  }
  
  // Additional required fields from IContentModel
  String? get description => content;
  
  String get authorId => creatorId;
  
  // Additional required fields from IVersusContentModel
  @override
  String get optionATitle => optionAText;
  
  @override
  String get optionBTitle => optionBText;
  
  @override
  Map<String, dynamic>? get targetAudience => null;
  
  // ContentType would come from IContentModel import
  ContentType get contentType => ContentType.post;
  
  @override
  bool get isPublic => true;
  
  @override
  Map<String, dynamic> get metadata => {};
  
  @override
  String? get layoutType => 'horizontal';
  
  List<double>? get aspectRatiosA => null;
  
  List<double>? get aspectRatiosB => null;
  
  @override
  DateTime? get voteStartTime => createdAt;
  
  @override
  DateTime? get voteEndTime => createdAt.add(Duration(minutes: 10));
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'optionAText': optionAText,
      'optionBText': optionBText,
      'optionAImageUrls': optionAImageUrls,
      'optionBImageUrls': optionBImageUrls,
      'votesA': votesA,
      'votesB': votesB,
      'creatorId': creatorId,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'voteStatus': voteStatus.toString(),
    };
  }
  
  @override
  String toString() {
    return 'MockVersusContentModel(id: $id, title: $title, votesA: $votesA, votesB: $votesB)';
  }
}

// ContentType is already defined in IContentModel