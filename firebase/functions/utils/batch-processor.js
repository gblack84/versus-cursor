/**
 * 배치 처리 유틸리티
 * 대규모 작업을 효율적으로 처리하기 위한 헬퍼 함수들
 */

const admin = require('firebase-admin');

/**
 * Firestore 배치 쓰기 프로세서
 * @param {Array} items - 처리할 항목들
 * @param {Function} processor - 각 항목을 처리하는 함수
 * @param {number} batchSize - 배치 크기 (기본 500)
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
      console.error(`Batch processing error at index ${i}:`, error);
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
 * 병렬 배치 프로세서
 * @param {Array} items - 처리할 항목들
 * @param {Function} processor - 각 항목을 처리하는 비동기 함수
 * @param {number} concurrency - 동시 실행 수 (기본 10)
 */
async function processParallelBatch(items, processor, concurrency = 10) {
  const results = [];
  
  for (let i = 0; i < items.length; i += concurrency) {
    const batch = items.slice(i, i + concurrency);
    const batchResults = await Promise.allSettled(
      batch.map(item => processor(item))
    );
    
    results.push(...batchResults.map((result, index) => ({
      item: batch[index],
      ...result
    })));
  }
  
  return results;
}

/**
 * 스로틀링된 배치 프로세서
 * @param {Array} items - 처리할 항목들
 * @param {Function} processor - 각 항목을 처리하는 함수
 * @param {number} rateLimit - 초당 처리 수
 * @param {number} batchSize - 배치 크기
 */
async function processThrottledBatch(items, processor, rateLimit = 100, batchSize = 10) {
  const delayMs = 1000 / (rateLimit / batchSize);
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const startTime = Date.now();
    const batch = items.slice(i, i + batchSize);
    
    // 배치 처리
    const batchResults = await Promise.allSettled(
      batch.map(item => processor(item))
    );
    
    results.push(...batchResults);
    
    // 스로틀링 적용
    const elapsed = Date.now() - startTime;
    if (elapsed < delayMs) {
      await new Promise(resolve => setTimeout(resolve, delayMs - elapsed));
    }
  }
  
  return results;
}

/**
 * 재시도 가능한 배치 프로세서
 * @param {Array} items - 처리할 항목들
 * @param {Function} processor - 각 항목을 처리하는 함수
 * @param {Object} options - 옵션
 */
async function processWithRetry(items, processor, options = {}) {
  const {
    maxRetries = 3,
    retryDelay = 1000,
    exponentialBackoff = true,
    batchSize = 100
  } = options;
  
  const results = [];
  const failedItems = [];
  
  // 초기 처리
  const initialResults = await processParallelBatch(items, processor, batchSize);
  
  // 실패한 항목 수집
  initialResults.forEach((result, index) => {
    if (result.status === 'fulfilled') {
      results.push(result);
    } else {
      failedItems.push({
        item: items[index],
        attempts: 1,
        lastError: result.reason
      });
    }
  });
  
  // 재시도 로직
  for (let attempt = 1; attempt <= maxRetries && failedItems.length > 0; attempt++) {
    const delay = exponentialBackoff ? retryDelay * Math.pow(2, attempt - 1) : retryDelay;
    await new Promise(resolve => setTimeout(resolve, delay));
    
    const retryItems = failedItems.splice(0);
    const retryResults = await processParallelBatch(
      retryItems.map(f => f.item),
      processor,
      batchSize
    );
    
    retryResults.forEach((result, index) => {
      if (result.status === 'fulfilled') {
        results.push(result);
      } else {
        retryItems[index].attempts++;
        retryItems[index].lastError = result.reason;
        if (retryItems[index].attempts <= maxRetries) {
          failedItems.push(retryItems[index]);
        }
      }
    });
  }
  
  return {
    successful: results.filter(r => r.status === 'fulfilled').length,
    failed: failedItems.length,
    results,
    failedItems
  };
}

/**
 * 투표 결과 배치 업데이트
 * @param {string} postId - 게시물 ID
 * @param {Array} participants - 참여자 목록
 */
async function batchUpdateVoteResults(postId, participants) {
  const db = admin.firestore();
  const batch = db.batch();
  
  // 메시지 쿼리
  const messagesQuery = await db
    .collection('chats_record')
    .doc('vote_tracking_global')
    .collection('messages')
    .where('vote_post_id', '==', postId)
    .where('message_type', '==', 'vote_request')
    .get();
  
  // 배치 업데이트
  messagesQuery.docs.forEach(doc => {
    batch.update(doc.ref, {
      vote_user_status: 'result_arrived',
      vote_global_status: 'completed',
      updated_at: admin.firestore.FieldValue.serverTimestamp()
    });
  });
  
  // 알림 생성
  participants.forEach(userId => {
    const notificationRef = db.collection('notifications_record').doc();
    batch.set(notificationRef, {
      user_id: userId,
      type: 'vote_result',
      source_id: postId,
      title: '투표 결과가 도착했습니다!',
      body: '참여하신 투표의 결과를 확인해보세요.',
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      read: false
    });
  });
  
  await batch.commit();
}

module.exports = {
  processBatch,
  processParallelBatch,
  processThrottledBatch,
  processWithRetry,
  batchUpdateVoteResults
};