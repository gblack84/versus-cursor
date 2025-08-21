/**
 * AI 피클 채팅 서비스
 * AI 어시스턴트와의 채팅 메시지 생성 및 관리
 * 
 * 로깅 가이드라인:
 * - 주요 이벤트만 로깅 (메시지 생성, 업데이트 완료)
 * - 개인정보는 마스킹하거나 제외
 * - 중복 로그 방지를 위해 간결하게 유지
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
    messageId: messageId,
    senderId: AI_ASSISTANT_ID,
    receiverId: userId,
    // content 필드 제거 - AI 채팅방은 투표 카드만 표시
    timeStamp: now,
    isRead: false,
    
    // 투표 메시지 정보
    messageType: 'voteRequest',
    votePostId: postId,
    voteTitle: postData.questionTitle || '',
    voteOptionAText: postData.optionA || '',
    voteOptionBText: postData.optionB || '',
    voteOptionAImage: postData.imageUrlA || null,
    voteOptionBImage: postData.imageUrlB || null,
    
    // 멀티이미지 지원
    voteOptionAImages: postData.imageUrlsA || null,
    voteOptionBImages: postData.imageUrlsB || null,
    
    // 스마트 레이아웃을 위한 aspectRatio 추가 - 올바른 필드명 사용
    voteAspectRatioA: postData.optionA?.aspectRatio || postData.aspectRatioA || null,
    voteAspectRatioB: postData.optionB?.aspectRatio || postData.aspectRatioB || null,
    
    // 전체 설명
    voteDescription: postData.description || '',
    
    // 카드 상태
    cardStatus: 'votingRequest', // 초기 상태: 대기중
    voteEndTime: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 10 * 60 * 1000) // 10분 후
    ),
    
    // 개별 사용자의 투표 정보를 저장할 필드 초기화
    userVotes: {},
    
    // 메타데이터에 실제 작성자 정보 포함
    metadata: {
      authorName: postData.displayName || '익명',
      authorPhotoUrl: postData.photoUrl || null,
      creatorId: postData.uid || null,
      postId: postId
    }
  };
  
  // 채팅방이 없으면 생성
  const chatRef = admin.firestore().collection('chats').doc(chatId);
  const chatDoc = await chatRef.get();
  
  // 채팅 목록 표시용 메시지 생성
  const listMessage = `[투표] ${postData.questionTitle || '새로운 투표'}`;
  
  if (!chatDoc.exists) {
    await chatRef.set({
      userA: AI_ASSISTANT_ID,
      userB: userId,
      lastMessageContent: listMessage,
      lastMessageAt: now,
      lastMessageSentBy: AI_ASSISTANT_ID,
      users: [AI_ASSISTANT_ID, userId],
      participantIds: [AI_ASSISTANT_ID, userId],  // Flutter 호환성을 위해 추가
      chatName: 'AI 피클',  // AI 채팅방 이름
      chatType: 'aiChat'  // 채팅 타입 명시
    });
  } else {
    // 마지막 메시지 업데이트
    await chatRef.update({
      lastMessageContent: listMessage,
      lastMessageAt: now,
      lastMessageSentBy: AI_ASSISTANT_ID
    });
  }
  
  // 메시지 생성
  await chatRef.collection('messages').doc(messageId).set(messageData);
  
  // 투표 요청 메시지 생성 완료
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
  
  // AI 채팅 메시지 생성 - 주요 이벤트만 로깅
  console.log('🤖 [AI_CHAT] 투표 생성 메시지', {
    timestamp: new Date().toISOString(),
    postId,
    messageId
  });
  
  const messageData = {
    // 기본 메시지 정보
    messageId: messageId,
    senderId: userId,
    receiverId: AI_ASSISTANT_ID,
    // content 필드 제거 - AI 채팅방은 투표 카드만 표시
    timeStamp: now,
    isRead: false,
    
    // 투표 메시지 정보
    messageType: 'voteCreated',
    votePostId: postId,
    voteTitle: postData.questionTitle || '',
    voteOptionAText: postData.optionA || '',
    voteOptionBText: postData.optionB || '',
    voteOptionAImage: postData.imageUrlA || null,
    voteOptionBImage: postData.imageUrlB || null,
    
    // 멀티이미지 지원
    voteOptionAImages: postData.imageUrlsA || null,
    voteOptionBImages: postData.imageUrlsB || null,
    
    // 스마트 레이아웃을 위한 aspectRatio 추가 - 올바른 필드명 사용
    voteAspectRatioA: postData.optionA?.aspectRatio || postData.aspectRatioA || null,
    voteAspectRatioB: postData.optionB?.aspectRatio || postData.aspectRatioB || null,
    
    // 전체 설명
    voteDescription: postData.description || '',
    
    // 카드 상태
    cardStatus: 'inProgress', // 작성자는 진행중 상태로 시작
    voteEndTime: admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 10 * 60 * 1000) // 10분 후
    ),
    
    // 개별 사용자의 투표 정보를 저장할 필드 초기화
    userVotes: {},
    
    // 메타데이터에 실제 작성자 정보 포함
    metadata: {
      authorName: postData.displayName || '익명',
      authorPhotoUrl: postData.photoUrl || null,
      creatorId: postData.uid || null,
      postId: postId
    }
  };
  
  // 채팅방이 없으면 생성
  const chatRef = admin.firestore().collection('chats').doc(chatId);
  const chatDoc = await chatRef.get();
  
  // 채팅 목록 표시용 메시지 생성
  const listMessage = `[투표] ${postData.questionTitle || '새로운 투표'}`;
  
  if (!chatDoc.exists) {
    await chatRef.set({
      userA: AI_ASSISTANT_ID,
      userB: userId,
      lastMessageContent: listMessage,
      lastMessageAt: now,
      lastMessageSentBy: AI_ASSISTANT_ID,
      users: [AI_ASSISTANT_ID, userId],
      participantIds: [AI_ASSISTANT_ID, userId],  // Flutter 호환성을 위해 추가
      chatName: 'AI 피클',  // AI 채팅방 이름
      chatType: 'aiChat'  // 채팅 타입 명시
    });
  } else {
    // 마지막 메시지 업데이트
    await chatRef.update({
      lastMessageContent: listMessage,
      lastMessageAt: now,
      lastMessageSentBy: AI_ASSISTANT_ID
    });
  }
  
  // 메시지 생성
  await chatRef.collection('messages').doc(messageId).set(messageData);
  
  console.log(`[AI 채팅] 투표 생성 메시지 완료: messageId=${messageId}`);
  
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
  
  // 카드 상태 업데이트 완료
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
    .where('messageType', '==', 'voteRequest')
    .get();
  
  if (!messagesSnapshot.empty) {
    const messageDoc = messagesSnapshot.docs[0];
    const messageData = messageDoc.data();
    
    // user_votes Map 업데이트
    const userVotes = messageData.user_votes || {};
    userVotes[userId] = {
      option: choice,
      voted_at: admin.firestore.Timestamp.now()
    };
    
    await updateCardStatus(userId, messageDoc.id, 'inProgress', {
      userVotes: userVotes,
      last_vote_update: admin.firestore.Timestamp.now()
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
  
  // 먼저 posts 컬렉션에서 실제 투표 여부 확인
  const postDoc = await admin.firestore().collection('posts').doc(postId).get();
  let userVoted = false;
  let userChoice = null;
  
  if (postDoc.exists) {
    const postData = postDoc.data();
    const votedUsersA = postData.votedUserIDsA || [];
    const votedUsersB = postData.votedUserIDsB || [];
    
    if (votedUsersA.includes(userId)) {
      userVoted = true;
      userChoice = 'A';
    } else if (votedUsersB.includes(userId)) {
      userVoted = true;
      userChoice = 'B';
    }
  }
  
  // 기존 투표 메시지 상태 업데이트
  const messagesSnapshot = await admin.firestore()
    .collection('chats')
    .doc(chatId)
    .collection('messages')
    .where('vote_post_id', '==', postId)
    .where('messageType', 'in', ['voteRequest', 'voteCreated'])
    .get();
  
  // 투표 결과 업데이트 시작
  
  const updatePromises = [];
  messagesSnapshot.forEach(doc => {
    const data = doc.data();
    let finalStatus;
    const updateData = {
      card_status: '',
      voteCompletedAt: admin.firestore.Timestamp.now(),
      // 투표 결과 정보 추가
      vote_results_a: voteResults.displayVotesA || voteResults.votesA,
      vote_results_b: voteResults.displayVotesB || voteResults.votesB,
      vote_winner: voteResults.displayVotesA > voteResults.displayVotesB ? 'A' : 
                   voteResults.displayVotesB > voteResults.displayVotesA ? 'B' : 'draw',
      vote_percent_a: voteResults.percentA,
      vote_percent_b: voteResults.percentB
    };
    
    // 실제로 투표했다면 user_votes에 추가
    if (userVoted && userChoice) {
      const currentUserVotes = data.user_votes || {};
      // 이미 있는 user_votes 유지하면서 현재 사용자 추가
      updateData.user_votes = {
        ...currentUserVotes,
        [userId]: {
          option: userChoice,
          voted_at: admin.firestore.Timestamp.now()
        }
      };
    }
    
    // 작성자 메시지는 투표 완료 시 항상 'completed'
    if (data.messageType === 'voteCreated') {
      finalStatus = 'completed';
    } else {
      // 일반 투표 요청 메시지는 실제 투표 여부에 따라 상태 결정
      finalStatus = userVoted ? 'completed' : 'notParticipated';
    }
    
    updateData.card_status = finalStatus;
    
    updatePromises.push(doc.ref.update(updateData));
  });
  
  await Promise.all(updatePromises);
  
  console.log(`[AI 채팅] 투표 결과 업데이트 완료: postId=${postId}`);
}

module.exports = {
  getAIChatId,
  createVoteRequestMessage,
  createVoteCreatedMessage,
  updateCardStatus,
  updateVoteParticipation,
  createVoteResultMessage
};