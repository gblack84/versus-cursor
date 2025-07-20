/**
 * AI 시스템용 캐싱 레이어
 * 메모리 기반 캐싱으로 토큰 사용량 감소 및 응답 속도 향상
 */

// 간단한 메모리 캐시 구현 (node-cache 대신 기본 Map 사용)
class SimpleCache {
  constructor(ttlSeconds = 3600) {
    this.cache = new Map();
    this.ttl = ttlSeconds * 1000; // milliseconds
  }

  get(key) {
    const item = this.cache.get(key);
    if (!item) return null;
    
    if (Date.now() > item.expiry) {
      this.cache.delete(key);
      return null;
    }
    
    return item.value;
  }

  set(key, value) {
    this.cache.set(key, {
      value,
      expiry: Date.now() + this.ttl
    });
  }

  has(key) {
    return this.get(key) !== null;
  }

  clear() {
    this.cache.clear();
  }

  // 만료된 항목 정리
  cleanup() {
    const now = Date.now();
    for (const [key, item] of this.cache.entries()) {
      if (now > item.expiry) {
        this.cache.delete(key);
      }
    }
  }

  // 캐시 통계
  stats() {
    this.cleanup();
    return {
      size: this.cache.size,
      keys: Array.from(this.cache.keys())
    };
  }
}

// 캐시 인스턴스 생성
const caches = {
  // 사용자 프로필 임베딩 캐시 (1시간)
  userEmbeddings: new SimpleCache(3600),
  
  // 투표 분석 결과 캐시 (30분)
  postAnalysis: new SimpleCache(1800),
  
  // AI 추천 결과 캐시 (5분)
  recommendations: new SimpleCache(300),
  
  // 사용자 프로필 캐시 (15분)
  userProfiles: new SimpleCache(900)
};

/**
 * 캐시를 통한 함수 실행
 * 캐시에 있으면 반환, 없으면 생성 후 캐시
 */
async function getCachedOrGenerate(cacheType, key, generator) {
  const cache = caches[cacheType];
  if (!cache) {
    console.warn(`[Cache] Unknown cache type: ${cacheType}`);
    return await generator();
  }

  // 캐시 확인
  const cached = cache.get(key);
  if (cached !== null) {
    console.log(`[Cache] Hit: ${cacheType}/${key}`);
    return cached;
  }

  // 캐시 미스 - 생성
  console.log(`[Cache] Miss: ${cacheType}/${key} - Generating...`);
  try {
    const result = await generator();
    cache.set(key, result);
    return result;
  } catch (error) {
    console.error(`[Cache] Generation error for ${cacheType}/${key}:`, error);
    throw error;
  }
}

/**
 * 투표 분석 결과 캐싱
 */
function getCacheKeyForPost(postData) {
  // 투표의 주요 내용을 기반으로 캐시 키 생성
  const elements = [
    postData.questionTitle || postData.question_title || '',
    postData.optionA || postData.option_a || '',
    postData.optionB || postData.option_b || '',
    postData.category || ''
  ];
  
  return `post_${elements.join('_').replace(/\s+/g, '').substring(0, 100)}`;
}

/**
 * 사용자 목록 캐시 키 생성
 */
function getCacheKeyForUserList(userIds) {
  // 사용자 ID 목록을 정렬하여 일관된 키 생성
  const sorted = userIds.slice().sort();
  const hash = sorted.join(',').substring(0, 200);
  return `users_${hash}`;
}

/**
 * 추천 결과 캐시 키 생성
 */
function getCacheKeyForRecommendation(postId, targetAudience) {
  return `rec_${postId}_${targetAudience.type}_${targetAudience.targetCount}`;
}

/**
 * 캐시 통계 및 정리
 */
function getCacheStats() {
  const stats = {};
  for (const [name, cache] of Object.entries(caches)) {
    stats[name] = cache.stats();
  }
  return stats;
}

/**
 * 모든 캐시 정리
 */
function clearAllCaches() {
  for (const cache of Object.values(caches)) {
    cache.clear();
  }
  console.log('[Cache] All caches cleared');
}

/**
 * 주기적 캐시 정리 (옵션)
 */
function startCacheCleanup(intervalMinutes = 10) {
  setInterval(() => {
    console.log('[Cache] Running cleanup...');
    for (const [name, cache] of Object.entries(caches)) {
      const before = cache.stats().size;
      cache.cleanup();
      const after = cache.stats().size;
      if (before !== after) {
        console.log(`[Cache] ${name}: Cleaned ${before - after} expired items`);
      }
    }
  }, intervalMinutes * 60 * 1000);
}

module.exports = {
  caches,
  getCachedOrGenerate,
  getCacheKeyForPost,
  getCacheKeyForUserList,
  getCacheKeyForRecommendation,
  getCacheStats,
  clearAllCaches,
  startCacheCleanup
};