// Firebase Functions 테스트 설정

const test = require('firebase-functions-test')({
  projectId: 'versus-space-1lwwiw',
}, '../service-account-key.json'); // 서비스 계정 키 경로

// 환경 변수 설정
process.env.GCLOUD_PROJECT = 'versus-space-1lwwiw';
process.env.FIRESTORE_EMULATOR_HOST = 'localhost:8080';
process.env.FIREBASE_AUTH_EMULATOR_HOST = 'localhost:9099';

// Firebase Functions 모킹
const myFunctions = require('../index');

module.exports = {
  test,
  myFunctions,
  
  // 테스트 헬퍼 함수들
  makeDocumentSnapshot: test.firestore.makeDocumentSnapshot,
  
  // 테스트 후 정리
  cleanup: () => {
    test.cleanup();
  }
};