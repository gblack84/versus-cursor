/**
 * 투표 타임아웃 확인 (매시간 실행)
 * 24시간 동안 목표 투표수에 도달하지 못한 게시물 처리
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { processVoteCompletion } = require("../../services/voteManagement");

exports.checkVoteTimeouts = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540, // 9분
    memory: '512MB'
  })
  .pubsub
  .schedule('every 60 minutes')
  .onRun(async (context) => {
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    const oneDayAgo = new admin.firestore.Timestamp(now.seconds - 24 * 60 * 60, now.nanoseconds);
    
    try {
      // 24시간 전에 생성되고 아직 투표가 진행 중인 게시물 찾기
      const expiredPostsSnapshot = await db.collection('posts')
        .where('isNotificationEnabled', '==', true)
        .where('time_posted', '<=', oneDayAgo)
        .where('isVoteCompleted', '==', false)
        .limit(50) // 한 번에 처리할 최대 개수
        .get();
      
      if (expiredPostsSnapshot.empty) {
        console.log('[타임아웃 검사] 만료된 투표 없음');
        return null;
      }
      
      console.log(`[타임아웃 검사] ${expiredPostsSnapshot.size}개의 만료된 투표 발견`);
      
      // 각 게시물에 대해 투표 종료 처리
      const results = await Promise.allSettled(
        expiredPostsSnapshot.docs.map(async (doc) => {
          const postId = doc.id;
          const postData = doc.data();
          
          const voteResults = {
            votesA: postData.votedUserIDsA?.length || 0,
            votesB: postData.votedUserIDsB?.length || 0,
            totalVotes: (postData.votedUserIDsA?.length || 0) + (postData.votedUserIDsB?.length || 0),
            requestedCount: postData.targetAudience?.count || 10,
            isTimeout: true // 타임아웃으로 인한 종료 표시
          };
          
          try {
            await processVoteCompletion(postId, voteResults);
            console.log(`[타임아웃 검사] Post ${postId} 타임아웃 처리 완료`);
          } catch (error) {
            console.error(`[타임아웃 검사] Post ${postId} 처리 실패:`, error);
            throw error;
          }
        })
      );
      
      // 결과 로그
      const succeeded = results.filter(r => r.status === 'fulfilled').length;
      const failed = results.filter(r => r.status === 'rejected').length;
      
      console.log(`[타임아웃 검사] 처리 완료 - 성공: ${succeeded}, 실패: ${failed}`);
      
      // 실패한 건이 있으면 다음 주기에 다시 시도
      if (failed > 0) {
        await db.collection('vote_timeout_errors').add({
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
          failed: failed,
          total: expiredPostsSnapshot.size
        });
      }
      
      return { succeeded, failed };
      
    } catch (error) {
      console.error('[타임아웃 검사] 오류 발생:', error);
      throw error;
    }
  });