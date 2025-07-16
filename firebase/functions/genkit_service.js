const { genkit } = require('genkit');
const { googleAI } = require('@genkit-ai/googleai');
const functions = require('firebase-functions');

// Firebase config에서 API 키 가져오기
const GOOGLE_GENAI_API_KEY = process.env.GOOGLE_GENAI_API_KEY || 
                            functions.config().google?.genai_api_key || 
                            functions.config().gemini?.api_key;

// Genkit 초기화 (API 키 직접 전달)
const ai = genkit({
  plugins: [googleAI({
    apiKey: GOOGLE_GENAI_API_KEY
  })],
});

// Gemini Pro 모델 정의 (함수 내에서 호출)
let geminiPro;

// 프롬프트 템플릿
const VERSUS_VALIDATION_PROMPT = `당신은 사용자가 작성한 A vs B 형식의 콘텐츠를 검토하는 AI입니다.

다음 기준으로 콘텐츠를 평가해주세요:

1. **논리적 타당성**: A와 B가 비교 가능한 대상인가?
2. **중복성**: A와 B가 실질적으로 같은 것을 의미하는가?
3. **의미성**: 비교가 의미 있고 흥미로운가?
4. **유해성**: 부적절하거나 해로운 내용이 포함되어 있는가?
5. **이미지-텍스트 연관성**: 이미지가 있는 경우, 질문/옵션과 관련이 있는가?

특히 주의할 점:
- 질문과 옵션이 전혀 관련 없는 경우 (예: "건빵은 어디가 맛나?" vs "엔진오리/다리털")
- 이미지가 질문/옵션과 무관한 경우 (예: 하늘 사진인데 음식 비교)
- 설명이 질문과 전혀 다른 내용인 경우

JSON 형식으로 응답해주세요:
{
  "isValid": boolean,
  "severity": "pass" | "warning" | "error",
  "reason": "검증 실패 이유 (한국어)",
  "suggestions": "개선 제안 사항 (한국어, 선택사항)",
  "confidence": 0.0-1.0
}`;

// 사용자 기록 가져오기
async function getUserHistory(userId, admin) {
  try {
    // 인덱스 문제로 인한 임시 조치: orderBy 제거
    // TODO: Firestore 복합 인덱스 생성 후 orderBy 다시 추가
    const userPostsSnapshot = await admin.firestore()
      .collection('posts_record')
      .where('user_info.user_ref', '==', admin.firestore().doc(`users_record/${userId}`))
      .limit(5)
      .get();

    const history = [];
    userPostsSnapshot.forEach(doc => {
      const data = doc.data();
      history.push({
        questionTitle: data.question_title || '',
        titleA: data.title_A || '',
        titleB: data.title_B || '',
        timestamp: data.timestamp
      });
    });

    // 수동으로 timestamp 기준 정렬 (최신순)
    history.sort((a, b) => {
      const timeA = a.timestamp?._seconds || 0;
      const timeB = b.timestamp?._seconds || 0;
      return timeB - timeA;
    });

    console.log(`[Genkit] 사용자 기록 ${history.length}개 조회 성공`);
    return history;
  } catch (error) {
    console.error('[Genkit] 사용자 기록 조회 실패:', error);
    console.error('[Genkit] 에러 상세:', error.message);
    
    // 인덱스 관련 에러인 경우 구체적인 메시지 출력
    if (error.code === 9 || error.message?.includes('index')) {
      console.error('[Genkit] Firestore 인덱스가 필요합니다. Firebase Console에서 인덱스를 생성해주세요.');
    }
    
    // 에러 발생 시에도 빈 배열 반환하여 서비스 계속 진행
    return [];
  }
}

// 콘텐츠 검증 함수
async function validateContentWithGenkit({
  userId,
  questionTitle,
  description,
  titleA,
  titleB,
  imageUrlA,
  imageUrlB,
  visionDataA,
  visionDataB,
  perspectiveScores,
  admin
}) {
  try {
    // API 키 확인
    if (!GOOGLE_GENAI_API_KEY) {
      console.error('[Genkit] API 키가 설정되지 않았습니다.');
      console.error('[Genkit] 환경 변수를 확인하세요: GOOGLE_GENAI_API_KEY, google.genai_api_key, gemini.api_key');
      return {
        isValid: true,
        severity: 'pass',
        reason: '',
        suggestions: '',
        error: true,
        errorMessage: 'API key not configured'
      };
    }
    
    console.log('[Genkit] API 키 설정 확인: ', GOOGLE_GENAI_API_KEY ? '있음' : '없음');
    
    // 입력된 콘텐츠 로깅
    console.log('[Genkit] 검증 요청 콘텐츠:');
    console.log(`  - 질문: ${questionTitle || '없음'}`);
    console.log(`  - 설명: ${description || '없음'}`);
    console.log(`  - A 옵션: ${titleA || '없음'}`);
    console.log(`  - B 옵션: ${titleB || '없음'}`);
    console.log(`  - A 이미지 URL: ${imageUrlA || '없음'}`);
    console.log(`  - B 이미지 URL: ${imageUrlB || '없음'}`);
    console.log(`  - A Vision 데이터: ${visionDataA ? '있음' : '없음'}`);
    console.log(`  - B Vision 데이터: ${visionDataB ? '있음' : '없음'}`);
    
    // Vision 데이터 상세 로깅
    if (visionDataA) {
      console.log('[Genkit] A 이미지 Vision 분석:');
      console.log(`  - SafeSearch: ${JSON.stringify(visionDataA.safeSearch || {})}`);
      console.log(`  - 라벨 수: ${visionDataA.labels?.length || 0}`);
      console.log(`  - 텍스트 감지: ${visionDataA.hasText ? '예' : '아니오'}`);
    }
    if (visionDataB) {
      console.log('[Genkit] B 이미지 Vision 분석:');
      console.log(`  - SafeSearch: ${JSON.stringify(visionDataB.safeSearch || {})}`);
      console.log(`  - 라벨 수: ${visionDataB.labels?.length || 0}`);
      console.log(`  - 텍스트 감지: ${visionDataB.hasText ? '예' : '아니오'}`);
    }
    
    // 사용자 기록 가져오기
    const userHistory = await getUserHistory(userId, admin);
    
    // 프롬프트 구성
    const userPrompt = `
사용자가 작성한 콘텐츠:
- 질문: ${questionTitle || '없음'}
- 설명: ${description || '없음'}
- A 옵션: ${titleA || '없음'}
- B 옵션: ${titleB || '없음'}

${visionDataA || visionDataB ? `
이미지 분석 결과 (Vision API):` : ''}
${visionDataA ? `
[A 이미지 분석]
- 주요 라벨: ${visionDataA.labels?.slice(0, 5).map(l => l.description).join(', ') || '없음'}
- 감지된 텍스트: ${visionDataA.detectedText || '없음'}
- SafeSearch: 성인(${visionDataA.safeSearch?.adult}), 폭력(${visionDataA.safeSearch?.violence}), 선정적(${visionDataA.safeSearch?.racy})
- 감지된 객체: ${visionDataA.objects?.slice(0, 3).map(o => o.name).join(', ') || '없음'}` : ''}
${visionDataB ? `
[B 이미지 분석]
- 주요 라벨: ${visionDataB.labels?.slice(0, 5).map(l => l.description).join(', ') || '없음'}
- 감지된 텍스트: ${visionDataB.detectedText || '없음'}
- SafeSearch: 성인(${visionDataB.safeSearch?.adult}), 폭력(${visionDataB.safeSearch?.violence}), 선정적(${visionDataB.safeSearch?.racy})
- 감지된 객체: ${visionDataB.objects?.slice(0, 3).map(o => o.name).join(', ') || '없음'}` : ''}

${perspectiveScores ? `
텍스트 유해성 점수:
${Object.entries(perspectiveScores).map(([key, value]) => `- ${key}: ${value}`).join('\n')}
` : ''}

${userHistory.length > 0 ? `
사용자의 최근 게시물:
${userHistory.map((post, i) => `${i + 1}. ${post.questionTitle} (A: ${post.titleA}, B: ${post.titleB})`).join('\n')}
` : ''}

이 콘텐츠를 검증해주세요. 특히 다음 사항을 확인하세요:
1. 질문과 A/B 옵션의 논리적 연관성
2. 이미지가 있는 경우, 이미지 내용과 질문/옵션의 관련성
3. 전체적인 맥락의 적절성`;

    // 모델 초기화 (처음 호출 시)
    if (!geminiPro) {
      geminiPro = 'googleai/gemini-1.5-flash';
    }

    // Genkit을 사용한 생성
    const result = await ai.generate({
      model: geminiPro,
      prompt: `${VERSUS_VALIDATION_PROMPT}\n\n${userPrompt}`,
      config: {
        temperature: 0.3,
        maxOutputTokens: 1000,
      }
    });
    
    // result 전체 구조 로깅 (토큰 정보 위치 파악용)
    console.log('[Genkit] Result 전체 구조:', JSON.stringify(result, null, 2));

    // 토큰 사용량 로깅 - 다양한 위치 확인
    const usage = result.usage || result.usageMetadata || result.metadata?.tokenUsage || result.tokenUsage;
    
    if (usage) {
      console.log('[Genkit] 토큰 사용량:');
      console.log(`  - 프롬프트: ${usage.promptTokenCount || usage.inputTokens || 0} 토큰`);
      console.log(`  - 응답: ${usage.candidatesTokenCount || usage.outputTokens || 0} 토큰`);
      console.log(`  - 전체: ${usage.totalTokenCount || usage.totalTokens || 0} 토큰`);
      if (usage.cachedContentTokenCount) {
        console.log(`  - 캐시됨: ${usage.cachedContentTokenCount} 토큰`);
      }
    } else {
      console.log('[Genkit] 토큰 사용량 정보 없음');
    }

    // 응답 파싱
    // Genkit의 generate 메서드는 output() 또는 직접 텍스트 접근
    let responseData;
    
    // result.output이 이미 객체인 경우 직접 사용
    if (result.output && typeof result.output === 'object') {
      responseData = result.output;
      console.log('[Genkit] AI 응답 (객체):', responseData);
    } else {
      // 문자열인 경우 파싱 시도
      const responseText = result.output || result.text || result.content || JSON.stringify(result);
      console.log('[Genkit] AI 응답 (텍스트):', responseText);
      
      try {
        if (typeof responseText === 'string') {
          const jsonMatch = responseText.match(/\{[\s\S]*\}/);
          if (jsonMatch) {
            responseData = JSON.parse(jsonMatch[0]);
          }
        } else {
          responseData = responseText;
        }
      } catch (parseError) {
        console.error('[Genkit] JSON 파싱 실패:', parseError);
        responseData = null;
      }
    }

    if (responseData) {
      // 검증 결과 로깅
      console.log('[Genkit] AI 검증 결과:');
      console.log(`  - isValid: ${responseData.isValid}`);
      console.log(`  - severity: ${responseData.severity || 'pass'}`);
      console.log(`  - reason: ${responseData.reason || '없음'}`);
      console.log(`  - suggestions: ${responseData.suggestions || '없음'}`);
      console.log(`  - confidence: ${responseData.confidence || 'N/A'}`);
      
      // 토큰 사용량 정보 안전하게 처리
      const tokenUsage = result.usage || result.usageMetadata || result.metadata?.tokenUsage || result.tokenUsage;
      
      return {
        isValid: responseData.isValid === true,
        severity: responseData.severity || 'pass',
        reason: responseData.reason || '',
        suggestions: responseData.suggestions || '',
        confidence: responseData.confidence,
        tokenUsage: tokenUsage || null
      };
    }

    // 파싱 실패 시 기본값
    const tokenUsage = result.usage || result.usageMetadata || result.metadata?.tokenUsage || result.tokenUsage;
    
    return {
      isValid: true,
      severity: 'pass',
      reason: '',
      suggestions: '',
      tokenUsage: tokenUsage || null
    };

  } catch (error) {
    console.error('[Genkit] 콘텐츠 검증 오류:', error);
    console.error('[Genkit] 에러 타입:', error.constructor.name);
    console.error('[Genkit] 에러 메시지:', error.message);
    console.error('[Genkit] 에러 스택:', error.stack);
    
    // API 키 오류 처리
    if (error.message?.includes('API key') || error.message?.includes('401')) {
      console.error('[Genkit] API 키 오류 - GOOGLE_GENAI_API_KEY 확인 필요');
      console.error('[Genkit] 현재 API 키 설정 여부:', !!process.env.GOOGLE_GENAI_API_KEY);
    }
    
    // 인덱스 관련 에러
    if (error.code === 9 || error.message?.includes('index')) {
      console.error('[Genkit] Firestore 인덱스 문제일 수 있습니다.');
    }
    
    // 서비스 중단 방지를 위해 기본값 반환
    return {
      isValid: true,
      severity: 'pass',
      reason: '',
      suggestions: '',
      error: true,
      errorMessage: error.message
    };
  }
}

module.exports = {
  validateContentWithGenkit,
  ai,
  geminiPro
};