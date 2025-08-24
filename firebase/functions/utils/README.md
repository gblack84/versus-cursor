# 📦 Firebase Functions 유틸리티 라이브러리

> Firebase Functions에서 사용되는 핵심 유틸리티 모듈 - 배치 처리, 스로틀링, 성능 최적화를 위한 도구 모음

## 📋 개요

Firebase Functions utils 디렉토리는 Cloud Functions의 성능과 안정성을 극대화하기 위한 유틸리티 모듈들을 제공합니다. 대규모 데이터 처리, 실시간 업데이트 관리, 에러 처리 등 프로덕션 환경에서 필수적인 기능들을 포함합니다.

### 주요 특징
- **배치 처리 최적화**: Firestore 배치 제한(500개)을 자동 관리
- **실시간 스로틀링**: 대량 업데이트를 효율적으로 그룹화
- **병렬 처리**: 동시성 제어로 처리 속도 극대화
- **재시도 로직**: 지수 백오프를 통한 안정적인 처리
- **메모리 관리**: 대규모 데이터셋의 효율적 처리

## 🏗️ 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────┐
│                   Firebase Functions                     │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │                 Utils Layer                       │  │
│  │                                                   │  │
│  │  ┌────────────────┐  ┌────────────────────┐     │  │
│  │  │ Batch Processor│  │ Realtime Throttle │     │  │
│  │  └────────────────┘  └────────────────────┘     │  │
│  │         ▲                      ▲                 │  │
│  │         │                      │                 │  │
│  │  ┌──────┴──────────────────────┴──────┐        │  │
│  │  │        Service Functions            │        │  │
│  │  │  (vote, notification, moderation)   │        │  │
│  │  └─────────────────────────────────────┘        │  │
│  └──────────────────────────────────────────────────┘  │
│                           │                             │
│                           ▼                             │
│                    ┌──────────┐                        │
│                    │ Firestore │                        │
│                    └──────────┘                        │
└─────────────────────────────────────────────────────────┘
```

## 📚 네이밍 컨벤션

| 구분 | 규칙 | 예시 |
|------|------|------|
| **파일명** | kebab-case | `batch-processor.js`, `realtime-throttle.js` |
| **클래스명** | PascalCase | `RealtimeThrottle`, `BatchProcessor` |
| **함수명** | camelCase | `processBatch()`, `queueUpdate()` |
| **상수** | UPPER_SNAKE_CASE | `MAX_BATCH_SIZE`, `DEFAULT_TIMEOUT` |
| **변수명** | camelCase | `updateQueue`, `throttleMs` |

> 📖 상세 규칙: [프로젝트 네이밍 컨벤션](../../../NAMING_CONVENTION.md)

## 🔧 주요 구성요소

### 1. batch-processor.js - 배치 처리 유틸리티

대규모 데이터를 효율적으로 처리하기 위한 배치 프로세서입니다.

#### 핵심 함수

##### processBatch()
Firestore 배치 쓰기를 안전하게 처리합니다.

```javascript
const { processBatch } = require('./utils/batch-processor');

// 1000개의 문서를 500개씩 나누어 처리
const results = await processBatch(
  documents,
  async (batch, doc) => {
    const ref = db.collection('posts').doc(doc.id);
    batch.set(ref, doc.data);
  },
  500 // 배치 크기
);

// 결과 확인
results.forEach(result => {
  if (result.success) {
    console.log(`처리 완료: ${result.processed}개`);
  } else {
    console.error(`처리 실패: ${result.error}`);
  }
});
```

##### processParallelBatch()
여러 작업을 병렬로 처리합니다.

```javascript
const { processParallelBatch } = require('./utils/batch-processor');

// 100개의 이미지를 10개씩 병렬 처리
const results = await processParallelBatch(
  imageUrls,
  async (url) => {
    return await processImage(url);
  },
  10 // 동시 실행 수
);

// 성공/실패 분리
const successful = results.filter(r => r.status === 'fulfilled');
const failed = results.filter(r => r.status === 'rejected');
```

##### processThrottledBatch()
API 호출 제한을 준수하며 처리합니다.

```javascript
const { processThrottledBatch } = require('./utils/batch-processor');

// 초당 100개 제한으로 외부 API 호출
const results = await processThrottledBatch(
  apiRequests,
  async (request) => {
    return await callExternalAPI(request);
  },
  100, // 초당 처리 수
  10   // 배치 크기
);
```

##### processWithRetry()
실패한 항목을 자동으로 재시도합니다.

```javascript
const { processWithRetry } = require('./utils/batch-processor');

// 재시도 로직이 포함된 처리
const result = await processWithRetry(
  items,
  async (item) => {
    // 불안정한 작업
    return await unreliableOperation(item);
  },
  {
    maxRetries: 3,
    retryDelay: 1000,
    exponentialBackoff: true,
    batchSize: 50
  }
);

console.log(`성공: ${result.successful}, 실패: ${result.failed}`);
```

#### 성능 최적화 팁

1. **배치 크기 조정**
```javascript
// CPU 집약적 작업: 작은 배치
const cpuIntensive = await processBatch(items, processor, 50);

// I/O 작업: 큰 배치
const ioOperation = await processBatch(items, processor, 500);
```

2. **병렬 처리 최적화**
```javascript
// 네트워크 작업: 높은 동시성
const networkOps = await processParallelBatch(urls, fetcher, 50);

// 데이터베이스 작업: 제한된 동시성
const dbOps = await processParallelBatch(queries, executor, 10);
```

### 2. realtime-throttle.js - 실시간 스로틀링

실시간 업데이트를 효율적으로 관리하는 스로틀링 시스템입니다.

#### RealtimeThrottle 클래스

```javascript
const { RealtimeThrottle } = require('./utils/realtime-throttle');

// 스로틀 인스턴스 생성
const throttle = new RealtimeThrottle({
  batchSize: 50,        // 배치 크기
  throttleMs: 500,      // 스로틀 시간 (ms)
  maxQueueSize: 1000    // 최대 큐 크기
});

// 업데이트 큐에 추가
throttle.queueUpdate('post123', {
  type: 'vote',
  userId: 'user456',
  option: 'A',
  timestamp: Date.now()
});

// 즉시 처리 강제
await throttle.flushUpdates('post123');

// 모든 큐 처리
await throttle.flushAll();

// 정리
throttle.cleanup();
```

#### 헬퍼 함수

##### queueVoteUpdate()
투표 업데이트를 스로틀링합니다.

```javascript
const { queueVoteUpdate } = require('./utils/realtime-throttle');

// Firebase 트리거에서 사용
exports.onVoteCreated = functions.firestore
  .document('votes/{voteId}')
  .onCreate(async (snap, context) => {
    const vote = snap.data();
    
    // 스로틀링된 업데이트
    queueVoteUpdate(vote.postId, vote.userId, vote.option);
  });
```

##### queueMessageStatusUpdate()
메시지 상태 변경을 배치 처리합니다.

```javascript
const { queueMessageStatusUpdate } = require('./utils/realtime-throttle');

// 메시지 상태 업데이트
queueMessageStatusUpdate(
  postId,
  messageId,
  userId,
  'inProgress',
  'A'
);
```

#### 스로틀링 전략

1. **시간 기반 스로틀링**
```javascript
// 0.5초마다 배치 처리
const timeThrottle = new RealtimeThrottle({
  throttleMs: 500
});
```

2. **크기 기반 스로틀링**
```javascript
// 100개 모이면 즉시 처리
const sizeThrottle = new RealtimeThrottle({
  batchSize: 100,
  throttleMs: 5000 // 최대 5초 대기
});
```

3. **하이브리드 스로틀링**
```javascript
// 시간과 크기 조건 모두 사용
const hybridThrottle = new RealtimeThrottle({
  batchSize: 50,      // 50개 모이면
  throttleMs: 1000,   // 또는 1초 지나면
  maxQueueSize: 500   // 최대 500개까지 큐잉
});
```

## 💡 활용 예제

### 투표 완료 처리 최적화

```javascript
const { processBatch } = require('./utils/batch-processor');
const { getThrottle } = require('./utils/realtime-throttle');

// 투표 완료 시 대량 알림 처리
async function processVoteCompletion(postId, participants) {
  const throttle = getThrottle();
  
  // 1. 참여자 알림 배치 생성
  await processBatch(
    participants,
    async (batch, userId) => {
      const notificationRef = db.collection('notifications').doc();
      batch.set(notificationRef, {
        userId,
        type: 'voteResult',
        postId,
        title: '투표가 완료되었습니다!',
        createdAt: admin.firestore.FieldValue.serverTimestamp()
      });
    },
    500 // Firestore 배치 제한
  );
  
  // 2. 메시지 상태 스로틀링 업데이트
  participants.forEach(userId => {
    throttle.queueUpdate(postId, {
      type: 'messageStatus',
      userId,
      status: 'completed',
      timestamp: Date.now()
    });
  });
  
  // 3. 모든 업데이트 플러시
  await throttle.flushUpdates(postId);
}
```

### 이미지 검열 병렬 처리

```javascript
const { processParallelBatch, processWithRetry } = require('./utils/batch-processor');

// 여러 이미지를 병렬로 검열
async function moderateImages(imageUrls) {
  // 재시도 로직이 포함된 병렬 처리
  const results = await processWithRetry(
    imageUrls,
    async (url) => {
      // Vision API 호출
      const [result] = await visionClient.safeSearchDetection({
        image: { source: { imageUri: url } }
      });
      
      return {
        url,
        safe: result.safeSearchAnnotation.adult !== 'VERY_LIKELY'
      };
    },
    {
      maxRetries: 3,
      retryDelay: 2000,
      exponentialBackoff: true,
      batchSize: 10 // Vision API 동시 호출 제한
    }
  );
  
  return results;
}
```

### 대규모 데이터 마이그레이션

```javascript
const { processBatch } = require('./utils/batch-processor');

// 컬렉션 전체 마이그레이션
async function migrateCollection(sourceCollection, targetCollection) {
  const snapshot = await db.collection(sourceCollection).get();
  const documents = snapshot.docs;
  
  console.log(`마이그레이션 시작: ${documents.length}개 문서`);
  
  const results = await processBatch(
    documents,
    async (batch, doc) => {
      const data = doc.data();
      
      // 데이터 변환
      const transformedData = {
        ...data,
        migratedAt: admin.firestore.FieldValue.serverTimestamp(),
        version: 2
      };
      
      // 새 컬렉션에 쓰기
      const targetRef = db.collection(targetCollection).doc(doc.id);
      batch.set(targetRef, transformedData);
    },
    500
  );
  
  // 결과 요약
  const successful = results.filter(r => r.success).length;
  const failed = results.filter(r => !r.success).length;
  
  console.log(`마이그레이션 완료: 성공 ${successful}, 실패 ${failed}`);
  
  return results;
}
```

## 🔥 성능 최적화 가이드

### 메모리 관리

```javascript
// ❌ 나쁜 예: 전체 데이터를 메모리에 로드
const allDocs = await db.collection('posts').get();
const results = allDocs.docs.map(doc => processDoc(doc));

// ✅ 좋은 예: 스트리밍 처리
async function* streamDocuments(collection, batchSize = 100) {
  let lastDoc = null;
  
  while (true) {
    let query = db.collection(collection)
      .orderBy('__name__')
      .limit(batchSize);
    
    if (lastDoc) {
      query = query.startAfter(lastDoc);
    }
    
    const snapshot = await query.get();
    if (snapshot.empty) break;
    
    lastDoc = snapshot.docs[snapshot.docs.length - 1];
    yield snapshot.docs;
  }
}

// 사용
for await (const batch of streamDocuments('posts')) {
  await processBatch(batch, processor);
}
```

### 동시성 제어

```javascript
// 동시 실행 제한으로 리소스 관리
class ConcurrencyLimiter {
  constructor(maxConcurrent = 10) {
    this.running = 0;
    this.queue = [];
    this.maxConcurrent = maxConcurrent;
  }
  
  async run(fn) {
    while (this.running >= this.maxConcurrent) {
      await new Promise(resolve => this.queue.push(resolve));
    }
    
    this.running++;
    
    try {
      return await fn();
    } finally {
      this.running--;
      const next = this.queue.shift();
      if (next) next();
    }
  }
}

// 사용
const limiter = new ConcurrencyLimiter(5);
const promises = urls.map(url => 
  limiter.run(() => fetchData(url))
);
const results = await Promise.all(promises);
```

### 캐싱 전략

```javascript
// LRU 캐시 구현
class LRUCache {
  constructor(maxSize = 100, ttlMs = 300000) {
    this.cache = new Map();
    this.maxSize = maxSize;
    this.ttl = ttlMs;
  }
  
  set(key, value) {
    // 기존 항목 삭제 (LRU 순서 유지)
    if (this.cache.has(key)) {
      this.cache.delete(key);
    }
    
    // 크기 제한 체크
    if (this.cache.size >= this.maxSize) {
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    
    // 새 항목 추가
    this.cache.set(key, {
      value,
      expires: Date.now() + this.ttl
    });
  }
  
  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;
    
    // TTL 체크
    if (Date.now() > item.expires) {
      this.cache.delete(key);
      return null;
    }
    
    // LRU 순서 갱신
    this.cache.delete(key);
    this.cache.set(key, item);
    
    return item.value;
  }
}

// 사용
const userCache = new LRUCache(1000, 600000); // 1000개, 10분

async function getUser(userId) {
  // 캐시 확인
  const cached = userCache.get(userId);
  if (cached) return cached;
  
  // DB 조회
  const user = await db.collection('users').doc(userId).get();
  const userData = user.data();
  
  // 캐시 저장
  userCache.set(userId, userData);
  
  return userData;
}
```

## 🧪 테스트 전략

### 단위 테스트

```javascript
// test/batch-processor.test.js
const { processBatch } = require('../utils/batch-processor');
const assert = require('assert');

describe('BatchProcessor', () => {
  it('should process items in batches', async () => {
    const items = Array.from({ length: 1500 }, (_, i) => i);
    const processed = [];
    
    const results = await processBatch(
      items,
      async (batch, item) => {
        processed.push(item);
      },
      500
    );
    
    assert.equal(processed.length, 1500);
    assert.equal(results.length, 3); // 3 batches
    assert.equal(results[0].processed, 500);
    assert.equal(results[1].processed, 500);
    assert.equal(results[2].processed, 500);
  });
  
  it('should handle errors gracefully', async () => {
    const items = [1, 2, 'error', 4, 5];
    
    const results = await processBatch(
      items,
      async (batch, item) => {
        if (item === 'error') {
          throw new Error('Test error');
        }
      },
      2
    );
    
    const failures = results.filter(r => !r.success);
    assert.equal(failures.length, 1);
    assert.equal(failures[0].error, 'Test error');
  });
});
```

### 통합 테스트

```javascript
// test/realtime-throttle.integration.js
const { RealtimeThrottle } = require('../utils/realtime-throttle');
const admin = require('firebase-admin');

describe('RealtimeThrottle Integration', () => {
  let throttle;
  
  beforeEach(() => {
    throttle = new RealtimeThrottle({
      throttleMs: 100,
      batchSize: 5
    });
  });
  
  afterEach(() => {
    throttle.cleanup();
  });
  
  it('should batch updates within time window', async (done) => {
    const postId = 'test-post';
    
    // 빠르게 5개 업데이트 추가
    for (let i = 0; i < 5; i++) {
      throttle.queueUpdate(postId, {
        type: 'vote',
        userId: `user${i}`,
        option: i % 2 === 0 ? 'A' : 'B'
      });
    }
    
    // 100ms 후 배치 처리 확인
    setTimeout(() => {
      assert.equal(throttle.updateQueue.size, 0);
      done();
    }, 150);
  });
});
```

### 부하 테스트

```javascript
// test/load-test.js
const { processParallelBatch } = require('../utils/batch-processor');

async function loadTest() {
  const items = Array.from({ length: 10000 }, (_, i) => i);
  const startTime = Date.now();
  
  const results = await processParallelBatch(
    items,
    async (item) => {
      // 시뮬레이션: 10ms 작업
      await new Promise(resolve => setTimeout(resolve, 10));
      return item * 2;
    },
    100 // 동시 실행 100개
  );
  
  const duration = Date.now() - startTime;
  const throughput = items.length / (duration / 1000);
  
  console.log(`처리 시간: ${duration}ms`);
  console.log(`처리량: ${throughput.toFixed(2)} items/sec`);
  console.log(`성공률: ${(results.filter(r => r.status === 'fulfilled').length / items.length * 100).toFixed(2)}%`);
}

loadTest().catch(console.error);
```

## 🚨 에러 처리

### 일반적인 에러와 해결책

#### 1. 배치 크기 초과
```javascript
// 문제
Error: Batch size cannot exceed 500 operations

// 해결
const { processBatch } = require('./utils/batch-processor');

// 자동으로 500개씩 분할
await processBatch(largeArray, processor, 500);
```

#### 2. 메모리 부족
```javascript
// 문제
FATAL ERROR: Reached heap limit Allocation failed

// 해결: 스트리밍 처리
async function* processInChunks(data, chunkSize = 100) {
  for (let i = 0; i < data.length; i += chunkSize) {
    yield data.slice(i, i + chunkSize);
  }
}

for await (const chunk of processInChunks(bigData)) {
  await processChunk(chunk);
}
```

#### 3. 타임아웃
```javascript
// 문제
Error: Function execution took 60001 ms, finished with status: 'timeout'

// 해결: 작업 분할 및 큐 사용
const { queueVoteUpdate } = require('./utils/realtime-throttle');

// 즉시 응답하고 백그라운드 처리
exports.onVoteCreated = functions.firestore
  .document('votes/{voteId}')
  .onCreate(async (snap, context) => {
    // 큐에 추가만 하고 즉시 반환
    queueVoteUpdate(snap.data().postId, snap.data().userId, snap.data().option);
    return null; // 함수 즉시 종료
  });
```

## 📈 모니터링 및 메트릭

### 성능 메트릭 수집

```javascript
class PerformanceMonitor {
  constructor() {
    this.metrics = {
      totalProcessed: 0,
      totalFailed: 0,
      averageTime: 0,
      peakMemory: 0
    };
  }
  
  async measure(label, fn) {
    const startTime = Date.now();
    const startMemory = process.memoryUsage().heapUsed;
    
    try {
      const result = await fn();
      
      const duration = Date.now() - startTime;
      const memoryUsed = process.memoryUsage().heapUsed - startMemory;
      
      // 메트릭 업데이트
      this.metrics.totalProcessed++;
      this.metrics.averageTime = 
        (this.metrics.averageTime * (this.metrics.totalProcessed - 1) + duration) 
        / this.metrics.totalProcessed;
      this.metrics.peakMemory = Math.max(this.metrics.peakMemory, memoryUsed);
      
      console.log(`[${label}] 완료: ${duration}ms, 메모리: ${(memoryUsed / 1024 / 1024).toFixed(2)}MB`);
      
      return result;
    } catch (error) {
      this.metrics.totalFailed++;
      console.error(`[${label}] 실패:`, error);
      throw error;
    }
  }
  
  report() {
    console.log('=== 성능 리포트 ===');
    console.log(`총 처리: ${this.metrics.totalProcessed}`);
    console.log(`실패: ${this.metrics.totalFailed}`);
    console.log(`평균 시간: ${this.metrics.averageTime.toFixed(2)}ms`);
    console.log(`최대 메모리: ${(this.metrics.peakMemory / 1024 / 1024).toFixed(2)}MB`);
  }
}

// 사용
const monitor = new PerformanceMonitor();

await monitor.measure('배치 처리', async () => {
  await processBatch(items, processor);
});

monitor.report();
```

### 실시간 모니터링

```javascript
// Cloud Monitoring 통합
const monitoring = require('@google-cloud/monitoring');
const client = new monitoring.MetricServiceClient();

async function reportMetric(metricType, value, labels = {}) {
  const projectId = process.env.GCLOUD_PROJECT;
  const dataPoint = {
    interval: {
      endTime: {
        seconds: Date.now() / 1000,
      },
    },
    value: {
      doubleValue: value,
    },
  };
  
  const timeSeriesRequest = {
    name: client.projectPath(projectId),
    timeSeries: [{
      metric: {
        type: `custom.googleapis.com/${metricType}`,
        labels,
      },
      points: [dataPoint],
    }],
  };
  
  await client.createTimeSeries(timeSeriesRequest);
}

// 사용
await reportMetric('batch_processing/duration', duration, {
  function: 'processVoteCompletion',
  status: 'success'
});
```

## 🔄 마이그레이션 가이드

### v1에서 v2로 마이그레이션

```javascript
// v1 (이전)
const batchProcessor = require('./utils/batchProcessor');
await batchProcessor.process(items);

// v2 (현재)
const { processBatch } = require('./utils/batch-processor');
await processBatch(items, processor, 500);
```

### 레거시 코드 개선

```javascript
// 이전: 수동 배치 처리
for (let i = 0; i < items.length; i += 500) {
  const batch = db.batch();
  const chunk = items.slice(i, i + 500);
  
  chunk.forEach(item => {
    batch.set(db.collection('items').doc(item.id), item);
  });
  
  await batch.commit();
}

// 개선: 유틸리티 사용
const { processBatch } = require('./utils/batch-processor');

await processBatch(items, async (batch, item) => {
  batch.set(db.collection('items').doc(item.id), item);
});
```

## 📝 변경 이력

### v2.0.0 (2025-08-21)
- ✨ RealtimeThrottle 클래스 추가
- ✨ processWithRetry 함수 추가
- 🔧 배치 프로세서 성능 최적화
- 📚 종합 문서화 완성

### v1.5.0 (2025-08-15)
- ✨ processParallelBatch 함수 추가
- ✨ processThrottledBatch 함수 추가
- 🐛 메모리 누수 수정

### v1.0.0 (2025-08-01)
- 🎉 초기 릴리스
- ✨ processBatch 함수 구현
- ✨ batchUpdateVoteResults 함수 구현

## 🔗 관련 문서

- [Firebase Functions 서비스 레이어](../services/README.md)
- [프로젝트 네이밍 컨벤션](../../../NAMING_CONVENTION.md)
- [Firebase Functions 가이드](../README.md)
- [프로젝트 아키텍처](../../../ARCHITECTURE.md)

## 📮 지원

문제가 발생하거나 개선 사항이 있다면:
1. [GitHub Issues](https://github.com/versus-space/firebase-functions/issues) 생성
2. 팀 Slack 채널: #firebase-functions
3. 담당자: Firebase Functions 팀

---

*Last Updated: 2025-08-21*
*Version: 2.0.0*