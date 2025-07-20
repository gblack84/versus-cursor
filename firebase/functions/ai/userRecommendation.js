// 공통 AI 설정 import
const { ai, models, aiConfig, updateTokenUsage } = require('./config');
const admin = require('firebase-admin');
const { getCachedOrGenerate, getCacheKeyForPost } = require('./cache');

/**
 * 투표 내용을 분석하여 주요 특성 추출
 * @param {Object} postData - 투표 게시물 데이터
 * @returns {Object} 분석 결과 (주제, 카테고리, 타겟 연령대 등)
 */
async function analyzePostContent(postData) {
  // 캐싱 키 생성
  const cacheKey = getCacheKeyForPost(postData);
  
  // 캐시에서 가져오거나 새로 생성
  return await getCachedOrGenerate('postAnalysis', cacheKey, async () => {
    try {
      console.log('[User Recommendation] 투표 내용 분석 시작');
      
      const prompt = `
다음 투표 게시물을 분석하여 JSON 형식으로 응답해주세요:

투표 정보:
- 질문: ${postData.questionTitle || postData.question_title || ''}
- 설명: ${postData.description || ''}
- A 옵션: ${postData.optionA || postData.option_a || ''}
- B 옵션: ${postData.optionB || postData.option_b || ''}
- 카테고리: ${postData.category || '미분류'}

분석 항목:
1. 주요 주제/토픽 (최대 5개)
2. 예상 관심 연령대
3. 관련 관심사 키워드
4. 콘텐츠 성격 (재미, 진지함, 논란성 등)
5. 예상 타겟 성별 (all, male, female)

응답 형식:
{
  "topics": ["주제1", "주제2", ...],
  "targetAge": ["10대", "20대", ...],
  "relatedInterests": ["관심사1", "관심사2", ...],
  "contentType": "fun|serious|controversial|educational",
  "targetGender": "all|male|female",
  "engagementScore": 0-100
}
`;

    const result = await ai.generate({
      model: models.userRecommendation,
      prompt: [{ text: prompt }],
      config: {
        ...aiConfig.recommendation,
        responseFormat: 'json'
      }
    });

    // 토큰 사용량 추적
    const usage = result.usage || result.usageMetadata;
    if (usage) {
      updateTokenUsage('recommendation', usage);
      await logAIUsage('recommendation', usage);
    }

    // 응답 파싱
    let analysis;
    if (result.output && typeof result.output === 'object') {
      analysis = result.output;
    } else {
      const responseText = result.output || result.text || '';
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        analysis = JSON.parse(jsonMatch[0]);
      }
    }

      console.log('[User Recommendation] 투표 분석 완료:', analysis);
      return analysis;

    } catch (error) {
      console.error('[User Recommendation] 투표 분석 오류:', error);
      // 오류 시 기본값 반환
      return {
        topics: [],
        targetAge: ['전체'],
        relatedInterests: [],
        contentType: 'general',
        targetGender: 'all',
        engagementScore: 50
      };
    }
  });
}

/**
 * 사용자 프로필을 기반으로 임베딩 생성
 * @param {Array} users - 사용자 목록
 * @returns {Array} 사용자별 임베딩 벡터
 */
async function generateUserEmbeddings(users) {
  try {
    console.log(`[User Recommendation] ${users.length}명의 사용자 임베딩 생성 시작`);
    
    // 배치 처리를 위한 청크 분할
    const batchSize = aiConfig.embedding.batchSize || 100;
    const chunks = [];
    for (let i = 0; i < users.length; i += batchSize) {
      chunks.push(users.slice(i, i + batchSize));
    }

    const allEmbeddings = [];
    
    for (const chunk of chunks) {
      const embeddings = await Promise.all(
        chunk.map(async (user) => {
          // 사용자 프로필 텍스트 생성
          const profileText = `
            관심사: ${(user.interests || []).join(', ')}
            연령대: ${user.ageGroup || '미지정'}
            성별: ${user.gender || '미지정'}
            활동성: ${user.votingFrequency || 0}회/월
            가입일: ${user.created_time ? new Date(user.created_time._seconds * 1000).toISOString() : '알수없음'}
          `;
          
          try {
            const result = await ai.embed({
              model: models.textEmbedding,
              content: profileText
            });
            
            return {
              userId: user.id,
              embedding: result.embedding || result.vector || result.output,
              profileText
            };
          } catch (embedError) {
            console.error(`[User Recommendation] 사용자 ${user.id} 임베딩 실패:`, embedError);
            return {
              userId: user.id,
              embedding: null,
              profileText
            };
          }
        })
      );
      
      allEmbeddings.push(...embeddings);
    }

    const successCount = allEmbeddings.filter(e => e.embedding !== null).length;
    console.log(`[User Recommendation] 임베딩 생성 완료: ${successCount}/${users.length} 성공`);
    
    return allEmbeddings;

  } catch (error) {
    console.error('[User Recommendation] 임베딩 생성 오류:', error);
    return users.map(user => ({
      userId: user.id,
      embedding: null,
      error: error.message
    }));
  }
}

/**
 * AI를 사용하여 사용자들의 관련성 순위 매기기
 * @param {Object} postAnalysis - 투표 분석 결과
 * @param {Array} users - 사용자 목록
 * @param {Array} embeddings - 사용자 임베딩 (선택사항)
 * @returns {Array} 순위가 매겨진 사용자 목록
 */
async function rankUsersByRelevance(postAnalysis, users, embeddings = null) {
  try {
    console.log('[User Recommendation] AI 기반 사용자 순위 매기기 시작');
    
    // 사용자 정보를 간략하게 정리
    const userSummaries = users.slice(0, 200).map((user, index) => ({
      id: user.id,
      interests: (user.interests || []).join(', '),
      ageGroup: user.ageGroup || '미지정',
      gender: user.gender || '미지정',
      activityLevel: calculateActivityLevel(user),
      index
    }));

    const prompt = `
투표 분석 결과:
${JSON.stringify(postAnalysis, null, 2)}

다음 사용자들을 이 투표에 대한 관심도와 참여 가능성 순으로 정렬하고,
각 사용자의 매칭 점수(0-100)를 부여해주세요.

점수 기준:
- 관심사 매칭: 40점
- 연령대 적합성: 20점
- 활동 수준: 20점
- 콘텐츠 성격 매칭: 20점

사용자 목록:
${JSON.stringify(userSummaries, null, 2)}

응답 형식:
{
  "rankings": [
    {
      "userId": "user_id",
      "score": 85,
      "reasons": ["관심사 일치", "활발한 활동"]
    },
    ...
  ]
}

상위 50명만 응답해주세요.
`;

    const result = await ai.generate({
      model: models.userRecommendation,
      prompt: [{ text: prompt }],
      config: {
        ...aiConfig.recommendation,
        responseFormat: 'json',
        maxOutputTokens: 3000
      }
    });

    // 토큰 사용량 추적
    const usage = result.usage || result.usageMetadata;
    if (usage) {
      updateTokenUsage('recommendation', usage);
      await logAIUsage('recommendation', usage);
    }

    // 응답 파싱
    let rankings;
    if (result.output && typeof result.output === 'object') {
      rankings = result.output.rankings || [];
    } else {
      const responseText = result.output || result.text || '';
      const jsonMatch = responseText.match(/\{[\s\S]*\}/);
      if (jsonMatch) {
        const parsed = JSON.parse(jsonMatch[0]);
        rankings = parsed.rankings || [];
      }
    }

    console.log(`[User Recommendation] 순위 매기기 완료: ${rankings.length}명`);
    
    // 원본 사용자 데이터와 매칭
    const rankedUsers = rankings
      .map(ranking => {
        const user = users.find(u => u.id === ranking.userId);
        if (user) {
          return {
            ...user,
            aiScore: ranking.score,
            aiReasons: ranking.reasons
          };
        }
        return null;
      })
      .filter(user => user !== null);

    return rankedUsers;

  } catch (error) {
    console.error('[User Recommendation] 순위 매기기 오류:', error);
    // 오류 시 랜덤 셔플 반환
    return users
      .sort(() => 0.5 - Math.random())
      .map(user => ({
        ...user,
        aiScore: Math.floor(Math.random() * 50) + 30,
        aiReasons: ['랜덤 선택']
      }));
  }
}

/**
 * 사용자 활동 수준 계산
 */
function calculateActivityLevel(user) {
  const lastActive = user.lastActive?._seconds || 0;
  const now = Date.now() / 1000;
  const daysSinceActive = (now - lastActive) / (24 * 60 * 60);
  
  if (daysSinceActive < 1) return '매우 활발';
  if (daysSinceActive < 3) return '활발';
  if (daysSinceActive < 7) return '보통';
  return '저조';
}

/**
 * 메인 AI 추천 함수
 * @param {Object} postData - 투표 게시물 데이터
 * @param {Array} candidateUsers - 후보 사용자 목록
 * @param {Number} targetCount - 목표 사용자 수
 * @returns {Array} AI가 추천한 사용자 목록
 */
async function getAIRecommendedUsers(postData, candidateUsers, targetCount) {
  try {
    console.log(`[User Recommendation] AI 추천 시작: ${candidateUsers.length}명 중 ${targetCount}명 선택`);
    
    // 1. 투표 내용 분석
    const postAnalysis = await analyzePostContent(postData);
    
    // 2. 사용자 프로필 임베딩 생성 (선택적 - 성능 고려)
    // const embeddings = await generateUserEmbeddings(candidateUsers);
    
    // 3. AI 기반 순위 매기기
    const rankedUsers = await rankUsersByRelevance(postAnalysis, candidateUsers);
    
    // 4. 상위 N명 선택
    const recommendedUsers = rankedUsers
      .sort((a, b) => (b.aiScore || 0) - (a.aiScore || 0))
      .slice(0, targetCount);
    
    console.log(`[User Recommendation] AI 추천 완료: ${recommendedUsers.length}명 선택됨`);
    console.log('[User Recommendation] 평균 AI 점수:', 
      recommendedUsers.reduce((sum, u) => sum + (u.aiScore || 0), 0) / recommendedUsers.length
    );
    
    return recommendedUsers;

  } catch (error) {
    console.error('[User Recommendation] AI 추천 오류:', error);
    
    // 오류 시 폴백: 랜덤 선택
    console.log('[User Recommendation] 폴백: 랜덤 선택 사용');
    return candidateUsers
      .sort(() => 0.5 - Math.random())
      .slice(0, targetCount);
  }
}

module.exports = {
  analyzePostContent,
  generateUserEmbeddings,
  rankUsersByRelevance,
  getAIRecommendedUsers
};