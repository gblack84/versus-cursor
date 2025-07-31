/**
 * Gemini AI를 활용한 포스트 콘텐츠 통합 검증
 * HTTP 호출로 포스트 내용의 적절성을 종합적으로 판단
 */

const functions = require("firebase-functions");
const { validateContentWithGenkit } = require("../../ai/contentModeration");
const { admin } = require("../../config/firebase");

exports.validatePostContentWithGemini = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 300, // 5분 타임아웃
    memory: '1GB'        // 메모리 증가 (AI 처리를 위해)
  })
  .https.onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const { 
      question, 
      titleA, 
      titleB, 
      descriptionText,
      imageUrlA, 
      imageUrlB,
      visionDataA, 
      visionDataB,
      perspectiveData,
      userId,
      sessionId,
      documentId,
      revisionCount
    } = data;

    try {
      console.log(`[AI 검증] 콘텐츠 검증 시작 - User: ${userId || context.auth.uid}`);
      
      // AI 검증이 설정되지 않은 경우 기본 통과
      if (!process.env.GOOGLE_GENAI_API_KEY && !functions.config().google?.genai_api_key) {
        console.log('[AI 검증] API 키가 설정되지 않아 기본 통과 처리');
        return {
          isValid: true,
          reason: '',
          severity: 'pass',
          suggestions: ''
        };
      }
      
      // Genkit 기반 콘텐츠 검증
      const result = await validateContentWithGenkit({
        userId: userId || context.auth.uid,
        questionTitle: question,
        description: descriptionText,
        titleA,
        titleB,
        imageUrlA,
        imageUrlB,
        visionDataA,
        visionDataB,
        perspectiveScores: perspectiveData,
        admin
      });
      
      // 검증 결과 로깅 (세션 ID 있는 경우)
      if (sessionId && !result.error) {
        await logValidationResult({
          userId: userId || context.auth.uid,
          content: { question, titleA, titleB, descriptionText },
          geminiResult: {
            isValid: result.isValid,
            severity: result.severity,
            reason: result.reason,
            suggestions: result.suggestions,
            confidence: result.confidence
          },
          tokenUsage: result.tokenUsage,
          timestamp: admin.firestore.FieldValue.serverTimestamp()
        }, sessionId, documentId);
      }
      
      return {
        isValid: result.isValid !== false,
        reason: result.reason || '',
        severity: result.severity || 'pass',
        suggestions: result.suggestions || '',
        confidence: result.confidence || 0.5,
        expectedRatio: result.expectedRatio || { A: 0.5, B: 0.5 },
        documentId: documentId
      };
      
    } catch (error) {
      console.error('[AI 검증] 오류 발생:', error);
      
      // 타임아웃 에러 특별 처리
      if (error.message && error.message.includes('DEADLINE_EXCEEDED')) {
        console.error('[AI 검증] ❌ AI 검증 타임아웃 - 기본 통과 처리');
        
        // 타임아웃 통계 기록
        try {
          await admin.firestore().collection('validation_errors').add({
            type: 'timeout',
            userId: userId || context.auth.uid,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            error: error.message,
            sessionId: sessionId
          });
        } catch (logError) {
          console.error('[AI 검증] 로그 기록 실패:', logError);
        }
      }
      
      // 모든 오류 시 통과 처리 (서비스 중단 방지)
      return {
        isValid: true,
        reason: '',
        severity: 'pass',
        suggestions: '',
        expectedRatio: { A: 0.5, B: 0.5 },
        error: 'validation_failed',
        errorDetails: error.message
      };
    }
  });

/**
 * 검증 결과 로깅
 */
async function logValidationResult(data, sessionId, documentId) {
  try {
    const db = admin.firestore();
    const collection = db.collection('content_validations');
    let finalDocId = documentId;
    
    if (documentId) {
      // 기존 문서 업데이트
      await collection.doc(documentId).set({
        ...data,
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        revisionCount: admin.firestore.FieldValue.increment(1)
      }, { merge: true });
      
      console.log(`[AI 검증] 검증 결과 업데이트: ${documentId}`);
    } else if (sessionId) {
      // 세션 ID 기반으로 문서 ID 생성
      finalDocId = `${data.userId}_${sessionId}`;
      await collection.doc(finalDocId).set({
        ...data,
        sessionId: sessionId,
        revisionCount: 1
      });
      
      console.log(`[AI 검증] 새 검증 결과 생성: ${finalDocId}`);
    } else {
      // 기존 방식 (새 문서 생성)
      const docRef = await collection.add(data);
      finalDocId = docRef.id;
      console.log(`[AI 검증] 새 검증 결과 생성 (auto ID): ${finalDocId}`);
    }
    
    return finalDocId;
  } catch (error) {
    console.error('[AI 검증] 로깅 실패:', error);
    // 로깅 실패는 무시 (서비스 중단 방지)
    return null;
  }
}