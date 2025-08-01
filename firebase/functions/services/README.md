# Services

공통 비즈니스 로직을 담당하는 서비스 레이어입니다.

## 서비스 목록

### aiChatService.js
AI 기반 투표 요청 채팅 메시지를 생성하고 관리하는 서비스입니다.

**주요 기능:**
- 투표 요청 메시지 생성
- 기존 채팅방 확인 및 생성
- 투표 상태 업데이트
- 진행 중 메시지 삭제

**컬렉션 사용:**
- `chats` (이전 `chats_record`)
- `messages` (이전 `messages_record`)

### 사용 예시

```javascript
const { createVoteRequestMessage } = require('./services/aiChatService');

// 투표 요청 메시지 생성
await createVoteRequestMessage({
  senderId: 'systemUser123',
  recipientId: 'targetUser456',
  postData: {
    id: 'post789',
    question: '어떤 것이 더 좋나요?',
    titleA: '옵션 A',
    titleB: '옵션 B'
  }
});
```

## 서비스 설계 원칙

1. **단일 책임**: 각 서비스는 하나의 도메인만 담당
2. **재사용성**: 여러 함수에서 공통으로 사용 가능
3. **테스트 가능**: 의존성 주입으로 테스트 용이
4. **에러 처리**: 명확한 에러 메시지와 로깅

## 향후 추가 예정 서비스

- UserService: 사용자 관리 로직
- NotificationService: 알림 발송 로직
- ModerationService: 콘텐츠 검열 로직