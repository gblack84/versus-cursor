# Firebase Functions Services Documentation

Firebase Functions의 서비스 레이어로, 백엔드 비즈니스 로직을 담당합니다.

## 📋 서비스 개요

### 1. **AI Chat Service** (`aiChatService.js`)
AI 피클과의 채팅 메시지 생성 및 관리를 담당합니다.

#### 주요 기능
- AI 채팅방 생성 및 관리
- 투표 요청 메시지 생성
- 투표 결과 메시지 업데이트
- 멀티이미지 지원

#### 핵심 메서드
```javascript
// AI와의 1:1 채팅방 ID 생성 (2025-08-03 수정됨)
function getAIChatId(userId) {
  // 기존: return [AI_ASSISTANT_ID, userId].sort().join('_');
  // 문제: JavaScript sort()가 대소문자를 다르게 정렬
  // 수정: 일관된 형식 사용
  return `${AI_ASSISTANT_ID}_${userId}`;
}

// 투표 요청 메시지 생성 (투표 받는 사람용)
async function createVoteRequestMessage(userId, postId, postData) {
  // 1. AI 채팅방 생성/확인
  // 2. 투표 카드 메시지 생성
  // 3. 10분 타이머 설정
  // 4. 알림과 연동
}

// 투표 생성 메시지 (작성자용)
async function createVoteCreatedMessage(userId, postId, postData) {
  // 작성자에게 진행 상태 메시지
  // 실시간 투표 현황 업데이트
}

// 투표 결과 업데이트 (투표 완료 시)
async function updateVoteResultMessages(postId, voteResults) {
  // 모든 참여자의 AI 채팅 메시지 업데이트
  // cardStatus: 'completed'로 변경
  // 최종 투표 결과 표시
}
```

#### 메시지 필드
- `messageType`: 'voteRequest' | 'voteCreated' | 'voteResult'
- `cardStatus`: 'votingRequest' | 'inProgress' | 'completed'
- `voteOptionAImages[]`: A 옵션 이미지 배열
- `voteOptionBImages[]`: B 옵션 이미지 배열
- `voteEndTime`: 10분 타이머 종료 시간

### 2. **Vote Management Service** (`voteManagement.js`)
투표 완료 처리 및 상태 업데이트를 담당합니다.

#### 주요 기능
- 투표 완료 시 전체 참여자 상태 업데이트
- AI 채팅방 메시지 상태 변경
- 결과 알림 생성
- 배치 처리로 성능 최적화

#### 핵심 메서드
```javascript
// 투표 완료 처리
async function processVoteCompletion(postId, voteResults) {
  // 1. 관련 알림 조회
  // 2. 참여자 목록 수집
  // 3. AI 채팅 메시지 업데이트
  // 4. 결과 알림 생성
  // 5. 배치 처리 실행
}
```

**참고**: 이 함수는 내부적으로만 사용되며 직접 export되지 않습니다.

### 3. **Notification Service** (`notificationService.js`)
스마트 알림 전송을 담당합니다.

#### 주요 기능
- 타겟 오디언스별 알림 전송
- AI 기반 사용자 매칭
- 알림 생성 및 관리

#### 타겟 모드
- **quick**: AI가 최적 사용자 추천
- **public**: 무작위 활성 사용자
- **custom**: 필터 기반 선택
- **test**: 개발/테스트용

### 4. **Text Moderation Service** (`textModeration.js`)
Perspective API를 통한 텍스트 검열을 담당합니다.

#### 검사 항목
- TOXICITY: 유해성
- PROFANITY: 욕설
- THREAT: 위협
- INSULT: 모욕
- IDENTITY_ATTACK: 신원 공격

### 5. **Image Moderation Service** (`imageModeration.js`)
Cloud Vision API를 통한 이미지 검열을 담당합니다.

#### 검사 항목
- ADULT: 성인 콘텐츠
- VIOLENCE: 폭력적 콘텐츠
- RACY: 선정적 콘텐츠

## 🔄 서비스 간 상호작용

### 게시물 생성 플로우
```
1. onPostCreatedSendNotifications 트리거
   ↓
2. AI 채팅 메시지 생성 (aiChatService)
   ↓
3. 스마트 알림 전송 (notificationService)
   ↓
4. 타이머 시작 (10분)
```

### 투표 완료 플로우
```
1. onPostVoteUpdate 감지
   ↓
2. 투표 완료 확인
   ↓
3. processVoteCompletion 호출
   ↓
4. 모든 참여자 업데이트
```

## 📊 성능 최적화

- **배치 처리**: 500개씩 묶어서 처리
- **병렬 실행**: Promise.all()로 독립 작업 병렬화
- **캐싱**: 자주 사용되는 데이터 캐싱

## 🛠️ 서비스 설계 원칙

1. **단일 책임**: 각 서비스는 하나의 도메인만 담당
2. **재사용성**: 여러 함수에서 공통으로 사용 가능
3. **테스트 가능**: 의존성 주입으로 테스트 용이
4. **에러 처리**: 명확한 에러 메시지와 로깅

## 🔧 주요 문제 해결 사례

### AI 채팅방 ID 생성 문제 (2025-08-03)

#### 문제 상황
- Android/Web에서 AI 채팅 메시지가 표시되지 않음 (iOS는 정상)
- JavaScript `sort()` 함수가 대소문자를 다르게 정렬하여 ID 불일치 발생

#### 원인 분석
```javascript
// 문제가 된 코드
const chatId = [AI_ASSISTANT_ID, userId].sort().join('_');

// 예시:
// userId가 'abc123'인 경우: ai_assistant_abc123 ✅
// userId가 'Abc123'인 경우: Abc123_ai_assistant ❌
```

#### 해결 방법
```javascript
// 수정된 코드
const chatId = `${AI_ASSISTANT_ID}_${userId}`;

// 항상 일관된 형식: ai_assistant_userId
```

#### 마이그레이션
- `migrateAIChatRooms` 함수로 기존 채팅방 ID 형식 통일
- 기존 메시지 보존하면서 새로운 형식으로 이전
- Flutter 앱과 완벽한 호환성 확보