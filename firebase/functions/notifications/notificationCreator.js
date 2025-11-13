const admin = require('firebase-admin');
const { v4: uuidv4 } = require('uuid');
const { createVoteRequestMessage } = require('../services/aiChatService');

/**
 * FCM 메시지 페이로드 생성
 * @param {Object} notificationData - 알림 데이터
 * @param {Object} postData - 게시물 데이터
 * @returns {Object} FCM 메시지 페이로드
 */
function buildFCMPayload(notificationData, postData) {
  // FCM 메시지 구조: data + notification
  // data: Flutter NotificationQueueService에서 파싱할 데이터
  // notification: 시스템 트레이 표시용

  const parsedContent = JSON.parse(notificationData.content);

  return {
    // data 페이로드: Flutter에서 domain.VoteNotification으로 변환
    data: {
      // 기본 식별 정보
      id: notificationData.notificationId,
      type: 'vote_notification',  // NotificationQueueService._convertFCMMessageToNotification 참조
      userId: notificationData.userId,

      // 투표 관련 정보
      postId: notificationData.sourceId,
      postTitle: parsedContent.postData?.questionTitle || '',
      postContent: parsedContent.message || '',
      postDescription: parsedContent.postData?.description || '',

      // 투표 옵션
      optionATitle: parsedContent.postData?.optionA || '',
      optionBTitle: parsedContent.postData?.optionB || '',

      // 이미지 URL (단일)
      imageUrlA: parsedContent.postData?.imageUrlA || '',
      imageUrlB: parsedContent.postData?.imageUrlB || '',

      // 멀티 이미지 URL (JSON 배열 문자열)
      imageUrlsA: JSON.stringify(parsedContent.postData?.imageUrlsA || []),
      imageUrlsB: JSON.stringify(parsedContent.postData?.imageUrlsB || []),

      // 레이아웃 정보
      aspectRatioA: String(parsedContent.postData?.aspectRatioA || ''),
      aspectRatioB: String(parsedContent.postData?.aspectRatioB || ''),
      layoutType: parsedContent.postData?.layoutType || '',

      // 작성자 정보
      senderName: parsedContent.postData?.authorName || '익명',
      authorPhotoUrl: parsedContent.postData?.authorPhotoUrl || '',
      creatorId: parsedContent.postData?.creatorId || '',

      // 타임스탬프 (ISO 8601 문자열)
      createdAt: new Date().toISOString(),

      // 투표 시간 정보
      voteStartTime: postData.voteStartTime ? postData.voteStartTime.toISOString() : new Date().toISOString(),
      voteEndTime: postData.voteEndTime ? postData.voteEndTime.toISOString() : new Date(Date.now() + 10 * 60 * 1000).toISOString(),
    },

    // notification 페이로드: 시스템 트레이 표시
    notification: {
      title: parsedContent.title || '새로운 투표가 도착했어요!',
      body: `${parsedContent.postData?.questionTitle || '투표에 참여해주세요'}`,
    },

    // Android 특정 설정
    android: {
      priority: 'high',
      notification: {
        sound: 'default',
        channelId: 'voting_notifications',  // Flutter에서 정의한 채널 ID
      },
    },

    // iOS 특정 설정
    apns: {
      payload: {
        aps: {
          sound: 'default',
          badge: 1,
        },
      },
    },
  };
}

/**
 * FCM 메시지 전송 (사용자별)
 * @param {string} fcmToken - 사용자 FCM 토큰
 * @param {Object} notificationData - 알림 데이터
 * @param {Object} postData - 게시물 데이터
 * @returns {Promise<boolean>} 전송 성공 여부
 */
async function sendFCMNotification(fcmToken, notificationData, postData) {
  if (!fcmToken) {
    console.log('[FCM] 토큰이 없어 FCM 전송 생략');
    return false;
  }

  try {
    const message = {
      token: fcmToken,
      ...buildFCMPayload(notificationData, postData),
    };

    const response = await admin.messaging().send(message);
    console.log(`[FCM] ✅ 메시지 전송 성공: ${response}`);
    return true;

  } catch (error) {
    // FCM 토큰 무효화 에러 처리
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      console.log(`[FCM] ⚠️ 토큰 무효화됨, 제거 필요: ${fcmToken.substring(0, 20)}...`);
      // 토큰 제거는 상위 함수에서 처리
      return false;
    }

    console.error('[FCM] ❌ 메시지 전송 실패:', error);
    return false;
  }
}

/**
 * FCM 메시지 전송 (재시도 로직 포함)
 * Exponential backoff: 1s → 2s → 4s (최대 3회 시도)
 *
 * @param {string} fcmToken - 사용자 FCM 토큰
 * @param {Object} notificationData - 알림 데이터
 * @param {Object} postData - 게시물 데이터
 * @param {number} maxRetries - 최대 재시도 횟수 (기본값: 3)
 * @returns {Promise<Object>} { success: boolean, attempts: number, error?: string }
 */
async function sendFCMWithRetry(fcmToken, notificationData, postData, maxRetries = 3) {
  const delays = [1000, 2000, 4000]; // 1s, 2s, 4s

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const success = await sendFCMNotification(fcmToken, notificationData, postData);

      if (success) {
        if (attempt > 1) {
          console.log(`[FCM Retry] ✅ ${attempt}번째 시도에서 성공 (notificationId: ${notificationData.notificationId})`);
        }
        return { success: true, attempts: attempt };
      }

      // 토큰 무효화된 경우 재시도 중단
      if (!success) {
        console.log(`[FCM Retry] ⚠️ 토큰 무효화로 재시도 중단 (attempt: ${attempt})`);
        return { success: false, attempts: attempt, error: 'invalid_token' };
      }

    } catch (error) {
      console.error(`[FCM Retry] ❌ ${attempt}번째 시도 실패:`, error.message);

      // 마지막 시도가 아니면 exponential backoff 대기
      if (attempt < maxRetries) {
        const delay = delays[attempt - 1] || 4000;
        console.log(`[FCM Retry] ⏳ ${delay}ms 후 재시도... (${attempt}/${maxRetries})`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }

  // 모든 재시도 실패
  console.error(`[FCM Retry] ❌ 최종 실패 (${maxRetries}회 시도) - notificationId: ${notificationData.notificationId}`);
  return { success: false, attempts: maxRetries, error: 'max_retries_exceeded' };
}

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

  // FCM 전송 통계
  const fcmStats = {
    sent: 0,
    failed: 0,
    noToken: 0,
  };

  // FCM 전송을 위한 데이터 저장
  const fcmSendTasks = [];
  const invalidTokenUsers = [];

  users.forEach((user, index) => {
    // 각 사용자별 알림 문서 생성
    const notificationRef = notificationsRef.doc();

    const notificationData = {
      // 기본 필드
      notificationId: notificationRef.id,
      userId: user.id,
      type: 'votingRequest',
      sourceId: postId,

      // 콘텐츠 - Flutter 스키마에 맞춰 JSON 문자열로 저장
      content: JSON.stringify({
        title: '새로운 투표가 도착했어요!',
        message: generateTargetReason(postData.targetAudience, user),
        postData: {
          questionTitle: postData.questionTitle || postData.questionTitle || '',
          // optionA/optionB가 Map 구조인지 확인하고 처리
          optionA: typeof postData.optionA === 'object' && postData.optionA !== null
            ? (postData.optionA.title || '')
            : (postData.optionA || postData.optionA || ''),
          optionB: typeof postData.optionB === 'object' && postData.optionB !== null
            ? (postData.optionB.title || '')
            : (postData.optionB || postData.optionB || ''),
          // 이미지 URL 처리 (멀티이미지 우선)
          imageUrlA: postData.optionA?.mediaUrls?.[0] || postData.imageUrlA || postData.imageUrlA || null,
          imageUrlB: postData.optionB?.mediaUrls?.[0] || postData.imageUrlB || postData.imageUrlB || null,
          // 멀티이미지 지원 추가
          imageUrlsA: postData.optionA?.mediaUrls || postData.imageUrlsA || postData.imageUrlsA || null,
          imageUrlsB: postData.optionB?.mediaUrls || postData.imageUrlsB || postData.imageUrlsB || null,
          description: postData.description || null,
          authorName: postData.displayName || postData.displayName || '익명',
          authorPhotoUrl: postData.photoUrl || postData.photoUrl || null,
          creatorId: postData.uid || null,
          category: postData.category || null,
          // 스마트 레이아웃을 위한 aspectRatio 및 layoutType 추가
          aspectRatioA: postData.optionA?.aspectRatio || null,
          aspectRatioB: postData.optionB?.aspectRatio || null,
          layoutType: postData.layoutType || null,
        }
      }),

      // 메타데이터
      createdAt: now,
      read: false,
      targetAudience: [postData.targetAudience.type], // Flutter 스키마에 맞춰 배열로 저장
      expiryTime: expiryTime,
      interactionType: 'vote',

      // targetReason 필드 제거 (Flutter 스키마에 없음)
    };

    batch.set(notificationRef, notificationData);
    successCount++;
    notificationIds.push(notificationRef.id);

    // FCM 전송 준비 (사용자 FCM 토큰 필요)
    fcmSendTasks.push({
      userId: user.id,
      notificationData: notificationData,
    });

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

      // ========================================
      // FCM 푸시 알림 전송 (병렬 처리)
      // ========================================
      console.log(`[FCM] 📱 FCM 전송 시작: ${fcmSendTasks.length}명`);

      // 1. 사용자 FCM 토큰 조회 (병렬)
      const userTokenPromises = fcmSendTasks.map(async (task) => {
        try {
          const userDoc = await admin.firestore()
            .collection('users')
            .doc(task.userId)
            .get();

          const fcmToken = userDoc.data()?.fcmToken;
          return {
            ...task,
            fcmToken: fcmToken || null,
          };
        } catch (error) {
          console.error(`[FCM] 토큰 조회 실패 (userId: ${task.userId}):`, error);
          return {
            ...task,
            fcmToken: null,
          };
        }
      });

      const tasksWithTokens = await Promise.all(userTokenPromises);

      // 2. FCM 메시지 전송 (재시도 로직 포함, 병렬)
      const fcmPromises = tasksWithTokens.map(async (task) => {
        if (!task.fcmToken) {
          fcmStats.noToken++;
          return { success: false, userId: task.userId, reason: 'no_token' };
        }

        // sendFCMWithRetry() 호출 (최대 3회 재시도)
        const result = await sendFCMWithRetry(
          task.fcmToken,
          task.notificationData,
          postData,
          3 // maxRetries
        );

        if (result.success) {
          fcmStats.sent++;
          // Firestore 알림에 fcmStatus 기록
          try {
            await admin.firestore()
              .collection('notifications')
              .doc(task.notificationData.notificationId)
              .update({
                fcmStatus: 'sent',
                fcmAttempts: result.attempts,
                fcmSentAt: admin.firestore.Timestamp.now(),
              });
          } catch (error) {
            console.error(`[FCM] fcmStatus 업데이트 실패 (notificationId: ${task.notificationData.notificationId}):`, error);
          }
          return { success: true, userId: task.userId, attempts: result.attempts };
        } else {
          fcmStats.failed++;

          // 토큰 무효화된 경우 기록
          if (result.error === 'invalid_token') {
            invalidTokenUsers.push({
              userId: task.userId,
              fcmToken: task.fcmToken,
            });
          }

          // Firestore 알림에 실패 상태 기록
          try {
            await admin.firestore()
              .collection('notifications')
              .doc(task.notificationData.notificationId)
              .update({
                fcmStatus: 'failed',
                fcmAttempts: result.attempts,
                fcmError: result.error || 'unknown',
                fcmFailedAt: admin.firestore.Timestamp.now(),
              });
          } catch (error) {
            console.error(`[FCM] fcmStatus 업데이트 실패 (notificationId: ${task.notificationData.notificationId}):`, error);
          }

          return {
            success: false,
            userId: task.userId,
            reason: result.error || 'send_failed',
            attempts: result.attempts,
          };
        }
      });

      await Promise.all(fcmPromises);

      // 3. 무효화된 FCM 토큰 제거 (병렬)
      if (invalidTokenUsers.length > 0) {
        console.log(`[FCM] 🗑️ 무효화된 토큰 ${invalidTokenUsers.length}개 제거 중...`);

        const removeTokenPromises = invalidTokenUsers.map(async ({ userId }) => {
          try {
            await admin.firestore()
              .collection('users')
              .doc(userId)
              .update({ fcmToken: admin.firestore.FieldValue.delete() });
            console.log(`[FCM] ✅ 토큰 제거 완료: ${userId}`);
          } catch (error) {
            console.error(`[FCM] ❌ 토큰 제거 실패 (userId: ${userId}):`, error);
          }
        });

        await Promise.all(removeTokenPromises);
      }

      // 4. FCM 전송 통계 로깅
      console.log('[FCM] 📊 전송 통계:', {
        total: fcmSendTasks.length,
        sent: fcmStats.sent,
        failed: fcmStats.failed,
        noToken: fcmStats.noToken,
        tokensRemoved: invalidTokenUsers.length,
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
            authorName: postData.displayName || postData.display_name || '익명',
            authorPhotoUrl: postData.photoUrl || postData.photo_url || null,
            creatorId: creatorId,
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