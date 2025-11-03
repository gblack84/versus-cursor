/**
 * Chat Feature Zod Schemas
 *
 * - Chat (17 fields)
 * - Message (45 fields, Vote Card 내장)
 *
 * @module chat_schema
 * @created 2025-11-02
 */

import { z } from 'zod';
import {
  baseSchema,
  parseStringArray,
  parseTimestampMap,
  validateWithContext,
} from './common_helpers';

// ============================================================================
// Chat Schema (17 fields)
// ============================================================================

export const ChatSchema = baseSchema.extend({
  chatId: z.string(),
  chatType: z.enum(['1:1', 'direct', 'group']).default('direct'),
  participantIds: z.array(z.string()),
  chatName: z.string(),
  lastMessageContent: z.string(),
  lastMessageAt: z.date().optional(),
  isRead: z.boolean().default(false),
  lastReadTimestamps: z.record(z.string(), z.date()),  // Map<userId, DateTime>
});

export type Chat = z.infer<typeof ChatSchema>;

export function validateChat(data: unknown): Chat {
  return validateWithContext(ChatSchema, data, 'Chat');
}

// ============================================================================
// Message Schema (45 fields, Vote Card 포함)
// ============================================================================

export const MessageSchema = baseSchema.extend({
  parentPath: z.string(),
  messageId: z.string(),
  senderId: z.string(),
  content: z.string(),
  messageType: z.enum(['text', 'image', 'video', 'vote_request']).default('text'),

  // Media fields (8)
  mediaType: z.enum(['text', 'image', 'video']).default('text'),
  imageUrl: z.string().optional(),
  videoUrl: z.string().optional(),
  thumbnailUrl: z.string().optional(),
  mediaSize: z.number().default(0),
  mediaWidth: z.number().optional(),
  mediaHeight: z.number().optional(),

  // Lifecycle (4)
  timeStamp: z.date().optional(),
  deliveredAt: z.date().optional(),
  seenAt: z.date().optional(),
  isRead: z.boolean().default(false),

  // Vote Card fields (10)
  votePostId: z.string().optional(),
  voteTitle: z.string().optional(),
  voteOptionAText: z.string().optional(),
  voteOptionBText: z.string().optional(),
  voteOptionAImages: z.array(z.string()).optional(),
  voteOptionBImages: z.array(z.string()).optional(),
  voteStatus: z.enum(['pending', 'completed', 'expired']).default('pending'),
  voteEndTime: z.date().optional(),
  voteResults: z.record(z.string(), z.any()).optional(),
  userVotes: z.record(z.string(), z.any()).optional(),
});

export type Message = z.infer<typeof MessageSchema>;

export function validateMessage(data: unknown): Message {
  return validateWithContext(MessageSchema, data, 'Message');
}

export default {
  ChatSchema,
  MessageSchema,
  validateChat,
  validateMessage,
};
