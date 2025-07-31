/**
 * 사용자 포스팅 이력 분석
 * AI 검증을 위한 사용자 이력 조회
 */

const { admin } = require('../config/firebase');

/**
 * 사용자 포스팅 이력 조회
 * @param {string} userId - 사용자 ID
 * @returns {Object} 이력 통계
 */
async function getUserPostingHistory(userId) {
  // TODO: Production 배포 전 Firestore 인덱스 생성 필요
  // 필요한 인덱스: content_validations 컬렉션
  // - userId (오름차순)
  // - geminiResult.isValid (오름차순)
  // - timestamp (내림차순)
  
  // 현재는 테스트를 위해 기본값 반환
  console.log('[getUserPostingHistory] 테스트 모드 - 기본값 반환');
  return {
    rejectedCount: 0,
    reportCount: 0,
    isNewUser: true
  };
  
  /* Production 코드 (인덱스 생성 후 주석 해제)
  try {
    const db = admin.firestore();
    
    // 최근 30일간의 거부된 포스트 수
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const rejectedSnapshot = await db
      .collection('content_validations')
      .where('userId', '==', userId)
      .where('geminiResult.isValid', '==', false)
      .where('timestamp', '>=', thirtyDaysAgo)
      .get();
    
    // 신고된 포스트 수 (posts에서)
    const reportedSnapshot = await db
      .collection('posts')
      .where('user_ref', '==', db.doc(`users/${userId}`))
      .where('reported_count', '>', 0)
      .get();
    
    return {
      rejectedCount: rejectedSnapshot.size,
      reportCount: reportedSnapshot.size,
      isNewUser: rejectedSnapshot.size === 0 && reportedSnapshot.size === 0
    };
  } catch (error) {
    console.error('[getUserPostingHistory] 오류:', error);
    return {
      rejectedCount: 0,
      reportCount: 0,
      isNewUser: true
    };
  }
  */
}

module.exports = {
  getUserPostingHistory
};