# Firebase Functions Utilities

Firebase Functions에서 사용되는 공통 유틸리티 함수들입니다.

## 📋 파일 목록

### 1. batch-processor.js
대량 데이터 처리를 위한 배치 프로세서입니다.

```javascript
const BatchProcessor = require('./utils/batch-processor');

// 사용 예제
const processor = new BatchProcessor({
  batchSize: 500,      // 배치 크기
  maxRetries: 3,       // 재시도 횟수
  retryDelay: 1000,    // 재시도 지연 (ms)
  maxParallel: 5       // 최대 병렬 처리 수
});

// 배치 처리
await processor.processBatch(items, async (batch) => {
  // 배치 처리 로직
  const promises = batch.map(item => processItem(item));
  await Promise.all(promises);
});
```

**주요 기능:**
- **자동 배치 분할**: 큰 배열을 설정된 크기로 자동 분할
- **병렬 처리**: 여러 배치를 동시에 처리
- **재시도 로직**: 실패한 배치 자동 재시도
- **진행률 추적**: 처리 진행 상황 모니터링

**성능 최적화:**
```javascript
// Firestore 배치 쓰기
await processor.processBatch(documents, async (batch) => {
  const writeBatch = db.batch();
  
  batch.forEach(doc => {
    const ref = db.collection('posts').doc(doc.id);
    writeBatch.set(ref, doc.data);
  });
  
  await writeBatch.commit();
});
```

### 2. realtime-throttle.js
실시간 이벤트 스로틀링을 위한 유틸리티입니다.

```javascript
const { ThrottleManager, createThrottledFunction } = require('./utils/realtime-throttle');

// 스로틀 매니저 생성
const throttle = new ThrottleManager({
  windowMs: 500,          // 시간 창 (ms)
  maxEvents: 10,          // 시간 창 내 최대 이벤트
  queueSize: 100,         // 큐 최대 크기
  flushInterval: 60000    // 플러시 간격 (1분)
});

// 스로틀된 함수 생성
const throttledUpdate = createThrottledFunction(
  async (postId, data) => {
    await updatePost(postId, data);
  },
  { 
    delay: 500,
    maxWait: 2000,
    groupBy: (postId) => postId  // 같은 postId끼리 그룹화
  }
);
```

**주요 기능:**
- **이벤트 그룹화**: 동일한 대상에 대한 이벤트 병합
- **큐 관리**: 메모리 효율적인 큐 시스템
- **자동 플러시**: 주기적인 큐 처리
- **백프레셔 제어**: 과부하 방지

**사용 사례:**
```javascript
// 투표 업데이트 스로틀링
exports.onVoteUpdate = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const postId = context.params.postId;
    
    // 0.5초 동안 같은 게시물의 업데이트를 모아서 처리
    await throttle.add(postId, async () => {
      await processVoteCompletion(postId);
    });
  });
```

## 공통 유틸리티 패턴

### 에러 처리
```javascript
// 안전한 실행 래퍼
async function safeExecute(fn, defaultValue = null) {
  try {
    return await fn();
  } catch (error) {
    console.error('실행 중 오류:', error);
    return defaultValue;
  }
}

// 사용 예제
const result = await safeExecute(
  () => riskyOperation(),
  [] // 기본값
);
```

### 타임아웃 처리
```javascript
// Promise 타임아웃
function withTimeout(promise, timeoutMs, errorMessage) {
  return Promise.race([
    promise,
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error(errorMessage)), timeoutMs)
    )
  ]);
}

// 사용 예제
try {
  const result = await withTimeout(
    longRunningOperation(),
    5000,
    '작업 시간 초과'
  );
} catch (error) {
  console.error('타임아웃:', error.message);
}
```

### 재시도 로직
```javascript
// 지수 백오프 재시도
async function retryWithBackoff(fn, options = {}) {
  const {
    maxRetries = 3,
    initialDelay = 1000,
    maxDelay = 30000,
    factor = 2
  } = options;
  
  let lastError;
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      if (i < maxRetries - 1) {
        const delay = Math.min(
          initialDelay * Math.pow(factor, i),
          maxDelay
        );
        
        console.log(`재시도 ${i + 1}/${maxRetries}, ${delay}ms 대기`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw lastError;
}
```

## 성능 최적화 유틸리티

### 메모리 관리
```javascript
// 큰 배열 스트리밍 처리
async function* streamProcess(largeArray, chunkSize = 100) {
  for (let i = 0; i < largeArray.length; i += chunkSize) {
    const chunk = largeArray.slice(i, i + chunkSize);
    yield chunk;
  }
}

// 사용 예제
for await (const chunk of streamProcess(millionItems)) {
  await processChunk(chunk);
  
  // 메모리 정리
  if (global.gc) {
    global.gc();
  }
}
```

### 캐싱
```javascript
// 간단한 메모리 캐시
class SimpleCache {
  constructor(ttlMs = 300000) { // 5분 기본 TTL
    this.cache = new Map();
    this.ttl = ttlMs;
  }
  
  set(key, value) {
    this.cache.set(key, {
      value,
      expires: Date.now() + this.ttl
    });
  }
  
  get(key) {
    const item = this.cache.get(key);
    
    if (!item) return null;
    
    if (Date.now() > item.expires) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }
  
  clear() {
    this.cache.clear();
  }
}

// 사용 예제
const userCache = new SimpleCache(600000); // 10분 캐시

async function getUser(userId) {
  const cached = userCache.get(userId);
  if (cached) return cached;
  
  const user = await db.collection('users').doc(userId).get();
  userCache.set(userId, user.data());
  
  return user.data();
}
```

## Firestore 헬퍼

### 트랜잭션 헬퍼
```javascript
// 안전한 트랜잭션 실행
async function runTransaction(fn, options = {}) {
  const { maxAttempts = 5 } = options;
  
  return db.runTransaction(async (transaction) => {
    try {
      return await fn(transaction);
    } catch (error) {
      console.error('트랜잭션 오류:', error);
      throw error;
    }
  }, { maxAttempts });
}
```

### 배치 삭제
```javascript
// 컬렉션 전체 삭제 (주의!)
async function deleteCollection(collectionPath, batchSize = 500) {
  const collectionRef = db.collection(collectionPath);
  const query = collectionRef.orderBy('__name__').limit(batchSize);
  
  return new Promise((resolve, reject) => {
    deleteQueryBatch(query, resolve).catch(reject);
  });
}

async function deleteQueryBatch(query, resolve) {
  const snapshot = await query.get();
  
  const batchSize = snapshot.size;
  if (batchSize === 0) {
    resolve();
    return;
  }
  
  const batch = db.batch();
  snapshot.docs.forEach((doc) => {
    batch.delete(doc.ref);
  });
  
  await batch.commit();
  
  process.nextTick(() => {
    deleteQueryBatch(query, resolve);
  });
}
```

## 모니터링 유틸리티

### 성능 측정
```javascript
// 함수 실행 시간 측정
function measureTime(label) {
  const start = Date.now();
  
  return {
    end: () => {
      const duration = Date.now() - start;
      console.log(`[${label}] 실행 시간: ${duration}ms`);
      return duration;
    }
  };
}

// 사용 예제
const timer = measureTime('데이터 처리');
await processLargeDataset();
timer.end();
```

### 메모리 사용량
```javascript
// 메모리 사용량 로깅
function logMemoryUsage(label) {
  const usage = process.memoryUsage();
  console.log(`[${label}] 메모리 사용량:`, {
    rss: `${Math.round(usage.rss / 1024 / 1024)}MB`,
    heapUsed: `${Math.round(usage.heapUsed / 1024 / 1024)}MB`,
    heapTotal: `${Math.round(usage.heapTotal / 1024 / 1024)}MB`
  });
}
```

## 테스트 유틸리티

### Mock 데이터 생성
```javascript
// 테스트용 게시물 생성
function createMockPost(overrides = {}) {
  return {
    uid: 'test_user_123',
    questionTitle: '테스트 질문',
    optionA: { title: 'A 옵션', imageUrl: 'https://example.com/a.jpg' },
    optionB: { title: 'B 옵션', imageUrl: 'https://example.com/b.jpg' },
    createdAt: new Date(),
    votes_a: 0,
    votes_b: 0,
    ...overrides
  };
}
```

## 베스트 프랙티스

1. **에러 처리**: 모든 비동기 작업에 try-catch 사용
2. **로깅**: 중요한 작업마다 로그 남기기
3. **타임아웃**: 외부 API 호출 시 항상 타임아웃 설정
4. **메모리 관리**: 큰 데이터셋은 스트리밍 처리
5. **재시도**: 네트워크 작업은 재시도 로직 포함

## 향후 추가 예정

1. **레이트 리미터**: API 호출 제한 관리
2. **분산 잠금**: 동시성 제어
3. **이벤트 버스**: 함수 간 통신
4. **메트릭 수집**: 성능 지표 자동 수집