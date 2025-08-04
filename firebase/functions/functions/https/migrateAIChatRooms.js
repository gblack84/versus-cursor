/**
 * AI 채팅방 ID 마이그레이션 함수
 * 기존의 잘못된 chat ID를 올바른 형식으로 변경
 */

const functions = require('firebase-functions');
const { admin } = require('../../config/firebase');

// AI 어시스턴트 상수
const AI_ASSISTANT_ID = 'ai_assistant';

/**
 * 채팅방 ID 마이그레이션
 * 기존: 대소문자가 섞인 ID (예: AacklMhqMxV8B1JgEAjG7aocxvg1_ai_assistant)
 * 신규: ai_assistant_userId 형식
 */
exports.migrateAIChatRooms = functions
  .region('asia-northeast3')
  .https.onRequest(async (req, res) => {
    try {
      console.log('[마이그레이션] AI 채팅방 마이그레이션 시작');
      
      // AI 채팅방 찾기 (ai_assistant가 participant인 모든 채팅방)
      const chatsSnapshot = await admin.firestore()
        .collection('chats')
        .where('participantIds', 'array-contains', AI_ASSISTANT_ID)
        .get();
      
      console.log(`[마이그레이션] 총 ${chatsSnapshot.size}개의 AI 채팅방 발견`);
      
      const migrationResults = {
        total: chatsSnapshot.size,
        migrated: 0,
        skipped: 0,
        errors: []
      };
      
      // 각 채팅방 처리
      for (const chatDoc of chatsSnapshot.docs) {
        const chatData = chatDoc.data();
        const currentChatId = chatDoc.id;
        
        // 사용자 ID 찾기
        const userId = chatData.participantIds.find(id => id !== AI_ASSISTANT_ID);
        if (!userId) {
          console.error(`[마이그레이션] 사용자 ID를 찾을 수 없음: ${currentChatId}`);
          migrationResults.errors.push({
            chatId: currentChatId,
            error: '사용자 ID를 찾을 수 없음'
          });
          continue;
        }
        
        // 새로운 채팅방 ID
        const newChatId = `${AI_ASSISTANT_ID}_${userId}`;
        
        // 이미 올바른 형식인 경우 스킵
        if (currentChatId === newChatId) {
          console.log(`[마이그레이션] 이미 올바른 형식: ${currentChatId}`);
          migrationResults.skipped++;
          continue;
        }
        
        console.log(`[마이그레이션] 마이그레이션 필요: ${currentChatId} → ${newChatId}`);
        
        try {
          // 트랜잭션으로 안전하게 처리
          await admin.firestore().runTransaction(async (transaction) => {
            // 기존 채팅방 데이터 읽기
            const oldChatRef = admin.firestore().collection('chats').doc(currentChatId);
            const oldChatDoc = await transaction.get(oldChatRef);
            
            if (!oldChatDoc.exists) {
              throw new Error('기존 채팅방을 찾을 수 없음');
            }
            
            // 새 채팅방 참조
            const newChatRef = admin.firestore().collection('chats').doc(newChatId);
            
            // 새 채팅방이 이미 존재하는지 확인
            const newChatDoc = await transaction.get(newChatRef);
            if (newChatDoc.exists) {
              console.log(`[마이그레이션] 대상 채팅방이 이미 존재함: ${newChatId}`);
              // 메시지 병합이 필요할 수 있음
              migrationResults.skipped++;
              return;
            }
            
            // 메시지 서브컬렉션 복사
            const messagesSnapshot = await admin.firestore()
              .collection('chats')
              .doc(currentChatId)
              .collection('messages')
              .get();
            
            console.log(`[마이그레이션] ${messagesSnapshot.size}개의 메시지 발견`);
            
            // 새 채팅방 생성
            transaction.set(newChatRef, {
              ...chatData,
              migrated_from: currentChatId,
              migrated_at: admin.firestore.Timestamp.now()
            });
            
            // 메시지 복사
            messagesSnapshot.docs.forEach(messageDoc => {
              const newMessageRef = newChatRef.collection('messages').doc(messageDoc.id);
              transaction.set(newMessageRef, messageDoc.data());
            });
            
            // 기존 채팅방 삭제 표시 (실제 삭제는 하지 않고 표시만)
            transaction.update(oldChatRef, {
              migrated_to: newChatId,
              migrated_at: admin.firestore.Timestamp.now(),
              is_migrated: true
            });
          });
          
          console.log(`[마이그레이션] 성공: ${currentChatId} → ${newChatId}`);
          migrationResults.migrated++;
          
        } catch (error) {
          console.error(`[마이그레이션] 실패: ${currentChatId}`, error);
          migrationResults.errors.push({
            chatId: currentChatId,
            error: error.message
          });
        }
      }
      
      console.log('[마이그레이션] 완료:', migrationResults);
      
      res.json({
        success: true,
        results: migrationResults
      });
      
    } catch (error) {
      console.error('[마이그레이션] 전체 오류:', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });