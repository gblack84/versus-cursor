import '../i_post_datasource.dart';
import '/features/posts/domain/models/posts_model.dart';

/// Posts feature에 대한 Mock DataSource 구현체
/// 
/// 실제 구현체는 Posts feature에서 제공되어야 하며,
/// 이 Mock은 테스트 및 개발 목적으로만 사용됩니다.
class MockPostDatasource implements IPostDatasource {
  // 테스트용 데이터 저장소
  final Map<String, Map<String, dynamic>> _posts = {};
  
  MockPostDatasource() {
    // 테스트 데이터 초기화
    _initTestData();
  }
  
  void _initTestData() {
    _posts['test_post_1'] = {
      'id': 'test_post_1',
      'title': 'Test Post 1',
      'content': 'This is a test post',
      'optionA': {
        'text': 'Option A',
        'imageUrls': ['https://example.com/imageA.jpg'],
      },
      'optionB': {
        'text': 'Option B',
        'imageUrls': ['https://example.com/imageB.jpg'],
      },
      'votesA': 10,
      'votesB': 8,
      'creatorId': 'test_user_1',
      'createdAt': DateTime.now().toIso8601String(),
      'notificationsSent': false,
    };
  }
  
  @override
  Future<PostsModel?> getPostModel(String postId) async {
    // TODO: Posts Feature 마이그레이션 후 실제 구현으로 교체
    print('[MockPostDatasource] getPostModel called for: $postId');
    return null;
  }
  
  @override
  Future<Map<String, dynamic>?> getPost(String postId) async {
    // 네트워크 지연 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 100));
    return _posts[postId];
  }
  
  @override
  Future<String> createPostWithTargetAudience({
    required Map<String, dynamic> postData,
    required Map<String, dynamic> targetAudience,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final postId = 'post_${DateTime.now().millisecondsSinceEpoch}';
    _posts[postId] = {
      'id': postId,
      ...postData,
      'targetAudience': targetAudience,
      'createdAt': DateTime.now().toIso8601String(),
      'notificationsSent': false,
    };
    
    return postId;
  }
  
  @override
  Future<void> updatePostNotificationStatus({
    required String postId,
    required bool notificationsSent,
    DateTime? notificationsSentAt,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_posts.containsKey(postId)) {
      _posts[postId]!['notificationsSent'] = notificationsSent;
      if (notificationsSentAt != null) {
        _posts[postId]!['notificationsSentAt'] = notificationsSentAt.toIso8601String();
      }
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getUserPosts(String userId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    return _posts.values
        .where((post) => post['creatorId'] == userId)
        .toList();
  }
  
  @override
  Future<bool> postExists(String postId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _posts.containsKey(postId);
  }
  
  @override
  Future<String?> getPostCreatorId(String postId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _posts[postId]?['creatorId'] as String?;
  }
  
  @override
  Future<void> updatePostVotes({
    required String postId,
    required int votesA,
    required int votesB,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (_posts.containsKey(postId)) {
      _posts[postId]!['votesA'] = votesA;
      _posts[postId]!['votesB'] = votesB;
      _posts[postId]!['lastVoteUpdate'] = DateTime.now().toIso8601String();
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getUserPostsWithTargetAudience({
    required String userId,
    int limit = 100,
  }) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    // Filter posts by user that have targetAudience
    final userPosts = _posts.values
        .where((post) => 
            post['creatorId'] == userId && 
            post['targetAudience'] != null)
        .take(limit)
        .toList();
    
    // Sort by creation time (descending)
    userPosts.sort((a, b) {
      final aTime = a['createdAt'] ?? '';
      final bTime = b['createdAt'] ?? '';
      return bTime.compareTo(aTime);
    });
    
    return userPosts;
  }
  
  // 테스트 헬퍼 메서드
  void addTestPost(String postId, Map<String, dynamic> postData) {
    _posts[postId] = postData;
  }
  
  void clearTestPosts() {
    _posts.clear();
    _initTestData();
  }
}