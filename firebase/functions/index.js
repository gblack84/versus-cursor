/**
 * Firebase Functions 진입점
 * 모든 함수들을 import하여 export
 */

// Auth 함수
const { onUserDeleted } = require('./functions/auth/onUserDeleted');

// Storage 함수
const { moderateImage } = require('./functions/storage/moderateImage');

// HTTPS 함수
const { checkImageContent } = require('./functions/https/checkImageContent');
const { validatePostContentWithGemini } = require('./functions/https/validatePostContentWithGemini');
const { testCreateAIChatMessage } = require('./functions/https/testCreateAIChatMessage');
const { migrateAIChatRooms } = require('./functions/https/migrateAIChatRooms');
const { migrateVoteData } = require('./functions/https/migrateVoteData');

// Firestore 함수
const { onPostCreatedSendNotifications } = require('./functions/firestore/onPostCreatedSendNotifications');
const { onPostVoteUpdate } = require('./functions/firestore/onPostVoteUpdate');

// Scheduled 함수
const { flushThrottleQueue } = require('./functions/scheduled/flushThrottleQueue');

// 기존 함수들 (아직 이동되지 않은 경우 - 향후 제거 예정)
const { getUserPostingHistory } = require('./ai/userHistoryAnalyzer');

// 모든 함수 export
module.exports = {
  // Auth
  onUserDeleted,
  
  // Storage
  moderateImage,
  
  // HTTPS
  checkImageContent,
  validatePostContentWithGemini,
  testCreateAIChatMessage,
  migrateAIChatRooms,
  migrateVoteData,
  
  // Firestore
  onPostCreatedSendNotifications,
  onPostVoteUpdate,
  
  // Scheduled
  flushThrottleQueue,
  
  // AI (임시)
  getUserPostingHistory
};