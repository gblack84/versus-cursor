/**
 * 실시간 업데이트 스로틀링 유틸리티
 * 대량의 실시간 업데이트를 효율적으로 관리
 */

const admin = require('firebase-admin');

class RealtimeThrottle {
  constructor(options = {}) {
    this.updateQueue = new Map(); // postId -> updates
    this.timers = new Map(); // postId -> timer
    this.batchSize = options.batchSize || 50;
    this.throttleMs = options.throttleMs || 500; // 0.5초
    this.maxQueueSize = options.maxQueueSize || 1000;
  }
  
  /**
   * 업데이트 큐에 추가
   * @param {string} postId - 게시물 ID
   * @param {Object} update - 업데이트 정보
   */
  queueUpdate(postId, update) {
    if (!this.updateQueue.has(postId)) {
      this.updateQueue.set(postId, []);
    }
    
    const queue = this.updateQueue.get(postId);
    
    // 큐 크기 제한
    if (queue.length >= this.maxQueueSize) {
      console.warn(`Queue size limit reached for post ${postId}`);
      this.flushUpdates(postId);
    }
    
    queue.push(update);
    
    // 스로틀 타이머 설정
    if (!this.timers.has(postId)) {
      this.timers.set(postId, setTimeout(() => {
        this.flushUpdates(postId);
      }, this.throttleMs));
    }
  }
  
  /**
   * 큐의 업데이트 즉시 처리
   * @param {string} postId - 게시물 ID
   */
  async flushUpdates(postId) {
    const updates = this.updateQueue.get(postId);
    if (!updates || updates.length === 0) return;
    
    // 큐 초기화
    this.updateQueue.delete(postId);
    this.timers.delete(postId);
    
    // 배치 처리
    try {
      await this.processBatchUpdates(postId, updates);
    } catch (error) {
      console.error(`Error flushing updates for post ${postId}:`, error);
    }
  }
  
  /**
   * 배치 업데이트 처리
   * @param {string} postId - 게시물 ID
   * @param {Array} updates - 업데이트 목록
   */
  async processBatchUpdates(postId, updates) {
    const db = admin.firestore();
    const batch = db.batch();
    
    // 업데이트 타입별로 그룹화
    const grouped = this.groupUpdatesByType(updates);
    
    // 투표 카운트 업데이트
    if (grouped.votes.length > 0) {
      const voteCountA = grouped.votes.filter(v => v.option === 'A').length;
      const voteCountB = grouped.votes.filter(v => v.option === 'B').length;
      const voters = [...new Set(grouped.votes.map(v => v.userId))];
      
      const postRef = db.collection('posts').doc(postId);
      batch.update(postRef, {
        vote_count_a: admin.firestore.FieldValue.increment(voteCountA),
        vote_count_b: admin.firestore.FieldValue.increment(voteCountB),
        voters: admin.firestore.FieldValue.arrayUnion(...voters),
        last_vote_at: admin.firestore.FieldValue.serverTimestamp()
      });
    }
    
    // 메시지 상태 업데이트
    if (grouped.messageUpdates.length > 0) {
      // 중복 제거 및 최신 상태만 유지
      const latestUpdates = new Map();
      grouped.messageUpdates.forEach(update => {
        const key = `${update.messageId}-${update.userId}`;
        latestUpdates.set(key, update);
      });
      
      // 메시지별로 그룹화
      const messageGroups = new Map();
      latestUpdates.forEach(update => {
        if (!messageGroups.has(update.messageId)) {
          messageGroups.set(update.messageId, []);
        }
        messageGroups.get(update.messageId).push(update);
      });
      
      // 각 사용자의 AI 채팅방에서 메시지 업데이트
      for (const [messageId, messageUpdates] of messageGroups) {
        const aiAssistantId = 'ai_assistant';
        
        // 각 사용자별로 처리
        for (const update of messageUpdates) {
          // AI와의 1:1 채팅방 ID
          const chatId = [aiAssistantId, update.userId].sort().join('_');
          
          // 해당 채팅방의 메시지 찾기
          const messageQuery = await db
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('vote_post_id', '==', postId)
            .where('message_type', 'in', ['vote_request', 'vote_created'])
            .limit(1)
            .get();
          
          if (!messageQuery.empty) {
            const messageDoc = messageQuery.docs[0];
            batch.update(messageDoc.ref, {
              vote_status: update.status,
              voted_option: update.votedOption,
              updated_at: admin.firestore.FieldValue.serverTimestamp()
            });
          }
        }
      }
    }
    
    // 진행 상황 메시지는 AI 채팅방에 생성하지 않음 (필요시 추가 가능)
    
    await batch.commit();
    console.log(`Processed ${updates.length} updates for post ${postId}`);
  }
  
  /**
   * 업데이트를 타입별로 그룹화
   * @param {Array} updates - 업데이트 목록
   */
  groupUpdatesByType(updates) {
    const grouped = {
      votes: [],
      messageUpdates: [],
      progressUpdates: []
    };
    
    updates.forEach(update => {
      switch (update.type) {
        case 'vote':
          grouped.votes.push(update);
          break;
        case 'message_status':
          grouped.messageUpdates.push(update);
          break;
        case 'progress':
          grouped.progressUpdates.push(update);
          break;
      }
    });
    
    return grouped;
  }
  
  /**
   * 모든 큐 비우기
   */
  async flushAll() {
    const postIds = Array.from(this.updateQueue.keys());
    await Promise.all(postIds.map(postId => this.flushUpdates(postId)));
  }
  
  /**
   * 정리
   */
  cleanup() {
    // 모든 타이머 정리
    this.timers.forEach(timer => clearTimeout(timer));
    this.timers.clear();
    this.updateQueue.clear();
  }
}

// 싱글톤 인스턴스
let throttleInstance = null;

/**
 * RealtimeThrottle 인스턴스 가져오기
 * @param {Object} options - 옵션
 */
function getThrottle(options) {
  if (!throttleInstance) {
    throttleInstance = new RealtimeThrottle(options);
  }
  return throttleInstance;
}

/**
 * 투표 업데이트 큐에 추가
 * @param {string} postId - 게시물 ID
 * @param {string} userId - 사용자 ID
 * @param {string} option - 투표 옵션 (A/B)
 */
function queueVoteUpdate(postId, userId, option) {
  const throttle = getThrottle();
  throttle.queueUpdate(postId, {
    type: 'vote',
    userId,
    option,
    timestamp: Date.now()
  });
}

/**
 * 메시지 상태 업데이트 큐에 추가
 * @param {string} postId - 게시물 ID
 * @param {string} messageId - 메시지 ID
 * @param {string} userId - 사용자 ID
 * @param {string} status - 상태
 * @param {string} votedOption - 투표한 옵션
 */
function queueMessageStatusUpdate(postId, messageId, userId, status, votedOption) {
  const throttle = getThrottle();
  throttle.queueUpdate(postId, {
    type: 'message_status',
    messageId,
    userId,
    status,
    votedOption,
    timestamp: Date.now()
  });
}

/**
 * 진행 상황 업데이트 큐에 추가
 * @param {string} postId - 게시물 ID
 * @param {string} content - 진행 상황 내용
 */
function queueProgressUpdate(postId, content) {
  const throttle = getThrottle();
  throttle.queueUpdate(postId, {
    type: 'progress',
    content,
    timestamp: Date.now()
  });
}

module.exports = {
  RealtimeThrottle,
  getThrottle,
  queueVoteUpdate,
  queueMessageStatusUpdate,
  queueProgressUpdate
};