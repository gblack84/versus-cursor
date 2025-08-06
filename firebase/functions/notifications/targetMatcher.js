const admin = require('firebase-admin');
const { getAIRecommendedUsers } = require('../ai/userRecommendation');

// 일주일 전 날짜 계산
function getOneWeekAgo() {
  const date = new Date();
  date.setDate(date.getDate() - 7);
  return admin.firestore.Timestamp.fromDate(date);
}

// 활성 사용자 가져오기 (두 필드명 모두 지원하면서 안정성 확보)
async function getActiveUsers(targetCount, oneWeekAgo, filters = {}) {
  const usersMap = new Map();
  
  try {
    // 1. 먼저 lastActive 필드로 시도 (새 데이터)
    let query = admin.firestore().collection('users')
      .where('lastActive', '>', oneWeekAgo);
    
    // 추가 필터 적용
    if (filters.interests && filters.interests.length > 0) {
      query = query.where('interests', 'array-contains-any', filters.interests);
    }
    if (filters.ageGroup && filters.ageGroup !== '전체') {
      query = query.where('ageGroup', '==', filters.ageGroup);
    }
    if (filters.gender && filters.gender !== 'all') {
      query = query.where('gender', '==', filters.gender);
    }
    
    query = query.orderBy('lastActive', 'desc').limit(targetCount);
    
    const snapshot1 = await query.get();
    console.log(`lastActive 쿼리 결과: ${snapshot1.size}명`);
    
    snapshot1.forEach(doc => {
      usersMap.set(doc.id, {
        id: doc.id,
        ...doc.data()
      });
    });
    
    // 2. 목표 수에 미달하면 레거시 데이터 추가 확인
    if (usersMap.size < targetCount * 0.8) {
      try {
        let legacyQuery = admin.firestore().collection('users')
          .where('last_active_time', '>', oneWeekAgo)
          .orderBy('last_active_time', 'desc')
          .limit(targetCount);
        
        const snapshot2 = await legacyQuery.get();
        console.log(`last_active_time 쿼리 결과: ${snapshot2.size}명`);
        
        snapshot2.forEach(doc => {
          if (!usersMap.has(doc.id)) {
            usersMap.set(doc.id, {
              id: doc.id,
              ...doc.data()
            });
          }
        });
      } catch (legacyError) {
        console.log('레거시 필드 쿼리 실패 (정상적인 경우일 수 있음):', legacyError.message);
      }
    }
    
  } catch (error) {
    console.error('활성 사용자 쿼리 오류:', error);
    throw error;
  }
  
  const users = Array.from(usersMap.values());
  console.log(`총 활성 사용자: ${users.length}명`);
  return users;
}

// 타겟 사용자 매칭 함수 (AI 통합)
async function matchTargetUsers(targetAudience, postData = null) {
  const { type, targetCount = 100, interests, ageGroup, gender } = targetAudience;
  
  let query = admin.firestore().collection('users');
  let matchedUsers = [];
  
  console.log(`타겟 타입: ${type}, 목표 수: ${targetCount}`);
  
  const oneWeekAgo = getOneWeekAgo();
  
  try {
    // 타입별로 활성 사용자 가져오기
    let activeUsers = [];
    
    switch (type) {
      case 'quick':
        // 빠른 수집: AI가 추천
        console.log('AI 추천 모드 활성화');
        
        // 활성 사용자 가져오기 (AI 추천을 위한 후보군 확보)
        activeUsers = await getActiveUsers(
          Math.min(targetCount * 5, 500), // 목표의 5배, 최대 500명
          oneWeekAgo
        );
        
        matchedUsers.push(...activeUsers);
        break;
        
      case 'public':
        // 전체 공개: 모든 활성 사용자
        console.log('전체 공개 모드');
        
        // 활성 사용자 가져오기
        activeUsers = await getActiveUsers(
          targetCount * 2, // 목표의 2배
          oneWeekAgo
        );
        
        matchedUsers.push(...activeUsers);
        break;
        
      case 'custom':
        // 맞춤 설정: 세부 조건 필터링
        console.log('맞춤 설정 모드');
        
        // 필터와 함께 활성 사용자 가져오기
        activeUsers = await getActiveUsers(
          targetCount * 2, // 목표의 2배
          oneWeekAgo,
          { interests, ageGroup, gender } // 필터 전달
        );
        
        // getActiveUsers에서 이미 필터링했으므로 추가 필터링 불필요
        matchedUsers.push(...activeUsers);
        break;
        
      default:
        console.error(`알 수 없는 타겟 타입: ${type}`);
        return [];
    }
    
    // 사용자 데이터 정규화
    matchedUsers = matchedUsers.map(user => ({
      id: user.id,
      displayName: user.display_name || user.displayName || '익명',
      // lastActive 필드 정규화 (레거시 데이터 처리)
      lastActive: user.lastActive || user.last_active_time,
      ...user
    }));
    
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