const functions = require("firebase-functions");
const admin = require("firebase-admin");
const vision = require("@google-cloud/vision");
const sharp = require("sharp");

admin.initializeApp();

// Vision API 클라이언트 초기화
const visionClient = new vision.ImageAnnotatorClient();

exports.onUserDeleted = functions
  .region("asia-northeast3")
  .auth.user()
  .onDelete(async (user) => {
    let firestore = admin.firestore();
    let userRef = firestore.doc("users/" + user.uid);
    await firestore.collection("users").doc(user.uid).delete();
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
    if (filePath.includes("_blur") || filePath.includes("_thumb")) {
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
        console.log("Inappropriate content detected, applying blur.");
        
        // 이미지에 블러 처리
        const blurredBuffer = await sharp(imageBuffer)
          .blur(20)
          .toBuffer();
        
        // 블러 처리된 이미지를 새 경로에 저장
        const blurredPath = filePath.replace(/(\.[^.]+)$/, "_blur$1");
        const blurredFile = bucket.file(blurredPath);
        
        await blurredFile.save(blurredBuffer, {
          metadata: {
            contentType: contentType,
            originalPath: filePath,
            blurred: "true"
          }
        });
        
        // 원본 이미지 삭제 (옵션)
        // await file.delete();
        
        moderationData.moderationStatus = "rejected";
        moderationData.blurredUrl = `gs://${object.bucket}/${blurredPath}`;
        moderationData.action = "blurred";
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
