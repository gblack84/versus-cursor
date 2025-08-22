/**
 * Firestore snake_case to camelCase Migration Script
 * 
 * 이 스크립트는 프로덕션 Firestore 데이터베이스의 모든 필드명을
 * snake_case에서 camelCase로 마이그레이션합니다.
 * 
 * 실행 방법:
 * 1. 먼저 DRY RUN 모드로 테스트: node migrate-snake-to-camel.js --dry-run
 * 2. 실제 마이그레이션 실행: node migrate-snake-to-camel.js --execute
 */

const admin = require('firebase-admin');

// Initialize Firebase Admin with Application Default Credentials
admin.initializeApp({
  projectId: 'versus-space-1lwwiw'
});

const db = admin.firestore();

// 마이그레이션 매핑
const FIELD_MAPPINGS = {
  // Common fields
  'created_at': 'createdAt',
  'updated_at': 'updatedAt',
  'created_time': 'createdTime',
  'updated_time': 'updatedTime',
  'last_active': 'lastActive',
  'last_active_time': 'lastActiveTime',
  'is_anonymous': 'isAnonymous',
  
  // User fields
  'user_id': 'userId',
  'display_name': 'displayName',
  'photo_url': 'photoUrl',
  'phone_number': 'phoneNumber',
  'points_A': 'pointsA',
  'points_Q': 'pointsQ',
  'total_a_points': 'totalAPoints',
  'total_q_points': 'totalQPoints',
  'is_premium_user': 'isPremiumUser',
  'anonymous_posts_count': 'anonymousPostsCount',
  'anonymous_comments_count': 'anonymousCommentsCount',
  'anonymous_question_count': 'anonymousQuestionCount',
  'current_rank': 'currentRank',
  'current_title': 'currentTitle',
  'rank_change_date': 'rankChangeDate',
  'title_change_date': 'titleChangeDate',
  'is_rank_eligible': 'isRankEligible',
  'rank_evaluation_count': 'rankEvaluationCount',
  'rank_history': 'rankHistory',
  'title_history': 'titleHistory',
  'receive_rank_update_notifications': 'receiveRankUpdateNotifications',
  'receive_title_update_notifications': 'receiveTitleUpdateNotifications',
  'active_chats': 'activeChats',
  'group_chats': 'groupChats',
  'short_description': 'shortDescription',
  'date_of_birth': 'dateOfBirth',
  
  // Post fields
  'post_id': 'postId',
  'comment_count': 'commentcount',
  'like_count': 'likecount',
  'interest_count': 'interestcount',
  'share_count': 'sherecount',
  'save_count': 'savecount',
  'participant_count': 'participantcount',
  'initial_comment_limit': 'initialCommentLimit',
  'current_comment_count': 'currentCommentCount',
  'option_a': 'optionA',
  'option_b': 'optionB',
  'option_a_description': 'optionADescription',
  'option_b_description': 'optionBDescription',
  'image_urls_a': 'imageUrlsA',
  'image_urls_b': 'imageUrlsB',
  'target_audience': 'targetAudience',
  'is_notification_enabled': 'isNotificationEnabled',
  'vote_start_time': 'voteStartTime',
  'vote_end_time': 'voteEndTime',
  'vote_completed': 'voteCompleted',
  'vote_status': 'voteStatus',
  'votes_a': 'votesA',
  'votes_b': 'votesB',
  'voter_ids': 'voterIds',
  'voter_count': 'voterCount',
  'vote_timeout_checked': 'voteTimeoutChecked',
  'notifications_sent': 'notificationsSent',
  'notifications_sent_at': 'notificationsSentAt',
  
  // Message fields
  'message_id': 'messageId',
  'chat_id': 'chatId',
  'sender_id': 'senderId',
  'receiver_id': 'receiverId',
  'card_type': 'cardType',
  'card_status': 'cardStatus',
  'vote_option_a': 'voteOptionA',
  'vote_option_b': 'voteOptionB',
  'vote_option_a_images': 'voteOptionAImages',
  'vote_option_b_images': 'voteOptionBImages',
  'vote_option_a_description': 'voteOptionADescription',
  'vote_option_b_description': 'voteOptionBDescription',
  'vote_option_a_images_aspect_ratio': 'voteOptionAImagesAspectRatio',
  'vote_option_b_images_aspect_ratio': 'voteOptionBImagesAspectRatio',
  'vote_end_time': 'voteEndTime',
  'layout_type': 'layoutType',
  'is_seen': 'isSeen',
  'seen_at': 'seenAt',
  'time_stamp': 'timeStamp',
  'emoji_reaction': 'emojiReaction',
  
  // Chat fields
  'last_message': 'lastMessage',
  'last_message_at': 'lastMessageAt',
  'participant_ids': 'participantIds',
  'unread_count': 'unreadCount',
  'chat_type': 'chatType',
  'group_name': 'groupName',
  'group_photo': 'groupPhoto',
  
  // Notification fields
  'notification_type': 'notificationType',
  'is_read': 'isRead',
  'read_at': 'readAt',
  'target_mode': 'targetMode',
  'sent_at': 'sentAt',
  
  // Image moderation fields
  'image_url': 'imageUrl',
  'moderation_labels': 'moderationLabels',
  'is_safe': 'isSafe',
  'checked_at': 'checkedAt',
  'vision_api_response': 'visionApiResponse',
  'gemini_response': 'geminiResponse',
  'perspective_scores': 'perspectiveScores'
};

// 변환 함수
function convertFieldNames(data) {
  if (!data || typeof data !== 'object') {
    return data;
  }
  
  const converted = {};
  let hasChanges = false;
  
  for (const [key, value] of Object.entries(data)) {
    const newKey = FIELD_MAPPINGS[key] || key;
    
    if (newKey !== key) {
      hasChanges = true;
      console.log(`  Field renamed: ${key} → ${newKey}`);
    }
    
    // 중첩된 객체 처리
    if (value && typeof value === 'object' && !Array.isArray(value) && !(value instanceof Date)) {
      converted[newKey] = convertFieldNames(value);
    } else {
      converted[newKey] = value;
    }
  }
  
  return { data: converted, hasChanges };
}

// 컬렉션 마이그레이션
async function migrateCollection(collectionName, isDryRun = true) {
  console.log(`\n📁 Processing collection: ${collectionName}`);
  
  const collection = db.collection(collectionName);
  const snapshot = await collection.limit(isDryRun ? 10 : 1000).get();
  
  if (snapshot.empty) {
    console.log(`  Collection is empty or doesn't exist`);
    return { processed: 0, updated: 0 };
  }
  
  let processed = 0;
  let updated = 0;
  const batch = db.batch();
  let batchCount = 0;
  
  for (const doc of snapshot.docs) {
    processed++;
    const originalData = doc.data();
    const { data: convertedData, hasChanges } = convertFieldNames(originalData);
    
    if (hasChanges) {
      updated++;
      console.log(`  Document ${doc.id}: needs update`);
      
      if (!isDryRun) {
        batch.update(doc.ref, convertedData);
        batchCount++;
        
        // Firestore batch limit is 500
        if (batchCount === 500) {
          await batch.commit();
          console.log(`  Committed batch of ${batchCount} updates`);
          batchCount = 0;
        }
      }
    }
  }
  
  if (!isDryRun && batchCount > 0) {
    await batch.commit();
    console.log(`  Committed final batch of ${batchCount} updates`);
  }
  
  console.log(`  Processed: ${processed} documents, Updated: ${updated} documents`);
  return { processed, updated };
}

// 메인 실행 함수
async function main() {
  const args = process.argv.slice(2);
  const isDryRun = !args.includes('--execute');
  
  console.log('==========================================');
  console.log('Firestore snake_case → camelCase Migration');
  console.log('==========================================');
  console.log(`Mode: ${isDryRun ? 'DRY RUN (no changes will be made)' : 'EXECUTE (changes will be applied)'}`);
  console.log('');
  
  if (!isDryRun) {
    console.log('⚠️  WARNING: This will modify production data!');
    console.log('Press Ctrl+C to cancel, or wait 5 seconds to continue...');
    await new Promise(resolve => setTimeout(resolve, 5000));
  }
  
  // 마이그레이션할 컬렉션 목록
  const collections = [
    'users',
    'posts',
    'messages',
    'notifications',
    'chats',
    'comments',
    'likes',
    'dislikes',
    'group_chats',
    'friends_list',
    'rankings',
    'searches',
    'interest',
    'user_contents',
    'premium_users',
    'characters',
    'encodings',
    'imageModeration'
  ];
  
  const stats = {
    totalProcessed: 0,
    totalUpdated: 0,
    collections: {}
  };
  
  for (const collectionName of collections) {
    try {
      const result = await migrateCollection(collectionName, isDryRun);
      stats.collections[collectionName] = result;
      stats.totalProcessed += result.processed;
      stats.totalUpdated += result.updated;
    } catch (error) {
      console.error(`  Error processing collection ${collectionName}:`, error.message);
      stats.collections[collectionName] = { error: error.message };
    }
  }
  
  // 결과 요약
  console.log('\n==========================================');
  console.log('Migration Summary');
  console.log('==========================================');
  console.log(`Total documents processed: ${stats.totalProcessed}`);
  console.log(`Total documents updated: ${stats.totalUpdated}`);
  console.log('\nPer collection:');
  
  for (const [collection, result] of Object.entries(stats.collections)) {
    if (result.error) {
      console.log(`  ${collection}: ERROR - ${result.error}`);
    } else {
      console.log(`  ${collection}: ${result.processed} processed, ${result.updated} updated`);
    }
  }
  
  if (isDryRun) {
    console.log('\n✅ Dry run completed. No changes were made.');
    console.log('Run with --execute flag to apply changes.');
  } else {
    console.log('\n✅ Migration completed successfully!');
  }
  
  process.exit(0);
}

// 에러 핸들링
process.on('unhandledRejection', (error) => {
  console.error('Unhandled error:', error);
  process.exit(1);
});

// 실행
main();