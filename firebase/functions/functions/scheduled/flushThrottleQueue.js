/**
 * 스로틀 큐 처리 (매분 실행)
 * 10분 타이머가 만료된 투표들을 자동 완료 처리
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { processVoteCompletion, calculateDisplayVotes } = require("../../services/voteManagement");
const { createVoteResultMessage } = require("../../services/aiChatService");
// throttleQueue\ub294 onPostVoteUpdate\uc5d0\uc11c export\ub418\uc5b4\uc57c \ud568\n// \uc784\uc2dc\ub85c \ud604\uc7ac\ub294 \uac01 \ud568\uc218\uac00 \ub3c5\ub9bd\uc801\uc73c\ub85c \uc791\ub3d9\ud558\ub3c4\ub85d \uc124\uc815\nconst throttleQueue = new Map();

exports.flushThrottleQueue = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540, // 9분
    memory: '512MB'
  })
  .pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    
    try {
      // 10분 타이머가 만료된 투표 찾기
      const expiredVotesSnapshot = await db.collection('posts')
        .where('voteStatus', '==', 'active')
        .where('voteEndTime', '<=', now)
        .where('voteCompleted', '==', false)
        .limit(30) // 한 번에 처리할 최대 개수
        .get();
      
      if (expiredVotesSnapshot.empty) {
        console.log('[10분 타이머] 만료된 투표 없음');
        return null;
      }
      
      console.log(`[10분 타이머] ${expiredVotesSnapshot.size}개의 만료된 투표 발견`);
      
      // 각 게시물에 대해 투표 종료 처리
      const results = await Promise.allSettled(
        expiredVotesSnapshot.docs.map(async (doc) => {
          const postId = doc.id;
          const postData = doc.data();
          
          // 실제 투표 수 계산
          const actualVotesA = postData.votedUserIDsA?.length || postData.votes_a || postData.vote_count_a || 0;
          const actualVotesB = postData.votedUserIDsB?.length || postData.votes_b || postData.vote_count_b || 0;
          const actualTotal = actualVotesA + actualVotesB;
          
          // 투표 증폭 계산 (목표: 100명)
          const targetCount = 100;
          const displayVotes = calculateDisplayVotes(
            { A: actualVotesA, B: actualVotesB },
            targetCount
          );
          
          // 표시용 비율 계산
          const percentA = Math.round((displayVotes.A / targetCount) * 100);
          const percentB = Math.round((displayVotes.B / targetCount) * 100);
          
          // 투표 결과 데이터
          const voteResults = {
            votesA: displayVotes.A,
            votesB: displayVotes.B,
            actualVotesA,
            actualVotesB,
            totalVotes: targetCount,
            actualTotalVotes: actualTotal,
            percentA,
            percentB,
            winner: displayVotes.A > displayVotes.B ? 'A' : displayVotes.B > displayVotes.A ? 'B' : 'draw',
            questionTitle: postData.question_title || postData.questionTitle,
            optionA: postData.option_a || postData.optionA?.title || 'A',
            optionB: postData.option_b || postData.optionB?.title || 'B',
            creatorId: postData.uid || postData.userid,
            creatorName: postData.authorName || postData.author_name || '알 수 없음',
            isTimeout: false, // 10분 타이머 정상 종료
            displayVotesA: displayVotes.A, // AI 채팅 메시지용
            displayVotesB: displayVotes.B  // AI 채팅 메시지용
          };
          
          try {
            // 1. 게시물 상태 업데이트
            await doc.ref.update({
              voteCompleted: true,
              voteCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
              voteStatus: 'completed',
              // 표시용 투표 수 (증폭된 수)
              display_votes_a: displayVotes.A,
              display_votes_b: displayVotes.B,
              display_percent_a: percentA,
              display_percent_b: percentB,
              // 실제 투표 수 (내부 데이터)
              actual_votes_a: actualVotesA,
              actual_votes_b: actualVotesB,
              actual_total_votes: actualTotal
            });
            
            // 2. 투표 완료 처리 (알림 생성 등)
            await processVoteCompletion(postId, voteResults);
            
            // 3. 모든 참여자에게 AI 채팅 결과 메시지 업데이트
            const notificationsSnapshot = await db.collection('notifications')
              .where('source_id', '==', postId)
              .where('type', '==', 'voting_request')
              .get();
            
            const participantIds = new Set();
            notificationsSnapshot.forEach(doc => {
              const userId = doc.data().user_id;
              if (userId) participantIds.add(userId);
            });
            
            // 작성자도 포함
            if (voteResults.creatorId) {
              participantIds.add(voteResults.creatorId);
            }
            
            // AI 채팅 결과 메시지 업데이트
            const messagePromises = Array.from(participantIds).map(userId => 
              createVoteResultMessage(userId, postId, voteResults)
            );
            await Promise.all(messagePromises);
            
            console.log(`[10분 타이머] Post ${postId} 완료 처리 성공`);
          } catch (error) {
            console.error(`[10분 타이머] Post ${postId} 처리 실패:`, error);
            throw error;
          }
        })
      );
      
      // 결과 로그
      const succeeded = results.filter(r => r.status === 'fulfilled').length;
      const failed = results.filter(r => r.status === 'rejected').length;
      
      console.log(`[10분 타이머] 처리 완료 - 성공: ${succeeded}, 실패: ${failed}`);
      
      return { succeeded, failed };
      
    } catch (error) {
      console.error('[10분 타이머] 오류 발생:', error);
      throw error;
    }
  });