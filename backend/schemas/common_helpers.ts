/**
 * Common Zod Schemas and Helper Functions
 *
 * 모든 Feature에서 재사용 가능한 공통 스키마와 Helper 함수
 *
 * @module common_helpers
 * @created 2025-11-02
 */

import { z } from 'zod';
import * as admin from 'firebase-admin';

// ============================================================================
// Base Schemas
// ============================================================================

/**
 * Base schema - 모든 엔티티에 공통 적용
 */
export const baseSchema = z.object({
  id: z.string().describe("Document ID from Firestore"),
  createdAt: z.date().describe("Creation timestamp"),
  updatedAt: z.date().optional().describe("Last update timestamp"),
});

export type BaseEntity = z.infer<typeof baseSchema>;

/**
 * User Reference Schema - 사용자 정보 필드 (80% 출현)
 */
export const userRefSchema = z.object({
  userId: z.string().describe("User ID (legacy: userid)"),
  displayName: z.string().optional().describe("User display name (legacy: username)"),
  photoUrl: z.string().optional().describe("Profile photo URL"),
});

export type UserReference = z.infer<typeof userRefSchema>;

// ============================================================================
// Timestamp Helpers
// ============================================================================

/**
 * Firestore Timestamp → Date 변환
 *
 * 지원 타입:
 * - Firestore Timestamp
 * - Date
 * - number (milliseconds since epoch)
 * - string (ISO 8601)
 *
 * @param value - 변환할 값
 * @returns Date 또는 undefined
 *
 * @example
 * const date = parseTimestamp(firestoreTimestamp);
 * const date = parseTimestamp(1698765432000);
 * const date = parseTimestamp('2023-10-31T12:30:00Z');
 */
export function parseTimestamp(value: any): Date | undefined {
  if (!value) return undefined;
  if (value instanceof Date) return value;
  if (value.toDate && typeof value.toDate === 'function') {
    return value.toDate();  // Firestore Timestamp
  }
  if (typeof value === 'number') {
    return new Date(value);  // milliseconds since epoch
  }
  if (typeof value === 'string') {
    const parsed = new Date(value);
    return isNaN(parsed.getTime()) ? undefined : parsed;
  }
  return undefined;
}

/**
 * Date → Firestore Timestamp 변환
 *
 * @param date - 변환할 Date
 * @returns Firestore Timestamp 또는 undefined
 *
 * @example
 * const timestamp = toFirestoreTimestamp(new Date());
 */
export function toFirestoreTimestamp(
  date: Date | undefined
): admin.firestore.Timestamp | undefined {
  return date ? admin.firestore.Timestamp.fromDate(date) : undefined;
}

// ============================================================================
// Array Helpers
// ============================================================================

/**
 * String 배열 안전 파싱
 *
 * - 빈 문자열 필터링
 * - null/undefined → 빈 배열
 * - 타입 가드 적용
 *
 * @param value - 파싱할 값
 * @returns string[] (빈 배열 또는 유효한 문자열 배열)
 *
 * @example
 * const urls = parseStringArray(data.images);  // ['url1', 'url2']
 * const empty = parseStringArray(null);        // []
 */
export function parseStringArray(value: any): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter(v => typeof v === 'string' && v.length > 0);
}

/**
 * Number 배열 안전 파싱
 *
 * - 문자열 → 숫자 변환 시도
 * - 실패 시 defaultValue 사용
 * - null/undefined → 빈 배열
 *
 * @param value - 파싱할 값
 * @param defaultValue - 변환 실패 시 기본값 (default: 1.0)
 * @returns number[]
 *
 * @example
 * const ratios = parseNumberArray(data.aspectRatios, 1.0);
 */
export function parseNumberArray(
  value: any,
  defaultValue: number = 1.0
): number[] {
  if (!Array.isArray(value)) return [];
  return value.map(v => {
    if (typeof v === 'number') return v;
    if (typeof v === 'string') {
      const parsed = parseFloat(v);
      return isNaN(parsed) ? defaultValue : parsed;
    }
    return defaultValue;
  });
}

// ============================================================================
// Map/Object Helpers
// ============================================================================

/**
 * Generic Map 안전 파싱
 *
 * @param value - 파싱할 값
 * @returns Record<string, any> 또는 null
 *
 * @example
 * const metadata = parseMap(data.targetAudience);
 */
export function parseMap(value: any): Record<string, any> | null {
  if (!value || typeof value !== 'object' || Array.isArray(value)) {
    return null;
  }
  return { ...value };
}

/**
 * Timestamp Map 파싱 (Map<userId, lastReadTime>)
 *
 * Chat Feature의 lastReadTimestamps 전용
 *
 * @param value - 파싱할 값
 * @returns Record<string, Date>
 *
 * @example
 * const lastRead = parseTimestampMap(data.lastReadTimestamps);
 * // { 'user1': Date, 'user2': Date }
 */
export function parseTimestampMap(value: any): Record<string, Date> {
  if (!value || typeof value !== 'object') return {};

  const result: Record<string, Date> = {};
  Object.entries(value).forEach(([key, val]) => {
    const date = parseTimestamp(val);
    if (date) {
      result[key] = date;
    }
  });
  return result;
}

// ============================================================================
// Integer Parsing
// ============================================================================

/**
 * 안전한 정수 파싱
 *
 * @param value - 파싱할 값
 * @param defaultValue - 기본값 (default: 0)
 * @returns number (integer)
 *
 * @example
 * const count = parseInt(data.commentCount, 0);
 */
export function parseIntSafe(value: any, defaultValue: number = 0): number {
  if (typeof value === 'number') {
    return Math.floor(value);
  }
  if (typeof value === 'string') {
    const parsed = parseInt(value, 10);
    return isNaN(parsed) ? defaultValue : parsed;
  }
  return defaultValue;
}

// ============================================================================
// Validation Helpers
// ============================================================================

/**
 * Zod schema validation with detailed error logging
 *
 * @param schema - Zod schema
 * @param data - 검증할 데이터
 * @param context - 에러 로그용 컨텍스트 (e.g., "PostDisplay", "Message")
 * @returns Validated data
 * @throws ZodError with detailed context
 *
 * @example
 * const post = validateWithContext(PostDisplaySchema, data, 'PostDisplay');
 */
export function validateWithContext<T>(
  schema: z.ZodSchema<T>,
  data: unknown,
  context: string
): T {
  try {
    return schema.parse(data);
  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error(`❌ Validation failed for ${context}:`, {
        errors: error.errors,
        data: JSON.stringify(data, null, 2),
      });
    }
    throw error;
  }
}

/**
 * Safe validation (no throw)
 *
 * @param schema - Zod schema
 * @param data - 검증할 데이터
 * @returns { success: true, data: T } | { success: false, error: ZodError }
 *
 * @example
 * const result = validateSafe(PostDisplaySchema, data);
 * if (result.success) {
 *   console.log(result.data.questionTitle);
 * } else {
 *   console.error(result.error.errors);
 * }
 */
export function validateSafe<T>(
  schema: z.ZodSchema<T>,
  data: unknown
): { success: true; data: T } | { success: false; error: z.ZodError } {
  const result = schema.safeParse(data);
  if (result.success) {
    return { success: true, data: result.data };
  } else {
    return { success: false, error: result.error };
  }
}

// ============================================================================
// Common Field Normalizers
// ============================================================================

/**
 * 공통 필드 정규화 (모든 Feature 적용 가능)
 *
 * - createdAt, updatedAt Timestamp 변환
 * - userId fallback (userid → userId)
 *
 * @param data - 정규화할 데이터
 * @returns 정규화된 데이터
 */
export function normalizeCommonFields(data: any): any {
  return {
    ...data,
    createdAt: parseTimestamp(data.createdAt || data.created_at),
    updatedAt: parseTimestamp(data.updatedAt || data.updated_at),
    userId: data.userId || data.userid || data.uid,
  };
}

// ============================================================================
// Exports
// ============================================================================

export default {
  // Schemas
  baseSchema,
  userRefSchema,

  // Timestamp
  parseTimestamp,
  toFirestoreTimestamp,

  // Arrays
  parseStringArray,
  parseNumberArray,

  // Maps
  parseMap,
  parseTimestampMap,

  // Numbers
  parseIntSafe,

  // Validation
  validateWithContext,
  validateSafe,

  // Normalizers
  normalizeCommonFields,
};
