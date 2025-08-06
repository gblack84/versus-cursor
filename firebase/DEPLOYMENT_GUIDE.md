# Firebase Functions 배포 가이드

## AI 채팅 투표 시스템 업데이트 배포

### 변경사항 요약
- `aiChatService.js`의 `updateVoteParticipation` 함수가 새로운 `user_votes` Map 구조를 사용하도록 업데이트됨
- 기존 deprecated 필드 제거

### 배포 전 체크리스트

1. **코드 검토**
   - [ ] `firebase/functions/services/aiChatService.js` 변경사항 확인
   - [ ] 다른 함수들이 영향받지 않는지 확인

2. **로컬 테스트** (선택사항)
   ```bash
   cd firebase/functions
   npm run serve
   ```

3. **마이그레이션 준비**
   - [ ] 서비스 계정 키 다운로드 (`service-account-key.json`)
   - [ ] 마이그레이션 스크립트 테스트 실행
   ```bash
   npm run migrate:test
   ```

### 배포 절차

#### 1단계: Firebase Functions 배포
```bash
cd firebase
firebase deploy --only functions:aiChatService
```

또는 모든 함수 배포:
```bash
firebase deploy --only functions
```

#### 2단계: 배포 확인
```bash
# 로그 확인
firebase functions:log

# 또는 실시간 로그
firebase functions:log --follow
```

#### 3단계: 데이터 마이그레이션

**⚠️ 중요**: Functions 배포가 성공한 후에 실행하세요.

1. **테스트 실행**
   ```bash
   cd firebase/functions
   npm run migrate:dry
   ```

2. **소량 실제 테스트**
   ```bash
   npm run migrate:run -- --limit=5
   ```

3. **전체 마이그레이션**
   ```bash
   npm run migrate:run
   ```

### 배포 후 검증

1. **Flutter 앱에서 테스트**
   - [ ] 새로운 투표 생성 및 알림 발송
   - [ ] 투표 참여 후 상태 확인
   - [ ] AI 채팅에서 투표 카드 상태 확인
   - [ ] 기존 투표 메시지들이 정상 표시되는지 확인

2. **Firebase Console에서 확인**
   - Firestore에서 `chats/{chatId}/messages` 컬렉션 확인
   - `user_votes` 필드가 올바르게 설정되었는지 확인

### 롤백 방법

문제 발생 시:

1. **이전 버전으로 롤백**
   ```bash
   # Functions 콘솔에서 이전 버전 선택하여 롤백
   # 또는 이전 코드로 재배포
   ```

2. **데이터 복원**
   - Firestore 백업에서 복원 (백업이 있는 경우)
   - 수동으로 데이터 수정

### 트러블슈팅

#### Functions 배포 실패
- Firebase CLI 최신 버전 확인: `npm install -g firebase-tools`
- 프로젝트 권한 확인
- `firebase login` 다시 실행

#### 마이그레이션 스크립트 오류
- 서비스 계정 키 파일 확인
- Node.js 버전 확인 (14+ 권장)
- 네트워크 연결 확인

#### 앱에서 오류 발생
- Functions 로그 확인
- Firestore 데이터 구조 확인
- Flutter 앱 재시작

### 모니터링

배포 후 24시간 동안:
- Functions 오류율 모니터링
- 사용자 피드백 수집
- 성능 메트릭 확인

## 연락처

문제 발생 시 개발팀에 연락하세요.