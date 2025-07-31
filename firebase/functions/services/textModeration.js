/**
 * 텍스트 검열 서비스
 * Perspective API를 사용한 텍스트 유해성 검사
 */

const axios = require("axios");
const functions = require("firebase-functions");

// Perspective API 설정
const PERSPECTIVE_API_KEY = process.env.PERSPECTIVE_API_KEY || functions.config().perspective?.api_key;
const PERSPECTIVE_API_URL = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

/**
 * 텍스트 언어 분석
 * @param {string} text - 분석할 텍스트
 * @returns {Object} 언어 분석 결과
 */
function analyzeTextLanguage(text) {
  const koreanChars = (text.match(/[ㄱ-ㅎ|ㅏ-ㅣ|가-힣]/g) || []).length;
  const englishChars = (text.match(/[a-zA-Z]/g) || []).length;
  const totalChars = text.length;
  
  return {
    hasKorean: koreanChars > 0,
    hasEnglish: englishChars > 0,
    koreanRatio: koreanChars / totalChars,
    englishRatio: englishChars / totalChars,
    primaryLanguage: koreanChars > englishChars ? 'ko' : 'en'
  };
}

/**
 * Perspective API로 텍스트 검열
 * @param {string} text - 검열할 텍스트
 * @returns {Object} 검열 결과 {isInappropriate, reason}
 */
async function checkTextWithPerspective(text) {
  if (!PERSPECTIVE_API_KEY) {
    console.warn('[텍스트 검열] PERSPECTIVE_API_KEY가 설정되지 않음');
    return { isInappropriate: false, reason: '' };
  }
  
  if (!text || text.trim().length < 3) {
    console.log('[텍스트 검열] 텍스트가 너무 짧아 검열 생략:', text);
    return { isInappropriate: false, reason: '' };
  }

  console.log('[텍스트 검열] 검열할 텍스트:', text);

  // 언어 분석
  const langInfo = analyzeTextLanguage(text);
  console.log(`[텍스트 검열] Language analysis: Korean=${langInfo.hasKorean}, English=${langInfo.hasEnglish}, Primary=${langInfo.primaryLanguage}`);

  // 기본 속성 설정 (모든 언어 지원)
  const requestedAttributes = {
    TOXICITY: {},
    SEVERE_TOXICITY: {},
    IDENTITY_ATTACK: {},
    INSULT: {},
    PROFANITY: {},
    THREAT: {}
  };

  // 영어 텍스트일 때만 SEXUALLY_EXPLICIT 추가
  if (!langInfo.hasKorean || langInfo.englishRatio > 0.8) {
    requestedAttributes.SEXUALLY_EXPLICIT = {};
    console.log('[텍스트 검열] SEXUALLY_EXPLICIT 속성 추가됨');
  }

  // 언어 설정
  const languages = langInfo.hasKorean ? ['ko'] : ['en'];
  console.log(`[텍스트 검열] 요청 언어: ${languages.join(', ')}`);

  try {
    const response = await axios.post(
      `${PERSPECTIVE_API_URL}?key=${PERSPECTIVE_API_KEY}`,
      {
        comment: { text: text },
        requestedAttributes: requestedAttributes,
        languages: languages
      }
    );

    const scores = response.data.attributeScores;
    
    // 응답 점수 로깅
    const logScores = {
      TOXICITY: scores.TOXICITY?.summaryScore?.value,
      SEVERE_TOXICITY: scores.SEVERE_TOXICITY?.summaryScore?.value,
      IDENTITY_ATTACK: scores.IDENTITY_ATTACK?.summaryScore?.value,
      INSULT: scores.INSULT?.summaryScore?.value,
      PROFANITY: scores.PROFANITY?.summaryScore?.value,
      THREAT: scores.THREAT?.summaryScore?.value
    };
    
    if (scores.SEXUALLY_EXPLICIT) {
      logScores.SEXUALLY_EXPLICIT = scores.SEXUALLY_EXPLICIT.summaryScore?.value;
    }
    
    console.log('[텍스트 검열] 응답 점수:', logScores);
    
    // 점수 임계값 설정
    const thresholds = {
      SEVERE_TOXICITY: 0.5,
      TOXICITY: 0.6,
      IDENTITY_ATTACK: 0.7,
      INSULT: 0.5,
      PROFANITY: 0.5,
      THREAT: 0.7
    };
    
    console.log('[텍스트 검열] 임계값 설정:', thresholds);
    
    // SEXUALLY_EXPLICIT는 영어 텍스트일 때만 추가
    if (scores.SEXUALLY_EXPLICIT) {
      thresholds.SEXUALLY_EXPLICIT = 0.7;
    }

    // 부적절한 콘텐츠 감지
    let isInappropriate = false;
    let reason = '';
    
    for (const [attribute, threshold] of Object.entries(thresholds)) {
      if (scores[attribute] && scores[attribute].summaryScore.value >= threshold) {
        isInappropriate = true;
        
        // 한국어 이유 매핑
        const reasonMap = {
          SEVERE_TOXICITY: '심각한 유해 콘텐츠',
          TOXICITY: '유해한 콘텐츠',
          IDENTITY_ATTACK: '혐오 표현',
          INSULT: '모욕적 표현',
          PROFANITY: '욕설',
          THREAT: '위협적 표현',
          SEXUALLY_EXPLICIT: '성적 콘텐츠'
        };
        
        reason = reasonMap[attribute] || '부적절한 텍스트';
        break;
      }
    }

    return { isInappropriate, reason };
  } catch (error) {
    console.error('[텍스트 검열] 오류 발생:', error.response?.data || error.message);
    console.error('[텍스트 검열] 상태 코드:', error.response?.status);
    // API 오류 시 기본 필터링만 적용
    return checkTextWithBasicFilter(text);
  }
}

/**
 * 기본 텍스트 필터링 (Perspective API 실패 시 백업)
 * @param {string} text - 검열할 텍스트
 * @returns {Object} 검열 결과
 */
function checkTextWithBasicFilter(text) {
  const bannedWords = [
    // 실제 서비스에서는 더 정교한 필터 필요
    '욕설', '비속어', '혐오표현'
  ];
  
  const lowerText = text.toLowerCase();
  for (const word of bannedWords) {
    if (lowerText.includes(word)) {
      return { isInappropriate: true, reason: '부적절한 텍스트 포함' };
    }
  }
  
  return { isInappropriate: false, reason: '' };
}

module.exports = {
  analyzeTextLanguage,
  checkTextWithPerspective,
  checkTextWithBasicFilter
};