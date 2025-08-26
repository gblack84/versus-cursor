# 📡 Profile Data Datasources Layer

> Feature-First Architecture - Profile 데이터소스 계층

## 📋 개요

프로필 기능의 **Data Sources Layer**를 담당하는 디렉토리입니다. Firebase, 로컬 캐시, 서드파티 서비스와의 데이터 통신을 추상화합니다.

### 🎯 목적
- **데이터 소스 분리**: 원격/로컬 데이터 접근 로직 분리
- **3-Layer 캐싱**: Memory → Hive → Firestore 캐싱 전략
- **오프라인 우선**: 로컬 데이터 우선 접근으로 빠른 응답
- **데이터 동기화**: 온라인 복귀 시 자동 동기화

## 🏗️ 디렉토리 구조

```
datasources/
├── remote/                                    # 원격 데이터소스
│   ├── firestore_profile_datasource.dart     # Firestore 프로필 데이터
│   ├── firebase_storage_datasource.dart      # Storage 프로필 이미지
│   ├── firestore_character_datasource.dart   # 캐릭터 데이터
│   ├── firestore_interest_datasource.dart    # 관심사/취미 데이터
│   ├── firestore_job_datasource.dart         # 직업 카테고리 데이터
│   ├── firestore_friends_datasource.dart     # 친구 목록 데이터
│   └── firestore_premium_datasource.dart     # 프리미엄 구독 데이터
│
└── local/                                     # 로컬 데이터소스
    ├── profile_local_datasource.dart         # 프로필 로컬 캐시
    ├── character_local_datasource.dart       # 캐릭터 로컬 캐시
    ├── interest_local_datasource.dart        # 관심사 로컬 캐시
    ├── settings_local_datasource.dart        # 설정 로컬 저장
    └── onboarding_progress_datasource.dart   # 온보딩 진행상태
```

## 📂 Remote 데이터소스 사양

### FirestoreProfileDatasource
- **역할**: Firestore 프로필 데이터 관리
- **주요 기능**:
  - 프로필 CRUD 작업
  - 실시간 스트림 제공
  - 랭킹 데이터 조회
  - 프로필 완성도 계산
- **컬렉션**: `users`
- **에러 처리**: ProfileDataSourceException

### FirebaseStorageDatasource  
- **역할**: 프로필 이미지 업로드/삭제
- **주요 기능**:
  - 이미지 압축 및 리사이징
  - 썸네일 생성
  - 캐릭터 이미지 목록 제공
- **경로**: `user_uploads/profile_images/`

### FirestoreInterestDatasource
- **역할**: 관심사/취미 데이터 관리
- **주요 기능**:
  - 카테고리별 관심사 조회
  - 인기 관심사 랭킹
  - 사용자 관심사 업데이트
- **컬렉션**: `interest`, `hobbies`

### FirestoreJobDatasource
- **역할**: 직업 카테고리 관리
- **주요 기능**:
  - 직업 카테고리 목록 조회
  - 카테고리별 직업명 조회
  - 직업 검색 기능
- **컬렉션**: `jopsCategory`, `jopsName`

## 📂 Local 데이터소스 사양

### ProfileLocalDatasource
- **역할**: 프로필 로컬 캐싱
- **캐싱 전략**:
  - 캐시 유효 시간: 6시간
  - 랭킹 캐시: 1시간
  - 오프라인 큐 관리
- **스토리지**: Hive Box

### OnboardingProgressDatasource
- **역할**: 온보딩 진행상태 관리
- **주요 기능**:
  - 단계별 진행상태 저장
  - 현재 단계 조회
  - 임시 데이터 관리
- **온보딩 단계**:
  1. age_agreement
  2. job_selection
  3. expertise_selection
  4. hobby_selection
  5. character_creation
  6. profile_setup

## 🔄 데이터 흐름

```
Repository Layer
    ↓
Network Status Check
    ↓
[Online] → Remote Datasources → Firestore/Storage
[Offline] → Local Datasources → Hive/SharedPrefs
    ↓
3-Layer Cache System
    ↓
Return Data
```

## 🔐 보안 고려사항

### 데이터 보호
- 개인정보 암호화 저장
- Storage Security Rules 적용
- 프로필 공개 범위 설정

### 캐시 보안
- 자동 만료 시간 설정
- userId 기반 격리
- 민감정보 캐싱 금지

## ✅ 체크리스트

### 구현 완료
- [ ] Remote 데이터소스 (7개)
- [ ] Local 데이터소스 (5개)
- [ ] 캐시 전략 구현
- [ ] 오프라인 동기화

### 구현 예정
- [ ] 실시간 상태 업데이트 (WebSocket)
- [ ] 고급 검색 기능 (Algolia)
- [ ] 배치 작업 최적화

---

*이 문서는 Feature-First Architecture의 Profile 기능 데이터소스 가이드입니다.*
*최종 업데이트: 2025-08-25*