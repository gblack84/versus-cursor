# 공통 패턴 분석

> **작성일**: 2025-11-02
> **목적**: Feature 간 재사용 가능한 공통 패턴 추출

---

## 📌 필수 공통 필드

### 모든 Feature에 공통 (100% 출현)

| 필드명 | 타입 | 용도 | 기본값 |
|-------|------|------|--------|
| `id` | String | Firestore 문서 ID | doc.id |
| `createdAt` | DateTime | 생성 시간 | DateTime.now() |

**TypeScript 권장**:
```typescript
const baseSchema = z.object({
  id: z.string().describe("Document ID"),
  createdAt: z.date().describe("Creation timestamp"),
  updatedAt: z.date().optional(),
});
```

### 사용자 참조 필드 (80% 출현)

| 필드명 | 타입 | 출현 빈도 |
|-------|------|----------|
| `userId` / `uid` | String | 4/5 (80%) |
| `displayName` / `username` | String? | 3/5 (60%) |
| `photoUrl` | String? | 3/5 (60%) |

**TypeScript 권장**:
```typescript
const userRefSchema = z.object({
  userId: z.string(),
  displayName: z.string().optional(),
  photoUrl: z.string().optional(),
});
```

---

## 🕐 Timestamp 처리 패턴

### _parseDateTime() 공통 Helper (100% 출현)

**모든 Feature에서 동일한 로직 사용**:

```dart
static DateTime? _parseDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is Timestamp) return value.toDate();  // Firestore
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);  // ISO 8601
  return null;
}
```

**TypeScript 등가 코드**:
```typescript
function parseTimestamp(value: any): Date | undefined {
  if (!value) return undefined;
  if (value instanceof Date) return value;
  if (value.toDate) return value.toDate();  // Firestore Timestamp
  if (typeof value === 'number') return new Date(value);
  if (typeof value === 'string') return new Date(value);
  return undefined;
}
```

---

## 📋 List/Array 처리 패턴

### String List 파싱 (73% 출현)

**사용처**: 이미지 URL 배열, 참여자 ID 배열

```dart
static List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .whereType<String>()
        .where((s) => s.isNotEmpty)  // 빈 문자열 필터링
        .toList();
  }
  return [];
}
```

**TypeScript 등가 코드**:
```typescript
function parseStringArray(value: any): string[] {
  if (!Array.isArray(value)) return [];
  return value.filter(v => typeof v === 'string' && v.length > 0);
}
```

### Number List 파싱 (aspectRatios 전용)

**사용처**: 이미지 aspectRatios (Post, Message)

```dart
static List<double> _parseDoubleList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value.map((e) {
      if (e is double) return e;
      if (e is int) return e.toDouble();
      if (e is String) return double.tryParse(e) ?? 1.0;
      return 1.0;  // 기본값 1.0 (정사각형)
    }).toList();
  }
  return [];
}
```

**TypeScript 등가 코드**:
```typescript
function parseNumberArray(value: any, defaultValue: number = 1.0): number[] {
  if (!Array.isArray(value)) return [];
  return value.map(v => {
    if (typeof v === 'number') return v;
    if (typeof v === 'string') return parseFloat(v) || defaultValue;
    return defaultValue;
  });
}
```

---

## 🗺️ Map 처리 패턴

### Generic Map (metadata, targetAudience)

**사용처**: targetAudience (Post), voteResults (Message)

```dart
static Map<String, dynamic>? _parseMap(dynamic value) {
  if (value == null) return null;
  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  return null;
}
```

**TypeScript 등가 코드**:
```typescript
function parseMap(value: any): Record<string, any> | null {
  if (!value || typeof value !== 'object') return null;
  return { ...value };
}
```

### Timestamp Map (lastReadTimestamps)

**사용처**: Chat Feature 전용 (사용자별 읽음 시간)

```dart
static Map<String, DateTime> _parseTimestampMap(dynamic value) {
  if (value == null) return {};
  if (value is Map) {
    final result = <String, DateTime>{};
    value.forEach((key, val) {
      if (key is String && val is Timestamp) {
        result[key] = val.toDate();
      }
    });
    return result;
  }
  return {};
}
```

**TypeScript 등가 코드**:
```typescript
function parseTimestampMap(value: any): Record<string, Date> {
  if (!value || typeof value !== 'object') return {};

  const result: Record<string, Date> = {};
  Object.entries(value).forEach(([key, val]) => {
    const date = parseTimestamp(val);
    if (date) result[key] = date;
  });
  return result;
}
```

---

## 🔢 Enum 처리 패턴

### VoteStatus Enum (Voting Feature 전용)

**Enum 정의**:
```dart
enum VoteStatus {
  pending,
  active,
  completed,
  cancelled,
  timeout,
}
```

**String → Enum**:
```dart
static VoteStatus _voteStatusFromJson(dynamic value) {
  if (value == null) return VoteStatus.pending;
  if (value is VoteStatus) return value;

  switch (value.toString().toLowerCase()) {  // 대소문자 무시
    case 'active': return VoteStatus.active;
    case 'completed': return VoteStatus.completed;
    case 'cancelled': return VoteStatus.cancelled;
    case 'timeout': return VoteStatus.timeout;
    default: return VoteStatus.pending;
  }
}
```

**Enum → String**:
```dart
static String _voteStatusToJson(VoteStatus status) {
  switch (status) {
    case VoteStatus.pending: return 'pending';
    case VoteStatus.active: return 'active';
    case VoteStatus.completed: return 'completed';
    case VoteStatus.cancelled: return 'cancelled';
    case VoteStatus.timeout: return 'timeout';
  }
}
```

**TypeScript 등가 코드**:
```typescript
enum VoteStatus {
  Pending = 'pending',
  Active = 'active',
  Completed = 'completed',
  Cancelled = 'cancelled',
  Timeout = 'timeout',
}

// Zod schema
const voteStatusSchema = z.enum(['pending', 'active', 'completed', 'cancelled', 'timeout']);

// Runtime validation
function parseVoteStatus(value: any): VoteStatus {
  const normalized = value?.toString().toLowerCase();
  switch (normalized) {
    case 'active': return VoteStatus.Active;
    case 'completed': return VoteStatus.Completed;
    case 'cancelled': return VoteStatus.Cancelled;
    case 'timeout': return VoteStatus.Timeout;
    default: return VoteStatus.Pending;
  }
}
```

---

## 📦 Nested Object 패턴

### Option 데이터 (Post Feature)

**Firestore 구조**:
```json
{
  "optionA": {
    "text": "Option A",
    "images": ["url1", "url2"],
    "aspectRatios": [1.5, 1.2]
  }
}
```

**Extension 파싱**:
```dart
static Map<String, dynamic> _parseOptionData(
  Map<String, dynamic> data,
  String optionKey,
) {
  return data[optionKey] as Map<String, dynamic>? ?? {};
}

static List<String> _parseOptionImages(
  Map<String, dynamic> data,
  String optionKey,
) {
  final option = _parseOptionData(data, optionKey);
  return _parseStringList(option['images']);
}
```

**TypeScript 권장**:
```typescript
const postOptionSchema = z.object({
  text: z.string().optional(),
  images: z.array(z.string()).optional(),
  aspectRatios: z.array(z.number()).optional(),
});

const postSchema = z.object({
  // ...
  optionA: postOptionSchema.optional(),
  optionB: postOptionSchema.optional(),
});
```

---

## ✅ DO / ❌ DON'T 가이드

### ✅ DO (권장)

**1. Helper 함수 재사용**:
```dart
// ✅ 공통 Helper 사용
final timestamp = _parseDateTime(data['createdAt']);
```

**2. Null-safe 기본값**:
```dart
// ✅ 기본값 제공
final images = _parseStringList(data['images']) ?? [];
final count = data['count'] as int? ?? 0;
```

**3. 타입 가드**:
```dart
// ✅ 타입 체크 후 변환
if (value is List) {
  return value.whereType<String>().toList();
}
```

**4. Enum 대소문자 무시**:
```dart
// ✅ 대소문자 무시
switch (value.toString().toLowerCase()) { }
```

### ❌ DON'T (피해야 할 것)

**1. 직접 Timestamp 접근**:
```dart
// ❌ 타입 에러 가능
final date = data['createdAt'].toDate();

// ✅ Helper 사용
final date = _parseDateTime(data['createdAt']);
```

**2. List 타입 가정**:
```dart
// ❌ 런타임 에러 가능
final images = data['images'] as List<String>;

// ✅ 안전한 파싱
final images = _parseStringList(data['images']);
```

**3. Null 체크 생략**:
```dart
// ❌ NullPointerException
final text = data['optionA']['text'];

// ✅ Null-safe 접근
final optionA = _parseOptionData(data, 'optionA');
final text = optionA['text'] as String? ?? '';
```

**4. Enum 문자열 직접 비교**:
```dart
// ❌ 대소문자 불일치 가능
if (data['status'] == 'PENDING') { }

// ✅ Helper 사용
final status = _voteStatusFromJson(data['status']);
```

---

## 🎯 TypeScript 스키마 권장사항

### 공통 Helper 모듈 (`common.schema.ts`)

```typescript
import { z } from 'zod';
import * as admin from 'firebase-admin';

// Base schemas
export const baseSchema = z.object({
  id: z.string(),
  createdAt: z.date(),
  updatedAt: z.date().optional(),
});

export const userRefSchema = z.object({
  userId: z.string(),
  displayName: z.string().optional(),
  photoUrl: z.string().optional(),
});

// Timestamp helpers
export function parseTimestamp(value: any): Date | undefined {
  // ... (위 코드 참조)
}

export function toFirestoreTimestamp(date: Date | undefined) {
  return date ? admin.firestore.Timestamp.fromDate(date) : undefined;
}

// Array helpers
export function parseStringArray(value: any): string[] {
  // ... (위 코드 참조)
}

export function parseNumberArray(value: any, defaultValue: number = 1.0): number[] {
  // ... (위 코드 참조)
}

// Map helpers
export function parseMap(value: any): Record<string, any> | null {
  // ... (위 코드 참조)
}

export function parseTimestampMap(value: any): Record<string, Date> {
  // ... (위 코드 참조)
}
```

---

## 🔗 관련 문서

- [Entity Analysis](./entity_analysis.md) - 엔티티별 상세 분석
- [FlutterFlow Legacy](./flutterflow_legacy.md) - 레거시 필드 매핑
- [Zod Schemas](/backend/schemas/common_helpers.ts) - TypeScript Helper 함수

---

**최종 업데이트**: 2025-11-02
