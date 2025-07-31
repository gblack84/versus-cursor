/**
 * 이미지 검열 서비스
 * Google Cloud Vision API를 사용한 이미지 안전성 검사
 */

const vision = require("@google-cloud/vision");
const admin = require("firebase-admin");
const { checkTextWithPerspective } = require("./textModeration");

// Vision API 클라이언트 초기화
const visionClient = new vision.ImageAnnotatorClient();

/**
 * 이미지 콘텐츠 검사 (SafeSearch + OCR)
 * @param {string} imageContent - Base64 인코딩된 이미지 데이터
 * @returns {Object} 검사 결과
 */
async function checkImageContent(imageContent) {
  try {
    console.log('[이미지 검열] 이미지 검사 시작');
    
    // Vision API로 SafeSearch 검출
    const [result] = await visionClient.safeSearchDetection({
      image: { content: imageContent }
    });
    
    const detections = result.safeSearchAnnotation;
    console.log('[이미지 검열] SafeSearch 결과:', detections);
    
    // OCR로 텍스트 추출
    let textDetected = '';
    let isTextInappropriate = false;
    let textReason = '';
    
    try {
      const [textResult] = await visionClient.textDetection({
        image: { content: imageContent },
        imageContext: {
          languageHints: ['ko', 'en']  // 한국어와 영어 힌트 추가
        }
      });
      
      if (textResult.textAnnotations && textResult.textAnnotations.length > 0) {
        textDetected = textResult.textAnnotations[0].description || '';
        console.log(`[이미지 검열] 추출된 텍스트 (${textDetected.length}자): ${textDetected.substring(0, 100)}...`);
        
        // 텍스트가 있으면 Perspective API로 검열
        const textCheckResult = await checkTextWithPerspective(textDetected);
        isTextInappropriate = textCheckResult.isInappropriate;
        textReason = textCheckResult.reason;
        
        if (isTextInappropriate) {
          console.log(`[이미지 검열] 부적절한 텍스트 감지: ${textReason}`);
        }
      } else {
        console.log('[이미지 검열] 텍스트가 감지되지 않음');
      }
    } catch (ocrError) {
      console.error('[이미지 검열] OCR 처리 중 오류:', ocrError);
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
    
    return {
      isAppropriate: !isInappropriate,
      reason: reason,
      hasText: textDetected.length > 0,
      detections: detections,
      textDetected: textDetected
    };
    
  } catch (error) {
    console.error('[이미지 검열] 이미지 검열 중 오류:', error);
    throw error;
  }
}

/**
 * Storage 이미지 파일 검열 및 메타데이터 저장
 * @param {Object} object - Storage 객체
 * @returns {Object} 검열 결과
 */
async function moderateStorageImage(object) {
  const filePath = object.name;
  const contentType = object.contentType;
  const bucket = admin.storage().bucket(object.bucket);
  
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
    
    console.log('[이미지 검열] SafeSearch results:', detections);
    
    // 메타데이터에서 정보 추출
    const metadata = object.metadata || {};
    const userId = metadata.uploadedBy || "unknown";
    const sessionId = metadata.sessionId || "default";
    const box = metadata.box || "unknown";
    
    // 세션 기반 모더레이션 ID 생성
    const moderationId = `${userId}_${sessionId}_${box}`;
    console.log(`[이미지 검열] Moderation ID: ${moderationId} for file: ${filePath}`);
    
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
      // Vision API 데이터
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
      console.log('[이미지 검열] 부적절한 콘텐츠 감지, 이미지 삭제 중...');
      
      moderationData.moderationStatus = "rejected";
      moderationData.action = "deleted";
      
      // Firestore에 먼저 기록
      await admin.firestore()
        .collection("image_moderation")
        .doc(moderationId)
        .set(moderationData, { merge: true });
      
      // 모든 버전의 이미지 삭제
      await deleteAllImageVersions(bucket, filePath);
      
      return { ...moderationData, deleted: true };
    } else {
      moderationData.moderationStatus = "approved";
    }
    
    // Firestore에 검열 결과 저장
    await admin.firestore()
      .collection("image_moderation")
      .doc(moderationId)
      .set(moderationData, { merge: true });
    
    console.log(`[이미지 검열] 이미지 검열 완료: ${filePath}`);
    return moderationData;
    
  } catch (error) {
    console.error('[이미지 검열] 오류 발생:', error);
    
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
    
    throw error;
  }
}

/**
 * 모든 버전의 이미지 삭제
 * @param {Object} bucket - Storage 버킷
 * @param {string} filePath - 원본 파일 경로
 */
async function deleteAllImageVersions(bucket, filePath) {
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
            console.log(`[이미지 검열] 삭제됨: ${versionPath}`);
          } catch (deleteError) {
            // 파일이 없는 경우는 무시
            if (!deleteError.message.includes('No such object')) {
              console.error(`[이미지 검열] 삭제 실패 ${versionPath}:`, deleteError.message);
            }
          }
        }
      }
    }
    
    console.log(`[이미지 검열] 모든 버전의 부적절한 이미지 삭제됨: ${filePath}`);
  } catch (deleteError) {
    console.error('[이미지 검열] 이미지 삭제 중 오류:', deleteError);
    throw deleteError;
  }
}

module.exports = {
  checkImageContent,
  moderateStorageImage,
  deleteAllImageVersions
};