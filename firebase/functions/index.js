const functions = require("firebase-functions");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");
const axios = require("axios");

admin.initializeApp();

// Vision API 클라이언트 초기화
const visionClient = new vision.ImageAnnotatorClient();

// Perspective API 설정
const PERSPECTIVE_API_KEY = process.env.PERSPECTIVE_API_KEY || functions.config().perspective?.api_key;
const PERSPECTIVE_API_URL = 'https://commentanalyzer.googleapis.com/v1alpha1/comments:analyze';

// Perspective API로 텍스트 검열
async function checkTextWithPerspective(text) {
  if (!PERSPECTIVE_API_KEY || !text || text.trim().length < 3) {
    return { isInappropriate: false, reason: '' };
  }

  try {
    const response = await axios.post(
      `${PERSPECTIVE_API_URL}?key=${PERSPECTIVE_API_KEY}`,
      {
        comment: { text: text },
        requestedAttributes: {
          TOXICITY: {},
          SEVERE_TOXICITY: {},
          IDENTITY_ATTACK: {},
          INSULT: {},
          PROFANITY: {},
          THREAT: {},
          SEXUALLY_EXPLICIT: {}
        },
        languages: ['ko', 'en']
      }
    );

    const scores = response.data.attributeScores;
    
    // 점수 임계값 설정
    const thresholds = {
      SEVERE_TOXICITY: 0.5,
      TOXICITY: 0.7,
      IDENTITY_ATTACK: 0.7,
      INSULT: 0.7,
      PROFANITY: 0.7,
      THREAT: 0.7,
      SEXUALLY_EXPLICIT: 0.7
    };

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
    console.error('Perspective API 오류:', error);
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
      console.log(`이미지 검열 시작 - 사용자: ${context.auth.uid}, 박스: ${box || 'unknown'}`);
      
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
          image: { content: image }
        });
        
        if (textResult.textAnnotations && textResult.textAnnotations.length > 0) {
          textDetected = textResult.textAnnotations[0].description || '';
          console.log(`추출된 텍스트 (${textDetected.length}자): ${textDetected.substring(0, 100)}...`);
          
          // 텍스트가 있으면 Perspective API로 검열
          const textCheckResult = await checkTextWithPerspective(textDetected);
          isTextInappropriate = textCheckResult.isInappropriate;
          textReason = textCheckResult.reason;
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
        console.log(`부적절한 콘텐츠 감지 - 사용자: ${context.auth.uid}, 이유: ${reason}`);
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
      
      // Vision API로 SafeSearch 검출
      const [result] = await visionClient.safeSearchDetection({
        image: { content: imageBuffer.toString("base64") }
      });
      
      const detections = result.safeSearchAnnotation;
      console.log("SafeSearch results:", detections);
      
      // 검열 결과를 Firestore에 저장
      const moderationId = filePath.replace(/[/.]/g, "_");
      const moderationData = {
        imageUrl: `gs://${object.bucket}/${filePath}`,
        downloadUrl: object.mediaLink || "",
        filePath: filePath,
        userId: object.metadata?.uploadedBy || "unknown",
        moderationStatus: "pending",
        safeSearchResults: {
          adult: detections.adult || "UNKNOWN",
          spoof: detections.spoof || "UNKNOWN",
          medical: detections.medical || "UNKNOWN",
          violence: detections.violence || "UNKNOWN",
          racy: detections.racy || "UNKNOWN"
        },
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
        
        // Firestore에 먼저 기록
        await admin.firestore()
          .collection("image_moderation")
          .doc(moderationId)
          .set(moderationData);
        
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
      
      // Firestore에 검열 결과 저장
      await admin.firestore()
        .collection("image_moderation")
        .doc(moderationId)
        .set(moderationData);
      
      console.log(`Image moderation completed for ${filePath}`);
      return null;
      
    } catch (error) {
      console.error("Error moderating image:", error);
      
      // 에러 발생 시에도 기록 남기기
      const moderationId = filePath.replace(/[/.]/g, "_");
      await admin.firestore()
        .collection("image_moderation")
        .doc(moderationId)
        .set({
          imageUrl: `gs://${object.bucket}/${filePath}`,
          filePath: filePath,
          moderationStatus: "error",
          error: error.message,
          moderatedAt: admin.firestore.FieldValue.serverTimestamp()
        });
      
      return null;
    }
  });
