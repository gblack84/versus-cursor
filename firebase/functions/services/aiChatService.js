/**
 * AI 피클 채팅 서비스
 * AI 어시스턴트와의 채팅 메시지 생성 및 관리
 */

const { admin } = require('../config/firebase');
const { v4: uuidv4 } = require('uuid');

// AI 어시스턴트 상수
const AI_ASSISTANT_ID = 'ai_assistant';
const AI_ASSISTANT_NAME = 'AI 피클';

/**
 * AI와의 1:1 채팅방 ID 생성
 * @param {string} userId - 사용자 ID
 * @returns {string} 채팅방 ID
 */
function getAIChatId(userId) {
  // AI 채팅방은 항상 'ai_assistant_userId' 형식으로 고정
  return `${AI_ASSISTANT_ID}_${userId}`;
}

/**
 * 투표 요청 메시지 생성 (투표 받는 사용자용)
 * @param {string} userId - 대상 사용자 ID
 * @param {string} postId - 게시물 ID
 * @param {Object} postData - 게시물 데이터
 * @returns {Promise<string>} 생성된 메시지 ID
 */
async function createVoteRequestMessage(userId, postId, postData) {
  const chatId = getAIChatId(userId);
  const messageId = uuidv4();
  const now = admin.firestore.Timestamp.now();
  
  const messageData = {
    // 기본 메시지 정보
    message_id: messageId,
    sender_id: AI_ASSISTANT_ID,
    receiver_id: userId,
    content: `${postData.authorName || '누군가'}님이 당신의 의견을 듣고 싶어해요!`,
    time_stamp: now,
    is_read: false,
    
    // 투표 메시지 정보
    message_type: 'vote_request',
    vote_post_id: postId,
    vote_title: postData.questionTitle || postData.question_title || '',
    vote_option_a_text: postData.optionA || postData.option_a || '',
    vote_option_b_text: postData.optionB || postData.option_b || '',
    vote_option_a_image: postData.imageUrlA || postData.image_url_a || null,
    vote_option_b_image: postData.imageUrlB || postData.image_url_b || null,
    
    // 멀티이미지 지원
    vote_option_a_images: postData.imageUrlsA || postData.image_urls_a || null,
    vote_option_b_images: postData.imageUrlsB || postData.image_urls_b || null,
    
    // 전체 설명
    vote_description: postData.description || '',
    
    // 카드 상태
    card_status: 'voting_request', // 초기 상태: 피클요청
    vote_status: 'pending',
    vote_end_time: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 10 * 60 * 1000) // 10분 후
    )
  };
  
  // 채팅방이 없으면 생성
  const chatRef = admin.firestore().collection('chats').doc(chatId);
  const chatDoc = await chatRef.get();
  
  if (!chatDoc.exists) {
    await chatRef.set({
      user_a: AI_ASSISTANT_ID,
      user_b: userId,
      last_message_content: messageData.content,
      last_message_at: now,
      last_message_sent_by: AI_ASSISTANT_ID,
      users: [AI_ASSISTANT_ID, userId],
      participantIds: [AI_ASSISTANT_ID, userId],  // Flutter 호환성을 위해 추가
      chat_name: 'AI 피클',  // AI 채팅방 이름
      chat_type: 'ai_chat'  // 채팅 타입 명시
    });
  } else {
    // 마지막 메시지 업데이트
    await chatRef.update({
      last_message_content: messageData.content,
      last_message_at: now,
      last_message_sent_by: AI_ASSISTANT_ID
    });
  }
  
  // 메시지 생성
  await chatRef.collection('messages').doc(messageId).set(messageData);
  
  console.log(`[AI 채팅] 투표 요청 메시지 생성: userId=${userId}, messageId=${messageId}`);
  return messageId;
}

/**
 * 투표 생성 메시지 (작성자용)
 * @param {string} userId - 작성자 ID
 * @param {string} postId - 게시물 ID
 * @param {Object} postData - 게시물 데이터
 * @returns {Promise<string>} 생성된 메시지 ID
 */
async function createVoteCreatedMessage(userId, postId, postData) {
  const chatId = getAIChatId(userId);
  const messageId = uuidv4();
  const now = admin.firestore.Timestamp.now();
  
  console.log(`[AI 채팅] createVoteCreatedMessage 시작: userId=${userId}, chatId=${chatId}`);
  
  const messageData = {
    // 기본 메시지 정보
    message_id: messageId,
    sender_id: userId,
    receiver_id: AI_ASSISTANT_ID,
    content: '새로운 질문을 만들었어요! AI의 의견을 들어볼까요?',
    time_stamp: now,
    is_read: false,
    
    // 투표 메시지 정보
    message_type: 'vote_created',
    vote_post_id: postId,
    vote_title: postData.questionTitle || postData.question_title || '',
    vote_option_a_text: postData.optionA || postData.option_a || '',
    vote_option_b_text: postData.optionB || postData.option_b || '',
    vote_option_a_image: postData.imageUrlA || postData.image_url_a || null,
    vote_option_b_image: postData.imageUrlB || postData.image_url_b || null,
    
    // 멀티이미지 지원
    vote_option_a_images: postData.imageUrlsA || postData.image_urls_a || null,
    vote_option_b_images: postData.imageUrlsB || postData.image_urls_b || null,
    
    // 전체 설명
    vote_description: postData.description || '',
    
    // 카드 상태
    card_status: 'in_progress', // 작성자는 진행중 상태로 시작
    vote_status: 'active',
    vote_end_time: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 10 * 60 * 1000) // 10분 후
    )
  };
  
  // 채팅방이 없으면 생성
  const chatRef = admin.firestore().collection('chats').doc(chatId);
  const chatDoc = await chatRef.get();
  
  if (!chatDoc.exists) {
    await chatRef.set({
      user_a: AI_ASSISTANT_ID,
      user_b: userId,
      last_message_content: messageData.content,
      last_message_at: now,
      last_message_sent_by: AI_ASSISTANT_ID,
      users: [AI_ASSISTANT_ID, userId],
      participantIds: [AI_ASSISTANT_ID, userId],  // Flutter 호환성을 위해 추가
      chat_name: 'AI 피클',  // AI 채팅방 이름
      chat_type: 'ai_chat'  // 채팅 타입 명시
    });
  } else {
    // 마지막 메시지 업데이트
    await chatRef.update({
      last_message_content: messageData.content,
      last_message_at: now,
      last_message_sent_by: AI_ASSISTANT_ID
    });
  }
  
  // 메시지 생성
  await chatRef.collection('messages').doc(messageId).set(messageData);
  
  console.log(`[AI 채팅] 투표 생성 메시지 생성 완료:`);
  console.log(`  - userId=${userId}`);
  console.log(`  - messageId=${messageId}`);
  console.log(`  - sender_id=${messageData.sender_id}`);
  console.log(`  - receiver_id=${messageData.receiver_id}`);
  console.log(`  - chatId=${chatId}`);
  console.log(`  - message_type=${messageData.message_type}`);
  
  return messageId;
}

/**
 * 카드 상태 업데이트
 * @param {string} userId - 사용자 ID
 * @param {string} messageId - 메시지 ID
 * @param {string} newStatus - 새로운 상태
 * @param {Object} additionalData - 추가 데이터
 */
async function updateCardStatus(userId, messageId, newStatus, additionalData = {}) {
  const chatId = getAIChatId(userId);
  const messageRef = admin.firestore()
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .doc(messageId);
  
  const updateData = {
    card_status: newStatus,
    ...additionalData
  };
  
  await messageRef.update(updateData);
  
  console.log(`[AI 채팅] 카드 상태 업데이트: messageId=${messageId}, status=${newStatus}`);
}

/**
 * 투표 참여 시 상태 업데이트
 * @param {string} userId - 사용자 ID
 * @param {string} postId - 게시물 ID
 * @param {string} choice - 선택 (A/B)
 */
async function updateVoteParticipation(userId, postId, choice) {
  const chatId = getAIChatId(userId);
  
  // 해당 투표 메시지 찾기
  const messagesSnapshot = await admin.firestore()
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('vote_post_id', '==', postId)
    .where('message_type', '==', 'vote_request')
    .get();
  
  if (!messagesSnapshot.empty) {
    const messageDoc = messagesSnapshot.docs[0];
    await updateCardStatus(userId, messageDoc.id, 'in_progress', {
      user_voted: true,
      vote_choice: choice,
      vote_participated_at: admin.firestore.Timestamp.now()
    });
  }
}

/**
 * 투표 완료 메시지 생성
 * @param {string} userId - 대상 사용자 ID
 * @param {string} postId - 게시물 ID
 * @param {Object} voteResults - 투표 결과
 */
async function createVoteResultMessage(userId, postId, voteResults) {
  const chatId = getAIChatId(userId);
  
  // 기존 투표 메시지 상태 업데이트
  const messagesSnapshot = await admin.firestore()
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('vote_post_id', '==', postId)
    .where('message_type', 'in', ['vote_request', 'vote_created'])
    .get();
  
  console.log(`[AI 채팅] 투표 결과 업데이트: userId=${userId}, 메시지 수=${messagesSnapshot.size}`);
  
  const updatePromises = [];
  messagesSnapshot.forEach(doc => {
    const data = doc.data();
    let finalStatus;
    
    // 작성자 메시지는 투표 완료 시 항상 'completed'
    if (data.message_type === 'vote_created') {
      finalStatus = 'completed';
    } else {
      // 일반 투표 요청 메시지는 참여 여부에 따라 결정
      finalStatus = data.user_voted ? 'completed' : 'not_participated';
    }
    
    console.log(`[AI 채팅] 메시지 상태 업데이트: messageId=${doc.id}, type=${data.message_type}, finalStatus=${finalStatus}`);
    
    updatePromises.push(
      doc.ref.update({
        card_status: finalStatus,
        vote_status: 'completed',
        vote_completed_at: admin.firestore.Timestamp.now(),
        // 투표 결과 정보 추가
        vote_results_a: voteResults.displayVotesA || voteResults.votesA,
        vote_results_b: voteResults.displayVotesB || voteResults.votesB,
        vote_winner: voteResults.displayVotesA > voteResults.displayVotesB ? 'A' : 
                     voteResults.displayVotesB > voteResults.displayVotesA ? 'B' : 'draw',
        vote_percent_a: voteResults.percentA,
        vote_percent_b: voteResults.percentB
      })
    );
  });
  
  await Promise.all(updatePromises);
  
  console.log(`[AI 채팅] 투표 결과 메시지 업데이트 완료: userId=${userId}, postId=${postId}`);
}

module.exports = {
  getAIChatId,
  createVoteRequestMessage,
  createVoteCreatedMessage,
  updateCardStatus,
  updateVoteParticipation,
  createVoteResultMessage
};