/**
 * 성능 최적화 테스트
 * 배치 처리 및 스로틀링 기능 검증
 */

const admin = require('firebase-admin');
const { describe, it, before, after } = require('mocha');
const { expect } = require('chai');

// 최적화 유틸리티 import
const { 
  processBatch, 
  processParallelBatch, 
  processThrottledBatch,
  processWithRetry 
} = require('../utils/batch-processor');

const { 
  RealtimeThrottle, 
  queueVoteUpdate, 
  queueProgressUpdate 
} = require('../utils/realtime-throttle');

// 테스트 환경 설정
const projectId = 'versus-space-1lwwiw';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';

// Admin SDK 초기화
if (!admin.apps.length) {
  admin.initializeApp({ projectId });
}

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

describe('성능 최적화 테스트', () => {
  
  describe('배치 처리 유틸리티', () => {
    
    it('processBatch: 500개씩 배치 처리', async function() {
      this.timeout(30000);
      
      console.log('\n=== processBatch 테스트 시작 ===');
      
      // 1500개의 작업 생성
      const operations = [];
      for (let i = 0; i < 1500; i++) {
        operations.push({
          id: `test-${i}`,
          data: { index: i, timestamp: Date.now() }
        });
      }
      
      const startTime = Date.now();
      
      // 배치 처리 실행
      const results = await processBatch(
        operations,
        async (batch, op) => {
          const ref = db.collection('test_batch').doc(op.id);
          batch.set(ref, op.data);
        },
        500 // 배치 크기
      );
      
      const totalTime = Date.now() - startTime;
      
      console.log(`✅ 1500개 작업을 ${results.length}개 배치로 처리`);
      console.log(`총 소요 시간: ${totalTime}ms`);
      console.log(`평균 배치당 시간: ${(totalTime / results.length).toFixed(2)}ms`);
      
      expect(results.length).to.equal(3); // 1500 / 500 = 3 배치
      expect(results.every(r => r.success)).to.be.true;
      
      // 정리
      const cleanupBatch = db.batch();
      for (const op of operations) {
        cleanupBatch.delete(db.collection('test_batch').doc(op.id));
      }
      await cleanupBatch.commit();
    });
    
    it('processParallelBatch: 병렬 처리 성능', async function() {
      this.timeout(20000);
      
      console.log('\n=== processParallelBatch 테스트 시작 ===');
      
      // 100개의 시뮬레이션 작업
      const tasks = [];
      for (let i = 0; i < 100; i++) {
        tasks.push({ id: i, delay: Math.random() * 100 }); // 0-100ms 지연
      }
      
      // 순차 처리 시간 측정
      const sequentialStart = Date.now();
      for (const task of tasks) {
        await new Promise(resolve => setTimeout(resolve, task.delay));
      }
      const sequentialTime = Date.now() - sequentialStart;
      
      // 병렬 처리 시간 측정
      const parallelStart = Date.now();
      const results = await processParallelBatch(
        tasks,
        async (task) => {
          await new Promise(resolve => setTimeout(resolve, task.delay));
          return { id: task.id, processed: true };
        },
        10 // 동시 실행 수
      );
      const parallelTime = Date.now() - parallelStart;
      
      console.log(`순차 처리 시간: ${sequentialTime}ms`);
      console.log(`병렬 처리 시간: ${parallelTime}ms`);
      console.log(`성능 향상: ${((sequentialTime / parallelTime) * 100 - 100).toFixed(1)}%`);
      
      expect(results.length).to.equal(100);
      expect(parallelTime).to.be.lessThan(sequentialTime);
    });
    
    it('processThrottledBatch: 속도 제한 처리', async function() {
      this.timeout(10000);
      
      console.log('\n=== processThrottledBatch 테스트 시작 ===');
      
      // 50개의 API 호출 시뮬레이션
      const apiCalls = Array.from({ length: 50 }, (_, i) => ({ id: i }));
      
      const startTime = Date.now();
      let callCount = 0;
      
      const results = await processThrottledBatch(
        apiCalls,
        async (call) => {
          callCount++;
          return { id: call.id, timestamp: Date.now() };
        },
        20, // 초당 20개 제한
        5   // 배치 크기 5
      );
      
      const totalTime = Date.now() - startTime;
      const actualRate = callCount / (totalTime / 1000);
      
      console.log(`총 처리 시간: ${totalTime}ms`);
      console.log(`실제 처리 속도: ${actualRate.toFixed(1)}개/초`);
      console.log(`목표 속도: 20개/초`);
      
      expect(results.length).to.equal(50);
      expect(actualRate).to.be.lessThanOrEqual(22); // 약간의 오차 허용
    });
    
    it('processWithRetry: 재시도 로직', async function() {
      this.timeout(15000);
      
      console.log('\n=== processWithRetry 테스트 시작 ===');
      
      let attemptCount = 0;
      const failureRate = 0.3; // 30% 실패율
      
      // 50개의 불안정한 작업
      const unreliableTasks = Array.from({ length: 50 }, (_, i) => ({ id: i }));
      
      const results = await processWithRetry(
        unreliableTasks,
        async (task) => {
          attemptCount++;
          // 30% 확률로 실패
          if (Math.random() < failureRate && attemptCount < 100) {
            throw new Error(`Task ${task.id} failed`);
          }
          return { id: task.id, success: true };
        },
        {
          maxRetries: 3,
          retryDelay: 100,
          exponentialBackoff: true,
          batchSize: 10
        }
      );
      
      console.log(`총 시도 횟수: ${attemptCount}`);
      console.log(`성공: ${results.successful}개`);
      console.log(`실패: ${results.failed}개`);
      console.log(`평균 시도/작업: ${(attemptCount / 50).toFixed(2)}`);
      
      expect(results.successful + results.failed).to.equal(50);
      expect(results.successful).to.be.greaterThan(40); // 대부분 성공해야 함
    });
  });
  
  describe('실시간 스로틀링', () => {
    let throttle;
    
    before(() => {
      throttle = new RealtimeThrottle({
        batchSize: 10,
        throttleMs: 200,
        maxQueueSize: 100
      });
    });
    
    after(() => {
      throttle.cleanup();
    });
    
    it('투표 업데이트 스로틀링', async function() {
      this.timeout(10000);
      
      console.log('\n=== 투표 업데이트 스로틀링 테스트 ===');
      
      const postId = 'test-post-123';
      let processedCount = 0;
      
      // 처리 함수 모킹
      throttle.processBatchUpdates = async (pid, updates) => {
        processedCount += updates.length;
        console.log(`배치 처리: ${updates.length}개 업데이트`);
      };
      
      // 50개의 빠른 투표 시뮬레이션
      const voteStart = Date.now();
      for (let i = 0; i < 50; i++) {
        queueVoteUpdate(postId, `user-${i}`, i % 2 === 0 ? 'A' : 'B');
        await new Promise(resolve => setTimeout(resolve, 10)); // 10ms 간격
      }
      
      // 스로틀 대기
      await new Promise(resolve => setTimeout(resolve, 1000));
      await throttle.flushAll();
      
      const totalTime = Date.now() - voteStart;
      
      console.log(`총 처리 시간: ${totalTime}ms`);
      console.log(`처리된 업데이트: ${processedCount}개`);
      
      expect(processedCount).to.equal(50);
      expect(totalTime).to.be.lessThan(2000); // 2초 이내 처리
    });
    
    it('큐 크기 제한 테스트', async function() {
      console.log('\n=== 큐 크기 제한 테스트 ===');
      
      const postId = 'test-post-overflow';
      let flushCount = 0;
      
      // 플러시 카운트
      const originalFlush = throttle.flushUpdates.bind(throttle);
      throttle.flushUpdates = async (pid) => {
        flushCount++;
        await originalFlush(pid);
      };
      
      // 큐 크기(100) 초과하는 업데이트
      for (let i = 0; i < 150; i++) {
        throttle.queueUpdate(postId, {
          type: 'vote',
          userId: `user-${i}`,
          option: 'A'
        });
      }
      
      // 자동 플러시 확인
      expect(flushCount).to.be.greaterThan(0);
      console.log(`자동 플러시 발생: ${flushCount}회`);
    });
  });
  
  describe('통합 성능 테스트', () => {
    
    it('대규모 투표 시뮬레이션 (1000명)', async function() {
      this.timeout(60000);
      
      console.log('\n=== 대규모 투표 시뮬레이션 시작 ===');
      
      const postId = 'perf-test-post';
      const userCount = 1000;
      const startTime = Date.now();
      
      // 1. 게시물 생성
      await db.collection('posts_record').doc(postId).set({
        question_title: '성능 테스트 투표',
        optionA: { title: 'Option A' },
        optionB: { title: 'Option B' },
        vote_count_a: 0,
        vote_count_b: 0,
        voters: [],
        created_at: FieldValue.serverTimestamp(),
        targetAudience: { count: userCount }
      });
      
      // 2. 병렬 투표 시뮬레이션
      const votePromises = [];
      for (let i = 0; i < userCount; i++) {
        const userId = `perf-user-${i}`;
        const option = Math.random() < 0.6 ? 'A' : 'B'; // 60% A, 40% B
        
        votePromises.push(
          db.runTransaction(async (transaction) => {
            const postRef = db.collection('posts_record').doc(postId);
            const postDoc = await transaction.get(postRef);
            
            if (!postDoc.exists) return;
            
            const data = postDoc.data();
            const fieldName = option === 'A' ? 'vote_count_a' : 'vote_count_b';
            const currentCount = data[fieldName] || 0;
            const voters = data.voters || [];
            
            transaction.update(postRef, {
              [fieldName]: currentCount + 1,
              voters: [...voters, userId],
              last_vote_at: FieldValue.serverTimestamp()
            });
          })
        );
        
        // 10개씩 배치 처리
        if (votePromises.length >= 10) {
          await Promise.all(votePromises.splice(0, 10));
        }
      }
      
      // 남은 투표 처리
      await Promise.all(votePromises);
      
      // 3. 결과 확인
      const finalDoc = await db.collection('posts_record').doc(postId).get();
      const finalData = finalDoc.data();
      const totalTime = Date.now() - startTime;
      
      console.log(`\n=== 성능 테스트 결과 ===`);
      console.log(`총 투표자: ${userCount}명`);
      console.log(`총 소요 시간: ${totalTime}ms`);
      console.log(`평균 처리 시간: ${(totalTime / userCount).toFixed(2)}ms/vote`);
      console.log(`처리량: ${(userCount / (totalTime / 1000)).toFixed(1)} votes/sec`);
      console.log(`최종 결과: A=${finalData.vote_count_a}표, B=${finalData.vote_count_b}표`);
      
      expect(finalData.vote_count_a + finalData.vote_count_b).to.equal(userCount);
      expect(finalData.voters.length).to.equal(userCount);
      
      // 정리
      await db.collection('posts_record').doc(postId).delete();
    });
  });
});

// 테스트 헬퍼 함수
function generateMockUsers(count) {
  return Array.from({ length: count }, (_, i) => ({
    uid: `mock-user-${i}`,
    display_name: `User ${i}`,
    interests: ['테스트', '개발'],
    created_time: new Date()
  }));
}

function measurePerformance(fn) {
  return async (...args) => {
    const start = Date.now();
    const result = await fn(...args);
    const duration = Date.now() - start;
    return { result, duration };
  };
}