// Firebase Functions 알림 시스템 테스트 스크립트 (AI 통합 버전)

const admin = require('firebase-admin');
const { getTokenUsageReport } = require('./ai/config');

// 테스트용 투표 데이터
const testPostData = {
  // 기본 투표 정보
  questionTitle: 'AI가 추천하는 첫 번째 투표입니다',
  question_title: 'AI가 추천하는 첫 번째 투표입니다',
  optionA: '옵션 A',
  option_a: '옵션 A',
  optionB: '옵션 B',
  option_b: '옵션 B',
  authorName: '테스트 작성자',
  author_name: '테스트 작성자',
  category: '일반',
  
  // 타겟 오디언스 설정 - Quick 모드
  targetAudience: {
    type: 'quick',
    targetCount: 10,
    createdAt: new Date(),
    status: {
      current: 'setting',
      collectedCount: 0,
      startedAt: null,
      completedAt: null
    }
  },
  
  // 기타 필드
  created_time: admin.firestore.FieldValue.serverTimestamp(),
  author: 'test-user-id',
  num_votes: 0,
  likes_count: 0,
  comments_count: 0
};

// 테스트 실행 함수
async function testNotificationSystem() {
  console.log('=== AI 통합 알림 시스템 테스트 시작 ===\n');
  
  try {
    // 1. 테스트 사용자 데이터 생성
    console.log('1. 테스트 사용자 생성 중...');
    const usersRef = admin.firestore().collection('users_record');
    const testUsers = [];
    
    for (let i = 1; i <= 20; i++) {
      const userId = `test-user-${i}`;
      const userData = {
        display_name: `테스트 사용자 ${i}`,
        email: `test${i}@example.com`,
        lastActive: admin.firestore.Timestamp.now(),
        interests: ['기술', '게임', '음악', '영화'].slice(0, Math.floor(Math.random() * 4) + 1),
        ageGroup: ['10대', '20대', '30대', '40대'][Math.floor(Math.random() * 4)],
        gender: ['male', 'female'][Math.floor(Math.random() * 2)],
        created_time: admin.firestore.Timestamp.now()
      };
      
      await usersRef.doc(userId).set(userData);
      testUsers.push({ id: userId, ...userData });
    }
    console.log(`✅ ${testUsers.length}명의 테스트 사용자 생성 완료\n`);
    
    // 2. 각 타겟 타입별 테스트
    const targetTypes = [
      {
        name: 'Quick (AI 추천)',
        targetAudience: {
          type: 'quick',
          targetCount: 5
        },
        description: 'AI가 투표 내용을 분석하여 가장 관심있을 사용자 추천'
      },
      {
        name: 'Public (전체 공개)',
        targetAudience: {
          type: 'public',
          targetCount: 10
        }
      },
      {
        name: 'Custom (AI + 필터)',
        targetAudience: {
          type: 'custom',
          targetCount: 5,
          interests: ['기술', '게임'],
          ageGroup: '20대',
          gender: 'all'
        },
        description: '필터링된 사용자 중 AI가 가장 적합한 사용자 선택'
      }
    ];
    
    for (const target of targetTypes) {
      console.log(`\n2. ${target.name} 테스트`);
      if (target.description) {
        console.log(`   설명: ${target.description}`);
      }
      console.log('타겟 설정:', JSON.stringify(target.targetAudience, null, 2));
      
      // 투표 생성 (이것이 Cloud Function을 트리거함)
      const postRef = await admin.firestore().collection('posts_record').add({
        ...testPostData,
        targetAudience: target.targetAudience,
        testType: target.name,
        created_at: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`✅ 테스트 투표 생성: ${postRef.id}`);
      
      // Cloud Function이 실행될 시간을 줌
      console.log('⏳ Cloud Function 실행 대기 중...');
      await new Promise(resolve => setTimeout(resolve, 3000));
      
      // 결과 확인
      const postSnapshot = await postRef.get();
      const postData = postSnapshot.data();
      
      if (postData.targetAudience.status) {
        console.log(`📊 처리 결과:`);
        console.log(`   - 상태: ${postData.targetAudience.status}`);
        console.log(`   - 매칭된 사용자 수: ${postData.targetAudience.matchedCount || 0}`);
        
        if (postData.notificationsSent) {
          console.log(`   - 전송된 알림 수: ${postData.notificationsSent}`);
        }
        
        if (postData.targetAudience.error) {
          console.log(`   - 오류: ${postData.targetAudience.error}`);
        }
      }
      
      // 생성된 알림 확인
      const notifications = await admin.firestore()
        .collection('notifications_record')
        .where('source_id', '==', postRef.id)
        .get();
      
      console.log(`✅ 생성된 알림 수: ${notifications.size}`);
      
      if (notifications.size > 0) {
        console.log('\n📬 샘플 알림:');
        const firstNotification = notifications.docs[0].data();
        console.log(`   - 받는 사람: ${firstNotification.user_id}`);
        console.log(`   - 제목: ${firstNotification.content.title}`);
        console.log(`   - 메시지: ${firstNotification.content.message}`);
        console.log(`   - 타겟 이유: ${firstNotification.targetReason}`);
        
        // AI 점수가 있는 경우 표시
        const userData = notifications.docs.map(doc => doc.data());
        const aiScores = userData
          .map(n => {
            const user = testUsers.find(u => u.id === n.user_id);
            return user?.aiScore;
          })
          .filter(score => score !== undefined);
        
        if (aiScores.length > 0) {
          console.log(`\n🤖 AI 점수 분포:`);
          console.log(`   - 최고: ${Math.max(...aiScores)}`);
          console.log(`   - 최저: ${Math.min(...aiScores)}`);
          console.log(`   - 평균: ${(aiScores.reduce((a, b) => a + b, 0) / aiScores.length).toFixed(1)}`);
        }
      }
      
      console.log('\n' + '='.repeat(50) + '\n');
    }
    
    // 3. 정리
    console.log('3. 테스트 데이터 정리 중...');
    
    // 테스트 사용자 삭제
    for (const user of testUsers) {
      await usersRef.doc(user.id).delete();
    }
    
    // 테스트 투표 삭제
    const testPosts = await admin.firestore()
      .collection('posts_record')
      .where('testType', 'in', ['Quick (빠른 수집)', 'Public (전체 공개)', 'Custom (맞춤 설정)'])
      .get();
    
    for (const doc of testPosts.docs) {
      await doc.ref.delete();
    }
    
    // 테스트 알림 삭제
    const testNotifications = await admin.firestore()
      .collection('notifications_record')
      .where('type', '==', 'voting_request')
      .get();
    
    for (const doc of testNotifications.docs) {
      await doc.ref.delete();
    }
    
    console.log('✅ 테스트 데이터 정리 완료');
    
    // AI 토큰 사용량 리포트
    console.log('\n📊 AI 토큰 사용량 리포트:');
    const tokenReport = getTokenUsageReport();
    console.log(JSON.stringify(tokenReport, null, 2));
    
    console.log('\n=== AI 통합 알림 시스템 테스트 완료 ===');
    
  } catch (error) {
    console.error('❌ 테스트 중 오류 발생:', error);
  }
}

// 에뮬레이터에서 실행하는 경우
if (process.env.FIRESTORE_EMULATOR_HOST) {
  console.log('🔧 Firebase Emulator 환경에서 실행 중...');
  testNotificationSystem();
} else {
  console.log('⚠️  이 스크립트는 Firebase Emulator에서만 실행해야 합니다.');
  console.log('실행 방법: npm run shell 후 require("./test-notification.js")');
}

module.exports = { testNotificationSystem };