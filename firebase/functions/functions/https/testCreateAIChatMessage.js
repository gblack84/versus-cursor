/**
 * AI 채팅 메시지 생성 테스트 함수
 * HTTP 요청으로 수동 테스트 가능
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { createVoteRequestMessage, createVoteCreatedMessage } = require("../../services/aiChatService");

exports.testCreateAIChatMessage = functions
  .region("asia-northeast3")
  .https
  .onRequest(async (req, res) => {
    try {
      const { userId, postId, messageType = 'request' } = req.body;
      
      if (!userId || !postId) {
        return res.status(400).json({ 
          error: 'userId와 postId가 필요합니다' 
        });
      }
      
      // 게시물 데이터 가져오기
      const postDoc = await admin.firestore()
        .collection('posts')
        .doc(postId)
        .get();
        
      if (!postDoc.exists) {
        return res.status(404).json({ 
          error: '게시물을 찾을 수 없습니다' 
        });
      }
      
      const postData = postDoc.data();
      
      // optionA/optionB 처리
      let optionATitle = '';
      let optionBTitle = '';
      let imageUrlsA = [];
      let imageUrlsB = [];
      
      if (typeof postData.optionA === 'object' && postData.optionA !== null) {
        optionATitle = postData.optionA.title || '';
        imageUrlsA = postData.optionA.mediaUrls || [];
      } else {
        optionATitle = postData.optionA || postData.option_a || '';
      }
      
      if (typeof postData.optionB === 'object' && postData.optionB !== null) {
        optionBTitle = postData.optionB.title || '';
        imageUrlsB = postData.optionB.mediaUrls || [];
      } else {
        optionBTitle = postData.optionB || postData.option_b || '';
      }
      
      const formattedData = {
        ...postData,
        authorName: postData.authorName || postData.author_name || '익명',
        questionTitle: postData.question_title || postData.questionTitle,
        optionA: optionATitle,
        optionB: optionBTitle,
        imageUrlA: imageUrlsA.length > 0 ? imageUrlsA[0] : (postData.image_url_a || postData.imageUrlA),
        imageUrlB: imageUrlsB.length > 0 ? imageUrlsB[0] : (postData.image_url_b || postData.imageUrlB),
        imageUrlsA: imageUrlsA.length > 0 ? imageUrlsA : (postData.image_urls_a || postData.imageUrlsA || []),
        imageUrlsB: imageUrlsB.length > 0 ? imageUrlsB : (postData.image_urls_b || postData.imageUrlsB || []),
        description: postData.description || ''
      };
      
      let messageId;
      
      if (messageType === 'created') {
        // 작성자용 메시지
        messageId = await createVoteCreatedMessage(userId, postId, formattedData);
      } else {
        // 투표 요청 메시지
        messageId = await createVoteRequestMessage(userId, postId, formattedData);
      }
      
      console.log(`[테스트] AI 채팅 메시지 생성 완료: messageId=${messageId}`);
      
      return res.json({
        success: true,
        messageId,
        chatId: `ai_assistant_${userId}`
      });
      
    } catch (error) {
      console.error('[테스트] AI 채팅 메시지 생성 실패:', error);
      return res.status(500).json({ 
        error: error.message,
        stack: error.stack 
      });
    }
  });