/**
 * 게시물 생성 시 알림 전송
 * 트리거: posts 컬렉션에 새 문서 생성
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { sendSmartNotifications } = require("../../services/notificationService");
const { createVoteCreatedMessage } = require("../../services/aiChatService");

exports.onPostCreatedSendNotifications = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 300, // 5분 타임아웃
    memory: '512MB'
  })
  .firestore
  .document('posts/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    const postId = context.params.postId;
    
    // 디버그 로그
    console.log(`[알림] 게시물 생성 감지: ${postId}`);
    console.log(`[알림] targetAudience 설정:`, postData.targetAudience);
    
    // 알림 비활성화된 경우 스킵
    if (!postData.isNotificationEnabled) {
      console.log('[알림] 알림이 비활성화되어 있습니다.');
      return null;
    }
    
    try {
      // 10분 타이머 시작/종료 시간 설정
      const now = Date.now();
      const voteStartTime = new Date(now);
      const voteEndTime = new Date(now + 10 * 60 * 1000); // 10분 후
      
      // 게시물에 타이머 정보 업데이트
      await snap.ref.update({
        voteStartTime: admin.firestore.Timestamp.fromDate(voteStartTime),
        voteEndTime: admin.firestore.Timestamp.fromDate(voteEndTime),
        voteStatus: 'active',
        voteCompleted: false
      });
      
      // 작성자에게 AI 채팅 메시지 생성
      const creatorId = postData.uid || postData.userid;
      if (creatorId) {
        await createVoteCreatedMessage(creatorId, postId, {
          ...postData,
          authorName: postData.authorName || postData.author_name || '익명',
          questionTitle: postData.question_title || postData.questionTitle,
          optionA: postData.option_a || postData.optionA?.title || 'A',
          optionB: postData.option_b || postData.optionB?.title || 'B',
          imageUrlA: postData.image_url_a || postData.imageUrlA,
          imageUrlB: postData.image_url_b || postData.imageUrlB,
          imageUrlsA: postData.image_urls_a || postData.imageUrlsA,
          imageUrlsB: postData.image_urls_b || postData.imageUrlsB,
          description: postData.description
        });
        console.log(`[알림] 작성자 AI 채팅 메시지 생성 완료: userId=${creatorId}`);
      }
      
      // 스마트 알림 전송 (10분 타이머 정보 포함)
      const result = await sendSmartNotifications(postId, {
        ...postData,
        voteStartTime,
        voteEndTime
      });
      
      console.log(`[알림] 알림 전송 완료:`, {
        postId,
        success: result.success,
        notificationsSent: result.notificationsSent,
        errors: result.errors,
        voteTimer: '10분',
        voteEndTime: voteEndTime.toISOString()
      });
      
      return result;
      
    } catch (error) {
      console.error('[알림] 알림 전송 중 오류:', error);
      
      // 오류 로깅
      await admin.firestore().collection('notification_errors').add({
        postId,
        error: error.message,
        stack: error.stack,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });
      
      throw error;
    }
  });