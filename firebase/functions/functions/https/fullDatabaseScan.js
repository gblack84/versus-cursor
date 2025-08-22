/**
 * 전체 데이터베이스 스캔 - 모든 컬렉션과 서브컬렉션의 snake_case 필드 찾기
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { createLogger } = require("../../config/logger");

// 마이그레이션 매핑 - migrateSnakeToCamel.js와 동일
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
  'perspective_scores': 'perspectiveScores',
  
  // Additional fields from previous migrations
  'test_mode_status': 'testModeStatus',
  'test_mode_user_choice': 'testModeUserChoice',
  'test_mode_user_voted_at': 'testModeUserVotedAt',
  'action_url': 'actionUrl',
  'vote_ai_chat_id': 'voteAiChatId',
  'ai_chats_created_at': 'aiChatsCreatedAt',
  'helper_ai_chat_id': 'helperAiChatId',
  'ai_chats_created': 'aiChatsCreated',
  'user_a': 'userA',
  'user_b': 'userB',
  'last_message_sent_by': 'lastMessageSentBy',
  'last_message_time': 'lastMessageTime',
  'last_message_content': 'lastMessageContent',
  'sort_priority': 'sortPriority',
  'chat_name': 'chatName',
  'participant_names': 'participantNames',
  'message_count': 'messageCount',
  'last_read_timestamps': 'lastReadTimestamps',
  'ai_assistant': 'aiAssistant',
  'ai_helper': 'aiHelper',
  'detected_text': 'detectedText',
  'original_metadata': 'originalMetadata',
  'uploaded_at': 'uploadedAt',
  'uploaded_by': 'uploadedBy',
  'firebase_storage_download_tokens': 'firebaseStorageDownloadTokens',
  'safe_search_results': 'safeSearchResults',
  'dominant_colors': 'dominantColors',
  'file_path': 'filePath',
  'download_url': 'downloadUrl',
  'moderation_status': 'moderationStatus',
  'last_updated': 'lastUpdated',
  'moderated_at': 'moderatedAt',
  
  // Subcollection specific fields (새로 추가)
  'poll_details': 'pollDetails',
  'poll_created_at': 'pollCreatedAt',
  'poll_updated_at': 'pollUpdatedAt',
  'poll_status': 'pollStatus',
  'voted_at': 'votedAt',
  'vote_choice': 'voteChoice',
  'vote_timestamp': 'voteTimestamp',
  'vote_ip': 'voteIp',
  'vote_device': 'voteDevice',
  'vote_location': 'voteLocation',
  'time_sync': 'timeSync',
  'server_time': 'serverTime',
  'client_time': 'clientTime',
  'time_offset': 'timeOffset',
  'sync_timestamp': 'syncTimestamp',
  'sync_status': 'syncStatus'
};

// snake_case 필드 찾기
function findSnakeCaseFields(data, path = '') {
  const snakeCaseFields = [];
  
  if (!data || typeof data !== 'object') {
    return snakeCaseFields;
  }
  
  for (const [key, value] of Object.entries(data)) {
    const currentPath = path ? `${path}.${key}` : key;
    
    // snake_case 패턴 확인
    if (key.includes('_') && !key.startsWith('_')) {
      snakeCaseFields.push({
        path: currentPath,
        field: key,
        mappedTo: FIELD_MAPPINGS[key] || 'NOT_MAPPED',
        value: typeof value === 'object' ? '[Object]' : value
      });
    }
    
    // 중첩된 객체 재귀 검사
    if (value && typeof value === 'object' && !Array.isArray(value) && 
        !(value instanceof Date) && !(value._seconds !== undefined)) {
      const nestedFields = findSnakeCaseFields(value, currentPath);
      snakeCaseFields.push(...nestedFields);
    }
  }
  
  return snakeCaseFields;
}

// 서브컬렉션 재귀적으로 스캔
async function scanSubcollections(docRef, path = '') {
  const results = [];
  
  try {
    // 문서의 모든 서브컬렉션 가져오기
    const subcollections = await docRef.listCollections();
    
    for (const subcollection of subcollections) {
      const subcollectionPath = `${path}/${subcollection.id}`;
      
      // 서브컬렉션의 문서들 확인
      const snapshot = await subcollection.limit(10).get();
      
      for (const doc of snapshot.docs) {
        const data = doc.data();
        const snakeCaseFields = findSnakeCaseFields(data);
        
        if (snakeCaseFields.length > 0) {
          results.push({
            path: `${subcollectionPath}/${doc.id}`,
            collection: subcollection.id,
            docId: doc.id,
            snakeCaseFields: snakeCaseFields
          });
        }
        
        // 재귀적으로 더 깊은 서브컬렉션 확인
        const deeperResults = await scanSubcollections(doc.ref, `${subcollectionPath}/${doc.id}`);
        results.push(...deeperResults);
      }
    }
  } catch (error) {
    console.error(`Error scanning subcollections at ${path}:`, error);
  }
  
  return results;
}

// 전체 데이터베이스 스캔
async function scanEntireDatabase() {
  const db = admin.firestore();
  const results = {
    collections: {},
    subcollections: {},
    unmappedFields: new Set(),
    summary: {
      totalCollections: 0,
      totalSubcollections: 0,
      totalDocuments: 0,
      totalSnakeCaseFields: 0
    }
  };
  
  // 모든 루트 컬렉션 가져오기
  const collections = await db.listCollections();
  
  for (const collection of collections) {
    const collectionName = collection.id;
    results.collections[collectionName] = {
      documents: [],
      documentCount: 0,
      snakeCaseFieldCount: 0
    };
    
    // 컬렉션의 문서들 확인 (최대 10개)
    const snapshot = await collection.limit(10).get();
    
    for (const doc of snapshot.docs) {
      const data = doc.data();
      const snakeCaseFields = findSnakeCaseFields(data);
      
      if (snakeCaseFields.length > 0) {
        results.collections[collectionName].documents.push({
          docId: doc.id,
          snakeCaseFields: snakeCaseFields
        });
        results.collections[collectionName].snakeCaseFieldCount += snakeCaseFields.length;
        
        // 매핑되지 않은 필드 수집
        snakeCaseFields.forEach(field => {
          if (field.mappedTo === 'NOT_MAPPED') {
            results.unmappedFields.add(field.field);
          }
        });
      }
      
      // 서브컬렉션 스캔
      const subcollectionResults = await scanSubcollections(doc.ref, `${collectionName}/${doc.id}`);
      if (subcollectionResults.length > 0) {
        if (!results.subcollections[collectionName]) {
          results.subcollections[collectionName] = [];
        }
        results.subcollections[collectionName].push(...subcollectionResults);
      }
    }
    
    results.collections[collectionName].documentCount = snapshot.docs.length;
    results.summary.totalDocuments += snapshot.docs.length;
  }
  
  // 요약 정보 업데이트
  results.summary.totalCollections = Object.keys(results.collections).length;
  results.summary.totalSubcollections = Object.values(results.subcollections).reduce(
    (sum, subs) => sum + subs.length, 0
  );
  results.summary.totalSnakeCaseFields = Object.values(results.collections).reduce(
    (sum, col) => sum + col.snakeCaseFieldCount, 0
  );
  results.unmappedFields = Array.from(results.unmappedFields);
  
  return results;
}

exports.fullDatabaseScan = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540,
    memory: '1GB'
  })
  .https.onRequest(async (req, res) => {
    const logger = createLogger('fullDatabaseScan');
    
    try {
      logger.info('Starting full database scan including subcollections');
      
      const scanResults = await scanEntireDatabase();
      
      // 결과를 보기 쉽게 정리
      const response = {
        success: true,
        summary: scanResults.summary,
        unmappedFields: scanResults.unmappedFields,
        collectionsWithIssues: Object.entries(scanResults.collections)
          .filter(([_, data]) => data.snakeCaseFieldCount > 0)
          .map(([name, data]) => ({
            collection: name,
            documentsWithSnakeCase: data.documents.length,
            totalSnakeCaseFields: data.snakeCaseFieldCount,
            sampleFields: data.documents[0]?.snakeCaseFields.slice(0, 5)
          })),
        subcollectionsWithIssues: scanResults.subcollections
      };
      
      logger.info('Full database scan complete', {
        collections: response.summary.totalCollections,
        subcollections: response.summary.totalSubcollections,
        unmappedFields: response.unmappedFields.length
      });
      
      res.status(200).json(response);
      
    } catch (error) {
      logger.error('Full database scan failed', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });