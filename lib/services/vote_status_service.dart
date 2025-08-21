import '/backend/backend.dart';
import '/posts/in_put_post_image/utils/debug_helper.dart';

/// 투표 상태 관리를 위한 중앙 서비스
class VoteStatusService {
  
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
        
        // 1.5 votes 서브컬렉션에 투표 문서 생성
        final voteRef = postRef.collection('votes').doc();
        transaction.set(voteRef, {
          'user': FirebaseFirestore.instance.doc('users/$userId'),
          'option': choice,
          'created_at': FieldValue.serverTimestamp(),
          'from_chat': messageId != null && chatId != null,
        });
        
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
          .where('votePostId', isEqualTo: postId)
          .where('messageType', isEqualTo: 'voteRequest')
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
}