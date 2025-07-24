// 공통 AI 설정 import
const { ai, models, aiConfig, GOOGLE_GENAI_API_KEY, updateTokenUsage } = require('./config');
const admin = require('firebase-admin');

// 프롬프트 템플릿
const VERSUS_VALIDATION_PROMPT = `
########################################################################
# Versus Space – 콘텐츠 검증 AI 통합 프롬프트 4.0
########################################################################

/*============================== 1) 역할(Persona) ==============================*/
당신은 'Versus Space' 커뮤니티의 재치 있고 현명한 커뮤니티-매니저 AI입니다.  
목표: (1) 유해 콘텐츠 차단  (2) 재미‧의미있는 비교 장려  (3) 친절한 코칭 제공

/*===================== 2) 두 단계 필터링(Workflow) =====================*/
① 1차 필터 – 절대 금지 영역 ⇒ "action":"BLOCK"  
② 2차 필터 – 품질·의도 판단 ⇒ "PROCEED" / "PROCEED_WITH_SUGGESTION" / "BLOCK"

/*==================== 3) 1차 필터 – 절대 금지(BLOCK) ====================*/
다음 항목 중 하나라도 충족하면 무조건 BLOCK.
- 혐오‧차별: 인종·성별·종교·국적·성적 지향 등 집단 비하·폭력 선동
- 범죄 조장: 범죄 계획·방법·미화, 불법상품·서비스 홍보, 테러·극단주의
- 개인정보 노출: 동의 없는 실명·연락처·주소·얼굴 등
- 노골적 성적/폭력 묘사, 아동 착취
- 스팸·사기·피싱·전문가/타인 사칭·허위 정보 유포

/*==================== 4) 2차 필터 – 품질·의도 판단 ====================*/
A. PROCEED – 창의적·재미있고 비교 가능 (밸런스게임, 밈 등)  
B. PROCEED_WITH_SUGGESTION – 논리 부족·정보 모호하지만 악의 없음  
   → feedback에 구체적 개선 팁 제시  
C. BLOCK – 무의미 장난·트롤링·정책 경계선(질문·옵션 불일치 등)

/*====================== 5) 특별 가이드라인(세부 룰) ======================*/
● 정치·종교  
  - 정책·이념·공인 행보 토론 ▶ 허용  
  - 특정 인물·집단 비방·음모론 ▶ BLOCK  

● 얼굴·외모 【★★★ 매우 중요 - 이미지에 사람 얼굴이 있을 때 필수 확인 ★★★】
  - 사람 얼굴 평가·점수·비교 ▶ 무조건 BLOCK  
  - 다음 모두 해당 시 BLOCK:
    ① 이미지에 사람 얼굴이 포함됨
    ② "닮았나요", "누구 같나요", "무엇을 닮았나요" 등 외모 비교 질문
    ③ 선택지가 동물, 캐릭터, 사물 등 (예: 요다/개구리, 강아지/고양이 등)
  - 본인 스타일 질문 또는 공인 공식 사진 비교 ▶ 허용  
  - 얼굴 노출 이미지 → Vision safeSearch 통과 필수  

● 이미지 일관성  
  - 이미지가 질문/옵션과 무관하면 BLOCK 또는 재촬영 권고  

/*==================== 6) 커뮤니티 가이드라인 요약(참조) ====================*/
🚫 **불법·위험 행위**: 범죄 계획, 불법 상품·서비스, 테러·극단주의  
💔 **타인에게 상처**: 혐오, 따돌림, 폭력 선동, 자해 조장, 사생활 침해  
🤥 **사기·허위 정보**: 스팸, 피싱, AI/전문가/타인 사칭  
🔞 **음란·성적으로 노골적 콘텐츠**: 공익 목적 없는 성적 만족용 질문

/*===================== 7) 출력(JSON) – 반드시 준수 =====================*/
{
  "action": "PROCEED" | "PROCEED_WITH_SUGGESTION" | "BLOCK",
  "feedback": {
    "title": "짧고 핵심적인 한 줄",
    "description": "사용자에게 보여줄 상세 가이드"
  } | null,
  "confidence": 0.0-1.0           // 신뢰도(선택)
}

/*========================== 8) 응답 예시 ==========================*/
① 완전 통과
{ "action":"PROCEED", "feedback":null, "confidence":0.92 }

② 개선 권장
{ "action":"PROCEED_WITH_SUGGESTION",
  "feedback":{
    "title":"후보 정보가 더 궁금해요!",
    "description":"각 후보의 경력·공약을 한두 줄씩 적어주면 투표가 더 쉬워집니다 😊"
  },
  "confidence":0.74 }

③ 차단
{ "action":"BLOCK",
  "feedback":{
    "title":"비교가 성립하지 않아요 😢",
    "description":"A·B 옵션이 질문과 무관합니다. 직접 비교 가능한 대상을 선택해 주세요."
  },
  "confidence":0.86 }
`;

// 새로운 응답 형식을 기존 형식으로 변환하는 함수
function convertResponseFormat(aiResponse) {
  // action을 기존 severity로 매핑
  const severityMap = {
    'PROCEED': 'pass',
    'PROCEED_WITH_SUGGESTION': 'warning',
    'BLOCK': 'error'
  };

  return {
    isValid: aiResponse.action !== 'BLOCK',
    severity: severityMap[aiResponse.action] || 'pass',
    reason: aiResponse.feedback?.title || '',
    suggestions: aiResponse.feedback?.description || '',
    confidence: aiResponse.confidence || 0.5
  };
}

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
    console.error('[Content Moderation] 사용자 기록 조회 실패:', error);
    console.error('[Content Moderation] 에러 상세:', error.message);
    
    // 인덱스 관련 에러인 경우 구체적인 메시지 출력
    if (error.code === 9 || error.message?.includes('index')) {
      console.error('[Content Moderation] Firestore 인덱스가 필요합니다. Firebase Console에서 인덱스를 생성해주세요.');
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
      console.error('[Content Moderation] API 키가 설정되지 않았습니다.');
      console.error('[Content Moderation] 환경 변수를 확인하세요: GOOGLE_GENAI_API_KEY, google.genai_api_key, gemini.api_key');
      return {
        isValid: true,
        severity: 'pass',
        reason: '',
        suggestions: '',
        error: true,
        errorMessage: 'API key not configured'
      };
    }
    
    console.log('[Content Moderation] API 키 설정 확인: ', GOOGLE_GENAI_API_KEY ? '있음' : '없음');
    
    // 입력된 콘텐츠 로깅
    console.log('[Content Moderation] 검증 요청 콘텐츠:');
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
      console.log('[Content Moderation] A 이미지 Vision 분석:');
      console.log(`  - SafeSearch: ${JSON.stringify(visionDataA.safeSearch || {})}`);
      console.log(`  - 라벨 수: ${visionDataA.labels?.length || 0}`);
      console.log(`  - 텍스트 감지: ${visionDataA.hasText ? '예' : '아니오'}`);
    }
    if (visionDataB) {
      console.log('[Content Moderation] B 이미지 Vision 분석:');
      console.log(`  - SafeSearch: ${JSON.stringify(visionDataB.safeSearch || {})}`);
      console.log(`  - 라벨 수: ${visionDataB.labels?.length || 0}`);
      console.log(`  - 텍스트 감지: ${visionDataB.hasText ? '예' : '아니오'}`);
    }
    
    // 🔥 병렬 처리 개선: 사용자 기록과 이미지 URL 변환을 동시에 처리
    const startTime = Date.now();
    
    // 병렬 작업 시작
    const [userHistory, displayUrls] = await Promise.all([
      // 사용자 기록 가져오기
      getUserHistory(userId, admin),
      
      // 이미지 URL 변환 (display 크기 사용)
      Promise.resolve({
        displayImageA: imageUrlA ? imageUrlA.replace('_original.jpg', '_display.jpg') : null,
        displayImageB: imageUrlB ? imageUrlB.replace('_original.jpg', '_display.jpg') : null
      })
    ]);
    
    console.log(`[Content Moderation] 병렬 처리 완료 - ${Date.now() - startTime}ms`);
    
    // display 이미지 URL 검증 및 fallback
    let displayImageA = displayUrls.displayImageA;
    let displayImageB = displayUrls.displayImageB;
    
    if (imageUrlA && displayImageA) {
      if (!displayImageA.includes('_display.jpg') && imageUrlA.includes('_original.jpg')) {
        console.log('[Content Moderation] ⚠️ Display 이미지 변환 실패, 원본 사용:', imageUrlA);
        displayImageA = imageUrlA;
      }
    }
    
    if (imageUrlB && displayImageB) {
      if (!displayImageB.includes('_display.jpg') && imageUrlB.includes('_original.jpg')) {
        console.log('[Content Moderation] ⚠️ Display 이미지 변환 실패, 원본 사용:', imageUrlB);
        displayImageB = imageUrlB;
      }
    }
    
    // 1. 시스템 프롬프트는 그대로 둡니다.
    const systemPrompt = VERSUS_VALIDATION_PROMPT;

    // 2. 사용자가 입력한 텍스트 콘텐츠를 별도로 구성합니다.
    const userTextContent = `
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
3. 전체적인 맥락의 적절성

【중요】 이미지에 사람 얼굴이 포함되어 있고, 질문이 "닮았나요" 형태이며, 
선택지가 동물/캐릭터/사물인 경우 = 얼굴 평가로 간주하여 반드시 BLOCK 처리하세요.`;

    // 콘텐츠 검열용 모델 사용
    const geminiModel = models.contentModeration;

    // 3. 최종 프롬프트를 시스템 지침, 사용자 텍스트, 사용자 이미지 순서로 구성합니다.
    const generatePrompt = [
      { text: systemPrompt },
      { text: userTextContent }
    ];

    // 이미지 URL이 있는 경우 프롬프트에 추가
    if (displayImageA) {
      console.log('[Content Moderation] A 이미지 포함 (display):', displayImageA);
      generatePrompt.push({ 
        media: { 
          url: displayImageA,
          contentType: 'image/jpeg'
        } 
      });
    }
    
    if (displayImageB) {
      console.log('[Content Moderation] B 이미지 포함 (display):', displayImageB);
      generatePrompt.push({ 
        media: { 
          url: displayImageB,
          contentType: 'image/jpeg'
        } 
      });
    }

    if (imageUrlA || imageUrlB) {
      console.log('[Content Moderation] 멀티모달 프롬프트 사용 - 이미지 개수:', (imageUrlA ? 1 : 0) + (imageUrlB ? 1 : 0));
    } else {
      console.log('[Content Moderation] 텍스트 전용 프롬프트 사용');
    }

    // Genkit을 사용한 생성 (공통 설정 사용)
    const aiStartTime = Date.now();
    const result = await ai.generate({
      model: geminiModel,
      prompt: generatePrompt,
      config: aiConfig.moderation
    });
    console.log(`[Content Moderation] AI 처리 완료 - ${Date.now() - aiStartTime}ms`);
    
    // result 전체 구조 로깅 (토큰 정보 위치 파악용)
    console.log('[Content Moderation] Result 전체 구조:', JSON.stringify(result, null, 2));

    // 토큰 사용량 로깅 및 통계 업데이트
    const usage = result.usage || result.usageMetadata || result.metadata?.tokenUsage || result.tokenUsage;
    
    if (usage) {
      // 중앙 집중식 토큰 사용량 추적
      updateTokenUsage('moderation', usage);
    } else {
      console.log('[Content Moderation] 토큰 사용량 정보 없음');
    }

    // 응답 파싱
    // Genkit의 generate 메서드는 output() 또는 직접 텍스트 접근
    let responseData;
    
    // result.output이 이미 객체인 경우 직접 사용
    if (result.output && typeof result.output === 'object') {
      responseData = result.output;
      console.log('[Content Moderation] AI 응답 (객체):', responseData);
    } else {
      // 문자열인 경우 파싱 시도
      const responseText = result.output || result.text || result.content || JSON.stringify(result);
      console.log('[Content Moderation] AI 응답 (텍스트):', responseText);
      
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
        console.error('[Content Moderation] JSON 파싱 실패:', parseError);
        responseData = null;
      }
    }

    if (responseData) {
      // 검증 결과 로깅
      // 새로운 응답 형식 처리
      if (responseData.action) {
        console.log('[Content Moderation] AI 검증 결과 (새 형식):');
        console.log(`  - action: ${responseData.action}`);
        console.log(`  - feedback: ${responseData.feedback ? JSON.stringify(responseData.feedback) : 'null'}`);
        console.log(`  - confidence: ${responseData.confidence || 'N/A'}`);
        
        // 새 형식을 기존 형식으로 변환
        const converted = convertResponseFormat(responseData);
        
        // 토큰 사용량 정보 안전하게 처리
        const tokenUsage = result.usage || result.usageMetadata || result.metadata?.tokenUsage || result.tokenUsage;
        
        return {
          ...converted,
          tokenUsage: tokenUsage || null
        };
      }
      // 기존 형식 처리 (하위 호환성)
      else if (responseData.isValid !== undefined) {
        console.log('[Content Moderation] AI 검증 결과 (기존 형식):');
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
    console.error('[Content Moderation] 콘텐츠 검증 오류:', error);
    console.error('[Content Moderation] 에러 타입:', error.constructor.name);
    console.error('[Content Moderation] 에러 메시지:', error.message);
    console.error('[Content Moderation] 에러 스택:', error.stack);
    
    // API 키 오류 처리
    if (error.message?.includes('API key') || error.message?.includes('401')) {
      console.error('[Content Moderation] API 키 오류 - GOOGLE_GENAI_API_KEY 확인 필요');
      console.error('[Content Moderation] 현재 API 키 설정 여부:', !!process.env.GOOGLE_GENAI_API_KEY);
    }
    
    // 인덱스 관련 에러
    if (error.code === 9 || error.message?.includes('index')) {
      console.error('[Content Moderation] Firestore 인덱스 문제일 수 있습니다.');
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
  validateContentWithGenkit
};