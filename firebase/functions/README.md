# 🔥 Firebase Functions - Versus Space 백엔드 시스템

## 📋 개요

Versus Space의 서버리스 백엔드 시스템으로, Firebase Cloud Functions v2를 기반으로 구축되었습니다. 실시간 알림, AI 기반 콘텐츠 검열, 자동화된 투표 처리, 스마트 사용자 매칭 등 핵심 비즈니스 로직을 담당합니다.

### 프로젝트 정보
- **프레임워크**: Firebase Functions v2 (Node.js 20)
- **AI 플랫폼**: Google Genkit + Gemini AI
- **데이터베이스**: Cloud Firestore
- **스토리지**: Firebase Storage
- **모니터링**: Cloud Logging + Performance Monitoring
- **배포 상태**: 프로덕션 운영 중 (16개 함수)

## 🎯 네이밍 컨벤션

프로젝트 전체 네이밍 컨벤션을 엄격히 준수합니다:

| 구분 | 컨벤션 | 예시 | 설명 |
|------|--------|------|------|
| **파일명** | camelCase.js | `onUserDeleted.js` | JavaScript 파일 |
| **디렉토리명** | 소문자 | `functions/`, `ai/` | 폴더명 |
| **함수명** | camelCase | `validateContent()` | 일반 함수 |
| **Cloud Functions** | camelCase | `onPostCreated` | Firebase 함수 |
| **변수명** | camelCase | `userId`, `postData` | 변수 |
| **상수** | UPPER_SNAKE_CASE | `MAX_RETRIES` | 상수 |
| **Firestore 필드** | camelCase | `createdAt`, `voteCount` | DB 필드 |
| **환경 변수** | UPPER_SNAKE_CASE | `GEMINI_API_KEY` | 환경 설정 |

참조: [NAMING_CONVENTION.md](../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
firebase/functions/
├── index.js                 # 메인 진입점 - 모든 함수 export (65줄)
├── package.json            # 의존성 관리 (Node.js 20)
├── .eslintrc.json         # 코드 스타일 규칙
│
├── 📁 ai/                 # AI 엔진 (⭐⭐⭐⭐⭐)
│   ├── config.js          # Genkit 설정 (118줄)
│   ├── contentModeration.js # 콘텐츠 검열 (506줄)
│   ├── userRecommendation.js # 사용자 추천 (375줄)
│   ├── cache.js           # AI 캐싱 (184줄)
│   └── monitoring.js      # 성능 모니터링 (292줄)
│
├── 📁 config/             # 핵심 설정 (⭐⭐⭐⭐⭐)
│   ├── firebase.js        # Firebase Admin SDK (23줄)
│   ├── apiClients.js      # 외부 API 클라이언트 (37줄)
│   └── logger.js          # 로깅 시스템 (205줄)
│
├── 📁 functions/          # Cloud Functions 구현 (⭐⭐⭐⭐⭐)
│   ├── auth/             # 인증 관련 함수
│   ├── firestore/        # Firestore 트리거 함수
│   ├── https/            # HTTP 엔드포인트
│   ├── scheduled/        # 스케줄 함수
│   └── storage/          # Storage 트리거 함수
│
├── 📁 services/          # 비즈니스 로직 서비스 (⭐⭐⭐⭐⭐)
│   ├── aiChatService.js        # AI 채팅 서비스 (721줄)
│   ├── notificationService.js  # 알림 처리 (248줄)
│   └── voteManagement.js       # 투표 관리 (319줄)
│
├── 📁 utils/             # 유틸리티 라이브러리 (⭐⭐⭐⭐)
│   ├── batch-processor.js      # 배치 처리 유틸 (229줄)
│   └── realtime-throttle.js    # 실시간 스로틀링 (264줄)
│
├── 📁 notifications/     # 알림 시스템 (⭐⭐⭐⭐⭐)
│   ├── targetAudience.js       # 타겟 사용자 선정 (412줄)
│   └── pushManager.js          # 푸시 알림 관리 (189줄)
│
├── 📁 scripts/           # 관리 스크립트 (⭐⭐⭐)
│   └── migrate-vote-data.js    # 데이터 마이그레이션 (285줄)
│
└── 📁 docs/              # 문서화 (⭐⭐⭐⭐)
    ├── ARCHITECTURE.md          # 시스템 아키텍처
    └── API_REFERENCE.md        # API 문서
```

## 🚀 배포된 Functions (16개)

### 🔐 Auth Functions
| 함수명 | 트리거 | 설명 | 상태 |
|--------|--------|------|------|
| `onUserDeleted` | Auth Delete | 사용자 삭제 시 관련 데이터 정리 | ✅ 운영중 |

### 🗄️ Firestore Functions
| 함수명 | 트리거 | 설명 | 상태 |
|--------|--------|------|------|
| `onPostCreatedSendNotifications` | posts/onCreate | 투표 생성 시 알림 발송 | ✅ 운영중 |
| `onPostVoteUpdate` | posts/onUpdate | 투표 완료 감지 및 처리 | ✅ 운영중 |
| `onMessageCreated` | messages/onCreate | 메시지 생성 시 처리 | ✅ 운영중 |

### 🌐 HTTPS Functions
| 함수명 | 엔드포인트 | 설명 | 상태 |
|--------|------------|------|------|
| `checkImageContent` | /checkImageContent | Vision API 이미지 검열 | ✅ 운영중 |
| `validatePostContentWithGemini` | /validatePostContentWithGemini | Gemini AI 콘텐츠 검증 | ✅ 운영중 |
| `testCreateAIChatMessage` | /testCreateAIChatMessage | AI 채팅 메시지 테스트 | 🧪 테스트 |
| `markMessagesAsSeen` | /markMessagesAsSeen | 메시지 읽음 처리 | ✅ 운영중 |
| `migrateAIChatRooms` | /migrateAIChatRooms | AI 채팅방 마이그레이션 | 🔧 관리용 |
| `migrateVoteData` | /migrateVoteData | 투표 데이터 마이그레이션 | 🔧 관리용 |
| `migrateSnakeToCamel` | /migrateSnakeToCamel | 네이밍 컨벤션 마이그레이션 | 🔧 관리용 |
| `debugMigration` | /debugMigration | 마이그레이션 디버깅 | 🔧 관리용 |
| `fullDatabaseScan` | /fullDatabaseScan | 전체 DB 스캔 | 🔧 관리용 |
| `migrateEntireDatabase` | /migrateEntireDatabase | 전체 DB 마이그레이션 | 🔧 관리용 |

### ⏰ Scheduled Functions
| 함수명 | 스케줄 | 설명 | 상태 |
|--------|--------|------|------|
| `flushThrottleQueue` | 매 1분 | 스로틀 큐 처리 | ✅ 운영중 |

### 📦 Storage Functions
| 함수명 | 트리거 | 설명 | 상태 |
|--------|--------|------|------|
| `moderateImage` | Storage Upload | 이미지 업로드 시 검열 | ✅ 운영중 |

## 💡 핵심 기능

### 🤖 AI 시스템 (Genkit Framework)

**통합 AI 엔진으로 다양한 기능 제공**:

```javascript
// 콘텐츠 검열
const result = await validateContentWithGenkit({
  questionTitle: "어느 것이 더 좋나요?",
  titleA: "옵션 A",
  titleB: "옵션 B",
  imageUrlA: "...",
  imageUrlB: "..."
});

// AI 추천
const users = await getAIRecommendedUsers(
  postData,
  candidateUsers,
  100 // 목표 사용자 수
);
```

**주요 특징**:
- Gemini 1.5 Pro/Flash 모델 활용
- 토큰 사용량 실시간 추적
- 3단계 검증 프로세스
- 예상 투표 비율 추론
- 스마트 캐싱 시스템

### 🔔 알림 시스템

**실시간 투표 요청 알림**:

```javascript
// 타겟 모드
- quick: AI가 최적 사용자 자동 선정
- public: 활성 사용자 랜덤 배포
- custom: 조건별 필터링
- test: 개발자 테스트 모드
```

**처리 플로우**:
1. 투표 생성 감지 (Firestore 트리거)
2. 타겟 사용자 선정 (AI 또는 조건 기반)
3. 알림 생성 및 발송
4. 실시간 동기화

### ⚡ 성능 최적화

**배치 처리 시스템**:
```javascript
// 대량 작업 효율적 처리
await processBatch(items, processor, 500);

// 병렬 처리
await processParallelBatch(items, processor, 10);

// 스로틀링
const throttle = new RealtimeThrottle({
  batchSize: 50,
  throttleMs: 500
});
```

**최적화 전략**:
- Firestore 배치 쓰기 (500개 제한)
- 병렬 처리 (동시 10개)
- 스로틀링 (0.5초 간격)
- 지수 백오프 재시도
- 메모리 기반 캐싱

### 📊 모니터링 시스템

**구조화된 로깅**:
```javascript
const logger = createLogger('MyFunction');

logger.info('작업 시작', { userId, taskId });
logger.error('오류 발생', error);
logger.debug('디버그 정보', { data });
```

**추적 메트릭**:
- 함수별 실행 시간
- AI 토큰 사용량
- 에러율 및 성공률
- 알림 발송 통계

## ⚙️ 환경 설정

### 필수 환경 변수

```bash
# Firebase Functions Config
firebase functions:config:set \
  google.genai_api_key="YOUR_GEMINI_KEY" \
  perspective.api_key="YOUR_PERSPECTIVE_KEY" \
  gemini.api_key="YOUR_GEMINI_KEY"

# 로컬 개발 (.env)
GOOGLE_GENAI_API_KEY=your_key_here
PERSPECTIVE_API_KEY=your_key_here
NODE_ENV=development
```

### 프로젝트 설정

```json
{
  "name": "cloud-functions",
  "engines": {
    "node": "20"
  },
  "dependencies": {
    "@genkit-ai/googleai": "^1.14.1",
    "@google-cloud/vision": "^5.3.0",
    "firebase-admin": "^11.11.0",
    "firebase-functions": "^4.4.1"
  }
}
```

## 🚀 개발 가이드

### 로컬 개발

```bash
# 의존성 설치
npm install

# 에뮬레이터 실행
npm run serve

# 함수 쉘 실행
npm run shell

# 로그 확인
npm run logs
```

### 코드 품질

```bash
# ESLint 검사
npm run lint

# 타입스크립트 컴파일 (검증용)
npm run compile
```

### 데이터 마이그레이션

```bash
# 드라이런 (변경 없이 확인)
npm run migrate:dry

# 테스트 (10개만)
npm run migrate:test

# 실제 실행
npm run migrate:run
```

## 📈 성능 지표

### 현재 운영 상태

| 메트릭 | 값 | 목표 |
|--------|-----|------|
| **평균 응답 시간** | 1.2초 | <2초 |
| **AI 처리 시간** | 2.5초 | <3초 |
| **알림 발송 성공률** | 98.5% | >95% |
| **일일 함수 호출** | ~50K | 100K |
| **일일 AI 토큰** | ~1M | <2M |
| **월간 비용** | ~$150 | <$200 |

### 최적화 성과

- **배치 처리**: 1000건 처리 시간 60초 → 15초 (75% ↓)
- **캐싱 적용**: AI 응답 시간 2.5초 → 0.5초 (80% ↓)
- **스로틀링**: 실시간 업데이트 부하 90% 감소
- **병렬 처리**: 알림 발송 시간 50% 단축

## 🔍 문제 해결

### 일반적인 문제

#### 1. API 키 오류
```
Error: API key not valid
```
**해결**:
- Firebase config 확인: `firebase functions:config:get`
- 환경 변수 확인: `.env` 파일
- API 콘솔에서 키 권한 확인

#### 2. Firestore 인덱스 오류
```
Error: The query requires an index
```
**해결**:
- 에러 메시지의 링크 클릭
- Firebase Console에서 인덱스 생성
- 5-10분 대기

#### 3. 메모리 부족
```
Error: Function ran out of memory
```
**해결**:
- Firebase Console에서 메모리 증가 (512MB → 1GB)
- 배치 크기 감소
- 스트리밍 처리 적용

#### 4. 타임아웃
```
Error: Function execution took 60001 ms
```
**해결**:
- 타임아웃 시간 증가 (최대 540초)
- 비동기 처리 최적화
- 불필요한 await 제거

## 🛠️ 모범 사례

### 1. 함수 구조화
```javascript
// ✅ 좋은 예: 명확한 디렉토리 구조
functions/
  auth/onUserDeleted.js
  firestore/onPostCreated.js
  https/validateContent.js

// ❌ 나쁜 예: 평면 구조
functions/
  function1.js
  function2.js
  function3.js
```

### 2. 에러 처리
```javascript
// ✅ 좋은 예: 구조화된 에러 처리
try {
  const result = await processData();
  logger.info('성공', { result });
  return { success: true, data: result };
} catch (error) {
  logger.error('실패', error);
  return { success: false, error: error.message };
}

// ❌ 나쁜 예: 에러 무시
try {
  return await processData();
} catch (e) {
  console.log(e);
}
```

### 3. 성능 최적화
```javascript
// ✅ 좋은 예: 병렬 처리
const [users, posts, notifications] = await Promise.all([
  getUsers(),
  getPosts(),
  getNotifications()
]);

// ❌ 나쁜 예: 순차 처리
const users = await getUsers();
const posts = await getPosts();
const notifications = await getNotifications();
```

### 4. 보안 처리
```javascript
// ✅ 좋은 예: 민감한 데이터 마스킹
logger.info('사용자 생성', { 
  userId: maskSensitive(uid, 4) 
});

// ❌ 나쁜 예: 민감한 데이터 노출
logger.info('사용자 생성', { 
  uid, email, phone 
});
```

## 📚 관련 문서

### 내부 문서
- [AI 시스템 상세](./ai/README.md)
- [설정 관리](./config/README.md)
- [알림 시스템](./notifications/README.md)
- [서비스 레이어](./services/README.md)
- [유틸리티](./utils/README.md)
- [아키텍처 가이드](./docs/ARCHITECTURE.md)

### 외부 참조
- [Firebase Functions 문서](https://firebase.google.com/docs/functions)
- [Google Genkit](https://firebase.google.com/docs/genkit)
- [Gemini AI API](https://ai.google.dev/tutorials/rest_quickstart)
- [Cloud Vision API](https://cloud.google.com/vision/docs)

## 📝 변경 이력

### 2025-08-21: 네이밍 컨벤션 통일
- snake_case → camelCase 완전 마이그레이션
- 768개 필드 변환 완료
- 12개 함수 업데이트

### 2025-08-20: Genkit 프레임워크 도입
- Google Genkit 통합
- AI 시스템 고도화
- 토큰 추적 구현

### 2025-08-19: 알림 시스템 구현
- 실시간 투표 알림
- AI 기반 사용자 매칭
- 4가지 타겟 모드

### 2025-08-18: 초기 구조 확립
- Firebase Functions v2 마이그레이션
- 디렉토리 구조 정립
- 기본 함수 구현

### 2025-08-10: 채팅 메시지 상태 관리
- markMessagesAsSeen 함수 추가
- onMessageCreated 트리거 구현
- 메시지 라이프사이클 관리

### 2025-08-06: 로깅 시스템 최적화
- 구조화된 로깅 도입
- 90% 로그 감소
- targetMatcher 버그 수정

### 2025-08-04: 투표 타이머 시스템
- 10분 자동 완료 구현
- Security Rules 업데이트
- 중복 투표 방지 강화

### 2025-08-03: AI 채팅 시스템 수정
- 채팅방 ID 생성 로직 수정
- 마이그레이션 함수 추가
- 대소문자 정렬 문제 해결

### 2025-07-31: 컬렉션 이름 정규화
- _record 접미사 제거
- Flutter 앱과 통일
- 데이터베이스 일관성 확보

## 🎯 향후 계획

### 단기 (1-2개월)
1. **Redis 캐싱 도입** - 응답 시간 50% 단축
2. **WebSocket 통합** - 실시간 업데이트
3. **A/B 테스트 프레임워크** - 기능 실험

### 중기 (3-4개월)
1. **멀티 리전 배포** - 글로벌 확장
2. **커스텀 AI 모델** - 도메인 특화
3. **엣지 컴퓨팅** - CDN 통합

### 장기 (6개월+)
1. **마이크로서비스 전환** - 독립 배포
2. **Kubernetes 마이그레이션** - 확장성
3. **GraphQL API** - 효율적 데이터 페칭

## 🤝 기여 가이드

### 브랜치 전략
- `main`: 프로덕션 배포
- `develop`: 개발 통합
- `feature/*`: 기능 개발
- `hotfix/*`: 긴급 수정

### 코드 리뷰 체크리스트
- [ ] ESLint 통과
- [ ] 유닛 테스트 작성
- [ ] 문서 업데이트
- [ ] 성능 영향 검토
- [ ] 보안 취약점 검사

### 커밋 메시지 규칙
```
feat: 새로운 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷팅
refactor: 코드 리팩토링
test: 테스트 추가
chore: 빌드 업무 수정
```

---

*이 프로젝트는 Versus Space의 핵심 백엔드 시스템으로, 지속적인 모니터링과 최적화가 필요합니다.*

**마지막 업데이트**: 2025-08-21
**문서 버전**: 2.0.0
**작성자**: Versus Space Backend Team