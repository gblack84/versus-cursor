const admin = require('firebase-admin');
const { getAIRecommendedUsers } = require('../ai/userRecommendation');

// 일주일 전 날짜 계산
function getOneWeekAgo() {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  return admin.firestore.Timestamp.fromDate(date);
}

// 타겟 사용자 매칭 함수 (AI 통합)
async function matchTargetUsers(targetAudience, postData = null) {
  const { type, targetCount = 100, interests, ageGroup, gender } = targetAudience;
  
  let query = admin.firestore().collection('users_record');
  const matchedUsers = [];
  
  console.log(`타겟 타입: ${type}, 목표 수: ${targetCount}`);
  
  switch (type) {
    case 'quick':
      // 빠른 수집: AI가 추천
      console.log('AI 추천 모드 활성화');
      
      // AI 추천을 위한 후보군 확보 (목표의 5배)
      query = query
        .where('lastActive', '>', getOneWeekAgo())
        .orderBy('lastActive', 'desc')
        .limit(Math.min(targetCount * 5, 500)); // 최대 500명까지
      break;
      
    case 'public':
      // 전체 공개: 모든 활성 사용자
      query = query
        .where('lastActive', '>', getOneWeekAgo())
        .orderBy('lastActive', 'desc')
        .limit(targetCount * 2);
      break;
      
    case 'custom':
      // 맞춤 설정: 세부 조건 필터링
      
      // 활성 사용자 필터를 먼저 적용
      query = query.where('lastActive', '>', getOneWeekAgo());
      
      // 관심사 필터 (Firestore는 array-contains-any를 지원)
      if (interests && interests.length > 0) {
        query = query.where('interests', 'array-contains-any', interests);
      }
      
      // 연령대 필터
      if (ageGroup && ageGroup !== '전체') {
        query = query.where('ageGroup', '==', ageGroup);
      }
      
      // 성별 필터
      if (gender && gender !== 'all') {
        query = query.where('gender', '==', gender);
      }
      
      query = query
        .orderBy('lastActive', 'desc')
        .limit(targetCount * 2);
      break;
      
    case 'test':
      // 테스트 모드: 생성자 본인에게만 전송
      console.log('[테스트 모드] 생성자에게만 알림 전송');
      
      const creatorId = postData?.uid || postData?.userid || postData?.creatorInfo?.uid;
      if (!creatorId) {
        console.error('[테스트 모드] 생성자 ID를 찾을 수 없음');
        return [];
      }
      
      const creator = await admin.firestore()
        .collection('users_record')
        .doc(creatorId)
        .get();
      
      if (creator.exists) {
        const creatorData = creator.data();
        
        // role 검증 (보안)
        if (creatorData.role === 'admin' || creatorData.role === 'tester') {
          // targetCount만큼 반복 (최대 10개)
          const testCount = Math.min(targetCount, 10);
          for (let i = 0; i < testCount; i++) {
            matchedUsers.push({
              id: creatorId,
              displayName: creatorData.display_name || '테스터',
              ...creatorData,
              testIndex: i + 1  // 알림 구분용
            });
          }
          console.log(`[테스트 모드] ${matchedUsers.length}개 알림 생성 (모두 ${creatorData.display_name}에게)`);
          
          // test 모드는 바로 리턴 (AI 추천 과정 생략)
          return matchedUsers;
        } else {
          console.error('[테스트 모드] 권한 없음 - 일반 사용자는 테스트 모드 사용 불가');
          return [];
        }
      } else {
        console.error('[테스트 모드] 생성자 문서를 찾을 수 없음');
        return [];
      }
      break;
      
    default:
      console.error(`알 수 없는 타겟 타입: ${type}`);
      return [];
  }
  
  try {
    // 쿼리 실행
    const snapshot = await query.get();
    
    // 결과 처리
    snapshot.forEach(doc => {
      const userData = doc.data();
      matchedUsers.push({
        id: doc.id,
        displayName: userData.display_name || '익명',
        ...userData
      });
    });
    
    console.log(`쿼리 결과: ${matchedUsers.length}명`);
    
    // AI 추천 또는 랜덤 선택
    let selected;
    
    if (type === 'quick' && postData) {
      // AI 추천 사용
      try {
        console.log('AI 추천 시작...');
        selected = await getAIRecommendedUsers(postData, matchedUsers, targetCount);
        console.log(`AI 추천 완료: ${selected.length}명 선택됨`);
      } catch (aiError) {
        console.error('AI 추천 실패, 랜덤 선택으로 폴백:', aiError);
        // AI 실패 시 랜덤 선택
        const shuffled = matchedUsers.sort(() => 0.5 - Math.random());
        selected = shuffled.slice(0, targetCount);
      }
    } else if (type === 'custom' && postData) {
      // Custom 모드에서도 AI 점수를 활용하여 정렬
      try {
        console.log('Custom 모드 AI 점수 계산...');
        const aiScored = await getAIRecommendedUsers(postData, matchedUsers, matchedUsers.length);
        // AI 점수가 높은 순으로 정렬 후 목표 수만큼 선택
        selected = aiScored
          .sort((a, b) => (b.aiScore || 0) - (a.aiScore || 0))
          .slice(0, targetCount);
      } catch (aiError) {
        console.error('AI 점수 계산 실패, 랜덤 선택으로 폴백:', aiError);
        const shuffled = matchedUsers.sort(() => 0.5 - Math.random());
        selected = shuffled.slice(0, targetCount);
      }
    } else {
      // 기본: 랜덤 선택 (public 모드 등)
      const shuffled = matchedUsers.sort(() => 0.5 - Math.random());
      selected = shuffled.slice(0, targetCount);
    }
    
    return selected;
  } catch (error) {
    console.error('사용자 매칭 중 오류:', error);
    return [];
  }
}

module.exports = { matchTargetUsers };