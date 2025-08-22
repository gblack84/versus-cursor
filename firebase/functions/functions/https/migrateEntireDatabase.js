/**
 * 전체 데이터베이스 마이그레이션 - 모든 컬렉션과 서브컬렉션의 snake_case를 camelCase로 변환
 */

const functions = require("firebase-functions");
const { admin } = require("../../config/firebase");
const { createLogger } = require("../../config/logger");

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
  'action_url': 'actionUrl',
  
  // Image moderation fields
  'image_url': 'imageUrl',
  'moderation_labels': 'moderationLabels',
  'is_safe': 'isSafe',
  'checked_at': 'checkedAt',
  'vision_api_response': 'visionApiResponse',
  'gemini_response': 'geminiResponse',
  'perspective_scores': 'perspectiveScores',
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
  
  // Additional fields
  'test_mode_status': 'testModeStatus',
  'test_mode_user_choice': 'testModeUserChoice',
  'test_mode_user_voted_at': 'testModeUserVotedAt',
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
  
  // Subcollection specific fields
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
  'sync_status': 'syncStatus',
  
  // Message subcollection fields  
  'message_text': 'messageText',
  'message_type': 'messageType',
  'vote_post_id': 'votePostId',
  'vote_title': 'voteTitle',
  'vote_option_a_text': 'voteOptionAText',
  'vote_option_b_text': 'voteOptionBText',
  'vote_option_a_image': 'voteOptionAImage',
  'vote_option_b_image': 'voteOptionBImage',
  'vote_description': 'voteDescription',
  'read_status': 'readStatus',
  'delivery_status': 'deliveryStatus',
  'edited_at': 'editedAt',
  'deleted_at': 'deletedAt',
  'reply_to': 'replyTo',
  'forwarded_from': 'forwardedFrom',
  'media_url': 'mediaUrl',
  'media_type': 'mediaType',
  'media_size': 'mediaSizwe',
  'media_duration': 'mediaDuration',
  'thumbnail_url': 'thumbnailUrl',
  
  // Comments subcollection fields
  'comment_text': 'commentText',
  'comment_id': 'commentId',
  'parent_comment_id': 'parentCommentId',
  'comment_level': 'commentLevel',
  'is_edited': 'isEdited',
  'is_deleted': 'isDeleted',
  'edit_history': 'editHistory',
  'deleted_by': 'deletedBy',
  'mention_users': 'mentionUsers',
  
  // Likes/Dislikes subcollection fields
  'liked_at': 'likedAt',
  'disliked_at': 'dislikedAt',
  'reaction_type': 'reactionType',
  'reaction_emoji': 'reactionEmoji',
  
  // Interest subcollection fields
  'interest_level': 'interestLevel',
  'interest_type': 'interestType',
  'interested_at': 'interestedAt',
  
  // Friends list fields
  'friend_id': 'friendId',
  'friend_since': 'friendSince',
  'friend_status': 'friendStatus',
  'request_sent_at': 'requestSentAt',
  'request_accepted_at': 'requestAcceptedAt',
  'is_blocked': 'isBlocked',
  'blocked_at': 'blockedAt',
  
  // Group chat fields
  'group_id': 'groupId',
  'group_admin': 'groupAdmin',
  'group_members': 'groupMembers',
  'member_count': 'memberCount',
  'created_by': 'createdBy',
  'group_description': 'groupDescription',
  'group_rules': 'groupRules',
  'is_public': 'isPublic',
  'join_code': 'joinCode',
  'member_roles': 'memberRoles',
  
  // Premium/Subscription fields
  'subscription_id': 'subscriptionId',
  'subscription_type': 'subscriptionType',
  'subscription_status': 'subscriptionStatus',
  'start_date': 'startDate',
  'end_date': 'endDate',
  'payment_method': 'paymentMethod',
  'payment_status': 'paymentStatus',
  'auto_renew': 'autoRenew',
  'cancel_at_period_end': 'cancelAtPeriodEnd',
  'trial_end': 'trialEnd',
  
  // Ranking fields
  'rank_position': 'rankPosition',
  'rank_score': 'rankScore',
  'rank_tier': 'rankTier',
  'previous_rank': 'previousRank',
  'rank_updated_at': 'rankUpdatedAt',
  'weekly_rank': 'weeklyRank',
  'monthly_rank': 'monthlyRank',
  'all_time_rank': 'allTimeRank',
  
  // Search fields
  'search_query': 'searchQuery',
  'search_results': 'searchResults',
  'search_count': 'searchCount',
  'searched_at': 'searchedAt',
  'search_type': 'searchType',
  'result_count': 'resultCount',
  
  // Content fields
  'content_id': 'contentId',
  'content_type': 'contentType',
  'content_status': 'contentStatus',
  'content_url': 'contentUrl',
  'content_data': 'contentData',
  'view_count': 'viewCount',
  'share_count': 'shareCount',
  'download_count': 'downloadCount',
  
  // Point transaction fields
  'point_type': 'pointType',
  'point_amount': 'pointAmount',
  'transaction_type': 'transactionType',
  'transaction_id': 'transactionId',
  'transaction_date': 'transactionDate',
  'balance_before': 'balanceBefore',
  'balance_after': 'balanceAfter',
  'transaction_reason': 'transactionReason',
  
  // Job category fields
  'job_category': 'jobCategory',
  'job_name': 'jobName',
  'job_description': 'jobDescription',
  'job_skills': 'jobSkills',
  'job_level': 'jobLevel',
  
  // Encoding fields
  'encoding_status': 'encodingStatus',
  'encoding_progress': 'encodingProgress',
  'input_url': 'inputUrl',
  'output_url': 'outputUrl',
  'encoding_started_at': 'encodingStartedAt',
  'encoding_completed_at': 'encodingCompletedAt',
  'encoding_error': 'encodingError',
  
  // Character fields
  'character_id': 'characterId',
  'character_name': 'characterName',
  'character_type': 'characterType',
  'character_level': 'characterLevel',
  'character_exp': 'characterExp',
  'character_stats': 'characterStats',
  'character_items': 'characterItems',
  'character_skills': 'characterSkills',
  
  // Additional unmapped fields from scan
  'completed_at': 'completedAt',
  'expiry_time': 'expiryTime',
  'interaction_type': 'interactionType',
  'notification_id': 'notificationId',
  'source_id': 'sourceId',
  'local_time': 'localTime'
};

// userId를 snake_case에서 camelCase로 변환하는 헬퍼 함수
function convertUserId(userId) {
  // 특별한 경우 처리
  if (userId === 'ai_assistant' || userId === 'ai_helper') {
    return userId;
  }
  
  // snake_case userId를 camelCase로 변환
  if (userId && userId.includes('_')) {
    return userId.split('_').map((part, index) => {
      if (index === 0) return part;
      return part.charAt(0).toUpperCase() + part.slice(1).toLowerCase();
    }).join('');
  }
  
  return userId;
}

// 필드 이름 변환
function convertFieldNames(data, parentKey = '') {
  if (!data || typeof data !== 'object') {
    return data;
  }
  
  const converted = {};
  let hasChanges = false;
  
  for (const [key, value] of Object.entries(data)) {
    let newKey = FIELD_MAPPINGS[key] || key;
    
    // 동적 userId 필드 처리
    if (parentKey === 'participantNames' || parentKey === 'lastReadTimestamps' || 
        parentKey === 'unreadCount' || parentKey === 'memberRoles') {
      // 이 필드들의 키는 userId이므로 변환
      if (key.includes('_') && !FIELD_MAPPINGS[key]) {
        newKey = convertUserId(key);
      }
    }
    
    if (newKey !== key) {
      hasChanges = true;
      console.log(`  Field renamed: ${key} → ${newKey}`);
    }
    
    // 중첩된 객체 처리
    if (value && typeof value === 'object' && !Array.isArray(value) && 
        !(value instanceof Date) && !(value._seconds !== undefined)) {
      const convertedValue = convertFieldNames(value, newKey);
      converted[newKey] = convertedValue.data || convertedValue;
      if (convertedValue.hasChanges) {
        hasChanges = true;
      }
    } else {
      converted[newKey] = value;
    }
  }
  
  return { data: converted, hasChanges };
}

// 서브컬렉션 마이그레이션
async function migrateSubcollections(docRef, path = '', isDryRun = false) {
  const results = {
    processed: 0,
    updated: 0,
    subcollections: []
  };
  
  try {
    // 문서의 모든 서브컬렉션 가져오기
    const subcollections = await docRef.listCollections();
    
    for (const subcollection of subcollections) {
      const subcollectionPath = `${path}/${subcollection.id}`;
      console.log(`\n  Migrating subcollection: ${subcollectionPath}`);
      
      const subcollectionResult = {
        name: subcollection.id,
        processed: 0,
        updated: 0
      };
      
      // 서브컬렉션의 모든 문서 가져오기 (페이지네이션)
      let lastDoc = null;
      let hasMore = true;
      
      while (hasMore) {
        let query = subcollection.limit(100);
        if (lastDoc) {
          query = query.startAfter(lastDoc);
        }
        
        const snapshot = await query.get();
        
        if (snapshot.empty) {
          hasMore = false;
          break;
        }
        
        const batch = admin.firestore().batch();
        let batchCount = 0;
        
        for (const doc of snapshot.docs) {
          subcollectionResult.processed++;
          const originalData = doc.data();
          const { data: convertedData, hasChanges } = convertFieldNames(originalData);
          
          if (hasChanges) {
            subcollectionResult.updated++;
            if (!isDryRun) {
              batch.set(doc.ref, convertedData, { merge: false });
              batchCount++;
            }
          }
          
          // 더 깊은 서브컬렉션 재귀 처리
          const deeperResults = await migrateSubcollections(
            doc.ref, 
            `${subcollectionPath}/${doc.id}`, 
            isDryRun
          );
          
          if (deeperResults.subcollections.length > 0) {
            subcollectionResult.subcollections = deeperResults.subcollections;
          }
        }
        
        if (!isDryRun && batchCount > 0) {
          await batch.commit();
          console.log(`    Committed ${batchCount} updates`);
        }
        
        lastDoc = snapshot.docs[snapshot.docs.length - 1];
        
        if (snapshot.docs.length < 100) {
          hasMore = false;
        }
      }
      
      console.log(`    Processed: ${subcollectionResult.processed}, Updated: ${subcollectionResult.updated}`);
      results.subcollections.push(subcollectionResult);
      results.processed += subcollectionResult.processed;
      results.updated += subcollectionResult.updated;
    }
  } catch (error) {
    console.error(`Error migrating subcollections at ${path}:`, error);
  }
  
  return results;
}

// 컬렉션 마이그레이션 (서브컬렉션 포함)
async function migrateCollectionWithSubcollections(collectionName, isDryRun = false) {
  console.log(`\n📁 Processing collection: ${collectionName}`);
  
  const db = admin.firestore();
  const collection = db.collection(collectionName);
  
  const results = {
    collection: collectionName,
    processed: 0,
    updated: 0,
    subcollections: []
  };
  
  // 페이지네이션으로 모든 문서 처리
  let lastDoc = null;
  let hasMore = true;
  
  while (hasMore) {
    let query = collection.limit(100);
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    
    const snapshot = await query.get();
    
    if (snapshot.empty) {
      hasMore = false;
      break;
    }
    
    const batch = db.batch();
    let batchCount = 0;
    
    for (const doc of snapshot.docs) {
      results.processed++;
      const originalData = doc.data();
      const { data: convertedData, hasChanges } = convertFieldNames(originalData);
      
      if (hasChanges) {
        results.updated++;
        if (!isDryRun) {
          batch.set(doc.ref, convertedData, { merge: false });
          batchCount++;
        }
      }
      
      // 서브컬렉션 마이그레이션
      const subcollectionResults = await migrateSubcollections(
        doc.ref, 
        `${collectionName}/${doc.id}`, 
        isDryRun
      );
      
      if (subcollectionResults.subcollections.length > 0) {
        results.subcollections.push(...subcollectionResults.subcollections);
        results.processed += subcollectionResults.processed;
        results.updated += subcollectionResults.updated;
      }
    }
    
    if (!isDryRun && batchCount > 0) {
      await batch.commit();
      console.log(`  Committed ${batchCount} updates`);
    }
    
    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    
    if (snapshot.docs.length < 100) {
      hasMore = false;
    }
  }
  
  console.log(`  Main collection - Processed: ${results.processed}, Updated: ${results.updated}`);
  
  return results;
}

exports.migrateEntireDatabase = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540,
    memory: '2GB'
  })
  .https.onRequest(async (req, res) => {
    const logger = createLogger('migrateEntireDatabase');
    
    try {
      const { dryRun = 'true', collections = '' } = req.query;
      const isDryRun = dryRun === 'true';
      
      logger.info('Starting entire database migration', { 
        isDryRun, 
        mode: isDryRun ? 'DRY RUN' : 'EXECUTE' 
      });
      
      const db = admin.firestore();
      const results = {
        mode: isDryRun ? 'DRY RUN' : 'EXECUTE',
        collections: [],
        summary: {
          totalCollections: 0,
          totalDocuments: 0,
          totalUpdated: 0,
          totalSubcollections: 0
        }
      };
      
      // 처리할 컬렉션 목록 결정
      let targetCollections = [];
      
      if (collections) {
        // 특정 컬렉션만 처리
        targetCollections = collections.split(',');
      } else {
        // 모든 컬렉션 가져오기
        const allCollections = await db.listCollections();
        targetCollections = allCollections.map(col => col.id);
      }
      
      // 각 컬렉션 처리
      for (const collectionName of targetCollections) {
        const collectionResult = await migrateCollectionWithSubcollections(
          collectionName, 
          isDryRun
        );
        
        results.collections.push(collectionResult);
        results.summary.totalDocuments += collectionResult.processed;
        results.summary.totalUpdated += collectionResult.updated;
        results.summary.totalSubcollections += collectionResult.subcollections.length;
      }
      
      results.summary.totalCollections = results.collections.length;
      
      logger.info('Database migration complete', results.summary);
      
      res.status(200).json({
        success: true,
        ...results
      });
      
    } catch (error) {
      logger.error('Database migration failed', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });