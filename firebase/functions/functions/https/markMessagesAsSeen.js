const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * HTTPS Callable function to mark messages as seen
 * Called when a user opens a chat room
 */
exports.markMessagesAsSeen = functions.https.onCall(async (data, context) => {
  // Check authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to mark messages as seen'
    );
  }
  
  const { chatId } = data;
  const userId = context.auth.uid;
  
  if (!chatId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'chatId is required'
    );
  }
  
  try {
    const db = admin.firestore();
    
    // Get all messages in the chat that don't have seen_at timestamp yet
    // We'll filter sender_id in memory for better performance
    const messagesQuery = await db
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .where('seen_at', '==', null)
      .get();
    
    if (messagesQuery.empty) {
      console.log(`No unread messages found in chat ${chatId} for user ${userId}`);
      return { success: true, count: 0 };
    }
    
    // Filter messages not sent by current user and batch update
    const batch = db.batch();
    const seenTimestamp = admin.firestore.FieldValue.serverTimestamp();
    let updateCount = 0;
    
    messagesQuery.docs.forEach((doc) => {
      const messageData = doc.data();
      // Only update messages not sent by the current user
      if (messageData.sender_id && messageData.sender_id !== userId) {
        batch.update(doc.ref, {
          seen_at: seenTimestamp
        });
        updateCount++;
      }
    });
    
    // Only commit if there are updates to make
    if (updateCount > 0) {
      await batch.commit();
    }
    
    console.log(`Marked ${updateCount} messages as seen in chat ${chatId} for user ${userId}`);
    
    return { 
      success: true, 
      count: updateCount,
      timestamp: new Date().toISOString()
    };
    
  } catch (error) {
    console.error(`Error marking messages as seen in chat ${chatId}:`, error);
    throw new functions.https.HttpsError(
      'internal',
      'Failed to mark messages as seen',
      error.message
    );
  }
});