import '../../repositories/i_post_repository.dart';

/// VoteUseCase - 투표 관련 비즈니스 로직
/// 
/// 투표 기능의 모든 비즈니스 룰을 캡슐화
class VoteUseCase {
  const VoteUseCase(this._postRepository);
  
  final IPostRepository _postRepository;
  
  /// 투표 실행
  Future<void> vote({
    required String postId,
    required String userId,
    required String option,
  }) async {
    // 중복 투표 검증
    final existingVote = await _postRepository.getUserVote(postId, userId);
    if (existingVote != null) {
      throw StateError('이미 투표한 게시물입니다');
    }
    
    await _postRepository.vote(postId, userId, option);
  }
  
  /// 투표 결과 조회
  Future<Map<String, int>> getVoteResults(String postId) async {
    return await _postRepository.getVoteResults(postId);
  }
  
  /// 투표 결과 실시간 감시
  Stream<Map<String, int>> watchVoteResults(String postId) {
    return _postRepository.watchVoteResults(postId);
  }
}