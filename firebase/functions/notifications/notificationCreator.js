const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');
const { createVoteRequestMessage } = require('../services/aiChatService');

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
        
        
    default:
      return '';
  }
}

// 알림 생성 함수
async function createNotificationsForUsers(users, postId, postData) {
  // 알림 생성 - 주요 정보만 로깅
  console.log('🔔 [NOTIFICATION] 알림 생성 시작', {
    timestamp: new Date().toISOString(),
    postId,
    userCount: users.length,
    targetType: postData.targetAudience?.type
  });
  
  if (users.length === 0) {
    console.log('[알림 생성] ⚠️ 알림을 보낼 사용자가 없습니다');
    return;
  }
  
  const batch = admin.firestore().batch();
  const notificationsRef = admin.firestore().collection('notifications');
  const now = admin.firestore.Timestamp.now();
  const expiryTime = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 15 * 60 * 1000) // 15분 후 만료
  );
  
  // 만료 시간은 고정값이므로 로깅 제거
  
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
          // optionA/optionB가 Map 구조인지 확인하고 처리
          optionA: typeof postData.optionA === 'object' && postData.optionA !== null 
            ? (postData.optionA.title || '') 
            : (postData.optionA || postData.option_a || ''),
          optionB: typeof postData.optionB === 'object' && postData.optionB !== null 
            ? (postData.optionB.title || '') 
            : (postData.optionB || postData.option_b || ''),
          // 이미지 URL 처리 (멀티이미지 우선)
          imageUrlA: postData.optionA?.mediaUrls?.[0] || postData.imageUrlA || postData.image_url_a || null,
          imageUrlB: postData.optionB?.mediaUrls?.[0] || postData.imageUrlB || postData.image_url_b || null,
          // 멀티이미지 지원 추가
          imageUrlsA: postData.optionA?.mediaUrls || postData.imageUrlsA || postData.image_urls_a || null,
          imageUrlsB: postData.optionB?.mediaUrls || postData.imageUrlsB || postData.image_urls_b || null,
          description: postData.description || null,
          authorName: postData.authorName || postData.author_name || '익명',
          category: postData.category || null,
          // 스마트 레이아웃을 위한 aspectRatio 및 layoutType 추가
          aspectRatioA: postData.optionA?.aspectRatio || null,
          aspectRatioB: postData.optionB?.aspectRatio || null,
          layoutType: postData.layoutType || null,
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
    
  });
  
  // 배치 커밋 (최대 500개씩)
  if (successCount > 0) {
    try {
      await batch.commit();
      console.log(`[알림 생성] ✅ ${successCount}개의 알림 생성 완료`);
      
      // 투표 통계 업데이트
      await admin.firestore()
        .collection('posts')
        .doc(postId)
        .update({
          notificationsSent: successCount,
          notificationsSentAt: now,
        });
      
      // AI 채팅 메시지 생성 (모든 타겟 타입에 대해)
      const creatorId = postData.uid || postData.userid;
      
      // 각 대상 사용자에 대해 AI 채팅 메시지 생성 (작성자 제외)
      const chatPromises = users
        .filter(user => {
          const shouldExclude = user.id === creatorId || user.id === postData.uid || user.id === postData.userid;
          return !shouldExclude;
        })  // 작성자는 제외
        .map(async (user) => {
        try {
          // optionA/optionB가 Map 구조인지 확인하고 처리
          let optionATitle = '';
          let optionBTitle = '';
          let imageUrlsA = [];
          let imageUrlsB = [];
          
          // optionA 처리
          if (typeof postData.optionA === 'object' && postData.optionA !== null) {
            optionATitle = postData.optionA.title || '';
            imageUrlsA = postData.optionA.mediaUrls || [];
          } else {
            optionATitle = postData.optionA || postData.option_a || '';
          }
          
          // optionB 처리
          if (typeof postData.optionB === 'object' && postData.optionB !== null) {
            optionBTitle = postData.optionB.title || '';
            imageUrlsB = postData.optionB.mediaUrls || [];
          } else {
            optionBTitle = postData.optionB || postData.option_b || '';
          }
          
          await createVoteRequestMessage(user.id, postId, {
            ...postData,
            authorName: postData.authorName || postData.author_name || '익명',
            questionTitle: postData.question_title || postData.questionTitle,
            optionA: optionATitle,
            optionB: optionBTitle,
            imageUrlA: imageUrlsA.length > 0 ? imageUrlsA[0] : (postData.image_url_a || postData.imageUrlA),
            imageUrlB: imageUrlsB.length > 0 ? imageUrlsB[0] : (postData.image_url_b || postData.imageUrlB),
            imageUrlsA: imageUrlsA.length > 0 ? imageUrlsA : (postData.image_urls_a || postData.imageUrlsA || []),
            imageUrlsB: imageUrlsB.length > 0 ? imageUrlsB : (postData.image_urls_b || postData.imageUrlB || []),
            description: postData.description || '',
            // 스마트 레이아웃 정보 전달
            aspectRatioA: postData.optionA?.aspectRatio || null,
            aspectRatioB: postData.optionB?.aspectRatio || null,
            layoutType: postData.layoutType || null
          });
        } catch (error) {
          console.error(`[알림 생성] AI 채팅 메시지 생성 실패:`, error);
        }
      });
      
      await Promise.all(chatPromises);
      console.log(`[알림 생성] ✅ AI 채팅 메시지 생성 완료: ${chatPromises.length}개`);
      
    } catch (error) {
      console.error('[알림 생성] ❌ 배치 커밋 중 오류 발생:', error);
      throw error;
    }
  }
  // 알림 생성 프로세스 종료
}


module.exports = { createNotificationsForUsers };