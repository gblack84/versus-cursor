# 🔥 Firebase - Versus Space 백엔드 인프라

## 📋 개요

Versus Space의 전체 Firebase 백엔드 인프라를 관리하는 루트 디렉토리입니다. Cloud Functions, Firestore, Storage, Hosting 등 모든 Firebase 서비스의 설정과 규칙을 중앙 집중식으로 관리합니다.

### 디렉토리 상태
- **상태**: ✅ **프로덕션 운영중**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: Firebase 전체 인프라 관리
- **프로젝트 ID**: versus-space-1lwwiw

## 🎯 네이밍 컨벤션

프로젝트 전체 네이밍 컨벤션을 엄격히 준수합니다:

| 구분 | 컨벤션 | 예시 | 설명 |
|------|--------|------|------|
| **설정 파일** | kebab-case.json | `firebase.json`, `firestore.rules` | Firebase 설정 |
| **컬렉션명** | camelCase | `users`, `posts`, `notifications` | Firestore 컬렉션 |
| **Storage 경로** | snake_case | `user_uploads/`, `post_images/` | Storage 폴더 |
| **필드명** | camelCase | `createdAt`, `voteCount` | Firestore 필드 |
| **인덱스 필드** | camelCase | `participantIds`, `lastMessageAt` | 복합 인덱스 |

참조: [NAMING_CONVENTION.md](../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
firebase/
├── 📄 firebase.json          # Firebase 프로젝트 전체 설정
├── 📄 firestore.rules        # Firestore 보안 규칙 (638줄)
├── 📄 firestore.indexes.json # Firestore 인덱스 설정
├── 📄 storage.rules          # Storage 보안 규칙 (12줄)
├── 📄 .firebaserc            # 프로젝트 별칭 설정
│
├── 📁 functions/             # Cloud Functions 코드 ⭐⭐⭐⭐⭐
│   ├── index.js              # 함수 진입점 (16개 함수)
│   ├── package.json          # Node.js 20 의존성
│   ├── ai/                   # AI 엔진 (Genkit 통합)
│   ├── config/               # 핵심 설정 및 로거
│   ├── functions/            # 함수 구현체
│   ├── services/             # 비즈니스 로직
│   ├── notifications/        # 알림 시스템
│   └── utils/                # 유틸리티
│
├── 📁 public/                # Hosting 정적 파일
│   └── index.html            # 기본 페이지
│
├── 📁 backups/               # 백업 파일
│   └── firestore.indexes.backup.json
│
└── 📁 scripts/               # 관리 스크립트
    └── deploy.sh             # 배포 자동화
```

## 🔐 Firebase 서비스 구성

### 1. Firestore Database

**주요 컬렉션 (25개)**:

| 컬렉션 | 용도 | 문서 수 | 보안 규칙 |
|--------|------|---------|-----------|
| `users` | 사용자 프로필 | ~10K | 본인만 수정 |
| `posts` | 투표 게시물 | ~50K | 공개 읽기 |
| `notifications` | 알림 메시지 | ~100K | 개인별 접근 |
| `chats` | 채팅방 | ~20K | 참여자만 접근 |
| `messages` | 채팅 메시지 | ~500K | 채팅방 기반 |
| `votes` | 투표 기록 | ~200K | 생성만 허용 |
| `comments` | 댓글 | ~100K | 공개 읽기 |
| `aiChats` | AI 채팅방 | ~5K | 본인만 접근 |

**보안 규칙 하이라이트**:
```javascript
// 중복 투표 방지 로직
match /posts/{postId} {
  allow update: if request.auth != null && (
    // 투표한 사용자 ID 리스트 확인
    (!('votedUserIDsA' in resource.data) || 
     !(request.auth.uid in resource.data.votedUserIDsA))
    && 
    (!('votedUserIDsB' in resource.data) || 
     !(request.auth.uid in resource.data.votedUserIDsB))
  );
}
```

### 2. Cloud Storage

**버킷 구조**:
```
users/
  {userId}/
    profile_images/    # 프로필 사진
    post_images/       # 게시물 이미지
    chat_media/        # 채팅 미디어
    
uploads/
  temp/               # 임시 업로드
  processed/          # 처리된 이미지
```

**보안 규칙**:
- 본인 폴더만 쓰기 가능
- 모든 사용자 읽기 가능
- 최대 파일 크기: 10MB

### 3. Cloud Functions

**배포된 함수 (16개)**:

#### 🔐 인증 (1개)
- `onUserDeleted` - 사용자 삭제 시 데이터 정리

#### 📝 Firestore 트리거 (3개)
- `onPostCreatedSendNotifications` - 투표 알림 발송
- `onPostVoteUpdate` - 투표 완료 감지
- `onMessageCreated` - 메시지 처리

#### 🌐 HTTPS 엔드포인트 (10개)
- `checkImageContent` - 이미지 검열
- `validatePostContentWithGemini` - AI 콘텐츠 검증
- `markMessagesAsSeen` - 메시지 읽음 처리
- 마이그레이션 함수 7개

#### ⏰ 스케줄 (1개)
- `flushThrottleQueue` - 매 1분 큐 처리

#### 📦 Storage 트리거 (1개)
- `moderateImage` - 업로드 이미지 검열

### 4. Firebase Hosting

**설정**:
```json
{
  "hosting": {
    "public": "public",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"]
  }
}
```

## 🔒 보안 규칙 관리

### Firestore Security Rules

**주요 패턴**:

1. **개인 데이터 보호**:
```javascript
match /users/{userId}/settings/{document} {
  allow read, write: if request.auth.uid == userId;
}
```

2. **공개 읽기, 제한된 쓰기**:
```javascript
match /posts/{postId} {
  allow read: if true;
  allow create: if request.auth != null;
  allow update: if [특정 필드만];
}
```

3. **서브컬렉션 상속**:
```javascript
match /chats/{chatId}/messages/{messageId} {
  allow read: if request.auth.uid in parent.participantIds;
}
```

### Storage Security Rules

**접근 제어**:
- 기본: 모든 접근 차단
- 사용자별: 본인 폴더만 쓰기
- 공개 읽기: 모든 인증 사용자

## 📊 Firestore 인덱스

### 복합 인덱스 (12개)

```json
{
  "indexes": [
    {
      "collectionGroup": "chats",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "participantIds", "order": "ASCENDING" },
        { "fieldPath": "lastMessageAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "createdAt", "order": "DESCENDING" },
        { "fieldPath": "voteStatus", "order": "ASCENDING" }
      ]
    }
  ]
}
```

## 🚀 배포 관리

### 배포 명령어

```bash
# 전체 배포
firebase deploy

# 개별 서비스 배포
firebase deploy --only functions
firebase deploy --only firestore:rules
firebase deploy --only firestore:indexes
firebase deploy --only storage
firebase deploy --only hosting

# 특정 함수만 배포
firebase deploy --only functions:onPostCreatedSendNotifications
```

### 환경 설정

```bash
# 프로덕션 환경 설정
firebase use versus-space-1lwwiw

# Functions 환경 변수
firebase functions:config:set \
  google.genai_api_key="YOUR_KEY" \
  perspective.api_key="YOUR_KEY"

# 로컬 에뮬레이터
firebase emulators:start
```

## 📈 모니터링 및 성능

### 현재 운영 지표

| 서비스 | 일일 사용량 | 월간 비용 | 성능 |
|--------|------------|-----------|------|
| **Firestore** | 500K 읽기, 100K 쓰기 | $50 | 50ms 평균 |
| **Functions** | 50K 호출 | $30 | 1.2초 평균 |
| **Storage** | 10GB, 1M 다운로드 | $20 | CDN 캐싱 |
| **Hosting** | 100K 방문 | $10 | 글로벌 CDN |
| **총 비용** | - | **$110/월** | - |

### 성능 최적화

1. **Firestore 최적화**:
   - 복합 인덱스로 쿼리 성능 향상
   - 배치 쓰기로 트랜잭션 최소화
   - 오프라인 지속성 활성화

2. **Functions 최적화**:
   - 콜드 스타트 최소화 (메모리 512MB)
   - 병렬 처리 및 배치 작업
   - 실시간 스로틀링

3. **Storage 최적화**:
   - 이미지 리사이징 (display, thumbnail)
   - CDN 캐싱 활용
   - 압축 및 최적화

## 🔍 문제 해결

### 일반적인 문제

#### 1. 권한 오류
```
Error: Missing or insufficient permissions
```
**해결**: firestore.rules 확인, 인덱스 생성 대기

#### 2. 함수 타임아웃
```
Error: Function execution took 60001 ms
```
**해결**: 타임아웃 증가, 비동기 처리 최적화

#### 3. 스토리지 CORS
```
Error: CORS policy blocked
```
**해결**: Firebase Console에서 CORS 설정

## 📚 관련 문서

### 내부 문서
- [Cloud Functions 상세](./functions/README.md) ⭐⭐⭐⭐⭐
- [보안 규칙 가이드](./SECURITY_RULES_UPDATE_GUIDE.md)
- [프로젝트 아키텍처](../ARCHITECTURE.md)
- [네이밍 컨벤션](../NAMING_CONVENTION.md)

### 외부 참조
- [Firebase 공식 문서](https://firebase.google.com/docs)
- [Firestore 보안 규칙](https://firebase.google.com/docs/firestore/security/get-started)
- [Cloud Functions 가이드](https://firebase.google.com/docs/functions)
- [Storage 보안 규칙](https://firebase.google.com/docs/storage/security)

## 📝 변경 이력

### 2025-08-21: 통합 문서화
- Firebase 전체 인프라 문서 작성
- 16개 Cloud Functions 운영 현황 정리
- 보안 규칙 및 인덱스 문서화

### 2025-08-20: Genkit 통합
- AI 프레임워크 도입
- Functions 구조 개선
- 성능 최적화

### 2025-08-04: 보안 규칙 강화
- 중복 투표 방지 로직 추가
- 타이머 필드 보호
- 시간 동기화 컬렉션 추가

### 2025-07-31: 컬렉션 정규화
- _record 접미사 제거
- camelCase 통일
- 768개 필드 마이그레이션

## 🎯 향후 계획

### 단기 (1-2개월)
1. **실시간 데이터베이스 통합** - 채팅 성능 개선
2. **백업 자동화** - 일일 자동 백업
3. **모니터링 대시보드** - Grafana 통합

### 중기 (3-4개월)
1. **멀티 리전 배포** - 아시아/유럽 확장
2. **캐싱 레이어** - Redis/Memcached
3. **GraphQL Gateway** - 효율적 데이터 페칭

### 장기 (6개월+)
1. **서버리스 마이그레이션** - Cloud Run 전환
2. **비용 최적화** - 사용량 기반 스케일링
3. **엔터프라이즈 보안** - VPC, Private endpoints

---

*이 디렉토리는 Versus Space의 전체 백엔드 인프라를 관리하는 핵심 위치입니다.*

**마지막 업데이트**: 2025-08-21  
**문서 버전**: 1.0.0  
**관리자**: Versus Space Backend Team