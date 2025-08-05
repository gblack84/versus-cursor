/**
 * 투표 업데이트 감지 및 AI 채팅 메시지 업데이트
 * 트리거: posts 컬렉션 문서 업데이트
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { updateVoteParticipation } = require("../../services/aiChatService");
const { createLogger } = require("../../config/logger");

exports.onPostVoteUpdate = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 60,
    memory: '256MB'
  })
  .firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const logger = createLogger('onPostVoteUpdate');
    const before = change.before.data();
    const after = change.after.data();
    const postId = context.params.postId;
    
    // 투표 상태 확인 (10분 타이머 중인지)
    if (after.voteCompleted === true) {
      return null; // 이미 종료된 투표
    }
    
    // 투표 수 변화 확인
    const beforeVotesA = before.votedUserIDsA?.length || 0;
    const beforeVotesB = before.votedUserIDsB?.length || 0;
    const afterVotesA = after.votedUserIDsA?.length || 0;
    const afterVotesB = after.votedUserIDsB?.length || 0;
    
    // 새로 투표한 사용자 찾기
    let newVoters = [];
    let votedOption = null;
    
    // A 옵션에 새로운 투표자가 있는지 확인
    if (afterVotesA > beforeVotesA) {
      const beforeSet = new Set(before.votedUserIDsA || []);
      const afterSet = new Set(after.votedUserIDsA || []);
      newVoters = [...afterSet].filter(id => !beforeSet.has(id));
      votedOption = 'A';
    }
    // B 옵션에 새로운 투표자가 있는지 확인
    else if (afterVotesB > beforeVotesB) {
      const beforeSet = new Set(before.votedUserIDsB || []);
      const afterSet = new Set(after.votedUserIDsB || []);
      newVoters = [...afterSet].filter(id => !beforeSet.has(id));
      votedOption = 'B';
    }
    
    if (newVoters.length === 0) {
      return null; // 새로운 투표자 없음
    }
    
    logger.info(`Post ${postId}: ${newVoters.length}명이 ${votedOption}에 투표`);
    
    // 각 새로운 투표자의 AI 채팅 메시지 업데이트
    const updatePromises = newVoters.map(async (userId) => {
      try {
        await updateVoteParticipation(userId, postId, votedOption);
        logger.debug(`${logger.maskSensitive(userId)}의 AI 채팅 메시지 업데이트 완료`);
      } catch (error) {
        logger.error(`${logger.maskSensitive(userId)} 메시지 업데이트 실패`, error);
      }
    });
    
    await Promise.all(updatePromises);
    
    // 현재 투표 수 로그
    const currentVoteCount = afterVotesA + afterVotesB;
    logger.info(`Post ${postId} 현재 투표 수: A=${afterVotesA}, B=${afterVotesB}, 총=${currentVoteCount}`);
    
    return null;
  });

// 10분 타이머 시스템으로 인해 24시간 스로틀 큐는 더 이상 필요하지 않음
// 모든 투표는 10분 후 자동으로 종료되며 flushThrottleQueue에서 처리됨