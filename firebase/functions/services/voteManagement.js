/**
 * 투표 관리 서비스
 * 투표 완료 처리 및 상태 업데이트 관련 로직
 */

const admin = require("firebase-admin");

/**
 * 투표 완료 시 모든 참여자 상태 업데이트 및 결과 알림 생성
 * @param {string} postId - 게시물 ID
 * @param {Object} voteResults - 투표 결과 정보
 */
async function processVoteCompletion(postId, voteResults) {
  console.log(`[투표 완료 처리] ========== 투표 완료 처리 시작 ==========`);
  console.log(`[투표 완료 처리] 게시물 ID: ${postId}`);
  console.log(`[투표 완료 처리] 최종 결과: A=${voteResults.votesA}표, B=${voteResults.votesB}표`);
  
  const db = admin.firestore();
  const startTime = Date.now();
  
  try {
    // 1. 병렬로 데이터 조회
    const [notificationsSnapshot] = await Promise.all([
      // 알림 문서 조회
      db.collection('notifications')
        .where('source_id', '==', postId)
        .where('type', '==', 'voting_request')
        .get()
    ]);
    
    console.log(`[투표 완료 처리] 데이터 조회 완료 (${Date.now() - startTime}ms)`);
    console.log(`[투표 완료 처리] - 관련 알림: ${notificationsSnapshot.size}개`);
    
    // 2. 참여자 목록 수집
    const participantIds = new Set();
    notificationsSnapshot.forEach(doc => {
      const userId = doc.data().user_id;
      if (userId) participantIds.add(userId);
    });
    
    // 3. 각 참여자의 AI 채팅방에서 메시지 업데이트
    const aiAssistantId = 'ai_assistant';
    const updatePromises = [];
    
    for (const userId of participantIds) {
      // AI와의 1:1 채팅방 ID
      const chatId = [aiAssistantId, userId].sort().join('_');
      
      // 해당 채팅방의 투표 메시지 검색
      const messagesPromise = db.collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('vote_post_id', '==', postId)
        .where('message_type', 'in', ['vote_request', 'vote_created'])
        .get()
        .then(snapshot => {
          const updates = [];
          snapshot.forEach(doc => {
            updates.push(doc.ref.update({ vote_status: 'completed' }));
          });
          return Promise.all(updates);
        });
      
      updatePromises.push(messagesPromise);
    }
    
    // 모든 메시지 업데이트 실행
    await Promise.all(updatePromises);
    
    console.log(`[투표 완료 처리] ${participantIds.size}명의 AI 채팅방 메시지 업데이트 완료`);
    
    // 4. 배치 처리를 위한 작업 목록 생성
    const batchOperations = [];
    
    // 알림 상태 업데이트 작업
    notificationsSnapshot.forEach(doc => {
      batchOperations.push({
        type: 'update',
        ref: doc.ref,
        data: {
          status: 'completed',
          completedAt: admin.firestore.FieldValue.serverTimestamp()
        }
      });
    });
    
    // 결과 알림 생성 작업
    const resultNotificationData = {
      type: 'vote_result',
      sourceId: postId,
      sourceType: 'post',
      title: '투표 결과가 도착했습니다!',
      message: `"${voteResults.questionTitle}" 투표가 완료되었습니다. 결과를 확인해보세요!`,
      imageUrl: null,
      actionUrl: `/posts/${postId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      priority: 'high',
      content: JSON.stringify({
        postData: {
          postId,
          questionTitle: voteResults.questionTitle,
          optionA: voteResults.optionA,
          optionB: voteResults.optionB,
          votesA: voteResults.votesA,
          votesB: voteResults.votesB,
          percentA: voteResults.percentA,
          percentB: voteResults.percentB,
          winner: voteResults.winner,
          totalVotes: voteResults.totalVotes
        }
      })
    };
    
    // 각 참여자에게 결과 알림 생성
    for (const userId of participantIds) {
      const notificationRef = db.collection('notifications').doc();
      batchOperations.push({
        type: 'set',
        ref: notificationRef,
        data: { ...resultNotificationData, userId }
      });
    }
    
    // 생성자에게도 결과 알림
    if (voteResults.creatorId && !participantIds.has(voteResults.creatorId)) {
      const creatorNotificationRef = db.collection('notifications').doc();
      batchOperations.push({
        type: 'set',
        ref: creatorNotificationRef,
        data: {
          ...resultNotificationData,
          userId: voteResults.creatorId,
          title: '내 투표가 완료되었습니다!',
          message: `"${voteResults.questionTitle}" 투표가 완료되었습니다. 총 ${voteResults.totalVotes}명이 참여했습니다!`
        }
      });
    }
    
    // 5. 배치 처리 실행 (500개씩 나눠서 처리)
    const batchResults = await processBatch(
      batchOperations,
      (batch, operation) => {
        if (operation.type === 'update') {
          batch.update(operation.ref, operation.data);
        } else if (operation.type === 'set') {
          batch.set(operation.ref, operation.data);
        }
      },
      500 // Firestore 배치 제한
    );
    
    const totalTime = Date.now() - startTime;
    
    console.log(`[투표 완료 처리] ✅ 투표 완료 처리 성공 (총 ${totalTime}ms)`);
    console.log(`[투표 완료 처리] - 배치 처리 결과:`, batchResults);
    console.log(`[투표 완료 처리] - 총 작업 수: ${batchOperations.length}개`);
    
    // 성능이 느린 경우 경고
    if (totalTime > 5000) {
      console.warn(`[투표 완료 처리] ⚠️ 처리 시간이 5초를 초과했습니다: ${totalTime}ms`);
    }
    
  } catch (error) {
    console.error('[투표 완료 처리] ❌ 오류 발생:', error);
    throw error;
  }
}

/**
 * Firestore 배치 쓰기 프로세서 (간소화 버전)
 * @param {Array} items - 처리할 항목들
 * @param {Function} processor - 각 항목을 처리하는 함수
 * @param {number} batchSize - 배치 크기
 */
async function processBatch(items, processor, batchSize = 500) {
  const db = admin.firestore();
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = db.batch();
    const batchItems = items.slice(i, i + batchSize);
    
    for (const item of batchItems) {
      await processor(batch, item);
    }
    
    try {
      await batch.commit();
      results.push({
        success: true,
        processed: batchItems.length,
        startIndex: i
      });
    } catch (error) {
      console.error(`[배치 처리] 오류 발생 at index ${i}:`, error);
      results.push({
        success: false,
        processed: 0,
        startIndex: i,
        error: error.message
      });
    }
  }
  
  return results;
}

/**
 * 투표 증폭 알고리즘
 * 실제 투표 수를 목표 인원수로 증폭하여 표시
 * @param {Object} actualVotes - 실제 투표 수 {A: number, B: number}
 * @param {number} targetCount - 목표 인원수
 * @param {Object} expectedRatio - AI 예상 비율 {A: number, B: number}
 * @returns {Object} 증폭된 투표 수 {A: number, B: number}
 */
function calculateDisplayVotes(actualVotes, targetCount, expectedRatio = { A: 0.5, B: 0.5 }) {
  const actualTotal = (actualVotes.A || 0) + (actualVotes.B || 0);
  
  // 투표가 없는 경우: AI 예상 비율 사용
  if (actualTotal === 0) {
    return addRandomVariation({
      A: Math.round(targetCount * expectedRatio.A),
      B: Math.round(targetCount * expectedRatio.B)
    }, targetCount);
  }
  
  // 개선된 가중치 공식 - 더 부드러운 전환과 AI 영향력 유지
  let weight;
  
  if (actualTotal <= 5) {
    // 1-5명: 20-50% 실제 비율 (AI가 50-80% 영향)
    weight = 0.2 + (actualTotal * 0.06);
  } else if (actualTotal <= 20) {
    // 6-20명: 50-80% 실제 비율 (AI가 20-50% 영향)
    weight = 0.5 + ((actualTotal - 5) * 0.02);
  } else if (actualTotal <= 50) {
    // 21-50명: 80-90% 실제 비율 (AI가 10-20% 영향)
    weight = 0.8 + ((actualTotal - 20) * 0.003);
  } else {
    // 50명 이상: 90% 실제 비율 (AI가 10% 영향)
    weight = 0.9;
  }
  
  console.log(`[투표 증폭] 실제 투표: ${actualTotal}명, 가중치: ${weight} (실제 ${Math.round(weight * 100)}%, AI ${Math.round((1 - weight) * 100)}%)`);
  
  // 실제 비율 계산
  const actualRatioA = actualVotes.A / actualTotal;
  const actualRatioB = actualVotes.B / actualTotal;
  
  // AI 예상과 실제 투표 조합
  const finalRatioA = (actualRatioA * weight) + (expectedRatio.A * (1 - weight));
  const finalRatioB = (actualRatioB * weight) + (expectedRatio.B * (1 - weight));
  
  console.log(`[투표 증폭] 최종 비율 - A: ${Math.round(finalRatioA * 100)}%, B: ${Math.round(finalRatioB * 100)}%`);
  
  return addRandomVariation({
    A: Math.round(targetCount * finalRatioA),
    B: Math.round(targetCount * finalRatioB)
  }, targetCount);
}

/**
 * 랜덤 변동 추가 함수
 * @param {Object} votes - 투표 수 {A: number, B: number}
 * @param {number} targetCount - 목표 합계
 * @param {number} maxVariation - 최대 변동 비율 (기본 10%)
 * @returns {Object} 변동이 적용된 투표 수
 */
function addRandomVariation(votes, targetCount, maxVariation = 0.1) {
  const variation = (Math.random() - 0.5) * maxVariation * targetCount;
  
  let variedA = Math.max(1, Math.round(votes.A + variation));
  let variedB = Math.max(1, Math.round(votes.B - variation));
  
  // 합계가 targetCount와 일치하도록 조정
  const variedTotal = variedA + variedB;
  if (variedTotal !== targetCount) {
    const diff = targetCount - variedTotal;
    if (variedA > variedB) {
      variedA += diff;
    } else {
      variedB += diff;
    }
  }
  
  return { A: variedA, B: variedB };
}

/**
 * 진행 중인 투표의 표시용 숫자 계산
 * 시간 경과에 따라 점진적으로 증가
 * @param {Object} actualVotes - 실제 투표 수
 * @param {number} targetCount - 목표 인원수
 * @param {number} elapsedMinutes - 경과 시간 (분)
 * @param {Object} expectedRatio - AI 예상 비율
 * @returns {Object} 현재 표시할 투표 수
 */
function calculateProgressiveDisplayVotes(actualVotes, targetCount, elapsedMinutes, expectedRatio = { A: 0.5, B: 0.5 }) {
  // 10분 기준으로 진행률 계산 (0~1)
  const progressRate = Math.min(elapsedMinutes / 10, 1);
  
  // 랜덤 요소 추가 (90%~110%)
  const randomFactor = 0.9 + Math.random() * 0.2;
  
  // 현재 시점의 예상 참여자 수
  const expectedVoters = Math.floor(targetCount * progressRate * randomFactor);
  
  // 증폭 계산 (예상 비율 전달)
  return calculateDisplayVotes(actualVotes, expectedVoters, expectedRatio);
}


module.exports = {
  processVoteCompletion,
  processBatch,
  calculateDisplayVotes,
  calculateProgressiveDisplayVotes
};