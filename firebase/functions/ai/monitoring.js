/**
 * AI 시스템 모니터링 및 로깅
 * 사용량 추적, 성능 모니터링, A/B 테스트 지원
 */

const admin = require('firebase-admin');
const { getTokenUsageReport } = require('./config');

/**
 * AI 작업 로깅
 * @param {string} operation - 작업 유형 (moderation, recommendation, embedding)
 * @param {Object} details - 작업 상세 정보
 */
async function logAIOperation(operation, details) {
  try {
    const logData = {
      operation,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      ...details,
      // 환경 정보
      environment: process.env.FUNCTIONS_EMULATOR ? 'emulator' : 'production',
      functionVersion: process.env.K_REVISION || 'unknown'
    };

    // Firestore에 로그 저장
    await admin.firestore()
      .collection('aiOperationLogs')
      .add(logData);

    // 콘솔 로그
    console.log(`[AI Monitoring] ${operation} logged:`, {
      operation,
      success: details.success,
      latency: details.latency,
      tokens: details.tokens
    });

  } catch (error) {
    console.error('[AI Monitoring] 로깅 실패:', error);
    // 로깅 실패는 서비스에 영향을 주지 않도록 함
  }
}

/**
 * AI 사용량 로깅
 * @param {string} operation - 작업 유형
 * @param {Object} usage - 토큰 사용량 정보
 */
async function logAIUsage(operation, usage) {
  if (!usage) return;

  try {
    const usageData = {
      operation,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
      tokens: {
        input: usage.inputTokens || usage.promptTokenCount || 0,
        output: usage.outputTokens || usage.candidatesTokenCount || 0,
        total: usage.totalTokens || usage.totalTokenCount || 0,
        cached: usage.cachedContentTokenCount || 0
      },
      model: usage.model || 'unknown',
      // 비용 추정 (Gemini 가격 기준)
      estimatedCost: calculateCost(operation, usage)
    };

    await admin.firestore()
      .collection('aiUsageLogs')
      .add(usageData);

  } catch (error) {
    console.error('[AI Monitoring] 사용량 로깅 실패:', error);
  }
}

/**
 * 비용 계산
 */
function calculateCost(operation, usage) {
  const input = usage.inputTokens || usage.promptTokenCount || 0;
  const output = usage.outputTokens || usage.candidatesTokenCount || 0;

  // Gemini 가격 (USD per 1M tokens)
  const prices = {
    moderation: { input: 0.075, output: 0.30 },    // Flash
    recommendation: { input: 1.25, output: 5.00 },  // Pro
    embedding: { input: 0.1, output: 0 }            // Embedding
  };

  const price = prices[operation] || prices.recommendation;
  const cost = (input / 1000000) * price.input + (output / 1000000) * price.output;

  return {
    amount: cost,
    currency: 'USD',
    breakdown: {
      inputCost: (input / 1000000) * price.input,
      outputCost: (output / 1000000) * price.output
    }
  };
}

/**
 * 성능 측정 헬퍼
 */
class PerformanceTracker {
  constructor(operation, metadata = {}) {
    this.operation = operation;
    this.metadata = metadata;
    this.startTime = Date.now();
  }

  async complete(success = true, additionalData = {}) {
    const latency = Date.now() - this.startTime;
    
    await logAIOperation(this.operation, {
      success,
      latency,
      ...this.metadata,
      ...additionalData
    });

    return latency;
  }
}

/**
 * A/B 테스트 추적
 */
async function trackExperiment(experimentName, variant, userId, outcome) {
  try {
    await admin.firestore()
      .collection('aiExperiments')
      .add({
        experiment: experimentName,
        variant,
        userId,
        outcome,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });

    console.log(`[AI Monitoring] Experiment tracked: ${experimentName}/${variant}`);

  } catch (error) {
    console.error('[AI Monitoring] 실험 추적 실패:', error);
  }
}

/**
 * 추천 성공률 추적
 */
async function trackRecommendationOutcome(postId, userId, action) {
  try {
    await admin.firestore()
      .collection('recommendationOutcomes')
      .add({
        postId,
        userId,
        action, // 'viewed', 'voted', 'ignored', 'reported'
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      });

  } catch (error) {
    console.error('[AI Monitoring] 추천 결과 추적 실패:', error);
  }
}

/**
 * 일일 사용량 리포트 생성
 */
async function generateDailyUsageReport() {
  try {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);

    // 오늘의 AI 사용량 로그 조회
    const snapshot = await admin.firestore()
      .collection('aiUsageLogs')
      .where('timestamp', '>=', today)
      .where('timestamp', '<', tomorrow)
      .get();

    const stats = {
      moderation: { count: 0, tokens: 0, cost: 0 },
      recommendation: { count: 0, tokens: 0, cost: 0 },
      total: { count: 0, tokens: 0, cost: 0 }
    };

    snapshot.forEach(doc => {
      const data = doc.data();
      const op = data.operation;
      
      if (stats[op]) {
        stats[op].count++;
        stats[op].tokens += data.tokens.total;
        stats[op].cost += data.estimatedCost.amount;
      }
      
      stats.total.count++;
      stats.total.tokens += data.tokens.total;
      stats.total.cost += data.estimatedCost.amount;
    });

    // 리포트 저장
    await admin.firestore()
      .collection('aiDailyReports')
      .doc(today.toISOString().split('T')[0])
      .set({
        date: today,
        stats,
        generatedAt: admin.firestore.FieldValue.serverTimestamp()
      });

    console.log('[AI Monitoring] 일일 리포트 생성 완료:', stats);
    return stats;

  } catch (error) {
    console.error('[AI Monitoring] 일일 리포트 생성 실패:', error);
    throw error;
  }
}

/**
 * 실시간 모니터링 대시보드용 메트릭
 */
async function getRealtimeMetrics() {
  try {
    // 현재 인메모리 토큰 사용량
    const tokenReport = getTokenUsageReport();
    
    // 최근 1시간 성능 메트릭
    const oneHourAgo = new Date();
    oneHourAgo.setHours(oneHourAgo.getHours() - 1);
    
    const perfSnapshot = await admin.firestore()
      .collection('aiOperationLogs')
      .where('timestamp', '>', oneHourAgo)
      .get();

    const performanceStats = {
      moderation: { count: 0, avgLatency: 0, successRate: 0 },
      recommendation: { count: 0, avgLatency: 0, successRate: 0 }
    };

    const latencies = { moderation: [], recommendation: [] };
    const successes = { moderation: 0, recommendation: 0 };

    perfSnapshot.forEach(doc => {
      const data = doc.data();
      const op = data.operation;
      
      if (performanceStats[op]) {
        performanceStats[op].count++;
        latencies[op].push(data.latency);
        if (data.success) successes[op]++;
      }
    });

    // 평균 계산
    for (const op of ['moderation', 'recommendation']) {
      if (latencies[op].length > 0) {
        performanceStats[op].avgLatency = 
          latencies[op].reduce((a, b) => a + b, 0) / latencies[op].length;
        performanceStats[op].successRate = 
          (successes[op] / performanceStats[op].count) * 100;
      }
    }

    return {
      timestamp: new Date().toISOString(),
      tokenUsage: tokenReport,
      performance: performanceStats
    };

  } catch (error) {
    console.error('[AI Monitoring] 실시간 메트릭 조회 실패:', error);
    return null;
  }
}

module.exports = {
  logAIOperation,
  logAIUsage,
  PerformanceTracker,
  trackExperiment,
  trackRecommendationOutcome,
  generateDailyUsageReport,
  getRealtimeMetrics
};