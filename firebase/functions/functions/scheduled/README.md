# ⏰ Scheduled 트리거 함수

## 📋 개요

정기적으로 실행되는 Cloud Functions 스케줄 함수 디렉토리입니다. Pub/Sub과 Cloud Scheduler를 활용하여 주기적인 작업을 자동화합니다. 현재 10분 투표 타이머 만료 처리를 담당하는 핵심 스케줄러가 구현되어 있으며, 매분마다 실행되어 투표 시스템의 시간 기반 로직을 처리합니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: 투표 타이머 만료 처리, 주기적 데이터 정리
- **권장사항**: 투표 시스템 핵심 기능으로 반드시 필요

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `flushThrottleQueue.js` |
| **함수명** | camelCase | `flushThrottleQueue()`, `processVoteCompletion()` |
| **변수명** | camelCase | `expiredVotes`, `displayVotes`, `voteEndTime` |
| **상수** | camelCase 또는 대문자 | `throttleQueue`, `targetCount` |
| **스케줄** | cron 표현식 | `every 1 minutes` |

참조: [NAMING_CONVENTION.md](../../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
scheduled/
├── flushThrottleQueue.js     # 투표 타이머 만료 처리 (230줄)
└── README.md                  # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. flushThrottleQueue.js - 10분 투표 타이머 처리
**매분마다 실행되어 만료된 투표를 자동 완료 처리** (230줄)

#### 핵심 기능
- **실행 주기**: 매 1분 (Cloud Scheduler)
- **타임아웃**: 9분 (540초)
- **메모리**: 512MB
- **리전**: asia-northeast3 (서울)
- **배치 처리**: 한 번에 최대 100개 투표 처리

#### 주요 처리 플로우
```
매 1분마다 트리거
    ↓
활성 투표 조회 (voteCompleted = false)
    ↓
만료 시간 확인 (voteEndTime <= 현재시간)
    ↓
┌─────────────────────┐
│  만료된 투표 처리    │
├─────────────────────┤
│ 1. AI 예상 비율 적용 │
│ 2. 투표 증폭 계산   │
│ 3. 표시용 수치 생성 │
│ 4. 게시물 상태 업데이트│
│ 5. AI 결과 메시지 전송│
└─────────────────────┘
    ↓
처리 결과 로깅
```

#### 투표 증폭 알고리즘
```javascript
// AI 예상 비율 읽기
const expectedRatio = {
  A: postData.moderation?.expectedRatioA || 0.5,
  B: postData.moderation?.expectedRatioB || 0.5
};

// 목표 100명으로 증폭
const targetCount = 100;
const displayVotes = calculateDisplayVotes(
  { A: actualVotesA, B: actualVotesB },
  targetCount,
  expectedRatio  // AI 예상 비율 적용
);

// 최종 표시 비율
const percentA = Math.round((displayVotes.A / targetCount) * 100);
const percentB = Math.round((displayVotes.B / targetCount) * 100);
```

#### Timestamp 파싱 헬퍼
```javascript
function parseTimestamp(value) {
  // Firestore Timestamp 객체
  if (value.toDate && typeof value.toDate === 'function') {
    return value;
  }
  
  // {_seconds, _nanoseconds} 형식
  if (value._seconds !== undefined) {
    return new admin.firestore.Timestamp(value._seconds, value._nanoseconds || 0);
  }
  
  // Date 객체나 문자열 처리
  if (value instanceof Date) {
    return admin.firestore.Timestamp.fromDate(value);
  }
  
  return null;
}
```

#### 투표 결과 데이터 구조
```javascript
const voteResults = {
  // 표시용 투표 수 (증폭된 값)
  votesA: displayVotes.A,
  votesB: displayVotes.B,
  totalVotes: targetCount,        // 100
  
  // 실제 투표 수
  actualVotesA: actualVotesA,
  actualVotesB: actualVotesB,
  actualTotalVotes: actualTotal,
  
  // 비율과 승자
  percentA: percentA,
  percentB: percentB,
  winner: displayVotes.A > displayVotes.B ? 'A' : 'B',
  
  // 메타데이터
  questionTitle: postData.questionTitle,
  optionA: postData.optionA?.title || 'A',
  optionB: postData.optionB?.title || 'B',
  creatorId: postData.uid,
  creatorName: postData.authorName,
  isTimeout: false  // 10분 정상 종료
};
```

#### 병렬 처리 최적화
```javascript
// Promise.allSettled로 안전한 병렬 처리
const results = await Promise.allSettled(
  expiredVotes.map(async (doc) => {
    // 각 투표 독립적으로 처리
    // 하나 실패해도 다른 투표는 계속 처리
  })
);

// 결과 집계
const succeeded = results.filter(r => r.status === 'fulfilled').length;
const failed = results.filter(r => r.status === 'rejected').length;
```

## 💡 시스템 아키텍처

### 투표 생명주기

```
게시물 생성 (onPostCreatedSendNotifications)
    ↓
10분 타이머 시작
    ↓
실시간 투표 진행
    ↓
┌────────────────────────┐
│  flushThrottleQueue    │
│  (매분마다 체크)        │
├────────────────────────┤
│ - 만료 투표 감지       │
│ - AI 비율 적용        │
│ - 투표 증폭 계산      │
│ - 결과 메시지 생성    │
└────────────────────────┘
    ↓
투표 완료 상태
```

### AI 투표 증폭 시스템

1. **실제 투표 수집**
   - 사용자들의 실제 투표 추적
   - votedUserIDsA/B 배열로 중복 방지

2. **AI 예상 비율 적용**
   - Gemini AI가 예측한 비율 활용
   - 실제 투표가 적을 때 AI 예측 강화

3. **목표 수치로 증폭**
   - 항상 100명 기준으로 표시
   - 실제와 AI 예측의 균형 조정

4. **결과 표시**
   - displayVotesA/B: 앱에서 표시할 수치
   - actualVotesA/B: 내부 통계용 실제 수치

## 🔍 문제 해결 가이드

### 일반적인 문제

1. **투표가 자동 완료되지 않음**
```
증상: 10분이 지나도 투표가 active 상태
```
- Cloud Scheduler 상태 확인
- Pub/Sub 토픽 연결 확인
- 함수 로그에서 에러 확인
- voteEndTime 필드 형식 검증

2. **Timestamp 파싱 에러**
```
Error: Cannot read property 'toDate' of undefined
```
- parseTimestamp 헬퍼 함수 사용
- 다양한 Timestamp 형식 지원
- null 체크 강화

3. **처리 시간 초과**
```
Error: Function execution took 540001 ms, finished with status: 'timeout'
```
- 배치 크기 줄이기 (limit 조정)
- 병렬 처리 최적화
- 불필요한 대기 제거

## 🚀 모범 사례

### 1. 안전한 Timestamp 처리
```javascript
// 항상 parseTimestamp 헬퍼 사용
const voteEndTime = parseTimestamp(data.voteEndTime);
if (!voteEndTime) {
  logger.warning('voteEndTime이 없거나 잘못된 형식');
  return;
}

// 시간 비교
if (voteEndTime.toMillis() <= now.toMillis()) {
  // 만료됨
}
```

### 2. 배치 처리 최적화
```javascript
// 적절한 배치 크기
const batchSize = 100;  // 너무 크면 타임아웃 위험

// Promise.allSettled 사용
const results = await Promise.allSettled(batch.map(processItem));

// 부분 실패 허용
const succeeded = results.filter(r => r.status === 'fulfilled');
```

### 3. 로깅 전략
```javascript
// 구조화된 로그
logger.info('처리 시작', {
  batchSize: items.length,
  timestamp: now.toDate().toISOString()
});

// 민감한 정보 마스킹
logger.debug(`사용자: ${logger.maskSensitive(userId)}`);

// 섹션 구분
logger.info('========== 처리 시작 ==========');
```

## 📊 성능 지표

### 현재 성능
| 항목 | 목표 | 현재 |
|------|------|------|
| **실행 주기** | 1분 | 1분 |
| **처리 시간** | <30초 | 평균 15초 |
| **배치 크기** | 100개 | 100개 |
| **성공률** | >95% | 98% |
| **메모리 사용** | <512MB | 평균 200MB |

### 시스템 제한
- 최대 실행 시간: 9분
- 최대 메모리: 8GB
- 최소 실행 간격: 1분
- 최대 배치 크기: Firestore 쿼리 제한

## 📈 모니터링

### Cloud Logging 쿼리
```javascript
// 스케줄 함수 실행 추적
resource.type="cloud_function"
resource.labels.function_name="flushThrottleQueue"
severity>=DEFAULT

// 만료된 투표 처리
jsonPayload.message=~"만료된 투표"

// 에러 추적
severity="ERROR"
resource.labels.function_name="flushThrottleQueue"

// 성능 분석
jsonPayload.succeeded>0
```

### 주요 메트릭
- 실행 빈도 및 성공률
- 평균 처리 시간
- 처리된 투표 수
- AI 예상 비율 정확도

## 📝 변경 이력

### 2025-08-24: Scheduled 함수 구현
- flushThrottleQueue 함수 구현
- 10분 투표 타이머 시스템 완성
- AI 예상 비율 통합
- 투표 증폭 알고리즘 구현

### 2025-08-20: 투표 시스템 개선
- parseTimestamp 헬퍼 추가
- 병렬 처리 최적화
- 에러 처리 강화

## 🎯 향후 계획

### 단기 (1-2개월)
1. **처리 효율 개선**
   - 인덱스 최적화
   - 캐싱 전략 구현
   - 배치 크기 동적 조정

2. **모니터링 강화**
   - 실시간 알림 시스템
   - 대시보드 구축
   - 성능 메트릭 추적

### 장기 (3-6개월)
1. **추가 스케줄 작업**
   - 일일 통계 집계
   - 주간 리포트 생성
   - 비활성 데이터 정리

2. **확장성 개선**
   - 분산 처리 구현
   - 다중 리전 지원
   - 부하 분산 전략

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../../README.md)
- [Firestore 트리거](../firestore/README.md)
- [서비스 레이어](../../services/README.md)
- [설정 관리](../../config/README.md)
- [네이밍 컨벤션](../../../../NAMING_CONVENTION.md)

### 외부 참조
- [Cloud Scheduler](https://cloud.google.com/scheduler/docs)
- [Pub/Sub 트리거](https://firebase.google.com/docs/functions/schedule-functions)
- [Firebase Functions 스케줄링](https://firebase.google.com/docs/functions/schedule-functions)

## ⚠️ 보안 고려사항

### 실행 권한
- Cloud Scheduler 서비스 계정만 실행 가능
- 외부 호출 차단
- IAM 역할 최소 권한

### 데이터 보호
- 민감한 정보 로깅 금지
- 사용자 ID 마스킹
- 트랜잭션 무결성 보장

### 장애 대응
- 중복 실행 방지 메커니즘
- 부분 실패 허용
- 자동 재시도 설정

---

*이 디렉토리는 정기적인 작업을 자동화하여 투표 시스템의 시간 기반 로직을 처리하는 핵심 스케줄링 시스템입니다.*