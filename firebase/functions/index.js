const functions = require("firebase-functions");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");
const axios = require("axios");
const { ChatGoogleGenerativeAI } = require("@langchain/google-genai");
const { validateContentWithGenkit } = require("./ai/contentModeration");

// 알림 관련 모듈 import
const { matchTargetUsers } = require('./notifications/targetMatcher');
const { createNotificationsForUsers } = require('./notifications/notificationCreator');

// 최적화 유틸리티 import
const { batchUpdateVoteResults, processWithRetry } = require('./utils/batch-processor');
const { queueVoteUpdate, queueMessageStatusUpdate, queueProgressUpdate, getThrottle } = require('./utils/realtime-throttle');

admin.initializeApp();

// Vision API 클라이언트 초기화
const visionClient = new vision.ImageAnnotatorClient();

// Perspective API 설정
const PERSPECTIVE_API_KEY = process.env.PERSPECTIVE_API_KEY || functions.config().perspective?.api_key;
const PERSPECTIVE_API_URL = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

// Gemini API 설정
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || functions.config().gemini?.api_key;
// Genkit용 환경 변수 추가
process.env.GOOGLE_GENAI_API_KEY = process.env.GOOGLE_GENAI_API_KEY || 
                                   functions.config().google?.genai_api_key || 
                                   functions.config().gemini?.api_key;

let geminiModel;
if (GEMINI_API_KEY) {
  geminiModel = new ChatGoogleGenerativeAI({
    apiKey: GEMINI_API_KEY,
    modelName: "gemini-pro",
    temperature: 0.3,
    maxOutputTokens: 1000,
  });
}

// 텍스트 언어 분석 함수
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

// Perspective API로 텍스트 검열
async function checkTextWithPerspective(text) {
  if (!PERSPECTIVE_API_KEY) {
    console.warn('[WARNING] PERSPECTIVE_API_KEY가 설정되지 않음');
    console.log('[Perspective API] 현재 API 키 길이:', PERSPECTIVE_API_KEY ? PERSPECTIVE_API_KEY.length : 0);
    return { isInappropriate: false, reason: '' };
  }
  
  if (!text || text.trim().length < 3) {
    console.log('[Perspective API] 텍스트가 너무 짧아 검열 생략:', text);
    return { isInappropriate: false, reason: '' };
  }

  console.log('[Perspective API] 검열할 텍스트:', text);

  // 언어 분석
  const langInfo = analyzeTextLanguage(text);
  console.log(`[Perspective API] Language analysis: Korean=${langInfo.hasKorean}, English=${langInfo.hasEnglish}, Primary=${langInfo.primaryLanguage}`);

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
    console.log('[Perspective API] SEXUALLY_EXPLICIT 속성 추가됨');
  }

  // 언어 설정
  const languages = langInfo.hasKorean ? ['ko'] : ['en'];
  console.log(`[Perspective API] 요청 언어: ${languages.join(', ')}`);

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
    
    // 응답 점수 로깅 (SEXUALLY_EXPLICIT는 조건부)
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
    
    console.log('[Perspective API] 응답 점수:', logScores);
    
    // 점수 임계값 설정 (낮을수록 더 엄격)
    const thresholds = {
      SEVERE_TOXICITY: 0.5,
      TOXICITY: 0.6,        // 0.7 → 0.6 (더 엄격)
      IDENTITY_ATTACK: 0.7,
      INSULT: 0.5,          // 0.7 → 0.5 (더 엄격)
      PROFANITY: 0.5,       // 0.7 → 0.5 (더 엄격)
      THREAT: 0.7
    };
    
    console.log('[Perspective API] 임계값 설정:', thresholds);
    
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
    console.error('[Perspective API] 오류 발생:', error.response?.data || error.message);
    console.error('[Perspective API] 상태 코드:', error.response?.status);
    // API 오류 시 기본 필터링만 적용
    return checkTextWithBasicFilter(text);
  }
}

// 기본 텍스트 필터링 (Perspective API 실패 시 백업)
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

exports.onUserDeleted = functions
  .region("asia-northeast3")
  .auth.user()
  .onDelete(async (user) => {
    let firestore = admin.firestore();
    let userRef = firestore.doc("users/" + user.uid);
    await firestore.collection("users").doc(user.uid).delete();
  });

// HTTP 호출로 이미지 콘텐츠만 검사하는 함수 (저장하지 않음)
exports.checkImageContent = functions
  .region("asia-northeast3")
  .https.onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    const { image, box } = data;
    
    if (!image) {
      throw new functions.https.HttpsError('invalid-argument', '이미지 데이터가 필요합니다.');
    }

    try {
      console.log(`Image moderation started - User: ${context.auth.uid}, Box: ${box || 'unknown'}`);
      
      // Vision API로 SafeSearch 검출
      const [result] = await visionClient.safeSearchDetection({
        image: { content: image }
      });
      
      const detections = result.safeSearchAnnotation;
      console.log("SafeSearch 결과:", detections);
      
      // OCR로 텍스트 추출 (편집된 이미지일 가능성이 있으면)
      let textDetected = '';
      let isTextInappropriate = false;
      let textReason = '';
      
      try {
        const [textResult] = await visionClient.textDetection({
          image: { content: image },
          imageContext: {
            languageHints: ['ko', 'en']  // 한국어와 영어 힌트 추가
          }
        });
        
        if (textResult.textAnnotations && textResult.textAnnotations.length > 0) {
          textDetected = textResult.textAnnotations[0].description || '';
          console.log(`[OCR] 추출된 텍스트 (${textDetected.length}자): ${textDetected.substring(0, 100)}...`);
          
          // 텍스트가 있으면 Perspective API로 검열
          const textCheckResult = await checkTextWithPerspective(textDetected);
          isTextInappropriate = textCheckResult.isInappropriate;
          textReason = textCheckResult.reason;
          
          if (isTextInappropriate) {
            console.log(`[Perspective API] 부적절한 텍스트 감지: ${textReason}`);
          }
        } else {
          console.log('[OCR] 텍스트가 감지되지 않음');
        }
      } catch (ocrError) {
        console.error("OCR 처리 중 오류:", ocrError);
        // OCR 실패는 무시하고 이미지 검열만 진행
      }
      
      // 이미지 부적절한 콘텐츠 감지 기준
      const isImageInappropriate = 
        detections.adult === "VERY_LIKELY" || 
        detections.adult === "LIKELY" ||
        detections.violence === "VERY_LIKELY" ||
        detections.violence === "LIKELY" ||
        detections.racy === "VERY_LIKELY";
      
      // 거부 이유 결정
      let reason = '';
      if (isTextInappropriate) {
        reason = textReason;
      } else if (detections.adult === "VERY_LIKELY" || detections.adult === "LIKELY") {
        reason = '성인 콘텐츠';
      } else if (detections.violence === "VERY_LIKELY" || detections.violence === "LIKELY") {
        reason = '폭력적 콘텐츠';
      } else if (detections.racy === "VERY_LIKELY") {
        reason = '선정적 콘텐츠';
      }
      
      const isInappropriate = isImageInappropriate || isTextInappropriate;
      
      // 로그 기록 (최소한의 정보만)
      if (isInappropriate) {
        console.log(`Inappropriate content detected - User: ${context.auth.uid}, Reason: ${reason}`);
      }
      
      return {
        isAppropriate: !isInappropriate,
        reason: reason,
        hasText: textDetected.length > 0,
        // 디버깅용 (프로덕션에서는 제거 가능)
        detections: process.env.NODE_ENV === 'development' ? detections : undefined
      };
      
    } catch (error) {
      console.error("이미지 검열 중 오류:", error);
      throw new functions.https.HttpsError('internal', '이미지 검사 중 오류가 발생했습니다.');
    }
  });

// 이미지 업로드 시 자동으로 검열하는 함수
exports.moderateImage = functions
  .region("asia-northeast3")
  .storage.object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    const bucket = admin.storage().bucket(object.bucket);
    
    // 이미지 파일이 아니면 무시
    if (!contentType || !contentType.startsWith("image/")) {
      console.log("Not an image file, skipping moderation.");
      return null;
    }
    
    // 썸네일이나 블러 처리된 이미지는 무시 (무한 루프 방지)
    if (filePath.includes("_blur") || filePath.includes("_thumb") || filePath.includes("_display")) {
      console.log("Already processed image, skipping moderation.");
      return null;
    }
    
    try {
      // Storage에서 이미지 다운로드
      const file = bucket.file(filePath);
      const [imageBuffer] = await file.download();
      
      // Vision API로 종합적인 이미지 분석
      const request = {
        image: { content: imageBuffer.toString("base64") },
        features: [
          { type: 'SAFE_SEARCH_DETECTION' },
          { type: 'LABEL_DETECTION', maxResults: 20 },
          { type: 'TEXT_DETECTION' },
          { type: 'LOGO_DETECTION', maxResults: 5 },
          { type: 'OBJECT_LOCALIZATION', maxResults: 10 },
          { type: 'IMAGE_PROPERTIES' },
          { type: 'FACE_DETECTION', maxResults: 10 }
        ]
      };
      
      const [result] = await visionClient.annotateImage(request);
      
      const detections = result.safeSearchAnnotation;
      const labels = result.labelAnnotations || [];
      const texts = result.textAnnotations || [];
      const logos = result.logoAnnotations || [];
      const objects = result.localizedObjectAnnotations || [];
      const imageProperties = result.imagePropertiesAnnotation || {};
      const faces = result.faceAnnotations || [];
      console.log("SafeSearch results:", detections);
      
      // 메타데이터에서 정보 추출
      const metadata = object.metadata || {};
      const userId = metadata.uploadedBy || "unknown";
      const sessionId = metadata.sessionId || "default";
      const box = metadata.box || "unknown";
      
      // 세션 기반 모더레이션 ID 생성 (userId_sessionId_box)
      const moderationId = `${userId}_${sessionId}_${box}`;
      console.log(`Moderation ID: ${moderationId} for file: ${filePath}`);
      
      const moderationData = {
        imageUrl: `gs://${object.bucket}/${filePath}`,
        downloadUrl: object.mediaLink || "",
        filePath: filePath,
        userId: userId,
        sessionId: sessionId,
        box: box,
        moderationStatus: "pending",
        lastUpdated: admin.firestore.FieldValue.serverTimestamp(),
        safeSearchResults: {
          adult: detections.adult || "UNKNOWN",
          spoof: detections.spoof || "UNKNOWN",
          medical: detections.medical || "UNKNOWN",
          violence: detections.violence || "UNKNOWN",
          racy: detections.racy || "UNKNOWN"
        },
        // 새로운 Vision API 데이터 추가
        labels: labels.map(label => ({
          description: label.description,
          score: label.score,
          topicality: label.topicality
        })),
        detectedText: texts.length > 0 ? texts[0].description : null,
        logos: logos.map(logo => ({
          description: logo.description,
          score: logo.score
        })),
        objects: objects.map(obj => ({
          name: obj.name,
          score: obj.score,
          boundingPoly: obj.boundingPoly
        })),
        dominantColors: imageProperties.dominantColors?.colors?.slice(0, 5).map(color => ({
          color: color.color,
          score: color.score,
          pixelFraction: color.pixelFraction
        })) || [],
        faces: faces.map(face => ({
          joyLikelihood: face.joyLikelihood,
          sorrowLikelihood: face.sorrowLikelihood,
          angerLikelihood: face.angerLikelihood,
          surpriseLikelihood: face.surpriseLikelihood,
          detectionConfidence: face.detectionConfidence
        })),
        moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
        originalMetadata: object.metadata || {}
      };
      
      // 부적절한 콘텐츠 감지 기준
      const isInappropriate = 
        detections.adult === "VERY_LIKELY" || 
        detections.adult === "LIKELY" ||
        detections.violence === "VERY_LIKELY" ||
        detections.violence === "LIKELY" ||
        detections.racy === "VERY_LIKELY";
      
      if (isInappropriate) {
        console.log("Inappropriate content detected, deleting image (updated logic).");
        
        moderationData.moderationStatus = "rejected";
        moderationData.action = "deleted";
        
        // Firestore에 먼저 기록 (merge 옵션으로 업데이트 또는 생성)
        await admin.firestore()
          .collection("image_moderation")
          .doc(moderationId)
          .set(moderationData, { merge: true });
        
        // 모든 버전의 이미지 삭제
        try {
          // original, display, thumbnail 버전 모두 삭제
          const baseFileName = filePath.replace(/_original\.|_display\.|_thumb\./, '.');
          const extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp'];
          const versions = ['_original', '_display', '_thumb'];
          
          for (const version of versions) {
            for (const ext of extensions) {
              if (baseFileName.endsWith(ext)) {
                const versionPath = baseFileName.replace(ext, `${version}${ext}`);
                try {
                  await bucket.file(versionPath).delete();
                  console.log(`Deleted: ${versionPath}`);
                } catch (deleteError) {
                  // 파일이 없는 경우는 무시
                  if (!deleteError.message.includes('No such object')) {
                    console.error(`Failed to delete ${versionPath}:`, deleteError.message);
                  }
                }
              }
            }
          }
          
          console.log(`All versions of inappropriate image deleted: ${filePath}`);
        } catch (deleteError) {
          console.error("Error deleting inappropriate image:", deleteError);
          // 삭제 실패 시 Firestore 업데이트
          await admin.firestore()
            .collection("image_moderation")
            .doc(moderationId)
            .update({
              deleteError: deleteError.message,
              deleteFailedAt: admin.firestore.FieldValue.serverTimestamp()
            });
        }
        
        return null; // 추가 처리 중단
      } else {
        moderationData.moderationStatus = "approved";
      }
      
      // Firestore에 검열 결과 저장 (merge 옵션으로 업데이트 또는 생성)
      await admin.firestore()
        .collection("image_moderation")
        .doc(moderationId)
        .set(moderationData, { merge: true });
      
      console.log(`Image moderation completed for ${filePath}`);
      return null;
      
    } catch (error) {
      console.error("Error moderating image:", error);
      
      // 에러 발생 시에도 기록 남기기
      const metadata = object.metadata || {};
      const userId = metadata.uploadedBy || "unknown";
      const sessionId = metadata.sessionId || "default";
      const box = metadata.box || "unknown";
      const moderationId = `${userId}_${sessionId}_${box}`;
      
      await admin.firestore()
        .collection("image_moderation")
        .doc(moderationId)
        .set({
          imageUrl: `gs://${object.bucket}/${filePath}`,
          filePath: filePath,
          userId: userId,
          sessionId: sessionId,
          box: box,
          moderationStatus: "error",
          error: error.message,
          moderatedAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdated: admin.firestore.FieldValue.serverTimestamp()
        }, { merge: true });
      
      return null;
    }
  });

// Gemini AI를 활용한 포스트 콘텐츠 통합 검증
exports.validatePostContentWithGemini = functions
  .region("asia-northeast3")
  .runWith({
    timeoutSeconds: 300, // 5분 타임아웃 (기본 60초에서 증가)
    memory: '1GB'        // 메모리도 증가 (AI 처리를 위해)
  })
  .https.onCall(async (data, context) => {
    // 인증 확인
    if (!context.auth) {
      throw new functions.https.HttpsError('unauthenticated', '로그인이 필요합니다.');
    }

    if (!GEMINI_API_KEY) {
      console.warn('[WARNING] GEMINI_API_KEY가 설정되지 않음');
      // API 키가 없으면 기본 통과 처리 (Phase 1)
      return {
        isValid: true,
        reason: '',
        severity: 'pass',
        suggestions: ''
      };
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
      console.log(`[Gemini Validation] Started - User: ${userId}`);
      
      // Genkit 사용 여부 (환경 변수로 제어)
      const useGenkit = process.env.USE_GENKIT === 'true' || functions.config().genkit?.enabled === 'true';
      
      if (useGenkit) {
        console.log('[Gemini] Genkit 모드 사용');
        
        // Genkit을 사용한 검증
        const genkitResult = await validateContentWithGenkit({
          userId,
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
        
        if (genkitResult) {
          // 에러가 발생한 경우 로그만 남기고 기본값 반환
          if (genkitResult.error) {
            console.log('[Gemini] Error occurred during Genkit validation, defaulting to pass');
            console.log('[Gemini] Error message:', genkitResult.errorMessage);
          } else {
            // 토큰 사용량 로깅
            if (genkitResult.tokenUsage) {
              const usage = genkitResult.tokenUsage;
              const total = usage.totalTokenCount || usage.totalTokens || 
                           (usage.promptTokenCount || 0) + (usage.candidatesTokenCount || 0);
              console.log('[Gemini] Token usage summary:');
              console.log(`  - Total: ${total} tokens`);
            }
            // 정상적인 검증 결과 로깅
            const validationDocId = await logValidationResult({
              userId,
              content: { question, titleA, titleB, descriptionText },
              geminiResult: {
                isValid: genkitResult.isValid,
                severity: genkitResult.severity,
                reason: genkitResult.reason,
                suggestions: genkitResult.suggestions,
                confidence: genkitResult.confidence
              },
              tokenUsage: genkitResult.tokenUsage ? {
                promptTokenCount: genkitResult.tokenUsage.promptTokenCount || 0,
                candidatesTokenCount: genkitResult.tokenUsage.candidatesTokenCount || 0,
                totalTokenCount: genkitResult.tokenUsage.totalTokenCount || 0
              } : null,
              timestamp: admin.firestore.FieldValue.serverTimestamp()
            }, sessionId, documentId);
            
            // 문서 ID를 결과에 포함
            return {
              isValid: genkitResult.isValid !== false,
              reason: genkitResult.reason || '',
              severity: genkitResult.severity || 'pass',
              suggestions: genkitResult.suggestions || '',
              confidence: genkitResult.confidence || 0.5,
              documentId: validationDocId
            };
          }
          
          return {
            isValid: genkitResult.isValid !== false,
            reason: genkitResult.reason || '',
            severity: genkitResult.severity || 'pass',
            suggestions: genkitResult.suggestions || '',
            confidence: genkitResult.confidence || 0.5
          };
        }
      }
      
      // 기존 LangChain 구현 (fallback)
      console.log('[Gemini] LangChain 모드 사용');
      
      // 사용자 이력 가져오기
      const userHistory = await getUserPostingHistory(userId);
      
      // 프롬프트 구성
      const prompt = buildValidationPrompt({
        question,
        titleA,
        titleB,
        descriptionText,
        visionDataA,
        visionDataB,
        perspectiveData
      }, userHistory);
      
      // Gemini 모델 호출
      const response = await geminiModel.invoke(prompt);
      const text = response.content;
      
      console.log('[Gemini Response]:', text);
      
      // JSON 파싱
      let geminiResult;
      try {
        // JSON 부분만 추출 (```json ... ``` 사이)
        const jsonMatch = text.match(/```json\s*([\s\S]*?)\s*```/);
        if (jsonMatch) {
          geminiResult = JSON.parse(jsonMatch[1]);
        } else {
          // 직접 파싱 시도
          geminiResult = JSON.parse(text);
        }
      } catch (parseError) {
        console.error('[Gemini] JSON 파싱 실패:', parseError);
        // 파싱 실패 시 기본 통과
        geminiResult = {
          action: 'PROCEED',
          feedback: null,
          confidence: 0.5
        };
      }
      
      // 새로운 응답 형식 처리
      let finalResult;
      if (geminiResult.action) {
        // 새 형식
        const severityMap = {
          'PROCEED': 'pass',
          'PROCEED_WITH_SUGGESTION': 'warning',
          'BLOCK': 'error'
        };
        
        finalResult = {
          isValid: geminiResult.action !== 'BLOCK',
          reason: geminiResult.feedback?.title || '',
          severity: severityMap[geminiResult.action] || 'pass',
          suggestions: geminiResult.feedback?.description || '',
          confidence: geminiResult.confidence || 0.5
        };
      } else if (geminiResult.isValid !== undefined) {
        // 기존 형식 (하위 호환성)
        finalResult = {
          isValid: geminiResult.isValid !== false,
          reason: geminiResult.reason || '',
          severity: geminiResult.severity || 'pass',
          suggestions: geminiResult.suggestions || '',
          confidence: geminiResult.confidence || 0.5
        };
      }
      
      // 검증 결과 로깅
      const validationDocId = await logValidationResult({
        userId,
        content: { question, titleA, titleB, descriptionText },
        geminiResult: finalResult,
        timestamp: admin.firestore.FieldValue.serverTimestamp()
      }, sessionId, documentId);
      
      // 문서 ID를 결과에 포함
      return {
        ...finalResult,
        documentId: validationDocId
      };
      
    } catch (error) {
      console.error('[Gemini Validation] 오류:', error);
      console.error('[Gemini Validation] 오류 타입:', error.name);
      console.error('[Gemini Validation] 오류 메시지:', error.message);
      
      // 타임아웃 에러 특별 처리
      if (error.message && error.message.includes('DEADLINE_EXCEEDED')) {
        console.error('[Gemini Validation] ❌ AI 검증 타임아웃 - 기본 통과 처리');
        
        // 타임아웃 통계 기록
        try {
          await admin.firestore().collection('validation_errors').add({
            type: 'timeout',
            userId: userId,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            error: error.message,
            sessionId: sessionId
          });
        } catch (logError) {
          console.error('[Gemini Validation] 로그 기록 실패:', logError);
        }
      }
      
      // 모든 오류 시 통과 처리 (서비스 중단 방지)
      return {
        isValid: true,
        reason: '',
        severity: 'pass',
        suggestions: '',
        error: 'validation_failed',
        errorDetails: error.message
      };
    }
  });

// 사용자 포스팅 이력 조회
async function getUserPostingHistory(userId) {
  // TODO: Production 배포 전 Firestore 인덱스 생성 필요
  // 필요한 인덱스: content_validations 컬렉션
  // - userId (오름차순)
  // - geminiResult.isValid (오름차순)
  // - timestamp (내림차순)
  
  // 현재는 테스트를 위해 기본값 반환
  console.log('[getUserPostingHistory] 테스트 모드 - 기본값 반환');
  return {
    rejectedCount: 0,
    reportCount: 0,
    isNewUser: true
  };
  
  /* Production 코드 (인덱스 생성 후 주석 해제)
  try {
    const db = admin.firestore();
    
    // 최근 30일간의 거부된 포스트 수
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    
    const rejectedSnapshot = await db
      .collection('content_validations')
      .where('userId', '==', userId)
      .where('geminiResult.isValid', '==', false)
      .where('timestamp', '>=', thirtyDaysAgo)
      .get();
    
    // 신고된 포스트 수 (posts_record에서)
    const reportedSnapshot = await db
      .collection('posts_record')
      .where('user_ref', '==', db.doc(`users_record/${userId}`))
      .where('reported_count', '>', 0)
      .get();
    
    return {
      rejectedCount: rejectedSnapshot.size,
      reportCount: reportedSnapshot.size,
      isNewUser: rejectedSnapshot.size === 0 && reportedSnapshot.size === 0
    };
  } catch (error) {
    console.error('[getUserPostingHistory] 오류:', error);
    return {
      rejectedCount: 0,
      reportCount: 0,
      isNewUser: true
    };
  }
  */
}

// Gemini 프롬프트 구성
function buildValidationPrompt(data, userHistory) {
  const prompt = `
########################################################################
# Versus Space – 콘텐츠 검증 AI 통합 프롬프트 4.0
########################################################################

/*============================== 1) 역할(Persona) ==============================*/
당신은 'Versus Space' 커뮤니티의 재치 있고 현명한 커뮤니티-매니저 AI입니다.  
목표: (1) 유해 콘텐츠 차단  (2) 재미‧의미있는 비교 장려  (3) 친절한 코칭 제공

[제출된 내용]
질문: ${data.question || '없음'}
설명: ${data.descriptionText || '없음'}
A 옵션: ${data.titleA || '없음'}
B 옵션: ${data.titleB || '없음'}

[텍스트 유해성 검사 결과]
${data.perspectiveData ? `
- 독성: ${(data.perspectiveData.TOXICITY * 100).toFixed(1)}%
- 모욕: ${(data.perspectiveData.INSULT * 100).toFixed(1)}%
- 욕설: ${(data.perspectiveData.PROFANITY * 100).toFixed(1)}%
` : '검사 결과 없음'}

${data.visionDataA || data.visionDataB ? `
[이미지 분석 결과]` : ''}
${data.visionDataA ? `
A 이미지:
- 주요 라벨: ${data.visionDataA.labels?.slice(0, 5).map(l => l.description).join(', ') || '없음'}
- SafeSearch: 성인(${data.visionDataA.safeSearch?.adult}), 폭력(${data.visionDataA.safeSearch?.violence})
- 얼굴 감지: ${data.visionDataA.faces?.length > 0 ? '있음' : '없음'}` : ''}
${data.visionDataB ? `
B 이미지:
- 주요 라벨: ${data.visionDataB.labels?.slice(0, 5).map(l => l.description).join(', ') || '없음'}
- SafeSearch: 성인(${data.visionDataB.safeSearch?.adult}), 폭력(${data.visionDataB.safeSearch?.violence})
- 얼굴 감지: ${data.visionDataB.faces?.length > 0 ? '있음' : '없음'}` : ''}

[사용자 이력]
- 최근 거부된 포스트: ${userHistory.rejectedCount}개
- 신고 이력: ${userHistory.reportCount}개
- 신규 사용자: ${userHistory.isNewUser ? '예' : '아니오'}

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

● 얼굴·외모  
  - '일반인' 얼굴 평가·점수 ▶ BLOCK  
  - 본인 스타일 질문 또는 공인 공식 사진 비교 ▶ 허용  
  - 얼굴 노출 이미지 → Vision safeSearch 통과 필수  

● 이미지 일관성  
  - 이미지가 질문/옵션과 무관하면 BLOCK 또는 재촬영 권고  

/*===================== 7) 출력(JSON) – 반드시 준수 =====================*/
{
  "action": "PROCEED" | "PROCEED_WITH_SUGGESTION" | "BLOCK",
  "feedback": {
    "title": "짧고 핵심적인 한 줄",
    "description": "사용자에게 보여줄 상세 가이드"
  } | null,
  "confidence": 0.0-1.0
}`;

  return prompt;
}

// 검증 결과 로깅
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
      
      console.log(`[logValidationResult] Document updated: ${documentId}`);
    } else if (sessionId) {
      // 세션 ID 기반으로 문서 ID 생성
      finalDocId = `${data.userId}_${sessionId}`;
      await collection.doc(finalDocId).set({
        ...data,
        sessionId: sessionId,
        revisionCount: 1
      });
      
      console.log(`[logValidationResult] New document created with session: ${finalDocId}`);
    } else {
      // 기존 방식 (새 문서 생성)
      const docRef = await collection.add(data);
      finalDocId = docRef.id;
      console.log(`[logValidationResult] New document created (auto ID): ${finalDocId}`);
    }
    
    return finalDocId;
  } catch (error) {
    console.error('[logValidationResult] Logging failed:', error);
    // 로깅 실패는 무시 (서비스 중단 방지)
    return null;
  }
}

// ==================== 알림 시스템 ====================

/**
 * 새 투표 게시물이 생성될 때 타겟 사용자에게 알림 전송
 * 
 * 트리거: posts_record 컬렉션에 새 문서가 생성될 때
 * 기능:
 * 1. targetAudience 설정 확인
 * 2. 타겟 사용자 매칭
 * 3. 알림 생성 및 전송
 */
exports.onPostCreatedSendNotifications = functions
  .region('asia-northeast3')
  .firestore
  .document('posts_record/{postId}')
  .onCreate(async (snapshot, context) => {
    const postId = context.params.postId;
    const postData = snapshot.data();
    
    console.log('[onPostCreate] ========== 새 게시물 생성 감지 ==========');
    console.log(`[onPostCreate] 게시물 ID: ${postId}`);
    console.log(`[onPostCreate] 생성 시간: ${new Date().toISOString()}`);
    console.log(`[onPostCreate] 생성자 ID: ${postData.uid || postData.userid || '알 수 없음'}`);
    
    // targetAudience 전체 내용 로깅
    console.log('[onPostCreate] targetAudience 데이터:');
    console.log(JSON.stringify(postData.targetAudience, null, 2));
    
    try {
      // 1. targetAudience 확인
      if (!postData.targetAudience) {
        console.log('[onPostCreate] ❌ targetAudience 필드가 없음 - 알림 전송 안 함');
        console.log('[onPostCreate] 게시물 데이터 전체 필드:');
        console.log(Object.keys(postData).join(', '));
        return null;
      }
      
      const { type, targetCount = 100 } = postData.targetAudience;
      console.log(`[onPostCreate] 타겟 타입: ${type}, 목표 수: ${targetCount}`);
      
      // 지원하는 타겟 타입 확인 (quick, public, custom, test)
      if (!['quick', 'public', 'custom', 'test'].includes(type)) {
        console.log(`[알림 시스템] 지원하지 않는 타겟 타입: ${type}`);
        return null;
      }
      
      // test 타입 추가 보안 검증
      if (type === 'test') {
        const creatorId = postData.uid || postData.userid || postData.creatorInfo?.uid;
        if (creatorId) {
          const creatorDoc = await admin.firestore()
            .collection('users_record')
            .doc(creatorId)
            .get();
          
          if (creatorDoc.exists) {
            const creatorData = creatorDoc.data();
            if (creatorData.role !== 'admin' && creatorData.role !== 'tester') {
              console.error('[알림 시스템] 테스트 모드 권한 없음 - 일반 사용자는 사용 불가');
              return null;
            }
          }
        }
        console.log('[알림 시스템] 테스트 모드 검증 통과');
      }
      
      console.log(`[알림 시스템] 타겟 설정: ${type}, 목표 수: ${targetCount}`);
      
      // 2. 타겟 사용자 매칭 (postData 전달하여 AI 분석 가능)
      const matchedUsers = await matchTargetUsers(postData.targetAudience, postData);
      
      if (matchedUsers.length === 0) {
        console.log('[알림 시스템] 매칭된 사용자 없음');
        await snapshot.ref.update({
          'targetAudience.status': 'no_matches',
          'targetAudience.processedAt': admin.firestore.FieldValue.serverTimestamp()
        });
        return null;
      }
      
      console.log(`[알림 시스템] ${matchedUsers.length}명의 사용자 매칭됨`);
      
      // 3. 알림 생성
      await createNotificationsForUsers(matchedUsers, postId, postData);
      
      // 4. 게시물 상태 업데이트
      await snapshot.ref.update({
        'targetAudience.status': 'notifications_sent',
        'targetAudience.matchedCount': matchedUsers.length,
        'targetAudience.processedAt': admin.firestore.FieldValue.serverTimestamp()
      });
      
      console.log('[onPostCreate] ========== 알림 전송 프로세스 완료 ==========');
      console.log(`[onPostCreate] 게시물 ID: ${postId}`);
      console.log(`[onPostCreate] 매칭된 사용자 수: ${matchedUsers.length}`);
      console.log(`[onPostCreate] 완료 시간: ${new Date().toISOString()}`);
      
    } catch (error) {
      console.error('[onPostCreate] ❌❌❌ 오류 발생 ❌❌❌');
      console.error('[onPostCreate] 오류 타입:', error.name);
      console.error('[onPostCreate] 오류 메시지:', error.message);
      console.error('[onPostCreate] 스택 트레이스:', error.stack);
      
      // 오류 상태 기록
      try {
        await snapshot.ref.update({
          'targetAudience.status': 'error',
          'targetAudience.error': error.message,
          'targetAudience.processedAt': admin.firestore.FieldValue.serverTimestamp()
        });
      } catch (updateError) {
        console.error('[onPostCreate] 오류 상태 업데이트 실패:', updateError);
      }
      
      throw error; // 재시도를 위해 오류 다시 던지기
    }
  });

// 투표 발생 시 투표 추적 채팅방 업데이트 (스로틀링 적용)
exports.onPostVoteUpdate = functions
  .region('asia-northeast3')
  .runWith({
    memory: '512MB',
    timeoutSeconds: 60
  })
  .firestore
  .document('posts_record/{postId}')
  .onUpdate(async (change, context) => {
    const postId = context.params.postId;
    const beforeData = change.before.data();
    const afterData = change.after.data();
    
    // 투표 수 변경 확인
    const beforeVotesA = beforeData.votes_a || beforeData.vote_count_a || 0;
    const beforeVotesB = beforeData.votes_b || beforeData.vote_count_b || 0;
    const afterVotesA = afterData.votes_a || afterData.vote_count_a || 0;
    const afterVotesB = afterData.votes_b || afterData.vote_count_b || 0;
    
    const totalBeforeVotes = beforeVotesA + beforeVotesB;
    const totalAfterVotes = afterVotesA + afterVotesB;
    
    // 투표가 발생했는지 확인
    if (totalAfterVotes <= totalBeforeVotes) {
      return null; // 투표 증가가 없으면 무시
    }
    
    console.log(`[투표 업데이트] 게시물 ${postId}에 새로운 투표 발생`);
    console.log(`[투표 업데이트] A: ${beforeVotesA} → ${afterVotesA}, B: ${beforeVotesB} → ${afterVotesB}`);
    
    try {
      // 글로벌 투표 추적 채팅방 찾기
      const voteChatId = 'vote_tracking_global';
      const voteChatRef = admin.firestore()
        .collection('chats_record')
        .doc(voteChatId);
      
      const voteChatDoc = await voteChatRef.get();
      if (!voteChatDoc.exists) {
        console.log(`[투표 업데이트] 글로벌 투표 추적 채팅방이 없음: ${voteChatId}`);
        return null;
      }
      
      // 누가 어디에 투표했는지 확인
      let voteInfo = '';
      if (afterVotesA > beforeVotesA) {
        voteInfo = `A(${afterData.option_a || 'A'})에 투표`;
      } else if (afterVotesB > beforeVotesB) {
        voteInfo = `B(${afterData.option_b || 'B'})에 투표`;
      }
      
      // 현재 투표 상황 계산
      const totalVotes = afterVotesA + afterVotesB;
      const percentA = totalVotes > 0 ? Math.round((afterVotesA / totalVotes) * 100) : 0;
      const percentB = totalVotes > 0 ? Math.round((afterVotesB / totalVotes) * 100) : 0;
      
      // 투표한 사용자 정보 가져오기 (작성자 정보 포함)
      const creatorId = afterData.uid || afterData.userid || afterData.user_ref?.id;
      let creatorName = '알 수 없음';
      
      if (creatorId) {
        try {
          const creatorDoc = await admin.firestore()
            .collection('users_record')
            .doc(creatorId)
            .get();
          
          if (creatorDoc.exists) {
            creatorName = creatorDoc.data().display_name || '익명';
          }
        } catch (error) {
          console.log(`[투표 업데이트] 작성자 정보 가져오기 실패: ${error.message}`);
        }
      }
      
      // 스로틀링을 통한 효율적인 업데이트
      // 실시간 업데이트를 큐에 추가 (즉시 처리하지 않고 배치로 처리)
      const progressContent = `${creatorName}님의 투표에 참여했습니다! ${voteInfo}\\n\\n` +
                            `"${afterData.question_title || '제목 없음'}"\\n\\n` +
                            `현재 투표 현황:\\n` +
                            `A: ${afterVotesA}표 (${percentA}%)\\n` +
                            `B: ${afterVotesB}표 (${percentB}%)\\n` +
                            `총 ${totalVotes}표`;
      
      // 진행 상황 업데이트를 스로틀 큐에 추가
      queueProgressUpdate(postId, progressContent);
      
      // 채팅방 마지막 메시지는 즉시 업데이트 (사용자 경험을 위해)
      await voteChatRef.update({
        last_message_content: `새로운 투표! 현재 A:${afterVotesA} vs B:${afterVotesB}`,
        last_message_at: admin.firestore.FieldValue.serverTimestamp(),
      });
      
      console.log(`[투표 업데이트] ✅ 투표 진행 상황 큐에 추가됨`);
      
      // 투표 완료 확인 (목표 투표 수 도달 또는 타겟 수 도달)
      const targetAudience = afterData.targetAudience || {};
      const targetCount = targetAudience.targetCount || afterData.target_votes || 10; // 기본 목표 10표
      const matchedCount = targetAudience.matchedCount || 0;
      
      // 완료 조건: 1) 목표 투표 수 도달 또는 2) 타겟 사용자 수만큼 투표
      const isVoteComplete = totalVotes >= targetCount || 
                            (matchedCount > 0 && totalVotes >= matchedCount);
      
      if (isVoteComplete && !afterData.vote_completed) {
        console.log(`[투표 완료] 투표 완료 감지! 총 ${totalVotes}표 / 목표 ${targetCount}표`);
        
        // 1. 게시물 상태 업데이트
        await change.after.ref.update({
          vote_completed: true,
          vote_completed_at: admin.firestore.FieldValue.serverTimestamp(),
          vote_status: 'completed'
        });
        
        // 2. 모든 참여자 상태 업데이트 (processing → result_arrived)
        await processVoteCompletion(postId, {
          votesA: afterVotesA,
          votesB: afterVotesB,
          totalVotes,
          percentA,
          percentB,
          winner: afterVotesA > afterVotesB ? 'A' : afterVotesB > afterVotesA ? 'B' : 'draw',
          questionTitle: afterData.question_title || afterData.questionTitle,
          optionA: afterData.option_a || afterData.optionA?.title || 'A',
          optionB: afterData.option_b || afterData.optionB?.title || 'B',
          creatorId,
          creatorName
        });
        
        // 3. 완료 메시지 추가
        const completionMessage = {
          message_id: `${Date.now()}_vote_complete`,
          sender_id: 'system',
          content: `🎉 투표가 완료되었습니다!\\n\\n` +
                   `최종 결과:\\n` +
                   `A(${afterData.option_a || afterData.optionA?.title || 'A'}): ${afterVotesA}표 (${percentA}%)\\n` +
                   `B(${afterData.option_b || afterData.optionB?.title || 'B'}): ${afterVotesB}표 (${percentB}%)\\n\\n` +
                   `승자: ${afterVotesA > afterVotesB ? 'A' : afterVotesB > afterVotesA ? 'B' : '무승부'}!`,
          time_stamp: admin.firestore.FieldValue.serverTimestamp(),
          message_type: 'vote_completion',
          vote_post_id: postId,
          final_votes_a: afterVotesA,
          final_votes_b: afterVotesB,
          winner: afterVotesA > afterVotesB ? 'A' : afterVotesB > afterVotesA ? 'B' : 'draw',
        };
        
        await voteChatRef.collection('messages').add(completionMessage);
        console.log(`[투표 완료] 🎉 투표 완료 처리 완료`);
      }
      
    } catch (error) {
      console.error('[투표 업데이트] ❌ 오류 발생:', error);
    }
  });

// 투표 완료 시 모든 참여자 상태 업데이트 및 결과 알림 생성 (최적화된 버전)
async function processVoteCompletion(postId, voteResults) {
  console.log(`[processVoteCompletion] ========== 투표 완료 처리 시작 (최적화 버전) ==========`);
  console.log(`[processVoteCompletion] 게시물 ID: ${postId}`);
  console.log(`[processVoteCompletion] 최종 결과: A=${voteResults.votesA}표, B=${voteResults.votesB}표`);
  
  const db = admin.firestore();
  const startTime = Date.now();
  
  try {
    // 1. 병렬로 데이터 조회
    const [messagesSnapshot, notificationsSnapshot, processingMessagesSnapshot] = await Promise.all([
      // 관련 메시지 조회
      db.collection('chats_record')
        .doc('vote_tracking_global')
        .collection('messages')
        .where('vote_post_id', '==', postId)
        .where('message_type', 'in', ['vote_request', 'vote_created'])
        .get(),
      
      // 알림 문서 조회
      db.collection('notifications_record')
        .where('sourceId', '==', postId)
        .where('type', '==', 'vote_request')
        .get(),
      
      // 진행중 메시지 조회
      db.collection('chats_record')
        .doc('vote_tracking_global')
        .collection('messages')
        .where('vote_post_id', '==', postId)
        .where('message_type', '==', 'vote_progress_update')
        .get()
    ]);
    
    console.log(`[processVoteCompletion] 데이터 조회 완료 (${Date.now() - startTime}ms)`);
    console.log(`[processVoteCompletion] - 관련 메시지: ${messagesSnapshot.size}개`);
    console.log(`[processVoteCompletion] - 관련 알림: ${notificationsSnapshot.size}개`);
    console.log(`[processVoteCompletion] - 진행중 메시지: ${processingMessagesSnapshot.size}개`);
    
    // 2. 참여자 목록 수집
    const participantIds = new Set();
    notificationsSnapshot.forEach(doc => {
      const userId = doc.data().userId;
      if (userId) participantIds.add(userId);
    });
    
    // 3. 배치 처리를 위한 작업 목록 생성
    const batchOperations = [];
    
    // 메시지 상태 업데이트 작업
    messagesSnapshot.forEach(doc => {
      const messageData = doc.data();
      batchOperations.push({
        type: 'update',
        ref: doc.ref,
        data: messageData.message_type === 'vote_created' 
          ? { vote_global_status: 'completed' }
          : { vote_user_status: 'result_arrived' }
      });
    });
    
    // 알림 상태 업데이트 작업
    notificationsSnapshot.forEach(doc => {
      batchOperations.push({
        type: 'update',
        ref: doc.ref,
        data: {
          status: 'completed',
          completedAt: admin.firestore.FieldValue.serverTimestamp()
        }
      });
    });
    
    // 결과 알림 생성 작업
    const resultNotificationData = {
      type: 'vote_result',
      sourceId: postId,
      sourceType: 'post',
      title: '투표 결과가 도착했습니다!',
      message: `"${voteResults.questionTitle}" 투표가 완료되었습니다. 결과를 확인해보세요!`,
      imageUrl: null,
      actionUrl: `/posts/${postId}`,
      read: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      priority: 'high',
      content: JSON.stringify({
        postData: {
          postId,
          questionTitle: voteResults.questionTitle,
          optionA: voteResults.optionA,
          optionB: voteResults.optionB,
          votesA: voteResults.votesA,
          votesB: voteResults.votesB,
          percentA: voteResults.percentA,
          percentB: voteResults.percentB,
          winner: voteResults.winner,
          totalVotes: voteResults.totalVotes
        }
      })
    };
    
    // 각 참여자에게 결과 알림 생성
    for (const userId of participantIds) {
      const notificationRef = db.collection('notifications_record').doc();
      batchOperations.push({
        type: 'set',
        ref: notificationRef,
        data: { ...resultNotificationData, userId }
      });
    }
    
    // 생성자에게도 결과 알림
    if (voteResults.creatorId && !participantIds.has(voteResults.creatorId)) {
      const creatorNotificationRef = db.collection('notifications_record').doc();
      batchOperations.push({
        type: 'set',
        ref: creatorNotificationRef,
        data: {
          ...resultNotificationData,
          userId: voteResults.creatorId,
          title: '내 투표가 완료되었습니다!',
          message: `"${voteResults.questionTitle}" 투표가 완료되었습니다. 총 ${voteResults.totalVotes}명이 참여했습니다!`
        }
      });
    }
    
    // 4. 배치 처리 실행 (500개씩 나눠서 처리)
    const batchResults = await require('./utils/batch-processor').processBatch(
      batchOperations,
      (batch, operation) => {
        if (operation.type === 'update') {
          batch.update(operation.ref, operation.data);
        } else if (operation.type === 'set') {
          batch.set(operation.ref, operation.data);
        }
      },
      500 // Firestore 배치 제한
    );
    
    // 5. 진행중 메시지 삭제 (병렬 처리)
    const deleteResults = await require('./utils/batch-processor').processParallelBatch(
      processingMessagesSnapshot.docs,
      async (doc) => doc.ref.delete(),
      50 // 동시에 50개씩 삭제
    );
    
    const totalTime = Date.now() - startTime;
    
    console.log(`[processVoteCompletion] ✅ 투표 완료 처리 성공 (총 ${totalTime}ms)`);
    console.log(`[processVoteCompletion] - 배치 처리 결과:`, batchResults);
    console.log(`[processVoteCompletion] - 삭제 성공: ${deleteResults.filter(r => r.status === 'fulfilled').length}개`);
    console.log(`[processVoteCompletion] - 총 작업 수: ${batchOperations.length + processingMessagesSnapshot.size}개`);
    
    // 성능이 느린 경우 경고
    if (totalTime > 5000) {
      console.warn(`[processVoteCompletion] ⚠️ 처리 시간이 5초를 초과했습니다: ${totalTime}ms`);
    }
    
  } catch (error) {
    console.error('[processVoteCompletion] ❌ 오류 발생:', error);
    throw error;
  }
}

// 예약된 함수: 스로틀 큐 플러시 (1분마다)
exports.flushThrottleQueue = functions
  .region('asia-northeast3')
  .pubsub.schedule('every 1 minutes')
  .onRun(async (context) => {
    console.log('[flushThrottleQueue] 스로틀 큐 플러시 시작');
    
    try {
      const throttle = getThrottle();
      await throttle.flushAll();
      console.log('[flushThrottleQueue] ✅ 스로틀 큐 플러시 완료');
    } catch (error) {
      console.error('[flushThrottleQueue] ❌ 플러시 실패:', error);
    }
    
    return null;
  });

// 예약된 함수: 24시간 후 자동 투표 종료
exports.checkVoteTimeouts = functions
  .region('asia-northeast3')
  .pubsub.schedule('every 1 hours')
  .onRun(async (context) => {
    console.log('[checkVoteTimeouts] ========== 투표 타임아웃 확인 시작 ==========');
    
    const db = admin.firestore();
    const now = Date.now();
    const twentyFourHoursAgo = new Date(now - 24 * 60 * 60 * 1000);
    
    try {
      // 24시간이 지났고 아직 완료되지 않은 투표 찾기
      const expiredVotesSnapshot = await db
        .collection('posts_record')
        .where('vote_completed', '!=', true)
        .where('created_at', '<', twentyFourHoursAgo)
        .where('targetAudience.type', 'in', ['quick', 'public', 'custom', 'test'])
        .limit(50) // 배치 처리를 위해 제한
        .get();
      
      console.log(`[checkVoteTimeouts] 만료된 투표 ${expiredVotesSnapshot.size}개 발견`);
      
      // 각 만료된 투표 처리
      const updatePromises = expiredVotesSnapshot.docs.map(async (doc) => {
        const postData = doc.data();
        const postId = doc.id;
        
        const votesA = postData.votes_a || postData.vote_count_a || 0;
        const votesB = postData.votes_b || postData.vote_count_b || 0;
        const totalVotes = votesA + votesB;
        
        // 최소 1표라도 있는 경우만 완료 처리
        if (totalVotes > 0) {
          const percentA = Math.round((votesA / totalVotes) * 100);
          const percentB = Math.round((votesB / totalVotes) * 100);
          
          // 게시물 상태 업데이트
          await doc.ref.update({
            vote_completed: true,
            vote_completed_at: admin.firestore.FieldValue.serverTimestamp(),
            vote_status: 'completed',
            vote_timeout: true
          });
          
          // 투표 완료 처리
          await processVoteCompletion(postId, {
            votesA,
            votesB,
            totalVotes,
            percentA,
            percentB,
            winner: votesA > votesB ? 'A' : votesB > votesA ? 'B' : 'draw',
            questionTitle: postData.question_title || postData.questionTitle,
            optionA: postData.option_a || postData.optionA?.title || 'A',
            optionB: postData.option_b || postData.optionB?.title || 'B',
            creatorId: postData.uid || postData.userid,
            creatorName: '시스템'
          });
          
          console.log(`[checkVoteTimeouts] 투표 ${postId} 타임아웃으로 완료 처리됨`);
        } else {
          // 투표가 전혀 없는 경우는 취소 처리
          await doc.ref.update({
            vote_completed: true,
            vote_status: 'cancelled',
            vote_cancelled_at: admin.firestore.FieldValue.serverTimestamp(),
            vote_cancelled_reason: 'no_votes_timeout'
          });
          
          console.log(`[checkVoteTimeouts] 투표 ${postId} 참여자 없음으로 취소됨`);
        }
      });
      
      await Promise.all(updatePromises);
      
      console.log(`[checkVoteTimeouts] ✅ 타임아웃 확인 완료`);
      
    } catch (error) {
      console.error('[checkVoteTimeouts] ❌ 오류 발생:', error);
    }
  });
