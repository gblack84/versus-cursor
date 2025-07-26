const admin = require('firebase-admin');
const { describe, it, before, after } = require('mocha');
const { expect } = require('chai');

// 테스트 환경 설정
const projectId = 'versus-space-1lwwiw';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// Admin SDK 초기화
admin.initializeApp({
  projectId: projectId,
});

const db = admin.firestore();
const auth = admin.auth();
const FieldValue = admin.firestore.FieldValue;

// 테스트 헬퍼 함수들
const createTestUser = async (uid, role = 'user') => {
  try {
    await auth.createUser({
      uid: uid,
      email: `${uid}@test.com`,
      displayName: `Test User ${uid}`,
    });
    
    // Firestore에 사용자 문서 생성
    await db.collection('users').doc(uid).set({
      uid: uid,
      email: `${uid}@test.com`,
      display_name: `Test User ${uid}`,
      created_time: FieldValue.serverTimestamp(),
      role: role,
      job_categories: ['개발자'],
      hobbies: ['코딩', '테스트'],
      interests: ['AI', '프로그래밍'],
    });
    
    return uid;
  } catch (error) {
    console.error(`Error creating test user ${uid}:`, error);
    throw error;
  }
};

const createTestPost = async (creatorId, targetMode = 'test') => {
  const postRef = await db.collection('posts_record').add({
    creator_id: creatorId,
    question_title: '테스트 투표: A vs B',
    descriptionA: 'A 옵션 설명',
    descriptionB: 'B 옵션 설명',
    optionA: {
      title: '옵션 A',
      mediaUrls: [],
    },
    optionB: {
      title: '옵션 B',
      mediaUrls: [],
    },
    vote_count_a: 0,
    vote_count_b: 0,
    voters: [],
    created_at: FieldValue.serverTimestamp(),
    targetAudience: {
      mode: targetMode,
      count: targetMode === 'test' ? 1 : 5,
      interests: targetMode === 'custom' ? ['개발자'] : [],
    },
  });
  
  return postRef.id;
};

const simulateVote = async (postId, userId, option) => {
  const postRef = db.collection('posts_record').doc(postId);
  
  // 투표 실행
  const fieldName = option.toLowerCase() === 'a' ? 'vote_count_a' : 'vote_count_b';
  await postRef.update({
    [fieldName]: FieldValue.increment(1),
    'voters': FieldValue.arrayUnion([userId]),
    'last_vote_at': FieldValue.serverTimestamp(),
  });
  
  // 채팅 메시지 상태 업데이트
  const messagesQuery = await db
    .collection('chats_record')
    .doc('vote_tracking_global')
    .collection('messages')
    .where('vote_post_id', '==', postId)
    .where('message_type', '==', 'vote_request')
    .get();
  
  for (const doc of messagesQuery.docs) {
    await doc.ref.update({
      [`vote_participants.${userId}`]: {
        status: 'completed',
        voted_option: option,
        timestamp: FieldValue.serverTimestamp(),
      },
    });
  }
};

const waitForCondition = async (checkFn, timeout = 10000, interval = 100) => {
  const startTime = Date.now();
  while (Date.now() - startTime < timeout) {
    if (await checkFn()) {
      return true;
    }
    await new Promise(resolve => setTimeout(resolve, interval));
  }
  throw new Error('Timeout waiting for condition');
};

describe('투표 알림 시스템 전체 플로우 테스트', () => {
  let testCreatorId;
  let testVoterIds = [];
  let testPostId;
  
  before(async () => {
    console.log('테스트 환경 설정 중...');
    
    // 테스트 사용자 생성
    testCreatorId = await createTestUser('test-creator', 'tester');
    for (let i = 1; i <= 5; i++) {
      const voterId = await createTestUser(`test-voter-${i}`, 'tester');
      testVoterIds.push(voterId);
    }
    
    // vote_tracking_global 채팅방 생성
    await db.collection('chats_record').doc('vote_tracking_global').set({
      chat_name: 'Vote Tracking Global',
      participantlds: ['system'],
      created_at: FieldValue.serverTimestamp(),
    });
    
    console.log('테스트 환경 설정 완료');
  });
  
  after(async () => {
    console.log('테스트 데이터 정리 중...');
    
    // 테스트 사용자 삭제
    try {
      await auth.deleteUser(testCreatorId);
      for (const voterId of testVoterIds) {
        await auth.deleteUser(voterId);
      }
    } catch (error) {
      console.error('Error deleting test users:', error);
    }
    
    console.log('테스트 데이터 정리 완료');
  });
  
  describe('시나리오 1: 테스트 모드 전체 플로우', () => {
    it('투표 생성 → 알림 전송 → 투표 참여 → 결과 처리', async function() {
      this.timeout(30000); // 30초 타임아웃
      
      console.log('\n=== 시나리오 1 시작 ===');
      
      // 1. 투표 게시물 생성
      console.log('1. 투표 게시물 생성');
      testPostId = await createTestPost(testCreatorId, 'test');
      expect(testPostId).to.be.a('string');
      console.log(`   ✓ 게시물 생성됨: ${testPostId}`);
      
      // 2. 알림이 생성되었는지 확인
      console.log('2. 알림 생성 확인');
      await waitForCondition(async () => {
        const notifications = await db
          .collection('notifications_record')
          .where('source_id', '==', testPostId)
          .where('user_id', '==', testCreatorId)
          .get();
        return !notifications.empty;
      });
      
      const notificationDoc = await db
        .collection('notifications_record')
        .where('source_id', '==', testPostId)
        .where('user_id', '==', testCreatorId)
        .limit(1)
        .get();
      
      expect(notificationDoc.empty).to.be.false;
      console.log('   ✓ 알림이 생성됨');
      
      // 3. 채팅 메시지가 생성되었는지 확인
      console.log('3. 채팅 메시지 확인');
      const voteMessages = await db
        .collection('chats_record')
        .doc('vote_tracking_global')
        .collection('messages')
        .where('vote_post_id', '==', testPostId)
        .get();
      
      expect(voteMessages.size).to.be.at.least(2); // vote_created와 vote_request
      console.log(`   ✓ 채팅 메시지 생성됨: ${voteMessages.size}개`);
      
      // 4. 투표 수행
      console.log('4. 투표 수행');
      await simulateVote(testPostId, testCreatorId, 'A');
      console.log('   ✓ 테스터가 옵션 A에 투표함');
      
      // 5. 투표 완료 처리 확인
      console.log('5. 투표 완료 확인');
      await waitForCondition(async () => {
        const postDoc = await db.collection('posts_record').doc(testPostId).get();
        const postData = postDoc.data();
        return postData.vote_completed === true;
      });
      
      const completedPost = await db.collection('posts_record').doc(testPostId).get();
      expect(completedPost.data().vote_completed).to.be.true;
      expect(completedPost.data().vote_count_a).to.equal(1);
      console.log('   ✓ 투표가 완료 처리됨');
      
      // 6. 결과 알림 확인
      console.log('6. 결과 알림 확인');
      await waitForCondition(async () => {
        const resultMessages = await db
          .collection('chats_record')
          .doc('vote_tracking_global')
          .collection('messages')
          .where('vote_post_id', '==', testPostId)
          .where('vote_user_status', '==', 'result_arrived')
          .get();
        return !resultMessages.empty;
      });
      
      console.log('   ✓ 결과 알림이 생성됨');
      console.log('\n=== 시나리오 1 완료 ===\n');
    });
  });
  
  describe('시나리오 2: 멀티 사용자 동시 투표', () => {
    it('여러 사용자가 동시에 투표하는 경우', async function() {
      this.timeout(30000);
      
      console.log('\n=== 시나리오 2 시작 ===');
      
      // 1. 퍼블릭 모드로 투표 생성
      console.log('1. 퍼블릭 투표 생성');
      const publicPostId = await createTestPost(testCreatorId, 'public');
      console.log(`   ✓ 퍼블릭 투표 생성됨: ${publicPostId}`);
      
      // 2. 5명의 사용자에게 알림이 전송되었는지 확인
      console.log('2. 5명에게 알림 전송 확인');
      await waitForCondition(async () => {
        const notifications = await db
          .collection('notifications_record')
          .where('source_id', '==', publicPostId)
          .get();
        return notifications.size >= 5;
      });
      
      const notifications = await db
        .collection('notifications_record')
        .where('source_id', '==', publicPostId)
        .get();
      
      expect(notifications.size).to.be.at.least(5);
      console.log(`   ✓ ${notifications.size}명에게 알림 전송됨`);
      
      // 3. 동시 투표 시뮬레이션
      console.log('3. 동시 투표 시뮬레이션');
      const votePromises = [];
      
      // 3명은 A, 2명은 B에 투표
      notifications.docs.slice(0, 3).forEach(doc => {
        votePromises.push(simulateVote(publicPostId, doc.data().user_id, 'A'));
      });
      
      notifications.docs.slice(3, 5).forEach(doc => {
        votePromises.push(simulateVote(publicPostId, doc.data().user_id, 'B'));
      });
      
      await Promise.all(votePromises);
      console.log('   ✓ 5명이 동시에 투표 완료');
      
      // 4. 투표 결과 확인
      console.log('4. 투표 결과 검증');
      const finalPost = await db.collection('posts_record').doc(publicPostId).get();
      const finalData = finalPost.data();
      
      expect(finalData.vote_count_a).to.equal(3);
      expect(finalData.vote_count_b).to.equal(2);
      expect(finalData.voters.length).to.equal(5);
      expect(finalData.vote_completed).to.be.true;
      
      console.log('   ✓ 투표 결과: A=3표, B=2표');
      console.log('   ✓ 투표 완료 처리됨');
      console.log('\n=== 시나리오 2 완료 ===\n');
    });
  });
  
  describe('시나리오 3: 에지 케이스 테스트', () => {
    it('투표 거부 처리', async function() {
      this.timeout(20000);
      
      console.log('\n=== 시나리오 3-1: 투표 거부 ===');
      
      // 1. 투표 생성
      const declinePostId = await createTestPost(testCreatorId, 'test');
      
      // 2. 알림 대기
      await waitForCondition(async () => {
        const notifications = await db
          .collection('notifications_record')
          .where('source_id', '==', declinePostId)
          .get();
        return !notifications.empty;
      });
      
      // 3. 투표 거부 시뮬레이션
      const messagesQuery = await db
        .collection('chats_record')
        .doc('vote_tracking_global')
        .collection('messages')
        .where('vote_post_id', '==', declinePostId)
        .where('message_type', '==', 'vote_request')
        .get();
      
      for (const doc of messagesQuery.docs) {
        await doc.ref.update({
          [`vote_participants.${testCreatorId}`]: {
            status: 'not_participated',
            timestamp: FieldValue.serverTimestamp(),
          },
        });
      }
      
      console.log('   ✓ 투표 거부 처리 완료');
    });
    
    it('24시간 타임아웃 처리', async function() {
      console.log('\n=== 시나리오 3-2: 타임아웃 처리 ===');
      
      // 1. 과거 시간으로 투표 생성
      const timeoutPostRef = await db.collection('posts_record').add({
        creator_id: testCreatorId,
        question_title: '타임아웃 테스트',
        optionA: { title: 'A' },
        optionB: { title: 'B' },
        vote_count_a: 0,
        vote_count_b: 0,
        voters: [],
        created_at: new Date(Date.now() - 25 * 60 * 60 * 1000), // 25시간 전
        targetAudience: {
          mode: 'test',
          count: 1,
        },
      });
      
      console.log('   ✓ 25시간 전 투표 생성됨');
      console.log('   ℹ️  실제 환경에서는 scheduled function이 이를 처리합니다');
    });
  });
});

// 성능 테스트
describe('성능 테스트', () => {
  it('대규모 투표 처리 (100명 동시)', async function() {
    this.timeout(60000); // 1분 타임아웃
    
    console.log('\n=== 성능 테스트 시작 ===');
    
    // 1. 100명의 테스트 사용자 생성 (배치)
    console.log('1. 100명 사용자 생성');
    const startTime = Date.now();
    const batchUsers = [];
    
    for (let i = 0; i < 10; i++) {
      const batch = db.batch();
      for (let j = 0; j < 10; j++) {
        const userId = `perf-user-${i * 10 + j}`;
        const userRef = db.collection('users').doc(userId);
        batch.set(userRef, {
          uid: userId,
          display_name: `Perf User ${i * 10 + j}`,
          created_time: FieldValue.serverTimestamp(),
        });
        batchUsers.push(userId);
      }
      await batch.commit();
    }
    
    const userCreationTime = Date.now() - startTime;
    console.log(`   ✓ 100명 생성 완료 (${userCreationTime}ms)`);
    
    // 2. 커스텀 모드로 투표 생성
    console.log('2. 대규모 투표 생성');
    const perfPostRef = await db.collection('posts_record').add({
      creator_id: 'test-creator',
      question_title: '성능 테스트 투표',
      optionA: { title: 'A' },
      optionB: { title: 'B' },
      vote_count_a: 0,
      vote_count_b: 0,
      voters: [],
      created_at: FieldValue.serverTimestamp(),
      targetAudience: {
        mode: 'custom',
        count: 100,
      },
    });
    
    // 3. 100명 동시 투표 시뮬레이션
    console.log('3. 100명 동시 투표');
    const voteStartTime = Date.now();
    const votePromises = [];
    
    for (let i = 0; i < 100; i++) {
      const option = i < 60 ? 'A' : 'B'; // 60% A, 40% B
      votePromises.push(
        simulateVote(perfPostRef.id, batchUsers[i], option)
          .catch(err => console.error(`Vote error for user ${i}:`, err))
      );
    }
    
    await Promise.all(votePromises);
    const voteTime = Date.now() - voteStartTime;
    
    console.log(`   ✓ 100명 투표 완료 (${voteTime}ms)`);
    console.log(`   ✓ 평균 투표 시간: ${(voteTime / 100).toFixed(2)}ms/vote`);
    
    // 4. 결과 검증
    const finalDoc = await perfPostRef.get();
    const finalData = finalDoc.data();
    
    expect(finalData.vote_count_a).to.be.within(55, 65); // 대략 60%
    expect(finalData.vote_count_b).to.be.within(35, 45); // 대략 40%
    expect(finalData.voters.length).to.equal(100);
    
    console.log('   ✓ 투표 결과 검증 완료');
    console.log(`   ✓ 최종 결과: A=${finalData.vote_count_a}표, B=${finalData.vote_count_b}표`);
    
    // 정리
    const cleanupBatch = db.batch();
    for (const userId of batchUsers) {
      cleanupBatch.delete(db.collection('users').doc(userId));
    }
    await cleanupBatch.commit();
    
    console.log('\n=== 성능 테스트 완료 ===');
    console.log(`총 소요 시간: ${Date.now() - startTime}ms`);
  });
});