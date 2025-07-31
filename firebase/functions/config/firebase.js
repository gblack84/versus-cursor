/**
 * Firebase 초기화 설정
 * Firebase Admin SDK 초기화 및 공통 설정
 */

const admin = require("firebase-admin");

// Firebase Admin 초기화 (한 번만 실행)
if (!admin.apps.length) {
  admin.initializeApp();
}

// Firestore 설정
const db = admin.firestore();

// Storage 설정  
const storage = admin.storage();

module.exports = {
  admin,
  db,
  storage
};