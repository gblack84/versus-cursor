const admin = require('firebase-admin');

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
  if (users.length === 0) {
    console.log('알림을 보낼 사용자가 없습니다');
    return;
  }
  
  const batch = admin.firestore().batch();
  const notificationsRef = admin.firestore().collection('notifications_record');
  const now = admin.firestore.Timestamp.now();
  const expiryTime = admin.firestore.Timestamp.fromDate(
    new Date(Date.now() + 15 * 60 * 1000) // 15분 후 만료
  );
  
  let successCount = 0;
  
  users.forEach(user => {
    // 각 사용자별 알림 문서 생성
    const notificationRef = notificationsRef.doc();
    
    const notificationData = {
      // 기본 필드
      notification_id: notificationRef.id,
      user_id: user.id,
      type: 'voting_request',
      source_id: postId,
      
      // 콘텐츠
      content: {
        title: '새로운 투표가 도착했어요!',
        message: generateTargetReason(postData.targetAudience, user),
        postData: {
          questionTitle: postData.questionTitle || postData.question_title || '',
          optionA: postData.optionA || postData.option_a || '',
          optionB: postData.optionB || postData.option_b || '',
          imageUrlA: postData.imageUrlA || postData.image_url_a || null,
          imageUrlB: postData.imageUrlB || postData.image_url_b || null,
          authorName: postData.authorName || postData.author_name || '익명',
          category: postData.category || null,
        }
      },
      
      // 메타데이터
      created_at: now,
      read: false,
      target_audience: postData.targetAudience.type,
      expiry_time: expiryTime,
      interaction_type: 'vote',
      
      // 추가 정보
      targetReason: generateTargetReason(postData.targetAudience, user),
    };
    
    batch.set(notificationRef, notificationData);
    successCount++;
  });
  
  // 배치 커밋 (최대 500개씩)
  if (successCount > 0) {
    await batch.commit();
    console.log(`${successCount}개의 알림이 생성되었습니다`);
    
    // 투표 통계 업데이트
    await admin.firestore()
      .collection('posts_record')
      .doc(postId)
      .update({
        notificationsSent: successCount,
        notificationsSentAt: now,
      });
  }
}

module.exports = { createNotificationsForUsers };