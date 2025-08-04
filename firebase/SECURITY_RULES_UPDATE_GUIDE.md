# Firebase 보안 규칙 업데이트 가이드

## 업데이트 내용 (2025-08-03)

### 1. 수정된 규칙

#### posts 컬렉션
- AI 채팅 투표 관련 필드 추가:
  - `voteStartTime`: 투표 시작 시간
  - `voteEndTime`: 투표 종료 시간 (10분 타이머)
  - `voteStatus`: 투표 상태 ('active', 'completed')
  - `voteCompleted`: 투표 완료 여부

#### chats 컬렉션
- AI 채팅방 특별 처리 추가
- 필드명 호환성 개선:
  - `last_message_content` (Firebase Functions 사용)
  - `last_message_at` (Firebase Functions 사용)
  - `lastMessageContent` (Flutter 사용)
  - `lastMessageAt` (Flutter 사용)

#### messages 서브컬렉션
- AI 채팅방 메시지 업데이트 권한 추가
- `vote_end_time` 필드 업데이트 허용

## 배포 방법

### 1. Firebase CLI를 통한 배포

```bash
# Firebase CLI 설치 (이미 설치되어 있다면 생략)
npm install -g firebase-tools

# Firebase 로그인
firebase login

# 프로젝트 디렉토리로 이동
cd /Users/g_black/versus-cursor

# 보안 규칙 배포
firebase deploy --only firestore:rules
```

### 2. Firebase Console을 통한 배포

1. [Firebase Console](https://console.firebase.google.com) 접속
2. 프로젝트 선택: `versus-space-1lwwiw`
3. 좌측 메뉴에서 `Firestore Database` 클릭
4. 상단 탭에서 `규칙` 클릭
5. 수정된 규칙 복사/붙여넣기 (`/firebase/firestore.rules` 파일 내용)
6. `게시` 버튼 클릭

## 테스트 방법

### 1. AI 채팅 메시지 생성 테스트

```javascript
// 테스트 계정으로 게시물 생성
// Firebase Functions가 자동으로:
// 1. AI 채팅방 생성
// 2. 투표 메시지 생성
// 3. 타이머 설정
```

### 2. 투표 기능 테스트

1. AI 피클 채팅방 확인
2. 투표 카드 클릭
3. A 또는 B 선택
4. 투표 완료 확인

### 3. 확인 사항

- [ ] AI 채팅방이 생성되는가?
- [ ] 투표 카드가 표시되는가?
- [ ] 투표가 정상적으로 저장되는가?
- [ ] 10분 타이머가 작동하는가?
- [ ] 중복 투표가 방지되는가?

## 문제 해결

### 권한 오류 발생 시

1. Firebase Console에서 규칙 확인
2. 브라우저 개발자 도구에서 에러 메시지 확인
3. 필요시 추가 필드 권한 부여

### 일반적인 오류 메시지

- `Missing or insufficient permissions`: 보안 규칙이 업데이트를 차단
- `The field ... is not allowed`: 해당 필드가 보안 규칙에 없음

## 롤백 방법

문제 발생 시 이전 버전으로 롤백:

1. Firebase Console > Firestore > 규칙
2. 우측 상단 `규칙 기록` 클릭
3. 이전 버전 선택 후 `복원`

## 모니터링

배포 후 24시간 동안 모니터링:
- Firebase Console > Firestore > 사용량
- 오류 로그 확인
- 사용자 피드백 수집