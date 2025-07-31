/**
 * 사용자 삭제 시 관련 데이터 정리
 * 트리거: Firebase Auth 사용자 삭제
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");

exports.onUserDeleted = functions
  .region("asia-northeast3")
  .auth.user()
  .onDelete(async (user) => {
    console.log(`[사용자 삭제] 사용자 삭제 처리 시작: ${user.uid}`);
    
    try {
      const firestore = admin.firestore();
      
      // 사용자 문서 삭제
      await firestore.collection("users").doc(user.uid).delete();
      
      console.log(`[사용자 삭제] 사용자 데이터 삭제 완료: ${user.uid}`);
    } catch (error) {
      console.error('[사용자 삭제] 오류 발생:', error);
      throw error;
    }
  });