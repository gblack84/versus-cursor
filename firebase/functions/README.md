# Firebase Functions

Versus Space 앱의 서버리스 백엔드 로직을 담당하는 Firebase Cloud Functions입니다.

## 디렉토리 구조

```
firebase/functions/
├── config/           # 설정 파일
├── functions/        # 개별 함수 구현
├── services/         # 공통 서비스 레이어
├── notifications/    # 알림 시스템
├── ai/              # AI 통합 (Genkit)
├── utils/           # 유틸리티 함수
└── index.js         # 함수 엔트리 포인트
```

## 주요 변경사항 (2025-07-31)

### 컬렉션 이름 정규화
- 모든 Firebase Functions에서 `_record` 접미사 제거
- Flutter 앱과 일치하도록 컬렉션 이름 통일
- 예시: `users_record` → `users`, `posts_record` → `posts`

### 영향받은 컬렉션
- `users_record` → `users`
- `posts_record` → `posts`
- `notifications_record` → `notifications`
- `chats_record` → `chats`
- `messages_record` → `messages`
- `votes_record` → `votes`

## 활성 함수 목록 (11개)

### 1. 사용자 관리
- **onUserDeleted**: 사용자 삭제 시 관련 데이터 정리

### 2. 콘텐츠 검열
- **checkImageContent**: 이미지 업로드 시 검열 트리거
- **moderateImage**: Vision API를 통한 이미지 검증
- **validatePostContentWithGemini**: AI 기반 콘텐츠 검증

### 3. 알림 시스템
- **onPostCreatedSendNotifications**: 게시물 생성 시 타겟 사용자에게 알림 발송
- **getUserPostingHistory**: 사용자 게시 기록 분석
- **testNotificationSystem**: 알림 시스템 테스트

### 4. 투표 시스템
- **onPostVoteUpdate**: 투표 업데이트 감지
- **processVoteCompletion**: 투표 자동 완료 처리
- **flushThrottleQueue**: 스로틀 큐 처리 (매 1분)
- **checkVoteTimeouts**: 투표 타임아웃 확인 (매 시간)

## 기술 스택

- **Runtime**: Node.js 18
- **Framework**: Firebase Functions v4
- **AI Integration**: Google Genkit
- **Database**: Firestore
- **Storage**: Firebase Storage
- **External APIs**: 
  - Google Cloud Vision API
  - Perspective API
  - Gemini AI

## 환경 변수

필요한 환경 변수는 Firebase Functions config에서 관리됩니다:

```bash
firebase functions:config:set gemini.api_key="YOUR_API_KEY"
firebase functions:config:set perspective.api_key="YOUR_API_KEY"
```

## 배포

```bash
# 전체 Functions 배포
firebase deploy --only functions

# 특정 함수만 배포
firebase deploy --only functions:onPostCreatedSendNotifications

# 환경 변수 확인
firebase functions:config:get
```

## 개발 가이드

1. 로컬 개발 시 Firebase 에뮬레이터 사용 권장
2. 컬렉션 이름은 Flutter 앱과 반드시 일치해야 함
3. 테스트 코드는 별도 브랜치에서 관리

## 성능 최적화

- 콜드 스타트 최소화를 위한 함수 분리
- 배치 처리로 Firestore 작업 최적화
- 병렬 처리로 응답 시간 단축
- 1000명 동시 처리 지원 (< 60초)