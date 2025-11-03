# Backend 마이그레이션 전략

> **작성일**: 2025-11-02
> **목적**: Firebase Cloud Functions TypeScript + Zod 마이그레이션 실행 계획

---

## 📋 목차

- [현재 상태 분석](#-현재-상태-분석)
- [마이그레이션 목표](#-마이그레이션-목표)
- [3단계 실행 로드맵](#-3단계-실행-로드맵)
- [성공 기준 및 검증](#-성공-기준-및-검증)
- [리스크 관리](#-리스크-관리)

---

## 📊 현재 상태 분석

### 아키텍처 현황

#### Frontend (Flutter)
```
lib/features/[feature]/
├── domain/
│   ├── entities/          # Freezed 불변 엔티티 (*.freezed.dart, *.g.dart)
│   └── repositories/      # Repository 인터페이스
├── data/
│   ├── repositories/      # Repository 구현체 (Firebase 직접 사용)
│   └── extensions/        # Firestore Extension (fromFirestore, toFirestore)
└── presentation/
    └── providers/         # Riverpod 2.x StreamProvider
```

**특징**:
- ✅ Clean Architecture v4.0 완성 (5개 Feature)
- ✅ Freezed + JSON Serializable 자동 생성
- ✅ Extension Pattern으로 DTO/Mapper 제거
- ⚠️ Flutter Freezed 모델이 암묵적 스키마 역할

#### Backend (Firebase Cloud Functions)
```
firebase/functions/
├── index.js               # ❌ JavaScript (타입 없음)
├── ai/                    # ❌ Genkit AI (타입 안전성 부족)
├── notifications/         # ❌ 알림 시스템 (런타임 에러 가능)
└── firestore/             # ❌ Firestore Triggers (타입 검증 없음)
```

**문제점**:
- ❌ JavaScript로 작성되어 타입 안전성 없음
- ❌ FlutterFlow 레거시 필드명 혼재 (userid vs userId)
- ❌ Flutter와 수동 동기화 필요 (7개 파일 수정)
- ❌ 런타임 타입 에러 가능성

### 분석 완료 Feature (5개 엔티티, 119개 필드)

| Feature | Entity | 필드 수 | Timestamp | List | Map | Enum | FlutterFlow Legacy |
|---------|--------|--------|-----------|------|-----|------|--------------------|
| **Post** | PostDisplay | 30 | 3 | 4 | 1 | 0 | ✅ 5개 |
| **Chat** | Chat | 17 | 3 | 1 | 1 | 0 | ❌ 없음 |
| **Chat** | Message | 45 | 4 | 4 | 3 | 0 | ❌ 없음 |
| **Voting** | Vote | 4 | 1 | 0 | 0 | 0 | ❌ 없음 |
| **Voting** | PostVoting | 23 | 6 | 2 | 0 | 1 | ❌ 없음 |

**총 119개 필드, 17개 Timestamp, 11개 List, 5개 Map, 1개 Enum**

### FlutterFlow 레거시 필드 (Post Feature 집중)

| Clean (camelCase) | FlutterFlow (lowercase) | 우선순위 | 영향도 |
|-------------------|------------------------|---------|--------|
| `userId` | `userid` | 🔴 Critical | 사용자 식별 |
| `userName` | `username` | 🔴 Critical | 사용자 표시 |
| `commentCount` | `commentcount` | 🟡 Medium | 메트릭 |
| `likeCount` | `likecount` | 🟡 Medium | 메트릭 |
| `shareCount` | `sharecount` | 🟡 Medium | 메트릭 |

**총 5개 레거시 필드 정리 필요**

---

## 🎯 마이그레이션 목표

### 1. TypeScript + Zod 스키마 도입

**Before** (현재):
```javascript
// firebase/functions/functions/firestore/onPostCreatedSendNotifications.js
async function analyzePostContent(postData) {
  // ❌ postData는 any 타입 - 타입 검증 없음
  const title = postData.questionTitle;
  const user = postData.userid;  // FlutterFlow naming
  const count = postData.commentcount;
}
```

**After** (목표):
```typescript
// firebase/functions/src/schemas/post.schema.ts
import { z } from 'zod';

export const PostDisplaySchema = z.object({
  id: z.string(),
  userId: z.string(),  // camelCase 표준
  questionTitle: z.string(),
  commentCount: z.number().default(0),
  // ... 30 fields
});

export type PostDisplay = z.infer<typeof PostDisplaySchema>;

// firebase/functions/src/firestore/onPostCreated.ts
export const onPostCreated = onDocumentCreated('posts/{postId}', async (event) => {
  const data = event.data?.data();

  // ✅ 런타임 타입 검증
  const post = PostDisplaySchema.parse(data);

  // ✅ 타입 안전성 - IDE 자동완성
  console.log(post.userId);  // ✅ OK
  console.log(post.userid);  // ❌ Compile Error
});
```

### 2. 코드 생성 자동화

**Before** (수동 동기화):
```bash
# Flutter 모델 수정
vim lib/features/post/domain/models/post_display.dart

# Extension 수정
vim lib/features/post/domain/models/post_display_extensions.dart

# Cloud Functions 수정 (수동!)
vim firebase/functions/functions/firestore/onPostCreated.js

# Firestore Rules 수정 (수동!)
vim firebase/firestore.rules

# Total: 4개 파일 수동 수정
```

**After** (자동 생성):
```bash
# 1. TypeScript 스키마만 수정 (Single Source of Truth)
vim firebase/functions/src/schemas/post.schema.ts

# 2. Dart 코드 자동 생성
npm run generate:dart
# ✅ post_display.dart 자동 생성
# ✅ post_display_extensions.dart 자동 생성
# ✅ post_display.freezed.dart 자동 생성
# ✅ post_display.g.dart 자동 생성

# 3. Freezed 빌드
dart run build_runner build --delete-conflicting-outputs

# Total: 1개 파일 수정 → 4개 파일 자동 생성
```

### 3. FlutterFlow 레거시 정리

**Before** (이중 필드 지원):
```dart
// post_display_extensions.dart
userId: data['userid'] as String? ?? data['uid'] as String? ?? '',
displayName: data['username'] as String? ?? data['userName'] as String? ?? '',
commentCount: _parseInt(data['commentcount']),
```

**After** (표준 camelCase):
```dart
// 자동 생성된 Extension
userId: data['userId'] as String? ?? '',
displayName: data['displayName'] as String? ?? '',
commentCount: data['commentCount'] as int? ?? 0,
```

**Firestore 데이터 마이그레이션**:
```typescript
// firebase/functions/src/migrations/normalize-field-names.ts
import * as admin from 'firebase-admin';

export async function migratePostFieldNames() {
  const firestore = admin.firestore();
  const postsRef = firestore.collection('posts');

  const snapshot = await postsRef.get();
  const batch = firestore.batch();

  snapshot.docs.forEach(doc => {
    const data = doc.data();

    // FlutterFlow → Standard naming
    const updates: any = {};
    if (data.userid) {
      updates.userId = data.userid;
      updates.userid = admin.firestore.FieldValue.delete();  // 삭제
    }
    if (data.username) {
      updates.displayName = data.username;
      updates.username = admin.firestore.FieldValue.delete();
    }
    if (data.commentcount !== undefined) {
      updates.commentCount = data.commentcount;
      updates.commentcount = admin.firestore.FieldValue.delete();
    }

    if (Object.keys(updates).length > 0) {
      batch.update(doc.ref, updates);
    }
  });

  await batch.commit();
  console.log(`Migrated ${snapshot.size} posts`);
}
```

### 4. Single Source of Truth 확립

**아키텍처 흐름**:
```
TypeScript + Zod Schema (SSOT)
    ↓ (npm run generate:dart)
Flutter Freezed Models (*.dart)
    ↓ (dart run build_runner)
Generated Files (*.freezed.dart, *.g.dart)
    ↓ (Extension Pattern)
Firestore Converters (fromFirestore, toFirestore)
```

---

## 🗺️ 3단계 실행 로드맵

### Phase 1: Cloud Functions TypeScript 전환 (1주)

#### Step 1.1: TypeScript 환경 설정

```bash
cd firebase/functions

# TypeScript 의존성 설치
npm install --save-dev typescript @types/node
npm install zod

# tsconfig.json 생성
npx tsc --init
```

**tsconfig.json 설정**:
```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "lib",
    "rootDir": "src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "lib"]
}
```

#### Step 1.2: 디렉토리 구조 변경

```bash
# src/ 디렉토리 생성
mkdir -p src/{schemas,firestore,ai,notifications,migrations}

# 기존 JavaScript 파일 이동 및 TypeScript 변환
mv functions/*.js src/
rename 's/\.js$/.ts/' src/*.ts

# index.ts 수정 (진입점)
```

**새로운 구조**:
```
firebase/functions/
├── package.json
├── tsconfig.json
├── src/
│   ├── index.ts              # 진입점 (TypeScript)
│   ├── schemas/              # Zod 스키마 정의
│   ├── firestore/            # Firestore Triggers
│   ├── ai/                   # Genkit AI Functions
│   ├── notifications/        # 알림 시스템
│   └── migrations/           # 데이터 마이그레이션 스크립트
└── lib/                      # 빌드 결과 (자동 생성)
```

#### Step 1.3: 기존 Functions 타입 추가

```typescript
// src/firestore/onPostCreatedSendNotifications.ts
import * as functions from 'firebase-functions';

// Before: any 타입
export const onPostCreated = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data();  // ❌ any
  });

// After: 임시 타입 정의
interface PostData {
  questionTitle: string;
  userid: string;  // ← FlutterFlow legacy (임시)
  commentcount: number;
}

export const onPostCreated = functions.firestore
  .document('posts/{postId}')
  .onCreate(async (snapshot, context) => {
    const data = snapshot.data() as PostData;  // ✅ 타입 지정
  });
```

#### Step 1.4: 빌드 및 배포 테스트

```bash
# TypeScript 컴파일
npm run build

# 로컬 에뮬레이터 테스트
firebase emulators:start

# 배포 (staging 환경 권장)
firebase deploy --only functions --project staging
```

**예상 소요 시간**: 3-5일

---

### Phase 2: Zod 스키마 정의 (2주)

#### Step 2.1: 공통 스키마 정의

```typescript
// src/schemas/common.schema.ts
import { z } from 'zod';
import * as admin from 'firebase-admin';

// Base schema for all entities
export const baseSchema = z.object({
  id: z.string().describe("Document ID"),
  createdAt: z.date().describe("Creation timestamp"),
  updatedAt: z.date().optional().describe("Last update timestamp"),
});

// User reference fields (FlutterFlow compatibility)
export const userRefSchema = z.object({
  userId: z.string().describe("User ID (legacy: userid)"),
  displayName: z.string().optional().describe("User name (legacy: username)"),
  photoUrl: z.string().optional().describe("Profile photo URL"),
});

// Timestamp helpers
export function parseTimestamp(value: any): Date | undefined {
  if (!value) return undefined;
  if (value instanceof Date) return value;
  if (value.toDate) return value.toDate();  // Firestore Timestamp
  if (typeof value === 'number') return new Date(value);
  if (typeof value === 'string') return new Date(value);
  return undefined;
}

export function toFirestoreTimestamp(date: Date | undefined) {
  return date ? admin.firestore.Timestamp.fromDate(date) : undefined;
}

// Array helpers
export function parseStringArray(value: any): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter(v => typeof v === 'string' && v.length > 0);
}

export function parseNumberArray(value: any, defaultValue: number = 1.0): number[] {
  if (!Array.isArray(value)) return [];
  return value.map(v => {
    if (typeof v === 'number') return v;
    if (typeof v === 'string') return parseFloat(v) || defaultValue;
    return defaultValue;
  });
}
```

#### Step 2.2: Feature별 스키마 작성

**Post Feature** (`src/schemas/post.schema.ts`):
```typescript
import { z } from 'zod';
import { baseSchema, userRefSchema } from './common.schema';

const postOptionSchema = z.object({
  text: z.string().optional(),
  images: z.array(z.string()).optional(),
  aspectRatios: z.array(z.number()).optional(),
});

export const PostDisplaySchema = baseSchema.extend({
  ...userRefSchema.shape,
  questionTitle: z.string(),
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
  votesA: z.number().default(0),
  votesB: z.number().default(0),
  voteStatus: z.enum(['pending', 'active', 'completed']).default('pending'),
  voteCompleted: z.boolean().default(false),
  voteStartTime: z.date().optional(),
  voteEndTime: z.date().optional(),
  commentCount: z.number().default(0),
  likeCount: z.number().default(0),
  shareCount: z.number().default(0),
  isAnonymous: z.boolean().default(false),
  status: z.string().default('published'),
  targetAudience: z.record(z.string(), z.any()).optional(),
});

export type PostDisplay = z.infer<typeof PostDisplaySchema>;

// FlutterFlow legacy compatibility
export function normalizeLegacyPostFields(data: any): any {
  return {
    userId: data.userid ?? data.userId,
    displayName: data.username ?? data.displayName,
    commentCount: data.commentcount ?? data.commentCount ?? 0,
    likeCount: data.likecount ?? data.likeCount ?? 0,
    shareCount: data.sharecount ?? data.shareCount ?? 0,
    ...data,
  };
}

// Runtime validation
export function validatePostDisplay(data: unknown): PostDisplay {
  const normalized = normalizeLegacyPostFields(data);
  return PostDisplaySchema.parse(normalized);
}
```

**Chat Feature** (`src/schemas/chat.schema.ts`):
```typescript
import { z } from 'zod';
import { baseSchema } from './common.schema';

export const ChatSchema = baseSchema.extend({
  chatId: z.string(),
  chatType: z.enum(['1:1', 'direct', 'group']).default('direct'),
  participantIds: z.array(z.string()),
  chatName: z.string(),
  lastMessageContent: z.string(),
  lastMessageAt: z.date().optional(),
  isRead: z.boolean().default(false),
  lastReadTimestamps: z.record(z.string(), z.date()),
});

export type Chat = z.infer<typeof ChatSchema>;
```

**Message Feature** (`src/schemas/message.schema.ts`):
```typescript
import { z } from 'zod';
import { baseSchema } from './common.schema';

export const MessageSchema = baseSchema.extend({
  parentPath: z.string(),
  messageId: z.string(),
  senderId: z.string(),
  content: z.string(),
  messageType: z.enum(['text', 'image', 'video', 'vote_request']).default('text'),
  mediaType: z.enum(['text', 'image', 'video']).default('text'),
  imageUrl: z.string().optional(),
  videoUrl: z.string().optional(),
  thumbnailUrl: z.string().optional(),
  mediaSize: z.number().default(0),
  mediaWidth: z.number().optional(),
  mediaHeight: z.number().optional(),
  timeStamp: z.date().optional(),
  deliveredAt: z.date().optional(),
  seenAt: z.date().optional(),
  isRead: z.boolean().default(false),
  // Vote Card fields
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
```

#### Step 2.3: 기존 Functions에 스키마 적용

```typescript
// src/firestore/onPostCreated.ts
import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { validatePostDisplay } from '../schemas/post.schema';

export const onPostCreatedSendNotifications = onDocumentCreated(
  'posts/{postId}',
  async (event) => {
    const data = event.data?.data();

    // ✅ 런타임 타입 검증
    const post = validatePostDisplay(data);

    // ✅ 타입 안전성
    console.log(`Post created: ${post.questionTitle}`);
    console.log(`Author: ${post.userId}`);
    console.log(`Comment count: ${post.commentCount}`);

    // AI 분석 호출
    await analyzePostContent(post);
  }
);
```

**예상 소요 시간**: 10-14일

---

### Phase 3: Dart 코드 생성 파이프라인 (1주)

#### Step 3.1: Quicktype 설치 및 설정

```bash
# Quicktype 설치
npm install --save-dev quicktype

# 또는 글로벌 설치
npm install -g quicktype
```

#### Step 3.2: 코드 생성 스크립트 작성

**package.json scripts 추가**:
```json
{
  "scripts": {
    "build": "tsc",
    "generate:dart": "node scripts/generate-dart-models.js",
    "generate:all": "npm run generate:dart && cd ../.. && dart run build_runner build --delete-conflicting-outputs",
    "deploy": "npm run build && firebase deploy --only functions"
  }
}
```

**scripts/generate-dart-models.js**:
```javascript
const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

// TypeScript 스키마 → JSON Schema
const schemas = [
  { name: 'PostDisplay', file: 'post.schema.ts' },
  { name: 'Chat', file: 'chat.schema.ts' },
  { name: 'Message', file: 'message.schema.ts' },
  { name: 'Vote', file: 'vote.schema.ts' },
  { name: 'PostVoting', file: 'voting.schema.ts' },
];

const outputDir = '../../lib/features';

schemas.forEach(({ name, file }) => {
  const schemaPath = `src/schemas/${file}`;
  const outputPath = path.join(outputDir, name.toLowerCase(), 'domain/models');

  // Quicktype 실행
  execSync(`quicktype ${schemaPath} \
    --lang dart \
    --src-lang schema \
    --out ${outputPath}/${name.toLowerCase()}.dart \
    --no-combine-classes \
    --use-freezed \
    --use-json-annotation \
    --final-properties`);

  console.log(`✅ Generated ${name}.dart`);
});

console.log('🎉 All Dart models generated successfully!');
```

#### Step 3.3: Extension Pattern 자동 생성

**scripts/generate-extensions.js**:
```javascript
const fs = require('fs');
const path = require('path');

function generateExtension(entityName, fields) {
  return `
import 'package:cloud_firestore/cloud_firestore.dart';
import '${entityName.toLowerCase()}.dart';

extension ${entityName}Firestore on ${entityName} {
  /// Firestore → Entity
  static ${entityName} fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ${entityName}.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Entity → Firestore
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');  // Firestore doc.id로 관리
    return json;
  }
}
`;
}

// 각 엔티티에 대한 Extension 생성
// (생략 - 실제 구현 시 TypeScript 스키마 파싱 필요)
```

#### Step 3.4: CI/CD 통합

**GitHub Actions 워크플로우** (`.github/workflows/codegen.yml`):
```yaml
name: Code Generation

on:
  push:
    paths:
      - 'firebase/functions/src/schemas/**'

jobs:
  generate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.8.0'

      - name: Install dependencies
        run: |
          cd firebase/functions
          npm install

      - name: Generate Dart models
        run: |
          cd firebase/functions
          npm run generate:dart

      - name: Run build_runner
        run: |
          flutter pub get
          dart run build_runner build --delete-conflicting-outputs

      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v5
        with:
          commit-message: 'chore: Auto-generate Dart models from TypeScript schemas'
          title: '🤖 Auto-generated Dart models'
          body: 'Dart models have been automatically generated from TypeScript schemas.'
```

**예상 소요 시간**: 5-7일

---

## ✅ 성공 기준 및 검증

### Phase 1 완료 기준

- [ ] TypeScript 컴파일 성공 (`npm run build`)
- [ ] 모든 Cloud Functions가 TypeScript로 변환
- [ ] 로컬 에뮬레이터 테스트 통과
- [ ] Staging 환경 배포 성공
- [ ] 기존 기능 정상 작동 확인

### Phase 2 완료 기준

- [ ] 5개 엔티티 Zod 스키마 작성 완료
- [ ] 공통 Helper 함수 구현 완료
- [ ] FlutterFlow legacy 호환성 레이어 구현
- [ ] 런타임 타입 검증 적용
- [ ] 단위 테스트 작성 (스키마 검증)

### Phase 3 완료 기준

- [ ] Quicktype 코드 생성 스크립트 작동
- [ ] Dart Freezed 모델 자동 생성 확인
- [ ] Extension Pattern 자동 생성 확인
- [ ] CI/CD 파이프라인 통합
- [ ] 전체 워크플로우 테스트 (`npm run generate:all`)

### 최종 검증 체크리스트

- [ ] TypeScript 스키마 변경 → Dart 자동 생성 검증
- [ ] 기존 Firestore 데이터 호환성 테스트
- [ ] Cloud Functions 타입 안전성 확인
- [ ] Flutter 앱 빌드 및 실행 성공
- [ ] E2E 테스트 통과
- [ ] 성능 벤치마크 (응답 시간 변화 없음)
- [ ] 문서 업데이트 완료

---

## ⚠️ 리스크 관리

### Risk 1: TypeScript 전환 중 런타임 에러

**리스크 레벨**: 🟡 Medium

**완화 전략**:
- 단계별 전환 (Function 하나씩)
- 로컬 에뮬레이터 충분한 테스트
- Staging 환경 먼저 배포
- 롤백 계획 준비 (Git tag)

### Risk 2: FlutterFlow 레거시 필드명 마이그레이션 실패

**리스크 레벨**: 🔴 High

**완화 전략**:
- 이중 필드 지원 유지 (최소 1개월)
- 점진적 마이그레이션 (Feature별 순차 진행)
- 데이터 백업 필수
- 마이그레이션 스크립트 충분한 테스트

### Risk 3: 코드 생성 파이프라인 오류

**리스크 레벨**: 🟡 Medium

**완화 전략**:
- Quicktype 대체 방안 준비 (커스텀 스크립트)
- 생성된 코드 검증 테스트
- 수동 검토 프로세스
- CI/CD 실패 시 알림

### Risk 4: 기존 Flutter 코드와 호환성 문제

**리스크 레벨**: 🟡 Medium

**완화 전략**:
- 자동 생성 코드와 기존 Extension 비교
- 단위 테스트 커버리지 ≥80%
- Integration 테스트
- Feature별 점진적 적용

### Risk 5: 팀 학습 곡선

**리스크 레벨**: 🟢 Low

**완화 전략**:
- 문서화 충실 (이 문서)
- 예시 코드 제공
- 팀 교육 세션 (2-3회)
- Pair Programming

---

## 📅 일정 요약

| Phase | 작업 내용 | 예상 기간 | 담당자 |
|-------|----------|----------|--------|
| **Phase 1** | Cloud Functions TypeScript 전환 | 1주 (5일) | Backend 개발자 |
| **Phase 2** | Zod 스키마 정의 | 2주 (10-14일) | Backend + Frontend 개발자 |
| **Phase 3** | Dart 코드 생성 파이프라인 | 1주 (5-7일) | DevOps + Frontend 개발자 |
| **검증** | 통합 테스트 및 최적화 | 1주 (5일) | 전체 팀 |
| **총계** | | **5-6주** | |

**추가 버퍼**: 1-2주 (리스크 대응)

**최종 예상 기간**: **6-8주**

---

## 🔗 관련 문서

- [Entity Analysis](/backend/analysis/entity_analysis.md) - 엔티티 패턴 분석
- [Common Patterns](/backend/analysis/common_patterns.md) - 공통 패턴
- [FlutterFlow Legacy](/backend/analysis/flutterflow_legacy.md) - 레거시 매핑
- [Zod Schemas](/backend/schemas/README.md) - Zod 스키마 가이드
- [Code Generation](/backend/codegen/README.md) - 코드 생성 파이프라인

---

**최종 업데이트**: 2025-11-02
**다음 리뷰**: Phase 1 완료 후
