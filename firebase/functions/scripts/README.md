# 투표 데이터 마이그레이션 가이드

## 개요
이 스크립트는 AI 채팅 메시지의 투표 데이터를 기존 형식에서 새로운 `user_votes` Map 구조로 마이그레이션합니다.

### 기존 구조 (deprecated)
```javascript
{
  user_voted: true,
  vote_choice: "A",
  vote_participated_at: Timestamp
}
```

### 새 구조
```javascript
{
  user_votes: {
    "userId1": {
      option: "A",
      voted_at: Timestamp
    },
    "userId2": {
      option: "B", 
      voted_at: Timestamp
    }
  }
}
```

## 사용 방법

### 1. 사전 준비
1. Firebase 서비스 계정 키를 다운로드하고 `service-account-key.json`으로 저장
   - Firebase Console → 프로젝트 설정 → 서비스 계정 → 새 비공개 키 생성
   - `firebase/functions/service-account-key.json`에 저장
   - **중요**: 이 파일을 절대 Git에 커밋하지 마세요!

2. 의존성 설치
```bash
cd firebase/functions
npm install
```

### 2. 실행 옵션

#### 테스트 실행 (DRY RUN)
실제로 데이터를 변경하지 않고 어떤 작업이 수행될지 확인:
```bash
node scripts/migrate-vote-data.js --dry-run
```

#### 제한된 수의 메시지만 처리
```bash
node scripts/migrate-vote-data.js --dry-run --limit=10
```

#### 실제 마이그레이션 실행
```bash
node scripts/migrate-vote-data.js
```

#### 특정 수만큼 실제 마이그레이션
```bash
node scripts/migrate-vote-data.js --limit=100
```

### 3. 단계별 실행 권장사항

1. **먼저 DRY RUN으로 테스트**
   ```bash
   node scripts/migrate-vote-data.js --dry-run --limit=10
   ```

2. **소량 데이터로 실제 테스트**
   ```bash
   node scripts/migrate-vote-data.js --limit=5
   ```

3. **결과 확인 후 전체 실행**
   ```bash
   node scripts/migrate-vote-data.js
   ```

## 출력 예시

```
=== 투표 데이터 마이그레이션 시작 ===
모드: DRY RUN (테스트)
처리 제한: 10개

📋 메시지 마이그레이션 시작...

채팅방 처리 중: ai_assistant_user123
  🔄 메시지 msg456: 마이그레이션 필요
     - sender_id: user123
     - vote_choice: A
     - user_votes: {"user123":{"option":"A","voted_at":...}}
     🧪 DRY RUN - 실제로 업데이트하지 않음

=== 마이그레이션 완료 ===
전체 메시지: 10
마이그레이션됨: 3
스킵됨: 7
오류: 0
```

## 주의사항

1. **백업**: 마이그레이션 전 Firestore 백업을 권장합니다
2. **시간**: 대량의 데이터가 있을 경우 시간이 걸릴 수 있습니다
3. **비용**: Firestore 읽기/쓰기 작업에 대한 비용이 발생할 수 있습니다
4. **중복 실행 안전**: 이미 마이그레이션된 데이터는 자동으로 스킵됩니다

## 롤백 방법

만약 문제가 발생하면:
1. Firebase Console에서 수동으로 복원
2. 또는 백업 데이터에서 복원

## 검증

마이그레이션 후 앱에서:
1. 기존 투표 메시지가 제대로 표시되는지 확인
2. 새로운 투표가 정상 작동하는지 확인
3. 투표 상태가 올바르게 표시되는지 확인