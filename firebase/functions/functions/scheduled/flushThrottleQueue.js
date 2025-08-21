/**
 * 스로틀 큐 처리 (매분 실행)
 * 10분 타이머가 만료된 투표들을 자동 완료 처리
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { processVoteCompletion, calculateDisplayVotes } = require("../../services/voteManagement");
const { createVoteResultMessage } = require("../../services/aiChatService");
const { createLogger } = require("../../config/logger");
// throttleQueue\ub294 onPostVoteUpdate\uc5d0\uc11c export\ub418\uc5b4\uc57c \ud568\n// \uc784\uc2dc\ub85c \ud604\uc7ac\ub294 \uac01 \ud568\uc218\uac00 \ub3c5\ub9bd\uc801\uc73c\ub85c \uc791\ub3d9\ud558\ub3c4\ub85d \uc124\uc815\nconst throttleQueue = new Map();

// Timestamp 파싱 헬퍼 함수
function parseTimestamp(value) {
  if (!value) return null;
  
  // 이미 Timestamp 객체인 경우
  if (value.toDate && typeof value.toDate === 'function') {
    return value;
  }
  
  // {_seconds, _nanoseconds} 형식인 경우
  if (value._seconds !== undefined) {
    return new admin.firestore.Timestamp(value._seconds, value._nanoseconds || 0);
  }
  
  // 다른 형식 시도
  if (value.seconds !== undefined) {
    return new admin.firestore.Timestamp(value.seconds, value.nanoseconds || 0);
  }
  
  // Date 객체인 경우
  if (value instanceof Date) {
    return admin.firestore.Timestamp.fromDate(value);
  }
  
  // 문자열인 경우
  if (typeof value === 'string') {
    return admin.firestore.Timestamp.fromDate(new Date(value));
  }
  
  return null;
}

exports.flushThrottleQueue = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540, // 9분
    memory: '512MB'
  })
  .pubsub
  .schedule('every 1 minutes')
  .onRun(async (context) => {
    const logger = createLogger('flushThrottleQueue');
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    
    logger.info('========== Scheduled Function 실행 시작 ==========');
    logger.debug(`현재 시간: ${now.toDate().toISOString()}`);
    
    try {
      // 10분 타이머가 만료된 투표 찾기
      // 먼저 모든 active 투표를 가져온 후 JavaScript에서 필터링
      const activeVotesSnapshot = await db.collection('posts')
        .where('voteCompleted', '==', false)
        .limit(100) // 더 많은 문서 가져오기
        .get();
      
      if (activeVotesSnapshot.empty) {
        logger.debug('Active 상태인 투표 없음');
        logger.info('========== Scheduled Function 종료 ==========');
        return null;
      }
      
      logger.info(`${activeVotesSnapshot.size}개의 active 투표 확인 중...`);
      
      // JavaScript에서 만료된 투표 필터링
      const expiredVotes = [];
      activeVotesSnapshot.forEach(doc => {
        const data = doc.data();
        const voteEndTime = parseTimestamp(data.voteEndTime);
        
        if (voteEndTime && voteEndTime.toMillis() <= now.toMillis()) {
          expiredVotes.push(doc);
          logger.debug(`만료된 투표 발견: ${doc.id}`, {
            voteEndTime: voteEndTime.toDate().toISOString(),
            currentTime: now.toDate().toISOString()
          });
        }
      });
      
      if (expiredVotes.length === 0) {
        logger.debug('만료된 투표 없음');
        
        // 디버그 정보 출력
        logger.debug('========== 디버그: Active 투표 상태 ==========');
        activeVotesSnapshot.forEach(doc => {
          const data = doc.data();
          const voteEndTime = parseTimestamp(data.voteEndTime);
          const remainingMinutes = voteEndTime ? Math.round((voteEndTime.toMillis() - now.toMillis()) / 1000 / 60) : null;
          
          logger.debug(`Post ${doc.id}`, {
            voteEndTimeRaw: logger.maskData(data.voteEndTime),
            voteEndTimeParsed: voteEndTime ? voteEndTime.toDate().toISOString() : 'null',
            remainingTime: remainingMinutes ? `${remainingMinutes}분` : 'N/A'
          });
        });
        
        logger.info('========== Scheduled Function 종료 ==========');
        return null;
      }
      
      logger.info(`${expiredVotes.length}개의 만료된 투표 처리 시작`);
      
      // 각 게시물에 대해 투표 종료 처리
      const results = await Promise.allSettled(
        expiredVotes.map(async (doc) => {
          const postId = doc.id;
          const postData = doc.data();
          
          // 실제 투표 수 계산
          const actualVotesA = postData.votedUserIDsA?.length || postData.votesA || postData.voteCountA || 0;
          const actualVotesB = postData.votedUserIDsB?.length || postData.votesB || postData.voteCountB || 0;
          const actualTotal = actualVotesA + actualVotesB;
          
          // AI 예상 비율 읽기 (Flutter가 저장한 위치에서)
          const expectedRatio = {
            A: postData.moderation?.expectedRatioA || 0.5,
            B: postData.moderation?.expectedRatioB || 0.5
          };
          
          logger.debug(`AI 예상 비율 - A: ${expectedRatio.A}, B: ${expectedRatio.B}`);
          
          // 투표 증폭 계산 (목표: 100명)
          const targetCount = 100;
          const displayVotes = calculateDisplayVotes(
            { A: actualVotesA, B: actualVotesB },
            targetCount,
            expectedRatio  // AI 예상 비율 전달
          );
          
          // 표시용 비율 계산
          const percentA = Math.round((displayVotes.A / targetCount) * 100);
          const percentB = Math.round((displayVotes.B / targetCount) * 100);
          
          // 투표 결과 데이터
          const voteResults = {
            votesA: displayVotes.A,
            votesB: displayVotes.B,
            actualVotesA,
            actualVotesB,
            totalVotes: targetCount,
            actualTotalVotes: actualTotal,
            percentA,
            percentB,
            winner: displayVotes.A > displayVotes.B ? 'A' : displayVotes.B > displayVotes.A ? 'B' : 'draw',
            questionTitle: postData.questionTitle || postData.questionTitle,
            optionA: postData.optionA?.title || postData.optionA || 'A',
            optionB: postData.optionB?.title || postData.optionB || 'B',
            creatorId: postData.uid || postData.userid,
            creatorName: postData.authorName || postData.authorName || '알 수 없음',
            isTimeout: false, // 10분 타이머 정상 종료
            displayVotesA: displayVotes.A, // AI 채팅 메시지용
            displayVotesB: displayVotes.B  // AI 채팅 메시지용
          };
          
          try {
            // 1. 게시물 상태 업데이트
            await doc.ref.update({
              voteCompleted: true,
              voteCompletedAt: admin.firestore.FieldValue.serverTimestamp(),
              // 표시용 투표 수 (증폭된 수)
              displayVotesA: displayVotes.A,
              displayVotesB: displayVotes.B,
              displayPercentA: percentA,
              displayPercentB: percentB,
              // 실제 투표 수 (내부 데이터)
              actualVotesA: actualVotesA,
              actualVotesB: actualVotesB,
              actualTotalVotes: actualTotal
            });
            
            // 2. 투표 완료 처리 (알림 생성 등)
            await processVoteCompletion(postId, voteResults);
            
            // 3. 모든 참여자에게 AI 채팅 결과 메시지 업데이트
            const notificationsSnapshot = await db.collection('notifications')
              .where('sourceId', '==', postId)
              .where('type', '==', 'voting_request')
              .get();
            
            const participantIds = new Set();
            notificationsSnapshot.forEach(doc => {
              const userId = doc.data().userId;
              if (userId) participantIds.add(userId);
            });
            
            // 작성자도 포함
            if (voteResults.creatorId) {
              participantIds.add(voteResults.creatorId);
            }
            
            // AI 채팅 결과 메시지 업데이트
            const messagePromises = Array.from(participantIds).map(userId => 
              createVoteResultMessage(userId, postId, voteResults)
            );
            await Promise.all(messagePromises);
            
            logger.info(`Post ${postId} 완료 처리 성공`);
          } catch (error) {
            logger.error(`Post ${postId} 처리 실패`, error);
            throw error;
          }
        })
      );
      
      // 결과 로그
      const succeeded = results.filter(r => r.status === 'fulfilled').length;
      const failed = results.filter(r => r.status === 'rejected').length;
      
      logger.info(`처리 완료 - 성공: ${succeeded}, 실패: ${failed}`);
      logger.info('========== Scheduled Function 종료 ==========');
      
      return { succeeded, failed };
      
    } catch (error) {
      logger.error('오류 발생', error);
      throw error;
    }
  });