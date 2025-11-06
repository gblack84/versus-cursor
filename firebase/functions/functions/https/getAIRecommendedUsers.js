const { onCall, HttpsError } = require('firebase-functions/v2/https');
const { getAIRecommendedUsers } = require('../../ai/userRecommendation');
const admin = require('firebase-admin');

/**
 * Callable Cloud Function: AI 기반 사용자 추천
 *
 * Flutter 클라이언트에서 호출 가능한 HTTP callable function으로,
 * 게시물 ID를 받아 Gemini AI 기반 추천 사용자 리스트를 반환합니다.
 *
 * @param {Object} request.data
 * @param {string} request.data.postId - 투표 게시물 ID
 * @param {number} request.data.targetCount - 추천할 사용자 수 (기본값: 50)
 * @returns {Object} { success: boolean, userIds: string[], scores: number[], metadata: {...} }
 *
 * @example
 * // Flutter에서 호출 예시:
 * final callable = FirebaseFunctions.instance.httpsCallable('getAIRecommendedUsersCallable');
 * final result = await callable.call({
 *   'postId': 'abc123',
 *   'targetCount': 50,
 * });
 */
exports.getAIRecommendedUsersCallable = onCall(async (request) => {
  try {
    const { postId, targetCount = 50 } = request.data;

    // Validation: postId 필수
    if (!postId) {
      throw new HttpsError('invalid-argument', 'postId is required');
    }

    // Validation: targetCount 범위 검증
    if (targetCount <= 0 || targetCount > 1000) {
      throw new HttpsError(
        'invalid-argument',
        'targetCount must be between 1 and 1000'
      );
    }

    console.log(
      `[AI Recommendation] Starting: postId=${postId}, targetCount=${targetCount}`
    );

    // 1. Firestore에서 게시물 데이터 조회
    const postDoc = await admin
      .firestore()
      .collection('posts')
      .doc(postId)
      .get();

    if (!postDoc.exists) {
      throw new HttpsError('not-found', `Post ${postId} not found`);
    }

    const postData = postDoc.data();
    console.log(
      `[AI Recommendation] Post found: ${postData.questionTitle || 'Untitled'}`
    );

    // 2. 활성 사용자 후보군 조회 (최대 1000명)
    const usersSnapshot = await admin
      .firestore()
      .collection('users')
      .where('isActive', '==', true)
      .limit(1000)
      .get();

    const candidateUsers = usersSnapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    console.log(
      `[AI Recommendation] Candidate users found: ${candidateUsers.length}`
    );

    if (candidateUsers.length === 0) {
      console.warn('[AI Recommendation] No active users found');
      return {
        success: true,
        userIds: [],
        scores: [],
        metadata: {
          totalCandidates: 0,
          recommendedCount: 0,
          avgScore: 0,
          warning: 'No active users available',
        },
      };
    }

    // 3. AI 추천 실행 (userRecommendation.js의 getAIRecommendedUsers 호출)
    console.log('[AI Recommendation] Calling AI recommendation engine...');
    const recommendedUsers = await getAIRecommendedUsers(
      postData,
      candidateUsers,
      targetCount
    );

    // 4. 결과 추출
    const userIds = recommendedUsers.map((user) => user.id);
    const scores = recommendedUsers.map((user) => user.aiScore || 50);

    // 평균 점수 계산
    const avgScore =
      scores.length > 0
        ? scores.reduce((a, b) => a + b, 0) / scores.length
        : 0;

    console.log(
      `[AI Recommendation] Success: ${userIds.length} users recommended, avg score: ${avgScore.toFixed(1)}`
    );

    // 5. 성공 응답 반환
    return {
      success: true,
      userIds,
      scores,
      metadata: {
        totalCandidates: candidateUsers.length,
        recommendedCount: userIds.length,
        avgScore: parseFloat(avgScore.toFixed(2)),
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
      },
    };
  } catch (error) {
    console.error('[AI Recommendation] Error:', error);

    // HttpsError는 그대로 throw (Firebase에서 자동 처리)
    if (error instanceof HttpsError) {
      throw error;
    }

    // 기타 에러는 internal error로 래핑
    throw new HttpsError(
      'internal',
      `AI recommendation failed: ${error.message}`
    );
  }
});
