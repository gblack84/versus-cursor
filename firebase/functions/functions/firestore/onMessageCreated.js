const functions = require('firebase-functions');
const admin = require('firebase-admin');

/**
 * Cloud Function triggered when a new message is created
 * Automatically sets delivered_at timestamp
 */
exports.onMessageCreated = functions.firestore
  .document('chats/{chatId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    const messageData = snap.data();
    const { chatId, messageId } = context.params;
    
    // If delivered_at already exists, skip
    if (messageData.delivered_at) {
      console.log(`Message ${messageId} already has delivered_at`);
      return null;
    }
    
    try {
      // Update the message with delivered_at timestamp
      await snap.ref.update({
        delivered_at: admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log(`Set delivered_at for message ${messageId} in chat ${chatId}`);
      return null;
    } catch (error) {
      console.error(`Error setting delivered_at for message ${messageId}:`, error);
      return null;
    }
  });