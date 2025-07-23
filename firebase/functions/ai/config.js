const { genkit } = require('genkit');
const { googleAI } = require('@genkit-ai/googleai');
const functions = require('firebase-functions');

// Firebase config에서 API 키 가져오기
const GOOGLE_GENAI_API_KEY = process.env.GOOGLE_GENAI_API_KEY || 
                            functions.config().google?.genai_api_key || 
                            functions.config().gemini?.api_key;

if (!GOOGLE_GENAI_API_KEY) {
  console.error('[AI Config] API 키가 설정되지 않았습니다.');
  console.error('[AI Config] 환경 변수를 확인하세요: GOOGLE_GENAI_API_KEY, google.genai_api_key, gemini.api_key');
}

// Genkit 초기화 (API 키 직접 전달)
const ai = genkit({
  plugins: [googleAI({
    apiKey: GOOGLE_GENAI_API_KEY
  })],
});

// 모델 정의 - 용도별로 최적화된 모델 선택
const models = {
  // 콘텐츠 검열용 - 빠른 응답 속도 우선
  contentModeration: 'googleai/gemini-1.5-flash',
  
  // 사용자 추천용 - 정확도 우선
  userRecommendation: 'googleai/gemini-1.5-pro',
  
  // 텍스트 임베딩용 - 유사도 계산
  textEmbedding: 'googleai/text-embedding-004'
};

// 공통 설정
const aiConfig = {
  // 콘텐츠 검열 설정
  moderation: {
    temperature: 0.3,
    maxOutputTokens: 1000
    // timeout은 Gemini API generation_config에서 지원하지 않음
  },
  
  // 사용자 추천 설정
  recommendation: {
    temperature: 0.5,
    maxOutputTokens: 2000
    // timeout은 Gemini API generation_config에서 지원하지 않음
  },
  
  // 임베딩 설정
  embedding: {
    dimensions: 768,
    batchSize: 100
  }
};

// 토큰 사용량 추적
let tokenUsageStats = {
  moderation: { input: 0, output: 0, total: 0 },
  recommendation: { input: 0, output: 0, total: 0 },
  embedding: { total: 0 }
};

// 토큰 사용량 업데이트 함수
function updateTokenUsage(operation, usage) {
  if (!usage) return;
  
  const stats = tokenUsageStats[operation];
  if (stats) {
    stats.input += usage.inputTokens || usage.promptTokenCount || 0;
    stats.output += usage.outputTokens || usage.candidatesTokenCount || 0;
    stats.total += usage.totalTokens || usage.totalTokenCount || 0;
  }
  
  // 로깅
  console.log(`[AI Config] ${operation} 토큰 사용:`, {
    input: usage.inputTokens || usage.promptTokenCount || 0,
    output: usage.outputTokens || usage.candidatesTokenCount || 0,
    total: usage.totalTokens || usage.totalTokenCount || 0
  });
}

// 토큰 사용량 리포트
function getTokenUsageReport() {
  return {
    timestamp: new Date().toISOString(),
    stats: tokenUsageStats,
    estimatedCost: calculateEstimatedCost(tokenUsageStats)
  };
}

// 예상 비용 계산 (Gemini 가격 기준)
function calculateEstimatedCost(stats) {
  // Gemini 1.5 Flash: $0.075 / 1M input tokens, $0.30 / 1M output tokens
  // Gemini 1.5 Pro: $1.25 / 1M input tokens, $5.00 / 1M output tokens
  
  const flashInputCost = (stats.moderation.input / 1000000) * 0.075;
  const flashOutputCost = (stats.moderation.output / 1000000) * 0.30;
  
  const proInputCost = (stats.recommendation.input / 1000000) * 1.25;
  const proOutputCost = (stats.recommendation.output / 1000000) * 5.00;
  
  return {
    moderation: flashInputCost + flashOutputCost,
    recommendation: proInputCost + proOutputCost,
    total: flashInputCost + flashOutputCost + proInputCost + proOutputCost,
    currency: 'USD'
  };
}

module.exports = {
  ai,
  models,
  aiConfig,
  GOOGLE_GENAI_API_KEY,
  updateTokenUsage,
  getTokenUsageReport
};