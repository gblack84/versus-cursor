/**
 * Voting Feature Zod Schemas
 *
 * - Vote (4 fields)
 * - PostVoting (23 fields, VoteStatus enum)
 *
 * @module voting_schema
 * @created 2025-11-02
 */

import { z } from 'zod';
import { baseSchema, validateWithContext } from './common_helpers';

// ============================================================================
// Vote Schema (4 fields)
// ============================================================================

export const VoteSchema = z.object({
  postId: z.string(),
  userId: z.string(),
  choice: z.enum(['A', 'B']),
  timestamp: z.date().optional(),
});

export type Vote = z.infer<typeof VoteSchema>;

export function validateVote(data: unknown): Vote {
  return validateWithContext(VoteSchema, data, 'Vote');
}

// ============================================================================
// VoteStatus Enum
// ============================================================================

export const VoteStatusSchema = z.enum([
  'pending',
  'active',
  'completed',
  'cancelled',
  'timeout',
]);

export type VoteStatus = z.infer<typeof VoteStatusSchema>;

// ============================================================================
// PostVoting Schema (23 fields)
// ============================================================================

export const PostVotingSchema = z.object({
  postId: z.string(),

  // Timing (6)
  voteStartTime: z.date().optional(),
  voteEndTime: z.date().optional(),
  voteCompletedAt: z.date().optional(),
  voteCancelledAt: z.date().optional(),
  voteTimeout: z.number().default(10 * 60 * 1000),  // milliseconds

  // Status (4)
  voteStatus: VoteStatusSchema.default('pending'),
  voteCompleted: z.boolean().default(false),
  voteCancelledReason: z.string().optional(),

  // Results (4)
  votesA: z.number().int().default(0),
  votesB: z.number().int().default(0),
  votedUserIdsA: z.array(z.string()).default([]),
  votedUserIdsB: z.array(z.string()).default([]),

  // Display (2)
  displayVotesA: z.number().optional(),
  displayVotesB: z.number().optional(),

  // Notifications (2)
  notificationsSent: z.boolean().default(false),
  notificationsSentAt: z.date().optional(),

  // Expansion (4)
  expansionPointsUsed: z.number().default(0),
  expandedUserCount: z.number().default(0),
  expansionStatus: z.enum(['none', 'pending', 'active', 'completed']).default('none'),
});

export type PostVoting = z.infer<typeof PostVotingSchema>;

export function validatePostVoting(data: unknown): PostVoting {
  return validateWithContext(PostVotingSchema, data, 'PostVoting');
}

export default {
  VoteSchema,
  VoteStatusSchema,
  PostVotingSchema,
  validateVote,
  validatePostVoting,
};
