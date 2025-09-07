# 하드코딩된 비밀 정보 감사 보고서
# Hardcoded Secrets Audit Report

> 생성일: 2025-01-07
> 상태: 🔴 CRITICAL - 즉시 조치 필요

## 📊 요약 / Summary

- **발견된 API 키**: 2개
- **노출된 프로젝트 ID**: 7개 위치
- **위험 수준**: 🔴 매우 높음 (Git 히스토리에 노출됨)

## 🔍 발견된 비밀 정보 / Found Secrets

### 1. Firebase API Keys

#### 1.1 Firebase Config API Key
- **파일**: `/lib/backend/firebase/config/firebase_config.dart`
- **키**: `AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY`
- **용도**: Firebase 초기화
- **위험도**: 🔴 CRITICAL
- **조치**: 환경 변수로 이동 필요

#### 1.2 Perspective API Key
- **파일**: `/lib/services/moderation/perspective_api_service.dart`
- **키**: `AIzaSyAq1pADTpUpThb1lFKL1Ilrenr8X4IlP_E`
- **용도**: 콘텐츠 검열 API
- **위험도**: 🔴 CRITICAL
- **조치**: 환경 변수로 이동 필요

### 2. Project IDs and Storage URLs

#### 2.1 Firebase Project ID
- **프로젝트 ID**: `versus-space-1lwwiw`
- **발견 위치**:
  1. `/lib/backend/firebase/config/firebase_config.dart`
     - authDomain: "versus-space-1lwwiw.firebaseapp.com"
     - projectId: "versus-space-1lwwiw"
     - storageBucket: "versus-space-1lwwiw.appspot.com"
  
  2. `/lib/features/posts/data/services/storage/storage_service.dart`
     - 주석에 프로젝트 ID 포함 (낮은 위험)
  
  3. `/lib/features/auth/presentation/screens/phone_auth/phonelogeinpincode_widget.dart`
     - 하드코딩된 스토리지 URL (기본 이미지)
  
  4. `/lib/features/auth/presentation/screens/email_verification/popup_timer_email/popup_timer_email_widget.dart`
     - 하드코딩된 스토리지 URL (기본 이미지)
  
  5. `/lib/features/profile/presentation/screens/user_info_input/user_info_input_widget.dart`
     - 하드코딩된 스토리지 URL (기본 이미지)

#### 2.2 하드코딩된 Storage URLs
- **기본 캐릭터 이미지 URL**: 
  ```
  https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec
  ```
- **위험도**: 🟡 MEDIUM (공개 URL이지만 프로젝트 구조 노출)
- **조치**: 상수 파일로 이동 권장

## 📋 조치 계획 / Action Plan

### Phase 0 - 즉시 조치 (Day 1)
1. ✅ 백업 완료: `firebase_config.dart.backup_20250107`
2. 🔄 진행 중: 환경 변수 설정
3. ⏳ 대기: Git 히스토리 정리

### 필요한 환경 변수
```env
# Firebase
FIREBASE_API_KEY=AIzaSyDQTChIlq8kj9PKn7LZJsmDxmW5HTvh0BY
FIREBASE_PROJECT_ID=versus-space-1lwwiw
FIREBASE_AUTH_DOMAIN=versus-space-1lwwiw.firebaseapp.com
FIREBASE_STORAGE_BUCKET=versus-space-1lwwiw.appspot.com

# APIs
PERSPECTIVE_API_KEY=AIzaSyAq1pADTpUpThb1lFKL1Ilrenr8X4IlP_E

# Default Assets
DEFAULT_CHARACTER_IMAGE_URL=https://firebasestorage.googleapis.com/v0/b/versus-space-1lwwiw.appspot.com/o/characters%2Fdefault%2Fdefaultimage.jpg?alt=media&token=b485c8ad-c393-4ec7-bc1a-c1c3c93ec4ec
```

## ⚠️ 위험 평가 / Risk Assessment

### 노출된 정보로 가능한 공격
1. **API 할당량 소진**: 악의적인 사용자가 API 키를 사용하여 할당량 소진
2. **비용 발생**: Firebase 사용량 증가로 인한 예상치 못한 비용
3. **데이터 접근**: 보안 규칙이 약한 경우 데이터 무단 접근 가능
4. **서비스 남용**: Perspective API를 통한 서비스 남용

### 즉시 필요한 조치
1. 🔴 **API 키 재생성** (Firebase Console에서)
2. 🔴 **환경 변수 마이그레이션** (Phase 0)
3. 🔴 **Git 히스토리 정리** (BFG Repo-Cleaner)
4. 🟡 **보안 규칙 강화** (Firebase Security Rules)

## 📝 참고사항 / Notes

- 모든 하드코딩된 URL은 설정 파일이나 환경 변수로 이동 필요
- 기본 이미지 URL은 상수로 관리하는 것이 좋음
- API 키는 절대 코드에 포함되어서는 안 됨

---
*이 보고서는 Phase 0 보안 수정의 일부로 생성되었습니다.*