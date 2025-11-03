# Zod 스키마 설계 가이드

> **작성일**: 2025-11-02
> **목적**: TypeScript + Zod 스키마 설계 및 런타임 타입 검증 가이드

---

## 📋 목차

- [Zod 소개](#-zod-소개)
- [스키마 파일 구조](#-스키마-파일-구조)
- [기본 스키마 작성법](#-기본-스키마-작성법)
- [런타임 타입 검증](#-런타임-타입-검증)
- [FlutterFlow 호환성](#-flutterflow-호환성)
- [Cloud Functions 적용](#-cloud-functions-적용)

---

## 🎯 Zod 소개

**Zod**는 TypeScript-first 스키마 선언 및 검증 라이브러리입니다.

### 왜 Zod인가?

1. **TypeScript 네이티브**: 타입 추론 자동 지원
2. **런타임 검증**: Firestore 데이터 타입 검증
3. **Zero Dependencies**: 가볍고 빠름
4. **체인 가능**: 복잡한 스키마도 직관적으로 작성

### 설치

```bash
cd firebase/functions
npm install zod
```

---

## 📁 스키마 파일 구조

```
firebase/functions/src/schemas/
├── README.md                 # 이 문서
├── common_helpers.ts         # 공통 Helper 함수
├── post_schema.ts            # Post Feature 스키마
├── chat_schema.ts            # Chat Feature 스키마
└── voting_schema.ts          # Voting Feature 스키마
```

### 작성 규칙

1. **Feature별 파일 분리**: 각 Feature의 모든 엔티티를 하나의 파일에
2. **공통 Helper 재사용**: `common_helpers.ts` import
3. **FlutterFlow 호환성**: `normalizeLegacy*()` 함수 제공
4. **런타임 검증**: `validate*()` 함수 export

---

## 🔧 기본 스키마 작성법

### 1. 공통 Base Schema

**모든 엔티티에 공통 적용**:

```typescript
// common_helpers.ts
import { z } from 'zod';

export const baseSchema = z.object({
  id: z.string().describe("Document ID"),
  createdAt: z.date().describe("Creation timestamp"),
  updatedAt: z.date().optional().describe("Last update timestamp"),
});

export type BaseEntity = z.infer<typeof baseSchema>;
```

### 2. User Reference Schema

**사용자 정보 필드 (80% 출현)**:

```typescript
export const userRefSchema = z.object({
  userId: z.string().describe("User ID"),
  displayName: z.string().optional().describe("User display name"),
  photoUrl: z.string().optional().describe("Profile photo URL"),
});
```

### 3. Feature 스키마 확장

```typescript
// post_schema.ts
import { baseSchema, userRefSchema } from './common_helpers';

export const PostDisplaySchema = baseSchema.extend({
  ...userRefSchema.shape,  // User reference 필드 추가
  questionTitle: z.string().min(1).max(200),
  description: z.string().optional(),
  votesA: z.number().int().default(0),
  votesB: z.number().int().default(0),
  // ... 30 fields
});

export type PostDisplay = z.infer<typeof PostDisplaySchema>;
```

### 4. Nested Object

```typescript
const postOptionSchema = z.object({
  text: z.string().optional(),
  images: z.array(z.string()).optional(),
  aspectRatios: z.array(z.number()).optional(),
});

export const PostDisplaySchema = baseSchema.extend({
  // ...
  optionA: postOptionSchema.optional(),
  optionB: postOptionSchema.optional(),
});
```

### 5. Enum

```typescript
const voteStatusSchema = z.enum([
  'pending',
  'active',
  'completed',
  'cancelled',
  'timeout',
]);

export const PostVotingSchema = z.object({
  voteStatus: voteStatusSchema.default('pending'),
  // ...
});

export type VoteStatus = z.infer<typeof voteStatusSchema>;
```

---

## ✅ 런타임 타입 검증

### 1. 기본 검증

```typescript
import { PostDisplaySchema } from './post_schema';

function processPost(data: unknown) {
  try {
    // ✅ 런타임 타입 검증
    const post = PostDisplaySchema.parse(data);

    // ✅ 타입 안전성 보장
    console.log(post.questionTitle);  // string
    console.log(post.votesA);         // number

  } catch (error) {
    if (error instanceof z.ZodError) {
      console.error('Validation failed:', error.errors);
      // [{
      //   path: ['questionTitle'],
      //   message: 'Required',
      //   code: 'invalid_type'
      // }]
    }
  }
}
```

### 2. Safe Parse (에러 처리)

```typescript
function processPostSafe(data: unknown) {
  const result = PostDisplaySchema.safeParse(data);

  if (result.success) {
    const post = result.data;  // ✅ PostDisplay 타입
    console.log(post.questionTitle);
  } else {
    console.error('Validation errors:', result.error.errors);
  }
}
```

### 3. Partial Update (부분 업데이트)

```typescript
const PostDisplayPartialSchema = PostDisplaySchema.partial();

function updatePost(postId: string, updates: unknown) {
  // ✅ 일부 필드만 검증
  const validatedUpdates = PostDisplayPartialSchema.parse(updates);

  firestore.collection('posts').doc(postId).update(validatedUpdates);
}
```

---

## 🔄 FlutterFlow 호환성

### 1. Legacy Field Normalization

```typescript
// post_schema.ts
export function normalizeLegacyPostFields(data: any): any {
  return {
    // camelCase 우선, lowercase는 fallback
    userId: data.userId || data.userid,
    displayName: data.displayName || data.username,
    commentCount: data.commentCount ?? data.commentcount ?? 0,
    likeCount: data.likeCount ?? data.likecount ?? 0,
    shareCount: data.shareCount ?? data.sharecount ?? 0,
    ...data,
  };
}
```

### 2. Validation with Legacy Support

```typescript
export function validatePostDisplay(data: unknown): PostDisplay {
  // 1. Legacy field 정규화
  const normalized = normalizeLegacyPostFields(data);

  // 2. Zod 검증
  return PostDisplaySchema.parse(normalized);
}
```

### 3. Safe Validation

```typescript
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
```

---

## 🔥 Cloud Functions 적용

### 1. Firestore Trigger

```typescript
// firebase/functions/src/firestore/onPostCreated.ts
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { validatePostDisplay } from '../schemas/post_schema';

export const onPostCreated = onDocumentCreated(
  'posts/{postId}',
  async (event) => {
    const data = event.data?.data();

    // ✅ 런타임 타입 검증 + Legacy 지원
    const post = validatePostDisplay(data);

    // ✅ 타입 안전성
    console.log(`Post created: ${post.questionTitle}`);
    console.log(`Author: ${post.userId}`);

    // AI 분석 호출
    await analyzePostContent(post);
  }
);
```

### 2. HTTP Callable Function

```typescript
import { onCall } from 'firebase-functions/v2/https';
import { PostDisplaySchema } from '../schemas/post_schema';

export const createPost = onCall(async (request) => {
  // ✅ Request 데이터 검증
  const postData = PostDisplaySchema.parse(request.data);

  // ✅ Firestore 저장
  const docRef = await firestore.collection('posts').add({
    ...postData,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { postId: docRef.id };
});
```

### 3. Scheduled Function

```typescript
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { validatePostDisplay } from '../schemas/post_schema';

export const cleanupExpiredPosts = onSchedule('every 24 hours', async () => {
  const snapshot = await firestore
    .collection('posts')
    .where('voteStatus', '==', 'expired')
    .get();

  snapshot.docs.forEach(doc => {
    // ✅ 각 문서 검증
    const post = validatePostDisplay(doc.data());

    // 만료된 게시물 처리
    if (post.voteCompleted) {
      // ...
    }
  });
});
```

---

## 📚 예시 파일

### 1. [common_helpers.ts](./common_helpers.ts)

공통 Helper 함수:
- `baseSchema`, `userRefSchema`
- `parseTimestamp()`, `toFirestoreTimestamp()`
- `parseStringArray()`, `parseNumberArray()`
- `parseMap()`, `parseTimestampMap()`

### 2. [post_schema.ts](./post_schema.ts)

Post Feature 스키마:
- `PostDisplaySchema` (30 fields)
- `normalizeLegacyPostFields()`
- `validatePostDisplay()`

### 3. [chat_schema.ts](./chat_schema.ts)

Chat Feature 스키마:
- `ChatSchema` (17 fields)
- `MessageSchema` (45 fields)
- Vote Card nested fields

### 4. [voting_schema.ts](./voting_schema.ts)

Voting Feature 스키마:
- `VoteSchema` (4 fields)
- `PostVotingSchema` (23 fields)
- `VoteStatus` enum

---

## 🎓 학습 리소스

### Zod 공식 문서
- [Zod GitHub](https://github.com/colinhacks/zod)
- [Zod Documentation](https://zod.dev/)

### 추천 읽기 순서
1. `common_helpers.ts` - 공통 패턴 이해
2. `post_schema.ts` - 가장 복잡한 엔티티 (30 fields, FlutterFlow legacy)
3. `chat_schema.ts` - Nested objects, Vote Card
4. `voting_schema.ts` - Enum 처리

---

## 🔗 관련 문서

- [Common Patterns](/backend/analysis/common_patterns.md) - Extension Pattern
- [FlutterFlow Legacy](/backend/analysis/flutterflow_legacy.md) - 레거시 매핑
- [Migration Strategy](/backend/MIGRATION_STRATEGY.md) - Phase 2 Zod 스키마 정의

---

**최종 업데이트**: 2025-11-02
