/**
 * HTTP 트리거로 snake_case → camelCase 마이그레이션 실행
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
  
  // Image moderation fields
  'image_url': 'imageUrl',
  'moderation_labels': 'moderationLabels',
  'is_safe': 'isSafe',
  'checked_at': 'checkedAt',
  'vision_api_response': 'visionApiResponse',
  'gemini_response': 'geminiResponse',
  'perspective_scores': 'perspectiveScores',
  
  // Additional post fields
  'question_title': 'questionTitle',
  'media_type': 'mediaType',
  'media_urls': 'mediaUrls',
  'aspect_ratio': 'aspectRatio',
  'vote_count_a': 'voteCountA',
  'vote_count_b': 'voteCountB',
  'total_votes': 'totalVotes',
  'voted_user_ids_a': 'votedUserIdsA',
  'voted_user_ids_b': 'votedUserIdsB',
  'display_votes_a': 'displayVotesA',
  'display_votes_b': 'displayVotesB',
  'actual_votes_a': 'actualVotesA',
  'actual_votes_b': 'actualVotesB',
  'vote_completed_at': 'voteCompletedAt',
  'last_vote_at': 'lastVoteAt',
  'migration_version': 'migrationVersion',
  'migrated_at': 'migratedAt',
  'creator_info': 'creatorInfo',
  
  // Notification fields
  'parent_id': 'parentId',
  'read_by': 'readBy',
  'processed_at': 'processedAt',
  'user_profiles': 'userProfiles',
  'actual_recipient_count': 'actualRecipientCount',
  'initial_targets': 'initialTargets',
  'retry_count': 'retryCount',
  'retry_ids': 'retryIds',
  'failed_ids': 'failedIds',
  'recipient_ids': 'recipientIds',
  'processed_count': 'processedCount',
  'failed_count': 'failedCount',
  'total_recipients': 'totalRecipients',
  'send_completed': 'sendCompleted',
  'send_started_at': 'sendStartedAt',
  'send_completed_at': 'sendCompletedAt',
  'next_batch_index': 'nextBatchIndex',
  'success_ids': 'successIds',
  'filtered_users': 'filteredUsers',
  'batch_index': 'batchIndex',
  'notification_id': 'notificationId',
  'actual_notifications_sent': 'actualNotificationsSent',
  'filtered_recipient_count': 'filteredRecipientCount',
  'matching_users': 'matchingUsers',
  'selected_recipients': 'selectedRecipients',
  'target_count': 'targetCount',
  'target_ids': 'targetIds',
  
  // Additional user fields
  'follower_count': 'followerCount',
  'following_count': 'followingCount',
  'post_count': 'postCount',
  'saved_posts': 'savedPosts',
  'saved_posts_count': 'savedPostsCount',
  'blocked_users': 'blockedUsers',
  'blocked_by': 'blockedBy',
  'notification_settings': 'notificationSettings',
  'privacy_settings': 'privacySettings',
  'profile_complete': 'profileComplete',
  'email_verified': 'emailVerified',
  'phone_verified': 'phoneVerified',
  'account_status': 'accountStatus',
  'account_created_at': 'accountCreatedAt',
  'last_login': 'lastLogin',
  'login_count': 'loginCount',
  'device_tokens': 'deviceTokens',
  
  // AI related fields
  'ai_chat_id': 'aiChatId',
  'ai_messages': 'aiMessages',
  'ai_response': 'aiResponse',
  'ai_score': 'aiScore',
  'ai_analysis': 'aiAnalysis',
  'ai_suggestions': 'aiSuggestions',
  'ai_model': 'aiModel',
  'ai_version': 'aiVersion',
  
  // Engagement fields
  'view_count': 'viewCount',
  'engagement_rate': 'engagementRate',
  'click_count': 'clickCount',
  'report_count': 'reportCount',
  'report_reasons': 'reportReasons',
  'reported_by': 'reportedBy',
  'share_link': 'shareLink',
  'short_link': 'shortLink',
  
  // Media fields
  'video_url': 'videoUrl',
  'video_thumbnail': 'videoThumbnail',
  'video_duration': 'videoDuration',
  'media_count': 'mediaCount',
  'media_positions': 'mediaPositions',
  'youtube_url': 'youtubeUrl',
  'youtube_id': 'youtubeId',
  
  // Settings and preferences
  'notification_enabled': 'notificationEnabled',
  'email_notifications': 'emailNotifications',
  'push_notifications': 'pushNotifications',
  'sms_notifications': 'smsNotifications',
  'dark_mode': 'darkMode',
  'language_preference': 'languagePreference',
  'time_zone': 'timeZone',
  
  // Character and profile fields
  'character_id': 'characterId',
  'character_name': 'characterName',
  'character_image': 'characterImage',
  'profile_completion': 'profileCompletion',
  'profile_views': 'profileViews',
  'profile_image': 'profileImage',
  'background_image': 'backgroundImage',
  
  // Status and flags
  'is_active': 'isActive',
  'is_deleted': 'isDeleted',
  'is_suspended': 'isSuspended',
  'is_verified': 'isVerified',
  'is_online': 'isOnline',
  'is_typing': 'isTyping',
  'is_blocked': 'isBlocked',
  'is_reported': 'isReported',
  'is_featured': 'isFeatured',
  'is_trending': 'isTrending',
  'is_pinned': 'isPinned',
  'is_archived': 'isArchived',
  'is_draft': 'isDraft',
  'is_published': 'isPublished',
  'is_private': 'isPrivate',
  'is_public': 'isPublic',
  
  // Timestamps
  'deleted_at': 'deletedAt',
  'suspended_at': 'suspendedAt',
  'verified_at': 'verifiedAt',
  'last_seen': 'lastSeen',
  'typing_started_at': 'typingStartedAt',
  'published_at': 'publishedAt',
  'archived_at': 'archivedAt',
  'pinned_at': 'pinnedAt',
  'featured_at': 'featuredAt',
  
  // Vote and poll specific
  'poll_id': 'pollId',
  'poll_type': 'pollType',
  'poll_options': 'pollOptions',
  'poll_results': 'pollResults',
  'poll_duration': 'pollDuration',
  'poll_end_time': 'pollEndTime',
  'allow_multiple': 'allowMultiple',
  'show_results': 'showResults',
  'results_visible': 'resultsVisible',
  
  // Meta fields
  'meta_data': 'metaData',
  'meta_title': 'metaTitle',
  'meta_description': 'metaDescription',
  'meta_keywords': 'metaKeywords',
  'meta_image': 'metaImage',
  'og_title': 'ogTitle',
  'og_description': 'ogDescription',
  'og_image': 'ogImage',
  
  // Analytics fields
  'analytics_id': 'analyticsId',
  'tracking_id': 'trackingId',
  'session_id': 'sessionId',
  'event_type': 'eventType',
  'event_value': 'eventValue',
  'event_timestamp': 'eventTimestamp',
  'user_agent': 'userAgent',
  'ip_address': 'ipAddress',
  'device_type': 'deviceType',
  'device_id': 'deviceId',
  'platform_type': 'platformType',
  
  // Payment and subscription
  'subscription_id': 'subscriptionId',
  'subscription_status': 'subscriptionStatus',
  'subscription_plan': 'subscriptionPlan',
  'subscription_start': 'subscriptionStart',
  'subscription_end': 'subscriptionEnd',
  'payment_method': 'paymentMethod',
  'payment_status': 'paymentStatus',
  'payment_amount': 'paymentAmount',
  'payment_currency': 'paymentCurrency',
  'payment_date': 'paymentDate',
  
  // Additional unmapped fields from debug output
  'expected_ratio_a': 'expectedRatioA',
  'expected_ratio_b': 'expectedRatioB',
  'is_premium': 'isPremium',
  'should_create_test_notification': 'shouldCreateTestNotification',
  'test_user_id': 'testUserId',
  'test_mode_auto_complete': 'testModeAutoComplete',
  'test_mode_target_count': 'testModeTargetCount',
  'actual_total_votes': 'actualTotalVotes',
  'display_percent_a': 'displayPercentA',
  'display_percent_b': 'displayPercentB',
  'notification_type_new': 'notificationTypeNew',
  'notification_text': 'notificationText',
  'auto_complete_at': 'autoCompleteAt',
  'selected_option': 'selectedOption',
  'throttle_buffer': 'throttleBuffer',
  'throttle_queue_position': 'throttleQueuePosition',
  'throttle_status': 'throttleStatus',
  'throttle_processing_at': 'throttleProcessingAt',
  'pending_deletion': 'pendingDeletion',
  'expiry_time': 'expiryTime',
  
  // Other miscellaneous fields
  'app_version': 'appVersion',
  'api_version': 'apiVersion',
  'build_number': 'buildNumber',
  'source_type': 'sourceType',
  'source_id': 'sourceId',
  'external_id': 'externalId',
  'internal_id': 'internalId',
  'legacy_id': 'legacyId',
  'import_id': 'importId',
  'export_id': 'exportId',
  'batch_id': 'batchId',
  'job_id': 'jobId',
  'task_id': 'taskId',
  'workflow_id': 'workflowId',
  'process_id': 'processId',
  'thread_id': 'threadId',
  'channel_id': 'channelId',
  'room_id': 'roomId',
  'space_id': 'spaceId',
  'workspace_id': 'workspaceId',
  'organization_id': 'organizationId',
  'team_id': 'teamId',
  'project_id': 'projectId',
  'client_id': 'clientId',
  'customer_id': 'customerId',
  'merchant_id': 'merchantId',
  'vendor_id': 'vendorId',
  'partner_id': 'partnerId',
  
  // New unmapped fields from debug
  // Posts collection
  'test_mode_status': 'testModeStatus',
  'test_mode_user_choice': 'testModeUserChoice',
  'test_mode_user_voted_at': 'testModeUserVotedAt',
  
  // Notifications collection
  'action_url': 'actionUrl',
  
  // Users collection  
  'vote_ai_chat_id': 'voteAiChatId',
  'ai_chats_created_at': 'aiChatsCreatedAt',
  'helper_ai_chat_id': 'helperAiChatId',
  'ai_chats_created': 'aiChatsCreated',
  
  // Chats collection
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
  'ai_helper': 'aiHelper'
};

// userId를 snake_case에서 camelCase로 변환하는 헬퍼 함수
function convertUserId(userId) {
  // 특별한 ID들은 그대로 유지
  if (userId === 'ai_assistant' || userId === 'ai_helper') {
    return userId;
  }
  
  // snake_case userId를 camelCase로 변환
  // 예: 4j_qif7_f5i5dh_ba3_hrs4r_mv_w_ax_rx2 → 4jQif7F5i5dhBa3Hrs4rMvWAxRx2
  if (userId && userId.includes('_')) {
    return userId.split('_').map((part, index) => {
      if (index === 0) return part;
      return part.charAt(0).toUpperCase() + part.slice(1).toLowerCase();
    }).join('');
  }
  
  return userId;
}

// 변환 함수
function convertFieldNames(data, parentKey = '') {
  if (!data || typeof data !== 'object') {
    return data;
  }
  
  const converted = {};
  let hasChanges = false;
  
  for (const [key, value] of Object.entries(data)) {
    let newKey = FIELD_MAPPINGS[key] || key;
    
    // 특별한 경우: participantNames나 unreadCount 내부의 동적 userId 키들
    if ((parentKey === 'participantNames' || parentKey === 'participant_names' || 
         parentKey === 'unreadCount' || parentKey === 'lastReadTimestamps') && 
        key.includes('_') && !['ai_assistant', 'ai_helper', 'aiAssistant', 'aiHelper'].includes(key)) {
      newKey = convertUserId(key);
    }
    
    if (newKey !== key) {
      hasChanges = true;
    }
    
    // 중첩된 객체 처리
    if (value && typeof value === 'object' && !Array.isArray(value) && 
        !(value instanceof Date) && !(value._seconds !== undefined)) {
      const result = convertFieldNames(value, newKey);
      if (result && typeof result === 'object' && 'data' in result) {
        converted[newKey] = result.data;
        if (result.hasChanges) hasChanges = true;
      } else {
        converted[newKey] = result;
      }
    } else {
      converted[newKey] = value;
    }
  }
  
  return { data: converted, hasChanges };
}

// 컬렉션 마이그레이션 (페이징 처리 포함)
async function migrateCollection(collectionName, isDryRun = true, batchSize = 500) {
  const logger = createLogger('migrateSnakeToCamel');
  logger.info(`Processing collection: ${collectionName}`);
  
  const db = admin.firestore();
  const collection = db.collection(collectionName);
  
  let processed = 0;
  let updated = 0;
  let lastDoc = null;
  let hasMore = true;
  
  while (hasMore) {
    // 페이징 쿼리 구성
    let query = collection.orderBy(admin.firestore.FieldPath.documentId()).limit(batchSize);
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    
    const snapshot = await query.get();
    
    if (snapshot.empty) {
      hasMore = false;
      break;
    }
    
    let batch = db.batch();
    let batchCount = 0;
    
    for (const doc of snapshot.docs) {
      processed++;
      const originalData = doc.data();
      const { data: convertedData, hasChanges } = convertFieldNames(originalData);
      
      if (hasChanges) {
        updated++;
        
        if (!isDryRun) {
          // 전체 문서를 새로운 데이터로 덮어쓰기 (merge: false)
          batch.set(doc.ref, convertedData, { merge: false });
          batchCount++;
          
          // Firestore batch limit is 500
          if (batchCount === 500) {
            await batch.commit();
            logger.info(`Committed batch of ${batchCount} updates in ${collectionName}`);
            batchCount = 0;
            // 새 배치 시작
            batch = db.batch();
          }
        }
      }
      
      lastDoc = doc;
    }
    
    // 남은 업데이트 커밋
    if (!isDryRun && batchCount > 0) {
      await batch.commit();
      logger.info(`Committed batch of ${batchCount} updates in ${collectionName}`);
    }
    
    // 가져온 문서가 batchSize보다 적으면 마지막 배치
    if (snapshot.docs.length < batchSize) {
      hasMore = false;
    }
    
    logger.info(`Progress: ${collectionName} - Processed: ${processed}, Updated: ${updated}`);
  }
  
  logger.info(`Completed ${collectionName}: Total processed: ${processed}, Total updated: ${updated}`);
  return { processed, updated };
}

exports.migrateSnakeToCamel = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 540, // 9분 타임아웃
    memory: '1GB'
  })
  .https.onRequest(async (req, res) => {
    const logger = createLogger('migrateSnakeToCamel');
    
    try {
      const { mode = 'dryrun', collections = '', batchSize = '500' } = req.query;
      const isDryRun = mode !== 'execute';
      
      logger.info('Starting migration', { 
        mode: isDryRun ? 'DRY RUN' : 'EXECUTE', 
        collections,
        batchSize 
      });
      
      // 마이그레이션할 컬렉션 목록
      const targetCollections = collections ? collections.split(',') : [
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
      
      for (const collectionName of targetCollections) {
        try {
          const result = await migrateCollection(
            collectionName, 
            isDryRun, 
            parseInt(batchSize)
          );
          stats.collections[collectionName] = result;
          stats.totalProcessed += result.processed;
          stats.totalUpdated += result.updated;
        } catch (error) {
          logger.error(`Error processing ${collectionName}`, error);
          stats.collections[collectionName] = { error: error.message };
        }
      }
      
      const response = {
        success: true,
        mode: isDryRun ? 'DRY_RUN' : 'EXECUTED',
        timestamp: new Date().toISOString(),
        stats
      };
      
      logger.info('Migration completed', response);
      res.status(200).json(response);
      
    } catch (error) {
      logger.error('Migration failed', error);
      res.status(500).json({
        success: false,
        error: error.message
      });
    }
  });