# 투표 시스템 통합 테스트 계획

## 테스트 환경 설정

### 1. Firebase 로컬 에뮬레이터
```bash
# Firebase 에뮬레이터 시작
firebase emulators:start --only firestore,functions,auth

# Functions 로그 확인
firebase functions:log --only flushThrottleQueue
```

### 2. 테스트 계정 준비
- 테스트 계정 5개 이상 생성
- admin/tester 역할 계정 1개

## 테스트 시나리오

### 시나리오 1: AI 예상 비율 저장 확인
1. **게시물 생성**
   - 질문: "아침에 커피 vs 차 어떤 걸 선호하시나요?"
   - 예상 결과: AI가 커피에 높은 비율 예상 (예: 70:30)

2. **확인 사항**
   - Firestore `posts` 컬렉션 확인
   - `moderation.expected_ratio_a/b` 필드 존재 여부
   - 값이 0.5가 아닌 다른 값인지 확인

### 시나리오 2: 소수 투표 테스트 (1-5명)
1. **설정**
   - 3명이 투표 (2명 A, 1명 B)
   - 실제 비율: 67:33
   - AI 예상: 85:15

2. **예상 결과**
   - 가중치: 0.38 (38% 실제, 62% AI)
   - 최종: 약 78:22

3. **확인 방법**
   ```javascript
   // Firebase Functions 로그에서 확인
   "[투표 증폭] 실제 투표: 3명, 가중치: 0.38"
   "[투표 증폭] 최종 비율 - A: 78%, B: 22%"
   ```

### 시나리오 3: 중간 투표 테스트 (10명)
1. **설정**
   - 10명이 투표 (6명 A, 4명 B)
   - 실제 비율: 60:40
   - AI 예상: 85:15

2. **예상 결과**
   - 가중치: 0.62 (62% 실제, 38% AI)
   - 최종: 약 70:30

### 시나리오 4: GlobalNotificationManager 투표 테스트
1. **테스트 절차**
   - 알림 모드로 게시물 생성
   - 다른 계정으로 알림 받기
   - 알림에서 투표하기

2. **확인 사항**
   - `votedUserIDsA/B` 배열에 사용자 ID 추가 확인
   - 중복 투표 방지 확인

### 시나리오 5: 극단적 케이스
1. **AI와 실제가 반대인 경우**
   - AI 예상: A 90%, B 10%
   - 실제 투표: A 30%, B 70%
   - 5명 투표 시 최종 결과 확인

2. **0명 투표**
   - AI 예상만으로 100명 분배
   - 랜덤 변동 적용 확인

## 검증 체크리스트

### Flutter 앱
- [ ] 게시물 생성 시 AI 예상 비율 저장
- [ ] 알림 투표가 실제로 저장됨
- [ ] 중복 투표 방지 동작

### Firebase Functions
- [ ] 10분 후 정확히 트리거
- [ ] AI 예상 비율 읽기
- [ ] 가중치 공식 올바르게 적용
- [ ] 최종 결과 100명으로 증폭

### 데이터 일관성
- [ ] votedUserIDsA/B 정확성
- [ ] displayVotesA/B 계산 정확성
- [ ] AI 채팅 메시지 상태 업데이트

## 모니터링 포인트

### 실시간 로그
```bash
# Functions 로그 필터링
firebase functions:log | grep "투표"
```

### Firestore 모니터링
1. posts 컬렉션
   - `moderation.expected_ratio_a/b`
   - `votedUserIDsA/B`
   - `voteCompleted`
   - `displayVotesA/B`

2. ai_chats 컬렉션
   - messages 서브컬렉션의 cardStatus

## 성능 메트릭

### 목표 지표
- 투표 저장 지연: < 500ms
- 10분 처리 정확도: ±30초
- AI 예상 생성 시간: < 3초

### 부하 테스트
- 동시 투표: 50명
- 동시 게시물: 10개
- 에러율: < 1%

## 롤백 계획

문제 발생 시:
1. `flushThrottleQueue`의 expectedRatio 파라미터 제거
2. `calculateDisplayVotes`의 이전 버전 복원
3. `GlobalNotificationManager`의 투표 로직 주석 처리

## 배포 전 최종 확인

1. [ ] 모든 테스트 시나리오 통과
2. [ ] 로그에 에러 없음
3. [ ] 데이터 일관성 확인
4. [ ] 성능 지표 만족
5. [ ] 문서화 완료