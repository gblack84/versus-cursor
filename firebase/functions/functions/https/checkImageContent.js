/**
 * HTTP 호출로 이미지 콘텐츠 검사
 * 이미지를 저장하기 전에 사전 검사하는 용도
 */

const functions = require("firebase-functions");
const { checkImageContent } = require("../../services/imageModeration");

exports.checkImageContent = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const { image, box } = data;
    
    if (!image) {
      throw new functions.https.HttpsError('invalid-argument', '이미지 데이터가 필요합니다.');
    }

    try {
      console.log(`[이미지 검사] 이미지 검사 시작 - User: ${context.auth.uid}, Box: ${box || 'unknown'}`);
      
      // 이미지 검사 서비스 호출
      const result = await checkImageContent(image);
      
      // 로그 기록 (최소한의 정보만)
      if (!result.isAppropriate) {
        console.log(`[이미지 검사] 부적절한 콘텐츠 감지 - User: ${context.auth.uid}, Reason: ${result.reason}`);
      }
      
      return {
        isAppropriate: result.isAppropriate,
        reason: result.reason,
        hasText: result.hasText,
        // 디버깅용 (프로덕션에서는 제거 가능)
        detections: process.env.NODE_ENV === 'development' ? result.detections : undefined
      };
      
    } catch (error) {
      console.error('[이미지 검사] 오류 발생:', error);
      throw new functions.https.HttpsError('internal', '이미지 검사 중 오류가 발생했습니다.');
    }
  });