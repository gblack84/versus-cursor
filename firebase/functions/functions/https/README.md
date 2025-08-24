# 🌐 HTTPS 트리거 함수

## 📋 개요

HTTP(S) 요청을 통해 호출되는 Cloud Functions 디렉토리입니다. REST API 엔드포인트, 콘텐츠 검증, 데이터 마이그레이션, 테스트 유틸리티 등 다양한 웹 서비스 기능을 제공합니다. 클라이언트 앱과 직접 통신하며 실시간 데이터 처리와 검증을 담당합니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: API 엔드포인트, 콘텐츠 검증, 데이터 마이그레이션
- **권장사항**: 핵심 API 기능과 마이그레이션 도구 제공

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `checkImageContent.js`, `migrateVoteData.js` |
| **함수명** | camelCase | `validatePostContentWithGemini()`, `migrateAIChatRooms()` |
| **변수명** | camelCase | `userId`, `postData`, `migrationResults` |
| **상수** | UPPER_SNAKE_CASE | `AI_ASSISTANT_ID` |
| **HTTP 엔드포인트** | camelCase | `/checkImageContent`, `/migrateVoteData` |

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
https/
├── checkImageContent.js               # 이미지 콘텐츠 검증 (49줄)
├── validatePostContentWithGemini.js   # Gemini AI 콘텐츠 검증 (182줄)
├── testCreateAIChatMessage.js         # AI 채팅 메시지 테스트 (95줄)
├── migrateAIChatRooms.js             # AI 채팅방 ID 마이그레이션 (145줄)
├── migrateVoteData.js                # 투표 데이터 마이그레이션 (152줄)
├── migrateSnakeToCamel.js            # snake_case → camelCase 변환
├── migrateEntireDatabase.js          # 전체 DB 마이그레이션
├── fullDatabaseScan.js               # DB 전체 스캔 유틸리티
├── debugMigration.js                 # 마이그레이션 디버깅
├── markMessagesAsSeen.js             # 메시지 읽음 처리
└── README.md                          # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. checkImageContent.js - 이미지 콘텐츠 검증
**클라이언트에서 이미지 업로드 전 사전 검증** (49줄)

#### 핵심 기능
- **호출 방식**: onCall (인증 필수)
- **Vision API 통합**: Cloud Vision API로 이미지 분석
- **안전성 검사**: 선정성, 폭력성, 텍스트 감지
- **실시간 피드백**: 즉각적인 검증 결과 반환

#### 코드 예시
```javascript
exports.checkImageContent = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated');
    }
    
    // Vision API로 이미지 검사
    const result = await checkImageContent(image);
    
    return {
      isAppropriate: result.isAppropriate,
      reason: result.reason,
      hasText: result.hasText
    };
  });
```

### 2. validatePostContentWithGemini.js - AI 통합 콘텐츠 검증
**Gemini AI를 활용한 포괄적 콘텐츠 검증 시스템** (182줄)

#### 핵심 기능
- **다층 검증**: Perspective API + Vision API + Gemini AI
- **투표 예측**: AI 기반 예상 투표 비율 계산
- **세션 관리**: documentId로 검증 이력 추적
- **타임아웃 처리**: 5분 제한, 실패 시 기본 통과
- **토큰 추적**: AI 사용량 모니터링

#### 검증 플로우
```
클라이언트 요청
    ↓
인증 확인
    ↓
Genkit AI 검증
    ↓
┌─────────────────────┐
│  다층 분석 실행      │
├─────────────────────┤
│ 1. 텍스트 분석      │
│ 2. 이미지 분석      │
│ 3. 논리적 타당성    │
│ 4. 투표 예측        │
└─────────────────────┘
    ↓
결과 로깅 및 반환
```

#### 코드 예시
```javascript
// Genkit 기반 검증
const result = await validateContentWithGenkit({
  userId,
  questionTitle: question,
  description: descriptionText,
  titleA, titleB,
  imageUrlA, imageUrlB,
  visionDataA, visionDataB,
  perspectiveScores: perspectiveData
});

// 예상 투표 비율 포함 응답
return {
  isValid: result.isValid,
  reason: result.reason,
  severity: result.severity,
  suggestions: result.suggestions,
  expectedRatio: result.expectedRatio || { A: 0.5, B: 0.5 }
};
```

### 3. testCreateAIChatMessage.js - AI 채팅 테스트
**AI 채팅 메시지 생성 기능 테스트 유틸리티** (95줄)

#### 핵심 기능
- **HTTP 엔드포인트**: onRequest로 직접 호출 가능
- **메시지 타입**: request(투표 요청), created(생성 알림)
- **데이터 포맷팅**: optionA/B Map 구조 처리
- **디버깅 지원**: 상세한 에러 스택 반환

#### 코드 예시
```javascript
// 게시물 데이터 처리
if (typeof postData.optionA === 'object') {
  optionATitle = postData.optionA.title || '';
  imageUrlsA = postData.optionA.mediaUrls || [];
}

// 메시지 생성
if (messageType === 'created') {
  messageId = await createVoteCreatedMessage(userId, postId, formattedData);
} else {
  messageId = await createVoteRequestMessage(userId, postId, formattedData);
}
```

### 4. migrateAIChatRooms.js - AI 채팅방 마이그레이션
**잘못된 채팅방 ID를 올바른 형식으로 변환** (145줄)

#### 마이그레이션 내용
- **기존 형식**: `{userId}_{AI_ASSISTANT_ID}` (대소문자 혼재)
- **신규 형식**: `ai_assistant_{userId}` (일관된 형식)
- **트랜잭션 처리**: 안전한 데이터 이전
- **메시지 보존**: 모든 메시지 서브컬렉션 복사

#### 처리 플로우
```javascript
// 트랜잭션으로 안전하게 처리
await admin.firestore().runTransaction(async (transaction) => {
  // 1. 기존 채팅방 읽기
  const oldChatDoc = await transaction.get(oldChatRef);
  
  // 2. 새 채팅방 생성
  transaction.set(newChatRef, {
    ...chatData,
    migrated_from: currentChatId,
    migrated_at: admin.firestore.Timestamp.now()
  });
  
  // 3. 메시지 복사
  messagesSnapshot.docs.forEach(messageDoc => {
    transaction.set(newMessageRef, messageDoc.data());
  });
  
  // 4. 마이그레이션 표시
  transaction.update(oldChatRef, {
    migrated_to: newChatId,
    is_migrated: true
  });
});
```

### 5. migrateVoteData.js - 투표 데이터 구조 변환
**레거시 투표 구조를 새로운 Map 형식으로 변환** (152줄)

#### 마이그레이션 내용
- **기존**: 단일 사용자 투표 (`user_voted`, `vote_choice`)
- **신규**: Map 구조 (`user_votes[userId] = {option, voted_at}`)
- **DRY RUN 지원**: 실제 변경 전 시뮬레이션
- **제한 옵션**: limit 파라미터로 부분 실행

#### 코드 예시
```javascript
// 레거시 데이터를 Map으로 변환
if (messageData.user_voted === true && messageData.sender_id) {
  const userVotes = {};
  userVotes[messageData.sender_id] = {
    option: messageData.vote_choice || '',
    voted_at: messageData.vote_participated_at || Timestamp.now()
  };
  
  // 업데이트
  await messageDoc.ref.update({
    user_votes: userVotes,
    migrated_at: Timestamp.now(),
    migration_version: '1.0'
  });
}
```

## 💡 시스템 아키텍처

### HTTP 함수 전체 플로우

```
클라이언트 앱
    ↓
Cloud Functions HTTPS
    ↓
┌──────────────────────┐
│  인증 & 권한 확인     │
├──────────────────────┤
│  요청 데이터 검증     │
├──────────────────────┤
│  비즈니스 로직 실행   │
├──────────────────────┤
│  외부 API 연동       │
│  - Vision API        │
│  - Gemini AI         │
│  - Perspective API   │
├──────────────────────┤
│  Firestore 작업      │
└──────────────────────┘
    ↓
응답 반환
```

### 보안 계층

1. **인증 검증**
   - onCall: Firebase Auth 자동 검증
   - onRequest: 수동 토큰 검증 필요

2. **입력 검증**
   - 필수 파라미터 확인
   - 데이터 타입 검증
   - SQL 인젝션 방지

3. **에러 처리**
   - HttpsError로 적절한 에러 코드 반환
   - 민감한 정보 마스킹
   - 상세 로깅 (개발 환경)

## 🔍 문제 해결 가이드

### 일반적인 문제

1. **CORS 에러**
```
Access to fetch at 'https://...' from origin 'http://localhost' has been blocked by CORS
```
- Firebase 프로젝트 설정에서 도메인 추가
- functions.config()로 허용 도메인 설정

2. **타임아웃 에러**
```
DEADLINE_EXCEEDED
```
- 함수 타임아웃 설정 증가 (최대 9분)
- 무거운 작업은 Pub/Sub으로 비동기 처리
- 배치 처리로 작업 분할

3. **인증 실패**
```
HttpsError: unauthenticated
```
- Firebase Auth 토큰 유효성 확인
- 클라이언트 SDK 버전 확인
- 네트워크 시간 동기화 확인

## 🚀 모범 사례

### 1. 에러 처리
```javascript
try {
  // 비즈니스 로직
} catch (error) {
  logger.error('작업 실패', error);
  
  // 클라이언트에 적절한 에러 반환
  if (error.code === 'permission-denied') {
    throw new functions.https.HttpsError('permission-denied', '권한이 없습니다');
  }
  
  // 일반 에러는 internal로
  throw new functions.https.HttpsError('internal', '처리 중 오류가 발생했습니다');
}
```

### 2. 입력 검증
```javascript
// 필수 파라미터 검증
if (!userId || !postId) {
  throw new functions.https.HttpsError(
    'invalid-argument', 
    '필수 파라미터가 누락되었습니다'
  );
}

// 타입 검증
if (typeof limit !== 'number' || limit < 0) {
  throw new functions.https.HttpsError(
    'invalid-argument',
    'limit은 양수여야 합니다'
  );
}
```

### 3. 트랜잭션 사용
```javascript
// 여러 문서를 원자적으로 업데이트
await admin.firestore().runTransaction(async (transaction) => {
  // 읽기 작업을 먼저
  const doc1 = await transaction.get(ref1);
  const doc2 = await transaction.get(ref2);
  
  // 쓰기 작업은 나중에
  transaction.set(ref1, data1);
  transaction.update(ref2, data2);
});
```

## 📊 성능 지표

### 현재 성능
| 함수 | 평균 응답 시간 | 메모리 사용 | 콜드 스타트 |
|------|---------------|------------|-------------|
| **checkImageContent** | 800ms | 256MB | 2s |
| **validatePostContentWithGemini** | 2.5s | 1GB | 3s |
| **testCreateAIChatMessage** | 300ms | 256MB | 1.5s |
| **migrateAIChatRooms** | 변동 | 512MB | 2s |
| **migrateVoteData** | 변동 | 512MB | 2s |

### 최적화 팁
- 콜드 스타트 최소화: 최소 인스턴스 설정
- 메모리 최적화: 필요한 모듈만 import
- 캐싱 활용: 자주 사용되는 데이터 캐싱

## 📈 모니터링

### Cloud Logging 쿼리
```javascript
// HTTP 함수 에러 추적
resource.type="cloud_function"
resource.labels.function_name=~"checkImageContent|validatePostContent"
severity="ERROR"

// 마이그레이션 진행 상황
jsonPayload.mode="PRODUCTION"
jsonPayload.totalMessages>0

// API 응답 시간 분석
resource.type="cloud_function"
labels."execution_id"
jsonPayload.duration>1000
```

### 주요 메트릭
- API 응답 시간
- 에러율 및 에러 타입
- AI API 사용량 및 비용
- 마이그레이션 진행률

## 📝 변경 이력

### 2025-08-24: HTTPS 함수 통합
- checkImageContent: Vision API 이미지 검증
- validatePostContentWithGemini: Gemini AI 통합 검증
- testCreateAIChatMessage: AI 채팅 테스트 도구
- 마이그레이션 도구 세트 구현

### 2025-08-21: Snake_case → CamelCase 마이그레이션
- 모든 필드명 camelCase로 통일
- migrateSnakeToCamel 함수 구현
- 전체 데이터베이스 변환 완료

### 2025-08-20: AI 시스템 통합
- Genkit 프레임워크 도입
- Gemini 1.5 Pro 통합
- 투표 예측 시스템 구현

## 🎯 향후 계획

### 단기 (1-2개월)
1. **Rate Limiting 구현**
   - IP 기반 요청 제한
   - 사용자별 할당량 관리
   - DDoS 방어 메커니즘

2. **캐싱 전략**
   - Redis 통합
   - CDN 활용
   - 응답 캐싱

### 장기 (3-6개월)
1. **GraphQL 지원**
   - Apollo Server 통합
   - 구독(Subscription) 지원
   - 배치 쿼리 최적화

2. **웹훅 시스템**
   - 외부 서비스 연동
   - 이벤트 기반 알림
   - 재시도 메커니즘

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../../README.md)
- [AI 시스템](../../ai/README.md)
- [서비스 레이어](../../services/README.md)
- [설정 관리](../../config/README.md)
- [네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

### 외부 참조
- [Cloud Functions for Firebase](https://firebase.google.com/docs/functions)
- [Callable Functions](https://firebase.google.com/docs/functions/callable)
- [HTTP Functions](https://firebase.google.com/docs/functions/http-events)
- [Genkit Documentation](https://firebase.google.com/docs/genkit)

## ⚠️ 보안 고려사항

### API 보안
- 모든 onCall 함수는 인증 필수
- 민감한 작업은 권한 검증 추가
- Rate limiting으로 남용 방지

### 데이터 보호
- 개인정보 마스킹 (logger.maskSensitive)
- HTTPS 전송 암호화
- 입력 데이터 검증 및 살균

### 마이그레이션 안전성
- DRY RUN 모드 제공
- 트랜잭션으로 원자성 보장
- 백업 후 실행 권장

---

*이 디렉토리는 HTTP(S) 요청을 처리하여 클라이언트 앱과 서버 간 통신을 담당하는 핵심 API 시스템입니다.*