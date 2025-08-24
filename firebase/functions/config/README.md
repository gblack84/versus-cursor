# ⚙️ Firebase Functions 설정 관리 시스템

## 📋 개요

Versus Space Firebase Functions의 핵심 설정 관리 디렉토리입니다. Firebase Admin SDK 초기화, 외부 API 클라이언트 관리, 구조화된 로깅 시스템 등 모든 Functions가 공통으로 사용하는 설정을 중앙 집중식으로 관리합니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: Firebase Functions 핵심 설정 및 공통 유틸리티
- **권장사항**: 모든 Functions에서 필수적으로 참조

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `apiClients.js`, `logger.js` |
| **함수명** | camelCase | `createLogger()`, `maskSensitiveData()` |
| **변수명** | camelCase | `visionClient`, `geminiModel` |
| **상수** | UPPER_SNAKE_CASE | `PERSPECTIVE_API_KEY`, `MIN_LOG_LEVEL` |
| **클래스** | PascalCase | `Logger` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
config/
├── firebase.js        # Firebase Admin SDK 초기화 (23줄)
├── apiClients.js     # 외부 API 클라이언트 설정 (37줄)
├── logger.js         # 구조화된 로깅 시스템 (205줄)
└── README.md         # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. firebase.js - Firebase Admin SDK 초기화
**Firebase 서비스 중앙 집중식 초기화** (23줄)

```javascript
// Firebase Admin 초기화 (싱글톤 패턴)
if (!admin.apps.length) {
  admin.initializeApp();
}

// 공통 서비스 export
module.exports = {
  admin,    // Admin SDK 인스턴스
  db,       // Firestore 인스턴스
  storage   // Cloud Storage 인스턴스
};
```

**특징**:
- 싱글톤 패턴으로 중복 초기화 방지
- 모든 Firebase 서비스 단일 진입점
- 자동 환경 감지 (로컬/프로덕션)

### 2. apiClients.js - 외부 API 클라이언트
**Vision API, Gemini AI 등 외부 서비스 통합** (37줄)

```javascript
// Vision API 클라이언트
const visionClient = new vision.ImageAnnotatorClient();

// Gemini AI 모델 (조건부 초기화)
if (GEMINI_API_KEY) {
  geminiModel = new ChatGoogleGenerativeAI({
    apiKey: GEMINI_API_KEY,
    modelName: "gemini-pro",
    temperature: 0.3,
    maxOutputTokens: 1000,
  });
}
```

**API 키 관리**:
- 3단계 폴백: 환경변수 → Firebase Config → undefined
- 민감한 정보 보호를 위한 조건부 초기화
- 키 없을 시 graceful degradation 지원

**지원 서비스**:
- Google Cloud Vision API (이미지 분석)
- Google Gemini AI (LangChain 통합)
- Perspective API (텍스트 검열)

### 3. logger.js - 구조화된 로깅 시스템
**엔터프라이즈급 로깅 프레임워크** (205줄)

```javascript
// 로거 생성 및 사용
const logger = createLogger('MyFunction');

logger.info('작업 시작', { userId, taskId });
logger.error('오류 발생', error);
logger.debug('디버그 정보', { data });
```

**로그 레벨**:
- `DEBUG` (0): 개발 환경 상세 정보
- `INFO` (1): 일반 정보 메시지
- `WARNING` (2): 경고 메시지
- `ERROR` (3): 오류 및 예외

**핵심 기능**:
1. **환경별 로그 레벨 자동 조정**
   - 개발: DEBUG 이상 모두 표시
   - 프로덕션: INFO 이상만 표시

2. **민감한 데이터 자동 마스킹**
   ```javascript
   // 자동 마스킹 필드
   ['password', 'token', 'apiKey', 'email', 'phone', 'uid']
   
   // 마스킹 예시
   "apiKey": "sk-1234...5678"  // 앞 4자, 뒤 4자만 표시
   ```

3. **구조화된 로깅 (Cloud Logging 통합)**
   ```javascript
   {
     severity: 'INFO',
     timestamp: '2024-01-01T12:00:00Z',
     tag: 'MyFunction',
     message: 'ℹ️ [MyFunction] 작업 완료',
     data: { /* 추가 메타데이터 */ }
   }
   ```

4. **로그 이모지로 가독성 향상**
   - 🔍 DEBUG
   - ℹ️ INFO
   - ⚠️ WARNING
   - ❌ ERROR

## 💡 사용 예시

### Firebase 서비스 사용
```javascript
const { admin, db, storage } = require('./config/firebase');

// Firestore 사용
const docRef = await db.collection('users').doc(userId).get();

// Storage 사용
const bucket = storage.bucket();
await bucket.file('path/to/file').save(buffer);
```

### 외부 API 사용
```javascript
const { visionClient, geminiModel } = require('./config/apiClients');

// Vision API 사용
const [result] = await visionClient.safeSearchDetection(imageUri);

// Gemini AI 사용 (키가 있을 때만)
if (geminiModel) {
  const response = await geminiModel.invoke(prompt);
}
```

### 로깅 시스템 사용
```javascript
const { createLogger } = require('./config/logger');
const logger = createLogger('ContentModeration');

// 다양한 로그 레벨 사용
logger.debug('이미지 분석 시작', { imageId });
logger.info('분석 완료', { result: 'SAFE' });
logger.warning('의심스러운 콘텐츠', { score: 0.8 });
logger.error('API 호출 실패', error);

// 민감한 데이터 마스킹
const maskedEmail = logger.maskSensitive('user@example.com', 3);
// 결과: "use....com"
```

## ⚙️ 환경 설정

### 필수 환경 변수
```bash
# Firebase Functions 설정
firebase functions:config:set \
  perspective.api_key="YOUR_KEY" \
  gemini.api_key="YOUR_KEY"

# 로컬 개발 (.env)
PERSPECTIVE_API_KEY=your_key_here
GEMINI_API_KEY=your_key_here
NODE_ENV=development
```

### 환경별 동작
| 환경 | 로그 레벨 | 데이터 마스킹 | 성능 최적화 |
|------|----------|-------------|------------|
| **개발** | DEBUG | 부분 마스킹 | 비활성화 |
| **프로덕션** | INFO | 완전 마스킹 | 활성화 |

## 🔍 문제 해결

### 일반적인 문제

1. **Firebase Admin 중복 초기화 오류**
```
Error: The default Firebase app already exists
```
- firebase.js의 싱글톤 패턴 확인
- 다른 파일에서 직접 초기화하지 않도록 주의

2. **API 키 누락**
```
Error: Gemini API key not found
```
- Firebase config 설정 확인
- 환경 변수 설정 확인
- apiClients.js의 조건부 초기화 확인

3. **로그가 표시되지 않음**
```
// 개발 환경에서도 DEBUG 로그가 안 보일 때
```
- NODE_ENV 환경 변수 확인
- MIN_LOG_LEVEL 설정 확인
- Firebase Functions 로그 뷰어 필터 확인

## 🚀 모범 사례

### 1. 중앙 집중식 설정 관리
```javascript
// ✅ 좋은 예: config 모듈 사용
const { db } = require('./config/firebase');

// ❌ 나쁜 예: 직접 초기화
const admin = require('firebase-admin');
admin.initializeApp();  // 중복 초기화 위험
```

### 2. 로거 태그 일관성
```javascript
// ✅ 좋은 예: 함수명과 일치하는 태그
const logger = createLogger('onPostCreated');

// ❌ 나쁜 예: 일관성 없는 태그
const logger = createLogger('my-func');
```

### 3. 민감한 데이터 처리
```javascript
// ✅ 좋은 예: 마스킹 후 로깅
logger.info('사용자 생성', { 
  userId: logger.maskSensitive(uid, 4) 
});

// ❌ 나쁜 예: 민감한 데이터 직접 로깅
logger.info('사용자 생성', { uid, email, phone });
```

## 📊 성능 고려사항

### 로깅 오버헤드 최소화
- 프로덕션에서는 DEBUG 로그 자동 스킵
- 구조화된 로깅으로 파싱 성능 향상
- 비동기 로깅으로 메인 로직 블로킹 방지

### API 클라이언트 재사용
- 전역 인스턴스로 초기화 비용 절감
- 조건부 초기화로 불필요한 연결 방지
- 연결 풀링 자동 관리

## 📈 모니터링

### Cloud Logging 대시보드 활용
```javascript
// 구조화된 로그로 고급 필터링 가능
severity="ERROR" AND tag="ContentModeration"
timestamp>"2024-01-01" AND data.userId="user123"
```

### 로그 기반 메트릭
- 에러율 추적
- API 호출 빈도 모니터링
- 민감한 데이터 접근 감사

## 📝 변경 이력

### 2025-08-20: 구조화된 로깅 시스템 구현
- Logger 클래스 구현
- 민감한 데이터 자동 마스킹
- 환경별 로그 레벨 관리

### 2025-08-19: 외부 API 통합
- Vision API 클라이언트 추가
- Gemini AI (LangChain) 통합
- Perspective API 설정

### 2025-08-18: 초기 설정
- Firebase Admin SDK 초기화
- 기본 설정 구조 확립

## 🎯 향후 계획

### 단기 (1-2개월)
1. **Redis 캐싱 레이어 추가**
2. **API Rate Limiting 구현**
3. **로그 집계 및 분석 도구**

### 장기 (3-6개월)
1. **멀티 리전 설정 지원**
2. **A/B 테스트 설정 관리**
3. **자동 설정 검증 시스템**

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../README.md)
- [AI 시스템](../ai/README.md)
- [알림 시스템](../notifications/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

### 외부 참조
- [Firebase Admin SDK](https://firebase.google.com/docs/admin/setup)
- [Google Cloud Vision API](https://cloud.google.com/vision/docs)
- [LangChain Google Generative AI](https://js.langchain.com/docs/integrations/llms/google_generativeai)
- [Cloud Logging](https://cloud.google.com/logging/docs)

---

*이 디렉토리는 모든 Firebase Functions의 기반이 되는 핵심 설정 관리 시스템입니다.*