# Chat Detail Widget Integration Guide

This document explains how to integrate the voting request message component into the chat detail page.

## Vote Request Message Component

The `VoteRequestMessage` component is designed to display voting requests within the chat interface. It supports:

- Title and description
- Two options (A vs B) with text and optional images
- Status indicators (pending, completed, expired)
- Sender distinction (different styling for sent vs received messages)

## Usage Example

To display a vote request message in the chat:

```dart
// In your chat messages list builder
if (message.messageType == 'vote_request') {
  return VoteRequestMessage(
    postTitle: message.voteTitle,
    postDescription: message.voteDescription,
    optionA: message.optionAText,
    optionB: message.optionBText,
    imageUrlA: message.optionAImage,
    imageUrlB: message.optionBImage,
    isMe: message.senderId == currentUserUid,
    timestamp: message.timeStamp,
    voteStatus: _getVoteStatus(message),
    onTap: () {
      // Navigate to voting page or show voting dialog
      context.pushNamed(
        'voting_page',
        queryParameters: {
          'postId': message.postId,
        },
      );
    },
  );
} else {
  // Regular text message
  return _buildTextMessage(message);
}
```

## Message Structure

To support vote requests in the chat, the message document should include:

```dart
{
  'message_type': 'vote_request', // or 'text' for regular messages
  'sender_id': 'user123',
  'content': 'Please vote on this!', // For regular text messages
  'vote_title': 'Coffee or Tea?', // For vote requests
  'vote_description': 'Which do you prefer in the morning?',
  'option_a_text': 'Coffee',
  'option_b_text': 'Tea',
  'option_a_image': 'https://...', // Optional
  'option_b_image': 'https://...', // Optional
  'post_id': 'post123', // Reference to the actual post
  'vote_status': 'pending', // pending, completed, expired
  'time_stamp': Timestamp.now(),
}
```

## Integration Steps

1. **Update MessagesRecord Schema**: Add fields for vote request data
2. **Modify Chat Detail Widget**: Add conditional rendering based on message type
3. **Create Vote Request**: When a user sends a vote request, create a message with type 'vote_request'
4. **Handle Tap Action**: Navigate to the voting page or show voting interface

## Notifications Integration

When a vote request is received through the notification system:

1. Create a chat conversation if it doesn't exist
2. Add the vote request as a message in the chat
3. Update the chat's last message to show the vote request
4. Navigate user to the chat when they tap the notification

This allows users to see all their voting interactions in one place and provides a conversation history around each voting request.