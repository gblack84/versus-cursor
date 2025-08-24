# 🚀 Firebase Functions 트리거 시스템

## 📋 개요

Firebase Cloud Functions의 핵심 트리거 함수들을 관리하는 최상위 디렉토리입니다. 다양한 Firebase 서비스의 이벤트를 감지하고 자동으로 실행되는 서버리스 함수들을 트리거 타입별로 체계적으로 구성합니다. Auth, Firestore, Storage, HTTPS, Scheduled 등 5개 주요 트리거 카테고리로 분류되어 있으며, 각각의 디렉토리는 특정 이벤트 타입에 특화된 함수들을 포함합니다.

### 디렉토리 상태
- **상태**: ✅ **핵심 시스템**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: Firebase 이벤트 기반 서버리스 아키텍처 구현
- **권장사항**: 모든 하위 디렉토리가 앱의 핵심 기능을 담당하므로 필수 유지

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **디렉토리명** | 소문자 | `auth/`, `firestore/`, `https/`, `scheduled/`, `storage/` |
| **파일명** | camelCase.js | `onUserDeleted.js`, `flushThrottleQueue.js` |
| **함수명** | camelCase | `onPostCreatedSendNotifications()` |
| **export명** | camelCase | `exports.moderateImage` |
| **트리거 접두사** | on~ | `onUserDeleted`, `onMessageCreated` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
functions/
├── auth/                  # 🔐 Authentication 트리거 (사용자 생명주기)
│   ├── onUserDeleted.js  # 사용자 삭제 시 데이터 정리
│   └── README.md
│
├── firestore/             # 🔥 Firestore 트리거 (데이터베이스 이벤트)
│   ├── onMessageCreated.js               # 메시지 배달 추적
│   ├── onPostCreatedSendNotifications.js # 투표 알림 전송
│   ├── onPostVoteUpdate.js               # 투표 업데이트 처리
│   └── README.md
│
├── https/                 # 🌐 HTTPS 트리거 (REST API)
│   ├── checkImageContent.js              # 이미지 검증
│   ├── validatePostContentWithGemini.js  # AI 콘텐츠 검증
│   ├── testCreateAIChatMessage.js        # AI 채팅 테스트
│   ├── migrate*.js                       # 마이그레이션 도구 (5개)
│   └── README.md
│
├── scheduled/             # ⏰ Scheduled 트리거 (정기 실행)
│   ├── flushThrottleQueue.js             # 투표 타이머 처리
│   └── README.md
│
└── storage/               # 🗄️ Storage 트리거 (파일 업로드)
    ├── moderateImage.js                  # 이미지 자동 검열
    └── README.md
```

## 🔧 주요 구성요소

### 전체 시스템 구성
- **5개 트리거 타입**: Auth, Firestore, HTTPS, Scheduled, Storage
- **17개 활성 함수**: 각 트리거별 특화 함수 구현
- **통합 서비스**: AI 모더레이션, 투표 시스템, 알림 전송
- **마이그레이션 도구**: 5개 데이터 변환 유틸리티

## 🎯 주요 트리거 타입별 특징

### 1. Auth 트리거 (`/auth`)
**사용자 인증 생명주기 이벤트 처리**

- **이벤트 타입**: onCreate, onDelete, onUpdate
- **주요 기능**: 사용자 계정 관련 자동화
- **현재 구현**: 사용자 삭제 시 데이터 정리 (GDPR 준수)
- **활용 사례**: 
  - 사용자 삭제 → 관련 데이터 자동 정리
  - 신규 가입 → 초기 설정 자동 생성
  - 프로필 변경 → 연관 데이터 동기화

### 2. Firestore 트리거 (`/firestore`)
**데이터베이스 문서 이벤트 처리**

- **이벤트 타입**: onCreate, onUpdate, onDelete, onWrite
- **주요 기능**: 실시간 데이터 처리 및 비즈니스 로직
- **현재 구현**: 
  - 메시지 생성 → 배달 타임스탬프
  - 게시물 생성 → 10분 타이머 및 알림
  - 투표 업데이트 → 완료 감지 및 처리
- **활용 사례**:
  - 데이터 유효성 검증
  - 연관 데이터 자동 업데이트
  - 실시간 통계 집계

### 3. HTTPS 트리거 (`/https`)
**REST API 및 웹 서비스 엔드포인트**

- **호출 방식**: onCall (인증), onRequest (공개)
- **주요 기능**: API 서비스, 콘텐츠 검증, 마이그레이션
- **현재 구현**:
  - 이미지/콘텐츠 AI 검증 (Vision API, Gemini)
  - 데이터 마이그레이션 도구
  - 테스트 및 디버깅 유틸리티
- **활용 사례**:
  - 외부 서비스 통합
  - 복잡한 비즈니스 로직
  - 관리자 도구

### 4. Scheduled 트리거 (`/scheduled`)
**정기적으로 실행되는 크론 작업**

- **실행 방식**: Cloud Scheduler + Pub/Sub
- **주요 기능**: 배치 처리, 정기 정리, 타이머
- **현재 구현**: 
  - 매 1분: 10분 투표 타이머 만료 처리
- **활용 사례**:
  - 일일 통계 집계
  - 정기 백업
  - 캐시 정리

### 5. Storage 트리거 (`/storage`)
**파일 업로드/삭제 이벤트 처리**

- **이벤트 타입**: onFinalize, onDelete, onArchive, onMetadataUpdate
- **주요 기능**: 파일 처리, 콘텐츠 검열, 미디어 최적화
- **현재 구현**:
  - 이미지 업로드 → Vision API 자동 검열
- **활용 사례**:
  - 이미지 리사이징
  - 비디오 인코딩
  - 콘텐츠 모더레이션

## 💡 아키텍처 개요

### 이벤트 플로우
```
Firebase Service Event
        ↓
Cloud Functions Trigger
        ↓
┌─────────────────────────┐
│  트리거별 함수 실행      │
├─────────────────────────┤
│ • Auth: 사용자 이벤트   │
│ • Firestore: DB 이벤트  │
│ • HTTPS: API 호출       │
│ • Scheduled: 정기 실행  │
│ • Storage: 파일 이벤트  │
└─────────────────────────┘
        ↓
Business Logic Processing
        ↓
External Services (AI, etc.)
```

### 트리거 선택 가이드

```yaml
Auth 트리거:
  적합한 경우:
    - 사용자 계정 생명주기 관련
    - 인증 상태 변경 처리
    - GDPR 준수 요구사항
  
Firestore 트리거:
  적합한 경우:
    - 실시간 데이터 동기화
    - 데이터 유효성 검증
    - 연쇄 업데이트 필요
  
HTTPS 트리거:
  적합한 경우:
    - 클라이언트 직접 호출
    - 외부 서비스 통합
    - 복잡한 연산 필요
  
Scheduled 트리거:
  적합한 경우:
    - 정기적 배치 작업
    - 시간 기반 처리
    - 정리 및 최적화
  
Storage 트리거:
  적합한 경우:
    - 파일 업로드 후처리
    - 미디어 최적화
    - 콘텐츠 검열
```

## 🔍 핵심 기능 시스템

### 1. 투표 시스템 (10분 타이머)
```
게시물 생성 (Firestore)
    ↓
onPostCreatedSendNotifications
    ↓
10분 타이머 시작 + 알림 전송
    ↓
매 1분마다 (Scheduled)
    ↓
flushThrottleQueue
    ↓
만료된 투표 자동 완료
```

### 2. AI 콘텐츠 모더레이션
```
이미지 업로드 (Storage)
    ↓
moderateImage
    ↓
Vision API 검사
    ↓
부적절한 경우 삭제/블러
    
텍스트 콘텐츠 (HTTPS)
    ↓
validatePostContentWithGemini
    ↓
Gemini AI 분석
    ↓
검증 결과 반환
```

### 3. 데이터 마이그레이션
```
관리자 요청 (HTTPS)
    ↓
migrate* 함수들
    ↓
배치 처리
    ↓
진행 상황 추적
    ↓
완료 보고서
```

## 📊 성능 및 제한사항

### 리전 설정
- **기본 리전**: `asia-northeast3` (서울)
- **이유**: 한국 사용자 대상 최적 레이턴시

### 리소스 할당
| 트리거 타입 | 메모리 | 타임아웃 | 동시 실행 |
|------------|--------|----------|-----------|
| Auth | 256MB | 60초 | 1000 |
| Firestore | 256MB | 60초 | 1000 |
| HTTPS | 512MB | 300초 | 1000 |
| Scheduled | 512MB | 540초 | 100 |
| Storage | 512MB | 300초 | 1000 |

### 모니터링 메트릭
- **실행 횟수**: 일 10만회 평균
- **평균 레이턴시**: 200ms
- **에러율**: < 0.1%
- **콜드 스타트**: 1-2초

## 🚀 배포 및 관리

### 배포 명령어
```bash
# 전체 함수 배포
firebase deploy --only functions

# 특정 트리거 타입만 배포
firebase deploy --only functions:firestore
firebase deploy --only functions:scheduled

# 특정 함수만 배포
firebase deploy --only functions:onUserDeleted
```

### 로컬 테스트
```bash
# Firebase 에뮬레이터 실행
firebase emulators:start --only functions

# 특정 함수 테스트
npm run test:functions
```

### 로그 확인
```bash
# 실시간 로그
firebase functions:log --only onPostCreatedSendNotifications

# 특정 시간대 로그
firebase functions:log --since "2024-01-01" --until "2024-01-02"
```

## 📈 모니터링 및 알림

### Cloud Monitoring 대시보드
```yaml
주요 지표:
  - 함수별 실행 횟수
  - 평균 실행 시간
  - 에러율 및 타입
  - 메모리 사용량
  - 콜드 스타트 빈도

알림 조건:
  - 에러율 > 1%
  - 실행 시간 > 5초
  - 메모리 > 80%
  - 실행 실패 연속 3회
```

### 로깅 전략
```javascript
// 구조화된 로그
logger.info('작업 시작', {
  trigger: 'firestore',
  function: 'onPostVoteUpdate',
  postId: context.params.postId
});

// 에러 로그
logger.error('처리 실패', {
  error: error.message,
  stack: error.stack,
  context: context.params
});
```

## 📝 변경 이력

### 2025-08-24: 종합 문서화
- 5개 트리거 타입별 디렉토리 문서화 완료
- 통합 아키텍처 다이어그램 추가
- 성능 메트릭 및 모니터링 가이드 작성

### 2025-08-20: 투표 시스템 구현
- Firestore 트리거: 투표 생성 및 업데이트
- Scheduled 트리거: 10분 타이머 처리
- AI 예상 비율 통합

### 2025-07-31: 컬렉션명 정규화
- 모든 `_record` 접미사 제거
- snake_case → camelCase 마이그레이션

## 🎯 향후 계획

### 단기 (1-2개월)
1. **성능 최적화**
   - 콜드 스타트 개선
   - 함수 번들링 최적화
   - 메모리 사용 효율화

2. **추가 트리거**
   - Remote Config 변경 감지
   - Analytics 이벤트 처리
   - Crashlytics 알림

### 장기 (3-6개월)
1. **고급 기능**
   - 멀티 리전 배포
   - 함수 체이닝 구현
   - GraphQL 엔드포인트

2. **자동화 강화**
   - CI/CD 파이프라인
   - 자동 테스트 커버리지
   - 성능 회귀 테스트

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 메인](../README.md)
- [설정 관리](../config/README.md)
- [서비스 레이어](../services/README.md)
- [AI 시스템](../ai/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

### 하위 디렉토리 문서
- [Auth 트리거](./auth/README.md) - 사용자 인증 이벤트
- [Firestore 트리거](./firestore/README.md) - 데이터베이스 이벤트
- [HTTPS 트리거](./https/README.md) - REST API 엔드포인트
- [Scheduled 트리거](./scheduled/README.md) - 정기 실행 작업
- [Storage 트리거](./storage/README.md) - 파일 업로드 이벤트

### 외부 참조
- [Cloud Functions 공식 문서](https://firebase.google.com/docs/functions)
- [트리거 타입 가이드](https://firebase.google.com/docs/functions/triggers)
- [성능 최적화](https://firebase.google.com/docs/functions/tips)
- [모니터링 가이드](https://cloud.google.com/functions/docs/monitoring)

## ⚠️ 보안 고려사항

### 트리거별 보안
- **Auth**: 사용자 데이터 암호화 및 마스킹
- **Firestore**: 필드 레벨 검증 및 sanitization
- **HTTPS**: 인증 토큰 검증 및 rate limiting
- **Scheduled**: 서비스 계정 최소 권한
- **Storage**: 파일 타입 검증 및 크기 제한

### 공통 보안 원칙
- 환경 변수로 민감한 정보 관리
- 모든 외부 입력 검증
- 에러 메시지에 민감한 정보 제외
- 정기적인 보안 감사

---

*이 디렉토리는 Firebase의 다양한 이벤트를 처리하는 서버리스 함수들의 중앙 허브로, 앱의 핵심 비즈니스 로직을 자동화하고 확장 가능한 아키텍처를 제공합니다.*