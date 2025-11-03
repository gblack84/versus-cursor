/**
 * Post Feature Zod Schemas
 *
 * PostDisplay 엔티티 (30 fields)
 * - FlutterFlow 레거시 5개 필드 지원
 * - Dual-field normalization (userid → userId)
 *
 * @module post_schema
 * @created 2025-11-02
 */

import { z } from 'zod';
import {
  baseSchema,
  userRefSchema,
  parseStringArray,
  parseNumberArray,
  parseMap,
  parseIntSafe,
  validateWithContext,
} from './common_helpers';

// ============================================================================
// Nested Object Schemas
// ============================================================================

/**
 * Post Option Schema (optionA, optionB)
 */
const postOptionSchema = z.object({
  text: z.string().optional(),
  images: z.array(z.string()).optional(),
  aspectRatios: z.array(z.number()).optional(),
});

export type PostOption = z.infer<typeof postOptionSchema>;

// ============================================================================
// PostDisplay Schema (30 fields)
// ============================================================================

export const PostDisplaySchema = baseSchema.extend({
  // User Reference Fields (3)
  ...userRefSchema.shape,

  // Content Fields (10)
  questionTitle: z.string().min(1).max(200),
  description: z.string().optional(),
  optionAText: z.string().optional(),
  optionBText: z.string().optional(),
  optionAImageUrl: z.string().optional(),
  optionBImageUrl: z.string().optional(),
  optionAImages: z.array(z.string()).optional(),
  optionAAspectRatios: z.array(z.number()).optional(),
  optionBImages: z.array(z.string()).optional(),
  optionBAspectRatios: z.array(z.number()).optional(),
  layoutType: z.string().default('vertical'),

  // Voting Fields (7)
  votesA: z.number().int().default(0),
  votesB: z.number().int().default(0),
  voteStatus: z.enum(['pending', 'active', 'completed']).default('pending'),
  voteCompleted: z.boolean().default(false),
  voteStartTime: z.date().optional(),
  voteEndTime: z.date().optional(),

  // Metrics Fields (3)
  commentCount: z.number().int().default(0),
  likeCount: z.number().int().default(0),
  shareCount: z.number().int().default(0),

  // Metadata Fields (6)
  isAnonymous: z.boolean().default(false),
  status: z.string().default('published'),
  targetAudience: z.record(z.string(), z.any()).optional(),
});

export type PostDisplay = z.infer<typeof PostDisplaySchema>;

// ============================================================================
// FlutterFlow Legacy Compatibility
// ============================================================================

/**
 * FlutterFlow 레거시 필드 정규화 (5개 필드)
 *
 * camelCase 우선, lowercase는 fallback
 *
 * @param data - Firestore 데이터
 * @returns 정규화된 데이터
 */
export function normalizeLegacyPostFields(data: any): any {
  return {
    ...data,
    // Critical fields
    userId: data.userId || data.userid || data.uid || '',
    displayName: data.displayName || data.username || data.userName || '',

    // Medium priority fields
    commentCount: data.commentCount ?? data.commentcount ?? 0,
    likeCount: data.likeCount ?? data.likecount ?? 0,
    shareCount: data.shareCount ?? data.sharecount ?? 0,

    // Arrays (안전한 파싱)
    optionAImages: parseStringArray(data.optionAImages),
    optionBImages: parseStringArray(data.optionBImages),
    optionAAspectRatios: parseNumberArray(data.optionAAspectRatios, 1.0),
    optionBAspectRatios: parseNumberArray(data.optionBAspectRatios, 1.0),

    // Map (targetAudience)
    targetAudience: parseMap(data.targetAudience),
  };
}

/**
 * PostDisplay 런타임 타입 검증 (Legacy 지원)
 *
 * @param data - 검증할 데이터
 * @returns PostDisplay
 * @throws ZodError
 *
 * @example
 * const post = validatePostDisplay(firestoreData);
 * console.log(post.questionTitle);  // ✅ string
 */
export function validatePostDisplay(data: unknown): PostDisplay {
  const normalized = normalizeLegacyPostFields(data);
  return validateWithContext(PostDisplaySchema, normalized, 'PostDisplay');
}

/**
 * PostDisplay 안전한 검증 (에러 던지지 않음)
 *
 * @param data - 검증할 데이터
 * @returns { success: true, data: PostDisplay } | { success: false, error }
 */
export function validatePostDisplaySafe(data: unknown) {
  try {
    return {
      success: true as const,
      data: validatePostDisplay(data),
    };
  } catch (error) {
    return {
      success: false as const,
      error: error instanceof z.ZodError ? error.errors : String(error),
    };
  }
}

// ============================================================================
// Firestore Converters
// ============================================================================

/**
 * PostDisplay → Firestore 문서 변환
 *
 * - createdAt, updatedAt → Firestore Timestamp
 * - camelCase 필드만 저장 (lowercase 제거)
 *
 * @param post - PostDisplay 엔티티
 * @returns Firestore 문서 데이터
 */
export function postDisplayToFirestore(post: PostDisplay): Record<string, any> {
  const { id, createdAt, updatedAt, ...rest } = post;

  return {
    ...rest,
    createdAt: admin.firestore.Timestamp.fromDate(createdAt),
    updatedAt: updatedAt
      ? admin.firestore.Timestamp.fromDate(updatedAt)
      : admin.firestore.FieldValue.serverTimestamp(),
  };
}

// ============================================================================
// Partial Update Schema
// ============================================================================

/**
 * PostDisplay 부분 업데이트 스키마
 *
 * 모든 필드를 optional로 만듦
 */
export const PostDisplayPartialSchema = PostDisplaySchema.partial();

export type PostDisplayPartial = z.infer<typeof PostDisplayPartialSchema>;

/**
 * 부분 업데이트 검증
 */
export function validatePostDisplayPartial(data: unknown): PostDisplayPartial {
  const normalized = normalizeLegacyPostFields(data);
  return validateWithContext(
    PostDisplayPartialSchema,
    normalized,
    'PostDisplayPartial'
  );
}

// ============================================================================
// Exports
// ============================================================================

export default {
  PostDisplaySchema,
  PostDisplayPartialSchema,
  normalizeLegacyPostFields,
  validatePostDisplay,
  validatePostDisplaySafe,
  validatePostDisplayPartial,
  postDisplayToFirestore,
};
