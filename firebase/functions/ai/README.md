# AI 시스템 (Genkit 통합)

## 개요

Versus Space의 통합 AI 시스템으로, Google Genkit 프레임워크를 활용하여 콘텐츠 검열과 사용자 추천 기능을 제공합니다.

## 아키텍처

```
ai/
├── config.js               # Genkit 설정 및 모델 정의
├── contentModeration.js    # 콘텐츠 검열 시스템
├── userRecommendation.js   # AI 기반 사용자 매칭
├── cache.js               # AI 응답 캐싱 시스템
└── monitoring.js          # 성능 모니터링 및 로깅
```

## 주요 기능

### 1. 통합 AI 설정 (config.js)

#### 모델 구성
- **콘텐츠 검열**: Gemini 1.5 Flash (빠른 응답 속도)
- **사용자 추천**: Gemini 1.5 Pro (높은 정확도)
- **텍스트 임베딩**: text-embedding-004 (유사도 계산)

#### 토큰 사용량 추적
```javascript
// 토큰 사용량 실시간 모니터링
{
  moderation: { input: 0, output: 0, total: 0 },
  recommendation: { input: 0, output: 0, total: 0 },
  embedding: { total: 0 }
}
```

#### 비용 계산
- Gemini 1.5 Flash: $0.075/1M input, $0.30/1M output
- Gemini 1.5 Pro: $1.25/1M input, $5.00/1M output

### 2. 콘텐츠 검열 (contentModeration.js)

#### 텍스트 검증
```javascript
const result = await validatePostContent({
  questionTitle: "어떤게 더 좋아?",
  titleA: "커피",
  titleB: "차",
  userId: "user123"
});
```

#### 이미지 검증
- Google Cloud Vision API 통합
- 성인/폭력/의료 콘텐츠 감지
- 얼굴 감지 및 평가 차단

#### 검증 프로세스
1. 필수 필드 확인
2. 텍스트 유해성 검사 (Perspective API)
3. AI 논리성 검증 (Gemini)
4. 이미지 안전성 검사 (Vision API)
5. 사용자 이력 확인

### 3. 사용자 추천 (userRecommendation.js)

#### AI 기반 매칭
```javascript
const recommendedUsers = await getAIRecommendedUsers(
  postData,        // 게시물 정보
  candidateUsers,  // 후보 사용자 목록
  targetCount      // 목표 사용자 수
);
```

#### 추천 프로세스
1. **게시물 분석**: 주제, 카테고리, 감정 톤 추출
2. **사용자 프로파일링**: 관심사, 활동 이력 분석
3. **유사도 계산**: 텍스트 임베딩 활용
4. **점수 기반 정렬**: AI 점수로 최적 사용자 선정

#### 추천 기준
- 관심사 일치도 (40%)
- 최근 활동성 (30%)
- 참여 품질 (20%)
- 다양성 보장 (10%)

### 4. 캐싱 시스템 (cache.js)

#### 캐시 전략
- 사용자 프로필: 24시간
- 게시물 분석: 7일
- 추천 결과: 1시간

#### 캐시 키 생성
```javascript
const key = generateCacheKey('recommendation', {
  postId: 'post123',
  targetCount: 100
});
```

### 5. 모니터링 (monitoring.js)

#### 성능 메트릭
- API 응답 시간
- 토큰 사용량
- 에러율 및 재시도
- 캐시 히트율

## 설정 방법

### 1. 환경 변수 설정
```bash
# Firebase Functions 설정
firebase functions:config:set google.genai_api_key="YOUR_GOOGLE_AI_API_KEY"
firebase functions:config:set gemini.api_key="YOUR_GEMINI_API_KEY"
```

### 2. 로컬 개발 환경
```bash
# .env 파일
GOOGLE_GENAI_API_KEY=your_api_key_here
```

### 3. API 키 발급
1. [Google AI Studio](https://makersuite.google.com/app/apikey)에서 API 키 발급
2. Firebase Console에서 Functions 환경 변수 설정

## 사용 예제

### 콘텐츠 검열
```javascript
const { validatePostContent } = require('./ai/contentModeration');

// Firebase Function에서 사용
exports.onPostCreate = functions.firestore
  .document('posts_record/{postId}')
  .onCreate(async (snap, context) => {
    const postData = snap.data();
    
    const validation = await validatePostContent(postData);
    
    if (!validation.isValid) {
      // 검증 실패 처리
      await snap.ref.update({
        status: 'rejected',
        rejectionReason: validation.reason
      });
    }
  });
```

### 사용자 추천
```javascript
const { matchTargetUsers } = require('./notifications/targetMatcher');

// 타겟 오디언스 매칭
const users = await matchTargetUsers({
  type: 'quick',        // AI 추천 모드
  targetCount: 100,     // 목표 사용자 수
  interests: ['게임', '기술']
}, postData);
```

## 테스트 모드

### 관리자/테스터 전용 기능
```javascript
// 테스트 모드 활성화 (role: admin 또는 tester 필요)
const users = await matchTargetUsers({
  type: 'test',
  targetCount: 10  // 본인에게만 10개 알림 전송
}, postData);
```

## 성능 최적화

### 1. 배치 처리
- 여러 요청을 묶어서 처리
- API 호출 횟수 최소화

### 2. 캐싱 활용
- 반복적인 AI 호출 방지
- 응답 시간 단축

### 3. 타임아웃 설정
- 콘텐츠 검열: 5초
- 사용자 추천: 10초

## 보안 고려사항

1. **API 키 관리**
   - 환경 변수로 관리
   - 소스 코드에 하드코딩 금지

2. **접근 제어**
   - Firebase Authentication 연동
   - 역할 기반 접근 제어 (RBAC)

3. **데이터 보호**
   - 민감한 사용자 정보 암호화
   - 최소 권한 원칙 적용

## 에러 처리

### 재시도 정책
- 최대 3회 재시도
- 지수 백오프 적용
- 최종 실패 시 기본값 반환

### 폴백 전략
1. AI 실패 → 랜덤 선택
2. 캐시 실패 → 직접 API 호출
3. 전체 실패 → 서비스 계속 운영

## 향후 계획

1. **모델 업그레이드**
   - Gemini 2.0 마이그레이션
   - 커스텀 모델 학습

2. **기능 확장**
   - 실시간 스트리밍 응답
   - 다국어 지원 강화
   - 이미지 생성 AI 통합

3. **최적화**
   - 엣지 캐싱 도입
   - 분산 처리 시스템
   - 비용 최적화 알고리즘

## 문제 해결

### 일반적인 문제

1. **API 키 오류**
   ```
   Error: API key not valid
   ```
   - 환경 변수 확인
   - API 키 권한 확인

2. **타임아웃 오류**
   ```
   Error: Request timeout
   ```
   - 네트워크 연결 확인
   - 타임아웃 설정 조정

3. **토큰 한도 초과**
   ```
   Error: Token limit exceeded
   ```
   - 입력 텍스트 길이 제한
   - 배치 크기 조정

## 참고 자료

- [Google Genkit 문서](https://firebase.google.com/docs/genkit)
- [Gemini API 가이드](https://ai.google.dev/tutorials/rest_quickstart)
- [Firebase Functions 베스트 프랙티스](https://firebase.google.com/docs/functions/bestpractices)