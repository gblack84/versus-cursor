/**
 * HTTP 함수로 투표 데이터 마이그레이션 실행
 * Firebase Console 또는 CLI에서 직접 호출 가능
 */

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const logger = functions.logger;

/**
 * 투표 데이터 마이그레이션 HTTP 함수
 * 
 * 사용 예:
 * - 테스트: https://[region]-[project].cloudfunctions.net/migrateVoteData?dryRun=true&limit=10
 * - 실행: https://[region]-[project].cloudfunctions.net/migrateVoteData
 */
exports.migrateVoteData = functions
  .region('asia-northeast3')
  .https.onRequest(async (req, res) => {
    try {
      // 인증 확인 (선택사항 - 보안을 위해 추가 가능)
      // if (!req.headers.authorization || req.headers.authorization !== 'Bearer YOUR_SECRET_TOKEN') {
      //   return res.status(403).send('Unauthorized');
      // }

      const isDryRun = req.query.dryRun === 'true';
      const limit = req.query.limit ? parseInt(req.query.limit) : null;

      logger.info('=== 투표 데이터 마이그레이션 시작 ===', {
        mode: isDryRun ? 'DRY RUN' : 'PRODUCTION',
        limit: limit || '제한 없음'
      });

      let totalMessages = 0;
      let migratedMessages = 0;
      let skippedMessages = 0;
      let errors = 0;
      const results = [];

      // 모든 채팅방 가져오기
      const chatsSnapshot = await admin.firestore().collection('chats').get();
      
      for (const chatDoc of chatsSnapshot.docs) {
        const chatId = chatDoc.id;
        
        // AI 채팅방만 처리
        if (!chatId.includes('ai_assistant')) {
          continue;
        }
        
        // 각 채팅방의 메시지 가져오기
        let messagesQuery = admin.firestore()
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('message_type', 'in', ['vote_request', 'vote_created']);
        
        if (limit) {
          messagesQuery = messagesQuery.limit(limit);
        }
        
        const messagesSnapshot = await messagesQuery.get();
        
        for (const messageDoc of messagesSnapshot.docs) {
          totalMessages++;
          const messageData = messageDoc.data();
          const messageId = messageDoc.id;
          
          // 이미 user_votes가 있고 데이터가 있으면 스킵
          if (messageData.user_votes && Object.keys(messageData.user_votes).length > 0) {
            logger.info(`메시지 ${messageId}: 이미 마이그레이션됨`);
            skippedMessages++;
            continue;
          }
          
          // 마이그레이션이 필요한 경우
          if (messageData.user_voted === true && messageData.sender_id) {
            const userVotes = {};
            
            // 기존 데이터를 user_votes Map으로 변환
            userVotes[messageData.sender_id] = {
              option: messageData.vote_choice || '',
              voted_at: messageData.vote_participated_at || admin.firestore.Timestamp.now()
            };
            
            logger.info(`메시지 ${messageId}: 마이그레이션 필요`, {
              sender_id: messageData.sender_id,
              vote_choice: messageData.vote_choice
            });
            
            if (!isDryRun) {
              try {
                await messageDoc.ref.update({
                  user_votes: userVotes,
                  migrated_at: admin.firestore.Timestamp.now(),
                  migration_version: '1.0'
                });
                logger.info(`메시지 ${messageId}: 마이그레이션 완료`);
                migratedMessages++;
                results.push({
                  messageId,
                  chatId,
                  status: 'migrated'
                });
              } catch (error) {
                logger.error(`메시지 ${messageId}: 마이그레이션 실패`, error);
                errors++;
                results.push({
                  messageId,
                  chatId,
                  status: 'error',
                  error: error.message
                });
              }
            } else {
              logger.info(`DRY RUN - 메시지 ${messageId}: 실제로 업데이트하지 않음`);
              migratedMessages++;
              results.push({
                messageId,
                chatId,
                status: 'would_migrate'
              });
            }
          }
        }
      }

      const summary = {
        mode: isDryRun ? 'DRY RUN' : 'PRODUCTION',
        totalMessages,
        migratedMessages,
        skippedMessages,
        errors,
        results: results.slice(0, 10) // 처음 10개만 표시
      };

      logger.info('=== 마이그레이션 완료 ===', summary);
      
      res.status(200).json({
        success: true,
        summary,
        message: `마이그레이션 ${isDryRun ? '시뮬레이션' : '실행'} 완료`
      });

    } catch (error) {
      logger.error('마이그레이션 오류:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });