import '/backend/backend.dart';
import '/posts/in_put_post_image/utils/debug_helper.dart';

/// 투표 상태 관리를 위한 중앙 서비스
class VoteStatusService {
  // 캐시를 위한 변수들
  static final Map<String, _CachedVoteStatus> _statusCache = {};
  static const Duration _cacheDuration = Duration(seconds: 1);
  
  /// 사용자의 개인 투표 상태 계산
  /// @deprecated VoteStateCoordinator로 대체됨
  /// TODO: Phase 5에서 제거 예정 (REFACTORING_PLAN.md 참조)
  static String getUserVoteStatus({
    required Map<String, dynamic>? userVotes,
    required String userId,
    required String? cardStatus,
    DateTime? voteEndTime,
  }) {
    // 캐시 키 생성
    final cacheKey = '$userId-$cardStatus-${userVotes?.keys.join(",")}';
    final now = DateTime.now();
    
    // 캐시된 값이 있고 유효한 경우 반환
    final cached = _statusCache[cacheKey];
    if (cached != null && now.difference(cached.timestamp) < _cacheDuration) {
      return cached.status;
    }
    
    // 디버그 모드에서만 로그 출력 (캐시 미스 시에만)
    DebugHelper.logVote('캐시 미스 - 새로 계산: userId=$userId, cardStatus=$cardStatus');
    
    // 1. 전체 투표 상태 먼저 확인
    String status;
    
    if (cardStatus == 'completed') {
      status = 'completed';
    } else if (cardStatus == 'voting_request') {
      status = 'voting_request';
    } else if (cardStatus == 'expired') {
      status = 'expired';
    } else if (cardStatus == 'in_progress') {
      // 2. 진행중 상태에서 개인 투표 여부 확인
      final hasVoted = userVotes?.containsKey(userId) ?? false;
      status = hasVoted ? 'in_progress' : 'pending';
    } else if (voteEndTime != null && DateTime.now().isAfter(voteEndTime)) {
      // 3. 시간 만료 확인
      status = 'not_participated';
    } else {
      status = 'pending';
    }
    
    // 캐시에 저장
    _statusCache[cacheKey] = _CachedVoteStatus(status: status, timestamp: now);
    
    // 주기적으로 오래된 캐시 정리
    if (_statusCache.length > 100) {
      _cleanupCache();
    }
    
    return status;
  }
  
  /// 오래된 캐시 항목 정리
  /// @deprecated getUserVoteStatus와 함께 제거 예정
  /// TODO: Phase 5에서 제거 예정 (REFACTORING_PLAN.md 참조)
  static void _cleanupCache() {
    final now = DateTime.now();
    _statusCache.removeWhere((key, value) => 
      now.difference(value.timestamp) > _cacheDuration * 2);
  }
  
  /// 투표 제출 (통합)
  static Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    try {
      DebugHelper.logVote('submitVote 시작: postId=$postId, choice=$choice', level: LogLevel.INFO);
      
      // 트랜잭션으로 모든 업데이트 처리
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // 1. Posts 업데이트
        final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
        final postDoc = await transaction.get(postRef);
        
        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }
        
        // 중복 투표 확인
        final postData = postDoc.data() as Map<String, dynamic>;
        
        final votedUsersA = List<String>.from(postData['votedUserIDsA'] ?? []);
        final votedUsersB = List<String>.from(postData['votedUserIDsB'] ?? []);
        
        if (votedUsersA.contains(userId) || votedUsersB.contains(userId)) {
          throw Exception('이미 투표하셨습니다');
        }
        
        // 투표 필드 업데이트
        final updates = <String, dynamic>{
          'votedUserIDs${choice}': FieldValue.arrayUnion([userId]),
          'votes_${choice.toLowerCase()}': FieldValue.increment(1),
          'total_votes': FieldValue.increment(1),
          'last_vote_at': FieldValue.serverTimestamp(),
        };
        
        transaction.update(postRef, updates);
        
        // 2. Messages 업데이트 (있는 경우)
        if (messageId != null && chatId != null) {
          final messageRef = FirebaseFirestore.instance
              .collection('chats').doc(chatId)
              .collection('messages').doc(messageId);
              
          final messageDoc = await transaction.get(messageRef);
          
          if (messageDoc.exists) {
            DebugHelper.logVote('메시지 user_votes 업데이트: messageId=$messageId, choice=$choice');
            
            transaction.update(messageRef, {
              'user_votes.$userId': {
                'option': choice,
                'voted_at': FieldValue.serverTimestamp(),
              },
              'last_vote_update': FieldValue.serverTimestamp(),
            });
          } else {
            DebugHelper.logVote('메시지 문서를 찾을 수 없음: messageId=$messageId', level: LogLevel.WARNING);
          }
        } else {
          DebugHelper.logVote('메시지 업데이트 스킵: messageId=$messageId, chatId=$chatId');
        }
      });
      
      // 3. AI 채팅 업데이트 (트랜잭션 외부)
      await _updateAIChatMessage(postId, userId, choice);
      
      DebugHelper.logVote('투표 제출 성공: postId=$postId, choice=$choice', level: LogLevel.INFO);
      
    } catch (e) {
      final errorMessage = e.toString().contains('이미 투표') 
          ? '이미 투표하셨습니다' 
          : e.toString().contains('찾을 수 없')
              ? '게시물을 찾을 수 없습니다'
              : '투표 처리 중 오류가 발생했습니다';
              
      DebugHelper.logVote('투표 제출 실패: $e', level: LogLevel.ERROR);
      
      // 에러 콜백 호출
      if (onError != null) {
        onError(errorMessage);
      }
      
      rethrow;
    }
  }
  
  /// AI 채팅 메시지 업데이트
  static Future<bool> _updateAIChatMessage(
    String postId,
    String userId,
    String choice,
  ) async {
    try {
      // 게시물 작성자 찾기
      final postDoc = await FirebaseFirestore.instance
          .collection('posts').doc(postId).get();
      
      if (!postDoc.exists) {
        DebugHelper.logVote('AI 채팅 업데이트 스킵: 게시물 없음');
        return false;
      }
      
      final postData = postDoc.data() as Map<String, dynamic>;
      final authorId = postData['user_id'] ?? postData['userId'] ?? postData['author_id'];
      if (authorId == null) {
        DebugHelper.logVote('AI 채팅 업데이트 스킵: 작성자 ID 없음');
        return false;
      }
      
      // AI 채팅 메시지 찾기
      final aiChatId = 'ai_assistant_$authorId';
      final messagesQuery = await FirebaseFirestore.instance
          .collection('chats').doc(aiChatId)
          .collection('messages')
          .where('vote_post_id', isEqualTo: postId)
          .where('message_type', isEqualTo: 'vote_request')
          .limit(1)
          .get();
      
      if (messagesQuery.docs.isEmpty) {
        DebugHelper.logVote('AI 채팅 업데이트 스킵: 메시지 없음');
        return false;
      }
      
      // user_votes 업데이트
      final messageDoc = messagesQuery.docs.first;
      await messageDoc.reference.update({
        'user_votes.$userId': {
          'option': choice,
          'voted_at': FieldValue.serverTimestamp(),
        },
        'last_vote_update': FieldValue.serverTimestamp(),
      });
      
      DebugHelper.logVote('AI 채팅 메시지 업데이트 성공');
      return true;
      
    } catch (e) {
      // 실패해도 메인 플로우는 계속
      DebugHelper.logVote('AI 채팅 업데이트 실패 (계속 진행): $e', level: LogLevel.WARNING);
      return false;
    }
  }
  
  /// 투표 상태 색상 가져오기
  static Color getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'voting_request':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      case 'not_participated':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
  
  /// 투표 상태 텍스트 가져오기
  static String getStatusText(String status, {bool hasUserVoted = false}) {
    switch (status) {
      case 'completed':
        return '완료';
      case 'voting_request':
        return '대기중';
      case 'expired':
        return '만료';
      case 'not_participated':
        return '미참여';
      case 'in_progress':
        // 진행중 상태에서 사용자가 투표했는지 확인
        if (hasUserVoted) {
          return '투표완료(진행중)';
        }
        return '진행중';
      default:
        return '대기중';
    }
  }
}

/// 캐시된 투표 상태를 저장하는 클래스
class _CachedVoteStatus {
  final String status;
  final DateTime timestamp;
  
  _CachedVoteStatus({required this.status, required this.timestamp});
}