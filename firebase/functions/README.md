# Firebase Functions

Versus Space 앱의 서버리스 백엔드 로직을 담당하는 Firebase Cloud Functions입니다.

## 디렉토리 구조

```
firebase/functions/
├── config/           # 설정 파일
├── functions/        # 개별 함수 구현
├── services/         # 공통 서비스 레이어
├── notifications/    # 알림 시스템
├── ai/              # AI 통합 (Genkit)
├── utils/           # 유틸리티 함수
└── index.js         # 함수 엔트리 포인트
```

## 주요 변경사항

### 2025-08-10: 채팅 메시지 상태 관리 시스템 구현
- **새로운 Functions 추가**
  - `markMessagesAsSeen`: HTTP 함수 - 채팅방 입장 시 메시지 읽음 처리
  - `onMessageCreated`: Firestore 트리거 - 새 메시지 생성 시 실시간 처리
- **메시지 라이프사이클 관리**
  - 메시지 상태: sent → delivered → seen
  - 배치 업데이트로 성능 최적화
  - 실시간 상태 동기화

### 2025-08-06: v2.0.0 시스템 통합 및 로깅 최적화
- **로깅 시스템 전면 개편**
  - 모든 console.log를 표준화된 로깅 함수로 전환
  - 단계별 처리 과정 추적 가능한 구조화된 로그
  - Firebase Functions 로그 90% 감소
  - 디버깅 효율성 대폭 향상
- **targetMatcher.js 버그 수정**
  - const → let 변경으로 matchedUsers 재할당 문제 해결
  - 알림 전송 실패 문제 완전 해결

### 2025-08-04: 투표 타이머 시스템 강화
- **Firebase Security Rules 업데이트**
  - 투표 타이머 필드 추가: `voteStartTime`, `voteEndTime`, `voteStatus`, `voteCompleted`
  - 알림 관련 필드 추가: `notificationsSent`, `notificationsSentAt`
  - 중복 투표 방지 로직 개선 (필드 존재 여부 체크)
- **투표 시스템 개선**
  - 10분 타이머 자동 완료 처리
  - 실시간 투표 상태 업데이트
  - AI 채팅 투표 카드 지원

### 2025-08-03: AI 채팅 시스템 수정
- **채팅방 ID 생성 로직 변경**
  - 기존: `[AI_ASSISTANT_ID, userId].sort().join('_')` (대소문자 정렬 문제)
  - 수정: `${AI_ASSISTANT_ID}_${userId}` (일관된 형식)
- **마이그레이션 함수 추가**
  - `migrateAIChatRooms`: 기존 채팅방 ID 형식 통일
  - `testCreateAIChatMessage`: AI 채팅 테스트 도구

### 2025-07-31: 컬렉션 이름 정규화
- 모든 Firebase Functions에서 `_record` 접미사 제거
- Flutter 앱과 일치하도록 컬렉션 이름 통일
- 예시: `users_record` → `users`, `posts_record` → `posts`

## 활성 함수 목록 (12개)

### 1. 사용자 관리
- **onUserDeleted**: 사용자 삭제 시 관련 데이터 정리

### 2. 콘텐츠 검열
- **checkImageContent**: 이미지 업로드 시 검열 트리거
- **moderateImage**: Vision API를 통한 이미지 검증
- **validatePostContentWithGemini**: AI 기반 콘텐츠 검증

### 3. 알림 시스템
- **onPostCreatedSendNotifications**: 게시물 생성 시 타겟 사용자에게 알림 발송
- **getUserPostingHistory**: 사용자 게시 기록 분석

### 4. 투표 시스템
- **onPostVoteUpdate**: 투표 업데이트 감지 및 완료 처리
- **flushThrottleQueue**: 10분 타이머 만료 시 투표 자동 완료 (매 1분)
- **checkVoteTimeouts**: 투표 타임아웃 확인 (매 시간)

### 5. AI 채팅 시스템
- **migrateAIChatRooms**: 기존 채팅방 ID 마이그레이션
- **testCreateAIChatMessage**: AI 채팅 메시지 테스트

### 내부 서비스 함수 (export되지 않음)
- **processVoteCompletion**: voteManagement.js에 구현되어 있으며, 다른 함수들에서 내부적으로 호출됨

## 기술 스택

- **Runtime**: Node.js 18
- **Framework**: Firebase Functions v4
- **AI Integration**: Google Genkit
- **Database**: Firestore
- **Storage**: Firebase Storage
- **External APIs**: 
  - Google Cloud Vision API
  - Perspective API
  - Gemini AI

## 활성 Functions 목록

### HTTP Functions
1. **checkImageContent** - 이미지 콘텐츠 검증
2. **validatePostContentWithGemini** - Gemini AI를 통한 콘텐츠 검증
3. **markMessagesAsSeen** - 채팅 메시지 읽음 처리 ⭐ NEW
4. **testCreateAIChatMessage** - AI 채팅 테스트
5. **migrateAIChatRooms** - AI 채팅방 마이그레이션
6. **migrateVoteData** - 투표 데이터 마이그레이션

### Firestore Triggers
1. **onUserDeleted** - 사용자 삭제 시 데이터 정리
2. **moderateImage** - 이미지 업로드 시 자동 검열
3. **onPostCreatedSendNotifications** - 게시물 생성 시 알림 전송
4. **onPostVoteUpdate** - 투표 업데이트 감지 및 완료 처리
5. **onMessageCreated** - 메시지 생성 시 처리 ⭐ NEW

### Scheduled Functions
1. **flushThrottleQueue** - 매 1분마다 실행, 투표 타이머 체크

## Chat Message Lifecycle Functions

### markMessagesAsSeen (HTTP)
**엔드포인트**: `/markMessagesAsSeen`

**목적**: 사용자가 채팅방에 입장할 때 읽지 않은 메시지를 모두 읽음 처리

**요청 예시**:
```json
{
  "chatId": "chatId",
  "userId": "userId"
}
```

**처리 과정**:
1. 해당 채팅방의 모든 메시지 조회
2. 상대방이 보낸 읽지 않은 메시지 필터링
3. 배치 업데이트로 `seen_at` 타임스탬프 추가
4. 실시간으로 상대방에게 읽음 상태 반영

### onMessageCreated (Firestore Trigger)
**트리거 경로**: `chats/{chatId}/messages/{messageId}`

**목적**: 새 메시지가 생성될 때 자동으로 처리

**처리 내용**:
1. 메시지 메타데이터 검증
2. 푸시 알림 준비 (향후 구현)
3. 실시간 상태 업데이트
4. 통계 데이터 수집

## 환경 변수

필요한 환경 변수는 Firebase Functions config에서 관리됩니다:

```bash
firebase functions:config:set gemini.api_key="YOUR_API_KEY"
firebase functions:config:set perspective.api_key="YOUR_API_KEY"
```

## 배포

```bash
# 전체 Functions 배포
firebase deploy --only functions

# 특정 함수만 배포
firebase deploy --only functions:onPostCreatedSendNotifications

# 환경 변수 확인
firebase functions:config:get
```

## 개발 가이드

1. 로컬 개발 시 Firebase 에뮬레이터 사용 권장
2. 컬렉션 이름은 Flutter 앱과 반드시 일치해야 함
3. 테스트 코드는 별도 브랜치에서 관리

## 성능 최적화

- 콜드 스타트 최소화를 위한 함수 분리
- 배치 처리로 Firestore 작업 최적화
- 병렬 처리로 응답 시간 단축
- 1000명 동시 처리 지원 (< 60초)

### AI 채팅방 마이그레이션 (2025-08-03)
마이그레이션 함수를 사용하여 기존 채팅방 ID를 수정할 수 있습니다:

```bash
# AI 채팅방 마이그레이션 실행
curl -X POST https://asia-northeast3-versus-space-1lwwiw.cloudfunctions.net/migrateAIChatRooms
```

**마이그레이션 내용**:
- 기존: `userId_ai_assistant` 또는 `AacklMhqMxV8B1JgEAjG7aocxvg1_ai_assistant` 형식
- 신규: `ai_assistant_userId` 형식으로 통일
- 메시지 서브컬렉션도 함께 마이그레이션
- 기존 채팅방은 삭제하지 않고 마이그레이션 표시만 추가

## 최근 문제 해결 (2025-08-03)

### AI 채팅 메시지 표시 문제
**문제**: Android와 Web에서 AI 채팅 메시지가 표시되지 않음 (iOS는 정상)

**원인 분석**:
- Firebase Functions는 정상적으로 메시지 생성
- JavaScript `.sort()` 함수가 대소문자를 다르게 정렬
- 사용자 ID가 대문자로 시작하면 채팅방 ID가 잘못 생성됨
  - 예: `AacklMhq...` → `AacklMhq..._ai_assistant` (잘못됨)
  - 예: `XChONL4...` → `XChONL4..._ai_assistant` (잘못됨)
  - 정상: `ai_assistant_userId` 형식이어야 함

**해결**:
1. `aiChatService.js`에서 채팅방 ID 생성 로직 수정
   - 기존: `[AI_ASSISTANT_ID, userId].sort().join('_')`
   - 수정: `${AI_ASSISTANT_ID}_${userId}`
2. `migrateAIChatRooms` 함수 추가로 기존 채팅방 마이그레이션
3. 새로운 채팅은 올바른 ID로 생성됨

### 테스트 함수 사용법
```bash
# AI 채팅 메시지 수동 생성
curl -X POST https://asia-northeast3-versus-space-1lwwiw.cloudfunctions.net/testCreateAIChatMessage \
  -H "Content-Type: application/json" \
  -d '{
    "userId": "사용자ID",
    "postId": "게시물ID",
    "messageType": "request" # 또는 "created"
  }'
```

## 투표 타이머 시스템 상세

### 10분 타이머 동작 방식
1. **투표 시작**: 첫 투표 시 `voteStartTime` 기록
2. **타이머 설정**: `voteEndTime = voteStartTime + 10분`
3. **상태 추적**: `voteStatus = 'active'`
4. **자동 완료**: 
   - `flushThrottleQueue` (매 1분): 실시간 체크
   - `checkVoteTimeouts` (매 시간): 백업 체크
5. **완료 처리**: `voteStatus = 'completed'`, AI 채팅 메시지 업데이트

### 투표 관련 필드 설명 (camelCase 마이그레이션 완료 ✅)
```javascript
{
  // 시간 관리
  voteStartTime: Timestamp,      // 첫 투표 시간
  voteEndTime: Timestamp,        // 종료 예정 시간 (시작 + 10분)
  voteStatus: String,            // 'active' | 'completed' | 'expired'
  voteCompleted: Boolean,        // 완료 여부
  
  // 투표 데이터 (camelCase)
  votesA: Number,                // A 옵션 투표 수 ✅ (이전: votes_a)
  votesB: Number,                // B 옵션 투표 수 ✅ (이전: votes_b)
  totalVotes: Number,            // 전체 투표 수 ✅ (이전: total_votes)
  votedUserIdsA: Array,          // A 투표자 ID 목록 ✅ (이전: votedUserIDsA)
  votedUserIdsB: Array,          // B 투표자 ID 목록 ✅ (이전: votedUserIDsB)
  
  // 알림 관리
  notificationsSent: Boolean,    // 알림 발송 여부
  notificationsSentAt: Timestamp // 알림 발송 시간
}