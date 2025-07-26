const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');

// 타겟 이유 메시지 생성
function generateTargetReason(targetAudience, user) {
  const { type, interests, ageGroup, gender } = targetAudience;
  
  switch (type) {
    case 'quick':
      return 'AI가 당신에게 추천하는 투표입니다';
      
    case 'public':
      return '모든 사용자에게 공개된 투표입니다';
      
    case 'custom':
      const reasons = [];
      
      if (interests && interests.length > 0) {
        reasons.push(`${interests.join(', ')}에 관심있으신 분께`);
      }
      
      if (ageGroup && ageGroup !== '전체') {
        reasons.push(`${ageGroup} 분들을 위한`);
      }
      
      if (gender && gender !== 'all') {
        const genderText = gender === 'male' ? '남성' : '여성';
        reasons.push(`${genderText} 분들을 위한`);
      }
      
      return reasons.length > 0 
        ? reasons.join(' ') + ' 투표입니다'
        : '맞춤 추천 투표입니다';
        
    case 'test':
      const testIndex = user?.testIndex || 1;
      return `🧪 테스트 알림 #${testIndex} - UI/플로우 확인용`;
        
    default:
      return '';
  }
}

// 알림 생성 함수
async function createNotificationsForUsers(users, postId, postData) {
  console.log('[알림 생성] ========== 알림 생성 시작 ==========');
  console.log(`[알림 생성] 대상 사용자 수: ${users.length}명`);
  console.log(`[알림 생성] 게시물 ID: ${postId}`);
  console.log(`[알림 생성] 타겟 타입: ${postData.targetAudience?.type || '알 수 없음'}`);
  
  if (users.length === 0) {
    console.log('[알림 생성] ⚠️ 알림을 보낼 사용자가 없습니다');
    return;
  }
  
  const batch = admin.firestore().batch();
  const notificationsRef = admin.firestore().collection('notifications_record');
  const now = admin.firestore.Timestamp.now();
  const expiryTime = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 15 * 60 * 1000) // 15분 후 만료
  );
  
  console.log('[알림 생성] 만료 시간:', new Date(Date.now() + 15 * 60 * 1000).toISOString());
  
  let successCount = 0;
  const notificationIds = [];
  
  users.forEach((user, index) => {
    // 각 사용자별 알림 문서 생성
    const notificationRef = notificationsRef.doc();
    
    const notificationData = {
      // 기본 필드
      notification_id: notificationRef.id,
      user_id: user.id,
      type: 'voting_request',
      source_id: postId,
      
      // 콘텐츠 - Flutter 스키마에 맞춰 JSON 문자열로 저장
      content: JSON.stringify({
        title: '새로운 투표가 도착했어요!',
        message: generateTargetReason(postData.targetAudience, user),
        postData: {
          questionTitle: postData.questionTitle || postData.question_title || '',
          optionA: postData.optionA || postData.option_a || '',
          optionB: postData.optionB || postData.option_b || '',
          imageUrlA: postData.imageUrlA || postData.image_url_a || null,
          imageUrlB: postData.imageUrlB || postData.image_url_b || null,
          // 멀티이미지 지원 추가
          imageUrlsA: postData.imageUrlsA || postData.image_urls_a || null,
          imageUrlsB: postData.imageUrlsB || postData.image_urls_b || null,
          descriptionA: postData.descriptionA || postData.description_a || null,
          descriptionB: postData.descriptionB || postData.description_b || null,
          authorName: postData.authorName || postData.author_name || '익명',
          category: postData.category || null,
        }
      }),
      
      // 메타데이터
      created_at: now,
      read: false,
      target_audience: [postData.targetAudience.type], // Flutter 스키마에 맞춰 배열로 저장
      expiry_time: expiryTime,
      interaction_type: 'vote',
      
      // targetReason 필드 제거 (Flutter 스키마에 없음)
    };
    
    batch.set(notificationRef, notificationData);
    successCount++;
    notificationIds.push(notificationRef.id);
    
    // 테스트 모드일 경우 각 알림 상세 로깅
    if (postData.targetAudience?.type === 'test') {
      console.log(`[알림 생성] 테스트 알림 #${user.testIndex || index + 1}:`);
      console.log(`  - 알림 ID: ${notificationRef.id}`);
      console.log(`  - 사용자: ${user.displayName} (${user.id})`);
      console.log(`  - 메시지: ${notificationData.targetReason}`);
    }
  });
  
  // 배치 커밋 (최대 500개씩)
  if (successCount > 0) {
    try {
      console.log('[알림 생성] Firestore 배치 커밋 시작...');
      await batch.commit();
      console.log(`[알림 생성] ✅ ${successCount}개의 알림이 성공적으로 생성되었습니다`);
      
      // 생성된 알림 ID 로깅 (처음 5개만)
      console.log('[알림 생성] 생성된 알림 ID (처음 5개):');
      notificationIds.slice(0, 5).forEach((id, idx) => {
        console.log(`  ${idx + 1}. ${id}`);
      });
      
      // 투표 통계 업데이트
      console.log('[알림 생성] 게시물 통계 업데이트 중...');
      await admin.firestore()
        .collection('posts_record')
        .doc(postId)
        .update({
          notificationsSent: successCount,
          notificationsSentAt: now,
        });
      console.log('[알림 생성] ✅ 게시물 통계 업데이트 완료');
      
      // 글로벌 투표 추적 채팅방에 상태 업데이트 메시지 추가
      const voteChatId = 'vote_tracking_global';
      const voteChatRef = admin.firestore()
        .collection('chats_record')
        .doc(voteChatId);
        
      const voteChatDoc = await voteChatRef.get();
      if (voteChatDoc.exists) {
        console.log('[알림 생성] 글로벌 투표 추적 채팅방에 상태 업데이트 중...');
        
        const statusMessage = {
          message_id: `${Date.now()}_system_status`,
          sender_id: 'system',
          content: `${successCount}명에게 투표 요청을 보냈습니다.\n\n타겟 타입: ${postData.targetAudience?.type || '알 수 없음'}`,
          time_stamp: admin.firestore.FieldValue.serverTimestamp(),
          message_type: 'vote_status_update',
          vote_post_id: postId,
          target_count: successCount,
        };
        
        await voteChatRef.collection('messages').add(statusMessage);
        
        // 테스트 모드가 아닐 때만 채팅방 마지막 메시지 업데이트
        // (테스트 모드에서는 Flutter 앱에서 이미 "Pikle AI가 투표 요청을 보냈습니다"로 설정함)
        if (postData.targetAudience?.type !== 'test') {
          await voteChatRef.update({
            last_message_content: `시스템: ${successCount}명에게 투표 요청을 보냈습니다`,
            last_message_at: admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log('[알림 생성] ✅ 글로벌 투표 추적 채팅방 업데이트 완료');
        } else {
          console.log('[알림 생성] 테스트 모드 - 채팅방 업데이트 건너뛰기 (Flutter에서 이미 처리됨)');
        }
      }
      
      // 채팅 메시지 생성 (타겟 타입이 custom, test일 때만)
      if (['custom', 'test'].includes(postData.targetAudience?.type)) {
        console.log('[알림 생성] 채팅 메시지 생성 시작...');
        const senderId = postData.userid || postData.uid || postData.creatorInfo?.uid;
        
        if (senderId) {
          // 각 대상 사용자와의 채팅 메시지 생성
          const chatPromises = users.map(async (user) => {
            try {
              await createVoteRequestChatMessage(senderId, user.id, postId, postData);
              console.log(`[알림 생성] 채팅 메시지 생성 완료: ${user.displayName}`);
            } catch (error) {
              console.error(`[알림 생성] 채팅 메시지 생성 실패 (${user.displayName}):`, error);
            }
          });
          
          await Promise.all(chatPromises);
          console.log('[알림 생성] ✅ 모든 채팅 메시지 생성 완료');
        } else {
          console.log('[알림 생성] ⚠️ 발신자 ID를 찾을 수 없어 채팅 메시지를 생성하지 않음');
        }
      }
      
    } catch (error) {
      console.error('[알림 생성] ❌ 배치 커밋 중 오류 발생:', error);
      throw error;
    }
  }
  
  console.log('[알림 생성] ========== 알림 생성 종료 ==========');
}

// 투표 요청 채팅 메시지 생성 함수 (글로벌 채팅방으로 통합)
async function createVoteRequestChatMessage(senderId, recipientId, postId, postData) {
  try {
    // 글로벌 투표 추적 채팅방 사용
    const voteChatId = 'vote_tracking_global';
    const chatRef = admin.firestore()
      .collection('chats_record')
      .doc(voteChatId);
      
    const chatDoc = await chatRef.get();
    
    if (!chatDoc.exists) {
      console.log('[채팅 메시지 생성] 글로벌 투표 추적 채팅방이 없음 - 생성 중...');
      // 글로벌 채팅방이 없으면 생성
      await chatRef.set({
        participantlds: [],
        lastMessageContent: '투표 추적 채팅방입니다',
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
        created_at: admin.firestore.FieldValue.serverTimestamp(),
        chat_name: '투표 피드',
        chat_type: 'vote_tracking',
        is_global: true,
      });
    }
    
    // 수신자를 참여자에 추가
    await chatRef.update({
      participantlds: admin.firestore.FieldValue.arrayUnion(recipientId),
    });
    
    // 수신자 정보 가져오기
    let recipientName = '알 수 없음';
    try {
      const recipientDoc = await admin.firestore()
        .collection('users_record')
        .doc(recipientId)
        .get();
      
      if (recipientDoc.exists) {
        recipientName = recipientDoc.data().display_name || '익명';
      }
    } catch (error) {
      console.log(`[채팅 메시지 생성] 수신자 정보 가져오기 실패: ${error.message}`);
    }
    
    // 투표 요청 수신 메시지 생성 (수신자가 받았다는 메시지)
    const messageId = uuidv4();
    
    await chatRef.collection('messages').add({
      message_id: messageId,
      sender_id: recipientId, // 수신자가 보낸 것처럼 표시
      content: `${recipientName}님이 투표 요청을 받았습니다.\n\n제목: ${postData.questionTitle || postData.question_title || ''}`,
      time_stamp: admin.firestore.FieldValue.serverTimestamp(),
      is_read: false,
      message_type: 'vote_request_received',
      vote_post_id: postId,
      vote_title: postData.questionTitle || postData.question_title || '',
      vote_description: postData.content || '',
      vote_option_a_text: postData.optionA?.text || postData.optionA?.title || '',
      vote_option_b_text: postData.optionB?.text || postData.optionB?.title || '',
      vote_option_a_image: postData.optionA?.imageUrl || postData.optionA?.image_url || '',
      vote_option_b_image: postData.optionB?.imageUrl || postData.optionB?.image_url || '',
      vote_status: 'pending',
      creator_id: senderId,
      recipient_id: recipientId,
      recipient_name: recipientName,
    });
    
    // 테스트 모드가 아닐 때만 채팅방 마지막 메시지 업데이트
    // (테스트 모드에서는 Flutter 앱에서 이미 "Pikle AI가 투표 요청을 보냈습니다"로 설정함)
    if (postData.targetAudience?.type !== 'test') {
      await chatRef.update({
        lastMessageContent: `${recipientName}님이 투표 요청을 받았습니다`,
        lastMessageAt: admin.firestore.FieldValue.serverTimestamp(),
      });
      console.log(`[채팅 메시지 생성] 글로벌 채팅방에 투표 수신 메시지 추가 완료: ${recipientName}`);
    } else {
      console.log(`[채팅 메시지 생성] 테스트 모드 - 채팅방 업데이트 건너뛰기 (Flutter에서 Pikle AI 메시지로 이미 처리됨)`);
    }
    
  } catch (error) {
    console.error('[채팅 메시지 생성] 오류:', error);
    throw error;
  }
}

module.exports = { createNotificationsForUsers };