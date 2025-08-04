/**
 * 알림 전송 서비스
 * 게시물 생성 시 타겟 사용자에게 알림을 전송하는 로직
 */

const { admin } = require('../config/firebase');
const { matchTargetUsers } = require('../notifications/targetMatcher');
const { createNotificationsForUsers } = require('../notifications/notificationCreator');

/**
 * 스마트 알림 전송
 * @param {string} postId - 게시물 ID
 * @param {Object} postData - 게시물 데이터
 * @returns {Object} 알림 전송 결과
 */
async function sendSmartNotifications(postId, postData) {
  const results = {
    success: false,
    notificationsSent: 0,
    errors: [],
    matchedUsers: 0
  };
  
  try {
    // 1. targetAudience 확인
    if (!postData.targetAudience) {
      console.log('[알림 서비스] targetAudience 필드가 없음');
      return results;
    }
    
    const { type, targetCount = 100 } = postData.targetAudience;
    console.log(`[알림 서비스] 타겟 타입: ${type}, 목표 수: ${targetCount}`);
    
    // 지원하는 타겟 타입 확인
    if (!['quick', 'public', 'custom'].includes(type)) {
      console.log(`[알림 서비스] 지원하지 않는 타겟 타입: ${type}`);
      return results;
    }
    
    // 2. 타겟 사용자 매칭
    const matchedUsers = await matchTargetUsers(postData.targetAudience, postData);
    
    // 3. 작성자 제외 필터링
    const creatorId = postData.uid || postData.userid;
    const filteredUsers = matchedUsers.filter(user => {
      const isCreator = user.id === creatorId;
      if (isCreator) {
        console.log(`[알림 서비스] 작성자 제외: ${user.id}`);
      }
      return !isCreator;
    });
    
    results.matchedUsers = filteredUsers.length;
    
    if (filteredUsers.length === 0) {
      console.log('[알림 서비스] 매칭된 사용자 없음 (작성자 제외 후)');
      return results;
    }
    
    console.log(`[알림 서비스] ${filteredUsers.length}명의 사용자 매칭됨 (작성자 제외)`);
    
    // 4. 알림 생성
    await createNotificationsForUsers(filteredUsers, postId, postData);
    
    results.success = true;
    results.notificationsSent = filteredUsers.length;
    
    return results;
    
  } catch (error) {
    console.error('[알림 서비스] 오류 발생:', error);
    results.errors.push(error.message);
    throw error;
  }
}

module.exports = {
  sendSmartNotifications
};