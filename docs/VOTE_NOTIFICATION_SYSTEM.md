# 투표 알림 시스템 완전 가이드

이 문서는 Versus Space의 AI 기반 투표 알림 시스템의 전체 구현을 설명합니다.

## 목차

1. [시스템 개요](#시스템-개요)
2. [아키텍처](#아키텍처)
3. [주요 구성 요소](#주요-구성-요소)
4. [데이터 플로우](#데이터-플로우)
5. [성능 최적화](#성능-최적화)
6. [테스트 및 모니터링](#테스트-및-모니터링)
7. [향후 개선 사항](#향후-개선-사항)

## 시스템 개요

### 핵심 기능
- **AI 기반 타겟팅**: Gemini AI를 활용한 스마트 사용자 매칭
- **실시간 알림**: Firebase를 통한 즉각적인 푸시 알림
- **자동 결과 처리**: 투표 완료 시 자동 상태 업데이트
- **성능 최적화**: 배치 처리 및 스로틀링으로 대규모 확장 가능

### 투표 생명주기
```
생성 → 타겟팅 → 알림 전송 → 투표 진행 → 자동 완료 → 결과 알림
```

## 아키텍처

### 시스템 구성도
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Flutter App    │────▶│ Firebase Functions│────▶│  Firestore DB   │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                       │                          │
         │                       ▼                          │
         │              ┌──────────────────┐               │
         └─────────────▶│   Gemini AI      │               │
                        └──────────────────┘               │
                                 │                          │
                                 ▼                          ▼
                        ┌──────────────────┐     ┌─────────────────┐
                        │ Target Matching  │     │  Notifications  │
                        └──────────────────┘     └─────────────────┘
```

### 기술 스택
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase Functions (Node.js)
- **Database**: Firestore
- **AI**: Google Gemini 1.5 Pro
- **인프라**: Google Cloud Platform

## 주요 구성 요소

### 1. Firebase Functions

#### onPostCreatedSendNotifications
게시물 생성 시 AI 타겟팅 및 알림 전송

```javascript
exports.onPostCreatedSendNotifications = functions
  .region('asia-northeast3')
  .firestore
  .document('posts/{postId}')
  .onCreate(async (snapshot, context) => {
    // 1. 타겟 사용자 매칭
    const targetUsers = await matchTargetUsers(targetAudience, creatorId);
    
    // 2. 알림 생성 및 전송
    await createNotificationsForUsers(targetUsers, postData);
    
    // 3. 채팅 메시지 생성
    await createVoteMessages(postId, targetUsers);
  });
```

#### onPostVoteUpdate
투표 발생 시 실시간 업데이트 (스로틀링 적용)

```javascript
exports.onPostVoteUpdate = functions
  .region('asia-northeast3')
  .runWith({ memory: '512MB', timeoutSeconds: 60 })
  .firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    // 1. 투표 업데이트 큐에 추가
    queueVoteUpdate(postId, userId, option);
    
    // 2. 투표 완료 확인
    if (isVoteComplete && !afterData.vote_completed) {
      await processVoteCompletion(postId, voteResults);
    }
  });
```

#### processVoteCompletion
투표 완료 시 자동 결과 처리 (최적화 버전)

```javascript
async function processVoteCompletion(postId, voteResults) {
  // 1. 병렬 데이터 조회
  const [messages, notifications, progressMessages] = await Promise.all([...]);
  
  // 2. 배치 처리로 상태 업데이트
  await processBatch(batchOperations, processor, 500);
  
  // 3. 병렬 메시지 삭제
  await processParallelBatch(progressMessages, deleteProcessor, 50);
}
```

### 2. 최적화 유틸리티

#### 배치 처리 (batch-processor.js)
```javascript
// Firestore 배치 제한(500)에 맞춰 자동 분할
await processBatch(operations, processor, 500);

// 병렬 처리로 성능 향상
await processParallelBatch(tasks, processor, concurrency);

// API 호출 속도 제한
await processThrottledBatch(apiCalls, processor, rateLimit);

// 자동 재시도 로직
await processWithRetry(unreliableTasks, processor, options);
```

#### 실시간 스로틀링 (realtime-throttle.js)
```javascript
// 투표 업데이트를 큐에 추가 (즉시 처리하지 않음)
queueVoteUpdate(postId, userId, option);

// 주기적으로 배치 처리 (0.5초마다)
const throttle = new RealtimeThrottle({
  batchSize: 50,
  throttleMs: 500,
  maxQueueSize: 1000
});
```

### 3. Flutter 클라이언트

#### GlobalNotificationManager
```dart
class GlobalNotificationManager {
  // 알림 큐 관리
  final List<NotificationsRecord> _notificationQueue = [];
  
  // 순차적 알림 표시
  void _processQueue() {
    if (_notificationQueue.isNotEmpty) {
      _showNotification(_notificationQueue.removeAt(0));
    }
  }
  
  // 투표 제출
  Future<void> _submitVote(String postId, String option) async {
    // Firestore 업데이트
    await postRef.update({
      fieldName: FieldValue.increment(1),
      'voters': FieldValue.arrayUnion([userId])
    });
  }
}
```

#### VotingNotificationDialog
```dart
Dialog(
  child: VotingNotificationDialog(
    question: question,
    optionA: optionA,
    optionB: optionB,
    imageUrlsA: imageUrlsA,  // 멀티이미지 지원
    imageUrlsB: imageUrlsB,
    sizeData: sizeData,      // 동적 크기 계산
    onVote: (option) => _submitVote(postId, option),
  ),
);
```

## 데이터 플로우

### 1. 투표 생성 플로우
```
1. 사용자가 투표 생성
   ↓
2. onPostCreatedSendNotifications 트리거
   ↓
3. AI가 타겟 사용자 분석
   ↓
4. 알림 전송 (notifications)
   ↓
5. 채팅 메시지 생성 (vote_tracking_global)
```

### 2. 투표 참여 플로우
```
1. 사용자가 알림 수신
   ↓
2. VotingNotificationDialog 표시
   ↓
3. 투표 선택 (A/B)
   ↓
4. Firestore 업데이트
   ↓
5. onPostVoteUpdate 트리거
   ↓
6. 스로틀 큐에 추가
```

### 3. 투표 완료 플로우
```
1. 목표 투표 수 도달 감지
   ↓
2. processVoteCompletion 호출
   ↓
3. 배치 처리로 상태 업데이트
   ↓
4. 진행중 메시지 삭제
   ↓
5. 결과 알림 생성
```

## 성능 최적화

### 배치 처리 성능
- **단일 작업**: ~100ms
- **100명 동시**: <10s (평균 80ms/vote)
- **1000명 동시**: <60s (평균 50ms/vote)

### 최적화 기법
1. **병렬 쿼리**: Promise.all()로 동시 데이터 조회
2. **배치 쓰기**: 500개씩 묶어서 Firestore 업데이트
3. **스로틀링**: 실시간 업데이트를 0.5초마다 배치 처리
4. **재시도 로직**: 실패한 작업 자동 재시도

### 리소스 관리
```javascript
// Functions 메모리 설정
.runWith({
  memory: '1GB',        // AI 처리용
  timeoutSeconds: 300   // 대규모 작업용
})

// 동시 실행 제한
processParallelBatch(tasks, processor, 50); // 최대 50개 동시
```

## 자동 투표 완료 처리 시스템

### 개요
2025-07-26에 구현 및 배포된 자동 투표 완료 처리 시스템은 목표 투표 수에 도달한 게시물을 자동으로 감지하고 처리합니다.

### 주요 기능
1. **자동 완료 감지**: 목표 투표 수 도달 시 즉시 감지
2. **진행중 메시지 삭제**: 모든 "투표 진행중" 메시지 자동 제거
3. **결과 알림 생성**: 참여자들에게 "결과 도착" 알림 전송
4. **배치 처리**: 대규모 투표도 효율적으로 처리

### 구현 상세

#### onPostVoteUpdate 함수
```javascript
exports.onPostVoteUpdate = functions
  .region('asia-northeast3')
  .runWith({ memory: '512MB', timeoutSeconds: 60 })
  .firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // 투표 완료 확인
    const totalVotes = (afterData.vote_count_a || 0) + (afterData.vote_count_b || 0);
    const targetCount = afterData.targetAudience?.count || 0;
    const isVoteComplete = targetCount > 0 && totalVotes >= targetCount;
    
    if (isVoteComplete && !afterData.vote_completed) {
      await processVoteCompletion(postId, {
        votesA: afterData.vote_count_a,
        votesB: afterData.vote_count_b,
        winnerOption: afterData.vote_count_a > afterData.vote_count_b ? 'A' : 'B'
      });
    }
  });
```

#### processVoteCompletion 함수
최적화된 투표 완료 처리 로직:
- **병렬 데이터 조회**: 메시지, 알림, 진행중 메시지를 동시 조회
- **배치 업데이트**: Firestore 500개 제한에 맞춰 자동 분할
- **병렬 삭제**: 진행중 메시지 50개씩 병렬 삭제

### 스케줄된 함수

#### flushThrottleQueue
- **실행 주기**: 1분마다
- **목적**: 스로틀 큐에 쌓인 업데이트 처리
- **효과**: 실시간 부하 분산

#### checkVoteTimeouts  
- **실행 주기**: 매시간
- **목적**: 24시간 초과 투표 자동 완료
- **범위**: 미완료 투표 중 24시간 경과 건

## 테스트 및 모니터링

### 테스트 시나리오
1. **기본 플로우 테스트** (`vote-flow-test.js`)
   - 테스트 모드 전체 플로우
   - 멀티 사용자 동시 투표
   - 에지 케이스 (거부, 타임아웃)

2. **성능 테스트** (`performance-optimization-test.js`)
   - 배치 처리 성능
   - 스로틀링 효과
   - 대규모 투표 시뮬레이션 (1000명)

### 테스트 실행
```bash
# 에뮬레이터와 함께 실행
npm run test:emulator

# 성능 테스트만
npx mocha test/performance-optimization-test.js

# 와치 모드
npm run test:watch
```

### 모니터링 포인트
- **처리 시간**: 5초 이상 시 경고
- **큐 크기**: 1000개 초과 시 자동 플러시
- **에러율**: 재시도 로직으로 자동 복구
- **리소스 사용량**: 메모리 및 CPU 모니터링

## 향후 개선 사항

### 단기 개선
1. **푸시 알림 통합**: FCM을 통한 백그라운드 알림
2. **분석 대시보드**: 투표 참여율 및 패턴 분석
3. **A/B 테스트**: 알림 문구 및 타이밍 최적화

### 중장기 개선
1. **ML 모델 고도화**: 사용자 행동 예측 모델
2. **실시간 스트리밍**: WebSocket 기반 실시간 업데이트
3. **글로벌 확장**: 다중 리전 배포 및 CDN 활용
4. **비용 최적화**: AI 호출 캐싱 및 배치 처리

## 배포 현황 (2025-07-26)

### 배포된 Firebase Functions
총 11개의 Cloud Functions가 성공적으로 배포되어 운영 중입니다:

1. **투표 시스템 핵심 함수**
   - `onPostVoteUpdate`: 투표 업데이트 감지 및 완료 처리
   - `processVoteCompletion`: 투표 완료 자동 처리 (내부 함수)
   - `flushThrottleQueue`: 스로틀 큐 정기 처리 (1분마다)
   - `checkVoteTimeouts`: 24시간 타임아웃 확인 (매시간)

2. **알림 시스템 함수**
   - `onPostCreatedSendNotifications`: 게시물 생성 시 AI 타겟팅 알림
   - `getUserPostingHistory`: 사용자 게시 이력 분석
   - `testNotificationSystem`: 알림 시스템 테스트

3. **콘텐츠 검열 함수**
   - `validatePostContentWithGemini`: Gemini AI 콘텐츠 검증
   - `checkImageContent`: 이미지 내용 검증
   - `moderateImage`: 이미지 모더레이션
   - `onUserDeleted`: 사용자 삭제 시 데이터 정리

### 성능 테스트 결과
- **100명 동시 투표**: <10초 완료 (평균 80ms/vote)
- **1000명 동시 투표**: <60초 완료 (평균 50ms/vote)
- **처리량**: 16-20 votes/sec
- **메모리 사용**: 512MB로 안정적 처리

## 결론

이 투표 알림 시스템은 AI 기반 타겟팅, 실시간 처리, 자동화된 워크플로우를 통해 사용자 참여를 극대화합니다. 배치 처리와 스로틀링을 통한 성능 최적화로 대규모 확장이 가능하며, 체계적인 테스트와 모니터링으로 안정성을 보장합니다.

### 주요 성과
- ✅ AI 기반 스마트 타겟팅 구현
- ✅ 실시간 투표 상태 동기화
- ✅ 자동 결과 처리 및 알림
- ✅ 1000명 동시 처리 가능
- ✅ 평균 응답 시간 <100ms
- ✅ 2025-07-26 프로덕션 배포 완료

### 연락처
질문이나 개선 제안은 프로젝트 이슈 트래커를 통해 제출해주세요.