/**
 * 투표 데이터 마이그레이션 스크립트
 * 기존 개별 필드를 user_votes Map 구조로 변환
 * 
 * 실행 방법:
 * cd firebase/functions
 * node scripts/migrate-vote-data.js [--dry-run] [--limit=100]
 */

const admin = require('firebase-admin');

// Firebase Admin 초기화
// 로컬에서 실행할 때는 GOOGLE_APPLICATION_CREDENTIALS 환경변수 설정 필요
// 또는 Firebase Functions 환경에서는 자동으로 인증됨
if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  // 환경변수로 서비스 계정 키 경로 지정된 경우
  admin.initializeApp();
} else {
  // 기본 인증 시도 (Firebase Functions 환경 또는 gcloud 인증)
  admin.initializeApp({
    projectId: 'versus-space-1lwwiw'
  });
}

const db = admin.firestore();

// 명령행 인자 파싱
const args = process.argv.slice(2);
const isDryRun = args.includes('--dry-run');
const limitArg = args.find(arg => arg.startsWith('--limit='));
const limit = limitArg ? parseInt(limitArg.split('=')[1]) : null;

console.log('=== 투표 데이터 마이그레이션 시작 ===');
console.log(`모드: ${isDryRun ? 'DRY RUN (테스트)' : 'PRODUCTION (실제 실행)'}`);
if (limit) console.log(`처리 제한: ${limit}개`);
console.log('');

/**
 * 메시지 마이그레이션
 */
async function migrateMessages() {
  console.log('📋 메시지 마이그레이션 시작...\n');
  
  let totalMessages = 0;
  let migratedMessages = 0;
  let skippedMessages = 0;
  let errors = 0;

  try {
    // 모든 채팅방 가져오기
    const chatsSnapshot = await db.collection('chats').get();
    
    for (const chatDoc of chatsSnapshot.docs) {
      const chatId = chatDoc.id;
      console.log(`\n채팅방 처리 중: ${chatId}`);
      
      // 각 채팅방의 메시지 가져오기
      let messagesQuery = db.collection('chats').doc(chatId).collection('messages')
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
          console.log(`  ⏭️  메시지 ${messageId}: 이미 마이그레이션됨`);
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
          
          console.log(`  🔄 메시지 ${messageId}: 마이그레이션 필요`);
          console.log(`     - sender_id: ${messageData.sender_id}`);
          console.log(`     - vote_choice: ${messageData.vote_choice}`);
          console.log(`     - user_votes: ${JSON.stringify(userVotes)}`);
          
          if (!isDryRun) {
            try {
              await messageDoc.ref.update({
                user_votes: userVotes,
                // 마이그레이션 메타데이터
                migrated_at: admin.firestore.Timestamp.now(),
                migration_version: '1.0'
              });
              console.log(`     ✅ 마이그레이션 완료`);
              migratedMessages++;
            } catch (error) {
              console.error(`     ❌ 마이그레이션 실패: ${error.message}`);
              errors++;
            }
          } else {
            console.log(`     🧪 DRY RUN - 실제로 업데이트하지 않음`);
            migratedMessages++;
          }
        }
      }
    }
    
  } catch (error) {
    console.error('오류 발생:', error);
  }
  
  console.log('\n=== 마이그레이션 완료 ===');
  console.log(`전체 메시지: ${totalMessages}`);
  console.log(`마이그레이션됨: ${migratedMessages}`);
  console.log(`스킵됨: ${skippedMessages}`);
  console.log(`오류: ${errors}`);
}

/**
 * 마이그레이션 검증
 */
async function validateMigration() {
  console.log('\n📊 마이그레이션 검증 시작...\n');
  
  let oldFormatCount = 0;
  let newFormatCount = 0;
  let bothFormatCount = 0;
  
  const chatsSnapshot = await db.collection('chats').get();
  
  for (const chatDoc of chatsSnapshot.docs) {
    const messagesSnapshot = await db.collection('chats')
      .doc(chatDoc.id)
      .collection('messages')
      .where('message_type', 'in', ['vote_request', 'vote_created'])
      .get();
    
    messagesSnapshot.forEach(doc => {
      const data = doc.data();
      const hasOldFormat = data.user_voted !== undefined;
      const hasNewFormat = data.user_votes !== undefined && Object.keys(data.user_votes).length > 0;
      
      if (hasOldFormat && hasNewFormat) {
        bothFormatCount++;
      } else if (hasOldFormat) {
        oldFormatCount++;
      } else if (hasNewFormat) {
        newFormatCount++;
      }
    });
  }
  
  console.log('=== 검증 결과 ===');
  console.log(`구 형식만: ${oldFormatCount}`);
  console.log(`신 형식만: ${newFormatCount}`);
  console.log(`양쪽 형식: ${bothFormatCount}`);
  console.log(`\n권장사항: ${oldFormatCount > 0 ? '추가 마이그레이션 필요' : '마이그레이션 완료'}`);
}

/**
 * 메인 실행 함수
 */
async function main() {
  try {
    // 마이그레이션 실행
    await migrateMessages();
    
    // 검증 실행
    if (!isDryRun) {
      await validateMigration();
    }
    
    console.log('\n✨ 모든 작업 완료!');
    process.exit(0);
  } catch (error) {
    console.error('\n❌ 치명적 오류:', error);
    process.exit(1);
  }
}

// 실행
main();