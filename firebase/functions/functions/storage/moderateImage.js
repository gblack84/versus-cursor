/**
 * Storage에 업로드된 이미지 자동 검열
 * 트리거: Storage 파일 업로드 완료
 */

const functions = require("firebase-functions");
const { moderateStorageImage } = require("../../services/imageModeration");

exports.moderateImage = functions
  .region("asia-northeast3")
  .storage.object()
  .onFinalize(async (object) => {
    const filePath = object.name;
    const contentType = object.contentType;
    
    // 이미지 파일이 아니면 무시
    if (!contentType || !contentType.startsWith("image/")) {
      console.log("[이미지 검열] 이미지 파일이 아니므로 검열 생략");
      return null;
    }
    
    // 썸네일이나 블러 처리된 이미지는 무시 (무한 루프 방지)
    if (filePath.includes("_blur") || filePath.includes("_thumb") || filePath.includes("_display")) {
      console.log("[이미지 검열] 이미 처리된 이미지이므로 검열 생략");
      return null;
    }
    
    try {
      console.log(`[이미지 검열] 이미지 검열 시작: ${filePath}`);
      
      // 이미지 검열 서비스 호출
      const result = await moderateStorageImage(object);
      
      if (result.deleted) {
        console.log(`[이미지 검열] 부적절한 이미지 삭제됨: ${filePath}`);
      } else {
        console.log(`[이미지 검열] 이미지 검열 완료: ${filePath}`);
      }
      
      return result;
      
    } catch (error) {
      console.error('[이미지 검열] 오류 발생:', error);
      return null;
    }
  });