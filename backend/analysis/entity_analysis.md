# Entity 패턴 분석 결과

> **작성일**: 2025-11-02
> **분석 대상**: Post, Chat, Message, Vote, PostVoting (5개 엔티티, 119개 필드)

---

## 📊 엔티티 비교 테이블

| Feature | Entity | 총 필드 수 | Timestamp 필드 | List 필드 | Map 필드 | Enum 필드 | FlutterFlow 필드 |
|---------|--------|----------|--------------|----------|----------|----------|----------------|
| **Post** | PostDisplay | 30 | 3 | 4 | 1 | 0 | ✅ 5개 |
| **Chat** | Chat | 17 | 3 | 1 | 1 | 0 | ❌ 없음 |
| **Chat** | Message | 45 | 4 | 4 | 3 | 0 | ❌ 없음 |
| **Voting** | Vote | 4 | 1 | 0 | 0 | 0 | ❌ 없음 |
| **Voting** | PostVoting | 23 | 6 | 2 | 0 | 1 | ❌ 없음 |
| **총계** | **5개** | **119개** | **17개** | **11개** | **5개** | **1개** | **5개** |

---

## 🔍 상세 엔티티 분석

### 1. PostDisplay (Post Feature)

**파일**: `lib/features/post/domain/models/post_display.dart:20-165`

**필드 구성** (30개):
- **Identification** (4): id, userId, displayName, photoUrl
- **Content** (10): questionTitle, description, optionAText, optionBText, images, aspectRatios
- **Voting** (7): votesA, votesB, voteStatus, voteCompleted, voteStartTime, voteEndTime, layoutType
- **Metrics** (3): commentCount, likeCount, shareCount
- **Metadata** (6): createdAt, isAnonymous, status, targetAudience

**특이사항**:
- ✅ FlutterFlow 레거시 5개 필드 (userid, username, commentcount, likecount, sharecount)
- ✅ Dual-field 지원 (Extension에서 자동 변환)
- ✅ 가장 복잡한 엔티티 (30 fields, 사용자 대면)

**Extension 위치**: `lib/features/post/domain/models/post_display_extensions.dart`

---

### 2. Chat (Chat Feature)

**파일**: `lib/features/chat/domain/entities/chat.dart`

**필드 구성** (17개):
- **Identification** (2): id, chatId
- **Participants** (2): participantIds, chatName
- **Content** (2): lastMessageContent, lastMessageAt
- **Type & Status** (2): chatType, isRead
- **Timestamps** (3): createdAt, lastMessageAt, lastReadTimestamps (Map<String, DateTime>)
- **Metadata** (6): 기타 채팅 메타데이터

**특이사항**:
- ✅ Pure camelCase (FlutterFlow 레거시 없음)
- ✅ Map<String, DateTime> lastReadTimestamps (사용자별 읽음 시간)
- ✅ 1:1, direct, group 채팅 타입 지원

**Extension 위치**: `lib/features/chat/data/extensions/chat_extensions.dart`

---

### 3. Message (Chat Feature)

**파일**: `lib/features/chat/domain/entities/message.dart`

**필드 구성** (45개):
- **Identification** (3): id, messageId, parentPath
- **Content** (2): content, senderId
- **Media** (8): mediaType, imageUrl, videoUrl, thumbnailUrl, mediaSize, mediaWidth, mediaHeight
- **Lifecycle** (4): timeStamp, deliveredAt, seenAt, isRead
- **Vote Card** (10): votePostId, voteTitle, voteOptionAText, voteOptionBText, voteOptionAImages, voteOptionBImages, voteStatus, voteEndTime, voteResults, userVotes
- **Metadata** (18): 기타 메시지 메타데이터

**특이사항**:
- ✅ 가장 많은 필드 (45개)
- ✅ Vote Card 내장 (10개 vote 관련 필드)
- ✅ 미디어 메시지 지원 (image, video, thumbnails)
- ✅ 3-Layer 메시지 상태 (delivered, seen, read)

**Extension 위치**: `lib/features/chat/data/extensions/message_extensions.dart`

---

### 4. Vote (Voting Feature)

**파일**: `lib/features/voting/domain/entities/vote.dart`

**필드 구성** (4개):
- postId (String)
- userId (String)
- choice (String: 'A' or 'B')
- timestamp (DateTime?)

**특이사항**:
- ✅ 가장 단순한 엔티티 (4 fields)
- ✅ Composite key 패턴 (postId + userId)
- ✅ 투표 기록 전용

---

### 5. PostVoting (Voting Feature)

**파일**: `lib/features/voting/domain/entities/post_voting.dart`

**필드 구성** (23개):
- **Identification** (1): postId
- **Timing** (6): voteStartTime, voteEndTime, voteCompletedAt, voteCancelledAt, voteTimeout
- **Status** (4): voteStatus (Enum), voteCompleted, voteCancelledReason
- **Results** (4): votesA, votesB, votedUserIdsA, votedUserIdsB
- **Display** (2): displayVotesA, displayVotesB
- **Notifications** (2): notificationsSent, notificationsSentAt
- **Expansion** (4): expansionPointsUsed, expandedUserCount, expansionStatus

**특이사항**:
- ✅ Enum 사용 (VoteStatus: pending, active, completed, cancelled, timeout)
- ✅ Duration → milliseconds 변환 (voteTimeout)
- ✅ 복잡한 비즈니스 로직 (알림, 확장 등)

**Extension 위치**: `lib/features/voting/data/extensions/post_voting_extensions.dart`

---

## 📈 필드 타입 통계

### Timestamp 필드 (17개, 14.3%)

| 엔티티 | Timestamp 필드 | 비율 |
|--------|---------------|------|
| PostDisplay | 3 (createdAt, voteStartTime, voteEndTime) | 10% |
| Chat | 3 (createdAt, lastMessageAt, lastReadTimestamps) | 17.6% |
| Message | 4 (timeStamp, deliveredAt, seenAt, voteEndTime) | 8.9% |
| Vote | 1 (timestamp) | 25% |
| PostVoting | 6 (다양한 lifecycle 시간) | 26.1% |

**공통 패턴**: 모든 엔티티가 `_parseDateTime()` Helper 사용

### List 필드 (11개, 9.2%)

| 엔티티 | List 필드 | 타입 |
|--------|----------|------|
| PostDisplay | optionAImages, optionBImages | List<String> |
| PostDisplay | optionAAspectRatios, optionBAspectRatios | List<double> |
| Chat | participantIds | List<String> |
| Message | voteOptionAImages, voteOptionBImages | List<String> (각 2개) |
| PostVoting | votedUserIdsA, votedUserIdsB | List<String> |

**공통 패턴**: `_parseStringList()`, `_parseDoubleList()` Helper

### Map 필드 (5개, 4.2%)

| 엔티티 | Map 필드 | 타입 |
|--------|----------|------|
| PostDisplay | targetAudience | Map<String, dynamic> |
| Chat | lastReadTimestamps | Map<String, DateTime> |
| Message | voteResults | Map<String, dynamic> |
| Message | userVotes | Map<String, dynamic> |
| Message | metadata | Map<String, dynamic> (추정) |

**공통 패턴**: `_parseMap()`, `_parseTimestampMap()` Helper

### Enum 필드 (1개, 0.8%)

| 엔티티 | Enum 필드 | 값 |
|--------|----------|-----|
| PostVoting | VoteStatus | pending, active, completed, cancelled, timeout |

**공통 패턴**: `_voteStatusFromJson()`, `_voteStatusToJson()` 변환

---

## 🔢 필드 크기 분포

```
PostDisplay ████████████████████████████████  30 fields
Message     █████████████████████████████████████████████  45 fields
PostVoting  ███████████████████████  23 fields
Chat        █████████████████  17 fields
Vote        ████  4 fields
```

**평균 필드 수**: 119 / 5 = 23.8개

**중앙값**: 23개 (PostVoting)

**최빈값**: 없음 (모두 unique)

---

## 📋 FlutterFlow 레거시 출현 빈도

| 엔티티 | FlutterFlow 필드 | 출현 비율 |
|--------|----------------|----------|
| PostDisplay | ✅ 5개 (userid, username, commentcount, likecount, sharecount) | 16.7% (5/30) |
| Chat | ❌ 0개 | 0% |
| Message | ❌ 0개 | 0% |
| Vote | ❌ 0개 | 0% |
| PostVoting | ❌ 0개 | 0% |
| **총계** | **5개** | **4.2% (5/119)** |

**결론**: FlutterFlow 레거시는 **Post Feature에만 집중**되어 있음 (5개 필드, 4.2%)

---

## 🎯 TypeScript 스키마 설계 시사점

### 1. 공통 Base Schema 필요

```typescript
// 모든 엔티티에 공통
const baseSchema = z.object({
  id: z.string(),
  createdAt: z.date(),
  updatedAt: z.date().optional(),
});
```

### 2. User Reference Schema 공통화

```typescript
// 사용자 정보 필드 (80% 출현)
const userRefSchema = z.object({
  userId: z.string(),
  displayName: z.string().optional(),
  photoUrl: z.string().optional(),
});
```

### 3. Timestamp Helper 필수

```typescript
function parseTimestamp(value: any): Date | undefined {
  // Firestore Timestamp, Date, int, string 지원
}
```

### 4. FlutterFlow 호환성 레이어

```typescript
function normalizeLegacyFields(data: any): any {
  // Post Feature 전용 (5개 필드)
  return {
    userId: data.userid ?? data.userId,
    // ...
  };
}
```

### 5. List/Map Helper 재사용

```typescript
function parseStringArray(value: any): string[] { }
function parseNumberArray(value: any, defaultValue: number): number[] { }
function parseMap(value: any): Map<string, any> { }
function parseTimestampMap(value: any): Map<string, Date> { }
```

---

## 🔗 관련 문서

- [Common Patterns](./common_patterns.md) - 공통 패턴 상세 분석
- [FlutterFlow Legacy](./flutterflow_legacy.md) - 레거시 매핑 및 마이그레이션
- [Zod Schemas](/backend/schemas/README.md) - TypeScript 스키마 설계 가이드

---

**최종 업데이트**: 2025-11-02
