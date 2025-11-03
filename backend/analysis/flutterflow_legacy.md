# FlutterFlow 레거시 분석

> **작성일**: 2025-11-02
> **문제**: FlutterFlow는 모든 필드를 lowercase로 저장 (userid, commentcount)
> **영향**: Post Feature 5개 필드 (4.2%), 총 119개 중

---

## 📊 레거시 필드 매핑

### Critical Priority (사용자 식별/표시)

| Clean (camelCase) | FlutterFlow (lowercase) | Feature | 빈도 | 우선순위 |
|-------------------|------------------------|---------|------|---------|
| `userId` | `userid` | Post | 30/30 (100%) | 🔴 Critical |
| `displayName` | `username` | Post | 30/30 (100%) | 🔴 Critical |

**이유**: 사용자 식별 및 표시는 핵심 기능. 레거시 필드명 유지 시 혼란 가능.

### Medium Priority (메트릭)

| Clean (camelCase) | FlutterFlow (lowercase) | Feature | 빈도 | 우선순위 |
|-------------------|------------------------|---------|------|---------|
| `commentCount` | `commentcount` | Post | 30/30 (100%) | 🟡 Medium |
| `likeCount` | `likecount` | Post | 30/30 (100%) | 🟡 Medium |
| `shareCount` | `sharecount` | Post | 30/30 (100%) | 🟡 Medium |

**이유**: 메트릭 필드는 표시 전용. 레거시 유지해도 기능 영향 적음.

### 총계

- **총 5개 레거시 필드** (Post Feature 전용)
- **빈도**: 4.2% (5/119 fields)
- **영향 Feature**: Post만 해당 (Chat, Message, Vote, PostVoting는 Pure camelCase)

---

## 🔧 현재 이중 필드 지원 방식

### Extension Pattern (fromFirestore)

**파일**: `lib/features/post/domain/models/post_display_extensions.dart:55-57`

```dart
static PostDisplay fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>? ?? {};

  return PostDisplay(
    id: doc.id,
    // ✅ 이중 필드 지원 (FlutterFlow + Clean)
    userId: data['userid'] as String? ?? data['uid'] as String? ?? '',
    displayName: data['username'] as String? ?? data['userName'] as String? ?? '',
    commentCount: _parseInt(data['commentcount']),
    likeCount: _parseInt(data['likecount']),
    shareCount: _parseInt(data['sharecount']),
    // ... other fields
  );
}
```

**특징**:
- ✅ Firestore 읽기 시 lowercase → camelCase 자동 변환
- ✅ 하위 호환성 유지 (기존 데이터 지원)
- ⚠️ 코드 복잡도 증가 (294줄 → 평균 대비 +50줄)

### Extension Pattern (toFirestore)

```dart
Map<String, dynamic> toFirestore() {
  return {
    // ✅ 새 데이터는 camelCase만 저장
    'userId': userId,
    'displayName': displayName,
    'commentCount': commentCount,
    'likeCount': likeCount,
    'shareCount': shareCount,
    // ... other fields
  };
}
```

**특징**:
- ✅ 새 데이터는 표준 camelCase 사용
- ⚠️ 기존 lowercase 데이터는 그대로 유지 (삭제 안 함)

---

## 🚀 마이그레이션 전략

### Option A: 점진적 마이그레이션 (권장 ⭐)

**장점**:
- ✅ 무중단 배포 가능
- ✅ 롤백 용이
- ✅ 리스크 최소화

**단점**:
- ⚠️ 이중 필드 지원 기간 필요 (1-3개월)
- ⚠️ 복잡도 증가

**실행 계획**:

#### Phase 1: 새 필드 추가 (1주)

```typescript
// Cloud Function: 기존 데이터에 camelCase 필드 추가
export async function addCamelCaseFields() {
  const firestore = admin.firestore();
  const postsRef = firestore.collection('posts');

  const snapshot = await postsRef.get();
  const batch = firestore.batch();

  snapshot.docs.forEach(doc => {
    const data = doc.data();

    // lowercase 필드가 있으면 camelCase 복사
    const updates: any = {};
    if (data.userid && !data.userId) {
      updates.userId = data.userid;
    }
    if (data.username && !data.displayName) {
      updates.displayName = data.username;
    }
    if (data.commentcount !== undefined && data.commentCount === undefined) {
      updates.commentCount = data.commentcount;
    }
    if (data.likecount !== undefined && data.likeCount === undefined) {
      updates.likeCount = data.likecount;
    }
    if (data.sharecount !== undefined && data.shareCount === undefined) {
      updates.shareCount = data.sharecount;
    }

    if (Object.keys(updates).length > 0) {
      batch.update(doc.ref, updates);
    }
  });

  await batch.commit();
  console.log(`✅ Added camelCase fields to ${snapshot.size} posts`);
}
```

#### Phase 2: Flutter Extension 간소화 (1주)

```dart
// fromFirestore: camelCase 우선, fallback으로 lowercase
userId: data['userId'] as String? ?? data['userid'] as String? ?? '',
displayName: data['displayName'] as String? ?? data['username'] as String? ?? '',
commentCount: data['commentCount'] as int? ?? _parseInt(data['commentcount']),
```

#### Phase 3: 검증 기간 (1개월)

- 모든 새 데이터가 camelCase로 저장되는지 확인
- 기존 데이터도 camelCase 필드가 추가되었는지 확인
- 에러 로그 모니터링

#### Phase 4: 레거시 필드 제거 (1주)

```typescript
// Cloud Function: lowercase 필드 삭제
export async function removeLegacyFields() {
  const firestore = admin.firestore();
  const postsRef = firestore.collection('posts');

  const snapshot = await postsRef.get();
  const batch = firestore.batch();

  snapshot.docs.forEach(doc => {
    const data = doc.data();

    // camelCase 필드가 있으면 lowercase 삭제
    const updates: any = {};
    if (data.userId && data.userid) {
      updates.userid = admin.firestore.FieldValue.delete();
    }
    if (data.displayName && data.username) {
      updates.username = admin.firestore.FieldValue.delete();
    }
    if (data.commentCount !== undefined && data.commentcount !== undefined) {
      updates.commentcount = admin.firestore.FieldValue.delete();
    }
    if (data.likeCount !== undefined && data.likecount !== undefined) {
      updates.likecount = admin.firestore.FieldValue.delete();
    }
    if (data.shareCount !== undefined && data.sharecount !== undefined) {
      updates.sharecount = admin.firestore.FieldValue.delete();
    }

    if (Object.keys(updates).length > 0) {
      batch.update(doc.ref, updates);
    }
  });

  await batch.commit();
  console.log(`✅ Removed legacy fields from ${snapshot.size} posts`);
}
```

#### Phase 5: Extension 정리 (1주)

```dart
// fromFirestore: camelCase만 사용 (fallback 제거)
userId: data['userId'] as String? ?? '',
displayName: data['displayName'] as String? ?? '',
commentCount: data['commentCount'] as int? ?? 0,
```

**총 기간**: 1개월 + 검증 1개월 = **2개월**

---

### Option B: 일괄 마이그레이션 (빠르지만 위험 ⚠️)

**장점**:
- ✅ 빠른 완료 (1-2주)
- ✅ 코드 간소화

**단점**:
- ❌ 다운타임 필요 (수 시간)
- ❌ 롤백 어려움
- ❌ 리스크 높음

**권장하지 않음**: Production 환경에서는 Option A 권장

---

## 📋 TypeScript 스키마 설계

### FlutterFlow 호환성 레이어

```typescript
// firebase/functions/src/schemas/post.schema.ts
import { z } from 'zod';

export const PostDisplaySchema = z.object({
  id: z.string(),
  userId: z.string(),  // ← 표준 필드
  displayName: z.string().optional(),
  commentCount: z.number().default(0),
  likeCount: z.number().default(0),
  shareCount: z.number().default(0),
  // ... other fields
});

// Legacy field normalization
export function normalizeLegacyPostFields(data: any): any {
  return {
    userId: data.userId || data.userid,  // ← camelCase 우선
    displayName: data.displayName || data.username,
    commentCount: data.commentCount ?? data.commentcount ?? 0,
    likeCount: data.likeCount ?? data.likecount ?? 0,
    shareCount: data.shareCount ?? data.sharecount ?? 0,
    ...data,
  };
}

// Runtime validation with legacy support
export function validatePostDisplay(data: unknown): PostDisplay {
  const normalized = normalizeLegacyPostFields(data);
  return PostDisplaySchema.parse(normalized);
}
```

### Cloud Functions 사용 예시

```typescript
// firebase/functions/src/firestore/onPostCreated.ts
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { validatePostDisplay } from '../schemas/post.schema';

export const onPostCreated = onDocumentCreated('posts/{postId}', async (event) => {
  const data = event.data?.data();

  // ✅ Legacy field 자동 변환 + 타입 검증
  const post = validatePostDisplay(data);

  // ✅ 타입 안전성 보장
  console.log(`User ID: ${post.userId}`);  // ✅ OK
  console.log(`User ID: ${post.userid}`);  // ❌ Compile Error
});
```

---

## 🔍 마이그레이션 검증

### 데이터 검증 쿼리

```typescript
// firebase/functions/src/migrations/validate-migration.ts
export async function validateMigration() {
  const firestore = admin.firestore();
  const postsRef = firestore.collection('posts');

  const snapshot = await postsRef.get();

  const stats = {
    total: snapshot.size,
    hasCamelCase: 0,
    hasLowercase: 0,
    hasBoth: 0,
    missingFields: [] as string[],
  };

  snapshot.docs.forEach(doc => {
    const data = doc.data();

    const hasUserId = !!data.userId;
    const hasUserid = !!data.userid;

    if (hasUserId && hasUserid) stats.hasBoth++;
    else if (hasUserId) stats.hasCamelCase++;
    else if (hasUserid) stats.hasLowercase++;
    else stats.missingFields.push(doc.id);
  });

  console.log('Migration Validation Results:');
  console.log(`Total posts: ${stats.total}`);
  console.log(`✅ camelCase only: ${stats.hasCamelCase} (${(stats.hasCamelCase / stats.total * 100).toFixed(1)}%)`);
  console.log(`⚠️  Both fields: ${stats.hasBoth} (${(stats.hasBoth / stats.total * 100).toFixed(1)}%)`);
  console.log(`❌ lowercase only: ${stats.hasLowercase} (${(stats.hasLowercase / stats.total * 100).toFixed(1)}%)`);
  console.log(`🚨 Missing fields: ${stats.missingFields.length}`);

  if (stats.missingFields.length > 0) {
    console.log('Missing field document IDs:', stats.missingFields.slice(0, 10));
  }

  return stats;
}
```

### Extension 코드 리뷰 체크리스트

- [ ] fromFirestore(): camelCase 우선, lowercase는 fallback만
- [ ] toFirestore(): camelCase만 저장
- [ ] 모든 레거시 필드 매핑 확인 (5개)
- [ ] Null-safe 기본값 제공
- [ ] 타입 변환 Helper 사용 (_parseInt 등)

---

## 📊 마이그레이션 진행 상황 추적

### Dashboard (Firestore Console)

```
Collection: posts
Field Statistics:

userId (camelCase):     ████████████ 80% (800/1000 documents)
userid (lowercase):     ██████████████████ 95% (950/1000 documents)
Both fields:            ███████████ 75% (750/1000 documents)

Target:
✅ Phase 1 Complete: All documents have camelCase fields (100%)
⏳ Phase 4 Pending: Remove legacy fields (0%)
```

### 알림 설정

```typescript
// Cloud Function: 마이그레이션 진행률 모니터링
export const checkMigrationProgress = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async () => {
    const stats = await validateMigration();

    if (stats.hasCamelCase / stats.total >= 0.95) {
      console.log('✅ 95% migrated to camelCase - Ready for Phase 4');
      // Send Slack notification
    }
  });
```

---

## 🔗 관련 문서

- [Entity Analysis](./entity_analysis.md) - PostDisplay 상세 분석
- [Common Patterns](./common_patterns.md) - Extension Pattern 패턴
- [Migration Strategy](/backend/MIGRATION_STRATEGY.md) - 전체 마이그레이션 계획

---

**최종 업데이트**: 2025-11-02
**다음 리뷰**: Phase 1 완료 후 (나머지 Feature 마이그레이션 완성 시)
