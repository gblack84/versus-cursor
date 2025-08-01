# Configuration

Firebase Functions 설정 관리 디렉토리입니다.

## 파일 목록

### genkit.config.js
Google Genkit Framework 설정 파일입니다.

**주요 설정:**
- AI 모델: Gemini 1.5 Pro
- 플러그인: Google AI, Dotprompt
- 로깅: 개발/프로덕션 환경별 설정
- 토큰 사용량 추적

**사용 예시:**
```javascript
const { genkit } = require('./config/genkit.config');

// AI 플로우 정의
const myFlow = genkit.defineFlow({
  name: 'myFlow',
  inputSchema: z.object({ text: z.string() }),
  outputSchema: z.object({ result: z.string() })
}, async (input) => {
  // AI 로직
});
```

## 환경별 설정

### 개발 환경
- 상세 로깅 활성화
- 에러 스택 트레이스 포함
- 토큰 사용량 콘솔 출력

### 프로덕션 환경
- 최소 로깅
- 토큰 사용량 Firestore 저장
- 성능 최적화 설정

## 보안 고려사항

- API 키는 Firebase Functions config에 저장
- 환경 변수로 민감한 정보 관리
- 프로덕션에서는 보안 강화 설정 적용