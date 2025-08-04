# Functions

개별 Firebase Functions 구현 디렉토리입니다.

## 디렉토리 구조

```
functions/
├── firestore/      # Firestore 트리거 함수
├── scheduled/      # 스케줄 함수
└── storage/        # Storage 트리거 함수
```

## Firestore 트리거 함수

### onPostCreatedSendNotifications.js
- **트리거**: `posts/{postId}` 문서 생성 시
- **기능**: 타겟 오디언스에게 알림 발송
- **변경사항**: `posts_record` → `posts` 컬렉션 사용

### onPostVoteUpdate.js
- **트리거**: `posts/{postId}` 문서 업데이트 시
- **기능**: 투표 완료 여부 확인 및 처리
- **스로틀링**: 0.5초 배치 처리

### onUserDeleted.js
- **트리거**: `users/{userId}` 문서 삭제 시
- **기능**: 사용자 관련 데이터 정리

## Storage 트리거 함수

### checkImageContent.js
- **트리거**: Storage 이미지 업로드 시
- **기능**: Vision API로 이미지 검열
- **메타데이터**: sessionId, userId 확인

## 스케줄 함수

### scheduled/flushThrottleQueue.js
- **스케줄**: 매 1분마다 실행
- **기능**: 10분 타이머 만료된 투표 자동 완료 처리

## 함수 작성 가이드

1. **네이밍**: 동작을 명확히 나타내는 이름 사용
2. **에러 처리**: try-catch로 모든 에러 처리
3. **로깅**: 중요 작업마다 로그 남기기
4. **성능**: 콜드 스타트 최소화 고려
5. **컬렉션명**: Flutter 앱과 일치하는 이름 사용 (no _record suffix)