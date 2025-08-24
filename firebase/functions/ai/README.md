# 🤖 AI 시스템 - Firebase Functions Genkit 통합

## 📋 개요

Versus Space의 핵심 AI 엔진으로, Google Genkit 프레임워크를 활용한 통합 AI 시스템입니다. 콘텐츠 검열, 사용자 추천, 임베딩 생성 등 다양한 AI 기능을 제공하며, 토큰 사용량 추적과 비용 최적화를 위한 캐싱 시스템을 포함합니다.

### 디렉토리 상태
- **상태**: ✅ **필수 유지**
- **중요도**: ⭐⭐⭐⭐⭐
- **용도**: AI 기반 콘텐츠 검열 및 사용자 매칭
- **권장사항**: 지속적인 모니터링 및 최적화 필요

## 🎯 네이밍 컨벤션

프로젝트 표준 네이밍 컨벤션을 따릅니다:

| 구분 | 컨벤션 | 예시 |
|------|--------|------|
| **파일명** | camelCase.js | `contentModeration.js` |
| **함수명** | camelCase | `validateContentWithGenkit()` |
| **변수명** | camelCase | `tokenUsageStats` |
| **상수** | UPPER_SNAKE_CASE | `VERSUS_VALIDATION_PROMPT` |
| **Firestore 필드** | camelCase | `userId`, `createdAt` |

참조: [NAMING_CONVENTION.md](../../../NAMING_CONVENTION.md)

## 📂 디렉토리 구조

```
ai/
├── config.js               # Genkit 설정 및 모델 정의 (118줄)
├── contentModeration.js    # 콘텐츠 검열 시스템 (506줄)
├── userRecommendation.js   # AI 기반 사용자 매칭 (375줄)
├── userHistoryAnalyzer.js  # 사용자 이력 분석 (68줄)
├── cache.js               # AI 응답 캐싱 시스템 (184줄)
├── monitoring.js          # 성능 모니터링 및 로깅 (292줄)
└── README.md             # 문서 (이 파일)
```

## 🔧 주요 구성요소

### 1. config.js - Genkit 설정 관리
**중앙 집중식 AI 설정 및 모델 관리** (118줄)

```javascript
// 모델별 용도 구분
const models = {
  contentModeration: 'googleai/gemini-1.5-flash',    // 빠른 응답
  userRecommendation: 'googleai/gemini-1.5-pro',     // 높은 정확도
  textEmbedding: 'googleai/text-embedding-004'       // 유사도 계산
};

// 토큰 사용량 추적
function updateTokenUsage(operation, usage) {
  stats.input += usage.inputTokens;
  stats.output += usage.outputTokens;
  stats.total += usage.totalTokens;
}
```

**특징**:
- API 키 3단계 폴백 (env → firebase config → gemini config)
- 실시간 토큰 사용량 추적
- 비용 자동 계산 (Gemini 가격 기준)
- 작업별 최적화된 모델 선택

### 2. contentModeration.js - 콘텐츠 검열
**AI 기반 다단계 콘텐츠 검증** (506줄)

```javascript
// 통합 검증 프로세스
async function validateContentWithGenkit({
  userId,
  questionTitle,
  titleA,
  titleB,
  imageUrlA,
  imageUrlB,
  visionDataA,
  visionDataB,
  perspectiveScores
}) {
  // 1. 사용자 이력 조회
  // 2. Vision API 데이터 분석
  // 3. Gemini AI 종합 판단
  // 4. 예상 투표 비율 추론
}
```

**검증 단계**:
1. **1차 필터**: 절대 금지 콘텐츠 차단 (혐오, 범죄, 개인정보)
2. **2차 필터**: 품질 및 의도 판단
3. **얼굴 평가 특별 처리**: 사람 얼굴 비교 차단
4. **예상 투표 비율**: 한국 사용자 기준 예측

**프롬프트 v4.0 특징**:
- 재치있고 친절한 커뮤니티 매니저 페르소나
- 3단계 응답: PROCEED, PROCEED_WITH_SUGGESTION, BLOCK
- 얼굴 평가 특별 감지 로직
- 예상 투표 비율 추론 (A:B 비율)

### 3. userRecommendation.js - 사용자 추천
**AI 기반 스마트 사용자 매칭** (375줄)

```javascript
// 메인 추천 함수
async function getAIRecommendedUsers(
  postData, 
  candidateUsers, 
  targetCount
) {
  // 1. 투표 내용 분석 (주제, 카테고리, 감정)
  // 2. 사용자 프로필 임베딩 생성
  // 3. AI 기반 순위 매기기
  // 4. 상위 N명 선택
}
```

**추천 프로세스**:
- **투표 분석**: 주제, 타겟 연령대, 관심사 추출
- **프로필 매칭**: 40% 관심사, 30% 활동성, 20% 참여 품질
- **스코어링**: 0-100점 AI 점수 부여
- **통계 추적**: 평균/최고/최저 점수, 점수 분포

### 4. cache.js - 캐싱 시스템
**메모리 기반 지능형 캐싱** (184줄)

```javascript
// 캐시 타입별 TTL 설정
const caches = {
  userEmbeddings: new SimpleCache(3600),    // 1시간
  postAnalysis: new SimpleCache(1800),      // 30분
  recommendations: new SimpleCache(300),     // 5분
  userProfiles: new SimpleCache(900)         // 15분
};
```

**캐시 전략**:
- SimpleCache 클래스로 TTL 기반 관리
- 자동 만료 항목 정리
- 캐시 히트/미스 로깅
- 주기적 클린업 지원

### 5. monitoring.js - 모니터링
**성능 추적 및 비용 관리** (292줄)

```javascript
// 성능 추적
class PerformanceTracker {
  async complete(success, additionalData) {
    const latency = Date.now() - this.startTime;
    await logAIOperation(this.operation, {
      success,
      latency,
      ...additionalData
    });
  }
}
```

**모니터링 기능**:
- 작업별 레이턴시 측정
- 토큰 사용량 Firestore 저장
- 비용 실시간 계산
- A/B 테스트 추적
- 일일 사용량 리포트

### 6. userHistoryAnalyzer.js - 사용자 이력
**사용자 행동 패턴 분석** (68줄)

```javascript
async function getUserPostingHistory(userId) {
  // 거부된 포스트 수 조회
  // 신고된 포스트 수 확인
  // 신규 사용자 여부 판단
}
```

**분석 항목**:
- 30일간 거부된 포스트
- 신고 받은 콘텐츠
- 신규 사용자 판별

## 💡 핵심 기능

### 토큰 사용량 관리
```javascript
// 실시간 추적
{
  moderation: { input: 15000, output: 3000, total: 18000 },
  recommendation: { input: 25000, output: 8000, total: 33000 },
  embedding: { total: 5000 }
}

// 비용 계산 (USD)
- Gemini 1.5 Flash: $0.075/1M input, $0.30/1M output
- Gemini 1.5 Pro: $1.25/1M input, $5.00/1M output
```

### 성능 최적화
- **병렬 처리**: 사용자 이력 + 이미지 변환 동시 처리
- **Display 이미지 사용**: _original → _display 자동 변환
- **캐싱**: 반복 요청 5분-1시간 캐싱
- **배치 처리**: 임베딩 100개씩 배치

### 에러 처리
- **3회 재시도**: 지수 백오프 적용
- **폴백 전략**: AI 실패 → 랜덤 선택
- **서비스 연속성**: 에러 시에도 기본값 반환

## 🚀 사용 예시

### 콘텐츠 검열
```javascript
const { validateContentWithGenkit } = require('./ai/contentModeration');

const result = await validateContentWithGenkit({
  userId: 'user123',
  questionTitle: '어떤 음식이 더 맛있나요?',
  titleA: '피자',
  titleB: '치킨',
  imageUrlA: 'https://storage.../pizza.jpg',
  imageUrlB: 'https://storage.../chicken.jpg'
});

if (!result.isValid) {
  console.log('차단 사유:', result.reason);
  console.log('개선 제안:', result.suggestions);
}
```

### 사용자 추천
```javascript
const { getAIRecommendedUsers } = require('./ai/userRecommendation');

const recommendedUsers = await getAIRecommendedUsers(
  postData,
  candidateUsers,
  100  // 목표 사용자 수
);

// AI 점수별 분포
recommendedUsers.forEach(user => {
  console.log(`${user.id}: ${user.aiScore}점 - ${user.aiReasons.join(', ')}`);
});
```

## 📊 모니터링 대시보드

### 실시간 메트릭
```javascript
{
  tokenUsage: {
    moderation: { input: 50000, output: 10000 },
    recommendation: { input: 100000, output: 30000 }
  },
  performance: {
    moderation: { avgLatency: 1200, successRate: 98.5 },
    recommendation: { avgLatency: 2500, successRate: 95.2 }
  }
}
```

## ⚙️ 환경 설정

### API 키 설정
```bash
# Firebase Functions 설정
firebase functions:config:set google.genai_api_key="YOUR_KEY"

# 로컬 개발 (.env)
GOOGLE_GENAI_API_KEY=your_key_here
```

### 필수 Firestore 인덱스
```
컬렉션: posts
- userInfo.userRef (ASC)
- timestamp (DESC)

컬렉션: aiOperationLogs
- operation (ASC)
- timestamp (DESC)

컬렉션: aiUsageLogs
- timestamp (ASC)
```

## 🔍 문제 해결

### 일반적인 문제

1. **API 키 오류**
```
Error: API key not valid
```
- 환경 변수 확인
- Firebase config 확인
- API 키 권한 확인

2. **인덱스 오류**
```
Error: The query requires an index
```
- Firebase Console에서 인덱스 생성
- userHistoryAnalyzer.js 주석 참조

3. **토큰 한도 초과**
```
Error: Token limit exceeded
```
- 입력 텍스트 길이 제한
- 배치 크기 조정
- 캐싱 활용

## 📈 성능 지표

### 현재 성능
- **콘텐츠 검열**: 평균 1.2초, 성공률 98.5%
- **사용자 추천**: 평균 2.5초, 성공률 95.2%
- **캐시 히트율**: 약 40-60%
- **일일 토큰 사용**: 약 500K-1M 토큰

### 비용 최적화
- Flash 모델 우선 사용 (10배 저렴)
- 캐싱으로 반복 요청 절감
- Display 이미지로 토큰 절약
- 배치 처리로 API 호출 최소화

## 📝 변경 이력

### 2025-08-20: Genkit 통합
- Google Genkit 프레임워크 도입
- 통합 AI 설정 시스템 구축
- 토큰 사용량 추적 구현

### 2025-08-19: 사용자 추천 시스템
- AI 기반 매칭 알고리즘 구현
- 임베딩 생성 및 유사도 계산
- 점수 기반 순위 시스템

### 2025-08-18: 콘텐츠 검열 v4.0
- 얼굴 평가 특별 감지 로직 추가
- 예상 투표 비율 추론 기능
- Vision API 통합 강화

## 🎯 향후 계획

### 단기 (1-2개월)
1. **Gemini 2.0 마이그레이션**
2. **실시간 스트리밍 응답**
3. **캐시 레이어 Redis 도입**

### 장기 (3-6개월)
1. **커스텀 모델 학습**
2. **다국어 지원 확대**
3. **이미지 생성 AI 통합**
4. **엣지 캐싱 구현**

## 🔗 관련 문서

### 프로젝트 문서
- [Firebase Functions 전체 구조](../README.md)
- [알림 시스템](../notifications/README.md)
- [네이밍 컨벤션](../../../NAMING_CONVENTION.md)

### 외부 참조
- [Google Genkit 문서](https://firebase.google.com/docs/genkit)
- [Gemini API 가이드](https://ai.google.dev/tutorials/rest_quickstart)
- [Firebase Functions 베스트 프랙티스](https://firebase.google.com/docs/functions/bestpractices)

---

*이 디렉토리는 Versus Space의 핵심 AI 엔진으로, 콘텐츠 품질과 사용자 경험의 중추적 역할을 담당합니다.*