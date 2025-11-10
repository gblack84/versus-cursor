/**
 * Voting Feature Zod Schemas
 *
 * Vote와 PostVoting 엔티티의 TypeScript 타입 정의 및 Firestore 변환
 *
 * @module voting_schema
 * @created 2025-11-02
 * @updated 2025-11-10
 * @feature Voting
 *
 * @entities
 * - Vote: 투표 기록 (4 fields)
 * - PostVoting: 투표 비즈니스 로직 (23 fields)
 *
 * @references
 * - Flutter: lib/features/voting/domain/entities/vote.dart
 * - Analysis: backend/analysis/entity_analysis.md
 */

import { z } from 'zod';
import * as admin from 'firebase-admin';
import {
  parseTimestamp,
  toFirestoreTimestamp,
  parseStringArray,
  parseIntSafe,
  validateWithContext,
  validateSafe,
} from './common_helpers';

// ============================================================================
// Vote Schema (4 fields)
// ============================================================================

/**
 * Vote - 투표 기록
 *
 * **Field Configuration** (4 fields):
 * - `postId`: 투표 대상 Post ID
 * - `userId`: 투표한 사용자 ID
 * - `choice`: 투표 선택지 ('A' or 'B')
 * - `timestamp`: 투표 시각 (optional)
 *
 * **Unique Aspects**:
 * - ✅ Simplest entity (4 fields)
 * - ✅ Composite key pattern (postId + userId)
 * - ✅ Vote record only
 *
 * **Flutter Entity**:
 * ```dart
 * @freezed
 * class Vote with _$Vote {
 *   const factory Vote({
 *     required String postId,
 *     required String userId,
 *     required String choice,  // 'A' or 'B'
 *     DateTime? timestamp,
 *   }) = _Vote;
 * }
 * ```
 *
 * **Firestore Path**: `/posts/{postId}/votes/{userId}`
 *
 * **Usage Example**:
 * ```typescript
 * const vote = VoteSchema.parse({
 *   postId: 'post123',
 *   userId: 'user456',
 *   choice: 'A',
 *   timestamp: new Date(),
 * });
 * ```
 */
export const VoteSchema = z.object({
  postId: z.string().describe("투표 대상 Post ID"),
  userId: z.string().describe("투표한 사용자 ID"),
  choice: z.enum(['A', 'B']).describe("투표 선택지 (A 또는 B)"),
  timestamp: z.date().optional().describe("투표 시각"),
});

export type Vote = z.infer<typeof VoteSchema>;

// ============================================================================
// VoteStatus Enum
// ============================================================================

/**
 * VoteStatus - 투표 상태 Enum
 *
 * **Values**:
 * - `pending`: 투표 시작 대기 중
 * - `active`: 투표 진행 중
 * - `completed`: 투표 완료
 * - `cancelled`: 투표 취소됨
 * - `timeout`: 시간 초과로 종료
 *
 * **Flutter Mapping**:
 * ```dart
 * enum VoteStatus {
 *   pending('pending'),
 *   active('active'),
 *   completed('completed'),
 *   cancelled('cancelled'),
 *   timeout('timeout');
 * }
 * ```
 */
export enum VoteStatus {
  Pending = 'pending',
  Active = 'active',
  Completed = 'completed',
  Cancelled = 'cancelled',
  Timeout = 'timeout',
}

export const voteStatusSchema = z.nativeEnum(VoteStatus);

// ============================================================================
// PostVoting Schema (23 fields)
// ============================================================================

/**
 * PostVoting - 투표 비즈니스 로직
 *
 * **Field Configuration** (23 fields):
 *
 * **1. Identification** (1 field):
 * - `postId`: Post ID
 *
 * **2. Timing** (6 fields):
 * - `voteStartTime`: 투표 시작 시각
 * - `voteEndTime`: 투표 종료 시각
 * - `voteCompletedAt`: 투표 완료 시각
 * - `voteCancelledAt`: 투표 취소 시각
 * - `voteTimeout`: 투표 제한 시간 (milliseconds)
 * - `timerExpiryAt`: 타이머 만료 시각
 *
 * **3. Status** (4 fields):
 * - `voteStatus`: 투표 상태 (Enum)
 * - `voteCompleted`: 완료 여부
 * - `voteCancelledReason`: 취소 사유
 * - `voteRequestStatus`: 요청 상태
 *
 * **4. Results** (4 fields):
 * - `votesA`: A 선택 투표 수
 * - `votesB`: B 선택 투표 수
 * - `votedUserIdsA`: A 투표 사용자 ID 배열
 * - `votedUserIdsB`: B 투표 사용자 ID 배열
 *
 * **5. Display** (2 fields):
 * - `displayVotesA`: A 표시용 투표 수 (증폭된 수)
 * - `displayVotesB`: B 표시용 투표 수 (증폭된 수)
 *
 * **6. Notifications** (2 fields):
 * - `notificationsSent`: 알림 전송 완료 여부
 * - `notificationsSentAt`: 알림 전송 시각
 *
 * **7. Expansion** (4 fields):
 * - `expansionPointsUsed`: 확장에 사용된 포인트
 * - `expandedUserCount`: 확장된 사용자 수
 * - `expansionStatus`: 확장 상태
 * - `timerStartedAt`: 타이머 시작 시각
 *
 * **Unique Aspects**:
 * - ✅ Uses Enum (VoteStatus)
 * - ✅ Duration → milliseconds conversion (voteTimeout)
 * - ✅ Complex business logic (notifications, expansion)
 *
 * **Flutter Entity**:
 * ```dart
 * @freezed
 * class PostVoting with _$PostVoting {
 *   const factory PostVoting({
 *     required String postId,
 *     DateTime? voteStartTime,
 *     DateTime? voteEndTime,
 *     // ... 23 fields total
 *     VoteStatus? voteStatus,
 *   }) = _PostVoting;
 * }
 * ```
 *
 * **Firestore Path**: `/posts/{postId}` (embedded in Post document)
 *
 * **Usage Example**:
 * ```typescript
 * const postVoting = PostVotingSchema.parse({
 *   postId: 'post123',
 *   voteStatus: VoteStatus.Active,
 *   votesA: 10,
 *   votesB: 8,
 *   voteStartTime: new Date(),
 *   voteEndTime: new Date(Date.now() + 86400000), // +1 day
 *   // ... other fields
 * });
 * ```
 */
export const PostVotingSchema = z.object({
  // 1. Identification (1 field)
  postId: z.string().describe("Post ID"),

  // 2. Timing (6 fields)
  voteStartTime: z.date().optional().describe("투표 시작 시각"),
  voteEndTime: z.date().optional().describe("투표 종료 시각"),
  voteCompletedAt: z.date().optional().describe("투표 완료 시각"),
  voteCancelledAt: z.date().optional().describe("투표 취소 시각"),
  voteTimeout: z
    .number()
    .int()
    .positive()
    .optional()
    .describe("투표 제한 시간 (milliseconds, Duration 변환)"),
  timerExpiryAt: z.date().optional().describe("타이머 만료 시각"),

  // 3. Status (4 fields)
  voteStatus: voteStatusSchema.optional().describe("투표 상태 (Enum)"),
  voteCompleted: z.boolean().optional().describe("투표 완료 여부"),
  voteCancelledReason: z.string().optional().describe("투표 취소 사유"),
  voteRequestStatus: z.string().optional().describe("투표 요청 상태"),

  // 4. Results (4 fields)
  votesA: z.number().int().nonnegative().optional().describe("A 선택 투표 수"),
  votesB: z.number().int().nonnegative().optional().describe("B 선택 투표 수"),
  votedUserIdsA: z.array(z.string()).optional().describe("A 투표 사용자 ID 배열"),
  votedUserIdsB: z.array(z.string()).optional().describe("B 투표 사용자 ID 배열"),

  // 5. Display (2 fields)
  displayVotesA: z
    .number()
    .int()
    .nonnegative()
    .optional()
    .describe("A 표시용 투표 수 (증폭된 수)"),
  displayVotesB: z
    .number()
    .int()
    .nonnegative()
    .optional()
    .describe("B 표시용 투표 수 (증폭된 수)"),

  // 6. Notifications (2 fields)
  notificationsSent: z.boolean().optional().describe("알림 전송 완료 여부"),
  notificationsSentAt: z.date().optional().describe("알림 전송 시각"),

  // 7. Expansion (4 fields)
  expansionPointsUsed: z
    .number()
    .int()
    .nonnegative()
    .optional()
    .describe("확장에 사용된 포인트"),
  expandedUserCount: z
    .number()
    .int()
    .nonnegative()
    .optional()
    .describe("확장된 사용자 수"),
  expansionStatus: z.string().optional().describe("확장 상태"),
  timerStartedAt: z.date().optional().describe("타이머 시작 시각"),
});

export type PostVoting = z.infer<typeof PostVotingSchema>;

// ============================================================================
// Firestore Converters
// ============================================================================

/**
 * Firestore DocumentData → Vote
 *
 * **Usage**:
 * ```typescript
 * const voteDoc = await firestore.collection('posts').doc(postId).collection('votes').doc(userId).get();
 * const vote = fromFirestoreVote(voteDoc.id, voteDoc.data());
 * ```
 *
 * @param voteId - Vote document ID (userId)
 * @param data - Firestore document data
 * @returns Vote entity
 */
export function fromFirestoreVote(voteId: string, data: any): Vote {
  return validateWithContext(
    VoteSchema,
    {
      postId: data.postId || '',
      userId: voteId,
      choice: data.choice || data.option || 'A', // Legacy: option → choice
      timestamp: parseTimestamp(data.timestamp || data.createdAt),
    },
    'Vote'
  );
}

/**
 * Vote → Firestore DocumentData
 *
 * **Usage**:
 * ```typescript
 * const vote: Vote = { postId: 'post123', userId: 'user456', choice: 'A', timestamp: new Date() };
 * const data = toFirestoreVote(vote);
 * await firestore.collection('posts').doc(vote.postId).collection('votes').doc(vote.userId).set(data);
 * ```
 *
 * @param vote - Vote entity
 * @returns Firestore document data
 */
export function toFirestoreVote(vote: Vote): Record<string, any> {
  return {
    postId: vote.postId,
    choice: vote.choice,
    timestamp: toFirestoreTimestamp(vote.timestamp) || admin.firestore.FieldValue.serverTimestamp(),
  };
}

/**
 * Firestore DocumentData → PostVoting
 *
 * **Usage**:
 * ```typescript
 * const postDoc = await firestore.collection('posts').doc(postId).get();
 * const postVoting = fromFirestorePostVoting(postDoc.id, postDoc.data());
 * ```
 *
 * @param postId - Post document ID
 * @param data - Firestore document data
 * @returns PostVoting entity
 */
export function fromFirestorePostVoting(postId: string, data: any): PostVoting {
  return validateWithContext(
    PostVotingSchema,
    {
      // 1. Identification
      postId,

      // 2. Timing
      voteStartTime: parseTimestamp(data.voteStartTime),
      voteEndTime: parseTimestamp(data.voteEndTime),
      voteCompletedAt: parseTimestamp(data.voteCompletedAt),
      voteCancelledAt: parseTimestamp(data.voteCancelledAt),
      voteTimeout: parseIntSafe(data.voteTimeout, undefined),
      timerExpiryAt: parseTimestamp(data.timerExpiryAt),

      // 3. Status
      voteStatus: data.voteStatus as VoteStatus | undefined,
      voteCompleted: data.voteCompleted ?? false,
      voteCancelledReason: data.voteCancelledReason,
      voteRequestStatus: data.voteRequestStatus,

      // 4. Results
      votesA: parseIntSafe(data.votesA, 0),
      votesB: parseIntSafe(data.votesB, 0),
      votedUserIdsA: parseStringArray(data.votedUserIdsA),
      votedUserIdsB: parseStringArray(data.votedUserIdsB),

      // 5. Display
      displayVotesA: parseIntSafe(data.displayVotesA, undefined),
      displayVotesB: parseIntSafe(data.displayVotesB, undefined),

      // 6. Notifications
      notificationsSent: data.notificationsSent ?? false,
      notificationsSentAt: parseTimestamp(data.notificationsSentAt),

      // 7. Expansion
      expansionPointsUsed: parseIntSafe(data.expansionPointsUsed, 0),
      expandedUserCount: parseIntSafe(data.expandedUserCount, 0),
      expansionStatus: data.expansionStatus,
      timerStartedAt: parseTimestamp(data.timerStartedAt),
    },
    'PostVoting'
  );
}

/**
 * PostVoting → Firestore DocumentData
 *
 * **Usage**:
 * ```typescript
 * const postVoting: PostVoting = { ... };
 * const data = toFirestorePostVoting(postVoting);
 * await firestore.collection('posts').doc(postVoting.postId).update(data);
 * ```
 *
 * @param postVoting - PostVoting entity
 * @returns Firestore document data
 */
export function toFirestorePostVoting(postVoting: PostVoting): Record<string, any> {
  return {
    // 2. Timing
    ...(postVoting.voteStartTime && { voteStartTime: toFirestoreTimestamp(postVoting.voteStartTime) }),
    ...(postVoting.voteEndTime && { voteEndTime: toFirestoreTimestamp(postVoting.voteEndTime) }),
    ...(postVoting.voteCompletedAt && {
      voteCompletedAt: toFirestoreTimestamp(postVoting.voteCompletedAt),
    }),
    ...(postVoting.voteCancelledAt && {
      voteCancelledAt: toFirestoreTimestamp(postVoting.voteCancelledAt),
    }),
    ...(postVoting.voteTimeout !== undefined && { voteTimeout: postVoting.voteTimeout }),
    ...(postVoting.timerExpiryAt && { timerExpiryAt: toFirestoreTimestamp(postVoting.timerExpiryAt) }),

    // 3. Status
    ...(postVoting.voteStatus && { voteStatus: postVoting.voteStatus }),
    ...(postVoting.voteCompleted !== undefined && { voteCompleted: postVoting.voteCompleted }),
    ...(postVoting.voteCancelledReason && { voteCancelledReason: postVoting.voteCancelledReason }),
    ...(postVoting.voteRequestStatus && { voteRequestStatus: postVoting.voteRequestStatus }),

    // 4. Results
    ...(postVoting.votesA !== undefined && { votesA: postVoting.votesA }),
    ...(postVoting.votesB !== undefined && { votesB: postVoting.votesB }),
    ...(postVoting.votedUserIdsA && { votedUserIdsA: postVoting.votedUserIdsA }),
    ...(postVoting.votedUserIdsB && { votedUserIdsB: postVoting.votedUserIdsB }),

    // 5. Display
    ...(postVoting.displayVotesA !== undefined && { displayVotesA: postVoting.displayVotesA }),
    ...(postVoting.displayVotesB !== undefined && { displayVotesB: postVoting.displayVotesB }),

    // 6. Notifications
    ...(postVoting.notificationsSent !== undefined && {
      notificationsSent: postVoting.notificationsSent,
    }),
    ...(postVoting.notificationsSentAt && {
      notificationsSentAt: toFirestoreTimestamp(postVoting.notificationsSentAt),
    }),

    // 7. Expansion
    ...(postVoting.expansionPointsUsed !== undefined && {
      expansionPointsUsed: postVoting.expansionPointsUsed,
    }),
    ...(postVoting.expandedUserCount !== undefined && {
      expandedUserCount: postVoting.expandedUserCount,
    }),
    ...(postVoting.expansionStatus && { expansionStatus: postVoting.expansionStatus }),
    ...(postVoting.timerStartedAt && { timerStartedAt: toFirestoreTimestamp(postVoting.timerStartedAt) }),
  };
}

// ============================================================================
// Validation Helpers
// ============================================================================

/**
 * Validate Vote data (safe validation)
 *
 * @param data - Data to validate
 * @returns Validation result
 *
 * @example
 * ```typescript
 * const result = validateVote(data);
 * if (result.success) {
 *   console.log('Valid vote:', result.data);
 * } else {
 *   console.error('Invalid vote:', result.error.errors);
 * }
 * ```
 */
export function validateVote(
  data: unknown
): { success: true; data: Vote } | { success: false; error: z.ZodError } {
  return validateSafe(VoteSchema, data);
}

/**
 * Validate PostVoting data (safe validation)
 *
 * @param data - Data to validate
 * @returns Validation result
 *
 * @example
 * ```typescript
 * const result = validatePostVoting(data);
 * if (result.success) {
 *   console.log('Valid post voting:', result.data);
 * } else {
 *   console.error('Invalid post voting:', result.error.errors);
 * }
 * ```
 */
export function validatePostVoting(
  data: unknown
): { success: true; data: PostVoting } | { success: false; error: z.ZodError } {
  return validateSafe(PostVotingSchema, data);
}

// ============================================================================
// Exports
// ============================================================================

export default {
  // Enums
  VoteStatus,

  // Schemas
  VoteSchema,
  PostVotingSchema,
  voteStatusSchema,

  // Converters
  fromFirestoreVote,
  toFirestoreVote,
  fromFirestorePostVoting,
  toFirestorePostVoting,

  // Validators
  validateVote,
  validatePostVoting,
};
